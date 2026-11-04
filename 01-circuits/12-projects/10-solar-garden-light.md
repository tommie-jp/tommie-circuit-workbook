---
book: circuits
chapter: 12
id: 12-10
title: ソーラーガーデンライト
tier: 200
source: 自作
board: PF
era: 今
---

# 12-10 ソーラーガーデンライト

庭に挿しておくと、昼は太陽電池で電池を充電し、暗くなると自分で LED を点ける明かり。市販品は専用の IC 1 つで組まれているが、
ここではトランジスタ 2 個で同じ働きを組む。仕組みは 2 つ: **太陽電池から電池へダイオードで充電する** (5-13 の太陽電池と蓄電)、
**太陽電池の電圧を明るさのセンサーとして使い、暗いときだけ LED を点ける** (8-18 の太陽電池を光センサーに)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 昼は太陽電池で電池を充電し、暗くなると Q2 が白い LED を点ける
parts:
  PV1: solar 1,3 1,5 l=$\mathrm{PV1}$
  G1: ground 1,5
  D1: schottky 2,3 2,1 1N5819
  R2: resistor 3,3 4.5,3 100k
  R3: resistor 4.5,3 4.5,5 100k
  G2: ground 4.5,5
  Q1: npn 5.5,3
  G3: ground 5.5,5
  R4: resistor 6.5,1 6.5,2.25 10k
  Q2: npn 8,3
  G4: ground 8,5
  R5: resistor 8,1 8,1.75 47
  D2: led 8,1.75 8,2.5 white
  BT1: battery 10,1 10,3 3.6V l=$\mathrm{BT1}$
  G5: ground 10,3
wires:
  - 1,3 -- 2,3 -- 3,3
  - 2,1 -- 6.5,1 -- 8,1 -- 10,1
  - 4.5,3 -- Q1.B
  - Q1.E -- 5.5,5
  - Q1.C |- 6.5,2.25
  - 6.5,2.25 -- 7,2.25 -- 7,3 -- Q2.B
  - Q2.C -- 8,2.5
  - Q2.E -- 8,5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/10-solar-garden-light.svg)

- 昼: PV1 (太陽電池、目安で開放 5 V 前後の小型品) の電流が D1 (1N5819) を通って BT1 (ニッケル水素電池 3 本、3.6 V) を充電する。
  夜は PV1 の電圧が 0 V 近くまで下がるが、D1 が電池から太陽電池への逆流を止める
- PV1 の電圧を R2・R3 (100 kΩ (オーム) ずつ) で半分にして Q1 のベースへ。明るい間は Q1 が入り、Q2 のベースを GND に落とすので、LED は消えている
- 暗くなって PV1 の電圧が 1.3 V ほどを切ると (ベースが約 0.65 V を切る)、Q1 が切れ、R4 (10 kΩ) が Q2 のベースへ電流を流して Q2 が入る。
  白い LED (D2) に R5 (47 Ω) を通して約 9.5 mA 流れる (下の LTspice)
- 太陽電池の短絡電流が電池の容量の 1/10 以下 (2000 mAh の電池なら 200 mA 以下) なら、ニッケル水素は止めずに充電し続けてよい (5-13 の考え方)。
  ここでは短絡電流 100 mA 以下の小型の太陽電池を使う

## ユニバーサル基板に組む

作品として屋外に置くので、perfboard に組む。太陽電池と電池はピンヘッダ (PV1・BT1) に線でつなぐ。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
title: 図2 perfboard に組む (部品面から見た図。黄色の丸は AD3 を挟む所)
points:
  BAT: a17
  GND: a5
parts:
  PV1: sip2 b7
  D1: schottky b12 b16 1N5819
  R2: resistor e9 i9 100k
  R3: resistor i8 i6 100k
  Q1: transistor m8 l8 k8 2SC1815
  R4: resistor l16 l12 10k
  Q2: transistor r8 q8 p8 2SC1815
  D2: led q14 q11 white
  R5: resistor s16 s14 47
  BT1: sip2 w10
wires:
  - BAT -- b17 red
  - b17 -- l17 red
  - l17 -- s17 red
  - s17 -- w17 red
  - GND -- c5 black
  - c5 -- i5 black
  - i5 -- m5 black
  - m5 -- r5 black
  - r5 -- x5 black
  - b16 -- b17 red
  - b7 -- b9
  - b9 -- b12
  - b9 -- e9
  - c7 -- c5 black
  - i9 -- i8
  - i6 -- i5 black
  - i9 -- k9
  - k9 -- k8
  - m8 -- m5 black
  - l16 -- l17 red
  - l12 -- l11
  - l11 -- l8
  - l11 -- p11
  - p11 -- p8
  - r8 -- r5 black
  - s16 -- s17 red
  - s14 -- q14
  - q11 -- q9
  - q9 -- q8
  - w10 -- w17 red
  - x10 -- x5 black
notes:
  - mark a17 yellow
  - mark a5 yellow
  - mark b9 yellow
  - mark q9 yellow
  - text a17 red large bold right: V+
  - text b4 red large bold center: GND
  - text d10 red large bold center: W1・1+
  - text q10 red large bold right: 2+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/10-solar-garden-light.svg)

- 部品面から見た図。上の 17 行が電池の +、下の 5 行が GND。PV1 (b7・c7) の 1 番が太陽電池の +、2 番が −。BT1 (w10・x10) も 1 番が +
- PV1 の + (b7) は B 列を上って b9 で分かれ、上は D1 (b12〜b16、帯が上 = カソードが上) から電池の + へ、右は R2 (e9〜i9) へ
- R2 と R3 (i8〜i6) の点 (i9) から Q1 のベース (k8) へ。Q1 と Q2 (2SC1815) は E C B の順に右から挿す (Q1 は m8・l8・k8、Q2 は r8・q8・p8)
- Q1 のコレクタ (l8) は L 列を上って R4 (l12〜l16) で電池の + へ。途中の l11 から 11 行を右へ運んで Q2 のベース (p8) へ
- R5 (s16〜s14) から D2 のアノード (q14) へ、D2 のカソード (q11) から Q2 のコレクタ (q8) へ
- **AD3 で確かめるとき**: 電池の代わりに Supplies の V+ を 3.6 V にして a17 へ、GND を a5 へ。太陽電池の代わりに W1 を PV1 の + の側 (b9) へ挟む。
  W1 は 0〜3.3 V に収め、V+ (3.6 V) を超えないので、D1 を通して V+ へ電流を押し込まない。Scope の 1+ を b9、2+ を Q2 のコレクタ (q9) に挟む
- 流れる電流は夜の LED の約 10 mA で、AD3 の Supplies と perfboard の範囲に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| PV1 | 太陽電池 (2 ピンのヘッダにつなぐ) | 開放 5 V 前後・短絡 100 mA 以下の小型品 |
| BT1 | ニッケル水素電池 (2 ピンのヘッダにつなぐ) | 単 3 × 3 本 (3.6 V) |
| D1 | ショットキーダイオード | 1N5819 |
| Q1・Q2 | NPN トランジスタ | 2SC1815 |
| D2 | LED | 白 5 mm |
| R2・R3 | 抵抗 | 100 kΩ |
| R4 | 抵抗 | 10 kΩ |
| R5 | 抵抗 (LED の電流の制限) | 47 Ω |
| — | 電源 | 3.6 V (電池。電池の電圧が題材なので 5 V ではない)。確かめるときは AD3 の V+ を 3.6 V |
| — | 計器 | Analog Discovery 3 の W1 (太陽電池の代わり、0〜3.3 V の三角波) と Scope (1+ = W1、2+ = Q2 のコレクタ) |

## 計器の設定

計器は AD3。太陽電池の代わりに W1 から 0〜3.3 V の三角波 (周期 4 秒) を出し、夕方から朝までを早回しにする。
**W1 が 1.3 V を切ると Q2 のコレクタが落ちて LED が点く**のを見る。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 3.6 V (電池の代わり) |
| W1 | 三角波 0.25 Hz、0〜3.3 V (振幅 1.65 V、オフセット 1.65 V) |
| CH1 (1+) | W1 (PV1 の +)。1 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | Q2 のコレクタ。1 V/div、0 V を下から半目盛 |
| 時間レンジ | 500 ms/div |
| トリガ | CH1 の立ち下がり、1.3 V。トリガの点を左から 3 目盛に置く |
| カーソル | X1 を 0.5 s (暗い)、X2 を 2.5 s (明るい) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 (太陽電池の代わり) が 1.3 V を切ると Q2 のコレクタが落ちる (LED が点く)
time: 500ms/div
trigger: ch1 falling 1.3V at -2div
ch1: {wave: triangle 0.25Hz 1.65V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: = 0.15V + 1.75V * step(ch1 - 1.33V), range: 1V/div, position: -3.5div}
cursors: [0.5s, 2.5s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/10-solar-garden-light.svg)

- 図の CH2 は、W1 が 1.33 V より低い間だけ 0.15 V (Q2 が飽和して LED が点いている)。高い間は 1.9 V ほど (LED がほとんど電流を流さない電圧。LED と温度で変わる)
- 点くしきい値と消えるしきい値はほぼ同じ (ヒステリシスが無い) ので、夕方の薄暗い間は LED が少しずつ明るくなる。図は理想の切り替わりで描いた
- 実物の太陽電池の電圧は明るさに対して対数のように変わり、曇りの昼でもかなり高い。1.3 V を切るのは日が沈んでから (目安)

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 太陽電池に光を当てる | LED が消える。電池へ充電の電流が流れる (D1 と直列にテスターの電流レンジを入れて確かめる) |
| 太陽電池を手で覆う | LED が点く |
| 夜の LED の電流 | 約 9.5 mA (R5 の両端の電圧 ÷ 47 Ω、計算値) |
| 夜に電池から出る電流 | 約 10 mA (LED と R4)。2000 mAh の電池なら 200 時間ほど |

## LTspice での確かめ

`sim/10-solar-garden-light.cir` で、太陽電池の電圧を 0〜3.3 V に振る直流の掃引をした。電池は 3.6 V の源、太陽電池は理想の電圧源、
Q1・Q2 は 2SC1815 の代用、白い LED は 10 mA で約 3.0 V の仮定の模型で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| LED が消えるしきい値 (2 mA を切る所) | 約 1.3 V | 1.33 V | 合う |
| 夜 (0 V) の LED の電流・LED の電圧 | 約 9.5 mA・約 3.0 V | 9.50 mA・3.00 V | 合う |
| 夜の Q2 のコレクタ | 約 0.15 V | 0.155 V | 合う |
| 夜に電池から出る電流 | 約 10 mA | 9.82 mA | 合う |
| 昼 (3.3 V) の LED の電流・Q2 のコレクタ | ほぼ 0・1.9 V ほど | 2 pA・1.91 V | 合う (コレクタの値は LED の模型しだい) |

## 出典

自作。

参考: [太陽電池 (Wikipedia)](https://ja.wikipedia.org/wiki/太陽電池)、[ニッケル・水素充電池 (Wikipedia)](https://ja.wikipedia.org/wiki/ニッケル・水素充電池)
