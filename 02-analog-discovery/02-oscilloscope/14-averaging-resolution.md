---
book: analog-discovery
chapter: 2
id: 2-14
title: 平均化と 14 bit の分解能
tier: 100
source: 自作
board: BB
---

# 2-14 平均化と 14 bit の分解能

AD3 の Scope の ADC は 14 bit。公式仕様では「平均化を使うと 16 bit」ともあり、
リファレンスマニュアルには、サンプルを 16 bit で保存しているので**サンプルレートを
下げるほど分解能が上がる**（システムクロックの半分で 15 bit、4 分の 1 以下で 16 bit）と
ある。ここでは 2-4 で見た、ほとんど 1 本の線にしか見えなかった 9.1 mV の信号を
題材に、**Sampling Mode を Average にして Sample Rate を下げる**とどう変わるかを確かめる。

## 回路図

```circuit
title: 図1 LED の電流を 1 Ω で測る (2-4 と同じ)
parts:
  V1: vsource a1 c1 5
  R1: resistor a1 a3 330
  D1: led a3 a5
  Rs: resistor a5 a7 1R
  G1: ground a7
  M1: voltmeter e5 e7 l=$\mathrm{CH1}$
wires:
  - c1 -| a7
  - a5 -- e5
  - a7 -- e7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/14-averaging-resolution.svg)

2-4 とまったく同じ回路。V+（5 V）→ R1（330 Ω）→ LED → Rs（1 Ω）→ GND。CH1 は
Rs の両端（≈ 9.1 mV、mV の値がそのまま mA の値）。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで LED の電流を測る (2-4 と同じ)
board: half
parts:
  R1: resistor b8 b12 330
  D1: led c12(A) c14(K) red
  Rs: resistor e14 e18 1R
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, 1+, 1-, GND]
wires:
  - AD.V+ -- a8 red
  - AD.1+ -- a14 orange
  - a18 -- -t18 black
  - AD.1- -- -t20 black
  - AD.GND -- -t22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/14-averaging-resolution.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Scope (CH1) | DC、**Range を最も細かい帯（≤ 0.5 V/div）まで絞る**、Sampling Mode は Average。Sample Rate を 100 MS/s（既定のシステムクロックのまま）→ 50 MS/s → 25 MS/s 以下と下げて比べる。Normal との比較もする |

## 見るべき値

CH1 の期待値は 2-4 のとおり **約 9.1 mV（計算値）**。公式仕様の
Absolute Resolution（≤ 0.5 V/div の帯）は **0.336 mV** — これが 14 bit の ADC 1 ステップ
ぶんの電圧（ハードウェアの範囲 5.5 V ÷ 2<sup>14</sup> = 0.3357 mV。仕様の脚注に
「ハードウェア設計上の範囲 5.5 V と 55 V に基づく理想値」とある）。

システムクロックが既定の 100 MHz のとき、マニュアルの記述と、同じ範囲 5.5 V から
計算した 1 ステップの電圧は次のとおり。

| Sample Rate | 分解能（マニュアル） | 1 LSB の電圧（計算値） | 9.1 mV は何 LSB か |
| --- | --- | --- | --- |
| 100 MS/s（システムクロックと同じ） | 14 bit | 0.336 mV（仕様の値） | 約 27 LSB（9.1 ÷ 0.336） |
| 50 MS/s（クロックの半分） | 15 bit | 約 0.168 mV（5.5 V ÷ 2<sup>15</sup>） | 約 54 LSB |
| 25 MS/s 以下（クロックの 4 分の 1 以下） | 16 bit | 約 0.084 mV（5.5 V ÷ 2<sup>16</sup>） | 約 108 LSB |

2<sup>16</sup> / 2<sup>14</sup> = 4 なので、14 bit → 16 bit は 1 ステップが **1/4** になる
ということで、これが仕様の「平均化で 16 bit」の中身になる。

| 項目 | 値 | 計算 |
| --- | --- | --- |
| 14 bit の 1 LSB | 0.336 mV | 仕様（0.3357 mV） |
| 16 bit の 1 LSB | 約 0.084 mV | 0.336 mV ÷ 4 |
| 線の見え方 | Normal より Average・低いサンプルレートのほうが細くなる**はず** | 量子化の刻みが 1/4 になる分。実際の太さはノイズにも左右され、**変化の大きさは未確認** |

平均化は**直流や、変化がゆっくりな信号**でこそ効く（1-9 の LM35 の出力もその
一例）。速く変化する波形を平均すると、変化そのものがならされてしまうので
使い所を選ぶ。

## 出典

自作。分解能（14 bit・平均化で 16 bit・Absolute Resolution 0.336 mV・範囲 5.5 V）は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
（Analog Input の Vertical System）、15 bit・16 bit とサンプルレートの関係と既定のシステムクロック
100 MHz は
[Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
（Oscilloscope の節、Adjustable System Clock Frequency の節）による。
