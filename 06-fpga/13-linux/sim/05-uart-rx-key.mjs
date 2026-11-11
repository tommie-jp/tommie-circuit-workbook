// 05-uart-rx-key.mjs : 13-5 の数を取る。保存した所から 1 字 (既定は l) を UART の受信に渡し、
// 1 クロックずつ回して、受信 → 割り込みの線 → トラップ → エコーのクロックを数える。
// 続けて残りの行 (既定は "s /" と改行) を渡し、行の最初の出力とプロンプトまでを数える。
//
//   REPO=<soft-fpga-riscv-linux の場所> [SETTLE=<クロック>] node 05-uart-rx-key.mjs [行 (既定 "ls /")]
//
// SETTLE (既定 3000000) は、読み戻してから 1 字目を渡すまでに回すクロック。保存した所はプロンプトの
// 最後の字を出した直後で、シェルもカーネルもまだ動いている。待ってから打つと、CPU が寝ている所へ届く。
//
// 先に公開リポジトリで make wasm と make state-gz (make wasm-restore でも作られる) を済ませておく。
// ring の語の並びは sim/wasm/harness.cpp の頭のコメント (語 0 の [1] トラップ [2] 割り込み
// [4:3] 特権 [11] UART 送信 [12] UART 受信 [22:16] 原因 [31:24] 字、語 9 の [8:5] 割り込みの線)。
import { readdirSync, readFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { gunzipSync } from 'node:zlib';

const repo = process.env.REPO;
if (!repo) {
  console.error('usage: REPO=<soft-fpga-riscv-linux> node 05-uart-rx-key.mjs [line]');
  process.exit(1);
}
const line = process.argv[2] ?? 'ls /';
const core = process.env.CORE ?? 'mmrisc2';
const stateDir = join(repo, 'state');
const gz = readdirSync(stateDir).find((f) => f.startsWith(core + '-') && f.endsWith('.state.gz'));
if (!gz) {
  console.error(`no ${core}-*.state.gz in ${stateDir} (make state-gz)`);
  process.exit(1);
}
const simMjs = join(repo, 'build', core, 'wasm', 'sim.mjs');
const { default: createSim } = await import(pathToFileURL(resolve(simMjs)).href);
const sim = await createSim();
sim.stateBytes = gunzipSync(readFileSync(join(stateDir, gz)));
sim.stateOffset = 0;
if (sim._sim_restore() !== 0) process.exit(1);
sim.stateBytes = null;

const RS = sim._get_ring_size();
const RW = sim._get_ring_words();
// 最後に書いたサンプル (今回したクロック) の語
const last = () => {
  const ring = new Uint32Array(sim.HEAPU8.buffer, sim._get_ring_ptr(), RS * RW);
  const b = ((sim._get_head() - 1) & (RS - 1)) * RW;
  return Array.from(ring.subarray(b, b + RW));
};
const step = () => { sim._sim_run(1); return last(); };

const start = sim._sim_cycle();
const settle = Number(process.env.SETTLE ?? 3_000_000);
// sim_run は stop_code が変わると途中で返るので、クロック数で数える
while (sim._sim_cycle() < start + settle) sim._sim_run(Math.min(100000, start + settle - sim._sim_cycle()));
console.log(`${gz}: restored at cycle ${start}, first char at cycle ${sim._sim_cycle()} (SETTLE ${settle})`);

// 1 字目
const first = line.charCodeAt(0);
sim._sim_send(first);
const t = {};
let prevIrq = (last()[9] >>> 5) & 15;
let trapsBeforeEcho = 0;
let prevPriv = null;   // 最後に退役した命令の特権モード (0 U、1 S、3 M)
const LIMIT = 2_000_000;
let n = 0;
for (; n < LIMIT; n++) {
  const w = step();
  const rx = (w[0] >>> 12) & 1;
  const tx = (w[0] >>> 11) & 1;
  const trap = (w[0] >>> 1) & 1;
  const ch = w[0] >>> 24;
  const irq = (w[9] >>> 5) & 15;
  if (rx && t.rx === undefined) { t.rx = n; console.log(`+0      rx  '${String.fromCharCode(ch)}' enters the RX FIFO (clock ${n} after the send)`); }
  if (t.rx === undefined) continue;
  const d = n - t.rx;
  if (irq !== prevIrq) {
    console.log(`+${d}  irq lines ${prevIrq.toString(2).padStart(4, '0')} -> ${irq.toString(2).padStart(4, '0')} (bit 3 S ext, 2 M ext, 1 M timer, 0 M soft), priv ${(w[0] >>> 3) & 3}`);
    if (t.irq === undefined && (irq & 8)) t.irq = d;
    prevIrq = irq;
  }
  const priv = (w[0] >>> 3) & 3;
  if (prevPriv !== null && priv !== prevPriv) console.log(`+${d}  priv ${'USHM'[prevPriv]} -> ${'USHM'[priv]}`);
  prevPriv = priv;
  if (trap) {
    const cause = (w[0] >>> 16) & 0x7f;
    const isInt = (w[0] >>> 23) & 1;
    trapsBeforeEcho++;
    console.log(`+${d}  trap ${isInt ? 'interrupt' : 'exception'} cause ${cause}, to ${(w[0] >>> 14) & 1 ? 'S' : 'M'}, from priv ${(w[0] >>> 3) & 3}, epc ${w[11].toString(16)}`);
    if (t.trap === undefined && isInt && cause === 9) t.trap = d;
  }
  if (tx) {
    console.log(`+${d}  tx  '${String.fromCharCode(ch)}' leaves the TX FIFO (echo)`);
    t.echo = d;
    break;
  }
}
console.log(`first char: irq +${t.irq}, trap +${t.trap}, echo +${t.echo} clocks (${trapsBeforeEcho} traps before the echo)`);

// 残りの行
const rest = line.slice(1) + '\n';
for (const c of Buffer.from(rest)) sim._sim_send(c);
let nlAt = null;      // 改行が受信 FIFO に入ったクロック
let firstOut = null;  // 改行のエコーの後、最初に出た字
let prompt = null;
let out = '';
let rxCount = 0;
const c1 = sim._sim_cycle();
for (let i = 0; i < 20_000_000; i++) {
  sim._sim_run(1);
  const w = last();
  const cyc = sim._sim_cycle();
  if ((w[0] >>> 12) & 1) { rxCount++; if ((w[0] >>> 24) === 10) nlAt = cyc; }
  if ((w[0] >>> 11) & 1) {
    const ch = String.fromCharCode(w[0] >>> 24);
    if (nlAt !== null) { out += ch; if (firstOut === null && ch !== '\r' && ch !== '\n') firstOut = cyc; }
  }
  if (nlAt !== null && out.endsWith('\n# ')) { prompt = cyc; break; }
}
console.log(`rest of the line: ${rxCount} chars entered the RX FIFO in ${rxCount} consecutive clocks: ${nlAt - c1 === rxCount ? 'yes' : 'no (' + (nlAt - c1) + ' clocks)'}`);
console.log(`newline at cycle ${nlAt}; first output +${firstOut - nlAt}, prompt +${prompt - nlAt} clocks; ${out.length} chars out`);
console.log(out.replace(/\r/g, ''));
