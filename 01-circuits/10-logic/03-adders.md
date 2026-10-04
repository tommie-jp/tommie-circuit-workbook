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

2 進数の足し算をゲートで組む。コンピュータの計算の中身は、この回路の積み重ねになっている。

まず 1 桁どうしの A + B を計算する半加算器を作る。1 + 1 = 10 (2 進数) のように、
1 桁の足し算は「その桁の和」と「上の桁への繰り上がり」の 2 つの出力を持つ。
和は XOR (排他的論理和: 2 つの入力が違うときだけ 1)、繰り上がりは AND (10-1) で作れる。
次に、もう 1 組の XOR・AND と OR を足して、下の桁からの繰り上がり (Cin) も足せる
全加算器に拡張する。3 つの CMOS IC (XOR・AND・OR) だけで組める。

式の記号は、⊕ が XOR、· が AND、+ が OR を表す。

## 回路図

```circuit
title: 図1 半加算器を全加算器に拡張する
parts:
  A: switch d3 f3
  RpdA: resistor f3 f1 10k
  GA: ground f1
  B: switch c6 e6
  RpdB: resistor e6 e4 10k
  GB: ground e4
  CIN: switch b9 d9
  RpdC: resistor d9 d7 10k
  GC: ground d7
  VCC: vcc d3 5V
  VCC: vcc c6 5V
  VCC: vcc b9 5V
  U1A: xor h14 CD4070
  U2A: and n14 CD4081
  U1B: xor h24 CD4070
  U2B: and l24 CD4081
  U3A: or m30 CD4071
  RS1: resistor h17 j17 330
  DS1: led j17 k17 red
  GS1: ground k17
  RC1: resistor n18 p18 330
  DC1: led p18 q18 red
  GC1: ground q18
  RCO: resistor m34 o34 330
  DCO: led o34 p34 red
  GCO: ground p34
  RS: resistor h37 j37 330
  DS: led j37 k37 red
  GDS: ground k37
wires:
  - f3 -- f10 -- f12
  - f12 |- U1A.a
  - f10 |- U2A.a
  - e6 -- e9 -- e11
  - e11 |- U1A.b
  - e9 |- U2A.b
  - d9 -- d20 -- d21
  - d21 |- U1B.a
  - d20 |- U2B.a
  - U1A.out -- h17 -- h19
  - h19 |- U1B.b
  - h19 |- U2B.b
  - U2A.out -- n18 -- n28
  - n28 |- U3A.b
  - U2B.out -- l28
  - l28 |- U3A.a
  - U3A.out -- m34
  - U1B.out -- h37
notes:
  - text g16 blue: S1
  - text m21 blue: C1
  - text k26 blue: C2
  - text l32 blue: Cout
  - text g35 blue: S
  - text r1 small left: "数字は IC の PIN 番号"
  - text s1 small left: "VDD は 3 つとも PIN 14 (+5V)、VSS は PIN 7 (GND)"
  - text t1 small left: "使わない入力は GND へ (U1・U2: PIN 8・9・12・13、U3: PIN 5・6・8・9・12・13)"
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/03-adders.svg)

- 半加算器: U1A (XOR、PIN 1・2→3) が和 S1 = A⊕B、U2A (AND、PIN 1・2→3) が繰り上がり C1 = A·B
- 全加算器への拡張: U1B (XOR、PIN 5・6→4) が和 S = Cin⊕S1、U2B (AND、PIN 5・6→4)
  が C2 = Cin·S1、U3A (OR、PIN 1・2→3) が繰り上がり Cout = C2 + C1。
  C1 と C2 が同時に 1 になることは無いので、OR でまとめてよい
- 図1 はゲートを論理記号で描き、記号の入出力に IC の PIN 番号を添えた。U1A・U1B は同じ
  CD4070 (U1) の 2 回路、U2A・U2B は同じ CD4081 (U2) の 2 回路
- 電源の PIN は記号に出ないので図の下に書いた。3 つの IC とも PIN 14 が VDD (+5V)、
  PIN 7 が VSS (GND)。つなぎ忘れると IC は動かない
- 使わない入力は GND へつなぐ (10-1)。U1・U2 は残り 2 ゲートの入力 (PIN 8・9・12・13)、
  U3 は残り 3 ゲートの入力 (PIN 5・6・8・9・12・13) が対象。出力の PIN (U1・U2 の
  PIN 10・11、U3 の PIN 4・10・11) は何もつながずに開けておく

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  A: switch d2 d4
  RpdA: resistor a4 -t4 10k
  B: switch d6 d8
  RpdB: resistor a8 -t8 10k
  CIN: switch d10 d12
  RpdC: resistor a12 -t12 10k
  U1: dip14 @ e14 CD4070
  RS1: resistor d21 d25 330
  DS1: led e25(A) e26(K) red
  RS: resistor d28 d32 330
  DS: led e32(A) e33(K) red
  U2: dip14 @ e37 CD4081
  RC1: resistor a45 a48 330
  DC1: led b48(A) b49(K) red
  U3: dip14 @ e51 CD4071
  RCO: resistor a58 a61 330
  DCO: led b61(A) b62(K) red
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
wires:
  # 電源: 上の + レール、下の - レール。- は 1 列で上下をつなぐ
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t2 -- a2 red
  - +t6 -- a6 red
  - +t10 -- a10 red
  - +t14 -- a14 red
  - +t37 -- a37 red
  - +t51 -- a51 red
  - j20 -- -b20 black
  - j43 -- -b43 black
  - j57 -- -b57 black
  # 入力: スイッチの列を溝の下へ下ろして U1 へ、上の b・c 行で U2 へ
  - e4 -- f4 yellow
  - e8 -- f8 green
  - e12 -- f12 blue
  - g4 -- g14 yellow
  - h8 -- h15 green
  - j12 -- j19 blue
  - b4 -- b35 yellow
  - c8 -- c34 green
  - e35 -- f35 yellow
  - e34 -- f34 green
  - i35 -- i37 yellow
  - h34 -- h38 green
  # U1: PIN 3 → PIN 5 (S1)、S1 と S を LED へ、S1 と Cin を U2 へ
  - g16 -- g18 orange
  - i18 -- i21 orange
  - f21 -- e21 orange
  - j21 -- j41 orange
  - h17 -- h28
  - f28 -- e28
  - g19 -- g42 blue
  - a26 -- -t26 black
  - a33 -- -t33 black
  # U2: PIN 3 (C1) を LED と U3 の PIN 1 へ、PIN 4 (C2) を U3 の PIN 2 へ
  - h39 -- h45
  - f45 -- e45
  - a49 -- -t49 black
  - g45 -- g51
  - i40 -- i52
  # U3: PIN 3 (Cout) を LED へ
  - g53 -- g58
  - f58 -- e58
  - a62 -- -t62 black
  # 使わない入力を GND へ: 上側の PIN は a 行から上の − レール、下側は j 行から下の − レール
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/03-adders.svg)

- U1 (CD4070, XOR) は 14〜20 列、U2 (CD4081, AND) は 37〜43 列、U3 (CD4071, OR)
  は 51〜57 列。どれも切り欠きが左で、PIN 1 が左下 (f 行)、PIN 14 が左上 (e 行)。
  左から入力 → U1・U2 → U3 → 出力 LED の順に並ぶ
- 電源 (板の左上) の +5V (赤) は上の + レールの 1 列、GND (黒) は上の − レールの 2 列へ
- 電源: 各 IC の PIN 14 (14・37・51 列) は a 行から上の + レールへ (赤)、PIN 7 (20・43・57
  列) は j 行から下の − レールへ (黒)。LED とプルダウン抵抗は上の − レールへ落とすので、1 列で
  上下の − レールをつなぐ
- スイッチ A・B・Cin (2〜4・6〜8・10〜12 列の d 行) は上の + レールから入れる。
  プルダウン抵抗はスイッチ側の列 (4・8・12 列) の a 行と上の − レールのあいだに
  縦に挿す。スイッチ側の列を
  e→f の短い線で溝の下へ下ろし、g・h・j 行で U1 の PIN 1・2・6 (14・15・19 列) へ入れる
- A (黄) と B (緑) は上のブロックの b 行・c 行を U1 の上を越えて 35・34 列まで運び、
  そこで溝の下へ下ろして i・h 行で U2 の PIN 1・2 (37・38 列) へ。Cin (青) は U1 の PIN 6
  (19 列) から g 行でそのまま U2 の PIN 6 (42 列) へ
- U1 の PIN 3 (S1、16 列) は g 行で PIN 5 (18 列) へ。S1 (橙) は i 行で 21 列へ運び、
  上へ上げて RS1・DS1 へ、同じ 21 列から j 行で U2 の PIN 5 (41 列) へ。U1 の PIN 4 (S、17 列) は
  h 行で 28 列へ運び、上へ上げて RS・DS へ。RS1・RS は d 行、DS1・DS は e 行に置き、
  b・c 行を通る A・B の線の下に並べる。LED のカソードは a 行から上の − レールへ
- U2 の PIN 3 (C1、39 列) は h 行で 45 列へ運び、上へ上げて RC1・DC1 へ、g 行で U3 の
  PIN 1 (51 列) へ。PIN 4 (C2、40 列) は i 行で U3 の PIN 2 (52 列) へ。U3 の PIN 3 (Cout、
  53 列) は g 行で 58 列へ運び、上へ上げて RCO・DCO へ
- 使わない入力は黒の短い線で GND へ。U1・U2・U3 の PIN 13・12・9・8 (15・16・19・20 列、
  38・39・42・43 列、52・53・56・57 列の上) は a 行から上の − レールへ、U3 の PIN 5・6
  (55・56 列の下) は j 行から下の − レールへ
- 線どうしの交差は無く、溝を横切るのは列をまっすぐ上下する短い線だけ

## 見るべき値

スイッチは閉じると 1。表の 1 は LED の点灯 (S1 は DS1、C1 は DC1、S は DS、Cout は DCO)。

| A | B | Cin | S1 | C1 | S (全体の和) | Cout | 10 進で |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 | 0 | 1 | 0 | 1 |
| 0 | 1 | 0 | 1 | 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 1 | 0 | 0 | 1 | 2 |
| 1 | 0 | 0 | 1 | 0 | 1 | 0 | 1 |
| 1 | 0 | 1 | 1 | 0 | 0 | 1 | 2 |
| 1 | 1 | 0 | 0 | 1 | 0 | 1 | 2 |
| 1 | 1 | 1 | 0 | 1 | 1 | 1 | 3 |

Cout を 2 の位、S を 1 の位として読むと、A + B + Cin の答えになる (最後の列)。
最後の行 (A=B=Cin=1) だけ S と Cout が両方光る。1+1+1 = 3 (2 進数で 11) になる
唯一の組み合わせで、Cin を足せる全加算器でないと表せない。

## 出典

自作。
