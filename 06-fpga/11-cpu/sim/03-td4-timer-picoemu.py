#!/usr/bin/env python3
"""11-3 の td4_113.uf2 を RP2350 エミュレータ picoemu (Cortex-M33) に載せ、SW4 を ON (1 kHz) にして
LED (GP18〜GP21 の写し) と AUX (GP17) の変わる時刻をクロックの数で数える。
picoemu は 5-2 と同じ版 (danish9661/pico-emulator b83786f + 05-soft-fpga-pico/sim/picoemu-m33.patch)。
実時間 (周期の正確さ) は対象外。数はクロックの立ち上がりの数で比べる。

使い方: python3 -I 03-td4-timer-picoemu.py --picoemu <picoemu> --uf2 <td4_113.uf2>
"""
import argparse
import os
import subprocess
import sys
import tempfile


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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--picoemu", required=True)
    ap.add_argument("--uf2", required=True)
    ap.add_argument("--steps", type=int, default=400_000_000)
    a = ap.parse_args()
    # SW1〜SW3 は OFF (H)、SW4 (GP13) だけ ON (L)
    script = "0ms: gpio10 1\n0ms: gpio11 1\n0ms: gpio12 1\n0ms: gpio13 0\n"
    with tempfile.TemporaryDirectory() as d:
        vcd, sp = os.path.join(d, "t.vcd"), os.path.join(d, "s.txt")
        open(sp, "w").write(script)
        subprocess.run([a.picoemu, a.uf2, "-arch", "m33", "-clock", "150", "-gpio-trace", vcd,
                        "-max-steps", str(a.steps), "-script", sp], capture_output=True, text=True)
        ev = parse_vcd(vcd)
    st = {p: 0 for p in range(30)}
    rises, changes, aux = [], [], None
    last = 0
    for k, (t, p, v) in enumerate(ev):
        st[p] = v
        if p == 16 and v == 1:
            rises.append(t)
        if p == 17 and v == 1 and aux is None:
            aux = len(rises)
        if k + 1 < len(ev) and ev[k + 1][0] == t:
            continue                               # 同じ時刻の変化はまとめてから見る (4 本は 1 度に書く)
        mon = sum(st[18 + i] << i for i in range(4))
        if mon != last:
            changes.append((len(rises), mon))      # 何番めの立ち上がりで変わったか (1 番めはリセット中)
            last = mon
    fails = 0
    # 1 番めの立ち上がりはリセット中。2 番め (添字 1) が 0 番地を実行する立ち上がり → n 番めのクロックは n + 2 番めの立ち上がり
    want = [(544 + 2, 0x1), (1089 + 2, 0x3), (1634 + 2, 0xF)]
    for i, (n, v) in enumerate(want):
        ok = i < len(changes) and changes[i] == (n, v)
        fails += not ok
        got = changes[i] if i < len(changes) else None
        print("%s LED が %X になるのは %s 番めの立ち上がり (期待 %d = %d 番めのクロック + 2)" %
              ("PASS" if ok else "FAIL", v, got[0] if got else "-", n, n - 2))
    ok = aux == 1634 + 2
    fails += not ok
    print("%s AUX が H になるのは %s 番めの立ち上がり" % ("PASS" if ok else "FAIL", aux))
    if len(rises) > 2:
        print("   CLK の周期 (picoemu の模型の時刻): %d us、立ち上がりの数 %d" % (rises[2] - rises[1], len(rises)))
    ok = len(changes) == 3
    fails += not ok
    print("%s LED の変化は 3 回だけ (%d 回)" % ("PASS" if ok else "FAIL", len(changes)))
    print("ALL PASS" if not fails else "FAILED %d" % fails)
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
