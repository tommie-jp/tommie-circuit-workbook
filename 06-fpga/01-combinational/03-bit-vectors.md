---
book: fpga
chapter: 1
id: 1-3
title: ビットの束 — 幅のある信号と連結・切り出し
tier: 50
source: 自作
board: —
device: SIM
---

# 1-3 ビットの束 — 幅のある信号と連結・切り出し

これまでの信号は 1 ビット (0 か 1) だった。数やアドレスを扱うには、複数のビットを束ねた信号を使う。
この題では、2 ビットの信号 a と b をつないで 4 ビットの信号を作り (連結)、そこから一部を取り出す (切り出し)。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。

## 説明

- `wire [3:0] x;` は 4 ビットの信号で、`[3:0]` は「上の端のビットが 3 番、下の端が 0 番」という意味。
  上の端のビットを **MSB**、下の端を **LSB** と呼ぶ
- 連結 `{a, b}` は、左に書いた信号が上位、右が下位になるように並べる。幅は 2 つの合計になる
- 切り出し `x[1:0]` は番号 1 から 0 の 2 ビット、`x[3]` は 3 番の 1 ビットだけを取り出す
- 束の信号を 1 つの数として見るときは、16 進で書くと桁が揃う。4 ビットがちょうど 16 進の 1 桁になる

## 論理図

束の連結と切り出しにゲートは要らない。線を並べ替えて、つなぎ替えるだけだ。
図 1 は 4 本の線の上に、`cat` の 4 ビットと、そこから取り出した `low` (2 本)・`msb` (1 本) の名前を付けたものだ。

```circuit
title: 図1 a と b を連結した cat と、その一部を取り出した low と msb
parts:
  a1: port b1
  a0: port d1
  b1: port f1
  b0: port h1
  cat3: port b12
  cat2: port d12
  cat1: port f12
  cat0: port h12
  msb: port b17
  low1: port f17
  low0: port h17
wires:
  - b1 -- b12
  - d1 -- d12
  - f1 -- f12
  - h1 -- h12
  - b12 -- b17
  - f12 -- f17
  - h12 -- h17
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/03-bit-vectors.svg)

- 上から順に a の上位ビット `a1`、下位ビット `a0`、b の上位ビット `b1`、下位ビット `b0` が並ぶ。
  `{a, b}` の順がそのまま `cat3`〜`cat0` の順になる
- `msb` は `cat3` と同じ線、`low1`・`low0` は `cat1`・`cat0` と同じ線で、新しい回路は何も増えない

## Verilog

```verilog
// bits.v
module bits (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire [3:0] cat,
    output wire [1:0] low,
    output wire       msb
);
    assign cat = {a, b};      // 連結: 上位に a、下位に b
    assign low = cat[1:0];    // 切り出し: 下位 2 ビット
    assign msb = cat[3];      // 切り出し: 最上位の 1 ビット
endmodule
```

- `[1:0]` と `[3:0]` で幅を宣言する。幅を書かない信号は 1 ビットだ
- `cat` は 4 ビットで、`{a, b}` の幅 2 + 2 とぴったり合っている。Verilator の `-Wall` は、幅が合わない代入を警告する
- `cat` は出力だが、同じ module の中で `cat[1:0]` のように読んでもよい

## 動かす

```cpp
// tb_bits.cpp
#include <cstdio>
#include "Vbits.h"

int main() {
    Vbits top;
    const int a_list[] = {0, 1, 2, 3};
    const int b_list[] = {0, 2, 3, 1};
    std::printf("# a b cat low msb\n");
    for (int i = 0; i < 4; i++) {
        top.a = a_list[i];
        top.b = b_list[i];
        top.eval();
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.cat, top.low, top.msb);
    }
    return 0;
}
```

```bash
verilator --lint-only -Wall bits.v
verilator -Wall --cc --exe --build bits.v tb_bits.cpp
./obj_dir/Vbits
```

束の信号は C++ では整数 (`int`) に見える。`top.a = 2;` と書けば a の 2 ビットが `10` になる。実行した結果 (16 進) は次のとおりだった。

```text
a b cat low msb
0 0 0 0 0
1 2 6 2 0
2 3 b 3 1
3 1 d 1 1
```

## 計器の設定

組まない題なので、計器は使わない。実行結果をロジックアナライザの画面と同じ形の図 2 に描く。
下の `a`・`b`・`cat`・`low` は、上の各ビットの線をまとめて 16 進で読んだバス (束) の表示だ。
実機で測った波形ではなく、実行結果から作った計算の図で、入力を変えた 1 回を 1 ms と見なして並べた。

```logic
title: 図2 a と b を 4 回変えたときの cat と low と msb (Verilator の実行結果から作った計算の図)
device: generic
window: 4ms
signals:
  a0: pattern 0101 bit 1ms
  a1: pattern 0011 bit 1ms
  b0: pattern 0011 bit 1ms
  b1: pattern 0110 bit 1ms
  cat0: pattern 0011 bit 1ms
  cat1: pattern 0110 bit 1ms
  cat2: pattern 0101 bit 1ms
  cat3: pattern 0011 bit 1ms
  low0: pattern 0011 bit 1ms
  low1: pattern 0110 bit 1ms
  msb: pattern 0011 bit 1ms
buses:
  a: a1 a0 hex
  b: b1 b0 hex
  cat: cat3 cat2 cat1 cat0 hex
  low: low1 low0 hex
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/03-bit-vectors.svg)

## 見るべき値

| a | b | cat = {a, b} | low = cat[1:0] | msb = cat[3] |
| --- | --- | --- | --- | --- |
| 0 (00) | 0 (00) | 0x0 (0000) | 0x0 | 0 |
| 1 (01) | 2 (10) | 0x6 (0110) | 0x2 | 0 |
| 2 (10) | 3 (11) | 0xB (1011) | 0x3 | 1 |
| 3 (11) | 1 (01) | 0xD (1101) | 0x1 | 1 |

- 3 行目で、a = 2 (`10`) が上位、b = 3 (`11`) が下位に並んで `1011` = 0xB になる。実行結果の `b` と一致する
- `low` は `cat` の下位 2 ビットなので、いつも `b` と同じ値になる
- `msb` は `a` の上位ビットと同じ値になる

## 出典

自作。
