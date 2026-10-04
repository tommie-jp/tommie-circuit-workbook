---
book: denken
chapter: 9
id: 9-5
title: トルクと電流 — 負荷を掛けると電流が増える
tier: 100
source: 自作
board: BB
---

# 9-5 トルクと電流 — 負荷を掛けると電流が増える

直流モータのトルクは電機子の電流に比例する (T = Kt × I)。軸に負荷を掛けるとモータは少し遅くなり、
逆起電力 E が下がった分だけ電流が増えて、負荷のトルクに釣り合う。
負荷には**同じモータをもう 1 台つないだ発電機**を使う。発電機の端子を抵抗 RL で閉じると、
発電機に流れる電流 I2 に比例したブレーキのトルクが軸に掛かる。RL を小さくするほど負荷が重い。
9-1・9-2 と同じ小型 DC モータを 2 台、軸どうしを継手 (シリコンチューブなど) でつないで確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| T = Kt × I | トルクは電流に比例する。Kt はトルク定数 |
| Kt = Ke (SI 単位) | トルク定数と起電力定数は同じ値。Ke = 0.67 mV/rpm = 6.4 mV/(rad/s) → Kt = 6.4 mN·m/A |
| I1 = I0 + I2 | 駆動するモータの電流 I1 は、摩擦の分 I0 と、発電機に取られるトルクの分 I2 (同じ Kt なので電流で比べられる) の和 |
| E = V − I1 × Ra | 電流が増えると E が下がり、回転数 N = E / Ke が下がる |

この題の値 (9-1・9-2 の模型): Ra ≒ 3 Ω、Ke ≒ 0.67 mV/rpm、1 台の摩擦の分の電流 15 mA (2 台なので I0 = 30 mA)。
回転数は、発電機の出力に乗る整流子のリップル (9-2、1 回転に 6 回) の周波数から n = f / 6 で読む。

## 回路図

```circuit
title: 図1 モータ M1 で発電機 M2 を回し、RL で負荷を掛ける
style:
  standard: jis
  pitch: 1.2
parts:
  B1: battery c1 g1 4.5
  M1: motor c5 e5
  Rs: resistor e5 g5 1 i=I1
  M3: voltmeter e7 g7 l=$\mathrm{CH1}$
  M2: motor c11 g11
  RL: resistor c14 g14 47 i=I2
  M4: voltmeter c16 g16 l=$\mathrm{CH2}$
  G1: ground g1
  G2: ground g16
wires:
  - c1 -- c5
  - e5 -- e7
  - g1 -- g5 -- g7
  - c11 -- c14 -- c16
  - g11 -- g14 -- g16
notes:
  - line d5f5 d10f5 blue
  - text c8 small blue: 軸を継手でつなぐ
  - text h14 small: (1 W。100・47・22 Ω に替える)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/05-torque-current.svg)

- B1 は単 3 電池 3 本 (4.5 V)。M1 (駆動) の電流 I1 は最大 0.2 A ほどになり、AD の Supplies では足りない
- Rs (1 Ω) は I1 を読むシャント。**M1 の GND 側に置く**ので、CH1 は GND 基準で Rs の電圧 (= I1 × 1 Ω) を読める
- M2 (発電機) の出力を RL で閉じる。RL の電流 I2 = CH2 ÷ RL。M2 の − を GND につないで CH2 の基準にする
  (M2 の回路は M1 の回路と電気的に別なので、1 点でつないでも電流の道は増えない)
- RL は電力が 0.5 W まで上がるので **1 W の抵抗** (酸化金属皮膜) を使う (22 Ω で 0.50 W)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (2 台のモータの軸は継手でつなぐ)
# 上の赤レール = 電池の + (4.5 V)、青レール = GND
board: half
parts:
  Rs: resistor c10 c14 1
  RL: resistor c20 c24 47
  BAT:
    type: device
    at: top
    label: 電池 3本 4.5V
    pins: ["+", "-"]
  MOT1:
    type: device
    at: top
    label: M1 駆動
    pins: ["+", "-"]
  MOT2:
    type: device
    at: top
    label: M2 発電機
    pins: ["-", "+"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [GND, 1+, 1-, 2-, 2+]
wires:
  - BAT.+ -- +t2 red
  - BAT.- -- -t3 black
  - MOT1.+ -- +t7 red
  - MOT1.- -- a10 green
  - a14 -- -t14 black
  - MOT2.+ -- a20 purple
  - MOT2.- -- -t18 black
  - a24 -- -t24 black
  - e10 -- f10 orange
  - AD.1+ -- j10 orange
  - e20 -- f20 blue
  - AD.2+ -- j20 blue
  - -t28 -- -b28 black
  - AD.GND -- -b8 black
  - AD.1- -- -b12 black
  - AD.2- -- -b16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/breadboard/05-torque-current.svg)

- M1 の + は赤レール、− は 10 列。Rs (1 Ω) が 10 列から 14 列、14 列は青レール (GND) へ
- M2 の + は 20 列、− は青レール。RL が 20 列から 24 列、24 列は青レールへ。RL は差し替える
- AD は板の下に置いた。CH1 (1+) は 10 列から溝を渡って j10、CH2 (2+) は 20 列から j20。1−・2−・GND は下の青レール。
  上下の青レールは 28 列の黒い線でつなぐ
- 2 台のモータの軸は、シリコンチューブを差し込んでつなぐ。2 台とも机にテープで固定し、軸の芯を揃える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1 = Rs の両端 (I1 = 読み ÷ 1 Ω)。CH2 = RL の両端 (I2 = 読み ÷ RL)。Time base は 2 ms/div |
| Measure | CH1・CH2 の Average。CH2 の Frequency (整流子のリップル。AC 結合にすると拾いやすい) |

RL を「開放 → 100 Ω → 47 Ω → 22 Ω」と重くしながら、そのたびに I1・I2・リップルの周波数を読む。
直流を読む題なので、画面の図は描かない (平らな線が 2 本並ぶだけになる)。回転数は CH2 のリップルの周波数で読む。

### オシロスコープと発振器

GND 基準の題で、測る所は図1 のまま ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。CH1 の先端を 10 列 (Rs の上)、
CH2 の先端を 20 列 (RL の上)、グランドクリップは 2 本とも青レール。電池も発電機も大地から浮いているので、
青レールが大地につながっても回路は変わらない。発振器は使わない。

- CH1 は 50 mV/div、CH2 は 1 V/div、どちらも DC 結合で Mean を読む。I1 の 0.03〜0.18 V は 8 bit でも 1 % ほどで読める
- リップルの周波数は CH2 を AC 結合・20 mV/div にして Frequency で読む。読んだら DC 結合に戻す
- 電池を安定化電源 (4.5 V) に替えるなら、電流制限は 2 A (起動の一瞬に 4.5 V / 4 Ω ≒ 1.1 A 流れる)

## 見るべき値

計算値。Vs = 4.5 V、Rs = 1 Ω、Ra = 3 Ω (2 台とも)、Ke = 0.67 mV/rpm、Kt = 6.4 mN·m/A、I0 = 30 mA とした。
T は発電機に掛かるブレーキのトルク (= Kt × I2)。

| RL | I2 (CH2 ÷ RL) | CH2 | T | I1 (CH1 ÷ 1 Ω) | N | リップル (6 × N / 60) |
| --- | --- | --- | --- | --- | --- | --- |
| 開放 | 0 | 4.38 V | 0 | 30.0 mA | 6540 rpm | 654 Hz |
| 100 Ω | 40.9 mA | 4.09 V | 0.26 mN·m | 70.9 mA | 6290 rpm | 629 Hz |
| 47 Ω | 81.1 mA | 3.81 V | 0.52 mN·m | 111 mA | 6050 rpm | 605 Hz |
| 22 Ω | 151 mA | 3.32 V | 0.97 mN·m | 181 mA | 5640 rpm | 564 Hz |

- **I1 はトルク (I2) に比例して増え、増えた分 (I1 − 30 mA) は I2 と等しい。** 2 台が同じ Kt なので、
  駆動の側の電流の増え方が、発電機の側で取られるトルクをそのまま表す
- 回転数は負荷を掛けても 14 % ほどしか下がらない。直流の他励・分巻のモータは「速度がほとんど変わらない」性質を持つ
  (Ra が小さいほど下がり方が小さい)
- 実物では継手の損失と、2 台の摩擦の違いで、I1 − I0 が I2 より少し大きく出る

```graph
title: 図3 負荷のトルクに比例して電流が増え、回転数は少し下がる
x: トルク mN·m 0..1
y:
  - 電流 mA 0..200
  - 回転数 rpm 0..7000
lines:
  駆動の電流 I1 mA: 30 + x / 6.4 * 1000
  回転数 rpm: (4.5 - 4 * (0.03 + x / 6.4)) / 0.00067
notes:
  - mark 0.52
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/graph/05-torque-current.svg)

## 出典

自作。
