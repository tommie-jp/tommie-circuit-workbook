#!/usr/bin/env python3
"""層 D: 本文の C プログラムの .uf2 (out/pico-uf2) を picoemu (RP2350・Cortex-M33) に載せ、GPIO の変化を突き合わせる。
wb-picoemu のコンテナの中で動かす (tests/pico/emu/run.sh)。
見るのは出力の並びと、sleep で決まる間隔。命令の速さは模型の値なので、`sleep` を使わない待ちの周期は見ない。
PWM・UART・I2C・ADC は GPIO の変化に出ないので対象外 (層 A が見る)。"""
import os
import subprocess
import sys
import tempfile

UF2 = os.environ.get('UF2_DIR', '/work/out/pico-uf2/build')
FAILS = []


def run(name, steps=20_000_000, clock=150):
    with tempfile.TemporaryDirectory() as d:
        vcd = os.path.join(d, 't.vcd')
        subprocess.run(['picoemu', os.path.join(UF2, name + '.uf2'), '-arch', 'm33', '-clock', str(clock),
                        '-gpio-trace', vcd, '-max-steps', str(steps)], capture_output=True, text=True, timeout=300)
        return parse_vcd(vcd)


def parse_vcd(path):
    ids, t, out = {}, 0, []
    for line in open(path):
        line = line.strip()
        if line.startswith('$var'):
            p = line.split()
            ids[p[3]] = int(p[4].removeprefix('gpio'))
        elif line.startswith('#'):
            t = int(line[1:])
        elif line and line[0] in '01' and line[1:] in ids:
            out.append((t, ids[line[1:]], int(line[0])))
    return [e for e in out if e[0] > 0]


def check(name, cond, detail=''):
    print('%s  %s %s' % ('ok' if cond else 'NG', name, detail))
    if not cond:
        FAILS.append(name)


def intervals(ev, pin, level=None):
    ts = [t for t, p, v in ev if p == pin and (level is None or v == level)]
    return [b - a for a, b in zip(ts, ts[1:])]


def near(xs, want, tol_us):
    return bool(xs) and all(abs(x - want) <= tol_us for x in xs)


def blink(name, label):
    ev = run(name, steps=2_000_000)   # 多いと vcd の時刻が 32 ビットで巻き戻る
    iv = intervals(ev, 15)
    check(f'{label} GP15 は 500 ms ごとに反転', len(iv) >= 4 and near(iv, 500_000, 200), f'{len(iv)} 回, 間隔 {sorted(set(iv))[:3]}')
    check(f'{label} 最初は H', ev[0][1:] == (15, 1))


blink('01-pico-blink-1', '11-1')
blink('02-install-tools-docker-1', '0-2')

ev = run('04-ad3-logic-connect-1')
check('0-4 bit0 は 1 ms ごと', near(intervals(ev, 14), 1000, 100), str(sorted(set(intervals(ev, 14)))[:3]))
check('0-4 bit1 は 2 ms ごと', near(intervals(ev, 15), 2000, 100), str(sorted(set(intervals(ev, 15)))[:3]))

ev = run('06-synchronous-speed-1')
per = intervals(ev, 2, 1)
f = 1e6 / (sum(per) / len(per)) if per else 0
check('9-6 U 相は 7 Hz', abs(f - 7.0) < 0.01, f'{f:.4f} Hz')
rises = {p: [t for t, q, v in ev if q == p and v == 1] for p in (2, 3, 4)}
step = 1_000_000 // 42
d = (rises[3][0] - rises[2][0]) % (6 * step)
check('9-6 V は U から 2 ステップ遅れ (120°)', abs(d - 2 * step) < 1.5 * step or abs(d - 4 * step) < 1.5 * step, f'{d} us')

ev = run('07-stepper-motor-1')
state, last, seq = 0, None, []
for t, p, v in ev:
    if t != last and last is not None:
        seq.append((last, state))
    last = t
    state = (state & ~(1 << (p - 2))) | (v << (p - 2))
first4 = [s for _, s in seq[:4]]
check('9-7 2 相励磁の並び 3,6,C,9', first4 == [0x3, 0x6, 0xC, 0x9], str([hex(x) for x in first4]))
steps = [b[0] - a[0] for a, b in zip(seq, seq[1:])][:200]
check('9-7 ステップは 5 ms (200 Hz)', near(steps, 5000, 100), f'{sorted(set(steps))[:3]}')

print('\n%d 件 NG' % len(FAILS) if FAILS else '\n全件 ok')
sys.exit(1 if FAILS else 0)
