---
book: denken
chapter: 3
id: 3-13
title: ひずみ波 — 方形波を FFT で基本波と高調波に分ける
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-13 ひずみ波 — 方形波を FFT で基本波と高調波に分ける

正弦波でない周期的な波 (ひずみ波) は、基本波と、その整数倍の周波数の正弦波 (高調波) の
和に分けられる (フーリエ級数)。**方形波は奇数次の高調波だけを持ち、n 次の高さは基本波の 1/n**
になる。AD の Spectrum (FFT) で方形波を分けて高さを読み、RC の回路を通すと高い次数ほど
小さくなる (回路は調波ごとに別のインピーダンスで働く) ことも確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| v = (4Vm/π){sin ωt + (1/3) sin 3ωt + (1/5) sin 5ωt + …} | 振幅 Vm (±Vm) の方形波のフーリエ級数 |
| V_n = 4Vm / (nπ) (n は奇数) | n 次の高調波の振幅。偶数次は 0 |
| V_1 = 4Vm / π = 1.27 Vm | 基本波は方形波の振幅より大きい |
| G_n = 1 / √(1 + (nf/fc)²)、fc = 1 / (2πRC) | RC の回路が n 次を通す割合。調波ごとに違う |
| V = √(V_1² + V_3² + V_5² + …) (実効値) | ひずみ波の実効値は各調波の実効値の二乗和の平方根 (3-14 で詳しく) |

## 回路図

```circuit
title: 図1 方形波と RC の回路
style:
  standard: jis
  pitch: 1.2
parts:
  V1: square c1 g1 l=$\mathrm{W1}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  R1: resistor c4 c6 1k
  C1: capacitor c8 g8 100n
  M2: voltmeter c11 g11 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3 -- c4
  - c6 -- c8 -- c11
  - g1 -- g3 -- g8 -- g11
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/13-square-wave-fft.svg)

- V1 は AD の波形発生器 W1 (方形波 1 kHz、±1 V)。CH1 は方形波そのもの
- R1 (1 kΩ) と C1 (100 nF) は低域通過の RC 回路 (fc = 1.59 kHz、τ = 100 µs)。CH2 は C1 の電圧。
  どちらも GND 基準

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor/film d10 d15 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, "1-", "2-", W1, "1+", "2+"]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.2+ -- a10 blue
  - a15 -- -t15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/13-square-wave-fft.svg)

- 5 列が W1、10 列が R1 と C1 のつなぎ目 (CH2)、15 列が GND 側
- 1+ は W1 と同じ 5 列、2+ は 10 列。1− と 2− は GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、1 kHz、Amplitude 1 V、Offset 0 V、Symmetry 50 % (±1 V の方形波) |
| Scope | CH1・CH2 とも 500 mV/div、Time 200 µs/div。形を見る |
| Spectrum | Channel 1 と 2。Start 0 Hz、Stop 10 kHz。Window は Flat Top (高さを正しく読むため)。縦軸は dBV |
| Spectrum のカーソル | 1・3・5・7・9 kHz の山 (Peak を読む) |

**dBV の 0 dB は実効値 1 V の正弦波** (リファレンスマニュアルの Spectrum の Units: dBV = 20 log10(Vrms))。
振幅 (peak) V_n の山は 20 log10(V_n / √2) dBV に立つ。振幅 1 V の正弦波なら −3.0 dBV。
W1 の電流は方形波の角の瞬間に最大で 2.0 mA (2 V ÷ 1 kΩ) で、この本の目安 10 mA (0-1) に収まる。

τ = 100 µs は半周期 (500 µs) より十分短いので、CH2 は角の丸い方形波になり、山は 0.99 V まで届く。

```scope
title: 図3 方形波 (CH1) と RC を通した波 (CH2)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | rc 100us, range: 500mV/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/13-square-wave-fft-1.svg)

次の図は計算だけで描いた画面。方形波 (CH1) に、基本波・3 次・5 次の 3 つを足した波 (CH2) を
重ねた。3 つだけでも方形波の形に近づき、角のそばで 1.19 V まで行き過ぎる (ギブズの現象)。

```scope
title: 図4 計算 — 基本波 + 3 次 + 5 次の和 (CH2) は方形波 (CH1) に近づく
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1kHz 1V, range: 500mV/div}
ch2: {wave: = 1.273V * (sin(2 * pi * 1kHz * t) + sin(2 * pi * 3kHz * t) / 3 + sin(2 * pi * 5kHz * t) / 5), range: 500mV/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/13-square-wave-fft-2.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい。端子の読み替えは
[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

- W1 は FG の OUT (High-Z) で Square、1 kHz、2 Vpp (±1 V)、Offset 0 V、Duty 50 %
- CH1 の先端は 5 列 (FG の出力)、CH2 の先端は 10 列 (C1 の上)。グランドクリップは 2 本とも GND のレール
- Spectrum は、オシロの Math の FFT で代える。窓は Flat Top、縦軸は dBV (実効値) か V (実効値) の
  機種が多い。dBV の基準は機種で違うことがあるので、先に振幅 1 V の正弦波を入れて −3.0 dBV と読めるかを確かめる。表示の周波数の範囲は 0〜10 kHz
- FFT の山の高さは 8 bit で 40〜50 dB ほど下まで読める。9 次 (−20 dBV) までなら十分。
  CH2 の 9 次 (−35 dBV) はノイズに近いので、FFT の平均 (Average) を掛ける
- FG の出力の 50 Ω が R1 に足され、τ は 105 µs、fc は 1.52 kHz になる。CH2 の 3 次は 0.199 → 0.19 V
  ほどで、表との差は 5 % 以内 (計算値)。CH1 は 1 kΩ の負荷で振幅が 5 % 下がるので、FG の振幅を上げて
  CH1 を ±1.00 V に合わせる

## 見るべき値

計算値 (方形波 ±1 V、1 kHz、R1 = 1 kΩ、C1 = 100 nF、fc = 1.59 kHz)。dBV は実効値 1 V を 0 dB とした値。

| 次数 (周波数) | CH1 の振幅 4/(nπ) | CH1 (dBV) | RC の通す割合 G_n | CH2 の振幅 | CH2 (dBV) |
| --- | --- | --- | --- | --- | --- |
| 1 (1 kHz) | 1.273 V | −0.9 | 0.847 | 1.078 V | −2.4 |
| 3 (3 kHz) | 0.424 V | −10.5 | 0.469 | 0.199 V | −17.0 |
| 5 (5 kHz) | 0.255 V | −14.9 | 0.303 | 0.077 V | −25.3 |
| 7 (7 kHz) | 0.182 V | −17.8 | 0.222 | 0.040 V | −30.9 |
| 9 (9 kHz) | 0.141 V | −20.0 | 0.174 | 0.025 V | −35.2 |
| 2・4・6・8 kHz | 0 | (山なし) | — | 0 | (山なし) |

CH1 の n 次 ÷ 基本波は 1/3・1/5・1/7・1/9。CH2 はそれよりずっと速く小さくなる。

```graph
title: 図5 奇数次の山の高さ — 方形波は 1/n、RC の後は速く落ちる (両対数)
x: 周波数 Hz log 500..10k
y: 振幅 V log 0.01..2
lines:
  方形波 (CH1) V: 4/pi*1000/x
  RC の後 (CH2) V: 4/pi*1000/x/sqrt(1+(x/1.5915k)^2)
notes:
  - mark 1k
  - mark 3k
  - mark 5k
  - mark 7k
  - mark 9k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/graph/13-square-wave-fft.svg)

図5 の線は奇数次の山の頂をつないだもの (包絡)。山があるのは 1・3・5・7・9 kHz の縦の破線の所だけで、
その間 (偶数次) には何も立たない。

分かること:

- **方形波は奇数次の高調波だけでできている。** 高さは基本波の 1/3・1/5・1/7 …。
  基本波だけで 1.27 V あり、方形波の振幅 (1 V) より大きい
- **基本波・3 次・5 次の 3 つを足すだけで方形波に近くなる** (図4)。角を鋭くするのは高い次数
- **RC の回路は調波ごとに違う割合で通す。** 3 次は 0.47 倍、9 次は 0.17 倍。高い次数ほど
  削られるので、CH2 の角が丸くなる。電力系統で高調波がコンデンサやリアクトルに別々の電流を流すのと
  同じ考え方 (3-15)
- 実効値で確かめると、1〜9 次の CH1 の二乗和の平方根は 0.980 V で、方形波の実効値 1 V の 98 %

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope・Spectrum の節)。
