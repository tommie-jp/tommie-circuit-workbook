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
  c11 の Vcc へ。使わないゲート3・4 の入力は実機では GND へ落とす

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
  RQ: resistor a32 a34 330
  DQ: led c34(A) c36(K) red
  RQb: resistor a42 a44 330
  DQb: led c44(A) c46(K) red
wires:
  - +t3 -- b3
  - b5 -- U1.1
  - g7 -- -b7
  - +t10 -- b10
  - b12 -- U1.5
  - g14 -- -b14
  - U1.4 -- b25
  - b25 -- U1.2
  - U1.3 -- b26
  - b26 -- U1.6
  - U1.14 -- b20
  - b20 -- +t20
  - U1.7 -- b21
  - b21 -- -t21
  - U1.3 -- b32
  - U1.4 -- b42
  - b34 -- -t34
  - b44 -- -t44
```

- SWS (e5)・SWR (e12) はタクトスイッチ。溝をまたぐ 4 本足の**手前側**
  (1a・1b、e5/e7 か e12/e14) にプルアップの節点、**奥側** (2a・2b、f5/f7 か
  f12/f14) に GND。押すと手前と奥がつながり、足が瞬間だけ 0 になる
- U1 (e20、CD4011) の足1に S、足5に R。足4→足2、足3→足6 のたすき掛けは
  25・26 列の空き穴を経由
- 足3 (Q) が LED1、足4 (Q バー) が LED2

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
