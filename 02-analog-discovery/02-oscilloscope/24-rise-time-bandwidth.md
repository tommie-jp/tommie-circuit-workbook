---
book: analog-discovery
chapter: 2
id: 2-24
title: 立ち上がり時間から帯域を逆算する (tr = 0.35 / BW)
tier: 200
source: 自作
board: —
---

# 2-24 立ち上がり時間から帯域を逆算する (tr = 0.35 / BW)

2-10 では目安の式 **t<sub>r</sub> ≈ 0.35 / BW** を使って、帯域 BW から方形波の立ち上がり時間 t<sub>r</sub> を見積もった。
ここではその逆をする。オシロで t<sub>r</sub> を測り、**経路の帯域を t<sub>r</sub> から計算する**。
そのために、まず 0.35 がどこから来る数で、どこまで当てにできるかを導き、
次に AD3 の Wavegen と Scope を BNC でつないだ経路の t<sub>r</sub> を測って帯域を逆算する。
最後に、測りたい回路 (被測定物、DUT) の t<sub>r</sub> から計器の分を差し引く式を使う。

基板を使わない題 (W1 の BNC を同軸ケーブルで CH1 の BNC へ直結するだけで、組む回路が無い) なので、実体配線図は載せない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 等価回路 (W1 から CH1 までを 1 次の低域で表す)
parts:
  W1: square 2,2 2,4 1.65 l=$\mathrm{W1}$
  G1: ground 2,4
  R: resistor 2,2 5,2 l=$R_{\mathrm{eq}}$
  C: capacitor 5,2 5,4 l=$C_{\mathrm{eq}}$
  G2: ground 5,4
  M1: voltmeter 7,2 7,4 l=$\mathrm{CH1}$
  G3: ground 7,4
wires:
  - 5,2 -- 7,2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/24-rise-time-bandwidth.svg)

W1 は 100 kHz、0〜3.3 V の方形波 (図の 1.65 V は振幅で、オフセットも 1.65 V)。周期 10 µs (マイクロ秒) に対して立ち上がりは数十 ns なので、
1 つの立ち上がりだけを拡大して読める。Wavegen の出力・同軸ケーブル・Scope の入力をまとめて、
1 本の抵抗 R<sub>eq</sub> と 1 個のコンデンサ C<sub>eq</sub> の低域 (時定数 τ (タウ) = R<sub>eq</sub>C<sub>eq</sub>) で表したのが図1 (**等価回路**。部品として組むものではない)。

### 0.35 の出所 (1 次の低域)

1 次の低域にステップ (0→1) を入れると、出力は v(t) = 1 − e<sup>−t/τ</sup>。10 % と 90 % に着く時刻は

- t<sub>10</sub> = τ ln(1/0.9) = 0.105 τ
- t<sub>90</sub> = τ ln 10 = 2.303 τ
- t<sub>r</sub> = t<sub>90</sub> − t<sub>10</sub> = τ ln 9 = **2.197 τ**

一方、同じ回路の −3 dB の帯域は BW = 1/(2πτ) (π (パイ))。2 つを掛けると τ が消えて

**t<sub>r</sub> × BW = ln 9 / (2π) = 0.3497**

になる。0.35 は「1 次の低域なら厳密に成り立つ数」で、近似ではない。

### 1 次でない経路では

実際の経路は 1 次とは限らない。帯域を 10 MHz にそろえた 3 つの低域のステップ応答を並べたのが図3。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 帯域 10 MHz の 3 つの低域 — 形は違っても 10→90 % はどれも 34〜35 ns
x: 時間 ns 0..100
y: 応答 % 0..110
lines:
  1 次 (RC) %: 100*(1-exp(-62.83M*x*1n))
  同じ極 2 つ %: 100*(1-exp(-97.63M*x*1n)*(1+97.63M*x*1n))
  2 次 Butterworth %: 100*(1-exp(-44.43M*x*1n)*(cos(44.43M*x*1n)+sin(44.43M*x*1n)))
notes:
  - level 10%
  - level 90%
  - mark 1.68
  - mark 5.45
  - mark 8.05
  - mark 36.65
  - mark 39.84
  - mark 42.23
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/graph/24-rise-time-bandwidth.svg)

| 低域の形 | 10 % の時刻 | 90 % の時刻 | t<sub>r</sub> | t<sub>r</sub> × BW | 行き過ぎ |
| --- | --- | --- | --- | --- | --- |
| 1 次 (RC) | 1.68 ns | 36.65 ns | 34.97 ns | 0.350 | なし |
| 同じ極 2 つ (RC を 2 段、間をバッファで切る) | 5.45 ns | 39.84 ns | 34.39 ns | 0.344 | なし |
| 2 次 Butterworth (ζ (ゼータ) = 0.707) | 8.05 ns | 42.23 ns | 34.19 ns | 0.342 | 4.3 % |

形が違うと立ち上がりの始まりは遅れる (遅延が増える) が、10→90 % の幅はほとんど変わらない。
行き過ぎ (オーバーシュート) の無い・小さい経路なら **0.34〜0.35** に収まる。
帯域の端で急に切れる (肩の鋭い) 特性のオシロでは 0.4〜0.45 になると言われる (目安)。その場合 0.35 で逆算すると帯域を 2〜3 割小さく見積もる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 接続 | BNC アダプタの W1 の BNC から CH1 の BNC へ同軸ケーブル (50 cm ほど) |
| Wavegen (W1) | 方形波、100 kHz、振幅 1.65 V、オフセット 1.65 V |
| Scope (CH1) | DC、500 mV/div、Time 10 ns/div、Trigger CH1 の立ち上がり 1.65 V、サンプリングは最速 (125 MS/s にするにはシステムクロックを 125 MHz に。2-10) |
| 平均 | Average 16 回 (2-14)。1 回ごとの雑音で 10 % と 90 % の点がぶれるのを抑える |
| 読み方 | Measurements の Rise Time か、縦カーソルを 10 % (0.33 V) と 90 % (2.97 V) の高さの点に合わせて時間差を読む |

2-10 の値 (Wavegen 12 MHz、Scope 30 MHz 以上) から見込んだ立ち上がり (約 31 ns) を、1 次の低域 τ = 14.3 ns で描いたのが図2。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 BNC でつないだ W1→CH1 の立ち上がり (10→90 % で約 31 ns)
time: 10ns/div
trigger: ch1 rising 1.65V at -3div
ch1: {wave: square 100kHz 1.65V offset 1.65V | rc 14.3ns, range: 500mV/div, position: -3div}
cursors: [-8.4ns, 23.0ns]
measure: [rise, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/24-rise-time-bandwidth.svg)

カーソルは 10 % の高さ (0.33 V) と 90 % の高さ (2.97 V) の点。125 MS/s でも 1 標本は 8 ns で、31 ns の立ち上がりには点が 4 つほどしか乗らない。
WaveForms は標本の間を補って線を引くので、カーソルは線の上に置けるが、読み値は 1〜2 ns ほどぶれると見ておく (目安)。

## 見るべき値

### 1. 経路の帯域を逆算する

計算値と読み方の例。**BW = 0.35 / t<sub>r</sub>**。

| 読んだ t<sub>r</sub> (例) | 逆算した BW | 分かること |
| --- | --- | --- |
| 31 ns | 11.3 MHz | Wavegen (12 MHz) と Scope (30 MHz 以上) を合わせた帯域。遅いほう (Wavegen) でほぼ決まる |
| 35 ns | 10.0 MHz | 同軸ケーブルが長い、または Wavegen の出力の設定で遅くなった場合 |
| 55 ns (付属ワイヤ、2-10) | 6.4 MHz | 付属ワイヤの経路 (9 MHz と 9 MHz) の合成 |

経路に帯域を決めるものが 2 つ直列にあるとき、立ち上がりは二乗和の平方根で合わさる
(t<sub>r,合成</sub> = √(t<sub>r1</sub><sup>2</sup> + t<sub>r2</sub><sup>2</sup>))。
Scope の 30 MHz は t<sub>r</sub> = 0.35 / 30 MHz = 11.7 ns なので、31 ns と読めたら Wavegen の側は
√(31<sup>2</sup> − 11.7<sup>2</sup>) = 28.7 ns、帯域にして 0.35 / 28.7 ns = 12.2 MHz。仕様の 12 MHz と合う。

### 2. 被測定物 (DUT) の帯域を計器の分を差し引いて出す

DUT を挟んで読んだ t<sub>r,読み</sub> から、計器だけの t<sub>r,計器</sub> (ここでは 31 ns) を引く:
**t<sub>r,DUT</sub> = √(t<sub>r,読み</sub><sup>2</sup> − t<sub>r,計器</sub><sup>2</sup>)**。計算値。

| DUT の本当の帯域 | DUT の t<sub>r</sub> | 読める t<sub>r</sub> | 差し引かずに逆算した BW | 差し引いて逆算した BW |
| --- | --- | --- | --- | --- |
| 1.59 MHz (RC 1 kΩ (キロオーム)・100 pF) | 220 ns | 222 ns | 1.57 MHz (−1 %) | 1.59 MHz |
| 5 MHz | 70 ns | 76.6 ns | 4.57 MHz (−9 %) | 5.0 MHz |
| 10 MHz | 35 ns | 46.8 ns | 7.48 MHz (−25 %) | 10.0 MHz |

**DUT の t<sub>r</sub> が計器の 3 倍より長ければ、差し引かなくても誤差は 5 % ほど** (3 倍で √(1 + 1/9) = 1.054)。
それより速い DUT では差し引きが要り、計器と同じくらい速い DUT では、読みの小さな誤差が大きく効くので当てにならない。
二乗和の平方根の式そのものも目安で、2-10 のように同じ極が 2 つ重なると厳密な値より 8 % ほど短く出る。

## LTspice での確かめ

`sim/24-rise-bw-tran.cir` (ステップ応答の 10→90 %) と `sim/24-rise-bw-ac.cir` (−3 dB の周波数) で、
帯域 10 MHz にそろえた 3 つの低域と、AD3 の経路の等価 (1 次、τ = 14.3 ns) を解いた。素子は理想で、AD3 の経路は 1 次と仮定した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 次の t<sub>r</sub> と帯域 | 34.97 ns、10 MHz (積 0.350) | 34.98 ns、10.00 MHz | 合う |
| 同じ極 2 つの t<sub>r</sub> | 34.39 ns (積 0.344) | 34.39 ns (帯域 10.00 MHz) | 合う |
| 2 次 Butterworth の t<sub>r</sub> と行き過ぎ | 34.19 ns (積 0.342)、4.3 % | 34.19 ns、4.32 % (帯域 10.00 MHz) | 合う |
| AD3 の経路の等価 (τ = 14.3 ns) | t<sub>r</sub> 31.4 ns、BW 11.1〜11.3 MHz | 31.42 ns、11.13 MHz | 合う (0.35 / 31.42 ns = 11.14 MHz) |

図2 の読み値の Rise (31.19 ns) が 31.4 ns より少し短いのは、図が標本の点から読むため。表 2 の数 (222 ns・46.8 ns など) は二乗和の平方根の算術。

## 出典

自作。帯域の数値は 2-10 と同じ Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf) による。

参考: [Rise time (Wikipedia)](https://en.wikipedia.org/wiki/Rise_time)、[Butterworth filter (Wikipedia)](https://en.wikipedia.org/wiki/Butterworth_filter)
