---
book: analog-discovery
chapter: 6
id: 6-5
title: インピーダンスアナライザアダプタ (自動レンジ)
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 6-5 インピーダンスアナライザアダプタ (自動レンジ)

6-1〜6-4 は基準抵抗 Rref を自分で選んで挿す方式だった。Digilent の純正
**Impedance Analyzer Adapter** は、この Rref を**内蔵のリレーで自動的に
切り替える**専用基板で、DUT を挟むだけで測定できる。仕組みは同じ
「基準抵抗の両端と DUT の両端を読む」やり方のまま、Rref を選ぶ手間だけが
無くなる。

## 回路図

```circuit
title: 図1 アダプタを挟んだ接続
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  ADP:
    type: device
    at: a9
    label: Z Analyzer Adapter
    pins: [W1, GND, 1+, 1-, 2+, 2-, DUT+, DUT-]
  DUT:
    type: device
    at: a17
    label: DUT
    pins: [P1, P2]
wires:
  - AD.W1 -| ADP.W1
  - AD.GND -| ADP.GND
  - AD.1+ -| ADP.1+
  - AD.1- -| ADP.1-
  - AD.2+ -| ADP.2+
  - AD.2- -| ADP.2-
  - ADP.DUT+ -| DUT.P1
  - ADP.DUT- -| DUT.P2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/05-impedance-adapter-autorange.svg)

- アダプタは AD3 の 2×15 コネクタにそのまま挿す (W1・GND・1±・2± の 6 本は
  基板内部で結線済み)。**DUT はアダプタの端子台 (J2) に挟むだけ**で、
  ブレッドボードは要らない
- アダプタの中では、内蔵の**複数の基準抵抗 (0.1% 精度) をリレーで切り替えて**
  DUT と直列にし、1+/1− (基準抵抗の両端) と 2+/2− (DUT の両端) を AD3 の
  オシロへ渡す — 6-1〜6-4 で自分の手でやっていたことを基板がやる

この題は実体配線図を付けない — DUT はアダプタの端子台に挟むだけで、板に挿す部品も配線も無い。

## 計器の設定

計器は Analog Discovery 3 とそのアダプタ (Rref を自動で選ぶため)。

| 計器 | 設定 |
| --- | --- |
| Wavegen | Impedance 計器が自動で設定 (手で触らない) |
| Impedance | Reference: **Adapter** (自動レンジ)。Start・Stop を測りたい範囲に設定 |

アダプタの中の 1+/1− と 2+/2− は、6-1〜6-4 と同じく Scope で見える。
DUT を 100 nF のコンデンサ、W1 の振幅を 1 V、周波数を 1 kHz とすると、表のとおりアダプタは Rref = 1 kΩ を選ぶ。
このとき X<sub>C</sub> = 1/(2π × 1 kHz × 100 nF) = 1591.5 Ω、回路全体の \|Z\| = √(1000² + 1591.5²) = 1879.6 Ω なので、
電流は 1 V / 1879.6 Ω = 0.532 mA。CH1 (Rref の両端) は 0.532 mA × 1 kΩ = 0.532 V、
CH2 (DUT の両端) は 0.532 mA × 1591.5 Ω = 0.847 V、CH2 は CH1 より 90° 遅れる。

```scope
title: 図2 CH2 (100 nF の電圧) は CH1 (電流) より 90° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.532V, range: 500mV/div}
ch2: {wave: sine 1kHz 0.847V phase -90deg, range: 500mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/05-impedance-adapter-autorange.svg)

図2 の Vpp は CH1 1.06 V・CH2 1.69 V (振幅の 2 倍)。

## 見るべき値

公式資料に載っているアダプタの自動レンジ表 (DUT の目安の値ごとに、
アダプタが選ぶ基準抵抗)。

| DUT の目安 | 選ばれる基準抵抗 |
| --- | --- |
| C ≈ 100 pF | 1 MΩ |
| C ≈ 1 nF | 100 kΩ |
| C ≈ 10 nF | 10 kΩ |
| C ≈ 100 nF | 1 kΩ |
| C ≈ 1 µF | 1 kΩ |
| C ≈ 10 µF | 100 Ω |
| C ≈ 100 µF | 10 Ω |
| L ≈ 1 µH | 100 nF に対応する抵抗と同じ帯 (1 kΩ 付近) |
| L ≈ 10 µH | 1 µF に対応する抵抗と同じ帯 (1 kΩ 付近) |
| L ≈ 100 µH | 10 µF に対応する抵抗と同じ帯 (100 Ω 付近) |
| L ≈ 1 mH | 100 µF に対応する抵抗と同じ帯 (10 Ω 付近) |

C ≈ 1 µF の行は公式の表のまま 1 kΩ と写した。C が 10 倍になるごとに |Z| は 1/10 になるので、
ほかの行と同じ規則なら 100 Ω のはずで、公式の表の 1 段ずれと見られる。表は「目安」で、
実際には WaveForms が測った |Z| と周波数から選ぶ。

**10 Ω・100 Ω・1 kΩ・10 kΩ・100 kΩ・1 MΩ の 6 段階**を自動で切り替える
(6-1 で「Rref は DUT と桁を合わせる」と説明した考え方そのものを、基板が
自動でやってくれている)。

分かること:

- **6-1〜6-4 で自分の手で選んでいた Rref の値が、この表とほぼ一致する。**
  例えば 6-3 (10 mH のコイル、10 kHz) では XL ≈ 628 Ω で Rref = 680 Ω を
  選んだが、アダプタなら同じ帯 (100 Ω〜1 kΩ) を自動で選ぶ
- **6 段階しかないので、DUT の値が境目付近だと桁の変わり目で誤差が増える。**
  自分で Rref を選ぶ方式なら、境目を避けてぴったりの値を選べる場面もある —
  自動レンジは速いが、際どい値では手動のほうが追い込める
- AD3 の資料 (Reference Manual) によれば、アダプタを使うときは、デジタル入出力と
  Supplies の電源がアダプタのリレーの制御に使われる。アダプタの消費電流は
  アダプタの資料に約 25 mA とあるが、これは AD3 で測った値ではなく、**AD3 での値は未確認**
  (25 mA なら 5 V で約 0.13 W。Supplies の限界 (0-2) より十分小さい)

## 出典

自作。アダプタの機能・自動レンジ表・消費電流は Digilent の
[Analog Discovery Impedance Analyzer Reference Manual](https://digilent.com/reference/add-ons/impedance-analyzer/reference-manual)
による (アダプタの資料そのものは旧機種の時代のもので、AD3 で表・消費電流が同じかは未確認)。
アダプタが Supplies と DIO を使うことと、Impedance の周波数範囲 (20 µHz 〜 システムクロックの 1/4、
既定 25 MHz) は
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
による。計器の操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
