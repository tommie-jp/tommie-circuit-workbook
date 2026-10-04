---
book: analog-discovery
chapter: 4
id: 4-3
title: 窓関数 (矩形・Hann・Flat-top) の違い
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-3 窓関数 (矩形・Hann・Flat-top) の違い

FFT は「取り込んだ長さがちょうど 1 周期の整数倍」でないと、周波数がビンの
真ん中からずれて**漏れ (leakage)** が起き、読んだ振幅が小さく出る。窓関数は
この漏れの出方を変える。AD3 のサンプル周波数は、システムクロック (既定 100 MHz、50〜125 MHz で調整できる)
を整数で割った値からしか選べないので、**信号の周波数がビンのどこに乗るかはこちらで正確には
決められない**。4-1 では Flat-top を使ってこの問題を避けたが、ここでは
**乗る場所が一番悪いとき (半ビンぶんずれた最悪ケース) の理論値**で、
Rectangular・Hann・Flat-top の 3 つが振幅の読み値をどれだけ悪化させるかを
比べる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/03-windows.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/03-windows.svg)

W1 と 1+ は 5 列に挿すだけで、列の内側でつながる。GND と 1− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**1000 Hz**、Amplitude 1 V |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz**。Window を Rectangular → Hann → Flat-top の順に切り替える。単位: dBV |

理想値は 4-1 と同じ −3.01 dBV (振幅 1 V の実効値)。実際にどれだけビンから
ずれるかは、その場の RBW と 1000 Hz の関係次第で決まり、こちらから正確には
選べない。ここではどれだけ悪くても (半ビンぶんずれても) この程度、という
**最悪ケースの理論値**でどれだけ振幅が下にずれるか (スキャロッピング損失) を
比べる。

図 3〜5 は最悪ケースを作って描いた画面である。FFT 点数を 8192 にすると
分解能は 6.25 Hz (1000 Hz はちょうど 160 番目のビン) になるので、信号を
半ビンずらした 1003.125 Hz にして、窓だけを替えて同じ尺度で並べた。

```spectrum
title: 図3 Rectangular — 半ビンずれで山が −6.92 dBV まで下がる
device: ad3
sweep: 0-20kHz
samples: 8192
window: rect
signal: sine 1003.125Hz 1V
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/03-windows-1.svg)

```spectrum
title: 図4 Hann — 同じずれで −4.43 dBV
device: ad3
sweep: 0-20kHz
samples: 8192
window: hann
signal: sine 1003.125Hz 1V
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/03-windows-2.svg)

```spectrum
title: 図5 Flat-top — 同じずれでも −3.02 dBV とほぼ正しい
device: ad3
sweep: 0-20kHz
samples: 8192
window: flattop
signal: sine 1003.125Hz 1V
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/03-windows-3.svg)

```scope
title: 図6 最悪ケースの 1003.125 Hz を時間で見ても、見かけは普通の正弦波
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1003.125Hz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/03-windows.svg)

図6 は図3〜5 と同じ信号を時間波形で見た画面。半ビンずれは時間波形には現れず、FFT にかけたときだけ窓ごとの読み値の差になる。

## 見るべき値

計算値。半ビンずれ (最悪のケース) でのスキャロッピング損失は窓ごとに決まった
値を持つ (よく使われる値)。

| 窓関数 | 最悪ケースの損失 | 読める振幅 (理論値 −3.01 dBV から) | ENBW (ビン単位) |
| --- | --- | --- | --- |
| Rectangular | 3.92 dB | −6.93 dBV | 1.0 |
| Hann | 1.42 dB | −4.43 dBV | 1.5 |
| Flat-top | 0.02 dB (ほぼ無し) | −3.03 dBV | 約 3.8 |

分かること:

- **Rectangular は分解能が一番良い (山が細い) が、振幅の誤差が一番大きい。**
  信号の周波数がビンにきちんと乗っていると確かめられた、まれな場面でだけ使う
- **Flat-top はビンの位置によらず振幅がほぼ正しく読める** (だから "flat"-top)。
  代わりに山が広がる (ENBW が Rectangular の約 3.8 倍) ので、近くの 2 本の
  信号を分けて見る力は一番弱い。振幅の絶対値を正確に読みたい校正の場面 (4-4 の
  THD・SNR の基準づくりなど) で使う
- **Hann は両者の中間。** 既定の窓として使われるのはこのバランスの良さのため。
  半ビンずれでも 1.42 dB (振幅で 15%) の誤差で収まる
- ENBW (等価雑音帯域幅) が広い窓ほど、同じ入力雑音でもノイズフロアが高く
  見える (4-5 の平均化と合わせて使う)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。窓関数のスキャロッピング損失・ENBW は信号処理の教科書に
載っている標準的な値 (Harris, "On the Use of Windows for Harmonic Analysis
with the Discrete Fourier Transform", 1978)。
