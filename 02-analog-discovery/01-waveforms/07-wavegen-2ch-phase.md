---
book: analog-discovery
chapter: 1
id: 1-7
title: 波形発生器 2 ch の同期と位相差
tier: 100
source: 自作
board: BB
---

# 1-7 波形発生器 2 ch の同期と位相差

Wavegen の `W1` と `W2` は**同じ内部クロックから作られる**ので、周波数を揃えれば
位相差を固定したまま出し続けられる（別々の発振器を 2 台使うのと違い、位相が
じわじわずれていかない）。ここでは `W1` を基準にして `W2` に位相差を付け、
オシロのカーソルで時間差として読む。XY 表示でリサージュ図形にする見方は
2-5 で扱う。

## 回路図

```circuit
title: 図1 W1 と W2 をそれぞれ CH1・CH2 に直結
parts:
  W1: sine 1,1 1,3 1
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  W2: sine 5,1 5,3 1
  M2: voltmeter 7,1 7,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 5,1 -- 7,1
  - 1,3 -- 3,3 -- 5,3 -- 7,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/07-wavegen-2ch-phase.svg)

外部の部品は無く、`W1`→`1+`、`W2`→`2+`、GND 共通のループバック（2-5 と同じ配線）。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+、W2 を 2+ に直結)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, W2, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.W2 -- a8 green
  - AD.2+ -- b8 blue
  - AD.GND -- -t3 black
  - AD.1- -- -t10 black
  - AD.2- -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/07-wavegen-2ch-phase.svg)

W1 と 1+ は 5 列、W2 と 2+ は 8 列に挿し、列の内側でつなぐ。GND・1−・2− は上の − レールにまとめる。部品は無く、電源も使わない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、10 kHz、振幅 1 V、位相 0° |
| Wavegen (W2) | 正弦波、10 kHz、振幅 1 V、位相 90° |
| Scope (CH1・CH2) | DC、Time/div 20 μs 程度 |
| カーソル | 縦カーソル 2 本を X（時間）モードにする |

次の図3・図4は Time/div と V/div を揃え、周波数だけを変えた。W2 の位相 90° は
W1 より**進む**向きなので、CH2 は CH1 より左 (早い時刻) で 0 V を上に横切る。

```scope
title: 図3 10 kHz — CH2 は CH1 より 25.0 μs 早く 0 V を横切る (90°)
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 1V, range: 500mV/div}
ch2: {wave: sine 10kHz 1V phase 90deg, range: 500mV/div}
cursors: [-25us, 0]
measure: [freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/07-wavegen-2ch-phase-1.svg)

```scope
title: 図4 20 kHz — 時間差は 12.5 μs に縮むが位相は 90° のまま
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 20kHz 1V, range: 500mV/div}
ch2: {wave: sine 20kHz 1V phase 90deg, range: 500mV/div}
cursors: [-12.5us, 0]
measure: [freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/07-wavegen-2ch-phase-2.svg)

## 見るべき値

周期 T = 1 / 10 kHz = **100 μs**。位相差 90° は 1/4 周期にあたる。

| 測る所 | 期待する値（計算値） | 分かること |
| --- | --- | --- |
| CH1 の立ち上がり（0 V を上に横切る瞬間）とCH2 の同じ立ち上がりの時間差 | 25.0 μs（= 100 μs × 90/360） | 位相差 90° が時間差として現れる |
| W2 の位相を 180° に変える | 時間差 50.0 μs（半周期）。CH2 は CH1 を上下反転した波形に見える | 逆位相 |
| W1・W2 の周波数を両方 20 kHz に変える（位相はそのまま） | 時間差は 12.5 μs（= 50 μs × 90/360）に**縮む**が、位相差はやはり 90° のまま | 2 ch は同じクロックから出ているので、周波数を変えても位相の関係（角度）は保たれる。時間差は周期に比例して変わるだけ |
| Run を止めて（Stop）再度 Run しても | 位相差は変わらない | 別々の自走発振器と違い、共通クロックなので再始動のたびに関係がずれない |

## 出典

自作。
