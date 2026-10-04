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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/circuit/03-rl-current-rise-1.svg)

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
  R1: resistor d5 d10 1k
  L1: inductor/axial c15 c20 10m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 2+, 2-, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- c5 yellow [h-10]
  - AD.1+ -- a5 yellow
  - AD.2+ -- b5 yellow [h10]
  - AD.2- -- a10 green
  - AD.1- -- -t12 black
  - b10 -- b15 green
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/breadboard/03-rl-current-rise.svg)

- CH1 (1+) は入力、CH1− は GND。CH2 は R1 の両端の**差動** (2+ が入力側の b5、
  2− が中間点の a10) — GND にはつながない
- L1 は軸物のインダクタ (`inductor/axial`)。15〜20 列に差し込む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、2 kHz、Amplitude 1 V、Offset 1 V (0 V〜2 V の方形波) |
| Scope | CH1 = 入力、CH2 = R1 の両端 (差動、電流の代わり)。Time base は 10 µs/div 前後 |

R1 の両端 (CH2) は電流 × 1 kΩ なので、RC の充電と同じ形で τ = L / R = 10 µs で立ち上がる。

```scope
title: 図3 立ち上がりから 1τ (10 µs) で電流 (CH2) は 63 % に届く
time: 10us/div
trigger: ch1 rising 1V
ch1: {wave: square 2kHz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | rc 10us, range: 500mV/div, position: -3div}
cursors: [0, 10us]
measure: [vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/03-rl-current-rise.svg)

### オシロスコープと発振器

AD 版は CH2 を R1 の両端に差動で当てる (2− は中間点)。汎用オシロでは
中間点にグランドクリップを当てられない。当てると中間点が GND に落ち、
L1 を短絡して回路が変わる ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) の落とし穴)。

**回路はそのまま、入力と中間点を GND 基準で測り、Math の CH1 − CH2 で R1 の両端を
読む** (図4)。R1 の両端は 0〜1.9 V で、振れ (2 V) のほぼ全部なので、8 bit でも
埋もれない。

```circuit
title: 図4 汎用オシロでの測り方
parts:
  V1: square a1 d1 1 l=$\mathrm{FG}$
  M1: voltmeter a4 d4 l=$\mathrm{CH1}$
  R1: resistor a6 a9 1k i=I
  M2: voltmeter a11 d11 l=$\mathrm{CH2}$
  L1: inductor a14 d14 10m
  G1: ground d8
wires:
  - a1 -- a4 -- a6
  - a9 -- a11 -- a14
  - d1 -- d4 -- d8 -- d11 -- d14
style:
  standard: jis
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/circuit/03-rl-current-rise-2.svg)

- FG は Square、2 kHz、**2 Vpp、Offset 1 V** (AD の Amplitude 1 V は山の高さ)、出力は
  High-Z ([0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))
- CH1 の先端を 5 列 (入力)、CH2 の先端を 10 列 (中間点。AD の 2− の穴) に当てる。
  グランドクリップは 2 本とも GND のレール。ブレッドボードの部品は動かさない
- 測る前に 2 本の先端を同じ点 (5 列) に当て、Math が 0 V 近くになるかを見る

**FG の 50 Ω で値が変わる** (計算値)。50 Ω が R1 に直列に足され、
τ = 10 mH ÷ 1050 Ω = 9.5 µs、最終値は 2 V ÷ 1050 Ω = 1.90 mA になる。
CH1 − CH2 の読みは、1 τ で 1.20 V、2 τ で 1.65 V、3 τ で 1.81 V、5 τ で 1.89 V
(最終値に対する 63・86・95・99 % は変わらない)。CH1 の入力の波形も平らではなく、
立ち上がりで 2 V まで跳ねてから、電流が増えるにつれて 1.90 V へ下がる
(FG の 50 Ω の電圧降下)。

## 見るべき値

計算値。τ = L / R = 10 mH ÷ 1 kΩ = 10 µs。方形波の半周期 250 µs は 25 τ ぶんある
ので、毎回電流が飽和してから次の周期に入る。最終値 I_max = 2 V ÷ 1 kΩ = 2 mA
(CH2 の読みでは 2.00 V)。

| 時間 (立ち上がりから) | CH2 の電圧 (= 電流 × 1 kΩ) | 電流 |
| --- | --- | --- |
| 0 (t = 0) | 0 V | 0 mA |
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
