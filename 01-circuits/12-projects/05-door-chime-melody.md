---
book: circuits
chapter: 12
id: 12-5
title: ドアチャイム / メロディ IC
tier: 200
source: 自作
board: PF
era: 古
---

# 12-5 ドアチャイム / メロディ IC

メロディ IC は、曲を覚えた ROM と発振回路と出力を、TO-92 の 3 本足の胴に詰めた IC。電源を入れるだけで曲を出す。
古くから電話の保留音やおもちゃ、ドアチャイムに使われてきた定番が UM66T (曲ごとに型番の末尾が違う。-19L が「エリーゼのために」など)。
ここでは、ボタンを押している間だけ UM66T に電源を入れ、出力で 2SC1815 を開け閉めしてスピーカーを鳴らす。

UM66T の電源は 1.3〜3.3 V (データシートの動作電圧)。5 V をそのまま入れると範囲を超える (絶対最大は 5.0 V) ので、
抵抗とツェナーダイオードで 3.0 V に下げる (5-2 のツェナーの定電圧)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 押している間だけ UM66T に 3.0 V を入れ、2SC1815 でスピーカーを鳴らす
parts:
  VCC: vcc 1,1 5V
  SW1: button 1,1 1,2.5 l=$\mathrm{SW1}$
  R1: resistor 1,2.5 3,2.5 1k
  DZ: zener 3,4.5 3,2.5 3.0V l=$D_Z$
  C1: ecap 4,2.5 4,4.5 100u
  G1: ground 3,4.5
  G2: ground 4,4.5
  U1: ic3 6.5,3.5 r180 UM66T
  G4: ground 5.25,4.5
  R2: resistor 8,3.5 9.25,3.5 4.7k
  Q1: npn 10,3.5
  VCC: vcc 10,1 5V
  R3: resistor 10,1 10,2 100
  SP1: speaker 10,2 10,3 8 l=$\mathrm{SP1}$
  G3: ground 10,4.5
wires:
  - 3,2.5 -- 4,2.5 -- 6.5,2.5
  - U1.2 -- 6.5,2.5
  - U1.3 -| 5.25,4.5
  - U1.1 -- 8,3.5
  - 9.25,3.5 -- Q1.B
  - 10,3 -- Q1.C
  - Q1.E -- 10,4.5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/05-door-chime-melody.svg)

- SW1 を押すと、R1 (1 kΩ (オーム)) と D<sub>Z</sub> (3.0 V のツェナー) が UM66T の VDD (2 番) を 3.0 V にする。UM66T は最大 50 µA (マイクロアンペア) しか引かないので、
  R1 の 2 mA ほどのほとんどは D<sub>Z</sub> を流れる
- C1 (100 µF) は、ボタンの接点のはねで電源が途切れないようにする。離したあとも、C1 の電荷で 0.5 秒ほど鳴り続ける (計算値。下の「見るべき値」)
- UM66T の出力 (1 番) は、音の高さの周波数で VDD と GND を行き来する方形波。出力の電流は 2 mA 以上 (データシート) とれるので、
  R2 (4.7 kΩ) を通して Q1 (2SC1815) のベースを直接動かす (データシートの使い方の例と同じ形)
- スピーカー (8 Ω) は R3 (100 Ω) と直列で 5 V から鳴らす。Q1 が開いた瞬間の電流は 5 V ÷ 108 Ω ≈ 43 mA。R3 の平均の電力は 0.09 W なので 1/2 W の品にする
- UM66T の 3 本は、平らな面を見て左から 1 番 (O/P)・2 番 (VDD)・3 番 (VSS) (データシートの Pin Configuration (Front View))

## ユニバーサル基板に組む

作品として仕上げるので、perfboard に組む。

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
  SW1: button b13
  R1: resistor e11 h11 1k
  DZ: zener j6 j10 3.0V
  C1: capacitor/electrolytic l11 l7 100u v=16V
  U1: ic3 p9 o9 n9 UM66T
  R2: resistor q7 u7 4.7k
  Q1: transistor x7 w7 v7 2SC1815
  R3: resistor v16 v13 100
  SP1: sip2 v11
wires:
  - PWR -- b17 red
  - b17 -- v17 red
  - v17 -- v16 red
  - GND -- j5 black
  - j5 -- l5 black
  - l5 -- n5 black
  - n5 -- x5 black
  - b13 -- b17 red
  - d11 -- e11
  - h11 -- j11
  - j11 -- j10
  - j11 -- l11
  - l11 -- o11
  - o11 -- o9
  - j6 -- j5 black
  - l7 -- l5 black
  - n9 -- n5 black
  - p9 -- p7
  - p7 -- q7
  - u7 -- v7
  - x7 -- x5 black
  - v13 -- v11
  - w11 -- w7
notes:
  - mark a17 yellow
  - mark a5 yellow
  - mark p7 yellow
  - mark w8 yellow
  - text a17 red large bold right: V+
  - text b4 red large bold center: GND
  - text p6 red large bold center: 1+
  - text x9 red large bold center: 2+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/05-door-chime-melody.svg)

- 部品面から見た図。上の 17 行が 5 V、下の 5 行が GND。左端の a17・a5 に AD3 の Supplies をつなぐ
- SW1 (b13) は上の 2 本を 5 V へ、下の d11 から R1 (e11〜h11) へ。h11 から 11 行を右へ運び、D<sub>Z</sub> (j6〜j10、帯が上 = カソードが上)・C1 (l11〜l7、+ が上) を経て
  UM66T の VDD (o9) へ下ろす
- UM66T (U1) は平らな面を手前にして、**左から 3 番・2 番・1 番の順** (n9・o9・p9) に挿す。図は上から見ているので、1 番 (O/P) が右に来る。3 番 (n9) は GND へ
- 1 番 (p9) から R2 (q7〜u7) を通して Q1 のベース (v7) へ。Q1 (2SC1815) は E C B の順で x7・w7・v7。E (x7) は GND へ
- R3 (v16〜v13) は 5 V からスピーカーのピンヘッダ SP1 (v11・w11) の 1 番へ。SP1 の 2 番 (w11) から Q1 のコレクタ (w7) へ。スピーカーの線はこのピンヘッダに挿す
- **AD3 は測るときだけ挟む一時的な接続**。V+ (5 V) を a17、GND を a5、Scope の 1+ を UM66T の出力 (p7)、2+ を Q1 のコレクタ (w8) に挟む。1−・2− は GND
- 流れる電流は平均で 23 mA ほど (下の LTspice)。AD3 の Supplies の 50 mA と、perfboard の範囲に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | メロディ IC | UM66T (末尾の数字で曲が違う。例: UM66T-19L) |
| Q1 | NPN トランジスタ | 2SC1815 |
| D<sub>Z</sub> | ツェナーダイオード | 3.0 V (0.5 W)。UM66T の電源 (1.3〜3.3 V) に合わせて 3.3 V より低い品 |
| R1 | 抵抗 | 1 kΩ |
| R2 | 抵抗 | 4.7 kΩ |
| R3 | 抵抗 (スピーカーの電流の制限、1/2 W) | 100 Ω |
| C1 | 電解コンデンサ | 100 µF・16 V |
| SW1 | タクトスイッチ | — (玄関のボタンの代わり) |
| SP1 | スピーカー (2 ピンのヘッダにつなぐ) | 8 Ω、0.5 W 程度の小型品 |
| — | 電源・計器 | Analog Discovery 3 の Supplies の V+ (5 V) と Scope (1+ = U1 の出力、2+ = Q1 のコレクタ、1−・2− = GND) |

## 計器の設定

計器は AD3 の Scope。SW1 を押している間の UM66T の出力と Q1 のコレクタを重ね、**出力が H の間だけコレクタが 0.4 V ほどまで落ちる**のを見る。
曲の音の高さはどんどん変わるので、図3 はラ (440 Hz) の音が出ている瞬間を例に描いた。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5 V |
| CH1 (1+) | UM66T の出力 (1 番)。1 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | Q1 のコレクタ。2 V/div、0 V を下から半目盛 |
| 時間レンジ | 1 ms/div |
| トリガ | CH1 の立ち上がり、1.5 V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Maximum・Minimum |
| カーソル | X1 を 0.5 ms (出力が H)、X2 を 1.7 ms (出力が L) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ラ (440 Hz) が鳴っている瞬間 — UM66T の出力 (CH1) と Q1 のコレクタ (CH2)
time: 1ms/div
trigger: ch1 rising 1.5V at -4div
ch1: {wave: square 440Hz 1.5V offset 1.5V, range: 1V/div, position: 0.5div}
ch2: {wave: = 5V - 4.6V * ch1 / 3V, range: 2V/div, position: -3.5div}
cursors: [0.5ms, 1.7ms]
measure: [freq, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/05-door-chime-melody.svg)

- CH1 は 0〜3.0 V の方形波 (VDD = D<sub>Z</sub> の 3.0 V まで振れる)。CH2 は逆向きで、出力が H の間は 0.4 V ほど (Q1 が飽和)、L の間は 5 V
- X1 は CH1 = 3.0 V・CH2 ≈ 0.4 V、X2 は CH1 = 0 V・CH2 = 5 V。図は理想の形で、実物のコレクタにはスピーカーのコイルによる跳ね (立ち上がりの山) が乗る
- UM66T の発振 (データシートで 63〜117 kHz) は IC の中で分周されて音になる。音の高さは個体で ±3 割ほどずれうる (目安)

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| SW1 を押している間 | 曲が鳴る (UM66T の曲) |
| UM66T の VDD (2 番) | 約 3.0 V (テスター) |
| Q1 が開いた間の電流 | 約 43 mA (R3 の両端の電圧 ÷ 100 Ω、計算値) |
| SW1 を離したあと | 0.5 秒ほどで止まる (C1 100 µF が UM66T と R2 の平均 0.3 mA ほどで 3.0 V から 1.3 V まで下がる時間、計算値) |

## LTspice での確かめ

`sim/05-door-chime-melody.cir` で、SW1 を押した状態を解いた。UM66T は VDD から 50 µA を引く電流源と、440 Hz で VDD と GND を行き来する出力 (内部抵抗 300 Ω の仮定) で表し、
D<sub>Z</sub> は 3.0 V のツェナー (仮定の模型)、Q1 は 2SC1815 の代用、スピーカーは 8 Ω の抵抗で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| UM66T の VDD | 約 3.0 V | 3.03 V | 合う |
| Q1 のベース電流 | (3.0 V − 0.7 V) ÷ 5 kΩ ≈ 0.46 mA | 0.45 mA | 合う |
| Q1 が開いた間の電流・コレクタの電圧 | 約 43 mA・約 0.4 V | 42.6 mA・0.40 V | 合う |
| R3 の平均の電力 | 0.09 W | 0.091 W | 合う (1/2 W の半分以下) |
| 5 V から引く平均の電流 | 23 mA ほど | 23.3 mA | 合う |

## 出典

自作。UM66T の電源の範囲・出力の電流・ピンの並び・使い方の例 (NPN トランジスタでスピーカーを駆動) は [UM66T のデータシート](https://kyohritsu.com/eclib/OTHER/DATASHEET/um66t.pdf) による。

参考: [ツェナーダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/ツェナーダイオード)
