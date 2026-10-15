---
book: fpga
chapter: 7
id: 7-6
title: ボーレートのずれは何 % まで許されるか
tier: 100
source: 自作
board: BB
device: PICO
---

# 7-6 ボーレートのずれは何 % まで許されるか

> [!WARNING]
> **この題は実機で組んでいない。** Verilog は Verilator の lint を通し、PC のシミュレーションで、
> 7-2 の受信回路に「ビットの長さをずらした送り手」の字を受けさせ、読み間違える境目を調べた。
> Pico 2 への書き込みと、AD3 での測定はしていない。「見るべき値」はシミュレーションの値と計算値。

UART は線にクロックを持たない。送り手と受け手は、それぞれ自分のクロックで 1 ビットの長さを決める。
**2 つのクロックの周波数は少しずつずれる**。どこまでずれても字が読めるかは、計算で出せる。

7-1 は「9600 bps は、µs の整数のクロック (7 µs) では 7 % ずれて受け手が読み違える」と書き、13 µs・4800 bps を選んだ。
この題は、その「何 % まで」の答えを、式とシミュレーションで出す。

## 式で出す

1 字は 10 ビット (スタート・データ 8・ストップ)。受け手は、スタートビットの立ち下がりから数え始め、
**n 番目のビットの真ん中 (n + 0.5 ビット目)** で読む (スタートが 0 番目、bit0 が 1 番目、ストップが 9 番目)。

送り手の 1 ビットを T<sub>s</sub>、受け手の 1 ビットを T<sub>r</sub> とすると、n 番目のビットは送り手の時刻 n × T<sub>s</sub> から (n + 1) × T<sub>s</sub> の間にある。
受け手が読む時刻 (n + 0.5) × T<sub>r</sub> がこの間に入る条件は、

n × T<sub>s</sub> ≤ (n + 0.5) × T<sub>r</sub> < (n + 1) × T<sub>s</sub>

つまり T<sub>s</sub> ÷ T<sub>r</sub> が (n + 0.5) ÷ (n + 1) 以上、(n + 0.5) ÷ n 以下。
n ごとの範囲を表にすると、後ろのビットほど狭い。

| n (ビット) | T<sub>s</sub> ÷ T<sub>r</sub> の下限 | 上限 |
| --- | --- | --- |
| 1 (bit0) | 0.7500 | 1.5000 |
| 5 (bit4) | 0.9167 | 1.1000 |
| 8 (bit7) | 0.9444 | 1.0625 |
| **9 (ストップ)** | **0.9500** | **1.0556** |

いちばん狭いのは最後の 9 番目 (ストップビット)。**範囲は −5.0 % から +5.56 %**。
ずれ ε = (T<sub>s</sub> − T<sub>r</sub>) ÷ T<sub>r</sub> と書くと、

- 下限: 9.5 × T<sub>r</sub> < 10 × T<sub>s</sub> より ε > −0.5 ÷ 10 = **−5.0 %**
- 上限: 9 × T<sub>s</sub> ≤ 9.5 × T<sub>r</sub> より ε ≤ 0.5 ÷ 9 = **+5.56 %**

「1 字 10 ビットのうち、半ビットまでずれても読める」ので、**ずれは約 ±5 %** (0.5 ÷ 10)。

- **送り手と受け手の両方がずれる**と、ずれは足し算になる。±5 % を 2 台で分けるので、1 台あたり 2 % 以内にしておくのが目安 (量子化の余裕を含む)
- 受け手が 16 倍の刻み (7-2) で読むと、読む時刻が最大 1 刻み (1 クロック = 1 字 160 クロックの 0.6 %) 遅れる。下側の限界は 0.6 % ほど狭くなる (下の測定で確かめる)
- 受け手のクロックが 1 字の間にずれる量は、字ごとに受け手が立ち下がりで数え直すので、字をまたいで積み上がらない

## ずれの出どころ

水晶のずれは ppm (百万分の 1。1 % = 10 000 ppm) の単位で、5 % には遠い。
このくらいのずれが実際に出るのは、**クロックを整数で割る丸め**のとき。

| クロック | ボーレート | 16 倍刻みの分周 | 出る速さ | ずれ (計算値) | ±5 % に入るか |
| --- | --- | --- | --- | --- | --- |
| 76.923 kHz (13 µs) | 4800 bps | 1 | 4808 bps | +0.16 % | 入る |
| 76.923 kHz (13 µs) | 2400 bps | 2 | 2404 bps | +0.16 % | 入る |
| 142.857 kHz (7 µs) | 9600 bps | 1 | 8929 bps | −6.99 % | **入らない** |
| 27 MHz (FPGA ボード) | 9600 bps | 176 | 9588 bps | −0.12 % | 入る |
| 27 MHz (FPGA ボード) | 19200 bps | 88 | 19176 bps | −0.12 % | 入る |
| 27 MHz (FPGA ボード) | 115200 bps | 15 | 112500 bps | −2.34 % | 入る (1 台で 2 % を超える) |

(出る速さ = クロック ÷ 分周 ÷ 16。ずれ = 出る速さ ÷ ボーレート − 1。7 µs は整数 µs の最も近い周期。)

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 の GP15 から UART の TXD を出し、AD3 の DIO0 で読む
parts:
  MCU: pico2 3,6 mirror
  G1: ground 5,9
  AD:
    type: device
    at: 8.5,10
    label: AD3
    pins: [DIO0, GND]
  G2: ground 7,10.8
wires:
  - MCU.GND18 |- 5,9
  - MCU.GP15 |- AD.DIO0
  - AD.GND |- 7,10.2 -- 7,10.8
style:
  pitch: 1.2
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/circuit/06-baud-tolerance.svg)

- 7-1 と同じ回路。Pico 2 の GP15 が送る線 (TXD)、AD3 の DIO0 が受ける側。AD3 の GND と Pico 2 の GND (18 番) を共通にする (0-4)
- この題では、**送る側の 1 ビットの長さだけを変えて**、AD3 の Protocol (受け手) が読み間違えるところを見る

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 ブレッドボードに Pico 2 を挿し、AD3 の DIO0 と GND をつなぐ
board: half
parts:
  MCU: pico2 @ h5
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [GND, DIO0]
wires:
  - AD.GND -- j22 black
  - AD.DIO0 -- j24 yellow
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/breadboard/06-baud-tolerance.svg)

- 7-1 と同じ配線。GP15 (24 列) に DIO0 の黄、GND (22 列) に黒。赤は使わない
- 信号は 4800 bps 前後で、ブレッドボードの範囲 (3 MHz 以下) に収まる

## Verilog

送り手は 7-1 の `uart_tx.v` と `hello_top.v` をそのまま使う (06-fpga/07-serial/01-uart-tx.md)。
**1 ビットのクロック数 `DIV` を直接決める**ため、`CLK_HZ = DIV × 4800` にする小さな最上位を足す。

```verilog
// 7-1 の hello_top を、1 ビットのクロック数 DIV を直接決めて使う最上位。
// CLK_HZ = DIV x 4800 にすると、uart_tx の分周が DIV クロックになる。
// 1 ビットの長さは DIV x (クロックの周期)。クロックの周期は 5-7 のタイマ割り込みの間隔 (µs) で決める
module skew_top #(
    parameter integer DIV = 16
) (
    input  clk,
    input  rst,
    output txd       // GP15
);
    hello_top #(.CLK_HZ(DIV * 4800), .BAUD(4800)) u_hello (.clk(clk), .rst(rst), .txd(txd));
endmodule
```

1 ビットの長さは **DIV × (クロックの周期)**。クロックの周期は 5-7 のタイマ割り込みの間隔 (µs の整数) で決める。
DIV と間隔の組を変えると、1 µs 刻みで 1 ビットの長さを変えられる。

Verilator の lint は警告なしで通る (`verilator --lint-only -Wall --top-module skew_top skew_top.v hello_top.v uart_tx.v`、確かめた)。

### Pico 2 のピンの割り当て

7-1 と同じ。`clk` は **TCLK_US µs ごと**のタイマ割り込みで 0 → 1 と変えて評価する (5-7)。TCLK_US は下の表の値で変える。
クロックを 10〜12 µs まで速くしたとき、この大きさの回路が 1 クロックに間に合うかは、5-9 の測り方で確かめる (間に合わない行は省く)。

| Verilog | Pico 2 | 向き | 設定 |
| --- | --- | --- | --- |
| `clk` | (ピンなし) | — | **TCLK_US µs ごと**のタイマ割り込み (5-7) |
| `rst` | (ピンなし) | — | 起動して最初の 1 クロックだけ 1 |
| `txd` | GP15 | 出力 | 起動直後から 1 を出す (アイドル) |

## 動かす — PC のシミュレーション

### 1. ずれを少しずつ変えて、受け手が読めるかを調べる

送り手の 1 ビットを、受け手 (7-2 の `uart_rx`、13 µs・4800 bps の設定) の 1 ビット 208 µs の (1 + ずれ) 倍にする。
ずれを −8 % から +8 % まで変え、各ずれで 0x00〜0xFF を**字の間をあけずに**送って、正しく受けた字を数える。

```verilog
`timescale 1ns / 1ps
// 送り手の 1 ビットの長さを、受け手の 1 ビット (16 クロック x 13 us = 208 us) の (1 + ずれ) 倍にして、
// 7-2 の uart_rx で受ける。ずれを SKEW0 から SKEW1 まで SKEWD ずつ (単位は 0.01 %) 変え、
// 各ずれで 0x00〜0xFF を字の間をあけずに送って、正しく受けた字を数える
module tb_skew;
    parameter integer SKEW0 = -800, SKEW1 = 800, SKEWD = 50;
    localparam real BIT_RX_NS = 208000.0;      // 受け手の 1 ビット

    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;              // 13 us
    end
    reg  rst;
    reg  line;
    wire [7:0] data;
    wire valid, frame_err, sample;
    uart_rx dut (.clk(clk), .rst(rst), .rxd(line),
                 .data(data), .valid(valid), .frame_err(frame_err), .sample(sample));

    integer nok, nbad, nframe;
    real    tfirst, bt;                        // 最初の字の頭の時刻と、送り手の 1 ビットの長さ
    integer idx;
    reg     fe_d;

    // valid は字の頭から 9〜10.4 ビット後に来る。時刻から何字目かを決めて、その字と突き合わせる
    always @(posedge clk) begin
        if (valid) begin
            idx = $rtoi((($realtime - tfirst) / bt - 9.7) / 10.0 + 0.5);
            if (data === idx[7:0]) nok = nok + 1;
            else                   nbad = nbad + 1;
        end
        fe_d <= frame_err;
        if (frame_err && !fe_d) nframe = nframe + 1;   // フレームエラーは立ち上がりで数える
    end

    task automatic send(input [7:0] b, input real bit_ns);
        integer k;
        begin
            line = 1'b0; #(bit_ns);
            for (k = 0; k < 8; k = k + 1) begin
                line = b[k]; #(bit_ns);
            end
            line = 1'b1; #(bit_ns);
        end
    endtask

    integer skew, i;
    initial begin
        line = 1'b1; rst = 1'b1; fe_d = 1'b0;
        #40000 rst = 1'b0;
        #1000000;
        $display("skew(%%)   ok  bad  lost  frame_err");
        for (skew = SKEW0; skew <= SKEW1; skew = skew + SKEWD) begin
            bt = BIT_RX_NS * (1.0 + skew * 0.0001);
            nok = 0; nbad = 0; nframe = 0;
            rst = 1'b1; #40000 rst = 1'b0;
            #(10 * BIT_RX_NS);
            for (i = 0; i < 256; i = i + 1) begin
                if (i == 0) tfirst = $realtime;
                send(i[7:0], bt);
            end
            #(5 * BIT_RX_NS);
            $display("%6.2f   %3d  %3d  %4d  %4d", skew * 0.01, nok, nbad, 256 - nok - nbad, nframe);
        end
        $finish;
    end
endmodule
```

```bash
verilator --binary --timing --top-module tb_skew tb_skew.v uart_rx.v
./obj_dir/Vtb_skew
```

```text
skew(%)   ok  bad  lost  frame_err
 -8.00     0   49   207    44
 -7.50     0   41   215    42
 -7.00     0   39   217    40
 -6.50     1   39   216    41
 -6.00     2   31   223    32
 -5.50     1   36   219    36
 -5.00     1   22   233    23
 -4.50     6   25   225    13
 -4.00   256    0     0     0
 -3.50   256    0     0     0
 -3.00   256    0     0     0
 -2.50   256    0     0     0
 -2.00   256    0     0     0
 -1.50   256    0     0     0
 -1.00   256    0     0     0
 -0.50   256    0     0     0
  0.00   256    0     0     0
  0.50   256    0     0     0
  1.00   256    0     0     0
  1.50   256    0     0     0
  2.00   256    0     0     0
  2.50   256    0     0     0
  3.00   256    0     0     0
  3.50   256    0     0     0
  4.00   256    0     0     0
  4.50   256    0     0     0
  5.00   256    0     0     0
  5.50   256    0     0     0
  6.00   179    0    77    52
  6.50   115   13   128     1
  7.00    64   64   128     1
  7.50    64   64   128     1
  8.00    38   90   128     1
```

(Verilator 5.042 で実行。`ok` は正しく受けた字、`bad` は値が違う字、`lost` は受けられなかった字、`frame_err` はストップビットが 0 だった数。)

境目を 0.05 % 刻みで探した結果 (`-GSKEW0=-450 -GSKEW1=-425 -GSKEWD=5` などで再現):

| ずれ | 受けた字 / 256 |
| --- | --- |
| −4.40 % | 23 (読み違える字が出る) |
| −4.35 % | 256 |
| +5.55 % | 256 |
| +5.60 % | 251 (受け損ねる字が出る) |

**全部の字が通る範囲は −4.35 % から +5.55 %**。式の −5.0 % 〜 +5.56 % のうち、下側が 0.65 % 狭い。
これは受け手が最大 1 クロック (13 µs) 遅れて読むぶん (1 字 160 クロックの 0.6 %) に合う。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 送り手のビットのずれと、正しく受けられた字 (256 字中)
x: 送り手の 1 ビットのずれ % -8..8
y: 正しく受けた字 字 0..256
lines:
  シミュレーション 字:
    - -8 0
    - -7 0
    - -6 2
    - -5 1
    - -4.5 6
    - -4.4 23
    - -4.35 256
    - 0 256
    - 5.55 256
    - 5.6 251
    - 6 179
    - 6.5 115
    - 7 64
    - 8 38
notes:
  - band -4.35 5.55: 全部受けられる
  - mark 0
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/graph/06-baud-tolerance.svg)

境目の外では、ほとんど読めない (0〜数十字)。境目の数 (ずれ −4.4 % 付近で 23 字、−4.5 % 付近で 6〜10 字) は、
送り手と受け手のクロックの位相の合い方で少し変わる。

### 2. 実機の表の各行を、7-1 の送り手で再現する

実機では、1 ビットの長さを `DIV × TCLK_US` で変える。下の 12 通りを、7-1 の `uart_tx` (字の間に 2 クロックのすき間がある) で送り、
受け手 (7-2 の `uart_rx`) で受ける。

```verilog
`timescale 1ns / 1ps
// 実機の表の各行 (uart_tx の分周 DIV と、クロックの周期 TCLK_US) を再現する。
// 送り手は 7-1 の uart_tx を DIV クロックの分周で動かし、受け手は 7-2 の uart_rx (13 us・4800 bps の設定)。
// 0x00〜0xFF を字の間 2 クロックで続けて送り、正しく受けた字を数える
module row #(
    parameter integer DIV     = 16,
    parameter integer TCLK_US = 13
);
    reg txclk;
    initial begin txclk = 1'b0; forever #(TCLK_US * 500) txclk = ~txclk; end
    reg rxclk;
    initial begin rxclk = 1'b0; forever #6500 rxclk = ~rxclk; end

    reg        rst;
    reg  [7:0] data;
    reg        start;
    wire       txd, busy;
    uart_tx #(.CLK_HZ(DIV * 4800), .BAUD(4800)) tx (
        .clk(txclk), .rst(rst), .data(data), .start(start), .txd(txd), .busy(busy));

    wire [7:0] rdata;
    wire       valid, ferr, smp;
    uart_rx rx (.clk(rxclk), .rst(rst), .rxd(txd), .data(rdata), .valid(valid), .frame_err(ferr), .sample(smp));

    localparam real BIT_NS = DIV * TCLK_US * 1000.0;     // 送り手の 1 ビット
    real    ts [0:255];                                  // 各字を送り始めた時刻
    integer nok, nferr, idx, i, k;
    reg     fe_d;

    always @(posedge rxclk) begin
        fe_d <= ferr;
        if (ferr && !fe_d) nferr = nferr + 1;
        if (valid) begin
            // いま受けた字は、頭から 8.5 ビット以上たった字のうち、いちばん後ろの字
            idx = -1;
            for (k = 0; k < 256; k = k + 1)
                if (ts[k] > 0.0 && ts[k] + 8.5 * BIT_NS <= $realtime) idx = k;
            if (idx >= 0 && rdata === idx[7:0]) nok = nok + 1;
        end
    end

    initial begin
        nok = 0; nferr = 0; fe_d = 1'b0;
        for (i = 0; i < 256; i = i + 1) ts[i] = 0.0;
        rst = 1'b1; start = 1'b0; data = 8'h00;
        #(40 * 1000) rst = 1'b0;
        #(10 * 208000);
        @(negedge txclk);
        for (i = 0; i < 256; i = i + 1) begin
            @(negedge txclk);
            while (busy) @(negedge txclk);
            data  = i[7:0];
            ts[i] = $realtime;
            start = 1'b1;
            @(negedge txclk);
            start = 1'b0;
            @(negedge txclk);
        end
        while (busy) @(negedge txclk);
        #(3 * 208000);
        $display("%2d x %2d us = %3d us  ずれ %6.2f %%  受けた字 %3d / 256  フレームエラー %2d",
                 DIV, TCLK_US, DIV * TCLK_US, (BIT_NS / 208000.0 - 1.0) * 100.0, nok, nferr);
    end
endmodule

module tb_rows;
    localparam integer N = 12;
    localparam integer DIVS  [0:N-1] = '{16, 15, 14, 18, 20, 17, 16, 15, 18, 20, 17, 16};
    localparam integer TCLKS [0:N-1] = '{12, 13, 14, 11, 10, 12, 13, 14, 12, 11, 13, 14};
    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : rows
            row #(.DIV(DIVS[g]), .TCLK_US(TCLKS[g])) u ();
        end
    endgenerate
    initial begin
        #1000000000;             // 1 s あれば全部の行が終わる
        $finish;
    end
endmodule
```

```bash
verilator --binary --timing --top-module tb_rows tb_rows.v skew_top.v hello_top.v uart_tx.v uart_rx.v
./obj_dir/Vtb_rows
```

```text
16 x 12 us = 192 us  ずれ  -7.69 %  受けた字   0 / 256  フレームエラー 40
15 x 13 us = 195 us  ずれ  -6.25 %  受けた字   1 / 256  フレームエラー 35
14 x 14 us = 196 us  ずれ  -5.77 %  受けた字   0 / 256  フレームエラー 25
18 x 11 us = 198 us  ずれ  -4.81 %  受けた字 256 / 256  フレームエラー  0
20 x 10 us = 200 us  ずれ  -3.85 %  受けた字 256 / 256  フレームエラー  0
17 x 12 us = 204 us  ずれ  -1.92 %  受けた字 256 / 256  フレームエラー  0
16 x 13 us = 208 us  ずれ   0.00 %  受けた字 256 / 256  フレームエラー  0
15 x 14 us = 210 us  ずれ   0.96 %  受けた字 256 / 256  フレームエラー  0
18 x 12 us = 216 us  ずれ   3.85 %  受けた字 256 / 256  フレームエラー  0
20 x 11 us = 220 us  ずれ   5.77 %  受けた字 217 / 256  フレームエラー 10
17 x 13 us = 221 us  ずれ   6.25 %  受けた字 128 / 256  フレームエラー  1
16 x 14 us = 224 us  ずれ   7.69 %  受けた字  44 / 256  フレームエラー  1
```

- **字の間に 2 クロックのすき間があると、速い送り手 (下側) の限界が広がる**。198 µs (−4.81 %) が通る。
  速い送り手のストップビットは短く、遅れて読んだ値が次の字のスタートの前の 1 (アイドル) に当たるため。1 の側 (+5.56 %) は変わらない
- 220 µs (+5.77 %) は式の上限 +5.56 % を超え、217 字しか受けられない。221 µs 以上は、半分以下になる
- 192・195・196 µs (−7.7 %・−6.3 %・−5.8 %) は 1 字も読めず、フレームエラーが出る

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 | 500 µs/div (10 目盛で 5 ms。1 字 = 10 ビットが 約 2 ms)。標本化 1 MS/s |
| トリガ | DIO0 の立ち下がり (スタートビット) |
| Protocol | UART。RX = DIO0、**4800 bps、8 ビット、パリティなし、ストップ 1**。Logic の読み下し (`decode:`) か、Protocol の UART で字を読む |
| 1 ビットの長さ | Logic のカーソルを、スタートビットの立ち下がりと立ち上がり (1 ビットめの変わり目) に置いて ΔX を読む |

## Logic に見えるはずの画面

7-2 の受け手がどこで読んでいるかを、シミュレーションで見る。送り手を +5.0 % ずらし (1 ビット 218.4 µs)、0x55 (0101 0101、
1 ビットごとに変わる字) を 1 字送った。`SMP` は 7-2 の `sample` (線を読んだ直後に 1 クロックだけ 1)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 ずれ +5.0 % の送り手 (0x55)。最後の読み (SMP) はストップビットの中
device: ad3
time: 250us/div
start: -50us
sample: 1MHz
signals:
  TXD: dio0 edges -50us=1 0s=0 218.4us=1 436.8us=0 655.2us=1 873.6us=0 1092us=1 1310.4us=0 1528.8us=1 1747.2us=0 1965.6us=1
  SMP: dio1 edges -50us=0 132.5us=1 145.5us=0 340.5us=1 353.5us=0 548.5us=1 561.5us=0 756.5us=1 769.5us=0 964.5us=1 977.5us=0 1172.5us=1 1185.5us=0 1380.5us=1 1393.5us=0 1588.5us=1 1601.5us=0 1796.5us=1 1809.5us=0 2004.5us=1 2017.5us=0
cursors: [1965.6us, 2004.5us]
trigger: TXD falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/logic/06-baud-tolerance.svg)

- 送り手のビットの境目は 218.4 µs ごと。`SMP` の間隔は 208 µs (受け手の 1 ビット) で、少しずつ**前へずれていく**
- 1 つ目の読みはスタートビットの真ん中 (0.55 ビット目)。最後の 10 回目 (ストップビット) の読みは 2004.5 µs
- ストップビットは 1965.6 µs (= 9 × 218.4) から。**読みは 38.9 µs 後 (X1 から X2)**。`SMP` の立ち上がりは線を読んだ 1 クロック後なので、
  読んだ時刻は約 26 µs 後で、ストップビットの中に 2 クロックの余裕がある。+5.56 % まで広げると、この余裕がなくなる

## 実機で測る手順

1. `skew_top.v` の `DIV` と、5-7 のタイマ割り込みの間隔 `TCLK_US` を、下の表の 1 行の値にして書き込む
2. Logic で 1 ビットの長さ (ΔX) を読み、`DIV × TCLK_US` に合っているか確かめる
3. AD3 の Protocol の UART (4800 bps、8N1) の読み下しが `Hi` になるか、文字化けするかを見る
4. 全部の行で繰り返し、「読めた」と「文字化け」の境目を表に書く

AD3 の Protocol の UART が許す範囲は、この題の受け手 (7-2) と同じ計算にはならない。
**表の「実機 (測って書く)」の列は、AD3 の受信の境目**。Pico 2 の受信の境目は、7-7 で AD3 の Protocol の UART の送りの速さ (Rate) を変えて確かめる。

## 見るべき値

シミュレーションの値と計算値。実機では測っていない。

| DIV × TCLK_US | 1 ビット | ずれ (計算値) | 7-2 の受け手で読む (シミュレーション) | AD3 の Protocol で読む (測って書く) |
| --- | --- | --- | --- | --- |
| 16 × 12 µs | 192 µs | −7.69 % | 0 / 256 (読めない) | |
| 15 × 13 µs | 195 µs | −6.25 % | 1 / 256 (読めない) | |
| 14 × 14 µs | 196 µs | −5.77 % | 0 / 256 (読めない) | |
| 18 × 11 µs | 198 µs | −4.81 % | 256 / 256 | |
| 20 × 10 µs | 200 µs | −3.85 % | 256 / 256 | |
| 17 × 12 µs | 204 µs | −1.92 % | 256 / 256 | |
| **16 × 13 µs** | **208 µs** | **0.00 %** | **256 / 256** | |
| 15 × 14 µs | 210 µs | +0.96 % | 256 / 256 | |
| 18 × 12 µs | 216 µs | +3.85 % | 256 / 256 | |
| 20 × 11 µs | 220 µs | +5.77 % | 217 / 256 | |
| 17 × 13 µs | 221 µs | +6.25 % | 128 / 256 | |
| 16 × 14 µs | 224 µs | +7.69 % | 44 / 256 | |

- ずれは受け手の 1 ビット 208 µs (16 クロック × 13 µs) に対する割合。基準の 16 × 13 µs は 4808 bps で、4800 bps に対して +0.16 %
- 4800 bps の AD3 が読む 208.33 µs に対しては、各行のずれが 0.16 % ほど小さくなる
- 実機の境目は、AD3 の受信の作りで ±5 % 付近のどこかになるはず。測って、7-2 のシミュレーションの境目 (−4.35 %・+5.55 %) と比べる

## シミュレーションでの確かめ

Verilator 5.042 で、本文の `skew_top.v` `tb_skew.v` `tb_rows.v` を取り出し、7-1 の `uart_tx.v` `hello_top.v`
と 7-2 の `uart_rx.v` と合わせて走らせ直した。
置き場は `sim/06-baud-tolerance.v` (`skew_top`)、`sim/06-baud-tolerance-tb.v` (`tb_skew`)、
`sim/06-baud-tolerance-rows-tb.v` (`tb_rows`)、`sim/06-baud-tolerance-fig4-tb.v` (図4 の波形を取る試験)。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、`skew_top`) | 警告 0 件 | 0 件 | 合った |
| −8 〜 +8 % の掃引 (33 行) | 本文の表 | 33 行とも同じ | 合った |
| 境目 −4.35 % | 256 | 256 | 合った |
| 境目 −4.40 % | 23 | 掃引の範囲で変わる (−4.50〜−4.25 なら 23、−4.40 だけなら 36、−5.00〜−4.00 なら 17) | 合った (位相で変わる) |
| 境目 +5.55 % / +5.60 % | 256 / 251 | 256 / 251 | 合った |
| 12 通りの表 | 本文の 12 行 | 12 行とも同じ | 合った |
| 図4 の SMP の立ち上がり | 132.5・340.5 … 2004.5 µs | 同じ (1 つ目のクロックがスタートの 2.5 µs 後のとき) | 合った |
| 式の下限・上限 | −5.0 %・+5.56 % | 0.5 ÷ 10、0.5 ÷ 9 | 合った |

−4.40 % の字数は、送り手とクロックの位相で変わる。本文の 23 は `-GSKEW0=-450 -GSKEW1=-425 -GSKEWD=5` で出た値で、
`-GSKEW0=-440 -GSKEW1=-440` の 1 点だけを回すと 36 字になった。本文も「位相で少し変わる」と書いている。
図4 の `SMP` の時刻もクロックとの位相に依る。`sim/06-baud-tolerance-fig4-tb.v` は、本文の図と同じ位相 (スタートの立ち下がりの
2.5 µs 後に最初のクロックが来る) にしてある。位相を変えると、全部の読みが同じだけ前後に動く。

AD3 の Protocol の受信の境目は、実機が要るので確かめていない。

## 出典

自作。UART の 8N1 の形と 16 倍刻みで読む方法は 7-1・7-2。ずれの式は、受け手が各ビットの真ん中で読むという 7-2 の決まりから、
この題で導いた。AD3 の Logic・Protocol の使い方は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)・
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
