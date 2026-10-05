---
book: circuits
chapter: 5
id: 5-3
title: 3 端子レギュレータ (7805)
tier: 50
source: 自作
board: [BB, PF]
---

# 5-3 3 端子レギュレータ (7805)

9 V の電池から、7805 という IC 1 個で 5 V を作る。5-2 のツェナー + Tr のレギュレータを、
誤差を直す仕組みまで含めて 1 個の IC にまとめたのが 3 端子レギュレータで、入力 (IN)・GND・出力 (OUT) のピン 3 本をつなぐだけで使える。
入力が多少ふらついても出力は 5 V に保たれるので、5 V で動く回路の電源の定番になっている。
この題では電源を Analog Discovery 3 (AD3) の Supplies からとり、**電源電圧を 7 V から 10 V まで変えても出力が 5 V のまま**であることを、
オシロ (Scope) で確かめる。

## 回路図

```circuit
title: 図1 7805 で 5V を作る (V1 は AD3 の電源、7 から 10 V)
parts:
  V1: vsource vin gnd 10
  G1: ground gnd
  U1: regulator b5 7805
  Cin: capacitor b3 d3 0.33u
  Cout: capacitor b7 d7 0.1u
  RL: resistor b9 d9 1k
  Rled: resistor b11 c11 680
  Dled: led c11 d11 red
  M1: voltmeter b13 d13 l=$\mathrm{CH1}$
points:
  vin: b1
  gnd: d1
wires:
  - vin -- b3 -- U1.in
  - U1.out -- b7 -- b9 -- b11 -- b13
  - U1.gnd -- d5
  - gnd -- d3 -- d5 -- d7 -- d9 -- d11 -- d13
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/03-three-terminal-regulator.svg)

- Cin (0.33 µF) は入力側、Cout (0.1 µF) は出力側のコンデンサ。どちらも発振を防ぎ、
  負荷の急な変化への応答を良くするためにデータシートが指定する定石の値
- RL (1 kΩ) が主な負荷で、Rled (680 Ω)・Dled は電源が来ているかを示す表示の LED。
  負荷を軽くしてあるのは、AD3 の Supplies の上限 (各レール 50 mA、USB 給電では全体で 250 mW) に収めるため。
  合計の電流は 5 + 4.4 + 7805 自身の数 mA で約 14 mA、入力 10 V のとき約 140 mW
- 入力 V1 は、AD3 の Supplies の V+ と V− の間の電圧。**7805 の GND ピンを V− につなぐ**と、入力は V+ − V− になり、
  出力は GND ピン (V−) から見て 5 V になる。V+ と V− を同じ大きさ (±3.5 V 〜 ±5 V) にそろえて、入力を 7 V 〜 10 V に動かす
- 入力が 7 V を超えていれば出力は 5 V のまま。7805 のドロップアウト (5-2 で見た、出力を保つのに要る入出力の差) は約 2 V

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (AD3 の Supplies から電源を取る)
board: half
parts:
  U1: regulator/to220 e8(in) e9(gnd) e10(out) 7805
  Cin: capacitor f5 f8 0.33uF
  Cout: capacitor f10 f13 0.1uF
  RL: resistor f14 f18 1k
  Rled: resistor h14 h20 680
  Dled: led f20(A) f23(K) red
  AD:
    type: device
    at: bottom
    label: Analog Discovery (Supplies と Scope)
    pins: [V+, V-, 1+, 2+, 1-, 2-]
wires:
  - AD.V+ -- +b2 red
  - AD.V- -- -b3 black
  - +b8 -- j8 red
  - e8 -- f8 red
  - e9 -- f9 black
  - j9 -- -b9 black
  - j5 -- -b5 black
  - j13 -- -b13 black
  - e10 -- f10 orange
  - i10 -- i14 orange
  - j18 -- -b18 black
  - j23 -- -b23 black
  - AD.1+ -- j10 orange
  - AD.2+ -- +b12 yellow
  - AD.1- -- -b24 black
  - AD.2- -- -b25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/03-three-terminal-regulator.svg)

- 7805 (TO-220) は、型番の印字面を手前に、ピンを下にして持つと、左から IN・GND・OUT。上に放熱板 (穴の開いた金属) が来る。
  図の 7805 もこの向きで描いてあり、型番が胴に刻んである
- U1 のピン (IN・GND・OUT = 8・9・10 列) は、上のブロックの e 行から線で下のブロックへ渡す
- Supplies の V+ (赤) は下の + レールへ、V− (黒) は下の − レールへ。下の + レールから IN の 8 列へ (`j8`)、
  GND のピン (9 列) は必ず − レールへ (`j9`)。ここが浮くと出力は 5 V にならない
- Cin (5・8 列) は IN・GND の間、Cout (10・13 列) は OUT・GND の間に入れる。リード線は
  短くし、レギュレータのすぐ近くに挿す
- 出力は下のブロックの 10 列から 14 列へ渡し (`i10`〜`i14`)、RL と Rled に配る。RL・Rled・Dled の GND 側は − レールへ
- Scope は、1+ (橙) を OUT の 10 列 (`j10`)、2+ (黄) を下の + レール (IN) へ、1− と 2− (黒) を下の − レールへ。
  1− と 2− は V− につなぐ (GND ピンと同じ電位)。V− は −3.5 〜 −5 V になるが、Scope の入力範囲 (±25 V) に収まる

## ユニバーサル基板の実体配線図

```perf
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  slots: on
unused: [J2.D+, J2.D-]
title: 図3 ユニバーサル基板に組む (部品面から見た図。黄色の丸は AD3 を挟む所)
parts:
  J1: sip2 b15
  J2: usb-c/female t5 u5 v5 w5
  U1: regulator/to220 f9 g9 h9 7805
  Cin: capacitor/ceramic e9 e6 0.33u
  Cout: capacitor/ceramic k9 k6 0.1u
  RL: resistor m9 m5 1k
  Rled: resistor p9 p6 680
  Dled: led p5 p3 red
wires:
  - b15 -- b17 red
  - b17 -- e17 red
  - e17 -- e9 red
  - f9 -- e9 red
  - c15 -- c3 black
  - c3 -- e3 black
  - e3 -- g3 black
  - g3 -- k3 black
  - k3 -- m3 black
  - m3 -- p3 black
  - p3 -- s3 black
  - s3 -- s5 black
  - s5 -- t5 black
  - e6 -- e3 black
  - g9 -- g3 black
  - k6 -- k3 black
  - m5 -- m3 black
  - h9 -- k9 orange
  - k9 -- m9 orange
  - m9 -- p9 orange
  - p9 -- w9 orange
  - w9 -- w5 orange
  - p6 -- p5 orange
notes:
  - mark b15 yellow
  - mark c15 yellow
  - mark n9 yellow
  - mark e13 yellow
  - mark j3 yellow
  - text b15 red large bold left: V+
  - text c15 red large bold right: V-
  - text n10 red large bold center: AD3 1+
  - text e13 red large bold right: AD3 2+
  - text j4 red large bold center: AD3 1-/2-
  - text w3 red large bold: OUT 5V
  - parts
style:
  back: on
  labels:
    sides: left bottom
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/perfboard/03-three-terminal-regulator.svg)

- 電源を使い続けるなら、ブレッドボードの配線は接触が不安定なので、ユニバーサル基板に半田付けして残す。
  電圧は 7〜10 V (12 V 以下)、電流は約 14 mA (500 mA 以下)、周波数は直流なので、ユニバーサル基板の範囲に収まる
- ユニバーサル基板は 5×7 cm のパッド付き基板を横に使う (24 列 × 18 行、1.6 mm の FR-4)。番地は基板の刷りどおりで、
  英字が列 (左から A〜X)、数字が行 (下から 1〜18)。上の図は部品面から見た図で、下の図は半田面 (列が左右逆)
- J1 (2 ピンのピンヘッダ、B15・C15) は、AD3 の Supplies をクリップで挟む所。B15 が V+、C15 が V−。
  V+ は 17 行の筋 (赤) を通って E 列を下り、E9 (IN) へ。V− は C 列を下りて 3 行の GND の筋 (黒) へ
- 7805 (TO-220、F9・G9・H9 = IN・GND・OUT) は、放熱板を上にして立てる。GND (G9) は G 列を下って GND の筋へ、
  OUT (H9) は 9 行を右へ (橙) 運び、Cout (K9・K6)・RL (M9・M5)・Rled (P9・P6) と、出力の USB-C (W9 から W5) に配る。
  Rled の先は Dled (P5・P3)
- **出力は USB-C のメス (J2、右下端の T5〜W5)**。USB-C の電源取り出しモジュールで、受け口は下の縁を向き、基板の中に収まる。
  VBUS (W5) に OUT の 5 V、GND (T5) に GND の筋 (S5 を経て 3 行) をつなぐ。D+ と D− は使わない (`unused:` に並べた)
- J2 は USB の規格の出力ではない。電源を渡すだけの取り出し口で、CC に電源側の抵抗 (Rp) が無いので、スマートフォンなどの
  USB-C 機器は電源とは認識しない。USB 機器・パソコン・充電器を J2 につながない (相手の 5 V とぶつかって壊れることがある)。
  5 V の実験回路へ、ケーブルで電源を渡す取り出し口として使う。実物の基板にも `OUT 5V` と書いておく
- Cin (E9・E6)・Cout (K9・K6)・RL (M5)・Dled のカソード (P3) の GND 側は、すべて 3 行の GND の筋につなぐ
- 黄色の丸は、**測るときだけ AD3 を挟む所**で、常には配線しない。AD3 の V+ と V− は J1 (B15・C15)、
  Scope の 1+ は OUT (N9)、2+ は IN の線 (E13)、1− と 2− は GND の筋 (J3) に、赤の大きな太字の名前の所で挟む
- 線は縦と横だけで、交差は無い

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 3 端子レギュレータ (TO-220) | 7805 |
| Cin | セラミックコンデンサ (入力側) | 0.33 µF |
| Cout | セラミックコンデンサ (出力側) | 0.1 µF |
| RL | 抵抗 (主負荷) | 1 kΩ |
| Rled | 抵抗 (表示 LED 電流制限) | 680 Ω |
| Dled | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| J1 | ピンヘッダ (2 ピン。ユニバーサル基板の図だけ。Supplies をクリップで挟む) | — |
| J2 | USB-C 電源取り出しモジュール (ユニバーサル基板の図だけ。出力の 5 V の取り出し口) | メス、右下端。USB 機器をつながない |
| — | 基板 (図3) | ユニバーサル基板 5×7 cm、パッド付き (横使い、1.6 mm・FR-4) |
| — | 計器・電源 | Analog Discovery 3 の Supplies (V+ と V−) と Scope (1+ = OUT、2+ = IN、1− と 2− = V−) |

電源は AD3 の Supplies を使う (5 V 単独では 7805 の入力に足りないので、V+ と V− の 2 つで 7〜10 V を作る)。
7805 は入出力差 (ドロップアウト) が約 2 V 要るので、出力 5 V に対して入力は 7 V 以上が要る。

## 計器の設定

計器は Analog Discovery 3 の Supplies と Scope。Supplies で入力電圧を変え、Scope で入力 (CH2) と出力 (CH1) を同じ画面に並べて見る。

1. Supplies の V+ を 3.5 V、V− を −3.5 V にして Master を On にする (入力は差の 7 V)
2. Scope は DC カップリング、時間軸を 10 s/div、Mode を Screen にする (画面が流れる)。
   CH1 は 500 mV/div・オフセット 5 V (出力の 5 V が画面の中央)、CH2 は 500 mV/div・オフセット 8.5 V (入力の 7〜10 V が収まる)
3. 25 秒ごとに V+ を 0.5 V ずつ、V− も同じだけ上げる (±3.5 V → ±4 V → ±4.5 V → ±5 V)。入力は 7 V → 8 V → 9 V → 10 V と階段になる

```scope
title: 図4 電源電圧 (CH2) を 7 V から 10 V へ上げても、出力 (CH1) は 5 V のまま
time: 10s/div
trigger: ch2 rising 7.5V at -4div
ch1: {wave: dc 5V, range: 500mV/div, position: -10div}
ch2: {wave: "= 7V + 1V * step(t) + 1V * step(t - 25s) + 1V * step(t - 50s)", range: 500mV/div, position: -17div}
cursors: [12s, 62s]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/03-three-terminal-regulator.svg)

- 図の画面は、7805 が理想どおりに働いたときの形 (実測の CSV を `data:` に重ねると、実線で出る)
- CH2 (入力) は 1 V ずつの階段で、CH1 (出力) は 500 mV/div に拡大しても平らな線のまま。
  カーソル X1 (8 V のとき) と X2 (10 V のとき) で読んだ出力が、ほぼ同じ値になる

## 見るべき値

表の値は計算値。実測では、電圧は Scope の読み値 (Measurements) とカーソルで読む。電流は、測った電圧を抵抗の値で割って求める。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力 (CH1) | 5.00 V (±4 %、4.8〜5.2 V)。入力を変えても動かない | 入力が 7 V 以上ならほぼ一定。7805 のデータシートの代表値で、入力が 2 V 変わっても出力は数 mV しか動かない (ラインレギュレーション) |
| 入力 (CH2) | 7 V → 8 V → 9 V → 10 V | Supplies で決めた V+ と V− の差 |
| カーソルの差 (X1 と X2 の CH1) | 数 mV 以下 | 入力を 2 V 変えても出力はほぼ変わらない |
| RL の電流 | 5 mA | 5 V ÷ 1 kΩ |
| Dled の電流 | 約 4.4 mA | (5 V − 2.0 V) ÷ 680 Ω |
| U1 の損失 (入力 10 V) | 約 70 mW | (10 V − 5 V) × 合計電流 (約 14 mA)。放熱板なしでも常温なら問題ない |
| 入力を 6 V まで下げた場合 (±3 V) | 出力が 5 V を割り始める | 入出力の差がドロップアウト電圧 (約 2 V) を下回ると、出力を保てなくなる |

負荷電流を増やす (RL を小さくする) と U1 の発熱が増える。1 A に近づくなら
放熱板が要る (データシートの熱抵抗から計算する、7-12 で扱う)。AD3 の Supplies は各レール 50 mA までなので、
この題の負荷より重くしないこと。

## 出典

自作。
