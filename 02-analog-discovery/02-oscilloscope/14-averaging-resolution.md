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

Scope の ADC は 14 bit。公式仕様では「平均化を使うと 16 bit 相当」ともある。
ここでは 2-4 で見た、ほとんど 1 本の線にしか見えなかった 9.1 mV の信号を
題材に、**Sampling Mode を Average にする**とどう変わるかを確かめる。

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

2-4 とまったく同じ回路。V+（5 V）→ R1（330 Ω）→ LED → Rs（1 Ω）→ GND。CH1 は
Rs の両端（≈ 9.1 mV、mV の値がそのまま mA の値）。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで LED の電流を測る (2-4 と同じ)
board: half
parts:
  R1: resistor c5 c10 330
  D1: led c12(A) c14(K) red
  Rs: resistor d14 d18 1R
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- a5 red
  - c10 -- d12 orange
  - AD.1+ -- e14 yellow
  - c18 -- -t18 black
  - AD.1- -- -t20 black
  - AD.GND -- -t22 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Scope (CH1) | DC、**Range を最も細かい帯（≤ 0.5 V/div）まで絞る**、Sampling Mode を Normal → Average と切り替える |

## 見るべき値

CH1 の期待値は 2-4 のとおり **約 9.1 mV（計算値）**。公式仕様の
Absolute Resolution（≤ 0.5 V/div の帯）は **0.32 mV（AD2）／0.336 mV（AD3）** —
これが ADC 1 ステップぶんの電圧。

| Sampling Mode | 見え方 | 分解能の目安 |
| --- | --- | --- |
| Normal（生の 14 bit） | 9.1 mV 付近で、線が ±0.3〜0.6 mV ほど**もやもや太い**（ノイズ＋量子化） | 1 LSB ≈ 0.32 mV |
| Average（N = 16 点を平均） | 同じ 9.1 mV 付近で、線の太さが**約 1/4 に細くなる** | 実効の 1 LSB ≈ 0.32 mV ÷ 4 ≈ **0.08 mV（計算値）** |

ノイズは平均する点数の**平方根**で減る（N = 16 → √16 = 4 倍改善）。
2<sup>16</sup> / 2<sup>14</sup> = 4 なので、この 4 倍という数字が
「14 bit → 16 bit 相当」という仕様の言い方の中身になる。

| 項目 | 値 | 計算 |
| --- | --- | --- |
| 9.1 mV は Normal の 1 LSB の何倍か | 約 28 倍 | 9.1 mV ÷ 0.32 mV ≈ 28.4 |
| N = 16 平均で減るノイズの比 | 1/4 | √16 = 4 |
| Average 後の実効分解能 | 約 0.08 mV（≈ 16 bit 相当） | 0.32 mV ÷ 4 |

平均化は**直流や、変化がゆっくりな信号**でこそ効く（1-9 の LM35 の出力もその
一例）。速く変化する波形を平均すると、変化そのものがならされてしまうので
使い所を選ぶ。

## 出典

自作。分解能の数値は Digilent の Analog Discovery 2 / 3 の公式仕様
（Absolute Resolution の節）による。
