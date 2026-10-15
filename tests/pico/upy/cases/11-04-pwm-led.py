PROGRAM = '01-circuits/11-microcontrollers/04-pwm-led-servo-1.py'
BUDGET_US = 1_000_000


def check(S, out, ok):
    p = S.pwm[15]
    ok(p['freq'] == 1000, f'1 kHz: {p["freq"]}')
    ok(p['duty'] == 61440, f'最後のデューティ 61440 (= 15 × 4096): {p["duty"]}')
    ok(abs(p['duty'] / 65535 - 0.9375) < 1e-4, 'デューティ 93.75 %')
