---
book: denken
chapter: 3
id: 3-5
title: RLC 直列共振 — 共振周波数で電流が最大
tier: 50
source: 自作
board: BB
---

# 3-5 RLC 直列共振 — 共振周波数で電流が最大

コイルとコンデンサを直列にすると、ある周波数で**リアクタンスがちょうど
打ち消し合い**、回路はまるで抵抗だけのように振る舞う。この周波数
(共振周波数) で電流が最大になることを、周波数を掃引して確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| f0 = 1 / (2π√(LC)) | 共振周波数。X_L = X_C になる周波数 |
| Z_min = R | 共振時のインピーダンスは R だけ (リアクタンスが打ち消し合う) |
| I_max = V / R | 共振時の電流は最大で、抵抗だけで決まる |

## 回路図

```circuit
title: 図1 RLC 直列
style:
  standard: jis
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  R1: resistor c1 c5 150
  L1: inductor c5 c9 100m
  C1: capacitor c9 c13 100n
  M1: voltmeter a1 a5 l=$\mathrm{CH1}$
  M2: voltmeter e5 e13 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - a1 -- c1
  - a5 -- c5
  - e5 -- c5
  - e13 -- c13
  - c13 -- c17
  - c17 -- g17
  - g17 -- g1
```

- CH1 が R1 の両端 (÷ R で電流になる)、CH2 が L1 + C1 をまとめた両端
  (共振ではここが 0 に近づく)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 150
  L1: inductor/axial d10 d15 100m
  C1: capacitor/ceramic c15 c20 100n
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
  - AD.2- -- a20 green
  - e20 -- -t20 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、Amplitude 1 V。周波数を 500 Hz〜2 kHz の間で振る |
| Scope | CH1・CH2 とも DC 結合。Measure で CH1 の Amplitude (÷ R1 で電流) を読む |

## 見るべき値

計算値 (R = 150 Ω、L = 100 mH、C = 100 nF、振幅 1 V)。共振周波数
f0 = 1 / (2π√(0.1 × 100×10⁻⁹)) ≈ **1.59 kHz**。

| 周波数 | 電流の振幅 (CH1 ÷ 150 Ω) | 備考 |
| --- | --- | --- |
| 500 Hz | 0.35 mA | 共振より低い (C が支配的) |
| 800 Hz | 0.67 mA | |
| **1.59 kHz (f0)** | **6.67 mA (最大)** | X_L = X_C = 1000 Ω で打ち消し合う |
| 1.3 kHz | 2.30 mA | |
| 2.0 kHz | 2.06 mA | 共振より高い (L が支配的) |

共振時: CH1 (V_R) = 1.00 V (= 電源電圧そのもの)、CH2 (V_L+C) ≈ 0 V。
V_L = V_C = I × X_L = 6.67 mA × 1000 Ω = 6.67 V (電源電圧の 1 V よりずっと
大きい。L と C の電圧が電源電圧を超える現象は 3-16 で扱う)。

分かること:

- **共振周波数で電流が最も大きくなる。** 低い周波数では C のリアクタンスが、
  高い周波数では L のリアクタンスが電流を妨げる
- **共振では L と C の電圧が互いに逆位相でほぼ打ち消し合う** (CH2 がほぼ 0 に
  なる)。個々の電圧 (6.67 V) は大きいのに、足し合わせると小さくなるのは
  ベクトル (フェーザ) で考える交流ならでは
- 巻線抵抗のある実物のコイルでは、R がもう少し大きくなるぶん、電流の
  ピークは表より少しなだらかになる

## 出典

自作。
