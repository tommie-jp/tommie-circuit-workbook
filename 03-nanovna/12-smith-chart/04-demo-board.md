---
book: nanovna
chapter: 12
id: 12-4
title: Smith チャートデモボード — 8 つの負荷を差し替えて 1 点ずつ測る
tier: 100
source: 自作
board: [PF, BB]
device: LV64
---

# 12-4 Smith チャートデモボード — 8 つの負荷を差し替えて 1 点ずつ測る

12-1〜12-3 で読んだ Smith チャートを、**自分の手で測った点**で確かめるための治具。端面 SMA を 1 つ付けた perfboard に、**8 つの負荷**
(Open・Short・51 Ω・24 Ω・100 Ω・コイル・コンデンサ・51 Ω + コイル) を半田付けしておき、2 ピンのジャンパで**どれか 1 つだけを SMA につなぐ**。
ジャンパを差し替えるたびに点がチャートの別の場所へ跳ぶのを見て、位置と値の関係を体で覚える。

> **この章の図の画面は理想の模型から計算したもので、実機では測っていない。** 治具で測った Touchstone は、フェンスの `data:` に書けば同じ画面に重なる。
> perfboard と端面 SMA の治具は、**周波数が 30 MHz までなら、図の理想と同じ位置に来る**ように設計した (自分で作って確かめる前の見積り)。

## 回路図

```circuit
title: 図1 デモボードの回路 (JP をどれか 1 つだけ閉じる)
parts:
  J1: sma c2 mirror
  G0: ground d2
  JP1: switch c5 e5
  JP2: switch c8 e8
  G2: ground e8
  JP3: switch c11 e11
  R1: resistor e11 h11 51
  G3: ground h11
  JP4: switch c14 e14
  R2: resistor e14 h14 24
  G4: ground h14
  JP5: switch c17 e17
  R3: resistor e17 h17 100
  G5: ground h17
  JP6: switch c20 e20
  L1: inductor e20 h20 820n
  G6: ground h20
  JP7: switch c23 e23
  C1: capacitor e23 h23 330p
  G7: ground h23
  JP8: switch c26 e26
  R4: resistor e26 g26 51
  L2: inductor g26 j26 820n
  G8: ground j26
wires:
  - J1.1 -- c5
  - c5 -- c8
  - c8 -- c11
  - c11 -- c14
  - c14 -- c17
  - c17 -- c20
  - c20 -- c23
  - c23 -- c26
  - J1.2 -- d2
notes:
  - text f5 small center: Open
  - text f8 small center: Short
  - text i11 small center: 51 Ω
  - text i14 small center: 24 Ω
  - text i17 small center: 100 Ω
  - text i20 small center: L
  - text i23 small center: C
  - text k26 small center: R + L
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/04-demo-board.svg)

- J1 の中心導体が**共通の線 (バス)**。JP1〜JP8 は 2 ピンのジャンパで、**同時に閉じるのは 1 つだけ** (2 つ閉じると、負荷が並列になる)
- JP1 は Open (閉じても何も付かない)。JP2 は Short (閉じると地へ直結)。それ以外は、JP を閉じると**その負荷が J1 の先に付く**
- 閉じていない JP の先の負荷は**切り離され**、バスには JP のピン 1 本 (数 pF 未満) だけが付く。30 MHz までなら見えないほど小さい

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 デモボード (perfboard、端面 SMA と 8 組の JP)
unused: [JP1.1]
points:
  GND: 011
parts:
  J1: sma/female-edge a10 011 09
  JP1: sip2 c11 r90
  JP2: sip2 h11 r90
  JP3: sip2 m11 r90
  JP4: sip2 r11 r90
  JP5: sip2 e10 r90
  JP6: sip2 j10 r90
  JP7: sip2 o10 r90
  JP8: sip2 t10 r90
  R1: resistor m12 m17 51
  R2: resistor r12 r17 24
  R3: resistor e8 e3 100
  L1: inductor j8 j3 820n
  C1: capacitor/ceramic o8 o3 330p
  R4: resistor t8 t5 51
  L2: inductor u5 u2 820n
wires:
  - a10 -- c10
  - c10 -- e10
  - e10 -- h10
  - h10 -- j10
  - j10 -- m10
  - m10 -- o10
  - o10 -- r10
  - r10 -- t10
  - h11 -- h18 black
  - m11 -- m12
  - r11 -- r12
  - m17 -- m18 black
  - r17 -- r18 black
  - 011 -- 018 black
  - 018 -- h18 black
  - h18 -- m18 black
  - m18 -- r18 black
  - 09 -- 02 black
  - e9 -- e8
  - j9 -- j8
  - o9 -- o8
  - t9 -- t8
  - t5 -- u5
  - e3 -- e2 black
  - j3 -- j2 black
  - o3 -- o2 black
  - 02 -- e2 black
  - e2 -- j2 black
  - j2 -- o2 black
  - o2 -- u2 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/perfboard/04-demo-board.svg)

- **SMA は端面コネクタ** (3-1 と同じ): 凹の腕をユニバーサル基板の縁の銅箔 (0 列) に半田付けし、中心導体を A10 に通す。左の縁の GND (09 と 011) は黒い線で上の GND (018) と下の GND (02) へ
- **バス**は 10 行の白い線で、**JP のピン 1 本ずつを通る** (JP1〜JP4 は C・H・M・R 列、JP5〜JP8 は E・J・O・T 列)。上の 4 組 (JP1〜JP4) は 11 行から上、下の 4 組 (JP5〜JP8) は 9 行から下
- **負荷は縦に半田付け**: 上の 4 組は 12 行〜17 行、下の 4 組は 8 行〜3 行。GND の線は 18 行 (上) と 2 行 (下)。リード線を短く切って、部品を基板に寝かせる
- **JP2 は GND への線 1 本** (H11 → H18): Short。**JP1 は何も付けない** (C11 のピンだけ): Open
- **JP8 の負荷は 51 Ω と 820 nH の直列**: T8 → T5 の抵抗と U5 → U2 のコイルを、T5 と U5 の間の線でつなぐ
- ジャンパは **JP に挿すショートピン** (2.54 mm ピッチ) を 1 つだけ用意して、差し替えて使う。**図には描かない**
- 抵抗は 1/4 W の金属皮膜 (誤差 1 %)。**51 Ω と 24 Ω は E24**、100 Ω も E24。51 Ω は 50 Ω に 2 % 高いが、SWR は 1.02 で十分 Load の代わりになる
- **820 nH** (E12) は 10 MHz で +j51.5 Ω、**330 pF** (E12) は −j48.2 Ω。どちらも「ほぼ ±j50 Ω」の部品になる。コイルは軸付きの小さなインダクタ (リードの短いもの)、コンデンサはセラミック (C0G 推奨)

## ブレッドボードで組む (3 MHz 以下向け)

perfboard の治具を作る前に、**ブレッドボードで同じ 8 つの負荷を試す**こともできる。ジャンパ (JP) の代わりに、**1 本の線 (オレンジ) を、選んだ負荷の列へ挿し替える**。

> **周波数の範囲の注意。** ブレッドボードは、列どうしの浮遊容量 (約 2.5 pF、8-2) と線のインダクタンス (5 cm のジャンパで約 43 nH、8-3) が
> 付くので、**3 MHz を超える部分は、ブレッドボードの寄生を含んだ値の目安**になる。**図の理想 (perfboard の値) と合わせて読むのは 3 MHz まで**。
> 10 MHz や 30 MHz の位置は、Open が右端から、Short が左端から**回り込んで**見える (下の図11〜図13)。
> 校正の基準面は SMA のケーブルの先なので、**ケーブルの先から挿し先の列までの線も測る物に含まれる**。短い線 (5 cm 以下) で挿す。

```breadboard
title: 図2b デモボードをブレッドボードで組む (JP3 の 51 Ω を選んだ状態)
board: half
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [RF, GND]
  R1: resistor a8 -t8 51
  R2: resistor a11 -t11 24
  R3: resistor a14 -t14 100
  L1: inductor a17 -t17 820n
  C1: capacitor a20 -t20 330p
  R4: resistor b23 b26 51
  L2: inductor a26 -t26 820n
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e8 orange
  - e5 -- -t5 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/04-demo-board.svg)

- 列ごとに負荷が 1 つ: **JP1 Open は 2 列目 (何も付けない)、JP2 Short は 5 列目 (黒い線で GND へ)、JP3 51 Ω は 8 列目、JP4 24 Ω は 11 列目、JP5 100 Ω は 14 列目、JP6 820 nH は 17 列目、JP7 330 pF は 20 列目、JP8 51 Ω + 820 nH は 23 列目から 26 列目**
- **選ぶのはオレンジの線 1 本だけ**。VNA の RF からの線を、測りたい列 (e の行) へ挿し替える。図は JP3 (8 列目) を選んだ状態で、上の青い線のレールが GND (黒の線で VNA の GND へ)。同時に 2 つの列へ挿さない (負荷が並列になる)
- JP8 は **23 列目の 51 Ω が 26 列目へ横に渡り、26 列目の 820 nH が GND へ**つながる。選ぶときは 23 列目 (b の行) へ
- 部品は perfboard の図 2 と同じ値。**perfboard の治具は 30 MHz まで**、ブレッドボードは **3 MHz まで** が使える範囲 (上の注意)
- 計器は VNA だけ (AD3 とオシロは使わない)。SMA ケーブルの先は、ピンヘッダに変換する SMA の基板か、ケーブルの先の線を剥いて、2 本の線 (RF と GND) に分けて使う

## 掃引の設定

計器は VNA。この本の図は LiteVNA64 の画面に合わせて書いてあり、NanoVNA-H4 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz |
| 点数 | 101 |
| 校正 | SOLT (1-1)。**ケーブルの先 (デモボードの SMA に挿す手前)** で Open / Short / Load / Thru |
| 表示 | S11 の Smith チャート。マーカー 1 を 10 MHz に置く |

手順:

1. 校正したケーブルの先を、デモボードの SMA にしっかり (締めすぎずに、0-2) つなぐ
2. **JP を 1 つだけ閉じる** (ほかは全部開けておく)
3. マーカー 1 を 10 MHz に置いて、Smith の位置と Z の読み値を、下の表に書き込む
4. JP を替えて繰り返す。**8 つ全部測ると、チャートの上に 8 点がそろう**

以下は、**理想の模型から計算した画面**。

```vna
sweep: 1M-30M 101
title: 図3 JP1 Open — 右端
dut: open
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-1.svg)

```vna
sweep: 1M-30M 101
title: 図4 JP2 Short — 左端
dut: short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-2.svg)

```vna
sweep: 1M-30M 101
title: 図5 JP3 51 Ω — 中心 (SWR 1.02)
dut:
  - series R 51
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-3.svg)

```vna
sweep: 1M-30M 101
title: 図6 JP4 24 Ω — 実軸の左 (SWR 2.08)
dut:
  - series R 24
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-4.svg)

```vna
sweep: 1M-30M 101
title: 図7 JP5 100 Ω — 実軸の右 (SWR 2.0)
dut:
  - series R 100
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-5.svg)

```vna
sweep: 1M-30M 101
title: 図8 JP6 820 nH — 上の外周 (+j51.5 Ω)
dut:
  - series L 820n
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-6.svg)

```vna
sweep: 1M-30M 101
title: 図9 JP7 330 pF — 下の外周 (−j48.2 Ω)
dut:
  - series C 330p
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-7.svg)

```vna
sweep: 1M-30M 101
title: 図10 JP8 51 Ω + 820 nH — r = 1 の円の上 (51 + j51.5 Ω)
dut:
  - series R 51
  - series L 820n
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-8.svg)

## ブレッドボードの寄生を含む Smith チャート

ブレッドボードで同じ負荷を測ると、**浮遊容量 2.5 pF (8-2) と 5 cm の線のインダクタンス 43 nH (8-3) が付いて、点が少し回る**。
下は、この 2 つを**負荷に足した模型**で計算した Smith チャート (perfboard の図 3〜図10 と同じ 1〜30 MHz。マーカーは 3 MHz と 30 MHz)。
**3 MHz では図の理想の位置に近く、30 MHz では回り込みが見える**。

```vna
sweep: 1M-30M 101
title: 図11 ブレッドボードの Open — 右端から下へ (2.5 pF 付き)
dut:
  - shunt C 2.5p
  - open
traces:
  - S11 smith
markers:
  - 3M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-9.svg)

```vna
sweep: 1M-30M 101
title: 図12 ブレッドボードの Short — 左端から上へ (43 nH 付き)
dut:
  - series L 43n
  - short
traces:
  - S11 smith
markers:
  - 3M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-10.svg)

```vna
sweep: 1M-30M 101
title: 図13 ブレッドボードの 51 Ω — 中心の近く (2.5 pF と 43 nH 付き)
dut:
  - series L 43n
  - shunt C 2.5p
  - series R 51
  - short
traces:
  - S11 smith
markers:
  - 3M
  - 30M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/04-demo-board-11.svg)

- **模型は仮定**: 2.5 pF と 43 nH は、8-2・8-3 の測った値を負荷の両側に足しただけ。実際の寄生は、挿す列・線の長さ・部品のリード線で変わる。**値の目安を見る図で、測った値ではない**
- Open は右端の少し下 (容量性の側)、Short は左端の少し上 (誘導性の側) へ回る。**30 MHz で回りが大きい** (Open の 2.5 pF は −j2.1 kΩ、Short の 43 nH は +j8.1 Ω)
- 回り込みが大きいときは、**校正 (Open / Short / Load) を同じ列・同じ線の長さで取り直す**と、基準面が負荷の根元へ移って、寄生が消える

## 見るべき値

計算値 (10 MHz、基準 50 Ω)。測った値と見比べる。

| JP | 負荷 | 理想の Z | z | \|Γ\| | SWR | チャート上の場所 |
| --- | --- | --- | --- | --- | --- | --- |
| JP1 | Open | ∞ | ∞ | 1 | ∞ | 右端 |
| JP2 | Short | 0 Ω | 0 | 1 | ∞ | 左端 |
| JP3 | 51 Ω | 51 Ω | 1.02 | 0.010 | 1.02 | 中心 |
| JP4 | 24 Ω | 24 Ω | 0.48 | 0.351 | 2.08 | 実軸の左 |
| JP5 | 100 Ω | 100 Ω | 2 | 0.333 | 2.00 | 実軸の右 |
| JP6 | 820 nH | +j51.5 Ω | +j1.03 | 1 | ∞ | 上の外周 |
| JP7 | 330 pF | −j48.2 Ω | −j0.96 | 1 | ∞ | 下の外周 |
| JP8 | 51 Ω + 820 nH | 51 + j51.5 Ω | 1.02 + j1.03 | 0.455 | 2.67 | r = 1 の円の上 |

- **24 Ω と 100 Ω は、中心から同じ距離 (SWR 2) で左右の対称**の位置に来る。ここがずれていたら、抵抗の値か基準面を疑う
- 実物では、**Open と Short が右端・左端から少し回る** (パッドの容量・配線のインダクタンス)。10 MHz なら数度以内に収まる見込み。周波数を 30 MHz に上げると回り方が増える
- JP6 (820 nH) と JP7 (330 pF) は**外周の近く** (実物のコイルは抵抗が少しあるので、外周から少し内側)。**この 2 点が外周の上と下に来れば、上はコイル・下はコンデンサの向きが確かめられる**
- 掃引を 1〜30 MHz にして、JP6 と JP7 の線が**上へ・下へ外周を時計回りに**動くことも確かめる (12-2)

## 出典

自作。
