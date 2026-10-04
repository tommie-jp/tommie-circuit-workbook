---
book: denken
chapter: 9
id: 9-2
title: 直流モータを発電機に — 回す速さと起電力
tier: 50
source: 自作
board: BB
---

# 9-2 直流モータを発電機に — 回す速さと起電力

9-1 と同じ小型 DC モータを、今度は電源を外して**指で軸を回し発電機として使う**。
出力には整流子のブラシによる細かいリップルが乗り、その周波数が回す速さそのものを
表す。リップルの周波数と出力電圧を同時に見て、起電力が回転数に比例することを
量として確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| E = Ke × N | 起電力は回転数 N に比例する (9-1 と同じ式) |
| f_ripple = k × n | 整流子のリップル周波数。k は 1 回転あたりの切り替わりの数 (この実験では 6)、n は回転数 [rev/s] |

このモータは 3 極の整流子を持つ。極 (片) の数が奇数なら、2 本のブラシが片の境目を別々の時刻にまたぐので、
1 回転で 2 × 3 = 6 回の切り替わりがある (目安。モータの作りで違うことがある)。リップルの
周波数を測れば n = f_ripple / 6 として回転数が分かる。

## 回路図

```circuit
title: 図1 モータを発電機にして開放電圧を見る
style:
  standard: jis
parts:
  M1: motor c3 c7
  M2: voltmeter a3 a7 l=$\mathrm{CH1}$
  G1: ground c7
wires:
  - a3 |- c3
  - a7 -- c7
notes:
  - text d5: "指で軸を回す (発電機として使う)"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/02-motor-as-generator.svg)

- 電源は無く、モータの軸を指で回すことで起電力が生じる
- CH1 はモータの両端をそのまま読む (開放電圧。負荷はつながない)

## 実体配線図

```breadboard
title: 図2 ブレッドボードとモータ (発電機として)
board: half
parts:
  MOT:
    type: device
    at: bottom
    label: DCモータ
    pins: ["+", "-"]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: ["1+", "1-"]
wires:
  - MOT.+ -- j5 orange
  - MOT.- -- j8 black
  - AD.1+ -- f5 blue
  - AD.1- -- f8 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/breadboard/02-motor-as-generator.svg)

- MOT (モータ) だけをブレッドボードの外の機器として描く。電源も他の部品も無い
- AD の CH1 (1+・1−) を下のブロックの 5 列・8 列 (f 行) につなぎ、モータの両端をそのまま読む。
  Wavegen も Supplies も使わない (電源は無く、指で回す)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 = モータの両端 (V)。Time/div は 5〜20 ms 程度 (リップルの山が見える範囲) |
| Measure | CH1 の Frequency (リップルの周波数 f_ripple)、Average や Peak-Peak (振幅の目安) |

```scope
title: 図3 Offset で直流を打ち消すと、300 rpm のリップルは 30 Hz (振幅は目安)
time: 10ms/div
trigger: ch1 rising 0.2V
ch1: {wave: sine 30Hz 0.02V offset 0.2V, range: 10mV/div, position: -20div}
measure: [freq, vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/scope/02-motor-as-generator.svg)

図は遅く回した場合 (表の 300 rpm) のリップルを拡大したもの。AD3 本体のピンの入力は DC 結合だけなので、CH1 の Offset を −0.2 V にして
E の平均 0.20 V を画面の中央に寄せ、10 mV/div に上げた。E の平均は Measurements の Avg (0.20 V) で読める。
速く回したときは E に合わせて Offset を −0.8 V に変える (0.5 V/div 以下の目盛で Offset が動かせるのは ±2.5 V まで)。
速く回した場合 (1200 rpm) は周波数が 120 Hz、E が 0.80 V に変わる。リップルの振幅 (図では 0.04 Vpp) は仮の値で、モータの作りで違う。

指で軸を回すのは難しいので、遅く回す・速く回すの 2 段階で十分。**同じ向きに
回し続ける** (向きを変えると極性が反転する)。

### オシロスコープと発振器

GND 基準の題で、測る所は図1 のまま。1+ → CH1 の先端を 5 列、1− → グランドクリップを 8 列
(モータの −、図1 の GND) に当てる ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md))。
電源も発振器も使わない。モータは大地から浮いているので、クリップで − が大地につながっても回路は変わらない。

- リップルの周波数は、CH1 を AC 結合にして 20 mV/div ほどに上げると山がはっきりし、Measure の
  Frequency が拾いやすい。AC 結合は数 Hz より下を削るので、E と振幅の比は DC 結合に戻して Mean と
  Peak-Peak で読む

## 見るべき値

計算値。この実験の Ke ≒ 0.67 mV/rpm、整流子は 3 極 (1 回転で 6 回の切り替わり) とした。

| 回し方 | 回転数の目安 | f_ripple (計算値) | E (計算値) | 分かること |
| --- | --- | --- | --- | --- |
| 遅く回す | 300 rpm (5 rev/s) | 30 Hz | 0.20 V | 遅い分、電圧もリップルの周波数も低い |
| 速く回す | 1200 rpm (20 rev/s) | 120 Hz | 0.80 V | 回転数が 4 倍になると、電圧も周波数も約 4 倍 |

**リップルの周波数が上がるのと同時に、振幅も同じ比率で大きくなる。** これが
E = Ke × N の直接の証拠になる。9-1 では電源電圧を手掛かりに間接的に確かめたが、
ここでは回転数そのもの (リップル周波数) と起電力を同時に測れる。

## 出典

自作。
