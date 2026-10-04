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
  - text r1 small left: "箱の足の名前は 0 から数える (A0 は本文の A1、S0 は本文の和1)"
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
- 図1 の IC の箱の中の足の名前は 0 から数える流儀 (A0〜A3・B0〜B3・S0〜S3・CIN・COUT) で、
  本文の名前 (データシートと同じ 1 から数える流儀) とは番号が 1 つずれる。
  たとえば本文の A1 は箱の「05 A0」。突き合わせは PIN 番号で行う
- 答えは 10-3 の全加算器を 4 段つないだ (リプルキャリー) ものと同じ。IC の中は
  桁上げを先に計算する回路 (桁上げ先見) で速く、外に桁上げの配線も要らない

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
(C0 を GND から外して +5V につなぎ替える)。

## 出典

自作。
