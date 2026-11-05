---
book: circuits
chapter: 12
id: 12-4
title: 電子ホタル — フェードイン・アウト
tier: 200
source: 自作
board: PF
---

# 12-4 電子ホタル — フェードイン・アウト

ホタルの光は、ぱっと点いて消えるのではなく、1〜2 秒かけてふわっと明るくなり、またゆっくり暗くなる。
LED を点滅させるだけなら 555 で足りるが、明るさを**なめらかに増やして減らす**には、電流をゆっくり上下させる波が要る。
ここでは 4-19 の三角波・方形波発生器を LM358 の 2 回路で 5 V 単電源に組み、周期 2.7 秒ほどの三角波を作る。
その三角波で 2SC1815 の電流を決め (4-15 のエミッタ抵抗で電流を決める考え方)、緑の LED をフェードイン・アウトさせる。
エミッタにダイオードを 2 本入れて、三角波の下半分では LED を消し、**暗い間と光る間**を交互に作る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 シュミット (U1B) と積分 (U1A) の三角波で、Q1 が LED の電流をゆっくり増やし減らす
parts:
  R1: resistor 1,4.38 3,4.38 68k
  R2: resistor 3,2 7,2 100k
  U1B: opamp 5,4.76 +up
  R4: resistor 9,4 12,4 1M
  C1: capacitor 12,2 16,2 1u
  U1A: opamp 14,4.38 +down
  VCC: vcc 10.5,5.5 5V
  R5: resistor 10.5,5.5 10.5,7.5 33k
  R6: resistor 10.5,7.5 10.5,9.5 18k
  G1: ground 10.5,9.5
  VCC: vcc 19,1 5V
  D3: led 19,1 19,3 green l=$D_3$
  Q1: npn 19,4.38
  D1: diode 19,5.5 19,6.75 1N4148
  D2: diode 19,6.75 19,8 1N4148
  R3: resistor 19,8 19,9.5 68
  G2: ground 19,9.5
  SQ: port 8,6
  TRI: port 18,6
wires:
  - 3,4.38 -| U1B.+
  - 3,4.38 -- 3,2
  - 7,2 -- 7,4.76
  - U1B.out -- 7,4.76 -- 8,4.76
  - 8,4.76 -- 8,4 -- 9,4
  - 8,4.76 -- 8,6
  - 12,4 -| U1A.-
  - 12,4 -- 12,2
  - 16,2 -- 16,4.38
  - U1A.out -- 16,4.38 -- 17,4.38
  - 17,4.38 -- 18,4.38 -- Q1.B
  - 18,4.38 -- 18,6
  - 17,4.38 -- 17,1 -- 1,1 -- 1,4.38
  - 4,7.5 |- U1B.-
  - 4,7.5 -- 10.5,7.5 -- 13,7.5
  - 13,7.5 |- U1A.+
  - 19,3 -- Q1.C
  - Q1.E -- 19,5.5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/04-electronic-firefly.svg)

- U1 は LM358 (2 回路入り)。図では電源のピンを省いた。8 番が 5 V、4 番が GND。U1A (1〜3 番) が積分、U1B (5〜7 番) がシュミット
- **基準の電圧 V<sub>ref</sub>**: 単電源なので、R5 (33 kΩ (オーム)) と R6 (18 kΩ) で 5 V × 18 / 51 = 1.76 V を作り、4-19 の 0 V の代わりにする。
  LM358 の出力 SQ は 0.1 V 付近と 3.5 V 付近 (電源より 1.5 V ほど低い所で頭打ち) の間を跳ぶので、その真ん中の 1.8 V に近い値を選んだ。
  真ん中から外すと、三角波の上りと下りの傾きがそろわない
- **積分 (U1A)**: SQ が Low の間は R4 (1 MΩ) に (1.76 − 0.1) V ÷ 1 MΩ ≈ 1.7 µA (マイクロアンペア) が流れ、C1 (1 µF) を充電して TRI が上がる。
  傾きは 1.7 µA ÷ 1 µF = 1.7 V/s。SQ が High の間は同じほどの傾きで下がる
- **シュミット (U1B)**: + 入力は TRI と SQ を R1 (68 kΩ) と R2 (100 kΩ) で分けた電圧で、これが V<sub>ref</sub> を横切ると SQ が跳ぶ。
  しきい値は TRI = V<sub>ref</sub> ± (SQ の振れの半分) × R1 / R2 ≈ 1.76 V ± 1.7 V × 0.68 で、**TRI は 0.58〜2.90 V を往復する**
- 周期: 2.32 V を 1.7 V/s で上り、同じほどで下りるので、半周期は約 1.36 秒、**周期は約 2.7 秒** (0.37 Hz)。
  式で書くと半周期は C1 × R4 × 2.32 V ÷ 1.7 V。LM358 の入力バイアス電流 (データシートで標準 20 nA、最大 250 nA) は 1.7 µA の 1〜15 % で、周期を少しずらす
- **LED の電流**: Q1 のベースに TRI を入れ、エミッタから D1・D2 (1N4148) と R3 (68 Ω) で GND へ。R3 の両端は
  TRI − V<sub>BE</sub> − 2 × V<sub>F</sub> ≈ TRI − 2.1 V になり、LED の電流はその ÷ 68 Ω。TRI が約 1.5 V より低い間は 3 つの PN 接合が開かず LED は消え、
  上で 2.90 V に届くと (2.90 − 2.12) V ÷ 68 Ω ≈ **11 mA**。ダイオードを抜くと、三角波のほとんどの間で LED が点いたままになり、暗い間が無くなる
- LED はコレクタ側にあるので、LED の V<sub>F</sub> (緑で約 2.1 V) の違いは電流に効かない。Q1 のコレクタは 5 V − 2.1 V ≈ 2.9 V、エミッタは最大 2.2 V で、Q1 は飽和しない

## ユニバーサル基板に組む

作品として飾っておくので、ブレッドボードではなく perfboard に組む。

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
  PWR: a17
  GND: a5
parts:
  U1: dip8 h12 LM358
  R5: resistor j17 j15 33k
  R6: resistor j8 j6 18k
  R2: resistor i14 k14 100k
  R1: resistor m14 m10 68k
  R4: resistor c11 c8 1M
  C1: capacitor f8 h8 1u
  Q1: transistor r11 q11 p11 2SC1815
  D3: led q16 q13 green
  D1: diode r10 t10 1N4148
  D2: diode u10 w10 1N4148
  R3: resistor x10 x6 68
wires:
  - PWR -- h17 red
  - h17 -- j17 red
  - j17 -- q17 red
  - q17 -- x17 red
  - GND -- j5 black
  - j5 -- k5 black
  - k5 -- x5 black
  - h12 -- h17 red
  - k9 -- k5 black
  - j12 -- j9 green
  - j12 -- j15 green
  - j9 -- j8 green
  - j6 -- j5 black
  - i12 -- i14 white
  - i12 -- i11 white
  - i11 -- c11 white
  - k12 -- k14 orange
  - k14 -- m14 orange
  - i9 -- i10 blue
  - i10 -- f10 blue
  - f10 -- f8 blue
  - c8 -- f8 blue
  - h9 -- h8 yellow
  - h8 -- h7 yellow
  - h7 -- m7 yellow
  - m10 -- m7 yellow
  - m7 -- p7 yellow
  - p7 -- p11 yellow
  - q17 -- q16 red
  - q13 -- q11
  - r11 -- r10
  - t10 -- u10
  - w10 -- x10
  - x6 -- x5 black
notes:
  - mark a17 yellow
  - mark a5 yellow
  - mark p7 yellow
  - mark x10 yellow
  - text a17 red large bold right: V+
  - text b4 red large bold center: GND
  - text p6 red large bold center: 1+
  - text x12 red large bold center: 2+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/04-electronic-firefly.svg)

- 部品面から見た図。上の 17 行が 5 V、下の 5 行が GND。左端の a17・a5 に AD3 の Supplies をつなぐ
- U1 (LM358) は切り欠きを左にして h12〜k12・h9〜k9 に挿す。上の段が左から 8 番 (V+、h12)・7 番 (SQ)・6 番・5 番、下の段が左から 1 番 (TRI、h9)・2 番・3 番・4 番 (GND、k9)
- **V<sub>ref</sub> は J 列の 1 本の筋**: R5 (j17〜j15) が 5 V から、6 番 (j12) と 3 番 (j9) を IC の下の緑の線でつなぎ、R6 (j8〜j6) で GND へ。
  IC の下を通す線は、半田面で IC のピンの間に這わせる
- SQ (7 番、i12) は上へ R2 (i14〜k14) へ、下へ IC の下の 11 行を左へ運んで R4 (c11〜c8) へ。R2 の右 (k14) は 5 番 (k12) と R1 (m14〜m10) につなぐ
- 2 番 (i9) は IC の下の 10 行を左へ運び、F 列を下りて C1 (f8〜h8) と R4 の下端 (c8) へ。1 番 (h9) から C1 の右 (h8) を経て、
  7 行を右へ R1 の下端 (m7) と Q1 のベース (p11) へ (黄)。黄の線は R6 の胴の下をくぐり、k7 で 4 番の GND の線 (黒) を跨ぐ
- Q1 (2SC1815) は E C B の順で r11・q11・p11。LED (D3) は q16 (アノード) から q13 (カソード) を Q1 のコレクタへ。
  エミッタ (r11) から D1 (r10〜t10)・D2 (u10〜w10、どちらも帯が右 = カソードが右) を経て R3 (x10〜x6) で GND へ
- **AD3 は測るときだけ挟む一時的な接続**。V+ (5 V) を a17、GND を a5、Scope の 1+ を TRI (p7)、2+ を R3 の上 (x10) に挟む。1−・2− は GND
- 流れる電流は平均 3 mA ほど (LED の平均 2.2 mA と LM358 自身の 0.7 mA)。AD3 の Supplies と perfboard の範囲に十分収まる

## 計器の設定

計器は AD3 の Scope。周期 2.7 秒のゆっくりした波なので、時間レンジを 500 ms/div にして 2 周期ほどを並べ、
**TRI が上にいる間だけ R3 に電圧が出る (LED が光る)**のを見る。R3 の電圧 ÷ 68 Ω が LED の電流。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5 V |
| CH1 (1+) | TRI (U1 の 1 番)。500 mV/div、0 V を下から半目盛 |
| CH2 (2+) | R3 の上 (LED の電流 × 68 Ω)。200 mV/div、0 V を下から半目盛 |
| 時間レンジ | 500 ms/div |
| トリガ | CH1 の立ち上がり、1.74 V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Maximum・Minimum |
| カーソル | X1 を 0.68 s (TRI の山)、X2 を 2.04 s (TRI の谷) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 三角波 (CH1) が上にいる間だけ R3 に電圧が出る (LED の電流 × 68 Ω)
time: 500ms/div
trigger: ch1 rising 1.74V at -4div
ch1: {wave: triangle 0.368Hz 1.16V offset 1.74V, range: 500mV/div, position: -3.5div}
ch2: {wave: ch1 | offset -2.12V | clip 0V, range: 200mV/div, position: -3.5div}
cursors: [0.68s, 2.04s]
measure: [freq, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/04-electronic-firefly.svg)

- CH1 は 0.58〜2.90 V、0.37 Hz の三角波。X1 (山) で CH1 = 2.90 V・CH2 = 0.78 V (LED は 11 mA)、X2 (谷) で CH2 = 0 V (LED は消えている)
- 図の CH2 は TRI − 2.12 V を 0 V で切った折れ線で描いた。実物では 3 つの PN 接合がなめらかに開くので、裾が丸く、点き始めは TRI = 1.5 V あたりから。
  目で見ると、1 周期 2.7 秒のうち 1.6 秒ほど光り、山へ向けて明るくなって戻る
- 方形波 SQ (7 番) も見たいときは、CH2 を i14 に移す。0.1 V と 3.5 V の間を跳び、TRI の山と谷で切り替わる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 2 回路オペアンプ | LM358 |
| Q1 | NPN トランジスタ | 2SC1815 |
| D1・D2 | 小信号ダイオード | 1N4148 |
| D3 | LED | 緑 5 mm (黄緑でもよい) |
| R1 | 抵抗 | 68 kΩ |
| R2 | 抵抗 | 100 kΩ |
| R3 | 抵抗 (LED の電流を決める) | 68 Ω |
| R4 | 抵抗 | 1 MΩ |
| R5 | 抵抗 | 33 kΩ |
| R6 | 抵抗 | 18 kΩ |
| C1 | フィルムコンデンサ | 1 µF (105)。電圧の向きが入れ替わるので電解は使わない |
| — | 電源・計器 | Analog Discovery 3 の Supplies の V+ (5 V) と Scope (1+ = TRI、2+ = R3 の上、1−・2− = GND) |

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| V<sub>ref</sub> (j12) | 1.76 V (テスター) |
| TRI (CH1) | 0.58〜2.90 V の三角波、周期 約 2.7 秒 |
| SQ (7 番) | 0.1 V と 3.5 V の間を跳ぶ方形波 |
| LED の電流の山 | 約 11 mA (CH2 の 0.78 V ÷ 68 Ω) |
| 光っている時間 | 1 周期のうち 1.6 秒ほど。残りの 1.1 秒は消えている |

周期を変えるには C1 か R4 を替える (どちらも周期に比例)。暗い間を短くするにはダイオードを 1 本にする。

## LTspice での確かめ

`sim/04-electronic-firefly.cir` で、電源を入れてから 30 秒の過渡解析をし、10〜30 秒の定常で測った。LM358 は 1 極の汎用模型
(出力 High は電源 − 1.5 V、Low は 0.1 V の仮定、入力バイアス電流は無し)、Q1 は 2SC1815 の代用、LED は緑の仮定の模型で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| V<sub>ref</sub> | 1.76 V | 1.765 V | 合う |
| TRI の山・谷 | 2.90 V・0.58 V | 2.897 V・0.585 V | 合う |
| SQ の High・Low | 3.5 V・0.1 V | 3.50 V・0.10 V | 合う (模型の仮定どおり) |
| 周期・SQ が High の時間 | 約 2.7 秒・約 1.36 秒 | 2.72 秒・1.33 秒 | 合う |
| LED の電流の山・R3 の電圧の山 | 約 11 mA・0.78 V | 11.4 mA・0.78 V | 合う |
| LED が点き始める TRI (0.1 mA) | 約 1.5 V | 1.54 V | 合う |
| 光っている時間 (0.1 mA 以上) | 1.6 秒ほど | 1.59 秒 | 合う |
| LED の平均の電流・Q1 の V<sub>CE</sub> の最小 | 2.2 mA・飽和しない | 2.23 mA・0.72 V | 合う |

## 出典

自作。積分とシュミットを輪にする形は 4-19 と同じ。LM358 の出力の振れと入力バイアス電流は [LM358 のデータシート (TI)](https://www.ti.com/lit/ds/symlink/lm358.pdf) による。

参考: [ホタル (Wikipedia)](https://ja.wikipedia.org/wiki/ホタル)、[Function generator (Wikipedia)](https://en.wikipedia.org/wiki/Function_generator)
