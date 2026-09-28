---
book: denken
chapter: 11
id: 11-4
title: ボード線図 — 折れ点で −3 dB、−20 dB/dec
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 11-4 ボード線図 — 折れ点で −3 dB、−20 dB/dec

11-3 の一次遅れ系 (K = 0.5、T = 1.0 ms) に、ステップの代わりに正弦波を入れ、周波数を変えながら
出力の大きさと位相を測る。横軸を対数の周波数、縦軸をゲイン (dB) と位相 (度) にした図が
**ボード線図**。一次遅れ系のゲインは、低い周波数では平らで、**折れ点周波数 1/(2πT) で平らな所から 3 dB 下がり**、
その先は **10 倍ごとに 20 dB** 下がる。位相は折れ点でちょうど −45°。AD の Network (ネットワーク
アナライザ) で一度に描く。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| G(jω) = K / (1 + jωT) | 一次遅れ系の周波数伝達関数 (11-3 の G(s) の s を jω に) |
| g = 20 log₁₀ \|G(jω)\| = 20 log₁₀ K − 10 log₁₀ {1 + (ωT)²} | ゲイン (dB)。K = 0.5 なら低い周波数で 20 log₁₀ 0.5 = −6.02 dB |
| f_c = 1 / (2πT) | 折れ点周波数。ωT = 1 で、ゲインは平らな所から −3.01 dB、位相は −45° |
| ∠G = −tan⁻¹(ωT) | 位相。低い周波数で 0°、高い周波数で −90° に近づく |
| f ≫ f_c で g ≈ 20 log₁₀ K − 20 log₁₀ (f / f_c) | 折れ点より上は −20 dB/dec (周波数 10 倍で 20 dB 下がる) |

## 回路図

11-3 と同じ回路。W1 を方形波から正弦波に替え、Network が周波数を掃引する。

```circuit
title: 図1 一次遅れ系 (11-3 と同じ RC)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  R1: resistor c5 c7 20k
  C1: capacitor c9 g9 100n
  R2: resistor c11 g11 20k
  M2: voltmeter c14 g14 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3 -- c5
  - c7 -- c9 -- c11 -- c14
  - g1 -- g3 -- g9 -- g11 -- g14
notes:
  - text a1 blue: 入力
  - text a13 blue: 出力
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/circuit/04-bode-plot.svg)

- K = R2 / (R1 + R2) = 0.5、T = C1 × (R1 ∥ R2) = 100 nF × 10 kΩ = 1.0 ms、f_c = 1 / (2π × 1.0 ms) = 159 Hz
- CH1 (M1) が入力、CH2 (M2) が出力。Network は CH2 ÷ CH1 の大きさと位相差を周波数ごとに描く

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (11-3 と同じ)
board: half
parts:
  R1: resistor c5 c10 20k
  C1: capacitor/ceramic c14 c18 100n
  R2: resistor e14 e22 20k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2-, 2+]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.1+ -- a5 yellow
  - AD.1- -- -t8 black
  - b10 -- b14 green
  - AD.2+ -- a14 green
  - AD.2- -- -t12 black
  - a18 -- -t18 black
  - a22 -- -t22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/breadboard/04-bode-plot.svg)

- 11-3 の板のまま。5 列が入力 (W1 と CH1)、14 列が出力 (CH2)
- R2 を抜くと K = 1・T = 2.0 ms (f_c = 79.6 Hz) の回路になる。平らな所が 0 dB に上がり、
  折れ点が左へ半分ずれる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V、Offset 0 V (Network が周波数を掃引する) |
| Network | Start 10 Hz、Stop 100 kHz、**Log**、Steps 101、Reference: Channel 1、表示: Bode (Magnitude dB・Phase deg) |
| カーソル | 159 Hz (折れ点)、1.59 kHz、15.9 kHz。10 倍ごとの dB の差を読む |

掃引の範囲は折れ点 159 Hz の上下に 1 桁と 3 桁。低い側の 1 桁で平らな所を、高い側の 3 桁で
−20 dB/dec の傾きを見る。

```graph
title: 図3 ボード線図 — 159 Hz で平らな所から 3 dB 下がり −45°、その先は −20 dB/dec
x: 周波数 Hz log 10..100k
y:
  - ゲイン dB -70..0
  - 位相 deg -90..0
lines:
  ゲイン dB: 20*log10(0.5/sqrt(1+(x/159.2)^2))
  折れ線近似 dB: min(-6.02, -6.02-20*log10(x/159.2))
  位相 deg: -deg(atan(x/159.2))
notes:
  - level -9.03dB
  - level -45deg
  - mark 15.9
  - mark 159.2
  - mark 1.592k
  - mark 15.92k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/graph/04-bode-plot.svg)

折れ点 f_c での画面をオシロで見ると次のとおり。出力 (CH2) は入力の 0.354 倍 (0.5 × 0.707) で、45° 遅れる。
CH2 は小さいので V/div を CH1 より細かく (200 mV/div) してある。

```scope
title: 図4 159 Hz — CH2 は CH1 の 0.354 倍で 45° 遅れる (CH2 は 200 mV/div)
time: 2ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 159.2Hz 1V, range: 500mV/div}
ch2: {wave: sine 159.2Hz 0.354V phase -45deg, range: 200mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/scope/04-bode-plot.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、つなぎ方は 11-3 と同じ GND 基準でよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。W1 は FG の OUT (Sine、**2 Vpp**、
Offset 0 V、High-Z)、CH1 の先端は 5 列、CH2 の先端は 14 列、グランドクリップは 2 本とも GND のレール。

- 汎用の計器には Network の掃引が無い。**周波数を手で変えて 1 点ずつ測る**。FG の周波数を
  15.9 Hz・50 Hz・159 Hz・500 Hz・1.59 kHz・5 kHz・15.9 kHz と 1 桁に 2 点ずつ変え、
  Measure の CH1 と CH2 の振幅 (Vpp) と位相差を読む。ゲインは 20 log₁₀ (CH2 ÷ CH1)
- 15.9 kHz では CH2 が 10 mVpp 程度しかない。CH2 を ×1 のプローブと細かいレンジ (5 mV/div 前後) にし、
  Average を掛ける。8 bit の分解能では −46 dB がほぼ下限になる
- FG の 50 Ω は R1 (20 kΩ) に直列に足されるだけで、CH1 は FG の出力そのものを測るので、比は変わらない。
  プローブは ×10 が基本で、R2 に並列の入力抵抗の影響は 0.1 % 以下 (×1 の 1 MΩ だと低い周波数で約 1 %、0.09 dB)。
  15.9 kHz の点だけ CH2 を ×1 にするのは、そこでは C1 のインピーダンス (100 Ω) が効いていて、1 MΩ の影響が無視できるため

## 見るべき値

計算値。K = 0.5、T = 1.0 ms、f_c = 159 Hz。

| 周波数 | f / f_c | ゲイン | 平らな所との差 | 位相 |
| --- | --- | --- | --- | --- |
| 15.9 Hz | 0.1 | −6.06 dB | −0.04 dB | −5.7° |
| 159 Hz (折れ点) | 1 | −9.03 dB | −3.01 dB | −45.0° |
| 1.59 kHz | 10 | −26.1 dB | −20.0 dB | −84.3° |
| 15.9 kHz | 100 | −46.0 dB | −40.0 dB | −89.4° |

分かること:

- **平らな所の高さが 20 log₁₀ K。** K = 0.5 なので −6.02 dB。R2 を抜いて K = 1 にすると 0 dB に上がる。
  K は線図を上下に動かすだけで、形を変えない
- **折れ点で平らな所から 3 dB 下がり、位相は −45°。** ゲインの落ち (−3 dB) と位相 (−45°) の両方から
  f_c が読め、T = 1 / (2π f_c) で 11-3 のステップ応答の T と同じ 1.0 ms になる
- **1.59 kHz から 15.9 kHz の 10 倍で、ゲインは 20.0 dB 下がる** (−20 dB/dec)。高い周波数では
  出力が周波数に反比例して小さくなる
- 図3 の折れ線近似 (平らな線と −20 dB/dec の線) は、実際の曲線と折れ点で 3 dB 離れるだけで、
  そこから離れるほど重なる。電験の制御の問題はこの折れ線でゲインを見積もる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Network Analyzer・Scope の節)。
