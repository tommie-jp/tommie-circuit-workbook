---
book: analog-discovery
chapter: 2
id: 2-2
title: 測定 (Measurements) — Vpp・RMS・周波数・デューティ
tier: 50
source: 自作
board: BB
---

# 2-2 測定 (Measurements) — Vpp・RMS・周波数・デューティ

Scope の **Measurements** (自動計測) を使う。デューティ比 30% の方形波を
1 つ作り、Vpp・Vmax・Vmin・平均・RMS・周波数・デューティを一度に読む。

## 回路図

```circuit
title: 図1 デューティ 30% の方形波
parts:
  W1: square a1 c1 1.65
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

W1 は振幅 1.65 V・オフセット 1.65 V (0〜3.3 V)、デューティ 30% の方形波。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで方形波を測る
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
| Wavegen (W1) | 方形波、1 kHz、振幅 1.65 V、オフセット 1.65 V、デューティ 30% |
| Scope (CH1) | DC、Measurements に Vpp・Vmax・Vmin・Average・RMS・Frequency・Duty Cycle を追加 |

## 見るべき値

| 測定項目 | 期待する値 (計算値) | 計算 |
| --- | --- | --- |
| Vmax | 3.30 V | オフセット + 振幅 |
| Vmin | 0.00 V | オフセット − 振幅 |
| Vpp | 3.30 V | Vmax − Vmin |
| Average | 0.99 V | デューティ 30% × 3.3 V |
| RMS | 1.81 V | √0.3 × 3.3 V (2 値信号の RMS は √デューティ × High) |
| Frequency | 1.000 kHz | Wavegen の設定どおり |
| Duty Cycle | 30.0 % | Wavegen の設定どおり |

Average と RMS が Vpp や Vmax と全く違う値になることを確かめる —
方形波は正弦波と違い、デューティ比が Average と RMS の両方を左右する。

## 出典

自作。
