"""6-5: Si5351A を I2C0 (GP4=SDA・GP5=SCL) で設定する。SW1 (GP14) を押し続けた 1.25 s を見る。
期待値は出る周波数 (PLL A と CLK0 の分周のレジスタから逆算した Hz)。C 版と同じ数。"""
PROGRAM = '05-etc/06-ham-receiver/05-direct-conversion-1.py'
BUDGET_US = 1_250_000


def setup(S):
    S.in_values[14] = 0                    # SW1 (UP) を押したまま


def ratio(S, base):
    d = S.i2c_mem[(0x60, base)]
    p3 = ((d[5] >> 4) << 16) | (d[0] << 8) | d[1]
    p1 = ((d[2] & 3) << 16) | (d[3] << 8) | d[4]
    p2 = ((d[5] & 15) << 16) | (d[6] << 8) | d[7]
    return (p1 + 512 + p2 / p3) / 128


def check(S, out, ok):
    ok(S.i2c[0]['freq'] == 100000, '100 kHz')
    ok(S.i2c[0]['sda'] == 4 and S.i2c[0]['scl'] == 5, 'GP4=SDA・GP5=SCL')
    ok(S.inits[14]['mode'] == 0 and S.inits[14]['pull'] == 2, 'GP14 は入力で内蔵プルアップ')
    ok(S.inits[15]['mode'] == 0 and S.inits[15]['pull'] == 2, 'GP15 は入力で内蔵プルアップ')
    lines = out.split()
    ok(lines[:3] == ['7010000.0', '7010100.0', '7010200.0'], f'起動は 7.0100 MHz、刻みは 100 Hz: {lines[:3]}')
    ok(len(lines) == 14, f'0.1 秒ごとに 1 行: {len(lines)}')
    want = 7010000 + 10 * 100 + 3 * 1000
    ok(abs(float(lines[-1]) - want) < 0.05, f'100 Hz x 10 + 1 kHz x 3: {lines[-1]}')
    ok(abs(ratio(S, 42) - 120) < 1e-9, 'CLK0 の分周は 120')
    f = 25e6 * ratio(S, 26) / ratio(S, 42)
    ok(abs(f - want) < 0.05, f'レジスタの周波数が表示と同じ: {f}')
    ok(S.i2c_mem[(0x60, 3)] == bytes([0xFE]), 'CLK0 だけ出す')
