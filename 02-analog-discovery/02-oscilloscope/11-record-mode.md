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
（記録）がある。Record は、AD 本体のバッファに収めずに、パソコン側の
RAM やディスクへ**流し込みながら**記録するモードで、バッファ長の限界
（1-10 で見た 8k〜65,536 点/ch）を超えた長さを取り込める。

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
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- a10 black
  - AD.1+ -- b5 yellow
  - AD.1- -- b10 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1) | DC、取り込みモードを **Record** に切り替える、Sample Rate 1 MS/s、記録時間 10 s を指定してファイルへ保存 |

## 見るべき値

| 項目 | 数値 | 分かること |
| --- | --- | --- |
| 1 MS/s で 10 秒ぶんのサンプル数 | 1,000 万点（計算値） | Scope 本体のバッファ（AD3 で最大 65,536 点/ch）の**150 倍以上** |
| 本体バッファだけで 1 MS/s を記録できる長さ | 65,536 点 ÷ 1 MS/s ≈ 65.5 ms（AD3、CH1 のみの構成） | 通常の Repeated モードでは、この長さを超えると画面から古いデータが押し出される |
| Record モードで PC のディスクへ流し込む速さの目安 | 合計で最大 ~5 MS/s 程度（公式仕様。PC の性能に依存） | 1 MS/s はこの上限より十分低いので、10 秒間、途切れずに記録できる |
| 記録された波形の周期数 | 1 kHz × 10 s = 10,000 周期 | 1 画面には収まらない長さでも、後から波形全体をスクロールして追える |

Record モードの実際の上限（サンプルレートと記録できる長さ）は、パソコンの
処理能力とディスクの速さに左右される——ここでの ~5 MS/s は目安であって、
遅いパソコンではこれより低い速さでしか安定して記録できないことがある。

## 出典

自作。Record モードの転送速度の目安は Digilent の Analog Discovery 3 の公式仕様
（Horizontal System の節）による。
