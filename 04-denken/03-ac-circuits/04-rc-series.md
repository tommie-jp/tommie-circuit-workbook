---
book: denken
chapter: 3
id: 3-4
title: RC 直列 — 電圧の和はベクトルの和
tier: 50
source: 自作
board: BB
---

# 3-4 RC 直列 — 電圧の和はベクトルの和

RL 直列 (3-3) と同じ考え方を、今度は抵抗とコンデンサの直列で確かめる。
コンデンサは電流が電圧より 90° 進むので、R の電圧と C の電圧はやはり
90° ずれる。テスターで別々に測った電圧を単純に足しても電源電圧にならない
ことを、実際に測って確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| X_C = 1 / (ωC) = 1 / (2πfC) | コンデンサのリアクタンス |
| Z = √(R² + X_C²) | RC 直列のインピーダンス |
| tan θ = X_C / R | 電圧が電流より遅れる角度 θ |
| V = √(V_R² + V_C²) | 電源電圧は V_R と V_C のベクトル和の大きさ |

## 回路図

```circuit
title: 図1 RC 直列
style:
  standard: jis
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  R1: resistor c1 c5 1k
  C1: capacitor c5 c9 100n
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

- CH1 が R1 の両端 (電流と同位相)、CH2 が C1 の両端 (電流より 90° 遅れる)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor/ceramic d10 d15 100n
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
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1・CH2 とも DC 結合。Measure で Amplitude と、CH1 に対する CH2 の Phase を読む |

## 見るべき値

計算値 (R = 1 kΩ、C = 100 nF、f = 1 kHz、振幅 1 V)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| X_C = 1 / (2πfC) | 1592 Ω | コンデンサのリアクタンス |
| Z = √(R² + X_C²) | 1880 Ω | 直列インピーダンス |
| 電流の振幅 I = V / Z | 0.53 mA | 回路に流れる電流 |
| CH1 (V_R = I × R) | 0.53 V | 電流と同位相 |
| CH2 (V_C = I × X_C) | 0.85 V | 電流より 90° 遅れる |
| CH2 の CH1 に対する位相 | −58° | ベクトル図の角度 θ (電圧が電流より遅れる) |

**ベクトルで確かめる**: √(V_R² + V_C²) = √(0.53² + 0.85²) ≈ 1.00 V。
これが電源の振幅 (1 V) に一致する。テスターで V_R と V_C を測って単純に
足すと 0.53 + 0.85 = 1.38 V となり、電源電圧の 1 V を超えてしまう —
これは測り方の間違いではなく、**足し算がベクトルでないと合わない**という
交流の性質そのもの。

分かること:

- RL (3-3) は電圧が電流より**進む**、RC は電圧が電流より**遅れる**。
  進み・遅れが逆になる
- 周波数を上げると X_C が小さくなり (RL の X_L は逆に大きくなる)、
  θ が 0° に近づく (3-9 で周波数特性を測る)
- R と C を入れ替えて測っても Z や θ は同じ (直列では順番によらない)

## 出典

自作。
