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

555 のゆっくりした方形波を CD4040 (12 ステージのバイナリカウンタ) のクロックに
入れ、下 4 ビット (Q1〜Q4) を LED で見る。0000 から 1111 まで 2 進数で数える。

## この実験で確かめる式

555 非安定のクロック周期 T = 0.69 × (R1 + 2·R2) × C1、4040 は**クロックの
立ち下がりで 1 つ数える**リプルカウンタ。

## 回路図

```circuit
title: 図1 555クロック + 4040バイナリカウンタ
parts:
  VCC: vcc b12
  U555: dip8 i16i0 NE555
  R1: resistor h19 g19 10k
  R2: resistor h19 h21 47k
  C1: capacitor h23 j23 10u
  GC1: ground j23
  U40: dip16 i10 CD4040
  GU40: ground k9
  GU555: ground i15c0 r90
  GRRST: ground d14 r270
  RRST: resistor d12 d14 10k
  SWRST: button d12 b12
  VCC: vcc f11
  VCC: vcc g17
  VCC: vcc l16
  RQ1: resistor l11a2 m11a2 330
  DQ1: led m11a2 n11a2 red
  GQ1: ground n11a2
  RQ2: resistor l8 m8 330
  DQ2: led m8 n8 red
  GQ2: ground n8
  RQ3: resistor l5a5 m5a5 330
  DQ3: led m5a5 n5a5 red
  GQ3: ground n5a5
  RQ4: resistor l3 m3 330
  DQ4: led m3 n3 red
  GQ4: ground n3
wires:
  - U555.3 -- U40.10
  - U40.16 -| f11
  - U40.11 -| d12
  - U555.1 -| i15c0
  - U555.2 -| e14a2
  - e14a2 -- e21 -- h21
  - U555.8 -| g17
  - g17 -- g19
  - U555.7 -| h19
  - U555.6 -| h21
  - h21 -- h23
  - U555.4 -| l15
  - l15 -- l16
  - U40.8 -| k9
  - U40.9 -| l11a2
  - U40.7 -| l8
  - U40.6 -| k7a4
  - k7a4 -- k5a5 -- l5a5
  - U40.5 -| j6f8
  - j6f8 -- j3f0 -- l3
notes:
  - text o10a6 blue: Q1 (LSB)
  - text o7a6 blue: Q2
  - text o5a1 blue: Q3
  - text o2a6 blue: Q4 (MSB)
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/04-binary-counter.svg)

- 555 は標準の非安定 (R1 10kΩ、R2 47kΩ、C1 10µF)。T ≈ 0.69×(10k+2×47k)×10µ
  **≈ 0.72秒**、f ≈ 1.4Hz
- 555 の出力 (足3) が 4040 のクロック (足10)。**立ち下がりで 1 つ進む**
- SWRST を押すと足11 (RESET) が Vcc (H) になり、カウンタが 0000 に戻る。
  離すと RRST (10kΩ) が足11 を GND (L) に落とす
- Q1 (足9)・Q2 (足7)・Q3 (足6)・Q4 (足5) が下 4 ビット。5 ビット目から上は
  この題では使わない
- CD4040 の入力は CLK (足10) と RESET (足11) の 2 本だけで、どちらもつないで
  ある (RESET は RRST で GND へ)。CMOS の入力は浮かせてはいけないが、この IC に
  使わない入力は無い。使わない Q5〜Q12 は出力なので開けておく

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
  RQ1: resistor a32 a34 330
  DQ1: led c34(A) c36(K) red
  RQ2: resistor a38 a40 330
  DQ2: led c40(A) c42(K) red
  RQ3: resistor a44 a46 330
  DQ3: led c46(A) c48(K) red
  RQ4: resistor a50 a52 330
  DQ4: led c52(A) c54(K) red
wires:
  - -t1 -- -b1 black
  - +t2 -- +b2 red
  - a5 -- +t5 red
  - a3 -- +t3 red
  - j5 -- -b5 black
  - j8 -- +b8 red
  - b7 -- b9 orange
  - d9 -- g9 -- g6 orange
  - j12 -- -b12 black
  - h7 -- h21 -- d21 -- d28 blue
  - c27 -- c19 green
  - b14 -- -t14 black
  - j17 -- +b17 red
  - a22 -- +t22 red
  - j29 -- -b29 black
  - d29 -- d32 yellow
  - g28 -- g38 -- e38 yellow
  - h27 -- h44 -- e44 yellow
  - i26 -- i50 -- e50 yellow
  - b36 -- -t36 black
  - b42 -- -t42 black
  - b48 -- -t48 black
  - b54 -- -t54 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/04-binary-counter.svg)

- 上の赤レール = Vcc、青レール = GND。下のレールは 1・2 列で上のレールとつなぐ
- U555 (NE555) は 5〜8 列、U40 (CD4040) は 22〜29 列。どちらも切り欠きが左で、
  足1 が左下 (f 行)。U555 は足8 (5 列の上) が左上、U40 は足16 (22 列の上) が左上
- U555: 足8 (5 列の上) と足4 (RESET、8 列の下) を Vcc へ、足1 (5 列の下) を GND へ。
  R1 は足7 (6 列の上) から 3 列の Vcc へ、R2 は足7 から 9 列へ。9 列は b 行で
  足6 (7 列の上) とつなぎ、溝をまたぐオレンジの線で足2 (6 列の下) へも渡す。
  C1 (+ が 9 列の下) を通して GND へ。足5 (CONT) は使わない
- U40: 足16 (22 列の上) を Vcc、足8 (29 列の下) を GND へ。足10 (CLK、28 列の上)
  には 555 の足3 (7 列の下) から青の線 (h 行 → 21 列で溝をまたぐ → d 行)。
  足11 (RESET、27 列の上) は c 行の緑の線で 19 列へ渡し、RRST (10kΩ) で GND へ、
  SWRST (e17) を押すと Vcc へ
- Q1 (足9、29 列の上)・Q2 (足7、28 列の下)・Q3 (足6、27 列の下)・Q4 (足5、
  26 列の下) を黄の線で 32・38・44・50 列へ渡し (下の 3 本は g・h・i 行を通って
  溝をまたぐ)、330Ω と LED を通して GND へ

## 見るべき値

計算値。T ≈ 0.72秒 なので、16 個のクロックで**1 周 (0000→1111→0000) に
約 11.6秒**。

| クロック数 | Q4 Q3 Q2 Q1 | 10進 |
| --- | --- | --- |
| 0 | 0000 | 0 |
| 5 | 0101 | 5 |
| 10 | 1010 | 10 |
| 15 | 1111 | 15 |
| 16 | 0000 | 0 (桁あふれ) |

LED が 2 進数のカウントアップとして順に点滅する。SWRST を押すといつでも
0000 に戻る。

## 出典

自作。
