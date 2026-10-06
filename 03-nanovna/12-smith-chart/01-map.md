---
book: nanovna
chapter: 12
id: 12-1
title: Smith チャートの地図 — 外周・実軸・R の円・X の円
tier: 100
source: 自作
board: —
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

この題は各 vna の図の前に回路図を付け、実体配線図は付けない — 格子の読み方の題で、組む回路が無い (同じ負荷を実物で測るのは 12-4 のデモボード)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz |
| 点数 | 101 |
| 校正 | SOLT (1-1)。ケーブルの先 (負荷を付ける所) で Open / Short / Load |
| 表示 | S11 の Smith チャート。マーカーは 10 MHz |

## 4 つの点

**25 Ω** (Γ = −1/3、z = 0.5)。実軸の左半分、中心と左端の間の 1/3 あたり。周波数を変えても動かない (純抵抗)。

```circuit
title: 図1 の回路 (25 Ω)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 e5 25
  G1: ground e5
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-1.svg)

```vna
sweep: 1M-30M 101
title: 図1 25 Ω — 実軸の中心より左
dut:
  - series R 25
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-1.svg)

**100 Ω** (Γ = +1/3、z = 2)。実軸の右半分。25 Ω と対称に、中心から同じ距離。

```circuit
title: 図2 の回路 (100 Ω)
parts:
  J1: sma c2 mirror
  G0: ground d2
  R1: resistor c5 e5 100
  G1: ground e5
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-2.svg)

```vna
sweep: 1M-30M 101
title: 図2 100 Ω — 実軸の中心より右
dut:
  - series R 100
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-2.svg)

**820 nH のコイル** (10 MHz で Z = +j51.5 Ω、z = +j1.03)。上半分の外周の近く。**周波数を上げると外周を時計回りに右へ**回る。

```circuit
title: 図3 の回路 (コイル 820 nH)
parts:
  J1: sma c2 mirror
  G0: ground d2
  L1: inductor c5 e5 820n
  G1: ground e5
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-3.svg)

```vna
sweep: 1M-30M 101
title: 図3 コイル 820 nH — 上半分の外周
dut:
  - series L 820n
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-3.svg)

**330 pF のコンデンサ** (10 MHz で Z = −j48.2 Ω、z = −j0.96)。下半分の外周の近く。**周波数を上げると外周を時計回りに左へ**回る。

```circuit
title: 図4 の回路 (コンデンサ 330 pF)
parts:
  J1: sma c2 mirror
  G0: ground d2
  C1: capacitor c5 e5 330p
  G1: ground e5
wires:
  - J1.1 -- c5
  - J1.2 -- d2
style:
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/circuit/01-map-4.svg)

```vna
sweep: 1M-30M 101
title: 図4 コンデンサ 330 pF — 下半分の外周
dut:
  - series C 330p
  - short
traces:
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/12-smith-chart/vna/01-map-4.svg)

- 820 nH と 330 pF は、どちらも 10 MHz でリアクタンスの大きさがほぼ 50 Ω (z がほぼ ±j1)。**z = ±j1 の弧は、外周の上と下、実軸から約 90° の所**を通る。
  この 2 つは 12-4 のデモボードの負荷になる。E12 の値で 50 Ω ちょうどにはならない (820 nH は +j51.5 Ω、330 pF は −j48.2 Ω)
- 4 つの点を並べると、実軸の右が抵抗の大きいほう、上がコイル、下がコンデンサの 3 つの向きが 1 枚で覚えられる

## 見るべき値

計算値 (10 MHz、基準 50 Ω)。

| 負荷 | Z | z = Z / 50 | \|Γ\| | Γ の角 | SWR | 場所 |
| --- | --- | --- | --- | --- | --- | --- |
| 25 Ω | 25 Ω | 0.5 | 0.333 | 180° | 2.0 | 実軸、中心の左 |
| 100 Ω | 100 Ω | 2 | 0.333 | 0° | 2.0 | 実軸、中心の右 |
| 820 nH | +j51.5 Ω | +j1.03 | 1.000 | +88° | ∞ | 外周の上 |
| 330 pF | −j48.2 Ω | −j0.96 | 1.000 | −92° | ∞ | 外周の下 |

- 25 Ω と 100 Ω は、**中心からの距離がどちらも 1/3** (SWR がどちらも 2)。**中心を挟んで同じ距離**にあるが、抵抗の値が「25 Ω は 50 Ω の半分、100 Ω は 2 倍」と比で対称になるため。
  SWR は比 (50 Ω の何倍か、または何分の 1 か) だけで決まる
- コイルとコンデンサは、ほぼ外周の上と下の対称な位置にある。損失が小さい部品は外周を回る

## 出典

自作。Smith チャートの格子 (R の円・X の弧・外周) の読み方は、VNA の取扱説明書や高周波の教科書に共通する内容による
(例: [Smith chart — Wikipedia](https://en.wikipedia.org/wiki/Smith_chart))。
