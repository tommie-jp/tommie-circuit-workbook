---
book: fpga
chapter: 7
id: 7-18
title: SPI のマスタを Pico 2 に載せる — 74HC595 の LED と AD3 で見る
tier: 100
source: 自作
board: BB
device: PICO
---

# 7-18 SPI のマスタを Pico 2 に載せる — 74HC595 の LED と AD3 で見る

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 への書き込みと、74HC595・AD3 での測定はしていない。
> 「見るべき値」は 7-4 のシミュレーションの値と計算値。

7-4 の SPI のマスタ (`spi_master.v` と最上位の `spi_top.v`) を Pico 2 の Soft-FPGA に載せ、74HC595 へ 0.5 秒ごとに
0x5A と 0xA5 を交互に送る。LED の QA〜QD が交互に光り、AD3 の Logic で SCK・MOSI・MISO・CS の 4 本を見る。
SPI の決まり、74HC595 を SPI のスレーブにするつなぎ方、Verilog は 7-4 にある (ここには載せない)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GP2 から GP5 を 74HC595 につなぎ、AD3 の DIO0 から DIO3 で読む
parts:
  MCU: pico2 3,7 mirror
  MISO: port 6.5,4.6
  SCK: port 6.5,5
  CS: port 6.5,5.4
  MOSI: port 6.5,5.8
  U1: ic 14,7 74HC595
  MOSI: port 10.5,6.5
  SCK: port 10.5,7
  CS: port 10.5,7.5
  MISO: port 17,9
  V1: vcc 14,3 3.3V
  G1: ground 14,12
  RD: resistor 19,6.5 19,8 330
  DD: led 19,8 19,9.5 red
  GD: ground 19,9.5
  RC: resistor 21.5,6 21.5,7.5 330
  DC: led 21.5,7.5 21.5,9 red
  GC: ground 21.5,9
  RB: resistor 24,5.5 24,7 330
  DB: led 24,7 24,8.5 red
  GB: ground 24,8.5
  RA: resistor 26.5,5 26.5,6.5 330
  DA: led 26.5,6.5 26.5,8 red
  GA: ground 26.5,8
  AD:
    type: device
    at: 24,12
    label: AD3
    pins: [DIO0, DIO1, DIO2, DIO3, GND]
  SCK: port 22.5,11.17
  MOSI: port 22.5,11.58
  MISO: port 22.5,12
  CS: port 22.5,12.42
  G2: ground 22.5,13.4
wires:
  - MCU.GP2 |- 6.5,4.6
  - MCU.GP3 |- 6.5,5
  - MCU.GP4 |- 6.5,5.4
  - MCU.GP5 |- 6.5,5.8
  - U1.SER |- 10.5,6.5
  - U1.SRCLK |- 10.5,7
  - U1.RCLK |- 10.5,7.5
  - U1.QH' |- 17,9
  - U1.VCC |- 14,3
  - U1.SRCLR |- 14.5,3
  - 14,3 -- 14.5,3
  - U1.GND |- 14,11
  - U1.OE |- 14.5,11
  - 14.5,11 -- 14,11 -- 14,12
  - U1.QA -| 26.5,5
  - U1.QB -| 24,5.5
  - U1.QC -| 21.5,6
  - U1.QD -| 19,6.5
  - AD.DIO0 |- 22.5,11.17
  - AD.DIO1 |- 22.5,11.58
  - AD.DIO2 |- 22.5,12
  - AD.DIO3 |- 22.5,12.42
  - AD.GND |- 22.5,12.83 -- 22.5,13.4
style:
  pitch: 1.2
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/circuit/18-spi-master-pico.svg)

- 同じ名前の端子 (白丸と名前) どうしがつながっている (6-2 と同じ描き方)。MISO は 74HC595 の QH' から Pico 2 の GP2 へ戻る線
- 74HC595 の SRCLR (10 番) は +3.3 V に固定してクリアしない。OE (13 番) は GND に固定して出力を常に出す (10-6 と同じ)
- LED は QA〜QD の 4 本。QE〜QH は開けておく。LED は出力が 1 (3.3 V) のとき光る
- AD3 は DIO0〜DIO3 で 4 本を読むだけ。何も出さない。電源は Pico 2 の USB で、74HC595 も 3.3 V (0-3)

## 部品

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Raspberry Pi Pico 2 | 1 | Soft-FPGA を動かす。USB から給電 |
| U2 | 74HC595 (SN74HC595N など。16 ピン DIP) | 1 | SPI のスレーブ |
| D1〜D4 | 5 mm LED 赤 | 4 | QA〜QD の表示 |
| R1〜R4 | 330 Ω (E24)、1/4 W | 4 | LED の電流を決める |
| — | ブレッドボード (full、63 列) | 1 | |
| — | ジャンパ線 | 約 15 本 | |
| AD | Analog Discovery 3 | 1 | Logic で 4 本を測る |

- 電源は教科書の既定の 5 V ではなく **3.3 V**。Pico 2 のピンに 5 V を入れないため (0-3)。74HC595 はデータシートの電源電圧の範囲が 2 V〜6 V なので 3.3 V で動く
- LED の電流は (3.3 V − 2.0 V) ÷ 330 Ω ≈ 3.9 mA (計算値。赤 LED の順電圧を 2.0 V と置いた)。74HC595 の出力電流の規格 (±6 mA) は 5 V のときの値なので、
  3.3 V でこれ以下に収まる見込みだが、保証値は表になく実機で確かめる
- Pico 2 の出力 (VOH 最小 2.62 V、IOVDD = 3.3 V) が 74HC595 の入力 (VIH は 2 V で 1.5 V、4.5 V で 3.15 V = VCC の 0.7 倍。3.3 V では 2.3 V 前後と見積もる) を超える。
  QH' の出力は VCC = 3.3 V 近くまで上がり、Pico 2 の入力 (VIH 最小 2 V) に入れてよい

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 Pico 2 の GP2 から GP5 を 74HC595 につなぎ、AD3 の DIO0 から DIO3 で読む
board: full
parts:
  MCU: pico2 @ h5
  U1: dip16 @ e30 r180 74HC595
  RA: resistor j42 -b42 330
  DA: led h40(A) h42(K) red i=3.9mA
  RB: resistor a42 -t42 330
  DB: led d40(A) d42(K) red i=3.9mA
  RC: resistor a46 -t46 330
  DC: led d44(A) d46(K) red i=3.9mA
  RD: resistor a50 -t50 330
  DD: led d48(A) d50(K) red i=3.9mA
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO2, DIO0, DIO3, DIO1, GND]
wires:
  - a9 -- +t9 red
  - +t63 -- +b63 red
  - -t63 -- -b63 black
  - a7 -- -t7 black
  - j8 -- i30 blue [v12, h10, v88, h400, v-110]
  - j9 -- i32 green [v12, h10, v80, h360, v-122]
  - j10 -- h33 orange [v12, h10, v72, h320, v-134]
  - j11 -- g35 yellow [v12, h10, v64, h280, v-146]
  - j37 -- +b37 red
  - j31 -- +b31 red
  - j34 -- -b34 black
  - a30 -- -t30 black
  - g36 -- g40 purple
  - a37 -- a40 purple
  - b36 -- b44 purple
  - c35 -- c48 purple
  - AD.DIO2 -- j30 blue
  - AD.DIO0 -- j32 green
  - AD.DIO3 -- j33 orange
  - AD.DIO1 -- j35 yellow
  - AD.GND -- -b39 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/breadboard/18-spi-master-pico.svg)

- Pico 2 は USB を左に向けて `@ h5` に挿す (0-4 と同じ)。下の列 (h 行) の 4 番 GP2 が 8 列、5 番 GP3 が 9 列、6 番 GP4 が 10 列、7 番 GP5 が 11 列。上の列 (c 行) の 36 番 3V3 が 9 列、38 番 GND が 7 列
- 74HC595 は溝をまたぎ、切り欠きを右にして `@ e30 r180` に挿す。下の列 (f 行) に 9 番 QH' (30 列)・10 番 SRCLR (31 列)・11 番 SRCLK (32 列)・12 番 RCLK (33 列)・13 番 OE (34 列)・14 番 SER (35 列)・15 番 QA (36 列)・16 番 VCC (37 列)、
  上の列 (e 行) に 8 番 GND (30 列) から 1 番 QB (37 列)
- 信号の線 (Pico 2 の下の列から 74HC595 の下の列へ): GP2 → QH' は青、GP3 → SRCLK は緑、GP4 → RCLK は橙、GP5 → SER は黄。
  線は Pico 2 の j 行から板の下へ出て、25〜28 列の右から下の段へ上がり、行の間を右へ入る (`i30`・`i32`・`h33`・`g35`)。
  AD3 の線も同じ色で、74HC595 側の同じ列の j 行 (`j30`・`j32`・`j33`・`j35`) に挿す。AD3 の GND は下の − レールの 39 列へ
- 電源: 3V3 (9 列) から上の + レールへ赤。74HC595 の VCC (37 列) と SRCLR (31 列) は下の + レールへ赤で短く。GND は Pico 2 の 38 番 (7 列) と 74HC595 の 8 番 (30 列) を上の − レールへ、OE (34 列) を下の − レールへ黒。上下のレールは右端 (63 列) でつなぐ
- LED は 4 個とも、長いほう (アノード) を左にして挿す。QA (36 列) は g 行の紫の線で 40 列の LED (h 行) へ。QB (37 列) は a 行、QC (36 列) は b 行、QD (35 列) は c 行の紫の線で、上の列の 40・44・48 列の LED (d 行) へ。
  カソードの列から 330 Ω を − レールへ立てる (QA は下の − レール、QB〜QD は上の − レール)
- 流れる電流は LED 4 個で 16 mA 以下 (計算値)。信号は 19 kHz で、ブレッドボードの範囲 (3 MHz 以下) に収まる

## Pico 2 のピンの割り当て

組み方は 5-3 と 5-7 (手本は [Soft-FPGA-TD4](https://github.com/tommie-jp/Soft-FPGA-TD4) の `verilator-TD4/main.cpp`)。

| Verilog | Pico 2 | 向き | 設定 |
| --- | --- | --- | --- |
| `clk` | (ピンなし) | — | **13 µs ごと**のタイマ割り込みで 0 → 1 と変えて評価する (5-7) |
| `rst` | (ピンなし) | — | 起動して最初の 1 クロックだけ 1 |
| `miso` | GP2 | 入力 | プルアップなし (74HC595 が 0 と 1 を出す) |
| `sck` | GP3 | 出力 | 起動直後は 0 |
| `cs_n` | GP4 | 出力 | 起動直後は 1 |
| `mosi` | GP5 | 出力 | |
| `ok` | GP25 | 出力 | Pico 2 の基板の LED |

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 = SCK、DIO1 = MOSI、DIO2 = MISO、DIO3 = CS を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 | 50 µs/div (10 目盛で 500 µs。1 回の送りが 429 µs)。標本化 1 MS/s (SCK の 1 周期に 52 標本) |
| トリガ | DIO3 (CS) の立ち下がり。トリガの前を 50 µs 見せる |
| Protocol | SPI。Select = DIO3、Clock = DIO0、Data (MOSI) = DIO1、Data (MISO) = DIO2。モード 0 (CPOL = 0、CPHA = 0)、MSB 先、8 ビット。操作の手順は Digilent の [Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer) |

## Logic に見えるはずの画面

7-4 のシミュレーション (`edge` の行) の変わり目の時刻をそのまま写した (2 回目の送り。CS の立ち下がりを 0 s とした)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 2 回目の送り。MOSI は 0xA5、MISO は 1 つ前の 0x5A
device: ad3
time: 50us/div
start: -50us
sample: 1MHz
signals:
  SCK:  dio0 edges -50us=0 26us=1 52us=0 78us=1 104us=0 130us=1 156us=0 182us=1 208us=0 234us=1 260us=0 286us=1 312us=0 338us=1 364us=0 390us=1 416us=0
  MOSI: dio1 edges -50us=0 0s=1 52us=0 104us=1 156us=0 260us=1 312us=0 364us=1
  MISO: dio2 edges -50us=0 26us=1 78us=0 130us=1 234us=0 286us=1 338us=0 390us=1
  CS:   dio3 edges -50us=1 0s=0 429us=1
cursors: [25us, 389us]
trigger: CS falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/07-serial/logic/18-spi-master-pico.svg)

- 0 s で CS が 0 に下がり、MOSI は 0xA5 の最上位ビット 1 を出す。SCK は 26 µs 後に最初の立ち上がり
- 0xA5 = 1010 0101 は上位ビットから送るので、SCK の立ち上がりごとの MOSI は 1・0・1・0・0・1・0・1
- MISO は SCK の立ち上がりのたびに変わる。立ち上がりの直前の値を並べると 0・1・0・1・1・0・1・0 = 0x5A。1 つ前に送った字
- X1 (25 µs) は最初の立ち上がりの直前で、MOSI = 1・MISO = 0。X2 (389 µs) は 8 回目の立ち上がりの直前で、MOSI = 1 (最下位ビット)・MISO = 0 (0x5A の最下位ビット)
- 429 µs で CS が 1 に戻る。この立ち上がりで 74HC595 の出力 QA〜QH に 0xA5 が写る
- 74HC595 の遅れ (標準 13 ns) は、この目盛では見えない。シミュレーションの図では SCK と MISO が同じ時刻に変わる

## 見るべき値

7-4 のシミュレーションの値と計算値。実機では測っていない。Logic のカーソルで読み、表に書き加える。

| 見る所 | シミュレーション・計算値 | 実機 (測って書く) |
| --- | --- | --- |
| SCK の周期 | 52 µs (4 クロック × 13 µs) | |
| SCK の周波数 | 19.23 kHz (計算値) | |
| 1 回の送りで CS が 0 の長さ | 429 µs | |
| SCK の立ち上がりの数 | 8 | |
| MOSI | 0x5A と 0xA5 を交互に | |
| MISO | 1 つ前に送った字 (2 回目以降) | |
| QA〜QD の LED | 0x5A のとき 0・1・0・1、0xA5 のとき 1・0・1・0 | |
| LED の電流 | 約 3.9 mA (計算値) | |
| GP25 (ok) | 2 回目の送りの後から 1 | |
| Protocol の SPI の読み下し | MOSI 0xA5、MISO 0x5A | |

実機でぶつかりやすいのは、SCK のモードの取り違え (モード 0 のつもりで AD3 をモード 1 にすると 1 ビットずれた値になる) と、
GND の共通を忘れること。

## シミュレーションでの確かめ

Verilator 5.042 で、7-4 の `sim/04-spi-master.v` `sim/04-spi-master-top.v` `sim/04-spi-master-tb.v` を走らせ、`edge` の行と図3 を突き合わせた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| 図3 (2 回目の送りの SCK・MOSI・MISO・CS) | 26 µs 刻みの変わり目 | 同じ時刻・同じ値 | 合った |

74HC595 の遅れや LED の電流は実機が要るので確かめていない。

## 出典

自作。74HC595 の機能・ピン・電圧の範囲・クロックの上限・標準の遅れは Texas Instruments
[SN54HC595, SN74HC595 データシート (SCLS041J、2021-10)](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf) の表から読んだ。
Pico 2 (RP2350) の入出力電圧は
[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) の 14.9.4 (IOVDD = 3.3 V の VIH・VOH) による。
SPI の語は一般に使われるもの。AD3 の Protocol の使い方は Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)。
74HC595 を LED につなぐ回路は 01-circuits/10-logic/06-shift-register.md。
