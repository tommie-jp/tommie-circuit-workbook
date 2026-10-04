---
book: fpga
chapter: 2
id: 2-1
title: D フリップフロップ — always @(posedge clk)
tier: 50
source: 自作
device: SIM
---

# 2-1 D フリップフロップ — always @(posedge clk)

組み合わせ回路 (第 1 章) は、入力が変われば出力もすぐ変わった。何も覚えていない。
順序回路は、過去の入力を覚えている。覚える最小の部品が **D フリップフロップ** (D-FF) で、1 ビットを覚える。

D-FF の働きは 1 つだけ。**クロック (CLK) が 0 から 1 に変わる瞬間** (立ち上がり) の D を取り込み、
それを Q に出して、次の立ち上がりまで保つ。立ち上がりの間に D がどう動いても、Q は変わらない。

この題は PC の Verilator だけで動かす。組まない題なので、実体配線図と Analog Discovery 3 は入れない。

## 論理図

```circuit
title: 図1 D フリップフロップ。CLK が 0 から 1 に変わる瞬間の D を Q に取り込む
parts:
  D: port e2
  CLK: port h2
  U1:
    type: ic3
    at: e6
    label: D-FF
    pins: [D, CLK, Q]
  Q: port e10
wires:
  - e2 -- U1.D
  - h2 -- h6 -- U1.CLK
  - U1.Q -- e10
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/circuit/01-d-flip-flop.svg)

## Verilog

```verilog
module dff (
    input  clk,
    input  d,
    output reg q
);
    always @(posedge clk)
        q <= d;
endmodule
```

- `always @(posedge clk)` は「clk が 0 から 1 に変わるたびに、中の文を 1 回実行する」という意味。
  立ち上がりのときだけ `q` に値が入るので、`q` は値を覚えるレジスタになる
- `output reg q` の `reg` は「この信号は always の中で代入される」という印で、
  部品としてはフリップフロップが 1 個できる
- `<=` はノンブロッキング代入。順序回路ではこれを使う。理由は 2-2 で波形を見て確かめる

## 動かす

テストベンチ (回路に信号を与える Verilog) は D を、立ち上がりの前後で変える。
ここで大事なのは、立ち上がりと立ち上がりの間にも D を変えている点である。

```verilog
module tb_dff;
    reg clk;
    reg d;
    wire q;

    dff u (.clk(clk), .d(d), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("dff.vcd");
        $dumpvars(0, tb_dff);
        d = 0;
        #8  d = 1;           //  8 us: 立ち上がり (15) の前に 1
        #9  d = 0;           // 17 us: 立ち上がり (15) の後に 0
        #11 d = 1;           // 28 us: 立ち上がりの間に 1 にして
        #4  d = 0;           // 32 us: 立ち上がり (35) の前に 0 へ戻す
        #4  d = 1;           // 36 us: 立ち上がり (45) の前に 1
        #11 d = 0;           // 47 us: 立ち上がり (45) の後に 0
        #33 $finish;
    end
endmodule
```

```bash
verilator --lint-only -Wall dff.v
verilator --timescale 1us/1ns --binary --timing --trace --top-module tb_dff dff.v tb_dff.v
./obj_dir/Vtb_dff
```

1 行目の `--lint-only -Wall` は書き間違いの検査で、警告 0 件で通った。
2 行目が C++ にして実行できる形に作る。時間の単位は 1 us と読む
(クロックは 10 us 周期の 100 kHz。実物の速さではなく、波形を読みやすくするための仮の単位)。
実行すると `dff.vcd` ができる。波形ビューアは 0-6 で扱う。

## シミュレーションの波形

```logic
title: 図2 D の変化と Q。Q は立ち上がりの値だけ取り込む
device: generic
time: 10us/div
signals:
  CLK: edges 0s=0 5us=1 10us=0 15us=1 20us=0 25us=1 30us=0 35us=1 40us=0 45us=1 50us=0 55us=1 60us=0 65us=1 70us=0 75us=1 80us=0
  D:   edges 0s=0 8us=1 17us=0 28us=1 32us=0 36us=1 47us=0
  Q:   edges 0s=0 15us=1 25us=0 45us=1 55us=0
cursors: [14us, 16us]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/logic/01-d-flip-flop.svg)

## 見るべき値 (シミュレーションを実行して得た値)

立ち上がりは 5・15・25・35・45・55 us。

| 立ち上がりの時刻 | その瞬間の D | 取り込んだ Q (その後) |
| --- | --- | --- |
| 15 us | 1 (8 us から) | 1 |
| 25 us | 0 (17 us から) | 0 |
| 35 us | 0 (28〜32 us の 1 は終わっている) | 0 |
| 45 us | 1 (36 us から) | 1 |
| 55 us | 0 (47 us から) | 0 |

- 5 us の立ち上がりでは D は 0 で、Q は最初から 0 のまま変わらない
- 図2のカーソル X1 = 14 us で D = 1・Q = 0、X2 = 16 us で D = 1・Q = 1。D はずっと 1 なのに、Q は立ち上がり (15 us) をまたいで初めて 1 になる
- 28〜32 us の D の 1 は、立ち上がりに掛からないので Q に現れない (35 us の立ち上がりで D は 0)
- 17 us に D が 0 に戻っても、Q は 25 us の立ち上がりまで 1 のまま
- Verilator は 2 値のシミュレータで、Q の最初の値を 0 にする。実物のフリップフロップは電源を入れた直後の値が決まっていない。
  最初の値を決める方法は 2-3 (リセット) と 2-18 で扱う

## 出典

自作。`always @(posedge clk)` の書き方は IEEE 1364-2005 (Verilog) の always 文と、Verilator のマニュアル
([https://verilator.org/guide/latest/](https://verilator.org/guide/latest/)) に基づく。
