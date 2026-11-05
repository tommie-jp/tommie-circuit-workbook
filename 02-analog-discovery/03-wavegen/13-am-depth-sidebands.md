---
book: analog-discovery
chapter: 3
id: 3-13
title: 変調度と側波帯 (FFT と対)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-13 変調度と側波帯 (FFT と対)

3-3 で作った AM (振幅変調) の **Depth (変調度 m)** を 25 %・50 %・100 % と変え、同じ波を 2 つの見方で読む。
Scope ではエンベロープ (包絡線) の山と谷から m を求め、Spectrum では側波帯の高さから m を求める。
2 つの読みが同じ m に戻ることを確かめると、「時間で見る」と「周波数で見る」が同じ波の 2 つの面だと分かる。
4-7 は m = 50 % の 1 点だけを FFT で見た。ここでは m を振り、側波帯が m に比例して伸びること、
側波帯に乗る電力が m = 100 % でも全体の 1/3 にとどまることを読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ループバック (W1 を 1+ に直結)
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/13-am-depth-sidebands.svg)

実体配線図は 3-3 の図2 と同じ (W1 と 1+ をブレッドボードの同じ列に挿し、GND と 1− を − レールへ)。前の題の配線をそのまま使い、測り方だけを足す題なので再掲しない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Carrier Sine 100 kHz、Amplitude 1 V。AM: Modulation Sine 1 kHz、**Depth 25 % → 50 % → 100 %** |
| Scope | CH1: DC 結合、Range 500 mV/div、Time 200 µs/div。トリガ CH1 立ち上がり 0 V。カーソル 2 本 (エンベロープの山と谷)。Measure に RMS |
| Spectrum | Source CH1、Start 90 kHz・Stop 110 kHz、FFT 点数 32768、Window Flat-top、単位 dBm (4-7 と同じ) |

Depth 100 % では山が 2 V になる。Wavegen の出力の範囲 ±5 V の内側で、振幅が 1.25 V を超えるので 10 Vpp のレンジで出る (仕様)。
Depth が 100 % を超える設定 (過変調) が選べるかは**未確認**。選べても、ここでは扱わない。

図2 は Depth 100 % の画面。エンベロープの谷が 0 V まで落ちる。
カーソルを変調の山 (252.5 µs) と谷 (752.5 µs) の搬送波の頭 (100 kHz の 1/4 周期 2.5 µs だけ後ろ) に置くと、エンベロープの大きさ A<sub>max</sub>・A<sub>min</sub> が読める (図2 の X1 が 1.99 V なのは、画面の点の間隔で搬送波の頭を少し外すため。2.00 V と読んでよい)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 Depth 100 % — エンベロープは 2 V と 0 V の間を振れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: = 1V * (1 + sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t), range: 500mV/div}
cursors: [252.5us, 752.5us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/13-am-depth-sidebands.svg)

図3 は Depth 25 % のスペクトル。側波帯は搬送波の 18 dB 下に ±1 kHz で 1 本ずつ立つ。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 Depth 25 % — 側波帯は搬送波の 18.1 dB 下
device: ad3
sweep: 90kHz-110kHz
samples: 32768
window: flattop
unit: dBm
ref: 13dBm
signal:
  - sine 100kHz 1V
  - sine 99kHz 0.125V
  - sine 101kHz 0.125V
markers: [100kHz, 99kHz, 101kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/spectrum/13-am-depth-sidebands.svg)

## 見るべき値

計算値。搬送波の振幅 A<sub>c</sub> = 1 V、側波帯 1 本の振幅は A<sub>c</sub> m / 2。
dBm は WaveForms の Spectrum が 50 Ω を基準に換算した値 (AD3 の入力自体は高インピーダンスで、50 Ω の負荷は付けない)。

| Depth m | A<sub>max</sub> / A<sub>min</sub> (Scope のカーソル) | 側波帯 1 本 | 搬送波との差 | 側波帯の電力の割合 | CH1 の RMS |
| --- | --- | --- | --- | --- | --- |
| 25 % | 1.25 V / 0.75 V | 0.125 V (−8.06 dBm) | −18.06 dB | 3.0 % | 0.718 V |
| 50 % | 1.50 V / 0.50 V | 0.250 V (−2.04 dBm) | −12.04 dB | 11.1 % | 0.750 V |
| 100 % | 2.00 V / 0 V | 0.500 V (+3.98 dBm) | −6.02 dB | 33.3 % | 0.866 V |

搬送波は m によらず 1 V (+10.00 dBm) のまま。読みかたの式は 2 つ:

- **時間から**: m = (A<sub>max</sub> − A<sub>min</sub>) / (A<sub>max</sub> + A<sub>min</sub>)。25 % なら (1.25 − 0.75) / 2.00 = 0.25
- **周波数から**: m = 2 × 10<sup>(側波帯と搬送波の差 dB) / 20</sup>。−18.06 dB なら 2 × 0.125 = 0.25

分かること:

- **側波帯の振幅は m に比例する** (dB では m を 2 倍にするごとに 6 dB 上がる)。搬送波は動かない
- 側波帯の電力の割合は (m<sup>2</sup>/2) / (1 + m<sup>2</sup>/2)。m = 100 % でも 1/3 で、残りの 2/3 は情報を運ばない搬送波に使われる。
  AM の電力の効率が悪いと言われる理由で、搬送波を除いた DSB や片側だけの SSB の動機になる
- RMS は (A<sub>c</sub>/√2)√(1 + m<sup>2</sup>/2)。Scope の Measure の RMS からも m が逆算できる (m = 100 % で 0.866 V)
- 2 つの読みが合わないときは、時間のほうはカーソルが搬送波の頭からずれていないか、周波数のほうは Window が Flat-top か
  (Hann では山の高さが最大 1.4 dB ほど低く読める。4-3) を疑う

## LTspice での確かめ (対象外)

変調の算術で確かめた (回路は W1 を CH1 に直結するだけ)。側波帯 A<sub>c</sub> m / 2 は 0.125・0.25・0.5 V で、搬送波との差 20 log(m/2) は
−18.06・−12.04・−6.02 dB。50 Ω での電力は (0.125/√2)<sup>2</sup> / 50 = 0.156 mW = −8.06 dBm (以下 −2.04・+3.98 dBm)。
電力の割合 (m<sup>2</sup>/2) / (1 + m<sup>2</sup>/2) は 0.0303・0.111・0.333、RMS は 0.7071 × √(1 + m<sup>2</sup>/2) = 0.718・0.750・0.866 V。本文の表と合う。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen と Spectrum の節)。出力の範囲とレンジは
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [振幅変調 (Wikipedia)](https://ja.wikipedia.org/wiki/振幅変調)
