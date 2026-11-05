---
book: circuits
chapter: 12
id: 12-7
title: 電池チェッカー
tier: 200
source: 自作
board: PF
---

# 12-7 電池チェッカー

5-12 の電池残量チェッカーは、電池に何もつながない (開放の) 電圧を読んだ。ところがアルカリ乾電池は、使い込んでも開放の電圧はあまり下がらず、
**中の抵抗 (内部抵抗) が増える**。電流を取り出したとたんに電圧が落ちるので、開放の電圧だけでは「まだ使える」と見誤る。
そこでこの題では、ボタン S1 を押している間だけ電池に 33 Ω (オーム) の負荷をつなぎ、**電流を流した状態の電圧**を 4 段の LED で読む作品を組む。
比べるのは LM324 の 4 回路で、しきい値は 1.3・1.2・1.1・1.0 V。

| 押したときの電池の電圧 | D1 緑 (1.3 V) | D2 緑 (1.2 V) | D3 黄 (1.1 V) | D4 赤 (1.0 V) | 読み |
| --- | --- | --- | --- | --- | --- |
| 1.33 V より上 | 点く | 点く | 点く | 点く | 新品に近い |
| 1.22〜1.33 V | 消える | 点く | 点く | 点く | まだ十分 |
| 1.12〜1.22 V | 消える | 消える | 点く | 点く | 半分ほど |
| 1.02〜1.12 V | 消える | 消える | 消える | 点く | そろそろ替える |
| 1.02 V より下 | 消える | 消える | 消える | 消える | 使い切り |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 33 Ω をつないだ電池の電圧を LM324 の 4 回路で 1.3・1.2・1.1・1.0 V と比べる
parts:
  VCC: vcc 3,1 5V
  RA: resistor 3,1 3,3 36k
  RB: resistor 3,3 3,4.5 1k
  RC: resistor 3,4.5 3,6 1k
  RD: resistor 3,6 3,7.5 1k
  RE: resistor 3,7.5 3,9.5 10k
  G1: ground 3,9.5
  U1B: opamp 8,3.38 +up
  U1A: opamp 8,4.88 +up
  U1D: opamp 8,6.38 +up
  U1C: opamp 8,7.88 +up
  D1: led 12.5,3.38 10.5,3.38 green
  R1: resistor 14,3.38 12.5,3.38 330
  VCC: vcc 14,3.38 5V
  D2: led 12.5,4.88 10.5,4.88 green
  R2: resistor 14,4.88 12.5,4.88 330
  VCC: vcc 14,4.88 5V
  D3: led 12.5,6.38 10.5,6.38 yellow
  R3: resistor 14,6.38 12.5,6.38 330
  VCC: vcc 14,6.38 5V
  D4: led 12.5,7.88 10.5,7.88 red
  R4: resistor 14,7.88 12.5,7.88 330
  VCC: vcc 14,7.88 5V
  BT1: battery 5,10.5 5,12 l=$\mathrm{BT1}$
  G2: ground 5,12
  S1: button 7.5,10.5 7.5,11.5 l=$\mathrm{S1}$
  RL: resistor 7.5,11.5 7.5,13 33 l=$R_\mathrm{L}$
  G3: ground 7.5,13
wires:
  - 3,3 -| U1B.+
  - 3,4.5 -| U1A.+
  - 3,6 -| U1D.+
  - 3,7.5 -| U1C.+
  - 6,3.76 -| U1B.-
  - 6,5.26 -| U1A.-
  - 6,6.76 -| U1D.-
  - 6,8.26 -| U1C.-
  - 6,3.76 -- 6,5.26 -- 6,6.76 -- 6,8.26 -- 6,9.5
  - 6,9.5 -- 5,9.5 -- 5,10.5
  - 6,9.5 -- 7.5,9.5 -- 7.5,10.5
  - U1B.out -- 10.5,3.38
  - U1A.out -- 10.5,4.88
  - U1D.out -- 10.5,6.38
  - U1C.out -- 10.5,7.88
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/07-battery-checker.svg)

- 分圧: RA (36 kΩ)・RB・RC・RD (1 kΩ ずつ)・RE (10 kΩ) の合計 49 kΩ に 5 V を掛けると 0.102 mA が流れ、しきい値は上から 1.327・1.224・1.122・1.020 V (5-12 と同じ考え方で、段を 1 つ増やした)
- **電池を − 入力、しきい値を + 入力**に入れる。電池がしきい値より高いと出力が Low に落ち、5 V から R (330 Ω) と LED を通して出力へ電流を吸い込んで LED が点く。
  5-12 とは + と − が逆で、LED を 5 V の側に置いた。こうすると 4 つの LED を基板の上の 5 V の筋から並べて引ける (下の図2)
- LED の電流は (5 V − V<sub>F</sub> − 出力の Low) ÷ 330 Ω で 8〜9 mA ほど (LTspice。LM324 の出力の Low は電流を吸うと上がるので、実物は少し少ない)。消えている間は出力が 3.5 V ほどの High で、LED には 1.5 V しか掛からず光らない
- **S1 と R<sub>L</sub>**: S1 を押すと R<sub>L</sub> (33 Ω) がつながる。新しい単 3 (1.55 V、内部抵抗 0.2 Ω ほど、目安) なら 47 mA で、R<sub>L</sub> の電力は 1.54 V × 47 mA ≈ 72 mW。
  1/4 W の抵抗の半分 (125 mW) より小さいので、押し続けても熱くならない。押すのは読む間の数秒にする (電池を減らさないため)
- 使い込んだ電池の例 (仮定): 開放 1.35 V・内部抵抗 4.7 Ω なら、押したときは 1.35 V × 33 ÷ (33 + 4.7) ≈ 1.18 V。押す前は 4 つとも点くが、押すと 2 つに減る。
  内部抵抗は (押す前 − 押した後) ÷ 電流 = 0.17 V ÷ 36 mA ≈ 4.7 Ω と読める
- LM324 の電源 (4 番が 5 V、11 番が GND) は図に描いていない。U1A〜U1D は LM324 の 1〜4 番の回路 (ピンの番号は図2 の説明)

## ユニバーサル基板に組む

作品として手元に置くので perfboard に組む。部品が 20 個ほどになるので、5×7 cm に収まらず、次の 9×7 cm (7×9 cm の基板を横に使う) にした。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 9x7cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
title: 図2 perfboard に組む (部品面から見た図。黄色の丸は AD3 を挟む所)
points:
  PWR: a23
  GND: a4
parts:
  U1: dip14 p11 r180 LM324
  RA: resistor l21 l18 36k
  RB: resistor l16 n16 1k
  RC: resistor o16 s16 1k
  RD: resistor l8 n8 1k
  RE: resistor l7 l5 10k
  R1: resistor j22 j20 330
  D1: led j19 j17 green
  R2: resistor p22 p20 330
  D2: led p19 p17 green
  R3: resistor r22 r20 330
  D3: led r19 r17 yellow
  R4: resistor h22 h20 330
  D4: led h19 h17 red
  BT1: sip2 c8
  S1: button f9
  RL: resistor i7 k7 33
wires:
  - PWR -- h23 red
  - h23 -- j23 red
  - j23 -- l23 red
  - l23 -- m23 red
  - m23 -- p23 red
  - p23 -- r23 red
  - r23 -- ae23 red
  - GND -- d4 black
  - d4 -- k4 black
  - k4 -- l4 black
  - l4 -- m4 black
  - m4 -- ae4 black
  - m14 -- m23 red
  - m11 -- m4 black
  - k14 -- k12 yellow
  - k12 -- k11 yellow
  - o14 -- o12 yellow
  - o12 -- o11 yellow
  - k12 -- o12 yellow
  - k11 -- k9 yellow
  - k9 -- h9 yellow
  - h9 -- f9 yellow
  - f9 -- c9 yellow
  - c9 -- c8 yellow
  - d8 -- d4 black
  - h7 -- i7
  - k7 -- k4 black
  - l23 -- l21 red
  - l14 -- l16 green
  - l16 -- l18 green
  - n14 -- n16 green
  - n16 -- o16 green
  - s16 -- s9 green
  - s9 -- n9 green
  - n9 -- n11 green
  - n9 -- n8 green
  - l11 -- l8 green
  - l8 -- l7 green
  - l5 -- l4 black
  - j23 -- j22 red
  - j20 -- j19
  - j17 -- j14
  - p23 -- p22 red
  - p20 -- p19
  - p17 -- p14
  - r23 -- r22 red
  - r20 -- r19
  - r17 -- r11 white
  - p11 -- r11 white
  - h23 -- h22 red
  - h20 -- h19
  - h17 -- h11 blue
  - j11 -- h11 blue
notes:
  - mark a23 yellow
  - mark a4 yellow
  - mark c9 yellow
  - mark p14 yellow
  - text a23 red large bold right: V+
  - text b3 red large bold center: GND
  - text c10 red large bold center: 1+
  - text q13 red large bold right: 2+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/07-battery-checker.svg)

- 部品面から見た図。上の 23 行が 5 V、下の 4 行が GND。左端の a23・a4 に電源をつなぐ
- **U1 (LM324) は切り欠きを右にして挿す** (図の向き)。上の段が左から 7 番 (2OUT)・6 番・5 番・4 番 (VCC+、m14)・3 番・2 番・1 番 (1OUT、p14)、
  下の段が 8 番 (3OUT)・9 番・10 番・11 番 (GND、m11)・12 番・13 番・14 番 (4OUT)。こう向けると、5 V のピンが上、GND のピンが下に来る
- 電池 (黄): − 入力の 4 本 (k14・o14・k11・o11) を IC の下でつなぎ、k11 から 9 行を左へ運んで電池のヘッダ BT1 (c8 が +、d8 が −) と S1 へ。S1 (f9) を押すと R<sub>L</sub> (i7〜k7) が GND とつながる
- しきい値 (緑): RA (l21〜l18) から 5 番 (1.327 V)、RB (l16〜n16) を経て 3 番 (1.224 V)、RC (o16〜s16) から S 列を下りて 12 番 (1.122 V)、RD (l8〜n8) を経て 10 番 (1.020 V)、RE (l7〜l5) で GND へ。
  RB は 5 V の線を、RC は D2・D3 の線を、RD は GND の線を、胴の下でまたぐ (線は胴の下を通してよい。部品と線が触れないよう、抵抗は基板から少し浮かせる)
- LED は上の 5 V から R (330 Ω) と LED を通して出力へ: H 列が D4 (赤、3OUT)、J 列が D1 (緑、2OUT)、P 列が D2 (緑、1OUT)、R 列が D3 (黄、4OUT)。
  基板の上の並びは左から 1.0・1.3・1.2・1.1 V なので、ケースの窓に値を書く
- **AD3 は確かめるときだけ挟む一時的な接続**。V+ (5 V) を a23、GND を a4、Scope の 1+ を電池の + (c9)、2+ を 1 番 (p14、1.2 V の段の出力) に挟む。1−・2− は GND
- 流れる電流は LED が 4 つ点いて 35 mA ほど (LTspice)。AD3 の Supplies と perfboard の範囲に収まる。R<sub>L</sub> の電流は電池から出るので、5 V には足されない

## 計器の設定

計器は AD3 の Scope。使い込んだ単 3 を BT1 につなぎ、S1 を押した瞬間の電池の電圧と、1.2 V の段の出力を見る。電池の電圧の下がり方が内部抵抗で、
**押す前は Low (LED が点く) だった出力が、押すと High (消える) に戻る**。図3 は開放 1.35 V・内部抵抗 4.7 Ω の仮定で描いた。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5 V |
| CH1 (1+) | 電池の + (c9)。50 mV/div、オフセットで 1.275 V を画面の中央に |
| CH2 (2+) | 1 番 (1OUT、1.2 V の段)。1 V/div、0 V を画面の下端 |
| 時間レンジ | 200 ms/div |
| トリガ | CH1 の立ち下がり、1.27 V (Single)。トリガの点を左から 2 目盛に置く |
| Measurements | Maximum・Minimum |
| カーソル | X1 を −200 ms (押す前)、X2 を 400 ms (押した後) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 押すと電池 (CH1) が 1.18 V に下がり、1.2 V の段 (CH2) が消える
time: 200ms/div
trigger: ch1 falling 1.27V at -3div
ch1: {wave: = 1.35V - 0.168V * step(t), range: 50mV/div, position: -25.5div}
ch2: {wave: = 0.1V + 3.4V * step(t), range: 1V/div, position: -4div}
cursors: [-200ms, 400ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/07-battery-checker.svg)

- X1 (押す前) で CH1 = 1.35 V・CH2 = 0.1 V、X2 (押した後) で CH1 = 1.18 V・CH2 = 3.5 V。CH1 の差 0.168 V ÷ 電流 36 mA ≈ 4.7 Ω が内部抵抗
- 実物では、押した瞬間に S1 の接点がはねて数 ms だけ波が乱れる。電池は押し続けると少しずつ下がっていく (化学反応が追いつかない)。図は理想の段差で描いた
- 新しい電池では CH1 は 0.01 V ほどしか下がらない (内部抵抗 0.2 Ω × 47 mA、目安)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 4 回路オペアンプ (比較器として使う) | LM324 |
| D1・D2 | LED | 緑 5 mm |
| D3 | LED | 黄 5 mm |
| D4 | LED | 赤 5 mm |
| R1〜R4 | 抵抗 (LED の電流の制限) | 330 Ω |
| RA | 抵抗 | 36 kΩ |
| RB・RC・RD | 抵抗 | 1 kΩ |
| RE | 抵抗 | 10 kΩ |
| R<sub>L</sub> | 抵抗 (負荷、1/4 W) | 33 Ω |
| S1 | タクトスイッチ | — |
| BT1 | 単 3 の電池ボックス (2 ピンのヘッダにつなぐ) | 調べる電池 1 本 (1.5 V のアルカリ乾電池) |
| — | 電源・計器 | 5 V (USB の 5 V か AD3 の V+)。Analog Discovery 3 の Scope (1+ = 電池の +、2+ = 1OUT、1−・2− = GND) |

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 5 番・3 番・12 番・10 番 (しきい値) | 1.327・1.224・1.122・1.020 V (テスター) |
| 新しい電池 (押す前・押した後) | 4 つとも点いたまま。電池の電圧は 1.55 V から 0.01 V ほどしか下がらない (目安) |
| 使い込んだ電池 (図3 の仮定) | 押す前は 4 つ、押すと 2 つ (D3・D4) |
| 押した間の電池の電流 | 電池の電圧 ÷ 33 Ω (1.54 V なら 47 mA) |
| 点いている LED の電流 | 8〜9 mA (R の両端の電圧 ÷ 330 Ω) |

## LTspice での確かめ

`sim/07-battery-checker.cir` で、電池の起電力を 0.9〜1.6 V に振る直流の掃引をし、S1 を離した状態と押した状態を比べた。電池は内部抵抗 4.7 Ω (仮定)、
LM324 は 5-12 と同じ汎用模型 (出力 High は電源 − 1.5 V、Low は 0.1 V の仮定)、LED は仮定の模型で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| しきい値 | 1.327・1.224・1.122・1.020 V | 1.327・1.224・1.122・1.020 V | 合う |
| LED が切り替わる電池の電圧 | しきい値と同じ | 1.326・1.224・1.122・1.020 V | 合う |
| 起電力 1.35 V で押したときの電池 | 約 1.18 V | 1.182 V | 合う |
| 点く LED の数 (押す前・押した後) | 4 つ・2 つ | 4・2 | 合う |
| 点いている LED の電流 (緑・赤) | 8〜9 mA | 8.5 mA・8.8 mA | 合う |
| 消えている LED の電流 | ほぼ 0 | 0.23 µA (マイクロアンペア) | 合う |
| 4 つ点いたときの 5 V の電流 | 35 mA ほど | 34.7 mA | 合う |

新しい電池 (1.55 V・0.2 Ω) で押したときの値 (1.54 V・47 mA・72 mW) は算術で出した: 1.55 V × 33 ÷ 33.2 = 1.541 V、1.541 V ÷ 33 Ω = 46.7 mA、1.541 V × 46.7 mA = 72 mW。

## 出典

自作。比較器としての使い方と入力の電圧の範囲は [LM324 のデータシート (TI)](https://www.ti.com/lit/ds/symlink/lm324.pdf) による。回路の考え方は 5-12 から。

参考: [アルカリマンガン乾電池 (Wikipedia)](https://ja.wikipedia.org/wiki/アルカリマンガン乾電池)、[内部抵抗 (Wikipedia)](https://ja.wikipedia.org/wiki/内部抵抗)
