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
  A: switch a1 c1
  RpdA: resistor c1 e1 10k
  GA: ground e1
  B: switch a4 c4
  RpdB: resistor c4 e4 10k
  GB: ground e4
  CIN: switch a8 c8
  RpdC: resistor c8 e8 10k
  GC: ground e8
  U1: dip14 a12 CD4070
  U2: dip14 a20 CD4081
  U3: dip14 a28 CD4071
  RS1: resistor h12 h14 330
  DS1: led h14 j14 red
  GS1: ground j14
  RC1: resistor h20 h22 330
  DC1: led h22 j22 red
  GC1: ground j22
  RS: resistor h5 h7 330
  DS: led h7 j7 red
  GDS: ground j7
  RCO: resistor h28 h30 330
  DCO: led h30 j30 red
  GCO: ground j30
wires:
  - a1 -- a4 -- a8
  - c1 |- U1.1
  - c1 |- U2.1
  - c4 |- U1.2
  - c4 |- U2.2
  - U1.3 |- U1.5
  - U1.3 |- U2.5
  - c8 |- U1.6
  - c8 |- U2.6
  - U2.3 |- U3.1
  - U2.4 |- U3.2
  - U1.3 |- h12
  - U1.4 |- h5
  - U2.3 |- h20
  - U3.3 |- h28
  - U1.14 |- a1
  - U2.14 |- a1
  - U3.14 |- a1
notes:
  - text f5 blue: S (合計)
  - text f12 blue: S1 (半加算の和)
  - text f20 blue: C1 (半加算の桁上げ)
  - text f28 blue: Cout (全加算の桁上げ)
style:
  grid: on
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
