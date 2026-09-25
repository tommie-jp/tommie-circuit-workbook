---
book: circuits
chapter: 10
id: 10-3
title: 半加算器と全加算器 (XOR + AND)
tier: 50
source: 自作
board: BB
---

# 10-3 半加算器と全加算器 (XOR + AND)

半加算器 (XOR + AND) を作ってから、もう 1 組の XOR・AND と OR を足して
**下の桁からの繰り上がり (Cin) も足せる全加算器**に拡張する。3 つの CMOS IC
(XOR・AND・OR) だけで組める。

## 回路図

```circuit
title: 図1 半加算器を全加算器に拡張する
parts:
  A: switch c3 e3
  RpdA: resistor e3 e1 10k
  GA: ground e1 r90
  B: switch b6 d6
  RpdB: resistor d6 d4 10k
  GB: ground d4 r90
  CIN: switch k16 m16
  RpdC: resistor m16 m18 10k
  GC: ground m18 r270
  VCC: vcc c3
  VCC: vcc b6
  VCC: vcc k16
  U1: dip14 j14 CD4070
  U2: dip14 j31 CD4081
  U3: dip14 j23 CD4071
  VCC: vcc h15i0
  VCC: vcc h32i0
  VCC: vcc h24i0
  RS1: resistor o17 p17 330
  DS1: led p17 q17 red
  GS1: ground q17
  RC1: resistor g26 h26 330
  DC1: led h26 i26 red
  GC1: ground i26
  RS: resistor k10 l10 330
  DS: led l10 m10 red
  GDS: ground m10
  RCO: resistor k20 l20 330
  DCO: led l20 m20 red
  GCO: ground m20
  GU1: ground l13
  GU2: ground l30
  GU3: ground l22
wires:
  - e3 -- e12 -- e29
  - e12 |- U1.1
  - e29 |- U2.1
  - d6 -- d11a6 -- d28a6
  - d11a6 |- U1.2
  - d28a6 |- U2.2
  - U1.3 -| j11e2
  - j11e2 |- U1.5
  - j11e2 -- o11a2 -- o17 -- o28a6
  - o28a6 |- U2.5
  - U1.4 -| k10
  - m16 -- n16
  - n12 -- n16 -- n29
  - n12 |- U1.6
  - n29 |- U2.6
  - U2.3 -| f28f2
  - f28f2 -- f26f0 -- f21f0
  - f26f0 -- g26
  - f21f0 |- U3.1
  - U2.4 -| f27a8
  - f27a8 -- f20a6
  - f20a6 |- U3.2
  - U3.3 -| k20
  - U1.14 -| h15i0
  - U2.14 -| h32i0
  - U3.14 -| h24i0
  - U1.7 -| l13
  - U2.7 -| l30
  - U3.7 -| l22
notes:
  - text n8a5 blue: S (合計)
  - text q18 blue: S1 (半加算の和)
  - text k24 blue: C1 (半加算の桁上げ)
  - text m21 blue: Cout (全加算の桁上げ)
style:
  grid: on
  pitch: 1.2
```

- **半加算器**: U1 ゲート1 (XOR、足1・2→3) が S1 = A⊕B、U2 ゲート1 (AND、
  足1・2→3) が C1 = A·B
- **全加算器への拡張**: U1 ゲート2 (足5・6→4) が S = S1⊕Cin、U2 ゲート2
  (足5・6→4) が C2 = S1·Cin、U3 ゲート1 (OR、足1・2→3) が Cout = C1 + C2
- 3 つの IC とも足14がVDD (VCC へ)、足7がVSS (GND へ)。どちらも図に描いてある。
  つなぎ忘れると IC は動かない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  A: switch a3 a5
  RpdA: resistor c5 c7 10k
  B: switch a10 a12
  RpdB: resistor c12 c14 10k
  CIN: switch a17 a19
  RpdC: resistor c19 c21 10k
  U1: dip14 @ e24 CD4070
  U2: dip14 @ e38 CD4081
  U3: dip14 @ e52 CD4071
  RS1: resistor a31 a33 330
  DS1: led b33(A) b34(K) red
  RS: resistor d32 d35 330
  DS: led c35(A) c37(K) red
  RC1: resistor a45 a47 330
  DC1: led b47(A) b49(K) red
  RCO: resistor a59 a61 330
  DCO: led b61(A) b63(K) red
wires:
  - +t3 -- b3
  - b7 -- -t7
  - +t10 -- b10
  - b14 -- -t14
  - +t17 -- b17
  - b21 -- -t21
  - -t1 -- -b1
  - b5 -- g24
  - d5 -- g38
  - b12 -- g25
  - d12 -- g39
  - b19 -- g29
  - d19 -- g43
  - a24 -- +t24
  - j30 -- -b30
  - a38 -- +t38
  - j44 -- -b44
  - a52 -- +t52
  - j58 -- -b58
  - h26 -- h28
  - i28 -- i42
  - j28 -- e31
  - j27 -- e32
  - g40 -- g52
  - h41 -- h53
  - j40 -- e45
  - j54 -- e59
  - a34 -- -t34
  - b37 -- -t37
  - a49 -- -t49
  - a63 -- -t63
```

- U1 (CD4070, XOR) は 24〜30 列、U2 (CD4081, AND) は 38〜44 列、U3 (CD4071, OR)
  は 52〜58 列。どれも切り欠きが左で、足1 が左下 (f 行)、足14 が左上 (e 行)
- 電源: 各 IC の足14 (24・38・52 列の上) を上の + レールへ、足7 (30・44・58 列の
  下) を下の − レールへ。下の − レールは 1 列で上の − レールとつなぐ
- A (5列)・B (12列) は U1 と U2 の足1・2 (24・25 列と 38・39 列の下) に共通で入る。
  Cin (19列) は足6どうし (29 列と 43 列の下) に共通で入る
- U1 の足3 (S1、26 列) は h 行で足5 (28 列) へ、i 行で U2 の足5 (42 列) へ。
  RS1・DS1 (S1 の LED) は 28 列から上のブロックの 31〜34 列へ渡す。
  U1 の足4 (S、27 列) は 32 列へ渡して RS・DS へ
- U2 の足3・4 (C1・C2、40・41 列) は U3 の足1・2 (52・53 列) へ。C1 の LED
  (RC1・DC1) は 40 列から 45〜49 列へ、U3 の足3 (Cout、54 列) は 59〜63 列の
  RCO・DCO へ

## 見るべき値

| A | B | Cin | S1 | C1 | S (全体の和) | Cout |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 | 1 | 0 | 1 |
| 1 | 1 | 1 | 0 | 1 | 1 | **1** |

最後の行 (A=B=Cin=1) だけ Cout が光る。1+1+1 = 3 (2進数で 11) になる
唯一の組み合わせで、全加算器でないと表せない。

## 出典

自作。
