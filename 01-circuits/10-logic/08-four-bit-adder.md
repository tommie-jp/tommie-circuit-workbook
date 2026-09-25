---
book: circuits
chapter: 10
id: 10-8
title: 4 bit 加算器 (74HC283)
tier: 100
source: 自作
---

# 10-8 4 bit 加算器 (74HC283)

10-3 の全加算器 (XOR + AND + OR の手作り) を 4 個つなげば 4 bit の加算器に
なるが、それを 1 個の IC にまとめたのが 74HC283。**A (4 bit) + B (4 bit) +
繰り上がり入力 C0** を、桁上げの伝わりまで含めて 1 個で計算する。

## 回路図

```circuit
title: 図1 74HC283で4bit同士を足す
parts:
  VCC: vcc j7
  SA1: switch j7 l7
  RA1: resistor l7 l5 10k
  GA1: ground l5 r90
  VCC: vcc d4
  SA2: switch d4 f4
  RA2: resistor f4 f2 10k
  GA2: ground f2 r90
  VCC: vcc d23
  SA3: switch d23 f23
  RA3: resistor f23 f25 10k
  GA3: ground f25 r270
  VCC: vcc j19
  SA4: switch j19 l19
  RA4: resistor l19 l21 10k
  GA4: ground l21 r270
  VCC: vcc k4
  SB1: switch k4 m4
  RB1: resistor m4 m2 10k
  GB1: ground m2 r90
  VCC: vcc c7
  SB2: switch c7 e7
  RB2: resistor e7 e5 10k
  GB2: ground e5 r90
  VCC: vcc c19
  SB3: switch c19 e19
  RB3: resistor e19 e21 10k
  GB3: ground e21 r270
  VCC: vcc k23
  SB4: switch k23 m23
  RB4: resistor m23 m25 10k
  GB4: ground m25 r270
  U1: dip16 h13 CD74HC283
  VCC: vcc f14g0
  GND: ground i12 r90
  GU1: ground j11a6
  RS1: resistor g9i0 h9i0 330
  DS1: led h9i0 i9i0 red
  GS1: ground i9i0
  RS2: resistor b13a5 c13a5 330
  DS2: led c13a5 d13a5 red
  GS2: ground d13a5
  RS3: resistor g17i0 h17i0 330
  DS3: led h17i0 i17i0 red
  GS3: ground i17i0
  RS4: resistor n17 o17 330
  DS4: led o17 p17 red
  GS4: ground p17
  RC4: resistor n11 o11 330
  DC4: led o11 p11 red
  GC4: ground p11
wires:
  - U1.16 -| f14g0
  - U1.7 -| i12
  - U1.8 -| j11a6
  - f4 -- f11a2
  - f11a2 |- U1.3
  - e7 -- e11a6
  - e11a6 |- U1.2
  - e19 -- e14a8
  - e14a8 |- U1.15
  - f23 -- f15a2
  - f15a2 |- U1.14
  - l7 -- l10a8
  - l10a8 |- U1.5
  - m4 -- m11a2
  - m11a2 |- U1.6
  - l19 -- l15a2
  - l15a2 |- U1.12
  - m23 -- m14a8
  - m14a8 |- U1.11
  - U1.4 -| g9i0
  - U1.13 -| g17i0
  - U1.1 -| b12
  - b12 -- b13a5
  - U1.9 -| n14
  - n14 -- n11
  - U1.10 -| n14a4
  - n14a4 -- n17
notes:
  - text j4a5 blue: A1
  - text d1a5 blue: A2
  - text d23a6 blue: A3
  - text j19a6 blue: A4
  - text k1a5 blue: B1
  - text c4a5 blue: B2
  - text c19a6 blue: B3
  - text k23a6 blue: B4
  - text i7a5 blue: "和1"
  - text b14a6 blue: "和2"
  - text i17a6 blue: "和3"
  - text p17a6 blue: "和4"
  - text p9a5 blue: C4
style:
  grid: on
  pitch: 1.2
```

- A1〜A4 (足5・3・14・12) と B1〜B4 (足6・2・15・11) がそれぞれ 4 bit の
  A・B。開けると 0、閉じると 1
- **C0 (足7、繰り上がり入力) は GND (0) に固定**。スイッチに替えれば
  「下の桁からの繰り上がり」を試せる (10-3 の Cin と同じ役目)
- Σ1〜Σ4 (足4・1・13・10) が和、**C4 (足9) が最上位からの繰り上がり出力**。
  Σ だけでは表せない 16 以上の答えはここに出る
- 内部は 10-3 の全加算器を 4 段リプルキャリーでつないだのと同じ働きだが、
  1 個の IC で桁上げの配線が要らない

## 見るべき値

| A (4bit) | B (4bit) | C0 | 和 (10進) | Σ4Σ3Σ2Σ1 | C4 |
| --- | --- | --- | --- | --- | --- |
| 0101 (5) | 0011 (3) | 0 | 8 | 1000 | 0 |
| 1001 (9) | 0001 (1) | 0 | 10 | 1010 | 0 |
| 1001 (9) | 1001 (9) | 0 | 18 | 0010 | **1** |
| 0111 (7) | 0001 (1) | 1 | 9 | 1001 | 0 |

3 行目 (9+9=18) は 4 bit (0〜15) では表せない答えで、**Σ には 18−16=2 だけが
残り、あふれた分が C4 に出る**。C0 を 1 にすると、A・B が同じでも和が 1 だけ
増える (4 行目)。

## 出典

自作。
