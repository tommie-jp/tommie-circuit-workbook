PROGRAM = '01-circuits/09-rf/24-iq-mw-radio-1.py'
BUDGET_US = 1_000_000


def setup(S):
    S.adc_fn[0] = lambda t: 32768
    S.adc_fn[1] = lambda t: 32768


def check(S, out, ok):
    ok(len(S.sm) == 1 and S.sm[0]['prog'] == 'lo', '状態機械 1 つに LO のプログラム')
    sm = S.sm[0]
    ok(sm['kw']['set_base'].id == 2, 'set_base は GP2')
    sys_hz = S.freq_calls[0]
    ok(100_000_000 <= sys_hz <= 150_000_000, f'sys {sys_hz / 1e6:.3f} MHz は 100〜150 MHz')
    m = S.mem32[0x50200000 + 0x0C8] >> 16
    ok(sm['freq'] == sys_hz // m, f'SM の周波数 = sys / M: {sm["freq"]} vs {sys_hz // m}')
    lo = sys_hz / (4 * m)
    ok(1000 <= abs(594_000 - lo) < 1500, f'LO {lo / 1e3:.3f} kHz は局の 1 kHz 上か下')
    ok(out.startswith('594 kHz  sys '), f'表示は 594 kHz から: {out[:40]!r}')
    ok(sm['active'] == 1, '状態機械を有効にする')
