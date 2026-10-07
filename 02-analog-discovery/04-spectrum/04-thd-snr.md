---
book: analog-discovery
chapter: 4
id: 4-4
title: THD と SNR — 波形発生器自身の歪
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
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
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/04-thd-snr.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/04-thd-snr.svg)

W1 と 1+ は 5 列に挿すだけで、列の内側でつながる。GND と 1− は上の − レールにまとめる。部品は無い。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1000 Hz、Amplitude 1 V |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz**。Window: Flat-top (信号がどのビンに乗っても振幅を正しく読むため、4-1・4-3)。Marker を THD・SNR モードにする |

**定義**: THD = √(Σ 2 次以上の高調波の実効値²) ÷ 基本波の実効値。
SNR = 基本波の実効値 ÷ (高調波を除いた雑音の実効値)、どちらも dB で表す。

```scope
title: 図3 時間で見ると歪みは見えない (1 kHz、Vpp 2.00 V の正弦波)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/04-thd-snr.svg)

図3 は同じ信号を Scope の時間波形で見た画面。THD が 0.1〜1% 程度の歪みは、時間波形では目で分からない。Spectrum の高調波の線で測る理由になる。

## 見るべき値

計算値と、比べるための理論の上限。

| 項目 | 値 | 計算 |
| --- | --- | --- |
| Scope の ADC (14 bit) が決める SNR の理論上限 (満振幅) | 86.0 dB | 6.02 × 14 + 1.76 (±2.5 V レンジいっぱいの正弦波に対する量子化雑音の理論式) |
| 同じ上限を振幅 1 V の正弦波で | 78.1 dB | 1 V は ±2.5 V の満振幅より 20 log₁₀ (1/2.5) ≈ −7.96 dB 小さいので 86.0 − 8.0 |
| 実測の SNR (目安) | 理論上限 78.1 dB より悪い (60〜75 dB 程度) | Wavegen の DAC の雑音・ジッタが Scope の ADC より支配的になるため |
| 実測の THD (目安) | 0.1〜1% (−60〜−40 dB) 程度 | DAC の非直線性による高調波が主な原因 |

分かること:

- **78.1 dB (満振幅なら 86.0 dB) は「Scope が測れる限界」であって「Wavegen が出せるきれいさ」ではない。**
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
