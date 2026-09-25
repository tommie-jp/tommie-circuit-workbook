---
book: analog-discovery
chapter: 3
id: 3-9
title: 音を出す (オーディオ出力)
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-9 音を出す (オーディオ出力)

W1 は可聴域 (20 Hz〜20 kHz) の波形をそのまま出せるので、小さいスピーカーを
つなげば音になる。W1 はほぼ理想電圧源 (3-5) で、8 Ω のスピーカーに直結すると
保証電流 (10 mA) を超えてしまうので、**電流を制限する抵抗**を直列に入れる。
アンプ (第 9 章の LM386 など) を使わない、いちばん簡素な「音を出す」実験。

## 回路図

```circuit
title: 図1 スピーカーを電流制限抵抗で鳴らす
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 150
  SPK: speaker a7 a9
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c9
  - a9 -- c9
```

板は使わない。ワニ口クリップで R1 とスピーカーを直列にし、W1・GND につなぐ。
CH1 は W1 の出力 (R1 + スピーカーの両端) をそのまま読む。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**440 Hz** (ラの音、A4)、Amplitude 1 V、Offset 0 V |
| Scope | CH1: DC 結合、Range 500 mV/div、Time/div 500 µs/div (440 Hz の 1 周期が画面に入る) |

## 見るべき値

計算値。スピーカーは 8 Ω、R1 = 150 Ω (合計 158 Ω)。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| ピーク電流 | 6.33 mA (= 1 V ÷ 158 Ω) | Wavegen の保証駆動電流 10 mA より小さく、安全 |
| 実効電流 | 4.48 mA (= 6.33 mA ÷ √2) | RMS の電流 |
| スピーカーで消費する電力 | 約 160 µW (= 実効電流² × 8 Ω) | R1 でほとんどの電圧が落ちるので、音はごく小さい (アンプではない) |

音階の周期の例 (Sine の Frequency をこの値に変える):

| 音 | 周波数 | 周期 |
| --- | --- | --- |
| A3 | 220 Hz | 4.545 ms |
| A4 | 440 Hz | 2.273 ms |
| A5 | 880 Hz | 1.136 ms |

分かること:

- **R1 が無いと壊れはしないが規格外になる。** 8 Ω に直結すると Amplitude 1 V で
  125 mA を要求してしまい、保証電流の 10 倍を超える (実際は電流制限がかかって
  波形が潰れる、3-5 と同じ現象)
- 160 µW は静かな部屋でようやく聞こえる程度で、大きな音にはならない。
  **もっと大きく鳴らしたいなら R1 を外すのではなく、第 9 章 (9-14) の LM386 の
  ようなアンプを間に挟む** — 電流を制限したまま音量を上げる本来のやり方
- 3-2 の Sweep で Start 20 Hz・Stop 20 kHz にすると、耳の可聴域を上から下まで
  スピーカーで聞ける (低い方も高い方も、この小さいスピーカーでは素直には
  出ない — スピーカー自体の周波数特性のため)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。W1 の出力インピーダンスと保証駆動電流は
[Analog Discovery 2 リファレンスマニュアル](https://digilent.com/reference/test-and-measurement/analog-discovery-2/reference-manual)
§3.4 (AWG Out)、3-5 で確かめた値。
