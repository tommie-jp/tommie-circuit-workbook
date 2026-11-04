PROGRAM = '01-circuits/11-microcontrollers/11-usb-vsys-power-1.py'
BUDGET_US = 2_500_000


def setup(S):
    S.adc_fn[3] = lambda t: 31523          # 31523 × 3.3 / 65535 × 3 = 4.76 V
    S.in_values[24] = 1


def check(S, out, ok):
    lines = out.splitlines()
    ok(len(lines) == 3, f'1 s ごと (2.5 s で 3 行): {len(lines)}')
    ok(lines[0] == 'VSYS 4.76 V  VBUS yes', f'表示: {lines[0]!r}')
    ok(S.inits[24]['mode'] == 0, 'GP24 は入力')
