---
book: denken
chapter: 7
id: 7-1
title: 分流器 — 電流計の測定範囲を広げる
tier: 50
source: 自作
board: BB
---

# 7-1 分流器 — 電流計の測定範囲を広げる

検流計 (ガルバノメータ) は流せる電流がとても小さい。もっと大きい電流を測るには、
**分流器** (低い抵抗) を並列に入れて、大部分の電流を分流器に逃がす。実験用の
本物の検流計は手元に無いので、抵抗 r_g (100 Ω) を検流計の内部抵抗の模型として使い、
その両端の電圧を AD で読んで電流に換算する。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R_s = r_g / (n − 1) | 測定範囲を n 倍にするための分流器の抵抗 (r_g は検流計の内部抵抗) |
| I_s / I_g = r_g / R_s | 分流器と検流計を流れる電流の比 (抵抗の逆比) |
| I = I_g + I_s | 全電流は検流計と分流器の電流の和 |

## 回路図

```circuit
title: 図1 分流器
parts:
  V1: vsource a1 c1 5
  Rt: resistor a1 a5 1k i=Itot
  Rg: resistor a5 a8 100 i=Ig
  G1: galvanometer a8 c8
  Rs: resistor a5 c5 50 i=Is
  G2: ground c1
wires:
  - c1 -- c5 -- c8
style:
  standard: jis
```

- Rg (100 Ω) が検流計の内部抵抗の模型。実物の検流計の記号 (G1) は電流の道筋を
  示すためだけに置き、抵抗の値は Rg が持つ
- Rs (50 Ω) が分流器。Rg と並列に入れる
- Rt (1 kΩ) は回路の外側の抵抗 (負荷) の代わり。値そのものは分流の比に関係しない

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rt: resistor c3 c8 1k
  Rg: resistor c15 c19 100
  Rs: resistor e15 e19 50
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t5 red
  - +t3 -- a3 red
  - AD.GND -- -t7 black
  - AD.1+ -- a8 green
  - b8 -- b15 green
  - AD.1- -- -t11 black
  - AD.2+ -- +t13 red
  - AD.2- -- a15 blue
  - a19 -- -t19 black
```

- Rt (1 kΩ) の先で、Rg (100 Ω、検流計の模型) と Rs (50 Ω、分流器) が並列になる
- CH1 (1+) は Rg (= Rs) の両端 (GND 基準)。CH2 は Rt の両端の差動 (全電流)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Scope | CH1 = 並列部分の電圧 (GND 基準)、CH2 = Rt の両端 (差動、全電流) |

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。この題は直流なので発振器は使わない。

AD の CH2 は Rt の両端を差動で挟んでいる。汎用オシロのグランドクリップを Rt の下の端
(並列部分) に当てると、並列部分が GND に落ちる。Rt の電圧は 4.84 V と電源の 9 割を超えるので、
**回路はそのまま**、2 本の先端を Rt の両端に当てて CH2 − CH1 で引く (図3)。

```circuit
title: 図3 汎用オシロでの測り方
parts:
  V1: vsource b2 d2 5
  M2: voltmeter b4 d4 l=$\mathrm{CH2}$
  Rt: resistor b4 b7 1k i=Itot
  M1: voltmeter b8 d8 l=$\mathrm{CH1}$
  Rs: resistor b10 d10 50 i=Is
  Rg: resistor b10 b13 100 i=Ig
  G1: galvanometer b13 d13
  G2: ground d2
wires:
  - b2 -- b4
  - b7 -- b8 -- b10
  - d2 -- d4 -- d8 -- d10 -- d13
style:
  standard: jis
```

| AD | 汎用の計器 |
| --- | --- |
| V+ = 5 V | 安定化電源 5 V、電流制限 10 mA (流れるのは 4.84 mA) |
| 1+ (8 列) / 1− (− レール) | CH1 の先端を 8 列、グランドクリップを − レール |
| 2+ (+ レール) / 2− (15 列) | CH2 の先端を + レール、グランドクリップを − レール。15 列の 2− の線は外す |
| Scope | 入力の結合は DC。Measure の Mean で読む。Rt の電圧は CH2 − CH1 (Math か、2 つの Mean の差) |

CH2 は Rt の電圧ではなく電源の電圧 (5.00 V、計算値) を読む。引いた 4.84 V は
振れの 9 割あるので、8 bit のオシロでも分解能に埋もれない。

## 見るべき値

計算値。Rg (100 Ω) と Rs (50 Ω) の並列 = 33.3 Ω。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (並列部分の電圧) | 0.161 V | I_g = 0.161 V ÷ 100 Ω = 1.61 mA |
| CH2 (Rt の両端、全電流) | 4.84 V | I_total = 4.84 V ÷ 1 kΩ = 4.84 mA |
| I_s (= I_total − I_g) | 3.22 mA | 分流器を流れる電流 |
| I_s / I_g | 2.00 (= r_g / R_s = 100/50) | 抵抗の逆比どおりに分かれる |
| I_total / I_g (= n) | 3.00 | 分流器のおかげで測定範囲が 3 倍になる |

分かること:

- **分流器の抵抗が小さいほど、逃がせる電流の割合が増える。** R_s を半分 (25 Ω)
  にすると n はさらに増える (n = 1 + r_g/R_s の関係)
- 実際の分流器は、検流計の個体ごとの r_g に合わせて精密な抵抗 (シャント抵抗)
  を使う。電流計の切り替えレンジは、この分流器を切り替えて作る

## 出典

自作。
