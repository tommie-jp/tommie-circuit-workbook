PROGRAM = '01-circuits/11-microcontrollers/03-adc-cds-1.py'
BUDGET_US = 1_100_000


def setup(S):
    S.adc_fn[0] = lambda t: 32768


def check(S, out, ok):
    lines = out.splitlines()
    ok(len(lines) == 3, f'500 ms ごと (1.1 s で 3 行): {len(lines)}')
    ok(lines[0].startswith('32768 1.6500'), f'32768 → 1.65 V: {lines[0]!r}')
