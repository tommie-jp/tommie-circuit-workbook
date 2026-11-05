---
book: circuits
chapter: 12
id: 12-9
title: LED イルミネーション (4017)
tier: 200
source: 自作
board: PF
---

# 12-9 LED イルミネーション (4017)

10-10 では 4017 の出力に LED を 1 kΩ (オーム) で直につなぎ、2.6 mA ほどで光らせた。飾りのイルミネーションにするには、もっと明るく (15 mA ほど) 光らせたい。
ところが CD4017B の出力は、5 V で使うと**1〜3 mA しか出せない** (データシートの出力の電流: 5 V で 4.6 V を保つのは標準 1 mA、2.5 V まで下がってよくて標準 3.2 mA)。
そこで、4017 と LED の間に**ドライバ IC の ULN2003A** (ダーリントントランジスタ 7 回路) を入れ、4017 は ULN2003A の入力に 1 mA ほどを流すだけにする。
LED の電流は ULN2003A が 5 V から吸い込む。クロックは 3-8 の 40106 の RC 発振で作り、4017 の Q7 を RESET に戻して 7 個の LED を順に送る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 40106 の発振で 4017 を進め、ULN2003A が 7 個の LED を順に点ける
parts:
  U1A: not 4,4 CD40106B
  RF: resistor 3,2.5 5.5,2.5 100k l=$R_\mathrm{F}$
  CF: ecap 2.5,4 2.5,6 2.2u l=$C_\mathrm{F}$
  GCF: ground 2.5,6
  CLK: port 8,4 out
  U2: dip16 18,6 CD4017
  VCC: vcc 20.5,4 5V
  Q7: port 19.6,5.2 in
  GINH: ground 19.6,6 r270
  CLK: port 21.4,5.6 in
  Q4: port 23.8,7.2 out
  Q5: port 15.5,4.8 out
  Q1: port 14.8,5.2 out
  Q0: port 14.1,5.6 out
  Q2: port 13.4,6 out
  Q6: port 12.7,6.4 out
  Q7: port 12,6.8 out
  Q3: port 11.3,7.2 out
  GVSS: ground 16,7.6 r90
  U3: dip16 18,12 ULN2003A
  Q4: port 15.5,10.8 in
  Q3: port 14.8,11.2 in
  Q6: port 14.1,11.6 in
  Q2: port 13.4,12 in
  Q0: port 12.7,12.4 in
  Q1: port 12,12.8 in
  Q5: port 11.3,13.2 in
  GULN: ground 16,13.6 r90
  VCC: vcc 26,7 5V
  D4: led 26,7 26,8.5 red
  R4: resistor 26,8.5 26,10 150
  VCC: vcc 27.5,7 5V
  D3: led 27.5,7 27.5,8.5 red
  R3: resistor 27.5,8.5 27.5,10 150
  VCC: vcc 29,7 5V
  D6: led 29,7 29,8.5 red
  R6: resistor 29,8.5 29,10 150
  VCC: vcc 30.5,7 5V
  D2: led 30.5,7 30.5,8.5 red
  R2: resistor 30.5,8.5 30.5,10 150
  VCC: vcc 32,7 5V
  D0: led 32,7 32,8.5 red
  R0: resistor 32,8.5 32,10 150
  VCC: vcc 33.5,7 5V
  D1: led 33.5,7 33.5,8.5 red
  R1: resistor 33.5,8.5 33.5,10 150
  VCC: vcc 35,7 5V
  D5: led 35,7 35,8.5 red
  R5: resistor 35,8.5 35,10 150
wires:
  - U1A.out -- 5.5,4 -- 8,4
  - 5.5,4 -- 5.5,2.5
  - 3,2.5 -- 2.5,2.5 -- 2.5,4
  - 2.5,4 -- U1A.in
  - U2.VDD -| 20.5,4.8
  - 20.5,4.8 -- 20.5,4
  - U2.RESET -| 19.6,5.2
  - U2.INH -| 19.6,6
  - U2.CLOCK -| 21.4,5.6
  - U2.Q4 -| 23.8,7.2
  - U2.Q5 -| 15.5,4.8
  - U2.Q1 -| 14.8,5.2
  - U2.Q0 -| 14.1,5.6
  - U2.Q2 -| 13.4,6
  - U2.Q6 -| 12.7,6.4
  - U2.Q7 -| 12,6.8
  - U2.Q3 -| 11.3,7.2
  - U2.VSS -| 16,7.6
  - U3.1B -| 15.5,10.8
  - U3.2B -| 14.8,11.2
  - U3.3B -| 14.1,11.6
  - U3.4B -| 13.4,12
  - U3.5B -| 12.7,12.4
  - U3.6B -| 12,12.8
  - U3.7B -| 11.3,13.2
  - U3.GND -| 16,13.6
  - U3.1C -| 26,10
  - U3.2C -| 27.5,10
  - U3.3C -| 29,10
  - U3.4C -| 30.5,10
  - U3.5C -| 32,10
  - U3.6C -| 33.5,10
  - U3.7C -| 35,10
notes:
  - text 1,9 small left: "同じ名前の端子 (CLK・Q0 から Q7) はつながっている"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/09-led-illumination-4017.svg)

- **クロック (U1A)**: 40106 (シュミットインバータ) の 1 回路に R<sub>F</sub> (100 kΩ) と C<sub>F</sub> (2.2 µF (マイクロファラド)) を付けた 3-8 の発振。
  周期は 0.81 × R<sub>F</sub> × C<sub>F</sub> = 0.81 × 100 kΩ × 2.2 µF ≈ 0.18 秒 (5.6 Hz)。係数 0.81 は TI の典型のしきい値 (2.9 V・1.9 V) から出した値で、品によって 2 割ほど動く (目安)
- **4017 (U2)**: クロックの立ち上がりごとに Q0 → Q1 → … と 1 本ずつ High になる。Q7 が High になった瞬間に RESET が掛かって Q0 に戻るので、**Q0〜Q6 の 7 本を 0.18 秒ずつ、1 周 1.25 秒**で回る。CLOCK INHIBIT (13 番) は GND
- **ULN2003A (U3)**: 入力 (1B〜7B) に 2.7 kΩ が入っていて、5 V の CMOS の出力でそのまま動かせる (データシート)。4017 の High の 4.5 V ほどで入力に 1.2 mA ほど流れ、出力 (1C〜7C) が GND の側へ入る。
  出力はコレクタだけなので、LED は 5 V から R (150 Ω) を通して出力へつなぐ。LED の電流は (5 V − V<sub>F</sub> − 0.73 V) ÷ 150 Ω ≈ 15 mA (LTspice。0.73 V はダーリントンの飽和電圧)
- 1 回路は 500 mA まで流せる (データシートの定格) ので、1 回路に LED を数個並べる (それぞれに 150 Ω) こともできる。そのときは電源の容量を見て決める
- COM (9 番) はモータなど巻線の負荷のときに電源へつなぐダイオードの端子で、LED では使わない
- 出力の対応は、ULN2003A の 1C = Q4、2C = Q3、3C = Q6、4C = Q2、5C = Q0、6C = Q1、7C = Q5。基板の配線が交差しないように選んだ並び (図2)

## ユニバーサル基板に組む

飾りに付けて使う作品なので、perfboard に組む。部品が多いので、発振の基板 (5×7 cm) と本体の基板 (9×7 cm) に分けた。LED は飾りの側に置き、8 ピンのヘッダ J1 から線でつなぐ。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図2 perfboard 2 枚に組む (部品面。黄色の丸は AD3 を挟む所)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
sheets:
  - name: 発振
    unused: [U1.H, U1.I, U1.J, U1.K, U1.L]
    points:
      PWR: a17
      GND: a5
      CLK: g6
    parts:
      U1: dip14 f12 CD40106B
      RF: resistor e7 g7 100k
      CF: capacitor/electrolytic d9 d6 2.2u
    wires:
      - PWR -- f17 red
      - f12 -- f13 red
      - f13 -- f17 red
      - g12 -- g13 red
      - i12 -- i13 red
      - k12 -- k13 red
      - k13 -- i13 red
      - i13 -- g13 red
      - g13 -- f13 red
      - GND -- d5 black
      - d5 -- l5 black
      - l9 -- l7 black
      - l7 -- l5 black
      - h9 -- h7 black
      - j9 -- j7 black
      - h7 -- j7 black
      - j7 -- l7 black
      - f9 -- e9 yellow
      - e9 -- e7 yellow
      - e9 -- d9 yellow
      - d6 -- d5 black
      - g9 -- g7 orange
      - g7 -- CLK orange
    notes:
      - mark g6 yellow
      - text g4 red large bold center: 1+
  - name: 本体
    board:
      size: 9x7cm
      silk: board
      h: 1.6mm
      material: FR-4
      slots: on
    unused: [U2.Q8, U2.Q9, U2.CO, U3.COM]
    points:
      PWR: a3
      GND: a24
      CLK: k10
    parts:
      U2: dip16 m12 r180 CD4017B
      U3: dip16 w12 r180 ULN2003A
      R5: resistor q11 q8 150
      R1: resistor r10 r7 150
      R0: resistor s11 s8 150
      R2: resistor t10 t7 150
      R6: resistor u11 u8 150
      R3: resistor v10 v7 150
      R4: resistor w11 w8 150
      J1: sip8 p6
    wires:
      - GND -- f24 black
      - f24 -- x24 black
      - PWR -- m3 red
      - m3 -- p3 red
      - f15 -- f24 black
      - m12 -- m3 red
      - j12 -- j13 black
      - j13 -- f13 black
      - f13 -- f15 black
      - h15 -- h14 orange
      - h14 -- l14 orange
      - l14 -- l12 orange
      - k12 -- CLK orange
      - m15 -- m16 white
      - m16 -- q16 white
      - q16 -- q15 white
      - l15 -- l17 white
      - l17 -- r17 white
      - r17 -- r15 white
      - k15 -- k18 white
      - k18 -- s18 white
      - s18 -- s15 white
      - j15 -- j19 white
      - j19 -- t19 white
      - t19 -- t15 white
      - i15 -- i20 white
      - i20 -- u20 white
      - u20 -- u15 white
      - g15 -- g21 white
      - g21 -- v21 white
      - v21 -- v15 white
      - g12 -- g11 blue
      - g11 -- d11 blue
      - d11 -- d22 blue
      - d22 -- w22 blue
      - w22 -- w15 blue
      - p15 -- p14 black
      - p14 -- x14 black
      - x14 -- x24 black
      - q12 -- q11
      - r12 -- r10
      - s12 -- s11
      - t12 -- t10
      - u12 -- u11
      - v12 -- v10
      - w12 -- w11
      - q8 -- q6
      - r7 -- r6
      - s8 -- s6
      - t7 -- t6
      - u8 -- u6
      - v7 -- v6
      - w8 -- w6
      - p6 -- p3 red
    notes:
      - mark a3 yellow
      - mark a24 yellow
      - mark s15 yellow
      - text a3 red large bold right: V+
      - text b23 red large bold center: GND
      - text s13 red large bold center: 2+
links:
  - 発振.PWR 本体.PWR
  - 発振.GND 本体.GND
  - 発振.CLK 本体.CLK
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/09-led-illumination-4017.svg)

- **発振の基板 (1 枚め)**: 上の 17 行が 5 V、下の 5 行が GND。40106 (U1) は切り欠きを左にして f12〜l12・f9〜l9。使う回路は A (1 番、f9) → G (2 番、g9) の 1 つで、
  R<sub>F</sub> (e7〜g7) が G から A へ、C<sub>F</sub> (d9〜d6、+ が上) が A から GND へ。使わない入力 (B・C は GND、D・E・F は 5 V) は浮かせない (CMOS の入力は浮かせると電流が増え、誤動作する)
- **本体の基板 (2 枚め)**: **上の 24 行が GND、下の 3 行が 5 V** (4017 と ULN2003A を切り欠きを右にして挿したので、GND のピンが上・電源のピンが下に来る)。
  4017 (U2) は m12 を 16 番 (VDD) にして、上の段が左から 8 番 (VSS)・7 番 (Q3)・6 番 (Q7)・5 番 (Q6)・4 番 (Q2)・3 番 (Q0)・2 番 (Q1)・1 番 (Q5)、下の段が 9 番〜16 番。
  ULN2003A (U3) は w12 を 16 番 (1C) にして、上の段が 8 番 (GND)・7B〜1B、下の段が 9 番 (COM)・7C〜1C
- 4017 の出力は白い線で上へ出し、行を 1 本ずつずらして右の ULN2003A の入力へ渡す (内側から順に Q5→7B、Q1→6B、Q0→5B、Q2→4B、Q6→3B、Q3→2B)。Q4 (下の段の g12) だけは青い線で左を回って 1B へ行き、f22 で GND の線を跨ぐ (被覆線にする)
- Q7 (h15) から RESET (l12) へ、INH (j12) から VSS (f15) へは、4017 の下を通す線でつなぐ。ULN2003A の GND (p15) は ULN2003A の下の 14 行を通して右の x 列から GND へ
- ULN2003A の出力の 7 本は R (150 Ω、q〜w 列、1 本おきに高さをずらした) を通して J1 の 2〜8 番へ。J1 の 1 番は 5 V で、飾りの LED のアノードをまとめてつなぐ
- J1 の 2〜8 番は順に Q5・Q1・Q0・Q2・Q6・Q3・Q4 の LED (D5・D1・D0・D2・D6・D3・D4) のカソード。飾りの上では D0 から D6 の順に並べると、光が一方向に流れる
- 2 枚の間は 3 本の線 (5 V・GND・CLK) でつなぐ (図の左の灰色の線)
- **AD3 は確かめるときだけ挟む一時的な接続**。V+ (5 V) を本体の a3、GND を本体の a24、Scope の 1+ を発振の CLK (g6)、2+ を ULN2003A の 5B (s15、4017 の Q0) に挟む。1−・2− は GND
- 流れる電流は平均 15 mA ほど (LED 1 個の 15 mA と IC の分、LTspice)。AD3 の Supplies と perfboard の範囲に収まる。LED を増やすときは USB の 5 V にする

## 計器の設定

計器は AD3 の Scope。クロック (CLK) と 4017 の Q0 を並べ、**クロック 7 回に 1 回だけ Q0 が 1 周期ぶん High になる**のを見る。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5 V |
| CH1 (1+) | CLK (発振の g6)。2 V/div、0 V を中央の半目盛上 |
| CH2 (2+) | Q0 (本体の s15)。2 V/div、0 V を下から半目盛 |
| 時間レンジ | 200 ms/div |
| トリガ | CH2 の立ち上がり、2 V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Maximum・Minimum |
| カーソル | X1 を 40 ms (Q0 が High)、X2 を 500 ms (Q0 が Low) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 クロック (CH1) 7 回に 1 回、4017 の Q0 (CH2) が 1 周期ぶん High になる
time: 200ms/div
trigger: ch2 rising 2V at -4div
ch1: {wave: square 5.59Hz 2.5V offset 2.5V duty 47.9%, range: 2V/div, position: 0.5div}
ch2: {wave: pulse 0.797Hz 2.27V offset 2.27V duty 14.3%, range: 2V/div, position: -3.5div}
cursors: [40ms, 500ms]
measure: [freq, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/09-led-illumination-4017.svg)

- CH1 は 0〜5 V、5.6 Hz の方形波 (High 0.086 秒・Low 0.093 秒)。CH2 は 0.80 Hz (1.25 秒ごと) に 0.18 秒だけ 4.5 V
- CH2 の High が 5 V に届かないのは、ULN2003A の入力に 1.2 mA ほど流すぶん 4017 の出力の電圧が下がるため (LTspice の値 4.54 V で描いた)
- 図は理想の形で描いた。実物の 40106 の周期は品によって 2 割ほどずれる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | シュミットインバータ (6 回路) | CD40106B |
| U2 | 10 進カウンタ (ジョンソンカウンタ + 解読) | CD4017B |
| U3 | ダーリントンのドライバ (7 回路) | ULN2003A |
| R<sub>F</sub> | 抵抗 | 100 kΩ |
| C<sub>F</sub> | 電解コンデンサ | 2.2 µF・16 V |
| R0〜R6 | 抵抗 (LED の電流の制限) | 150 Ω × 7 本 |
| D0〜D6 | LED (飾りの側、J1 から線でつなぐ) | 赤 5 mm × 7 個 (色は好みで。V<sub>F</sub> の高い青・白は R を 100 Ω に) |
| J1 | ピンヘッダ | 8 ピン (1 番 = 5 V、2〜8 番 = LED のカソード) |
| — | 電源・計器 | 5 V (USB か AD3 の V+)。Analog Discovery 3 の Scope (1+ = CLK、2+ = Q0、1−・2− = GND) |

## 見るべき値

| 測る所 | 期待する値 |
| --- | --- |
| LED の点き方 | 7 個が 0.18 秒ずつ順に点き、1.25 秒で 1 周する。いつも 1 個だけ点く |
| CLK の周期 | 約 0.18 秒 (5.6 Hz)。品によって 2 割ほど動く |
| 点いている LED の電流 | 約 15 mA (R の両端の電圧 ÷ 150 Ω) |
| ULN2003A の出力 (点いている回路) | 約 0.73 V (テスター) |
| 4017 の出力の High (ULN2003A の入力) | 約 4.5 V |

## LTspice での確かめ

`sim/09-led-illumination-4017.cir` で、40106 の発振 (LTspice の SCHMITT、しきい値は典型値の 2.9 V・1.9 V)、4017 (10-19 と同じ D-FF 5 段と解読、Q7 を RESET へ)、
ULN2003A の 7 回路 (データシートの等価回路を汎用の NPN で組んだ仮定の模型) と LED を 4 秒の過渡解析で解いた。4017 の出力は 5 V の源と出力抵抗 400 Ω (データシートの 4.6 V で 1 mA から決めた仮定)。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| クロックの周期 | 0.81 × 100 kΩ × 2.2 µF ≈ 0.18 秒 | 0.179 秒 | 合う |
| LED が 1 周する時間 | 7 × 0.18 秒 ≈ 1.25 秒 | 1.255 秒 | 合う |
| 点く順 | Q0 → Q1 → … → Q6 → Q0 | D1・D2・…・D6・D0 が 0.179 秒おきに点く | 合う |
| 同時に点く LED | いつも 1 個 | 0〜2 個 (切り替わりの一瞬だけ 0 か 2) | 合う |
| LED の電流・ULN2003A の出力の電圧 | 約 15 mA・約 0.73 V | 15.2 mA・0.734 V | 合う |
| 4017 の High (ULN2003A の入力) | 約 4.5 V | 4.54 V | 合う |
| 電源の電流の平均 | 15 mA ほど | 14.9 mA | 合う |

## 出典

自作。CD4017B の出力の電流は [CD4017B のデータシート (TI)](https://www.ti.com/lit/ds/symlink/cd4017b.pdf)、ULN2003A の入力の抵抗・等価回路・定格は [ULN2003A のデータシート (TI)](https://www.ti.com/lit/ds/symlink/uln2003a.pdf) による。

参考: [Ring counter (英語版 Wikipedia。ジョンソンカウンタの節がある)](https://en.wikipedia.org/wiki/Ring_counter)
