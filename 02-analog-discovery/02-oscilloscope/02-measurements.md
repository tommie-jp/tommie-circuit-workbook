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
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 デューティ 30% の方形波
parts:
  W1: square 1,1 1,3 1.65
  R1: resistor 3,1 3,3 1k
  M1: voltmeter 5,1 5,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 5,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/02-measurements.svg)

W1 は振幅 1.65 V・オフセット 1.65 V (0〜3.3 V)、デューティ 30% の方形波。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードで方形波を測る
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/02-measurements.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、1 kHz、振幅 1.65 V、オフセット 1.65 V、デューティ 30% |
| Scope (CH1) | DC、Measurements に Vpp・Vmax・Vmin・Average・RMS・Frequency・Duty Cycle を追加 |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 デューティ 30 % の方形波は Average 0.99 V・RMS 1.81 V
time: 200us/div
trigger: ch1 rising 1.65V
ch1: {wave: square 1kHz 1.65V offset 1.65V duty 30%, range: 500mV/div, position: -3div}
measure: [vmax, avg, rms, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/02-measurements.svg)

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

## LTspice での確かめ (対象外)

方形波の統計量の算術で確かめた。0〜3.3 V・デューティ 30 % で、Vmax 3.30 V、Vmin 0 V、Vpp 3.30 V、平均 0.3 × 3.3 = 0.99 V、RMS √0.3 × 3.3 = 0.548 × 3.3 = 1.81 V。本文の値と合う。

## 出典

自作。

参考: [WaveForms Oscilloscope (Digilent)](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)、[オシロスコープ (Wikipedia)](https://ja.wikipedia.org/wiki/オシロスコープ)、[デューティ比 (Wikipedia)](https://ja.wikipedia.org/wiki/デューティ比)
