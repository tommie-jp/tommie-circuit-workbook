PROGRAM = '01-circuits/11-microcontrollers/02-button-pullup-1.py'
BUDGET_US = 1_000_000


def check(S, out, ok):
    ok(out.startswith('1\n1\n1\n1\n1\n'), f'1 s で 5 回 "1": {out!r}')
    ok(S.inits[16]['mode'] == 0, 'GP16 は入力')
    ok(S.inits[16]['pull'] == -1, '内蔵プルアップは使わない (外付け R1)')
