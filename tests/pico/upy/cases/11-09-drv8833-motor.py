PROGRAM = '01-circuits/11-microcontrollers/09-drv8833-motor-1.py'
BUDGET_US = 6_500_000


def duty_at(log, t):
    d = None
    for tt, f, du in log:
        if tt <= t:
            d = (f, du)
    return d


def check(S, out, ok):
    a, b = S.pwm[14]['log'], S.pwm[15]['log']
    for t, da, db, what in [(1_000_000, 65535, 32768, '前進 50 %'), (2_500_000, 65535, 65535, 'ブレーキ'),
                            (4_000_000, 32768, 65535, '後進 50 %'), (5_500_000, 65535, 65535, 'ブレーキ')]:
        fa, ua = duty_at(a, t)
        fb, ub = duty_at(b, t)
        ok(fa == 20_000 and fb == 20_000, f'{what}: 20 kHz')
        ok(ua == da and ub == db, f'{what}: AIN1 {ua}・AIN2 {ub}')
