---
book: denken
chapter: 3
id: 3-6
title: 有効電力・無効電力・皮相電力と力率
tier: 50
source: 自作
board: BB
---

# 3-6 有効電力・無効電力・皮相電力と力率

交流の電力には 3 つの顔がある。**実際に仕事をする有効電力 P**、
**行ったり来たりするだけで仕事をしない無効電力 Q**、**その両方を合わせた
大きさの皮相電力 S**。3 つの関係を、遅れ力率の負荷 (抵抗 + コイル) で
実測する。3-7 の力率改善の土台になる回路。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| cos θ = R / √(R² + X_L²) | 力率 (遅れ)。負荷の抵抗とリアクタンスの比で決まる |
| P = V I cos θ | 有効電力。実際に熱として消費される分 |
| Q = V I sin θ | 無効電力。コイルと電源の間を往復するだけの分 |
| S = V I = √(P² + Q²) | 皮相電力。P と Q のベクトル和の大きさ |

## 回路図

```circuit
title: 図1 遅れ力率の負荷 (R1 + L1)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c4 10 i=I
  M2: voltmeter a1 a4 l=$\mathrm{CH2}$
  M1: voltmeter c6 g6 l=$\mathrm{CH1}$
  R1: resistor c8 e8 47
  L1: inductor e8 g8 10m
  G1: ground g6
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c6 -- c8
  - g1 -- g6 -- g8
```

- V1 は AD の波形発生器 W1。Rs (10 Ω) は線電流 I を測るシャント。
  CH2 は Rs の両端 (差動)、CH1 は受電端 (R1 + L1) の電圧
- R1 + L1 が遅れ力率の負荷。3-7 ではこの負荷にコンデンサを並列に足す

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rs: resistor c5 c10 10
  R1: resistor d10 d15 47
  L1: inductor/axial c15 c20 10m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "2+", "1+", "2-", "1-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 blue [h10]
  - AD.1+ -- a10 orange
  - AD.2- -- b10 white [h10]
  - AD.1- -- -t12 black
  - a20 -- -t20 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V |
| Scope | CH1 = 受電端の電圧、CH2 = Rs の電圧 (= 10 Ω × 電流)。Average を 16 回 |
| Math | M1 = C1 × C2 / 10 (瞬時電力 p、単位 W)。Measure で M1 の Average が有効電力 P |
| Measure | CH1・CH2 の RMS、CH1 に対する CH2 の Phase (位相差 θ。cos θ が力率) |

**電流の上限**: AD の波形発生器は 10 mA まで。この回路の線電流は最大値で
5.9 mA なので余裕がある。

## 見るべき値

計算値。10 mH の小さなコイルは巻線抵抗 (数 Ω〜数十 Ω) を持ち、その分
R が大きく見えて力率は計算より少し良くなる。巻線抵抗をテスターで測り、
R1 に足して計算し直すとよい。

| 測る所 | 期待する値 |
| --- | --- |
| X_L = 2πfL | 62.8 Ω |
| 力率 cos θ = R1 / √(R1² + X_L²) | 0.60 (遅れ) |
| 線電流の最大値 (CH2 ÷ 10 Ω) | 5.9 mA |
| 受電端の電圧の最大値 (CH1) | 0.462 V |
| 負荷の有効電力 P | 0.82 mW |
| 無効電力 Q | 1.09 mW |
| 皮相電力 S = √(P² + Q²) | 1.36 mW |

分かること:

- **P・Q・S は直角三角形の関係。** P が底辺、Q が高さ、S が斜辺
  (力率 cos θ = P / S)
- **力率が 1 に近いほど、同じ皮相電力 (見かけの容量) でより多くの有効電力を
  運べる。** 力率が低いと、線路や発電設備の容量を無駄に使うことになる
- コイルを抵抗だけの負荷に替えると (X_L = 0)、cos θ = 1、Q = 0 になり、
  P = S になることも確かめられる
- この負荷に並列にコンデンサを足すと、線電流が減って力率が改善する
  (3-7 で確かめる)

## 出典

自作。
