---
book: analog-discovery
chapter: 6
id: 6-1
title: 抵抗の |Z| と位相 — 基準抵抗で測る仕組み
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-1 抵抗の |Z| と位相 — 基準抵抗で測る仕組み

WaveForms の **Impedance** (インピーダンスアナライザ) は、専用のアダプタが無くても
**既知の基準抵抗 Rref** を 1 本足すだけで測れる。W1 で正弦波を出し、Rref と DUT を
直列につないで、Rref の両端 (電流に比例) と DUT の両端 (電圧) をオシロの 2 ch で
同時に読む。既知の抵抗を測って、この仕組み自体が合っているかを確かめるのがこの題。
アダプタを使う自動レンジは 6-5 で扱う。

## 回路図

```circuit
title: 図1 基準抵抗と DUT を直列にして電流と電圧を読む
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 1k
  Rdut: resistor c9 c12 1k l=$\mathrm{R_{DUT}}$
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

- **1+/1− が Rref の両端**。読んだ電圧 V1 を Rref で割ると、直列に流れている電流
  I = V1 / Rref が分かる
- **2+/2− が DUT の両端**。読んだ電圧 V2 と I から Z<sub>DUT</sub> = V2 / I = Rref × V2 / V1
- 位相は 2ch の波形が 1ch に対してどれだけずれているかで読む。**抵抗は理想上 0°**

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 1k
  Rdut: resistor d10 d14 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 green
  - AD.2+ -- b10 white [h10]
  - AD.2- -- b14 gray
  - a14 -- -t14 black
  - AD.GND -- -t17 black
```

- 5 列が W1 の節点、10 列が Rref と R<sub>DUT</sub> の中点 (同じ列なので行が違ってもつながる)、
  14 列が GND
- 1+ (橙) と W1 (黄) は同じ 5 列に挿すので、1+ は半列右から回して重ねない ([h10])。
  10 列の 1− と 2+ も同じ
- R<sub>DUT</sub> は今回は既知の 1 kΩ。ほかの部品に差し替えれば同じ配線でその Z を測れる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1 = Rref の両端 (差動)、CH2 = DUT の両端 (差動)。Range は両方 1 V/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

Rref は **DUT と同じ桁の値**を選ぶ (ここは両方 1 kΩ)。桁が離れると、片方の読みが
小さくなりすぎて誤差が増える。

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (Rref の両端) | 0.500 V | I = 0.500 mA |
| CH2 (DUT の両端) | 0.500 V | V2 |
| Z<sub>DUT</sub> = Rref × V2 / V1 | 1.00 kΩ、位相 0° | 既知の 1 kΩ と一致 → 仕組みが合っている |

DUT を 1 kΩ 以外に替えたときも同じ式で Z が出る。位相が 0° からずれたら、
その部品は純抵抗ではない (6-2・6-3 のコンデンサ・コイルで確かめる)。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
