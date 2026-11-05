PROGRAM = '02-analog-discovery/07-logic/18-boot-log-record-1.py'
BUDGET_US = 2_700_000


def check(S, out, ok):
    u = S.uart[0]
    ok(u['baudrate'] == 115200 and u['bits'] == 8 and u['stop'] == 1 and u['parity'] is None, '115200 8N1')
    ok(u['tx'] == 0 and u['rx'] == 1, 'GP0 TX・GP1 RX')
    got = [(t, b) for t, b in S.uart_tx]
    want = [(0, b'boot\r\n'), (500_000, b'ready\r\n'), (500_000, b't=0\r\n'), (1_500_000, b't=1\r\n'), (2_500_000, b't=2\r\n')]
    ok(got == want, f'行と時刻: {got}')
