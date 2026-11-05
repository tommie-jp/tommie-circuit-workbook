---
book: analog-discovery
chapter: 7
id: 7-11
title: 74HC595 を叩いて 7 セグを点ける
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Protocol の SPI の節)
board: BB
---

# 7-11 74HC595 を叩いて 7 セグを点ける

回路の教科書の 10-6 ではボタンで、11-6 では Pico 2 の SPI で 74HC595 にビットを送った。ここでは**マイコンを使わず、
AD3 の Protocol の SPI (マスタ) から 1 バイトを送る**。回路は 11-6 と同じで、Pico 2 の代わりに AD3 の DIO 3 本と Supplies をつなぐ。
新しいのは、**SPI の Select の線を 74HC595 のラッチ (RCLK) に使う**ことと、送った線を同じ AD3 の Logic で見て
「1 バイト = 8 クロック + ラッチ 1 回」を確かめること。ソフトを書く前に、表示の基板だけを単独で確かめる道具にもなる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 AD3 の Protocol (SPI) で 74HC595 に 1 バイト送り、7 セグを点ける
parts:
  AD:
    type: device
    at: 3,4.5
    label: Analog Discovery 3
    pins: [V+, DIO0, DIO1, DIO2, GND]
    turn: mirror
  V33: vcc 5.5,1.5 3.3V
  G4: ground 5.5,7.5
  U2: ic 9,5 74HC595
  V33: vcc 9,1 3.3V
  C1: capacitor 7.5,1.5 7.5,2.5 100n
  G0: ground 7.5,2.5
  G1: ground 9,7.75
  G2: ground 9.5,7.75
  Ra: resistor 11,3 12.5,3 l=$R_a$
  Rb: resistor 11,3.5 12.5,3.5 l=$R_b$
  Rc: resistor 11,4 12.5,4 l=$R_c$
  Rd: resistor 11,4.5 12.5,4.5 l=$R_d$
  Re: resistor 11,5 12.5,5 l=$R_e$
  Rf: resistor 11,5.5 12.5,5.5 l=$R_f$
  Rg: resistor 11,6 12.5,6 l=$R_g$
  DS1:
    type: device
    at: 17,5
    label: 5161AS
    pins: [e, g, f, a, b, c, d, COM]
  G3: ground 15.5,7
wires:
  - AD.V+ -| 5.5,1.5
  - AD.GND -| 5.5,7.5
  - U2.QA -| 11,3
  - U2.QB -| 11,3.5
  - U2.QC -| 11,4
  - U2.QD -| 11,4.5
  - U2.QE -| 11,5
  - U2.QF -| 11,5.5
  - U2.QG -| 11,6
  - 12.5,3 -- 15.25,3 -- 15.25,4.25 -- DS1.e
  - 12.5,3.5 -- 15,3.5 -- 15,4.5 -- DS1.g
  - 12.5,4 -- 14.75,4 -- 14.75,4.75 -- DS1.f
  - 12.5,4.5 -- 14.5,4.5 -- 14.5,5 -- DS1.a
  - 12.5,5 -- 14.25,5 -- 14.25,5.25 -- DS1.b
  - 12.5,5.5 -- DS1.c
  - 12.5,6 -- 14.25,6 -- 14.25,5.75 -- DS1.d
  - DS1.COM -| 15.5,7
  - U2.VCC |- 9,1.5
  - 9,1.5 -- 9,1
  - 7.5,1.5 -- 9,1.5
  - U2.SRCLR |- 9.5,1.5
  - 9,1.5 -- 9.5,1.5
  - U2.GND |- 9,7.75
  - U2.OE |- 9.5,7.75
  - AD.DIO0 -| 7,4.5
  - U2.SER -| 7,4.5
  - AD.DIO1 -| 6.5,5
  - U2.SRCLK -| 6.5,5
  - AD.DIO2 -| 6,5.5
  - U2.RCLK -| 6,5.5
notes:
  - text 11.75,6.6: Ra-Rg はどれも 470Ω
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/11-shift-register-7seg.svg)

- DIO0 = SER (14 番、データ)、DIO1 = SRCLK (11 番、シフトクロック)、DIO2 = RCLK (12 番、ラッチ)。Protocol の SPI の
  DQ0 (MOSI)・Clock・Select に当たる。Select は送る間だけ L になり、最後に H へ戻る。この**立ち上がりで 8 ビットが出力に写る**
- 電源は Supplies の V+ を 3.3 V にする。DIO の H は 3.3 V なので、74HC595 も 3.3 V で動かせば入力の H の下限
  (0.7 × V<sub>CC</sub> = 2.31 V) を確実に超える。5 V で動かすと下限は 3.5 V になり、3.3 V の H は届かない (7-15)
- OE (13 番) は GND、SRCLR (10 番) は 3.3 V に固定。C1 (0.1 µF (マイクロファラド)) は電源のデカップリング
- 7 セグはカソードコモンの 5161AS。セグメントの割り当ては 11-6 と同じ (QA = e、QB = g、QC = f、QD = a、QE = b、QF = c、QG = d。
  ブレッドボードで配線が短くなる順)。抵抗は 470 Ω (オーム) を 1 本ずつ

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (74HC595 は向きを逆に挿す。電源と信号は AD3 から)
board: full
parts:
  U1: dip16 @ e30 r180 74HC595
  C1: capacitor i34 i37 100n
  DS1: seg7 @ e44
  Re: resistor a34 a48 470 cap=above
  Rd: resistor b35 b47 470 cap=left
  Rc: resistor c36 c45 470 cap=left
  Rb: resistor d37 d44 470 cap=left
  Ra: resistor j36 j44 470
  Rg: resistor e51 f51 470
  Rf: resistor e52 f52 470
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, DIO2, DIO1, DIO0]
wires:
  - AD.V+ -- +b20 red
  - AD.GND -- -b22 black
  - -t62 -- -b62 black
  - +t63 -- +b63 red
  - a30 -- -t30 black
  - j37 -- +b37 red
  - j31 -- +b31 red
  - j34 -- -b34 black
  - AD.DIO0 -- h35 yellow
  - AD.DIO1 -- i32 green
  - AD.DIO2 -- h33 blue
  - a32 -- a51 white
  - a33 -- a52 orange
  - j51 -- j45 white
  - j52 -- j47 orange
  - j46 -- -b46 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/11-shift-register-7seg.svg)

- 部品の置き方は回路の教科書の 11-6 の図2 と同じ。74HC595 (U1) は**切り欠きを右にして** e30 に挿す (`r180`)。
  下の列は左から 9 番 (QH')・SRCLR・SRCLK・RCLK・OE・SER・QA・16 番 (VCC)
- Pico 2 の代わりに AD3 をブレッドボードの下に置く。V+ (赤) を下の + レール、GND (黒) を下の − レールへ。
  DIO1 (緑) を SRCLK の列 (`i32`)、DIO2 (青) を RCLK の列 (`h33`)、DIO0 (黄) を SER の列 (`h35`) へ
- 上下のレールは右端 (62・63 列) でつなぐ。7 セグの下の COM (46 列) を − レールへ
- AD3 のピンの並びは、線が交わらない順にした (実物の並びとは違う)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Protocol | SPI。Select = DIO2 (Active Low)、Clock = DIO1、DQ0 = DIO0。Frequency 1 MHz、Polarity 0・Phase 0 (モード 0)、First bit = MSB。Write で 8 ビット、`0x7A` を送る |
| Logic | Protocol の **Debug with Logic Analyzer** を入れてから DIO0〜DIO2 を表示。Rate 10 MS/s、トリガは DIO2 の立ち下がり |

Protocol は Pattern と Logic の資源を借りて動くので、使っている間 Pattern と Logic は Busy になる。
**Debug with Logic Analyzer** を入れると Logic で線を見られる (その間、Protocol は受信せず送るだけ。この題は送るだけなので困らない)。
見る物はレベルが 0 か 1 かと順序だけなので、オシロではなくロジックの画面にした。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 数字の 3 (0x7A) を送る — CS の立ち上がりが 74HC595 のラッチになる
device: ad3
time: 1us/div
start: -1us
sample: 10MHz
signals:
  CS:   dio2 edges -1us=1 0s=0 8.5us=1
  SCLK: dio1 pattern 01010101010101010 bit 500ns from 0s
  MOSI: dio0 pattern 01111010 bit 1us from 0s
cursors: [1.75us, 5.75us]
trigger: CS falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/11-shift-register-7seg.svg)

図3 は計算で作った理想の画面で、実測ではない。SCLK は 0.5 µs (マイクロ秒)・1.5 µs・…・7.5 µs に 8 回立ち上がり (1 MHz)、
MOSI はその立ち上がりの前に次のビットへ変わっている (モード 0)。立ち上がりで読まれる値は上位から 0・1・1・1・1・0・1・0 (= 0x7A)。
X1 (2 ビット目) は 1、X2 (6 ビット目) は 0。**CS の立ち上がり (8.5 µs) で RCLK が上がり、ここで初めて表示が変わる。**
ヘルプによれば Protocol の SPI の Select はソフトが動かすので、CS とクロックの間の時間は毎回少し違う。図3 の 0.5 µs は形を見せるための値。
ラッチはクロックの後の立ち上がりだけで決まるので、この間隔がずれても表示は変わらない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 (図1 では U2) | シフトレジスタ | 74HC595 (DIP-16、3.3 V で使う) |
| DS1 | 7 セグメント LED | 5161AS (赤・カソードコモン) |
| Ra〜Rg | 抵抗 (1/4 W) | 470 Ω × 7 |
| C1 | セラミックコンデンサ | 0.1 µF (104) |
| — | 電源・信号源・計器 | Analog Discovery 3 (Supplies 3.3 V、Protocol、Logic) |

電流は 1 セグメント約 2.5 mA、数字の 8 (7 本) で約 17 mA (下の LTspice)。Supplies の V+ は 3.3 V × 17 mA ≈ 57 mW で、
USB 給電の 250 mW に収まる。74HC595 の定格 (1 出力 ±35 mA、VCC と GND のピン ±70 mA) にも余裕がある。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| `0x7A` を送った後の表示 | 数字の 3 (a・b・c・d・g) | ビットとセグメントの割り当てが合っている |
| Logic の SCLK の立ち上がりの数 | 1 回の送信で 8 回 | 1 バイト = 8 クロック |
| 1 ビットの長さ | 1 µs (1 MHz) | Protocol の Frequency どおり |
| CS (DIO2) の立ち上がり | 送信ごとに 1 回、8 回目のクロックの後 | ここで RCLK が上がり、表示が切り替わる |
| 送る前と送った後の表示の間 | 途中の値は出ない | シフトとラッチが分かれている (10-6) |
| First bit を LSB にして `0x7A` を送る | 0101 1110 の並びが出て、別の形になる | 先頭のビットは QH へ行く |

0〜9 の値は 11-6 の表と同じ (`0x7D 0x30 0x5B 0x7A 0x36 0x6E 0x6F 0x38 0x7F 0x7E`)。Protocol の Write に順に入れて送れば、1 つずつ表示が変わる。

**点かないときの絞り方**: (1) Supplies の V+ を入れたまま、Static I/O で DIO0〜2 を Switch にして手で 1 ビットずつ送る
(10-6 と同じ手順)。ここで点けば配線は正しく、SPI の設定を疑う。(2) 点かなければ Logic で DIO2 の立ち上がりが来ているか、
(3) 来ていれば 7 セグの COM と抵抗の列を見る。全セグメントが点くなら OE と SRCLR の固定を見る。

## LTspice での確かめ

`sim/11-shift-register-7seg.cir` で、3.3 V の 74HC595 の出力 1 本 → 470 Ω → セグメントを、5 本 (数字の 3) と 7 本 (8) で解いた。
74HC595 の出力は 3.3 V の源と 50 Ω の内部抵抗、電源の線は 5 Ω、LED は回路の教科書の 11-6 と同じ仮定のモデル。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 セグメントの電流 (数字の 3) | 約 2.5 mA | 2.51 mA | 合う |
| 合計 (数字の 3、5 本) | — | 12.5 mA (41 mW) | — |
| 1 セグメントの電流 (数字の 8) | 約 2.5 mA | 2.46 mA (Vf 1.93 V) | 合う |
| 合計 (数字の 8、7 本) | 約 17 mA | 17.3 mA | 合う |
| Supplies の電力 (数字の 8) | 約 57 mW | 57 mW | 合う (250 mW の内) |

SPI の並びは算術で確かめた。0x7A = 0111 1010 を上位から送ると、8 回ずれたあと QA = 0 (e)、QB = 1 (g)、QC = 0 (f)、QD = 1 (a)、
QE = 1 (b)、QF = 1 (c)、QG = 1 (d) で、a・b・c・d・g が点く (数字の 3)。1 MHz の 8 ビットは 8 µs で、図3 の SCLK の変わり目 16 (立ち上がり 8) と合う。

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Protocol の SPI の節、Logic) と Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)。

参考: [Texas Instruments SN74HC595 データシート](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf)、[シフトレジスタ (Wikipedia)](https://ja.wikipedia.org/wiki/シフトレジスタ)
