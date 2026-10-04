---
book: denken
chapter: 3
id: 3-6
title: 有効電力・無効電力・皮相電力と力率
tier: 50
source: 自作
board: BB
---

# 3-6 有効電力・無効電力・皮相電力と力率

交流の電力には 3 つの顔がある。**実際に仕事をする有効電力 P**、
**行ったり来たりするだけで仕事をしない無効電力 Q**、**その両方を合わせた
大きさの皮相電力 S**。3 つの関係を、遅れ力率の負荷 (抵抗 + コイル) で
実測する。3-7 の力率改善の土台になる回路。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| cos θ = R / √(R² + X_L²) | 力率 (遅れ)。負荷の抵抗とリアクタンスの比で決まる |
| P = V I cos θ | 有効電力。実際に熱として消費される分 |
| Q = V I sin θ | 無効電力。コイルと電源の間を往復するだけの分 |
| S = V I = √(P² + Q²) | 皮相電力。P と Q のベクトル和の大きさ |

## 回路図

```circuit
title: 図1 遅れ力率の負荷 (R1 + L1)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c4 10 i=I
  M2: voltmeter a1 a4 l=$\mathrm{CH2}$
  M1: voltmeter c6 g6 l=$\mathrm{CH1}$
  R1: resistor c8 e8 47
  L1: inductor e8 g8 10m
  G1: ground g6
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c6 -- c8
  - g1 -- g6 -- g8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/06-power-triangle-1.svg)

- V1 は AD の波形発生器 W1。Rs (10 Ω) は線電流 I を測るシャント。
  CH2 は Rs の両端 (差動)、CH1 は受電端 (R1 + L1) の電圧
- R1 + L1 が遅れ力率の負荷。3-7 ではこの負荷にコンデンサを並列に足す

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rs: resistor c5 c10 10
  R1: resistor d10 d15 47
  L1: inductor/axial c15 c20 10m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "2+", "1+", "2-", "1-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.2+ -- a5 blue
  - AD.1+ -- b10 orange [h-10]
  - AD.2- -- a10 white
  - AD.1- -- -t12 black
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/06-power-triangle.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V |
| Scope | CH1 = 受電端の電圧、CH2 = Rs の電圧 (= 10 Ω × 電流)。Average を 16 回 |
| Math | M1 = C1 × C2 / 10 (瞬時電力 p、単位 W)。Measure で M1 の Average が有効電力 P |
| Measure | CH1・CH2 の RMS、CH1 に対する CH2 の Phase (位相差 θ。cos θ が力率) |

**電流の上限**: AD3 の波形発生器は 30 mA まで (歪みなく出せる上限。40 mA でハードウェアの
保護が働く)。この回路の線電流は最大値で 5.9 mA で、この本の目安 10 mA (0-1) にも収まる。

電流 (CH2) は数十 mV なので、CH1 と違う V/div にしてある。赤の線は Math の瞬時電力 p (単位 W)。

```scope
title: 図3 線電流 (CH2、20 mV/div) は 53° 遅れ、瞬時電力 (Math) の平均が P
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.462V, range: 200mV/div}
ch2: {wave: sine 1kHz 58.9mV phase -53.2deg, range: 20mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 500uW/div, position: -2div}
measure: [vmax, rms, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/06-power-triangle.svg)

MATH の Avg (815 µW) が有効電力 P。p は電源の 2 倍の周波数で振れ、谷のあたりで負になる —
コイルが蓄えた分を電源へ返す時間で、これが無効電力 Q の往復にあたる。

### オシロスコープと発振器

AD の CH2 は Rs の両端を差動で挟む (2− が 10 列)。汎用オシロのグランドクリップは大地につながって
いるので、10 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。Rs の電圧は最大 59 mV と小さく、
CH1 − CH2 の引き算では 8 bit の分解能に埋もれるので、0-3 と同じく **Rs を GND 側 (戻りの線) へ移す**
(図4)。Rs は戻りの線に入っても、線路の抵抗の役はそのまま。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 i1 l=$\mathrm{FG}$
  M1: voltmeter c3 i3 l=$\mathrm{CH1}$
  R1: resistor c5 e5 47
  L1: inductor e5 g5 10m
  Rs: resistor g7 i7 10 i=I
  M2: voltmeter g9 i9 l=$\mathrm{CH2}$
  G1: ground i1
wires:
  - c1 -- c3 -- c5
  - g5 -- g7 -- g9
  - i1 -- i3 -- i7 -- i9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/06-power-triangle-2.svg)

- W1 は FG の OUT (High-Z)。CH1 の先端は FG の出力 (負荷の上)、CH2 の先端は Rs の上、
  グランドクリップは 2 本とも GND
- ブレッドボードは図2 から、Rs を 5〜10 列から抜いて FG の芯を 10 列へ挿す。20 列から GND のレールへの
  黒い線を外し、Rs を 20〜25 列 (d20–d25) に挿して、25 列から GND のレールへ黒い線を渡す。
  CH1 の先端は 10 列、CH2 の先端は 20 列
- CH1 は負荷と Rs を合わせた電圧になる。受電端の電圧は Math の CH1 − CH2
- 有効電力: Math の C1 × C2 / 10 の平均は、負荷と Rs を合わせた電力 0.99 mW になる。
  Rs の損失 (CH2 の RMS² ÷ 10 Ω = 0.17 mW) を引くと負荷の P = 0.82 mW (計算値)。掛け算の無い機種は、
  CH1 と CH2 の RMS と位相差から P = V I cos φ を出して、同じく Rs の損失を引く
- CH1 と CH2 の位相差 φ は Rs を含んだ角度で 48° (cos φ = 0.67)。負荷の力率 0.60 は
  cos θ = P / (V I) で出す。V は Math (CH1 − CH2) の RMS (計算値)
- FG の出力の 50 Ω で、振幅 0.5 V の設定のままだと線電流は 4.0 mA に下がる (計算値)。
  **CH1 の振幅が 0.50 V になるまで FG の振幅を上げる** (設定は約 0.73 V、Vpp で入れる機種なら 1.46 Vpp)。
  そうすれば見るべき値の表がそのまま使える

## 見るべき値

計算値。10 mH の小さなコイルは巻線抵抗 (数 Ω〜数十 Ω) を持ち、その分
R が大きく見えて力率は計算より少し良くなる。巻線抵抗をテスターで測り、
R1 に足して計算し直すとよい。

| 測る所 | 期待する値 |
| --- | --- |
| X_L = 2πfL | 62.8 Ω |
| 力率 cos θ = R1 / √(R1² + X_L²) | 0.60 (遅れ) |
| 線電流の最大値 (CH2 ÷ 10 Ω) | 5.9 mA |
| 受電端の電圧の最大値 (CH1) | 0.462 V |
| 負荷の有効電力 P | 0.82 mW |
| 無効電力 Q | 1.09 mW |
| 皮相電力 S = √(P² + Q²) | 1.36 mW |

分かること:

- **P・Q・S は直角三角形の関係。** P が底辺、Q が高さ、S が斜辺
  (力率 cos θ = P / S)
- **力率が 1 に近いほど、同じ皮相電力 (見かけの容量) でより多くの有効電力を
  運べる。** 力率が低いと、線路や発電設備の容量を無駄に使うことになる
- コイルを抵抗だけの負荷に替えると (X_L = 0)、cos θ = 1、Q = 0 になり、
  P = S になることも確かめられる
- この負荷に並列にコンデンサを足すと、線電流が減って力率が改善する
  (3-7 で確かめる)

## 出典

自作。
