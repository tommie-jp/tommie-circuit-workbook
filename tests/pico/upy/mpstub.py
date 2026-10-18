"""MicroPython (Pico 2) の標準ライブラリの最小のスタブ。CPython で本文のプログラムを動かす (docs/133 の層 A')。
machine・time・utime・rp2 を sys.modules に差し込み、仮想時刻と呼び出しの記録だけを持つ。"""
import sys
import types


class StopSim(BaseException):
    """予算 (仮想時刻) を使い切った。OSError などの except では捕まらない。"""


class State:
    def __init__(self, budget_us):
        self.now_us = 0
        self.budget_us = budget_us
        self.events = []           # (t_us, pin_id, level)
        self.levels = {}           # pin_id -> level
        self.in_values = {}        # pin_id -> 入力として返す値 (既定 1)
        self.pwm = {}              # pin_id -> {'freq':, 'duty':, 't': [(t, freq, duty)]}
        self.adc_fn = {}           # channel -> f(t_us) -> 0..65535
        self.adc_default = 32768
        self.i2c_mem = {}          # (addr, reg) -> bytes
        self.i2c = {}              # id -> {'freq':, 'scl':, 'sda':}
        self.uart = {}             # id -> {'baudrate':, 'tx':, 'rx':}
        self.uart_tx = []          # (t_us, bytes)
        self.uart_rx = []          # 受信キュー (bytes の列)
        self.spi = {}              # id -> {...}
        self.spi_tx = []
        self.sm = []               # rp2.StateMachine の記録
        self.freq_calls = []
        self.mem32 = {}
        self.inits = {}            # pin_id -> {'mode':, 'pull':}

    def advance(self, us):
        self.now_us += us
        if self.now_us >= self.budget_us:
            raise StopSim()


S = None


def install(state):
    """スタブを sys.modules に入れる。state は State。"""
    global S
    S = state

    # ---- time / utime ----
    t = types.ModuleType('time')
    t.sleep = lambda s: S.advance(max(0, int(round(s * 1_000_000))))
    t.sleep_ms = lambda ms: S.advance(int(ms * 1000))
    t.sleep_us = lambda us: S.advance(int(us))
    t.ticks_ms = lambda: (S.now_us // 1000) & 0x3FFFFFFF
    t.ticks_us = lambda: S.now_us & 0x3FFFFFFF
    t.ticks_add = lambda a, d: (a + d) & 0x3FFFFFFF
    t.ticks_diff = lambda a, b: ((a - b + 0x20000000) & 0x3FFFFFFF) - 0x20000000
    t.time = lambda: S.now_us / 1e6
    sys.modules['time'] = t
    sys.modules['utime'] = t

    # ---- machine ----
    m = types.ModuleType('machine')

    class Pin:
        IN, OUT, OPEN_DRAIN = 0, 1, 2
        PULL_UP, PULL_DOWN = 2, 1

        def __init__(self, id, mode=-1, pull=-1, value=None):
            self.id = id
            S.inits[id] = {'mode': mode, 'pull': pull}
            if value is not None:
                self.value(value)

        def value(self, v=None):
            if v is None:
                if S.inits.get(self.id, {}).get('mode') == Pin.OUT:
                    return S.levels.get(self.id, 0)
                return S.in_values.get(self.id, 1)
            v = 1 if v else 0
            if S.levels.get(self.id, 0) != v or not any(e[1] == self.id for e in S.events):
                if S.levels.get(self.id, None) != v:
                    S.events.append((S.now_us, self.id, v))
            S.levels[self.id] = v

        __call__ = value
        on = lambda self: self.value(1)
        off = lambda self: self.value(0)

    class PWM:
        def __init__(self, pin, freq=None, duty_u16=None):
            self.pin = pin.id if isinstance(pin, Pin) else pin
            S.pwm[self.pin] = {'freq': None, 'duty': 0, 'log': []}
            if freq is not None:
                self.freq(freq)
            if duty_u16 is not None:
                self.duty_u16(duty_u16)

        def freq(self, f=None):
            if f is None:
                return S.pwm[self.pin]['freq']
            S.pwm[self.pin]['freq'] = f
            S.pwm[self.pin]['log'].append((S.now_us, f, S.pwm[self.pin]['duty']))

        def duty_u16(self, d=None):
            if d is None:
                return S.pwm[self.pin]['duty']
            S.pwm[self.pin]['duty'] = d
            S.pwm[self.pin]['log'].append((S.now_us, S.pwm[self.pin]['freq'], d))

        def duty_ns(self, ns):
            f = S.pwm[self.pin]['freq']
            self.duty_u16(int(ns * 1e-9 * f * 65535))

        def deinit(self):
            pass

    class ADC:
        def __init__(self, pin):
            self.ch = pin.id - 26 if isinstance(pin, Pin) else (pin - 26 if pin >= 26 else pin)
            S.adc_fn.setdefault(self.ch, None)

        def read_u16(self):
            S.advance(10)                      # 1 回の変換と呼び出しの目安 (実機の値ではない)
            fn = S.adc_fn.get(self.ch)
            return int(fn(S.now_us)) if fn else S.adc_default

    class I2C:
        def __init__(self, id, scl=None, sda=None, freq=400000):
            S.i2c[id] = {'freq': freq, 'scl': scl.id if scl else None, 'sda': sda.id if sda else None}

        def scan(self):
            return sorted({a for a, _ in S.i2c_mem})

        def readfrom_mem(self, addr, reg, n):
            return bytes(S.i2c_mem.get((addr, reg), bytes(n)))[:n]

        def writeto_mem(self, addr, reg, data):
            S.i2c_mem[(addr, reg)] = bytes(data)

    class UART:
        def __init__(self, id, baudrate=9600, bits=8, parity=None, stop=1, tx=None, rx=None):
            S.uart[id] = {'baudrate': baudrate, 'bits': bits, 'parity': parity, 'stop': stop,
                          'tx': tx.id if tx else None, 'rx': rx.id if rx else None}

        def write(self, b):
            S.uart_tx.append((S.now_us, bytes(b)))
            return len(b)

        def read(self, n=1):
            if S.uart_rx:
                b = S.uart_rx.pop(0)
                return b[:n]
            S.advance(100)                     # 来ていない: None を返してすぐ戻る (本文はこれを回して待つ)
            return None

        def any(self):
            return len(S.uart_rx)

    class SPI:
        def __init__(self, id, baudrate=1000000, polarity=0, phase=0, bits=8, firstbit=0, sck=None, mosi=None, miso=None):
            S.spi[id] = {'baudrate': baudrate, 'polarity': polarity, 'phase': phase,
                         'sck': sck.id if sck else None, 'mosi': mosi.id if mosi else None}

        def write(self, b):
            S.spi_tx.append((S.now_us, bytes(b)))

    m.Pin, m.PWM, m.ADC, m.I2C, m.UART, m.SPI = Pin, PWM, ADC, I2C, UART, SPI

    def freq(hz=None):
        if hz is None:
            return 150_000_000
        S.freq_calls.append(hz)
    m.freq = freq

    class Mem32:
        def __getitem__(self, a):
            return S.mem32.get(a, 0)

        def __setitem__(self, a, v):
            S.mem32[a] = v
    m.mem32 = Mem32()
    sys.modules['machine'] = m

    # ---- rp2 ----
    r = types.ModuleType('rp2')

    class PIO:
        OUT_LOW, OUT_HIGH, IN_LOW, IN_HIGH, SHIFT_LEFT, SHIFT_RIGHT = 0, 1, 2, 3, 0, 1
        JOIN_NONE, JOIN_TX, JOIN_RX = 0, 1, 2

    def asm_pio(**kw):
        def deco(fn):
            fn.pio_kwargs = kw
            return fn
        return deco

    class StateMachine:
        def __init__(self, id, prog=None, freq=-1, **kw):
            self.rec = {'id': id, 'prog': getattr(prog, '__name__', None), 'freq': freq, 'kw': kw, 'active': None, 'puts': []}
            S.sm.append(self.rec)

        def put(self, w, shift=0):       # TX FIFO に書いた語と時刻 (深さは模さない)
            for x in (w if isinstance(w, (list, tuple, bytes, bytearray)) or hasattr(w, '__iter__') else [w]):
                self.rec['puts'].append((S.now_us, int(x)))

        def active(self, a=None):
            if a is not None:
                self.rec['active'] = a
    r.PIO, r.asm_pio, r.StateMachine = PIO, asm_pio, StateMachine
    sys.modules['rp2'] = r
    return S
