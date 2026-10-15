import math
PROGRAM = '01-circuits/09-rf/23-iq-pico2-adc-1.py'
BUDGET_US = 400_000


def setup(S):
    # I・Q を LO より +1.000 kHz 上の信号 (0.5 V peak、利得 2) として与える
    amp = 0.5 * 2.0 / 3.3 * 65535
    S.adc_fn[0] = lambda t: 32768 + amp * math.cos(2 * math.pi * 1000 * t / 1e6)
    S.adc_fn[1] = lambda t: 32768 - amp * math.sin(2 * math.pi * 1000 * t / 1e6)


def check(S, out, ok):
    line = out.splitlines()[0]
    ok(line.startswith('+1.00'), f'+1.000 kHz 付近: {line!r}')
    ok('1.00 Vpp' in line, f'1.00 Vpp: {line!r}')
