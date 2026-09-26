---
book: denken
chapter: 1
id: 1-2
title: 直列・並列の合成抵抗と分圧・分流
tier: 50
source: 自作
board: BB
---

# 1-2 直列・並列の合成抵抗と分圧・分流

同じ 2 本の抵抗 (1 kΩ と 2 kΩ) を、直列につなぐか並列につなぐかで、
合成抵抗も電圧・電流の分かれ方もまったく違う値になる。両方を同じ抵抗で
組んで比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R = R1 + R2 (直列) | 直列の合成抵抗。個々の抵抗より必ず大きくなる |
| V1 = V × R1 / (R1 + R2) | 分圧の式。直列では抵抗の比で電圧が分かれる |
| R = R1 R2 / (R1 + R2) (並列) | 並列の合成抵抗。個々の抵抗より必ず小さくなる |
| I1 = I × R2 / (R1 + R2) | 分流の式。並列では抵抗の比が**逆**になって電流が分かれる |

## 回路図

```circuit
title: 図1 直列つなぎ (分圧)
style:
  standard: jis
parts:
  B1: battery a3 a1 9
  R1: resistor a3 a5 1k
  R2: resistor a5 a7 2k
  V1: voltmeter e3 e5
  V2: voltmeter g5 g7
  G1: ground c1
wires:
  - a1 -- c1
  - a7 -- a11
  - a11 -- c11
  - c11 -- c1
  - a3 -- e3
  - a5 -- e5
  - a5 -- g5
  - a7 -- g7
```

- B1 の電流は R1 → R2 と 1 本道を通る。V1 が R1 の両端、V2 が R2 の両端

```circuit
title: 図2 並列つなぎ (分流)
style:
  standard: jis
parts:
  B1: battery a1 c1 9
  A0: ammeter a1 a3
  A1: ammeter a5 c5
  R1: resistor c5 e5 1k
  A2: ammeter a9 c9
  R2: resistor c9 e9 2k
  G1: ground c1
wires:
  - a3 -- a9
  - c1 -- e1
  - e1 -- e5
  - e5 -- e9
```

- A0 が電池から出る全電流。A1・A2 がそれぞれの抵抗の枝を流れる電流

## 実体配線図

```breadboard
title: 図3 直列のブレッドボード
board: half
parts:
  R1: resistor a5 a10 1k
  R2: resistor a12 a17 2k
  BAT:
    type: device
    at: top
    label: 電池 9V
    pins: ["+", "-"]
wires:
  - BAT.+ -- b5 red
  - b10 -- b12 orange
  - b17 -- -t17 black
  - BAT.- -- -t7 black
notes:
  - text: "R1 の両端 (5・10 列) と R2 の両端 (12・17 列) にテスターの電圧レンジを当てる"
  - text: "共通の電流を読むにはここ (10-12 列の橙の線) を外してテスターの電流レンジを挟む"
```

```breadboard
title: 図4 並列のブレッドボード
board: half
parts:
  R1: resistor b14 b19 1k
  R2: resistor b23 b28 2k
  AM0:
    type: device
    at: top
    label: "テスター (mA、全電流)"
    pins: ["+", "-"]
  AM1:
    type: device
    at: bottom
    label: "テスター (mA、R1)"
    pins: ["+", "-"]
  AM2:
    type: device
    at: bottom
    label: "テスター (mA、R2)"
    pins: ["+", "-"]
  BAT:
    type: device
    at: top
    label: 電池 9V
    pins: ["-", "+"]
wires:
  - BAT.- -- -t2 black
  - BAT.+ -- b6 red [h-10]
  - AM0.+ -- a6 orange
  - AM0.- -- b12 orange
  - d12 -- d21 orange
  - AM1.+ -- e12 orange
  - AM1.- -- e14 orange
  - AM2.+ -- e21 orange
  - AM2.- -- e23 orange
  - a19 -- -t19 black
  - a28 -- -t28 black
```

- 図4 は 12 列が節点 (電池と AM0 の先。d 行の橙の線で 21 列へ延ばす)。
  AM1 を介して R1 が、AM2 を介して R2 がそれぞれ GND に落ちる。AM0 が全電流、AM1・AM2 が枝の電流をそのまま示す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| テスター | 直流電圧レンジ (分圧) と直流電流レンジ (分流) を、図に合わせて当て替える |

## 見るべき値

計算値 (V = 9 V、R1 = 1 kΩ、R2 = 2 kΩ)。

| 配線 | 測る所 | 期待する値 |
| --- | --- | --- |
| 直列 | 合成抵抗 | 3 kΩ |
| 直列 | 電流 (共通) | 3.0 mA |
| 直列 | V1 (R1 の電圧) | 3.0 V |
| 直列 | V2 (R2 の電圧) | 6.0 V (V1 + V2 = 9 V) |
| 並列 | 合成抵抗 | 667 Ω |
| 並列 | 全電流 (A0) | 13.5 mA |
| 並列 | R1 の電流 (A1) | 9.0 mA |
| 並列 | R2 の電流 (A2) | 4.5 mA (A1 + A2 = 13.5 mA) |

分かること:

- **直列では大きいほうの抵抗 (R2) に大きい電圧が掛かる。** 分圧の比は
  抵抗の比そのもの (1 : 2 なら電圧も 1 : 2 で 3 V : 6 V)
- **並列では小さいほうの抵抗 (R1) に大きい電流が流れる。** 分流の比は
  抵抗の比の**逆** (1 : 2 の抵抗に 2 : 1 の電流)
- 並列の合成抵抗 (667 Ω) は、小さいほう (1 kΩ) よりさらに小さくなる

## 出典

自作。
