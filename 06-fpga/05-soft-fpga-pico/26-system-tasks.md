---
book: fpga
chapter: 5
id: 5-26
title: $display・$finish・$readmemh を Pico で使う — ビルドして確かめ、ROM は initial に埋める
tier: 100
source: 自作
board: —
device: PICO
---

# 5-26 $display・$finish・$readmemh を Pico で使う — ビルドして確かめ、ROM は initial に埋める

> [!WARNING]
> **この題は実機で動かしていない。** 確かめたのは、PC の Docker での Verilator の変換と Pico SDK でのビルド (`.uf2` ができること) と、
> ランタイムのソースを読んだ結果だけ。「Pico 2 で動いたらこうなる」と書いた所は、ソースの読みで、実機では確かめていない。

この題は実体配線図と Analog Discovery 3 の図を付けない。PC でビルドするだけの組まない題だから。

5-13 では、Verilator のランタイムの役割ごとに Pico 2 での扱いを決めた。この題では、Verilog に `$display`・`$finish`・`$readmemh` を書いたとき何が起きるかを、
実際にビルドして確かめる。ファイルの無い Pico 2 でも ROM を持てるように、`$readmemh` を `initial` 文に置き換える。

## 実際にビルドして確かめる

次の 3 つの Verilog を、5-1 と同じ手順 (`verilate.sh` → Pico SDK) でビルドした。主ループは `static` のモデルを 1 つ置き、立ち下がり・立ち上がりの `eval()` を繰り返す形で、どれも同じ。
`p_none` の主ループは次の形で、LED は GP14 に `count` の最下位を出す。

```cpp
#include "pico/stdlib.h"
#include "Vp_none.h"
static Vp_none top;
int main() {
    gpio_init(14); gpio_set_dir(14, GPIO_OUT);
    top.rst = 1; top.clk = 0; top.eval(); top.clk = 1; top.eval();   // リセット
    top.rst = 0;
    while (true) {
        top.clk = 0; top.eval();
        top.clk = 1; top.eval();
        gpio_put(14, top.count & 1);
    }
}
```

`p_disp` は `static VerilatedContext ctx; static Vp_disp top{&ctx};` にして、ループの条件を `while (!ctx.gotFinish())` に替える (ループのあとは `tight_loop_contents()` で待つ)。
`p_rom`・`p_rom2` は、リセットの代わりに周回ごとに `top.addr` を 0〜15 で進め、`data` の最下位を出す。
どれも `stdio_init_all()` は呼んでいない (表の大きさは、周りの仕事を足したぶんだけを見るため)。

`p_none.v` (周りの仕事を使わない 4 ビットのカウンタ):

```verilog
module p_none (
    input        clk,
    input        rst,
    output [3:0] count
);
    reg [3:0] r;
    assign count = r;
    always @(posedge clk)
        if (rst) r <= 4'd0;
        else     r <= r + 4'd1;
endmodule
```

`p_disp.v` (`$display` と `$finish` を使う):

```verilog
module p_disp (
    input        clk,
    input        rst,
    output [3:0] count
);
    reg [3:0] r;
    assign count = r;
    always @(posedge clk) begin
        if (rst) r <= 4'd0;
        else     r <= r + 4'd1;
        if (r == 4'd9) begin
            $display("count reached %0d", r);
            $finish;
        end
    end
endmodule
```

`p_rom.v` (`$readmemh` で ROM を読む):

```verilog
module p_rom (
    input        clk,
    input  [3:0] addr,
    output reg [7:0] data
);
    reg [7:0] rom [0:15];
    initial $readmemh("rom.hex", rom);
    always @(posedge clk) data <= rom[addr];
endmodule
```

3 つとも、Verilator の `--lint-only` ではなく、5-1 の `verilate.sh` と同じ `-Wall --no-timing --no-trace` で変換し、警告なしで通った。

| 回路 | `.uf2` | text | bss | `p_none` との差 (text) |
| --- | --- | --- | --- | --- |
| `p_none` | 93 184 バイト | 50 184 バイト | 2 452 バイト | — |
| `p_disp` (`$display` + `$finish`) | 121 856 バイト | 64 524 バイト | 2 892 バイト | +14 340 バイト |
| `p_rom` (`$readmemh`) | 105 984 バイト | 56 568 バイト | 2 480 バイト | +6 384 バイト |

- **3 つともビルドとリンクは通った。** Pico SDK の newlib に `fopen` や `printf` が無いことは、リンクを止めない
- `$display` を 1 つ書くと、書式を整形する関数 (`_vl_vsformat` ほか) が引き込まれ、text が約 14 KB 増えた。フラッシュ (4 MB) には収まる
- `$readmemh` を書くと、ファイルを読む仕組みが引き込まれて約 6 KB 増えた。動かしたときの動きは次の項

### 動かしたらどうなるか (ソースの読み)

- **`$display`**: `VL_PRINTF` は `printf`。`stdio_init_all()` を呼べば、既定は UART0 (GP0 が TX、GP1 が RX) に出る (Pico SDK の `pico2.h`)。
  呼ばないと、どこにも出ない。USB に出すのは 5-14
- **`$finish`**: `vl_finish` は文を出して `gotFinish(true)` を立てるだけで、プログラムを止めない。止めるのは主ループの側 (`while (!ctx.gotFinish())`)。
  `p_disp` の主ループはそう書いた。止めずに回し続けると、`$finish` のあとも `eval()` が続く
- **`$stop`・`$fatal`・致命的な診断**: `vl_fatal` が文を出して `std::exit(1)`。Pico SDK の `_exit` は `__breakpoint()` を無限に繰り返す。
  つまり**固まる**。デバッガをつないでいなければ、LED が止まったように見える
- **`$readmemh`**: `fopen("rom.hex")` は、Pico SDK の `_open` が -1 を返すので失敗する。
  `VlReadMem` は「`$readmem file not found`」の警告を出して続ける。**ROM は初期値のまま (0) で、回路は ROM が空のまま動く**。
  警告は `$display` と同じく stdio に出るので、stdio を出していないと気づけない

## `$readmemh` を `initial` 文に置き換える

ROM の中身は、ビルドのときに Verilog の中へ埋め込めば、ファイルが要らない。TD4 (5-8) の `TD4.v` が `initial begin rom[...] = ...; end` で ROM を書いているのと同じ形。
hex ファイルから、`initial` の中身を作る小さなスクリプトを置く。

```python
#!/usr/bin/env python3
"""hex2init.py — $readmemh 用の hex ファイルを、Verilog の initial 文の並びに直す。

使い方: python3 hex2init.py rom.hex rom > rom_init.vh
  hex の 1 行に 1 つの値。'//' から後ろは注釈。'@' の番地指定には対応しない (断る)。
"""
import sys


def main(path, name):
    values = []
    with open(path) as f:
        for lineno, line in enumerate(f, 1):
            text = line.split("//")[0].strip()
            if not text:
                continue
            if text.startswith("@"):
                sys.exit(f"{path}:{lineno}: '@' の番地指定には対応していない")
            values.extend(text.split())
    width = max(len(v) for v in values) * 4
    for i, v in enumerate(values):
        print(f"{name}[{i}] = {width}'h{v};")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit("使い方: hex2init.py rom.hex rom > rom_init.vh")
    main(sys.argv[1], sys.argv[2])
```

```bash
python3 hex2init.py rom.hex rom > rom_init.vh
```

`rom.hex` が 16 行の値 (`00` `11` … `FF`) のとき、出力は `rom[0] = 8'h00;` … `rom[15] = 8'hFF;` の 16 行。
Verilog の側は、`initial` の中で `` `include `` する。

```verilog
module p_rom2 (
    input        clk,
    input  [3:0] addr,
    output reg [7:0] data
);
    reg [7:0] rom [0:15];

    initial begin
`include "rom_init.vh"
    end

    always @(posedge clk) data <= rom[addr];
endmodule
```

これも `-Wall` で警告なしに変換でき、Pico SDK のビルドが通った。

| 回路 | `.uf2` | text | `p_none` との差 (text) |
| --- | --- | --- | --- |
| `p_rom2` (`initial` に置き換え) | 92 672 バイト | 50 000 バイト | −184 バイト |

`$readmemh` の版 (`p_rom`) より text が 6 568 バイト小さく、ファイルを読む仕組みも要らない。
Verilator の `--public-flat-rw` で内部の配列に C++ から書き込む方法もあるが、ここでは使わない
(ROM の中身を Verilog の側に置いたほうが、PC の Verilator・ブラウザ (第 4 章)・実物の FPGA (第 8 章) で同じ `.v` を使い回せる)。

## 見るべき値

**実機では動かしていない。** 表は、PC の Docker (Verilator 5.048、Pico SDK 2.2.0) でビルドして出た値。

| 確かめること | 打つ物 | 出た物 |
| --- | --- | --- |
| 変換 (`-Wall`) | `sh verilate.sh` (`sfa-dev:local` の中) | `p_none`・`p_disp`・`p_rom`・`p_rom2` とも警告なし |
| `$display` + `$finish` を足したときの text の増え方 | `arm-none-eabi-size` | +14 340 バイト (50 184 → 64 524) |
| `$readmemh` を足したときの text の増え方 | 同じ | +6 384 バイト (50 184 → 56 568) |
| `$readmemh` を `initial` に直したとき | 同じ | 50 000 バイト (`p_none` より 184 バイト少ない) |

## シミュレーションでの確かめ (対象外を含む)

PC で回す確かめは手元の Verilator 5.042 で行った。本文の `p_none.v`・`p_disp.v`・`p_rom.v`・`p_rom2.v`・`hex2init.py` を抜き出し、
`-Wall --no-timing --no-trace` で C++ にして、PC の Verilator と Pico SDK でそれぞれ動かした
(`sim/13-runtime-trim-*.v`・`-disp-tb.cpp`・`-rom-tb.cpp`)。主ループは本文の説明どおり (static のモデルを 1 つ、立ち下がり・立ち上がりの `eval()`) に書いた。
`.uf2` と `arm-none-eabi-size` の値は、本文の Docker イメージ (`sfa-dev:local` の Verilator 5.048 と `wb-pico-sdk` の Pico SDK 2.2.0、`arm-none-eabi-gcc` 13.2.1) で、本文の `.cpp` と `.v` からビルドし直した値。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| 変換 (`-Wall`) | 4 つとも警告なし | 警告なし | 合った |
| `$display` と `$finish` | 文を出して `gotFinish` が立つ。止めるのは主ループ | `count reached 9` を出し、10 クロック目で `gotFinish` = 1 | 合った |
| `$readmemh` (`rom.hex` が有る) | ROM が読める | 0・17・34 … 255 の 16 値が読めた | 合った |
| `$readmemh` (`rom.hex` が無い) | 警告を出して続け、ROM は 0 のまま | `$readmem file not found` を出して 16 値とも 0 | 合った |
| `hex2init.py` | 16 行の `rom[i] = 8'hXX;` | 16 行 (`rom[0] = 8'h00;` … `rom[15] = 8'hFF;`) | 合った |
| `p_rom2` (`initial` に置き換え) | `p_rom` と同じ中身 | 16 値とも `p_rom` と同じ | 合った |
| `_exit` と `_open` | `_exit` は `__breakpoint()` の無限ループ、`_open` は −1 | `newlib_interface.c` のとおり | 合った |
| `.uf2` (`p_none`) | 93 184 バイト、text 50 184・bss 2 452 | 93 184 バイト、text 50 184・bss 2 452 | 合った |
| `.uf2` (`p_disp`) | 121 856 バイト、text 64 524・bss 2 892 | 121 856 バイト、text 64 524・bss 2 892 | 合った |
| `.uf2` (`p_rom`) | 105 984 バイト、text 56 568・bss 2 480 | 105 984 バイト、text 56 568・bss 2 480 | 合った |
| `.uf2` (`p_rom2`) | 92 672 バイト、text 50 000 | 92 672 バイト、text 50 000 | 合った |
| `$display` を足したときの text | +14 340 バイト | +14 340 バイト | 合った |
| `$readmemh` を足したときの text | +6 384 バイト | +6 384 バイト | 合った |
| `initial` に直したときの text | −184 バイト | −184 バイト | 合った |

確かめられなかったもの。

- Pico 2 の上での `$display` の出力先と `exit` で固まる動き (実機)。ソースの読みだけ

## 出典

自作。ランタイムの仕組みは [Verilator User's Guide](https://veripool.org/guide/latest/) と、Verilator 5.048 の `verilated.cpp`・`verilated.h`。
Pico SDK の `_exit`・`_open`・既定の UART は Pico SDK 2.2.0 の `pico_clib_interface/newlib_interface.c` と `boards/pico2.h`。
ランタイムの直し方は 5-13。
