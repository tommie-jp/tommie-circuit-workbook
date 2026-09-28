---
book: denken
chapter: 3
id: 3-12
title: 瞬時電力 — v × i の波形は 2 倍の周波数で脈打つ
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-12 瞬時電力 — v × i の波形は 2 倍の周波数で脈打つ

交流の電力は、ある瞬間の電圧 v と電流 i の積 p = v × i (瞬時電力) で考える。v と i が
どちらも周波数 f の正弦波なら、積 p は **2f で振れる波**になる。その平均が有効電力 P だ。
AD の Math で p を画面に出し、抵抗とコンデンサで形を比べる。抵抗では p は 0 と 2P の間を
振れて負にならず、コンデンサでは平均が 0 で、正と負を同じだけ往復する。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| v = Vm sin ωt、i = Im sin(ωt + φ) | 電圧と電流 (φ は電流の進み) |
| p = v i = (Vm Im / 2){cos φ − cos(2ωt + φ)} | 瞬時電力。一定の部分と、2ω で振れる部分の和 |
| P = (Vm Im / 2) cos φ = V I cos φ | 平均 (有効電力)。V・I は実効値 |
| 抵抗 (φ = 0): 0 ≦ p ≦ 2P | p は負にならない。電源から受け取るだけ |
| コンデンサ (φ = 90°): P = 0、p = ±V I | 受け取った分を 1/4 周期後に返す。振れの大きさ V I が無効電力 Q |

## 回路図

```circuit
title: 図1 瞬時電力を測る (1 回目 R1、2 回目 C1)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  R1: resistor c3 c7 150
  M1: voltmeter a3 a7 l=$\mathrm{CH1}$
  Rs: resistor c9 g9 10 i=I
  M2: voltmeter c11 g11 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3
  - a3 -- c3
  - a7 -- c7
  - c7 -- c9 -- c11
  - g1 -- g9 -- g11
notes:
  - text e2 blue: 2 回目は R1 を C1 (1 µF) に替える
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/12-instantaneous-power.svg)

- V1 は AD の波形発生器 W1。R1 (か C1) が電力を測る負荷で、CH1 はその両端 (差動) の電圧 v
- Rs (10 Ω) は電流のシャント。CH2 は Rs の上 (GND 基準) で、CH2 ÷ 10 Ω が i。
  **Math の CH1 × CH2 ÷ 10 が p** (単位 W)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (1 回目 R1)
board: half
parts:
  R1: resistor c5 c12 150
  Rs: resistor d12 d17 10
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
  - text: 2 回目は R1 を抜き、C1 (1 µF のフィルムコンデンサ) を同じ c5–c12 に挿す
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/12-instantaneous-power.svg)

- 5 列が W1、12 列が負荷と Rs のつなぎ目、17 列が GND 側 (黒い線で GND のレールへ)
- CH1 は 1+ を 5 列、1− を 12 列に挿して負荷の両端を差動で読む。**1− を GND につながない**
  (つなぐと Rs が短絡される)。CH2 は 2+ を 12 列、2− を GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V、Offset 0 V |
| Scope | CH1 = 負荷の電圧 v (差動、200 mV/div)、CH2 = Rs の電圧 (GND 基準、10 mV/div)。Average を 16 回 |
| Math | M1 = C1 × C2 / 10 (瞬時電力 p、単位 W、500 µW/div) |
| Measure | CH1・CH2 の Amplitude、CH1 に対する CH2 の Phase、M1 の Average (= P) と Frequency |

電流の振幅は 3.1 mA で、この本の目安 10 mA (0-1) に収まる。

R1 と C1 の 2 つの画面。Math (赤) の V/div と基準は 2 枚とも同じにしてある。

```scope
title: 図3 R1 — p (Math) は 2 kHz で 0〜1.46 mW を振れ、平均 0.73 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.46875V, range: 200mV/div}
ch2: {wave: sine 1kHz 31.25mV, range: 10mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 500uW/div, position: 0div}
measure: [vmax, avg, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/12-instantaneous-power-1.svg)

```scope
title: 図4 C1 — 電流 (CH2) は 90° 進み、p (Math) は ±0.78 mW で平均 0
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.499V, range: 200mV/div}
ch2: {wave: sine 1kHz 31.35mV phase 90deg, range: 10mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 500uW/div, position: 0div}
measure: [vmax, avg, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/12-instantaneous-power-2.svg)

### オシロスコープと発振器

AD の CH1 は負荷の両端を差動で挟む (1− が 12 列)。汎用オシロのグランドクリップは大地につながって
いるので、12 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。負荷の電圧は振れ (0.5 V) の 9 割以上あり
8 bit でも埋もれないので、**回路はそのままで 2 本の先端を当てる**。

- W1 は FG の OUT (High-Z)。振幅 0.5 V は、Vpp で入れる機種なら 1 Vpp
- CH1 の先端は 5 列 (FG の出力)、CH2 の先端は 12 列 (Rs の上)。グランドクリップは 2 本とも GND のレール。
  ブレッドボードの部品は図2 のまま動かさない
- 汎用オシロの Math は 1 つの式しか持てない機種が多く、(CH1 − CH2) × CH2 は書けない。
  **Math の CH1 × CH2 ÷ 10 は負荷と Rs を合わせた p** で、形は負荷の p とほぼ同じ (Rs の分は
  電流の 2 乗 × 10 Ω で、R1 のときの 1/15)。平均から Rs の損失 (CH2 の RMS² ÷ 10 Ω = 0.049 mW) を
  引くと負荷の P になる。R1 で 0.781 − 0.049 = 0.732 mW、C1 で 0.049 − 0.049 = 0 mW (計算値)
- 掛け算の無い機種は、CH1 − CH2 の RMS と CH2 の RMS と位相差から P = V I cos φ を出す
- FG の出力の 50 Ω で、振幅 0.5 V の設定のままだと電流は R1 で 2.38 mA、C1 で 2.94 mA に下がる
  (計算値)。**CH1 の振幅が 0.50 V になるまで FG の振幅を上げる** (設定は R1 で約 0.66 V、C1 で約 0.53 V)。
  そうすれば見るべき値の表がそのまま使える

## 見るべき値

計算値 (R1 = 150 Ω、C1 = 1 µF (X_C = 159 Ω)、Rs = 10 Ω、f = 1 kHz、W1 の振幅 0.5 V)。

| 測る所 | R1 (1 回目) | C1 (2 回目) |
| --- | --- | --- |
| v の振幅 (CH1) | 0.469 V | 0.499 V |
| i の振幅 (CH2 ÷ 10 Ω) | 3.125 mA (CH2 は 31.25 mV) | 3.14 mA (CH2 は 31.4 mV) |
| CH1 に対する CH2 の位相 φ | 0° | +90° (電流が進む) |
| p の周波数 | 2 kHz | 2 kHz |
| p の最大 / 最小 | 1.46 mW / 0 mW | +0.78 mW / −0.78 mW |
| p の平均 (有効電力 P) | 0.732 mW | 0 mW |
| V I (実効値の積 = 皮相電力 S) | 0.732 mW | 0.78 mW (= 無効電力 Q) |

分かること:

- **p は電源の 2 倍の周波数で脈打つ。** v と i は 1 周期に 2 回ずつ符号を変え、その積は
  1 周期に 2 回ずつ山になる
- **抵抗では p が負にならない。** 電源から受け取ったエネルギーを全部熱にする。
  平均 P は最大の半分 (= V I)
- **コンデンサでは p の平均が 0。** 1/4 周期で電荷を蓄え、次の 1/4 周期で電源へ返す。
  振れの大きさ V I が無効電力 Q (単位は var) で、線路に電流を流すのに仕事をしない
- 3-6 の R + L の負荷は、この 2 つの間。p は少しだけ負になり、平均は V I cos φ

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節、Math のチャンネル)。
