---
book: analog-discovery
chapter: 7
id: 7-16
title: パターンで状態機械 (ROM もどき)
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Patterns の ROM Logic)
board: BB
---

# 7-16 パターンで状態機械 (ROM もどき)

**状態機械** (ステートマシン) は、いまの状態と入力から次の状態を決める回路。部品で組むなら、状態を覚える D フリップフロップ
(回路の教科書の 10-5) と、次の状態を計算する組み合わせ回路が要る。組み合わせ回路の部分は、入力を番地にして出力を読み出す
**ROM (読み出し専用のメモリ) の表**に置き換えられる。番地 = (入力, いまの状態)、中身 = (次の状態, 出力) の表を作れば、どんな状態機械も書ける。

Pattern の **ROM Logic** は、この表を AD3 の中に持つ機能。ヘルプによれば、表の左に入力、右に出力を並べ、入力の値は 0・1・X (どちらでもよい) で書く。
状態の線は入力と出力の両方に選んだ DIO で、決めた Frequency ごとに表を引いて書き換わる。ここでは押しボタン付きの信号機を作る。

| いまの状態 (Q1 Q0) | 意味 | ボタン BTN | 次の状態 | 次の状態で点く LED |
| --- | --- | --- | --- | --- |
| 00 | 緑 | 0 | 00 (緑のまま) | G |
| 00 | 緑 | 1 | 01 | Y |
| 01 | 黄 | X | 10 | R |
| 10 | 赤 | X | 11 | R |
| 11 | 赤 (待ち) | X | 00 | G |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 押しボタンを DIO8 に、信号機の 3 色の LED を DIO2-DIO4 に
parts:
  AD:
    type: device
    at: 2,4
    label: Analog Discovery 3
    pins: [V+, DIO8, DIO2, DIO3, DIO4, GND]
    turn: mirror
  SW1: button 7,1.5 7,2.75
  R1: resistor 8,2.75 9.5,2.75 10k
  G2: ground 9.5,2.75
  RR: resistor 9,5 9,6 1k l=$R_\mathrm{R}$
  DR: led 9,6 9,7 red l=$D_\mathrm{R}$
  RY: resistor 11,5 11,6 1k l=$R_\mathrm{Y}$
  DY: led 11,6 11,7 yellow l=$D_\mathrm{Y}$
  RG: resistor 13,5 13,6 1k l=$R_\mathrm{G}$
  DG: led 13,6 13,7 green l=$D_\mathrm{G}$
  G1: ground 5.5,7.5
wires:
  - AD.V+ -| 5,1.5
  - 5,1.5 -- 7,1.5
  - 7,2.75 -- 8,2.75
  - 7,2.75 -- 7,3.75
  - AD.DIO8 -- 7,3.75
  - AD.DIO2 -| 13,5
  - AD.DIO3 -| 11,5
  - AD.DIO4 -| 9,5
  - AD.GND -| 5.5,7.5
  - 5.5,7.5 -- 9,7.5
  - 9,7.5 -- 11,7.5
  - 11,7.5 -- 13,7.5
  - 9,7 -- 9,7.5
  - 11,7 -- 11,7.5
  - 13,7 -- 13,7.5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/16-rom-state-machine.svg)

- ボタン SW1 は V+ (3.3 V) と DIO8 の間。R1 (10 kΩ (オーム)) は押していないとき DIO8 を L にするプルダウン。押すと 3.3 V ÷ 10 kΩ = 0.33 mA
- DIO2・DIO3・DIO4 に 1 kΩ と LED (緑・黄・赤)。DIO の H は 3.3 V なので、LED の電流は (3.3 V − 2.0 V) ÷ 1 kΩ ≈ 1.3 mA (V<sub>F</sub> 2.0 V の目安)。
  DIO から引く電流を小さくするため 1 kΩ にした (暗いが見える)
- 状態の 2 ビット Q1・Q0 は DIO1・DIO0 に出す。基板にはつながず、Logic で見るだけ。ROM Logic の状態は AD3 の中で折り返されるので、線をつながなくても動く (ヘルプの internal loopback)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (LED は左から赤・黄・緑)
board: half
parts:
  SW1: button @ e5
  R1: resistor h7 h10 10k
  RR: resistor i12 i15 1k
  DR: led h15(A) h17(K) red
  RY: resistor i18 i21 1k
  DY: led h21(A) h23(K) yellow
  RG: resistor i24 i27 1k
  DG: led h27(A) h29(K) green
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, DIO8, GND, DIO4, DIO3, DIO2]
wires:
  - AD.V+ -- +b2 red
  - +b1 -- +t1 red
  - a5 -- +t5 red
  - AD.DIO8 -- j5 yellow
  - j10 -- -b10 black
  - AD.GND -- -b8 black
  - AD.DIO4 -- j12 white
  - AD.DIO3 -- j18 orange
  - AD.DIO2 -- j24 blue
  - j17 -- -b17 black
  - j23 -- -b23 black
  - j29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/16-rom-state-machine.svg)

- SW1 (タクトスイッチ) は e5 で溝をまたぐ。上の 5 列 (e5・e7 の組) を + レールへ、下の 5 列に DIO8 (黄)、下の 7 列から R1 (h7〜h10) を − レールへ
- LED は 15〜29 列に赤・黄・緑。1 kΩ (i 行) から LED のアノード (h 行の左)、カソード (右) の列を j 行の黒い線で − レールへ
- AD3 は下に置く。V+ を下の + レールに入れ、1 列で上の + レールへ渡す。DIO4 (白)・DIO3 (橙)・DIO2 (青) を各色の 1 kΩ の列へ
- DIO0・DIO1 は基板につながない (Logic で見るだけ)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Pattern | Add → ROM Logic。入力 = DIO8 (BTN)・DIO1 (Q1)・DIO0 (Q0)、出力 = DIO1・DIO0・DIO2 (G)・DIO3 (Y)・DIO4 (R)。Frequency 1 Hz (目安。下限は版による)。表は下 |
| Logic | DIO0〜DIO4・DIO8。Rate 1 kHz、1 s/div、トリガは DIO8 の立ち上がり。Bus で Q1 Q0 を State (2 進) にまとめる |

見る物は 0 か 1 かと順序だけなので、オシロではなくロジックの画面にした。

ROM Logic の表 (上から順に評価し、後の行が前の行を上書きする。ヘルプの決め)。

| BTN | Q1 | Q0 | → Q1 | Q0 | G | Y | R |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 |
| 1 | 0 | 0 | 0 | 1 | 0 | 1 | 0 |
| X | 0 | 1 | 1 | 0 | 0 | 0 | 1 |
| X | 1 | 0 | 1 | 1 | 0 | 0 | 1 |
| X | 1 | 1 | 0 | 0 | 1 | 0 | 0 |

**LED の出力は「次の状態」に合わせて書く**。表は 1 回引くたびに Q と LED を同時に書き換えるので、いまの状態から LED を決めると、
LED が状態より 1 歩遅れる (ムーア型の出力を表に入れるときの決め)。
入力に選べる DIO は、ヘルプによれば Pattern の Custom のバッファの大きさで決まる (2 を底とする対数の本数。1k 標本なら DIO0〜DIO9)。DIO8 はこの内にある。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 ボタンを押すと、次の更新から 緑 → 黄 → 赤 → 赤 → 緑 と 1 s ずつ進む
device: ad3
time: 1s/div
start: 0s
sample: 1kHz
signals:
  BTN: dio8 edges 0s=0 2.3s=1 3.4s=0
  Q1:  dio1 edges 0s=0 4s=1 6s=0
  Q0:  dio0 edges 0s=0 3s=1 4s=0 5s=1 6s=0
  G:   dio2 edges 0s=1 3s=0 6s=1
  Y:   dio3 edges 0s=0 3s=1 4s=0
  R:   dio4 edges 0s=0 4s=1 6s=0
buses:
  State: Q1 Q0 bin
cursors: [3.5s, 5.5s]
trigger: BTN rising at 2.3s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/16-rom-state-machine.svg)

図3 は表から計算した理想の画面で、実測ではない。ボタンを 2.3 s から 3.4 s まで押したとする。表は 1 s ごと (1・2・3 … s) に引かれ、
3 s の更新で BTN = 1 を読んで 00 → 01 (黄)。そのあとはボタンに関係なく 01 → 10 → 11 → 00 と 1 s ずつ進み、6 s で緑に戻る。
X1 (3.5 s) は State 01・Y、X2 (5.5 s) は State 11・R。**ボタンを押した瞬間ではなく、次の更新で変わる** (同期式の回路の性質)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| SW1 | タクトスイッチ | 1 個 |
| R1 | 抵抗 (1/4 W)、プルダウン | 10 kΩ |
| RR・RY・RG | 抵抗 (1/4 W)、LED の電流制限 | 1 kΩ × 3 |
| DR・DY・DG | LED | 5 mm、赤・黄・緑 |
| — | 電源・計器 | Analog Discovery 3 (Supplies 3.3 V、Pattern の ROM Logic、Logic) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ボタンを押さないとき | 緑のまま、State 00 が続く | 00 と BTN = 0 の行が自分へ戻る |
| ボタンを押して離す | 次の更新から 黄 1 s → 赤 2 s → 緑 | 01 から先は入力に関係なく進む |
| 押してから黄になるまで | 0〜1 s (押した時刻と更新の時刻の差) | 入力は更新の時刻にだけ読まれる |
| 1 s より短く押して更新の間に離す | 何も起きない | 更新の間の入力は読まれない (取りこぼし) |
| 赤の間にもう一度押す | 何も起きない | 表の 01・10・11 の行は BTN が X |
| Frequency を 10 Hz にする | 同じ順で 10 倍速く進む | 状態の進み方は表だけで決まり、速さはクロック |

部品で組むなら、Q1・Q0 を 74HC74 の 2 個の D フリップフロップに、表を 8 番地 × 5 ビットの ROM か論理ゲートにする。
Pattern で表を先に確かめておけば、部品の回路を組んだときに「表の誤り」と「配線の誤り」を分けられる。

## LTspice での確かめ (対象外)

ロジックの状態機械の題。表を Python で引いて確かめた (8 番地を全部引き、図3 のボタンの時刻で 1〜10 s を進めた)。
次の状態は 00→00 (BTN 0)・00→01 (BTN 1)・01→10・10→11・11→00 で、図3 の State の並び 00・01 (3 s)・10 (4 s)・11 (5 s)・00 (6 s) と合う。
LED の電流は算術で (3.3 V − 2.0 V) ÷ 1 kΩ = 1.3 mA。

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Patterns の ROM Logic と Output、Logic の Bus)。

参考: [有限オートマトン (Wikipedia)](https://ja.wikipedia.org/wiki/有限オートマトン)
