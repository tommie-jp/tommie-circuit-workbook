PROGRAM = '01-circuits/09-rf/16-dds-sdr-module-1.py'
BUDGET_US = 1_000_000


def check(S, out, ok):
    s = S.spi[0]
    ok(s['baudrate'] == 1_000_000 and s['polarity'] == 1 and s['phase'] == 0, '1 MHz・CPOL=1・CPHA=0')
    ok(s['sck'] == 2 and s['mosi'] == 3, 'GP2 SCK・GP3 MOSI')
    words = [int.from_bytes(b, 'big') for _, b in S.spi_tx]
    freq = 75161928
    want = [0x2100, 0x4000 | (freq & 0x3FFF), 0x4000 | ((freq >> 14) & 0x3FFF), 0xC000, 0x2000]
    ok(words == want, f'5 語: {[hex(w) for w in words]}')
    ok(abs(float(out.split()[0]) - 7000000.03) < 0.005, f'実際の周波数 7000000.03: {out!r}')
