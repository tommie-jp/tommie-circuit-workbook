// 13-12: 保存した所から SD カードを直に読ませ、読み 1 回ごとの時刻を ring から取る
//
//   SIM_MJS=<soft-fpga-riscv-linux>/build/mmrisc2/wasm/sim.mjs \
//     node 12-sd-read-trace.mjs <保存ファイル .state.gz> [読むブロック数 (4 KB 単位、既定 64)] > reads.csv
//
// 環境変数 FUNCS に「名前=番地,名前=番地,...」(番地は 16 進。模型の中の /proc/kallsyms から取る) を渡すと、
// コマンドを出してから次のコマンドを出すまでに入った関数 (その番地の命令が退役した) を、入った順に CSV の最後の欄に書く。
//
// 模型 (Wasm 版) を 2000 クロックずつ回し、そのたびに Logic Analyzer の ring の新しいサンプルを読む。
// 各コマンドについて、出してから 200 クロックの間・次の刻みまで・次のコマンドまでに退役した命令の数も数える。
// 見るのは語 0 (トラップと原因・退役)、語 2 (命令)、語 9 (SD の状態・コマンド済み・データ済み)、語 14 (クロック数)。
// dd の行を打ってからプロンプトが戻るまでの、SD のコマンド 1 回ごとの時刻を CSV (標準出力) に、まとめを標準エラーに出す。
// 時刻は dd の行を打った時からの模型の時間 [ms] (クロックは 50 MHz、1 クロック = 20 ns)。
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { gunzipSync } from 'node:zlib';

const CLOCK_HZ = 50e6;
const CHUNK = 2000;            // ring (16384 サンプル) より短く回す
const STOP_NONE = 0;
const STOP_PROMPT = 1;
const MAX_CYCLES = 300e6;
const WFI = 0x10500073;
const CAUSE_S_TIMER = 5;       // 割り込みの原因: S モードのタイマー
const CAUSE_S_EXT = 9;         // 割り込みの原因: S モードの外部 (PLIC。UART と SD)
const SD_IDLE = 0;

const [statePath, countArg] = process.argv.slice(2);
if (!statePath || !process.env.SIM_MJS) {
    console.error('usage: SIM_MJS=<sim.mjs> node 12-sd-read-trace.mjs <state.gz> [count]');
    process.exit(1);
}
const count = Number(countArg ?? 64);
const lines = ['echo 3 > /proc/sys/vm/drop_caches', `dd if=/dev/mmcblk0 of=/dev/null bs=4096 count=${count}`];

const { default: createSim } = await import(pathToFileURL(resolve(process.env.SIM_MJS)).href);
const sim = await createSim({ print: () => {} });   // 模型の $display (@@PC など) は捨てる
const raw = readFileSync(statePath);
sim.stateBytes = statePath.endsWith('.gz') ? gunzipSync(raw) : raw;
sim.stateOffset = 0;
if (sim._sim_restore() !== 0) process.exit(1);
sim.stateBytes = null;

const ringSize = sim._get_ring_size();
const ringWords = sim._get_ring_words();
const ringBase = sim._get_ring_ptr() >>> 2;
let seen = sim._get_head() >>> 0;

// 見ている間 (dd の行を打ってから) の記録
let tracing = false;
let cycle0 = 0;
let prevSd = SD_IDLE;
let prevCmdDone = 0;
let prevDataDone = 0;
const funcs = new Map((process.env.FUNCS ?? '').split(',').filter(Boolean).map((kv) => {
    const [name, addr] = kv.split('=');
    return [Number(BigInt('0x' + addr) & 0xffffffffn), name];   // ring の PC は下 32 ビット
}));
const reads = [];              // {start, cmdDone, dataDone, sExt, timer, wfiAfter, busyRetired, busyTraps, busyTlb}
const CMD_CLOCKS = 200;        // SD の模型がコマンドと応答にかける長さ (SD_MODEL の CMD_CYCLES)
let cur = null;
const timerIrqs = [];
let retired = 0;
let clocks = 0;
let wfiRetired = 0;

function scan() {
    const head = sim._get_head() >>> 0;
    const heap = sim.HEAPU32;
    for (; seen !== head; seen = (seen + 1) >>> 0) {
        if (!tracing) continue;
        const at = ringBase + (seen & (ringSize - 1)) * ringWords;
        const w0 = heap[at];
        const w9 = heap[at + 9];
        const t = (heap[at + 14] - cycle0) >>> 0;
        clocks++;
        if (w0 & 1) {
            retired++;
            if (cur) cur.retiredAll++;
            if (cur && funcs.size > 0) {
                const name = funcs.get(heap[at + 1]);
                if (name && !cur.funcs.includes(name)) cur.funcs.push(name);
            }
            if (heap[at + 2] === WFI) {
                wfiRetired++;
                if (cur && cur.dataDone !== null && cur.wfiAfter === null) cur.wfiAfter = t;
            }
        }
        const sd = (w9 >>> 18) & 7;
        const cmdDone = (w9 >>> 21) & 1;
        const dataDone = (w9 >>> 22) & 1;
        if (sd !== SD_IDLE && prevSd === SD_IDLE) {
            cur = { start: t, cmdDone: null, dataDone: null, sExt: null, timer: null, wfiAfter: null, busyRetired: 0, busyTraps: 0, busyTlb: 0, funcs: [], retiredAll: 0, retiredAtTimer: null };
            reads.push(cur);
        }
        if (cur && cmdDone && !prevCmdDone && cur.cmdDone === null) cur.cmdDone = t;
        if (cur && dataDone && !prevDataDone && cur.dataDone === null) cur.dataDone = t;
        if (cur && t - cur.start < CMD_CLOCKS) {         // コマンドが済むまでの 200 クロックの CPU の様子
            cur.busyRetired += w0 & 1;
            cur.busyTraps += (w0 >>> 1) & 1;
            cur.busyTlb += ((w0 >>> 5) | (w0 >>> 6)) & 1;
        }
        prevSd = sd;
        prevCmdDone = cmdDone;
        prevDataDone = dataDone;
        if ((w0 & 2) && ((w0 >>> 23) & 1)) {            // 割り込みのトラップ
            const cause = (w0 >>> 16) & 0x7f;
            if (cause === CAUSE_S_TIMER) {
                timerIrqs.push(t);
                if (cur && cur.dataDone !== null && cur.timer === null) {
                    cur.timer = t;
                    cur.retiredAtTimer = cur.retiredAll;   // コマンドを出してから刻みまでに進んだ命令
                }
            } else if (cause === CAUSE_S_EXT && cur && cur.sExt === null) {
                cur.sExt = t;
            }
        }
    }
}

let out = '';
const flushOut = () => {
    const len = sim._sim_out_len();
    if (len > 0) {
        out += Buffer.from(sim.HEAPU8.subarray(sim._sim_out_ptr(), sim._sim_out_ptr() + len)).toString('latin1');
        sim._sim_out_clear();
    }
};

const start = sim._sim_cycle();
let sentAny = false;
let leftPrompt = false;
let stop = sim._sim_run(0);
for (;;) {
    if (stop === STOP_NONE) leftPrompt = true;
    if (stop !== STOP_NONE && stop !== STOP_PROMPT) break;
    if (stop === STOP_PROMPT && (!sentAny || leftPrompt)) {
        if (lines.length === 0) break;
        const line = lines.shift();
        if (lines.length === 0) {                      // 最後の行 (dd) からを見る
            tracing = true;
            cycle0 = sim._sim_cycle() >>> 0;
        }
        for (const ch of Buffer.from(line + '\n')) sim._sim_send(ch);
        sentAny = true;
        leftPrompt = false;
    }
    if (sim._sim_cycle() - start > MAX_CYCLES) break;
    stop = sim._sim_run(CHUNK);
    scan();
    flushOut();
}
scan();
flushOut();
const total = (sim._sim_cycle() >>> 0) - cycle0;

const ms = (c) => (c === null ? '' : ((c * 1000) / CLOCK_HZ).toFixed(4));
console.log('n,start_ms,cmd_done_ms,data_done_ms,s_ext_irq_ms,wfi_ms,timer_irq_ms,next_start_ms,retired_200,traps_200,tlb_miss_200,retired_to_timer,retired_to_next,funcs');
reads.forEach((r, i) => {
    const next = reads[i + 1]?.start ?? null;
    console.log([i + 1, ms(r.start), ms(r.cmdDone), ms(r.dataDone), ms(r.sExt), ms(r.wfiAfter), ms(r.timer), ms(next), r.busyRetired, r.busyTraps, r.busyTlb, r.retiredAtTimer ?? '', r.retiredAll, r.funcs.join(' ')].join(','));
});

const stat = (xs) => {
    const s = [...xs].sort((a, b) => a - b);
    const mean = s.reduce((a, b) => a + b, 0) / s.length;
    return `n=${s.length} mean=${mean.toFixed(3)} median=${s[s.length >> 1].toFixed(3)} min=${s[0].toFixed(3)} max=${s[s.length - 1].toFixed(3)}`;
};
const toMs = (c) => (c * 1000) / CLOCK_HZ;
const withData = reads.filter((r) => r.dataDone !== null && r.dataDone > r.cmdDone);   // データの無いコマンドは 2 つが同時に立つ
const gaps = reads.slice(1).map((r, i) => toMs(r.start - reads[i].start));
const ticks = timerIrqs.slice(1).map((t, i) => toMs(t - timerIrqs[i]));
console.error(out.replace(/\r/g, ''));
console.error(`dd line to prompt: ${total} clocks = ${toMs(total).toFixed(1)} ms of model time`);
console.error(`SD commands: ${reads.length}, with a data transfer: ${withData.length}`);
console.error(`retired ${retired} in ${clocks} recorded clocks (${(retired / clocks).toFixed(3)} per clock), wfi retired ${wfiRetired}`);
console.error(`S timer interrupts: ${timerIrqs.length}, interval [ms]: ${stat(ticks)}`);
console.error(`command start to next command start [ms]: ${stat(gaps)}`);
console.error(`start -> cmd done [ms]: ${stat(reads.filter((r) => r.cmdDone !== null).map((r) => toMs(r.cmdDone - r.start)))}`);
console.error(`start -> data done [ms]: ${stat(withData.map((r) => toMs(r.dataDone - r.start)))}`);
const slept = withData.filter((r) => r.timer !== null && reads[reads.indexOf(r) + 1]);
console.error(`data done -> next S timer interrupt [ms]: ${stat(slept.map((r) => toMs(r.timer - r.dataDone)))}`);
console.error(`S timer interrupt -> next command start [ms]: ${stat(slept.map((r) => toMs(reads[reads.indexOf(r) + 1].start - r.timer)))}`);
const noTick = withData.filter((r) => { const n = reads[reads.indexOf(r) + 1]; return n && (r.timer === null || r.timer > n.start); });
console.error(`commands followed by the next command before any timer interrupt: ${noTick.length}`);
