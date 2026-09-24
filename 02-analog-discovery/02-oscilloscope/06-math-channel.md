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
  W1: sine a1 c1 1
  R1: resistor a1 a3 100
  Rs: resistor a3 a5 1R
  G1: ground a5
  M1: voltmeter b7 d7 l=$\mathrm{CH1}$
  M2: voltmeter e3 e5 l=$\mathrm{CH2}$
wires:
  - a1 |- b7
  - c1 |- d7
  - a3 -- e3
  - a5 -- e5
```

W1 (1 kHz、振幅 1 V) → R1 (100 Ω) → Rs (1 Ω) → GND。CH1 は W1 の出力
そのもの、CH2 は Rs の両端 (= 電流を mV の値で表したもの)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで電圧と電流を測る
board: half
parts:
  R1: resistor c5 c10 100
  Rs: resistor d10 d15 1R
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- a15 black
  - AD.1+ -- b5 yellow
  - AD.1- -- b15 black
  - AD.2+ -- b10 yellow
  - AD.2- -- c15 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1・CH2) | DC。CH2 の Range は ±20 mV 程度まで絞る |
| Math 1 | `CH1 − CH2` (R1 単体の両端の電圧) |
| Math 2 | `CH1 × CH2` (瞬時電力。CH2 は 1 Ω の両端なので、数値としては電流 [A] と同じ) |
| Math 3 | `∫ CH2 dt` (電荷。積分区間はグラフの表示幅いっぱい) |

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
