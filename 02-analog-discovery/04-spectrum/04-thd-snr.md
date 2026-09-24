---
book: analog-discovery
chapter: 4
id: 4-4
title: THD と SNR — 波形発生器自身の歪
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-4 THD と SNR — 波形発生器自身の歪

W1 が出す「きれいな正弦波」は、Wavegen 内部の DAC の丸め誤差ぶんだけ歪んで
いる。Spectrum の THD (全高調波歪率) と SNR (信号対雑音比) の測定機能で、
**Wavegen 自身の歪を測る**。DUT を挟まずに W1 を直接測るので、この値が以後
すべての実験の「測定系そのものの限界」になる。

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
| Wavegen | W1: Sine、1000 Hz、Amplitude 1 V |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz**。Window: Flat-top (信号がどのビンに乗っても振幅を正しく読むため、4-1・4-3)。Marker を THD・SNR モードにする |

**定義**: THD = √(Σ 2 次以上の高調波の実効値²) ÷ 基本波の実効値。
SNR = 基本波の実効値 ÷ (高調波を除いた雑音の実効値)、どちらも dB で表す。

## 見るべき値

計算値と、比べるための理論の上限。

| 項目 | 値 | 計算 |
| --- | --- | --- |
| Scope の ADC (14 bit) が決める SNR の理論上限 | 86.0 dB | 6.02 × 14 + 1.76 (満振幅の正弦波に対する量子化雑音の理論式) |
| 実測の SNR (目安) | 理論上限より悪い (60〜80 dB 程度) | Wavegen の DAC の雑音・ジッタが Scope の ADC より支配的になるため |
| 実測の THD (目安) | 0.1〜1% (−60〜−40 dB) 程度 | DAC の非直線性による高調波が主な原因 |

分かること:

- **86.0 dB は「Scope が測れる限界」であって「Wavegen が出せるきれいさ」ではない。**
  実測の SNR がこれよりかなり悪ければ、悪化の原因は Wavegen 側にある
- THD・SNR は Amplitude や周波数を変えると変わる。**Amplitude を下げすぎると
  今度は Scope 側のノイズフロアが効いてくる**ので、レンジいっぱい (フルスケール
  に近い振幅) で測るのが基本
- ここで測った THD・SNR は、この後アンプや DUT を挟む実験 (第 9 章など) で
  「測定系だけで生まれる歪」として差し引いて考える基準になる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。ADC の量子化雑音の式 (6.02N + 1.76) は AD 変換の教科書に
載っている標準的な導出。
