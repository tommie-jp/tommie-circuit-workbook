PROGRAM = '02-analog-discovery/07-logic/06-uart-echo-1.py'
BUDGET_US = 1_000_000


def setup(S):
    S.uart_rx.extend(bytes([b]) for b in (0x00, 0x41, 0x7F, 0xFE, 0xFF))


def check(S, out, ok):
    ok(b''.join(b for _, b in S.uart_tx) == bytes([0x01, 0x42, 0x80, 0xFF, 0x00]), f'+1 して返す: {S.uart_tx}')
