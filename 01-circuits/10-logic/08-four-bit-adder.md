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
  VCC: vcc a1
  GND: ground a50
  SA1: switch a5 c5
  RA1: resistor c6 e6 10k
  GA1: ground e6
  SA2: switch a10 c10
  RA2: resistor c11 e11 10k
  GA2: ground e11
  SA3: switch a15 c15
  RA3: resistor c16 e16 10k
  GA3: ground e16
  SA4: switch a20 c20
  RA4: resistor c21 e21 10k
  GA4: ground e21
  SB1: switch a25 c25
  RB1: resistor c26 e26 10k
  GB1: ground e26
  SB2: switch a30 c30
  RB2: resistor c31 e31 10k
  GB2: ground e31
  SB3: switch a35 c35
  RB3: resistor c36 e36 10k
  GB3: ground e36
  SB4: switch a40 c40
  RB4: resistor c41 e41 10k
  GB4: ground e41
  U1: dip16 h6 CD74HC283
  GU1: ground i2
  RS1: resistor k45 m45 330
  DS1: led m45 o45 red
  GS1: ground o45
  RS2: resistor k48 m48 330
  DS2: led m48 o48 red
  GS2: ground o48
  RS3: resistor k51 m51 330
  DS3: led m51 o51 red
  GS3: ground o51
  RS4: resistor k54 m54 330
  DS4: led m54 o54 red
  GS4: ground o54
  RC4: resistor k57 m57 330
  DC4: led m57 o57 red
  GC4: ground o57
wires:
  - a1 -- a5
  - a5 -- a10
  - a10 -- a15
  - a15 -- a20
  - a20 -- a25
  - a25 -- a30
  - a30 -- a35
  - a35 -- a40
  - a1 |- U1.16
  - a50 |- U1.7
  - a50 |- U1.8
  - c5 -- c6
  - c5 -- f5
  - f5 -| U1.5
  - c10 -- c11
  - c10 -- g10
  - g10 -| U1.3
  - c15 -- c16
  - c15 -- h15
  - h15 -| U1.14
  - c20 -- c21
  - c20 -- i20
  - i20 -| U1.12
  - c25 -- c26
  - c25 -- j25
  - j25 -| U1.6
  - c30 -- c31
  - c30 -- k30
  - k30 -| U1.2
  - c35 -- c36
  - c35 -- l35
  - l35 -| U1.15
  - c40 -- c41
  - c40 -- m40
  - m40 -| U1.11
  - U1.8 |- i2
  - U1.4 -| k45
  - U1.1 -| k48
  - U1.13 -| k51
  - U1.10 -| k54
  - U1.9 -| k57
notes:
  - text b7 blue: A1
  - text b12 blue: A2
  - text b17 blue: A3
  - text b22 blue: A4
  - text b27 blue: B1
  - text b32 blue: B2
  - text b37 blue: B3
  - text b42 blue: B4
  - text j44 blue: "和1"
  - text j47 blue: "和2"
  - text j50 blue: "和3"
  - text j53 blue: "和4"
  - text j56 blue: C4
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
