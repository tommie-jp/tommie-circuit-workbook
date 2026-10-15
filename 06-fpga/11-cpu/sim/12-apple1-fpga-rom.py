"""11-12: FPGA のブロック RAM に置く ROM の中身 ($E000-$FFFF の 8 KB) を $readmemh の形で書く。

ROM の中身 (Woz Monitor と Integer BASIC) はこのリポジトリに置かない。
soft-fpga の examples/04-6502/cxx/harness.cpp に C の配列 (WOZMON[256]・BASIC[4096]) として
入っているので、そこから読み出す。

    python3 -I 12-apple1-fpga-rom.py <soft-fpga>/examples/04-6502/cxx/harness.cpp rom.hex

並び: $E000-$EFFF = BASIC、$F000-$FEFF = $FF (何も無い)、$FF00-$FFFF = Woz Monitor。
1 行 1 バイト、8192 行。
"""

import re
import sys

ROM_BASE = 0xE000
ROM_SIZE = 0x2000


def c_array(source: str, name: str, size: int) -> bytes:
    """`static const uint8_t NAME[size] = { ... };` の中の 16 進を読む"""
    m = re.search(r"\b" + name + r"\[" + str(size) + r"\]\s*=\s*\{(.*?)\};", source, re.S)
    if m is None:
        raise SystemExit(f"{name}[{size}] が見つからない")
    body = re.sub(r"//[^\n]*", "", m.group(1))
    data = bytes(int(x, 16) for x in re.findall(r"0x([0-9A-Fa-f]{2})", body))
    if len(data) != size:
        raise SystemExit(f"{name} は {size} バイトのはずが {len(data)} バイト")
    return data


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: 12-apple1-fpga-rom.py <harness.cpp> <out.hex>")
    with open(sys.argv[1], encoding="utf-8") as f:
        src = f.read()
    basic = c_array(src, "BASIC", 4096)
    wozmon = c_array(src, "WOZMON", 256)

    rom = bytearray([0xFF] * ROM_SIZE)
    rom[0xE000 - ROM_BASE:0xE000 - ROM_BASE + len(basic)] = basic
    rom[0xFF00 - ROM_BASE:0xFF00 - ROM_BASE + len(wozmon)] = wozmon
    reset = rom[0xFFFC - ROM_BASE] | rom[0xFFFD - ROM_BASE] << 8
    with open(sys.argv[2], "w", encoding="ascii") as f:
        f.writelines(f"{b:02X}\n" for b in rom)
    print(f"wrote {len(rom)} bytes, reset vector = ${reset:04X}")


if __name__ == "__main__":
    main()
