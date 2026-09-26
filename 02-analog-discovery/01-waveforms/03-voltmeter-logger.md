---
book: analog-discovery
chapter: 1
id: 1-3
title: 電圧計とデータロガー — 分圧回路を 1 分記録する
tier: 50
source: 自作
board: BB
---

# 1-3 電圧計とデータロガー — 分圧回路を 1 分記録する

固定の分圧回路の電圧を、Voltmeter (電圧計) で一度読み、続けて
Data Logger (データロガー) で 1 分間記録する。オシロが「速い変化を
短く見る」のに対し、ロガーは「遅い変化を長く見る」道具だと分かる。

## 回路図

```circuit
title: 図1 分圧回路
parts:
  V1: vsource a1 c1 5
  R1: resistor a1 a3 2.2k
  R2: resistor a3 a5 1k
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - c1 -- c3 -- a5
```

V+ (5 V) を R1 (2.2 kΩ) と R2 (1 kΩ) で分圧し、その中点を CH1 で読む。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで分圧回路を記録する
board: half
parts:
  R1: resistor c5 c10 2.2k
  R2: resistor d10 d15 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, 1+, 1-, GND]
wires:
  - AD.V+ -- a5 red
  - AD.GND -- b15 black
  - AD.1+ -- b10 orange
  - AD.1- -- a15 black
```

R1 と R2 は 10 列の穴 (c10 / d10) で中点を共有する。CH1 はその中点
(b10) と GND (a15) から読む。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V にして Enable、Master Enable を入れる |
| Voltmeter | CH1、DC |
| Data Logger | 記録元 CH1、間隔 1 s、長さ 60 s (60 点) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Voltmeter (CH1) の 1 回の読み | 1.56 V (計算値。5 × 1k / (2.2k + 1k) = 1.5625 V) | 分圧の計算どおりか |
| Data Logger の 60 点 | すべて 1.56 V 前後で横ばい | 固定の抵抗分圧は時間が経っても変わらない (温度センサーなどを使う 1-9 との違い) |
| Data Logger のグラフの横軸 | 0〜60 s、60 点 | Scope の記録 (ms〜s のオーダー) より遥かに長い時間を扱える |

## 出典

自作。
