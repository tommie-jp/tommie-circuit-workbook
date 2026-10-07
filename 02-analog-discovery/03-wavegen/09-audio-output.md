---
book: analog-discovery
chapter: 3
id: 3-9
title: 音を出す (オーディオ出力)
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-9 音を出す (オーディオ出力)

W1 は可聴域 (20 Hz〜20 kHz) の波形をそのまま出せるので、小さいスピーカーを
つなげば音になる。AD3 の W1 はほぼ理想電圧源 (3-5) で、8 Ω のスピーカーに直結すると
歪みなく出せる電流 (30 mA) を超えてしまうので、**電流を制限する抵抗**を直列に入れる。
アンプ (第 9 章の LM386 など) を使わない、いちばん簡素な「音を出す」実験。

## 回路図

```circuit
title: 図1 スピーカーを電流制限抵抗で鳴らす
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  R1: resistor 5,1 7,1 150
  SPK: speaker 7,1 9,1
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 9,3
  - 9,1 -- 9,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/09-audio-output.svg)

R1 とスピーカーを直列にし、W1・GND につなぐ。
CH1 は W1 の出力 (R1 + スピーカーの両端) をそのまま読む。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (R1 とスピーカーを W1 に直列)
board: half
parts:
  R1: resistor c6 c10 150
  SPK: speaker d10 d14
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a6 yellow
  - AD.1+ -- b6 orange
  - a14 -- -t14 black
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/09-audio-output.svg)

W1 → R1 (150 Ω) → スピーカー → GND の順に直列。CH1 (1+・1−) は W1 の出力と GND の間を読む。
スピーカーはリード線の付いた小型のものを挿す。リードが太くて挿せないときは、ワニ口クリップで R1 の端と GND につなぐ。電源 (Supplies) は使わず、W1 の出力だけで鳴らす。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**440 Hz** (ラの音、A4)、Amplitude 1 V、Offset 0 V |
| Scope | CH1: DC 結合、Range 500 mV/div、Time/div 500 µs/div (440 Hz の 1 周期が画面に入る) |

```scope
title: 図3 440 Hz の 1 周期は 2.273 ms
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 440Hz 1V, range: 500mV/div}
cursors: [0, 2.273ms]
measure: [vpp, freq, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/09-audio-output.svg)

## 見るべき値

計算値。スピーカーは 8 Ω、R1 = 150 Ω (合計 158 Ω)。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| ピーク電流 | 6.33 mA (= 1 V ÷ 158 Ω) | AD3 の歪みなく出せる電流 30 mA より小さく、安全 (約 1/5) |
| 実効電流 | 4.48 mA (= 6.33 mA ÷ √2) | RMS の電流 |
| スピーカーで消費する電力 | 約 160 µW (= 実効電流² × 8 Ω) | R1 でほとんどの電圧が落ちるので、音はごく小さい (アンプではない) |

音階の周期の例 (Sine の Frequency をこの値に変える):

| 音 | 周波数 | 周期 |
| --- | --- | --- |
| A3 | 220 Hz | 4.545 ms |
| A4 | 440 Hz | 2.273 ms |
| A5 | 880 Hz | 1.136 ms |

分かること:

- **R1 が無いと壊れはしないが規格外になる。** 8 Ω に直結すると Amplitude 1 V で
  125 mA を要求してしまい、歪みなく出せる 30 mA の約 4 倍、ハードウェアの遮断の 40 mA の
  3 倍を超える (波形が潰れる・遮断されるなど、3-5 と同じ現象)
- 160 µW は静かな部屋でようやく聞こえる程度で、大きな音にはならない。
  **もっと大きく鳴らしたいなら R1 を外すのではなく、第 9 章 (9-14) の LM386 の
  ようなアンプを間に挟む** — 電流を制限したまま音量を上げる本来のやり方
- 3-2 の Sweep で Start 20 Hz・Stop 20 kHz にすると、耳の可聴域を上から下まで
  スピーカーで聞ける (低い方も高い方も、この小さいスピーカーでは素直には
  出ない — スピーカー自体の周波数特性のため)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。W1 の出力インピーダンス (0 Ω) と歪みなく出せる電流 (30 mA) は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Wavegen の節)、3-5 で確かめた値。
