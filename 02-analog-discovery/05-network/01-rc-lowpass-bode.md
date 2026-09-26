---
book: analog-discovery
chapter: 5
id: 5-1
title: RC ローパスのボード線図
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-1 RC ローパスのボード線図

**Network** はW1 の周波数を自動で掃引し、CH1 (基準) に対する CH2 (応答) の
利得と位相を測ってボード線図を描く計器。3-2 では手動で Sweep を追ったが、
ここからは Network に任せる。RC ローパス 1 個の教科書どおりの形を確かめる。

## 回路図

```circuit
title: 図1 RC ローパス
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 1k
  C1: capacitor a7 c7 100n
  M2: voltmeter a9 c9 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c7 -- c9
  - a7 -- a9
```

R1 = 1 kΩ、C1 = 100 nF → **f<sub>c</sub> = 1 / (2πRC) ≈ 1.59 kHz**。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor d10 d14 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
  - a14 -- -t14 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V (Network が自動で掃引する) |
| Network | Start 100 Hz、Stop 100 kHz、**Log**、Steps 101、Reference: Channel 1、表示: Bode (利得 dB・位相 deg) |

## 見るべき値

計算値。利得 (dB) = 20 log₁₀ (1 / √(1 + (f/f<sub>c</sub>)²))、
位相 = −arctan(f / f<sub>c</sub>)。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 Hz | −0.02 dB (ほぼ 0 dB) | −3.6° |
| 1.59 kHz (f<sub>c</sub>) | −3.01 dB | −45.0° |
| 10 kHz | −16.07 dB | −81.0° |
| 100 kHz | −35.96 dB | −89.1° |

分かること:

- **f<sub>c</sub> を境に −20 dB/decade で下がる。** 10 kHz (f<sub>c</sub> の約 6.3 倍) で
  −16 dB、100 kHz (約 63 倍) で −36 dB と、10 倍ごとに約 20 dB ずつ下がっている
  ことをカーソルで確かめる
- **位相は f<sub>c</sub> でちょうど −45°**、低い周波数では 0° に、高い周波数では
  −90° に近づく。−3 dB 点と −45° 点が同じ周波数に来るのが 1 次ローパスの特徴
  (5-4 で詳しく読む)
- 100 kHz でも Amplitude 1 V の W1 は問題なく出せる (Wavegen の帯域は 9 MHz
  程度まで、3-15 参照)。ブレッドボードの寄生 (8-4) の影響はこの周波数ではまだ
  小さい

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
