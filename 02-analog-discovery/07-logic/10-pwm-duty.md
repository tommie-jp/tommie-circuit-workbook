---
book: analog-discovery
chapter: 7
id: 7-10
title: PWM のデューティを測る
tier: 100
source: 自作 (計器の操作は Digilent の Using the Logic Analyzer)
board: BB
---

# 7-10 PWM のデューティを測る

**PWM (パルス幅変調)** は、周期は一定のまま H の時間の割合 (デューティ比) を
変えて、LED の明るさやモータの速さを調整する定番の手法。ここでは Pattern で
作った PWM を LED に流して光り方を見ながら、Logic で捕まえた波形からデューティ
比を計算し、Pattern に設定した値と突き合わせる。

## 回路図

```circuit
title: 図1 Pattern で作った PWM を LED と Logic で見る
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [GND, DIO0]
  R1: resistor n1 n3 1k
  D1: led n3 n5 red
  G1: ground n5
wires:
  - AD.DIO0 -| n1
  - AD.GND -| n5
```

- R1 (1 kΩ) は LED の電流制限。DIO0 が H (3.3 V) のとき、赤 LED の順方向電圧を
  2.0 V とすると電流は (3.3 − 2.0) / 1 kΩ = **1.3 mA** — LED の上限 (20 mA) にも
  DIO の駆動能力 (AD2 の DIO は 4 mA 駆動) にも十分収まる
- DIO0 が L (0 V) の間、LED は消える。**デューティ比が高いほど点いている時間が
  長く、目には明るく見える** (人の目は数十 Hz 以上の点滅を積分して見る)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor f5 f7 1k
  D1: led/5mm g7(A) g9(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [GND, DIO0]
wires:
  - AD.DIO0 -- j5 yellow
  - AD.GND -- -b6 black
  - j9 -- -b9 black
```

R1 (f5〜f7) と D1 (g7〜g9) は列 7 で同じ下ブロックの列につながっているので、
R1 の f7 側と D1 のアノード (g7) は追加の配線なしでそのまま同じ節点になる。
DIO0 は R1 のもう一方の端 (f5 と同じ列の j5) から、GND は D1 のカソード側の列
(j9) から取る。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Pattern | DIO0 = Clock、1 kHz、**Duty = 25%** |
| Logic | DIO0 を Enable。Rate は 1 kHz より十分速く (1 MS/s 程度)。カーソルで H の時間と 1 周期の時間を読む |

## 見るべき値

計算値。Pattern の周期は 1 kHz → 1000 µs、Duty 25% として設定。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 周期の時間 | 1000 µs (1 kHz) | Pattern の周波数の設定どおり |
| H の時間 | 250 µs | 1000 µs × 25% |
| L の時間 | 750 µs | 1000 µs − 250 µs |
| デューティ比 = H の時間 / 1 周期 | 250 / 1000 = **25%** | Logic のカーソルで読んだ時間から計算した値が Pattern の設定と一致すれば OK |

**Duty を変えて (例えば 75%) 同じように測り直すと、LED の明るさが変わると
同時に Logic で読んだデューティ比の計算結果も変わる** — 明るさの見た目と
波形の数字が対応していることを確かめられる。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)
(Pattern Generator の節)。AD2 の DIO 駆動能力 (4 mA) は Analog Discovery 2
リファレンスマニュアルによる。
