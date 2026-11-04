---
book: fpga
chapter: 7
id: 7-5
title: I2C のマスタ — 温度センサーを読む
tier: 100
source: 自作
board: —
device: SIM
---

# 7-5 I2C のマスタ — 温度センサーを読む

> [!WARNING]
> **この題は実機で組んでいない。** Verilog は Verilator の lint を通し、PC のシミュレーション
> (LM75 の動きを真似た模型) で 5 回の読み出しを確かめた。「見るべき値」はシミュレーションの値と計算値。

I2C は、**2 本の線 (SDA と SCL) に何台もつなぐ**通信。SPI (7-4) のように相手ごとの CS の線を引かず、
**アドレス**で相手を選ぶ。この題では Pico 2 の Soft-FPGA がマスタになり、温度センサー LM75 (アドレス 0x48) の温度を 0.5 秒ごとに読む。
読んだ値は、7-1 の UART で 16 進の文字にして出す。

この題は Verilog を書いて PC で確かめる所までで、組まない (`device: SIM`)。実体配線図・Analog Discovery 3・Logic の図は付けない。
プルアップの抵抗、Pico 2 に載せて組む回路、AD3 で見る画面は 7-19。

## I2C の決まり

| 決まり | 内容 |
| --- | --- |
| 線 | SDA (データ) と SCL (クロック)。どちらも**オープンドレイン**で、0 を出すか放すかの 2 通りしかない。1 は外のプルアップ抵抗が作る |
| START | SCL が 1 の間に SDA を 1 → 0 にする。通信の始まり |
| STOP | SCL が 1 の間に SDA を 0 → 1 にする。通信の終わり |
| データ | SCL が 0 の間に SDA を変え、SCL が 1 の間は SDA を動かさない。1 バイト = 8 ビット (上位から)。SCL の立ち上がりで読む |
| ACK | 1 バイトの後の 9 つ目のクロックで、受けた側が SDA を 0 に引く。1 のままなら NACK (返事なし、または「もう要らない」) |
| アドレス | START の後の最初のバイト = 7 ビットのアドレス + 読み書きの 1 ビット (0 = 書き、1 = 読み) |

## 温度センサー LM75 の決まり

この題の温度センサーは Texas Instruments の **LM75B** (データシート SNIS153D、2015-10)。

| 項目 | 値 | データシートの箇所 |
| --- | --- | --- |
| 電源電圧 | 3 V〜5.5 V | 1 Features・6.3 |
| スレーブアドレス (7 ビット) | 1001 A2 A1 A0。A2・A1・A0 を GND に落とすと **0x48** | 7.5.1 |
| ポインタレジスタ | 0 = 温度 (読み出し専用)、1 = 設定、2 = THYST、3 = TOS。**電源投入直後は 0** | 7.5.8・7.4 |
| 温度の形式 | 9 ビット、2 の補数、**1 ビット = 0.5 °C**。2 バイトで返り、最初のバイトが上位。データは 16 ビットの上位 9 ビット (下位バイトの最上位ビットが 0.5 °C) | 7.5.2・7.5.8 |
| 精度 | −25 °C〜100 °C で ±2 °C (最大) | 6.5 |
| 変換の間隔 | 標準 100 ms、最大 300 ms。**300 ms より短い間隔で続けて読まない** | 6.5 の注 (5) |
| SCL | 400 kHz まで (周期 2.5 µs 以上) | 3 Description・6.7 (t1) |
| SDA の Low | 3 mA で 0.4 V 以下 | 6.6 |
| プルアップ | SDA・SCL に **10 kΩ** (設計の前提として書かれている) | 8.2.1.1 |
| バイパスコンデンサ | 100 nF (と 10 µF) | 8.2.1.1 |

データシート 7.5.2 の表の温度を、読み出す 2 バイトに直すと次のとおり。
9 ビットの値 V から、上位バイト = V の上位 8 ビット、下位バイト = V の最下位ビットを 0x80 にしたもの (0 なら 0x00)。

| 温度 | 9 ビットの値 | 上位バイト | 下位バイト |
| --- | --- | --- | --- |
| +125 °C | 0 1111 1010 (0x0FA) | 0x7D | 0x00 |
| +25 °C | 0 0011 0010 (0x032) | 0x19 | 0x00 |
| +0.5 °C | 0 0000 0001 (0x001) | 0x00 | 0x80 |
| 0 °C | 0 0000 0000 (0x000) | 0x00 | 0x00 |
| −0.5 °C | 1 1111 1111 (0x1FF) | 0xFF | 0x80 |
| −25 °C | 1 1100 1110 (0x1CE) | 0xE7 | 0x00 |
| −55 °C | 1 1001 0010 (0x192) | 0xC9 | 0x00 |

**変換の式**: 温度 [°C] = (上位バイトを符号付き 8 ビットとして読んだ値 × 2 + 下位バイトの最上位ビット) × 0.5。
例: 0x19 0x80 → (25 × 2 + 1) × 0.5 = 25.5 °C。0xE7 0x00 → (−25 × 2 + 0) × 0.5 = −25.0 °C。

**確かめた範囲と、確かめていないこと。**

- 確かめた: 上の表の値。LM75B の TI のデータシート 1 冊だけから読んだ
- 注意: 本文 (7.3.1・8.2.1.1) には動作電圧 2.7 V とも書かれているが、規格の表 (6.3) は 3 V から。3.3 V の電源はどちらでも範囲に入る
- 確かめていない: 他社の LM75 や、同じ名前の互換品 (NXP などの LM75B は、温度が 11 ビット = 0.125 °C の品がある)。買った品のデータシートで、アドレスと形式を見直す
- データシートでは、3.3 V 用の品は型番の末尾が `-3` の品 (LM75BIM-3 など) で、3.3 V の規格を当てている。実際に売っている型番は、買う前に確かめる

## SCL の速さ

クロックは 7-1〜7-3 と同じ **13 µs (76.923 kHz)**。SCL の 1 周期を 4 つの 1/4 周期に分け、1 つを 1 クロックにする。
**SCL の周期は 4 クロック = 52 µs (19.23 kHz)** (計算値)。LM75B の上限 400 kHz よりずっと遅い。

## 通信の順

```plantuml
@startuml
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
participant "マスタ\n(Pico 2)" as M
participant "LM75\n(0x48)" as S

M -> S : START と 0x90 (アドレス 0x48 + 書き)
S --> M : ACK
M -> S : 0x00 (ポインタ = 温度レジスタ)
S --> M : ACK
M -> S : 再 START と 0x91 (アドレス 0x48 + 読み)
S --> M : ACK
S -> M : 上位バイト
M --> S : ACK
S -> M : 下位バイト
M --> S : NACK と STOP
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/plantuml/05-i2c-master-temperature.svg)

- 先にポインタを 0 にしてから読む。電源投入直後はポインタが 0 なので書きを省いてもよいが、設定を変えた後でも読めるように毎回書く
- 再 START (STOP を挟まない START) で、書きから読みへ変える
- 最後のバイトには NACK (「もう要らない」) を返してから STOP

## Verilog

### i2c_read.v — マスタ

```verilog
// I2C のマスタ (100 kHz 以下のスタンダードモード、7 ビットアドレス)。
// LM75 のレジスタを 1 つ読む決まった手順だけを行う:
//   START - (ADDR<<1|0) - ACK - PTR - ACK - 再START - (ADDR<<1|1) - ACK - 上位バイト - ACK - 下位バイト - NACK - STOP
// SDA と SCL は「0 を引く」か「放す」かだけ。1 は外のプルアップが作る (オープンドレイン)
module i2c_read #(
    parameter [6:0] ADDR = 7'h48,   // LM75 は A2・A1・A0 を GND に落とすと 0x48
    parameter [7:0] PTR  = 8'h00,   // 読むレジスタ。0 が温度
    parameter integer QTR = 1       // SCL の 1/4 周期のクロック数。1 なら SCL = クロック / 4
) (
    input            clk,
    input            rst,
    input            start,         // 1 クロック 1 で読み始める
    input            sda_in,        // SDA 線の今の値 (GPIO の入力)
    output reg       sda_low,       // 1 のとき SDA を GND へ引く。0 なら放す
    output reg       scl_low,       // 1 のとき SCL を GND へ引く。0 なら放す
    output           busy,
    output reg       done,          // 読み終えたクロックだけ 1
    output reg       nack,          // done のとき 1 なら、アドレスかレジスタ番号に ACK が返らなかった
    output reg [7:0] data_hi,       // 温度の上位バイト
    output reg [7:0] data_lo        // 温度の下位バイト
);
    localparam integer QW = (QTR > 1) ? $clog2(QTR) : 1;

    reg            active;
    reg [5:0]      slot;            // 0〜47
    reg [1:0]      ph;              // 枠の中の 1/4 周期 0〜3
    reg [QW-1:0]   qcnt;
    reg            nack_acc;
    reg [7:0]      sh_in;

    assign busy = active;

    // 枠 slot の種類。
    //  0: START  1〜8: アドレス(書き)  9: ACK  10〜17: レジスタ番号  18: ACK  19: 再START
    //  20〜27: アドレス(読み)  28: ACK  29〜36: 上位バイトを受ける  37: ACK を返す
    //  38〜45: 下位バイトを受ける  46: NACK を返す  47: STOP
    wire [7:0] addr_w = {ADDR, 1'b0};
    wire [7:0] addr_r = {ADDR, 1'b1};

    // 枠の番号から、8 ビットのうち何ビット目 (7 が最初) を出すか。3 ビットで足りるので下位だけ使う
    wire [2:0] bit_a = 3'd0 - slot[2:0];   // 枠 1〜8   → 7〜0
    wire [2:0] bit_p = 3'd1 - slot[2:0];   // 枠 10〜17 → 7〜0
    wire [2:0] bit_r = 3'd3 - slot[2:0];   // 枠 20〜27 → 7〜0

    // 枠が出すビット (master → slave の枠だけ意味がある)。
    reg out_bit;
    always @(*) begin
        out_bit = 1'b1;
        if (slot >= 6'd1  && slot <= 6'd8)  out_bit = addr_w[bit_a];
        if (slot >= 6'd10 && slot <= 6'd17) out_bit = PTR[bit_p];
        if (slot >= 6'd20 && slot <= 6'd27) out_bit = addr_r[bit_r];
        if (slot == 6'd37)                  out_bit = 1'b0;     // 上位バイトに ACK を返す (0 を引く)
        if (slot == 6'd46)                  out_bit = 1'b1;     // 下位バイトに NACK を返す (放す)
    end

    wire is_start = (slot == 6'd0)  || (slot == 6'd19);
    wire is_stop  = (slot == 6'd47);
    wire is_ackin = (slot == 6'd9)  || (slot == 6'd18) || (slot == 6'd28);
    wire is_din   = (slot >= 6'd29 && slot <= 6'd36) || (slot >= 6'd38 && slot <= 6'd45);
    wire q_last   = (qcnt == QTR[QW-1:0] - 1'b1);

    always @(posedge clk)
        if (rst) begin
            active   <= 1'b0;
            slot     <= 6'd0;
            ph       <= 2'd0;
            qcnt     <= {QW{1'b0}};
            sda_low  <= 1'b0;
            scl_low  <= 1'b0;
            done     <= 1'b0;
            nack     <= 1'b0;
            nack_acc <= 1'b0;
            sh_in    <= 8'h00;
            data_hi  <= 8'h00;
            data_lo  <= 8'h00;
        end else begin
            done <= 1'b0;
            if (!active) begin
                if (start) begin
                    active   <= 1'b1;
                    slot     <= 6'd0;
                    ph       <= 2'd0;
                    qcnt     <= {QW{1'b0}};
                    nack_acc <= 1'b0;
                    sda_low  <= 1'b0;     // バスは両方放した状態から始める
                    scl_low  <= 1'b0;
                end
            end else begin
                // ---- 1/4 周期ごとに線を動かす (枠の頭 ph == 0 で SDA、ph == 1 で SCL を上げる、…)
                if (qcnt == {QW{1'b0}}) begin
                    case (ph)
                        2'd0: begin
                            // SCL を低くしたまま SDA を決める
                            if (is_stop) begin scl_low <= 1'b1; sda_low <= 1'b1; end
                            else begin
                                scl_low <= 1'b1;
                                if (is_start)      sda_low <= 1'b0;          // 放す (1)
                                else if (is_ackin || is_din) sda_low <= 1'b0;  // 相手に任せる
                                else               sda_low <= ~out_bit;
                            end
                        end
                        2'd1: scl_low <= 1'b0;                                // SCL を放して上げる
                        2'd2: begin
                            if (is_start) sda_low <= 1'b1;                    // SCL が高いうちに SDA を下げる = START
                            if (is_ackin && sda_in) nack_acc <= 1'b1;         // ACK の枠で 1 なら返事が無い
                            if (is_din) sh_in <= {sh_in[6:0], sda_in};        // SCL の高い真ん中で読む
                        end
                        default: begin
                            if (is_stop) sda_low <= 1'b0;                     // SCL が高いうちに SDA を放す = STOP
                            else scl_low <= 1'b1;                             // SCL を下げる
                        end
                    endcase
                end
                // ---- 時間を進める
                if (!q_last) qcnt <= qcnt + 1'b1;
                else begin
                    qcnt <= {QW{1'b0}};
                    if (ph != 2'd3) ph <= ph + 2'd1;
                    else begin
                        ph <= 2'd0;
                        // 枠の終わりで、読んだバイトを置く
                        if (slot == 6'd36) data_hi <= sh_in;
                        if (slot == 6'd45) data_lo <= sh_in;
                        if (slot == 6'd47) begin
                            active <= 1'b0;
                            done   <= 1'b1;
                            nack   <= nack_acc;
                        end else
                            slot <= slot + 6'd1;
                    end
                end
            end
        end
endmodule
```

- 1 ビットぶんの時間を **枠** (slot) と数え、枠を 48 個並べ、START から STOP までを決まった順に出す。枠の中は 1/4 周期 (ph) が 4 つ
- 各枠の中では、ph 0 で SCL を 0 にしたまま SDA を決め、ph 1 で SCL を放して 1 にし、ph 2 (SCL が 1 の真ん中) で SDA を読み、ph 3 で SCL を 0 に戻す
- `sda_low` と `scl_low` は「0 を引く」ときだけ 1。1 は出さずに**放す** (オープンドレイン)
- ACK の枠 (9・18・28) では SDA を放し、ph 2 で 1 が見えたら `nack_acc` を立てる。NACK は `nack` で外へ出す
- SCL を引き延ばす相手 (クロックストレッチ) には使えない。LM75B のデータシートには引き延ばしの記述が見つからなかった

### i2c_temp_top.v — 0.5 s ごとに読んで UART に出す

```verilog
// 0.5 s ごとに LM75 の温度レジスタを読み、2 バイトを 16 進で UART に出す。Pico 2 に載せる最上位
//   読めたとき  "19 80\r\n"   (上位バイト 下位バイト)
//   返事が無いとき "ERR\r\n"
module i2c_temp_top #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input  clk,
    input  rst,
    input  sda_in,      // GP4  SDA の線の値
    output sda_low,     // GP4  1 のとき出力 0 を出し、0 のとき入力にする (外のプルアップが 1 を作る)
    output scl_low,     // GP5  同上
    output txd          // GP15 UART の TXD
);
    localparam integer HALF = CLK_HZ / 2;
    localparam integer W    = $clog2(HALF);

    reg [W-1:0] tcnt;
    reg         rd_start;
    wire        rd_busy, rd_done, rd_nack;
    wire [7:0]  t_hi, t_lo;

    i2c_read #(.ADDR(7'h48), .PTR(8'h00), .QTR(1)) u_rd (
        .clk(clk), .rst(rst), .start(rd_start), .sda_in(sda_in),
        .sda_low(sda_low), .scl_low(scl_low), .busy(rd_busy), .done(rd_done),
        .nack(rd_nack), .data_hi(t_hi), .data_lo(t_lo));

    // ---- 結果を 1 行にして UART へ
    reg [7:0] hi, lo;
    reg       err;
    reg [2:0] idx;       // 次に送る字の番号
    reg [2:0] len;       // 1 行の字数。7 (16 進 2 桁 + 空白 + 2 桁 + CR LF) か 5 (ERR + CR LF)
    reg       sending;
    reg       tx_start;
    reg [7:0] tx_data;
    wire      tx_busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(tx_data), .start(tx_start), .txd(txd), .busy(tx_busy));

    function [7:0] hex(input [3:0] n);
        hex = (n < 4'd10) ? (8'h30 + {4'd0, n}) : (8'h37 + {4'd0, n});   // 0-9 は 0x30〜、A-F は 0x41〜
    endfunction

    function [7:0] ch(input [2:0] i, input [7:0] h, input [7:0] l, input e);
        if (e)
            case (i)
                3'd0:    ch = "E";
                3'd1:    ch = "R";
                3'd2:    ch = "R";
                3'd3:    ch = 8'h0D;
                default: ch = 8'h0A;
            endcase
        else
            case (i)
                3'd0:    ch = hex(h[7:4]);
                3'd1:    ch = hex(h[3:0]);
                3'd2:    ch = " ";
                3'd3:    ch = hex(l[7:4]);
                3'd4:    ch = hex(l[3:0]);
                3'd5:    ch = 8'h0D;
                default: ch = 8'h0A;
            endcase
    endfunction

    always @(posedge clk)
        if (rst) begin
            tcnt     <= {W{1'b0}};
            rd_start <= 1'b0;
            hi       <= 8'h00;
            lo       <= 8'h00;
            err      <= 1'b0;
            idx      <= 3'd0;
            len      <= 3'd0;
            sending  <= 1'b0;
            tx_start <= 1'b0;
            tx_data  <= 8'h00;
        end else begin
            rd_start <= 1'b0;
            tx_start <= 1'b0;

            // 0.5 s ごとに読み始める (LM75 の変換は 100 ms 程度。300 ms 以内に続けて読まない)
            if (tcnt == HALF[W-1:0] - 1'b1) begin
                tcnt <= {W{1'b0}};
                if (!rd_busy && !sending) rd_start <= 1'b1;
            end else
                tcnt <= tcnt + 1'b1;

            // 読めたら 1 行にする
            if (rd_done) begin
                hi      <= t_hi;
                lo      <= t_lo;
                err     <= rd_nack;
                len     <= rd_nack ? 3'd5 : 3'd7;
                idx     <= 3'd0;
                sending <= 1'b1;
            end

            // 1 字ずつ送る
            if (sending && !tx_busy && !tx_start) begin
                if (idx == len)
                    sending <= 1'b0;
                else begin
                    tx_data  <= ch(idx, hi, lo, err);
                    tx_start <= 1'b1;
                    idx      <= idx + 3'd1;
                end
            end
        end
endmodule
```

- 読む間隔は 0.5 s (38 461 クロック)。LM75B の変換の最大 300 ms より長い
- 出す行は `19 80` と CR LF (7 字)。返事が無いときは `ERR` と CR LF (5 字)。7-1 の `uart_tx.v` をそのまま使う
- 16 進の桁は 0〜9 を 0x30 から、A〜F を 0x41 から (`hex` 関数)。0x0A は 0x37 + 10 = 0x41 で 'A'

Verilator の lint は警告なしで通る (`verilator --lint-only -Wall --top-module i2c_temp_top i2c_temp_top.v i2c_read.v uart_tx.v`、確かめた)。

### Pico 2 のピンの割り当て

組み方は 5-3 と 5-7 (手本は [Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/main.cpp`)。

| Verilog | Pico 2 | 向き | 設定 |
| --- | --- | --- | --- |
| `clk` | (ピンなし) | — | **13 µs ごと**のタイマ割り込みで 0 → 1 と変えて評価する (5-7) |
| `rst` | (ピンなし) | — | 起動して最初の 1 クロックだけ 1 |
| `sda_in` | GP4 | 入力 | SDA の線の値。内部のプルアップは使わない (外の 10 kΩ に任せる) |
| `sda_low` | GP4 | 出力 (0 を出す) / 入力 | 1 のとき**出力にして 0 を出す**。0 のとき**入力に戻す** (1 を出さない) |
| `scl_low` | GP5 | 出力 (0 を出す) / 入力 | 同上 |
| `txd` | GP15 | 出力 | 起動直後から 1 を出す (アイドル) |

`sda_low`・`scl_low` で GPIO の向きを毎クロック切り替える組み方 (5-3 の応用。出力値は常に 0 にして向きだけを切り替える) は、
動かして確かめていない。

## 動かす — PC のシミュレーション

LM75 の動きを真似たテストベンチの模型 (アドレス一致で ACK を返し、ポインタを受け、上位・下位の順に 2 バイトを返す) と、
UART の出力を 4800 bps で読む受け手を `i2c_temp_top` につなぐ。SDA と SCL は、マスタと模型のどちらかが 0 を引けば 0、
どちらも放せば 1 (外のプルアップ)。温度の値を途中で変えて、読み出しごとに出る行を見る。

```verilog
`timescale 1ns / 1ps
// LM75 の動きを真似た模型 (アドレス ADDR、ポインタで温度レジスタを選び、上位・下位の順に 2 バイト返す) に
// i2c_temp_top をつなぎ、UART の出力 (4800 bps) を読んで書き出す。SDA と SCL はオープンドレイン (どちらかが 0 を引けば 0)
module tb_i2c;
    parameter [6:0] MODEL_ADDR = 7'h48;

    reg clk;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;          // 13 us
    end
    reg rst;

    wire sda_low, scl_low, txd;
    reg  slv_low;                           // 模型が SDA を 0 に引く
    wire sda = ~(sda_low | slv_low);        // 外のプルアップが 1 を作る
    wire scl = ~scl_low;

    i2c_temp_top dut (.clk(clk), .rst(rst), .sda_in(sda),
                      .sda_low(sda_low), .scl_low(scl_low), .txd(txd));

    // ---- LM75 の模型
    reg [7:0] t_hi, t_lo, ptr_reg;
    integer   n_read;
    task automatic recv_byte(output [7:0] b);
        integer i;
        begin
            b = 8'h00;
            for (i = 0; i < 8; i = i + 1) begin
                @(posedge scl);
                b = {b[6:0], sda};
            end
        end
    endtask
    task automatic send_ack;
        begin
            @(negedge scl); slv_low = 1'b1;     // 8 ビット目の次の SCL の間、0 を引く
            @(negedge scl); slv_low = 1'b0;
        end
    endtask
    task automatic send_byte(input [7:0] v, output ack);
        integer i;
        begin
            slv_low = ~v[7];                    // 直前の negedge の直後なので、最上位ビットをここで出す
            for (i = 6; i >= 0; i = i - 1) begin
                @(negedge scl);
                slv_low = ~v[i];
            end
            @(negedge scl);
            slv_low = 1'b0;                     // 9 つ目のクロックは放す。マスタが ACK か NACK を返す
            @(posedge scl);
            ack = ~sda;
            @(negedge scl);                     // この negedge の直後に次のバイトの最上位ビットを出す
        end
    endtask

    reg [7:0] rb;
    reg       a;
    initial begin
        slv_low = 1'b0; t_hi = 8'h19; t_lo = 8'h80; ptr_reg = 8'h00; n_read = 0;
        forever begin
            @(negedge sda);
            if (scl) begin                          // START
                recv_byte(rb);
                if (rb[7:1] == MODEL_ADDR && !rb[0]) begin
                    send_ack;
                    recv_byte(rb);                  // ポインタ
                    ptr_reg = rb;
                    send_ack;
                    @(negedge sda);                 // 再 START
                    recv_byte(rb);
                    if (rb[7:1] == MODEL_ADDR && rb[0]) begin
                        send_ack;
                        send_byte(t_hi, a);
                        send_byte(t_lo, a);         // マスタの NACK のあとは何もしない
                        slv_low = 1'b0;
                        n_read = n_read + 1;
                    end
                end else begin
                    // 自分のアドレスでなければ ACK を返さない (SDA は 1 のまま)
                end
            end
        end
    end

    // ---- UART の受信 (4800 bps ちょうど)
    localparam real BIT_NS = 1.0e9 / 4800.0;
    reg [7:0] rx;
    integer   b;
    integer   nchar = 0;
    reg [8*8-1:0] line;
    integer   ll = 0;
    initial begin
        #1000;
        forever begin
            @(negedge txd);
            #(BIT_NS * 1.5);
            for (b = 0; b < 8; b = b + 1) begin
                rx[b] = txd;
                #(BIT_NS);
            end
            nchar = nchar + 1;
            if (rx == 8'h0A) begin
                $display("  uart line (%0d reads): %0s", n_read, line);
                line = 0; ll = 0;
            end else if (rx != 8'h0D) begin
                line = {line[8*7-1:0], rx};
                ll = ll + 1;
            end
        end
    end

    // ---- 変わり目の記録 (最初の 1 回の読み出し。logic の図の元)
    realtime t0, tlast;
    integer  go = 0;
    always @(sda or scl) begin
        if (!rst && n_read < 2 && (go == 0 || $realtime - t0 < 2700000.0)) begin
            if (go == 0) t0 = $realtime;
            $display("EDGE %9.1f scl=%b sda=%b", ($realtime - t0) / 1000.0, scl, sda);
            go = go + 1;
        end
    end

    // ---- UART の TXD の変わり目 (最初の 1 行。最初の START からの時刻)
    realtime tstart_i2c;
    reg got_start = 0;
    always @(negedge sda) if (scl && !got_start && !rst) begin tstart_i2c = $realtime; got_start = 1; end
    always @(txd)
        if (got_start && n_read < 2 && $realtime - tstart_i2c < 22000000.0)
            $display("TXD %9.1f %b", ($realtime - tstart_i2c) / 1000.0, txd);

    initial begin
        #4000000000 $finish;               // 返事が無い試験のための打ち切り (4 s)
    end

    initial begin
        rst = 1'b1;
        #26000 rst = 1'b0;
        wait (n_read == 1);
        #(12 * BIT_NS * 7);
        $display("--- 温度を -25.0 C (0xE7 0x00) に変える");
        t_hi = 8'hE7; t_lo = 8'h00;
        wait (n_read == 2); wait (n_read == 3);
        #(12 * BIT_NS * 7);
        $display("--- 0x7D 0x00 (+125 C)");
        t_hi = 8'h7D; t_lo = 8'h00;
        wait (n_read == 5);
        #(12 * BIT_NS * 7);
        $finish;
    end
endmodule
```

```bash
verilator --binary --timing --top-module tb_i2c tb_i2c.v i2c_temp_top.v i2c_read.v uart_tx.v
./obj_dir/Vtb_i2c
```

```text
  uart line (1 reads): 19 80
--- 温度を -25.0 C (0xE7 0x00) に変える
  uart line (2 reads): E7 00
  uart line (3 reads): E7 00
--- 0x7D 0x00 (+125 C)
  uart line (4 reads): 7D 00
  uart line (5 reads): 7D 00
```

(Verilator 5.042 で実行。`EDGE` と `TXD` の行 (7-19 の図の元になる変わり目の時刻) は省いた。読み出しは 0.5 s ごとなので、温度を変えた後の行が 2 回ずつ続く。)

## 見るべき値 (シミュレーションを実行して得た値)

| 模型の温度レジスタ | 1 行に出た字 | 式で直した温度 |
| --- | --- | --- |
| 0x19 0x80 | `19 80` | 25.5 °C |
| 0xE7 0x00 | `E7 00` | −25.0 °C |
| 0x7D 0x00 | `7D 00` | +125.0 °C |
| (模型のアドレスを 0x49 にした) | `ERR` | 返事なし |

- 1 回の通信は START から STOP まで 2.457 ms (48 枠 × 52 µs から、前後の半枠を引いた長さ)
- 返事が無いとき (アドレスが違うとき) は、アドレスの ACK で SDA が 1 のままなので `ERR` になる (`-GMODEL_ADDR=7'h49` で再現)

## シミュレーションでの確かめ

Verilator 5.042 で、本文の `i2c_read.v` `i2c_temp_top.v` `tb_i2c.v` を取り出し、7-1 の `uart_tx.v` と合わせて走らせ直した。
置き場は `sim/05-i2c-master-temperature.v` `sim/05-i2c-master-temperature-top.v` `sim/05-i2c-master-temperature-tb.v`
(送信は `sim/01-uart-tx.v`)。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、`i2c_temp_top` を最上位) | 警告 0 件 | 0 件 | 合った |
| UART の行 | `19 80`、`E7 00` が 2 回、`7D 00` が 2 回 | 同じ | 合った |
| 模型のアドレスを 0x49 にしたとき | `ERR` | `ERR` が毎回 | 合った |
| 1 回の通信の長さ | 2.457 ms | STOP が 2457 µs | 合った |

LM75 の実物の応答、SDA の向き替え (GPIO) と電圧の値は、実機が要るので確かめていない (7-19)。

## 出典

自作。LM75B のアドレス・レジスタ・温度の形式・電圧・変換時間・プルアップの値は Texas Instruments
[LM75B, LM75C データシート (SNIS153D、2015-10)](https://www.ti.com/lit/ds/symlink/lm75b.pdf) の表と本文から読んだ。
I2C の START・STOP・ACK の定義は [SLVA704 Understanding the I2C Bus](https://www.ti.com/lit/an/slva704/slva704.pdf)。
LM75 を AD3 から叩く題は 02-analog-discovery/07-logic/04-i2c-temperature.md (5 V、AD3 がマスタ)。
