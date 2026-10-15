PROGRAM = '01-circuits/11-microcontrollers/05-i2c-temperature-1.py'
BUDGET_US = 2_500_000


def setup(S):
    S.i2c_mem[(0x18, 0x05)] = bytes([0x01, 0x90])      # 25.0 ℃


def check(S, out, ok):
    ok(S.i2c[0]['freq'] == 100000, '100 kHz')
    ok(S.i2c[0]['scl'] == 1 and S.i2c[0]['sda'] == 0, 'GP1=SCL・GP0=SDA')
    lines = out.splitlines()
    ok(lines[0] == '[24]', f'scan は [24]: {lines[0]!r}')
    ok(lines[1] == '25.0 C', f'25 ℃: {lines[1]!r}')
    ok(len(lines) == 4, f'1 s ごと (2.5 s で 3 回): {len(lines) - 1}')
