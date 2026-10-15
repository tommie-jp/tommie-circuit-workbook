#!/usr/bin/env python3
"""Tang Nano 9K の小さいロジックアナライザ (12-6) を PC から動かし、VCD に書き出す。

    python3 la.py --port /dev/ttyUSB1 --rate 1M --trigger rise:3 --pre 1024 -o out.vcd
    python3 la.py --port COM5 --rate 27M --trigger pattern:xxxx1xx0 -o out.vcd

--rate は 27 MHz を割り切れる速さ (27M・13.5M・9M・…・1M・100k など)。
--trigger は rise:<ch> (立ち上がり)、pattern:<8 字> (左が ch7、0・1・x)、
両方を + でつなぐ (rise:3+pattern:xxxxxxx1)、none (すぐ止める) のどれか。
"""
from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from typing import IO, Sequence

CLK_HZ = 27_000_000
BAUD = 115_200
DEPTH = 4096
CHANNELS = 8


@dataclass(frozen=True)
class Trigger:
    mask: int = 0          # 1 のチャネルだけ比べる
    value: int = 0         # 比べる値
    edge_ch: int | None = None   # 立ち上がりを見るチャネル (無ければ None)


def parse_rate(text: str) -> int:
    """'1M' '100k' '27000000' を分周の数 div にする。27 MHz を割り切れなければ ValueError。"""
    scale = {"k": 1e3, "K": 1e3, "M": 1e6}
    hz = float(text[:-1]) * scale[text[-1]] if text[-1] in scale else float(text)
    div = round(CLK_HZ / hz)
    if div < 1 or div > 0xFFFF or abs(CLK_HZ / div - hz) > hz * 1e-6:
        raise ValueError(f"{text}: 27 MHz を 1〜65535 で割った速さにする (近いのは {CLK_HZ / max(div, 1):.0f} Hz)")
    return div


def parse_trigger(text: str) -> Trigger:
    """rise:3 / pattern:xxxx1xx0 / rise:3+pattern:... / none を Trigger にする。"""
    mask = value = 0
    edge_ch = None
    if text == "none":
        return Trigger()
    for part in text.split("+"):
        kind, _, arg = part.partition(":")
        if kind == "rise":
            edge_ch = int(arg)
            if not 0 <= edge_ch < CHANNELS:
                raise ValueError(f"{part}: チャネルは 0〜7")
        elif kind == "pattern":
            if len(arg) != CHANNELS or any(c not in "01xX" for c in arg):
                raise ValueError(f"{part}: 0・1・x を 8 字 (左が ch7)")
            for i, c in enumerate(reversed(arg)):
                if c in "01":
                    mask |= 1 << i
                    value |= int(c) << i
        else:
            raise ValueError(f"{part}: rise:<ch> か pattern:<8 字>")
    return Trigger(mask, value, edge_ch)


def build_command(div: int, trig: Trigger, pre: int) -> bytes:
    """'A' と 7 バイト (div 上下・mask・value・edge・pre 上下) を作る。"""
    if not 0 <= pre < DEPTH:
        raise ValueError(f"pre は 0〜{DEPTH - 1}")
    edge = 0 if trig.edge_ch is None else 0x80 | trig.edge_ch
    return bytes([ord("A"), div >> 8, div & 0xFF, trig.mask, trig.value, edge, pre >> 8, pre & 0xFF])


def parse_dump(raw: bytes) -> list[int]:
    """FPGA から来た 'D' と 4096 バイトを、サンプルの並びにする。"""
    if len(raw) != DEPTH + 1 or raw[0] != ord("D"):
        raise ValueError(f"'D' と {DEPTH} バイトのはずが、{len(raw)} バイト (先頭 {raw[:1]!r})")
    return list(raw[1:])


def write_vcd(out: IO[str], samples: Sequence[int], div: int, pre: int) -> None:
    """サンプルを VCD に書く。時刻の単位は ps、0 が最初のサンプル。trig はトリガのサンプルで 1。"""
    ids = [chr(ord("!") + i) for i in range(CHANNELS)]
    trig_id = chr(ord("!") + CHANNELS)
    out.write("$date tommie-circuit-workbook 12-6 $end\n")
    out.write(f"$comment rate {CLK_HZ / div:.0f} Hz (27 MHz / {div}), trigger at sample {pre} $end\n")
    out.write("$timescale 1ps $end\n$scope module la $end\n")
    for i, ident in enumerate(ids):
        out.write(f"$var wire 1 {ident} ch{i} $end\n")
    out.write(f"$var wire 1 {trig_id} trig $end\n$upscope $end\n$enddefinitions $end\n")
    prev: int | None = None
    for n, s in enumerate(samples):
        t_ps = round(n * div * 1e12 / CLK_HZ)
        lines = [f"{(s >> i) & 1}{ident}" for i, ident in enumerate(ids)
                 if prev is None or ((s ^ prev) >> i) & 1]
        if n in (0, pre, pre + 1):
            lines.append(f"{int(n == pre)}{trig_id}")
        if lines:
            out.write(f"#{t_ps}\n" + "\n".join(lines) + "\n")
        prev = s
    out.write(f"#{round(len(samples) * div * 1e12 / CLK_HZ)}\n")


def capture(port: str, div: int, trig: Trigger, pre: int, timeout: float) -> list[int]:
    """設定を送り、貯め終えて返ってくる 4097 バイトを受ける。"""
    import serial  # pyserial。試験 (test_la.py) では使わない

    with serial.Serial(port, BAUD, timeout=timeout) as ser:
        ser.reset_input_buffer()
        ser.write(build_command(div, trig, pre))
        raw = ser.read(DEPTH + 1)
        if len(raw) == 0:
            ser.write(b"F")                       # トリガが来ないので止めさせる
            raw = ser.read(DEPTH + 1)
        elif len(raw) < DEPTH + 1:                # 待つ間の終わりに送り始めた
            raw += ser.read(DEPTH + 1 - len(raw))
    return parse_dump(raw)


def main(argv: Sequence[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Tang Nano 9K の小さいロジックアナライザ")
    ap.add_argument("--port", required=True)
    ap.add_argument("--rate", default="1M")
    ap.add_argument("--trigger", default="none")
    ap.add_argument("--pre", type=int, default=DEPTH // 4)
    ap.add_argument("--timeout", type=float, default=10.0, help="トリガを待つ秒数。過ぎたら F で止める")
    ap.add_argument("-o", "--out", default="la.vcd")
    args = ap.parse_args(argv)
    try:
        div = parse_rate(args.rate)
        trig = parse_trigger(args.trigger)
        samples = capture(args.port, div, trig, args.pre, args.timeout)
    except (ValueError, OSError, ImportError) as e:
        print(f"la.py: {e}", file=sys.stderr)
        return 1
    with open(args.out, "w", encoding="ascii") as f:
        write_vcd(f, samples, div, args.pre)
    print(f"{args.out}: {len(samples)} samples at {CLK_HZ / div:.0f} Hz, trigger at {args.pre}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
