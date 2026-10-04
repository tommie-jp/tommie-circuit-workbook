---
book: fpga
chapter: 1
id: 1-5
title: always @(*) と case — デコーダ
tier: 50
source: 自作
board: —
device: SIM
---

# 1-5 always @(*) と case — デコーダ

デコーダは、入力の組み合わせに応じて、出力の 1 本だけを 1 にする回路だ。
2 ビットの入力 a を 4 本の出力 y に直す 2 → 4 デコーダを、`always @(*)` と `case` で書く。
式を 1 行ずつ書く `assign` と違い、入力ごとの出力を表のように並べて書ける。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。

## 説明

- `always @(*)` は「右辺に出てくる信号のどれかが変わるたびに、中の文を実行し直す」という意味の組み合わせ回路の書き方だ。
  `(*)` は、必要な信号を自動で拾う印になる
- `always` の中で値を入れる信号は、`wire` ではなく `reg` と宣言する。`reg` と書いても、組み合わせ回路なら記憶はしない
- `case (a)` は、a の値ごとに行き先を分ける。各行は `値: 文;` と書く
- **`default:` は、どの行にも当てはまらないときの値を決める。** a は 2 ビットなので 0〜3 で全部の値を書き尽くしているが、
  それでも `default` を置く。あとで a を広げたり、書き漏れたりしたとき、出力が決まらない入力があると、
  回路は「前の値を覚えておく」記憶素子 (ラッチ) になってしまうからだ。1-13 でこの失敗を実際に起こして見る
- `always @(*)` の中の代入は `=` (ブロッキング代入) で書く。順序回路の `<=` は 2-2 で使い分ける

## 論理図

図 1 はゲートで描いたデコーダだ。a1・a0 とそれぞれを反転した線を 4 本用意し、
その中から 2 本ずつを AND に入れる。4 つの AND のどれが 1 になるかが、a の値で決まる。

```circuit
title: 図1 2 ビットから 4 本へのデコーダ
parts:
  a1: port b1
  a0: port d1
  N1: not b6
  N2: not d13
  Y0: and h21
  Y1: and l21
  Y2: and p21
  Y3: and t21
  y0: port h26
  y1: port l26
  y2: port p26
  y3: port t26
wires:
  - b1 -- b4
  - b4 -- t4
  - b4 -- N1.in
  - N1.out -- b9
  - b9 -- l9
  - d1 -- d12
  - d12 -- t12
  - d12 -- N2.in
  - N2.out -- d16
  - d16 -- p16
  - h9 |- Y0.a
  - l9 |- Y1.a
  - p4 |- Y2.a
  - t4 |- Y3.a
  - h16 |- Y0.b
  - l12 |- Y1.b
  - p16 |- Y2.b
  - t12 |- Y3.b
  - Y0.out -- h26
  - Y1.out -- l26
  - Y2.out -- p26
  - Y3.out -- t26
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/05-case-decoder.svg)

- a1・a0 の縦線から横に伸びる線は、交わる所に黒丸が無い限りつながっていない。黒丸がある所だけで枝分かれしている
- Y0 は a1 も a0 も 0 のとき (入力の反転どうしの AND)、Y3 は両方 1 のときに 1 になる
- Y1 は a1 が 0 で a0 が 1 のとき、Y2 は a1 が 1 で a0 が 0 のときに 1 になる

## Verilog

```verilog
// decoder2to4.v
module decoder2to4 (
    input  wire [1:0] a,
    output reg  [3:0] y
);
    always @(*) begin
        case (a)
            2'd0:    y = 4'b0001;
            2'd1:    y = 4'b0010;
            2'd2:    y = 4'b0100;
            2'd3:    y = 4'b1000;
            default: y = 4'b0000;
        endcase
    end
endmodule
```

- 各行の右辺の `4'b0001` は「4 ビットの 2 進数の 0001」の書き方。`4'b0001` と `4'd1` は同じ値で、ここではどの 1 本が 1 かを見せるために 2 進数で書いた
- 出力 y の最下位ビット (`y[0]`) が図の Y0 に当たる

## 動かす

```cpp
// tb_decoder2to4.cpp
#include <cstdio>
#include "Vdecoder2to4.h"

int main() {
    Vdecoder2to4 top;
    std::printf("# a y\n");
    for (int a = 0; a < 4; a++) {
        top.a = a;
        top.eval();
        std::printf("%x %x\n", top.a, top.y);
    }
    return 0;
}
```

```bash
verilator --lint-only -Wall decoder2to4.v
verilator -Wall --cc --exe --build decoder2to4.v tb_decoder2to4.cpp
./obj_dir/Vdecoder2to4
```

a を 0 から 3 まで順に与えた結果 (16 進) は次のとおりだった。

```text
a y
0 1
1 2
2 4
3 8
```

## 計器の設定

組まない題なので、計器は使わない。実行結果をロジックアナライザの画面と同じ形の図 2 に描く。
実機で測った波形ではなく、実行結果から作った計算の図で、入力を変えた 1 回を 1 ms と見なして並べた。

```logic
title: 図2 a を 0 から 3 まで変えたときの y (Verilator の実行結果から作った計算の図)
device: generic
window: 4ms
signals:
  a0: pattern 0101 bit 1ms
  a1: pattern 0011 bit 1ms
  y0: pattern 1000 bit 1ms
  y1: pattern 0100 bit 1ms
  y2: pattern 0010 bit 1ms
  y3: pattern 0001 bit 1ms
buses:
  a: a1 a0 hex
  y: y3 y2 y1 y0 hex
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/05-case-decoder.svg)

## 見るべき値

| a (2 進) | y (2 進、y3 y2 y1 y0) | 1 になる出力 |
| --- | --- | --- |
| 00 | 0001 | y0 |
| 01 | 0010 | y1 |
| 10 | 0100 | y2 |
| 11 | 1000 | y3 |

- どの行でも、1 になる出力は 1 本だけだ。このような出し方を **ワンホット** と呼ぶ
- 実行結果の y の列 (16 進で 1・2・4・8) が、2 進の 0001・0010・0100・1000 に当たる

## 出典

自作。
