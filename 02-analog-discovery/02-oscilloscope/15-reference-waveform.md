---
book: analog-discovery
chapter: 2
id: 2-15
title: 参照波形と重ねて比べる
tier: 100
source: 自作
board: —
---

# 2-15 参照波形と重ねて比べる

Scope はトレースを**参照波形（Reference）として凍結**し、その後の生きた波形と
重ねて表示できる。「直したら本当に変わったか」「前の設定と今の設定はどう違うか」
を目で比べるときに使う。ここではループバックで基準を保存し、Wavegen の設定を
変えて違いを見る。

## 回路図

```circuit
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: sine a1 c1 1
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/15-reference-waveform.svg)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+ に直結。0-3 と同じ)
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/15-reference-waveform.svg)

W1 と 1+ は同じ 5 列に挿し、GND と 1− は上の − レールにまとめる。部品は無く、電源も使わない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V（基準を保存する時点の設定） |
| Scope (CH1) | DC。トレースを右クリック（または該当ボタン）で **Reference として保存**（破線で表示され続ける） |

次の図3・図4は、保存した参照 (1 kHz・1 V) を CH1、生きた波形を CH2 として同じ尺度で重ねたもの。

```scope
title: 図3 振幅を 1.5 V にすると参照 (CH1) より 1.5 倍高い
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1.5V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/15-reference-waveform-1.svg)

```scope
title: 図4 1.2 kHz にすると山がずれていき、5 ms で 1 周期ぶん追い付く
time: 500us/div
trigger: ch1 rising 0V at -5div
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1.2kHz 1V, range: 500mV/div}
cursors: [0, 5ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/15-reference-waveform-2.svg)

## 見るべき値

保存した参照波形は 1 kHz・振幅 1 V（Vpp 2 V）の正弦波。これを基準に、生きた
トレースだけを変えて比べる。

| 変えた設定 | 参照（破線）に対する生きた波形の見え方 | 分かること |
| --- | --- | --- |
| W1 の振幅を 1.5 V に | 破線より 1.5 倍（Vpp 3.0 V）高く重なる | 振幅の差がひと目で分かる。数値を読み比べるより速い |
| W1 の振幅を戻し、周波数を 1.2 kHz に | 高さは同じだが周期が短く、時間が経つほど破線と山の位置がずれていく | 2 つの周波数の差 0.2 kHz が「うなり」のように現れる。ずれが 1 周期分たまるまでの時間は 1 / (1.2 kHz − 1.0 kHz) = **5 ms（計算値）** |
| 設定を基準と同じ（1 kHz・1 V）に戻す | 生きた波形が破線にぴったり重なる | 参照波形は「あのときの状態」をそのまま保持している——比較の基準として使える |

参照波形は保存した瞬間のスナップショットなので、あとから Wavegen や Scope の
設定をどれだけ変えても動かない。修理や調整の前後を比べる、他の実験（1-7 の
位相差など）の結果を後から重ねて見返す、といった使い方ができる。

## 出典

自作。
