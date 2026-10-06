---
book: etc
chapter: 1
id: 1-3
title: レジスタ — 4 ビットを D フリップフロップで覚える
tier: 200
source: 自作
board: BB
---

# 1-3 レジスタ — 4 ビットを D フリップフロップで覚える

[1-2](02-alu-like.md) の ALU は、スイッチを倒すとすぐに答えが変わる。答えを取っておく場所が無い。
CPU は計算の途中の値を**レジスタ**に覚えておく。レジスタは D フリップフロップ
([回路の本の 10-5](../../01-circuits/10-logic/05-d-flip-flop.md)) を必要なビット数だけ並べたもので、
クロックの立ち上がりの瞬間に D の値を取り込み、次の立ち上がりまで Q に出し続ける。

この題では、4 ビットのレジスタを 74HC273 で組む。ただし 74HC273 は**立ち上がりのたびに必ず**取り込む。
「覚えたままにする」には、**書き込み許可 (LOAD)** を自分で作らなければならない。
ここでは 74HC157 (2 → 1 のセレクタ) で「新しい値」か「今の値」を選んで D に戻す。
このレジスタは、[1-4](04-cpu-mimic.md) で CPU もどきの ACC (アキュムレータ) になる。

## 全体の構成

```text
 SW1 (IN0〜IN3) ----B---> [ U2  74HC157 ] --Y--> D [ U1  74HC273 ] Q --+--> LED 4 つ (図3)
                   +-A--> [ 選択 = LOAD ]          [ CLK = W1     ]    |
                   |                                                    |
                   +----------------------- Q0〜Q3 (今の値) <-----------+
 SW2 の 1 番 (LOAD) --> 選択      AD3 の W1 (1 Hz) --> CLK      S1 --> CLR (0 にする)
```

1. LOAD = 1 のとき、U2 は B (スイッチの IN) を選ぶ。次のクロックの立ち上がりで U1 が IN を取り込む
2. LOAD = 0 のとき、U2 は A (U1 の Q、今の値) を選ぶ。立ち上がりで U1 は**今の値をもう一度取り込む**ので、値は変わらない
3. S1 を押すと、U1 の CLR が L になり、クロックを待たずに Q が 0 になる (非同期のクリア)

| LOAD | U2 が選ぶ | 立ち上がりのあとの Q |
| --- | --- | --- |
| 0 | A = Q | 今の値のまま |
| 1 | B = IN | IN (スイッチの値) |

## D フリップフロップの IC を選ぶ

74HC で D フリップフロップを 4 ビット以上まとめた IC は、ピンの名前の表にある 3 つから選ぶ。

| 型番 | ビット | クリア | 出力 | ピン | 書き込み許可 |
| --- | --- | --- | --- | --- | --- |
| 74HC175 | 4 | あり (CLR、非同期) | Q と /Q (反転) | DIP-16 | 無し |
| 74HC273 | 8 | あり (CLR、非同期) | Q | DIP-20 | 無し |
| 74HC574 | 8 | 無し | Q (3 ステート。OE が H で切り離す) | DIP-20 | 無し |

**74HC273 を選んだ。** 理由は 3 つ。

1. **クリアがある。** 1-4 の ACC は、走らせる前に 0 にしたい。74HC574 にはクリアが無く、0 を書き込むには
   スイッチで 0 を作って LOAD する手間が要る
2. **出力は Q だけ。** 74HC175 は Q と /Q の 2 本がビットごとに出ていて、取り違えやすい。74HC273 は 1 ビットにつき D と Q の 2 本だけだ
3. **8 ビットある。** 使うのは 4 ビットだが、残りの 4 ビットで 1-4 の ACC を 8 ビットに広げたり、桁上がりを覚えたりできる。
   使わない 5D〜8D は GND につなぐ (CMOS の入力を開けておかない)

74HC175 でも同じ回路になる。4 ビットにちょうどよく、ピンも少ない (DIP-16)。替えるときのピンの対応は次のとおりで、/Q (PIN 3・6・11・14) は使わない。

| 働き | 74HC273 | 74HC175 |
| --- | --- | --- |
| CLR | PIN 1 | PIN 1 |
| CLK | PIN 11 | PIN 9 |
| D0〜D3 | PIN 3・4・7・8 | PIN 4・5・12・13 |
| Q0〜Q3 | PIN 2・5・6・9 | PIN 2・7・10・15 |
| VCC / GND | PIN 20 / 10 | PIN 16 / 8 |

## 書き込み許可の作り方

3 つの IC のどれにも書き込み許可が無い。立ち上がりのたびに D を取り込んでしまう。作り方は 2 とおりある。

| 作り方 | 回路 | よい所 | 困る所 |
| --- | --- | --- | --- |
| **D に戻す (この題)** | 74HC157 で D に「IN」か「Q」を選んで入れる | クロックはそのまま。全部のフリップフロップが同じ瞬間に動く (同期式) | IC が 1 個増える |
| クロックを止める | CLK を LOAD とのゲート (74HC08 など) に通す | IC は 74HC08 の 1 ゲートで済む | ゲートの遅れでクロックがずれる。LOAD がクロックの H の間に変わると、余分な立ち上がりができる |

**クロックには手を付けず、D に戻す**のが同期式の回路の定石だ。1-4 では PC (74HC163) と ACC が同じクロックで動くので、
クロックを止める作り方では ACC だけが少し遅れて動く。この題では D に戻す作り方にした。
書き込み許可の付いた IC (74HC377・74HC173 など) もあるが、許可の中身を見せるために使わない。

## 回路図

回路図は 3 枚に分ける。図1 が入力、図2 がセレクタとレジスタ、図3 が表示だ。
**同じ名前の端子 (IN0〜IN3・LOAD・Q0〜Q3・CLK) は、図をまたいで同じ線**になる。

```circuit
title: 図1 入力のスイッチ (書き込む値 IN0 から IN3 と LOAD)
parts:
  VCC: vcc b2 5V
  SI0: switch b2 b5 l=$\mathrm{SW1}_1$
  R1: resistor b5 c5 10k
  G1: ground c5
  IN0: port b9
  VCC: vcc d2 5V
  SI1: switch d2 d5 l=$\mathrm{SW1}_2$
  R2: resistor d5 e5 10k
  G2: ground e5
  IN1: port d9
  VCC: vcc f2 5V
  SI2: switch f2 f5 l=$\mathrm{SW1}_3$
  R3: resistor f5 g5 10k
  G3: ground g5
  IN2: port f9
  VCC: vcc h2 5V
  SI3: switch h2 h5 l=$\mathrm{SW1}_4$
  R4: resistor h5 i5 10k
  G4: ground i5
  IN3: port h9
  VCC: vcc j2 5V
  SL: switch j2 j5 l=$\mathrm{SW2}_1$
  R5: resistor j5 k5 10k
  G5: ground k5
  LOAD: port j9
wires:
  - b5 -- b9
  - d5 -- d9
  - f5 -- f9
  - h5 -- h9
  - j5 -- j9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/03-register-1.svg)

- スイッチは DIP スイッチの 1 つ 1 つを別に描いた。SW1 の 1〜4 番が IN0〜IN3、SW2 の 1 番が LOAD。
  ON で 1 (+5V)、OFF で 0 (10 kΩ で GND へ)。SW2 の 2〜4 番は使わない

```circuit
title: 図2 74HC157 で新しい値か今の値を選び、74HC273 で覚える
parts:
  U2: ic h12 74HC157
  VCC: vcc d12 5V
  GU2: ground m12
  LOAD: port f8
  Q0: port f7f0
  IN0: port g8
  Q1: port g7f0
  IN1: port h8
  Q2: port h7f0
  IN2: port i8
  Q3: port i7f0
  IN3: port j8
  U1: ic i22f0 74HC273
  VCC: vcc e22 5V
  GU1: ground m22
  GD5: ground i18f0 r90
  GD6: ground j18 r90
  GD7: ground j18f0 r90
  GD8: ground k18 r90
  CLK: port k18f0
  VCC: vcc d26 5V
  R6: resistor d26 f26 10k
  S1: button f26 f29
  GS: ground f29
  Q0: port h26
  Q1: port h28f0
  Q2: port i26
  Q3: port i28f0
wires:
  - U2.VCC |- d12
  - U2.GND |- m12
  - U2.G |- m12
  - U2.A/B -| f8
  - U2.1A -| f7f0
  - U2.1B -| g8
  - U2.2A -| g7f0
  - U2.2B -| h8
  - U2.3A -| h7f0
  - U2.3B -| i8
  - U2.4A -| i7f0
  - U2.4B -| j8
  - U2.1Y -- U1.1D
  - U2.2Y -- U1.2D
  - U2.3Y -- U1.3D
  - U2.4Y -- U1.4D
  - U1.5D -| i18f0
  - U1.6D -| j18
  - U1.7D -| j18f0
  - U1.8D -| k18
  - U1.CLK -| k18f0
  - U1.VCC |- e22
  - U1.GND |- m22
  - U1.CLR |- f26
  - U1.1Q -| h26
  - U1.2Q -| h28f0
  - U1.3Q -| i26
  - U1.4Q -| i28f0
notes:
  - text n2 small: "LOAD が 0 なら A (今の値 Q)、1 なら B (新しい値 IN) を選ぶ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/03-register-2.svg)

- U2 (74HC157) と U1 (74HC273) は**働きでピンを並べた記号**で描いた。箱の中の `02 1A` は PIN 2 が 1A だ。
  実物の DIP のピンの順とは違うので、組むときは PIN の番号で探す
- U2 の左は、選択の A/B (PIN 1) と、4 組の A・B。A が今の値 (Q0〜Q3)、B が新しい値 (IN0〜IN3) だ。
  **A/B が L なら A、H なら B** が Y に出る。A/B に LOAD をつなぐ。G (PIN 15) は L で働くので GND につなぐ
- U2 の Y (1Y〜4Y) が U1 の D (1D〜4D) へまっすぐ入る。U1 の 5D〜8D は GND につなぐ
- U1 の CLK (PIN 11) に AD3 の W1 (0〜5 V、1 Hz) をつなぐ。CLR (PIN 1) は R6 (10 kΩ) で +5V へ引き、S1 を押すと GND に落ちる
- U1 の Q (1Q〜4Q) は Q0〜Q3 の線になり、図3 の LED と、U2 の A へ戻る。**この戻る線が「覚えたまま」を作る**。5Q〜8Q は使わない

```circuit
title: 図3 覚えた値の表示 (LED 4 つ)
parts:
  Q0: port b2
  R7: resistor b3 b6 820
  D1: led b6 b9 red
  GD1: ground b9
  Q1: port d2
  R8: resistor d3 d6 820
  D2: led d6 d9 red
  GD2: ground d9
  Q2: port f2
  R9: resistor f3 f6 820
  D3: led f6 f9 red
  GD3: ground f9
  Q3: port h2
  R10: resistor h3 h6 820
  D4: led h6 h9 red
  GD4: ground h9
wires:
  - b2 -- b3
  - d2 -- d3
  - f2 -- f3
  - h2 -- h3
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/circuit/03-register-3.svg)

- Q0〜Q3 に、820 Ω と赤の LED を 1 つずつつなぐ。1 が点灯。電流は (5 − 1.9) ÷ 820 ≒ 3.8 mA (順方向電圧 1.9 V は仮定) で、
  74HC の出力の保証 (±4 mA) に収まる

## 実体配線図

**ブレッドボードは full 1 枚。** 左から、DIP スイッチ 2 個と集合抵抗、U2 (74HC157)、U1 (74HC273)、S1、LED 4 つの順に置く。
IC 2 個 (18 列) と DIP スイッチ 2 個 (8 列) と LED 4 つ (12 列) は half (30 列) に収まらない。

```breadboard
title: 図4 4 ビットのレジスタをブレッドボードに組む
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, DIO6, DIO7, DIO8, DIO9, DIO5, W1, DIO4, DIO3, DIO2, DIO1, DIO0]
  RN1: sip9 @ b1 l=10k-8
  SW1: dip-switch4 @ e2
  SW2: dip-switch4 @ e6
  U2: dip16 @ e13 74HC157
  U1: dip20 @ e24 74HC273
  S1: button @ e36
  R6: resistor j36 +b36 10k
  R10: resistor e41 g41 820
  D4: led h41(A) h42(K) red
  R9: resistor e44 g44 820
  D3: led h44(A) h45(K) red
  R8: resistor e47 g47 820
  D2: led c47(A) c48(K) red
  R7: resistor e50 g50 820
  D1: led c50(A) c51(K) red
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t63 -- +b63 red
  - -t63 -- -b63 black
  - a1 -- -t1 black
  - j2 -- +b2 red
  - j3 -- +b3 red
  - j4 -- +b4 red
  - j5 -- +b5 red
  - j6 -- +b6 red
  - a13 -- +t13 red
  - a14 -- -t14 black
  - j20 -- -b20 black
  - a24 -- +t24 red
  - j33 -- -b33 black
  - a26 -- -t26 black
  - a27 -- -t27 black
  - a30 -- -t30 black
  - a31 -- -t31 black
  - a36 -- -t36 black
  - j42 -- -b42 black
  - j45 -- -b45 black
  - a48 -- -t48 black
  - a51 -- -t51 black
  - c2 -- h15 blue
  - c3 -- h18 blue
  - c4 -- c19 blue
  - c5 -- c16 blue
  - c6 -- h13 white
  - AD.DIO6 -- a2 orange
  - AD.DIO7 -- a3 orange
  - AD.DIO8 -- a4 orange
  - AD.DIO9 -- a5 orange
  - AD.DIO5 -- a6 orange
  - g16 -- g26 green
  - i19 -- i27 green
  - b20 -- b22 green
  - e22 -- f22 green
  - h22 -- h30 green
  - d17 -- d23 green
  - e23 -- f23 green
  - i23 -- i31 green
  - g25 -- g14 yellow
  - h25 -- h50 yellow
  - g28 -- g17 yellow
  - h28 -- h47 yellow
  - i29 -- i21 yellow
  - e21 -- f21 yellow
  - c21 -- c18 yellow
  - h32 -- h34 yellow
  - e34 -- f34 yellow
  - c34 -- c15 yellow
  - b34 -- b41 yellow
  - b21 -- b44 yellow
  - i24 -- i36 white
  - AD.W1 -- a33 purple
  - AD.DIO4 -- b33 orange
  - AD.DIO0 -- i50 orange
  - AD.DIO1 -- i47 orange
  - AD.DIO2 -- a44 orange
  - AD.DIO3 -- a41 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/breadboard/03-register.svg)

- **電源**: AD3 の V+ (5V、赤) を上の + レールの 1 列に、GND (黒) を上の − レールの 2 列に入れる。上と下のレールは、
  右の端 (63 列) で + どうしと − どうしをつなぐ。**赤は +5V の線だけ、黒は GND の線だけ**に使った
- **DIP スイッチ**: SW1 (IN0〜IN3) は 2〜5 列、SW2 は 6〜9 列 (使うのは 1 番 = 6 列の LOAD だけ)。下の組を +5V (赤の線で下の + レールへ)、
  上の組を入力の線にした。集合抵抗 RN1 (10 kΩ × 8、9 ピン) は b 行の 1〜9 列で、共通のピン (1 列) を上の − レールへ落とす。
  RN1 の 7〜9 番のピンは、使わない SW2 の 2〜4 番の列に入るだけで、何もしない
- **IC の向き**: 2 個とも切り欠きが左。U2 (74HC157) は 13〜20 列、U1 (74HC273) は 24〜33 列。
  U2 は VCC (13 列の上) を上の + レールへ、G (14 列の上) を上の − レールへ、GND (20 列の下) を下の − レールへ落とす。
  U1 は VCC (24 列の上) を上の + レールへ、GND (33 列の下) を下の − レールへ、5D〜8D (26・27・30・31 列の上) を上の − レールへ落とす
- **列をまたぐ線**: U2 の 3Y・4Y は上の組に、U1 の 3D・4D は下の組にある。21〜23 列と 34 列を中継に使い、溝をまたぐ短い線
  (`e22 -- f22` など) で上と下をつなぐ。21 列が Q2、22 列が 3Y → 3D、23 列が 4Y → 4D、34 列が Q3 の中継だ
- **線の色**: 青 = IN0〜IN3、白 = LOAD と CLR、緑 = Y → D、黄 = Q0〜Q3、紫 = CLK (AD3 の W1)、橙 = AD3 の DIO
- **S1 (CLR)**: 36〜38 列。下の組 (36 列の下) を U1 の CLR (24 列の下) と R6 (10 kΩ、+5V へ) に、上の組を上の − レールにつなぐ。
  押すと下の組と上の組がつながり、CLR が GND に落ちる
- **LED**: 41 列から 3 列おきに Q3・Q2・Q1・Q0 (左が上の桁)。Q3・Q2 は上の組から抵抗が溝をまたぎ、LED は下 (h 行) でカソードを下の − レールへ。
  Q1・Q0 は線が下の組に来るので、抵抗を下から上へ渡し、LED は上 (c 行) でカソードを上の − レールへ落とす。
  どちらも LED の長いピン (アノード) が抵抗の側だ
- 下の組 (g〜j 行) の線は、行き先の間の穴がふさがっているので、図ではブレッドボードの下の縁に沿って回してある。
  実物では、**下の「回路図との対応」の表の穴どうしを 1 本ずつ**つなげばよい
- **1 つの穴には 1 本だけ**挿している

### 回路図との対応

| 線の名前 | 回路図 | ブレッドボード (始め → 終わり) |
| --- | --- | --- |
| IN0 / IN1 | SW1₁・SW1₂ → U2 1B・2B (PIN 3・6) | `c2` → `h15`、`c3` → `h18` |
| IN2 / IN3 | SW1₃・SW1₄ → U2 3B・4B (PIN 10・13) | `c4` → `c19`、`c5` → `c16` |
| LOAD | SW2₁ → U2 A/B (PIN 1) | `c6` → `h13` |
| 1Y → 1D | U2 PIN 4 → U1 PIN 3 | `g16` → `g26` |
| 2Y → 2D | U2 PIN 7 → U1 PIN 4 | `i19` → `i27` |
| 3Y → 3D | U2 PIN 9 → U1 PIN 7 | `b20` → `b22`、`e22` → `f22`、`h22` → `h30` |
| 4Y → 4D | U2 PIN 12 → U1 PIN 8 | `d17` → `d23`、`e23` → `f23`、`i23` → `i31` |
| Q0 | U1 1Q (PIN 2) → U2 1A (PIN 2)、R7 | `g25` → `g14`、`h25` → `h50` |
| Q1 | U1 2Q (PIN 5) → U2 2A (PIN 5)、R8 | `g28` → `g17`、`h28` → `h47` |
| Q2 | U1 3Q (PIN 6) → U2 3A (PIN 11)、R9 | `i29` → `i21`、`e21` → `f21`、`c21` → `c18`、`b21` → `b44` |
| Q3 | U1 4Q (PIN 9) → U2 4A (PIN 14)、R10 | `h32` → `h34`、`e34` → `f34`、`c34` → `c15`、`b34` → `b41` |
| CLR | U1 PIN 1、R6、S1 | `i24` → `i36`、R6 は `j36` → 下の + レール |
| CLK | W1 → U1 PIN 11 | AD3 の W1 → `a33` |

`breadboard-fence check` のネットリストは、この表のとおりだった (たとえば Q2 の線は `AD.DIO2, U2.3A, U1.3Q, R9.1`、
CLR の線は `U1.CLR, S1.2a, S1.2b, R6.1`)。このネットリストと回路図 (図2) のネットリストを Python で読み、
74HC157 と 74HC273 の働きを当ててクロックを 1 つずつ進め、下の「見るべき値」の表と同じ Q の並びになることを確かめた (実機では測っていない)。

### ブレッドボードの限度の確認

電圧は 5V (12V 以下)。電流は、LED 4 つが全部点いて 3.8 mA × 4 ≒ 15 mA、閉じたスイッチのプルダウンが最大 5 本で
0.5 mA × 5 = 2.5 mA、R6 は S1 を押した間だけ 0.5 mA、IC の静止電流は数 µA で、**合計は最大でも約 18 mA**。
1 穴 200 mA・ブレッドボード全体 500 mA の限度より十分に小さい。周波数はクロックの **1 Hz** で、ブレッドボードの 3 MHz の限度に十分収まる。
この回路の上限は、U1 の CLK → Q (最大 32 ns) + U2 の A → Y (最大 25 ns) + U1 の準備時間 (20 ns) ≒ 77 ns で決まり、
約 13 MHz の見積もりになる (データシートの 25 ℃・4.5 V の最大値による計算で、実測していない。ブレッドボードでは 3 MHz までにとどめる)。

## 計器の設定

**計器は Analog Discovery 3 (AD3) 1 台**で、電源 (Supplies)・クロック (Wavegen)・観測 (Logic) を兼ねる。
AD3 の DIO は 3.3V の LVCMOS で、5V まで入れてよい。CLK・LOAD・IN の 4 本・Q の 4 本の合計 10 本を Logic で見る。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V にして Master Enable を入れる |
| Wavegen | W1: **Square**、Frequency **1 Hz**、Amplitude **2.5 V**、Offset **2.5 V** (0〜5 V)、Symmetry 50 % |
| Logic | **DIO0〜DIO3 = Q0〜Q3、DIO4 = CLK、DIO5 = LOAD、DIO6〜DIO9 = IN0〜IN3** (図4 の配線)。IN と Q をそれぞれ 16 進のバスにまとめる。Time base **1 s/div** (窓 10 s)、Mode は Record、Sample rate 1 kHz。Trigger は **DIO4 (CLK) の立ち上がり**。WaveForms の項目の名前は確認していない |
| 接続 | AD3 の GND を上の − レールへ |

手順: SW1 を 0101 (IN = 5)、SW2 の 1 番 (LOAD) を OFF にする。S1 を押して Q を 0 にする (LED が全部消える)。
Logic を走らせ、下の表のとおりにスイッチを倒す。**スイッチは、クロックが変わる時刻 (整数の秒) から離れた所で倒す**。
立ち上がりの直前 20 ns (U1 の準備時間) の間に LOAD や IN が変わると、取り込むのは前の値か新しい値か決まらない。

| 時刻 | 倒すスイッチ | そのあとの LOAD・IN |
| --- | --- | --- |
| 0.5 s | SW2 の 1 番を ON | LOAD = 1、IN = 5 |
| 1.5 s | SW2 の 1 番を OFF | LOAD = 0 |
| 3.5 s | SW1 を 1010 に | IN = A (10) |
| 4.5 s | SW2 の 1 番を ON | LOAD = 1 |
| 5.5 s | SW2 の 1 番を OFF | LOAD = 0 |
| 6.5 s | SW1 を 0011 に | IN = 3 |

## 計器の画面

図5 は、上の手順で見えるはずの Logic の画面だ (計算で作った理想の形で、実測ではない)。
カーソルは **X1 = 3.75 s** (IN は A に変わったが、Q は 5 のまま) と **X2 = 5.25 s** (5 s の立ち上がりで A を覚えた) に置いた。

```logic
title: 図5 LOAD が 1 の間の立ち上がりだけ、IN を Q に覚える (計算)
device: ad3
time: 1s/div
sample: 1kHz
signals:
  CLK: dio4 clock 1Hz
  LOAD: dio5 edges 0s=0 500ms=1 1500ms=0 4500ms=1 5500ms=0
  IN0: dio6 edges 0s=1 3500ms=0 6500ms=1
  IN1: dio7 edges 0s=0 3500ms=1
  IN2: dio8 edges 0s=1 3500ms=0
  IN3: dio9 edges 0s=0 3500ms=1 6500ms=0
  Q: dio0..dio3 counter on CLK rising sequence 0 5 5 5 5 10 10 10 10 10
buses:
  IN: IN3..IN0 hex
  Qbus: Q3..Q0 hex
cursors: [3.75s, 5.25s]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/01-cpu/logic/03-register.svg)

## 見るべき値 (目安)

下の表は、図2 の結線どおりに Python で 1 クロックずつ計算した値だ。実機では測っていない。
「立ち上がりの直前」の LOAD と IN で、立ち上がりのあとの Q が決まる。

| 立ち上がり | 直前の LOAD | 直前の IN | U2 が選ぶ | 立ち上がりのあとの Q | LED (Q3〜Q0) |
| --- | --- | --- | --- | --- | --- |
| 0 s | 0 | 5 | Q (= 0) | 0 | ○○○○ |
| 1 s | **1** | 5 | IN | **5** | ○●○● |
| 2 s | 0 | 5 | Q | 5 | ○●○● |
| 3 s | 0 | 5 | Q | 5 | ○●○● |
| 4 s | 0 | **A** | Q | **5 のまま** | ○●○● |
| 5 s | **1** | A | IN | **A** | ●○●○ |
| 6 s | 0 | A | Q | A | ●○●○ |
| 7 s | 0 | **3** | Q | **A のまま** | ●○●○ |
| 8・9 s | 0 | 3 | Q | A | ●○●○ |

(● が点灯、○ が消灯)

- **LOAD が 1 の間にある立ち上がり (1 s と 5 s) だけ**、Q が IN に替わる。LOAD を 1 秒間 ON にすると、立ち上がりはちょうど 1 回入る
- 4 s と 7 s は、IN が変わったあとの立ち上がりだが、LOAD = 0 なので Q は変わらない。**これが「覚えている」状態**だ
- 図5 の**カーソル**: X1 (3.75 s) は IN = 0xA・Qbus = 0x5・LOAD = 0。X2 (5.25 s) は IN = 0xA・Qbus = 0xA・LOAD = 1
- 図5 の Q の並びは `0x0@0 s 0x5@1 s 0xA@5 s`、IN の並びは `0x5@0 s 0xA@3.5 s 0x3@6.5 s` (`logic-fence check` の読み値)
- S1 を押すと、クロックを待たずに Q が 0 になる (LED が全部消える)。CLR が L の間は、立ち上がりがあっても 0 のままだ

| 電圧・電流・時間 (計算値) | 値 |
| --- | --- |
| LED 1 つの電流 | (5 − 1.9) ÷ 820 ≒ 3.8 mA (順方向電圧は仮定) |
| 全体の電流 | 最大でも約 18 mA |
| 立ち上がりから Q が変わるまで | 最大 32 ns (74HC273 の CLK → Q、25 ℃・4.5 V) |
| LOAD・IN を変えてはいけない時間 | 立ち上がりの前 20 ns (準備時間)。立ち上がりの後は 0 ns (保持時間) |

## 部品

電源は AD3 の V+ (5 V)。

| 記号 | 部品 | 値・型番 | 数 |
| --- | --- | --- | --- |
| U1 | 8 ビット D フリップフロップ、クリア付き (DIP-20) | 74HC273 (SN74HC273N など) | 1 |
| U2 | 2 → 1 セレクタ × 4 (DIP-16) | 74HC157 (SN74HC157N など) | 1 |
| SW1、SW2 | 4 連 DIP スイッチ (DIP-8、幅 0.3 インチ) | ピッチ 2.54 mm。n 番が PIN n と PIN 9−n をつなぐ品 | 2 |
| RN1 | 集合抵抗 (SIL 9 ピン、共通付き) | 10 kΩ × 8 (図1 の R1〜R5 を兼ねる。3 本は空き) | 1 |
| R6 | 抵抗 (1/4 W) | 10 kΩ | 1 |
| R7〜R10 | 抵抗 (1/4 W) | 820 Ω | 4 |
| D1〜D4 | LED 5 mm | 赤 | 4 |
| S1 | タクトスイッチ | 6 mm | 1 |
| — | ブレッドボード | full 1 枚 | 1 |
| — | ジャンパ線 | 赤・黒・各色 | 適宜 |

- 74HC273 の代わりに 74HC175 を使うときは、上の「D フリップフロップの IC を選ぶ」のピンの対応のとおりにつなぐ
- 型番の入手性は確認していない

## 出典

自作。74HC273 のピンの並び・クリア (非同期、L で 0)・準備時間 (データ 20 ns・CLR の解除 20 ns)・保持時間 (0 ns)・
CLK → Q の伝搬遅延 (最大 32 ns)・最大のクロック (27 MHz) は、25 ℃・VCC = 4.5 V の値で TI の SN74HC273 データシート (SCLS136F) による。
74HC157 の真理値表 (A/B が L で A) と伝搬遅延 (A・B → Y が最大 25 ns) は TI の SN74HC157 データシート (SCLS113F)、
74HC175 の働き (4 ビット、Q と /Q、クリア付き) と準備時間 (20 ns) は TI の SN74HC175 データシート (SCLS299F) による。
74HC574 にクリアが無いことは TI の SN74HC574 データシート (SCLS148H) による。

- [https://www.ti.com/lit/ds/symlink/sn74hc273.pdf](https://www.ti.com/lit/ds/symlink/sn74hc273.pdf)
- [https://www.ti.com/lit/ds/symlink/sn74hc157.pdf](https://www.ti.com/lit/ds/symlink/sn74hc157.pdf)
- [https://www.ti.com/lit/ds/symlink/sn74hc175.pdf](https://www.ti.com/lit/ds/symlink/sn74hc175.pdf)
- [https://www.ti.com/lit/ds/symlink/sn74hc574.pdf](https://www.ti.com/lit/ds/symlink/sn74hc574.pdf)
- 74HC175・74HC273・74HC157 のピンの番号は、上のデータシートの端子の図と突き合わせた
- 74HC377・74HC173 (書き込み許可付き) は名前を挙げただけで、データシートを確かめていない
- 型番の入手性、WaveForms の Logic の項目の名前は確認していない
