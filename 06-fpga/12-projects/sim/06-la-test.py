#!/usr/bin/env python3
"""la.py の試験。PC の側だけで回る試験と、tb_la が書いた la_dump<N>.txt を VCD にして読み戻す試験。

    python3 test_la.py           # la_dump*.txt が無ければ後ろの 3 つは飛ばす
"""
import importlib.util
import io
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))


def load_la():
    for name in ("la.py", "06-la.py"):          # 題の名前と、sim/ に置いた名前
        path = os.path.join(HERE, name)
        if os.path.exists(path):
            spec = importlib.util.spec_from_file_location("la", path)
            mod = importlib.util.module_from_spec(spec)
            sys.modules["la"] = mod                # dataclass が自分のモジュールを引くので先に登録する
            spec.loader.exec_module(mod)
            return mod
    raise FileNotFoundError("la.py")


la = load_la()


def read_vcd(text):
    """VCD を {名前: [(時刻 ps, 値), ...]} にする (この試験で書く形だけ読む)。"""
    names, changes, t = {}, {}, 0
    for line in text.splitlines():
        if line.startswith("$var"):
            f = line.split()
            names[f[3]] = f[4]
            changes[f[4]] = []
        elif line.startswith("#"):
            t = int(line[1:])
        elif line and line[0] in "01" and line[1:] in names:
            changes[names[line[1:]]].append((t, int(line[0])))
    return changes


def load_dump(n):
    path = os.path.join(HERE, f"la_dump{n}.txt")
    if not os.path.exists(path):
        return None
    with open(path, encoding="ascii") as f:
        return bytes(int(x, 16) for x in f.read().split())


class TestParse(unittest.TestCase):
    def test_rate(self):
        self.assertEqual(la.parse_rate("27M"), 1)
        self.assertEqual(la.parse_rate("1M"), 27)
        self.assertEqual(la.parse_rate("100k"), 270)
        with self.assertRaises(ValueError):
            la.parse_rate("10M")               # 27 MHz ÷ 2.7 は割り切れない

    def test_trigger(self):
        self.assertEqual(la.parse_trigger("rise:3"), la.Trigger(0, 0, 3))
        self.assertEqual(la.parse_trigger("pattern:1xxxxxx0"), la.Trigger(0x81, 0x80, None))
        self.assertEqual(la.parse_trigger("rise:0+pattern:xxxx1xxx"), la.Trigger(0x08, 0x08, 0))
        for bad in ("rise:8", "pattern:10", "fall:1"):
            with self.assertRaises(ValueError):
                la.parse_trigger(bad)

    def test_command(self):
        cmd = la.build_command(270, la.Trigger(0x81, 0x80, 3), 1024)
        self.assertEqual(cmd, bytes([0x41, 0x01, 0x0E, 0x81, 0x80, 0x83, 0x04, 0x00]))


class TestVcd(unittest.TestCase):
    def test_changes_only(self):
        out = io.StringIO()
        la.write_vcd(out, [0x00, 0x01, 0x01, 0x03], div=27, pre=1)
        ch = read_vcd(out.getvalue())
        self.assertEqual(ch["ch0"], [(0, 0), (1_000_000, 1)])          # 1 µs ごと
        self.assertEqual(ch["ch1"], [(0, 0), (3_000_000, 1)])
        self.assertEqual(ch["trig"], [(0, 0), (1_000_000, 1), (2_000_000, 0)])


@unittest.skipIf(load_dump(1) is None, "la_dump*.txt が無い (tb_la を先に回す)")
class TestFromSimulation(unittest.TestCase):
    def vcd(self, n, div, pre):
        out = io.StringIO()
        la.write_vcd(out, la.parse_dump(load_dump(n)), div, pre)
        return read_vcd(out.getvalue())

    def test_counter_1msps(self):
        # 1. カウンタ (1 µs ごとに +1) を 1 MS/s で。ch0 は毎サンプル、ch7 は 128 サンプルごとに変わる
        ch = self.vcd(1, div=27, pre=1024)
        self.assertEqual(len(ch["ch0"]), 4096)
        self.assertEqual(ch["ch7"][:3], [(0, 1), (128_000_000, 0), (256_000_000, 1)])
        self.assertEqual(ch["trig"][1], (1_024_000_000, 1))

    def test_edge_27msps(self):
        # 2. ch3 の立ち上がりは 100 サンプルめ (3.704 µs)、以後 300 サンプル (11.111 µs) ごと
        ch = self.vcd(2, div=1, pre=100)
        rises = [t for t, v in ch["ch3"][1:] if v == 1]
        self.assertEqual(rises[0], round(100 * 1e12 / 27e6))
        self.assertEqual(rises[1] - rises[0], round(400 * 1e12 / 27e6) - round(100 * 1e12 / 27e6))
        self.assertEqual(len(rises), 14)

    def test_square_100ksps(self):
        # 4. 10 kHz の方形波を 100 kS/s で。変わり目は 50 µs ごと
        ch = self.vcd(4, div=270, pre=0)
        times = [t for t, _ in ch["ch0"]]
        gaps = {b - a for a, b in zip(times[1:], times[2:])}
        self.assertEqual(gaps, {50_000_000})


if __name__ == "__main__":
    unittest.main(verbosity=2)
