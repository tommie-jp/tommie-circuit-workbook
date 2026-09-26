---
book: denken
chapter: 4
id: 4-3
title: Δ 負荷 — 線電流は相電流の √3 倍
tier: 50
source: 自作
board: BB
---

# 4-3 Δ 負荷 — 線電流は相電流の √3 倍

4-1 で作った三相電源に、抵抗 3 本を三角形につないだ **Δ (デルタ) 結線**の負荷を
つなぐ。Δ の 1 辺を流れる電流 (相電流) と、電源から出て行く電流 (線電流) を
それぞれ抵抗の両端の電圧から求めて比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_a = I_ab − I_ca | 線電流 (a 線) は、Δ の 2 つの辺の電流の差 (キルヒホッフの電流則) |
| \|I_a\| = √3 × \|I_ab\| | 平衡負荷なら、線電流の大きさは相電流 (Δ の 1 辺の電流) の √3 倍 |
| ∠I_a = ∠I_ab − 30° | 線電流の位相は、その相電流より 30° 遅れる |

## 回路図

```circuit
title: 図1 三相電源にデルタ結線の負荷
parts:
  V1: sine a1 c1 1 l=$\mathrm{W1}$
  G1: ground c1
  R1: resistor a1 a4 10k
  V2: sine e1 g1 1 l=$\mathrm{W2}$
  G2: ground g1
  R2: resistor e1 e5 10k
  U1: opamp c9 +up TL071
  G3: ground c6
  Rf: resistor d11 d14 10k
  OUT: port c16
  RLA: resistor b30 b33 20
  RLB: resistor f35 f38 20
  RLC: resistor c40 c43 20
  RAB: resistor k33 k38 1k
  RBC: resistor k38 k43 1k
  RCA: resistor m33 m43 1k
wires:
  - a4 |- U1.-
  - e5 |- U1.-
  - c6 |- U1.+
  - d11 |- U1.-
  - U1.out -- c14 -- c16
  - d14 -- c14
  - a1 -- b30
  - e1 -- f35
  - c16 -- c40
  - b33 -- k33
  - f38 -- k38
  - c43 -- k43
  - k43 -- m43
  - m33 -- k33
notes:
  - text c16 blue: 3 相目
  - text k33 blue: a
  - text k38 blue: b
  - text k43 blue: c
style:
  standard: jis
  grid: on
  pitch: 1.2
```

- RLA・RLB・RLC (各 20 Ω) は**線電流を測るためのシャント**。値は小さく、
  電源の電圧をほとんど下げない
- RAB・RBC・RCA (各 1 kΩ) が Δ 結線の負荷本体。a・b・c の 3 点を三角形につなぐ
- RLA の両端の電圧を Rline = 20 Ω で割ると線電流、RAB の両端の電圧を
  1 kΩ で割ると相電流になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上のブロック: TL071 の入力側と R1・R2、右に d 行の線電流シャントと a〜c 行の Δ の 3 辺。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運ぶ
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  RLA: resistor d35 d38 20
  RLB: resistor d41 d44 20
  RLC: resistor d53 d56 20
  RAB: resistor b38 b44 1k
  RBC: resistor c44 c56 1k
  RCA: resistor a38 a56 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 2-, V-, W1, 1+, W2, 2+]
wires:
  - AD.V+ -- +t4 red
  - AD.GND -- -t6 black
  - AD.1- -- -t8 black
  - AD.2- -- -t10 black
  - AD.V- -- a13 purple
  - AD.W1 -- c17 yellow [h-10]
  - AD.1+ -- a17 yellow
  - AD.W2 -- b25 orange [h-10]
  - AD.2+ -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - e25 -- f25 orange
  - j25 -- j41 orange
  - h14 -- h53 blue
  - f35 -- e35 yellow
  - f41 -- e41 orange
  - f53 -- e53 blue
notes:
  - text small: 列 38 が a 点、44 が b 点、56 が c 点 (どれも a〜e 行の同じ列は同じネット)
```

- 35・41・53 列は AD.W1・AD.W2・U1.6 (3 相目) を下の段の g・j・h 行で右へ運び、
  溝を渡る短い線 (e35・e41・e53) で上の段へ戻したもの。
  d 行のシャント (RLA・RLB・RLC) を通って a・b・c の 3 点になる
- **a〜e 行は同じ列なら同じネット**なので、a 点 (列 38) は RLA (d38)・RAB (b38)・
  RCA (a38) の 3 つの穴に分かれて出る。別の行の穴を使うのは、実物のブレッドボードで
  同じ穴に 2 本挿せないため。b 点は列 44、c 点は列 56 も同じ考え方

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope (1 回目) | CH1 = RLA の両端 (差動、線電流 a)、CH2 = RAB の両端 (差動、相電流 ab) |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

## 見るべき値

計算値。線のシャント (20 Ω) を含めて計算している。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RAB の両端 (振幅) | 1.63 V | 相電流 1.63 V ÷ 1 kΩ = 1.63 mA |
| RLA の両端 (振幅) | 56.6 mV | 線電流 56.6 mV ÷ 20 Ω = 2.83 mA |
| 線電流 ÷ 相電流 | 1.73 (= √3) | 線電流は相電流の √3 倍 |
| 線電流の位相 (相電流に対して) | −30° | 線電流は相電流より 30° 遅れる |

分かること:

- **線電流のほうが相電流より大きい。** カタログのモータの定格電流は線電流な
  ので、内部が Δ 結線なら 1 相の巻線に流れる電流はその 1/√3
- シャント (20 Ω) を入れたぶんだけ Δ の両端の電圧は理想 (1.73 V) よりわずかに
  下がる (1.63 V)。**線電流と相電流の比 √3 は、シャントの値によらず成り立つ**
  (キルヒホッフの電流則そのものだから)

## 出典

自作。
