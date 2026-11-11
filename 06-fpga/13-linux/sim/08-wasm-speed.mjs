// 13-8: Wasm 版の模型を Node で回し、速さ [クロック/秒] を測る
//
//   SIM_MJS=<soft-fpga-riscv-linux>/build/mmrisc2/wasm/sim.mjs \
//     node 08-wasm-speed.mjs <保存ファイル .state.gz> [--la-off] [--out=<出た字を書くファイル>] [打つ行 ...]
//
// soft-fpga-riscv-linux の sim/wasm/run-node.mjs と同じ手順 (プロンプトに合わせて行を打ち、尽きた後の
// プロンプトで止まる) で、違いは 2 つ: --la-off で Logic Analyzer の ring への記録を止められる、
// 出た字の SHA-256 を出す (PC 版の出力と比べる)。打つ行の既定は 'ls /' と 'cat /proc/cpuinfo'。
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { gunzipSync } from 'node:zlib';

const STOP_NONE = 0;
const STOP_PROMPT = 1;
const CHUNK = 200000;        // sim_run 1 回の上限 [クロック]
const MAX_CYCLES = 200e6;

const args = process.argv.slice(2);
const laOff = args.includes('--la-off');
const outPath = args.find((a) => a.startsWith('--out='))?.slice(6) ?? null;
const [statePath, ...rest] = args.filter((a) => a !== '--la-off' && !a.startsWith('--out='));
if (!statePath || !process.env.SIM_MJS) {
    console.error('usage: SIM_MJS=<sim.mjs> node 08-wasm-speed.mjs <state.gz> [--la-off] [line ...]');
    process.exit(1);
}
const lines = rest.length > 0 ? rest : ['ls /', 'cat /proc/cpuinfo'];

const { default: createSim } = await import(pathToFileURL(resolve(process.env.SIM_MJS)).href);
const sim = await createSim({ print: () => {} });   // 模型の $display は捨てる

let t0 = performance.now();
const raw = readFileSync(statePath);
sim.stateBytes = statePath.endsWith('.gz') ? gunzipSync(raw) : raw;
sim.stateOffset = 0;
const tRead = (performance.now() - t0) / 1000;
t0 = performance.now();
if (sim._sim_restore() !== 0) process.exit(1);
sim.stateBytes = null;
const tRestore = (performance.now() - t0) / 1000;
if (laOff) sim._sim_set_la(0);

const hash = createHash('sha256');
let chars = 0;
const outChunks = [];
const flushOut = () => {
    const len = sim._sim_out_len();
    if (len === 0) return;
    const bytes = sim.HEAPU8.slice(sim._sim_out_ptr(), sim._sim_out_ptr() + len);
    hash.update(bytes);
    outChunks.push(bytes);
    chars += len;
    sim._sim_out_clear();
};

const cycle0 = sim._sim_cycle();
t0 = performance.now();
let sentAny = false;
let leftPrompt = false;
let stop = sim._sim_run(0);
for (;;) {
    if (stop === STOP_NONE) leftPrompt = true;
    if (stop !== STOP_NONE && stop !== STOP_PROMPT) break;
    if (stop === STOP_PROMPT && (!sentAny || leftPrompt)) {
        if (lines.length === 0) break;
        for (const ch of Buffer.from(lines.shift() + '\n')) sim._sim_send(ch);
        sentAny = true;
        leftPrompt = false;
    }
    if (sim._sim_cycle() - cycle0 > MAX_CYCLES) break;
    stop = sim._sim_run(CHUNK);
    flushOut();
}
flushOut();
if (outPath) writeFileSync(outPath, Buffer.concat(outChunks));
const cycles = sim._sim_cycle() - cycle0;
const secs = (performance.now() - t0) / 1000;
console.log(`wasm${laOff ? ' la-off' : ''}: gunzip ${tRead.toFixed(2)} s, restore ${tRestore.toFixed(2)} s, ` +
            `stop cycle ${sim._sim_cycle()}, ${cycles} cycles in ${secs.toFixed(1)} s, ${Math.round(cycles / secs)} cycles/s, ` +
            `${chars} chars, sha256 ${hash.digest('hex').slice(0, 16)}, heap ${(sim.HEAPU8.length / 2 ** 20).toFixed(0)} MiB`);
