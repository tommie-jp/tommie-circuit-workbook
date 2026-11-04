PROGRAM = '01-circuits/11-microcontrollers/07-uart-two-picos-1.py'
BUDGET_US = 2_500_000


def setup(S):
    S.uart_rx[:] = [b'7', b'\n']      # 相手から届いた 1 行 (スタブは 1 回の read で 1 かたまりを返す)


def check(S, out, ok):
    u = S.uart[0]
    ok(u['baudrate'] == 9600 and u['bits'] == 8 and u['parity'] is None and u['stop'] == 1, '9600 bps・8N1')
    ok(u['tx'] == 0 and u['rx'] == 1, 'GP0=TX・GP1=RX')
    sent = b''.join(b for _, b in S.uart_tx)
    ok(sent == b'0\n1\n2\n', f'0・1・2 を送る: {sent!r}')
    t = [t for t, _ in S.uart_tx]
    ok(len(t) == 3 and all(abs((b - a) - 1_000_000) <= 2000 for a, b in zip(t, t[1:])), f'1 s ごと: {t}')
    ok(out == '7\n', f'受けた字を写す: {out!r}')
