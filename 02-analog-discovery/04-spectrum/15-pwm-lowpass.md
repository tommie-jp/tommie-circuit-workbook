---
book: analog-discovery
chapter: 4
id: 4-15
title: PWM のスペクトルとローパス
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-15 PWM のスペクトルとローパス

マイコンの PWM (パルス幅変調) に RC のローパスを付けると、デューティに比例した直流が取り出せる (簡単な DA 変換)。
時間で見ると「ほぼ平らな直流に小さなリプル」だが、Spectrum で見ると **PWM は直流と高調波の列**で、
ローパスは**高調波を周波数の 2 乗で削る** (2 段なら −40 dB/dec) 道具だと分かる。

W1 で 10 kHz・0〜3.3 V・デューティ 25% の PWM を作り (マイコンの 3.3 V の PWM のまね)、2 段の RC に通す前 (CH1) と後 (CH2) の
スペクトルを比べる。デューティ 25% の PWM は 4 の倍数の次数 (40 kHz・80 kHz …) が消える、という形の手がかりも読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の PWM を 2 段の RC (各 159 Hz) で均す
parts:
  V1: square 1,2 1,4 l=$\mathrm{W1}$
  G1: ground 1,4
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  G2: ground 3,4
  R1: resistor 3,1 6,1 1k
  C1: capacitor 6,1 6,4 1u
  G3: ground 6,4
  R2: resistor 6,1 9,1 10k
  C2: capacitor 9,1 9,4 100n
  G4: ground 9,4
  M2: voltmeter 11,2 11,4 l=$\mathrm{CH2}$
  G5: ground 11,4
wires:
  - 1,2 -- 1,1 -- 3,1
  - 3,1 -- 3,2
  - 9,1 -- 11,1 -- 11,2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/15-pwm-lowpass.svg)

- 1 段めは R1 1 kΩ (Ω はオーム)・C1 1 µF (µ はマイクロ)、2 段めは R2 10 kΩ・C2 100 nF。どちらも折れ点は 1 / (2π × 1 ms) = 159 Hz
- 2 段めを 10 倍の抵抗にして、1 段めへの負荷を軽くした。2 段まとめた −3 dB は 94 Hz (LTspice)
- CH2 の入力抵抗 1 MΩ は R1 + R2 = 11 kΩ と分圧になり、直流を 1.1% 下げる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (2 段の RC)
board: half
parts:
  R1: resistor c3 c8 1k
  C1: capacitor b8 -t8 1u
  R2: resistor d8 d14 10k
  C2: capacitor h14 -b14 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 1-, GND, 2+, 2-]
wires:
  - AD.W1 -- b3 yellow
  - AD.1+ -- a3 orange
  - AD.1- -- -t5 black
  - AD.GND -- -t6 black
  - -t1 -- -b1 black
  - e14 -- f14 white
  - AD.2+ -- a14 blue
  - AD.2- -- -t16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/15-pwm-lowpass.svg)

R1 (3〜8 列)・C1 (8 列から上の − レール) が 1 段め、R2 (8〜14 列) が 2 段め。C2 は 14 列を白の線で下半分へ渡し、下の − レールへ挿した。
W1 (黄) と CH1 (1+、橙) は 3 列、CH2 (2+、青) は 14 列。部品は向きの無いフィルムかセラミック。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、10 kHz、Amplitude 1.65 V、Offset 1.65 V (0〜3.3 V)、Symmetry 25% (デューティ) |
| Scope | CH1・CH2: DC、1 V/div。Time 50 µs/div。Trigger: CH1 の立ち上がり 1.65 V |
| Spectrum | Source: Channel 1、次に Channel 2。Start 0 Hz、Stop 50 kHz、FFT 点数 8192、Window: Flat-top。単位: dBm |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH1 は 0〜3.3 V・デューティ 25% の PWM、CH2 はその平均 0.816 V
time: 50us/div
trigger: ch1 rising 1.65V
ch1: {wave: pulse 10kHz 1.65V offset 1.65V duty 25%, range: 1V/div, position: -3div}
ch2: {wave: "= 0.8157V - 0.376mV * cos(2 * pi * 10kHz * t)", range: 1V/div, position: -3div}
measure: [freq, duty, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/15-pwm-lowpass.svg)

CH2 のリプル (Vpp 0.78 mV) は 1 V/div では線の太さに隠れる。時間で読めないほど小さい残りを、Spectrum の dB で読む。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 PWM (CH1) — 直流と 10 kHz の高調波の列。4 次 (40 kHz) は消える
device: ad3
sweep: 0-50kHz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
scale: 15dB
signal: pulse 10kHz 3.3Vpp offset 1.65V duty 25%
markers: [0, 10kHz, 20kHz, 30kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/15-pwm-lowpass-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図5 2 段の RC の後 (CH2) — 直流は残り、10 kHz は 72 dB 削られる
device: ad3
sweep: 0-50kHz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
scale: 15dB
signal:
  - dc 0.8157V
  - sine 10kHz 0.376mV
  - sine 20kHz 66.5uV
  - sine 30kHz 13.9uV
markers: [0, 10kHz, 20kHz, 30kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/15-pwm-lowpass-2.svg)

図4 と図5 は同じ尺度 (REF 20 dBm・15 dB/div) で並べた。図5 の線の高さは下の表の計算値 (LTspice の利得から)。
実機ではこの下に AD3 の雑音のフロアがあり、30 kHz (−87 dBm) は埋もれることがある。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 | 1 kΩ |
| C1 | フィルムかセラミックのコンデンサ | 1 µF (105) |
| R2 | 抵抗 | 10 kΩ |
| C2 | フィルムかセラミックのコンデンサ | 100 nF (104) |
| — | 信号源 | AD3 の Wavegen W1 (0〜3.3 V。R1 に流れる電流は 3.3 mA 以下) |

## 見るべき値

計算値。高さ A = 3.3 V・デューティ D = 0.25 の PWM の n 次の振幅は (2A ÷ nπ) × |sin(nπD)|、直流は A × D。
ローパスの利得は LTspice の .ac の値。

| 線 | CH1 (PWM) | 2 段の RC の利得 | CH2 (後) |
| --- | --- | --- | --- |
| 直流 | 0.825 V (+11.34 dBm) | 0.989 (CH2 の 1 MΩ との分圧) | 0.816 V (+11.24 dBm) |
| 10 kHz (1 次) | 1.486 V (+13.44 dBm) | 2.53 × 10⁻⁴ (−71.9 dB) | 0.376 mV (−58.50 dBm) |
| 20 kHz (2 次) | 1.050 V (+10.43 dBm) | 6.33 × 10⁻⁵ (−84.0 dB) | 66.5 µV (−73.54 dBm) |
| 30 kHz (3 次) | 0.495 V (+3.90 dBm) | 2.82 × 10⁻⁵ (−91.0 dB) | 13.9 µV (−87.14 dBm) |
| 40 kHz (4 次) | 0 (sin π = 0) | — | 0 |

分かること:

- **PWM の直流はデューティで決まり、ローパスはそれを通す**。高調波の高さもデューティで決まり、25% では 4 の倍数の次数が消える。
  デューティを 50% にすると偶数次が全部消える (4-2 の方形波)
- **2 段の RC は、折れ点 (159 Hz) よりずっと上では周波数の 2 乗で効く**。10 kHz から 20 kHz で利得は 1/4 (−12 dB) になった。
  1 段だけなら 1/2 (−6 dB) ずつで、10 kHz の残りは約 −36 dB にとどまる
- 時間で見たリプル (Vpp 0.78 mV) と、スペクトルの 10 kHz の線 (振幅 0.376 mV = Vpp 0.75 mV) はほぼ同じ物を見ている。差は 2 次以上の線のぶん
- PWM の周波数を 10 倍の 100 kHz にすれば、同じ RC で残りは約 40 dB 減る。マイコンの PWM の DA で「周波数を上げる」理由がこれである

## LTspice での確かめ

`sim/15-pwm-lowpass.cir` (過渡解析、40〜60 ms) と `sim/15-pwm-lowpass-ac.cir` (.ac) で図1 を解いた。PWM は PULSE の電源 (0〜3.3 V、周期 100 µs、High 25 µs)、
CH2 の入力は 1 MΩ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力の直流 | 0.816 V | 0.8157 V | 合う |
| 出力のリプル | Vpp 0.78 mV | Vpp 0.779 mV | 合う |
| 利得 10 kHz | 2.53 × 10⁻⁴ | 2.532 × 10⁻⁴ | 合う |
| 利得 20 kHz | 6.33 × 10⁻⁵ | 6.333 × 10⁻⁵ | 合う |
| 利得 30 kHz | 2.82 × 10⁻⁵ | 2.815 × 10⁻⁵ | 合う |
| −3 dB | 94 Hz | 94.4 Hz | 合う |

手計算: 2 段の RC の伝達は 1 / (1 + jω(R1C1 + R2C2 + R1C2) − ω²R1C1R2C2)。10 kHz では ω²R1C1R2C2 = 3948、
jω × 2.1 ms = 132 なので |分母| = 3949、利得は 2.53 × 10⁻⁴。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Spectrum の節)。パルス列のフーリエ級数は信号処理の教科書に載っている標準的な式。

参考: [パルス幅変調 (Wikipedia)](https://ja.wikipedia.org/wiki/パルス幅変調)
