---
book: analog-discovery
chapter: 3
id: 3-4
title: カスタム波形 (CSV) と Play
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-4 カスタム波形 (CSV) と Play

Wavegen の Function には **Custom** (くり返す) と **Play** (1 回だけ出す) という
2 つの「自分で作った波形」がある。CSV で 8 段の階段波形を作り、Custom で
くり返し、Play で 1 回だけ出して違いを見る。

## 回路図

```circuit
title: 図1 ループバック (W1 を 1+ に直結)
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/04-custom-waveform.svg)

V1 の記号は正弦だが、実際は下の CSV の波形が出る。

## 作る CSV

8 点、-1 から 1 まで等間隔に上がる階段。1 行 1 値 (正規化した振幅、-1〜1)。

```text
-1.000
-0.714
-0.429
-0.143
0.143
0.429
0.714
1.000
```

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+ に直結)
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/04-custom-waveform.svg)

W1 と 1+ は 5 列に挿すだけで、列の内側でつながる。GND と 1− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (Custom) | Function: Custom、上の CSV を読み込む。Frequency 1 kHz、Amplitude 1 V、Offset 0 V。Run で連続出力 |
| Wavegen (Play) | Function: Play、同じ CSV。Run (Single) を 1 回押すと 1 周期だけ出て止まる |
| Scope | CH1: DC 結合、Time/div 125 µs/div、Range 500 mV/div |

Frequency 1 kHz なので 1 周期 = 1000 µs。8 点を均等に敷くので、
**1 段の幅は 1000 µs ÷ 8 = 125 µs**。

```scope
title: 図3 Custom は 8 段の階段を 125 µs ずつくり返す
time: 125us/div
trigger: ch1 rising 0V at -5div
ch1: {wave: = 0.143V - 0.286V*step(-t) + 0.2857V*(step(t-125us)+step(t-250us)+step(t-375us)+step(t-625us)+step(t-750us)+step(t-875us)+step(t-1ms)+step(t-1125us)) - 2V*step(t-500us), range: 500mV/div}
cursors: [562.5us, 687.5us]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/04-custom-waveform.svg)

X1 は段 0 (−1.000 V)、X2 は段 1 (−0.714 V) の中ほどで、ΔX が 1 段の幅 125 µs。

## 見るべき値

計算値。CSV の値 v (−1〜1) に Amplitude 1 V を掛けた電圧がそのまま出る
(Offset 0 V なので v そのもの)。

| 段 (k = 0〜7) | CSV の値 | 出力電圧 | 続く時間 |
| --- | --- | --- | --- |
| 0 | −1.000 | −1.000 V | 125 µs |
| 1 | −0.714 | −0.714 V | 125 µs |
| 2 | −0.429 | −0.429 V | 125 µs |
| 3 | −0.143 | −0.143 V | 125 µs |
| 4 | 0.143 | 0.143 V | 125 µs |
| 5 | 0.429 | 0.429 V | 125 µs |
| 6 | 0.714 | 0.714 V | 125 µs |
| 7 | 1.000 | 1.000 V | 125 µs |

分かること:

- **Custom は Run を押している間ずっとくり返す** (連続する階段波形として見える)。
  **Play は 1 回押すごとに 1 周期だけ**出て止まる。決まった並びを 1 回だけ
  送りたい実験に向く
- 段の数を増やすほど階段が細かくなり、正弦波に近づく。8 点は粗いので
  角がはっきり見える。3-10 の「数式で波形」もこの Custom の応用

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
