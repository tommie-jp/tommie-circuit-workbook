---
book: circuits
chapter: 2
id: 2-9
title: JFET の定電流
tier: 100
source: 自作
---

# 2-9 JFET の定電流

接合型 FET (JFET) はゲートに電流をほぼ流さない部品だが、**ソースに抵抗
1 本を足してゲートを直接 GND に落とす**だけで、電源電圧が変わっても
ほぼ一定の電流を流し続ける**定電流ダイオード**として使える。2-7 の
カレントミラーとは違う、もっと部品点数の少ない定電流の作り方。

## 回路図

```circuit
title: 図1 JFET のセルフバイアスで定電流を作る
parts:
  V1: vsource a1 g1 9
  G0: ground g1
  D1: led a3 c3
  J1: njfet e5
  G1: ground d2
  RS: resistor g5 g7 1k
  G2: ground g7
wires:
  - a1 -- a3
  - c3 -| J1.D
  - d2 -| J1.G
  - J1.S -| g5
style:
  grid: on
```

`J1` のゲートは `G1` で直接 GND に落としてある。ソースが `RS` を通して
GND から浮くと、ゲート-ソース間には **V<sub>GS</sub> = −I<sub>D</sub> × RS** の
逆バイアスがかかり、これが FET 自身の電流を絞る (セルフバイアス)。
J1 は 2SK30A (GR ランク) を想定し、代表値として I<sub>DSS</sub> = 3mA、
V<sub>GS(off)</sub> = −2.5V とする (個体差が大きいので目安の値)。

- シェイクレイの式 I<sub>D</sub> = I<sub>DSS</sub>(1 − V<sub>GS</sub>/V<sub>GS(off)</sub>)<sup>2</sup>
  と V<sub>GS</sub> = −I<sub>D</sub>×RS を連立して解くと、RS = 1kΩ のとき
  **I<sub>D</sub> ≈ 1.03 mA**、V<sub>GS</sub> ≈ **−1.03 V** (計算値)
- ドレイン-ソース間の最小電圧 (ピンチオフを保つ条件): V<sub>DS(min)</sub> =
  V<sub>GS</sub> − V<sub>GS(off)</sub> ≈ −1.03 − (−2.5) ≈ **1.47 V**
- LED (V<sub>F</sub> ≈ 2.0V) をつないだときのドレイン電圧は 9 − 2.0 = 7.0V、
  ソース電圧は I<sub>D</sub>×RS ≈ 1.03V、V<sub>DS</sub> ≈ **5.97 V** — 最小値
  1.47V より十分高いので、定電流領域で動いている

電源電圧を 9V から 7V や 12V に変えても、V<sub>DS</sub> が最小値を超えている
限り I<sub>D</sub> はほぼ 1.03mA のまま — **1-1 の「抵抗 1 本で電流を決める」
方法は電源電圧で電流が変わったが、JFET のセルフバイアスは電源電圧に
ほぼ無関係な電流源になる**。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| J1 | N チャネル JFET | 2SK30A (GR ランク)、代表値 I<sub>DSS</sub> = 3mA、V<sub>GS(off)</sub> = −2.5V |
| RS | 抵抗 (1/4 W) | 1 kΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 9V 電池 |

## 見るべき値

| 測る所 | 期待する値 (計算値、個体差あり) | 分かること |
| --- | --- | --- |
| RS の両端の電圧 (÷1kΩ で I<sub>D</sub>) | 約 1.0 V (I<sub>D</sub> ≈ 1.0mA) | ソース電流がそのまま LED の電流になる |
| V<sub>GS</sub> (ゲート-ソース間) | 約 −1.0 V | JFET 自身がこの逆バイアスで電流を絞っている |
| 電源電圧を 9V→12V に変えたときの LED の電流 | ほとんど変わらない (V<sub>DS</sub> の余裕が増えるだけ) | 電源電圧に対する定電流性が確かめられる |
| RS を 470Ω に替えたときの電流 | 約 1.5mA 前後に増える (計算値、個体差の影響を受けやすい) | RS が小さいほど電流は増えるが、JFET の個体差の影響も受けやすくなる |

## 出典

自作。
