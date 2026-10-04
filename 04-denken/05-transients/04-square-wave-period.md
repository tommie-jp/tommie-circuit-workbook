---
book: denken
chapter: 5
id: 5-4
title: 方形波で繰り返し見る — 時定数と周期の比
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-4 方形波で繰り返し見る — 時定数と周期の比

5-1・5-2 と同じ RC 直列回路に、周波数を変えた方形波を加える。方形波の半周期が
時定数 τ より十分長ければ、コンデンサは毎回満充電・完全放電してから次の段に移る。
半周期が τ と同じくらいになると途中で折り返し、τ よりずっと短いと**平均値 (1 V) の
まわりを小さく揺れる三角波**になる。形を決めるのは**半周期と τ の比**だけである。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| τ = CR | 時定数 |
| V_H = V / (1 + e^(−T_h/τ))、V_L = V e^(−T_h/τ) / (1 + e^(−T_h/τ)) | 繰り返しが落ち着いたあとの出力の山と谷 (0〜V の方形波、半周期 T_h) |
| V_H − V_L = V tanh(T_h / 2τ) | 出力の振れ。T_h ≫ τ で V、T_h ≪ τ で V T_h / 2τ |
| (V_H + V_L) / 2 = V / 2 | 振れの中央はいつも入力の平均値 |

## 回路図

```circuit
title: 図1 RC 直列に方形波を加える (5-1 と同じ回路)
parts:
  V1: square b1 d1 1 l=$\mathrm{W1}$
  R1: resistor b1 b5 10k
  C1: capacitor b5 d5 100n
  G1: ground d1
wires:
  - d1 -- d5
notes:
  - text a1f0 blue: 入力 (CH1)
  - text a5f0 blue: 出力 Vc (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/circuit/04-square-wave-period.svg)

- 回路と部品は 5-1 と同じ (R1 = 10 kΩ、C1 = 100 nF、τ = 1.0 ms)
- 変えるのは Wavegen の周波数だけ。100 Hz・500 Hz・5 kHz の 3 通りで、
  半周期 T_h はそれぞれ 5 ms (5 τ)・1 ms (1 τ)・0.1 ms (0.1 τ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (5-1 と同じ配線)
board: half
parts:
  R1: resistor c5 c10 10k
  C1: capacitor/ceramic c15 c20 100n
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
  - b10 -- b15 green
  - AD.2+ -- a15 green
  - AD.2- -- -t13 black
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/breadboard/04-square-wave-period.svg)

- 配線は 5-1 と同じ。CH1 (1+) は入力 (5 列)、CH2 (2+) は出力 (15 列、C1 の上の端)。
  1− と 2− は GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、Amplitude 1 V、Offset 1 V (0 V〜2 V)。周波数を 100 Hz → 500 Hz → 5 kHz と変える |
| Scope | CH1 = 入力、CH2 = 出力。2 ch とも 500 mV/div、0 V を下から 1 目盛。Time base は 2〜2.5 周期ぶん (2 ms/div・500 µs/div・50 µs/div)。Trigger は CH1 の立ち上がり |
| Measure | CH2 の Maximum・Minimum・Peak2Peak |

3 枚とも CH1 と CH2 を同じ尺度で描き、周期に合わせて Time base だけを変えた。
横軸はどれも 2〜2.5 周期ぶんなので、形の違いは半周期と τ の比だけから来る。

```scope
title: 図3 100 Hz (半周期 5τ) — 出力 (CH2) は毎回ほぼ 0 V と 2 V に届く
time: 2ms/div
trigger: ch1 rising 1V
ch1: {wave: square 100Hz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 500mV/div, position: -3div}
measure: [vmax, vmin, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/04-square-wave-period-1.svg)

```scope
title: 図4 500 Hz (半周期 1τ) — 途中で折り返し、0.54〜1.46 V を往復する
time: 500us/div
trigger: ch1 rising 1V
ch1: {wave: square 500Hz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 500mV/div, position: -3div}
measure: [vmax, vmin, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/04-square-wave-period-2.svg)

```scope
title: 図5 5 kHz (半周期 0.1τ) — 1 V のまわりを 0.1 V だけ揺れる三角波
time: 50us/div
trigger: ch1 rising 1V
ch1: {wave: square 5kHz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 500mV/div, position: -3div}
measure: [vmax, vmin, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/04-square-wave-period-3.svg)

図5 の CH2 の揺れ (0.1 V) は 500 mV/div では 0.2 目盛しかない。形を見るときは
CH2 だけを 20 mV/div にし、Offset (Position) を −1 V にして 1 V を画面の中央へ寄せる。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Square、**2 Vpp、Offset 1 V** (AD の Amplitude 1 V は山の高さ)、出力は High-Z。周波数を 100 Hz・500 Hz・5 kHz と変える |
| 1+ | CH1 の先端を 5 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 15 列 (C1 の上の端)、グランドクリップを GND のレール |

- FG の 50 Ω は R1 に直列に足され、τ が 1.005 ms (計算値) になる。0.5 % の違いは
  部品の誤差に隠れ、見るべき値はそのまま使える
- 図5 の小さな揺れは、CH2 を **AC 結合**にして 20 mV/div で見る。AD の Offset で
  寄せる代わりに、直流分 (1 V) を結合コンデンサで落とす。平均値の 1 V は DC 結合に
  戻して Measure の Mean で読む

## 見るべき値

計算値。τ = CR = 1.0 ms、入力は 0 V〜2 V の方形波 (平均 1 V)。

| 周波数 | 半周期 T_h | T_h / τ | 出力の山 V_H | 出力の谷 V_L | 振れ (Peak2Peak) |
| --- | --- | --- | --- | --- | --- |
| 100 Hz | 5 ms | 5 | 1.99 V | 0.01 V | 1.97 V |
| 500 Hz | 1 ms | 1 | 1.46 V | 0.54 V | 0.92 V |
| 5 kHz | 0.1 ms | 0.1 | 1.05 V | 0.95 V | 0.10 V |

```graph
title: 図6 出力の振れ (計算) — 半周期が τ を下回ると振れが小さくなる
x: 周波数 Hz log 20..20k
y: 振れ V 0..2.2
lines:
  出力の振れ V: 2 * (exp(1 / (2 * x * 1m)) - 1) / (exp(1 / (2 * x * 1m)) + 1)
notes:
  - mark 100
  - mark 500
  - mark 5k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/graph/04-square-wave-period.svg)

式は V tanh(T_h / 2τ) を指数で書き直したもの (T_h = 1 / 2f)。

分かること:

- **振れの中央はいつも 1 V** (入力の平均値)。周波数を上げても出力は 1 V のまわりに
  集まるだけで、平均は変わらない。RC 回路が低域フィルタ (直流を通して速い変化を
  ならす) として働く姿で、10-2 の平滑も同じ考え
- 半周期が 5 τ あれば、1 回ごとの充放電は 5-1・5-2 の 1 回きりの波形とほぼ同じ。
  **「5 τ でほぼ終わる」が繰り返しの波形でも使える**目安になる
- 半周期が τ よりずっと短いと、コンデンサの電圧はほとんど変わらず、電流
  ((入力 − 出力) ÷ R) は ±1 V ÷ 10 kΩ の一定値に近い。一定の電流で充放電するので
  出力は直線 (三角波) になる。振れは V T_h / 2τ = 2 V × 0.1 ms ÷ 2 ms = 0.10 V

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
