PROGRAM = '02-analog-discovery/07-logic/23-clock-overshoot-ringing-1.py'
BUDGET_US = 2_500_000


def check(S, out, ok):
    p = S.pwm[16]
    ok(p['freq'] == 100_000, f'100 kHz: {p["freq"]}')
    ok(p['duty'] == 32768, f'Duty 50 % (32768): {p["duty"]}')
