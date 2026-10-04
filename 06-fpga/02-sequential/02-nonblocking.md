---
book: fpga
chapter: 2
id: 2-2
title: ノンブロッキング代入 — ブロッキング代入との違いを波形で見る
tier: 50
source: 自作
device: SIM
---

# 2-2 ノンブロッキング代入 — ブロッキング代入との違いを波形で見る

Verilog の代入には 2 種類ある。`<=` が**ノンブロッキング代入**、`=` が**ブロッキング代入**。
クロックで動く always の中では `<=` を使う、と覚えている人が多いが、ここでは使い分けを波形で確かめる。

違いは「いつ値が変わるか」にある。

- `<=`: 右辺を**先に全部読んでおき**、always が終わるときにまとめて左辺へ入れる。
  同じ立ち上がりの中では、どの文も「立ち上がりの直前の値」を見る
- `=`: その場で左辺を書き換える。次の文は**書き換わった後の値**を見る

D-FF を 2 段並べる (D → Q1 → Q2) 回路を、両方の書き方で作る。組まない題なので、実体配線図と Analog Discovery 3 は入れない。

## 論理図

`<=` で書くと、図1 のとおり D-FF が 2 つ直列になる。

```circuit
title: 図1 ノンブロッキング代入の 2 段。Q1 は D を、Q2 は 1 つ前の Q1 を取り込む
parts:
  D: port e2
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
  Q1: port b10
  Q2: port e18
wires:
  - e2 -- U1.D
  - h2 -- h6 -- U1.CLK
  - h6 -- h14 -- U2.CLK
  - U1.Q -- e10
  - e10 -- U2.D
  - e10 -- b10
  - U2.Q -- e18
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/circuit/02-nonblocking-1.svg)

`=` で書くと、`q1 = d;` の直後に `q2 = q1;` が走るので、`q2` には `q1` の古い値でなく、いま入れたばかりの `d` が入る。
`q1` はただの配線になり、フリップフロップは `q2` の 1 つだけになる (図2)。

```circuit
title: 図2 ブロッキング代入の 2 段。Q1 は配線にすぎず、Q2 も D を取り込む 1 段になる
parts:
  D: port e2
  CLK: port h2
  Q1: port b6
  U1:
    type: ic3
    at: e10
    label: D-FF
    pins: [D, CLK, Q]
  Q2: port e14
wires:
  - e2 -- e5
  - e5 -- U1.D
  - e5 -- b6
  - h2 -- h10 -- U1.CLK
  - U1.Q -- e14
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/circuit/02-nonblocking-2.svg)

## Verilog

`<=` の版。

```verilog
module shift_nb (
    input  clk,
    input  d,
    output reg q1,
    output reg q2
);
    always @(posedge clk) begin
        q1 <= d;
        q2 <= q1;
    end
endmodule
```

`=` の版。

```verilog
module shift_bl (
    input  clk,
    input  d,
    output reg q1,
    output reg q2
);
    always @(posedge clk) begin
        q1 = d;
        q2 = q1;
    end
endmodule
```

2 つの違いは代入の記号だけである。

## 動かす

```verilog
module tb_nb;
    reg clk;
    reg d;
    wire nb_q1, nb_q2, bl_q1, bl_q2, rv_q1, rv_q2;

    shift_nb      u_nb (.clk(clk), .d(d), .q1(nb_q1), .q2(nb_q2));
    shift_bl      u_bl (.clk(clk), .d(d), .q1(bl_q1), .q2(bl_q2));
    shift_bl_rev  u_rv (.clk(clk), .d(d), .q1(rv_q1), .q2(rv_q2));

    initial clk = 0;
    always #5 clk = ~clk;    // 立ち上がりは 5, 15, 25, ... us

    initial begin
        $dumpfile("nb.vcd");
        $dumpvars(0, tb_nb);
        d = 0;
        #8  d = 1;           //  8 us: 1 を 1 クロックぶんだけ与える
        #10 d = 0;           // 18 us
        #52 $finish;
    end
endmodule
```

テストベンチは D を、1 クロックぶんだけ 1 にする (8 us に立てて 18 us に戻す。立ち上がりは 15 us の 1 回だけ掛かる)。

```bash
verilator --lint-only -Wall shift_nb.v
verilator --timescale 1us/1ns --binary --timing --trace --top-module tb_nb shift_nb.v shift_bl.v tb_nb.v
./obj_dir/Vtb_nb
```

`=` の版を lint に掛けると、Verilator が止める。

```bash
verilator --lint-only -Wall shift_bl.v
```

```text
%Warning-BLKSEQ: shift_bl.v:8:12: Blocking assignment '=' in sequential logic process
%Warning-BLKSEQ: shift_bl.v:9:12: Blocking assignment '=' in sequential logic process
%Error: Exiting due to 2 warning(s)
```

`-Wall` の BLKSEQ は「クロックで動く always の中に `=` がある」という警告で、この種の間違いを書いた時点で見つけられる。
`<=` の版 (`shift_nb.v`) は警告 0 件で通った。波形を得るために `shift_bl.v` も作ったが、この警告は `--lint-only` では出て、
上の作り方 (`--binary`) では止まらない。

## シミュレーションの波形

```logic
title: 図3 ノンブロッキングは 1 段遅れ、ブロッキングは遅れない
device: generic
time: 10us/div
signals:
  CLK:   edges 0s=0 5us=1 10us=0 15us=1 20us=0 25us=1 30us=0 35us=1 40us=0 45us=1 50us=0 55us=1 60us=0 65us=1 70us=0
  D:     edges 0s=0 8us=1 18us=0
  NB_Q1: edges 0s=0 15us=1 25us=0
  NB_Q2: edges 0s=0 25us=1 35us=0
  BL_Q1: edges 0s=0 15us=1 25us=0
  BL_Q2: edges 0s=0 15us=1 25us=0
cursors: [20us, 30us]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/logic/02-nonblocking.svg)

## 見るべき値 (シミュレーションを実行して得た値)

| 時刻 | 起きたこと |
| --- | --- |
| 15 us | `<=`・`=` どちらも Q1 が 1 になる。`=` の Q2 も**同じ 15 us で** 1 になる。`<=` の Q2 はまだ 0 |
| 25 us | `<=` の Q1 は 0 に戻り、Q2 が 1 になる (1 クロック遅れ)。`=` の Q1・Q2 は 25 us で一緒に 0 に戻る |
| 35 us | `<=` の Q2 が 0 に戻る |

- カーソル X1 = 20 us では、`<=` が Q1 = 1・Q2 = 0、`=` が Q1 = 1・Q2 = 1。X2 = 30 us では `<=` が Q1 = 0・Q2 = 1、`=` が Q1 = 0・Q2 = 0
- `=` の版では 2 段のつもりが 1 段に潰れた。D を 1 クロック遅らせるのは Q1 の 1 段だけで、Q2 は D に追従している
- `=` でも、文の順を逆にして `q2 = q1; q1 = d;` と書くと、`<=` と同じ波形になった (実行して確かめた)。
  `=` は文の順で結果が変わる。`<=` は順を入れ替えても同じ。複数のフリップフロップを書くときに、順を気にしなくてよいのが `<=` の利点である
- 規則: クロックで動く always には `<=`、組み合わせ回路の `always @(*)` (1-5) には `=`

## 出典

自作。ブロッキング代入とノンブロッキング代入の定義は IEEE 1364-2005 (Verilog) の手続き代入の節と、
Verilator のマニュアルの警告 BLKSEQ の節
([https://verilator.org/guide/latest/warnings.html](https://verilator.org/guide/latest/warnings.html)) による。
