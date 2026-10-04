---
book: analog-discovery
chapter: 2
id: 2-10
title: 帯域の違いを方形波の立ち上がりで見る (9 / 30 MHz)
tier: 100
source: 自作
board: BB
---

# 2-10 帯域の違いを方形波の立ち上がりで見る (9 / 30 MHz)

帯域 BW と立ち上がり時間 t<sub>r</sub> には、よく使われる目安の関係
**t<sub>r</sub> ≈ 0.35 / BW** がある（正確な導出は 2-24）。ここではこの式を使い、
0-5・0-6 で見た AD3 の「30 MHz+（BNC アダプタ有り。この教科書の標準）」と
「9 MHz（アダプタ無しの付属ワイヤ）」が、方形波の立ち上がり時間にしてどれくらいの
差になるかを見積もり、付属ワイヤの分は実際にカーソルで測って確かめる
（アダプタが無くても手元でできるのは付属ワイヤの側なので、測るのはこちら）。

## 回路図

```circuit
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: square a1 c1 1.65
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/10-bandwidth-rise-time.svg)

W1（100 kHz、0〜3.3 V の方形波）を CH1 に直結。周期 10 μs に対して立ち上がりは
ずっと短いので、他のエッジと混ざらずに 1 つの立ち上がりだけを拡大して見られる。

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/10-bandwidth-rise-time.svg)

W1 と 1+ は同じ 5 列に挿す。GND と 1− は上の − レールにまとめる。部品は無く、電源も使わない。
付属ワイヤ (ヘッダ直結) でつなぐので、測るのは 9 MHz の側 (「見るべき値」の表の付属ワイヤの行)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、100 kHz、振幅 1.65 V、オフセット 1.65 V（0〜3.3 V） |
| Scope (CH1) | DC、Time/div 10〜20 ns（立ち上がり 1 つを画面いっぱいに拡大） |
| カーソル | 縦カーソル 2 本を、10%（0.33 V）と 90%（2.97 V）の高さに合わせて X モード |

付属ワイヤの経路を 1 次の低域 (t<sub>r</sub> = 2.2 τ = 55 ns、τ = 25 ns) とみなして描いた、
見えるはずの立ち上がりが図3。カーソルは 10 % (0.33 V) と 90 % (2.97 V) の所。

```scope
title: 図3 カーソルで 10 %→90 % を読むと約 55 ns
time: 20ns/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 100kHz 1.65V offset 1.65V | rc 25ns, range: 500mV/div, position: -3div}
cursors: [-14.7ns, 40.3ns]
measure: [rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/10-bandwidth-rise-time.svg)

## 見るべき値

ループバックでは発生器とオシロが直列に効くので、それぞれの立ち上がり時間を
二乗和の平方根で合成する（t<sub>r,合成</sub> = √(t<sub>r,Wavegen</sub>² + t<sub>r,Scope</sub>²)）。

| 経路 | Wavegen の BW（−3 dB） | Scope の BW（−3 dB） | t<sub>r</sub> = 0.35/BW（各） | 合成 t<sub>r</sub>（計算値） |
| --- | --- | --- | --- | --- |
| BNC アダプタ（標準） | 12 MHz | 30 MHz+ | 29.2 ns、11.7 ns（以下） | **約 31 ns**（以下） |
| 付属ワイヤ（ヘッダ直結） | 9 MHz | 9 MHz | 38.9 ns、38.9 ns | **約 55 ns** |

BNC アダプタ有りの Scope は「30 MHz **以上**」なので、11.7 ns と 31 ns は
「これ以下（これより速い）」の値になる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| カーソルで読む付属ワイヤの立ち上がり時間（10%→90%） | 約 55 ns（計算値。実測はこれより長め・短めどちらもあり得る目安） | 9 MHz という帯域の数字が、実際の波形の速さに直結する |
| 既定の 100 MS/s（1 サンプル = 10 ns）での 55 ns ぶんのサンプル数 | 約 5〜6 点（55 ÷ 10 = 5.5） | 立ち上がりを正確に読むにはぎりぎりの点数。Time/div をこれ以上速くしても、サンプル点はこれしか無い |
| 最大の 125 MS/s（1 サンプル = 8 ns）にしたときの点数 | 約 7 点（55 ÷ 8 ≈ 6.9） | Device Options でシステムクロックを 125 MHz にすると 2 割ほど増える。AD3 の既定のクロックは 100 MHz |
| BNC アダプタ経由の立ち上がり（計算のみ、ここでは実測しない） | 約 31 ns（以下）。125 MS/s で 4 点弱（31 ÷ 8 ≈ 3.9） | 付属ワイヤの約 55 ns より速いが、Wavegen 自身の 12 MHz が効いて 0 にはならない（0-5 の議論のとおり）。点数は 4 点ほどしか無く、立ち上がりの形を細かく見るには足りない |
| ナイキスト周波数（125 MS/s で 62.5 MHz）と入力帯域 | 30+ MHz（BNC）・9 MHz（ヘッダ）はどちらもナイキストより下 | 通常の使い方ではエイリアスより先に帯域（アナログ）が信号を削る。エイリアスが問題になるのは 2-16 のようにサンプルレートを下げたとき |

**立ち上がりが速いほど、帯域の数字を裏から確かめられる**——これが 2-24 で
tr = 0.35 / BW の式を厳密に扱うときの土台になる。

## 出典

自作。帯域の数値（Wavegen 9 MHz / 12 MHz、Scope 9 MHz / 30+ MHz）、最大サンプルレート
125 MS/s、既定のシステムクロック 100 MHz は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
と
[Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
（Adjustable System Clock Frequency の節）による。
tr ≈ 0.35 / BW は帯域とステップ応答の立ち上がり時間を結ぶ、教科書でよく使われる
近似式。
