---
book: circuits
chapter: 12
id: 12-8
title: 植物の水やりアラーム
tier: 200
source: 自作
board: PF
era: 古
---

# 12-8 植物の水やりアラーム

鉢植えの土に 2 本の電極を挿しておき、**土が乾いたら赤い LED が 1 秒に 1 回ぴかっと光って**水やりを知らせる。
湿った土は水に溶けた塩類で電気を通し、乾くと通しにくくなる (8-9 の電極で水位・土の湿りを見る考え方)。12-3 の水漏れアラームとは逆に、
**通さなくなったら知らせる**ので、電極の電流で発振を止める形にする。光らせるのはトランジスタ 2 個の非安定マルチバイブレータで、
古くからの電子工作の定番 (3-1 の LED 点滅)。短く光らせて長く休むので、電流が平均 2 mA ほどで済む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 土が乾くと Q1 が離れ、Q2・Q3 のマルチバイブレータが LED を 1 秒ごとに光らせる
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,1 2,3 10k
  P1: port 2,3
  RS: resistor-var 2,3 2,5 l=$R_\mathrm{soil}$
  P2: port 2,5
  VR1: potentiometer 4,6 4,8 50k l=$\mathrm{VR1}$
  G1: ground 4,8
  R2: resistor 7,1 7,3 4.7k
  R3: resistor 9,1 9,3 47k
  R4: resistor 11,1 11,3 100k
  R5: resistor 13,1 13,2 330
  D1: led 13,2 13,3 red
  Q2: npn 7,5 mirror
  Q3: npn 13,5
  C1: ecap 7,3.5 10,3.5 22u
  C2: ecap 13,4 11.75,4 4.7u
  G3: ground 7,6.5
  G4: ground 13,6.5
  Q1: npn 11.5,7.5
  G2: ground 11.5,8.5
wires:
  - 2,1 -- 7,1 -- 9,1 -- 11,1 -- 13,1
  - 2,5 -- 4,5 -- 4,6
  - 4,5 -- 5,5 -- 5,7.5 -- Q1.B
  - VR1.w -- 4,8
  - Q1.E -- 11.5,8.5
  - Q1.C -- 11.5,6.25 -- 11,6.25 -- 11,5
  - 7,3 -- 7,3.5 -- Q2.C
  - 9,3 -- 9,4 -- 9,5 -- Q2.B
  - 10,3.5 -- 11,3.5
  - 11,3 -- 11,3.5 -- 11,5 -- Q3.B
  - 11.75,4 -- 9,4
  - 13,3 -- 13,4 -- Q3.C
  - Q2.E -- 7,6.5
  - Q3.E -- 13,6.5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/08-plant-watering-alarm.svg)

- **電極 (P1・P2)**: 5 V から R1 (10 kΩ (オーム)) と土の抵抗 R<sub>soil</sub> を通して Q1 のベースへ。VR1 (B50K を可変抵抗として使う) がベースを GND へ引く。
  Q1 が入るのは、ベースが約 0.6 V を超えるとき: R<sub>soil</sub> < VR1 × (5 V ÷ 0.6 V − 1) − 10 kΩ。VR1 が中ほど (25 kΩ) なら約 170 kΩ より低いと「湿っている」(計算値)
- **非安定マルチバイブレータ (Q2・Q3)**: C1 (22 µF (マイクロファラド)) と R4 (100 kΩ) が Q3 の休む時間、C2 (4.7 µF) と R3 (47 kΩ) が Q3 の入っている時間 (LED が光る時間) を決める。
  目安は 0.69 × R × C で、光るのが 0.69 × 47 kΩ × 4.7 µF ≈ 0.15 秒、休むのが 0.69 × 100 kΩ × 22 µF ≈ 1.5 秒
- **止め方**: 土が湿っていると Q1 が入り、Q3 のベースを GND に押さえる。Q3 は入れず、C2 が Q2 を揺らさないので、Q2 が入りっぱなし・Q3 が切れっぱなしで止まり、LED は消える。
  Q1 は R4 の 50 µA を吸い込むだけでよいので、電極に流れる電流は 0.1 mA ほどで足りる (下の LTspice)
- 実物 (と LTspice) では休む時間が 0.84 秒ほどで、目安より短い。Q3 のベースが C1 で −2.8 V まで押し下げられたとき、Q1 のコレクタとベースの間の PN 接合が開いて、C1 を早く戻すため
- 電極は直流なので、何か月も挿したままにすると陽極の側が溶けてくる。ステンレスのねじや、ステンレスの線を使う。電流が小さい (湿っていて 0.1 mA ほど) ほど長持ちする

## ユニバーサル基板に組む

鉢の脇に置いたままにする作品なので、perfboard に組む。電極は 2 ピンのヘッダ J1 から線で鉢へ伸ばす。

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
  J1: sip2 b13
  R1: resistor b16 b14 10k
  VR1: potentiometer c9 d9 e9 50k
  Q1: transistor h11 g11 f11 2SC1815
  R2: resistor k16 k13 4.7k
  R3: resistor m16 m13 47k
  R4: resistor o16 o13 100k
  R5: resistor q16 q14 330
  D1: led q13 q11 red
  C1: capacitor/electrolytic k12 n12 22u
  C2: capacitor/electrolytic q10 m10 4.7u
  Q2: transistor j8 k8 l8 2SC1815
  Q3: transistor r8 q8 p8 2SC1815
wires:
  - PWR -- b17 red
  - b17 -- k17 red
  - k17 -- m17 red
  - m17 -- o17 red
  - o17 -- q17 red
  - q17 -- x17 red
  - GND -- d5 black
  - d5 -- e5 black
  - e5 -- h5 black
  - h5 -- j5 black
  - j5 -- r5 black
  - r5 -- x5 black
  - b16 -- b17 red
  - b14 -- b13
  - c13 -- c11 blue
  - c11 -- f11 blue
  - c11 -- c9 blue
  - d9 -- d5 black
  - e9 -- e5 black
  - h11 -- h5 black
  - g11 -- g14 green
  - g14 -- n14 green
  - n14 -- n12 green
  - k16 -- k17 red
  - k13 -- k12
  - k12 -- k8
  - m16 -- m17 red
  - m13 -- m10 white
  - m10 -- m8 white
  - m8 -- l8 white
  - o16 -- o17 red
  - o13 -- o12 green
  - n12 -- o12 green
  - o12 -- o8 green
  - o8 -- p8 green
  - q16 -- q17 red
  - q14 -- q13
  - q11 -- q10
  - q10 -- q9
  - q9 -- q8
  - j8 -- j5 black
  - r8 -- r5 black
notes:
  - mark a17 yellow
  - mark a5 yellow
  - mark q9 yellow
  - text a17 red large bold right: V+
  - text b4 red large bold center: GND
  - text s9 red large bold right: 1+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/08-plant-watering-alarm.svg)

- 部品面から見た図。上の 17 行が 5 V、下の 5 行が GND。左端の a17・a5 に電源をつなぐ
- 電極のヘッダ J1 (b13・c13): 1 番 (P1) は R1 (b16〜b14) で 5 V へ、2 番 (P2) は C 列を下りて 11 行を右へ Q1 のベース (f11) と、VR1 (c9〜e9) の 1 番へ。VR1 の中央 (ワイパー) と 3 番は GND へ
- トランジスタは 3 つとも 2SC1815 で、E C B の順に挿す: Q1 は h11・g11・f11、Q2 は j8・k8・l8、Q3 は r8・q8・p8。エミッタはどれも GND へ
- Q1 のコレクタ (g11) は緑の線で 14 行を右へ運び、N 列を下りて Q3 のベースの線 (O 列) へ。緑の線は R2・R3 の胴の下をくぐる (抵抗は基板から少し浮かせる)
- Q2 のコレクタ (k8) は R2 (k16〜k13) と C1 (k12〜n12、+ が左) へ。C1 の − は Q3 のベースの線へ。Q2 のベース (l8) は R3 (m16〜m13) と C2 (q10〜m10、+ が右) へ
- Q3 のベース (p8) は O 列で R4 (o16〜o13) へ。Q3 のコレクタ (q8) は LED (D1、q13 がアノード) と R5 (q16〜q14) で 5 V へ
- **AD3 は確かめるときだけ挟む一時的な接続**。V+ (5 V) を a17、GND を a5、Scope の 1+ を Q3 のコレクタ (q9) に挟む。1− は GND
- 流れる電流は平均 2.3 mA (乾いて点滅している間、LTspice) で、AD3 の Supplies と perfboard の範囲に収まる。ふだんは USB の 5 V か単 3 電池 3 本で動かす

## 計器の設定

計器は AD3 の Scope。電極を空中に置いた「乾いた」状態で、Q3 のコレクタが周期的に落ちる (LED が光る) のを見る。
次に J1 の 2 本の間に 10 kΩ の抵抗を挿して「湿った」状態にし、波が止まって 3.5 V ほどのままになるのを見る。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5 V |
| CH1 (1+) | Q3 のコレクタ (q9)。1 V/div、0 V を下から半目盛 |
| 時間レンジ | 200 ms/div |
| トリガ | CH1 の立ち下がり、1.8 V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Maximum・Minimum |
| カーソル | X1 を 60 ms (LED が光っている)、X2 を 500 ms (休んでいる) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 乾いた土 — Q3 のコレクタ (CH1) が約 1 秒ごとに 0.12 秒だけ落ち、LED が光る
time: 200ms/div
trigger: ch1 falling 1.8V at -4div
ch1: {wave: pulse 1.034Hz 1.69V offset 1.81V duty 87.3%, range: 1V/div, position: -3.5div}
cursors: [60ms, 500ms]
measure: [freq, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/08-plant-watering-alarm.svg)

- 周期 0.97 秒 (1.03 Hz)、落ちている時間 0.12 秒。X1 で 0.12 V (Q3 が飽和し、LED に 8.7 mA)、X2 で 3.5 V (LED が消えている)
- 実物では、休んでいる間のコレクタは C2 の充電で 3.4 V から 3.56 V へゆっくり上がる。図は平らに描いた
- J1 に 10 kΩ を挿すと波が止まる。100 kΩ でも止まり、330 kΩ では点滅が続く (VR1 が中ほどのとき)。VR1 を回すと、止まる境の抵抗が 30 kΩ ほどから 350 kΩ ほどまで動く (計算値)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1・Q2・Q3 | NPN トランジスタ | 2SC1815 |
| D1 | LED | 赤 5 mm |
| R1 | 抵抗 (電極の電流の制限) | 10 kΩ |
| R2 | 抵抗 | 4.7 kΩ |
| R3 | 抵抗 | 47 kΩ |
| R4 | 抵抗 | 100 kΩ |
| R5 | 抵抗 (LED の電流の制限) | 330 Ω |
| VR1 | 半固定抵抗 (感度) | B50K |
| C1 | 電解コンデンサ | 22 µF・16 V |
| C2 | 電解コンデンサ | 4.7 µF・16 V |
| J1 | ピンヘッダ (電極の線をつなぐ) | 2 ピン |
| — | 電極 | ステンレスのねじか線 2 本。2〜3 cm 離して土に挿す |
| — | 電源・計器 | 5 V (USB か単 3 電池 3 本)。確かめるときは Analog Discovery 3 の V+ と Scope (1+ = Q3 のコレクタ、1− = GND) |

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| 電極を空中に置く (乾き) | LED が約 1 秒ごとに 0.12 秒光る |
| J1 に 10 kΩ・100 kΩ を挿す (湿り) | LED が消えたまま |
| 止まる境 (VR1 が中ほど) | 土の抵抗が 150〜200 kΩ の間 (LTspice。計算値は 170 kΩ) |
| 光っている間の LED の電流 | 約 8.7 mA (R5 の両端の電圧 ÷ 330 Ω) |
| 電源の電流の平均 | 乾いて点滅中は 2.3 mA、湿って止まっている間は 1.3 mA ほど |

## LTspice での確かめ

`sim/08-plant-watering-alarm.cir` で、土の抵抗を 1 GΩ (乾き)・1 MΩ・300 kΩ・250 kΩ・200 kΩ・150 kΩ・100 kΩ・30 kΩ (湿り) の 8 通りにして 12 秒の過渡解析をし、4〜12 秒で測った。
VR1 は 25 kΩ (中ほどの仮定)、トランジスタは 2SC1815 の代用、LED は仮定の模型で表した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 乾き (1 GΩ) の周期・光る時間 | 約 1 秒・0.12 秒 (目安 0.15 秒) | 0.967 秒・0.123 秒 | 合う |
| 光っている間の LED の電流・コレクタ | 約 8.7 mA・0.12 V | 8.73 mA・0.118 V | 合う |
| 休んでいる間のコレクタ | 3.5 V ほど | 3.4〜3.56 V | 合う |
| Q3 のベースが押し下げられる電圧 | −2.8 V ほど | −2.77 V | 合う |
| 点滅が続く土の抵抗 | 200 kΩ 以上 | 1 GΩ・1 MΩ・300 kΩ・250 kΩ・200 kΩ で点滅 | 合う |
| 止まる土の抵抗 | 150 kΩ 以下 | 150 kΩ・100 kΩ・30 kΩ で止まる | 合う |
| 電源の電流の平均 (点滅中・止まり) | 2.3 mA・1.3 mA | 2.29 mA・1.23〜1.30 mA | 合う |

## 出典

自作。電極で土の乾きを見てトランジスタで知らせる形は、Talking Electronics の「Plant Needs Watering」(トランジスタ回路集) と同じ発想だが、回路は別に組み直した。

参考: [200 Transistor Circuits (Talking Electronics)](https://www.talkingelectronics.com/projects/200TrCcts/200TrCcts.html)、[マルチバイブレータ (Wikipedia)](https://ja.wikipedia.org/wiki/マルチバイブレータ)
