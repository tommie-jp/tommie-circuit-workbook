PROGRAM = '02-analog-discovery/07-logic/21-pico-adc-linearity-1.py'
BUDGET_US = 63_500_000
PAT = [2047, 2048, 2049, 2048]
T0 = []


def setup(S):
    def fn(t):
        if not T0:
            T0.append(t)
        return PAT[((t - 10) // 100) % 4] << 4   # read_u16 は変換に 10 µs を足してから値を返す
    S.adc_fn[0] = fn


def check(S, out, ok):
    lines = out.splitlines()
    ok(T0 and 3_000_000 <= T0[0] < 3_000_200, f'3 s 待ってから読み始める: {T0}')
    ok(lines and lines[0] == 'N 600000 mean 2048.00 sd 0.71 V 1.6500', f'1 行目: {lines[:1]}')
    ok(lines[1:4] == ['2047 150000', '2048 300000', '2049 150000'], f'度数: {lines[1:4]}')
