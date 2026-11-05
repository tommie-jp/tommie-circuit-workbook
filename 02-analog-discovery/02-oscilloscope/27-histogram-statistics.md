---
book: analog-discovery
chapter: 2
id: 2-27
title: 測定のヒストグラムと統計
tier: 200
source: 自作
board: BB
---

# 2-27 測定のヒストグラムと統計

雑音のように毎回違う波形は、1 回の画面の値 (RMS・平均) を読んでも、その数がどれだけ確かか分からない。
WaveForms の Scope には、**電圧の分布を数えるヒストグラム**の表示と、**測定 (Measurements) を取り込みごとに集めた統計** (平均・最小・最大など) がある。
この題では W1 の雑音 (Noise) を RC の低域に通し、

- 入力 (CH1) と出力 (CH2) で**分布の形**がどう変わるか (平らな分布 → 釣り鐘の分布)
- 出力の RMS が取り込みごとにどれくらい揺れ、何回分の平均で数が落ち着くか

を見る。雑音の RMS は分布の幅 (標準偏差 σ (シグマ)) と同じ量で、ヒストグラムと Measurements の 2 つで同じ数を読むことになる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の Noise を RC の低域 (時定数 100 µs) に通す
parts:
  W1: vsource 2,2 2,4 l=$\mathrm{W1}$
  G1: ground 2,4
  M1: voltmeter 3.5,2 3.5,4 l=$\mathrm{CH1}$
  G2: ground 3.5,4
  R1: resistor 5,2 8,2 10k
  C1: capacitor 9.5,2 9.5,4 10n
  G3: ground 9.5,4
  M2: voltmeter 11,2 11,4 l=$\mathrm{CH2}$
  G4: ground 11,4
wires:
  - 2,2 -- 3.5,2 -- 5,2
  - 8,2 -- 9.5,2 -- 11,2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/27-histogram-statistics.svg)

- W1 は Noise (雑音)、振幅 1 V、オフセット 0 V。新しい乱数に替わる速さ (Noise の周波数の欄) を 100 kHz にする (目安)
- R1 (10 kΩ (キロオーム)) と C1 (10 nF) の低域。時定数 τ (タウ) = 100 µs (マイクロ秒)、−3 dB は 1.59 kHz
- CH1 は W1 (入力)、CH2 は C1 の両端 (出力)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (R1 と C1 の 2 個だけ)
board: half
parts:
  R1: resistor c8 c14 10k
  C1: capacitor/film e14 e18 10n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, 1+, W1, 2+, 2-]
wires:
  - AD.W1 -- a8 yellow
  - b8 -- b6 white
  - AD.1+ -- a6 orange
  - AD.2+ -- a14 blue
  - a18 -- -t18 black
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/27-histogram-statistics.svg)

W1 は 8 列 (a8)。8 列から白い線で 6 列へ渡し、a6 に CH1 (1+)。R1 は c8〜c14、C1 は e14〜e18 で 18 列を − レールへ。CH2 (2+) は 14 列 (a14)。
GND・1−・2− は上の − レール。電源 (Supplies) は使わない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | Noise、周波数 100 kHz、振幅 1 V、オフセット 0 V |
| Scope | CH1 500 mV/div、CH2 200 mV/div、Time 1 ms/div (1 回の取り込みは 10 ms)、Trigger は Auto (雑音にはきれいに掛からない) |
| Measurements | CH1・CH2 の RMS と Average。統計の表示 (取り込みごとの値を集めた平均・最小・最大・回数など) を有効にする |
| ヒストグラム | Scope の表示に Histogram を足す (電圧ごとの点の数) |

統計とヒストグラムの欄の名前と置き場は WaveForms の版で違う (目安。Scope の View の欄と、Measurements の窓の設定)。

見えるはずの画面が図3。雑音は scope の図の波の書き方では描けないので、W1 の Noise を「±1 V の一様分布の乱数を 100 kHz ごとに替える」と仮定し、
RC を通した波形を計算して `27-noise-rc.csv` に置いた (実測ではない)。破線は平均 (0 V) の位置。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH1 (W1 の Noise) と CH2 (RC の後) — 計算した波形
time: 1ms/div
trigger: ch1 rising 0V
ch1: {wave: dc 0V, range: 500mV/div, position: 2div}
ch2: {wave: dc 0V, range: 200mV/div, position: -2div}
data: 27-noise-rc.csv 計算
measure: [rms, avg, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/27-histogram-statistics.svg)

図3 の 1 回 (10 ms) の CH2 の RMS は 132 mV。次の取り込みでは別の数になる (下の表)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 50 mV ごとの割合 — CH1 は平ら (一様)、CH2 は釣り鐘 (σ = 0.129 V)
x: 電圧 V -1.2..1.2
y: 割合 % 0..18
lines:
  CH1 (一様 ±1 V) %:
    - -1.2 0
    - -1.001 0
    - -0.999 2.5
    - 0.999 2.5
    - 1.001 0
    - 1.2 0
  CH2 (正規 σ 0.129 V) %: 5*exp(-x^2/(2*0.129^2))/(0.129*sqrt(2*pi))
notes:
  - mark 0
  - mark 0.129
  - mark 0.258
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/graph/27-histogram-statistics.svg)

図4 は、CH1・CH2 のヒストグラムが十分な数の点で近づくはずの形 (50 mV の幅ごとに点の何 % が入るか)。CH1 は −1〜+1 V に平らに 2.5 % ずつ、
CH2 は 0 V を中心に σ = 0.129 V の正規分布 (釣り鐘)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 10 kΩ |
| C1 | フィルムコンデンサ | 10 nF (103) |

## 見るべき値

計算値。CH1 は ±A (A = 1 V) の一様分布なので、平均 0 V、RMS = A/√3 = 0.577 V。
CH2 の分散は、100 kHz ごとに替わる入力 (間隔 T = 10 µs) を τ = 100 µs の RC に通すので、a = e<sup>−T/τ</sup> = 0.905 として
σ<sub>出力</sub><sup>2</sup> = σ<sub>入力</sub><sup>2</sup> × (1 − a)/(1 + a) = σ<sub>入力</sub><sup>2</sup> × 0.050 (≈ π f<sub>c</sub> T の近似とも合う)。
σ<sub>出力</sub> = 0.577 V × √0.050 = **0.129 V**。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 のヒストグラム | −1〜+1 V に平ら (端で落ちる) | W1 の Noise が一様分布かどうか (目安。平らでなければ、その形が W1 の Noise の分布) |
| CH2 のヒストグラム | 0 V を中心にした釣り鐘。±σ (±0.129 V) に点の約 68 %、±2σ に約 95 % | RC が 10 個ほどの乱数を足し合わせる (τ / T = 10) ので、平らな分布が正規分布に近づく (中心極限定理) |
| CH1 の RMS | 0.577 V | 一様分布の RMS は A/√3 |
| CH2 の RMS (多くの回の平均) | 0.129 V | 帯域を絞ると雑音が減る: √0.050 = 0.22 倍 |
| CH2 の RMS の取り込みごとの揺れ (10 ms ごと) | 標準偏差で 8 mV ほど (6 %)、最小と最大で 108〜143 mV ほど | 10 ms の中に互いに似ていない区間が数十しか無いので、1 回の RMS は 6 % ほどしか確かでない |
| CH2 の Average の取り込みごとの揺れ | 標準偏差で 19 mV ほど | 平均 0 V の雑音でも、1 回の画面の平均は 0 にならない |
| 統計の平均の確かさ | N 回の平均で 1/√N。100 回で 6 % → 0.6 % | 回数を増やせば統計の平均は落ち着く。最小と最大は回数とともに広がる |

**1 回の画面で読んだ雑音の数は、その確かさと一緒に書く** (この題なら「RMS 0.13 V ± 6 %」)。
Measurements の統計の平均を読めば、それが小さくなる。ヒストグラムの幅からも σ が読めて、Measurements の RMS と同じ数になる (平均が 0 のとき)。

## LTspice での確かめ

`sim/27-noise-rc.cir` で、W1 の Noise を ±1 V の一様な乱数を 100 kHz ごとに替える源 (`rand()`。仮定) にして RC に通し、
200 ms ぶんの RMS と、10 ms ずつ 5 回の RMS を読んだ。取り込みごとの揺れ (99 回の統計) と図3 の波形は、同じ仮定で Python で計算した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| CH1 の RMS | 0.577 V | 0.568 V | 合う (1.6 % 低い。200 ms の乱数の数のばらつきの内) |
| CH2 の RMS (200 ms) | 0.129 V | 0.128 V | 合う |
| CH2 の平均 (200 ms) | 0 V | −4.0 mV | 合う (200 ms の平均の揺れの目安 ±4 mV) |
| CH2 の最大・最小 | ±0.43 V ほど (±3.3σ) | +0.425 V・−0.435 V | 合う |
| CH2 の 10 ms ごとの RMS (5 回) | 108〜143 mV ほど | 118〜133 mV | 合う |

Python の計算 (1 s、10 ms の取り込み 99 回) では、CH2 の RMS が平均 127 mV・標準偏差 7.8 mV、±σ に 67.6 %・±2σ に 95.7 %、Average の標準偏差 18.8 mV。表の値はこの数による。

## 出典

自作。

参考: [ヒストグラム (Wikipedia)](https://ja.wikipedia.org/wiki/ヒストグラム)、[中心極限定理 (Wikipedia)](https://ja.wikipedia.org/wiki/中心極限定理)、[連続一様分布 (Wikipedia)](https://ja.wikipedia.org/wiki/連続一様分布)
