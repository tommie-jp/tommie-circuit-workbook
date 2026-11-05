import math

PROGRAM = '02-analog-discovery/07-logic/26-adc-sampling-alias-1.py'
BUDGET_US = 200_000


def u16(t_us):
    code = round(2048 + 1241 * math.sin(2 * math.pi * 9500 * t_us * 1e-6))   # 9.5 kHz・1 V (peak)
    return code << 4


def setup(S):
    S.adc_fn[0] = u16


def check(S, out, ok):
    p = S.pwm[16]
    ok(p['freq'] == 146_484, f'146,484 Hz: {p["freq"]}')
    log = [(t, d) for t, f, d in p['log'][1:]]
    ok(len(log) > 1000, f'戻した回数: {len(log)}')
    dts = {b[0] - a[0] for a, b in zip(log, log[1:])}
    ok(dts == {100}, f'100 µs ごと: {sorted(dts)[:5]}')
    ok(all(d == u16(t) for t, d in log), '戻す値 = 読んだ値 (変換の 10 µs の時刻)')
    lv = [d >> 6 for _, d in log]
    ok(max(abs(lv[i + 20] - lv[i]) for i in range(len(lv) - 20)) <= 2, '20 標本 (2 ms) で一巡 = 500 Hz')
