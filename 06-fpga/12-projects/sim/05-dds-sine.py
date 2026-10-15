#!/usr/bin/env python3
"""DDS の正弦の表 (sine.hex) を作る。1 周期を 2^AW 語に分け、DW ビットの符号なしで書く。

    python3 sine.py            # 1024 語 × 8 ビットを sine.hex に
    python3 sine.py 12 8 out.hex

値は floor(M/2 + M/2 × sin(2π i / 2^AW) + 0.5)、M = 2^DW − 1。0 から M まで使う。
"""
import math
import sys


def table(aw: int, dw: int) -> list[int]:
    n = 1 << aw
    m = (1 << dw) - 1
    return [math.floor(m / 2 + m / 2 * math.sin(2 * math.pi * i / n) + 0.5) for i in range(n)]


def main() -> None:
    aw = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    dw = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    out = sys.argv[3] if len(sys.argv) > 3 else "sine.hex"
    digits = (dw + 3) // 4
    words = table(aw, dw)
    with open(out, "w", encoding="ascii") as f:
        f.write(f"// sine {1 << aw} x {dw} bit (sine.py)\n")
        for w in words:
            f.write(f"{w:0{digits}x}\n")
    print(f"{out}: {len(words)} words, min {min(words)}, max {max(words)}, "
          f"[0] {words[0]:x} [{len(words) // 4}] {words[len(words) // 4]:x}")


if __name__ == "__main__":
    main()
