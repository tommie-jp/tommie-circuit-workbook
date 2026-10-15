#!/usr/bin/env python3
"""5 章・6-6・6-7 の .uf2 を RP2350 エミュレータ picoemu (Cortex-M33) に載せ、
論理で決まる値 (出力の並び・反転の回数・分周比・押し方への反応) を突き合わせる。

使い方:
  python3 picoemu-check.py --picoemu ./picoemu --uf2 <.uf2 を集めたフォルダ> [題 ...]
  題: 5-2 5-3 5-4 5-5 5-6 5-7 5-8 5-9 5-10 5-11 5-14 5-15 6-6 6-7 (省くと全部)

.uf2 のファイル名: blink_pico io_reg_pico gates_pico clock55 clock56 clock57
  td4_58 (プログラム A) td4_58_b (プログラム B) clock59 clock510 clock511
  serial514 (USB 付き) seg515 press66 timer99_pico

picoemu は sim/picoemu-m33.patch を当てた版 (danish9661/pico-emulator b83786f)。
周期・ジッタ・周波数などの実時間は対象外 (picoemu は命令ごとの周期の模型で、実機の時間ではない)。
入力 (DIP・ボタン) は picoemu の -script で与える。時刻は ms 刻み。
"""
import argparse
import os
import re
import statistics
import subprocess
import sys
import tempfile

ARGS = None
FAILS = []


def run(uf2, steps, clock=150, script=None, extra=(), env=None):
    """uf2 を M33 で steps 命令まで回す。GPIO の変化 [(us, pin, val)] と標準出力・標準エラーを返す。"""
    with tempfile.TemporaryDirectory() as d:
        vcd = os.path.join(d, "t.vcd")
        cmd = [ARGS.picoemu, os.path.join(ARGS.uf2, uf2 + ".uf2"), "-arch", "m33",
               "-clock", str(clock), "-gpio-trace", vcd, "-max-steps", str(steps), *extra]
        if script:
            sp = os.path.join(d, "s.txt")
            with open(sp, "w") as f:
                f.write(script)
            cmd += ["-script", sp]
        e = dict(os.environ, **(env or {}))
        r = subprocess.run(cmd, capture_output=True, text=True, env=e)
        return parse_vcd(vcd), r.stdout + r.stderr


def parse_vcd(path):
    ids, t, out = {}, 0, []
    for line in open(path):
        line = line.strip()
        if line.startswith("$var"):
            p = line.split()
            ids[p[3]] = int(p[4].removeprefix("gpio"))
        elif line.startswith("#"):
            t = int(line[1:])
        elif line and line[0] in "01" and line[1:] in ids:
            out.append((t, ids[line[1:]], int(line[0])))
    return out


def check(name, ok, detail=""):
    print("%s  %s %s" % ("ok" if ok else "NG", name, detail))
    if not ok:
        FAILS.append(name)


def after0(ev):
    return [e for e in ev if e[0] > 0]


def level_at(ev, pins, t_us):
    """pins (下位ビットから) の値を t_us 時点で数にする。"""
    st = {}
    for (t, p, v) in ev:
        if t > t_us:
            break
        st[p] = v
    return sum(st.get(p, 0) << i for i, p in enumerate(pins))


def dip(bits, at_ms=0, first_pin=10):
    """SW1 = GP10 … SW4 = GP13、ON で L。bits は SW1 が上の桁の 4 ビット。"""
    return "".join("%dms: gpio%d %d\n" % (at_ms, first_pin + i, 0 if (bits >> (3 - i)) & 1 else 1)
                   for i in range(4))


def rev4(v):
    return ((v >> 3) & 1) | ((v >> 1) & 2) | ((v << 1) & 4) | ((v << 3) & 8)


# ---------------------------------------------------------------- 5-2
def c52():
    ev, _ = run("blink_pico", 30_000_000, clock=150)
    ch = [(t, v) for (t, p, v) in after0(ev) if p == 14]
    # 本文: 50 000 周ごとに反転。主ループの 1 周はおよそ 228 命令
    check("5-2 GP14 が反転する", len(ch) >= 2, "反転 %d 回" % len(ch))
    ev, log = run("blink_pico", 90_000_000, env={"PICOEMU_PUT_LOG": "14"})
    puts = [int(m.group(1)) for m in re.finditer(r"GP14=\d at put-call #(\d+)", log)]
    if puts:  # gpio_init が 1 回 gpio_put(0) するので、1 周目の書き込みは 2 回目の呼び出し
        loops = [p - 1 for p in puts]
        check("5-2 反転は 50 000 周ごと", loops[:4] == [50000, 100000, 150000, 200000], str(loops[:4]))


# ---------------------------------------------------------------- 5-3
def c53():
    sc = "5ms: gpio17 0\n10ms: gpio16 0\n15ms: gpio17 1\n20ms: gpio16 1\n"
    ev, _ = run("io_reg_pico", 30_000_000, script=sc)
    for t_ms, sw, want in ((2, "SW1 OFF SW2 OFF", 0), (8, "SW1 ON", 1), (13, "SW1 ON SW2 ON", 3),
                           (18, "SW2 ON", 2), (24, "どちらも OFF", 0)):
        got = level_at(ev, [14, 15], t_ms * 1000)
        check("5-3 %s -> D1 D2 = %s" % (sw, format(want, "02b")), got == want, "実行 %s" % format(got, "02b"))


# ---------------------------------------------------------------- 5-4
def c54():
    combos = [(0, 0), (0, 1), (1, 0), (1, 1)]
    sc = "".join("%dms: gpio17 %d\n%dms: gpio16 %d\n" % (5 + 10 * i, 1 - a, 5 + 10 * i, 1 - b)
                 for i, (a, b) in enumerate(combos))
    ev, _ = run("gates_pico", 40_000_000, script=sc)
    for i, (a, b) in enumerate(combos):
        t = (9 + 10 * i) * 1000
        got = (level_at(ev, [14], t), level_at(ev, [15], t), level_at(ev, [25], t))
        want = (a & b, a | b, 1 - a)
        check("5-4 a=%d b=%d -> AND OR NOT = %s" % (a, b, want), got == want, "実行 %s" % (got,))


# ---------------------------------------------------------------- 5-5
def c55():
    ev, _ = run("clock55", 2_000_000)
    ev = after0(ev)
    st = {p: 0 for p in range(30)}
    falls, aux, bad = 0, [], 0
    for (t, p, v) in ev:
        st[p] = v
        if p == 16 and v == 0:
            falls += 1
            mon = sum(st[18 + i] << i for i in range(4))
            led = sum(st[2 + i] << i for i in range(4))
            exp = ((falls - 1) >> 4) & 15
            bad += (mon != exp or led != rev4(exp))
        if p == 17:
            aux.append(falls)
    check("5-5 LED = count[7:4] (count は周回数 - 1)、GP2 が bit3", bad == 0 and falls > 1000, "%d クロック、不一致 %d" % (falls, bad))
    check("5-5 AUX は 1000 クロックごとに反転", aux[:4] == [1000, 2000, 3000, 4000], str(aux[:4]))


# ---------------------------------------------------------------- 5-6
def many_sum(k, n):
    x = 0
    for i in range(n):
        x ^= (k * (i + 1)) & 0xFFFFFFFF
    return x


def c56():
    rate = {}
    for sel in range(5):
        # SW1〜SW3 (GP10〜GP12)。sel の上の桁が SW1
        sc = "".join("0ms: gpio%d %d\n" % (10 + i, 0 if (sel >> (2 - i)) & 1 else 1) for i in range(3))
        steps = 13_000_000 if sel == 4 else 3_000_000
        ev, _ = run("clock56", steps, script=sc)
        st = {p: 0 for p in range(30)}
        falls, aux, mon = 0, [], []
        for (t, p, v) in ev:
            st[p] = v
            if t == 0:
                continue
            if p == 16 and v == 0:
                falls += 1
                mon.append(sum(st[18 + i] << i for i in range(4)))
            if p == 17:
                aux.append(falls)
        rate[sel] = falls / (steps / 1e6)   # 100 万命令あたりのクロック数
        names = ["counter8", "counter32", "TD4", "blink", "many N=256"]
        if sel in (0, 1):
            ok = mon == [((k - 1) >> 4) & 15 for k in range(1, falls + 1)]
        elif sel == 3:
            flips = [k for k in range(1, falls) if mon[k] != mon[k - 1]]
            ok = flips[:4] == [500, 1000, 1500, 2000]
        elif sel == 2:
            seq = [m for i, m in enumerate(mon) if i == 0 or m != mon[i - 1]]
            ok = seq[:9] == [0, 3, 6, 12, 8, 12, 6, 3, 1]
        else:
            ok = mon == [(many_sum(k - 1, 256) >> 4) & 15 for k in range(1, falls + 1)]
        check("5-6 DIP %d -> %s が回り、LED/OUT が合う" % (sel, names[sel]), ok, "%d クロック" % falls)
        if sel < 4:
            check("5-6 DIP %d AUX は 1000 クロックごと" % sel, aux[:3] == [1000, 2000, 3000], str(aux[:3]))
        else:
            check("5-6 many の 1 クロックは counter8 の 10 倍以上の命令 (PC の 43 倍と同じ向き)", rate[4] * 10 < rate[0],
                  "100 万命令あたり many %.0f、counter8 %.0f クロック" % (rate[4], rate[0]))


# ---------------------------------------------------------------- 5-7
def c57():
    for sel, steps in ((0, 15_000_000), (3, 150_000_000)):
        sc = "".join("0ms: gpio%d %d\n" % (10 + i, 0 if (sel >> (2 - i)) & 1 else 1) for i in range(3))
        ev, _ = run("clock57", steps, script=sc)
        ev = after0(ev)
        rises = [t for (t, p, v) in ev if p == 16 and v == 1]
        per = [b - a for a, b in zip(rises, rises[1:])]
        check("5-7 DIP %d CLK の周期は 1000 us (±1)" % sel, min(per) >= 999 and max(per) <= 1001,
              "min %d max %d" % (min(per), max(per)))
        if sel == 3:
            ch = [t for (t, p, v) in ev if p == 18]
            gaps = [round((b - a) / 1000) for a, b in zip(ch, ch[1:])][:5]
            check("5-7 blink の LED は 500 ms ごとに反転 (周期 1 s)", gaps == [500] * len(gaps) and len(gaps) >= 3, str(gaps))


# ---------------------------------------------------------------- 5-8
def td4_out(uf2, script, steps=400_000_000):
    ev, _ = run(uf2, steps, script=script)
    ev = after0(ev)
    st = {p: 0 for p in range(30)}
    per, rises = [], []
    for (t, p, v) in ev:
        if p == 16 and v == 0:
            per.append(sum(st[18 + i] << i for i in range(4)))
        if p == 16 and v == 1:
            rises.append(t)
        st[p] = v
    return per, rises


def c58():
    per, rises = td4_out("td4_58", dip(0))
    want = [0] + [3, 6, 12, 8, 8, 12, 6, 3, 1, 1] * 3
    check("5-8 プログラム A の OUT = 3 6 C 8 8 C 6 3 1 1 の繰り返し", per[:31] == want, " ".join("%X" % x for x in per[:21]))
    check("5-8 CLK の周期は 100 ms", abs((rises[1] - rises[0]) - 100000) <= 10, "%d us" % (rises[1] - rises[0]))
    sc = dip(5) + dip(15, at_ms=1530)
    per, rises = td4_out("td4_58_b", sc)
    first6 = next(i for i, v in enumerate(per) if v == 6)
    check("5-8 プログラム B、DIP = 5 -> OUT = 6、リセットのあと 4 クロック目から", first6 == 4 and per[4:19] == [6] * 15,
          "最初の 6 は %d 番目の立ち上がり (1 番目がリセット)" % (first6 + 1))
    first0 = next(i for i, v in enumerate(per) if i > first6 and v == 0)
    check("5-8 プログラム B、DIP を F に替えると 0.5 s 以内に OUT = 0", (rises[first0] - 1530000) <= 500000,
          "%.0f ms 後" % ((rises[first0] - 1530000) / 1000))


# ---------------------------------------------------------------- 5-9
HALF59 = [2000, 1500, 1000, 700, 500, 300, 200, 150, 100, 70, 50, 30, 20, 15, 10, 5]


def c59():
    for idx in (0, 4, 8):
        ev, _ = run("clock59", 80_000_000, script=dip(idx))
        rises = [t for (t, p, v) in after0(ev) if p == 16 and v == 1]
        per = [b - a for a, b in zip(rises, rises[1:])]
        want = 2 * HALF59[idx]
        check("5-9 DIP %d (半周期 %d us) -> CLK の周期 %d us" % (idx, HALF59[idx], want),
              min(per) >= want - 1 and max(per) <= want + 1, "min %d max %d" % (min(per), max(per)))
    ev, _ = run("clock59", 80_000_000, script=dip(15))
    ev = after0(ev)
    check("5-9 半周期 5 us は間に合わず、LED が全部点いてタイマが止まる",
          level_at(ev, [2, 3, 4, 5], 10**9) == 15 and len([1 for (t, p, v) in ev if p == 16 and v == 1]) <= 1)
    ev, _ = run("clock59", 80_000_000, script=dip(15) + dip(0, at_ms=50))
    rises = [t for (t, p, v) in after0(ev) if p == 16 and v == 1 and t > 50000]
    check("5-9 DIP を替えると、その半周期でやり直す (2000 us)", len(rises) > 100 and rises[1] - rises[0] == 4000)


# ---------------------------------------------------------------- 5-10
def c510():
    half = [5, 10, 20, 50, 100, 200, 500, 1000]
    ok = True
    for i, h in enumerate(half):
        ev, _ = run("clock510", 60_000_000 if h >= 100 else 20_000_000, script=dip(8 | i))
        rises = [t for (t, p, v) in after0(ev) if p == 16 and v == 1]
        per = [b - a for a, b in zip(rises, rises[1:])]
        ok &= (min(per) == max(per) == 2 * h)
    check("5-10 タイマ割り込みの周期 = 2 x 半周期 (8 通り)。ばらつきは 0 で、ジッタは測れない", ok)
    ev, _ = run("clock510", 10_000_000, script=dip(0))
    check("5-10 SW1 OFF は主ループで回る", len([1 for (t, p, v) in after0(ev) if p == 16 and v == 1]) > 1000)


# ---------------------------------------------------------------- 5-11
def c511():
    table = [(10, 240, 62499, 31250), (20, 120, 62499, 31250), (50, 48, 62499, 31250),
             (100, 24, 62499, 31250), (200, 12, 62499, 31250), (500, 5, 59999, 30000),
             (1000, 3, 49999, 25000), (2000, 2, 37499, 18750)]
    for idx, (f, div, top, lvl) in enumerate(table):
        ev, log = run("clock511", 3_000_000, script=dip(idx << 1), env={"PICOEMU_PWM_LOG": "1"})
        regs = {int(m.group(1), 16): int(m.group(2), 16) for m in re.finditer(r"\[PWM\] \+0x([0-9a-f]{2}) = 0x([0-9a-f]+)", log)}
        got = (regs.get(4, 0) >> 4, regs.get(0x10), regs.get(0xC, 0) & 0xFFFF)
        check("5-11 %d Hz -> div/wrap/level = %d/%d/%d" % (f, div, top, lvl), got == (div, top, lvl), "実行 %s" % (got,))


# ---------------------------------------------------------------- 5-14
def c514():
    ev, log = run("serial514", 150_000_000)
    lines = re.findall(r"^\d+ pc=\S+ op=\S+ out=\S+$", log, re.M)
    want = ["1 pc=1 op=B6 out=3", "2 pc=2 op=BC out=6", "3 pc=3 op=B8 out=C"]
    check("5-14 SW1 OFF: 最初の 3 行は本文の行と同じ (4 行目から先は CDC が止まる。picoemu 側の限り)", lines[:3] == want, str(lines[:4]))
    ev, log = run("serial514", 300_000_000, script="0ms: gpio10 0\n")
    lines = re.findall(r"^\d+ pc=\S+ op=\S+ out=\S+$", log, re.M)
    check("5-14 SW1 ON: 1000 クロックごとに pc=0 op=B3 out=1",
          len(lines) > 100 and all(l == "%d pc=0 op=B3 out=1" % (1000 * (i + 1)) for i, l in enumerate(lines[:100])), str(lines[:2]))


# ---------------------------------------------------------------- 5-15
def c515():
    seg_pins = [11, 12, 16, 17, 18, 10, 9]
    mon_pins = [22, 21, 20, 19]
    exp = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F]
    sc = "".join("%dms: gpio26 0\n%dms: gpio26 1\n" % (10 + 10 * k, 15 + 10 * k) for k in range(11))
    ev, _ = run("seg515", 40_000_000, script=sc)
    check("5-15 電源を入れると 0", (level_at(ev, seg_pins, 5000), level_at(ev, mon_pins, 5000)) == (0x3F, 0))
    got = [(level_at(ev, seg_pins, (18 + 10 * k) * 1000), level_at(ev, mon_pins, (18 + 10 * k) * 1000)) for k in range(11)]
    want = [(exp[(k + 1) % 10], (k + 1) % 10) for k in range(11)]
    check("5-15 11 回押す: 1 → … → 9 → 0 → 1、seg の値も合う", got == want)
    ev, _ = run("seg515", 40_000_000, script="100ms: gpio26 0\n101ms: gpio26 1\n102ms: gpio26 0\n150ms: gpio26 1\n")
    check("5-15 跳ねる押し方 (L H L) は 1 回で 2 つ進む", level_at(ev, mon_pins, 140000) == 2)


# ---------------------------------------------------------------- 6-6
def c66():
    def seq(t0, ms_down, bounce):
        e = [(t0, 0), (t0 + 1, 1), (t0 + 2, 0), (t0 + 3, 1), (t0 + 4, 0)] if bounce else [(t0, 0)]
        up = t0 + ms_down
        return e + ([(up, 1), (up + 1, 0), (up + 2, 1)] if bounce else [(up, 1)])
    scen = [("短押し 300 ms", seq(100, 300, True), 100, 800, (1, 0, 0)),
            ("長押し 2.5 s", seq(800, 2500, True), 800, 4000, (0, 1, 7)),
            ("跳ねずに 0.9 s", seq(4000, 900, False), 4000, 5500, (1, 0, 0)),
            ("跳ねずに 1.1 s", seq(5500, 1100, False), 5500, 7000, (0, 1, 0)),
            ("5 ms のひげ", [(7000, 0), (7005, 1)], 7000, 7500, (0, 0, 0))]
    sc = "".join("%dms: gpio0 %d\n" % (m, l) for (_, e, _, _, _) in scen for (m, l) in e)
    ev, _ = run("press66", 300_000_000, clock=20, script=sc)
    ev = after0(ev)
    rise = lambda pin: [t / 1000 for (t, p, v) in ev if p == pin and v == 1]
    for name, e, a, b, want in scen:
        got = tuple(len([t for t in rise(pin) if a <= t < b]) for pin in (15, 14, 16))
        check("6-6 %s -> short/long/repeat = %s" % (name, want), got == want, "実行 %s" % (got,))
    r = [t for t in rise(16) if 800 <= t < 4000]
    check("6-6 repeat の間隔は 200 ms", [round(y - x, 1) for x, y in zip(r, r[1:])] == [200.0] * 6)
    s = [t for t in rise(15) if 100 <= t < 800][0]
    check("6-6 短押しで離してから D1 まで約 22.5 ms (ms 刻みの跳ねで 22.8 ms)", 21 < s - 402 < 25, "%.1f ms" % (s - 402))
    l = [t for t in rise(14) if 5500 <= t < 7000][0]
    check("6-6 跳ねない 1.1 s の長押しで押してから D2 まで約 1022.5 ms", 1021 < l - 5500 < 1025, "%.1f ms" % (l - 5500))


# ---------------------------------------------------------------- 6-7
def c67():
    DEC = {0x3F: 0, 0x06: 1, 0x5B: 2, 0x4F: 3, 0x66: 4, 0x6D: 5, 0x7D: 6, 0x07: 7, 0x7F: 8, 0x6F: 9}
    tens = [4, 5, 18, 17, 16, 3, 2]
    ones = [8, 9, 21, 20, 19, 7, 6]
    ev_s, marks = [], []
    t = [13]

    def at(p, v):
        ev_s.append((t[0], p, v))

    def push(pin, n):
        for i in range(5):
            at(pin, i & 1)
            t[0] += 1
        at(pin, 0)
        t[0] += n
        at(pin, 1)
        t[0] += 50
    push(1, 100); marks.append((t[0], (0, 0), "スタートを押しても 00 のまま"))
    for _ in range(3):
        push(0, 100)
    marks.append((t[0], (0, 3), "「+」を 3 回 -> 03"))
    push(0, 2000); marks.append((t[0], (2, 0), "「+」を 2 s 押し続ける -> 20"))
    push(1, 100); t[0] += 5370; marks.append((t[0], (1, 5), "走って約 5.5 s -> 15"))
    push(1, 100); marks.append((t[0], (1, 5), "止める -> 15 のまま"))
    t[0] += 3000; marks.append((t[0], (1, 5), "3 s 後も 15"))
    push(1, 100); t[0] += 15000; marks.append((t[0], (0, 0), "15 s 後に 00"))
    sc = "".join("%dms: gpio%d %d\n" % x for x in ev_s)
    ev, _ = run("timer99_pico", 700_000_000, clock=10, script=sc)
    ev = after0(ev)
    for tm, want, name in marks:
        got = (DEC.get(level_at(ev, tens, tm * 1000)), DEC.get(level_at(ev, ones, tm * 1000)))
        check("6-7 %s" % name, got == want, "実行 %s" % (got,))
    sec = [t_ / 1000 for (t_, p, v) in ev if p == 14 and v == 1]
    g = sorted({round(b - a) for a, b in zip(sec, sec[1:])})
    check("6-7 SEC の周期は 1000 ms (間に止めた 3 s を除く)", 1000 in g and all(x == 1000 or x > 3000 for x in g), str(g))
    bz = [t_ for (t_, p, v) in ev if p == 15 and v == 1]
    one_s = [x for x in bz if bz[0] <= x < bz[0] + 1_000_000]
    gaps = {round((b - a) / 1000, 1) for a, b in zip(one_s, one_s[1:])}
    check("6-7 ブザーは 1 s に 250 回の立ち上がり、周期 2 ms", len(one_s) == 250 and gaps == {2.0}, "%d 回 %s" % (len(one_s), gaps))
    bins = [len([x for x in bz if bz[0] + k * 100_000 <= x < bz[0] + (k + 1) * 100_000]) for k in range(10)]
    check("6-7 鳴る 0.5 s と休む 0.5 s", bins == [50] * 5 + [0] * 5, str(bins))
    check("6-7 RING に入るのは 26 395 ms 付近 (本文 26 394 ms)", abs(bz[0] / 1000 - 26395) < 5, "%.1f ms" % (bz[0] / 1000))


CHECKS = {"5-2": c52, "5-3": c53, "5-4": c54, "5-5": c55, "5-6": c56, "5-7": c57, "5-8": c58, "5-9": c59,
          "5-10": c510, "5-11": c511, "5-14": c514, "5-15": c515, "6-6": c66, "6-7": c67}


def main():
    global ARGS
    ap = argparse.ArgumentParser()
    ap.add_argument("--picoemu", required=True)
    ap.add_argument("--uf2", required=True)
    ap.add_argument("items", nargs="*")
    ARGS = ap.parse_args()
    for k in ARGS.items or CHECKS:
        CHECKS[k]()
    print("\n%s" % ("全部 ok" if not FAILS else "NG: %s" % ", ".join(FAILS)))
    return 1 if FAILS else 0


if __name__ == "__main__":
    sys.exit(main())
