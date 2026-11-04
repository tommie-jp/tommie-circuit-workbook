PROGRAM = '01-circuits/11-microcontrollers/06-spi-shift-register-1.py'
BUDGET_US = 5_600_000
WANT = [0x7D, 0x30, 0x5B, 0x7A, 0x36, 0x6E, 0x6F, 0x38, 0x7F, 0x7E]


def setup(S):
    import sys
    sys.modules['machine'].SPI.MSB = 0     # スタブに無い定数 (値は数に関わらない)


def check(S, out, ok):
    spi = S.spi[0]
    ok(spi['baudrate'] == 1_000_000 and spi['polarity'] == 0 and spi['phase'] == 0, 'SPI0 1 MHz・モード 0')
    ok(spi['sck'] == 6 and spi['mosi'] == 3, 'SCK=GP6・MOSI=GP3')
    sent = [b[0] for _, b in S.spi_tx]
    ok(len(sent) == 12, f'12 バイト: {len(sent)}')
    ok(sent == [WANT[i % 10] for i in range(len(sent))], f'並び: {sent}')
    rises = [t for t, p, v in S.events if p == 7 and v == 1]
    ok(len(rises) == 12, f'ラッチ 12 回: {len(rises)}')
    ok(all(b - a == 500_000 for a, b in zip(rises, rises[1:])), '間隔 0.5 s')
