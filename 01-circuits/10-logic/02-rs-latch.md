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

10-1 のゲートは、入力を変えると出力もすぐ変わった。この題では、ゲート 2 つの出力を
互いの入力に戻して、ボタンを離しても状態を覚え続ける回路 (**ラッチ**) を作る。
カウンタやメモリなど「覚える」回路の出発点になる。

使うのは NAND (AND の出力を反転したゲート。入力が両方 1 のときだけ 0 を出す)。
CD4011 (2 入力 NAND が 4 回路入り) の 2 つのゲートだけを使う。入力の S̄・R̄ は
負論理 (0 のときに働く) で、ボタンを押している間だけ 0 になり、離すとプルアップ
(RS・RR、10kΩ で +5V へ引き上げる抵抗) で 1 に戻る。出力は Q と Q̄ (Q バー、Q の反対の値)。

## 回路図

```circuit
title: 図1 NANDたすき掛けのRSラッチ
parts:
  VCC: vcc b5 5V
  RS: resistor b5 e5 10k
  SWS: button e5 g5 l=$\mathrm{SW}_\mathrm{S}$
  GSWS: ground g5
  VCC: vcc j3 5V
  RR: resistor j3 n3 10k
  SWR: button n3 p3 l=$\mathrm{SW}_\mathrm{R}$
  GSWR: ground p3
  U1A: nand h14 CD4011
  U1B: nand m14 CD4011
  RQ: resistor h20 h23 1k
  DQ: led h23 j23 red
  GDQ: ground j23
  RQb: resistor m20 m23 1k
  DQb: led m23 o23 red
  GDQb: ground o23
wires:
  - e5 -- e11
  - e11 |- U1A.a
  - U1A.out -- h17 -- h20
  - h17 -- j17 -- j11
  - j11 |- U1B.a
  - n3 -- n11
  - n11 |- U1B.b
  - U1B.out -- m18 -- m20
  - m18 -- k18 -- k9
  - k9 |- U1A.b
notes:
  - text d8 blue: "S (Low で有効)"
  - text m7 blue: "R (Low で有効)"
  - text g18 blue: "Q"
  - text l20 blue: "Qバー"
  - text r1 small left: "数字は IC の PIN 番号 (U1A・U1B は同じ CD4011)"
  - text s1 small left: "VDD は PIN 14 (+5V)、VSS は PIN 7 (GND)。使わない入力は GND へ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/02-rs-latch.svg)

- U1A (CD4011 のゲート1、PIN 1・2→3) が Q を出す NAND、U1B (ゲート2、
  PIN 5・6→4) が Q̄ を出す NAND。互いの出力を相手の入力に戻す (PIN 4→PIN 2、
  PIN 3→PIN 5) のがラッチの仕掛け。図1 の中ほどで 2 本の戻り線が 1 回交わる
  (黒丸が無いのでつながってはいない)
- SWS (Set) を押すと PIN 1 が 0 になり、Q (PIN 3) が 1 になる。SWR (Reset) を押すと
  PIN 6 が 0 になり、Q̄ (PIN 4) が 1 (= Q が 0) になる
- 両方離しているあいだは、直前に決まった Q・Q̄ をそのまま保持する
  (だから「ラッチ」= 掛け金)
- ゲートは論理記号で描き、記号の足に IC の PIN 番号を添えた。電源の足は記号に
  出ないので図の下に書いた。PIN 14 (VDD) を +5V へ、PIN 7 (VSS) を GND へつなぐ
- 使わないゲート3・4 の入力 (PIN 8・9・12・13) は GND につなぐ (図1 には描かず、
  図の下に書いた)。CMOS の入力は浮かせると勝手に振れて電流を食う (10-1)。
  出力の PIN 10・11 は何もつながずに開けておく
- LED の直列抵抗 RQ・RQb は 1kΩ。10-1 と同じく、5V の CD4000 系の出力は数 mA しか
  流し出せない (TI の CD4011B のデータシートで I<sub>OH</sub> は出力 2.5V のとき最小 1.6mA)。
  1kΩ なら LED の電流は 1.5〜2.2mA (10-1 で求めた目安)。暗いときは高輝度 LED にするか、
  74HC00 (74HC 系の NAND) に替える

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  SWS: button @ e5
  RS: resistor b3 b5 10k
  SWR: button @ e32
  RR: resistor b36 b34 10k
  U1: dip14 @ e20 CD4011
  RQ: resistor h16 h11 1k
  DQ: led g11(A) g8(K) red
  RQb: resistor h30 h35 1k
  DQb: led i35(A) i39(K) red
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t3 -- a3 red
  - +t36 -- a36 red
  - a20 -- +t20 red
  # S: 7 列 → PIN 1 (20 列)
  - d7 -- d18 yellow
  - e18 -- f18 yellow
  - g18 -- g20 yellow
  # R: 32 列 → PIN 6 (25 列)
  - d32 -- d28 green
  - e28 -- f28 green
  - g28 -- g25 green
  # たすき掛け: PIN 4 → PIN 2、PIN 3 → PIN 5
  - g23 -- g21 orange
  - h22 -- h24 orange
  # Q (PIN 3) → RQ、Qバー (PIN 4) → RQb
  - i22 -- i16 blue
  - i23 -- i30 orange
  - j7 -- -b7 black
  - j32 -- -b32 black
  - j26 -- -b26 black
  - j8 -- -b8 black
  - j39 -- -b39 black
  # 使わない入力 (PIN 8・9・12・13) を上の青レール (GND) へ
  - a21 -- -t21 black
  - a22 -- -t22 black
  - a25 -- -t25 black
  - a26 -- -t26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/02-rs-latch.svg)

- 電源は Analog Discovery 3 (AD3、0-3 で使った USB 計測器) の Supplies で、V+ を 5V にする。
  左上の AD3 の V+ を上の赤レール (+t1) へ赤、GND を上の青レール (-t2) へ黒で入れる。
  下の青レールは 1 列で上の青レールとつなぐ
- SWS (e5)・SWR (e32) はタクトスイッチ。溝をまたぐ 4 本足の手前側
  (1a・1b、e5/e7 か e32/e34) にプルアップの節点、奥側 (2a・2b、f5/f7 か
  f32/f34) に GND をつなぐ。押すと手前と奥がつながり、押している間だけ入力の PIN が 0 になる
- U1 (CD4011) は 20〜26 列。切り欠きが左で、PIN 1 が左下 (f 行)、PIN 14 が左上
  (e 行)。PIN 14 (20 列の上) を a20 から赤レールへ、PIN 7 (26 列の下) を j26 から
  下の青レールへ
- S (黄) は d7→d18、e18→f18 で溝を渡り、g18→g20 で PIN 1 へ。R (緑) は
  d32→d28、e28→f28 で溝を渡り、g28→g25 で PIN 6 へ。1 つの穴には線か足を 1 本だけ挿す
- たすき掛けは下のブロックで、PIN 4→PIN 2 (g23→g21、オレンジ)、PIN 3→PIN 5
  (h22→h24、オレンジ)
- PIN 3 (Q、22 列) は i 行の青の線 (i22→i16) で RQ・DQ へ。PIN 4 (Q̄、
  23 列) は i 行のオレンジの線 (i23→i30) で RQb・DQb へ
- 使わないゲート3・4 の入力 (PIN 13・12・9・8 = 21・22・25・26 列の上) は、a 行から
  黒の短い線で上の青レール (GND) へ。PIN 11・10 (23・24 列の上) は出力なので開けておく

## 計器の設定

計器は AD3 の Supplies (電源) だけを使い、Q・Q̄ は LED で読む。
この題はオシロの図を付けない — ボタンを押す・離すたびに変わる直流の 0 と 1 (保持された状態) を見る題で、
画面に残す時間の波形が無いため。

板を流れる電流は、LED 1 個 (1kΩ で約 2mA) と押したボタンのプルアップ (5V / 10kΩ = 0.5mA) を合わせて
数 mA。板の範囲 (1 穴 200mA・板全体 500mA) にも、AD3 の V+ を USB 給電で使うときの目安 (5V で 50mA) にも収まる。

## 見るべき値

| 操作 | Q (DQ) | Q̄ (DQb) |
| --- | --- | --- |
| SWS を押す | 点灯 (1) | 消灯 (0) |
| 両方離す (直後) | 前のまま保持 | 前のまま保持 |
| SWR を押す | 消灯 (0) | 点灯 (1) |
| SWS と SWR を同時に押す | 点灯 (1、禁止入力) | 点灯 (1、禁止入力) |

最後の行は NAND ラッチの禁止入力。両方を 0 にすると、Q・Q̄ がどちらも 1 になって
「反対の値」という約束が崩れる。そのまま同時に離すと、どちらへ落ち着くかは 2 つの
ゲートのわずかな差と離すタイミングで決まり、試すたびに変わりうる (不定)。

## 出典

自作。
