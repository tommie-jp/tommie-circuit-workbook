---
book: circuits
chapter: 10
id: 10-1
title: ゲートの基本 — スイッチと LED で AND / OR / NOT
tier: 50
source: 自作
board: BB
---

# 10-1 ゲートの基本 — スイッチと LED で AND / OR / NOT

CMOS ロジック IC を 3 つ並べ、同じ 2 つのスイッチ入力 (A・B) を AND と OR の
両方に入れて出力を比べる。もう 1 つのスイッチ C は NOT (インバータ) に入れる。
LED が点いていれば出力は 1 (Hレベル)、消えていれば 0。

## 回路図

```circuit
title: 図1 AND・OR・NOTを並べて比べる
parts:
  A: switch a1 c1
  RpdA: resistor c1 e1 10k
  GA: ground e1
  B: switch a4 c4
  RpdB: resistor c4 e4 10k
  GB: ground e4
  C: switch a8 c8
  RpdC: resistor c8 e8 10k
  GC: ground e8
  U1: dip14 a12 CD4081
  U2: dip14 a18 CD4071
  U3: dip14 a24 CD4069
  R1: resistor h12 h14 330
  D1: led h14 j14 red
  GD1: ground j14
  R2: resistor h18 h20 330
  D2: led h20 j20 red
  GD2: ground j20
  R3: resistor h24 h26 330
  D3: led h26 j26 red
  GD3: ground j26
  GU1: ground b13
  GU2: ground b19
  GU3: ground b25
wires:
  - a1 -- a4 -- a8
  - c1 |- U1.1
  - c1 |- U2.1
  - c4 |- U1.2
  - c4 |- U2.2
  - c8 |- U3.1
  - U1.3 |- h12
  - U2.3 |- h18
  - U3.2 |- h24
  - U1.14 |- a1
  - U2.14 |- a1
  - U3.14 |- a1
  - U1.7 |- b13
  - U2.7 |- b19
  - U3.7 |- b25
notes:
  - text b12 blue: AND
  - text b18 blue: OR
  - text b24 blue: NOT
style:
  grid: on
```

- U1 (CD4081、AND) と U2 (CD4071、OR) は**同じ A・B** を入力にする。ゲート1
  (足1・2→3) だけを使う
- U3 (CD4069、6 回路入りインバータ) はゲート1 (足1→2) を使う。C を NOT に入れる
- スイッチを開けると入力はプルダウン抵抗 (10kΩ) で 0V (0) に落ち、閉じると
  Vcc (1) になる。CMOS の入力は浮かせてはいけないので、開いている間もプル
  ダウンで電位を決めておく
- U1.14・U2.14・U3.14 が VDD (5V)、U1.7・U2.7・U3.7 が VSS (GND、図では省略。
  実配線では必ずつなぐ)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  A: switch a3 a5
  RpdA: resistor c5 c7 10k
  B: switch a10 a12
  RpdB: resistor c12 c14 10k
  C: switch a17 a19
  RpdC: resistor c19 c21 10k
  U1: dip14 @ e30 CD4081
  U2: dip14 @ e40 CD4071
  U3: dip14 @ e50 CD4069
  R1: resistor a32 a34 330
  D1: led c34(A) c36(K) red
  R2: resistor a42 a44 330
  D2: led c44(A) c46(K) red
  R3: resistor a52 a54 330
  D3: led c54(A) c56(K) red
wires:
  - +t3 -- b3
  - b7 -- -t7
  - b5 -- U1.1
  - b5 -- U2.1
  - +t10 -- b10
  - b14 -- -t14
  - b12 -- U1.2
  - b12 -- U2.2
  - +t17 -- b17
  - b21 -- -t21
  - b19 -- U3.1
  - U1.14 -- b30
  - b30 -- +t30
  - U1.7 -- b31
  - b31 -- -t31
  - U2.14 -- b40
  - b40 -- +t40
  - U2.7 -- b41
  - b41 -- -t41
  - U3.14 -- b50
  - b50 -- +t50
  - U3.7 -- b51
  - b51 -- -t51
  - U1.3 -- b32
  - U2.3 -- b42
  - U3.2 -- b52
  - c36 -- -t36
  - c46 -- -t46
  - c56 -- -t56
```

- 上の赤レール = +5V (単3 電池 3 本か USB の 5V)、青レール = GND
- A・B は 5・12 列のスイッチの出力を、それぞれ U1 (CD4081, AND) と U2
  (CD4071, OR) の足 1・2 (b 列経由) へ渡す。C は 19 列から U3 (CD4069, NOT)
  の足 1 へ
- 3 つの DIP14 (e30・e40・e50) は足 14 (VDD) を赤レール、足 7 (VSS) を
  青レールへ

## 見るべき値

| A | B | AND (LED1) | OR (LED2) |
| --- | --- | --- | --- |
| 0 | 0 | 消灯 | 消灯 |
| 1 | 0 | 消灯 | **点灯** |
| 0 | 1 | 消灯 | **点灯** |
| 1 | 1 | **点灯** | **点灯** |

| C | NOT (LED3) |
| --- | --- |
| 0 | **点灯** |
| 1 | 消灯 |

AND は両方閉じたときだけ点く。OR はどちらか片方でも点く。NOT はスイッチを
**開けている間だけ**点く (入力 0 → 出力 1)。

## 出典

自作。
