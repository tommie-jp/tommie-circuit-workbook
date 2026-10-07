---
book: analog-discovery
chapter: 2
id: 2-3
title: カーソルで RC の時定数を読む
tier: 50
source: 自作
board: BB
---

# 2-3 カーソルで RC の時定数を読む

方形波を RC ローパスに通し、充電カーブをカーソルで読んで時定数
τ = RC を確かめる。自動計測 (2-2) では出てこない「時間の差」を、
カーソルで直接測る題。

## 回路図

```circuit
title: 図1 RC ローパスのステップ応答
parts:
  M1: voltmeter 1,1 1,3 l=$\mathrm{CH1}$
  W1: square 3,1 3,3 1.65
  R1: resistor 3,1 5,1 10k
  C1: capacitor 5,1 5,3 100n
  M2: voltmeter 7,1 7,3 l=$\mathrm{CH2}$
  G1: ground 3,3
wires:
  - 1,1 -- 3,1
  - 5,1 -- 7,1
  - 1,3 -- 3,3 -- 5,3 -- 7,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/03-cursors-rc.svg)

W1 (100 Hz、0〜3.3 V の方形波) を R1 (10 kΩ)・C1 (100 nF) の直列に通す。
CH1 は W1 の出力そのもの (方形波)、CH2 は C1 の両端 (充放電カーブ)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで RC ローパスを測る
board: half
parts:
  R1: resistor c7 c10 10k
  C1: capacitor d10 d15 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 2+, 1-, GND, 2-]
wires:
  - AD.W1 -- b7 yellow
  - AD.GND -- b15 black
  - AD.1+ -- a7 orange
  - AD.1- -- a15 black
  - AD.2+ -- b10 blue
  - AD.2- -- c15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/03-cursors-rc.svg)

R1 と C1 は 10 列の穴で中点 (RC の接続点) を共有する。CH2 はその中点
(b10) と GND (c15) から読む。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、100 Hz、振幅 1.65 V、オフセット 1.65 V (0〜3.3 V) |
| Scope (CH1・CH2) | DC、Time/div 1 ms 程度 |
| カーソル | 縦カーソル 2 本を X (時間) モードにする |

```scope
title: 図3 C の電圧 (CH2) が 2.08 V に届くまでをカーソルで読むと 1 τ = 1 ms
time: 1ms/div
trigger: ch1 rising 1.65V
ch1: {wave: square 100Hz 1.65V offset 1.65V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 500mV/div, position: -3div}
cursors: [0, 1ms]
measure: [vpp, vmax]
notes:
  - text ch2 1ms 2.08V: 1 τ で 63.2 %
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/03-cursors-rc.svg)

CH1 と CH2 は同じ 500 mV/div・同じ基準で重ねてある。画面の左半分は前の半周期の放電。

## 見るべき値

τ = R × C = 10 kΩ × 100 nF = **1.00 ms (計算値)**。

| カーソルの位置 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 本目: CH1 の立ち上がり (0 V → 3.3 V の瞬間) | t = 0 ms | 充電の起点 |
| 2 本目: CH2 が 2.08 V (= 0.632 × 3.3 V) に達した所 | t ≈ 1.00 ms | 1 τ で 63.2 % まで上がるという RC 回路の性質 |
| 2 本のカーソルの差 (Δt) | 1.00 ms ≈ τ の計算値と一致 | カーソルで時定数を直接読み取れる |
| 半周期 (5 ms) 経過後の CH2 | 3.3 V にほぼ達している (5 τ で 99.3 %) | 半周期を 5 τ 以上取ったので、次の遷移前に十分充電しきる |

## 出典

自作。
