---
book: analog-discovery
chapter: 6
id: 6-2
title: コンデンサの C と ESR
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-2 コンデンサの C と ESR

実物のコンデンサは、理想の C だけでなく**直列に小さな抵抗 (ESR)** を持つ。
6-1 と同じ基準抵抗の仕組みで、電解コンデンサの Z = ESR − j/(ωC) を測り、
振幅比から |Z|、位相から ESR と C を分けて取り出す。

## 回路図

```circuit
title: 図1 基準抵抗と電解コンデンサ
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 33
  Cdut: ecap c9 c12 4.7u l=$\mathrm{C_{DUT}}$
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c6
  - c6 -- c9
  - AD.2+ -| c9
  - AD.2- -| c12
  - c12 -- c14
  - AD.GND -| c14
```

- C<sub>DUT</sub> は 4.7 µF の小型電解コンデンサ。**電解は極性がある**ので、
  帯 (−側) を GND 側に向ける
- Rref は 33 Ω。ESR (数 Ω) と Xc (数十 Ω) を足した |Z| に近い値を選ぶと、
  1ch と 2ch の振幅が同じ桁になって読みやすい

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 33
  Cdut: capacitor/electrolytic c15(+) c20(-) 4.7uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h5]
  - a10 -- a15 blue
  - AD.1- -- b10 green [h5]
  - AD.2+ -- b15 white [h5]
  - AD.2- -- b20 gray [h5]
  - a20 -- -t20 black
  - AD.GND -- -t3 black
```

- 電解コンデンサは**帯のある側 (−) を 20 列 = GND 側**に挿す。逆に挿すと壊れる
- 配線の考え方は 6-1 と同じ。10 = 15 列が Rref とコンデンサの中点

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.4 V、**Offset 0.5 V** (電解に逆電圧をかけないため) |
| Scope | CH1 = Rref の両端、CH2 = C<sub>DUT</sub> の両端。Range は両方 200 mV/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

**W1 にオフセットを足す理由。** オフセット無しの正弦波だと、C<sub>DUT</sub> の両端は
0 V を中心に ±0.26 V 振れ、半周期ごとに電解の − 側が + 側より高くなる (逆電圧)。
Offset 0.5 V を足すと、コンデンサは 0.5 V に充電された上で ±0.26 V 振れる
(約 0.24〜0.76 V) ので、+ 側が常に高いまま測れる。Rref には直流が流れないので
(充電は 33 Ω × 4.7 µF ≈ 0.16 ms で終わる) CH1 は 0 V 中心のまま、CH2 だけ
0.5 V 持ち上がる。Amplitude と Phase は交流分だけを見るので、下の値は変わらない。

Xc がまだ ESR より大きいので、位相は −90° に近いがぴったりではない。

## 見るべき値

計算値。ESR はデータシートに載っていないことが多く、ここでは小型電解 (4.7 µF) の
目安として **ESR ≈ 8 Ω** を仮定した (実測すると個体差で変わる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Xc = 1/(2πfC) | 33.9 Ω | 理想のリアクタンス |
| CH1 (Rref の両端) | 0.248 V | I ≈ 7.5 mA |
| CH2 (C<sub>DUT</sub> の両端) | 0.262 V、位相 −76.7° | \|Z\| = 34.8 Ω |
| 分けた ESR と C | ESR ≈ \|Z\|cos(76.7°) = 8 Ω、Xc ≈ \|Z\|sin(76.7°) = 33.9 Ω → C ≈ 4.7 µF | 位相が −90° より浅いぶんが ESR |

位相が −90° にどれだけ足りないかで ESR の大きさが分かる。**セラミックコンデンサに
差し替えると位相はほぼ −90° になる** (6-6 で比べる)。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
