---
book: denken
chapter: 7
id: 7-5
title: 電力計の結線 — 単相の電力を測る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 7-5 電力計の結線 — 単相の電力を測る

電力計 (電流力計形) は、負荷と直列に入れる**電流コイル**と、負荷と並列に入れる**電圧コイル**を
持ち、2 つのコイルの瞬時値の積 v × i の平均、つまり有効電力 P = V I cos θ を指す。電圧コイルを
電流コイルの**電源側**につなぐか**負荷側**につなぐかで、計器自身の消費が読みに乗る向きが変わる。
電流コイルを 10 Ω、電圧コイルを 2.2 kΩ の抵抗で模型にし、v × i の平均は AD の Math で計算する。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| P = (1/T)∫v i dt = V I cos θ | 電力計が指す値 (有効電力)。V・I は実効値 |
| 電源側: P_読み = P + I² R_C | 電圧コイルが電流コイルの電圧降下まで含めて測る |
| 負荷側: P_読み = P + V² / R_P | 電流コイルが電圧コイルの電流まで含めて測る |
| R_C ≪ 負荷 ならば電源側、R_P ≫ 負荷 ならば負荷側が有利 | 7-3 の電圧計・電流計のつなぎ方と同じ考え |

## 回路図

```circuit
title: 図1 単相の負荷と電力計の模型 (電圧コイルは電源側)
parts:
  V1: sine 1,2 1,6 1 l=$\mathrm{W1}$
  RP: resistor 4,2 4,6 2.2k l=$\mathrm{R_P}$
  RC: resistor 8,6 6,6 10 i=I l=$\mathrm{R_C}$
  RL: resistor 9,2 9,4 100
  C1: capacitor 9,4 9,6 1u
  G1: ground 1,6
wires:
  - 1,2 -- 4,2 -- 9,2
  - 1,6 -- 4,6 -- 6,6
  - 8,6 -- 9,6
notes:
  - text 1,1 blue: A (CH1)
  - text 9.5,6 blue: B (CH2)
  - box 3,1 8.5,6.5 orange
  - text 5,1 orange: 電力計の模型
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/05-wattmeter-connection.svg)

- 負荷は R_L (100 Ω) と C1 (1 µF) の直列。1 kHz で X_C = 159 Ω、|Z| = 188 Ω、力率 0.53 (進み)
- R_C (10 Ω) が電流コイルの模型で、戻りの線 (GND の側) に入れた。B の電圧 (CH2) ÷ 10 Ω が
  電流コイルの電流 i。R_P (2.2 kΩ) が電圧コイルの模型
- 図は**電源側** (R_P の下の端が GND、R_C の手前)。**負荷側にするには、R_P の下の端を B に
  つなぎ替える** (R_P の電流も R_C を通る)
- 電力計の読みは AD の Math で出す。電源側は A の電圧 × i (C1 × C2 / 10)、負荷側は
  電圧コイルの電圧 (A − B) × i ((C1 − C2) × C2 / 10)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RL: resistor c5 c10 100
  C1: capacitor/film c12 c15 1u
  RC: resistor c17 c21 10
  RP: resistor h5 h10 2k2
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 yellow [h10]
  - AD.1- -- -t9 black
  - b10 -- b12 green
  - b15 -- b17 green
  - AD.2+ -- a15 blue
  - AD.2- -- -t19 black
  - a21 -- -t21 black
  - e5 -- f5 yellow
  - j10 -- -b10 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/breadboard/05-wattmeter-connection.svg)

- 5 列が A (W1 と CH1)。R_L (5〜10 列)、C1 (12〜15 列)、R_C (17〜21 列) の順に直列にし、
  21 列を GND のレールへ。15 列が B で CH2 (2+)
- R_P (2.2 kΩ) は下の段 (h5〜h10)。5 列から黄色の線で溝を渡り、10 列を下の GND のレールへ (電源側)。
  下と上の GND のレールは 28 列の黒い線でつなぐ
- **負荷側**は、j10 から下のレールへの黒い線を外し、10 列の下の段から 15 列 (B) へ線を渡す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Offset 0 V |
| Scope | CH1 = A (500 mV/div)、CH2 = B (20 mV/div)。Time base 200 µs/div。Average を 16 回 |
| Math (電源側) | M1 = C1 × C2 / 10 (単位 W)。Measure で M1 の Average が電力計の読み |
| Math (負荷側) | M1 = (C1 − C2) × C2 / 10 |
| Measure | CH1・CH2 の Amplitude、CH1 に対する CH2 の Phase |

Wavegen の電流は最大 5.4 mA (R_P の分を含む) で、この本の目安 10 mA に収まる。

```scope
title: 図3 電源側 — 電流 (CH2) は 55° 進み、読み (Math の Avg) は 1.47 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 51.7mV phase 55.3deg, range: 20mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 2mW/div, position: -2div}
measure: [vmax, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/scope/05-wattmeter-connection-1.svg)

```scope
title: 図4 負荷側 — 電流コイルに R_P の電流も入り、読み (Math の Avg) は 1.54 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 53.9mV phase 51.4deg, range: 20mV/div}
math: {expr: (ch1 - ch2) * ch2 / 10, unit: W, range: 2mW/div, position: -2div}
measure: [vmax, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/scope/05-wattmeter-connection-2.svg)

CH2 は 20 mV/div、CH1 は 500 mV/div と V/div を分けた (電流の電圧は数十 mV)。赤の線が
瞬時電力で、2 倍の周波数で揺れる。一瞬だけ負になる所は、C1 が電源へエネルギーを返している。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。電流コイルの模型 R_C を
GND の側に置いたので、電流は CH2 の 1 本で読める。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Sine、1 kHz、**2 Vpp** (AD の Amplitude 1 V は山の高さ)、Offset 0 V、出力は High-Z |
| 1+ | CH1 の先端を 5 列 (A)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 15 列 (B)、グランドクリップを GND のレール |

- FG の 50 Ω で A の電圧が下がる (約 184 Ω の負荷で 0.84 V、計算値)。**CH1 の振幅が 1.00 V になるまで
  FG の振幅を上げれば**表がそのまま使える (約 2.4 Vpp)
- 掛け算の Math が無い機種は、CH1 と CH2 の RMS と位相差 θ から P = V I cos θ を出す。負荷側の
  電圧コイルの電圧は CH1 − CH2 (Math の引き算。差は振れの 95 % あり 8 bit でも埋もれない) で、
  その RMS と位相を使う

## 見るべき値

計算値。負荷で消える本当の電力は R_L の I² R (C1 は消費しない)。

| つなぎ方 | 電流 (CH2 ÷ 10 Ω) の山 | 位相 (CH1 に対して) | 電力計の読み (Math の Avg) | 負荷の本当の電力 | 誤差 |
| --- | --- | --- | --- | --- | --- |
| 電源側 | 5.17 mA | 55.3° 進み | 1.47 mW | 1.34 mW | +10 % (= I² R_C の 0.13 mW) |
| 負荷側 | 5.39 mA | 51.4° 進み | 1.54 mW | 1.32 mW | +16 % (= V² / R_P の 0.21 mW) |

- 電源側の誤差の割合は R_C / R_L = 10 ÷ 100 = 10 % で決まる (電流によらない)
- 負荷側の誤差の割合は |Z|² / (R_L R_P) = 188² ÷ (100 × 2200) = 16 %

分かること:

- **電力計は V × I ではなく V I cos θ を指す。** 電圧 0.71 V・電流 3.65 mA (実効値) の積は 2.6 mW だが、
  力率 0.53 を掛けた 1.3 mW しか消費していない
- どちらのつなぎ方でも、計器のコイルが消費する電力が読みに足される。負荷のインピーダンスが
  小さい (電流が大きい) ときは負荷側、大きいときは電源側が有利 (7-3 と同じ)。実物の電力計は
  R_C が 0.1 Ω 前後、R_P が数 kΩ〜数十 kΩ で、差は小さい
- 瞬時電力は 2 倍の周波数で脈動し、平均が P。三相なら 3 相の和が一定になる (4 章)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope・Math の節)。
