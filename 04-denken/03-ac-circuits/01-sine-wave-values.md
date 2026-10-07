---
book: denken
chapter: 3
id: 3-1
title: 正弦波の最大値・実効値・平均値 — √2 と 2/π を測る
tier: 50
source: 自作
board: BB
---

# 3-1 正弦波の最大値・実効値・平均値 — √2 と 2/π を測る

交流には 3 つの代表値がある。**最大値** (振幅そのもの)、**実効値**
(同じ働きをする直流に換算した値)、**平均値** (半周期だけ平均した値)。
正弦波ではこの 3 つの間に √2 と 2/π という決まった比がある。
AD のオシロスコープ 1 つで、この 3 つを実測して比を確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_rms = V_m / √2 | 実効値。最大値の 1/√2 ≈ 0.707 倍 |
| V_av = (2/π) V_m | 平均値。半周期 (0〜π) だけ平均すると最大値の 2/π ≈ 0.637 倍 |
| V_av = 0 (全周期平均) | 正弦波を 1 周期まるごと平均すると 0 になる (プラスとマイナスが打ち消す) |

## 回路図

```circuit
title: 図1 正弦波を負荷抵抗で受ける
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine 1,3 1,7 l=$\mathrm{W1}$
  R1: resistor 1,3 3,3 1k
  M1: voltmeter 1,1 3,1 l=$\mathrm{CH1}$
  G1: ground 1,7
wires:
  - 1,1 -- 1,3
  - 3,1 -- 3,3
  - 3,3 -- 3,7
  - 3,7 -- 1,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/01-sine-wave-values.svg)

- V1 は AD の波形発生器 (W1)。R1 はただの負荷、M1 (CH1) が読み取り点

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-"]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 blue [h10]
  - AD.1- -- -t8 black
  - c10 -- -t10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/01-sine-wave-values.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Offset 0 V |
| Scope | CH1、DC 結合。Measure で Maximum (最大値) と RMS (実効値) を表示 |

最大値と実効値は波形を丸ごと表示したまま Measure で読める。平均値は
**半周期だけを画面に収める** (Time base を 50 µs/div にして、横 10 目盛り = 0.5 ms に正の 1 山
だけがちょうど入るようにする) と、Measure の Average がそのまま
半周期平均 = 2/π × V_m になる (図4)。1 周期まるごと表示すると Average は 0 に
近づいてしまうので、必ず半周期に絞る。

波形を丸ごと表示した画面。正の半周期は X1 (0) から 0.5 ms まで、X2 はその真ん中の山に置いてある。

```scope
title: 図3 最大値 1 V・実効値 0.707 V、1 周期の平均は 0
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
cursors: [0, 250us]
measure: [vmax, rms, avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/01-sine-wave-values-1.svg)

半周期だけを映した画面。50 µs/div にし、トリガの位置を左端に寄せてある (t = 0 の立ち上がりが左端、
右端が 0.5 ms)。X2 は山 (0.25 ms) に置いてある。

```scope
title: 図4 正の半周期だけを映すと、平均は 0.637 V
time: 50us/div
trigger: ch1 rising 0V at -5div
ch1: {wave: sine 1kHz 1V, range: 200mV/div, position: -3div}
cursors: [0, 250us]
measure: [vmax, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/01-sine-wave-values-2.svg)

### オシロスコープと発振器

W1 → FG の OUT (High-Z)、芯を 5 列、外皮を GND のレール。1+ → CH1 のプローブの先端を 5 列、
1− → グランドクリップを GND のレール ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。
振幅を Vpp で入れる機種では、振幅 1 V は 2 Vpp。

- FG の出力の 50 Ω と R1 (1 kΩ) で分かれて、R1 の両端は 0.952 V に下がる。最大値 0.952 V、
  実効値 0.673 V、半周期の平均値 0.606 V になる (計算値)。比 (0.707、0.637) は変わらない。
  表の値にそろえるなら、CH1 の最大値が 1.000 V になるまで振幅を上げる (約 2.1 Vpp)
- Measure の Max・RMS・Mean (平均) が AD の Maximum・RMS・Average に当たる。RMS と Mean は、画面全体で
  取るか 1 周期で取るかを選べる機種がある。半周期の平均値は「画面全体」で取る
- 画面の横が 10 目盛りの機種で正の半周期 (0.5 ms) だけを画面に収めるには 50 µs/div にし、
  立ち上がりの 0 V でトリガを掛けて、トリガの位置を画面の左端へ寄せる。横が 12・14 目盛りの機種は、
  カーソルで 0〜0.5 ms を挟み、Measure の範囲 (ゲート) をカーソルの間にする

## 見るべき値

計算値 (振幅 V_m = 1.000 V)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Max (最大値) | 1.000 V | 振幅そのもの |
| RMS (実効値) | 0.707 V | V_m / √2 |
| Average、半周期だけ表示 (平均値) | 0.637 V | (2/π) V_m |
| Average、1 周期まるごと表示 | 0 V 付近 | 正負が打ち消し合う |

分かること:

- **3 つの値はどれも振幅 V_m の定数倍。** 比は波形の形 (正弦波) だけで決まり、
  電圧の大きさにはよらない
- テスターの交流電圧レンジが表示するのは**実効値** (0.707 V_m)。
  電力の計算 (P = V_rms I_rms cos θ、3-6) に使うのもこの値
- 「平均値」は測り方によって答えが変わる (半周期か全周期か)。整流形の
  計器は半波・全波で整流してから平均値を測り、係数を掛けて実効値らしく
  表示する (0-2・7-6 で扱う)

## 出典

自作。
