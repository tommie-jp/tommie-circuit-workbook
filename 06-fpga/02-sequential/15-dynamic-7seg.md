---
book: fpga
chapter: 2
id: 2-15
title: 7 セグのダイナミック点灯
tier: 200
source: 自作
board: BB
device: PICO
---

# 2-15 7 セグのダイナミック点灯

> [!WARNING]
> **この題は実機で組んでいない。** Verilog は Verilator の lint を通し、PC のシミュレーションで 1 万秒ぶん (1 000 万クロック) を回して自分で合否を言う試験を通した。
> Pico 2 のプログラムは `.uf2` までのビルドを確かめたが、書き込んで動かしてはいない。7 セグの点灯、AD3 での測定、ゴーストの見え方は確かめていない。
> 「見るべき値」は設計値・シミュレーションの値・計算値で、測った値ではない。

4 桁を別々に光らせるには 8 本 × 4 桁 = 32 本の線が要る。4 桁の 7 セグ OSL40562-LR は 4 桁のセグメント (a〜g・dp) が中でつながっていて、
外に出ているのはセグメント 8 本と桁ごとの共通のカソード 4 本 (DIG1〜DIG4) の 12 本だけである。
そこで **1 度に 1 桁だけを光らせ、光らせる桁を速く順に替える** (ダイナミック点灯)。目は速い点滅を平均するので、4 桁が同時に点いて見える。

Pico 2 の Soft-FPGA で、2-9 の 10 進カウンタを 4 桁に伸ばした 0000〜9999 を出す。クロックは 5-7 のタイマで **1 kHz に固定**し、
**1 クロックごとに光らせる桁を 1 つずらす**。1 つの桁は 4 ms に 1 回、1 ms だけ光る (250 Hz、デューティ 1/4)。
12-4 の時計 ([06-fpga/12-projects/04-clock.md](../12-projects/04-clock.md)) も同じ方式・同じ回路。ゴーストとその対策は 2-20 に分けた。

| 決め | 内容 | 理由 |
| --- | --- | --- |
| クロック | 1 kHz (5-7 の繰り返しタイマ、半周期 500 µs) | Soft-FPGA のクロックは固定しないと回路の規模で変わる (5-6)。1 秒も桁の切り替えもクロックの数で決める |
| 桁の切り替え | 1 クロック (1 ms) ごとに 1 桁ずらす。DIG1 → DIG2 → DIG3 → DIG4 → DIG1 | 1 つの桁は 250 Hz。ちらつきが見えるのは数十 Hz より遅いとき |
| 見せる数 | 0000〜9999 を 1 秒ごとに数える。9999 の次は 0000 | 2-9 の `bcd_digit` を 4 つつなぐ。どの桁にも別の数字が出る |
| 7 セグ | OSL40562-LR (0.56 インチ 4 桁、カソード共通、赤) | 12-4 と同じ |
| 桁の共通 (カソード) | NPN トランジスタ 2SC1815 で GND へ落とす。ベース抵抗 1 kΩ | 1 桁に最大 8 セグメントぶんの電流が集まるので、Pico 2 のピン 1 本で受けない (12-4 と同じ) |
| セグメントの抵抗 | 220 Ω | 3.3 V で 1 本 4〜6 mA (見積り)。12-4 と同じ |
| ピンへの書き込み | 12 本を `gpio_put_masked` の 1 回で書く | セグメントと桁が同じ瞬間に変わる (ずれるとゴースト。2-20) |
| 電源 | Pico 2 の USB から | 7 セグは Pico 2 の GPIO の 3.3 V で光らせる。電源レールは GND だけ |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 の 12 本のピンから抵抗とトランジスタを通して 4 桁の 7 セグを光らせる
parts:
  U1: pico2 5,6
  SA: port 3.5,6.5
  SF: port 3.5,7
  SB: port 3.5,7.25
  DRV3: port 3.5,7.5
  DRV4: port 3.5,7.75
  DRV2: port 3.5,8.25
  DRV1: port 3.5,8.5
  SG: port 6.5,7
  SC: port 6.5,7.25
  SDP: port 6.5,7.5
  SD: port 6.5,7.75
  SE: port 6.5,8.25
  G0: ground 7,9
  DS1: seg7x4 16,6 OSL40562-LR
  SA: port 11,1.6
  R1: resistor 11,1.6 12.5,1.6 220
  SB: port 11,2.3
  R2: resistor 11,2.3 12.5,2.3 220
  SC: port 11,3
  R3: resistor 11,3 12.5,3 220
  SD: port 11,3.7
  R4: resistor 11,3.7 12.5,3.7 220
  SE: port 11,4.4
  R5: resistor 11,4.4 12.5,4.4 220
  SF: port 11,5.1
  R6: resistor 11,5.1 12.5,5.1 220
  SG: port 11,5.8
  R7: resistor 11,5.8 12.5,5.8 220
  SDP: port 11,6.5
  R8: resistor 11,6.5 12.5,6.5 220
  DIG1: port 14.5,6.63
  DIG2: port 14.5,6.88
  DIG3: port 14.5,7.13
  DIG4: port 14.5,7.38
  DRV1: port 7.1,10.5
  R9: resistor 7.1,10.5 8.6,10.5 1k
  Q1: npn 9.5,10.5 2SC1815
  DIG1: port 9.5,9.5
  G1: ground 9.5,11.5
  DRV2: port 10.6,10.5
  R10: resistor 10.6,10.5 12.1,10.5 1k
  Q2: npn 13,10.5 2SC1815
  DIG2: port 13,9.5
  G2: ground 13,11.5
  DRV3: port 14.1,10.5
  R11: resistor 14.1,10.5 15.6,10.5 1k
  Q3: npn 16.5,10.5 2SC1815
  DIG3: port 16.5,9.5
  G3: ground 16.5,11.5
  DRV4: port 17.6,10.5
  R12: resistor 17.6,10.5 19.1,10.5 1k
  Q4: npn 20,10.5 2SC1815
  DIG4: port 20,9.5
  G4: ground 20,11.5
  AD:
    type: device
    at: 1,2
    label: AD3
    pins: [DIO0, DIO1, DIO2, DIO3, DIO4, DIO5, GND]
    turn: mirror
  DRV1: port 2.5,1.25
  DRV2: port 2.5,1.5
  DRV3: port 2.5,1.75
  DRV4: port 2.5,2
  SA: port 2.5,2.25
  SF: port 2.5,2.5
  G5: ground 2.5,3.1
wires:
  - U1.GP9 -- 3.5,6.5
  - U1.GP10 -- 3.5,7
  - U1.GP11 -- 3.5,7.25
  - U1.GP12 -- 3.5,7.5
  - U1.GP13 -- 3.5,7.75
  - U1.GP14 -- 3.5,8.25
  - U1.GP15 -- 3.5,8.5
  - U1.GP21 -- 6.5,7
  - U1.GP20 -- 6.5,7.25
  - U1.GP19 -- 6.5,7.5
  - U1.GP18 -- 6.5,7.75
  - U1.GP17 -- 6.5,8.25
  - U1.GND23 -- 7,8 -- 7,9
  - 12.5,1.6 -- 14.8,1.6 -- 14.8,4.63 -| DS1.a
  - 12.5,2.3 -- 14.6,2.3 -- 14.6,4.88 -| DS1.b
  - 12.5,3 -- 14.4,3 -- 14.4,5.13 -| DS1.c
  - 12.5,3.7 -- 14.2,3.7 -- 14.2,5.38 -| DS1.d
  - 12.5,4.4 -- 14,4.4 -- 14,5.63 -| DS1.e
  - 12.5,5.1 -- 13.8,5.1 -- 13.8,5.88 -| DS1.f
  - 12.5,5.8 -- 13.6,5.8 -- 13.6,6.13 -| DS1.g
  - 12.5,6.5 -- 13.4,6.5 -- 13.4,6.38 -| DS1.dp
  - 14.5,6.63 -| DS1.DIG1
  - 14.5,6.88 -| DS1.DIG2
  - 14.5,7.13 -| DS1.DIG3
  - 14.5,7.38 -| DS1.DIG4
  - 8.6,10.5 -- Q1.B
  - 9.5,9.5 -- Q1.C
  - Q1.E -- 9.5,11.5
  - 12.1,10.5 -- Q2.B
  - 13,9.5 -- Q2.C
  - Q2.E -- 13,11.5
  - 15.6,10.5 -- Q3.B
  - 16.5,9.5 -- Q3.C
  - Q3.E -- 16.5,11.5
  - 19.1,10.5 -- Q4.B
  - 20,9.5 -- Q4.C
  - Q4.E -- 20,11.5
  - AD.DIO0 |- 2.5,1.25
  - AD.DIO1 |- 2.5,1.5
  - AD.DIO2 |- 2.5,1.75
  - AD.DIO3 |- 2.5,2
  - AD.DIO4 |- 2.5,2.25
  - AD.DIO5 |- 2.5,2.5
  - AD.GND |- 2.5,2.75 -- 2.5,3.1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/circuit/15-dynamic-7seg.svg)

- セグメント (a〜g・dp) は 4 桁で共通のアノード。光らせたい桁の DIGk だけをトランジスタで GND へ落とす
- `DRV1`〜`DRV4` は Verilog の `dig[3]`〜`dig[0]`。1 にした桁のカソードが GND になる
- **同じ名前の端子 (白丸と名前) どうしがつながっている**。U1 の 12 番ピン (GP9) の `SA` は R1 の左の `SA` とつながる
- ピンはブレッドボードの線が交わりにくい順に割り当てたので、GP の番号と a〜g の順がそろっていない (下の「Pico 2 のピン」)
- AD3 は DIO0〜DIO3 で `DRV1`〜`DRV4`、DIO4 と DIO5 でセグメント a と f を読む
- 点 (dp) の線もつなぐ。この題では点けない (12-4 では秒の点に使う)

## 部品

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | 1 | Soft-FPGA を動かす。USB から給電 |
| DS1 | OSL40562-LR (0.56 インチ 4 桁 7 セグ、カソード共通、赤) | 1 | 表示 |
| R1〜R8 | 220 Ω (E24)、1/4 W | 8 | セグメント a〜g・dp の電流を決める |
| Q1〜Q4 | 2SC1815 (NPN) | 4 | DIG1〜DIG4 のカソードを GND へ落とす |
| R9〜R12 | 1 kΩ (E24)、1/4 W | 4 | トランジスタのベースの電流を決める |
| — | ブレッドボード (full、63 列) | 1 | |
| — | ジャンパ線 | 約 40 本 | |
| AD | Analog Discovery 3 | 1 | Logic で測る |

電源は既定の 5 V でなく **3.3 V** (Pico 2 の GPIO。5 V を入れると壊れる。0-3)。

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 1 枚のブレッドボードに組む。電源は USB から Pico 2 へ
board: full
parts:
  U1: pico2 @ g2
  R2: resistor e28 f28 220 cap=left
  Q3: transistor f29(B) e30(C) f30(E) 2SC1815
  R11: resistor j29 j27 1k
  Q2: transistor f31(E) e32(C) f32(B) 2SC1815
  R10: resistor g32 g33 1k shift=up cap=left
  R6: resistor e34 f34 220 cap=left
  R1: resistor e35 f35 220 cap=below
  Q1: transistor f36(E) e37(C) f37(B) 2SC1815
  R9: resistor h37 h38 1k
  R7: resistor e39 f39 220 cap=below:0.5,0
  R3: resistor e40 f40 220 cap=above:0.5,-0.5
  R8: resistor e41 f41 220 cap=above:0,0.5
  R4: resistor e42 f42 220 cap=above:1,-0.5
  R5: resistor e43 f43 220 cap=right
  DS1: seg7x4 @ b52
  Q4: transistor h58(E) h59(C) h60(B) 2SC1815 cap=left:0,-1
  R12: resistor g60 g63 1k
  AD:
    type: device
    at: bottom
    label: AD3
    pins: [DIO4, DIO5, DIO2, DIO1, DIO0, GND, DIO3]
wires:
  - a20 -- a22 yellow
  - a19 -- a23 black [v-8]
  - a18 -- a24 orange [v-13]
  - a17 -- a25 brown [v-18]
  - a16 -- a26 orange [v-23]
  - a15 -- a27 brown [v-28]
  - e23 -- f23 black
  - b22 -- b43 yellow [v-10, h420]
  - c24 -- c42 orange [v-10, h360]
  - b25 -- b41 brown [h320]
  - c26 -- c40 orange [h280]
  - d27 -- d39 brown [h240]
  - a28 -- a57 yellow [v-28]
  - a30 -- a56 white [v-23]
  - a32 -- a55 white [v-18]
  - a34 -- a54 gray [v-13]
  - a35 -- a53 yellow [v-8]
  - a37 -- a52 white
  - h13 -- h35 yellow [v10, h440]
  - h15 -- h34 gray
  - i16 -- i28 yellow [v10, h240]
  - i17 -- i27 blue
  - j18 -- i63 blue [v24, h230, v-34, h670]
  - j20 -- i33 blue [v12, h170, v-32, h90]
  - j21 -- j22 blue
  - g22 -- g38 blue [v10, h320]
  - g23 -- g30 black
  - j30 -- -b30 black
  - j31 -- -b31 black
  - j36 -- -b36 black
  - g43 -- g52 orange
  - g42 -- g53 brown [v10, h220]
  - h41 -- h54 orange
  - h40 -- h55 yellow [v10, h300]
  - i39 -- h56 gray [h340]
  - i59 -- i57 white
  - j58 -- -b58 black
  - AD.DIO4 -- j13 orange
  - AD.DIO5 -- j15 gray
  - AD.DIO2 -- j17 green
  - AD.DIO1 -- j33 green
  - AD.DIO0 -- j38 green
  - AD.GND -- -b45 black
  - AD.DIO3 -- j63 green
notes:
  - text: 給電は Pico 2 の USB (5 V)。ピンは 3.3 V。電源レールは GND (−) だけ使う
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/breadboard/15-dynamic-7seg.svg)

- Pico 2 は USB を左に向け、溝をまたいで挿す (`@ g2`)。1〜20 番が下の列、40〜21 番が上の列で、上は a 行、下は h〜j 行から線を取る
- 7 セグ (DS1) も溝をまたぐ (`@ b52`)。胴が左右へ 7 列ずつはみ出すので、上のピンは a 行、下のピンは g〜j 行から取る
- セグメントの抵抗 (39〜43 列) は溝をまたいで縦に挿す
- Pico 2 の GND (23 番ピン) はセグメントの線にはさまれているので、黒い弧で 23 列へ渡して下の段へ降ろす。エミッタは Q1〜Q4 とも下の − レールへ
- Q1〜Q3 はコレクタだけを上の段 (e 行) に挿す。7 セグの上のピンへは a 行の上の入れ子の弧で渡す
- 線の色: 黒は GND だけ。青は Pico 2 → ベース抵抗、白はコレクタ → DIG、黄・灰・橙・茶はセグメント、AD3 の桁 (DIO0〜DIO3) は緑。赤と上のレールは使わない
- AD3 は DIO4・DIO5・DIO2 を Pico 2 の下の列に、DIO1・DIO0・DIO3 をベース抵抗の入り口に (どれも j 行)。GND は下の − レールへ
- 電流は 1 本で最大 50 mA 前後 (コレクタ)、全体で 0.1 A 以下 (見積り)。信号は 1 kHz 以下で範囲 (3 MHz 以下) に収まる

### Pico 2 のピン

| Verilog | Pico 2 | ネット | 行き先 |
| --- | --- | --- | --- |
| `seg[0]` (a) | GP9 (12 番) | SA | R1 → DS1 の a |
| `seg[1]` (b) | GP11 (15 番) | SB | R2 → b |
| `seg[2]` (c) | GP20 (26 番) | SC | R3 → c |
| `seg[3]` (d) | GP18 (24 番) | SD | R4 → d |
| `seg[4]` (e) | GP17 (22 番) | SE | R5 → e |
| `seg[5]` (f) | GP10 (14 番) | SF | R6 → f |
| `seg[6]` (g) | GP21 (27 番) | SG | R7 → g |
| `seg[7]` (dp) | GP19 (25 番) | SDP | R8 → dp |
| `dig[3]` | GP15 (20 番) | DRV1 | R9 → Q1 → DIG1 (左端) |
| `dig[2]` | GP14 (19 番) | DRV2 | R10 → Q2 → DIG2 |
| `dig[1]` | GP12 (16 番) | DRV3 | R11 → Q3 → DIG3 |
| `dig[0]` | GP13 (17 番) | DRV4 | R12 → Q4 → DIG4 (右端) |
| `clk` `rst` | (ピンなし) | — | タイマ割り込みで回す (5-7)。リセットは起動の直後の 1 クロック |

## Verilog

モジュールは 4 つ (1 ファイル 1 モジュール)。3 つは前の題のものをそのまま使う。

| ファイル | 中身 | どこから |
| --- | --- | --- |
| `tick.v` | `CLK_HZ` を数えて、`TICK_HZ` の速さで 1 クロックだけ `en` を 1 にする | 12-4 |
| `bcd_digit.v` | 10 進の 1 桁。9 の次に 0 へ戻って `carry` を出す | 2-9 |
| `seg7.v` | 0〜9 を a〜g に直す (1 が点灯、`{g, f, e, d, c, b, a}`) | 2-9 |
| `dyn7seg.v` | この題の本体 | 下に載せる |

`dyn7seg.v`:

```verilog
// dyn7seg.v — 4 桁の 10 進カウンタを、1 クロックに 1 桁ずつ順に光らせる
module dyn7seg #(
    parameter CLK_HZ = 1000,     // 5-7 のタイマで決めた 1 kHz
    parameter BLANK  = 0         // 1: 桁を替える前に 1 クロックだけ全部消す (ゴースト対策)
) (
    input         clk,
    input         rst,
    output [7:0]  seg,           // {dp, g, f, e, d, c, b, a}。1 で点灯
    output [3:0]  dig,           // 1 の桁だけ光る。dig[3] が左端 (DIG1)
    output [15:0] value          // 4 桁の BCD {千, 百, 十, 一}。試験で見る
);
    // 1 秒に 1 クロックだけ 1 になる合図 (2-5・2-7)
    wire en_sec;
    tick #(.CLK_HZ(CLK_HZ), .TICK_HZ(1)) t_sec (.clk(clk), .rst(rst), .en(en_sec));

    // 0000〜9999 を数える。下の桁の carry を上の桁の en に (2-9)
    wire [3:0] d0, d1, d2, d3;
    wire       c0, c1, c2;

    bcd_digit u0 (.clk(clk), .rst(rst), .en(en_sec), .q(d0), .carry(c0));
    bcd_digit u1 (.clk(clk), .rst(rst), .en(c0),     .q(d1), .carry(c1));
    bcd_digit u2 (.clk(clk), .rst(rst), .en(c1),     .q(d2), .carry(c2));
    /* verilator lint_off PINCONNECTEMPTY */    // 9999 の次は 0000。千の位の carry は使わない
    bcd_digit u3 (.clk(clk), .rst(rst), .en(c2),     .q(d3), .carry());
    /* verilator lint_on PINCONNECTEMPTY */

    // 光らせる桁の番号 pos (0 が左端)。BLANK = 1 なら、光らせた次の 1 クロックは dark で全部消す
    reg [1:0] pos;
    reg       dark;

    always @(posedge clk)
        if (rst) begin
            pos  <= 2'd0;
            dark <= 1'b0;
        end else if (BLANK == 0) begin
            pos  <= pos + 2'd1;             // 1 クロックごとに次の桁へ
        end else begin
            dark <= ~dark;                  // 光る・消すを 1 クロックずつ
            if (!dark) pos <= pos + 2'd1;   // 消している間に次の桁へ進めておく
        end

    // pos の桁の数を選んで a〜g に直す
    reg [3:0] shown;
    always @(*)
        case (pos)
            2'd0:    shown = d3;
            2'd1:    shown = d2;
            2'd2:    shown = d1;
            default: shown = d0;
        endcase

    wire [6:0] abc;
    seg7 dec (.d(shown), .seg(abc));

    assign seg   = dark ? 8'd0 : {1'b0, abc};          // 点 (dp) は使わない
    assign dig   = dark ? 4'd0 : (4'b1000 >> pos);
    assign value = {d3, d2, d1, d0};
endmodule
```

- 下の桁の `carry` を上の桁の `en` につなぐ (2-9 の 2 桁を 4 桁に)。一の位の `en` は 1 秒に 1 回の `en_sec`
- `pos` は光らせる桁の番号 (0 が左端の DIG1)。`BLANK = 0` では 1 クロックごとに 1 進み、3 の次は 0 (2 ビットなので自然に戻る)
- `shown` (`pos` の桁の数) を `seg7` で a〜g に直して `seg` に出す。`dig` は `pos` の桁だけ 1
- `seg` と `dig` はどちらも `pos` (と `dark`) だけから決まるので、**同じクロックの端で一緒に変わる**
- `BLANK = 1` はゴーストの対策 (2-20)。本題 (12-4 の時計と同じ動き) は `BLANK = 0`
- `value` は 4 桁の BCD を試験で見る出口 (ピンには出さない)

lint は `BLANK = 0` と `BLANK = 1` のどちらも警告 0 件 (Verilator 5.042)。

```bash
verilator --lint-only -Wall --top-module dyn7seg dyn7seg.v tick.v bcd_digit.v seg7.v
verilator --lint-only -Wall -GBLANK=1 --top-module dyn7seg dyn7seg.v tick.v bcd_digit.v seg7.v
```

## 動かす — PC のシミュレーション

`CLK_HZ` を 1000 にして 1 クロックを 1 ms とみなし、消さない版 (`u`、`BLANK = 0`) と消す版 (`b`、`BLANK = 1`) を並べて回す。
`check` が合否を言い (3-3)、毎クロック、光っている桁の模様が `seg` に出ているかも数える。

```verilog
// CLK_HZ = 1000 (1 クロック = 1 ms) で、消さない版 (u) と消す版 (b) を並べて回す
module tb_dyn7seg;
    reg clk = 0;
    reg rst = 1;
    wire [7:0]  seg,   seg_b;
    wire [3:0]  dig,   dig_b;
    wire [15:0] value, value_b;
    integer errors = 0;

    dyn7seg #(.CLK_HZ(1000), .BLANK(0)) u (.clk(clk), .rst(rst), .seg(seg),   .dig(dig),   .value(value));
    dyn7seg #(.CLK_HZ(1000), .BLANK(1)) b (.clk(clk), .rst(rst), .seg(seg_b), .dig(dig_b), .value(value_b));

    always #1 clk = ~clk;                    // 1 周期 = 2 時間単位 = 1 ms とみなす

    task ms(input integer n);
        repeat (n) @(posedge clk);
    endtask

    task check(input ok, input [8*28-1:0] what);
        if (!ok) begin
            $display("NG %0s", what);
            errors = errors + 1;
        end else
            $display("ok %0s", what);
    endtask

    // 0〜9 の a〜g (2-9 の seg7 と同じ表)
    function [7:0] pat(input [3:0] n);
        case (n)
            4'd0: pat = 8'h3f;  4'd1: pat = 8'h06;  4'd2: pat = 8'h5b;  4'd3: pat = 8'h4f;
            4'd4: pat = 8'h66;  4'd5: pat = 8'h6d;  4'd6: pat = 8'h7d;  4'd7: pat = 8'h07;
            4'd8: pat = 8'h7f;  4'd9: pat = 8'h6f;  default: pat = 8'h00;
        endcase
    endfunction

    // 今 dig で光っている桁の数の模様が seg に出ているか
    function shows_right(input [3:0] dg, input [7:0] sg, input [15:0] v);
        case (dg)
            4'b1000: shows_right = (sg == pat(v[15:12]));
            4'b0100: shows_right = (sg == pat(v[11:8]));
            4'b0010: shows_right = (sg == pat(v[7:4]));
            4'b0001: shows_right = (sg == pat(v[3:0]));
            4'b0000: shows_right = (sg == 8'h00);       // 消している間は seg も 0
            default: shows_right = 1'b0;                // 2 桁が同時に光ってはいけない
        endcase
    endfunction

    // 走らせている間、毎クロックの終わりに確かめる
    integer bad = 0, bad_b = 0;
    always @(negedge clk) if (!rst) begin
        if (!shows_right(dig,   seg,   value))   bad   = bad + 1;
        if (!shows_right(dig_b, seg_b, value_b)) bad_b = bad_b + 1;
    end

    // n クロックのうち、各桁が光ったクロックの数
    integer on1, on2, on3, on4, on1b, on2b, on3b, on4b, k;
    task count_on(input integer n);
        begin
            on1 = 0; on2 = 0; on3 = 0; on4 = 0; on1b = 0; on2b = 0; on3b = 0; on4b = 0;
            for (k = 0; k < n; k = k + 1) begin
                @(negedge clk);
                if (dig[3])   on1  = on1  + 1;
                if (dig[2])   on2  = on2  + 1;
                if (dig[1])   on3  = on3  + 1;
                if (dig[0])   on4  = on4  + 1;
                if (dig_b[3]) on1b = on1b + 1;
                if (dig_b[2]) on2b = on2b + 1;
                if (dig_b[1]) on3b = on3b + 1;
                if (dig_b[0]) on4b = on4b + 1;
            end
        end
    endtask

    reg [3:0] d_seq [0:7];
    reg [3:0] b_seq [0:7];
    integer i;
    initial begin
        ms(3); @(negedge clk); rst = 0;   // クロックの立ち下がりで放す

        // 放した所から 8 クロックの桁の並び
        for (i = 0; i < 8; i = i + 1) begin
            d_seq[i] = dig; b_seq[i] = dig_b;
            @(negedge clk);
        end
        $display("dig   : %b %b %b %b %b %b %b %b", d_seq[0], d_seq[1], d_seq[2], d_seq[3], d_seq[4], d_seq[5], d_seq[6], d_seq[7]);
        $display("dig_b : %b %b %b %b %b %b %b %b", b_seq[0], b_seq[1], b_seq[2], b_seq[3], b_seq[4], b_seq[5], b_seq[6], b_seq[7]);
        check(d_seq[0] == 4'b1000 && d_seq[1] == 4'b0100 && d_seq[2] == 4'b0010 && d_seq[3] == 4'b0001
              && d_seq[4] == 4'b1000, "1 clock per digit");
        check(b_seq[0] == 4'b1000 && b_seq[1] == 4'b0000 && b_seq[2] == 4'b0100 && b_seq[3] == 4'b0000
              && b_seq[4] == 4'b0010 && b_seq[6] == 4'b0001, "blank between digits");

        // 4000 クロック (4 s) で、各桁が光ったクロックの数
        count_on(4000);
        $display("on (BLANK=0): %0d %0d %0d %0d of 4000", on1, on2, on3, on4);
        $display("on (BLANK=1): %0d %0d %0d %0d of 4000", on1b, on2b, on3b, on4b);
        check(on1 == 1000 && on2 == 1000 && on3 == 1000 && on4 == 1000, "duty 1/4");
        check(on1b == 500 && on2b == 500 && on3b == 500 && on4b == 500, "duty 1/8 with blank");

        // 数える値: リセットを放してから 1 s ごとに 1
        // 放してから 8 + 4000 = 4008 ms。215.5 s まで進めて 0215
        ms(215_500 - 4008);
        $display("value at 215.5 s: %h / %h", value, value_b);
        check(value == 16'h0215 && value_b == 16'h0215, "count 0215");

        ms(1000 * 9784);                 // 9999.5 s
        $display("value at 9999.5 s: %h", value);
        check(value == 16'h9999, "count 9999");
        ms(1000);                        // 10000.5 s
        $display("value at 10000.5 s: %h", value);
        check(value == 16'h0000, "wrap to 0000");

        $display("wrong pattern clocks: %0d / %0d", bad, bad_b);
        check(bad == 0 && bad_b == 0, "seg matches dig");

        if (errors == 0) $display("PASS");
        else             $display("FAIL: %0d", errors);
        $finish;
    end
endmodule
```

```bash
verilator --binary --timing --top-module tb_dyn7seg tb_dyn7seg.v dyn7seg.v tick.v bcd_digit.v seg7.v
./obj_dir/Vtb_dyn7seg
```

```text
dig   : 1000 0100 0010 0001 1000 0100 0010 0001
dig_b : 1000 0000 0100 0000 0010 0000 0001 0000
ok 1 clock per digit
ok blank between digits
on (BLANK=0): 1000 1000 1000 1000 of 4000
on (BLANK=1): 500 500 500 500 of 4000
ok duty 1/4
ok duty 1/8 with blank
value at 215.5 s: 0215 / 0215
ok count 0215
value at 9999.5 s: 9999
ok count 9999
value at 10000.5 s: 0000
ok wrap to 0000
wrong pattern clocks: 0 / 0
ok seg matches dig
PASS
```

全部 ok で `PASS` (Verilator 5.042。1 万秒 = 1 000 万クロックが手元の PC で約 2 秒)。

- `dig` の行: 1 クロックごとに DIG1 → DIG2 → DIG3 → DIG4 とずれ、4 クロックで 1 周する。`dig_b` (消す版) は 2-20
- `on` の行: 4000 クロックのうち各桁は 1000 クロック (1/4) 光る。消す版は 500 クロック (1/8)
- 215.5 s で `0215`、9999.5 s で `9999`、その 1 秒後に `0000` に戻る
- `wrong pattern clocks` は、光っている桁に違う模様が出たか 2 桁が同時に光ったクロックの数。どちらの版も 0

## Pico 2 のプログラム

プログラムは C++ (Pico SDK)。Verilator の出す C++ を呼ぶので MicroPython では書かない (5-1)。
組み方は 5-7 と同じで、500 µs ごとの割り込みで立ち上がりと立ち下がりを交互に計算する。ピンの割り当てが 5-5〜5-8 と違うので、`board.h` を使わずピンの表を書いた。

### 作業用のフォルダに置くもの

| ファイル | 中身 | どこから |
| --- | --- | --- |
| `dyn7seg.v` `tick.v` `bcd_digit.v` `seg7.v` | 回路 | 上の「Verilog」 |
| `seg215.cpp` | 主ループと割り込み | 下に載せる |
| `seg215b.cpp` | 消す版 (2-20) を組む 2 行 | 下に載せる |
| `verilate.sh` | Verilog を C++ にする手順 | 下に載せる |
| `CMakeLists.txt` | ビルドの設定 | 5-1 のもの。最後の行を下の 2 行に替える |
| `pico_tls.cpp` `stub_mutex.h` `cxx_minimal.cpp` `verilated.cpp` | Verilator のランタイムの部品 | 5-1 と同じ |

`seg215.cpp`:

```cpp
// 2-15 7 セグのダイナミック点灯 — 5-7 のタイマで 1 kHz に固定して、1 クロックに 1 桁ずつ光らせる
#include "pico/stdlib.h"
#ifdef USE_BLANK
#include "Vdyn7seg_blank.h"
using Model = Vdyn7seg_blank;       // 桁の間に 1 クロック消す版 (seg215b.cpp)
#else
#include "Vdyn7seg.h"
using Model = Vdyn7seg;
#endif

constexpr int64_t HALF_US = 500;    // 半周期 500 µs → クロック 1 kHz (5-7)

// seg[0]〜seg[7] (a b c d e f g dp) を出すピン
constexpr uint SEG_PIN[8] = {9, 11, 20, 18, 17, 10, 21, 19};
// dig[0]〜dig[3] を出すピン (DRV4 DRV3 DRV2 DRV1)。dig[3] が DIG1 (左端)
constexpr uint DIG_PIN[4] = {13, 12, 14, 15};

static Model top;
static unsigned g_clk = 0;
static uint32_t g_mask = 0;          // 12 本のピンの印

// seg と dig を、12 本のピンの値にまとめる
static uint32_t to_pins(unsigned seg, unsigned dig) {
    uint32_t v = 0;
    for (int i = 0; i < 8; i++) if ((seg >> i) & 1u) v |= 1u << SEG_PIN[i];
    for (int i = 0; i < 4; i++) if ((dig >> i) & 1u) v |= 1u << DIG_PIN[i];
    return v;
}

static bool on_half(repeating_timer_t*) {
    g_clk ^= 1u;                     // 立ち上がりと立ち下がりを交互に
    top.clk = g_clk;
    top.eval();
    if (g_clk) gpio_put_masked(g_mask, to_pins(top.seg, top.dig));   // 12 本を 1 回で書く
    return true;
}

int main() {
    for (uint p : SEG_PIN) g_mask |= 1u << p;
    for (uint p : DIG_PIN) g_mask |= 1u << p;
    gpio_init_mask(g_mask);
    gpio_set_dir_out_masked(g_mask);
    for (uint p : SEG_PIN) gpio_set_drive_strength(p, GPIO_DRIVE_STRENGTH_8MA);
    for (uint p : DIG_PIN) gpio_set_drive_strength(p, GPIO_DRIVE_STRENGTH_8MA);

    top.rst = 1;                     // 1 クロックだけリセット
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
    top.rst = 0;

    repeating_timer_t timer;
    add_repeating_timer_us(-HALF_US, on_half, nullptr, &timer);   // 負の周期: 呼び始めの間隔 (5-7)

    while (true) tight_loop_contents();
}
```

`seg215b.cpp`:

```cpp
// 2-15 の消す版。seg215.cpp を Vdyn7seg_blank で組む
#define USE_BLANK
#include "seg215.cpp"
```

- 立ち上がりの `eval()` の後に **12 本のピンを `gpio_put_masked` の 1 回で書く**。立ち下がりでは出力が変わらないので書かない
- 駆動の強さは 8 mA (`gpio_set_drive_strength`)。既定の 4 mA では、セグメント 1 本の 4〜6 mA (見積り) で H の電圧が下がる
- 主ループは何もしない (入力が無い)

`verilate.sh`:

```bash
#!/bin/sh
# Verilog を C++ にする (sfa-dev のコンテナの中で打つ)
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc   # ランタイムのヘッダ
V="dyn7seg.v tick.v bcd_digit.v seg7.v"
verilator --cc --no-timing --no-trace -Wall --top-module dyn7seg --prefix Vdyn7seg       -GCLK_HZ=1000           --Mdir v_dyn7seg       $V
verilator --cc --no-timing --no-trace -Wall --top-module dyn7seg --prefix Vdyn7seg_blank -GCLK_HZ=1000 -GBLANK=1 --Mdir v_dyn7seg_blank $V
```

`CMakeLists.txt` の最後の行 (`add_soft_fpga(blink_pico …)`) を次の 2 行に替える。

```cmake
add_soft_fpga(seg215  seg215.cpp  dyn7seg)
add_soft_fpga(seg215b seg215b.cpp dyn7seg_blank)
```

打つ物は [5-1 の「ビルドする」](../05-soft-fpga-pico/01-verilator-on-pico.md#ビルドする)の 2 行のまま。

空のフォルダから 5-1 の手順でビルドし、`build/seg215.uf2` と `build/seg215b.uf2` (どちらも 95 744 バイト) ができた
(Verilator 5.048 の `sfa-dev:local`、Pico SDK 2.2.0 の `wb-pico-sdk`。`verilate.sh` の lint も警告なし)。`arm-none-eabi-size` で text 51 576 バイト。
**実機では動かしていない。** `.uf2` を書く手順は 0-2 と同じ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0〜DIO3 を `DRV1`〜`DRV4` (ベース抵抗の手前)、DIO4 をセグメント a (`SA`)、DIO5 を f (`SF`) につなぐ。DIO は 3.3 V。GND を共通にする (0-4) |
| 桁の切り替え (図3) | 時間軸 1 ms/div (窓 10 ms)、標本化 100 kHz。トリガは DIO0 (`DRV1`) の立ち上がり。カーソルは 0.5 ms と 4.5 ms (DIG1 の H の真ん中) |

標本化は、見る一番速い変化 (桁の切り替えの 1 ms) の 4 倍よりずっと速くした。

## Logic に見えるはずの画面

リセットから 215 s 後、`0215` を出している所 (設計値と上の試験の値)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 4 つの桁を 1 ms ずつ順に光らせる。a と f は光っている桁の数字 (0215) で変わる
device: ad3
time: 1ms/div
start: -1ms
sample: 100kHz
signals:
  DRV1: dio0 pattern 01000100010 bit 1ms from -1ms
  DRV2: dio1 pattern 00100010001 bit 1ms from -1ms
  DRV3: dio2 pattern 00010001000 bit 1ms from -1ms
  DRV4: dio3 pattern 10001000100 bit 1ms from -1ms
  SA: dio4 pattern 11101110111 bit 1ms from -1ms
  SF: dio5 pattern 11001100110 bit 1ms from -1ms
cursors: [0.5ms, 4.5ms]
trigger: DRV1 rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/02-sequential/logic/15-dynamic-7seg.svg)

- 1 つの桁は 4 ms に 1 回、1 ms だけ光る (デューティ 1/4)。カーソルの間隔 4 ms が周期で、1/ΔX = 250 Hz
- `DRV1`〜`DRV4` は、どの瞬間も 1 本だけが H
- `SA` と `SF` は光っている桁の数字で決まる。DIG1 の `0` は a・f とも 1、DIG2 の `2` は a だけ 1、DIG3 の `1` はどちらも 0、DIG4 の `5` はどちらも 1
- `SA` `SF` の変わり目は `DRV` の変わり目と同じ時刻。ずれるとゴーストが出る (2-20)

## 見るべき値

設計値・シミュレーションの値・計算値。実機では測っていない。

| 項目 | 値 | どこで得たか |
| --- | --- | --- |
| クロック | 1.000 kHz (半周期 500 µs) | 設計値 (5-7 のタイマ) |
| 桁の切り替えの間隔 | 1 クロック = 1 ms | 試験の `dig` の行 |
| 1 つの桁が光る周期 | 4 ms (250 Hz)、デューティ 1/4 | 試験の `on` の行、図3 のカーソル |
| 2 桁が同時に光るクロック | 0 | 試験の `wrong pattern clocks` |
| 光っている桁と違う模様のクロック | 0 | 同上 |
| 215.5 s の表示 | `0215` | 試験 |
| 9999 の次 | `0000` (10 000 s 後) | 試験 |
| セグメント 1 本の電流 (光っている間) | 4〜6 mA (見積り) | 下の計算 |
| 1 桁に集まる電流 (8 本とも光る「8.」) | 30〜50 mA (見積り) | 同上 |
| 2SC1815 のベース電流 | 約 2.6 mA (見積り) | (3.3 − 0.75) / 1 kΩ |

セグメントの電流は 12-4 と同じく (ピンの H − LED の順電圧 − 飽和電圧) / 220 Ω で見積もった。H の電圧は 8 mA の駆動で 2.9〜3.3 V (見積り。RP2350 の資料で確かめていない)、順電圧は OSL40562-LR の表で 1.8〜2.3 V (20 mA のとき。5 mA では低い)、飽和電圧は 0.1 V ほど。
(2.9 − 1.9 − 0.1) / 220 = 4.1 mA、(3.3 − 1.9 − 0.1) / 220 = 5.9 mA。実機では 220 Ω の両端の電圧を測って書く。

- 1 つの桁は 1/4 の時間しか光らないので、5 mA でも平均は 1.5 mA ほど。暗ければ 220 Ω を 150 Ω にする (6〜9 mA。表の最大 20 mA の内側)
- 「8.」が光る間、Pico 2 のピンからはセグメント 8 本とベース 1 本で約 45 mA (見積り) が出る。RP2350 の GPIO 全体の電流の上限は未確認で、組む前に Raspberry Pi の資料で確かめる
- 1 桁の 30〜50 mA は 2SC1815 のコレクタ電流の最大 150 mA の内側。ベース電流 2.6 mA の約 18 倍までで、hFE の最小 70 より十分小さいので飽和する

確かめていないこと: Pico 2 での点灯、`.uf2` が割り込みの 500 µs に間に合うか (計算にかかる時間は 5-7 の BUSY の幅で測る)。

## シミュレーションでの確かめ

道具は Verilator 5.042。回路は `sim/15-dynamic-7seg.v`、テストベンチは `sim/15-dynamic-7seg-tb.v` に置いた。`tick.v` は 12-4、`bcd_digit.v` と `seg7.v` は 2-9 のもの。`.uf2` はこの環境では組み直していない。図 3 (と 2-20 の図1) のパターンは `sim/15-dynamic-7seg-fig-tb.v` で 215.5 s 後の `dig` と `seg` を読み出して突き合わせた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| lint (`BLANK` = 0 と 1) | 警告 0 件 | 2 通りとも警告 0 件 | 合った |
| 試験の結果 | 全部 ok で `PASS` | 同じ。1 万秒 (1 000 万クロック) が約 2.1 秒 | 合った |
| `dig` の並び | 1000 0100 0010 0001 … | 同じ | 合った |
| 消す版の `dig_b` | 1000 0000 0100 0000 … | 同じ | 合った |
| 光ったクロックの数 | 1000 (消さない版)、500 (消す版) | 同じ | 合った |
| 値 | 215.5 s で 0215、9999.5 s で 9999、10000.5 s で 0000 | 同じ | 合った |
| 図 3 の `DRV4` | `00001000100` | `10001000100`。窓の頭 (-1 ms) は DIG4 の 1 クロックなのに `DRV4` だけ 0 だった。図を直した | 直した |
| 図 3 の `DRV1`〜`DRV3` `SA` `SF` | 0215 の a と f | 一致 (消す版の図は 2-20) | 合った |
| ピンの表と図 1 | GP 番号と DRV・SA〜SG | ネットリスト・ピンの表・`seg215.cpp` が一致 | 合った |

確かめられなかった範囲: `.uf2` の再ビルド (95 744 バイト)、Pico 2 での点灯・割り込みが 500 µs に間に合うか・電流 (実機が要る)。電流の見積り (4.1〜5.9 mA、ベース 2.55 mA) は式を計算し直しただけ。

## 出典

自作。

- 4 桁の 7 セグ・トランジスタ・抵抗の回路と値: 12-4 ([06-fpga/12-projects/04-clock.md](../12-projects/04-clock.md))
- 10 進カウンタと 7 セグのデコーダ: 2-9 ([06-fpga/02-sequential/09-decimal-counter.md](09-decimal-counter.md))
- クロックを固定する繰り返しタイマ: 5-7 ([06-fpga/05-soft-fpga-pico/07-clock-timer.md](../05-soft-fpga-pico/07-clock-timer.md))。Pico SDK の `pico_time` (`add_repeating_timer_us`) と `hardware_gpio` (`gpio_put_masked`・`gpio_set_drive_strength`)
- OSL40562-LR のピン配置と順電圧: OptoSupply のデータシート (秋月電子通商 [https://akizukidenshi.com/goodsaffix/OSL40562-LR.pdf](https://akizukidenshi.com/goodsaffix/OSL40562-LR.pdf))
- 2SC1815 の最大定格と hFE: 東芝のデータシート
