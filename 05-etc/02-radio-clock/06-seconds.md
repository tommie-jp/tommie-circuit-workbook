---
book: etc
chapter: 2
id: 2-6
title: 秒のカウンタ — 74HC163 を 2 個つないで 00〜59 を数え、分へ桁上げを出す
tier: 200
source: 自作
board: BB
---

# 2-6 秒のカウンタ — 74HC163 を 2 個つないで 00〜59 を数え、分へ桁上げを出す

> [!WARNING]
> **この題は、まだ実際の回路で検証していない。** 回路図・実体配線図・波形・数値は、設計から計算と見積りで作ったもので、組んで測ったものではない。

[05-oscillator.md](05-oscillator.md) (2-5) の 1 秒の TICK を数えて、秒の 00〜59 を作る。
74HC163 (4 ビットの同期カウンタ) を 2 個使い、一の位は 0〜9、十の位は 0〜5 で折り返す。
59 から 00 になるクロックで **ENMU** (分の一の位を進める信号) を出す。分と時のカウンタは同じ形の繰り返しで、
全体は [07-clock.md](07-clock.md) (2-7) で時計になる。この題の新しいことは、**同期カウンタの折り返しと桁上げ**だ。

## 折り返しと桁上げ — すべて LOAD で作る

74HC163 は、LOAD が L のときは、イネーブルに関係なく、クロックの立ち上がりでデータ入力を読み込む。
そこで、折り返し (秒の 59 → 00 など) と、リセット (正時と設定) を、**どちらも LOAD で作る**。データ入力はすべて GND で、読み込むのはいつも 0 だ。

- 折り返し: 「その桁が最大で、イネーブルされている」ときに LOAD を L にして 0 を読み込む。
- リセット (正時と設定): 同じ LOAD を RS (ACC または SET) でも L にする。

この題だけで組むときは RS を GND にする。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 秒のカウンタ (ユニット 2)
parts:
  U21: ic 12,8 74HC163
  GND1: ground 8.4,6.5 r90
  TICK: port 8.4,8.75
  CLK: port 8.4,9.5
  VCC: vcc 11.5,4.6 5V
  LDSU: port 15.6,5.7
  GND2: ground 12,10.6
  SU0: port 15.6,7
  SU1: port 15.6,7.5
  SU2: port 15.6,8
  SU3: port 15.6,8.5
  U22: ic 12,19 74HC163
  GND3: ground 8.4,17.5 r90
  ENST: port 8.4,19.75
  CLK: port 8.4,20.5
  VCC: vcc 11.5,15.6 5V
  LDST: port 15.6,16.7
  GND4: ground 12,21.6
  ST0: port 15.6,18
  ST1: port 15.6,18.5
  ST2: port 15.6,19
  ST3: port 15.6,19.5
  U33A: and 23,6
  SU3: port 19.5,5.25
  SU0: port 19.5,6.75
  SU9: port 26,6
  U33B: and 23,9.4
  SU9: port 19.5,8.65
  TICK: port 19.5,10.15
  ENST: port 26,9.4
  U42A: nor 23,12.8
  RS: port 19.5,12.05
  ENST: port 19.5,13.55
  LDSU: port 26,12.8
  U33C: and 23,17
  ST2: port 19.5,16.25
  ST0: port 19.5,17.75
  ST5: port 26,17
  U33D: and 23,20.4
  ST5: port 19.5,19.65
  ENST: port 19.5,21.15
  ENMU: port 26,20.4
  U42B: nor 23,23.8
  RS: port 19.5,23.05
  ENMU: port 19.5,24.55
  LDST: port 26,23.8
wires:
  - U21.A -| 9.5,6.5
  - U21.B -| 9.5,7
  - U21.C -| 9.5,7.5
  - U21.D -| 9.5,8
  - 9.5,6.5 -- 9.5,7
  - 9.5,7 -- 9.5,7.5
  - 9.5,7.5 -- 9.5,8
  - 9.5,6.5 -- 8.4,6.5
  - U21.ENP -| 9.5,8.5
  - U21.ENT -| 9.5,9
  - 9.5,8.5 -- 9.5,8.75
  - 9.5,8.75 -- 9.5,9
  - 9.5,8.75 -- 8.4,8.75
  - U21.CLK -| 8.4,9.5
  - 11.5,5.2 -| U21.VCC
  - 12,5.2 -| U21.CLR
  - 11.5,5.2 -- 12,5.2
  - 11.5,5.2 -- 11.5,4.6
  - U21.LOAD |- 15.6,5.7
  - 12,10.6 -| U21.GND
  - U21.QA -| 15.6,7
  - U21.QB -| 15.6,7.5
  - U21.QC -| 15.6,8
  - U21.QD -| 15.6,8.5
  - U22.A -| 9.5,17.5
  - U22.B -| 9.5,18
  - U22.C -| 9.5,18.5
  - U22.D -| 9.5,19
  - 9.5,17.5 -- 9.5,18
  - 9.5,18 -- 9.5,18.5
  - 9.5,18.5 -- 9.5,19
  - 9.5,17.5 -- 8.4,17.5
  - U22.ENP -| 9.5,19.5
  - U22.ENT -| 9.5,20
  - 9.5,19.5 -- 9.5,19.75
  - 9.5,19.75 -- 9.5,20
  - 9.5,19.75 -- 8.4,19.75
  - U22.CLK -| 8.4,20.5
  - 11.5,16.2 -| U22.VCC
  - 12,16.2 -| U22.CLR
  - 11.5,16.2 -- 12,16.2
  - 11.5,16.2 -- 11.5,15.6
  - U22.LOAD |- 15.6,16.7
  - 12,21.6 -| U22.GND
  - U22.QA -| 15.6,18
  - U22.QB -| 15.6,18.5
  - U22.QC -| 15.6,19
  - U22.QD -| 15.6,19.5
  - 19.5,5.25 |- U33A.a
  - 19.5,6.75 |- U33A.b
  - U33A.out -- 26,6
  - 19.5,8.65 |- U33B.a
  - 19.5,10.15 |- U33B.b
  - U33B.out -- 26,9.4
  - 19.5,12.05 |- U42A.a
  - 19.5,13.55 |- U42A.b
  - U42A.out -- 26,12.8
  - 19.5,16.25 |- U33C.a
  - 19.5,17.75 |- U33C.b
  - U33C.out -- 26,17
  - 19.5,19.65 |- U33D.a
  - 19.5,21.15 |- U33D.b
  - U33D.out -- 26,20.4
  - 19.5,23.05 |- U42B.a
  - 19.5,24.55 |- U42B.b
  - U42B.out -- 26,23.8
notes:
  - text 13.5,4.1 small left: U21 74HC163 (秒の一の位)
  - text 13.5,15.1 small left: U22 74HC163 (秒の十の位)
  - text 21.9,5.4 tiny center: "1"
  - text 21.9,6.6 tiny center: "2"
  - text 23.7,5.6 tiny center: "3"
  - text 21.9,8.8 tiny center: "4"
  - text 21.9,10 tiny center: "5"
  - text 23.7,9 tiny center: "6"
  - text 21.9,12.2 tiny center: "2"
  - text 21.9,13.4 tiny center: "3"
  - text 23.7,12.4 tiny center: "1"
  - text 21.9,16.4 tiny center: "9"
  - text 21.9,17.6 tiny center: "10"
  - text 23.7,16.6 tiny center: "8"
  - text 21.9,19.8 tiny center: "12"
  - text 21.9,21 tiny center: "13"
  - text 23.7,20 tiny center: "11"
  - text 21.9,23.2 tiny center: "5"
  - text 21.9,24.4 tiny center: "6"
  - text 23.7,23.4 tiny center: "4"
  - text 3,27.5 small left: 74HC08・74HC02 は PIN 14 が +5V、PIN 7 が GND
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/06-seconds.svg)

- U33A は秒の一の位が 9 (SU3 かつ SU0)。U33B は、9 で TICK が来たとき (ENST) で、十の位を 1 つ進める。同時に、U42A が一の位に 0 を読み込ませる (LDSU が L)。
- U33C は十の位が 5。U33D は、5 で ENST が来たとき (ENMU) で、分の一の位を 1 つ進める。U42B が十の位に 0 を読み込ませる。
- 一の位は TICK で数える。十の位は ENST で、データ入力はどちらも GND。
- **RS は 2-7 の窓判定から来る** (正時と設定で秒を 00 に戻す)。この題だけで組むときは、RS を GND につなぐ。

## 実体配線図

ブレッドボードの周波数は 8 Hz のクロックだけで、目安の 3 MHz 以下に収まる。電流はロジックの静止電流だけで、数 mA 以下 (見積り)。
IC 4 個は互いに線でつながり、1 枚に描くと線が重なって追えなくなるので、**カウンタの基板 (図2) とゲートの基板 (図3) の 2 枚の half** に分けた。
基板と基板のあいだの線は、箱の端子の名前で渡す (同じ名前どうしをつなぐ)。各 IC の電源のそばには 0.1 µF を挿す (図には描いていない)。

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 秒のカウンタの基板 — 74HC163 が 2 個 (一の位と十の位)
board: half
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  AT1:
    type: device
    at: top
    label: AD3 (Logic)
    pins: [DIO1, DIO2, DIO3, DIO4]
  OT:
    type: device
    at: top
    label: 2-5 から
    pins: [TICK]
  GT1:
    type: device
    at: top
    label: 図3 へ
    pins: [LDSU, SU0, SU3]
  AT2:
    type: device
    at: top
    label: AD3 (Logic)
    pins: [DIO5, DIO6, DIO7]
  GT2:
    type: device
    at: top
    label: 図3 へ
    pins: [ENST, LDST, ST0, ST2]
  OB:
    type: device
    at: bottom
    label: 2-5 の基板から
    pins: [CLK, TICK]
  GB:
    type: device
    at: bottom
    label: ゲートの基板 (図3)
    pins: [ENST]
  U21: dip16 @ e3 74HC163
  U22: dip16 @ e17 74HC163
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t28 -- +b28 red
  - -t29 -- -b29 black
  - a3 -- +t3 red
  - j3 -- +b3 red
  - j5 -- -b5 black
  - j6 -- -b6 black
  - j7 -- -b7 black
  - j8 -- -b8 black
  - j10 -- -b10 black
  - a17 -- +t17 red
  - j17 -- +b17 red
  - j19 -- -b19 black
  - j20 -- -b20 black
  - j21 -- -b21 black
  - j22 -- -b22 black
  - j24 -- -b24 black
  - OB.CLK -- i4 white
  - OB.CLK -- i18 white
  - OB.TICK -- i9 green
  - AT1.DIO1 -- b5 yellow
  - AT1.DIO2 -- b6 yellow
  - AT1.DIO3 -- b7 yellow
  - AT1.DIO4 -- b8 yellow
  - OT.TICK -- b9 green
  - GT1.LDSU -- b10 purple
  - d5 -- d12 yellow
  - c8 -- c13 yellow
  - GT1.SU0 -- b12 yellow
  - GT1.SU3 -- b13 yellow
  - AT2.DIO5 -- b19 blue
  - AT2.DIO6 -- b20 blue
  - AT2.DIO7 -- b21 blue
  - GT2.ENST -- b23 orange
  - GT2.LDST -- b24 purple
  - d19 -- d25 blue
  - c21 -- c26 blue
  - GT2.ST0 -- b25 blue
  - GT2.ST2 -- b26 blue
  - GB.ENST -- i23 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/06-seconds-1.svg)

- **74HC163 の向き**: 2 個とも切り欠きが左。U21 (一の位) が 3〜10 列、U22 (十の位) が 17〜24 列。
  上の組に VCC・RCO・QA〜QD・ENT・LOAD (16 番から 9 番)、下の組に CLR・CLK・A〜D・ENP・GND (1 番から 8 番) が来る
- **電源**: CLR と VCC を + レールへ、A〜D と GND を − レールへ。上と下のレールは右端 (28・29 列) でつなぐ
- **入力**: CLK (白) は 2 個とも 2-5 の基板から。TICK (緑) は U21 の ENP (下) と ENT (上) の両方へ、ENST (橙) は U22 の ENP と ENT の両方へ入れる。LOAD (紫) はゲートの基板から
- **出力**: QA〜QD を AD3 の DIO1〜DIO7 へ (黄 = 秒の一の位、青 = 十の位)。ゲートの基板へ送る SU0・SU3・ST0・ST2 は、同じ列に AD3 の線と 2 本挿さないよう、`d5`〜`d12` などで空いた列へ渡してから出す

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図3 秒のゲートの基板 — 74HC08 と 74HC02 (桁上がりと LOAD)
board: half
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  CT:
    type: device
    at: top
    label: カウンタの基板 (図2)
    pins: [ST0, ST2]
  CB:
    type: device
    at: bottom
    label: カウンタの基板 (図2)
    pins: [SU3, SU0, ENST, LDSU, LDST]
  OB:
    type: device
    at: bottom
    label: 2-5 の基板から
    pins: [TICK]
  NB:
    type: device
    at: bottom
    label: 2-7 の基板・AD3
    pins: [RS, ENMU, DIO8]
  U33: dip14 @ e3 74HC08
  U42: dip14 @ e14 74HC02
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - +t28 -- +b28 red
  - -t29 -- -b29 black
  - a3 -- +t3 red
  - j9 -- -b9 black
  - a14 -- +t14 red
  - j20 -- -b20 black
  - a16 -- -t16 black
  - a17 -- -t17 black
  - a19 -- -t19 black
  - a20 -- -t20 black
  - CB.SU3 -- j3 yellow
  - CB.SU0 -- j4 yellow
  - OB.TICK -- j7 green
  - h5 -- h6 yellow
  - g8 -- g11 orange
  - e11 -- f11 orange
  - c11 -- c4 orange
  - h8 -- h16 orange
  - CB.ENST -- i8 orange
  - CB.ENST -- j8 orange
  - CT.ST0 -- b7 blue
  - CT.ST2 -- b8 blue
  - d9 -- d5 blue
  - a6 -- a12 gray
  - e12 -- f12 gray
  - g12 -- g19 gray
  - CB.LDSU -- j14 purple
  - NB.RS -- j15 brown
  - CB.LDST -- j17 purple
  - NB.RS -- j18 brown
  - NB.ENMU -- h19 gray
  - NB.DIO8 -- j19 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/06-seconds-2.svg)

- **IC の向き**: U33 (74HC08) が 3〜9 列、U42 (74HC02) が 14〜20 列。どちらも切り欠きが左
- **桁上がり**: SU9 (U33 の 1Y) を `h5`〜`h6` で 2A へ。ENST (U33 の 2Y、8 列の下) は、`g8`〜`g11` と溝をまたぐ `e11`〜`f11`、`c11`〜`c4` で 4B (上) へ、`h8`〜`h16` で U42 の 1B へ。
  ST5 (U33 の 3Y) は `d9`〜`d5` で 4A へ。ENMU (U33 の 4Y、6 列の上) は `a6`〜`a12`・`e12`〜`f12`・`g12`〜`g19` で U42 の 2B へ
- **LOAD**: U42 の 1Y (LDSU) と 2Y (LDST) をカウンタの基板へ。RS は 2-7 の基板から (この題だけなら GND)
- U42 の C・D (PIN 8・9・11・12) は 2-7 の分のカウンタで使う。この題では − レールにつないでおく (2-7 で外す)

| 線の名前 | 回路図 | ブレッドボード |
| --- | --- | --- |
| CLK・TICK | 2-5 から | 図2 の `i4` `i18` (CLK)、`i9` `b9` (TICK)。図3 の `j7` (TICK) |
| SU0・SU3 | U21 の QA・QD → U33 の 1B・1A | 図2 の `b12` `b13` → 図3 の `j4` `j3` |
| ST0・ST2 | U22 の QA・QC → U33 の 3B・3A | 図2 の `b25` `b26` → 図3 の `b7` `b8` |
| ENST | U33 の 2Y → U22 の ENP・ENT、U33 の 4B、U42 の 1B | 図3 の `i8` `j8` → 図2 の `i23` `b23` |
| LDSU・LDST | U42 の 1Y・2Y → U21・U22 の LOAD | 図3 の `j14` `j17` → 図2 の `b10` `b24` |
| ENMU | U33 の 4Y → U42 の 2B、2-7 の分 | 図3 の `h19` (2-7 へ)、`j19` (AD3 の DIO8) |

## 計器の設定

計器は Analog Discovery 3 (AD3) のロジックアナライザ (Logic)。秒の桁はロジックの信号なので、電圧の形ではなく高低の並びと時刻を見る
(この題にオシロの図は置かない。クロックの波形は 2-5 の図4 で見る)。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V |
| Logic | DIO0 = CLK、DIO1〜DIO4 = SU0〜SU3、DIO5〜DIO7 = ST0〜ST2、DIO8 = ENMU。標本化 1 kHz、ENMU の立ち上がりでトリガ |

## 計器の画面

次の図は、**設計から計算で出した見えるはずの画面**で、実測ではない。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 秒が 59 から 00 になり、ENMU で分へ桁上げを出す (計算)
device: ad3
window: 5s
sample: 1kHz
signals:
  CLK: dio0 clock 8Hz
  TICK: pattern 00000001 bit 125ms repeat
  SU: dio1..dio4 counter on CLK rising sequence 7 7 7 7 7 7 7 7 8 8 8 8 8 8 8 8 9 9 9 9 9 9 9 9 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 2
  ST: dio5..dio7 counter on CLK rising sequence 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  ENMU: dio8 edges 0s=0 2.875s=1 3s=0
buses:
  Sec1: SU3..SU0 dec
  Sec10: ST2..ST0 dec
cursors: [2.9375s, 3.46875s]
trigger: ENMU rising
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/logic/06-seconds.svg)

| 見る所 | 見るべき値 | check の読み値 |
| --- | --- | --- |
| 秒の一の位 (Sec1) の並び | 1 秒ごとに 7 → 8 → 9 → 0 → 1 | 7@0 s、8@1 s、9@2 s、0@3 s、1@4 s |
| カーソル X1 (2.938 s、桁上がりの手前) | 秒 59、ENMU が H | Sec1 9、Sec10 5、ENMU 1 |
| カーソル X2 (3.469 s、桁上がりの後) | 秒 00、ENMU が L | Sec1 0、Sec10 0、ENMU 0 |

- 桁が変わるのは、TICK が H だった 1 クロックのあとの、CLK の立ち上がりだけだ。ENMU が H のクロックで、秒の 59 が 00 になる。2-7 では同じクロックで分の一の位が +1 になる。

## 部品表

| 部品 | 個数 | 備考 |
| --- | --- | --- |
| 74HC163 | 2 | U21 (秒の一の位)・U22 (十の位) |
| 74HC08 | 1 | U33 (2 入力 AND、4 回路) |
| 74HC02 | 1 | U42 (2 入力 NOR)。この題では 2 回路を使う |
| 0.1 µF のセラミックコンデンサ | 4 | IC ごとの電源のそば |
| ブレッドボード | 2 | half |

## LTspice での確かめ

同期カウンタとゲートの論理の題で、計算するアナログの回路が無い。この題は SPICE の対象外 (桁の並びは図4 の `logic-fence check` の読み値で確かめた)。

## 出典

自作。参考: [TI の SN74HC163 データシート (SCLS298D)](https://www.ti.com/lit/ds/symlink/sn74hc163.pdf)、
[TI の SN74HC08 データシート (SCLS081J)](https://www.ti.com/lit/ds/symlink/sn74hc08.pdf)、
[TI の SN74HC02 データシート (SCLS076G)](https://www.ti.com/lit/ds/symlink/sn74hc02.pdf)。
