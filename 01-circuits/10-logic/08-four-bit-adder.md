---
book: circuits
chapter: 10
id: 10-8
title: 4 bit 加算器 (74HC283)
tier: 100
source: 自作
---

# 10-8 4 bit 加算器 (74HC283)

10-3 の全加算器 (XOR + AND + OR の手作り) を 4 個つなぐと 4 bit の加算器になる。
それを 1 個の IC にまとめたのが 74HC283。A (4 bit) + B (4 bit) + 繰り上がり入力 C0 を、
桁上げの伝わりまで含めて 1 個で計算する。4 bit なら 0〜15 の数どうしを足せる。

## 回路図

```circuit
title: 図1 74HC283で4bit同士を足す
parts:
  U1: ic j14 CD74HC283
  VCC: vcc f14 5V
  GU1: ground m14
  GC0: ground l11a5
  VCC: vcc b3 5V
  SA1: switch b3 b6 l=$\mathrm{A1}$
  RA1: resistor b6 c6 10k l=$R_\mathrm{A1}$
  GA1: ground c6
  VCC: vcc d3 5V
  SB1: switch d3 d6 l=$\mathrm{B1}$
  RB1: resistor d6 e6 10k l=$R_\mathrm{B1}$
  GB1: ground e6
  VCC: vcc f3 5V
  SA2: switch f3 f6 l=$\mathrm{A2}$
  RA2: resistor f6 g6 10k l=$R_\mathrm{A2}$
  GA2: ground g6
  VCC: vcc h3 5V
  SB2: switch h3 h6 l=$\mathrm{B2}$
  RB2: resistor h6 i6 10k l=$R_\mathrm{B2}$
  GB2: ground i6
  VCC: vcc j3 5V
  SA3: switch j3 j6 l=$\mathrm{A3}$
  RA3: resistor j6 k6 10k l=$R_\mathrm{A3}$
  GA3: ground k6
  VCC: vcc l3 5V
  SB3: switch l3 l6 l=$\mathrm{B3}$
  RB3: resistor l6 m6 10k l=$R_\mathrm{B3}$
  GB3: ground m6
  VCC: vcc n3 5V
  SA4: switch n3 n6 l=$\mathrm{A4}$
  RA4: resistor n6 o6 10k l=$R_\mathrm{A4}$
  GA4: ground o6
  VCC: vcc p3 5V
  SB4: switch p3 p6 l=$\mathrm{B4}$
  RB4: resistor p6 q6 10k l=$R_\mathrm{B4}$
  GB4: ground q6
  RS1: resistor m26 n26 330 l=$R_\mathrm{S1}$
  DS1: led n26 o26 red l=$D_\mathrm{S1}$
  GS1: ground o26
  RS2: resistor m23a5 n23a5 330 l=$R_\mathrm{S2}$
  DS2: led n23a5 o23a5 red l=$D_\mathrm{S2}$
  GS2: ground o23a5
  RS3: resistor m21 n21 330 l=$R_\mathrm{S3}$
  DS3: led n21 o21 red l=$D_\mathrm{S3}$
  GS3: ground o21
  RS4: resistor m18a5 n18a5 330 l=$R_\mathrm{S4}$
  DS4: led n18a5 o18a5 red l=$D_\mathrm{S4}$
  GS4: ground o18a5
  RC4: resistor m16 n16 330 l=$R_\mathrm{C4}$
  DC4: led n16 o16 red l=$D_\mathrm{C4}$
  GC4: ground o16
wires:
  - U1.VCC |- f14
  - U1.GND |- m14
  # C0 (CIN) は GND に固定
  - U1.CIN -| l11a5
  - U1.A0 -| b11
  - b11 -- b6
  - U1.B0 -| d10a5
  - d10a5 -- d6
  - U1.A1 -| f10
  - f10 -- f6
  - U1.B1 -| h9a5
  - h9a5 -- h6
  - U1.A2 -| j6
  - U1.B2 -| l10
  - l10 -- l6
  - U1.A3 -| n10a5
  - n10a5 -- n6
  - U1.B3 -| p11
  - p11 -- p6
  - U1.S0 -| m26
  - U1.S1 -| m23a5
  - U1.S2 -| m21
  - U1.S3 -| m18a5
  - U1.COUT -| m16
notes:
  - text p16 blue center: C4
  - text p18a5 blue center: 和4
  - text p21 blue center: 和3
  - text p23a5 blue center: 和2
  - text p26 blue center: 和1
  - text r1 small left: "箱のピンの名前は 0 から数える (A0 は本文の A1、S0 は本文の和1)"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/08-four-bit-adder.svg)

- A1〜A4 (PIN 5・3・14・12) と B1〜B4 (PIN 6・2・15・11) がそれぞれ 4 bit の
  A・B (1 が最下位の桁)。スイッチを開けると 0、閉じると 1
- C0 (PIN 7、繰り上がり入力) は GND (0) に固定する。スイッチに替えれば
  「下の桁からの繰り上がり」を試せる (10-3 の Cin と同じ役目)
- Σ1〜Σ4 (PIN 4・1・13・10。図1 では 和1〜和4) が和、C4 (PIN 9) が最上位からの繰り上がり出力。
  Σ だけでは表せない 16 以上の答えは C4 に出る
- 図1 の IC の箱の中のピンの名前は 0 から数える流儀 (A0〜A3・B0〜B3・S0〜S3・CIN・COUT) で、
  本文の名前 (データシートと同じ 1 から数える流儀) とは番号が 1 つずれる。
  たとえば本文の A1 は箱の「05 A0」。突き合わせは PIN 番号で行う
- 答えは 10-3 の全加算器を 4 段つないだ (リプルキャリー) ものと同じ。IC の中は
  桁上げを先に計算する回路 (桁上げ先見) で速く、外に桁上げの配線も要らない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (U1 は 74HC283。入力は AD3 の DIO0〜7、出力は DIO8〜12 で読む)
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, DIO9, DIO5, DIO1, DIO6, DIO2, DIO10, DIO3, DIO7, DIO11, DIO12, DIO0, DIO4, DIO8]
  U1: dip16 @ e30 74HC283
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t2 -- -b2 black
  - a30 -- +t30 red
  - j36 -- -b36 black
  - j37 -- -b37 black
  - g32 -- g28 yellow
  - g28 -- a28 yellow
  - h31 -- h27 yellow
  - h27 -- a27 yellow
  - i30 -- i26 yellow
  - i26 -- a26 yellow
  - g34 -- g39 yellow
  - g39 -- a39 yellow
  - h35 -- h40 yellow
  - h40 -- a40 yellow
  - i33 -- i41 yellow
  - i41 -- a41 yellow
  - AD.DIO9 -- a26 green
  - AD.DIO5 -- a27 blue
  - AD.DIO1 -- a28 blue
  - AD.DIO6 -- a31 blue
  - AD.DIO2 -- a32 blue
  - AD.DIO10 -- a33 green
  - AD.DIO3 -- a34 blue
  - AD.DIO7 -- a35 blue
  - AD.DIO11 -- a36 green
  - AD.DIO12 -- a37 green
  - AD.DIO0 -- a39 blue
  - AD.DIO4 -- a40 blue
  - AD.DIO8 -- a41 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/08-four-bit-adder.svg)

- **この図は回路図の 8 本のスイッチと 5 組の LED を、AD3 の DIO に置き換えた形**。スイッチ 8 本・プルダウン 8 本・LED 5 組をブレッドボードに並べると線が込み入って追えなくなる。
  AD3 の Patterns (入力) と Logic (出力) なら、同じ入力を決まった順に正確に送れ、結果を時間軸で読める。スイッチと LED で組みたいときは、図1 のとおりにピンを結べばよい
- U1 (74HC283) は 30〜37 列。切り欠きが左で、PIN 1 (Σ2、箱では S1) が下の左端 (f 行の 30 列)、PIN 16 (VCC) が上の左端
- 電源は AD3 の Supplies。V+ (赤) を 3.3V、GND (黒) を GND へ。VCC (PIN 16) は上の + レール (3.3V) へ、GND (PIN 8) と C0 (PIN 7、箱では CIN) は下の GND へ
- AD3 の DIO0〜3 (青) が A1〜A4、DIO4〜7 (青) が B1〜B4 の入力。DIO8〜11 (緑) が Σ1〜Σ4、DIO12 (緑) が C4 の出力を読む。
  下のブロックのピン (PIN 1〜6) は黄の線で左右の空いた列へ引き、上へ渡して AD3 の DIO につなぐ
- 箱のピンの名前は 0 から数える (A0 は本文の A1) ので、AD3 の DIO0 = 本文の A1 = U1 の PIN 5。ロジックの図 (図3) のレーン名 A0〜A3 も同じ数え方
- ブレッドボードを流れる電流は、74HC283 の自身の数 µA と DIO の入力だけで、数 mA 以下。AD3 の Supplies の各レール 50mA (USB 給電で 250mW) にも、ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) にも十分収まる。
  AD3 の DIO の出力は最大 3.3V (使う機種の仕様で確かめる)。
  TI のデータシート (CD54HC283 / CD74HC283、SCHS176E) の表 5.4 では、入力が H と読める電圧 V<sub>IH</sub> の最小は、
  V<sub>CC</sub> = 4.5V で 3.15V、6V で 4.2V (25℃)。5V の欄は無いが、4.5V と 6V の間なので 3.15V より高く、
  3.3V の H では足りない。**5V の 74HC283 は、3.3V の DIO では確実に動かない**。
  そこで図2 は、AD3 の Supplies の V+ を 3.3V に下げて 74HC283 を 3.3V で動かす (HC 型の電源範囲は 2〜6V)。
  3.3V の欄も表に無いが、2V の 1.5V と 4.5V の 3.15V の間 (V<sub>CC</sub> の 0.7 倍の約 2.3V と見積もれる) なので、3.3V の DIO の H は V<sub>IH</sub> を十分に超える (見積もり)。
  74HC283 の出力 (H は約 3.3V) を DIO が読むのにも支障は無い。
  図1 のスイッチ版は、入力が電源と同じ電圧まで上がるので 5V のままでよい。

## 計器の設定

計器は AD3 の Supplies (電源)・Patterns (入力 A・B の信号源)・Logic (出力 Σ・C4 の観測)。足し算は 4 回の入力の組で答えが決まる回路で、
時間の波形そのものに意味は無いので、オシロでなくロジックの画面で、入力と出力のビットを並べて見る。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 3.3V (DIO の H が 74HC283 の V<sub>IH</sub> を超えるように。上の説明のとおり)、Master Enable を入れる |
| Patterns | DIO0〜3 (A1〜A4) と DIO4〜7 (B1〜B4) を、Custom の数値で 0.5 秒ごとに順に送る。A = 5, 9, 9、B = 3, 1, 9 |
| Logic | DIO0〜12 を表示。A (DIO0〜3)・B (DIO4〜7)・Σ (DIO8〜11) を 10 進のバスにまとめる。標本化 1kHz、時間 150ms/div (全体で 1.5 秒) |
| カーソル | X1 = 0.25 秒 (5 + 3)、X2 = 1.25 秒 (9 + 9) |

```logic
title: 図3 5+3、9+1、9+9 を順に足す — Σ は 8、10、2 で、9+9 のときだけ C4 が 1 (計算)
device: ad3
time: 150ms/div
sample: 1kHz
signals:
  CLK: dio15 clock 2Hz
  A: dio0..dio3 counter on CLK rising sequence 5 9 9
  B: dio4..dio7 counter on CLK rising sequence 3 1 9
  S: dio8..dio11 counter on CLK rising sequence 8 10 2
  C4: dio12 edges 0s=0 1s=1 1.5s=0
buses:
  A: A3..A0 dec
  B: B3..B0 dec
  Sum: S3..S0 dec
cursors: [0.25s, 1.25s]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/logic/08-four-bit-adder.svg)

- 図3 は計算で作った理想の形で、実測ではない。C0 は GND に固定なので 3 回分 (下の「見るべき値」の表の 1〜3 行目)。4 行目 (C0 = 1) は、C0 を GND から外して 電源 (+) へつなぎ替えて試す
- X1 (0.25 秒) で A = 5、B = 3、Σ = 8、C4 = 0。X2 (1.25 秒) で A = 9、B = 9、Σ = 2、C4 = 1。18 − 16 = 2 が Σ に残り、16 が C4 に出る
- レーン S0〜S3 は Σ1〜Σ4、A0〜A3 は A1〜A4 に当たる。CLK は 3 回の切り替えの区切りを見せる印で、ブレッドボードにはつながない (Patterns の内部のクロック)

## 見るべき値

スイッチは閉じると 1。Σ1〜Σ4 と C4 は LED (DS1〜DS4・DC4) が点けば 1。

| A (4bit) | B (4bit) | C0 | 和 (10進) | Σ4Σ3Σ2Σ1 | C4 |
| --- | --- | --- | --- | --- | --- |
| 0101 (5) | 0011 (3) | 0 | 8 | 1000 | 0 |
| 1001 (9) | 0001 (1) | 0 | 10 | 1010 | 0 |
| 1001 (9) | 1001 (9) | 0 | 18 | 0010 | **1** |
| 0111 (7) | 0001 (1) | 1 | 9 | 1001 | 0 |

3 行目 (9+9=18) は 4 bit (0〜15) では表せない答えで、Σ には 18−16=2 だけが
残り、あふれた 16 の分が C4 に出る。4 行目は C0 を 1 にした例で、7+1 に 1 が足されて 9 になる
(C0 を GND から外して 電源 (+) につなぎ替える)。

## 出典

自作。
