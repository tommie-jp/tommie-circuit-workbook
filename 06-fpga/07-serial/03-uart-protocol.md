---
book: fpga
chapter: 7
id: 7-3
title: AD3 の Protocol で UART の字を読む
tier: 50
source: 自作
board: BB
device: PICO
---

# 7-3 AD3 の Protocol で UART の字を読む

> [!WARNING]
> **この題は実機で組んでいない。** Verilog は Verilator の lint を通し、PC のシミュレーションで 5.6 s 分を回して、
> 送った 11 行を 4800 bps の受け手で読んだ。Baud をまちがえたときの読み違いもシミュレーションで出した。
> Pico 2 への書き込みと、AD3 の Protocol での受信はしていない。

7-1 の Logic では、線の高低と、Logic に足した UART の読み下しで字を見た。
AD3 の **Protocol** (プロトコルアナライザ) の UART は、線を読んで**字の並びだけ**を出す。端末 (シリアルモニタ) と同じ使い方になる。

この題では、Pico 2 から 0.5 s ごとに 1 行 `CNT=n` (n は 0〜9 を繰り返す) を送る。
Protocol で字を読み、Logic の読み下し (`logic` の `decode:`) と同じ字かを突き合わせる。
Baud を正しく合わせないと何が見えるかも、シミュレーションで出しておく。

クロックとボーレートは 7-1 と同じ **13 µs (マイクロ秒) と 4800 bps**。

## 送る行

| 字 | `C` | `N` | `T` | `=` | `1` | CR | LF |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 16 進 | 0x43 | 0x4E | 0x54 | 0x3D | 0x31 | 0x0D | 0x0A |

- 数字は `'0'` (0x30) に n を足して作る。n = 1 なら 0x31
- CR (0x0D) と LF (0x0A) は行の終わり。端末はこの 2 字で次の行へ移る

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 の GP15 から字を送り、AD3 の DIO0 (Protocol の RX) で受ける
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/circuit/03-uart-protocol.svg)

- 7-1 と同じ回路。Pico 2 の GP15 が送る線 (TXD)、AD3 の DIO0 が受ける側
- Protocol の UART は RX に DIO0 を選ぶ。AD3 からは何も出さない (TX の DIO は使わない)

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 7-1 と同じ。GP15 を AD3 の DIO0、GND を GND につなぐ
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/breadboard/03-uart-protocol.svg)

- 7-1 と同じ配線。GP15 (24 列) に DIO0 の黄、GND (22 列) に黒
- 信号は 4800 bps で、ブレッドボードの範囲 (3 MHz 以下) に収まる

## Verilog

7-1 の `uart_tx.v` をそのまま使い、送る字を替えた最上位 `count_top.v` を足す。

```verilog
// 0.5 s ごとに "CNT=n\r\n" を送る。n は 0〜9 を繰り返す 1 桁。Pico 2 に載せる最上位
module count_top #(
    parameter CLK_HZ = 76_923,
    parameter BAUD   = 4800
) (
    input  clk,
    input  rst,
    output txd       // GP15
);
    localparam integer HALF = CLK_HZ / 2;                 // 0.5 s のクロック数
    localparam integer W    = $clog2(HALF);
    localparam [2:0]   LEN  = 3'd7;                        // 1 行の字数

    reg [W-1:0] tcnt;
    reg [2:0]   idx;      // 次に送る字の番号。LEN で送り終わり
    reg [3:0]   n;        // 送る数 (0〜9)
    reg         start;
    reg [7:0]   data;
    wire        busy;

    uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_tx (
        .clk(clk), .rst(rst), .data(data), .start(start), .txd(txd), .busy(busy));

    // i 番目の字。数字は '0' (0x30) に n を足して作る
    function [7:0] msg(input [2:0] i, input [3:0] v);
        case (i)
            3'd0:    msg = "C";
            3'd1:    msg = "N";
            3'd2:    msg = "T";
            3'd3:    msg = "=";
            3'd4:    msg = 8'h30 + {4'd0, v};
            3'd5:    msg = 8'h0D;    // \r
            default: msg = 8'h0A;    // \n
        endcase
    endfunction

    always @(posedge clk)
        if (rst) begin
            tcnt  <= {W{1'b0}};
            idx   <= LEN;            // 送らない
            n     <= 4'd0;
            start <= 1'b0;
            data  <= 8'h00;
        end else begin
            start <= 1'b0;
            if (tcnt == HALF[W-1:0] - 1'b1) begin
                tcnt <= {W{1'b0}};
                idx  <= 3'd0;        // 0.5 s ごとに 1 行を送り始める
            end else
                tcnt <= tcnt + 1'b1;

            if (idx != LEN && !busy && !start) begin
                data  <= msg(idx, n);
                start <= 1'b1;
                idx   <= idx + 3'd1;
                if (idx == LEN - 3'd1)            // 行の最後の字を渡したら次の数へ
                    n <= (n == 4'd9) ? 4'd0 : n + 4'd1;
            end
        end
endmodule
```

- `msg` は 7 字の表。5 字目 (`i` = 4) だけ `n` で変わる
- 行の最後の字 (LF) を渡したクロックで `n` を 1 進める。9 の次は 0
- 送り方は 7-1 の `hello_top` と同じ (`busy` が 0 のときに `start` を 1 クロック)

Verilator の lint は警告なしで通る (`verilator --lint-only -Wall --top-module count_top count_top.v uart_tx.v`、確かめた)。

### Pico 2 のピンの割り当て

7-1 と同じ。`clk` は 13 µs ごとのタイマ割り込み (5-7)、`rst` は起動して最初の 1 クロック、`txd` は GP15。

## 動かす — PC のシミュレーション

`count_top` を 13 µs のクロックで 5.6 s 回し、送った字を 3 つの受け手で読む。
受け手はどれも、立ち下がりから 1.5 ビット待って 1 ビットごとに読む (7-1 のテストベンチと同じ)。

- 4800 bps: 正しい設定。行ごとに書く
- 9600 bps と 2400 bps: Protocol の Baud をまちがえたときの代わり。2 行目 (1.0〜1.1 s) に読んだ字を書く

```verilog
`timescale 1ns / 1ps
// count_top を 13 µs のクロックで 5.6 s 回し、送った字を 3 通りの受け手で読む。
// 4800 bps (正しい設定) と、まちがえた 9600 bps・2400 bps (Protocol の Baud をまちがえたとき)
module tb_count;
    reg clk;
    reg rst;
    initial begin
        clk = 1'b0;
        forever #6500 clk = ~clk;
    end
    wire txd;
    count_top dut (.clk(clk), .rst(rst), .txd(txd));

    // まちがえた Baud で 2 行目 (1.0〜1.1 s) に読んだ字を、終わりにまとめて書く
    reg [7:0] got [0:1][0:31];
    reg       bad [0:1][0:31];
    integer   ngot [0:1];
    initial begin ngot[0] = 0; ngot[1] = 0; end

    // 受け手: 立ち下がりから 1.5 ビット待って 1 ビットごとに読む。
    task automatic rx_loop(input real baud);
        real    bit_ns;
        integer b;
        reg [7:0] ch;
        begin
            bit_ns = 1.0e9 / baud;
            forever begin
                @(negedge txd);
                #(bit_ns * 1.5);
                for (b = 0; b < 8; b = b + 1) begin ch[b] = txd; #(bit_ns); end
                if (baud == 4800.0) begin
                    if (ch >= 8'h20 && ch < 8'h7F) $write("%c", ch);
                    else                            $write("<%02h>", ch);
                    if (ch == 8'h0A) $write("   (%7.3f s)\n", $realtime / 1.0e9);
                end else if ($realtime > 1.0e9 && $realtime < 1.1e9) begin
                    got[baud == 9600.0 ? 0 : 1][ngot[baud == 9600.0 ? 0 : 1]] = ch;
                    bad[baud == 9600.0 ? 0 : 1][ngot[baud == 9600.0 ? 0 : 1]] = !txd;
                    ngot[baud == 9600.0 ? 0 : 1] = ngot[baud == 9600.0 ? 0 : 1] + 1;
                end
            end
        end
    endtask

    initial rx_loop(4800.0);
    initial rx_loop(9600.0);
    initial rx_loop(2400.0);

    integer j, k;
    initial begin
        rst = 1'b1;
        #26000 rst = 1'b0;
        #5600000000.0;
        for (k = 0; k < 2; k = k + 1) begin
            $write("%s bps で読んだ 2 行目:", k == 0 ? "9600" : "2400");
            for (j = 0; j < ngot[k]; j = j + 1)
                $write(" %02h%s", got[k][j], bad[k][j] ? "!" : "");
            $write("   (! はストップビットが 0)\n");
        end
        $finish;
    end
endmodule
```

```bash
verilator --binary --timing --top-module tb_count tb_count.v count_top.v uart_tx.v
./obj_dir/Vtb_count
```

```text
CNT=0<0d><0a>   (  0.515 s)
CNT=1<0d><0a>   (  1.015 s)
CNT=2<0d><0a>   (  1.515 s)
CNT=3<0d><0a>   (  2.015 s)
CNT=4<0d><0a>   (  2.515 s)
CNT=5<0d><0a>   (  3.015 s)
CNT=6<0d><0a>   (  3.515 s)
CNT=7<0d><0a>   (  4.015 s)
CNT=8<0d><0a>   (  4.515 s)
CNT=9<0d><0a>   (  5.015 s)
CNT=0<0d><0a>   (  5.515 s)
9600 bps で読んだ 2 行目: 1e! 86  98  60! 66! fe  98  e0  98  1e! 98  80    (! はストップビットが 0)
2400 bps で読んだ 2 行目: 6c! cf! 4a! f8    (! はストップビットが 0)
```

- 4800 bps では、0.5 s ごとに `CNT=0`〜`CNT=9` が順に読め、10 行目の次は `CNT=0` に戻った (Verilator 5.042 で実行)。時刻は行の最後の LF を読み終えた時刻
- 9600 bps で読むと、7 字の行が 12 字になり、`!` (ストップビットが 0) が 4 字に付いた。1 ビットを半分の長さで読むので、1 字の中に 2 字ぶん見つける
- 2400 bps で読むと 4 字になり、3 字に `!` が付いた。1 字を読む間に次の字が来てしまう
- どちらも、読めた字の値は送った `CNT=1` と 1 字も合わない

Protocol の画面で、字がでたらめに見えたり、行が来ないのに字が出たりしたら、Baud を疑う。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Protocol | UART。RX = DIO0、Baud = 4800、Bits = 8、Parity = None、Stop = 1 (8N1)。Receive を押して受け続ける。表示は Text (字) と Hex (16 進) を切り替えて見る |
| Logic | DIO0 を Enable。UART の読み下しを 2 つ足す (どちらも DIO0・4800 bps・8N1。1 つは ASCII、もう 1 つは 16 進)。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 (Logic) | 2 ms/div (10 目盛で 20 ms。1 行 7 字の 14.7 ms が入る)。標本化 1 MS/s |
| トリガ (Logic) | DIO0 の立ち下がり。トリガの前を 2 ms 見せる |

Protocol の UART の項目の名前と、Logic と同時に動かす使い方は、02-analog-discovery の 7-3 と 7-6
(`02-analog-discovery/07-logic/03-uart-pico.md`・`02-analog-discovery/07-logic/06-uart-echo.md`) と同じ。

## Protocol に見えるはずの字

0.5 s ごとに 1 行ずつ増える。Text の表示では次のように並ぶ (シミュレーションで読んだ字を写した)。

```text
CNT=0
CNT=1
CNT=2
CNT=3
```

Hex の表示では、1 行が `43 4E 54 3D 31 0D 0A` のように 7 バイトになる (n = 1 の行)。

## Logic に見えるはずの画面

シミュレーションの 2 行目 (`CNT=1`) の変わり目の時刻を写した。行の最初の立ち下がりを 0 s とした。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 1 行 "CNT=1" と CR LF。1 字は 2.106 ms ごと
device: ad3
time: 2ms/div
start: -2ms
sample: 1MHz
signals:
  TXD: dio0 edges -2ms=1 0us=0 208us=1 624us=0 1456us=1 1664us=0 1872us=1 2106us=0 2522us=1 3146us=0 3562us=1 3770us=0 3978us=1 4212us=0 4836us=1 5044us=0 5252us=1 5460us=0 5668us=1 5876us=0 6084us=1 6318us=0 6526us=1 6734us=0 6942us=1 7774us=0 8190us=1 8424us=0 8632us=1 8840us=0 9464us=1 9880us=0 10296us=1 10530us=0 10738us=1 10946us=0 11154us=1 11570us=0 12402us=1 12636us=0 13052us=1 13260us=0 13468us=1 13676us=0 14508us=1
decode:
  ASCII: uart TXD baud 4800 8N1 ascii
  HEX: uart TXD baud 4800 8N1 hex
cursors: [104us, 2210us]
trigger: TXD falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/logic/03-uart-protocol.svg)

- 上の読み下しは ASCII、下は 16 進。`C` = 0x43、`N` = 0x4E、…、CR = 0x0D、LF = 0x0A
- X1 (104 µs) と X2 (2.210 ms) は、1 字目と 2 字目のスタートビットの真ん中。ΔX = 2.106 ms が 1 字の間隔で、1/ΔX = 474.8 Hz は 1 秒に送れる字の数 (474.8 字/s)
- 1 字の間隔 2.106 ms は、10 ビット (2.080 ms) に字と字のすき間 26 µs (2 クロック) を足した長さ (7-1)
- Protocol の字の並びと、この読み下しの並びが同じなら、Protocol の設定 (Baud・8N1・RX の DIO) が合っている

## 見るべき値

シミュレーションの値と計算値。実機では測っていない。Protocol の表示と Logic の読み下しを見て、表に書き加える。

| 見る所 | シミュレーション・計算値 | 実機 (測って書く) |
| --- | --- | --- |
| Protocol の Text の表示 | 0.5 s ごとに `CNT=0`〜`CNT=9` が 1 行ずつ | |
| 1 行の Hex (n = 1) | 43 4E 54 3D 31 0D 0A | |
| 1 字の間隔 | 2.106 ms (図3の ΔX) | |
| 1 行 (7 字) の長さ | 14.716 ms (計算値。6 × 2.106 + 2.080) | |
| 1 秒に送れる字の数 | 474.8 字/s (1/ΔX)。4800 bps ÷ 10 ビット = 480 字/s より少し少ない (すき間の分) | |
| Baud を 9600 にしたとき | 1 行が 12 字に化け、4 字がストップビットの誤り (シミュレーション) | |
| Baud を 2400 にしたとき | 1 行が 4 字に化け、3 字がストップビットの誤り (シミュレーション) | |

Protocol がストップビットの誤りをどう表示するか (印や色) は、WaveForms の画面で確かめて書く。

## シミュレーションでの確かめ

Verilator 5.042 で、本文の `count_top.v` と `tb_count.v` を取り出し、7-1 の `uart_tx.v` と合わせて走らせ直した。
置き場は `sim/03-uart-protocol.v` と `sim/03-uart-protocol-tb.v` (送信は `sim/01-uart-tx.v`)。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`-Wall`、`count_top` を最上位) | 警告 0 件 | 0 件 | 合った |
| 4800 bps で読んだ行 | `CNT=0`〜`CNT=9` と戻って `CNT=0`、0.515 s から 0.5 s 間隔 | 同じ 11 行 (0.515 … 5.515 s) | 合った |
| 9600 bps で読んだ 2 行目 | 12 字、`!` が 4 字 | 同じ字の並び | 合った |
| 2400 bps で読んだ 2 行目 | 4 字、`!` が 3 字 | 同じ字の並び | 合った |
| 図3 の変わり目 (`C` の部分) | 208・624・1456・1664・1872 µs、2 字目は 2106 µs から | 0x43 の下位から並べて同じ | 合った |

AD3 の Protocol の画面は、実機が要るので確かめていない。

## 出典

自作。AD3 の Protocol の使い方は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)。
文字の値は ASCII の表 (0x30 が `0`、0x41 が `A`)。
