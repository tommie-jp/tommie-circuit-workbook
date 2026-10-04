---
book: denken
chapter: 1
id: 1-1
title: オームの法則 — 電圧・電流・抵抗を同時に測る
tier: 50
source: 自作
board: BB
---

# 1-1 オームの法則 — 電圧・電流・抵抗を同時に測る

電験三種の理論のすべての土台になる式。電源と抵抗 1 本だけの回路で、
電圧・電流・抵抗の値を同時に測り、V = IR が成り立つことを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V = I R | オームの法則。電圧・電流・抵抗のどれか 2 つから残り 1 つが決まる |
| R = V / I | 電圧計と電流計の読みから抵抗を逆算する (テスターの抵抗レンジと比べて確かめる) |

## 回路図

```circuit
title: 図1 電圧・電流・抵抗を同時に測る
style:
  standard: jis
parts:
  B1: battery a3 a1 5
  A1: ammeter a3 a5
  R1: resistor a5 a7 1k
  V1: voltmeter e5 e7
  G1: ground g1
wires:
  - a7 -- a11
  - a11 -- g11
  - g11 -- g1
  - a1 -- g1
  - a5 -- e5
  - a7 -- e7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/circuit/01-ohms-law.svg)

- B1 は 5 V の電源 (USB の 5 V か AD の Supplies。単 3 電池 3 本の 4.5 V でも可)。
  先に書いた番地が + 側で、A1 (電流計) に直接つながる
- A1 (テスターの電流レンジ) は R1 と**直列**。電流はどこで測っても同じ値
- V1 (テスターの電圧レンジ) は R1 と**並列**。R1 の両端の電圧だけを読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  R1: resistor a5 a10 1k
  AM:
    type: device
    at: bottom
    label: "テスター (mA)"
    pins: ["+", "-"]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+, "1+", "1-"]
wires:
  - AD.V+ -- b3 red
  - AM.+ -- c3 orange
  - AM.- -- b5 orange
  - b10 -- -t10 black
  - AD.GND -- -t5 black
  - AD.1+ -- d5 blue
  - AD.1- -- d10 white
notes:
  - text: "R1 の両端 (5 列・10 列) にテスター (電圧レンジ) を当てる"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/breadboard/01-ohms-law.svg)

- AM (テスターの電流レンジ) を電源と R1 の間に直列に入れる。3 列 (電源側) と
  5 列 (R1 側) が離れているのは、テスターを挟むため
- 電圧計は R1 の両端 (5 列・10 列) に当てるだけでよい (回路を切らない)。AD の Scope の 1+ / 1− も同じ 5 列・10 列に挿してあり、テスターの代わりに電圧を読める
- AD の Supplies V+ を 5 V にして電源に使う。流れる電流は 5 mA で、各レール約 50 mA (USB 給電で 250 mW) に収まる。板の電流もブレッドボードの範囲 (1 穴 200 mA) に収まる

## 計器の設定

この題の計器は Analog Discovery 3 (AD3) の Supplies (電源) とテスター。Scope は電圧の読みの代わりに使える。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V。Enable してから Master Enable を入れる |
| Scope | CH1 (1+ / 1−) を R1 の両端に。DC 結合で、Measure の Average が 5 V になる |
| テスター 1 | 直流電流レンジ (mA)。3〜5 列の間に直列に入れる |
| テスター 2 | 直流電圧レンジ (V)。R1 の両端に当てる |
| テスター 3 (別に) | 抵抗レンジ。回路から外した R1 単体を測って比べる |

この題はオシロの図を付けない — 直流の量だけを見る (テスターの読みで足りる)。

## 見るべき値

計算値 (V = 5 V、R = 1 kΩ)。単 3 電池 3 本 (4.5 V) なら電圧・電流とも 0.9 倍になる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 電流計 (A1) | 5.0 mA | I = V / R = 5 V / 1 kΩ |
| 電圧計 (V1、R1 の両端) | 5.0 V | 回路に他の抵抗が無いので、電源の電圧がそのまま R1 に掛かる |
| R = V1 の読み ÷ A1 の読み | 1.0 kΩ | 抵抗レンジで測った値と一致する |

分かること:

- **3 つの値のうち 2 つを測れば残り 1 つは計算で分かる。** 電圧・電流・抵抗の
  どれを測るかは、テスターの当て方 (直列か並列か) で決まる
- R1 を 2 kΩ に替えると、電圧は 5 V のまま、電流は半分の 2.5 mA になる
  (1-2 の直列・並列で組み合わせを増やす)

## 出典

自作。
