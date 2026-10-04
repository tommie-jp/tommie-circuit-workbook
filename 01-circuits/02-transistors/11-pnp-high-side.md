---
book: circuits
chapter: 2
id: 2-11
title: PNP のハイサイドスイッチ
tier: 100
board: BB
source: 自作
---

# 2-11 PNP のハイサイドスイッチ

2-1 の NPN スイッチは負荷の**GND 側**に割り込む「ローサイド」だった。
PNP (2-10 で見た、NPN と向きが逆のトランジスタ) は逆に、負荷の**電源側**に割り込む
「ハイサイド」スイッチに向く。負荷の片方を GND につないだまま、電源側で入り切りできる。

PNP は「エミッタよりベースを下げる」と導通する。ロジック信号 (0V/5V) でベースを直接動かすと、
0V で点いて 5V で消える逆の動きになり、負荷の電源がロジックより高い (12V など) ときは 5V でも
切れない。そこで間に NPN (`Q2`) を 1 石はさみ、NPN が導通したときだけ PNP のベースを引き下げる。
この題では W1 の方形波で入り切りし、入力とコレクタの電圧が同じ向きに動くことをオシロで確かめる。

## 回路図

```circuit
title: 図1 PNP ハイサイドスイッチ (W1 で入れ、CH2 で入力、CH1 でコレクタを見る)
parts:
  VCC: vcc b4 5V
  RB1: resistor b7 d7 10k
  RB2: resistor d7 f7 4.7k
  Q1: pnp d9
  Q2: npn g8
  RB3: resistor g5 g7 10k
  W1: square g2 i2 l=$\mathrm{W1}$
  G0: ground i2
  M2: voltmeter g4 i4 l=$\mathrm{CH2}$
  G3: ground i4
  RL: resistor e11 e13 470
  D1: led e13 g13
  G1: ground g13
  G2: ground h8
  M1: voltmeter f10 h10 l=$\mathrm{CH1}$
  G4: ground h10
wires:
  - b4 -- b7 -- b9
  - b9 -- Q1.E
  - d7 -- Q1.B
  - f7 -| Q2.C
  - g2 -- g4 -- g5
  - g7 -- Q2.B
  - Q1.C -- e9 -- e10 -- e11
  - e10 -- f10
  - Q2.E -- h8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/11-pnp-high-side.svg)

図1 の +5V は Analog Discovery の電源出力 V+ (WaveForms の Supplies で 5 V にして入れる)。
流れるのは LED の 6 mA ほどなので V+ で足りる。ロジック入力の代わりに W1 の 0 V / 5 V の方形波を
`RB3` に入れる。CH2 は入力 (`RB3` の左端)、CH1 は `Q1` のコレクタ (負荷の上端) の電圧を GND から測る。

`Q1` (PNP) のエミッタは +5V に直結。`RB1` (10kΩ) はベースをエミッタと
同電位に保つ「切る」抵抗、`RB2` (4.7kΩ) は `Q2` (NPN) が導通したときに
`Q1` のベースを引き下げる電流を決める。ロジック入力もこの回路の電源と
同じ 5V 系とする (W1 = 0V / 5V)。

- **W1 = 0V (Q2 OFF)**: `Q2` に電流が流れないので `RB2` にも電流が流れず、
  `Q1` のベースは `RB1` を通じて +5V と同電位 → V<sub>EB</sub> = 0V → **Q1 OFF**
- **W1 = 5V (Q2 ON)**: `Q2` のベース電流 = (5−0.7)/10kΩ ≈ 0.43mA で
  `Q2` は飽和。`Q1` のベースは V<sub>EB</sub> ≈ 0.7V (導通に必要な電圧) に
  クランプされるので、V<sub>B</sub>(Q1) ≈ 5 − 0.7 = **4.3 V**
  - `RB2` に流れる電流: (4.3 − 0.2) / 4.7kΩ ≈ **0.87 mA** (Q2 の
    V<sub>CE(sat)</sub> ≈ 0.2V として計算)
  - `RB1` からベースへ流れ込む電流: (5 − 4.3) / 10kΩ ≈ 0.07mA。
    差し引き `Q1` のベース電流 I<sub>B1</sub> ≈ 0.87 − 0.07 ≈ **0.80 mA**
  - 負荷: `RL` (470Ω) + LED (V<sub>F</sub> ≈ 2.0V)。Q1 が飽和
    (V<sub>EC(sat)</sub> ≈ 0.2V) すると、コレクタ電圧 = 5 − 0.2 = 4.8V、
    I<sub>C1</sub> = (4.8 − 2.0) / 470Ω ≈ **6.0 mA**
  - 飽和に要る最小ベース電流 (hFE = 70 の最悪値でも): 6.0mA/70 ≈
    0.085mA。実際のベース電流 0.80mA はその約 **9 倍**ある。この余裕を
    オーバードライブと呼び、これだけあれば確実に飽和する

`RB2` を小さくしすぎると `Q1` のベース電流が過大になって無駄が大きく、
大きくしすぎると飽和しない — 4.7kΩ はこの回路の負荷電流 (約 6.0mA) に対して
十分なオーバードライブを残しつつ、`RB2`・`Q2` の負担を抑える値。

## 実体配線図

```breadboard
title: 図2 PNP ハイサイドスイッチ (W1 と CH2 を入力へ、CH1 をコレクタへ)
# 上の + レール = +5V (AD の V+)、上の − レール = GND (下のレールは使わない)
board: half
parts:
  RB3: resistor c4 c8 10k
  Q2: transistor e8(B) e9(C) e10(E) 2SC1815
  RB2: resistor b9 b14 4.7k
  Q1: transistor e14(B) e15(C) e16(E) 2SA1015
  RB1: resistor a14 +t14 10k
  RL: resistor b15 b21 470
  D1: led c21(A) c23(K) red
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 2+, 2-, 1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.W1 -- a4 yellow
  - AD.2+ -- a5 blue
  - e5 -- e4 blue
  - AD.2- -- -t6 black
  - a10 -- -t10 black
  - AD.1+ -- a17 orange
  - d17 -- d15 orange
  - +t16 -- a16 red
  - a23 -- -t23 black
  - AD.1- -- -t25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/11-pnp-high-side.svg)

図2 のとおり、5V は Analog Discovery の V+ (赤) から上の + レールの `+t1` へ、GND (黒) は `-t2` へ入れる。

- **Q2 (2SC1815) と Q1 (2SA1015) は上のブロックの e 行に、180 度回して挿す**。どちらも平らな面を
  見て左から E・C・B なので、回すと左から B・C・E になる (Q2 は `e8`–`e10`、Q1 は `e14`–`e16`)
- **入力 (列 4)**: W1 (黄) を `a4` に、`RB3` の左端を `c4` に。CH2 の 2+ (青) は `a5` に挿し、
  `e5`–`e4` の青線で入力の列へ渡す。`RB3` の右端 (`c8`) が Q2 のベース
- **Q2 のコレクタ (列 9)** から `RB2` (`b9`–`b14`) で Q1 のベース (列 14) へ。同じ列の `a14` から
  `RB1` を上の + レール (`+t14`) へ縦に挿す
- **Q1 のエミッタ (列 16)**: `a16` から + レールへ赤線
- **Q1 のコレクタ (列 15)**: `RL` の左端 (`b15`) と CH1 の 1+ (橙)。1+ は `a17` に挿し、`d17`–`d15` の橙線でコレクタの列へ渡す。`RL` の右端 (列 21) に
  LED のアノード、カソード (列 23) は `a23` から − レールへ黒線
- **Q2 のエミッタ (列 10)**: `a10` から − レールへ黒線
- 2− と 1− (黒) は上の − レール (`-t6` `-t25`) へ。下のレールは使わない

## オシロで見る

W1 を 100 Hz・0 V / 5 V の方形波にし (目には半分の明るさで点きっぱなしに見える。点滅を目で見たいときは 1 Hz に下げる)、
CH2 (入力) と CH1 (Q1 のコレクタ) を同じ 1 V/div で重ねる (図3)。トリガは CH2 の立ち上がり 2.5 V (Normal)。

```scope
title: 図3 入力 (CH2) とコレクタ (CH1) — 入力が 5 V の間だけコレクタが 4.8 V に上がる
time: 2ms/div
trigger: ch2 rising 2.5V
ch1: {wave: square 100Hz 2.4V offset 2.4V, range: 1V/div, position: -3div}
ch2: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/11-pnp-high-side.svg)

- CH2 は 0 V と 5 V を 100 Hz で行き来する
- CH1 は入力と**同じ向き**に動く (2-1 の NPN ローサイドは逆向きだった)。入力 5 V の間は
  Q1 が飽和してコレクタが約 4.8 V (5 − V<sub>EC(sat)</sub>)
- 入力 0 V の間は Q1 がオフで、コレクタは RL と LED を通って GND へ落ち、約 0 V になる。
  コレクタの電圧が「ある・ない」で切り替わる = 負荷の電源側を入り切りしている (ハイサイド)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RB1 | 抵抗 (1/4 W) | 10 kΩ |
| RB2 | 抵抗 (1/4 W) | 4.7 kΩ |
| RB3 | 抵抗 (1/4 W) | 10 kΩ |
| RL | 抵抗 (1/4 W) | 470 Ω |
| Q1 | PNP トランジスタ | 2SA1015 |
| Q2 | NPN トランジスタ | 2SC1815 |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | Analog Discovery の V+ (5 V) |
| W1 | ロジック入力 | Analog Discovery の W1 (0 V / 5 V の方形波、100 Hz) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| W1 = 0V のときの Q1 のベース電圧 | 約 5 V (Vcc と同じ) | RB1 が Q1 を確実に OFF にしている |
| W1 = 0V のときのコレクタ電圧 (CH1) | 約 0 V | Q1 OFF で負荷の電源側が切り離されている |
| W1 = 0V のときの LED | 消灯 | Q1 OFF で負荷に電流が流れない |
| W1 = 5V のときの Q1 のベース電圧 | 約 4.3 V | Q1 が導通 (V<sub>EB</sub> ≈ 0.7V) |
| W1 = 5V のときのコレクタ電圧 (CH1) | 約 4.8 V | Q1 が飽和 (V<sub>EC(sat)</sub> ≈ 0.2V)。入力と同じ向きに動く |
| W1 = 5V のときの LED の電流 (RL の両端 ÷ 470Ω) | 約 6.0 mA (計算値) | 十分なオーバードライブで飽和している |

## 出典

自作。
