---
book: analog-discovery
chapter: 6
id: 6-6
title: 電解とセラミックの違い
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-6 電解とセラミックの違い

6-2 では電解コンデンサの ESR を測った。同じ 4.7 µF でも**セラミック**なら
ESR がずっと小さく、位相は −90° にほぼぴったり近づく。同じ回路・同じ Rref で
部品だけを差し替え、2 種類のコンデンサの違いを数字で比べる。

## 回路図

6-2 と同じ回路。C<sub>DUT</sub> を電解 → セラミックに差し替える。

```circuit
title: 図1 基準抵抗と DUT (電解からセラミックに差し替え)
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 33
  Cdut: capacitor c9 c12 4.7u l=$\mathrm{C_{DUT}}$
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

## 実体配線図

6-2 と同じ配線。**電解 (帯を GND 側に) → セラミック (極性なし、向きは自由)**
に差し替えるだけ。

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

セラミックに差し替えるときは `capacitor/ceramic` (極性なし。どちら向きでもよい)。

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
セラミックに差し替えたときも同じ設定のまま測る (比べる条件を揃える)。

## 見るべき値

計算値。Xc = 1/(2πfC) = 33.86 Ω (両方共通、1 kHz・4.7 µF)。電解の ESR は
6-2 と同じ **目安 8 Ω**、セラミックの ESR は **目安 0.02 Ω** とした
(データシートに明記されないことが多く、良質なセラミックの代表値として仮定)。

| 部品 | \|Z\| | 位相 | ESR (逆算) |
| --- | --- | --- | --- |
| 電解 4.7 µF | 34.8 Ω | −76.7° | 8.0 Ω |
| セラミック 4.7 µF | 33.9 Ω | **−89.97°** | 0.02 Ω |

分かること:

- **セラミックは位相がほぼ −90° ぴったり。** 6-2 の電解 (−76.7°) と比べて
  13° 以上も理想に近い — ESR が 400 分の 1 程度しかないことが、位相の差に
  はっきり表れる
- **\|Z\| はほとんど同じ (34.8 Ω vs 33.9 Ω) なのに、位相は大きく違う。**
  振幅だけを見ていては ESR の違いに気づけない。**位相まで見て初めて
  「良いコンデンサ」かどうかが分かる**、というのがこの題の要点
- 用途への含み: **電源のデカップリング**のように高周波でインピーダンスを
  低く保ちたい用途では、ESR の小さいセラミックが有利。**大容量が必要な平滑**
  用途では、価格・体積の面で電解が有利 (10 章で電源のリップルを扱うときに
  この違いが効いてくる)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。ESR の代表値は一般的な部品の傾向による仮定 (実測すると
個体差・周波数依存で変わる)。
