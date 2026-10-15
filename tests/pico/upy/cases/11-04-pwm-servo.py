PROGRAM = '01-circuits/11-microcontrollers/04-pwm-led-servo-2.py'
BUDGET_US = 3_000_000


def check(S, out, ok):
    p = S.pwm[14]
    ok(p['freq'] == 50, f'50 Hz = 20 ms: {p["freq"]}')
    highs = [d / 65535 / f * 1e3 for _, f, d in p['log'] if f and d]   # ms
    ok(len(highs) == 3, f'パルス幅は 3 回設定: {highs}')
    for want, got in zip((1.5, 1.0, 2.0), highs):
        ok(abs(got - want) < 0.001, f'パルス幅 {want} ms: {got:.4f} ms')
