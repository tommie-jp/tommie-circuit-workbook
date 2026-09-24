---
book: circuits
chapter: 8
id: 8-1
title: CdS で暗くなると点く
tier: 50
source: 自作
board: BB
---

# 8-1 CdS で暗くなると点く

CdS セル (硫化カドミウムを使った光センサー) は、当たる光が弱いほど抵抗が
大きくなる。固定抵抗と組んで分圧すると、明るさを電圧に変えられる。
その電圧でトランジスタを ON/OFF すれば、暗くなったら自動で LED が点く回路になる。

## 回路図

```circuit
title: 図1 CdS が暗いとトランジスタが ON になる
parts:
  VCC: vcc a1
  R1: resistor a1 a3 10k
  CDS1: photoresistor a3 a5 GL5528 l=$\mathrm{CDS1}$
  G1: ground a5
  Q1: npn d4
  VCC: vcc f1
  R2: resistor f1 f3 330
  D1: led f3 f5
  G2: ground g4
wires:
  - a3 -| Q1.B
  - f5 -| Q1.C
  - Q1.E -| g4
style:
  grid: on
```

- R1 (固定 10 kΩ、上) と CDS1 (CdS、下) で分圧し、その中点 (a3) を Q1 の
  ベースに直結する。**CdS が暗くて抵抗が大きくなるほど、中点の電圧は VCC に
  近づく** — 上の R1 が固定なのに下の CDS1 の抵抗だけが上がるので、電圧の
  ほとんどが CDS1 側に掛かり、中点 (R1 と CDS1 の間) は VCC 寄りになる
- 中点の電圧が Q1 の V<sub>BE</sub> (約 0.7 V) を超えると Q1 が ON になり、
  R2 (330 Ω) を通して D1 (LED) が点く
- ベースに直接分圧の中点をつなぐ簡単な作りなので、切り替わりはゆるやか
  (はっきりした ON/OFF ではない)。感度を変えたいときは R1 を大きく/小さくする

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤いレール = +5V、青いレール = GND
board: half
parts:
  R1: resistor a3 a6 10k
  CDS1: photoresistor a9 a12 GL5528
  Q1: transistor c15(B) c16(C) c17(E) 2SC1815
  R2: resistor f3 f6 330
  D1: led f9(A) f10(K) red
wires:
  - +t3 -- b3 red
  - b6 -- b9 -- b15
  - -t12 -- b12 black
  - +b3 -- g3 red
  - g6 -- g9
  - g10 -- d16
  - -t17 -- d17 black
  - +t1 -- +b1 red
  - -t1 -- -b1 black
notes:
  - text: R1・CDS1 の間 (6・9 列) がベースへの分圧の中点。1 列で上下のレールをつないでいる
```

- CDS1 (CdS) は受光面の蛇行した抵抗体で見分けられる部品。向きは無い
- Q1 のベース (15 列) へは、分圧の中点 (6 列) から配線する。R2・D1 は下ブロック
  (f 行) に置き、下のレールを使う。配線は部品の足そのものではなく、
  同じ列の空いた行 (b・d・g 行) を経由させてある

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 | 10 kΩ |
| CDS1 | CdS セル | GL5528 (10 lux で 8〜20 kΩ) |
| Q1 | NPN トランジスタ | 2SC1815 |
| R2 | 抵抗 | 330 Ω |
| D1 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |

## 見るべき値

計算値。CdS の抵抗は照度のおよそ 0.7 乗に反比例するという代表的な特性で見積もった
目安 (実物には個体差があるので、実測して確かめる)。

| 明るさ | CdS の抵抗 (目安) | 分圧の中点の電圧 | Q1 と LED |
| --- | --- | --- | --- |
| 明るい室内 (500 lux) | 約 650 Ω | 約 0.3 V | OFF (消灯) |
| 薄暗い室内 (100 lux) | 約 2 kΩ | 約 0.8 V | ほぼ OFF |
| 夕方くらい (10 lux) | 約 10 kΩ | 約 2.5 V | ON (点灯) |
| 手で覆う (ほぼ 0 lux) | 約 500 kΩ | 約 4.9 V | ON (しっかり点灯) |

## 出典

自作。
