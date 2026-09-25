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
分解能 (RBW) = サンプル周波数 ÷ 点数が全帯域に一律にかかるが、CZT は
**見たい狭い帯域だけに同じ点数を集めて計算する**ので、同じ点数でもその帯域の
分解能をずっと細かくできる。50 Hz しか離れていない 2 本の近接波を、ふつうの
FFT では 1 本に見えるのに、CZT では分けて見えることを確かめる。

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

W1・W2 を 1 kΩ ずつで足し合わせ、CH1 (1 MΩ、ほとんど電流を取らない) で
読む。合成した電圧はほぼ (W1 + W2) ÷ 2 になる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**5.000000 MHz**、Amplitude 0.5 V。W2: Sine、**5.000050 MHz** (W1 と 50 Hz だけ違う)、Amplitude 0.5 V |
| Spectrum (通常の FFT) | Source: Channel 1。Start 0 Hz、Stop 10 MHz。FFT 点数 32768。サンプル周波数 25 MHz |
| Spectrum (CZT) | 同じ取り込みから、表示帯域だけ **Start 4.99 MHz、Stop 5.01 MHz** に絞る (CZT モード) |

## 見るべき値

計算値。RBW = サンプル周波数 ÷ 点数 (通常の FFT)、RBW = 表示帯域幅 ÷ 点数 (CZT、
表示帯域だけに点数を使うため)。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| 通常の FFT の RBW | 763 Hz (= 25 MHz ÷ 32768) | 2 本の間隔 50 Hz よりずっと粗く、1 本の山に見えてしまう |
| CZT (帯域 20 kHz) の RBW | 0.610 Hz (= 20 kHz ÷ 32768) | 50 Hz の間隔を 80 ビン以上に分けて見られる |
| 分解能の改善率 | **1250 倍** (= 763 Hz ÷ 0.610 Hz) | 同じ点数のまま、見たい帯域だけに集中させた効果 |

分かること:

- **CZT は「取り込みをやり直す」のではなく、すでに取り込んだデータを計算だけで
  ズームする。** 通常の FFT で Start・Stop を狭めても (4-1)、それは表示を
  切り取るだけで RBW 自体は変わらない — CZT は RBW そのものを狭い帯域に
  集中させる点が違う
- **AD2 には CZT が無い。** 同じ効果を得るには、見たい帯域に Nyquist が合うまで
  サンプル周波数そのものを下げてから (取り込み直して) 通常の FFT を掛ける
  しかなく、そのたびに再取り込みが要る。分解能の上限も AD2 のバッファ長
  (16k、AD3 は 32k) で頭打ちになる
- 2 本の周波数差 50 Hz は Wavegen の周波数分解能 (1 Hz よりずっと細かい) の
  範囲内なので、この設定はどちらの機種でも作れる — 違うのは**見る側** (CZT の
  有無) だけ

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。CZT は AD3 だけの機能。
