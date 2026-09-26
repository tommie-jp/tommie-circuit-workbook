---
book: circuits
chapter: 10
id: 10-2
title: RS ラッチ (NAND)
tier: 50
source: 自作
board: BB
---

# 10-2 RS ラッチ (NAND)

NAND を 2 つ交差につなぐと、ボタンを離しても状態を覚え続ける**ラッチ**になる。
CD4011 (4 回路入り 2 入力 NAND) の 2 つのゲートだけを使う。S̄・R̄ は**負論理**
(押す = 0) — ボタンを押した瞬間だけ 0 になり、離すとプルアップで 1 に戻る。

## 回路図

```circuit
title: 図1 NANDたすき掛けのRSラッチ
parts:
  VCC: vcc a9
  RS: resistor a9 c9 10k
  SWS: button c9 c7
  GSWS: ground c7
  VCC: vcc h3
  RR: resistor h3 h5 10k
  SWR: button h5 j5
  GSWR: ground j5
  U1: dip14 e10g0 CD4011
  RQ: resistor h9 h11 330
  DQ: led h11 j11 red
  GDQ: ground j11
  RQb: resistor d6i0 d3i0 330
  DQb: led d3i0 e3i0 red
  GDQb: ground e3i0
  VCC: vcc c11
  G1: ground g9
  GU1: ground f11i3
wires:
  - U1.1 -| c9
  - U1.2 -| d8i5
  - U1.4 -| d8i5
  - d8i5 -- d6i0
  - U1.3 -| e8c0
  - U1.6 -| f8e0
  - e8c0 -- f8e0 -- h8 -- h9
  - U1.5 -| h5
  - U1.14 -| c11
  - U1.7 -| g9
  # 使わないゲート3・4 の入力 (足8・9・12・13) を GND へ
  - U1.13 -| d11i3
  - U1.12 -| e11c3
  - U1.9 -| f11e3
  - U1.8 -| f11i3
  - d11i3 -- e11c3 -- f11e3 -- f11i3
notes:
  - text b8 right blue: "S (足1、Low で有効)"
  - text j4 right blue: "R (足5、Low で有効)"
  - text g7 right blue: "Q (足3)"
  - text d3 blue: "Qバー (足4)"
style:
  grid: on
  pitch: 1.2
```

- U1 の**ゲート1** (足1・2→3) が Q を出す NAND、**ゲート2** (足5・6→4) が Q̄ を
  出す NAND。互いの出力を相手の 2 番目の入力に戻す (足4→足2、足3→足6) のが
  ラッチの仕掛け
- SWS (Set) を押すと足1が 0 になり、Q (足3) が 1 になる。SWR (Reset) を押すと
  足5が 0 になり、Q̄ (足4) が 1 (= Q が 0) になる
- 両方離しているあいだは、直前に決まった Q・Q̄ を**そのまま保持**する
  (だから「ラッチ」)
- U1.7 (VSS) は g9 の GND (SWS のボタン側と同じ GND) へ、U1.14 (VDD) は
  c11 の Vcc へ
- **使わない入力は GND へ。** 使わないゲート3・4 の入力 (足8・9・12・13) は
  GND につなぐ (図の U1 の右側)。CMOS の入力は浮かせると勝手に振れて電流を
  食う。出力の足10・11 は何もつながずに開けておく

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  SWS: button @ e5
  RS: resistor c3 c5 10k
  SWR: button @ e12
  RR: resistor c10 c12 10k
  U1: dip14 @ e20 CD4011
  RQ: resistor g30 g32 330
  DQ: led h32(A) h34(K) red
  RQb: resistor i19 i17 330
  DQb: led h17(A) h15(K) red
wires:
  - -t1 -- -b1
  - +t3 -- b3
  - b5 -- g20
  - g7 -- -b7
  - +t10 -- b10
  - b12 -- g24
  - g14 -- -b14
  - a20 -- +t20
  - g26 -- -b26
  - g23 -- g21
  - h22 -- h25
  - i22 -- i30
  - j23 -- j19
  - j34 -- -b34
  - j15 -- -b15
  # 使わない入力 (足8・9・12・13) を上の青レール (GND) へ
  - a21 -- -t21 black
  - a22 -- -t22 black
  - a25 -- -t25 black
  - a26 -- -t26 black
```

- 上の赤レール = +5V、青レール = GND。下の青レールは 1 列で上の青レールとつなぐ
- SWS (e5)・SWR (e12) はタクトスイッチ。溝をまたぐ 4 本足の**手前側**
  (1a・1b、e5/e7 か e12/e14) にプルアップの節点、**奥側** (2a・2b、f5/f7 か
  f12/f14) に GND。押すと手前と奥がつながり、足が瞬間だけ 0 になる
- U1 (CD4011) は 20〜26 列。切り欠きが左で、足1 が左下 (f 行)、足14 が左上
  (e 行)。足14 (20 列の上) を赤レールへ、足7 (26 列の下) を下の青レールへ
- 足1 (20 列の下) に S、足5 (24 列の下) に R。たすき掛けは下のブロックで、
  足4→足2 (23 列→21 列、g 行)、足3→足6 (22 列→25 列、h 行)
- 足3 (Q、22 列) は i 行で 30 列へ渡して RQ・DQ (LED1) へ。足4 (Q バー、23 列)
  は j 行で 19 列へ渡して RQb・DQb (LED2) へ
- 使わないゲート3・4 の入力 (足13・12・9・8 = 21・22・25・26 列の上) は、a 行から
  黒の短い線で上の青レール (GND) へ。足11・10 (23・24 列の上) は出力なので開けておく

## 見るべき値

| 操作 | Q (LED1) | Q̄ (LED2) |
| --- | --- | --- |
| SWS を押す | **点灯 (1)** | 消灯 (0) |
| 両方離す (直後) | **前のまま保持** | **前のまま保持** |
| SWR を押す | 消灯 (0) | **点灯 (1)** |
| SWS と SWR を同時に押す | 点灯 (**不定状態**) | 点灯 (**不定状態**) |

最後の行は NAND ラッチの**禁止入力**。両方 0 にすると Q・Q̄ がどちらも 1 に
なり、同時に離した瞬間にどちらへ落ち着くかは回路のわずかな差で決まる
(実機で試すと再現しにくい理由)。

## 出典

自作。
