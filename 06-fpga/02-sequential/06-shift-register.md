---
book: fpga
chapter: 2
id: 2-6
title: シフトレジスタ
tier: 50
source: 自作
device: SIM
---

# 2-6 シフトレジスタ

D-FF を一列につなぎ、前の段の Q を次の段の D に入れる。すると、クロックの立ち上がりごとに、中身が 1 段ずつ隣へ送られる。
これが**シフトレジスタ**である。最初の段に入れた 1 は、1 クロックごとに Q0 → Q1 → Q2 → Q3 と進み、最後の段の次で消える。

1 ビットずつ送り込む (直列に入れる) だけで、4 ビットがそろって手に入る。逆に、4 ビットを 1 ビットずつ送り出すこともできる。
直列の通信 (UART、SPI) の元になる回路で、7-1 の UART の送信はこれを使う。

組まない題なので、実体配線図と Analog Discovery 3 は入れない。

## 論理図

```circuit
title: 図1 4 段のシフトレジスタ。Q3 は 4 クロック前の DIN
parts:
  DIN: port e2
  CLK: port h2
  U1:
    type: ic3
    at: e6
    label: D-FF
    pins: [D, CLK, Q]
  U2:
    type: ic3
    at: e14
    label: D-FF
    pins: [D, CLK, Q]
  U3:
    type: ic3
    at: e22
    label: D-FF
    pins: [D, CLK, Q]
  U4:
    type: ic3
    at: e30
    label: D-FF
    pins: [D, CLK, Q]
  Q0: port b10
  Q1: port b18
  Q2: port b26
  Q3: port e34
wires:
  - e2 -- U1.D
  - h2 -- h6 -- U1.CLK
  - h6 -- h14 -- U2.CLK
  - h14 -- h22 -- U3.CLK
  - h22 -- h30 -- U4.CLK
  - U1.Q -- e10
  - e10 -- U2.D
  - U2.Q -- e18
  - e18 -- U3.D
  - U3.Q -- e26
  - e26 -- U4.D
  - e10 -- b10
  - e18 -- b18
  - e26 -- b26
  - U4.Q -- e34
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/circuit/06-shift-register.svg)

図1 はリセットを省いて描いた。Verilog では、`rst` が 1 のとき 4 段とも 0 にする (各段の D の前に AND が付く。2-3)。

## Verilog

```verilog
module shift4 (
    input        clk,
    input        rst,
    input        din,
    output [3:0] q
);
    reg [3:0] r;

    assign q = r;

    always @(posedge clk)
        if (rst) r <= 4'b0000;
        else     r <= {r[2:0], din};
endmodule
```

- `{r[2:0], din}` は、`r` の下位 3 ビットの右に `din` をつなげた 4 ビットである (連結。1-3)。
  `r[3]` は捨てられ、`r[2:0]` が 1 つ上へ移り、`din` が最下位に入る
- 1 行で 4 個のフリップフロップを書いている。`<=` なので、4 個とも同じ立ち上がりの直前の値を見る (2-2)。
  これが 2-2 の「1 段ずつ遅れる」を 1 行にしたものである

## 動かす

```verilog
module tb_shift4;
    reg clk;
    reg rst;
    reg din;
    wire [3:0] q;

    shift4 u (.clk(clk), .rst(rst), .din(din), .q(q));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("shift4.vcd");
        $dumpvars(0, tb_shift4);
        rst = 1; din = 0;
        #12 rst = 0;         // 12 us: リセットを放す
        #8  din = 1;         // 20 us: 立ち上がり (25) の前に 1 を与え
        #10 din = 0;         // 30 us: 1 クロックぶんだけで 0 に戻す
        #100 $finish;
    end
endmodule
```

```bash
verilator --lint-only -Wall shift4.v
verilator --timescale 1us/1ns --binary --timing --trace --top-module tb_shift4 shift4.v tb_shift4.v
./obj_dir/Vtb_shift4
```

テストベンチは `din` を 1 クロックぶんだけ 1 にする (20 us に立て、30 us に戻す。立ち上がりは 25 us の 1 回だけ掛かる)。

## シミュレーションの波形

```logic
title: 図2 DIN の 1 が 1 クロックごとに 1 段ずつ進む
device: generic
time: 10us/div
signals:
  CLK: edges 0s=0 5us=1 10us=0 15us=1 20us=0 25us=1 30us=0 35us=1 40us=0 45us=1 50us=0 55us=1 60us=0 65us=1 70us=0 75us=1 80us=0 85us=1 90us=0 95us=1 100us=0
  DIN: edges 0s=0 20us=1 30us=0
  Q0:  edges 0s=0 25us=1 35us=0
  Q1:  edges 0s=0 35us=1 45us=0
  Q2:  edges 0s=0 45us=1 55us=0
  Q3:  edges 0s=0 55us=1 65us=0
buses:
  Q: Q3..Q0 bin
cursors: [40us, 60us]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/logic/06-shift-register.svg)

## 見るべき値 (シミュレーションを実行して得た値)

| 立ち上がり | `q` (Q3 Q2 Q1 Q0) | 1 がある段 |
| --- | --- | --- |
| 25 us | 0001 | Q0 |
| 35 us | 0010 | Q1 |
| 45 us | 0100 | Q2 |
| 55 us | 1000 | Q3 |
| 65 us | 0000 | (消えた) |

- 1 クロックごとに 1 が 1 段ずつ進む。カーソル X1 = 40 us で Q = 0b0010、X2 = 60 us で Q = 0b1000
- 4 段なので、入れた 1 は 4 クロック後に Q3 に着き、5 クロック後に消える
- `din` に 1 と 0 の列を与えれば、その列がそのまま Q0 → Q3 へ流れていく。4 クロックぶん前の入力が Q3 に出る (4 クロックの遅延)

## 出典

自作。連結 `{ }` の書き方は IEEE 1364-2005 (Verilog) の連結演算子の節による。
