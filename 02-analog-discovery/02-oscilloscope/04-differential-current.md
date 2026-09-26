---
book: analog-discovery
chapter: 2
id: 2-4
title: 差動入力で電流を測る — 1 Ω の両端
tier: 50
source: 自作
board: BB
---

# 2-4 差動入力で電流を測る — 1 Ω の両端

オシロには電流を直接測る入力は無いが、**1 Ω のような小さい既知の抵抗を
直列に入れ、その両端の電圧を差動入力で読む**と、電圧の値がそのまま
電流 [mA] になる (V = I × 1 Ω なので、mV の値 = mA の値)。

## 回路図

```circuit
title: 図1 LED の電流を 1 Ω で測る
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

V+ (5 V) → R1 (330 Ω) → LED → Rs (1 Ω、電流検出用) → GND。CH1 (`1+` /
`1-`) を Rs の両端につなぎ、差動で読む。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで LED の電流を測る
board: half
parts:
  R1: resistor b8 b12 330
  D1: led c12(A) c14(K) red
  Rs: resistor e14 e18 1R
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, 1+, 1-, GND]
wires:
  - AD.V+ -- a8 red
  - AD.1+ -- a14 orange
  - a18 -- -t18 black
  - AD.1- -- -t20 black
  - AD.GND -- -t22 black
```

Rs (1 Ω) は LED のカソード (14 列) の続きに置く。CH1 (`1+`) は 14 列の
別の穴 (a14) から取り、Rs の先 (18 列) と `1-` は GND レールへ落とす。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Scope (CH1) | DC、Range を ±50 mV 程度まで絞る (1 Ω の電圧はとても小さい) |

## 見るべき値

| 測る所 | 期待する値 (計算値) | 計算 |
| --- | --- | --- |
| LED の電流 | 約 9.1 mA | (5 V − LED の V<sub>F</sub> 2.0 V) ÷ (330 Ω + 1 Ω) ≈ 9.06 mA |
| CH1 (Rs の両端) | 約 9.1 mV | 9.06 mA × 1 Ω。**mV の値がそのまま mA の値** |
| Rs で消費する電力 | 約 0.08 mW | 9.06 mA × 9.1 mV。R1 (約 27 mW) に比べて無視できるほど小さく、測定用の抵抗として電流をほぼ乱さない |

Range をいつもどおり (±5 V など) にしたままだと、9 mV は画面の中で
ほぼ 1 本の線に見えてしまう。**Range を測りたい値に合わせて絞る**のが
小さい電圧を読むコツ。

## 出典

自作。
