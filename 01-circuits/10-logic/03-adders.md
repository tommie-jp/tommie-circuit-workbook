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
  GU1b: ground k15c3
  GU2b: ground k32c3
  GU3b: ground k24c3
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
  - U3.7 -| k22c0
  # 使わない入力 (U1・U2 は足8・9・12・13、U3 は足5・6・8・9・12・13) を GND へ
  - U1.13 -| i15c3
  - U1.12 -| i15g3
  - U1.9 -| j15i3
  - U1.8 -| k15c3
  - i15c3 -- i15g3 -- j15i3 -- k15c3
  - U2.13 -| i32c3
  - U2.12 -| i32g3
  - U2.9 -| j32i3
  - U2.8 -| k32c3
  - i32c3 -- i32g3 -- j32i3 -- k32c3
  - U3.13 -| i24c3
  - U3.12 -| i24g3
  - U3.9 -| j24i3
  - U3.8 -| k24c3
  - i24c3 -- i24g3 -- j24i3 -- k24c3
  - U3.5 -| j22e0
  - U3.6 -| j22i0
  - j22e0 -- j22i0 -- k22c0 -- l22
notes:
  - text n8a5 blue: S (合計)
  - text q18 blue: S1 (半加算の和)
  - text k25 blue: C1 (半加算の桁上げ)
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
- **使わない入力は GND へ。** U1・U2 は残り 2 ゲートの入力 (足8・9・12・13)、
  U3 は残り 3 ゲートの入力 (足5・6・8・9・12・13) を GND につなぐ。CMOS の入力は
  浮かせると勝手に振れて電流を食う。出力の足 (U1・U2 の足10・11、U3 の足4・10・11)
  は何もつながずに開けておく

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  A: switch b2 b4
  RpdA: resistor i4 i2 10k
  B: switch b6 b8
  RpdB: resistor i8 i6 10k
  CIN: switch b10 b12
  RpdC: resistor i12 i10 10k
  U1: dip14 @ e14 CD4070
  RS1: resistor a22 a25 330
  DS1: led b25(A) b26(K) red
  RS: resistor a28 a31 330
  DS: led b31(A) b32(K) red
  U2: dip14 @ e37 CD4081
  RC1: resistor a45 a48 330
  DC1: led b48(A) b49(K) red
  U3: dip14 @ e51 CD4071
  RCO: resistor a59 a62 330
  DCO: led b62(A) b63(K) red
wires:
  # 電源: 上の + レール、下の - レール。- は 1 列で上下をつなぐ
  - -t1 -- -b1 black
  - +t2 -- a2 red
  - +t6 -- a6 red
  - +t10 -- a10 red
  - +t14 -- a14 red
  - +t37 -- a37 red
  - +t51 -- a51 red
  - j2 -- -b2 black
  - j6 -- -b6 black
  - j10 -- -b10 black
  - j20 -- -b20 black
  - j43 -- -b43 black
  - j57 -- -b57 black
  # 入力: スイッチの列を溝の下へ下ろして U1 へ、上の d・c 行で U2 へ
  - e4 -- f4 yellow
  - e8 -- f8 green
  - e12 -- f12 blue
  - g4 -- g14 yellow
  - h8 -- h15 green
  - j12 -- j19 blue
  - d4 -- d35 yellow
  - c8 -- c34 green
  - e35 -- f35 yellow
  - e34 -- f34 green
  - i35 -- i37 yellow
  - h34 -- h38 green
  # U1: 足3 → 足5 (S1)、S1 と S を LED へ、S1 と Cin を U2 へ
  - g16 -- g18 orange
  - i18 -- i22 orange
  - f22 -- e22 orange
  - j22 -- j41 orange
  - h17 -- h28
  - f28 -- e28
  - g19 -- g42 blue
  - a26 -- -t26 black
  - a32 -- -t32 black
  # U2: 足3 (C1) を LED と U3 の足1 へ、足4 (C2) を U3 の足2 へ
  - h39 -- h45
  - f45 -- e45
  - a49 -- -t49 black
  - g45 -- g51
  - i40 -- i52
  # U3: 足3 (Cout) を LED へ
  - g53 -- g59
  - f59 -- e59
  - a63 -- -t63 black
  # 使わない入力を GND へ: 上側の足は a 行から上の − レール、下側は j 行から下の − レール
  - a15 -- -t15 black
  - a16 -- -t16 black
  - a19 -- -t19 black
  - a20 -- -t20 black
  - a38 -- -t38 black
  - a39 -- -t39 black
  - a42 -- -t42 black
  - a43 -- -t43 black
  - a52 -- -t52 black
  - a53 -- -t53 black
  - a56 -- -t56 black
  - a57 -- -t57 black
  - j55 -- -b55 black
  - j56 -- -b56 black
```

- U1 (CD4070, XOR) は 14〜20 列、U2 (CD4081, AND) は 37〜43 列、U3 (CD4071, OR)
  は 51〜57 列。どれも切り欠きが左で、足1 が左下 (f 行)、足14 が左上 (e 行)。
  左から入力 → U1・U2 → U3 → 出力 LED の順に並ぶ
- 電源: 各 IC の足14 (14・37・51 列) は a 行から上の + レールへ (赤)、足7 (20・43・57
  列) は j 行から下の − レールへ (黒)。LED は上の − レールへ落とすので、1 列で
  上下の − レールをつなぐ
- スイッチ A・B・Cin (2〜4・6〜8・10〜12 列の b 行) は上の + レールから入れ、
  プルダウン抵抗は溝の下の i 行から下の − レールへ。スイッチ側の列 (4・8・12 列) を
  e→f の短い線で溝の下へ下ろし、g・h・j 行で U1 の足1・2・6 (14・15・19 列) へ入れる
- A (黄) と B (緑) は上のブロックの d 行・c 行を U1 の上を越えて 35・34 列まで運び、
  そこで溝の下へ下ろして i・h 行で U2 の足1・2 (37・38 列) へ。Cin (青) は U1 の足6
  (19 列) から g 行でそのまま U2 の足6 (42 列) へ
- U1 の足3 (S1、16 列) は g 行で足5 (18 列) へ。S1 (橙) は 22 列で上へ上げて
  RS1・DS1 へ、同じ 22 列から j 行で U2 の足5 (41 列) へ。U1 の足4 (S、17 列) は
  h 行で 28 列へ運び、上へ上げて RS・DS へ
- U2 の足3 (C1、39 列) は h 行で 45 列へ運び、上へ上げて RC1・DC1 へ、g 行で U3 の
  足1 (51 列) へ。足4 (C2、40 列) は i 行で U3 の足2 (52 列) へ。U3 の足3 (Cout、
  53 列) は g 行で 59 列へ運び、上へ上げて RCO・DCO へ
- 使わない入力は黒の短い線で GND へ。U1・U2・U3 の足13・12・9・8 (15・16・19・20 列、
  38・39・42・43 列、52・53・56・57 列の上) は a 行から上の − レールへ、U3 の足5・6
  (55・56 列の下) は j 行から下の − レールへ
- 線どうしの交差は無く、溝を横切るのは列をまっすぐ上下する短い線だけ

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
