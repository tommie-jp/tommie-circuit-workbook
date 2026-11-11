// 09-trace-lib.mjs : 13-9・13-10 の共通の道具。Wasm の模型を Node で読み戻し、ring の全サンプルを順に渡す
//
// 要る物 (公開リポジトリ tommie-jp/soft-fpga-riscv-linux の fd1efd5 で確かめた):
//   <repo>/build/mmrisc2/wasm/sim.mjs   make wasm で作る
//   <repo>/state/mmrisc2-*.state.gz     make linux-sd-save と make state-gz で作る (PC で約 14 分)
//   <repo>/web/rv-disasm.js             命令を読む (RVDIS)
//
// ring は 16384 サンプルしか残らないので、8000 クロックずつ回しては新しいサンプルを読む。
// 語の並びは <repo>/sim/wasm/harness.cpp の頭のコメント (1 サンプル 17 語)。
import { readFileSync, readdirSync } from 'node:fs';
import { gunzipSync } from 'node:zlib';
import { pathToFileURL } from 'node:url';
import { resolve, join } from 'node:path';

export const EXC = { 0: 'i-misalign', 1: 'i-fault', 2: 'illegal', 3: 'ebreak', 4: 'l-misalign', 5: 'l-fault',
  6: 's-misalign', 7: 's-fault', 8: 'ecall-U', 9: 'ecall-S', 11: 'ecall-M', 12: 'i-page', 13: 'l-page', 15: 's-page' };
export const IRQ = { 1: 'S-soft', 3: 'M-soft', 5: 'S-timer', 7: 'M-timer', 9: 'S-ext', 11: 'M-ext', 13: 'PMU' };
export const INSN_SRET = 0x10200073;
export const INSN_WFI = 0x10500073;

// 語から信号を取り出す (la-defs.js と同じ場所)
export const sig = {
  retire: (w) => w[0] & 1,
  trap: (w) => (w[0] >>> 1) & 1,
  priv: (w) => (w[0] >>> 3) & 3,          // 0 U、1 S、3 M
  dtlb: (w) => (w[0] >>> 6) & 1,
  memRd: (w) => (w[0] >>> 7) & 1,
  tx: (w) => (w[0] >>> 11) & 1,
  rx: (w) => (w[0] >>> 12) & 1,
  rdWe: (w) => (w[0] >>> 13) & 1,
  toS: (w) => (w[0] >>> 14) & 1,
  cause: (w) => { const c = (w[0] >>> 16) & 0xff; return (c & 0x80) ? IRQ[c & 0x7f] : (EXC[c & 0x7f] ?? 'exc' + (c & 0x7f)); },
  ch: (w) => String.fromCharCode(w[0] >>> 24),
  pc: (w) => w[1] >>> 0,
  insn: (w) => w[2] >>> 0,
  rd: (w) => w[9] & 31,
  rdLo: (w) => w[6] >>> 0,
  sext: (w) => (w[9] >>> 8) & 1,
  pending: (w) => (w[9] >>> 9) & 1,
  sie: (w) => (w[9] >>> 10) & 1,
  claim: (w) => (w[9] >>> 24) & 1,
  satp: (w) => w[10] >>> 0,
  epc: (w) => w[11] >>> 0,
  cycle: (w) => w[14] >>> 0,
};

export async function openSim(repo) {
  if (!repo) {
    console.error('usage: node <script>.mjs <soft-fpga-riscv-linux の場所>');
    process.exit(1);
  }
  globalThis.window = globalThis;
  (0, eval)(readFileSync(join(repo, 'web/rv-disasm.js'), 'utf8'));   // RVDIS を置く
  const { default: createSim } = await import(pathToFileURL(resolve(repo, 'build/mmrisc2/wasm/sim.mjs')).href);
  const sim = await createSim();
  const gz = readdirSync(join(repo, 'state')).filter((f) => f.endsWith('.state.gz')).sort()[0];
  if (!gz) throw new Error('state/*.state.gz が無い (make linux-sd-save と make state-gz)');
  sim.stateBytes = gunzipSync(readFileSync(join(repo, 'state', gz)));
  sim.stateOffset = 0;
  if (sim._sim_restore() !== 0) throw new Error('restore');
  sim.stateBytes = null;
  const RS = sim._get_ring_size(), RW = sim._get_ring_words();
  const CHUNK = 8000;   // ring (16384) より短く
  let seen = sim._get_head() >>> 0;
  // 最大 n クロック回し、新しいサンプルを 1 つずつ cb(語の並び) に渡す。cb が true を返したらやめる
  const run = (n, cb) => {
    // sim_run は stop_code が変わると早く返るので、回したクロックは sim_cycle で数える
    const end = sim._sim_cycle() + n;
    while (sim._sim_cycle() < end) {
      sim._sim_run(Math.min(CHUNK, end - sim._sim_cycle()));
      const head = sim._get_head() >>> 0, rb = sim._get_ring_ptr() >>> 2;
      let stop = false;
      for (let s = seen; s < head; s++) {
        const b = rb + (s & (RS - 1)) * RW;
        if (cb(sim.HEAPU32.subarray(b, b + RW))) stop = true;
      }
      seen = head;
      if (stop) return true;
    }
    return false;
  };
  const send = (text) => { for (const c of Buffer.from(text)) sim._sim_send(c); };
  return { sim, run, send, state: gz, ringSize: RS, ringWords: RW };
}
