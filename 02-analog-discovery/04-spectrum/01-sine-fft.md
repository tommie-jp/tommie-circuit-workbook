---
book: analog-discovery
chapter: 4
id: 4-1
title: 正弦波の FFT — 基本波と高調波
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-1 正弦波の FFT — 基本波と高調波

**Spectrum** は Scope が取り込んだ時間波形を FFT にかけて、横軸を周波数にした
計器。W1 の純粋な正弦波を Spectrum で見て、**基本波の高さが振幅からどう
計算できるか**と、**周波数の分解能がどう決まるか**を確かめる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/01-sine-fft.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**1000 Hz**、Amplitude 1 V、Offset 0 V |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz**、FFT 点数はできるだけ大きく (例: 32768)。Window: **Flat-top**。単位: dBV |

AD3 のサンプル周波数は、システムクロック (既定 100 MHz、50〜125 MHz で調整できる) を整数で割った値からしか選べないので、
分解能 (RBW) をちょうど 1 Hz のようなきりのいい値に手で合わせることはできない。
**Start・Stop は Spectrum の画面で直接決め** (Scope のサンプル周波数から逆算
しない)、実際の RBW は画面の表示を読む。信号の周波数がどの位置のビンに
乗るかも保証できないので、振幅を正しく読むために **Window は Flat-top**
にする (4-3 で理由を確かめる)。

画面は次のようになる。基本波 1 本だけが立ち、ほかの周波数には何も出ない (理想)。

```spectrum
title: 図2 1 kHz の基本波が −3.01 dBV に 1 本だけ立つ
device: ad3
sweep: 0-20kHz
samples: 32768
window: flattop
signal: sine 1kHz 1V
markers: [1kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/01-sine-fft.svg)

## 見るべき値

計算値。dBV は実効値基準 (**dBV = 20 log₁₀ (V<sub>rms</sub> / 1 V)**)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1000 Hz の基本波の高さ | −3.01 dBV (振幅 1 V → 実効値 0.707 V) | 振幅と dBV の変換。Flat-top ならビンの位置によらずこの値に近く読める |
| 分解能 (RBW) | 画面の表示を読む (例として RBW ≈ 1 Hz、FFT 点数 32768 とする) | Start・Stop と FFT 点数から機器が決める。手計算のきりのいい値を当てにしない |
| 量子化だけで決まるノイズの下限 (1 ビンあたり、計算例) | 約 −123 dBV | 14 bit ADC (±2.5 V レンジ) の量子化雑音を FFT の処理利得ぶん下げた理論値の一例 |

量子化だけで決まる下限の計算例 (RBW ≈ 1 Hz、FFT 点数 N = 32768 の場合):
量子化ステップ q = 5 V / 2¹⁴ ≈ 0.31 mV、量子化雑音の実効値 q/√12 ≈ 88 µV
(dBV で −81.1 dBV)。AD3 の Scope の入力レンジは ±2.5 V と ±25 V の 2 段で、1 V の信号なら ±2.5 V 側が選ばれる。この雑音は全ビンに広がるので、1 ビンあたりの高さは
**処理利得 10 log₁₀ (N/2) ≈ 42.1 dB** ぶん下がり、−81.1 − 42.1 ≈ **−123 dBV**。
FFT 点数を画面の設定から変えたら、この処理利得も計算し直す。

分かること:

- **理想的な正弦波ならこの下限まで下がるはず。** 実際に見える 2000 Hz・
  3000 Hz などの小さな山は、Wavegen 自身の歪 (DAC の非直線性) が作った
  高調波で、理論の下限より高い所に出る — その大きさを測るのが 4-4
- **Window を Flat-top にしたのは、信号がどのビンに乗るか保証できないから。**
  Rectangular のままだとビンから外れた分だけ振幅が小さく読める (漏れ、
  leakage)。窓ごとの違いは 4-3 で確かめる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。
