PROGRAM = '02-analog-discovery/07-logic/25-eye-pattern-1.py'
BUDGET_US = 5_000


def check(S, out, ok):
    u = S.uart[0]
    ok(u['baudrate'] == 1_000_000 and u['tx'] == 16, f'UART0・1 Mbit/s・TX = GP16: {u}')
    ok(len(S.uart_tx) >= 2 and S.uart_tx[1][0] - S.uart_tx[0][0] == 2000, f'2 ms ごとに送る: {[t for t, _ in S.uart_tx]}')
    data = S.uart_tx[0][1]
    ok(len(data) == 127, f'127 バイト: {len(data)}')
    bits = [(data[i // 8] >> (i % 8)) & 1 for i in range(127 * 8)]
    ok(all(bits[i] == bits[i + 127] for i in range(len(bits) - 127)), '127 ビットの周期')
    ok(sum(bits[:127]) == 64, f'1 周期に 1 が 64 個: {sum(bits[:127])}')
    wins = {tuple(bits[i:i + 7]) for i in range(127)}
    ok(len(wins) == 127 and (0,) * 7 not in wins, f'7 ビットの窓 127 通り: {len(wins)}')
