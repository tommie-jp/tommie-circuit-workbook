---
book: analog-discovery
chapter: 2
id: 2-16
title: サンプリングとエイリアス — 1 MHz を 1.2 MS/s で見る
tier: 100
source: 自作
board: BB
---

# 2-16 サンプリングとエイリアス — 1 MHz を 1.2 MS/s で見る

サンプルレートの半分（ナイキスト周波数）を超える信号を取り込むと、実際とは
違う低い周波数の波形として見えてしまう——これが**エイリアス（折り返し雑音）**。
ここでは 1 MHz の正弦波を、ナイキスト周波数 (0.6 MHz) が信号より低くなる 1.2 MS/s で、わざと
取り込み、200 kHz 付近に見える偽の波形を確かめる。

## 回路図

```circuit
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: sine 1,1 1,3 1
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/16-sampling-alias.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/16-sampling-alias.svg)

W1 と 1+ は同じ 5 列に挿し、GND と 1− は上の − レールにまとめる。部品は無く、電源も使わない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、**1 MHz**、振幅 1 V |
| Scope (CH1) | DC、Sample Rate を **1.2 MS/s** に指定する |

```scope
title: 図3 1.205 MS/s で取ると 1 MHz が 205 kHz に見える (エイリアス)
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: sine 205kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/16-sampling-alias-1.svg)

```scope
title: 図4 10 MS/s に戻すと正しく 1 MHz
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 1MHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/16-sampling-alias-2.svg)

図3 は WaveForms が点を結んで見せる形を描いたもの。1 周期あたりの点は
1.205 MS/s ÷ 205 kHz ≈ 6 点しか無いので、実機では角ばった正弦波に見える。

## 見るべき値

ナイキスト周波数 = サンプルレート ÷ 2 = 1.2 MHz ÷ 2 = **0.6 MHz**。信号
（1 MHz）はこれを超えているので、エイリアスが起きる。

エイリアス周波数 = |信号の周波数 − サンプルレートの整数倍のうち最も近いもの|
= |1 MHz − 1 × 1.2 MHz| = **0.2 MHz（200 kHz、計算値）**

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Scope に映る波形の周波数 | 約 200 kHz の正弦波（1 MHz には見えない） | 1 MHz の信号が、サンプルレートに対して折り返され、別の周波数として現れる |
| Wavegen を 1 MHz のまま、Sample Rate だけ 10 MS/s（ナイキスト 5 MHz）に戻す | 正しく 1.000 MHz の正弦波に見える | ナイキスト周波数を上回ってさえいなければエイリアスは起きない |

**注**: AD3 のサンプルレートは、システムクロック（既定 100 MHz、Device Options で
50〜125 MHz）を整数で割った値になる（整数で割る仕組みは、AD3 の資料では**未確認**。
WaveForms の一般的な動作としての説明）。1.2 MS/s ちょうどにはできず、100 MHz ÷ 83 ≈
**1.205 MS/s** に丸められる。この場合の
エイリアス周波数は |1 MHz − 1.205 MHz| ≈ **205 kHz** となり、上の計算値
（200 kHz）とわずかにずれる。この丸めのずれ自体も、サンプルレートが
「連続量ではなく飛び飛びの値」であることを示す一例になっている。

**最大の 125 MS/s ではどうか。** システムクロックを 125 MHz にすると、ナイキスト周波数は
125 ÷ 2 = **62.5 MHz**。AD3 のアナログ入力の帯域は BNC アダプタ有りで 30+ MHz（−3 dB）、
ヘッダ直結で 9 MHz（−3 dB）とどちらもこれより低い。最大のサンプルレートでは
**アナログ帯域が先に信号を減らす**ので、エイリアスは起きにくい（帯域の外の
信号が完全に消えるわけではない）。この題のエイリアスは、
サンプルレートを信号に対して低く選んだときの話。

## 出典

自作。システムクロック（50〜125 MHz、既定 100 MHz）・最大 125 MS/s・アナログ帯域は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
と
[Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
（Adjustable System Clock Frequency の節）による。
