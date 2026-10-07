---
book: fpga
chapter: 1
id: 1-6
title: 半加算器と全加算器
tier: 50
source: 自作
board: —
device: SIM
---

# 1-6 半加算器と全加算器

2 進数の足し算を回路で作る。1 桁どうしの足し算は、答えの桁 (和) と、上の桁へ渡す桁上げの 2 つを出す。
XOR と AND だけで作る半加算器、それを 2 つ重ねて下の桁からの桁上げも受ける全加算器を、Verilog で書く。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。
同じ回路を CD4070 などの IC で組む題は、回路の冊の 10-3 にある。

## 説明

- 1 + 1 = 10 (2 進数) のように、1 桁の足し算は「この桁の和」と「上の桁への桁上げ」を出す。
  和は XOR、桁上げは AND で作れる
- **半加算器** は、2 つの入力 a と b を足す。下の桁からの桁上げ (cin) は受けない
- **全加算器** は、a と b と cin の 3 つを足す。半加算器を 2 つ使い、桁上げ 2 つを OR で合わせる。
  2 つの桁上げが同時に 1 になることは無いので、OR でまとめてよい
- 半加算器を箱 (module) にして、全加算器から 2 回呼ぶ。1-2 で見た「箱を呼ぶ」書き方を使う

## 論理図

図 1 は半加算器だ。

```circuit
title: 図1 半加算器 (和は XOR、桁上げは AND)
parts:
  a: port 1,3
  b: port 1,11
  X1: xor 8,3
  A1: and 8,7
  sum: port 14,3
  carry: port 14,7
wires:
  - 1,3 -- 3,3
  - 3,3 -- 3,7
  - 3,3 |- X1.a
  - 3,7 |- A1.a
  - 1,11 -- 5,11
  - 5,11 -- 5,3
  - 5,3 |- X1.b
  - 5,11 |- A1.b
  - X1.out -- 14,3
  - A1.out -- 14,7
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/06-adders-1.svg)

図 2 は全加算器だ。X1・A1 が 1 つ目の半加算器 (`u_ha1`)、X2・A2 が 2 つ目 (`u_ha2`) に当たり、桁上げ 2 つを O1 (OR) で合わせる。

```circuit
title: 図2 全加算器は半加算器 2 つと OR (X1 と A1 が u_ha1、X2 と A2 が u_ha2)
parts:
  a: port 1,3
  b: port 1,11
  cin: port 1,17
  X1: xor 8,3
  A1: and 8,7
  X2: xor 20,3
  A2: and 20,11
  O1: or 28,7
  sum: port 34,3
  cout: port 34,7
wires:
  - 1,3 -- 3,3
  - 3,3 -- 3,7
  - 3,3 |- X1.a
  - 3,7 |- A1.a
  - 1,11 -- 5,11
  - 5,11 -- 5,3
  - 5,3 |- X1.b
  - 5,11 |- A1.b
  - X1.out -- 14,3
  - 14,3 |- X2.a
  - 14,3 -- 14,11
  - 14,11 |- A2.a
  - 1,17 -- 17,17
  - 17,17 -- 17,3
  - 17,3 |- X2.b
  - 17,11 |- A2.b
  - A1.out -- 25,7
  - 25,7 |- O1.a
  - A2.out -- 25,11
  - 25,11 |- O1.b
  - X2.out -- 34,3
  - O1.out -- 34,7
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/06-adders-2.svg)

- 1 つ目の半加算器の和 (X1 の出力) が、2 つ目の半加算器の a に入る。この線は X2 と A2 の両方に枝分かれしている
- cin の縦線と、1 つ目の桁上げ (A1 の出力) の横線は交わるが、黒丸が無いのでつながっていない

## Verilog

```verilog
// half_adder.v
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;
    assign carry = a & b;
endmodule
```

```verilog
// full_adder.v
module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    wire s1, c1, c2;
    half_adder u_ha1 (.a(a),  .b(b),   .sum(s1),  .carry(c1));
    half_adder u_ha2 (.a(s1), .b(cin), .sum(sum), .carry(c2));
    assign cout = c1 | c2;
endmodule
```

- `full_adder` の中で `half_adder` を 2 回呼んでいる。内部の線 `s1`・`c1`・`c2` は図 2 の線に当たる
- `cout = c1 | c2;` が図 2 の O1

## 動かす

```cpp
// tb_full_adder.cpp
#include <cstdio>
#include "Vfull_adder.h"

int main() {
    Vfull_adder top;
    std::printf("# a b cin sum cout\n");
    for (int i = 0; i < 8; i++) {
        top.a   = (i >> 2) & 1;
        top.b   = (i >> 1) & 1;
        top.cin = i & 1;
        top.eval();
        std::printf("%x %x %x %x %x\n", top.a, top.b, top.cin, top.sum, top.cout);
    }
    return 0;
}
```

```bash
verilator --lint-only -Wall full_adder.v half_adder.v
verilator -Wall --cc --exe --build full_adder.v half_adder.v tb_full_adder.cpp
./obj_dir/Vfull_adder
```

a・b・cin を 000 から 111 まで順に与えた結果は次のとおりだった。

```text
a b cin sum cout
0 0 0 0 0
0 0 1 1 0
0 1 0 1 0
0 1 1 0 1
1 0 0 1 0
1 0 1 0 1
1 1 0 0 1
1 1 1 1 1
```

## 計器の設定

組まない題なので、計器は使わない。実行結果をロジックアナライザの画面と同じ形の図 3 に描く。
実機で測った波形ではなく、実行結果から作った計算の図で、入力を変えた 1 回を 1 ms と見なして並べた。

```logic
title: 図3 a b cin を 000 から 111 まで順に変えたときの sum と cout (Verilator の実行結果から作った計算の図)
device: generic
window: 8ms
signals:
  a: pattern 00001111 bit 1ms
  b: pattern 00110011 bit 1ms
  cin: pattern 01010101 bit 1ms
  sum: pattern 01101001 bit 1ms
  cout: pattern 00010111 bit 1ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/06-adders.svg)

## 見るべき値

| a | b | cin | sum | cout | 10 進で |
| --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 0 | 1 |
| 0 | 1 | 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 | 1 | 2 |
| 1 | 0 | 0 | 1 | 0 | 1 |
| 1 | 0 | 1 | 0 | 1 | 2 |
| 1 | 1 | 0 | 0 | 1 | 2 |
| 1 | 1 | 1 | 1 | 1 | 3 |

- cout を 2 の位、sum を 1 の位として読むと、a + b + cin の答えになる (最後の列)
- 最後の行 (a = b = cin = 1) だけ sum と cout が両方 1 になる。1 + 1 + 1 = 3 (2 進数で 11) で、cin を足せる全加算器でないと作れない行だ
- 実行結果の 8 行が、この表と同じになっている

## 出典

自作。回路の考え方は、回路の冊の 10-3 (半加算器と全加算器) による。
