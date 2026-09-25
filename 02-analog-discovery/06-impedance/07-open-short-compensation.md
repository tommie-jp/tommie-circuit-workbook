---
book: analog-discovery
chapter: 6
id: 6-7
title: Open / Short 補償
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-7 Open / Short 補償

6-1〜6-6 は基準抵抗だけで測ってきたが、ブレッドボードの配線自体にも
寄生 (8-2 の列間容量、8-3 のジャンパのインダクタンス) がある。**DUT を挟む前に
「何もつながない (Open)」「ショートする (Short)」の 2 回測っておく**と、
この寄生を計算で差し引ける。10 kΩ という比較的大きな抵抗を、補償の
あり・なしで比べる。

## 回路図

DUT の位置 (2+/2− の手前) だけを 3 通りに変える。回路そのものは 6-1 と同じ。

```circuit
title: 図1 DUT の位置を Open・Short・実測の 3 通りに
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 10k
  Rdut: resistor c9 c12 10k l=$\mathrm{R_{DUT}}$
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

- **Open**: R<sub>DUT</sub> の場所に**何も挿さない** (c9・c12 を空けたまま)
- **Short**: R<sub>DUT</sub> の場所を**ジャンパ線 1 本**に差し替える (c9−c12 間を導線に)
- **実測**: R<sub>DUT</sub> (10 kΩ) を挿す

## 実体配線図

6-1 と同じ配線。R<sub>DUT</sub> の場所だけ、何も挿さない・ジャンパ 1 本・
10 kΩ の抵抗、の 3 通りに差し替える。

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 10k
  Rdut: resistor c15 c20 10k
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

R<sub>DUT</sub> (15〜20 列) を空ける・ジャンパにする・10 kΩ にする、の 3 通り。
Open のとき、20 列 (2− 側) は浮くのではなく **6-2 と同様に基準側の配線には
そのままつながっている** ので、Open は「R<sub>DUT</sub> の 2 端子間だけが開いている」
状態になる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**1 MHz**、Amplitude 1 V |
| Scope | CH1 = Rref の両端、CH2 = R<sub>DUT</sub> の両端 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

低い周波数では寄生が小さすぎて見えないので、**あえて 1 MHz**で測る
(6-1〜6-6 の 1 kHz よりずっと高い)。

## 見るべき値

計算値。8-2 の列間容量 (**C<sub>stray</sub> ≈ 2.5 pF**) と 8-3 のジャンパの
インダクタンス (**L<sub>stray</sub> ≈ 43 nH**) を、それぞれ Open・Short 測定の
寄生モデルとして使う。1 MHz、R<sub>DUT</sub> = 10 kΩ (実測値) として計算。

| 測定 | 計算に使う寄生 | 結果 |
| --- | --- | --- |
| Open (Z<sub>open</sub>) | C<sub>stray</sub> = 2.5 pF | Z<sub>open</sub> = 1/(2πfC) ≈ −j63.7 kΩ |
| Short (Z<sub>short</sub>) | L<sub>stray</sub> = 43 nH | Z<sub>short</sub> = 2πfL ≈ +j0.27 Ω (ほぼ 0) |
| 補償前 (生の測定値) | Z<sub>meas</sub> = Z<sub>short</sub> + (R<sub>DUT</sub> ∥ Z<sub>open</sub>) | \|Z<sub>meas</sub>\| ≈ 9.88 kΩ、位相 ≈ −8.9° |
| **補償後** | Z<sub>DUT</sub> = (Z<sub>meas</sub> − Z<sub>short</sub>) × Z<sub>open</sub> / (Z<sub>open</sub> − (Z<sub>meas</sub> − Z<sub>short</sub>)) | **10.00 kΩ、位相 0.0°** (元の 10 kΩ に戻る) |

分かること:

- **補償しないと、ただの抵抗のはずが「約 8.9° の位相を持つ何か」に見えてしまう。**
  実際は R<sub>DUT</sub> = 10 kΩ の純抵抗なのに、Open で測った並列の寄生容量が
  1 MHz では無視できなくなり、見かけの \|Z\| も 9.88 kΩ とわずかに低く出る
- **Open (並列の漏れ) と Short (直列のリード) は効き方が逆。** 大きい R<sub>DUT</sub>
  (この題の 10 kΩ) では Open の寄生が支配的で、Short の寄生 (0.27 Ω) は
  ほぼ無視できる。小さい R<sub>DUT</sub> (6-3 のような数十〜数百 Ω) では逆に
  Short の寄生のほうが効いてくる
- **この Open/Short の考え方は、NanoVNA の校正 (Open・Short・Load) と同じ
  発想**。測定治具そのものの寄生を先に測って引き算する、という基本は
  計測全般で共通する

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。Open/Short 補償の式 Z<sub>DUT</sub> = (Z<sub>meas</sub> − Z<sub>short</sub>) ×
Z<sub>open</sub> / (Z<sub>open</sub> − (Z<sub>meas</sub> − Z<sub>short</sub>)) は LCR メータで一般に使われる
2 端子補償の式 (自分で確かめた)。寄生の値は 8-2・8-3 の仮定値を流用。
