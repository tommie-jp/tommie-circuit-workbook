---
book: analog-discovery
chapter: 3
id: 3-7
title: ノイズ波形と RC フィルタ
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-7 ノイズ波形と RC フィルタ

Wavegen の Function には **Noise** (乱数のような波形) もある。3-2 と同じ RC
ローパスに通し、**フィルタの遮断周波数を変えると、通り抜けてくる雑音の量が
どう変わるか**を確かめる。4 章で FFT を使う前の、時間領域からの下ごしらえ。

## 回路図

```circuit
title: 図1 RC ローパス (ノイズを通す)
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 1k
  C1: capacitor a7 c7 100n
  M2: voltmeter a9 c9 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c7 -- c9
  - a7 -- a9
```

V1 の記号は正弦だが、実際は Wavegen の Function を **Noise** にして使う (3-1 と
同じ考え方)。R1 (1 kΩ)・C1 で 3-2 と同じ RC ローパス。CH1 が入力 (ノイズその
もの)、CH2 が出力 (フィルタを通ったあと)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c6 c10 1k
  C1: capacitor c15 c20 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, W1, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a6 yellow
  - AD.1+ -- b6 orange
  - AD.1- -- -t8 black
  - b10 -- b15 green
  - AD.2+ -- a15 blue
  - AD.2- -- -t18 black
  - a20 -- -t20 black
```

3-2 と同じ配線 (R1 1 kΩ、C1 100 nF)。この後の測定で C1 を 1 µF に差し替える。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Function **Noise**、Amplitude 2 V (Frequency は Noise には効かない) |
| Scope | CH1・CH2 とも DC 結合、Range ±2 V 程度。**Persistence** (2-7) を on にすると、帯の太さで振幅のばらつきが見える。Measure に **RMS** (AC) を出す |

## 見るべき値

計算値。1 次 RC ローパスの**等価雑音帯域幅 (ENBW)** は ENBW = (π/2) f<sub>c</sub> =
1 / (4RC) — 「白色雑音をこのフィルタに通すと、理想の矩形フィルタで幅 ENBW だけ
切り出したのと同じ電力になる」という、フィルタ自身が持つ値 (信号の中身によらない)。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| フィルタ 1 (C1 = 100 nF) の f<sub>c</sub> | 1.59 kHz (= 1/(2πRC)、3-2 と同じ) | R1・C1 で決まる |
| フィルタ 1 の ENBW | **2500 Hz** (= 1/(4×1 kΩ×100 nF)) | このフィルタを通した雑音の実効帯域 |
| フィルタ 2 (C1 → 1 µF) の f<sub>c</sub> | 159 Hz (10 倍の C で 1/10) | |
| フィルタ 2 の ENBW | **250 Hz** | |
| CH2 の RMS の比 (フィルタ 1 出力 ÷ フィルタ 2 出力) | 約 **3.16 倍 (10.0 dB)** = √(2500/250) | ENBW の比の平方根。同じノイズ源を通した 2 つの RC の比較で使える |

分かること:

- **ENBW は RC だけで決まり、ノイズ源の中身 (絶対レベル) を知らなくても計算できる。**
  だから「フィルタ 1 出力 と フィルタ 2 出力 の比」という**相対値**なら、
  Wavegen の Noise が実際どんな分布・帯域を持つか (非公開) を仮定しなくても
  確かめられる — Wavegen の出力帯域 (付属ワイヤで 9 MHz、3-5) は両方の f<sub>c</sub>
  よりずっと広いので、「広い帯域に平らに広がった雑音」という前提は妥当
- CH1 (フィルタ前) の RMS は、C1 をどちらに替えても変わらないはず。**変わって
  しまったら、ノイズ源ではなく配線や負荷を疑う**
- Persistence (2-7) で見ると、フィルタ後 (CH2) は帯の太さがフィルタ前 (CH1) より
  はっきり細くなる — 高い周波数成分が削られて振れ幅が小さくなった証拠
- 4-5 の平均化 (Average) はここでは使えない。Average は「同じ位相でくり返す
  周期信号」が前提で、ランダムなノイズは平均するとノイズごと小さくなってしまう

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。ENBW = 1/(4RC) は 1 次 RC ローパスの標準的な導出。
