PROGRAM = '04-denken/09-rotating-machines/07-stepper-motor-1.py'
BUDGET_US = 12_000_000


def check(S, out, ok):
    ok(all(S.levels.get(p, 0) == 0 for p in (2, 3, 4, 5)), '最後は全相 L')
    seq, state, last = [], 0, None
    for t, p, v in S.events:
        if t != last:
            if last is not None:
                seq.append(state)
            last = t
        state = (state & ~(1 << (p - 2))) | (v << (p - 2))
    ok(seq[:4] == [0x3, 0x6, 0xC, 0x9], f'2 相励磁の並び: {[hex(x) for x in seq[:4]]}')
    ok(10_200_000 <= S.events[-1][0] <= 10_300_000, f'10.24 s で止まる: {S.events[-1][0]}')
