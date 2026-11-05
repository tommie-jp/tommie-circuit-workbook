---
book: analog-discovery
chapter: 3
id: 3-14
title: 位相変調と PSK
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-14 位相変調と PSK

AM (3-3・3-13) は振幅を、FM は周波数を変調信号で動かした。**PM (位相変調)** は搬送波の**位相**を動かす。
AD3 の Wavegen は変調に位相も選べる (仕様の「modulation (phase, AM, FM)」)。
変調信号を正弦にすると位相が滑らかに揺れ、方形波にすると位相が 2 つの値の間を跳ぶ。
後者がデジタル無線の基本の **BPSK** (2 値の位相偏移変調) で、ビットの 0 と 1 を搬送波の向き (位相 180° 違い) で表す。
位相は 1 本の波だけでは読めないので、W2 に変調の無い同じ周波数の搬送波を出して**基準**にする。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 (変調あり) を CH1、W2 (基準) を CH2 に直結
parts:
  W1: sine 1,1 1,3 1
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  W2: sine 5,1 5,3 1
  M2: voltmeter 7,1 7,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 5,1 -- 7,1
  - 1,3 -- 3,3 -- 5,3 -- 7,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/14-pm-psk.svg)

実体配線図は 1-7 の図2 と同じ (W1 と 1+、W2 と 2+ をそれぞれ同じ列に挿し、GND・1−・2− を − レールへ)。前の題の配線をそのまま使い、測り方だけを足す題なので再掲しない。

## 計器の設定

| 計器 | 設定 (PM) | 設定 (BPSK) |
| --- | --- | --- |
| Wavegen W1 | Carrier Sine 10 kHz、Amplitude 1 V。変調 PM: Sine 100 Hz、偏移 57.3° (1 rad) | Carrier 同じ。変調 PM: **Square 1 kHz**、偏移 **90°** |
| Wavegen W2 | Sine 10 kHz、Amplitude 1 V、変調なし。W1 と同期 (1-7) | 同じ |
| Scope | CH1・CH2: Range 500 mV/div。Time 20 µs/div。トリガ CH2 立ち上がり 0 V | Time 100 µs/div、トリガ同じで位置 −3 div |
| Spectrum | — | Source CH1、Start 0 Hz・Stop 20 kHz、Window Flat-top、単位 dBm |

PM の偏移を度で書くか rad で書くか、方形波の変調で ±90° になるか 0〜90° になるかは WaveForms の版で違うかもしれない (**目安**)。
CH2 を基準にして、BPSK の 2 つの位相の差が 180° になるように偏移を合わせる。
W1 と W2 は同期させないと、基準との位相差が少しずつ流れて読めない。

**PM (正弦の変調)**: 位相は ±57.3° の間を 100 Hz で揺れる。CH1 を CH2 と重ねると、CH1 の零点が CH2 の零点の前後へ
最大 57.3 / 360 × 100 µs = 15.9 µs ずれ、10 ms ごとに元に戻る。位相の揺れは瞬時周波数の揺れでもあり、
偏移は Δf = β f<sub>m</sub> = 1 × 100 Hz = 100 Hz。PM と FM は、変調信号を微分するか積分するかの違いだけで、正弦の変調では区別できない。

**BPSK**: 変調の方形波が +1 の間は CH1 が CH2 より 90° 進み、−1 の間は 90° 遅れる。境目で CH1 の向きが反転する (図2)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 BPSK — 500 µs ごとに CH1 の向きが反転する (CH2 は基準)
time: 100us/div
trigger: ch2 rising 0V at -3div
ch1: {wave: "= 1V * clip(1000 * sin(2 * pi * 1kHz * t), -1, 1) * cos(2 * pi * 10kHz * t)", range: 500mV/div, position: 2div}
ch2: {wave: sine 10kHz 1V, range: 500mV/div, position: -2div}
cursors: [0, 500us]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/14-pm-psk.svg)

BPSK のスペクトルには搬送波 (10 kHz) が無く、±1 kHz・±3 kHz・±5 kHz … の奇数次の線が並ぶ (図3)。
1010… と交互に並ぶビット列は 1 kHz の方形波なので、方形波の奇数次の高調波 (4-2) が搬送波の両側に写る。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 BPSK (1010…) — 搬送波は消え、10 kHz ± 1・3・5 kHz に線が立つ
device: ad3
sweep: 0-20kHz
samples: 32768
window: flattop
unit: dBm
ref: 13dBm
signal:
  - sine 9kHz 0.6366V
  - sine 11kHz 0.6366V
  - sine 7kHz 0.21221V
  - sine 13kHz 0.21221V
  - sine 5kHz 0.1273V
  - sine 15kHz 0.1273V
markers: [11kHz, 13kHz, 15kHz, 10kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/spectrum/14-pm-psk.svg)

## 見るべき値

計算値。dBm は 50 Ω を基準にした換算 (4-7 と同じ)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| PM: CH1 と CH2 の零点のずれの最大 | ±15.9 µs (±57.3°) | 偏移 1 rad。2-2 の Measure の Phase でも読める |
| PM: スペクトルの搬送波 | 0.765 V (+7.68 dBm) | β = 1 rad の PM は J<sub>0</sub>(1) = 0.765 倍。FM の 4-8 と同じ形 |
| PM: 100 Hz 離れた側波帯 1 本 | 0.440 V (+2.87 dBm) | J<sub>1</sub>(1) = 0.440 倍 |
| BPSK: CH1 の向きの反転 | 500 µs ごと (図2 のカーソルの間) | 1 bit = 500 µs (2000 bit/s の 1010…) |
| BPSK: 10 kHz の線 | 無い | 位相が +90° と −90° に等しく居るので、平均の搬送波が打ち消し合う |
| BPSK: 9 kHz・11 kHz | 各 0.637 V (+6.08 dBm、搬送波 1 V に対し −3.92 dB) | 方形波の基本波 4/π の半分ずつ |
| BPSK: 7・13 kHz / 5・15 kHz | 0.212 V (−3.46 dBm) / 0.127 V (−7.90 dBm) | 1/3・1/5 で減る |

分かること:

- **BPSK は「方形波 (±1) を搬送波に掛けたもの」と同じ**。位相 ±90° の跳びは sin(ωt ± 90°) = ±cos ωt で、向きの反転になる。
  振幅は変わらないので、Scope の Vpp は 2.00 V のまま (図2)
- 線の電力を全部足すと、変調の無い搬送波 1 本の電力 (+10.00 dBm) に戻る。変調は電力を周波数の上に配り直すだけ
- 実際の無線では方形波の高い次数が帯域を広げるので、ビットの境目をなめらかにしてから変調する (帯域の制限)。
  Wavegen なら変調を Square から Custom (3-4) の丸めた波に替えると試せる (**未確認**)

## LTspice での確かめ (対象外)

変調の算術で確かめた (回路は W1・W2 を CH1・CH2 に直結するだけ)。PM の零点のずれは 57.3° / 360° × 100 µs = 15.9 µs、
側波帯は J<sub>0</sub>(1) = 0.7652、J<sub>1</sub>(1) = 0.4401 で、10 + 20 log 0.7652 = +7.68 dBm、10 + 20 log 0.4401 = +2.87 dBm。
BPSK の線は (2/π)/k = 0.6366・0.2122・0.1273 V (k = 1・3・5) で、+6.08・−3.46・−7.90 dBm。
電力の和 Σ 2 × (2/(πk))<sup>2</sup> / 2 は奇数の k で 1 に収束する (8/π<sup>2</sup> × π<sup>2</sup>/8 = 1)。本文の表と合う。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。Wavegen が位相の変調を持つことは
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Advanced Waveforms の行)。
参考: [位相変調 (Wikipedia)](https://ja.wikipedia.org/wiki/位相変調)、[位相偏移変調 (Wikipedia)](https://ja.wikipedia.org/wiki/位相偏移変調)
