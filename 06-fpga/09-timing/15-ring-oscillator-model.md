---
book: fpga
chapter: 9
id: 9-15
title: リングオシレータの模型 — 遅れの無いシミュレーションでは発振しない
tier: 100
source: 自作
board: —
device: SIM
---

# 9-15 リングオシレータの模型 — 遅れの無いシミュレーションでは発振しない

この題は実体配線図と Analog Discovery 3 の図を付けない。PC のシミュレーションだけの題で、組む物が無いから。

9-4 では、インバータを奇数個、輪にしたリングオシレータで、FPGA の中のインバータ 1 段の遅れを測った。
この題では、同じ輪を PC のシミュレーションに掛ける。遅れを持たない Verilator では輪は発振せず、
1 段に `#` で遅れを入れた**模型**にすると発振して、周期が式 (周期 = 2 × N × t<sub>pd</sub>) のとおりになる。
模型の遅れは自分で決めた仮の値で、**実物の FPGA の遅れについては何も言わない。**

## 遅れの無いシミュレーションでは発振しない

遅れを持たない Verilator に、9-4 の輪 (`top_ring`) を動かさせると、次のエラーで止まる。

```text
%Error: tb_ring_nodelay.v:1: Active region did not converge after 100 tries
Aborting...
```

`en` を 1 にした瞬間、輪の値は時間が進まないまま、反転を繰り返す。Verilator は 100 回で諦める。
**シミュレーションの中の信号は、遅れが 0 なので、輪は「動いた」とは言えない。**
輪の周波数は、実物の LUT と配線の遅れで決まる。

## 遅れを入れた模型

1 段に `#` で遅れを入れた**模型**なら、輪は動く。ただし、これは遅れを自分で決めたもので、FPGA の遅れではない。
ここでは 1 段を 0.5 ns と決めた。この 0.5 ns は、模型を動かすために置いた数であり、実物の値と関係がない。

```verilog
// ring_model.v  リングオシレータの「模型」。インバータ 1 段に tpd だけの遅れを # で与える (実物の遅れではない)
module ring_model #(
    parameter N = 5,
    parameter real TPD = 0.5     // 1 段の遅れ (ns)。模型のために決めた値
) (
    input  wire en,
    output wire y
);
    wire [N-1:0] w;

    assign #(TPD) w[0] = ~(w[N-1] & en);

    genvar i;
    generate
        for (i = 1; i < N; i = i + 1) begin : stage
            assign #(TPD) w[i] = ~w[i-1];
        end
    endgenerate

    assign y = w[N-1];
endmodule
```

```verilog
// tb_ring_model.v  遅れを # で入れた模型。段数を 3・5・7・9 にして、周期が 2 × 段数 × 遅れ になるかを見る
module tb_ring_model;
    localparam real TPD = 0.5;    // 1 段の遅れ (ns)。模型のために決めた値で、実物の値ではない

    reg  en = 0;
    wire y3, y5, y7, y9;
    real t_prev3 = 0, t_last3 = 0, t_prev5 = 0, t_last5 = 0;
    real t_prev7 = 0, t_last7 = 0, t_prev9 = 0, t_last9 = 0;

    ring_model #(.N(3), .TPD(TPD)) u3 (.en(en), .y(y3));
    ring_model #(.N(5), .TPD(TPD)) u5 (.en(en), .y(y5));
    ring_model #(.N(7), .TPD(TPD)) u7 (.en(en), .y(y7));
    ring_model #(.N(9), .TPD(TPD)) u9 (.en(en), .y(y9));

    always @(posedge y3) begin t_prev3 = t_last3; t_last3 = $realtime; end
    always @(posedge y5) begin t_prev5 = t_last5; t_last5 = $realtime; end
    always @(posedge y7) begin t_prev7 = t_last7; t_last7 = $realtime; end
    always @(posedge y9) begin t_prev9 = t_last9; t_last9 = $realtime; end

    initial begin
        $dumpfile("ring_model.vcd");
        $dumpvars(0, tb_ring_model.u5);
        #10 en = 1;               // 10 ns で発振を許す
        #200;
        $display("N = 3: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last3 - t_prev3, 2.0 * 3 * TPD);
        $display("N = 5: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last5 - t_prev5, 2.0 * 5 * TPD);
        $display("N = 7: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last7 - t_prev7, 2.0 * 7 * TPD);
        $display("N = 9: 周期 %0.3f ns (2 x N x TPD = %0.3f ns)", t_last9 - t_prev9, 2.0 * 9 * TPD);
        $finish;
    end
endmodule
```

```bash
verilator --lint-only --timing -Wall ring_model.v
verilator --timescale 1ns/1ps --binary --timing --trace --top-module tb_ring_model ring_model.v tb_ring_model.v
./obj_dir/Vtb_ring_model
```

`ring_model.v` の lint は警告 0 件で通った。実行した結果は次のとおり。

```text
N = 3: 周期 3.000 ns (2 x N x TPD = 3.000 ns)
N = 5: 周期 5.000 ns (2 x N x TPD = 5.000 ns)
N = 7: 周期 7.000 ns (2 x N x TPD = 7.000 ns)
N = 9: 周期 9.000 ns (2 x N x TPD = 9.000 ns)
```

模型の周期は、`2 × N × TPD` と一致した。模型は式を確かめただけで、実物の遅れについては何も言っていない。
図1は、N = 5 の模型の各段の出力。模型の時刻で 10 ns に `en` を 1 にしたあと、変化が 0.5 ns ずつずれて輪を回る。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図1 模型 (TPD = 0.5 ns, N = 5)。変化は 1 段ずつ 0.5 ns ずれ、周期は 5 ns
device: generic
time: 4ns/div
start: 10ns
signals:
  EN: edges 0s=1
  W0: edges 0s=1 10.5ns=0 13ns=1 15.5ns=0 18ns=1 20.5ns=0 23ns=1 25.5ns=0 28ns=1 30.5ns=0 33ns=1 35.5ns=0 38ns=1 40.5ns=0 43ns=1 45.5ns=0 48ns=1
  W1: edges 0s=0 11ns=1 13.5ns=0 16ns=1 18.5ns=0 21ns=1 23.5ns=0 26ns=1 28.5ns=0 31ns=1 33.5ns=0 36ns=1 38.5ns=0 41ns=1 43.5ns=0 46ns=1 48.5ns=0
  W2: edges 0s=1 11.5ns=0 14ns=1 16.5ns=0 19ns=1 21.5ns=0 24ns=1 26.5ns=0 29ns=1 31.5ns=0 34ns=1 36.5ns=0 39ns=1 41.5ns=0 44ns=1 46.5ns=0 49ns=1
  W3: edges 0s=0 12ns=1 14.5ns=0 17ns=1 19.5ns=0 22ns=1 24.5ns=0 27ns=1 29.5ns=0 32ns=1 34.5ns=0 37ns=1 39.5ns=0 42ns=1 44.5ns=0 47ns=1 49.5ns=0
  W4: edges 0s=1 12.5ns=0 15ns=1 17.5ns=0 20ns=1 22.5ns=0 25ns=1 27.5ns=0 30ns=1 32.5ns=0 35ns=1 37.5ns=0 40ns=1 42.5ns=0 45ns=1 47.5ns=0 50ns=1
cursors: [12.6ns, 17.6ns]
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/09-timing/logic/15-ring-oscillator-model.svg)

W0〜W4 は各段の出力 (W0 が NAND、W4 が最後のインバータ)。カーソル X1 = 12.6 ns と X2 = 17.6 ns は W4 の立ち下がりの 2 つで、
ΔX = 5.00 ns、1/ΔX = 200 MHz。`2 × 5 × 0.5 ns = 5 ns` と合う。**模型の値であって、FPGA の値ではない。**

## 見るべき値

シミュレーションの値。実物の遅れは 9-4 で測る。

| 項目 | 値 | どこで得たか |
| --- | --- | --- |
| 遅れの無い輪 (`top_ring`) | `Active region did not converge after 100 tries` で止まる | Verilator 5.042 |
| 模型の周期 (1 段 0.5 ns、N = 3・5・7・9) | 3.000・5.000・7.000・9.000 ns | シミュレーションの値 |
| 図1 の ΔX (N = 5) | 5.00 ns (1/ΔX = 200 MHz) | シミュレーションの値 |
| 式の周期 2 × N × TPD | 3・5・7・9 ns | 計算値 |

## シミュレーションでの確かめ

Verilator 5.042 で、本文の `ring_model.v` `tb_ring_model.v` を取り出して走らせ直した。
置き場は `sim/04-ring-oscillator-model.v` `sim/04-ring-oscillator-model-tb.v`。
遅れの無い輪が止まる実行には、9-4 の最上位 `top_ring` に `en` を与えるだけの `sim/04-ring-oscillator-nodelay-tb.v` を書いた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`ring_model.v`、`--timing -Wall`) | 警告 0 件 | 0 件 | 合った |
| 遅れの無い輪の実行 | Active region did not converge after 100 tries | 同じエラーで止まった | 合った |
| 模型の周期 N = 3・5・7・9 | 3.000・5.000・7.000・9.000 ns | 同じ | 合った |
| 模型 N = 5 の波形 (図1) | 10 ns に en = 1。W4 の立ち下がりは 12.5 ns、周期 5 ns | 同じ (W0 は 10.5 ns で 0、W4 は 12.5 ns で 0、15 ns で 1) | 合った |

確かめていない数: 実物の 1 段の遅れ (実機が要る。9-4 で測る)。

## 出典

自作。

- リングオシレータで遅れを測る考え方は、CMOS の回路の定番の測り方である。この題では式 (周期 = 2 × N × t<sub>pd</sub>) を、
  シミュレーションの模型で確かめた
- Verilator の `--timing` と `#` の遅れ: [Verilator のマニュアル](https://www.verilator.org/guide/latest/)
