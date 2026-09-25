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

- 555 は標準の非安定 (R1 10kΩ、R2 47kΩ、C1 10µF)。T ≈ 0.69×(10k+2×47k)×10µ
  **≈ 0.72秒**、f ≈ 1.4Hz
- 555 の出力 (足3) が 4040 のクロック (足10)。**立ち下がりで 1 つ進む**
- SWRST を押すと足11 (RESET) が Vcc (H) になり、カウンタが 0000 に戻る。
  離すと RRST (10kΩ) が足11 を GND (L) に落とす
- Q1 (足9)・Q2 (足7)・Q3 (足6)・Q4 (足5) が下 4 ビット。5 ビット目から上は
  この題では使わない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  U555: dip8 @ e5 NE555
  R1: resistor a12 a14 10k
  R2: resistor c14 c17 47k
  C1: capacitor/electrolytic a17 a19 10u
  U40: dip16 @ e20 CD4040
  RRST: resistor c35 c37 10k
  SWRST: button @ e40
  RQ1: resistor a45 a47 330
  DQ1: led c47(A) c49(K) red
  RQ2: resistor a52 a54 330
  DQ2: led c54(A) c56(K) red
  RQ3: resistor a59 a61 330
  DQ3: led c61(A) c63(K) red
wires:
  - U555.8 -- b8
  - b8 -- +t8
  - U555.4 -- b8
  - U555.1 -- b9
  - b9 -- -t9
  - U555.7 -- b12
  - b17 -- U555.6
  - U555.2 -- b17
  - b19 -- -t19
  - U555.3 -- U40.10
  - U40.16 -- b20
  - b20 -- +t20
  - U40.8 -- b21
  - b21 -- -t21
  - c35 -- U40.11
  - c37 -- b9
  - d40 -- c35
  - +b42 -- g42
  - U40.9 -- b45
  - U40.7 -- b52
  - U40.6 -- b59
  - c49 -- -t49
  - c56 -- -t56
  - c63 -- -t63
```

- Q4 (5 番目の LED) は列が足りないので省略。Q1〜Q3 と同じ考え方で足4 (Q4)
  から続ければ足せる
- U555 (e5) の足8・4 を +t (Vcc) へ、足1 を GND へ。R1・R2・C1 で非安定回路
- U40 (e20) の足16 を +t、足8 を GND へ。足10 に 555 の出力、足11 に
  リセットボタン (押すと Vcc、離すと RRST で GND)

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
