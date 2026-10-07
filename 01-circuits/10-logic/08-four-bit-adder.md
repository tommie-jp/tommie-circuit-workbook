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
  U1: ic 14,10 CD74HC283
  VCC: vcc 14,6 5V
  GU1: ground 14,13
  GC0: ground 11.5,12
  VCC: vcc 3,2 5V
  SA1: switch 3,2 6,2 l=$\mathrm{A1}$
  RA1: resistor 6,2 6,3 10k l=$R_\mathrm{A1}$
  GA1: ground 6,3
  VCC: vcc 3,4 5V
  SB1: switch 3,4 6,4 l=$\mathrm{B1}$
  RB1: resistor 6,4 6,5 10k l=$R_\mathrm{B1}$
  GB1: ground 6,5
  VCC: vcc 3,6 5V
  SA2: switch 3,6 6,6 l=$\mathrm{A2}$
  RA2: resistor 6,6 6,7 10k l=$R_\mathrm{A2}$
  GA2: ground 6,7
  VCC: vcc 3,8 5V
  SB2: switch 3,8 6,8 l=$\mathrm{B2}$
  RB2: resistor 6,8 6,9 10k l=$R_\mathrm{B2}$
  GB2: ground 6,9
  VCC: vcc 3,10 5V
  SA3: switch 3,10 6,10 l=$\mathrm{A3}$
  RA3: resistor 6,10 6,11 10k l=$R_\mathrm{A3}$
  GA3: ground 6,11
  VCC: vcc 3,12 5V
  SB3: switch 3,12 6,12 l=$\mathrm{B3}$
  RB3: resistor 6,12 6,13 10k l=$R_\mathrm{B3}$
  GB3: ground 6,13
  VCC: vcc 3,14 5V
  SA4: switch 3,14 6,14 l=$\mathrm{A4}$
  RA4: resistor 6,14 6,15 10k l=$R_\mathrm{A4}$
  GA4: ground 6,15
  VCC: vcc 3,16 5V
  SB4: switch 3,16 6,16 l=$\mathrm{B4}$
  RB4: resistor 6,16 6,17 10k l=$R_\mathrm{B4}$
  GB4: ground 6,17
  RS1: resistor 26,13 26,14 330 l=$R_\mathrm{S1}$
  DS1: led 26,14 26,15 red l=$D_\mathrm{S1}$
  GS1: ground 26,15
  RS2: resistor 23.5,13 23.5,14 330 l=$R_\mathrm{S2}$
  DS2: led 23.5,14 23.5,15 red l=$D_\mathrm{S2}$
  GS2: ground 23.5,15
  RS3: resistor 21,13 21,14 330 l=$R_\mathrm{S3}$
  DS3: led 21,14 21,15 red l=$D_\mathrm{S3}$
  GS3: ground 21,15
  RS4: resistor 18.5,13 18.5,14 330 l=$R_\mathrm{S4}$
  DS4: led 18.5,14 18.5,15 red l=$D_\mathrm{S4}$
  GS4: ground 18.5,15
  RC4: resistor 16,13 16,14 330 l=$R_\mathrm{C4}$
  DC4: led 16,14 16,15 red l=$D_\mathrm{C4}$
  GC4: ground 16,15
wires:
  - U1.VCC |- 14,6
  - U1.GND |- 14,13
  # C0 (CIN) は GND に固定
  - U1.CIN -| 11.5,12
  - U1.A0 -| 11,2
  - 11,2 -- 6,2
  - U1.B0 -| 10.5,4
  - 10.5,4 -- 6,4
  - U1.A1 -| 10,6
  - 10,6 -- 6,6
  - U1.B1 -| 9.5,8
  - 9.5,8 -- 6,8
  - U1.A2 -| 6,10
  - U1.B2 -| 10,12
  - 10,12 -- 6,12
  - U1.A3 -| 10.5,14
  - 10.5,14 -- 6,14
  - U1.B3 -| 11,16
  - 11,16 -- 6,16
  - U1.S0 -| 26,13
  - U1.S1 -| 23.5,13
  - U1.S2 -| 21,13
  - U1.S3 -| 18.5,13
  - U1.COUT -| 16,13
notes:
  - text 16,16 blue center: C4
  - text 18.5,16 blue center: 和4
  - text 21,16 blue center: 和3
  - text 23.5,16 blue center: 和2
  - text 26,16 blue center: 和1
  - text 1,18 small left: "箱のピンの名前は 0 から数える (A0 は本文の A1、S0 は本文の和1)"
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
