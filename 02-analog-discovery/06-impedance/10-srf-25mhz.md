---
book: analog-discovery
chapter: 6
id: 6-10
title: 25 MHz まで — 0.1 µF の SRF
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: PF
device: AD3
---

# 6-10 25 MHz まで — 0.1 µF の SRF

デカップリングの定番、0.1 µF (マイクロファラド) の積層セラミックも、6-4 のコイルと同じく
**自己共振 (SRF) を持つ**。コンデンサの中とリードにある小さなインダクタンス **ESL** と C が直列に共振し、
SRF より上では**コンデンサなのにコイルとして振る舞う**。リード付きの品の SRF は 10 MHz 前後にあり、
AD2 の Impedance (10 MHz まで) では端に掛かって見えにくい。Analog Discovery 3 の Impedance は
25 MHz まで掃引できるので、SRF の上の「コイルの側」まで一続きに見える。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗と 0.1 µF (CH1 は W1 の出口、CH2 は DUT の両端)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery 3 + BNC
    pins: [W1, 1+, 2+, GND]
    turn: mirror
  Rref: resistor 5,4 8,4 100
  Cdut: capacitor 11,4 14,4 0.1u l=$\mathrm{C_{DUT}}$
  G1: ground 16,4
wires:
  - AD.W1 -| 5,4
  - AD.1+ -| 5,4
  - 8,4 -- 11,4
  - AD.2+ -| 10,4
  - 14,4 -- 16,4
  - AD.GND -| 16,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/10-srf-25mhz.svg)

- **BNC アダプタを付けた Analog Discovery 3** で測る。BNC の入力は片側が GND の単端なので、6-1〜6-4 の
  「1+/1− で Rref の両端」の代わりに、**CH1 で W1 の出口 (Rref の入口)、CH2 で DUT の両端**を測り、
  電流は (V<sub>CH1</sub> − V<sub>CH2</sub>) / Rref で出す
- Rref (基準抵抗) は 100 Ω (オーム)。W1 の振幅 1 V で電流が 10 mA (Wavegen が流せる目安) に収まる値にした
- C<sub>DUT</sub> は 0.1 µF・50 V の X7R (リード付き、ピンの間隔 2.54 mm)。**等価回路**としては、
  C = 0.1 µF に ESL 2.2 nH (ナノヘンリー) と ESR 0.03 Ω が直列につながる (ESL と ESR は仮定。下の「見るべき値」)

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図2 ユニバーサル基板と Analog Discovery 3 (部品面から見た図)
board:
  size: 7x5cm
  slots: on
parts:
  Rref: resistor e10 i10 100
  Cdut: capacitor/ceramic k10 l10 0.1u
  AD:
    type: device
    at: e22
    label: AD3 + BNC
    pins: [W1, 1+, 2+, GND]
wires:
  - AD.W1 -- e18 yellow
  - e18 -- e16 yellow
  - e16 -- e10 yellow
  - AD.1+ -- f18 white
  - f18 -- f16 white
  - f16 -- e16 white
  - AD.2+ -- g18 gray
  - g18 -- g14 gray
  - g14 -- j14 gray
  - j14 -- j10 gray
  - i10 -- j10 gray
  - j10 -- k10 gray
  - AD.GND -- h18 black
  - h18 -- h16 black
  - h16 -- o16 black
  - o16 -- o10 black
  - o10 -- l10 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/perfboard/10-srf-25mhz.svg)

- **ユニバーサル基板にする理由。** 掃引が 25 MHz まで伸び、ブレッドボードの列どうしの浮遊容量 (数 pF) と
  長い金属の板バネのインダクタンスが、測りたい ESL (数 nH) と同じ桁になるから。穴の独立したユニバーサル基板なら、
  C<sub>DUT</sub> の周りの線を数 mm にできる。ユニバーサル基板の範囲は 10 MHz までなので、**10 MHz より上の値は
  基板の寄生を含む目安**として読み、6-7 の Open / Short 補償で基板と線の分を引く
- C<sub>DUT</sub> は**リードを根元まで切り詰め、隣り合う 2 穴 (K10・L10) に挿す**。リード 1 mm で約 1 nH 増えるので
  (目安)、リードの長さで SRF が動く
- 計器の 4 本 (W1・1+・2+・GND) は BNC ケーブルの先をユニバーサル基板の上の端に半田付けし、
  ケーブルの外皮 (GND) は 4 本とも H18 の筋にまとめる (図では GND を 1 本で描いた)

## 計器の設定

計器は Analog Discovery 3 の Impedance (25 MHz まで掃引できるのは AD3 だけ) と BNC アダプタ。

| 計器 | 設定 |
| --- | --- |
| Impedance | Start 100 kHz、Stop 25 MHz、点数 201、Amplitude 1 V。Reference: 抵抗 100 Ω |
| 接続の構成 | W1 → CH1 → Rref → CH2 → DUT → GND の並び (WaveForms の構成の一覧から選ぶ。名前は版で違うので目安) |
| 補償 | 6-7 と同じ Open (DUT を抜く) と Short (DUT の代わりに K10–L10 を太い線で短絡) を、25 MHz まで取ってから測る |
| 表示 | \|Z\| と位相 (Phase)。必要なら Rs と Xs も |

**AD2 で代わりにやるなら。** AD2 の Impedance は 10 MHz までなので、SRF の近く (10.7 MHz) は端に掛かる。
0.1 µF の代わりに 0.47 µF (SRF は 4.95 MHz、計算値) を測ると、SRF の上も AD2 の範囲で見える。

Wavegen は BNC で 12 MHz (−3 dB) までなので、25 MHz では W1 の振幅が下がる。Impedance は CH1 と CH2 の比で読むので
\|Z\| の値は変わらないが、CH2 の電圧が小さくなるぶん読みが揺れる (平均を増やす)。
Impedance の掃引の途中、1 MHz の 1 点を Scope で見るとこうなる (計算値)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 MHz の CH2 (C の両端) は 15.8 mV で 88° 遅れる — まだコンデンサ
time: 500ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 1MHz 1V, range: 500mV/div}
ch2: {wave: sine 1MHz 15.8mV phase -88deg, range: 5mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/10-srf-25mhz.svg)

CH1 (1 V) と CH2 (15.8 mV) は振幅が 60 倍違うので、尺度を 500 mV/div と 5 mV/div に分けた。
CH2 の CH1 に対する位相 −88° は、C<sub>DUT</sub> の電圧が Rref の電流より約 90° 遅れることを示す
(電流は CH1 とほぼ同じ位相。Rref 100 Ω が DUT よりずっと大きいため)。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 100 Ω、1/4 W 金属皮膜 | 電流 10 mA で 10 mW |
| C<sub>DUT</sub> | 0.1 µF・50 V、X7R、リード付き積層セラミック (2.54 mm 間隔、記号 104) | リードは根元まで切る |
| 基板 | ユニバーサル基板 7×5 cm (FR-4、1.6 mm) | 25 MHz を測るため (上の理由) |
| 計器 | Analog Discovery 3 + BNC アダプタ、BNC ケーブル 3 本 | |

## 見るべき値

計算値。**ESL 2.2 nH と ESR 0.03 Ω は仮定** (リードを切った 0.1 µF の目安)。実測の SRF から ESL を逆算できる:
ESL = 1 / ((2π × SRF)² × C)。

| 周波数 | \|Z\| | 位相 | CH2 (振幅) | 分かること |
| --- | --- | --- | --- | --- |
| 100 kHz | 15.9 Ω | −89.9° | 157 mV | ほぼ理想の C (X<sub>C</sub> = 1/ωC) |
| 1 MHz | 1.58 Ω | −88.9° | 15.8 mV | まだコンデンサ。X<sub>C</sub> から 1.59 Ω のうち ESL の分 0.014 Ω が引かれる |
| 10.7 MHz (SRF) | 0.03 Ω (= ESR) | 0° | 0.3 mV | X<sub>L</sub> と X<sub>C</sub> が打ち消し、残るのは ESR だけ |
| 25 MHz | 0.28 Ω | **+83.9°** | 2.8 mV | **コイルに変わっている** (\|Z\| は周波数とともに増える) |

SRF = 1 / (2π√(2.2 nH × 0.1 µF)) = **10.7 MHz**。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 0.1 µF は 10.7 MHz (SRF) で |Z| が谷になり、上ではコイル (+90°) になる
x: 周波数 Hz log 100k..25M
y:
  - インピーダンス Ω log
  - 位相 deg -100..100
lines:
  "0.1 µF (ESL 2.2 nH) Ω": sqrt(0.03^2+(2*pi*x*2.2n-1/(2*pi*x*0.1u))^2)
  "理想の C Ω": 1/(2*pi*x*0.1u)
  "0.1 µF の位相 deg": deg(atan2(2*pi*x*2.2n-1/(2*pi*x*0.1u), 0.03))
notes:
  - mark 1M
  - mark 10.73M
  - mark 25M
  - level 0deg
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/10-srf-25mhz.svg)

分かること:

- **SRF の谷の底は ESR で決まる。** 0.03 Ω を 10 mA で読むと CH2 は 0.3 mV しか無く、AD3 の Scope の分解能に近い。
  谷の深さは平均を増やしても揺れるので、**SRF は位相が 0° を横切る周波数で読む** (谷の底より確か)
- SRF より上は「ESL のコイル」で、0.1 µF を何個並べても高い周波数の雑音は下がりにくい。
  高い周波数まで低いインピーダンスが要る所は、小さい容量 (SRF が高い) を並べるか、ESL の小さいチップ部品にする
- 6-4 (100 µH のコイル) は SRF の上でコンデンサに、この題のコンデンサは SRF の上でコイルになる。
  どちらも「部品は SRF の下で使う」

## LTspice での確かめ

`sim/10-srf-25mhz.cir` で図1 (W1 の振幅 1 V、Rref 100 Ω、C<sub>DUT</sub> は 0.1 µF に ESL 2.2 nH と ESR 0.03 Ω を直列) を
100 kHz〜25 MHz で交流解析した。ESL・ESR は本文の仮定で、**実測ではない**。BNC と基板の寄生は入れていない (補償で引く分)。位相は V(CH2) の位相から Rref の電流の位相を引いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| \|Z\| (100 kHz) | 15.9 Ω | 15.91 Ω | 合う |
| \|Z\| (1 MHz) | 1.58 Ω | 1.578 Ω | 合う |
| CH2 (1 MHz) | 15.8 mV | 15.77 mV | 合う |
| \|Z\| と位相 (25 MHz) | 0.28 Ω、+83.9° | 0.2835 Ω、+83.9° | 合う |
| SRF (\|Z\| の谷) | 10.7 MHz、0.03 Ω | 位相が 0° を横切るのは 10.73 MHz、谷は 0.0300 Ω | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。Impedance の周波数範囲 (AD3 は既定 25 MHz まで) は
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
による。
