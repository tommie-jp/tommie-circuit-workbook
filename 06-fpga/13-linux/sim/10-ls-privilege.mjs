// 10-ls-privilege.mjs : 13-10 の数を取る。ls / を打ち、プロンプトが戻るまでの特権 (U / S / M) の行き来・
// トラップ・システムコールを数える
//
//   node 10-ls-privilege.mjs <soft-fpga-riscv-linux の場所> [-v] [--zoom getpid]
//
// 要る物は 09-trace-lib.mjs の頭。-v を付けると、システムコールを 1 つずつ出す。
// --zoom <名前> で、その名前の最初のシステムコールの中 (トラップ・SIE・sret・特権の変わり目) を出す。
// システムコールの番号は a7 (x17)。ecall のトラップの時点の a7 を、ring の書き戻しの記録
// (退役した命令が書いたレジスタと値) を追って求める。番号の名前は Linux の asm-generic の表 (riscv64)。
import { openSim, sig, INSN_SRET } from './09-trace-lib.mjs';

const SYSCALL = { 17: 'getcwd', 23: 'dup', 24: 'dup3', 25: 'fcntl', 29: 'ioctl', 48: 'faccessat', 56: 'openat', 57: 'close',
  61: 'getdents64', 62: 'lseek', 63: 'read', 64: 'write', 66: 'writev', 73: 'ppoll', 78: 'readlinkat', 79: 'newfstatat',
  80: 'fstat', 93: 'exit', 94: 'exit_group', 96: 'set_tid_address', 99: 'set_robust_list', 113: 'clock_gettime', 115: 'clock_nanosleep',
  129: 'kill', 134: 'rt_sigaction', 135: 'rt_sigprocmask', 139: 'rt_sigreturn', 154: 'setpgid', 155: 'getpgid',
  160: 'uname', 167: 'prctl', 172: 'getpid', 173: 'getppid', 174: 'getuid', 175: 'geteuid', 176: 'getgid', 177: 'getegid',
  214: 'brk', 215: 'munmap', 220: 'clone', 221: 'execve', 222: 'mmap', 226: 'mprotect', 260: 'wait4',
  261: 'prlimit64', 278: 'getrandom', 291: 'statx', 293: 'rseq' };
const verbose = process.argv.includes('-v');
const { sim, run, send, state } = await openSim(process.argv[2]);
console.log('state', state);
run(3_000_000, () => false);   // wfi で寝る所まで空回し

const LINE = 'ls /\n';
send(LINE);
const x = new Array(32).fill(null);   // 書き戻しの記録から追った x レジスタ (下 32 ビット)
let t0 = null, rxCount = 0, out = '', done = false, lastPriv = 1, lastT = 0;
const n = { retired: { U: 0, S: 0, M: 0 }, traps: {}, toM: 0, sret: 0, sretToU: 0, sretToS: 0, tx: 0 };
const syscalls = {};        // 名前 → 回数
const calls = [];           // { T, satp, name, back } back = U に戻るまでのクロック
const satpSeen = new Map(); // satp → { firstT, retiredU }
const uRuns = [];           // U モードで続けて退役した命令の数
let uRun = 0, open = null;
const med = (a) => { const s = [...a].sort((p, q) => p - q); return s.length ? s[s.length >> 1] : 0; };

// 「事象のあるクロックだけ」なら記録されるサンプルを数える (harness.cpp の worth_recording と同じ条件)
let evSamples = 0, prevSlow = '';
// --zoom <名前>: その名前の最初のシステムコールの、ecall のトラップから U に戻るまでを 1 行ずつ出す
const zoomName = process.argv.includes('--zoom') ? process.argv[process.argv.indexOf('--zoom') + 1] : null;
let zoom = null, zoomDone = false, prevW = null;
run(40_000_000, (w) => {
  if (done) return true;
  {
    const slow = [w[0] & 0x07e0, w[9] & 0x03fc0fe0, w[13]].join(',');
    if (t0 !== null && ((w[0] & 0x1803) || (w[9] >>> 27) || slow !== prevSlow)) evSamples++;
    prevSlow = slow;
  }
  if (sig.rdWe(w)) x[sig.rd(w)] = sig.rdLo(w);
  if (w[9] >>> 27) x[w[9] >>> 27] = w[15] >>> 0;
  if (sig.rx(w)) { if (t0 === null) t0 = sig.cycle(w); rxCount++; }
  if (t0 === null) return false;
  const T = sig.cycle(w) - t0;
  lastT = T;
  if (sig.trap(w)) {
    const c = sig.cause(w);
    n.traps[c] = (n.traps[c] ?? 0) + 1;
    if (!sig.toS(w)) n.toM++;
    if (c === 'ecall-U') {
      const name = x[17] === null ? '?' : (SYSCALL[x[17]] ?? 'sys' + x[17]);
      syscalls[name] = (syscalls[name] ?? 0) + 1;
      open = { T, satp: sig.satp(w), name, a0: x[10], back: null, retiredAtTrap: !!sig.retire(w) };
      calls.push(open);
    }
  }
  if (sig.tx(w)) { n.tx++; out += sig.ch(w); }
  if (sig.retire(w)) {
    const p = sig.priv(w);
    n.retired['US?M'[p]]++;
    if (sig.insn(w) === INSN_SRET) { n.sret++; if (p === 0) n.sretToU++; else n.sretToS++; }
    if (p === 0) {
      // sret が退役したサンプルの Priv はもう U。その次からがユーザーの命令
      if (sig.insn(w) !== INSN_SRET) {
        uRun++;
        const s = sig.satp(w);
        if (!satpSeen.has(s)) satpSeen.set(s, { firstT: T, firstPc: sig.pc(w), retiredU: 0 });
        satpSeen.get(s).retiredU++;
      }
      if (open && open.back === null && T > open.T) open.back = T - open.T;   // トラップと同じクロックの退役は前の命令
    } else if (lastPriv === 0 && uRun > 0) { uRuns.push(uRun); uRun = 0; }
    lastPriv = p;
  } else if (sig.trap(w) && uRun > 0) { uRuns.push(uRun); uRun = 0; }
  if (zoomName && !zoomDone) {
    if (!zoom && open && open.name === zoomName && open.T === T) { zoom = { T0: T, retired: 0 }; console.log(`--- zoom ${zoomName}: T=0 is the ecall trap (ls T=${T}), a7=${x[17]}`); }
    if (zoom) {
      const t = T - zoom.T0, ev = [];
      if (sig.trap(w)) ev.push(`trap ${sig.cause(w)} to ${sig.toS(w) ? 'S' : 'M'} epc ${sig.epc(w).toString(16)}`);
      if (prevW && sig.sie(w) !== sig.sie(prevW)) ev.push('SIE=' + sig.sie(w));
      if (sig.retire(w)) {
        zoom.retired++;
        const p = 'US?M'[sig.priv(w)], line = `${sig.pc(w).toString(16)} ${RVDIS.disasm(sig.insn(w), sig.pc(w))} [${p}]`;
        if (zoom.retired <= 3 || sig.insn(w) === INSN_SRET || (prevW && zoom.lastP !== p)) ev.push(`retire #${zoom.retired} ${line}`);
        if (sig.priv(w) === 0 && sig.insn(w) !== INSN_SRET && t > 0) { ev.push(`back in U after ${zoom.retired - 1} kernel insns`); zoomDone = true; }
        zoom.lastP = p;
      }
      if (ev.length) console.log(`  t=${t}  ` + ev.join(' | '));
    }
  }
  prevW = Array.from(w);
  // 終わり: 打った行のエコーと ls の出力の後に、プロンプト "# " が出た
  if (rxCount === LINE.length && out.endsWith('\n# ') && out.includes('usr')) done = true;
  return done;
});

console.log(`ls / : ${lastT} clocks from the first key to the prompt, ${n.tx} chars out`);
console.log(`samples in the events-only mode: ${evSamples} (${(lastT / evSamples).toFixed(2)} clocks per sample)`);
console.log('retired', JSON.stringify(n.retired), 'total', n.retired.U + n.retired.S + n.retired.M);
console.log('traps', JSON.stringify(n.traps), 'to M:', n.toM);
console.log(`sret ${n.sret} (to U ${n.sretToU}, to S ${n.sretToS})`);
console.log(`U-mode runs: ${uRuns.length}, median ${med(uRuns)} insns, max ${Math.max(...uRuns)}, first ${uRuns[0]}`);
console.log('system calls', calls.length, JSON.stringify(Object.fromEntries(Object.entries(syscalls).sort((a, b) => b[1] - a[1]))));
const backs = calls.filter((c) => c.back !== null).map((c) => c.back);
console.log(`ecall -> back in U: median ${med(backs)} clocks, min ${Math.min(...backs)}, max ${Math.max(...backs)}`);
const sameClock = calls.filter((c) => c.retiredAtTrap).length;
console.log(`ecall traps with a retire on the same clock: ${sameClock}`);
for (const [s, v] of satpSeen) console.log(`satp ${s.toString(16).padStart(8, '0')}: first U retire T=${v.firstT} pc ${v.firstPc.toString(16)}, ${v.retiredU} U insns`);
for (const name of ['clone', 'execve', 'getdents64', 'exit_group', 'wait4']) {
  const c = calls.filter((k) => k.name === name);
  console.log(`${name}: ${c.map((k) => `T=${k.T} satp ${k.satp.toString(16)} back ${k.back}`).join('; ')}`);
}
if (verbose) for (const c of calls) console.log(`T=${c.T} satp ${c.satp.toString(16)} ${c.name} a0=${c.a0?.toString(16)} back ${c.back}`);
console.log('uart out:', JSON.stringify(out));
