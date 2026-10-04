---
book: fpga
chapter: 1
id: 1-1
title: assign で AND・OR・NOT — 論理図と Verilog を並べる
tier: 50
source: 自作
board: —
device: SIM
---

# 1-1 assign で AND・OR・NOT — 論理図と Verilog を並べる

Verilog は、回路のつながりを文字で書く言語だ。この章では、書いた Verilog を PC の
[Verilator](https://veripool.org/guide/latest/) で動かし、論理図と見比べる。
最初の題では、AND・OR・NOT の 3 つのゲートを `assign` で書く。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。
PC の中だけで動かす (`device: SIM`)。Verilator は 5.042 で確かめた。

## 説明

- `assign y = 式;` は、右辺の式の値を左辺の線 (`wire`) にいつも流しておく、という宣言だ。
  C 言語の代入のように「その行に来たら 1 度だけ実行する」命令ではない
- 演算子は `&` が AND、`|` が OR、`~` が NOT。1 ビットの信号ならそのままゲートの働きになる
- `assign` は何行書いても同時に働いている。並べる順を入れ替えても、できる回路は同じだ
- 入力は `input wire`、出力は `output wire` と書く。回路の外から見える口を **ポート** と呼ぶ

## 論理図

下の図 1 は、これから書く回路の論理図だ。入力は a と b の 2 本、出力は 3 本。
ゲート G1 (NOT) は a だけを使い、G2 (AND) と G3 (OR) は a と b の両方を使う。

```circuit
title: 図1 AND・OR・NOT の論理図
parts:
  a: port b1
  b: port h1
  G1: not b8
  G2: and e8
  G3: or h8
  y_not: port b13
  y_and: port e13
  y_or: port h13
wires:
  - b1 -- b3
  - b3 -- g3
  - b3 |- G1.in
  - e3 |- G2.a
  - g3 |- G3.a
  - h1 -- h5
  - h5 -- f5
  - f5 |- G2.b
  - h5 |- G3.b
  - G1.out -- b13
  - G2.out -- e13
  - G3.out -- h13
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/01-assign-gates.svg)

- 線の途中の黒丸は、そこで線が枝分かれして同じ信号がつながっていることを表す。
  a の縦線から G1・G2・G3 の入力へ枝が出ている
- b の縦線は、a から G3 へ向かう横線と交わるが、交わる所に黒丸が無い。黒丸が無い交差は、つながっていない
- 出力 y_not・y_and・y_or は、それぞれ 1 つのゲートの出力だ

## Verilog

図 1 を、そのまま `assign` 3 本にする。

```verilog
// gates.v
module gates (
    input  wire a,
    input  wire b,
    output wire y_and,
    output wire y_or,
    output wire y_not
);
    assign y_and = a & b;
    assign y_or  = a | b;
    assign y_not = ~a;
endmodule
```

- `module gates ( … );` が箱の名前とポートの並び。`endmodule` で閉じる
- `y_not = ~a;` が G1、`y_and = a & b;` が G2、`y_or = a | b;` が G3 に当たる。図と式が 1 対 1 に並ぶ

## 動かす

Verilator は Verilog を C++ に直して、PC で動く実行ファイルにする。
入力を与えて結果を読む C++ のプログラム (**テストベンチ**) は、次のように書く。
テストベンチの書き方は 3-1 で詳しく見る。ここでは `top.a` に値を入れて `top.eval()` を呼ぶと、
その入力に対する出力が `top.y_and` などに出てくる、とだけ読めばよい。

```cpp
// tb_gates.cpp
#include <cstdio>
#include "Vgates.h"

int main() {
    Vgates top;
    std::printf("# a b y_and y_or y_not\n");
    for (int i = 0; i < 4; i++) {
        top.a = (i >> 1) & 1;   // i = 0..3 の上位ビットを a、下位ビットを b に
        top.b = i & 1;
        top.eval();             // 入力を変えたら eval で出力を計算させる
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.y_and, top.y_or, top.y_not);
    }
    return 0;
}
```

まず、書き間違いが無いかを `--lint-only` で調べる。`%Warning` が出ず、終了コードが 0 なら通っている。
そのあと C++ にして組み立て、実行する。

```bash
verilator --lint-only -Wall gates.v
verilator -Wall --cc --exe --build gates.v tb_gates.cpp
./obj_dir/Vgates
```

実行した結果は次のとおりだった (1 行目は列の名前)。

```text
a b y_and y_or y_not
0 0 0 0 1
0 1 0 1 1
1 0 0 1 0
1 1 1 1 0
```

## 計器の設定

組まない題なので、計器は使わない。代わりに、実行の結果をロジックアナライザの画面と同じ形の図 2 に描く。
この図は実機で測った波形ではなく、上の実行結果から作った計算の図だ。
Verilator の中には時間が無いので、入力を変えた 1 回を 1 ms と見なして横に並べた。

```logic
title: 図2 入力を 00・01・10・11 の順に変えたときの出力 (Verilator の実行結果から作った計算の図)
device: generic
window: 4ms
signals:
  a: pattern 0011 bit 1ms
  b: pattern 0101 bit 1ms
  y_and: pattern 0001 bit 1ms
  y_or: pattern 0111 bit 1ms
  y_not: pattern 1100 bit 1ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/01-assign-gates.svg)

## 見るべき値

上の実行結果が、AND・OR・NOT の真理値表になっている。

| a | b | y_and (a AND b) | y_or (a OR b) | y_not (NOT a) |
| --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 1 |
| 0 | 1 | 0 | 1 | 1 |
| 1 | 0 | 0 | 1 | 0 |
| 1 | 1 | 1 | 1 | 0 |

- y_and が 1 になるのは a と b が両方 1 の行だけ
- y_or が 0 になるのは a と b が両方 0 の行だけ
- y_not は b に関係なく、a の反対になる。b を変えても y_not の列は動かない

## 出典

自作。Verilator の使い方は [Verilator のマニュアル](https://veripool.org/guide/latest/) による。
