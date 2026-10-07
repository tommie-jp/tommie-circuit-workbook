---
book: analog-discovery
chapter: 1
id: 1-10
title: デバイスマネージャ — 計器ごとのバッファ長の配分を切り替える
tier: 100
source: 自作 (数値は Digilent の Analog Discovery 3 の公式資料)
board: BB
device: AD3
---

# 1-10 デバイスマネージャ — 計器ごとのバッファ長の配分を切り替える

Analog Discovery 3 (AD3) は、Scope・Wavegen・Logic Analyzer・Pattern
Generator が使う記録メモリの配分を、あらかじめ決められた**6 通りの構成**から
選ぶ。**Device Manager**（`Settings > Device Manager`）は、その構成を選ぶ画面。
ここでは Scope と Wavegen のバッファ長（1 チャネルあたりの記録点数）が構成ごとに
どう入れ替わるかを確かめる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/10-device-manager-buffer.svg)

配線は 0-3 のループバックのまま。ここで変えるのは配線ではなく、Device Manager
の設定。

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/10-device-manager-buffer.svg)

W1 と 1+ を同じ 5 列に挿し、GND と 1− は上の − レールにまとめる。部品は無く、電源も使わない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1・CH2) | 今の構成でまず Buffer（Scope の記録点数の設定欄）の上限を確認する |
| Device Manager | 今の構成 → Scope が最大の構成 2 → Scope が最小の構成 5 と切り替え、そのつど Scope の Buffer の上限を見る |

どの構成でも、波形そのものは同じに見える。構成が変えるのは記録点数 (Buffer の上限) だけで、図3 は
どの構成でも読める 1 kHz・振幅 1 V の正弦波である。

```scope
title: 図3 構成を切り替えても CH1 の波形は同じ — Vpp 2.00 V・1.000 kHz
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
cursors: [0, 1ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/10-device-manager-buffer.svg)

## 見るべき値（AD3）

AD3 のリファレンスマニュアル（Device Configuration の節、Table 1）に、構成 1〜6 の
バッファ長が載っている。単位の KiS は 1024 サンプル（1 KiS = 1,024 点）。

| 構成 | Scope | Wavegen（搬送波） | Logic Analyzer | Pattern Generator |
| --- | --- | --- | --- | --- |
| 1 | 16 KiS（16,384 点） | 16 KiS | 16 KiS | 2 KiS |
| 2 | **32 KiS（32,768 点）** | 4 KiS | 4 KiS | 2 KiS |
| 3 | 8 KiS（8,192 点） | **32 KiS** | 2 KiS | 2 KiS |
| 4 | 16 KiS | 4 KiS | **32 KiS** | 2 KiS |
| 5 | 4 KiS（4,096 点） | 4 KiS | **32 KiS** | **32 KiS** |
| 6 | 8 KiS | 16 KiS | 2 KiS | 2 KiS |

読み方:

- 仕様の「Scope のバッファは最大 32,768 点/ch」は、構成 2 の 32 KiS に当たる。
  表の値は 1 チャネルあたりと読む（マニュアルの表には 1 チャネルあたりか合計かの
  明記が無く、仕様の「per channel」との一致からの判断。**未確認**）
- 仕様の脚注に、**Scope を 1 チャネルだけ使うと 65,536 点まで増える**とある
  （2 チャネルぶんのメモリを 1 チャネルに集める。構成 2 なら 32,768 × 2 = 65,536）
- **どの構成が既定かは、手元の資料に書かれていない（未確認）**。実機の Device Manager で
  選択中の構成と、Scope の Buffer の上限を見て確かめる

| 構成 | CH1 のバッファ長 | CH2 は使えるか |
| --- | --- | --- |
| 構成 2（Scope 最大） | 32,768 点 | 使える |
| 構成 2 で CH1 のみ | 65,536 点（2 倍） | 使えない |
| 構成 5（Scope 最小） | 4,096 点 | 使える |

構成 2 と 5 で Scope が 8 倍（32,768 ÷ 4,096）違う代わりに、構成 5 は Logic Analyzer と
Pattern Generator が 32 KiS に増える。**今の実験に要らない計器のメモリを削って、
使う計器に長い記録を回す**、というのがこの画面の考え方。

Wavegen は、Custom（3-4・3-10）で作れる波形の点数が構成で変わる（構成 3 で最大の
32,768 点）。Scope の記録点数がこの範囲を超えるときは、2-11 の Record モード
（パソコン側へ流し込む）を使う。

設定を切り替えるとデバイスの再構成（FPGA の書き直し）が入り、一瞬デバイスが
切断されたように見えることがある——実験中の波形は失われるので、切り替えは測定の
合間に行う（この再構成の挙動は WaveForms の一般的な動作で、AD3 のマニュアルの
その節には書かれていない。**未確認**）。

## 出典

自作。バッファ長は Digilent の
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
（Device Configuration の Table 1）と
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
（Horizontal System の節）による。
