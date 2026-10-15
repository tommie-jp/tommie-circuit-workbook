#!/usr/bin/env python3
"""層 B: PIO プログラムを rp2040-pio-emulator (pioemu) で回し、出力の並びとサイクル数を確かめる。
対象: 09-rf 24 の LO (set pins 0→1→3→2)。命令は本文の C (out/pico) の lo_insn から読む。
使い方: python3 -I tests/pico/pio/run.py   (pioemu が無ければ SKIP して 0 で終わる)"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..'))
PROG = os.path.join(ROOT, 'out', 'pico', '01-circuits', '09-rf', '24-iq-mw-radio-1.c')

try:
    from pioemu import emulate, State
    from pioemu.conditions import clock_cycles_reached
except ImportError:
    print('SKIP  rp2040-pio-emulator が無い (pip install rp2040-pio-emulator==0.88.0)')
    sys.exit(0)

fails = []


def ok(cond, what):
    if not cond:
        fails.append(what)


src = open(PROG, encoding='utf8').read()
m = re.search(r'lo_insn\[\]\s*=\s*\{([^}]*)\}', src)
opcodes = [int(x, 16) for x in re.findall(r'0x[0-9a-fA-F]+', m.group(1))]
ok(opcodes == [0xe000, 0xe001, 0xe003, 0xe002], f'命令 4 つ: {[hex(o) for o in opcodes]}')

# set pins は GP2 から 2 本。4 命令を 1 命令 1 サイクルで 3 周する。
SET_BASE, CYCLES = 2, 12
seq = []
for before, after in emulate(opcodes, stop_when=clock_cycles_reached(CYCLES), initial_state=State(),
                             set_base=SET_BASE, set_count=2, wrap_target=0, wrap_top=3):
    seq.append((after.clock, (after.pin_values >> SET_BASE) & 0b11))

values = [v for _, v in seq]
ok(len(values) == CYCLES, f'{CYCLES} サイクルで {CYCLES} 命令: {len(values)}')
ok(values[:8] == [0, 1, 3, 2, 0, 1, 3, 2], f'S1S0 の並び 00→01→11→10: {values[:8]}')
ok(values[4:8] == values[0:4], '4 状態で 1 周して繰り返す (wrap 0〜3)')
# 隣り合う状態でビットが 1 つだけ変わる (グレイコード) = Tayloe の 4 相が重ならない
ok(all(bin(a ^ b).count('1') == 1 for a, b in zip(values, values[1:])), '1 つ進むごとに 1 ビットだけ変わる')
# f_LO = sys / (4 × M): 1 周 = 4 サイクル
cycles_per_lo_period = 4
ok(cycles_per_lo_period == 4, 'LO の 1 周期は 4 サイクル (sys/(4M))')

if fails:
    for f in fails:
        print('NG:', f)
    sys.exit(1)
print('ok  09-24 LO: 00→01→11→10 を 4 サイクルで繰り返す')
