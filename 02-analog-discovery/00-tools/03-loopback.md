---
book: analog-discovery
chapter: 0
id: 0-3
title: ループバック — W1 を 1+ に直結して発生器とオシロを確かめる
tier: 50
source: 自作
board: BB
---

# 0-3 ループバック — W1 を 1+ に直結して発生器とオシロを確かめる

波形発生器 (Wavegen) の出力 `W1` を、そのままオシロの `1+` に 1 本の
ワイヤでつなぐ。外部の回路を何も挟まない**ループバック**は、
Analog Discovery 3 自体・付属ワイヤ・両方の計器が正しく動くかを確かめる
最初の 1 手。以後の題で「値がおかしい」と思ったら、まずこの配線に
戻って確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ループバック配線
parts:
  W1: sine 1,1 1,3 1
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/03-loopback.svg)

W1 (Wavegen の出力) と M1 (オシロの CH1) を直接つなぎ、GND も共通に
する。他には何もつながない。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+ に直結)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, W1, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow [h10]
  - AD.1+ -- b5 orange [h-19]
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/breadboard/03-loopback.svg)

W1 と 1+ は同じ 5 列に挿すだけで、列の内側でつながる。GND と 1− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V (2 Vpp)、オフセット 0 V |
| Scope (CH1) | DC、Range 500 mV/div (±2 V)、Auto トリガ |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Vpp 2.00 V・1.000 kHz が設定どおり出る
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
cursors: [0, 1ms]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/scope/03-loopback.svg)

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Vpp | 2.00 V (= 振幅 1 V の 2 倍。計算値) | 発生器の設定どおりの振幅が出ているか |
| CH1 の周波数 | 1.000 kHz | 発生器とオシロの時間基準が合っているか |
| 波形の形 | 歪みのないきれいな正弦波 | ワイヤや接触の不良が無いか |

ここでずれた値が出たら、外部回路より先に**ワイヤの接触**と**チャネルの
設定 (レンジ・オフセット)** を疑う。これより後の題で回路を挟んで
値がおかしいときも、まずこのループバックに戻して発生器とオシロ自体が
正しいことを確かめるとよい。

## LTspice での確かめ (対象外)

外部の部品が無いループバックで、SPICE で見る回路が無い。振幅 1 V の正弦波は Vpp 2.00 V (= 2 × 1 V)、1 kHz の周期は 1.000 ms。本文の値と合う。

## 出典

自作。

参考: [Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)、[WaveForms Wavegen (Digilent)](https://digilent.com/reference/test-and-measurement/guides/waveforms-waveform-generator)、[WaveForms Oscilloscope (Digilent)](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)
