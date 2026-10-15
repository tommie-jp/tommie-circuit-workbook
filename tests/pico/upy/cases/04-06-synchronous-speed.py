PROGRAM = '04-denken/09-rotating-machines/06-synchronous-speed-1.py'
BUDGET_US = 2_000_000


def check(S, out, ok):
    rises = {p: [t for t, q, v in S.events if q == p and v == 1] for p in (2, 3, 4)}
    ok(all(len(r) >= 2 for r in rises.values()), '3 相とも立ち上がる')
    f = 1e6 / (rises[2][1] - rises[2][0])
    ok(abs(f - 7.0) < 0.01, f'電源周波数 7 Hz: {f:.4f}')
    step = 1_000_000 // 42
    d = (rises[3][0] - rises[2][0]) % (6 * step)
    ok(abs(d - 2 * step) < 1.5 * step or abs(d - 4 * step) < 1.5 * step, f'V は U から 120°: {d}')
