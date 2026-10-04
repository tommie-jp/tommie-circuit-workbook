---
book: circuits
chapter: 1
id: 1-9
title: ダイオードのクリッパとクランパ
tier: 100
source: 自作
---

# 1-9 ダイオードのクリッパとクランパ

ダイオードは 1-4 で見たとおり、一方向 (順方向) にしか電流を流さない。シリコンの小信号
ダイオード (1N4148) は、流れている間に両端に約 0.7V が残る (LED の V<sub>F</sub> にあたる値)。
この 2 つの性質だけで、交流の波形を**加工**できる。振幅の一部を削る**クリッパ**と、
波形全体を上下にずらす**クランパ**の 2 つを組む。クリッパは入力を守る保護回路に、
クランパはテレビの映像信号の直流の位置合わせなどに使われてきた。

## 回路図

クリッパ (振幅を ±0.7V あたりで削る)。

```circuit
title: 図1 ダイオードクリッパ (W1 で入れ、CH2 と CH1 で比べる)
parts:
  W1: square a2 c2 l=$\mathrm{W1}$
  G3: ground c2
  M2: voltmeter a4 c4 l=$\mathrm{CH2}$
  G4: ground c4
  R1: resistor a4 a6 1k
  D1: diode a7 c7
  G1: ground c7
  D2: diode c9 a9
  G2: ground c9
  OUT: port a11
  M1: voltmeter a13 c13 l=$\mathrm{CH1}$
  G5: ground c13
wires:
  - a2 -- a4
  - a6 -- a7
  - a7 -- a9
  - a9 -- a11
  - a11 -- a13
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/09-diode-clipper-clamper-1.svg)

クランパ (波形全体を上へずらす)。

```circuit
title: 図2 ダイオードクランパ (W1 で入れ、CH2 と CH1 で比べる)
parts:
  W1: square a2 c2 l=$\mathrm{W1}$
  G1: ground c2
  M2: voltmeter a4 c4 l=$\mathrm{CH2}$
  G2: ground c4
  C1: capacitor a4 a6 1u
  D3: diode c7 a7
  G3: ground c7
  RL: resistor a9 c9 100k
  G4: ground c9
  OUT: port a11
  M1: voltmeter a13 c13 l=$\mathrm{CH1}$
  G5: ground c13
wires:
  - a2 -- a4
  - a6 -- a7
  - a7 -- a9
  - a9 -- a11
  - a11 -- a13
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/09-diode-clipper-clamper-2.svg)

## 実体配線図

Analog Discovery (AD) の W1 から ±5V・1kHz の方形波を入れ、CH2 (2+) で入力を、
CH1 (1+) で出力を見る (図3・図4)。1−・2−・GND は上の − レールへ。直流の電源は要らない。

```breadboard
title: 図3 クリッパの実体配線図 (W1 と CH2 を入力へ、CH1 を出力へ)
board: half
parts:
  R1: resistor b3 b8 1k
  D1: diode a8 -t8 1N4148
  D2: diode -t11 a11 1N4148
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [2-, 2+, W1, GND, 1-, 1+]
wires:
  - AD.2- -- -t1 black
  - AD.2+ -- a2 orange
  - e2 -- e3 orange
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - e8 -- e11 blue
  - d11 -- d13 blue
  - AD.1- -- -t10 black
  - AD.1+ -- a13 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/09-diode-clipper-clamper-1.svg)

```breadboard
title: 図4 クランパの実体配線図 (W1 と CH2 を入力へ、CH1 を出力へ)
board: half
parts:
  C1: capacitor b3 b8 1uF
  D3: diode -t8 a8 1N4148
  RL: resistor a12 -t12 100k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [2-, 2+, W1, GND, 1-, 1+]
wires:
  - AD.2- -- -t1 black
  - AD.2+ -- a2 orange
  - e2 -- e3 orange
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - e8 -- e12 blue
  - d12 -- d14 blue
  - AD.1- -- -t10 black
  - AD.1+ -- a14 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/09-diode-clipper-clamper-2.svg)

## 動作

**クリッパ (図1)**: 入力に ±5V の方形波を想定する。`D1` は出力が +0.7V を
超えると導通し、それ以上は流させない。`D2` は逆向きに入れてあるので、
出力が −0.7V を下回ると導通する。

- 入力が +5V のとき: `D1` が導通し、出力は **+0.7V** に頭打ち (計算値)
- 入力が −5V のとき: `D2` が導通し、出力は **−0.7V** に頭打ち (計算値)
- 入力が −0.7V 〜 +0.7V の間: どちらのダイオードも導通せず、出力は
  **入力そのまま**

**クランパ (図2)**: 入力に ±5V の方形波 (1kHz) を想定する。`D3` は
出力が −0.7V を下回ろうとすると導通し、それより下がらないように押さえる。
`C1` は交流を素通りさせつつ、`D3` が導通するたびにこの下限を保つ
ように充電される。

- 入力の最小 (−5V) のときに出力が −0.7V になるよう、`C1` は約
  **4.3V** (= −0.7 − (−5)) に充電される (計算値)
- 出力 = 入力 + 4.3V のオフセットがかかるので、入力の最大 (+5V) では出力は
  +5 + 4.3 = **+9.3 V** まで持ち上がる (計算値)。**波形の形は変えず、
  全体を +4.3V だけ底上げする**のがクランパ
- `RL` (100kΩ) と `C1` (1µF) の時定数 = 100ms。1kHz の半周期 (0.5ms) は
  この 0.5% ほどなので、`D3` が導通していない間の電圧の垂れ下がりはごく
  わずか (計算値)

クリッパは**振幅を削り**、クランパは**振幅を保ったまま底上げする** —
似た部品構成でも働きがまったく違う。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 1 kΩ |
| D1, D2, D3 | 小信号ダイオード | 1N4148 |
| C1 | フィルムコンデンサ | 1 µF |
| RL | 抵抗 (1/4 W) | 100 kΩ |

## 見るべき値

W1 (か発振器) で ±5V、1kHz の方形波を入れ、オシロスコープの CH2 に入力、CH1 に出力をつないで
比べる (図5・図6)。結合は DC にする。AC 結合 (直流分を切って見る) にすると、クランパが
持ち上げた直流の分が消えて、入力と同じ高さに見えてしまう。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| 図1、入力 (CH2) の最大・最小 | +5 V・−5 V | 入力は ±5V の方形波 |
| 図1、入力 +5V のときの出力 (CH1) | 約 +0.7 V | D1 がクリップしている |
| 図1、入力 −5V のときの出力 (CH1) | 約 −0.7 V | D2 がクリップしている |
| 図2、出力の最小値 (CH1、DC 結合で見る) | 約 −0.7 V | D3 が下限をクランプしている |
| 図2、出力の最大値 (CH1、DC 結合で見る) | 約 +9.3 V | 波形全体が +4.3V 底上げされている |
| 図2、出力の振幅 (最大 − 最小) | 約 10 V (入力と同じ) | クランパは振幅を変えない (クリッパとの違い) |

## オシロで見る

CH1 (出力) と CH2 (入力) を同じ 2V/div で重ねる (DC 結合)。

```scope
title: 図5 クリッパの出力 (CH1) と入力 (CH2) — 出力は ±0.7 V で頭打ち
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: square 1kHz 5V | clip -0.7V 0.7V, range: 2V/div}
ch2: {wave: square 1kHz 5V, range: 2V/div}
measure: [vmax, vmin, vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/09-diode-clipper-clamper-1.svg)

```scope
title: 図6 クランパの出力 (CH1) と入力 (CH2) — 形はそのまま +4.3 V 持ち上がる
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: square 1kHz 5V | offset 4.3V, range: 2V/div, position: -1div}
ch2: {wave: square 1kHz 5V, range: 2V/div, position: -1div}
measure: [vmax, vmin, vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/09-diode-clipper-clamper-2.svg)

## 出典

自作。
