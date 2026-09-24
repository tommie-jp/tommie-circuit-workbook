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
この漏れの出方を変える。AD の内部サンプル周波数は 100 MHz を整数で割った値
からしか選べないので、**信号の周波数がビンのどこに乗るかはこちらで正確には
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
  半ビンずれでも 1.42 dB (振幅で 12%) の誤差で収まる
- ENBW (等価雑音帯域幅) が広い窓ほど、同じ入力雑音でもノイズフロアが高く
  見える (4-5 の平均化と合わせて使う)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。窓関数のスキャロッピング損失・ENBW は信号処理の教科書に
載っている標準的な値 (Harris, "On the Use of Windows for Harmonic Analysis
with the Discrete Fourier Transform", 1978)。
