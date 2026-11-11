// 09-key-to-irq.mjs : 13-9 の数を取る。1 字 (l) を UART に入れ、割り込み → トラップ → カーネル → ash → エコー
// までの事象を、字が入ったクロックを T=0 として並べる
//
//   node 09-key-to-irq.mjs <soft-fpga-riscv-linux の場所>
//
// 要る物は 09-trace-lib.mjs の頭。保存した所 (最初のプロンプト) から 300 万クロック空回しして、
// CPU が wfi で寝ている所へ字を入れる。同じ保存ファイルなら毎回同じ数になる。
import { openSim, sig, INSN_SRET, INSN_WFI } from './09-trace-lib.mjs';

const { sim, run, send, state } = await openSim(process.argv[2]);
console.log('state', state, 'restored at cycle', sim._sim_cycle());

// 空回し: タイマーの刻みだけが来る
let idle = { retired: 0, traps: {}, wfi: 0 };
run(3_000_000, (w) => {
  if (sig.retire(w)) { idle.retired++; if (sig.insn(w) === INSN_WFI) idle.wfi++; }
  if (sig.trap(w)) idle.traps[sig.cause(w)] = (idle.traps[sig.cause(w)] ?? 0) + 1;
});
console.log(`idle 3000000 clocks: ${idle.retired} retired, wfi ${idle.wfi}, traps ${JSON.stringify(idle.traps)}`);

send('l');
let t0 = null, prev = null, retired = 0, lastPriv = 1, sawTx = false, done = false, lastRetireT = 0;
const first = {};   // 最初に起きた T
const count = { traps: {}, sret: 0, sretToU: 0, dtlb: 0, memRd: 0, retiredU: 0, retiredS: 0, retiredM: 0 };
const at6000 = {};
const note = (name, T, extra = '') => {
  if (first[name] !== undefined) return;
  first[name] = T;
  console.log(`T=${String(T).padStart(6)}  ${name}${extra ? '  ' + extra : ''}  (retired ${retired})`);
};
run(400_000, (w) => {
  if (done) return true;
  if (sig.rx(w) && t0 === null) t0 = sig.cycle(w);
  if (t0 === null) { prev = Array.from(w); return false; }
  const T = sig.cycle(w) - t0;
  if (T === 6001 && at6000.retired === undefined) Object.assign(at6000, { retired, dtlb: count.dtlb, memRd: count.memRd });
  if (sig.rx(w)) note('RX', T, `char ${JSON.stringify(sig.ch(w))}`);
  if (prev && sig.sext(w) && !sig.sext(prev)) note('SExt rises', T);
  if (prev && sig.pending(w) && !sig.pending(prev)) note('Pending rises', T);
  if (prev && sig.sie(w) && !sig.sie(prev)) note('SIE rises', T);
  if (sig.trap(w)) {
    const c = sig.cause(w);
    count.traps[c] = (count.traps[c] ?? 0) + 1;
    note('Trap ' + c, T, `to ${sig.toS(w) ? 'S' : 'M'}, epc ${sig.epc(w).toString(16)}`);
  }
  if (prev && sig.claim(w) && !sig.claim(prev)) note('PLIC claim', T);
  if (prev && !sig.sext(w) && sig.sext(prev)) note('SExt falls', T);
  if (sig.dtlb(w)) count.dtlb++;
  if (sig.memRd(w)) count.memRd++;
  if (sig.tx(w)) { note('TX (echo)', T, `char ${JSON.stringify(sig.ch(w))}`); sawTx = true; }
  if (sig.retire(w)) {
    retired++;
    const p = sig.priv(w), insn = sig.insn(w);
    count[p === 0 ? 'retiredU' : p === 1 ? 'retiredS' : 'retiredM']++;
    if (retired === 1) note('first retire', T, `${sig.pc(w).toString(16)} ${RVDIS.disasm(insn, sig.pc(w))}`);
    if (insn === INSN_SRET) { count.sret++; note('first sret', T); }
    if (p === 0 && lastPriv !== 0) { count.sretToU++; note('first U-mode retire', T, `pc ${sig.pc(w).toString(16)}`); }
    // エコーの後で wfi が退役した所 = 次に起こされた所。その前の退役までが 1 字の分
    if (insn === INSN_WFI && sawTx && retired > 1) {
      note('last retire before the kernel sleeps in wfi again', lastRetireT);
      note('wfi retires again (woken by the next interrupt)', T);
      done = true;
    }
    lastPriv = p;
    lastRetireT = T;
  }
  prev = Array.from(w);
  return done;
});
console.log(`T<=6000: ${at6000.retired} retired, DTLB-miss clocks ${at6000.dtlb}, memory reads ${at6000.memRd}`);
console.log('until the next wake:', JSON.stringify(count));
console.log('uart out:', JSON.stringify(Buffer.from(sim.HEAPU8.subarray(sim._sim_out_ptr(), sim._sim_out_ptr() + sim._sim_out_len())).toString()));
