---
book: circuits
chapter: 10
id: 10-15
title: トランジスタで作るゲート (RTL / DTL)
tier: 200
source: 自作
era: 古
---

# 10-15 トランジスタで作るゲート (RTL / DTL)

10-1 で使った 74HC のゲートの中身は CMOS (P と N の MOSFET の組) だが、IC のロジックはトランジスタと抵抗だけの
**RTL** (Resistor-Transistor Logic) から始まった。次に入力をダイオードで受ける **DTL** (Diode-Transistor Logic) が続き、
その後の TTL (74 シリーズの元) につながる。どちらも 1960 年代の古典で、今は部品で組むことは無いが、
「しきい値」「ノイズマージン」「入力が電流を流し出す」といった、ロジック IC のデータシートの言葉の意味が手で確かめられる。

この題では、2SC1815 と抵抗で 2 入力の RTL の NOR、1N4148 と 2SC1815 で 2 入力の DTL の NAND を同じブレッドボードに組み、
同じ入力 A・B を両方に入れて、真理値表と、入力をゆっくり上げたときに出力が切り替わる電圧 (しきい値) を比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 RTL の NOR (上) と DTL の NAND (下)。入力 A と B は両方に入る
parts:
  A: port 1,4 in
  Rb1: resistor 2,4 4,4 10k
  Q1: npn 5,4
  GQ1: ground 5,5
  B: port 1,6.5 in
  Rb2: resistor 2,6.5 4,6.5 10k
  Q2: npn 9,4
  GQ2: ground 9,5
  VCC: vcc 7,1 5V
  Rc1: resistor 7,1 7,2.5 1k
  NOR: port 12,2.5 out
  A: port 1,9 in
  D1: diode 4,9 2,9
  B: port 1,11 in
  D2: diode 4,11 2,11
  VCC: vcc 4,7.5 5V
  R1: resistor 4,7.5 4,9 4.7k
  D3: diode 4,10 6,10
  D4: diode 6,10 8,10
  Rbd: resistor 8,10 8,12 10k
  GRbd: ground 8,12
  Q3: npn 10,10
  GQ3: ground 10,11
  VCC: vcc 10,7.5 5V
  Rc2: resistor 10,7.5 10,9 1k
  NAND: port 12,9 out
wires:
  - 1,4 -- 2,4
  - 1,6.5 -- 2,6.5
  - 4,4 |- Q1.B
  - Q1.E -- 5,5
  - 4,6.5 -- 8,6.5
  - 8,6.5 |- Q2.B
  - Q2.E -- 9,5
  - Q1.C -- 5,2.5 -- 7,2.5
  - 7,2.5 -- 9,2.5
  - Q2.C -- 9,2.5
  - 9,2.5 -- 12,2.5
  - 1,9 -- 2,9
  - 1,11 -- 2,11
  - 4,9 -- 4,10
  - 4,10 -- 4,11
  - 8,10 |- Q3.B
  - Q3.E -- 10,11
  - 10,9 -- Q3.C
  - 10,9 -- 12,9
notes:
  - text 4.3,9.5 blue left: P
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/15-rtl-dtl.svg)

- **RTL の NOR**: A と B がそれぞれ Rb1・Rb2 (10 kΩ) を通して Q1・Q2 のベースに入る。コレクタは共通で、Rc1 (1 kΩ) で 5 V へ。
  どちらかの入力が H (5 V) なら、そのトランジスタがオンして出力を 0.1 V ほどに引き下げる。両方 L のときだけ出力は H。
  オンのときのベース電流は (5 V − 0.7 V) ÷ 10 kΩ = 0.43 mA、コレクタ電流は 5 V ÷ 1 kΩ = 5 mA。
  hFE が 12 あれば飽和するので、2SC1815 (hFE 70 以上) なら十分
- **DTL の NAND**: 入力はダイオード D1・D2 のカソード。アノードをまとめた節点 P を R1 (4.7 kΩ) で 5 V へ引き上げる。
  どちらかの入力が L なら、R1 の電流はそのダイオードを通って入力へ流れ出し、P は 0.55 V ほど。
  P から Q3 のベースまでには D3・D4 と Q3 のベース・エミッタの 3 段の順方向電圧があるので、Q3 はオフ、出力は H
- 両方の入力が H なら D1・D2 は逆向きで切れ、R1 の電流は D3・D4 を通って Q3 のベースへ入る。P は約 1.8 V、ベース電流は約 0.6 mA で Q3 は飽和し、出力は L。
  Rbd (10 kΩ) は、Q3 を切るときにベースの電荷を抜く抵抗
- DTL の入力は L のとき電流を**流し出す** (A・B とも L なら 1 本あたり 0.47 mA)。L を出す側の IC は、この電流を吸い込めなければならない。
  TTL の「入力 L の電流 I<sub>IL</sub>」と同じ考え方
- 図1 の A・B は同じ名前の端子どうしがつながっている (1 組の入力を両方のゲートに入れる)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (上が RTL の NOR、下が DTL の NAND)
board: half
parts:
  AD:
    type: device
    at: bottom
    label: AD3 Wavegen・Scope・Supplies
    pins: [1+, W1, W2, 2+, 1-, 2-, GND, V+]
  Q1: transistor c4 c5 c6 2SC1815
  Q2: transistor c18 c17 c16 2SC1815
  Rb1: resistor d10 d6 10k
  Rb2: resistor d12 d16 10k
  Rc1: resistor e17 e21 1k cap=above
  D1: diode i14 i10
  D2: diode g14 g12
  R1: resistor j14 +b14 4.7k
  D3: diode h14 h17
  D4: diode g17 g20
  Rbd: resistor j20 -b20 10k
  Q3: transistor i22 i21 i20 2SC1815 cap=right
  Rc2: resistor g21 g25 1k
wires:
  - AD.V+ -- +b29 red
  - AD.GND -- -b28 black
  - +b30 -- +t30 red
  - -b30 -- -t30 black
  - a4 -- -t4 black
  - a18 -- -t18 black
  - a5 -- a17 orange
  - a21 -- +t21 red
  - e10 -- f10 yellow
  - e12 -- f12 green
  - e5 -- f5 white
  - j22 -- -b22 black
  - j25 -- +b25 red
  - AD.W1 -- j10 yellow
  - AD.W2 -- j12 green
  - AD.2+ -- j21 blue
  - AD.1+ -- j5 white
  - AD.1- -- -b26 black
  - AD.2- -- -b27 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/15-rtl-dtl.svg)

- 電源は AD3 の Supplies の V+ (5 V) を下のレールへ入れ、右端の 30 列で上のレールとつなぐ
- 入力 A は 10 列、B は 12 列。下のブロックで AD3 の W1・W2 を受け、溝をまたぐ黄と緑の線で上のブロックへも渡す
- 上 (RTL): Q1 は 4〜6 列 (E・C・B、平らな面が手前)、Q2 は 16〜18 列で、平らな面を奥にして挿す (B・C・E の順になる)。
  Rb1 は 10 列から 6 列 (Q1 の B)、Rb2 は 12 列から 16 列 (Q2 の B)。2 本のエミッタ (4・18 列) を上の青レールへ。
  オレンジの線で 2 本のコレクタ (5・17 列) をつなぎ、Rc1 (17〜21 列) と赤の線で +5 V へ。NOR の出力は 5 列で、白い線で溝をまたいで下へ出す
- 下 (DTL): P は 14 列。D1 は 14 列から 10 列 (A)、D2 は 14 列から 12 列 (B) で、帯 (カソード) が入力の側。R1 (4.7 kΩ) は 14 列から下の赤レールへ。
  D3 (14→17 列) と D4 (17→20 列) を通して 20 列が Q3 のベース。Rbd が 20 列から下の青レールへ。
  Q3 は 20〜22 列 (平らな面を奥にして B・C・E)。E (22 列) を青レールへ、C (21 列) が NAND の出力で、Rc2 (21〜25 列) と赤の線で +5 V へ
- AD3 の 1+ を NOR (5 列)、2+ を NAND (21 列) に挿す。Logic (図4) で見るときは DIO0〜DIO3 を A (10 列)・B (12 列)・NOR (5 列)・NAND (21 列) に挿す (図2 では省いた)
- 電流は Rc1・Rc2 が最大 5 mA ずつ、R1 が 1 mA 弱、ベースが 1 mA 弱で、合わせて 12 mA ほど。ブレッドボードの範囲にも AD3 の Supplies にも収まる。
  W1・W2 が出す電流は 1 本 1 mA 足らず (Rb の 0.43 mA と DTL の入力の 0.47 mA) で、Wavegen の出せる電流 (約 10 mA) に収まる

## 計器の設定

計器は AD3 の Supplies・Wavegen (入力 A・B)・Scope・Logic。W1 と W2 を 2 倍違う周波数の方形波にすると、
2 ms ごとに (A, B) の 4 通りが 1 回ずつ現れ、真理値表が 1 画面に並ぶ。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V |
| W1 (A) | Square、1 kHz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V) |
| W2 (B) | Square、500 Hz、0〜5 V。W1 と同期 (Wavegen の Synchronized) |
| CH1 (1+) | NOR。2 V/div、0 V を中央から 0.5 目盛上 |
| CH2 (2+) | NAND。2 V/div、0 V を中央から 3.5 目盛下 (2 本を上下に分ける) |
| 時間 | 500 µs/div。トリガは CH2 (NAND) の立ち下がり 2.5 V (A と B が同時に立ち上がる所)、トリガの点を左から 1 目盛 |
| カーソル | X1 = 0.25 ms (A = B = 1)、X2 = 1.75 ms (A = B = 0) |
| Logic | DIO0〜3 を A・B・NOR・NAND。標本化 1 MHz、250 µs/div |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 NOR (CH1、上) と NAND (CH2、下) (計算)
time: 500us/div
trigger: ch2 falling 2.5V at -4div
ch1: {wave: pulse 500Hz 2.45V offset 2.55V duty 25% | delay 1.5ms, range: 2V/div, position: 0.5div}
ch2: {wave: pulse 500Hz 2.455V offset 2.545V duty 75% | delay 500us, range: 2V/div, position: -3.5div}
cursors: [250us, 1.75ms]
measure: [vmax, vmin, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/15-rtl-dtl.svg)

- 図3 は計算で作った理想の波形 (L の 0.1 V は LTspice の値)。トリガの点 (0 ms) で A と B が同時に立ち上がる。
  0〜0.5 ms は A = B = 1、0.5〜1 ms は A = 0・B = 1、1〜1.5 ms は A = 1・B = 0、1.5〜2 ms は A = B = 0
- CH1 (NOR、上) は 1.5〜2 ms の間だけ 5 V で、デューティ 25 %。CH2 (NAND、下) は 0〜0.5 ms の間だけ 0.1 V で、デューティ 75 %
- 図3 の時間軸 (1 目盛 0.5 ms) では見えないが、RTL と DTL の出力の立ち上がりは Rc (1 kΩ) と配線・プローブの容量で決まり、
  立ち下がり (トランジスタが引く) より遅い。74HC と比べて遅いのは、この抵抗で引き上げる形のため

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 A・B の 4 通りと NOR・NAND (計算)
device: ad3
time: 250us/div
sample: 1MHz
signals:
  A:    dio0 clock 1kHz
  B:    dio1 clock 500Hz
  NOR:  dio2 edges 0s=0 1.5ms=1 2ms=0
  NAND: dio3 edges 0s=0 500us=1 2ms=0
cursors: [250us, 1.75ms]
trigger: B rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/logic/15-rtl-dtl.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1・Q2・Q3 | NPN トランジスタ | 2SC1815 (TO-92) × 3 |
| D1〜D4 | 小信号ダイオード | 1N4148 × 4 |
| Rb1・Rb2・Rbd | 抵抗 (1/4 W) | 10 kΩ × 3 本 |
| Rc1・Rc2 | 抵抗 (1/4 W)、コレクタの負荷 | 1 kΩ × 2 本 |
| R1 | 抵抗 (1/4 W)、DTL の引き上げ | 4.7 kΩ |
| — | 電源・信号源・計器 | Analog Discovery 3 |

Rc1・Rc2 の電力は出力が L のとき 5 V × 5 mA = 25 mW で、1/4 W の半分より小さい。

## 見るべき値

| A | B | NOR (RTL) | NAND (DTL) |
| --- | --- | --- | --- |
| 0 | 0 | H (5.0 V) | H (5.0 V) |
| 0 | 1 | L (0.10 V) | H (5.0 V) |
| 1 | 0 | L (0.10 V) | H (5.0 V) |
| 1 | 1 | L (0.07 V) | L (0.09 V) |

| 項目 | RTL の NOR (B = 0) | DTL の NAND (B = 1) |
| --- | --- | --- |
| 出力が 2.5 V を切る入力 (しきい値) | 0.76 V | 1.03 V |
| 入力 L のノイズマージン (しきい値 − 出力の L 0.1 V) | 約 0.66 V | 約 0.94 V |
| 入力 L のときに入力が流し出す電流 | 0 (入力は抵抗でベースへ) | 約 0.9 mA (片方だけ L のとき) |

- しきい値は LTspice の値 (下の節)。W1 を三角波 (100 Hz、0〜2 V) にし、W2 を NOR なら 0 V、NAND なら 5 V の直流にすると、
  Scope の XY (横 W1、縦 CH1 か CH2) で伝達特性 (下の表の数) が測れる
- RTL のしきい値は 1 段のベース・エミッタの順方向電圧 (0.6〜0.7 V) で決まり、L の出力 (0.1 V) との差が小さい。
  雑音で誤動作しやすいのが RTL の弱点。DTL は P からベースまでのダイオードの段の分だけしきい値が上がる。
  D3・D4 の 2 本は、その段を足すために入れてある
- 74HC (10-9) のしきい値は 5 V で 1.7〜2.8 V あたり。今の CMOS は、電源の真ん中付近でしきい値を取って、両側のマージンを広く取る

## LTspice での確かめ

`sim/15-rtl-dtl.cir` で入力の 4 通りを .op で、`sim/15-rtl-dtl-sweep.cir` で A を 0〜5 V に掃いた伝達特性を解いた。
2SC1815 と 1N4148 は他の題と同じ近似モデル (仮定)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| NOR の出力 (A, B) = (0,0) / (0,1) / (1,0) / (1,1) | H / L / L / L | 5.00 / 0.099 / 0.099 / 0.069 V | 合う |
| NAND の出力 (同じ順) | H / H / H / L | 5.00 / 5.00 / 5.00 / 0.092 V | 合う |
| RTL のベース電流 (入力 H) | 0.43 mA | 0.430 mA | 合う |
| DTL の P (両方 H) とベース電流 | 約 1.8 V・約 0.6 mA | 1.84 V・0.601 mA | 合う |
| DTL の P (入力 L) | 約 0.55 V | 0.551 V | 合う |
| DTL の入力 1 本が流し出す電流 (両方 L) | 0.47 mA | 0.473 mA | 合う |
| NOR のしきい値 (出力 2.5 V) | 0.76 V | 0.763 V | 合う |
| NAND のしきい値 (出力 2.5 V) | 1.03 V | 1.034 V | 合う |

手で積んだ見積り (ダイオードとベース・エミッタ 0.65 V ずつで DTL のしきい値 1.3 V) は、電流の小さい所の順方向電圧が 0.5 V 台に下がる分だけ、
LTspice より高い。しきい値の近くは電流が小さいので、0.65 V で数えると外れる。

## 出典

自作。

参考: [Resistor–transistor logic (英語版 Wikipedia)](https://en.wikipedia.org/wiki/Resistor%E2%80%93transistor_logic)、[Diode–transistor logic (英語版 Wikipedia)](https://en.wikipedia.org/wiki/Diode%E2%80%93transistor_logic)、[1N4148 データシート](https://www.vishay.com/docs/81857/1n4148.pdf)
