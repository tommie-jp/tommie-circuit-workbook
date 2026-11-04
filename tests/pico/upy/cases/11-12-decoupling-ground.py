PROGRAM = '01-circuits/11-microcontrollers/12-decoupling-ground-1.py'
BUDGET_US = 1000


def check(S, out, ok):
    p = S.pwm[15]
    ok(p['freq'] == 1_000_000 and p['duty'] == 32768, f'1 MHz・50 %: {p["freq"]} {p["duty"]}')
