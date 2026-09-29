---
book: circuits
chapter: 10
id: 10-1
title: ゲートの基本 — スイッチと LED で AND / OR / NOT
tier: 50
source: 自作
board: BB
---

# 10-1 ゲートの基本 — スイッチと LED で AND / OR / NOT

CMOS ロジック IC を 3 つ並べ、同じ 2 つのスイッチ入力 (A・B) を AND と OR の
両方に入れて出力を比べる。もう 1 つのスイッチ C は NOT (インバータ) に入れる。
LED が点いていれば出力は 1 (Hレベル)、消えていれば 0。

## 回路図

```circuit
title: 図1 AND・OR・NOTを並べて比べる
parts:
  A: button d3 f3
  RpdA: resistor f3 f1 10k
  GA: ground f1
  B: button c6 e6
  RpdB: resistor e6 e4 10k
  GB: ground e4
  C: button b9 d9
  RpdC: resistor d9 d7 10k
  GC: ground d7
  VCC: vcc d3
  VCC: vcc c6
  VCC: vcc b9
  U1: and h14 CD4081
  U2: or h20 CD4071
  U3: not h26 CD4069
  R1: resistor h16 j16 330
  D1: led j16 k16 red
  GD1: ground k16
  R2: resistor h22 j22 330
  D2: led j22 k22 red
  GD2: ground k22
  R3: resistor h28 j28 330
  D3: led j28 k28 red
  GD3: ground k28
wires:
  - f3 -- f12 -- f18
  - e6 -- e11 -- e17
  - d9 -- d24
  - f12 |- U1.a
  - e11 |- U1.b
  - f18 |- U2.a
  - e17 |- U2.b
  - d24 |- U3.in
  - U1.out -- h16
  - U2.out -- h22
  - U3.out -- h28
notes:
  # IC の足の番号 (ゲート 1 回路目)
  - text g12g8 small center: "1"
  - text h12e8 small center: "2"
  - text g14h2 small center: "3"
  - text g18g8 small center: "1"
  - text h18e8 small center: "2"
  - text g20h2 small center: "3"
  - text g25h4 small center: "1"
  - text g26h5 small center: "2"
  - text j1 small left: "数字は IC の足の番号 (1 回路目を使う)"
  - text k1 small left: "VDD は 3 つとも足 14 (VCC)、VSS は足 7 (GND)。使わない入力は GND へ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/01-basic-gates.svg)

- U1 (CD4081、AND) と U2 (CD4071、OR) は**同じ A・B** を入力にする。ゲート1
  (足1・2→3) だけを使う
- U3 (CD4069、6 回路入りインバータ) はゲート1 (足1→2) を使う。C を NOT に入れる
- スイッチを開けると入力はプルダウン抵抗 (10kΩ) で 0V (0) に落ち、閉じると
  Vcc (1) になる。CMOS の入力は浮かせてはいけないので、開いている間もプル
  ダウンで電位を決めておく
- 図1 はゲートを論理記号で描き、記号の足に IC の足の番号を添えた。電源の足は記号に
  出ないので図の下に書いた — U1.14・U2.14・U3.14 が VDD (5V)、U1.7・U2.7・U3.7 が VSS (GND)
- **使わない入力は GND へ。** U1・U2 は残り 3 ゲートの入力 (足5・6・8・9・12・13)、
  U3 は残り 5 回路の入力 (足3・5・9・11・13) を GND につなぐ。CMOS の入力は
  浮かせると勝手に振れて電流を食う。出力の足 (U1・U2 の足4・10・11、U3 の足4・6・
  8・10・12) は何もつながずに開けておく

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  A: switch b10 b12
  B: switch b3 b5
  C: switch b45 b47
  RpdA: resistor j24 -b24 10k
  RpdB: resistor j39 -b39 10k
  RpdC: resistor j52 -b52 10k
  U1: dip14 @ e24 CD4081
  U2: dip14 @ e38 CD4071
  U3: dip14 @ e52 CD4069
  R1: resistor g26 g33 330
  D1: led h33(A) h35(K) red
  R2: resistor g40 g45 330
  D2: led h45(A) h46(K) red
  R3: resistor g53 g60 330
  D3: led h60(A) h62(K) red
wires:
  - -t1 -- -b1 black
  - +t3 -- a3 red
  - +t10 -- a10 red
  - +t45 -- a45 red
  - a12 -- a22 yellow
  - e22 -- f22 yellow
  - g22 -- g24 yellow
  - b22 -- b37 yellow
  - e37 -- f37 yellow
  - g37 -- g38 yellow
  - d5 -- d20 green
  - e20 -- f20 green
  - h20 -- h25 green
  - c20 -- c36 green
  - e36 -- f36 green
  - h36 -- h39 green
  - c47 -- g52 blue
  - a24 -- +t24 red
  - j30 -- -b30 black
  - a38 -- +t38 red
  - j44 -- -b44 black
  - a52 -- +t52 red
  - j58 -- -b58 black
  - j35 -- -b35 black
  - j46 -- -b46 black
  - j62 -- -b62 black
  # 使わない入力を GND へ (上は上の青レール、下は下の青レール)
  - a25 -- -t25 black
  - a26 -- -t26 black
  - a29 -- -t29 black
  - a30 -- -t30 black
  - j28 -- -b28 black
  - j29 -- -b29 black
  - a39 -- -t39 black
  - a40 -- -t40 black
  - a43 -- -t43 black
  - a44 -- -t44 black
  - j42 -- -b42 black
  - j43 -- -b43 black
  - a53 -- -t53 black
  - a55 -- -t55 black
  - a57 -- -t57 black
  - j54 -- -b54 black
  - j56 -- -b56 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/01-basic-gates.svg)

- 上の赤レール = +5V (単3 電池 3 本か USB の 5V)、青レール = GND。下の青レールは
  1 列で上の青レールとつなぐ
- U1 (CD4081, AND) は 24〜30 列、U2 (CD4071, OR) は 38〜44 列、U3 (CD4069, NOT)
  は 52〜58 列。どれも切り欠きが左で、足1 が左下 (f 行)、足14 が左上 (e 行)
- 電源: 各 IC の足14 (24・38・52 列の上) を上の赤レールへ、足7 (VSS、30・44・58
  列の下) を下の青レールへ
- スイッチは上ブロック (B が 3〜5 列、A が 10〜12 列、C が 45〜47 列)。**1 つの穴には
  線を 1 本だけ挿す** — 分けるときは同じ列の別の穴から出す (縦の 5 穴は中でつながっている)
  - A (黄): `a12` → `a22`。列 22 で溝をまたいで (`e22` → `f22`)、`g22` → U1 の足 1 (`g24`)。
    U2 へは `b22` → `b37`、列 37 で溝をまたいで (`e37` → `f37`)、`g37` → U2 の足 1 (`g38`)
  - B (緑): `d5` → `d20`。列 20 で溝をまたいで (`e20` → `f20`)、`h20` → U1 の足 2 (`h25`)。
    U2 へは `c20` → `c36`、列 36 で溝をまたいで (`e36` → `f36`)、`h36` → U2 の足 2 (`h39`)
  - C (青): `c47` → U3 の足 1 (`g52`)
- プルダウン抵抗 (RpdA・RpdB・RpdC) は IC の入力の列の j 行から下の青レールへ縦に挿す
  (RpdA は 24 列、RpdB は 39 列、RpdC は 52 列)
- 出力 (U1・U2 の足3 = 26・40 列、U3 の足2 = 53 列) は g 行の 330Ω と h 行の LED を
  通して下の青レールへ
- 使わない入力は黒の短い線で GND へ。上側の足 (U1・U2 の足8・9・12・13、U3 の
  足9・11・13) は a 行から上の青レールへ、下側の足 (U1・U2 の足5・6、U3 の足3・5)
  は j 行から下の青レールへ

## 見るべき値

| A | B | AND (LED1) | OR (LED2) |
| --- | --- | --- | --- |
| 0 | 0 | 消灯 | 消灯 |
| 1 | 0 | 消灯 | **点灯** |
| 0 | 1 | 消灯 | **点灯** |
| 1 | 1 | **点灯** | **点灯** |

| C | NOT (LED3) |
| --- | --- |
| 0 | **点灯** |
| 1 | 消灯 |

AND は両方閉じたときだけ点く。OR はどちらか片方でも点く。NOT はスイッチを
**開けている間だけ**点く (入力 0 → 出力 1)。

## 出典

自作。
