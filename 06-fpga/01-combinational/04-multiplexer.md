---
book: fpga
chapter: 1
id: 1-4
title: マルチプレクサ — 条件演算子で 2 つから 1 つを選ぶ
tier: 50
source: 自作
board: —
device: SIM
---

# 1-4 マルチプレクサ — 条件演算子で 2 つから 1 つを選ぶ

マルチプレクサ (mux) は、複数の入力から 1 つを選んで出力に出す回路だ。
選ぶ信号 `sel` が 0 なら a、1 なら b を出す 2 入力のマルチプレクサを、条件演算子 `? :` で書く。

この題は組まない題で、実体配線図と Analog Discovery 3 は付けない。PC の中だけで動かす (`device: SIM`)。

## 説明

- `y = sel ? b : a;` は「sel が 1 なら b、そうでなければ a」と読む。C 言語の条件演算子と同じ書き方だ
- 選ばれる側 (a と b) は 4 ビットの束でもよい。1 回の `assign` で 4 ビットぶんが一度に選ばれる
- 1 ビットぶんをゲートで書くと、`(a & ~sel) | (b & sel)` になる。sel が 0 のときは左の AND だけが a を通し、1 のときは右の AND だけが b を通す

## 論理図

図 1 は 1 ビットぶんの回路だ。NOT で sel を反転し、2 つの AND の片方に a と反転した sel、
もう片方に b と sel を入れて、OR で合わせる。

```circuit
title: 図1 1 ビットのマルチプレクサ (sel が 1 なら b、0 なら a)
parts:
  sel: port 1,2
  a: port 1,6
  b: port 1,13
  G1: not 6,2
  G2: and 12,6
  G3: and 12,11
  G4: or 19,8
  y: port 24,8
wires:
  - 1,2 -- 4,2
  - 4,2 -- 4,10
  - 4,2 -- G1.in
  - 4,10 |- G3.a
  - G1.out -- 9,2
  - 9,2 -- 9,4
  - 9,4 |- G2.b
  - 1,6 -- 3,6
  - 3,6 |- G2.a
  - 1,13 -- 3,13
  - 3,13 |- G3.b
  - G2.out -- 16,6
  - 16,6 |- G4.a
  - G3.out -- 16,11
  - 16,11 |- G4.b
  - G4.out -- 24,8
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/circuit/04-multiplexer.svg)

- sel が 0 のとき、G1 の出力が 1 になり、G2 が a をそのまま通す。G3 には sel の 0 が入るので 0 のままで、G4 は a を出す
- sel が 1 のとき、G2 には 0 が入って 0 のまま。G3 が b を通し、G4 は b を出す
- sel の縦線と a の横線が交わる所には黒丸が無い。つながっていない

## Verilog

```verilog
// mux2.v
module mux2 (
    input  wire       sel,
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] y
);
    assign y = sel ? b : a;   // sel が 1 なら b、0 なら a
endmodule
```

`a` と `b` を 4 ビットにしたので、図 1 の回路が 4 組、同じ sel でそろって動く。

## 動かす

```cpp
// tb_mux2.cpp
#include <cstdio>
#include "Vmux2.h"

int main() {
    Vmux2 top;
    // {sel, a, b} を 6 通り
    const int sel_list[] = {0, 1, 0, 1, 1, 0};
    const int a_list[]   = {0x3, 0x3, 0x9, 0x9, 0x9, 0x9};
    const int b_list[]   = {0xC, 0xC, 0xC, 0xC, 0x5, 0x5};
    std::printf("# sel a b y\n");
    for (int i = 0; i < 6; i++) {
        top.sel = sel_list[i];
        top.a = a_list[i];
        top.b = b_list[i];
        top.eval();
        std::printf("%x %x %x %x\n", top.sel, top.a, top.b, top.y);
    }
    return 0;
}
```

```bash
verilator --lint-only -Wall mux2.v
verilator -Wall --cc --exe --build mux2.v tb_mux2.cpp
./obj_dir/Vmux2
```

sel・a・b を 6 通り流した結果 (16 進) は次のとおりだった。

```text
sel a b y
0 3 c 3
1 3 c c
0 9 c 9
1 9 c c
1 9 5 5
0 9 5 9
```

## 計器の設定

組まない題なので、計器は使わない。実行結果をロジックアナライザの画面と同じ形の図 2 に描く。
実機で測った波形ではなく、実行結果から作った計算の図で、入力を変えた 1 回を 1 ms と見なして並べた。

```logic
title: 図2 sel と a と b を変えたときの y (Verilator の実行結果から作った計算の図)
device: generic
window: 6ms
signals:
  sel: pattern 010110 bit 1ms
  a0: pattern 111111 bit 1ms
  a1: pattern 110000 bit 1ms
  a2: pattern 000000 bit 1ms
  a3: pattern 001111 bit 1ms
  b0: pattern 000011 bit 1ms
  b1: pattern 000000 bit 1ms
  b2: pattern 111111 bit 1ms
  b3: pattern 111100 bit 1ms
  y0: pattern 101011 bit 1ms
  y1: pattern 100000 bit 1ms
  y2: pattern 010110 bit 1ms
  y3: pattern 011101 bit 1ms
buses:
  a: a3 a2 a1 a0 hex
  b: b3 b2 b1 b0 hex
  y: y3 y2 y1 y0 hex
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/01-combinational/logic/04-multiplexer.svg)

## 見るべき値

| 回 | sel | a | b | y | 選ばれた入力 |
| --- | --- | --- | --- | --- | --- |
| 1 | 0 | 0x3 | 0xC | 0x3 | a |
| 2 | 1 | 0x3 | 0xC | 0xC | b |
| 3 | 0 | 0x9 | 0xC | 0x9 | a (a を変えた) |
| 4 | 1 | 0x9 | 0xC | 0xC | b |
| 5 | 1 | 0x9 | 0x5 | 0x5 | b (b を変えた) |
| 6 | 0 | 0x9 | 0x5 | 0x9 | a |

- 1 と 2 で、a と b を変えずに sel だけを変えると y が a から b に切り替わる
- 3 では sel が 0 なので a の変化が y に出て、5 では sel が 1 なので b の変化が y に出る。選ばれていない側の入力は y に出てこない

## 出典

自作。
