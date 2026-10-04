---
book: nanovna
chapter: 4
id: 4-9
title: バリキャップの C vs 電圧
tier: 100
source: 自作
board: PF
device: H4
---

# 4-9 バリキャップの C vs 電圧

バリキャップ (可変容量ダイオード) は、逆向きにかけた電圧で接合の容量が変わる
ダイオード。ラジオの同調や VCO で、バリコンの代わりに電圧で周波数を動かす (7-5 の
バリコンを電圧で置き換える部品)。AM 用の 1SV149 に**逆向きの直流**をかけながら
3-1 の直列治具で S21 を測り、電圧ごとの容量を読む。

## 回路図

直列治具の真ん中に、**直流を止めるコンデンサ (C1・C2)** とバリキャップ D1 を
挟む。直流は R1・R2 (100 kΩ) を通して D1 の両端だけにかける。

```circuit
title: 図1 バリキャップに逆向きの直流をかけて直列治具で測る
parts:
  J1: sma e2 mirror CH0
  C1: capacitor e3 e5 100n
  D1: varicap e8 e6 1SV149
  C2: capacitor e9 e11 100n
  J2: sma e12 CH1
  R1: resistor c6 e6 100k
  R2: resistor c8 e8 100k
  VR1: potentiometer b8 b4 l=$\mathrm{VR}_1$
  BT1: battery a4 a8 9 l=$\mathrm{BT}_1$
  G1: ground f2
  G2: ground f12
wires:
  - J1.1 -- e3
  - e5 -- e6
  - e8 -- e9
  - e11 -- J2.1
  - J1.2 -- f2
  - J2.2 -- f12
  - c6 |- VR1.w
  - c8 -- b8
  - b4 -- a4
  - b8 -- a8
notes:
  - text b5d0 center: 10 kΩ
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/09-varicap.svg)

- D1 は**カソードが CH0 側 (左)**。R1 がカソードへ +、R2 がアノードへ − をつなぐので、
  逆向き (カソードが高い) の電圧がかかる。電圧は VR1 で 0〜9 V に変える
- **C1・C2 が直流を止める**。NanoVNA のポートに直流をかけないため。100 nF は 1 MHz で
  1.6 Ω しかなく、測る値にほとんど効かない
- 電池は GND につながない (浮かせる)。D1 の両端の差だけが決まればよく、GND を
  信号の線の上へ回さずに済む
- R1・R2 (100 kΩ) は高周波には開放に見え、治具の 50 Ω にほとんど効かない

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 直列治具にバリキャップとバイアス
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  C1: capacitor/ceramic i2 i4 100n
  D1: varicap i9 i6 1SV149
  C2: capacitor/ceramic i11 i13 100n
  R1: resistor f6 h6 100k
  R2: resistor f9 h9 100k
  VR1: potentiometer/trimmer e2 f3 e4 10k
  BT1:
    type: device
    at: top
    label: 電池 9V
    pins: + -
wires:
  - i1 -- i2
  - i4 -- i6
  - i9 -- i11
  - i13 -- i24
  - i6 -- h6
  - i9 -- h9
  - f3 -- f6
  - e4 -- e9
  - e9 -- f9
  - BT1.+ -- e2 red
  - BT1.- -- e9 blue
  - j0 -- j25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/09-varicap.svg)

- 信号は i 行をまっすぐ通る。バイアスは上 (e〜h 行) から R1・R2 で D1 の両足へ降りる
- 電池の − (青) は GND ではない。j 行の GND とつながないまま、VR1 と R2 へ行く
- 1SV149 の足のどちらがカソードかは、データシートの外形図で確かめてから挿す
- 電圧はテスターで D1 の両足 (i6 と i9) の間を測って合わせる。VR1 の目盛は当てにしない
- VR1 を回し切ると 9 V になる。1SV149 の最大逆電圧は 15 V (データシート) なので 9 V は
  範囲の中。表はデータシートの容量比の点 (1 V と 8 V) に合わせて 8 V までにする

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| D1 | 1SV149 (AM 用バリキャップ) | 最大逆電圧 15 V。1 V で 435〜540 pF、容量比 C(1 V) / C(8 V) は 15 以上 (データシート)。以下の計算は 1 V で 485 pF、8 V で 25 pF とする (目安) |
| C1・C2 | 100 nF (積層セラミック) | 直流を止める |
| R1・R2 | 100 kΩ | 直流をかけ、高周波は通さない |
| VR1 | 10 kΩ (半固定) | 0〜9 V を作る |
| 電源 | **9 V 電池 — データシートの 8 V の点まで振るため** | この本の電源は 5 V が決めだが、5 V では逆電圧が 5 V までしか届かず、データシートの容量比 (1 V と 8 V) を確かめられない |

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜5 MHz |
| 点数 | 201 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag と位相。CH1 まで通す (直列治具) |

**1 V** のときに見えるはずの画面 (C1・C2 も入れた理想の模型)。

```vna
device: h4
sweep: 50k-5M 201
title: 図3 1 V (485 pF) — 1 MHz で S21 は −10.8 dB
dut:
  - series C 100n
  - series C 485p
  - series C 100n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/09-varicap-1.svg)

**8 V** のとき (同じ設定)。容量が小さいぶん、ずっと通りにくい。

```vna
device: h4
sweep: 50k-5M 201
title: 図4 8 V (25 pF) — 1 MHz で S21 は −36.1 dB
dut:
  - series C 100n
  - series C 25p
  - series C 100n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/09-varicap-2.svg)

## 見るべき値

直列治具では S21 = 100 / (100 + Z)。Z = 1 / (jωC) なら、読んだ |S21| から

```text
C = 1 / (2π f × 100 × √(1/|S21|² − 1))
```

で容量が出る (|S21| は dB から直した比。−10.8 dB なら 0.289)。C1・C2 の 3.2 Ω (1 MHz) も
Z に入るので、この式の C は 1 % ほど小さく出る (485 pF → 480 pF)。

| 逆電圧 | C (目安) | 1 MHz の X | 1 MHz の S21 (計算値) | 位相 (計算値) |
| --- | --- | --- | --- | --- |
| 1 V | 485 pF | −328 Ω | −10.8 dB | +73.2° |
| 8 V | 25 pF | −6.37 kΩ | −36.1 dB | +89.1° |

途中の電圧は測って表を埋め、C を電圧に対して描く。

| 逆電圧 | 1 V | 2 V | 3 V | 4 V | 5 V | 6 V | 8 V |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 MHz の S21 (測る) | | | | | | | |
| C (計算する) | | | | | | | |

分かること:

- **1 V と 8 V で容量はおよそ 19 倍変わる** (目安の値で。データシートの保証は 15 倍以上)。AM 用のバリキャップは、中波の 1 つの
  コイルで 530〜1600 kHz を回せる (周波数で 3 倍 = 容量で 9 倍) ように、この比を大きく作ってある
- 8 V (図4) の位相は +89° 前後から動かない。容量が小さく、5 MHz でも X が 100 Ω より
  ずっと大きいからで、図4 の位相の線が平らなのは意図どおり (図3 の 1 V と比べる線)
- 容量の変わり方は一様ではなく、低い電圧のほうが急。データシートの曲線と、
  自分で測った表を比べる
- NanoVNA の出力は小さい (0-3) が、0 V 近くでは高周波の振れでダイオードが少し
  順方向に入り、容量の読みが揺れる。**表は 1 V から始める**

## 出典

自作。1SV149 の最大逆電圧 (15 V)、1 V の容量の範囲 (435〜540 pF)、容量比 (15 以上) は東芝の
データシートによる。計算に使った 485 pF・25 pF は、その範囲の中から選んだ目安の値。
