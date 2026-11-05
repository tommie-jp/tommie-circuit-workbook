PROGRAM = '02-analog-discovery/07-logic/24-jitter-1.py'
BUDGET_US = 20_000


def check(S, out, ok):
    p = S.pwm[18]
    ok(p['freq'] == 10_000 and p['duty'] == 32768, f'PWM 10 kHz・50 %: {p["freq"]} {p["duty"]}')
    t = [e[0] for e in S.events if e[1] == 16]
    d = {b - a for a, b in zip(t, t[1:])}
    ok(len(t) > 100 and d == {50}, f'GP16 は 50 µs ごとに反転: {len(t)} 回、間隔 {sorted(d)[:5]}')
