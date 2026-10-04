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

デジタル回路は、電圧の高い・低いを 1 と 0 として扱う。1 は H レベル (High、
ほぼ電源の電圧)、0 は L レベル (Low、ほぼ 0 V)。入力の 0・1 から決まった規則で
出力の 0・1 を決める回路を**ゲート**と呼び、どんなデジタル回路もゲートの組み合わせで
できている。この題では、いちばん基本の 3 つのゲートを LED で確かめる。

- AND: 入力が両方 1 のときだけ出力が 1
- OR: 入力のどちらか 1 つでも 1 なら出力が 1
- NOT (インバータ): 入力の反対を出す (0 なら 1、1 なら 0)

ゲートの IC は CD4000 系の CMOS (MOSFET で作ったロジック IC。入力にほとんど電流が
流れない) を使う。IC を 3 つ並べ、同じ 2 つのスイッチ入力 (A・B) を AND と OR の
両方に入れて出力を比べる。もう 1 つのスイッチ C は NOT に入れる。
LED が点いていれば出力は 1、消えていれば 0。

## 回路図

```circuit
title: 図1 AND・OR・NOTを並べて比べる
parts:
  A: switch d3 f3
  RpdA: resistor f3 f1 10k
  GA: ground f1
  B: switch c6 e6
  RpdB: resistor e6 e4 10k
  GB: ground e4
  C: switch b9 d9
  RpdC: resistor d9 d7 10k
  GC: ground d7
  VCC: vcc d3 5V
  VCC: vcc c6 5V
  VCC: vcc b9 5V
  U1: and h14 CD4081
  U2: or h20 CD4071
  U3: not h26 CD4069
  R1: resistor h16 j16 1k
  D1: led j16 k16 red
  GD1: ground k16
  R2: resistor h22 j22 1k
  D2: led j22 k22 red
  GD2: ground k22
  R3: resistor h28 j28 1k
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
  # IC の PIN 番号 (ゲート 1 回路目)
  - text g12g8 small center: "1"
  - text h12e8 small center: "2"
  - text g14h2 small center: "3"
  - text g18g8 small center: "1"
  - text h18e8 small center: "2"
  - text g20h2 small center: "3"
  - text g25h4 small center: "1"
  - text g26h5 small center: "2"
  - text j1 small left: "数字は IC の PIN 番号 (1 回路目を使う)"
  - text k1 small left: "VDD は 3 つとも PIN 14 (+5V)、VSS は PIN 7 (GND)。使わない入力は GND へ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/01-basic-gates.svg)

- U1 (CD4081、AND) と U2 (CD4071、OR) は同じ A・B を入力にする。どちらも 4 回路入りで、
  ゲート1 (PIN 1・2→3) だけを使う
- U3 (CD4069、6 回路入りインバータ) はゲート1 (PIN 1→2) を使う。C を NOT に入れる
- スイッチを開けると、入力はプルダウン抵抗 (RpdA〜RpdC、10kΩ。GND へ引き下げる抵抗) で
  0V (0) に落ちる。閉じると +5V (1) になる。CMOS の入力は浮かせると 0 とも 1 とも
  決まらないので、開いている間もプルダウンで電位を決めておく
- 図1 はゲートを論理記号で描き、記号の足に IC の PIN 番号を添えた。電源の足は記号に
  出ないので図の下に書いた。3 つの IC とも PIN 14 が VDD (+5V)、PIN 7 が VSS (GND)
- 使わない入力は GND へつなぐ。U1・U2 は残り 3 ゲートの入力 (PIN 5・6・8・9・12・13)、
  U3 は残り 5 回路の入力 (PIN 3・5・9・11・13) が対象。CMOS の入力は浮かせると勝手に
  振れて電流を食う。出力の足 (U1・U2 の PIN 4・10・11、U3 の PIN 4・6・8・10・12) は
  何もつながずに開けておく

### LED の抵抗を 1kΩ にする理由

CD4000 系の出力は、電流を取り出すほど電圧が下がる。H を出している出力から流し出せる電流を
I<sub>OH</sub> と呼ぶ。TI のデータシート (CD4081B、V<sub>DD</sub> = 5V、25℃) では、
出力が 4.6V のとき最小 0.51mA (標準 1mA)、2.5V まで下がったときでも最小 1.6mA
(標準 3.2mA) しかない。CD4071B と CD4069UB のデータシートも同じ値。
5V で動かす CD4000 系の出力は数 mA が限度なので、330Ω で
(5V − 2.0V) / 330Ω ≈ 9.1mA を流す設計にすると、出力の電圧が落ちて計算と合わない。

そこで LED の直列抵抗 R1〜R3 を 1kΩ にして、電流を 2mA 前後に抑える。出力の電圧を
V<sub>OH</sub>、LED の順方向電圧を V<sub>F</sub> (赤の LED を 2mA で使うとき約 1.8V、目安) とすると、

I = (V<sub>OH</sub> − V<sub>F</sub>) / R

V<sub>OH</sub> は流す電流で決まる。出力の電圧の落ちと電流の関係を上の 2 点を通る曲線で表し、
この式と両方を満たす点を python で解くと次のようになる (目安)。

- 標準の品: V<sub>OH</sub> ≈ 4.0V、I = (4.0V − 1.8V) / 1kΩ ≈ 2.2mA
- 最小の品: V<sub>OH</sub> ≈ 3.3V、I = (3.3V − 1.8V) / 1kΩ ≈ 1.5mA

2mA 前後でも LED の点灯は見て分かる。暗いときは高輝度 LED にするか、出力の強い
74HC 系 (AND は 74HC08、OR は 74HC32、NOT は 74HC04) に替える。

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
  R1: resistor g26 g33 1k
  D1: led h33(A) h35(K) red
  R2: resistor g40 g45 1k
  D2: led h45(A) h46(K) red
  R3: resistor g53 g60 1k
  D3: led h60(A) h62(K) red
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
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

- 電源は Analog Discovery 3 (AD3、0-3 で使った USB 計測器) の Supplies。WaveForms の Supplies で
  V+ を 5V にする (単3 電池 3 本や USB の 5V でもよい)。上の赤レール = +5V、青レール = GND。
  AD3 の V+ (赤) は上の赤レールの 1 列、GND (黒) は上の青レールの 2 列へ (AD3 は板の左上に置く)。下の青レールは
  1 列で上の青レールとつなぐ
- U1 (CD4081, AND) は 24〜30 列、U2 (CD4071, OR) は 38〜44 列、U3 (CD4069, NOT)
  は 52〜58 列。どれも切り欠きが左で、PIN 1 が左下 (f 行)、PIN 14 が左上 (e 行)
- 電源: 各 IC の PIN 14 (24・38・52 列の上) を上の赤レールへ、PIN 7 (VSS、30・44・58
  列の下) を下の青レールへ
- スイッチは上ブロック (B が 3〜5 列、A が 10〜12 列、C が 45〜47 列)。1 つの穴には
  線を 1 本だけ挿す。分けるときは同じ列の別の穴から出す (縦の 5 穴は中でつながっている)
  - A (黄): `a12` → `a22`。列 22 で溝をまたいで (`e22` → `f22`)、`g22` → U1 の PIN 1 (`g24`)。
    U2 へは `b22` → `b37`、列 37 で溝をまたいで (`e37` → `f37`)、`g37` → U2 の PIN 1 (`g38`)
  - B (緑): `d5` → `d20`。列 20 で溝をまたいで (`e20` → `f20`)、`h20` → U1 の PIN 2 (`h25`)。
    U2 へは `c20` → `c36`、列 36 で溝をまたいで (`e36` → `f36`)、`h36` → U2 の PIN 2 (`h39`)
  - C (青): `c47` → U3 の PIN 1 (`g52`)
- プルダウン抵抗 (RpdA・RpdB・RpdC) は IC の入力の列の j 行から下の青レールへ縦に挿す
  (RpdA は 24 列、RpdB は 39 列、RpdC は 52 列)
- 出力 (U1・U2 の PIN 3 = 26・40 列、U3 の PIN 2 = 53 列) は g 行の 1kΩ と h 行の LED を
  通して下の青レールへ
- 使わない入力は黒の短い線で GND へ。上側の足 (U1・U2 の PIN 8・9・12・13、U3 の
  PIN 9・11・13) は a 行から上の青レールへ、下側の足 (U1・U2 の PIN 5・6、U3 の PIN 3・5)
  は j 行から下の青レールへ

## 計器の設定

計器は AD3 の Supplies (電源) だけを使い、出力の 0・1 は LED とテスターで読む。
この題はオシロの図を付けない — スイッチを止めている間の直流の電圧 (0 か 1) だけを見る題で、時間で変わる量が無いため。

板を流れる電流は、LED 3 個が全部点いても約 2.2mA × 3 ≈ 7mA と、閉じたスイッチのプルダウンに流れる
5V / 10kΩ = 0.5mA × 3 で、合わせて 10mA に満たない。板の範囲 (1 穴 200mA・板全体 500mA) にも、
AD3 の V+ を USB 給電で使うときの目安 (5V で 50mA) にも収まる。

## 見るべき値

| A | B | AND (D1) | OR (D2) |
| --- | --- | --- | --- |
| 0 | 0 | 消灯 | 消灯 |
| 1 | 0 | 消灯 | **点灯** |
| 0 | 1 | 消灯 | **点灯** |
| 1 | 1 | **点灯** | **点灯** |

| C | NOT (D3) |
| --- | --- |
| 0 | **点灯** |
| 1 | 消灯 |

スイッチは閉じると 1、開けると 0。AND は A・B を両方閉じたときだけ点く。OR はどちらか
片方でも点く。NOT は C を開けている間だけ点く (入力 0 → 出力 1)。

テスターで確かめるなら、直流電圧レンジで各 IC の出力の PIN (U1・U2 は PIN 3、U3 は PIN 2) と
GND の間を測る。LED が点いているときは約 3.3〜4V (1)、消えているときはほぼ 0V (0) になる。

## 出典

自作。
