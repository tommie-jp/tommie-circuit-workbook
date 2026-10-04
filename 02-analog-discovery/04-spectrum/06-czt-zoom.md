---
book: analog-discovery
chapter: 4
id: 4-6
title: CZT (ズーム) で狭帯域を見る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
device: AD3
---

# 4-6 CZT (ズーム) で狭帯域を見る

AD3 の Spectrum には **CZT (Chirp-Z Transform)** がある。ふつうの FFT は
ビンの間隔 = サンプル周波数 ÷ 点数 が全帯域に一律にかかるが、CZT は
**見たい狭い帯域だけに同じ点数を並べて計算する**ので、その帯域ではビンの間隔を
ずっと細かくできる。ただし、近い 2 本を分けて見られるか (分解能) は、ビンの間隔では
なく**取り込んだ時間の長さ**で決まる。50 Hz しか離れていない 2 本の近接波を見て、
CZT でビンを細かくしても 2 本には分かれないことを確かめる。

## 回路図

```circuit
title: 図1 W1・W2 を抵抗で足して CH1 で見る
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  V2: sine a5 c5 l=$\mathrm{W2}$
  R1: resistor a1 a3 1k
  R2: resistor a5 a3 1k
  M1: voltmeter a9 c9 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a3 -- b3 -- b8 -- a8 -- a9
  - c1 -- c5 -- c9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/06-czt-zoom.svg)

W1・W2 を 1 kΩ ずつで足し合わせ、CH1 (1 MΩ、ほとんど電流を取らない) で
読む。合成した電圧はほぼ (W1 + W2) ÷ 2 になるので、CH1 に現れる 2 本は
Wavegen の半分の **0.25 V** ずつ (図 3・4 はこの値で描いた)。

5 MHz は AD3 の入力帯域の内側だが、BNC アダプタ無し (2×15 ヘッダ) の帯域は
9 MHz (−3 dB)・2.9 MHz (−0.5 dB) なので、ワイヤでつなぐと読みが 0.5〜3 dB の
あいだで下がる (5 MHz での値は仕様書に無く、**未確認**)。BNC アダプタ有りなら
−0.5 dB が 15 MHz なので 5 MHz はほぼ平らである。どちらも 2 本を分けて見る
話には影響しない。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1・W2 を 1 kΩ ずつで足す)
board: half
parts:
  R1: resistor c6 c10 1k
  R2: resistor d10 d14 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, W2, GND, 1+, 1-]
wires:
  - AD.W1 -- a6 yellow
  - AD.W2 -- a14 green
  - AD.1+ -- a10 orange
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/06-czt-zoom.svg)

R1 と R2 の片方の端を 10 列に挿して足し合わせ、その列から CH1 (1+) を取る。W1 は 6 列、W2 は 14 列の R の端へつなぐ。電源 (Supplies) は使わず、W1・W2 の出力だけを使う。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**5.000000 MHz**、Amplitude 0.5 V。W2: Sine、**5.000050 MHz** (W1 と 50 Hz だけ違う)、Amplitude 0.5 V |
| Spectrum (通常の FFT) | Source: Channel 1。Start 0 Hz、Stop 10 MHz。FFT 点数 32768。サンプル周波数 25 MHz (例。実機で選べる値は装置の丸めで多少ずれることがある) |
| Spectrum (CZT) | 同じ取り込みから、表示帯域だけ **Start 4.99 MHz、Stop 5.01 MHz** に絞る (CZT モード) |

通常の FFT で見ると次のようになる。図は Stop 10 MHz から決まるサンプル周波数
(25.6 MHz) で描いたので RBW は 781 Hz だが、50 Hz 離れた 2 本が 1 本の山に
融けることは変わらない。CZT の画面は、この図の道具が CZT を持たないので
描いていない。CZT でもビンが細かくなるだけで、山は図4 と同じ 1 本のままになる。

```spectrum
title: 図3 通常の FFT では 50 Hz 離れた 2 本が 1 本の山になる
device: ad3
sweep: 0-10MHz
samples: 32768
window: flattop
signal:
  - sine 5MHz 0.25V
  - sine 5.00005MHz 0.25V
markers: [5MHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/06-czt-zoom-1.svg)

```spectrum
title: 図4 Start・Stop を 4.99〜5.01 MHz に絞っても RBW は同じで山は 1 本のまま
device: ad3
center: 5MHz
span: 20kHz
samples: 32768
window: flattop
signal:
  - sine 5MHz 0.25V
  - sine 5.00005MHz 0.25V
markers: [5MHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/06-czt-zoom-2.svg)

時間波形では、5 MHz と 5.00005 MHz の差 50 Hz は見えない。うなりの周期は 1 / 50 Hz = 20 ms で、
図5 の 2 µs の窓の 1 万倍ある。窓の中では 2 本が同位相で重なり、振幅 0.25 V の 2 本の和 0.5 V (Vpp 1.00 V) の
5 MHz 正弦波 1 本に見える (図は CH1 に映る和そのものを描いた)。

```scope
title: 図5 CH1 は Vpp 1.00 V の 5 MHz — 50 Hz のうなりは窓に出ない
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 5MHz 0.5V, range: 200mV/div}
cursors: [0, 200ns]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/06-czt-zoom.svg)

## 見るべき値

計算値。ビンの間隔 = サンプル周波数 ÷ 点数 (通常の FFT)、= 表示帯域幅 ÷ 点数 (CZT)。
分けて見られる間隔の目安は 1 ÷ 取り込み時間 T に、窓の ENBW (Flat-top は約 3.8 ビン、4-3) を掛けた値。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| 取り込み時間 T | 1.31 ms (= 32768 ÷ 25 MHz) | FFT でも CZT でも同じ取り込みを使う |
| 通常の FFT のビンの間隔 | 763 Hz (= 25 MHz ÷ 32768 = 1/T) | 2 本の間隔 50 Hz よりずっと粗い |
| CZT (帯域 20 kHz) のビンの間隔 | 0.610 Hz (= 20 kHz ÷ 32768) | 1250 倍細かい点で山の形を描ける |
| 分けて見られる間隔の目安 | 約 2.9 kHz (= 3.8 ÷ T、Flat-top) | FFT でも CZT でも同じ。50 Hz の 2 本は 1 本の山になる |

サンプル周波数 25 MHz は説明用に選んだ例の値で、実機は選べる値に丸める。
それでも「分けて見られる間隔は 1/T で決まり、CZT はビンを細かくするだけ」という
結論は、選ぶ数値によらない。

分かること:

- **CZT は取り込みをやり直さず、すでに取り込んだデータを計算だけでズームする。**
  通常の FFT で Start・Stop を狭めても (図4) 表示を切り取るだけでビンは粗いままだが、
  CZT は狭い帯域に点を密に並べる。山の頂点の周波数と高さを細かく読むのに効く
- **2 本を分けるには、取り込み時間を延ばすしかない。** 50 Hz を Flat-top で分けるには
  T ≥ 3.8 ÷ 50 Hz ≈ 76 ms が要る。バッファが 32768 点 (Scope を 1 チャンネルだけ
  使うと 65536 点) なら、サンプル周波数は 430 kHz (65536 点で 860 kHz) 以下になり、
  5 MHz の信号はそもそも正しく取り込めない
- 2 本の周波数差 50 Hz は Wavegen の周波数分解能 (1 Hz よりずっと細かい) の
  範囲内なので、この設定は作れる。50 Hz の差が見えるかどうかを決めるのは
  **見る側の取り込み時間**である

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。AD3 の仕様書 (Specifications) の Spectrum Analyzer の項に、電力スペクトルの算法として FFT と CZT が載っている。
