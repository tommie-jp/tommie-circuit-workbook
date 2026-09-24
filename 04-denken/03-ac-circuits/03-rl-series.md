---
book: denken
chapter: 3
id: 3-3
title: RL 直列 — インピーダンスとベクトル図
tier: 50
source: 自作
board: BB
---

# 3-3 RL 直列 — インピーダンスとベクトル図

抵抗とコイルを直列につなぐと、電圧の足し算は単純な数の足し算にならない。
**R の電圧と L の電圧は 90° 位相がずれているので、ベクトルとして足す**必要が
ある。AD の 2 ch で R と L それぞれの電圧を測り、ベクトル図で確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| X_L = ωL = 2πfL | コイルのリアクタンス |
| Z = √(R² + X_L²) | RL 直列のインピーダンス (合成した「抵抗」) |
| tan θ = X_L / R | 電圧が電流より進む角度 θ |
| V = √(V_R² + V_L²) | 電源電圧は V_R と V_L のベクトル和の大きさ (ピタゴラスの定理) |

## 回路図

```circuit
title: 図1 RL 直列
style:
  standard: jis
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  R1: resistor c1 c5 100
  L1: inductor c5 c9 15m
  M1: voltmeter a1 a5 l=$\mathrm{CH1}$
  M2: voltmeter e5 e9 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - a1 -- c1
  - a5 -- c5
  - e5 -- c5
  - e9 -- c9
  - c9 -- c13
  - c13 -- g13
  - g13 -- g1
```

- CH1 が R1 の両端 (電流と同位相)、CH2 が L1 の両端 (電流より 90° 進む)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 100
  L1: inductor/axial d10 d15 15m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-", "2+", "2-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 blue [h10]
  - AD.1- -- a10 orange
  - AD.2+ -- b10 white [h10]
  - AD.2- -- a15 green
  - e15 -- -t15 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.7 V |
| Scope | CH1・CH2 とも DC 結合。Measure で CH1・CH2 の Amplitude (振幅) と、CH1 に対する CH2 の Phase を読む |

## 見るべき値

計算値 (R = 100 Ω、L = 15 mH、f = 1 kHz、振幅 0.7 V)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| X_L = 2πfL | 94.2 Ω | コイルのリアクタンス |
| Z = √(R² + X_L²) | 137 Ω | 直列インピーダンス |
| 電流の振幅 I = V / Z | 5.1 mA | 回路に流れる電流 |
| CH1 (V_R = I × R) | 0.51 V | 電流と同位相 |
| CH2 (V_L = I × X_L) | 0.48 V | 電流より 90° 進む |
| CH2 の CH1 に対する位相 | +43° (≈ tan⁻¹(94.2/100)) | ベクトル図の角度 θ |

**ベクトルで確かめる**: V_R と V_L は 90° 直角なので、√(V_R² + V_L²) =
√(0.51² + 0.48²) ≈ 0.70 V。これが電源の振幅 (0.7 V) にほぼ一致する
(単純に 0.51 + 0.48 = 0.99 V ではない。ここが直流の直列と違う所)。

分かること:

- **電圧を単純に足すと合わない。** RL 直列では V_R と V_L が 90° ずれているので、
  足し算は必ずベクトル (フェーザ) で行う
- インピーダンス Z も同じベクトルの考え方で、R と X_L を直角の 2 辺とする
  直角三角形の斜辺になる
- 周波数を上げると X_L が大きくなり、θ が 90° に近づく (3-9 で周波数特性を測る)

## 出典

自作。
