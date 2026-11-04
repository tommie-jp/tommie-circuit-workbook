PROGRAM = '01-circuits/11-microcontrollers/10-pico2w-threshold-notify-1.py'
BUDGET_US = 2_200_000
BRIGHT, DARK = 32768, 3100          # 1.65 V・0.156 V (11-3 の表)


def setup(S):
    import sys
    import types
    S.sent = []
    net = types.ModuleType('network')
    net.STA_IF = 0

    class WLAN:                          # 2 回目の isconnected() で繋がる
        def __init__(self, i):
            self.n = 0

        def active(self, a):
            pass

        def connect(self, ssid, pw):
            pass

        def isconnected(self):
            self.n += 1
            return self.n >= 2

        def ifconfig(self):
            return ('192.168.1.20', '255.255.255.0', '192.168.1.1', '192.168.1.1')
    net.WLAN = WLAN
    sock = types.ModuleType('socket')
    sock.AF_INET, sock.SOCK_DGRAM = 2, 2

    class Sock:                          # 送った時刻・中身・宛先を残す
        def __init__(self, *a):
            pass

        def sendto(self, b, addr):
            S.sent.append((S.now_us, bytes(b), addr))
    sock.socket = Sock
    sys.modules['network'], sys.modules['socket'] = net, sock
    # 接続を待つ 0.5 s のあと、1.0〜2.0 s のあいだ暗い
    S.adc_fn[0] = lambda t: DARK if 1_000_000 <= t < 2_000_000 else BRIGHT


def check(S, out, ok):
    ok(out.splitlines()[0] == 'connected 192.168.1.20', f'接続: {out.splitlines()[:1]}')
    msgs = [m for _, m, _ in S.sent]
    ok(msgs == [b'dark 0.16 V', b'bright 1.65 V'], f'2 回だけ: {msgs}')
    ok(all(a == ('192.168.1.10', 5005) for _, _, a in S.sent), '宛先')
    t = [x for x, _, _ in S.sent]
    ok(len(t) == 2 and 1_000_000 <= t[0] <= 1_110_000 and 2_000_000 <= t[1] <= 2_110_000, f'0.1 s 以内: {t}')
