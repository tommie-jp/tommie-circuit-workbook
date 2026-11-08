---
book: circuits
chapter: 0
id: 0-10
title: ロジックプローブと音で聞く検出器
tier: 200
source: 自作
board: BB
era: 古
---

# 0-10 ロジックプローブと音で聞く検出器

デジタル回路が動かないとき、まず知りたいのは「この線は H か L か、それとも何もつながっていないか」。
テスターでも電圧は読めるが、何本もの線を次々に当たるには、先端を当てるだけで LED が答える**ロジックプローブ**が速い。
もう 1 つ、パルスが**出ているかどうか**を知るには、目より耳が速い。コンデンサを通してイヤホンにつなぐと、
1 kHz のパルスはピーという音、100 Hz はブーという音、止まっていれば無音になる。どちらも、ロジック IC を組む人が
オシロを持たなかった時代の定番の道具。

この題では 2 つを 1 つのプローブにまとめる。

- **H の赤 LED と L の緑 LED** — 入力をコンパレータ 2 個 (LM393) で 2 つのしきい値と比べる (**窓コンパレータ**)。
  H は 2.91 V より上、L は 1.46 V より下。その間 (浮いている、つまり何もつながっていない線) ではどちらも消える
- **音** — 入力を 0.1 µF (マイクロファラド) で受けてクリスタルイヤホンへ。直流は通さず、変化だけを音にする

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 窓コンパレータのロジックプローブ (上) と音で聞く検出器 (下)
parts:
  TIP: port 1,12
  VCC: vcc 3,10 5V
  R4: resistor 3,10 3,12 1M
  R5: resistor 3,12 3,14 1M
  G1: ground 3,14
  VCC: vcc 7,1 5V
  RA: resistor 7,1 7,3 4.3k
  RB: resistor 7,3 7,8.5 3.0k
  RC: resistor 7,8.5 7,10 3.0k
  G2: ground 7,10
  U1A: opamp 11,4 +up
  U1B: opamp 11,8 +up
  VCC: vcc 14,1 5V
  R7: resistor 14,1 14,2.5 680
  D1: led 14,2.5 14,4 red
  VCC: vcc 15,5 5V
  R8: resistor 15,5 15,6.5 680
  D2: led 15,6.5 15,8 green
  C3: capacitor 9,12 11,12 100n
  R6: resistor 12,12 12,14 10k
  E1: earphone 14,12 14,14
  M1: voltmeter 16,12 16,14 l=$\mathrm{CH2}$
  G3: ground 12,14
  G4: ground 14,14
  G5: ground 16,14
  M2: voltmeter 5,12 5,14 l=$\mathrm{CH1}$
  G6: ground 5,14
wires:
  - 1,12 -- 3,12
  - 3,12 -- 5,12
  - 5,12 -- 9,12
  - 9,12 -- 9,6
  - 9,6 |- U1A.-
  - 9,6 |- U1B.+
  - 7,3 -| U1A.+
  - 7,8.5 -| U1B.-
  - U1A.out -| 14,4
  - U1B.out -| 15,8
  - 11,12 -- 12,12
  - 12,12 -- 14,12
  - 14,12 -- 16,12
notes:
  - text 13.3,4.7 left: H (赤)
  - text 15.3,8.7 left: L (緑)
  - text 9.3,6: X
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/circuit/10-logic-probe.svg)

入力 (TIP) は、`R4`・`R5` (1 MΩ ずつ) で 2.5 V に引かれた点 X につながる。`U1A`・`U1B` は LM393 の 2 回路 (記号はオペアンプと同じ三角で描くが、
出力はトランジスタが GND へ引くだけの**開コレクタ**)。LM393 の電源 (8 番 VCC = 5 V、4 番 GND) は図に描いていない。

- **しきい値**: `RA`・`RB`・`RC` の分圧で、上が 5 V × 6.0 k / 10.3 k = **2.91 V**、下が 5 V × 3.0 k / 10.3 k = **1.46 V**
- **H**: X が 2.91 V を超えると、`U1A` の − 入力が + 入力より高くなり、出力が GND へ引かれる。5 V → `R7` → `D1` (赤) に
  (5 − 1.9 − 0.1) / 680 Ω ≈ **4.4 mA** が流れて点く (1.9 V は赤 LED の順方向電圧の目安、0.1 V は LM393 の出力に残る電圧)
- **L**: X が 1.46 V を下回ると、`U1B` の出力が GND へ引かれ、`D2` (緑) が点く
- **浮き**: TIP に何もつながないと X は 2.5 V で、2 つのしきい値の間。どちらも消える。テスターでは「2.5 V」にしか見えないが、
  プローブは「H でも L でもない」と言い分ける。CMOS の入力の浮き (配線忘れ) を見つけるのに効く
- **しきい値の上限**: LM393 は入力の片方が 0〜(VCC − 2 V) = 3 V の範囲にあれば、もう片方が 5 V まで上がっても正しく比べる
  (データシートの注)。上のしきい値を 2.91 V にしたのはこのため
- **入力の重さ**: TIP から見ると 1 MΩ が 2 本と、`C3` の先の 10 kΩ。直流では 500 kΩ で、測る回路をほとんど引っ張らない

**音で聞く検出器**: TIP の電圧の変化だけが `C3` (0.1 µF) を通り、`R6` (10 kΩ) とクリスタルイヤホン `E1` の両端に出る。
時定数は 0.1 µF × 10 kΩ = 1 ms。0〜5 V・1 kHz の方形波なら、跳ぶたびに ±3.1 V の山が 1 ms で落ちる波 (微分波形) になり、
イヤホンから 1 kHz の音が出る。クリスタルイヤホンは数百 kΩ 以上の高インピーダンスなので、電流はほとんど要らない。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 LM393 の左にしきい値と LED、右に入力の X とイヤホン
board: half
parts:
  U1: dip8 @ e12 LM393
  R8: resistor b5 b9 680
  D2: led c9 c13 green
  RC: resistor a14 -t14 3.0k
  RB: resistor c14 c18 3.0k cap=above
  RA: resistor b18 b22 4.3k
  R7: resistor h4 h8 680
  D1: led g8 g12 red
  R5: resistor j24 -b24 1M
  R4: resistor g24 g28 1M
  C3: capacitor/film b24 b28 100n cap=below:2,0
  R6: resistor a28 -t28 10k
  E1: speaker e28 e30 l=イヤホン(数百kΩ) cap=below:-2,1
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, 1+, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t3 -- +b3 red
  - a5 -- +t5 red
  - a12 -- +t12 red
  - a22 -- +t22 red
  - e18 -- f18 purple
  - h14 -- h18 purple
  - d15 -- d24 white
  - e24 -- f24 white
  - i13 -- i24 white
  - j15 -- -b15 black
  - j4 -- +b4 red
  - j28 -- +b28 red
  - a30 -- -t30 black
  - AD.W1 -- a24 yellow
  - c24 -- c25 blue
  - AD.1+ -- a25 blue
  - AD.1- -- -t26 black
  - AD.2- -- -t27 black
  - d28 -- d29 orange
  - AD.2+ -- a29 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/breadboard/10-logic-probe.svg)

LM393 (U1) は列 12〜15 で溝をまたぐ。切り欠きを左にして、下の列の左から 1〜4 番、上の列の右から 5〜8 番。

- **電源**: V+ (5 V) を上の + レールへ、GND を上の − レールへ。上下の + レールは列 3、− レールは列 1 でつなぐ。8 番 (列 12 の上) を + レールへ、4 番 (列 15 の下) を下の − レールへ
- **しきい値 (上のブロック)**: `RC` は列 14 (6 番 = 2IN−、下のしきい値) から − レールへ縦に。`RB` で列 18 (上のしきい値)、`RA` で列 22 から + レールへ。
  上のしきい値は紫の線で下のブロックへ渡し、3 番 (1IN+、列 14 の下) へ
- **X (白の線)**: 5 番 (2IN+、列 15 の上) から列 24 の上へ、列 24 を下へ渡して 2 番 (1IN−、列 13 の下) へ。列 24 が TIP で、W1 (黄) と CH1 の 1+ (青、列 25 経由) が入る。
  `R4` は列 24 の下から列 28、列 28 を下の + レールへ。`R5` は列 24 の下から下の − レールへ
- **LED**: 緑の `D2` はアノードを列 9 (`R8` から + レール)、カソードを 7 番 (2OUT、列 13 の上) に。赤の `D1` はアノードを列 8 の下 (`R7` から下の + レール)、カソードを 1 番 (1OUT、列 12 の下) に
- **イヤホン**: `C3` を列 24 から列 28、`R6` を列 28 から − レールへ縦に、イヤホン `E1` を列 28 と列 30 に挿し、列 30 を − レールへ。CH2 の 2+ は列 29 (列 28 から橙の線)

5 V から流れるのは LED 1 個の 4.4 mA、分圧の 0.5 mA、LM393 の 0.4 mA ほどで、AD3 の V+ の範囲に収まる。

## 計器の設定

計器は AD3 の Supplies (V+ = 5 V)・Wavegen・Scope。W1 で TIP にいろいろな信号を入れて、LED と音の答えを確かめ、Scope でイヤホンに出る波を見る。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5.0 V |
| Wavegen W1 | 試す順に、DC 0 V → DC 5 V → DC 2.0 V → 方形波 1 Hz (0〜5 V) → 方形波 1 kHz (0〜5 V: 振幅 2.5 V・オフセット 2.5 V) |
| Scope CH1 (TIP) | 2 V/div |
| Scope CH2 (イヤホン) | 2 V/div |
| 時間 | 500 µs/div (1 kHz の 5 周期) |
| トリガ | CH1 の立ち上がり、2.5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 kHz のパルスが TIP (CH1) に来ると、イヤホン (CH2) に ±3.1 V の微分波形
time: 500us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 1kHz 2.5V offset 2.5V, range: 2V/div}
ch2: {wave: ch1 | hp 1ms, range: 2V/div}
measure: [vpp, vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/scope/10-logic-probe.svg)

図3 の CH2 は、TIP が 0 → 5 V に跳ぶたびに +3.1 V、5 → 0 V で −3.1 V に跳び、1 ms の時定数で 0 へ戻る。
イヤホンにはこの山が 1 秒に 1000 回ずつ来て、1 kHz の音になる。山が ±5 V にならないのは、半周期 (0.5 ms) では戻りきらないため
(山 = 5 V / (1 + e<sup>−0.5</sup>) = 3.1 V)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | コンパレータ (2 回路、DIP-8) | LM393 |
| RA | 抵抗 (1/4 W) | 4.3 kΩ |
| RB, RC | 抵抗 (1/4 W) | 3.0 kΩ |
| R4, R5 | 抵抗 (1/4 W) | 1 MΩ |
| R7, R8 | 抵抗 (1/4 W) | 680 Ω |
| D1 | LED (5 mm) | 赤 (H) |
| D2 | LED (5 mm) | 緑 (L) |
| C3 | フィルムコンデンサ | 0.1 µF (104) |
| R6 | 抵抗 (1/4 W) | 10 kΩ |
| E1 | クリスタルイヤホン | 高インピーダンスの品 (ゲルマニウムラジオ用)。実体配線図ではスピーカーの形で描いた |
| — | 電源 | AD3 の V+ (5 V)。プローブとして使うときは、測る回路の 5 V と GND からもらう |

## 見るべき値

| TIP に入れるもの (W1) | 期待する答え | 分かること |
| --- | --- | --- |
| DC 0 V | 緑だけ点く (4.4 mA) | L |
| DC 5 V | 赤だけ点く (4.4 mA) | H |
| 何もつながない (W1 を抜く) | どちらも消える。X は 2.5 V | 浮き。テスターでは見分けにくい |
| DC 2.0 V | どちらも消える | 1.46〜2.91 V の間は「H でも L でもない」(CMOS で入力が中途半端な電圧のとき) |
| 方形波 1 Hz (0〜5 V) | 赤と緑が 0.5 s ずつ交互に点く | ゆっくりなパルスは目で追える |
| 方形波 1 kHz (0〜5 V) | 赤と緑が両方点いて見える (半分ずつの明るさ)。イヤホンからピーという 1 kHz の音 | 速いパルスは LED ではまとまって見え、音で「動いている」と分かる |
| 方形波 1 kHz のときの CH2 (イヤホン) | ±3.1 V (6.2 Vpp) の微分波形 | 図3 |

1 kHz を 100 Hz・3 kHz と変えると、音の高さがそのまま変わる。分周回路 (第 10 章) の出力を順に当たると、
段ごとに 1 オクターブずつ下がって聞こえ、どこで止まっているかがすぐ分かる。

## LTspice での確かめ

`sim/10-logic-probe.cir` で、図1 の窓コンパレータの .op を、TIP を 0 V・5 V・開放 (1 GΩ で浮かせる)・2.0 V・3.2 V にして解いた。
LM393 は開コレクタの比較器の行動模型 (出力を 25 Ω で GND へ引く、入力電流 0)、LED は 1-1 の模型で、どちらも仮定。
イヤホンの道は `sim/10-logic-probe-ear.cir` の .tran (0〜5 V・1 kHz の方形波) で、20〜30 ms の波形の最大・最小を読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| しきい値 (上・下) | 2.91 V・1.46 V | 2.913 V・1.456 V | 合う |
| TIP 0 V | 緑 4.4 mA、赤 0 | 緑 4.31 mA、赤 0 | 合う |
| TIP 5 V | 赤 4.4 mA、緑 0 | 赤 4.31 mA、緑 0 | 合う |
| 開放 | X 2.5 V、どちらも 0 | X 2.499 V、どちらも 0 | 合う |
| TIP 2.0 V / 3.2 V | 消える / 赤 | 消える / 赤 4.31 mA | 合う |
| イヤホンの山 (1 kHz) | ±3.1 V | +3.11 V・−3.11 V (6.22 Vpp) | 合う |

## 出典

自作。

参考: [LM393 データシート (TI, SLCS005)](https://www.ti.com/lit/ds/symlink/lm393.pdf)、[Logic probe (Wikipedia)](https://en.wikipedia.org/wiki/Logic_probe)、[Lessons in Electric Circuits Vol. VI 第 4 章 (AC 回路の実験。Sensitive audio detector)](https://www.ibiblio.org/kuphaldt/electricCircuits/Exper/EXP_4.html)
