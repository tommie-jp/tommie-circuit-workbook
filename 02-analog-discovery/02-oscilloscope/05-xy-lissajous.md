---
book: analog-discovery
chapter: 2
id: 2-5
title: XY 表示 — リサージュ図形
tier: 50
source: 自作
board: BB
---

# 2-5 XY 表示 — リサージュ図形

Scope を時間軸ではなく **XY 表示** (CH1 を横軸、CH2 を縦軸) にすると、
2 つの波形の位相関係が図形として見える。Wavegen の 2 系統 `W1` `W2` を
同じ周波数・位相差 90° にして、円を描く。

## 回路図

```circuit
title: 図1 W1 と W2 をそれぞれ CH1・CH2 に直結
parts:
  W1: sine a1 c1 1
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  W2: sine a5 c5 1
  M2: voltmeter a7 c7 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3
  - a5 -- a7
  - c1 -- c3 -- c5 -- c7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/05-xy-lissajous.svg)

外部の部品は無く、`W1`→`1+`、`W2`→`2+`、GND 共通のループバック。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 → 1+、W2 → 2+)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, W2, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.W2 -- a9 green
  - AD.2+ -- b9 blue
  - AD.GND -- -t3 black
  - AD.1- -- -t7 black
  - AD.2- -- -t11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/05-xy-lissajous.svg)

W1 と 1+ を 5 列、W2 と 2+ を 9 列に挿す。GND・1−・2− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V、位相 0° |
| Wavegen (W2) | 正弦波、1 kHz、振幅 1 V、位相 90° |
| Scope | 表示モードを **XY** に切り替え、X = CH1、Y = CH2 |

```scope
title: 図3 位相差 90°・同じ振幅は円になる
view: xy
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V phase 90deg, range: 500mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/05-xy-lissajous-1.svg)

```scope
title: 図4 同位相 (0°) は右肩上がりの直線
view: xy
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V, range: 500mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/05-xy-lissajous-2.svg)

```scope
title: 図5 W2 を 2 kHz (1:2) にすると 8 の字
view: xy
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 2kHz 1V, range: 500mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/05-xy-lissajous-3.svg)

## 見るべき値

| 設定 | 見え方 | 分かること |
| --- | --- | --- |
| 同じ周波数・位相差 90°・同じ振幅 | **円** | 位相差 90° の 2 つの正弦波は円を描く (計算値: x = sin θ, y = sin(θ+90°) = cos θ なので x² + y² = 1) |
| 位相差を 0° にする | 右肩上がりの**直線** | 同位相だと XY はただの直線になる |
| 位相差を 180° にする | 右肩下がりの**直線** | 逆位相でも直線 (傾きが逆) |
| W2 の周波数を W1 の 2 倍にする | **8 の字 (リサージュ図形)** | 周波数比 1:2 の代表的な形。比が単純な整数になるほど図形は安定する |

## 出典

自作。
