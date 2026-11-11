// 11-regs-at.mjs : 13-11 の数を取る。ls / の途中で Logic Analyzer を止め、ring の書き戻しの記録と
// 止まった時の写しから、ring の中のいくつかの時点の x0〜x31 を組み立てる。何本分かるかを数え、
// 分かった値を「保存した所から全部の書き戻しを追った値」と比べる
//
//   node 11-regs-at.mjs <soft-fpga-riscv-linux の場所> [0|1] [idle]
//     0 毎クロック (既定)、1 事象のあるクロックだけ。idle を付けると、ls を打たずに寝ている所で止める
//
// 要る物は 09-trace-lib.mjs の頭。組み立て方は <repo>/web/regs-panel.js の _xAt と同じ決まり:
//   1. その時点 t までに書いた記録が ring にあれば、最後の記録の値
//   2. 無ければ、止まった時の写しの値。ただし t より後に書き込みがあれば使えない (分からない = ?)
// (トリガーが発火した時の写しと、途切れの印はここでは使わない。止めるのは 1 度だけなので途切れは無い)
import { openSim, sig } from './09-trace-lib.mjs';

const mode = Number(process.argv[3] ?? 0);
const idle = process.argv[4] === 'idle';   // idle: ls を打たず、wfi で寝ている所で止める (書き込みがほとんど無い ring)
const { sim, run, send, ringSize: RS, ringWords: RW } = await openSim(process.argv[2]);
const NR = sim._sim_reg_count();
const readWindow = () => { const p = sim._sim_regs() >>> 2; return sim.HEAPU32.slice(p, p + NR * 2); };

// 追う値: 始めにレジスタの窓を読み、あとは書き戻しを全部当てる
const x = readWindow().slice(0, 64);
const hist = new Map();   // サンプルの通し番号 → そのサンプルの後の x (直近 RS 個だけ持つ)
let serial = sim._get_head() >>> 0;
const track = (w) => {
  if (sig.rdWe(w) && sig.rd(w)) { x[2 * sig.rd(w)] = w[6]; x[2 * sig.rd(w) + 1] = w[7]; }
  const r2 = w[9] >>> 27;
  if (r2) { x[2 * r2] = w[15]; x[2 * r2 + 1] = w[16]; }
  hist.set(serial, x.slice());
  hist.delete(serial - RS);
  serial++;
  return false;
};
sim._sim_set_sample_mode(mode);
run(3_000_000, track);
if (!idle) {
  send('ls /\n');
  run(2_000_000, track);   // ls の子が動いている最中
}
sim._sim_freeze_ring();
const snap = readWindow();
const head = sim._get_head() >>> 0;
if (head !== serial) throw new Error('lost samples');
const rb = sim._get_ring_ptr() >>> 2, ring = sim.HEAPU32.slice(rb, rb + RS * RW);
const word = (s, k) => ring[(s & (RS - 1)) * RW + k] >>> 0;
const lastCycle = word(head - 1, 14);
const incl = (sim._sim_regs_cycle() % 4294967296) !== lastCycle;   // 写しが最後のサンプルの書き込みを含むか
console.log(`mode ${mode}${idle ? ' idle' : ''}: ring ${RS} x ${RW} words = ${RS * RW * 4} bytes, window ${NR} regs`);
console.log(`frozen at clock ${lastCycle}, ring spans ${lastCycle - word(head - RS, 14) + 1} clocks, snapshot ${incl ? 'after' : 'on'} the last sample`);

// ring の中の書き込み (レジスタごと、古い順)
const writes = Array.from({ length: 32 }, () => []);
let nWrites = 0;
for (let s = head - RS; s < head; s++) {
  if ((word(s, 0) >>> 13) & 1) { writes[word(s, 9) & 31].push({ s, lo: word(s, 6), hi: word(s, 7) }); nWrites++; }
  const r2 = word(s, 9) >>> 27;
  if (r2) { writes[r2].push({ s, lo: word(s, 15), hi: word(s, 16) }); nWrites++; }
}
console.log(`writebacks in the ring: ${nWrites}, registers written at least once: ${writes.filter((w, r) => r && w.length).length} of 31`);

const xAt = (t) => {
  const out = [{ known: true, lo: 0, hi: 0, from: 'zero' }];
  const end = incl ? head - 1 : head - 2;
  for (let r = 1; r < 32; r++) {
    let last = null;
    for (const w of writes[r]) { if (w.s <= t) last = w; else break; }
    if (last) { out.push({ known: true, lo: last.lo, hi: last.hi, from: 'ring' }); continue; }
    const clean = !writes[r].some((w) => w.s > t && w.s <= end);
    out.push(clean ? { known: true, lo: snap[2 * r], hi: snap[2 * r + 1], from: 'snap' } : { known: false });
  }
  return out;
};
let bad = 0;
for (const back of [0, 100, 1000, 4000, 8000, 12000, 14000, 15000, 16000, 16300, RS - 1]) {
  const t = head - 1 - back, xs = xAt(t), truth = hist.get(t);
  const ring_ = xs.filter((v) => v.from === 'ring').length, snap_ = xs.filter((v) => v.from === 'snap').length;
  const unknown = xs.filter((v) => !v.known).length;
  let wrong = 0;
  // 最後のサンプルの書き込みは、写しにまだ入っていないことがある (次の立ち上がりで入る)。記録が優先なので比べられる
  xs.forEach((v, r) => { if (v.known && (v.lo !== truth[2 * r] || v.hi !== truth[2 * r + 1])) wrong++; });
  bad += wrong;
  console.log(`T=-${String(back).padStart(5)} (clock ${word(t, 14)}): from ring ${String(ring_).padStart(2)}, from snapshot ${String(snap_).padStart(2)}, unknown ${String(unknown).padStart(2)}, wrong ${wrong}`);
}
// レジスタの窓はクロックを動かさない: 読む前後でクロック数が同じで、2 度読んで同じ値
const c0 = sim._sim_cycle();
sim._sim_thaw_ring();
const a = readWindow(), b = readWindow();
console.log(`window read twice while running: same ${a.every((v, i) => v === b[i])}, clock moved ${sim._sim_cycle() - c0}`);
console.log(bad === 0 ? 'PASS' : `FAIL ${bad}`);
process.exit(bad ? 1 : 0);
