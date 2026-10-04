---
book: circuits
chapter: 2
id: 2-1
title: トランジスタスイッチ (LED)
tier: 50
source: 自作
board: BB
---

# 2-1 トランジスタスイッチ (LED)

トランジスタは**小さい電流で大きい電流を制御する**部品。足は 3 本で、ベース (B)・
コレクタ (C)・エミッタ (E) と呼ぶ。ベースからエミッタへわずかな電流を流すと、
コレクタからエミッタへ大きな電流が流れる。この題の 2SC1815 は NPN 形で、ベースをエミッタより
約 0.7 V (ベース-エミッタ間の電圧 V<sub>BE</sub>) 高くすると電流が流れ始める。ベースを動かすのは、電池 3 本 (4.5V) や
USB の 5V のような小さな電圧で足りる。

この題では、ベースに入れる電圧を 0 V と 5 V で切り替えて LED を点けたり消したりし、
トランジスタをスイッチとして使う。マイコンの出力のような弱い信号で LED やリレーを
入り切りするときの、いちばん基本の回路である。

## 回路図

```circuit
title: 図1 NPN トランジスタで LED をスイッチする (W1 で入れ、CH2 と CH1 で比べる)
parts:
  VCC: vcc b9 5V
  R1: resistor b9 d9 330
  D1: led d9 f9
  Q1: npn g9
  RB: resistor g6 g8 10k
  W1: square g2 i2 l=$\mathrm{W1}$
  G1: ground i2
  M2: voltmeter g4 i4 l=$\mathrm{CH2}$
  G3: ground i4
  G2: ground h9
  M1: voltmeter f11 h11 l=$\mathrm{CH1}$
  G4: ground h11
wires:
  - g2 -- g4 -- g6
  - g8 -- Q1.B
  - f9 -- Q1.C
  - Q1.E -- h9
  - f9 -- f11
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/01-transistor-switch.svg)

+5V は Analog Discovery の電源出力 V+ (WaveForms の Supplies で 5 V にして入れる)。
入力はスイッチの代わりに W1 (Analog Discovery の波形発生器。1-3 で使った) の 0 V / 5 V の方形波で入れる。
W1 が 5V のときベースに電流が流れ、トランジスタが**飽和**して LED が光る。飽和とは、ベース電流を
十分に流した結果、コレクタ-エミッタ間の電圧が 0.2 V ほどまで下がり、閉じたスイッチと同じになった状態をいう。
W1 を 0V にすると LED は消える。CH2 は入力 (`RB` の左端)、CH1 はコレクタ (LED のカソード) の電圧を見る (図1)。

- ベース電流: I<sub>B</sub> = (5 − 0.7) / 10kΩ ≈ **0.43 mA**
- コレクタ電流 (LED): I<sub>C</sub> = (5 − 0.2 − 2.0) / 330Ω ≈ **8.5 mA**
  (飽和したときの C-E 間電圧 V<sub>CE(sat)</sub> ≈ 0.2V、LED の順方向電圧 V<sub>F</sub> ≈ 2.0V (1-4 で見た) として計算)
- I<sub>C</sub> / I<sub>B</sub> ≈ 20 倍。2SC1815 の hFE (直流の電流増幅率 I<sub>C</sub> / I<sub>B</sub>。0-5 で見たとおり 70〜700) より
  ずっと小さいので、hFE が低い個体でも確実に飽和する (スイッチとして使うときの基本)

## 実体配線図

```breadboard
title: 図2 トランジスタスイッチ (W1 と CH2 を入力へ、CH1 をコレクタへ)
# 上の + レール = +5V (AD の V+)、上の − レール = GND (下のレールは使わない)
board: half
parts:
  R1: resistor b5 b11 330
  D1: led c11(A) c13(K) red
  Q1: transistor e12(B) e13(C) e14(E) 2SC1815
  RB: resistor b12 b17 10k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+, 2+, 2-, W1]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1- -- -t11 black
  - AD.1+ -- a13 orange
  - AD.2+ -- a15 blue
  - e15 -- e17 blue
  - AD.2- -- -t16 black
  - AD.W1 -- a17 yellow
  - +t5 -- a5 red
  - a14 -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/01-transistor-switch.svg)

図2 のとおり、部品はすべて上半分に挿し、GND はすべて上の − レールに取る (下のレールは使わない)。
5V は Analog Discovery の V+ (赤) から上の + レールへ。

- **コレクタ (列 13)**: `D1` のカソードと `Q1` の C が同じ列。CH1 の 1+ (橙) を `a13` に挿す
- **ベース (列 12)**: `RB` の左端 (`b12`) が Q1 の B と同じ列。線は要らない
- **エミッタ (列 14)**: 黒線で `a14` から − レールへ直接
- **入力 (列 17)**: `RB` の右端 (`b17`)。W1 (黄) を `a17` に、CH2 の 2+ (青) は `a15` に挿して `e15`–`e17` で渡す
- AD の GND・1−・2− (黒) は上の − レールへ

`Q1` は平らな面を見て左から E・C・B (2SC1815 の実物の並び)。図は B・C・E の
順に挿すので、**平らな面を奥に向けて**挿す。

## オシロで見る

W1 を 100 Hz・0 V / 5 V の方形波にし (目には半分の明るさで点きっぱなしに見える。点滅を目で見たいときは 1 Hz に下げる)、CH2 (入力) と CH1 (コレクタ) を同じ 1 V/div で重ねる。

```scope
title: 図3 入力 (CH2) とコレクタ (CH1) — 入力が 5 V の間だけコレクタが 0.2 V に落ちる
time: 2ms/div
trigger: ch2 rising 2.5V
ch1: {wave: square 100Hz 1.65V offset 1.85V phase 180deg, range: 1V/div, position: -3div}
ch2: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/01-transistor-switch.svg)

図3 の CH1 は CH2 を裏返した形になる。エミッタを GND につなぐこの形 (エミッタ接地) のスイッチは、入力と出力が逆向きに動く。入力が 5 V の間、コレクタは
V<sub>CE(sat)</sub> ≈ **0.2 V** まで落ち、LED には (5 − 0.2 − 2.0) / 330 Ω ≈ 8.5 mA が流れる。
入力が 0 V の間は LED にほとんど電流が流れないので、コレクタは 5 V から LED の立ち上がり手前の
約 1.5 V を引いた**約 3.5 V** に留まる (5 V までは上がらない)。
両端の値は Measurements の Max・Min で読む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 330 Ω |
| RB | 抵抗 (1/4 W) | 10 kΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| W1 = 5V のときの LED の電流 (R1 の両端 ÷ 330Ω) | 約 8.5 mA | 計算値と一致すれば飽和で動いている証拠 |
| W1 = 5V のときの Q1 の C-E 間電圧 | 約 0.2 V (V<sub>CE(sat)</sub>) | 飽和すると C-E 間には小さい電圧しか残らない |
| W1 = 0V のときのコレクタ (CH1) | 約 3.5 V | LED にほぼ電流が流れず、V<sub>F</sub> の手前 (約 1.5 V) だけ下がる |
| W1 = 0V のときの LED | 消える | ベース電流が無いとコレクタ電流も流れない |
| ベース抵抗を 100kΩ に替えたとき | hFE が 200 を超える個体 (GR ランクなど) なら点いたまま。O ランク (70〜140) では飽和が外れて暗くなる | I<sub>B</sub> ≈ 43 µA で 8.5 mA を流すには hFE 200 が要る (計算値) |

## 出典

自作。
