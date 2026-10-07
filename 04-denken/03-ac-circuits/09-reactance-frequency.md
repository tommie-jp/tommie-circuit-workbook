---
book: denken
chapter: 3
id: 3-9
title: リアクタンスの周波数特性 — X_L は f に比例、X_C は反比例
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-9 リアクタンスの周波数特性 — X_L は f に比例、X_C は反比例

コイルの「交流の抵抗」(誘導リアクタンス X_L) は周波数に比例して大きくなり、
コンデンサの容量リアクタンス X_C は周波数に反比例して小さくなる。電験の計算で
いちばん使う 2 つの式を、周波数を 500 Hz〜8 kHz の 5 点で変えて測る。部品の電圧を
電流で割れば、その周波数のリアクタンスが出る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| X_L = 2πfL | 誘導リアクタンス。f を 2 倍にすると 2 倍 |
| X_C = 1 / (2πfC) | 容量リアクタンス。f を 2 倍にすると 1/2 |
| X = V_X / I | 部品の電圧の振幅を電流の振幅で割ったもの |
| f = 1 / (2π√(LC)) | X_L と X_C が等しくなる周波数 (3-5 の共振周波数と同じ式) |

## 回路図

```circuit
title: 図1 リアクタンスを測る (1 回目 L1、2 回目 C1)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine 1,3 1,7 l=$\mathrm{W1}$
  L1: inductor 3,3 7,3 10m
  M1: voltmeter 3,1 7,1 l=$\mathrm{CH1}$
  Rs: resistor 9,3 9,7 100 i=I
  M2: voltmeter 11,3 11,7 l=$\mathrm{CH2}$
  G1: ground 1,7
wires:
  - 1,3 -- 3,3
  - 3,1 -- 3,3
  - 7,1 -- 7,3
  - 7,3 -- 9,3 -- 11,3
  - 1,7 -- 9,7 -- 11,7
notes:
  - text 2,5 blue: 2 回目は L1 を C1 (1 µF) に替える
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/09-reactance-frequency.svg)

- V1 は AD の波形発生器 W1。CH1 は測る部品 (L1 か C1) の両端 (差動)、CH2 は Rs の上 (GND 基準)。
  CH2 ÷ 100 Ω が電流 I
- 1 回目は L1 (10 mH)、2 回目は同じ穴に C1 (1 µF) を挿して、同じ 5 つの周波数で測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (1 回目 L1)
board: half
parts:
  L1: inductor/axial c5 c12 10m
  Rs: resistor d12 d17 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, "2-", W1, "1+", "1-", "2+"]
wires:
  - AD.GND -- -t2 black
  - AD.2- -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- b12 green [h10]
  - AD.2+ -- a12 blue
  - a17 -- -t17 black
notes:
  - text: 2 回目は L1 を抜き、C1 (1 µF のフィルムコンデンサ) を同じ c5–c12 に挿す
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/09-reactance-frequency.svg)

- 5 列が W1、12 列が L1 と Rs のつなぎ目、17 列が GND 側 (黒い線で GND のレールへ)
- CH1 は 1+ を 5 列、1− を 12 列に挿して L1 の両端を差動で読む。**1− を GND につながない**
  (つなぐと Rs が短絡される)。CH2 は 2+ を 12 列、2− を GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、Amplitude 0.5 V、Offset 0 V。周波数を 500 Hz・1 kHz・2 kHz・4 kHz・8 kHz と変える |
| Scope | CH1 = 部品の電圧 V_X (差動)、CH2 = Rs の電圧 (GND 基準)。どちらも 200 mV/div、Average を 16 回。Time は 1 画面に 2 周期ほど (1 kHz なら 200 µs/div) |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

**X = CH1 の振幅 ÷ (CH2 の振幅 ÷ 100 Ω)。** 電流の最大は 8 kHz の C1 の 4.9 mA で、
この本の目安 10 mA (0-1) に収まる。

1 kHz の 2 つの画面。L1 では電流 (CH2) が電圧 (CH1) より 90° 遅れ、C1 では 90° 進む。

```scope
title: 図3 L1、1 kHz — 電流 (CH2) は V_L (CH1) より 90° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.266V, range: 200mV/div}
ch2: {wave: sine 1kHz 0.423V phase -90deg, range: 200mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/09-reactance-frequency-1.svg)

```scope
title: 図4 C1、1 kHz — 電流 (CH2) は V_C (CH1) より 90° 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.423V, range: 200mV/div}
ch2: {wave: sine 1kHz 0.266V phase 90deg, range: 200mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/09-reactance-frequency-2.svg)

### オシロスコープと発振器

AD の CH1 は部品の両端を差動で挟む (1− が 12 列)。汎用オシロのグランドクリップは大地につながって
いるので、12 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。部品の電圧は振れの 3〜10 割あり
8 bit でも埋もれないので、**回路はそのままで 2 本の先端を当て、V_X を Math の CH1 − CH2 で引く**。
2 ch はこれで使い切る。

- W1 は FG の OUT (High-Z)。振幅 0.5 V は、Vpp で入れる機種なら 1 Vpp
- CH1 の先端は 5 列 (FG の出力)、CH2 の先端は 12 列 (Rs の上)。グランドクリップは 2 本とも GND のレール。
  ブレッドボードの部品は図2 のまま動かさない
- V_X は Math の CH1 − CH2 の振幅。電流は CH2 ÷ 100 Ω で AD と同じ
- Math の波形に Phase を当てられない機種でも、**X は振幅の比だけで出る**ので困らない
- FG の出力の 50 Ω で電流は表より下がる (500 Hz の L1 で 4.77 → 3.26 mA、計算値)。ただし X は
  V_X と I の比なので、**リアクタンスの値は変わらない**。振幅の設定を合わせ直さなくてよい

## 見るべき値

計算値 (L1 = 10 mH、C1 = 1 µF、Rs = 100 Ω、W1 の振幅 0.5 V)。
電流 = CH2 ÷ 100 Ω、X = CH1 ÷ 電流。

| 周波数 | X_L = 2πfL | L1 の CH1 (V_L) | L1 の CH2 | X_C = 1/(2πfC) | C1 の CH1 (V_C) | C1 の CH2 |
| --- | --- | --- | --- | --- | --- | --- |
| 500 Hz | 31.4 Ω | 0.150 V | 0.477 V | 318 Ω | 0.477 V | 0.150 V |
| 1 kHz | 62.8 Ω | 0.266 V | 0.423 V | 159 Ω | 0.423 V | 0.266 V |
| 2 kHz | 126 Ω | 0.391 V | 0.311 V | 79.6 Ω | 0.311 V | 0.391 V |
| 4 kHz | 251 Ω | 0.465 V | 0.185 V | 39.8 Ω | 0.185 V | 0.465 V |
| 8 kHz | 503 Ω | 0.490 V | 0.098 V | 19.9 Ω | 0.098 V | 0.490 V |

CH1 に対する CH2 の位相は、L1 で −90° (電流が遅れる)、C1 で +90° (電流が進む)。

```graph
title: 図5 X_L は右上がり、X_C は右下がり。1.59 kHz で交わる (両対数)
x: 周波数 Hz log 300..10k
y: リアクタンス Ω log 10..1k
lines:
  X_L (10 mH) Ω: 2*pi*x*10m
  X_C (1 µF) Ω: 1/(2*pi*x*1u)
notes:
  - mark 500
  - mark 1.59k
  - mark 8k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/graph/09-reactance-frequency.svg)

分かること:

- **X_L は周波数に比例、X_C は反比例する。** 周波数を 2 倍にするたびに X_L は 2 倍、
  X_C は半分。両対数のグラフでは傾き +1 と −1 の直線になる
- **2 本は f = 1 / (2π√(LC)) ≈ 1.59 kHz で交わり、どちらも 100 Ω。** 直列にすれば打ち消し合う
  周波数で、3-5 の共振と同じ式になる
- 表では、同じ周波数の L1 の CH1 と C1 の CH2 が同じ数になる。どの周波数でも
  X_L × X_C = L / C = 10000 Ω² で、これが Rs² (100 Ω の 2 乗) に等しくなる値を選んだからだ。
  X_L と X_C は周波数について逆数の関係にある
- 10 mH のコイルは巻線抵抗 r (数 Ω〜数十 Ω) を持つので、CH1 ÷ 電流は √(r² + X_L²) になる。
  低い周波数ほど r の割合が大きい。**X_L = (CH1 ÷ 電流) × sin φ** (φ は電流に対する V_L の位相)
  とすると r の分を除ける。φ が 90° より小さく出るのが r のしるし

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
