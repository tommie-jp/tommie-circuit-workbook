---
book: circuits
chapter: 1
id: 1-2
title: 直列・並列と分圧
tier: 50
source: 自作
board: BB
---

# 1-2 直列・並列と分圧

何本かの抵抗をまとめて 1 本と見たときの値を**合成抵抗**と呼ぶ。抵抗は**直列**
(一列につなぐ) なら足し算、**並列** (両端をそろえてつなぐ) なら逆数の足し算
(1/R = 1/R2 + 1/R3) で合成でき、並列の合成抵抗はどの 1 本より小さくなる。
直列の 1 本と並列の 2 本を組み合わせた回路で、計算した値と実測を突き合わせる。
電圧が抵抗の比で分かれる**分圧** (0-1) が、並列を含む回路でも成り立つことも確かめる。

## 回路図

```circuit
title: 図1 直列 1 本と並列 2 本
parts:
  V1: vsource a1 c1 5
  R1: resistor a1 a3 1k
  R2: resistor a3 c3 2k
  R3: resistor a5 c5 2k
  G1: ground c1
wires:
  - a3 -- a5
  - c1 -- c3
  - c3 -- c5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/02-series-parallel.svg)

図1 の R2 と R3 (2 kΩ ずつ) は並列で 1 kΩ になり、R1 (1 kΩ) と直列で合計 2 kΩ。
5 V は R1 と並列部分 (1 kΩ どうし) で半分ずつに分かれる。

- 合成抵抗: R2∥R3 = (2k×2k)/(2k+2k) = **1 kΩ**、全体 = R1 + 1k = **2 kΩ**
- 全体の電流: I = 5V / 2kΩ = **2.5 mA**
- R1 の両端: 2.5mA × 1k = **2.5 V**
- 並列部分の両端: 2.5mA × 1k = **2.5 V** (R1 の両端と偶然同じ値になる)
- R2, R3 それぞれの電流: 2.5V / 2k = **1.25 mA** ずつ (合計で 2.5mA)

## 実体配線図

```breadboard
title: 図2 直列 1 本と並列 2 本
# 上のレール = +5V、下のレール = GND
board: half
parts:
  R1: resistor b5 b10 1k
  R2: resistor c10 c15 2k
  R3: resistor e10 e15 2k
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a15 -- -t15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/02-series-parallel.svg)

5 V の電源は Analog Discovery 3 (AD3) の Supplies の V+ を使う (WaveForms で V+ を 5 V にして出力を入れる)。図2 の「電源」の箱がそれで、V+ を上の + レール、GND を上の − レールへつなぐ。電流は全部で約 2.5 mA で、ブレッドボードの範囲と AD3 の電源 (各レール約 50 mA まで) に収まる。

図2 の `R2` と `R3` の上端はどちらも列 10 (上ブロック) なので、ジャンパ線なしで
`R1` の下端とつながる。下端も列 15 でつながっていて、そこから GND レールへ
1 本引くだけでよい。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 1 kΩ |
| R2, R3 | 抵抗 (1/4 W) | 2 kΩ |
| — | 電源 | Analog Discovery 3 の V+ (5 V) |

オシロスコープの図は付けない。この題は直流の電圧と電流だけを見るので、テスターの読み値で足りる (オシロは 0-3)。

## 見るべき値

電圧はテスターの直流電圧レンジで部品の両端に当てる。電流は、測る部品のピンを 1 本抜いて空いた列に挿し直し、
その列と元の列の間にテスターの電流レンジ (mA) を当てて、回路に割り込ませて測る (0-1)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| R1 の両端 | 約 2.5 V | 計算値どおり |
| 並列部分 (R2∥R3) の両端 | 約 2.5 V | R1 の両端とほぼ同じ電圧になる (今回の値の組み合わせでは) |
| R2 単体、R3 単体を流れる電流 | 約 1.25 mA ずつ | 並列は電流が分かれる |
| 電源からの全電流 | 約 2.5 mA | 1.25mA × 2 に一致する |

## 出典

自作。
