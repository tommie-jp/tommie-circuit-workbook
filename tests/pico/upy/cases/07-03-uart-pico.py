PROGRAM = '02-analog-discovery/07-logic/03-uart-pico-1.py'
BUDGET_US = 3_500_000


def check(S, out, ok):
    u = S.uart[0]
    ok(u['baudrate'] == 115200 and u['bits'] == 8 and u['stop'] == 1 and u['parity'] is None, '115200 8N1')
    ok(u['tx'] == 0 and u['rx'] == 1, 'GP0 TX・GP1 RX')
    ok([b for _, b in S.uart_tx] == [b'U'] * 4, f'3.5 s で 4 文字: {S.uart_tx}')
    ok([t for t, _ in S.uart_tx] == [0, 1_000_000, 2_000_000, 3_000_000], '1 s 間隔')
