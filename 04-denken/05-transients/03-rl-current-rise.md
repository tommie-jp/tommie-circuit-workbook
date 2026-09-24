---
book: denken
chapter: 5
id: 5-3
title: RL の電流の立ち上がり — τ = L / R
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-3 RL の電流の立ち上がり — τ = L / R

抵抗とコイルの直列回路 (RL 回路) に方形波を加える。コイルは電流の変化を
嫌うので、電流は一気には流れ始めず、時定数 **τ = L / R** で決まる速さで
最終値に近づく。電流は直接測れないので、直列に入れた抵抗の両端の電圧
(= 電流 × 抵抗) で読む。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| τ = L / R | 時定数。電流が最終値の 63.2 % に達するまでの時間 |
| i(t) = (V/R)(1 − e^(−t/τ)) | 電流 (0 から立ち上がるとき) |
| i(τ) = 0.632 (V/R)、i(2τ) = 0.865 (V/R)、i(5τ) = 0.993 (V/R) | τ の倍数ごとの到達率。RC の充電と同じ形 |

## 回路図

```circuit
title: 図1 RL 直列の電流の立ち上がり
parts:
  V1: square a1 c1 1 l=$\mathrm{W1}$
  R1: resistor a1 a5 1k i=I
  L1: inductor a5 c5 10m
  G1: ground c1
wires:
  - c1 -- c5
notes:
  - text a1 blue: 入力
  - text a5 blue: 電流を読む点 (R1 の両端)
style:
  standard: jis
  grid: on
```

- R1 (1 kΩ) と L1 (10 mH) で τ = L / R = 10 µs
- 電流 i は R1 の両端の電圧を 1 kΩ で割って求める (i = V_R1 / R1)。R1 の両端は
  **入力 (a1) と中間点 (a5) の差**なので、差動で測る
- コイルの巻線抵抗 (数 Ω〜数十 Ω) は R1 (1 kΩ) に対して小さいので、ここでは
  無視する (3-7 で扱った注意と同じ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  L1: inductor/axial c15 c20 10m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - a10 -- a15 green
  - a20 -- -t20 black
  - AD.GND -- -t2 black
  - AD.1+ -- a5 yellow [h10]
  - AD.1- -- -t7 black
  - AD.2+ -- a5 yellow [h12]
  - AD.2- -- a10 green [h12]
```

- CH1 (1+) は入力、CH1− は GND。CH2 は R1 の両端の**差動** (2+ が入力側の a5、
  2− が中間点の a10) — GND にはつながない
- L1 は軸物のインダクタ (`inductor/axial`)。15〜20 列に差し込む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、2 kHz、Amplitude 1 V、Offset 1 V (0 V〜2 V の方形波) |
| Scope | CH1 = 入力、CH2 = R1 の両端 (差動、電流の代わり)。Time base は 10 µs/div 前後 |

## 見るべき値

計算値。τ = L / R = 10 mH ÷ 1 kΩ = 10 µs。方形波の半周期 250 µs は 25 τ ぶんある
ので、毎回電流が飽和してから次の周期に入る。最終値 I_max = 2 V ÷ 1 kΩ = 2 mA
(CH2 の読みでは 2.00 V)。

| 時間 (立ち上がりから) | CH2 の電圧 (= 電流 × 1 kΩ) | 電流 |
| --- | --- | --- |
| 0 (τ = 0) | 0 V | 0 mA |
| 1 τ (10 µs) | 1.26 V | 1.26 mA |
| 2 τ (20 µs) | 1.73 V | 1.73 mA |
| 3 τ (30 µs) | 1.90 V | 1.90 mA |
| 5 τ (50 µs) | 1.99 V | 1.99 mA |

分かること:

- **式の形は RC の充電と同じ** (τ = L/R が τ = CR の代わり)。指数で近づく
  カーブは、貯めるのが電荷 (C) でもコイルの磁束 (L) でも同じになる
- コイルの電流は急に変えられない (5-6 で確かめる)。方形波を切ったあとの
  逆起電力にも注意がいる (2-18)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
