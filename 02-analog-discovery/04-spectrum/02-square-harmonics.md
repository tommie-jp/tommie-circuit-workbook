---
book: analog-discovery
chapter: 4
id: 4-2
title: 方形波の高調波 (奇数次)
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-2 方形波の高調波 (奇数次)

理想の方形波 (デューティ 50%) はフーリエ級数で書くと**奇数次の高調波だけ**を
持ち、n 次の振幅は基本波の 1/n で下がる。Spectrum で W1 の Square を見て、
1・3・5・7・9 次のレベルが計算どおりに並ぶかを確かめる。

## 回路図

```circuit
title: 図1 ループバック (W1 を 1+ に直結)
parts:
  V1: square a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/02-square-harmonics.svg)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+ に直結)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/02-square-harmonics.svg)

W1 と 1+ は 5 列に挿すだけで、列の内側でつながる。GND と 1− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、**1000 Hz**、Amplitude 1 V、Offset 0 V、Duty 50% |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz** (9 次の 9000 Hz まで余裕を持って収める)。Window: Flat-top (各次数の振幅を正しく読むため)。単位: dBV |

Stop を 9000 Hz よりだいぶ高い 20 kHz にしておくのは、9 次の山を画面の右端から
離し、11 次以降も並び続けることを見せるため。方形波の高調波は 11 次・13 次…と
限りなく続くので、Stop をいくつにしても画面の外に高調波は残る。

画面は次のようになる。奇数次の山が 1/n で下がりながら並び、偶数次には何も出ない (理想)。

```spectrum
title: 図3 奇数次の山だけが 1/n で下がって並ぶ
device: ad3
sweep: 0-20kHz
samples: 32768
window: flattop
signal: square 1kHz 1V
markers: [1kHz, 3kHz, 5kHz, 9kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/02-square-harmonics.svg)

```scope
title: 図4 同じ信号を時間で見ると 0〜2 V ではなく ±1 V の方形波 (Vpp 2.00 V)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/02-square-harmonics.svg)

図4 は同じ信号を Scope の時間波形で見た画面。角ばった波形が奇数次の高調波の重なりでできている。

## 見るべき値

計算値。振幅 A = 1 V の理想方形波 (デューティ 50%) の n 次高調波 (n は奇数) の
**ピーク振幅は (4/π) × A / n**。dBV は実効値換算 (ピーク / √2)。

| 次数 n | 周波数 | ピーク振幅 | dBV | 基本波との差 |
| --- | --- | --- | --- | --- |
| 1 (基本波) | 1000 Hz | 1.273 V | −0.91 dBV | 0 dB (基準) |
| 3 | 3000 Hz | 0.424 V | −10.45 dBV | −9.54 dB |
| 5 | 5000 Hz | 0.255 V | −14.89 dBV | −13.98 dB |
| 7 | 7000 Hz | 0.182 V | −17.81 dBV | −16.90 dB |
| 9 | 9000 Hz | 0.141 V | −20.00 dBV | −19.08 dB |
| 2・4・6・8 (偶数次) | 2000〜8000 Hz | (理想では 0) | ノイズフロアに埋もれる | デューティが正確に 50% なら現れない |

分かること:

- **基本波との差は 20 log₁₀(1/n) dB にきれいに一致する** (n = 3 で −9.54 dB、
  n = 5 で −13.98 dB…)。これはどの振幅・周波数でも成り立つ形なので、方形波を
  見たらまずこの並びを確かめるとよい
- **偶数次が見えたら、デューティが 50% からずれている証拠。** Wavegen の Duty
  を 55% などにずらして測り直すと、2 次・4 次が顔を出すのを確かめられる
- 基本波の振幅 1.273 V は元の方形波の振幅 1 V より**大きい**。方形波は
  同じ振幅の正弦波より肩が張っていて、その肩の分だけ基本波の成分が大きくなる
  (4/π ≈ 1.273 倍)。電力で比べると基本波は全体の 81% (8/π²) で、残りが高調波

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。
