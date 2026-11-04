PROGRAM = '01-circuits/11-microcontrollers/08-rotary-encoder-irq-1.py'
BUDGET_US = 200_000
# 割り込みを起こす時刻 (µs)・ピン・その時の DT
EVENTS = [(10_000, 14, 1), (35_000, 14, 1), (60_000, 14, 1), (85_000, 14, 0), (120_000, 13, 1)]


def setup(S):
    import sys
    machine, time = sys.modules['machine'], sys.modules['time']
    S.irq = {}
    S.fired = 0
    machine.Pin.IRQ_FALLING, machine.Pin.IRQ_RISING = 2, 1

    def irq(self, trigger=None, handler=None):     # スタブに無い Pin.irq: 呼び出し先を残すだけ
        S.irq[self.id] = (trigger, handler)
    machine.Pin.irq = irq
    sleep_ms = time.sleep_ms

    def sleep_ms_irq(ms):                          # 時刻が来たら割り込みを起こす
        sleep_ms(ms)
        while S.fired < len(EVENTS) and S.now_us >= EVENTS[S.fired][0]:
            _, pin, dt = EVENTS[S.fired]
            S.in_values[15] = dt
            S.fired += 1
            S.irq[pin][1](pin)
    time.sleep_ms = sleep_ms_irq


def check(S, out, ok):
    ok(S.irq[14][0] == 2 and S.irq[13][0] == 2, 'GP14・GP13 の立ち下がり')
    ok(S.inits[13]['pull'] == 2, 'SW は内蔵プルアップ')
    ok(S.fired == 5, f'割り込み 5 回: {S.fired}')
    ok(out.split() == ['1', '2', '3', '2', '0'], f'1・2・3・2・0: {out.split()}')
