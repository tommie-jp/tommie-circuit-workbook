---
book: circuits
chapter: 10
id: 10-1
title: ゲートの基本 — スイッチと LED で AND / OR / NOT
tier: 50
source: 自作
board: BB
---

# 10-1 ゲートの基本 — スイッチと LED で AND / OR / NOT

CMOS ロジック IC を 3 つ並べ、同じ 2 つのスイッチ入力 (A・B) を AND と OR の
両方に入れて出力を比べる。もう 1 つのスイッチ C は NOT (インバータ) に入れる。
LED が点いていれば出力は 1 (Hレベル)、消えていれば 0。

## 回路図

```circuit
title: 図1 AND・OR・NOTを並べて比べる
parts:
  A: switch d3 f3
  RpdA: resistor f3 f1 10k
  GA: ground f1 r90
  B: switch c6 e6
  RpdB: resistor e6 e4 10k
  GB: ground e4 r90
  C: switch b9 d9
  RpdC: resistor d9 d7 10k
  GC: ground d7 r90
  VCC: vcc d3
  VCC: vcc c6
  VCC: vcc b9
  U1: dip14 i13 CD4081
  U2: dip14 i18 CD4071
  U3: dip14 i23 CD4069
  VCC: vcc g14i0
  VCC: vcc g19i0
  VCC: vcc g24i0
  R1: resistor l11 m11 330
  D1: led m11 n11 red
  GD1: ground n11
  R2: resistor l16 m16 330
  D2: led m16 n16 red
  GD2: ground n16
  R3: resistor l21 m21 330
  D3: led m21 n21 red
  GD3: ground n21
  GU1: ground k12
  GU2: ground k17
  GU3: ground k21a6
  GU1b: ground j14c3
  GU2b: ground j19c3
  GU3b: ground i24i3
wires:
  - f3 -- f12 -- f17
  - e6 -- e11a5 -- e16a5
  - d9 -- d22
  - f12 |- U1.1
  - e11a5 |- U1.2
  - f17 |- U2.1
  - e16a5 |- U2.2
  - d22 |- U3.1
  - U1.3 -| l11
  - U2.3 -| l16
  - U3.2 -| l21
  - U1.14 -| g14i0
  - U2.14 -| g19i0
  - U3.14 -| g24i0
  - U1.7 -| j12c0
  - U2.7 -| j17c0
  - U3.7 -| j21c6
  # 使わない入力 (U1・U2 は足5・6・8・9・12・13、U3 は足3・5・9・11・13) を GND へ
  - U1.5 -| i12e0
  - U1.6 -| i12i0
  - i12e0 -- i12i0 -- j12c0 -- k12
  - U1.13 -| h14c3
  - U1.12 -| h14g3
  - U1.9 -| i14i3
  - U1.8 -| j14c3
  - h14c3 -- h14g3 -- i14i3 -- j14c3
  - U2.5 -| i17e0
  - U2.6 -| i17i0
  - i17e0 -- i17i0 -- j17c0 -- k17
  - U2.13 -| h19c3
  - U2.12 -| h19g3
  - U2.9 -| i19i3
  - U2.8 -| j19c3
  - h19c3 -- h19g3 -- i19i3 -- j19c3
  - U3.3 -| h21g6
  - U3.5 -| i21e6
  - h21g6 -- i21e6 -- j21c6 -- k21a6
  - U3.13 -| h24c3
  - U3.11 -| i24a3
  - U3.9 -| i24i3
  - h24c3 -- i24a3 -- i24i3
notes:
  - text k13a5 blue: AND
  - text k18a5 blue: OR
  - text k23a5 blue: NOT
style:
  grid: on
  pitch: 1.2
```

- U1 (CD4081、AND) と U2 (CD4071、OR) は**同じ A・B** を入力にする。ゲート1
  (足1・2→3) だけを使う
- U3 (CD4069、6 回路入りインバータ) はゲート1 (足1→2) を使う。C を NOT に入れる
- スイッチを開けると入力はプルダウン抵抗 (10kΩ) で 0V (0) に落ち、閉じると
  Vcc (1) になる。CMOS の入力は浮かせてはいけないので、開いている間もプル
  ダウンで電位を決めておく
- U1.14・U2.14・U3.14 が VDD (5V)、U1.7・U2.7・U3.7 が VSS (GND)
- **使わない入力は GND へ。** U1・U2 は残り 3 ゲートの入力 (足5・6・8・9・12・13)、
  U3 は残り 5 回路の入力 (足3・5・9・11・13) を GND につなぐ。CMOS の入力は
  浮かせると勝手に振れて電流を食う。出力の足 (U1・U2 の足4・10・11、U3 の足4・6・
  8・10・12) は何もつながずに開けておく

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  A: switch a3 a5
  RpdA: resistor c5 c7 10k
  B: switch a10 a12
  RpdB: resistor c12 c14 10k
  C: switch a17 a19
  RpdC: resistor c19 c21 10k
  U1: dip14 @ e24 CD4081
  U2: dip14 @ e38 CD4071
  U3: dip14 @ e52 CD4069
  R1: resistor i32 i34 330
  D1: led h34(A) h36(K) red
  R2: resistor i46 i48 330
  D2: led h48(A) h50(K) red
  R3: resistor i59 i61 330
  D3: led h61(A) h63(K) red
wires:
  - +t3 -- b3
  - b7 -- -t7
  - +t10 -- b10
  - b14 -- -t14
  - +t17 -- b17
  - b21 -- -t21
  - -t1 -- -b1
  - b5 -- g24
  - d5 -- g38
  - b12 -- g25
  - d12 -- g39
  - b19 -- g52
  - a24 -- +t24
  - j30 -- -b30
  - a38 -- +t38
  - j44 -- -b44
  - a52 -- +t52
  - j58 -- -b58
  - h26 -- h32
  - h40 -- h46
  - h53 -- h59
  - j36 -- -b36
  - j50 -- -b50
  - j63 -- -b63
  # 使わない入力を GND へ (上は上の青レール、下は下の青レール)
  - a25 -- -t25 black
  - a26 -- -t26 black
  - a29 -- -t29 black
  - a30 -- -t30 black
  - j28 -- -b28 black
  - j29 -- -b29 black
  - a39 -- -t39 black
  - a40 -- -t40 black
  - a43 -- -t43 black
  - a44 -- -t44 black
  - j42 -- -b42 black
  - j43 -- -b43 black
  - a53 -- -t53 black
  - a55 -- -t55 black
  - a57 -- -t57 black
  - j54 -- -b54 black
  - j56 -- -b56 black
```

- 上の赤レール = +5V (単3 電池 3 本か USB の 5V)、青レール = GND。下の青レールは
  1 列で上の青レールとつなぐ
- U1 (CD4081, AND) は 24〜30 列、U2 (CD4071, OR) は 38〜44 列、U3 (CD4069, NOT)
  は 52〜58 列。どれも切り欠きが左で、足1 が左下 (f 行)、足14 が左上 (e 行)
- 電源: 各 IC の足14 (24・38・52 列の上) を上の赤レールへ、足7 (VSS、30・44・58
  列の下) を下の青レールへ
- A・B は 5・12 列のスイッチの出力を、それぞれ U1 と U2 の足 1・2 (24・25 列と
  38・39 列の下) へ渡す。C は 19 列から U3 の足 1 (52 列の下) へ
- 出力 (U1・U2 の足3 = 26・40 列、U3 の足2 = 53 列) は h 行で右隣の空き列へ渡し、
  330Ω と LED を通して下の青レールへ
- 使わない入力は黒の短い線で GND へ。上側の足 (U1・U2 の足8・9・12・13、U3 の
  足9・11・13) は a 行から上の青レールへ、下側の足 (U1・U2 の足5・6、U3 の足3・5)
  は j 行から下の青レールへ

## 見るべき値

| A | B | AND (LED1) | OR (LED2) |
| --- | --- | --- | --- |
| 0 | 0 | 消灯 | 消灯 |
| 1 | 0 | 消灯 | **点灯** |
| 0 | 1 | 消灯 | **点灯** |
| 1 | 1 | **点灯** | **点灯** |

| C | NOT (LED3) |
| --- | --- |
| 0 | **点灯** |
| 1 | 消灯 |

AND は両方閉じたときだけ点く。OR はどちらか片方でも点く。NOT はスイッチを
**開けている間だけ**点く (入力 0 → 出力 1)。

## 出典

自作。
