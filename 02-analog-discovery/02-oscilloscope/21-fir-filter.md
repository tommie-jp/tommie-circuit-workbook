---
book: analog-discovery
chapter: 2
id: 2-21
title: FIR フィルタ ch でノイズを除く
tier: 200
source: 自作
board: BB
device: AD3
---

# 2-21 FIR フィルタ ch でノイズを除く

AD3 の Scope には、入力の 1 本ごとに**フィルタのチャネル**があり、取り込んだ数の列に AD3 の中で FIR (有限インパルス応答) の
デジタルフィルタを掛けて、もう 1 本のトレースとして出せる。回路に RC のフィルタを足さずに、見たい帯域だけを残せる。
1 kHz の信号に 50 kHz の雑音を抵抗で混ぜ、FIR の低域通過で 50 kHz を消す。
**FIR は位相が周波数に比例してずれる (群遅延が一定の) フィルタ**で、消したあとの波形が元より少し遅れて出ることも見る。

**AD2 での代わり**: AD2 にはこのチャネルが無い。Math の Filter (PC の側で計算する Butterworth・Chebyshev の IIR、
係数を書く FIR) で同じことができる。Sample Mode の Average (2-14) は、雑音が 1 kHz と同期していなければ効くが、
この題の W2 のように同じ時計から作った 50 倍の周波数は毎回同じ所に来るので、平均しても消えない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 1 kHz の信号 (W1) に 50 kHz の雑音 (W2) を抵抗で混ぜる
parts:
  M1: voltmeter 1,2 1,6 l=$\mathrm{CH1}$
  W1: sine 3,2 3,6 1
  R1: resistor 3,2 6,2 10k
  M2: voltmeter 6,3 6,6 l=$\mathrm{CH2}$
  R2: resistor 9,2 6,2 10k
  W2: sine 9,2 9,6 0.5
  G1: ground 3,6
wires:
  - 1,2 -- 3,2
  - 6,2 -- 6,3
  - 1,6 -- 3,6 -- 6,6 -- 9,6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/21-fir-filter.svg)

- W1 (1 kHz、振幅 1 V) が見たい信号、W2 (50 kHz、振幅 0.5 V) が雑音の代わり (スイッチング電源の雑音の模型)
- R1・R2 (10 kΩ (キロオーム)) で混ぜた点は、2 つの電圧の平均 (W1 + W2) / 2。Scope の入力抵抗 1 MΩ が 5 kΩ の出力抵抗を引くので、
  正しくは 0.995 倍で、1 kHz が 0.4975 V、50 kHz が 0.2488 V (振幅)
- CH1 は W1 そのもの (位相の基準)、CH2 が混ぜた点。フィルタは CH2 に掛ける

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (W1 と W2 を 10 kΩ 2 本で混ぜる)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 2+, W2, GND, 1-, 2-]
  R1: resistor c5 c10 10k
  R2: resistor d15 d10 10k
wires:
  - AD.1+ -- a3 orange
  - b3 -- b5 yellow
  - AD.W1 -- a5 yellow
  - AD.2+ -- a10 blue
  - AD.W2 -- a15 green
  - AD.GND -- -t18 black
  - AD.1- -- -t20 black
  - AD.2- -- -t22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/21-fir-filter.svg)

- R1 は W1 の 5 列から混ぜる点の 10 列へ、R2 は W2 の 15 列から同じ 10 列へ。2+ (青) は 10 列
- 1+ (橙) は 3 列に挿し、黄の線で W1 の 5 列とつなぐ (同じ列へ上から 2 本下ろさないため)
- GND・1−・2− は上の − レールへ。W1・W2 の戻りは AD3 の中で GND につながっている

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | Sine、1 kHz、Amplitude 1 V |
| Wavegen (W2) | Sine、50 kHz、Amplitude 0.5 V (W1 と同期させて Run) |
| Scope (CH1) | DC、500 mV/div。Trigger は CH1、Rising、0 V |
| Scope (CH2) | DC、200 mV/div |
| Time | 200 µs/div (µs はマイクロ秒)。Rate を 1 MS/s に下げる (下の理由) |
| CH2 の Filter | Source: Decimate、Mode: FIR Window (Hamming)、Type: Low pass、Cutoff 10 kHz、Size 64 (タップ数) |

フィルタのチャネルは、Scope の Channels の列で CH2 の下に畳まれている (WaveForms 付属のヘルプ。開き方は版で違うので目安)。
Source を Decimate にすると、フィルタは Scope の Rate (ここでは 1 MS/s) で動く。Rate が高いままだと、10 kHz を切るのに
桁違いに多いタップが要る。**FIR の切れ味は、タップ数 ÷ Rate (= フィルタが見る時間の長さ、64 µs) で決まる。**
Filter の編集画面に伝達特性の下見があるので、50 kHz の落ち方をそこで先に確かめる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH2 (混ぜた後) の 50 kHz を、CH2 の FIR フィルタ (赤) が取り除く
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: = 0.4975V * sin(2 * pi * 1kHz * t) + 0.2488V * sin(2 * pi * 50kHz * t), range: 200mV/div}
math: {expr: 0.4962V * sin(2 * pi * 1kHz * (t - 31.5us)), range: 200mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/21-fir-filter.svg)

図3 の赤い線 (フェンスでは Math の位置) がフィルタのチャネル。理想の FIR (下の算術の値) の出力を描いた:
50 kHz は 0.4 % (−48 dB) に落ちて見えなくなり、1 kHz は 0.997 倍で残る。CH1 (W1、500 mV/div) とは尺度が違うので、振幅は数で比べる。
赤い線は CH1 より 31.5 µs 遅れる (1 kHz で −11.3°)。64 タップの FIR は、真ん中のタップ (31.5 番め) の時刻の値を出すから。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (W1 の側) | 10 kΩ |
| R2 | 抵抗 (W2 の側) | 10 kΩ |
| — | 計器 | AD3 の Wavegen (W1・W2) と Scope (1+ = W1、2+ = 混ぜた点)、CH2 のフィルタのチャネル |

## 見るべき値

フィルタの値は、64 タップの Hamming 窓の窓関数法 (Rate 1 MS/s、Cutoff 10 kHz、直流で 1 になるよう正規化) を算術で計算したもの。
WaveForms の FIR Window の作り方は公開されていないので、細かい値は Filter の下見で読み直す (目安)。

| 項目 | 期待する値 | 計算・読み方 |
| --- | --- | --- |
| CH2 の 1 kHz の振幅 | 0.4975 V | 1 V / 2 × 0.995 (Scope の 1 MΩ の分) |
| CH2 の 50 kHz の振幅 | 0.249 V | 0.5 V / 2 × 0.995 |
| CH2 の Vpp | 1.49 V | (0.4975 + 0.2488) × 2 (山と山が重なる所) |
| FIR の 1 kHz の利得 | 0.997 (−0.02 dB) | 出力の Vpp 0.992 V |
| FIR の 50 kHz の利得 | 0.0039 (−48 dB) | 0.249 V → 0.96 mV。14 bit の 1 段 (0.336 mV) の 3 段ぶん |
| FIR の −6 dB の周波数 | 約 13 kHz (10 kHz で −2.4 dB) | 窓関数法の Cutoff は「−6 dB の点」ではない |
| 群遅延 | 31.5 µs (1 kHz で −11.3°) | (64 − 1) / 2 / 1 MS/s。周波数によらず一定 |

確かめ方の手順:

1. フィルタを切った CH2 と入れた CH2 を並べ、Measurements の Vpp を読む (1.49 V → 0.992 V)
2. W2 を 5 kHz に下げる。FIR の 5 kHz の利得は 0.93 (−0.6 dB) で、雑音はほとんど残る。**周波数が近い雑音はフィルタで分けられない**
3. Size を 16 に減らすと、フィルタが見る時間は 16 µs になり、50 kHz は −4.2 dB しか落ちない (同じ算術)。遅れは 7.5 µs に縮む
4. W2 を Noise (Frequency = DAC の更新の速さ、1 MHz) に替える。広い帯域の雑音のうち 13 kHz より上が消え、線が細くなる
5. Mode を IIR Butterworth にすると、同じ切れ味を少ない計算でできるが、遅れが周波数で変わり、方形波の形が崩れる。FIR は崩れない

## LTspice での確かめ

`sim/21-fir-mix.cir` で混ぜる回路 (図1) を AC 解析した。Scope の入力は 1 MΩ の抵抗と**仮定**し、入力の容量は無視した (実測ではない)。
FIR は Scope の中の数の計算なので SPICE では解かず、上の窓関数法の算術 (Python で係数を作り、周波数応答を計算) で確かめた。

| 項目 | 本文の数字 | LTspice / 算術 | 判定 |
| --- | --- | --- | --- |
| W1 から CH2 への利得 (1 kHz) | 0.4975 | 0.4975 (LTspice) | 合う |
| W2 から CH2 への利得 (50 kHz) | 0.4975 (0.5 V → 0.2488 V) | 0.4975 → 0.2488 V (LTspice) | 合う |
| FIR の 1 kHz・50 kHz の利得 | −0.02 dB・−48 dB | −0.023 dB・−48.3 dB (算術) | 合う |
| FIR の 5 kHz・10 kHz の利得 | −0.6 dB・−2.4 dB | −0.59 dB・−2.37 dB (算術) | 合う |
| 群遅延 | 31.5 µs | 31.5 µs (算術、(N − 1) / 2 / f<sub>s</sub>) | 合う |
| 16 タップの 50 kHz の利得 | −4.2 dB | −4.17 dB (算術) | 合う |

## 出典

自作。フィルタのチャネル (Source・Mode・Size・Window・Cutoff) と Math の Filter は WaveForms 付属のヘルプ (Oscilloscope の Filter Channels と Math Channels の節) による。

参考: [FIR フィルタ (Wikipedia)](https://ja.wikipedia.org/wiki/FIRフィルタ)、[デジタルフィルタ (Wikipedia)](https://ja.wikipedia.org/wiki/デジタルフィルタ)
