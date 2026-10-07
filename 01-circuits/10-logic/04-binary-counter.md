---
book: circuits
chapter: 10
id: 10-4
title: バイナリカウンタ (4 bit、4040)
tier: 50
source: 自作
board: BB
---

# 10-4 バイナリカウンタ (4 bit、4040)

パルスの数を 2 進数で数えるカウンタを LED で見る。時計・タイマー・マイコンの中で、
数を数える仕事はこの回路が受け持つ。

3-2 の 555 非安定で作ったゆっくりした方形波を、CD4040 (12 段のバイナリカウンタ) の
クロック (数える合図になるパルス) に入れる。下 4 ビット (Q1〜Q4) を LED で見て、
0000 から 1111 まで 2 進数で数えるのを確かめる。Q1 がいちばん下の桁 (LSB)、
Q4 がいちばん上の桁 (MSB)。

## この実験で確かめる式

555 非安定のクロック周期は T = 0.69 × (R1 + 2·R2) × C1 (3-2 と同じ式)。
4040 はクロックの立ち下がり (H から L に変わる瞬間) で 1 つ数える。
中は 10-5 で見る T フリップフロップを 12 段つないだ形で、1 段目の出力が次の段の
クロックになる (リプルカウンタ。数が波のように段から段へ伝わるのでこう呼ぶ)。

## 回路図

```circuit
title: 図1 555クロック + 4040バイナリカウンタ
parts:
  U555: ic 6,5 NE555
  VCC: vcc 3,2 5V
  R1: resistor 3,2 3,4.5 10k
  R2: resistor 3,4.5 3,6 47k
  C1: capacitor 4,6 4,8 10u
  GC1: ground 4,8
  GU555: ground 6,8
  U40: ic 15,5 CD4040B
  VCC: vcc 15,1 5V
  GU40: ground 15,10
  VCC: vcc 10,7 5V
  SWRST: button 10,7 12,7 l=$\mathrm{SW_{RST}}$
  RRST: resistor 12,7 12,9 10k l=$R_\mathrm{RST}$
  GRRST: ground 12,9
  RQ1: resistor 27,5 27,6 1k l=$R_\mathrm{Q1}$
  DQ1: led 27,6 27,7 red l=$D_\mathrm{Q1}$
  GQ1: ground 27,7
  RQ2: resistor 24,5 24,6 1k l=$R_\mathrm{Q2}$
  DQ2: led 24,6 24,7 red l=$D_\mathrm{Q2}$
  GQ2: ground 24,7
  RQ3: resistor 21,5 21,6 1k l=$R_\mathrm{Q3}$
  DQ3: led 21,6 21,7 red l=$D_\mathrm{Q3}$
  GQ3: ground 21,7
  RQ4: resistor 18,5 18,6 1k l=$R_\mathrm{Q4}$
  DQ4: led 18,6 18,7 red l=$D_\mathrm{Q4}$
  GQ4: ground 18,7
wires:
  # 555 非安定
  - U555.VCC |- 6,2
  - U555.RESET |- 6.5,2
  - 3,2 -- 6,2 -- 6.5,2
  - U555.DISCH -| 3,4.5
  - U555.THRES -| 4,5
  - U555.TRIG -| 4,5.5
  - 4,5 -- 4,6
  - 3,6 -- 4,6
  - U555.GND |- 6,8
  # クロック: 555 の OUT を 4040 の CLOCK へ
  - U555.OUT -| 10,5
  - U40.CLOCK -| 10,5
  # リセット: SWRST で +5V、離すと RRST で GND
  - U40.R -| 12,7
  # 4040 の電源
  - 15,1 |- U40.VDD
  - U40.VSS |- 15,10
  # 出力: Q1 を一番外側にして、線が交わらないように右へ
  - U40.Q1 -| 27,5
  - U40.Q2 -| 24,5
  - U40.Q3 -| 21,5
  - U40.Q4 -| 18,5
notes:
  - text 27,9 blue center: Q1 (LSB)
  - text 24,9 blue center: Q2
  - text 21,9 blue center: Q3
  - text 18,9 blue center: Q4 (MSB)
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/04-binary-counter.svg)

- 555 は標準の非安定 (R1 10kΩ、R2 47kΩ、C1 10µF)。
  T ≈ 0.69 × (10kΩ + 2 × 47kΩ) × 10µF ≈ 0.72 秒、f = 1/T ≈ 1.4Hz (計算値)
- 555 の出力 (PIN 3) が 4040 のクロック (PIN 10)。立ち下がりで 1 つ進む
- SWRST を押すと PIN 11 (RESET) が +5V (H) になり、カウンタが 0000 に戻る。
  離すと RRST (10kΩ) が PIN 11 を GND (L) に落とす
- Q1 (PIN 9)・Q2 (PIN 7)・Q3 (PIN 6)・Q4 (PIN 5) が下 4 ビット。5 ビット目から上は
  この題では使わない
- CD4040 の入力は CLK (PIN 10) と RESET (PIN 11) の 2 本だけで、どちらもつないで
  ある (RESET は RRST で GND へ)。CMOS の入力は浮かせてはいけないが、この IC に
  使わない入力は無い。使わない Q5〜Q12 は出力なので開けておく
- 電源の PIN: 4040 は VDD が PIN 16・VSS が PIN 8、555 は VCC が PIN 8・GND が PIN 1
- 図1 の 4040 (U40) と 555 (U555) は、ピンを働きで並べた箱で描いた。
  上が電源 (VDD・VCC)、左が入力 (CLOCK・R)、右が出力 (Q1〜Q4)、下が GND (VSS・GND)。
  PIN の番号は箱の中に添えてある。使わない Q5〜Q12 は線を引かず開けておく。
  LED は Q1 を一番右、Q4 を一番左に並べ、出力の線が交わらないようにした
- LED の直列抵抗 RQ1〜RQ4 は 1kΩ。10-1 と同じく、5V の CD4000 系の出力は数 mA しか
  流し出せないので (CD4040B も CD4000B 系の標準の出力で、I<sub>OH</sub> は出力 2.5V のとき
  最小 1.6mA)、LED の電流を 1.5〜2.2mA (10-1 で求めた目安) に抑える。
  暗いときは高輝度 LED にするか、ピンの並びが同じ 74HC4040 に替える

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  U555: dip8 @ e5 NE555
  R1: resistor b6 b3 10k
  R2: resistor c6 c9 47k
  C1: capacitor/electrolytic i9 i12 10u
  RRST: resistor c17 c14 10k
  SWRST: button @ e17
  U40: dip16 @ e22 CD4040
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: top
    label: AD3 Scope
    pins: [1+, 1-, 2+, 2-]
  RQ1: resistor a32 a34 1k
  DQ1: led c34(A) c36(K) red
  RQ2: resistor a38 a40 1k
  DQ2: led c40(A) c42(K) red
  RQ3: resistor a44 a46 1k
  DQ3: led c46(A) c48(K) red
  RQ4: resistor a50 a52 1k
  DQ4: led c52(A) c54(K) red
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t62 -- +b62 red
  - a5 -- +t5 red
  - a3 -- +t3 red
  - j5 -- -b5 black
  - j8 -- +b8 red
  - b7 -- b9 orange
  - d9 -- f9 orange
  - g9 -- g6 orange
  - j12 -- -b12 black
  - h7 -- h21 blue
  - g21 -- e21 blue
  - d21 -- d28 blue
  - c27 -- c19 green
  - a14 -- -t14 black
  - j17 -- +b17 red
  - a22 -- +t22 red
  - j29 -- -b29 black
  - d29 -- d32 yellow
  - g28 -- g38 yellow
  - f38 -- e38 yellow
  - h27 -- h44 yellow
  - f44 -- e44 yellow
  - i26 -- i50 yellow
  - f50 -- e50 yellow
  - a36 -- -t36 black
  - a42 -- -t42 black
  - a48 -- -t48 black
  - a54 -- -t54 black
  - SC.1+ -- a21 yellow
  - SC.1- -- -t19 black
  - SC.2+ -- b29 blue
  - SC.2- -- -t31 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/04-binary-counter.svg)

- 電源は Analog Discovery 3 (AD3、0-3 で使った USB 計測器) の Supplies で、V+ を 5V にする。
  左上の AD3 の V+ を上の赤レール (1 列)、GND を上の青レール (2 列) へ。
  下のレールは青を 1 列、赤を 62 列 (右端) で上のレールとつなぐ
- U555 (NE555) は 5〜8 列、U40 (CD4040) は 22〜29 列。どちらも切り欠きが左で、PIN 1 が左下 (f 行)。U555 は PIN 8 (5 列の上) が左上、U40 は PIN 16 (22 列の上) が左上
- U555: PIN 8 (5 列の上) と PIN 4 (RESET、8 列の下) を +5V へ、PIN 1 (5 列の下) を GND へ。
  R1 は PIN 7 (6 列の上) から 3 列の +5V へ、R2 は PIN 7 から 9 列へ。9 列は b 行で
  PIN 6 (7 列の上) とつなぎ、溝をまたぐオレンジの線で PIN 2 (6 列の下) へも渡す。
  C1 (+ が 9 列の下) を通して GND へ。PIN 5 (CONT) は使わない
- U40: PIN 16 (22 列の上) を +5V、PIN 8 (29 列の下) を GND へ。PIN 10 (CLK、28 列の上)
  には 555 の PIN 3 (7 列の下) から青の線 (h 行 → 21 列で溝をまたぐ → d 行)。
  PIN 11 (RESET、27 列の上) は c 行の緑の線で 19 列へ渡し、RRST (10kΩ) で GND へ、
  SWRST (e17) を押すと +5V へ
- Q1 (PIN 9、29 列の上)・Q2 (PIN 7、28 列の下)・Q3 (PIN 6、27 列の下)・Q4 (PIN 5、
  26 列の下) を黄の線で 32・38・44・50 列へ渡し (下の 3 本は g・h・i 行を通って
  溝をまたぐ)、1kΩ と LED を通して GND へ
- AD3 のオシロは、1+ (黄) をクロックの列 21 (`a21`、555 の PIN 3 から U40 の PIN 10 へ渡る青の線の途中) に、
  2+ (青) を Q1 の列 29 (`b29`) に挿す。1− と 2− (黒) は上の青レール (GND) へ
- ブレッドボードを流れる電流は、LED 4 個が全部点いても約 2.2mA × 4 ≈ 9mA に、NE555 自身の約 3mA (データシートの典型値) と
  R1 の数百 µA を足して 13mA ほど。ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) にも、AD3 の V+ を USB 給電で使うときの
  目安 (5V で 50mA) にも収まる

## 計器の設定

計器は AD3 の Supplies (電源) とオシロ (Scope)。クロックと Q1 を同じ時間軸で並べ、
**Q1 がクロックの立ち下がりで切り替わり、周期がクロックの 2 倍になる** (2 分周) ことを見る。
クロックは約 1.4Hz とゆっくりなので、WaveForms の Scope を Scan (流し表示) にするか、
時間レンジを 500ms/div にして 1 画面に 7 周期ほどを入れる。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5V、V− は使わない |
| CH1 (1+) | クロック (555 の PIN 3 = 4040 の PIN 10)。1V/div、0V を下から 1 目盛 |
| CH2 (2+) | Q1 (4040 の PIN 9)。CH1 と同じ 1V/div・同じ 0V の位置 |
| 1−・2− | GND |
| 時間レンジ | 500ms/div |
| トリガ | CH1 の立ち上がり、1.8V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Duty |
| カーソル | X1・X2 をクロックの続く 2 つの立ち下がりの直後に置く。ΔX がクロックの 1 周期 = Q1 の半周期 |

```scope
title: 図3 クロック (CH1) と Q1 (CH2) — Q1 は立ち下がりで切り替わり、周波数は半分
time: 500ms/div
trigger: ch1 rising 1.8V at -4div
ch1: {wave: square 1.394Hz 1.7V offset 1.8V duty 54.8%, range: 1V/div, position: -3div}
ch2: {wave: square 0.697Hz 2V offset 2V | delay 393ms, range: 1V/div, position: -3div}
cursors: [400ms, 1.117s]
measure: [freq, duty, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/04-binary-counter.svg)

- 図3 の CH1 (クロック) は約 0.1V と約 3.5V を行き来する。High が約 0.39 秒、Low が約 0.32 秒
  (3-2 の式で tH = 0.69 × (R1 + R2) × C1、tL = 0.69 × R2 × C1。計算値)
- CH2 (Q1) はクロックが立ち下がるたびに (カーソル X1・X2 の位置) 0 と 1 が入れ替わる。
  Q1 の周波数はクロックの半分の約 0.70Hz で、デューティ比は 50%。Q1 の High は LED に 2mA ほど流しながら約 4V
  (10-1 の目安。標準の品)
- 2+ を Q2・Q3・Q4 に挿し替えると、周波数はさらに半分ずつ (約 0.35Hz・0.17Hz・0.087Hz) になる

## 見るべき値

計算値。T ≈ 0.72 秒なので、16 個のクロックで 1 周 (0000→1111→0000) するのに
約 11.5 秒 (16 × 0.72 秒) かかる。Q1 の LED は 0.72 秒ごとに点灯と消灯が入れ替わる。
Q2 はその 2 倍、Q3 は 4 倍、Q4 は 8 倍の間隔で入れ替わる。

| クロック数 | Q4 Q3 Q2 Q1 | 10進 |
| --- | --- | --- |
| 0 | 0000 | 0 |
| 5 | 0101 | 5 |
| 10 | 1010 | 10 |
| 15 | 1111 | 15 |
| 16 | 0000 | 0 (桁あふれ) |

点いている LED を 1、消えている LED を 0 として左から Q4 Q3 Q2 Q1 と読むと、
クロックの数を 2 進数で表した値になる。SWRST を押すといつでも 0000 に戻る。

## 出典

自作。
