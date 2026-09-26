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

**ツイン T** は、R・R と 2C の T 字と、C・C と R/2 の T 字を並列にしただけの受動回路なのに、
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
  C3: capacitor a9 c9 20n l=$\mathrm{2C}$
  Gc3: ground c9
  C1: capacitor e5 e9 10n
  C2: capacitor e9 e13 10n
  R3: resistor e9 g9 5k
  Gr3: ground g9
  M2: voltmeter a15 c15 l=$\mathrm{CH2}$
  Gm2: ground c15
wires:
  - a1 -- a3 -- a5
  - a5 -- e5
  - a13 -- e13
  - a13 -- a15
```

- **上の T (R・R と 2C)**: R1・R2 (各 10 kΩ) が入力から出力へ直列に並び、中点
  (a9) から 2C (C3 = 20 nF) が GND へ落ちる
- **下の T (C・C と R/2)**: C1・C2 (各 10 nF) が入力から出力へ直列に並び、中点
  (e9) から R/2 (R3 = 5 kΩ) が GND へ落ちる。入力 (5 列) と出力 (13 列) は上下の
  枝で共有 (`a5--e5`、`a13--e13` の縦線)
- ノッチ周波数 **f₀ = 1/(2πRC) = 1/(2π × 10 kΩ × 10 nF) ≈ 1.59 kHz**
  (5-1 と同じ f<sub>c</sub> になるよう部品を選んだ)
- **分路の素子は種類が入れ替わる**のがツイン T の要。抵抗の T の中点には
  **コンデンサ** (2C)、コンデンサの T の中点には**抵抗** (R/2) を落とす。
  同じ種類 (2R・C/2) を落とすと、上の T は抵抗だけ・下の T はコンデンサだけの
  分圧器になり、谷はできない
- 20 nF は 10 nF を 2 個並列、5 kΩ は 10 kΩ を 2 個並列で作ると、C・R と
  ちょうど 2 倍・半分の比がそろう (E 系列の 22 nF・4.7 kΩ で代えると f₀ と谷の深さがずれる)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  R1: resistor c5 c12 10k
  R2: resistor b12 b20 10k
  C3: capacitor d12 d14 20n
  C1: capacitor h5 h12 10n
  C2: capacitor g12 g20 10n
  R3: resistor i12 i16 5k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, GND, 1-, 2+, 2-]
wires:
  - AD.GND -- -t10 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t12 black
  - AD.2+ -- a20 blue
  - AD.2- -- -t22 black
  - e5 -- f5 yellow
  - e20 -- f20 blue
  - a14 -- -t14 black
  - j16 -- -b16 black
  - -t1 -- -b1 black
```

- **上の枝 (上のブロック)**: R1 (5〜12 列、行 c) → ノード A (12 列) → R2 (12〜20 列、行 b)。
  ノード A から C3 (2C = 20 nF、12〜14 列、行 d) が上の − レール (AD.GND) へ
- **下の枝 (下のブロック)**: C1 (5〜12 列、行 h) → ノード B (12 列) → C2 (12〜20 列、行 g)。
  ノード B から R3 (R/2 = 5 kΩ、12〜16 列、行 i) が下の − レールへ。下の − レールは
  1 列目の黒線 (`-t1 -- -b1`) で上の − レール (AD.GND) とつなぐ
- 入力 (5 列) と出力 (20 列) は、溝をまたぐ短い線 (`e5 -- f5` と `e20 -- f20`) で
  上下のブロックをつなぎ、R1・C1 の左端と R2・C2 の右端を共有する。
  ノード A (R の中点) とノード B (C の中点) は同じ 12 列だが、**溝で切れた上下の別の
  ブロック**にあるので互いにつながらない

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
  R・R・2C と C・C・R/2 という部品比がこの対称性を作っている

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。ツイン T の伝達関数は回路方程式による導出 (自分で確かめた)。
