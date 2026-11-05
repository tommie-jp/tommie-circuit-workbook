PROGRAM = '02-analog-discovery/07-logic/22-pwm-rc-dac-1.py'
BUDGET_US = 170_000


def check(S, out, ok):
    p = S.pwm[16]
    ok(p['freq'] == 146_484, f'146,484 Hz: {p["freq"]}')
    steps = [(t, d) for t, f, d in p['log'] if f is not None]   # 先頭は PWM(freq=) の記録
    want = [(0, 0), (20_000, 16384), (40_000, 32768), (60_000, 49152), (80_000, 0)]
    ok(steps[1:6] == want, f'0・256・512・768 を 20 ms ずつ: {steps[1:6]}')
    ok(abs(32768 / 65536 - 0.5) < 1e-9, 'レベル 512 → 50 %')
