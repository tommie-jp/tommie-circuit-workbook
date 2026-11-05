---
book: analog-discovery
chapter: 1
id: 1-14
title: 計器を同時に走らせる (Scope + Spectrum + Logger)
tier: 200
source: 自作 (入力の取り合いは Digilent の Analog Discovery 3 の公式資料)
board: BB
---

# 1-14 計器を同時に走らせる (Scope + Spectrum + Logger)

WaveForms では、Scope・Spectrum・Logger の窓を同時に開ける。けれども 3 つとも **同じ 2 本のアナログ入力**
(CH1・CH2) を使う。Analog Discovery 3 (AD3) の Reference Manual によれば、同じハードウェアを使う計器は
**最後に Run (か Stop) を押した 1 つ**が入力を握り、ほかの窓には **Busy** と出る (Trigger System の節)。
Voltmeter も同じで、Scope・Logger・Spectrum と同時には使えない (Voltmeter の節)。

つまり「3 つを同時に走らせる」は、窓を 3 つ並べて Run を 3 回押すことではない。この題では、

1. 3 つの窓で順に Run を押し、Busy になる様子を見る
2. **1 つの Scope の記録から、波形・スペクトル・ログの 3 つを同時に出す** (Scope の中の FFT の表示と記録の機能)

を試す。測るのは 1 kHz の方形波を RC ローパスに通した波で、波形の丸まり・高調波の減り・平均の 3 つが同じ記録から読める。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の方形波を R1・C1 (1.59 kHz のローパス) に通す
parts:
  W1: square 1,2 1,4 l=$\mathrm{W1}$
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  R1: resistor 3,2 5,2 1k
  C1: capacitor 5,2 5,4 100n
  M2: voltmeter 7,2 7,4 l=$\mathrm{CH2}$
  G1: ground 1,4
wires:
  - 1,2 -- 3,2
  - 5,2 -- 7,2
  - 1,4 -- 3,4 -- 5,4 -- 7,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/14-simultaneous-instruments.svg)

- W1 は 1 kHz、0〜2 V の方形波 (振幅 1 V・オフセット 1 V)
- R1 (1 kΩ (キロオーム))・C1 (100 nF) の遮断周波数は 1 ÷ (2π × 1 kΩ × 100 nF) = 1.59 kHz、時定数 τ (タウ) = 0.1 ms

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 R1 (6〜10 列) と C1 (10 列と GND)。CH1 は 6 列、CH2 は 10 列 (1-12 と同じ並び)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, 2-, W1, 1+, 2+]
  R1: resistor c6 c10 1k
  C1: capacitor/ceramic e10 e13 100n
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - AD.W1 -- a6 yellow
  - AD.1+ -- b6 orange [h10]
  - AD.2+ -- a10 blue
  - a13 -- -t13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/14-simultaneous-instruments.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、1 kHz、振幅 1 V、オフセット 1 V |
| Scope | CH1・CH2 とも 500 mV/div、200 µs/div、トリガは CH1 の立ち上がり 1 V。Measurements に Average・Peak2Peak |
| Spectrum (手順 1 だけ) | CH2、0〜10 kHz、窓 Flat Top、単位 dBm |
| Logger (手順 1 だけ) | CH2 の Average、1 秒に 1 点 |
| Scope の FFT と記録 (手順 2) | Scope の表示に FFT を足し (View の追加。名前は目安)、Scope の Logging で CH2 の Average を 1 秒ごとにファイルへ |

手順 1 (Busy を見る): Scope で Run → Spectrum で Run を押すと Scope が Busy になる → Logger で Run を押すと Spectrum が Busy になる。
入力を握るのはいつも最後に押した 1 つ。手順 2 では Spectrum と Logger を Stop にして、Scope だけを走らせる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH2 は τ = 0.1 ms で丸まる — Vpp 1.97 V、平均 1.00 V
time: 200us/div
trigger: ch1 rising 1V
ch1: {wave: square 1kHz 1V offset 1V, range: 500mV/div, position: -2div}
ch2: {wave: ch1 | rc 100us, range: 500mV/div, position: -2div}
measure: [avg, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/14-simultaneous-instruments.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 CH2 のスペクトル — 基本波 10.6 dBm、3 次 −4.0 dBm、5 次 −12.2 dBm
device: ad3
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
signal:
  - dc 1V
  - sine 1kHz 1.078V
  - sine 3kHz 0.1989V
  - sine 5kHz 0.0772V
  - sine 7kHz 0.0403V
  - sine 9kHz 0.0246V
markers: [1kHz, 3kHz, 5kHz, 7kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/spectrum/14-simultaneous-instruments.svg)

図4 は CH2 の方形波の奇数次の高調波 (振幅 4/π ÷ n V) に、RC の |H| を掛けた値で描いた。Spectrum の窓で見ても、
Scope の FFT の表示で見ても、同じ記録から計算するので値は同じになるはず (表示の細かい設定は目安)。

## 部品

| 記号 | 部品 | 値・型 | 備考 |
| --- | --- | --- | --- |
| R1 | 抵抗 | 1 kΩ、1/4 W | |
| C1 | 積層セラミック | 100 nF (0.1 µF (マイクロファラド)) | W1 は負に振れないので極性は気にしない |

## 見るべき値

| 計器 | 見る物 | 期待する値 |
| --- | --- | --- |
| Scope (CH2) | 丸まった方形波の Vpp・平均 | 1.97 V (= 2 V × tanh(1 ms ÷ (4 × 0.1 ms)))、1.00 V |
| Spectrum (CH2) | 1・3・5・7 kHz の線 | 10.6・−4.0・−12.2・−17.9 dBm (CH1 では 12.1・2.6・−1.9・−4.8 dBm) |
| Logger (CH2) | Average の 1 秒ごとの点 | 1.00 V で横ばい |
| 手順 1 | 後から Run を押した窓以外 | Busy |

- 方形波のままの CH1 では高調波が 1/n で下がる (3 次は基本波の 9.5 dB 下)。CH2 では RC の分だけ余計に下がり、3 次は基本波の 14.7 dB 下
- 平均 (直流分) は RC を通しても 1.00 V のまま (1-12 と同じ)。Logger の値は波形が丸まっても変わらない

## LTspice での確かめ

`sim/14-simultaneous-instruments.cir` (過渡解析、40〜50 ms の定常) で CH2 の平均・Vpp を、
`sim/14-simultaneous-instruments-ac.cir` (AC 解析) で各高調波の |H| を読んだ。どちらも CH2 の入力 1 MΩ を負荷に入れた。

| 項目 | 本文 | LTspice | 判定 |
| --- | --- | --- | --- |
| CH2 の平均 | 1.00 V | 0.999 V | 合う |
| CH2 の Vpp | 1.97 V | 1.971 V | 合う |
| −3 dB の周波数 | 1.59 kHz | 1.592 kHz | 合う |
| H の大きさ (1・3・5・7 kHz) | 0.847・0.469・0.303・0.222 | 0.846・0.469・0.303・0.222 | 合う |
| 基本波の dBm | 10.6 dBm (= 4/π × 0.847 = 1.078 V) | 4/π × 0.846 = 1.077 V → 10.6 dBm | 合う |

## 出典

自作。最後に Run を押した計器が入力を握り、ほかが Busy になること、Voltmeter が Scope・Logger・Spectrum と同時に動かないことは Digilent の
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Trigger System・Voltmeter の節)。Spectrum の単位と窓は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Spectrum Analyzer の節)。
