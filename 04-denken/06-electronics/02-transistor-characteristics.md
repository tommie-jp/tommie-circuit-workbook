---
book: denken
chapter: 6
id: 6-2
title: トランジスタの静特性 — I_C-V_CE と h_FE
tier: 50
source: 自作
board: BB
---

# 6-2 トランジスタの静特性 — I_C-V_CE と h_FE

トランジスタはベース電流 I_B の何倍もの電流 I_C をコレクタに流せる (電流増幅)。
その倍率 **h_FE** を、ベースとコレクタそれぞれの抵抗の両端の電圧から求める。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_B = (V_CC − V_BE) / R_B | ベース電流。V_BE ≈ 0.6 V (シリコンの順方向電圧) |
| I_C = h_FE × I_B | コレクタ電流。h_FE がこのトランジスタの電流増幅率 |
| V_CE = V_CC − I_C × R_C | コレクタ・エミッタ間の電圧 (エミッタ接地、エミッタは GND) |
| h_FE = I_C / I_B = (V_RC / R_C) / (V_RB / R_B) | 測った 2 つの電圧から h_FE を求める式 |

## 回路図

```circuit
title: 図1 固定バイアスで hFE を測る
parts:
  VCC: vcc a3 5V
  RB: resistor b3 d3 470k i=IB
  RC: resistor b7 d7 1k i=IC
  Q1: npn f7 2SC1815
  G1: ground h7
wires:
  - a3 -- a7 -- b7
  - a3 -- b3
  - d3 -- f3
  - f3 -- Q1.B
  - d7 -- Q1.C
  - Q1.E -- h7
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/02-transistor-characteristics-1.svg)

- R_B (470 kΩ) がベース電流を決め、R_C (1 kΩ) がコレクタ電流を電圧に変える
- Q1 は 2SC1815 (GR ランク、h_FE は個体差があり 200〜400 程度)。ここでは
  代表値 h_FE = 250 として計算する
- V_CC は AD の Supplies (+5 V)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RB: resistor b10 b15 470k
  RC: resistor b24 b16 1k
  Q1: transistor e15(B) e16(C) e17(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, 1+, GND, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t6 red
  - AD.1+ -- +t8 red
  - AD.GND -- -t12 black
  - +t10 -- a10 red
  - +t24 -- a24 red
  - a17 -- -t17 black
  - AD.1- -- a15 orange
  - AD.2- -- a16 green
  - AD.2+ -- +t20 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/breadboard/02-transistor-characteristics.svg)

- +t (赤レール) が +5 V。R_B・R_C ともここから取る (R_B は 10 列、R_C は 24 列から)。
  もう片方の足はベース (15 列)・コレクタ (16 列) に直に挿す
- CH1 (1+/1−) は R_B の両端の差動 (1+ は +t レール、1− は 15 列)。CH2 は R_C の両端の差動
  (2+ は +t レール、2− は 16 列)。Q1.E (17 列) は -t のレールへ

## 計器の設定

この題はオシロの図を付けない — 直流の量 (R_B・R_C の両端の電圧) だけを見る。テスターの読みで足りる。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Scope | CH1 = R_B の両端 (差動)、CH2 = R_C の両端 (差動) |

### オシロスコープと発振器

AD 版は CH1 を R_B、CH2 を R_C の両端に差動で当てる (1− はベース、2− はコレクタ)。
汎用オシロのグランドクリップをベースに当てるとトランジスタが切れ、コレクタに当てると
R_C に 5 V がそのまま掛かる ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) の落とし穴)。

**回路はそのまま、ベースとコレクタを GND 基準で測り、V_CC から引く** (図3)。
測る点は +5 V・ベース・コレクタの 3 つだが、どれも直流なので同時に測らなくてよい。
引いた差は 4.40 V と 2.34 V で、5 V の振れの半分前後あるので 8 bit でも埋もれない。

```circuit
title: 図3 汎用オシロでの測り方
parts:
  VCC: vcc b3 5V
  RB: resistor b3 e3 470k i=IB
  RC: resistor b8 e8 1k i=IC
  Q1: npn g8 2SC1815
  M1: voltmeter g3 j3 l=$\mathrm{CH1}$
  G1: ground j3
  M2: voltmeter g11 j11 l=$\mathrm{CH2}$
  G2: ground j11
  G3: ground j8
wires:
  - b3 -- b8
  - e3 -- g3 -- Q1.B
  - e8 -- Q1.C
  - e8 -| g11
  - Q1.E -- j8
style:
  standard: jis
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/02-transistor-characteristics-2.svg)

- V+ は安定化電源の 5 V。電流制限は 10 mA (飽和しても I_C は 5 V ÷ 1 kΩ = 5 mA まで)
  ([0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))
- 先に CH1 の先端を + のレールに当てて V_CC を読む。次に CH1 をベース (15 列)、
  CH2 をコレクタ (16 列) に当てる。グランドクリップは 2 本とも GND のレール。
  ブレッドボードの部品は動かさない
- R_B の両端 = V_CC − CH1、R_C の両端 = V_CC − CH2。CH2 はそのまま V_CE
- ベースには **×10 のプローブ** (10 MΩ) を当てる。×1 (1 MΩ) ではプローブが 0.6 µA を引き、
  I_B (9.36 µA) が 6 % 減って I_C も同じだけ下がる (計算値)。×10 なら 0.6 % で済む

| 測る所 | 汎用オシロの読み (計算値) | 見るべき値の表との関係 |
| --- | --- | --- |
| CH1 (ベース) | 0.60 V (V_BE) | 5 V − 0.60 V = 4.40 V が R_B の両端 |
| CH2 (コレクタ) | 2.66 V (V_CE) | 5 V − 2.66 V = 2.34 V が R_C の両端 |

直流の確度はテスターのほうが良い (オシロは満目盛りの数 %)。h_FE を詰めるなら
3 つの電圧をテスターでも測る。

## 見るべき値

計算値。h_FE = 250 と仮定して計算している (実測の h_FE は使ったトランジスタの
個体で変わる)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (R_B の両端) | 4.40 V | I_B = 4.40 V ÷ 470 kΩ = 9.36 µA。V_CC − V_BE そのもの |
| CH2 (R_C の両端) | 2.34 V | I_C = 2.34 V ÷ 1 kΩ = 2.34 mA |
| V_CE (= 5 V − CH2) | 2.66 V | 飽和 (約 0.2 V) より十分高く、能動領域で動いている |
| h_FE (= I_C / I_B) | 250 | 計算どおりなら代表値と一致する。実測では個体差が出る |

分かること:

- **CH1 は h_FE によらずほぼ一定** (V_CC − V_BE を R_B で割るだけ)。CH2 だけが
  トランジスタの個体差で変わるので、h_FE の違いは CH2 の値にそのまま出る
- R_B を 2 倍 (470 kΩ を 2 本直列で 940 kΩ) にすると I_B が半分になり、I_C・CH2 も半分になる —
  比例関係を変えて確かめられる
- I_B を増やして V_CE が V_CE(sat) (約 0.2 V) まで下がると、I_C は h_FE × I_B に届かず頭打ちになる
  (飽和。6-7 のスイッチ動作で使う領域)

## 出典

自作。
