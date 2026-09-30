---
book: analog-discovery
chapter: 2
id: 2-11
title: Record モードで長時間 (ディスクへ)
tier: 100
source: 自作
board: BB
---

# 2-11 Record モードで長時間 (ディスクへ)

Scope の取り込みモードには、通常の Repeated（繰り返し）のほかに **Record**
（記録）がある。Record は、AD3 本体のバッファに収めずに、パソコン側の
RAM やディスクへ**流し込みながら**記録するモードで、バッファ長の限界
（1-10 で見た 4,096〜65,536 点/ch）を超えた長さを取り込める。

## 回路図

```circuit
title: 図1 正弦波を作って測る (1-2 と同じ)
parts:
  W1: sine a1 c1 1
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/11-record-mode.svg)

1-2 と同じ、正弦波 → 負荷抵抗 → CH1 の回路。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで正弦波を測る (1-2 と同じ)
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 1-, GND]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b10 black
  - AD.1+ -- a5 orange
  - AD.1- -- a10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/11-record-mode.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1) | DC、取り込みモードを **Record** に切り替える、Sample Rate 1 MS/s、記録時間 10 s を指定してファイルへ保存 |

## 見るべき値

| 項目 | 数値 | 分かること |
| --- | --- | --- |
| 1 MS/s で 10 秒ぶんのサンプル数 | 1,000 万点（計算値） | Scope 本体のバッファ（AD3 で最大 65,536 点/ch、1-10）の**150 倍以上**（1000 万 ÷ 65,536 ≈ 153） |
| 本体バッファだけで 1 MS/s を記録できる長さ | 65,536 点 ÷ 1 MS/s ≈ 65.5 ms（AD3、CH1 のみの構成） | 通常の Repeated モードでは、この長さを超えると画面から古いデータが押し出される |
| Record モードで PC へ流し込む速さの目安 | パソコンの RAM へは合計で最大 ~10 MS/s、ディスクのファイルへは合計で最大 ~5 MS/s 程度（公式仕様。PC の性能に依存） | 1 MS/s はどちらの上限より十分低いので、10 秒間、途切れずに記録できる |
| 記録された波形の周期数 | 1 kHz × 10 s = 10,000 周期 | 1 画面には収まらない長さでも、後から波形全体をスクロールして追える |

Record モードの実際の上限（サンプルレートと記録できる長さ）は、パソコンの
処理能力とディスクの速さに左右される——ここでの ~10 MS/s・~5 MS/s は目安であって、
遅いパソコンではこれより低い速さでしか安定して記録できないことがある。

## 出典

自作。Record モードの転送速度の目安は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
（Horizontal System の節）による。
