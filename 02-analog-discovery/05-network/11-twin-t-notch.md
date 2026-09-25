---
book: analog-discovery
chapter: 5
id: 5-11
title: ツイン T ノッチ
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-11 ツイン T ノッチ

**ツイン T** は、R・R・2R の枝と C・C・C/2 の枝を並列にしただけの受動回路なのに、
ある 1 つの周波数だけをほぼ完全に落とす**ノッチ (帯域阻止) フィルタ**になる。
5-1〜5-9 のローパス・ハイパスとは違う「谷が 1 本だけ」という形を Network で見る。

## 回路図

```circuit
title: 図1 ツイン T ノッチ
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  Gv: ground c1
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  Gm1: ground c3
  R1: resistor a5 a9 10k
  R2: resistor a9 a13 10k
  R3: resistor a9 c9 20k l=$\mathrm{2R}$
  Gr3: ground c9
  C1: capacitor e5 e9 10n
  C2: capacitor e9 e13 10n
  C3: capacitor e9 g9 5n
  Gc3: ground g9
  M2: voltmeter a15 c15 l=$\mathrm{CH2}$
  Gm2: ground c15
wires:
  - a1 -- a3 -- a5
  - a5 -- e5
  - a13 -- e13
  - a13 -- a15
```

- **上の枝 (R・R・2R)**: R1・R2 (各 10 kΩ) が入力から出力へ直列に並び、中点
  (a9) から 2R (20 kΩ) が GND へ落ちる
- **下の枝 (C・C・C/2)**: C1・C2 (各 10 nF) が入力から出力へ直列に並び、中点
  (e9) から C/2 (5 nF) が GND へ落ちる。入力 (5 列) と出力 (13 列) は上下の
  枝で共有 (`a5--e5`、`a13--e13` の縦線)
- ノッチ周波数 **f₀ = 1/(2πRC) = 1/(2π × 10 kΩ × 10 nF) ≈ 1.59 kHz**
  (5-1 と同じ f<sub>c</sub> になるよう部品を選んだ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  R1: resistor c5 c11 10k
  R2: resistor d11 d20 10k
  R3: resistor e11 e13 20k
  C1: capacitor a5 a14 10n
  C2: capacitor b14 b20 10n
  C3: capacitor e14 e16 5n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- d5 orange [h5]
  - AD.1- -- -t8 black
  - c13 -- -b13 black
  - a16 -- -b16 black
  - AD.2+ -- c20 blue [h5]
  - AD.2- -- -t22 black
```

- **上の枝**: R1 (5〜11 列、行 c) → ノード A (11 列) → R2 (11〜20 列、行 d)。
  ノード A から R3 (2R = 20 kΩ、11〜13 列、行 e) が下レールへ
- **下の枝**: C1 (5〜14 列、行 a) → ノード B (14 列) → C2 (14〜20 列、行 b)。
  ノード B から C3 (C/2 = 5 nF、14〜16 列、行 e) が下レールへ。**R3 と C3 は
  同じ行 (e) だが列がずれている (11〜13 と 14〜16) ので別のノードのまま**
- 入力 (5 列) は R1・C1 の左端が共有、出力 (20 列) は R2・C2 の右端が共有。
  ノード A (R の中点) とノード B (C の中点) は**別の列**なので互いにつながらない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 150 Hz、Stop 15 kHz、Log、Steps 201 (谷が細いので点数を増やす)、Reference: Channel 1 |

## 見るべき値

計算値。回路方程式から求めた伝達関数
H(jω) = (1 − (ωRC)²) / (1 − (ωRC)² + 4jωRC)。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 159 Hz (0.1×f₀) | −0.66 dB | −22.0° |
| 1.43 kHz (0.9×f₀) | −25.6 dB | −87.0° |
| **1.59 kHz (f₀)** | **理想は −∞ (深い谷)** | 谷の直前後で ±90° 付近から反転 |
| 1.75 kHz (1.1×f₀) | −26.4 dB | +87.3° |
| 15.9 kHz (10×f₀) | −0.66 dB | +22.0° |

分かること:

- **f₀ をまたいで利得が急に深く落ち、また戻る。** ローパス・ハイパスのような
  「そこから先はずっと落ちたまま」ではなく、**1 点だけ落ちてすぐ回復する**のが
  ノッチの形。実測の谷の深さは部品の精度 (R・C のばらつき) で決まり、1%
  精度の部品でも −30〜−40 dB 程度が目安 (理論の −∞ には届かない)
- **谷の下側 (f < f₀) と上側 (f > f₀) で位相の符号が反転する。** 下側では
  入力より遅れ (−側)、上側では進み (+側) になり、ちょうど f₀ で符号が
  入れ替わる — 5-9 の自己共振 (SRF) で見た位相反転と同じ考え方
- **上下で対称な形。** 0.1×f₀ と 10×f₀、0.9×f₀ と 1.1×f₀ で利得の値がそれぞれ
  同じ (−0.66 dB、−25.6 / −26.4 dB とほぼ対称) になっている。ツイン T の
  R・R・2R と C・C・C/2 という部品比がこの対称性を作っている

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。ツイン T の伝達関数は回路方程式による導出 (自分で確かめた)。
