---
book: circuits
chapter: 1
id: 1-1
title: LED を点ける — 抵抗で電流を決める
tier: 50
source: 自作
board: BB
---

# 1-1 LED を点ける — 抵抗で電流を決める

LED は**流す電流**で明るさが決まる部品で、電源に直につなぐと電流が流れすぎて
壊れる。抵抗を直列に入れて電流を決める。抵抗の値を計算で決め、組んでテスターで確かめる、
という本書の進め方を、いちばん小さな回路で一通りやってみる。

## 回路図

```circuit
title: 図1 LED と電流を決める抵抗
parts:
  V1: vsource a1 c1 5
  R1: resistor a1 a3 330 i=I
  D1: led a3 c3 v=VF
  G1: ground c1
wires:
  - c1 -- c3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/01-led.svg)

LED は光っている間、両端にほぼ一定の電圧が残る。これを**順方向電圧** V<sub>F</sub> と呼び、
赤色の LED なら約 2.0 V。残りの電圧 (V − V<sub>F</sub>) が抵抗にかかるので、
抵抗の値は **R = (V − V<sub>F</sub>) / I** で決める。

- 電源 5 V、V<sub>F</sub> ≈ 2.0 V、流したい電流 10 mA なら R = (5 − 2.0) / 10 mA = 300 Ω
- ここでは手に入りやすい 330 Ω (E12 系列の値。0-4) を使う。電流は (5 − 2.0) / 330 ≈ **9.1 mA** になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤いレール = +5 V、青いレール = GND
board: half
parts:
  R1: resistor b5 b10 330
  D1: led c10(A) c11(K) red
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a11 -- -t11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/01-led.svg)

5 V の電源は Analog Discovery 3 (AD3) の Supplies の V+ を使う (WaveForms で V+ を 5 V にして出力を入れる)。図2 の「電源」の箱がそれで、V+ を上の + レール、GND を上の − レールへつなぐ。電流は全部で約 9 mA で、ブレッドボードの範囲と AD3 の電源 (各レール約 50 mA まで) に収まる。

- 同じ列の a〜e は中でつながっている (0-2)。抵抗の右リード (10 列) と LED のアノードが
  10 列でつながる
- LED は**ピンの長いほうがアノード (A)**、短いほうがカソード (K)。アノードを抵抗の側に挿す。
  逆に挿すと点かない (5 V なら壊れはしない。1-4)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | Analog Discovery 3 の V+ (5 V)。単 3 電池 3 本の 4.5 V でもよく、そのとき電流は約 7.6 mA |

オシロスコープの図は付けない。この題は直流の電圧と電流だけを見るので、テスターの読み値で足りる (オシロは 0-3)。

## 見るべき値

テスターの直流電圧レンジで、抵抗と LED の両端をそれぞれ測る (0-1)。電流は抵抗の両端の電圧を 330 Ω で割って求める。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 抵抗の両端の電圧 | 約 3.0 V | ÷ 330 Ω で電流 (約 9.1 mA) |
| LED の両端の電圧 | 約 2.0 V | 電流を変えてもほとんど変わらない (ダイオードの性質) |
| 抵抗を 1 kΩ に替えたときの抵抗の両端 | 約 3.0 V | 電流は約 3 mA に減り、暗くなる |

## 出典

自作。
