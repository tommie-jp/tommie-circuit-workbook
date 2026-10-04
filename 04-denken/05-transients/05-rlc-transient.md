---
book: denken
chapter: 5
id: 5-5
title: RLC の過渡 — R で減衰振動・臨界・過制動
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-5 RLC の過渡 — R で減衰振動・臨界・過制動

抵抗・コイル・コンデンサを直列にした RLC 回路に方形波を加え、コンデンサの電圧を見る。
RC (5-1) や RL (5-3) と違い、エネルギーが C と L の間を行き来できるので、
R が小さいと電圧は最終値を**行き過ぎて揺れる** (減衰振動)。R を大きくすると揺れが消え
(臨界制動)、さらに大きくすると**ゆっくり近づく** (過制動)。境目の R は
**R = 2√(L/C)** で決まる。R を 3 本差し替えて 3 つの姿を並べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R_c = 2√(L/C) | 臨界制動の抵抗。R < R_c で減衰振動、R > R_c で過制動 |
| ζ = R / R_c | 減衰の度合い (減衰係数)。1 が臨界 |
| f₀ = 1 / (2π√(LC)) | 揺れの元になる固有周波数 |
| f_d = f₀ √(1 − ζ²)、t_p = 1 / (2 f_d) | 減衰振動の周波数と、最初の山までの時間 |
| 行き過ぎ量 = e^(−πζ / √(1 − ζ²)) | 最初の山が最終値を越える割合 |

## 回路図

```circuit
title: 図1 RLC 直列に方形波を加える
parts:
  V1: square b1 d1 1 l=$\mathrm{W1}$
  R1: resistor b1 b3 100
  L1: inductor b4 b6 10m
  C1: capacitor b7 d7 100n
  G1: ground d1
wires:
  - b3 -- b4
  - b6 -- b7
  - d1 -- d7
notes:
  - text a1f0 blue: 入力 (CH1)
  - text a7f0 blue: 出力 Vc (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/circuit/05-rlc-transient.svg)

- L1 = 10 mH、C1 = 100 nF で f₀ = 5.03 kHz、R_c = 2√(L/C) = 632 Ω
- R1 を **100 Ω・620 Ω・2.2 kΩ** と差し替える (ζ = 0.16・0.98・3.5)。620 Ω は R_c に
  一番近い E24 の値で、ほぼ臨界になる
- 入力は AD の Wavegen (W1) の方形波 (0 V〜2 V、200 Hz)。半周期 2.5 ms は、どの R でも
  揺れや立ち上がりが収まるのに十分長い
- **コイルの巻線抵抗 r は R1 に足される。** 10 mH の小さなコイルは数 Ω〜数十 Ω ある。
  テスターで測り、R1 + r を R として計算し直す (100 Ω のときに一番効く)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 100
  L1: inductor/axial c13 c18 10m
  C1: capacitor/film c21 c24 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.1+ -- a5 yellow
  - AD.1- -- -t9 black
  - b10 -- b13 green
  - b18 -- b21 green
  - AD.2+ -- a21 blue
  - AD.2- -- -t16 black
  - a24 -- -t24 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/breadboard/05-rlc-transient.svg)

- 5〜10 列が R1、13〜18 列が L1 (軸物のインダクタ)、21〜24 列が C1 (フィルム)。
  緑の線で順につなぎ、C1 の右のピン (24 列) を GND のレールへ
- CH1 (1+) は入力 (5 列)、CH2 (2+) は C1 の上の端 (21 列)。1− と 2− は GND のレール
- R1 を 100 Ω → 620 Ω → 2.2 kΩ と差し替えて 3 回測る。ほかは動かさない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、200 Hz、Amplitude 1 V、Offset 1 V (0 V〜2 V) |
| Scope | CH1 = 入力、CH2 = 出力 (Vc)。2 ch とも 500 mV/div、0 V を下から 1 目盛。Time base 100 µs/div、Trigger は CH1 の立ち上がりで、位置を左から 1 目盛 |
| Cursors | X1 = 0 (立ち上がり)、X2 = 100 µs (減衰振動の最初の山のころ) |
| Measure | CH2 の Maximum |

3 枚とも同じ設定で、変えたのは R1 だけ。同じ 100 µs の時点 (X2) で出力を比べる。

```scope
title: 図3 R = 100 Ω (ζ = 0.16) — 3.21 V まで行き過ぎ、201 µs 周期で揺れて収まる
time: 100us/div
trigger: ch1 rising 1V at -4div
ch1: {wave: square 200Hz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | lc 5.03kHz 3.16, range: 500mV/div, position: -3div}
cursors: [0, 100us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/05-rlc-transient-1.svg)

```scope
title: 図4 R = 620 Ω (ζ = 0.98) — 行き過ぎずに一番早く 2 V に届く
time: 100us/div
trigger: ch1 rising 1V at -4div
ch1: {wave: square 200Hz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | lc 5.03kHz 0.51, range: 500mV/div, position: -3div}
cursors: [0, 100us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/05-rlc-transient-2.svg)

```scope
title: 図5 R = 2.2 kΩ (ζ = 3.5) — 揺れないが、2 V へゆっくり近づく
time: 100us/div
trigger: ch1 rising 1V at -4div
ch1: {wave: square 200Hz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | lc 5.03kHz 0.144, range: 500mV/div, position: -3div}
cursors: [0, 100us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/05-rlc-transient-3.svg)

直列 RLC のコンデンサの電圧は 2 次の低域フィルタと同じ式で、Q = √(L/C) / R = 1 / (2ζ)。
図の CH2 はその式 (f₀ = 5.03 kHz、Q = 3.16・0.51・0.144) で描いた理想の波形である。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Square、200 Hz、**2 Vpp、Offset 1 V** (AD の Amplitude 1 V は山の高さ)、出力は High-Z |
| 1+ | CH1 の先端を 5 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 21 列 (C1 の上の端)、グランドクリップを GND のレール |

**FG の 50 Ω は R1 に直列に足され、減衰が変わる** (計算値)。R1 = 100 Ω のままだと
R = 150 Ω、ζ = 0.24 で、最初の山は 3.21 V ではなく 2.93 V になる。**R1 を 50 Ω 少ない
値に替えれば表がそのまま使える**: 100 Ω → 51 Ω (合わせて 101 Ω)、620 Ω → 560 Ω
(610 Ω)。2.2 kΩ は 2 % の違いで、そのままでよい。CH1 は FG の端子の電圧なので、
立ち上がりの直後に電流の分だけ少しへこむ。

## 見るべき値

計算値。L = 10 mH、C = 100 nF、巻線抵抗は 0 とした。入力は 0 V → 2 V の段。

| R1 | ζ | 状態 | CH2 の最大 (Maximum) | 100 µs 後の CH2 (X2) | 見どころ |
| --- | --- | --- | --- | --- | --- |
| 100 Ω | 0.16 | 減衰振動 | 3.21 V | 3.21 V | 最初の山は t_p = 101 µs。揺れの周期 201 µs (4.97 kHz)。1 周期ごとに振れが 0.37 倍 |
| 620 Ω | 0.98 | ほぼ臨界 | 2.00 V | 1.66 V | 行き過ぎが無い。90 % に届くのは 120 µs |
| 2.2 kΩ | 3.5 | 過制動 | 1.97 V (画面の右端 900 µs でもまだ 2 V に届かない) | 0.72 V | 遅い時定数 215 µs で近づく。90 % に届くのは 500 µs |

分かること:

- **R が小さいほど揺れが長く続く。** 揺れの振れは e^(−t/(2L/R)) で減り、2L/R は
  100 Ω で 200 µs。R が熱に変える分しかエネルギーが減らないため
- **臨界制動が「行き過ぎずに一番早く」最終値に届く。** 計器の指針や制御系は、
  揺れを嫌う所ではこの近くに合わせる
- R を大きくしすぎると (過制動)、揺れはしないが RC 回路のように遅くなる。
  2.2 kΩ の遅い時定数 215 µs は、C R = 220 µs に近い

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
