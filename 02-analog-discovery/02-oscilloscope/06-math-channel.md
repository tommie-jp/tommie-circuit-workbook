---
book: analog-discovery
chapter: 2
id: 2-6
title: Math チャネル — 差・積 (瞬時電力)・積分
tier: 50
source: 自作
board: BB
---

# 2-6 Math チャネル — 差・積 (瞬時電力)・積分

Scope の **Math チャネル**は、2 つの入力を演算した波形を新しい 1 本の
トレースとして表示する機能。CH1 (電源の電圧) と CH2 (1 Ω の両端 = 電流)
を使い、差・積・積分の 3 つを試す。

## 回路図

```circuit
title: 図1 電圧と電流をそれぞれ測る
parts:
  M1: voltmeter a1 c1 l=$\mathrm{CH1}$
  W1: sine a3 c3 1
  R1: resistor a3 a6 100
  Rs: resistor a6 c6 1
  M2: voltmeter a8 c8 l=$\mathrm{CH2}$
  G1: ground c3
wires:
  - a1 -- a3
  - a6 -- a8
  - c1 -- c3 -- c6 -- c8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/06-math-channel.svg)

W1 (1 kHz、振幅 1 V) → R1 (100 Ω) → Rs (1 Ω) → GND。CH1 は W1 の出力
そのもの、CH2 は Rs の両端 (= 電流を mV の値で表したもの)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで電圧と電流を測る
board: half
parts:
  R1: resistor c7 c10 100
  Rs: resistor d10 d15 1R
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 2+, 1-, GND, 2-]
wires:
  - AD.W1 -- b7 yellow
  - AD.GND -- b15 black
  - AD.1+ -- a7 orange
  - AD.1- -- a15 black
  - AD.2+ -- b10 blue
  - AD.2- -- c15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/06-math-channel.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1・CH2) | DC。CH2 の Range は ±20 mV 程度まで絞る |
| Math 1 | `CH1 − CH2` (R1 単体の両端の電圧) |
| Math 2 | `CH1 × CH2` (瞬時電力。CH2 は 1 Ω の両端なので、数値としては電流 [A] と同じ) |
| Math 3 | `∫ CH2 dt` (電荷。積分区間はグラフの表示幅いっぱい) |

CH2 は 9.9 mV しか振れないので 5 mV/div に絞る (CH1 とは別の尺度)。
Math は瞬時電力 CH1 × CH2 (1 Ω なので V² の数がそのまま W)。
CH1 と CH2 は尺度を変えたので、画面の上ではぴったり重なる (電流は電圧と同位相)。

```scope
title: 図3 瞬時電力 (Math) は 2 倍の周波数で振れ、平均は 4.95 mW で 0 にならない
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | gain 0.0099, range: 5mV/div}
math: {expr: ch1 * ch2, unit: W, range: 2mW/div, position: -3div}
measure: [vmax, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/06-math-channel.svg)

## 見るべき値

| 項目 | 期待する値 (計算値) | 計算 |
| --- | --- | --- |
| ピーク電流 | 9.90 mA | 1 V ÷ (100 Ω + 1 Ω) |
| CH2 のピーク | 9.90 mV | 9.90 mA × 1 Ω |
| Math 1 (CH1−CH2) のピーク | 約 0.990 V | R1 (100 Ω) 単体の両端。CH1 とほぼ同じに見えるが、CH2 のぶん (約 1%) だけ小さい |
| Math 2 (CH1×CH2) の平均 | 約 4.95 mW | I<sub>rms</sub>² × (R1 + Rs) = (9.90 mA / √2)² × 101 Ω |
| Math 3 (∫CH2 dt) を 1 周期分見る | ほぼ 0 C に戻る | 交流 1 周期の電荷の正味移動は 0 (電流の平均が 0 のため)。**電力の平均は 0 ではない**点と対比させる |

## 出典

自作。
