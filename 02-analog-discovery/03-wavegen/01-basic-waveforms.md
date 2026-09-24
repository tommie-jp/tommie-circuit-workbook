---
book: analog-discovery
chapter: 3
id: 3-1
title: 正弦・方形・三角・ノコギリ・DC と振幅・オフセット
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-1 正弦・方形・三角・ノコギリ・DC と振幅・オフセット

**Wavegen** (波形発生器) の W1 から基本の 5 つの波形 — Sine・Square・Triangle・
Ramp Up (ノコギリ) ・DC — を順に出し、Scope で読む。**Amplitude はオフセットからの
片振幅 (0-peak)** で、Vpp (画面で読む値) とは違う。ここを取り違えると、あとの章の
FFT やネットワークアナライザで振幅が計算と合わなくなる。

## 回路図

W1 を 1+ に直結するだけの**ループバック**。板は使わない。

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

- V1 は波形の種類を切り替える W1 の代わり (図では正弦の記号を使うが、実際は
  Sine / Square / Triangle / Ramp Up / DC を Wavegen の画面で選ぶ)
- 1− は GND に、W1 の GND (黒) も同じ GND に落とす。**GND を共通にしないと
  読みが浮く** (0-1 の話)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Frequency 1 kHz、**Amplitude 2 V**、**Offset 0.5 V**。Function を Sine → Square → Triangle → Ramp Up → DC の順に切り替える |
| Scope | CH1: DC 結合、Range 1 V/div。Measure に Maximum・Minimum・Average・RMS を出す |

**Amplitude 2 V** は「オフセットから ±2 V」という意味。Offset 0.5 V と合わせると、
波形はどれも **+2.5 V から −1.5 V の間**を振れる (Vpp = 2 × Amplitude = 4 V)。
DC だけは Amplitude が効かず、Offset の値がそのまま出力になる。

## 見るべき値

計算値。RMS の列は交流成分だけ (Average を引いた分) の実効値。

| 波形 | 最大値 | 最小値 | Vpp | 平均 (Average) | RMS (交流分) |
| --- | --- | --- | --- | --- | --- |
| Sine | 2.5 V | −1.5 V | 4.0 V | 0.5 V | 1.414 V (= 2/√2) |
| Square (50%) | 2.5 V | −1.5 V | 4.0 V | 0.5 V | 2.000 V (= 2) |
| Triangle | 2.5 V | −1.5 V | 4.0 V | 0.5 V | 1.155 V (= 2/√3) |
| Ramp Up (ノコギリ) | 2.5 V | −1.5 V | 4.0 V | 0.5 V | 1.155 V (= 2/√3) |
| DC | 0.5 V | 0.5 V | 0 V | 0.5 V | 0 V |

分かること:

- **最大値・最小値・Vpp はどの波形でも同じ** (Amplitude と Offset だけで決まる)。
  違うのは波形の**形**で、RMS (実効値、電力に効く量) が変わる
- Square が RMS 最大 (常に振れ切っているため)、Sine が最小に近い。
  Triangle と Ramp Up は同じ RMS (三角波の特別な形がノコギリなので当然)
- Average は**どの波形でも Offset に一致する**。波形の対称性 (Sine・Triangle・
  Square は上下対称、Ramp Up も平均では対称) から、直流成分は Offset だけで決まる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
