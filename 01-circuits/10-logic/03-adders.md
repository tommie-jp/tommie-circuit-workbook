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
  U1: dip14 j13 CD4070
  U2: dip14 j30 CD4081
  U3: dip14 j22 CD4071
  VCC: vcc h14i0
  VCC: vcc h31i0
  VCC: vcc h23i0
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
  - U1.14 -| h14i0
  - U2.14 -| h31i0
  - U3.14 -| h23i0
notes:
  - text n8a5 blue: S (合計)
  - text q18 blue: S1 (半加算の和)
  - text j23a5 blue: C1 (半加算の桁上げ)
  - text m21 blue: Cout (全加算の桁上げ)
style:
  grid: on
  pitch: 1.2
```

- **半加算器**: U1 ゲート1 (XOR、足1・2→3) が S1 = A⊕B、U2 ゲート1 (AND、
  足1・2→3) が C1 = A·B
- **全加算器への拡張**: U1 ゲート2 (足5・6→4) が S = S1⊕Cin、U2 ゲート2
  (足5・6→4) が C2 = S1·Cin、U3 ゲート1 (OR、足1・2→3) が Cout = C1 + C2
- 3 つの IC とも足14がVDD、足7がVSS (図では省略。実配線では必ずつなぐ)

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
  U1: dip14 @ e30 CD4070
  U2: dip14 @ e40 CD4081
  U3: dip14 @ e50 CD4071
  RS1: resistor a32 a34 330
  DS1: led c34(A) c36(K) red
  RC1: resistor a42 a44 330
  DC1: led c44(A) c46(K) red
  RS: resistor a52 a54 330
  DS: led c54(A) c56(K) red
  RCO: resistor a58 a60 330
  DCO: led c60(A) c62(K) red
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
  - b19 -- U1.6
  - b19 -- U2.6
  - U1.3 -- b25
  - b25 -- U1.5
  - b25 -- U2.5
  - U1.14 -- b30
  - b30 -- +t30
  - U1.7 -- b31
  - b31 -- -t31
  - U2.14 -- b40
  - b40 -- +t40
  - U2.7 -- b41
  - b41 -- -t41
  - U2.3 -- b45
  - b45 -- U3.1
  - U2.4 -- b47
  - b47 -- U3.2
  - U3.14 -- b50
  - b50 -- +t50
  - U3.7 -- b51
  - b51 -- -t51
  - U1.3 -- b32
  - U1.4 -- b52
  - U2.3 -- b42
  - U3.3 -- b58
  - b36 -- -t36
  - b46 -- -t46
  - b56 -- -t56
  - b62 -- -t62
```

- A (5列)・B (12列) は U1 (CD4070, XOR) と U2 (CD4081, AND) の足1・2 に共通で入る
- U1 の足3 (S1) は 25 列を経由して U1 の足5・U2 の足5 (2 段目の入力) へ戻る。
  Cin (19列) は足6どうし (U1・U2) に共通で入る
- U2 の足3・4 (C1・C2) は U3 (CD4071, OR) の足1・2 へ

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
