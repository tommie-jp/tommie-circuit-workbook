PROGRAM = '06-fpga/00-tools/04-ad3-logic-connect-1.py'
BUDGET_US = 10_000


def check(S, out, ok):
    ok(S.inits[14]['mode'] == 1 and S.inits[15]['mode'] == 1, 'GP14・GP15 は出力')
    b0 = [(t, v) for t, p, v in S.events if p == 14]
    ok(all(b[0] - a[0] == 1000 for a, b in zip(b0, b0[1:])), 'bit0 は 1 ms ごとに反転 (2 進カウンタの最下位)')
    b1 = [(t, v) for t, p, v in S.events if p == 15]
    ok(all(b[0] - a[0] == 2000 for a, b in zip(b1, b1[1:])), 'bit1 は 2 ms ごとに反転')
