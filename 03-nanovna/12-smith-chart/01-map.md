---
book: nanovna
chapter: 12
id: 12-1
title: Smith チャートの地図 — 外周・実軸・R の円・X の円
tier: 100
source: 自作
board: BB
device: LV64
---

# 12-1 Smith チャートの地図 — 外周・実軸・R の円・X の円

Smith チャートは、**反射係数 Γ (ガンマ)** を、インピーダンス Z が読める格子の上に描いた図だ。VNA の S11 は Γ そのもので、
Smith はそれを「何 Ω (オーム) の抵抗と、何 Ω のコイルかコンデンサか」に読み替えてくれる。この題では、格子の読み方を、
**4 つの既知の負荷が 1 点ずつ落ちる場所**で覚える。2 本目 (12-2) からは、その点が周波数で動くのを見る。

> **この章の図は理想の模型から計算した画面で、実機では測っていない。** 12-4 の治具で測れば、
> フェンスの `data:` に Touchstone を書いて同じ画面に重ねられる。

## 読み方

測る回路の入り口から負荷を見たインピーダンス Z を、基準の 50 Ω で割った **z = Z / 50** (正規化) で格子を読む。
反射係数との関係は次の 1 本だけ覚える。

Γ = (Z − 50) / (Z + 50) = (z − 1) / (z + 1)

- **中心 (Γ = 0) は 50 Ω** (z = 1)。反射が無い、つまり整合している点。中心から遠いほど反射が大きい
- **右端 (Γ = +1) は開放** (Z = ∞)、**左端 (Γ = −1) は短絡** (Z = 0)。校正の Open と Short (1-2) がこの 2 点
- **横の線 (実軸) は純抵抗**。中心より右は 50 Ω より大きく、左は小さい。50 Ω の 2 倍 (100 Ω、z = 2) は中心と右端の間の 1/3 あたり
- **実軸の上の半分は誘導性 (+jX、コイル)、下の半分は容量性 (−jX、コンデンサ)**。覚え方は「上はコイル、下はコンデンサ」。
  X が大きいほど外周に近づく
- **R の円**は、右端でそろって接する円。抵抗が同じ点をつなぐ。**X の円弧**は、右端から出て、上下に弧を描く。リアクタンスが同じ点をつなぐ
- **外周 (|Γ| = 1) は純リアクタンス**。抵抗が 0 (損失が無い) の点だけが外周に乗る。コイルやコンデンサは、抵抗が小さい限り外周の近くにある

## 掃引の設定

計器は VNA。この本の図は LiteVNA64 の画面に合わせて書いてあり、NanoVNA-H4 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

4 つの負荷は 1 枚のブレッドボードに並べて挿しておき、VNA の RF の線を測る負荷の列へ挿し替えて 1 つずつ測る (実体配線図は図 5)。
各 vna の図の前には、その負荷だけの回路図を付ける。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜3 MHz |
| 点数 | 101 |
| 校正 | SOLT (1-1) の Open / Short / Load を、**ブレッドボードの上で**取る (下の「測る前に」の図 6) |
| 表示 | S11 の Smith チャート。マーカーは 1 MHz |

周波数は 3 MHz までにした。ブレッドボードの列どうしの浮遊容量 (約 2.5 pF、[02-analog-discovery/08-breadboard-limits/02-row-capacitance.md](../../02-analog-discovery/08-breadboard-limits/02-row-capacitance.md)) は 3 MHz で −j21 kΩ、
5 cm の線のインダクタンス (約 43 nH、[02-analog-discovery/08-breadboard-limits/03-jumper-inductance.md](../../02-analog-discovery/08-breadboard-limits/03-jumper-inductance.md)) は +j0.8 Ω で、どちらも負荷 (数十 Ω) に比べて見えないほど小さい。
**ブレッドボードで組んでも、図の理想の位置に来る**範囲。

## 4 つの点

**25 Ω** (Γ = −1/3、z = 0.5)。実軸の左半分、中心と左端の間の 1/3 あたり。周波数を変えても動かない (純抵抗)。

```circuit
title: 図1 の回路 (25 Ω、12 Ω と 13 Ω の直列)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  R1: resistor 5,3 9,3 12
  R2: resistor 9,3 9,5 13
  G1: ground 9,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-1.svg)

```vna
sweep: 100k-3M 101
title: 図1 25 Ω — 実軸の中心より左
dut:
  - series R 25
  - short
traces:
  - S11 smith
markers:
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-1.svg)

**100 Ω** (Γ = +1/3、z = 2)。実軸の右半分。25 Ω と対称に、中心から同じ距離。

```circuit
title: 図2 の回路 (100 Ω)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  R1: resistor 5,3 5,5 100
  G1: ground 5,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-2.svg)

```vna
sweep: 100k-3M 101
title: 図2 100 Ω — 実軸の中心より右
dut:
  - series R 100
  - short
traces:
  - S11 smith
markers:
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-2.svg)

**8.2 µH (マイクロヘンリー) のコイル** (1 MHz で Z = +j51.5 Ω、z = +j1.03)。上半分の外周の近く。**周波数を上げると外周を時計回りに右へ**回る。

```circuit
title: 図3 の回路 (コイル 8.2 µH)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  L1: inductor 5,3 5,5 8.2u
  G1: ground 5,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-3.svg)

```vna
sweep: 100k-3M 101
title: 図3 コイル 8.2 µH — 上半分の外周
dut:
  - series L 8.2u
  - short
traces:
  - S11 smith
markers:
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-3.svg)

**3.3 nF のコンデンサ** (1 MHz で Z = −j48.2 Ω、z = −j0.96)。下半分の外周の近く。**周波数を上げると外周を時計回りに左へ**回る。

```circuit
title: 図4 の回路 (コンデンサ 3.3 nF)
parts:
  J1: sma 2,3 mirror
  G0: ground 2,4
  C1: capacitor 5,3 5,5 3.3n
  G1: ground 5,5
wires:
  - J1.1 -- 5,3
  - J1.2 -- 2,4
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-4.svg)

```vna
sweep: 100k-3M 101
title: 図4 コンデンサ 3.3 nF — 下半分の外周
dut:
  - series C 3.3n
  - short
traces:
  - S11 smith
markers:
  - 1M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-4.svg)

- 8.2 µH と 3.3 nF は、どちらも 1 MHz でリアクタンスの大きさがほぼ 50 Ω (z がほぼ ±j1)。**z = ±j1 の弧は、外周の上と下、実軸から約 90° の所**を通る。
  この 2 つは 12-4 のデモボードの負荷になる。E12 の値で 50 Ω ちょうどにはならない (8.2 µH は +j51.5 Ω、3.3 nF は −j48.2 Ω)
- 4 つの点を並べると、実軸の右が抵抗の大きいほう、上がコイル、下がコンデンサの 3 つの向きが 1 枚で覚えられる

## 実体配線図

```breadboard
title: 図5 4 つの負荷をブレッドボードに並べる (図1 の 25 Ω を選んだ状態)
board: half
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [GND, RF]
  R1: resistor c3 c7 12
  R2: resistor a7 -t7 13
  R3: resistor a12 -t12 100
  L1: inductor a17 -t17 8.2u
  C1: capacitor/ceramic a22 -t22 3.3n
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e3 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/01-map-1.svg)

- 列ごとに負荷が 1 つ: **25 Ω (図 1) は 3 列目** (R1 12 Ω で 7 列目へ渡り、R2 13 Ω で上の − レールへ)、**100 Ω (図 2) は 12 列目、8.2 µH (図 3) は 17 列目、3.3 nF (図 4) は 22 列目**
- **選ぶのはオレンジの線 1 本だけ**。VNA の RF からの線を、測る負荷の列の e の行へ挿し替える。上の − レール (青の線) が GND で、黒い線で VNA の GND へつなぐ。同時に 2 つの列へ挿さない (負荷が並列になる)
- 25 Ω は E24 に無いので、**12 Ω と 13 Ω (どちらも E24) の直列**で作る
- SMA ケーブルの先は、ピンヘッダに変換する SMA の基板を使うか、線を剥いて RF と GND の 2 本に分ける。線は 5 cm 以下にする
- コイルは軸付きの小さなインダクタ (8.2 µH、E12)、コンデンサはセラミック (3.3 nF、E12。C0G がよい)

## 測る前に — ブレッドボードの上で校正し、部品を測る

### ブレッドボードの上で校正する

ケーブルの先で校正すると、ケーブルの先からブレッドボードの列までの線も測る物に入る。
**校正の Open / Short / Load をブレッドボードの列で取る**と、校正の基準面
([03-nanovna/01-calibration/05-reference-plane.md](../01-calibration/05-reference-plane.md)) がオレンジの線の先へ移り、
線とブレッドボードの寄生は校正で差し引かれる。**測る物は、列に挿した負荷だけ**になる。

```breadboard
title: 図6 校正の 3 つの標準をブレッドボードで作る (Open を取る状態)
board: half
parts:
  VNA:
    type: device
    at: top
    label: VNA (SMA ケーブルの先)
    pins: [GND, RF]
  R1: resistor b11 b14 100
  R2: resistor d11 d14 100
wires:
  - VNA.GND -- -t1 black
  - VNA.RF -- e3 orange
  - -t7 -- a7 black
  - -t14 -- a14 black
notes:
  - text f3 large bold center: Open
  - text f7 large bold center: Short
  - text f12 large bold center: Load
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/breadboard/01-map-2.svg)

1. VNA の範囲を、測るときと同じ 100 kHz〜3 MHz に合わせてから校正 (1-1) を始める
2. **Open**: オレンジの線を 3 列目 (何も挿していない列) の e の行に挿して取る
3. **Short**: 7 列目 (黒い線で上の − レールへ) に挿し替えて取る
4. **Load**: 11 列目 (100 Ω の 2 本並列 = 50 Ω を通って 14 列目から GND へ) に挿し替えて取る
5. 校正を保存する。**このあと、オレンジの線は替えない**。線の先が基準面なので、線を替えたり取り回しを大きく変えたりすると基準面がずれる

- 3 MHz 以下では、ブレッドボードで作った標準でもほぼ理想どおりに働く。Open の列の浮遊容量 (約 2.5 pF) は 3 MHz で −j21 kΩ、
  Short の黒い線 (約 20 nH、見積り) は +j0.4 Ω、Load の 100 Ω (誤差 1 %) の 2 本並列は 50 Ω から ±1 % 以内
- Load は 51 Ω 1 本でもよい (2 % 高く、SWR 1.02)。そのときは、測った 51 Ω の負荷 ([03-nanovna/12-smith-chart/04-demo-board.md](04-demo-board.md) の JP3) が 50 Ω に見える
- 標準は、測る負荷と同じブレッドボードの空いた列に作っておくと、校正をすぐ取り直せる

### 組む前にコイルとコンデンサを測る

図と実測が食い違う原因で一番大きいのは、ブレッドボードの寄生ではなく**部品の誤差**。軸付きのコイルは ±10 % の物が多く、
8.2 µH の +j51.5 Ω (1 MHz) は +j46〜57 Ω のどこかに来る。コンデンサは C0G でも ±5 %。

校正のあと、**コイルとコンデンサを 1 本ずつ列に挿して (列から上の − レールへ)、1 MHz のマーカーの読み値**から値を出す。
図 3・図 4 の測り方そのもの。

- コイル: L = X / (2π (パイ) f)。例: +j51.5 Ω なら 51.5 / (2π × 1 MHz) = 8.2 µH
- コンデンサ: C = 1 / (2π f |X|)。例: −j48.2 Ω なら 1 / (2π × 1 MHz × 48.2) = 3.3 nF
- 出た値を、部品表の値の横に書いておく。**図と点がずれたら、まずこの値で計算し直す**。12-2 以降の題で使うコイルとコンデンサも、組む前に同じように測っておく

## 見るべき値

計算値 (1 MHz、基準 50 Ω)。

| 負荷 | Z | z = Z / 50 | \|Γ\| | Γ の角 | SWR | 場所 |
| --- | --- | --- | --- | --- | --- | --- |
| 25 Ω | 25 Ω | 0.5 | 0.333 | 180° | 2.0 | 実軸、中心の左 |
| 100 Ω | 100 Ω | 2 | 0.333 | 0° | 2.0 | 実軸、中心の右 |
| 8.2 µH | +j51.5 Ω | +j1.03 | 1.000 | +88° | ∞ | 外周の上 |
| 3.3 nF | −j48.2 Ω | −j0.96 | 1.000 | −92° | ∞ | 外周の下 |

- 25 Ω と 100 Ω は、**中心からの距離がどちらも 1/3** (SWR がどちらも 2)。**中心を挟んで同じ距離**にあるが、抵抗の値が「25 Ω は 50 Ω の半分、100 Ω は 2 倍」と比で対称になるため。
  SWR は比 (50 Ω の何倍か、または何分の 1 か) だけで決まる
- コイルとコンデンサは、ほぼ外周の上と下の対称な位置にある。損失が小さい部品は外周を回る

## 出典

自作。Smith チャートの格子 (R の円・X の弧・外周) の読み方は、VNA の取扱説明書や高周波の教科書に共通する内容による
(例: [Smith chart — Wikipedia](https://en.wikipedia.org/wiki/Smith_chart))。
