---
book: analog-discovery
chapter: 5
id: 5-9
title: 2 段 RC と −40 dB/dec
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-9 2 段 RC と −40 dB/dec

5-1 の RC ローパス (1 次、−20 dB/dec) をもう 1 段足すと、2 次のローパスになる。
2 段目のインピーダンスを 1 段目の**10 倍**にして、2 段目が 1 段目を大きく
負荷しないようにすると、f<sub>c</sub> が同じ 2 つのローパスを単純にかけ合わせた
形に近くなる。−20 dB/dec が −40 dB/dec に変わる様子を見る。

## 回路図

```circuit
title: 図1 2 段の RC ローパス
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 1k
  C1: capacitor a7 c7 100n
  R2: resistor a9 a11 10k
  C2: capacitor a11 c11 10n
  M2: voltmeter a13 c13 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c7 -- c11 -- c13
  - a7 -- a9
  - a11 -- a13
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/09-two-stage-rc-40db.svg)

- 1 段目: R1 = 1 kΩ、C1 = 100 nF → f<sub>c1</sub> = 1/(2πR1C1) ≈ 1.59 kHz
- 2 段目: R2 = 10 kΩ、C2 = 10 nF → f<sub>c2</sub> = 1/(2πR2C2) ≈ 1.59 kHz
  (**同じ f<sub>c</sub>**。R2C2 = R1C1 になるように選んだ)
- **R2 は R1 の 10 倍。** 2 段目の入力インピーダンスが 1 段目より十分大きいので、
  1 段目はほとんど負荷されない (完全に無視はできないので、見るべき値は
  負荷込みで計算した)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor d10 d13 100n
  R2: resistor b10 b15 10k
  C2: capacitor d15 d18 10n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t9 black
  - a13 -- -t13 black
  - AD.2+ -- a15 blue
  - AD.2- -- -t17 black
  - a18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/09-two-stage-rc-40db.svg)

- R1 (5〜10 列) の出口が 10 列 (ノード A)。**C1 (10〜13 列) はノード A から
  GND へ落ちる枝**、R2 (10〜15 列) は同じ 10 列からそのまま 2 段目へ続く
  (列が同じなら行が違ってもつながる)。R2 の出口が 15 列 (ノード B) で、
  **C2 (15〜18 列) が GND へ落ちる枝**、2+ (CH2) も同じ 15 列から読む
- 1+ (CH1) は 1 段目の入り口 (5 列)、2+ (CH2) は 2 段目の出口 (15 列)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 100 Hz、Stop 200 kHz、Log、Steps 101、Reference: Channel 1 |

掃引の途中の f<sub>c</sub> (1.59 kHz) の 1 点を、オシロの時間波形で見たのが図3。2 段の伝達関数
H = 1 / ((1 − x²) + j2.1x) (x = f / f<sub>c</sub>、負荷込み。図4 の式と同じ) を f<sub>c</sub> (x = 1) で計算すると、
大きさ 1/2.1 = 0.476 (−6.44 dB)、位相 −90° になる。CH2 (C2 の電圧) は CH1 の 0.476 倍で、
山が 1/4 周期 (629 µs ÷ 4 ≈ 157 µs) 遅れる。

```scope
title: 図3 1.59 kHz の 1 点 — CH2 は 0.476 倍で 157 µs (90°) 遅れる
time: 100us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.59kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | lc 1.59kHz 0.476, range: 500mV/div}
cursors: [157us, 314us]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/09-two-stage-rc-40db.svg)

## 見るべき値

計算値。負荷 (2 段目が 1 段目を引く効果) を含めて回路方程式から計算した値。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 159 Hz (0.1×f<sub>c</sub>) | −0.10 dB | −12.0° |
| **1.59 kHz (f<sub>c</sub>)** | **−6.44 dB** | **−90.0°** |
| 15.9 kHz (10×f<sub>c</sub>) | −40.10 dB | −168.0° |
| 159 kHz (100×f<sub>c</sub>) | −80.00 dB | −178.8° |

図4 は 2 段 (負荷込み) と、5-1 の 1 段を同じ枠に重ねたもの。

```graph
title: 図4 2 段は 1 桁で −40 dB 落ちる (1 段は −20 dB)、fc で −6.44 dB・−90°
x: 周波数 Hz log 100..200k
y:
  - 利得 dB -100..0
  - 位相 deg -180..0
lines:
  2 段 利得 dB: -10*log10((1-(x/1591.5)^2)^2+(2.1*x/1591.5)^2)
  1 段 (5-1) 利得 dB: -10*log10(1+(x/1591.5)^2)
  2 段 位相 deg: -deg(atan2(2.1*x/1591.5, 1-(x/1591.5)^2))
  1 段 (5-1) 位相 deg: -deg(atan(x/1591.5))
notes:
  - mark 159
  - mark 1.59k
  - mark 15.9k
  - mark 159k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/09-two-stage-rc-40db.svg)

分かること:

- **10×f<sub>c</sub> で −40.1 dB、100×f<sub>c</sub> で −80.0 dB と、この 1 桁で
  39.9 dB 下がる。** 高い側では 1 桁ごとにほぼ 40 dB ずつ下がる —
  これが「2 次フィルタは −40 dB/decade」の意味。5-1 (1 次、−20 dB/dec) の
  ちょうど 2 倍
- **f<sub>c</sub> ちょうどでの利得は 5-1 の −3.01 dB の 2 倍 (−6.02 dB) にわずかに
  届かない (−6.44 dB)。** 2 段目が 1 段目を少し負荷する分、1 段目単体の
  −3.01 dB より深く落ちるため。**R2 を R1 の 10 倍にしても、負荷の影響は
  完全には消えない**ことが数値に表れている
- **位相は f<sub>c</sub> でちょうど −90°** (1 次の −45° の 2 倍)。高い周波数では
  −180° に近づく (2 段とも十分高い周波数では各段が −90° ずつ効くため)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
