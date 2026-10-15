PROGRAM = '01-circuits/11-microcontrollers/01-pico-blink-1.py'
BUDGET_US = 5_200_000


def check(S, out, ok):
    ev = [e for e in S.events if e[1] == 15]
    ok(len(ev) >= 10, f'反転が少ない: {len(ev)}')
    ok(all(b[0] - a[0] == 500_000 for a, b in zip(ev, ev[1:])), '反転の間隔が 500 ms でない')
    ok(ev and ev[0][2] == 1 and ev[0][0] == 0, '最初は H で点灯する')
