---
book: analog-discovery
chapter: 3
id: 3-3
title: AM / FM 変調
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-3 AM / FM 変調

Wavegen の W1 は単純な波形だけでなく、**AM (振幅変調)** と **FM (周波数変調)** も
1 台で作れる。搬送波 (Carrier) に低い周波数の信号 (Modulation) を乗せ、Scope の
時間軸でエンベロープ (AM) や周期の変化 (FM) を読む。第 4 章の FFT で側波帯を
見る実験 (4-7・4-8) の元になる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/03-am-fm.svg)

W1 の出力をそのまま 1+ で読む (配線は図2)。

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/03-am-fm.svg)

W1 と 1+ は 5 列に挿すだけで、列の内側でつながる。GND と 1− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 (AM) | 設定 (FM) |
| --- | --- | --- |
| Wavegen | Carrier: Sine 100 kHz、Amplitude 1 V。AM: Modulation Sine 1 kHz、Depth 50% | Carrier: Sine 100 kHz、Amplitude 1 V。FM: Modulation Sine 1 kHz、Deviation 2 kHz |
| Scope | CH1: 200 µs/div、Range 500 mV/div (変調 2 周期ぶんのエンベロープが見える) | CH1: 2 µs/div、Range 500 mV/div (搬送波の 1 周期をカーソルで読む) |

AM は変調の 1 周期 (1 ms) が収まるよう 200 µs/div に広げる (図3)。
FM の周期の違いは 2 % しかないので、2 µs/div に縮めて変調の山 (t = 0) の 1 周期をカーソルで読む (図4)。

```scope
title: 図3 AM のエンベロープは 1.5 V と 0.5 V の間を変調信号の形でなぞる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: = 1V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t), range: 500mV/div}
measure: [vmax]
notes:
  - text 250us 1.5V: 山 1.5 V
  - text 750us -0.5V: 谷 0.5 V
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/03-am-fm-1.svg)

```scope
title: 図4 FM の変調の山では 1 周期が 9.804 µs (102 kHz)
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: = 1V * sin(2 * pi * 100kHz * t + 2 * sin(2 * pi * 1kHz * t)), range: 500mV/div}
cursors: [0, 9.804us]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/03-am-fm-2.svg)

## 見るべき値

計算値。AM は Depth (変調度) m = 0.5、搬送波の振幅 A<sub>c</sub> = 1 V。

| 測る所 (AM) | 期待する値 | 分かること |
| --- | --- | --- |
| エンベロープの山 (最大振幅) | A<sub>c</sub>(1+m) = 1.5 V | 変調信号の山で搬送波が最も大きくなる |
| エンベロープの谷 (最小振幅) | A<sub>c</sub>(1−m) = 0.5 V | 変調信号の谷で最も小さくなる |
| 側波帯 1 本の振幅 (搬送波比) | m/2 = 0.25 倍 = −12.0 dB | 4-7 で FFT を撮ると 99 kHz・101 kHz にこの高さで立つ |

FM は変調指数 β = Δf / f<sub>m</sub> = 2 kHz / 1 kHz = 2。瞬時周波数はカーソルで
周期を読んで確かめる。

| 測る所 (FM) | 期待する値 | 分かること |
| --- | --- | --- |
| 変調信号が山のときの周期 | 1 / 102 kHz ≈ 9.804 µs | 瞬時周波数は f<sub>c</sub> + Δf = 102 kHz |
| 変調信号が 0 のときの周期 | 1 / 100 kHz = 10.000 µs | 瞬時周波数は f<sub>c</sub> のまま |
| 変調信号が谷のときの周期 | 1 / 98 kHz ≈ 10.204 µs | 瞬時周波数は f<sub>c</sub> − Δf = 98 kHz |

AM は**振幅**が変調信号の形をなぞり、FM は**周期 (瞬時周波数)** が変調信号の形を
なぞる。Scope のカーソルで山・谷・ゼロ点の位置の周期を読めば、この 3 点は
計算どおりに並ぶ。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
