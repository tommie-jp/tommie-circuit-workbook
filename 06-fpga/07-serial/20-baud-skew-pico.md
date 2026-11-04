---
book: fpga
chapter: 7
id: 7-20
title: ボーレートのずれを Pico 2 で作り、AD3 で読めるかを見る
tier: 100
source: 自作
board: BB
device: PICO
---

# 7-20 ボーレートのずれを Pico 2 で作り、AD3 で読めるかを見る

> [!WARNING]
> **この題は実機で組んでいない。** Verilog は Verilator の lint を通し、実機の表の各行を PC のシミュレーションで再現した。
> Pico 2 への書き込みと、AD3 での測定はしていない。「見るべき値」はシミュレーションの値と計算値。

7-6 で、1 字 10 ビットの UART が許すボーレートのずれを式 (−5.0 % 〜 +5.56 %) とシミュレーション
(7-2 の受け手で −4.35 % 〜 +5.55 %) で出した。この題では、Pico 2 の送り手 (7-1) の 1 ビットの長さを変えて、
AD3 の Protocol の UART が読めるか、文字化けするかの境目を測る。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/circuit/20-baud-skew-pico.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/breadboard/20-baud-skew-pico.svg)

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

## 動かす — 実機の表の各行を、7-1 の送り手で再現する

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
title: 図3 ずれ +5.0 % の送り手 (0x55)。最後の読み (SMP) はストップビットの中
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

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/logic/20-baud-skew-pico.svg)

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
- 実機の境目は、AD3 の受信の作りで ±5 % 付近のどこかになるはず。測って、7-6 のシミュレーション (7-2 の受け手) の境目 (−4.35 %・+5.55 %) と比べる

## シミュレーションでの確かめ

Verilator 5.042 で、本文の `skew_top.v` `tb_rows.v` を取り出し、7-1 の `uart_tx.v` `hello_top.v`
と 7-2 の `uart_rx.v` と合わせて走らせ直した。
置き場は `sim/06-baud-tolerance.v` (`skew_top`)、`sim/06-baud-tolerance-rows-tb.v` (`tb_rows`)、
`sim/06-baud-tolerance-fig4-tb.v` (図3 の波形を取る試験)。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、`skew_top`) | 警告 0 件 | 0 件 | 合った |
| 12 通りの表 | 本文の 12 行 | 12 行とも同じ | 合った |
| 図3 の SMP の立ち上がり | 132.5・340.5 … 2004.5 µs | 同じ (1 つ目のクロックがスタートの 2.5 µs 後のとき) | 合った |

図3 の `SMP` の時刻もクロックとの位相に依る。`sim/06-baud-tolerance-fig4-tb.v` は、本文の図と同じ位相 (スタートの立ち下がりの
2.5 µs 後に最初のクロックが来る) にしてある。位相を変えると、全部の読みが同じだけ前後に動く。

AD3 の Protocol の受信の境目は、実機が要るので確かめていない。

## 出典

自作。UART の 8N1 の形と 16 倍刻みで読む方法は 7-1・7-2。ずれの式は、受け手が各ビットの真ん中で読むという 7-2 の決まりから、
この題で導いた。AD3 の Logic・Protocol の使い方は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)・
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
