---
book: circuits
chapter: 10
id: 10-7
title: 7 セグメントとデコーダ (4511)
tier: 100
source: 自作
---

# 10-7 7 セグメントとデコーダ (4511)

2 進数 4 桁 (BCD) を、7 セグメント LED が表示する「0〜9 の形」に変換する
IC が CD4511。10-4 のバイナリカウンタの出力をここへつなげば、数字が
そのまま見える表示器になる (この題ではまず、スイッチで直接 BCD を入れて
デコーダ単体の働きを確かめる)。

## 回路図

```circuit
title: 図1 CD4511でBCDを7セグメントに変換する
parts:
  VCC: vcc a11 5V
  SWB: switch a11 c11
  RpdB: resistor c11 e11 10k
  GB: ground e11
  VCC: vcc d8 5V
  SWC: switch d8 f8
  RpdC: resistor f8 h8 10k
  GC: ground h8
  VCC: vcc h11 5V
  SWD: switch h11 j11
  RpdD: resistor j11 l11 10k
  GD: ground l11
  VCC: vcc k8 5V
  SWA: switch k8 m8
  RpdA: resistor m8 o8 10k
  GA: ground o8
  U1: dip16 h16 CD4511
  VCC: vcc e12a5 5V
  VCC: vcc e18a5 5V
  GND: ground h12a5f0
  GU1: ground j14a5
  DS1: seg7 k22
  GCOM: ground m20a5
wires:
  - c11 -- c14
  - c14 |- U1.1
  - f8 -- f13a5
  - f13a5 |- U1.2
  - j11 -- j13a5
  - j13a5 |- U1.6
  - m8 -- m14
  - m14 |- U1.7
  - U1.3 -| e12a5
  - U1.4 -| e12a5
  - U1.5 -| h12a5f0
  - U1.8 -| j14a5
  - U1.16 -| e18a5
  - U1.13 -| g18i8
  - g18i8 |- DS1.a
  - U1.12 -| h18c4
  - h18c4 |- DS1.b
  - U1.11 -| h18g0
  - h18g0 |- DS1.c
  - U1.10 -| i17a6
  - i17a6 |- DS1.d
  - U1.9 -| i17e2
  - i17e2 |- DS1.e
  - U1.14 -| n23a4
  - n23a4 -- n20a1
  - n20a1 |- DS1.g
  - U1.15 -| o23a8
  - o23a8 -- o19a7
  - o19a7 |- DS1.f
  - DS1.COM1 -| m20a5
  - DS1.COM2 -| m20a5
notes:
  - text b12a5h5 small blue: "B (PIN 1)"
  - text e10h5 small blue: "C (PIN 2)"
  - text i11a8h5 small blue: "D (PIN 6)"
  - text l12h5 small blue: "A (PIN 7)"
  - text p1 small left: "VDD は PIN 16 (+5V)、VSS は PIN 8 (GND)"
  - text q1 small left: "LT (PIN 3)・BI (PIN 4) は +5V、LE (PIN 5) は GND に固定"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/07-seven-segment.svg)

- SWA〜SWD が BCD の A(LSB)〜D(MSB)。開けると 0、閉じると 1 (プルダウンで
  開いた側を 0V に決める)
- **LT̄ (PIN 3) と BĪ (PIN 4) は Vcc に固定** — どちらも負論理で、LT̄ を GND に
  落とすと全セグメント点灯 (ランプテスト)、BĪ を GND に落とすと全消灯になる
  検査用の足。ここでは使わないので無効化する
- **LE (PIN 5) は GND に固定** — LE = 0 の間はラッチが透過 (今の BCD がそのまま
  表示に出る)。LE を H にすると、そのときの表示のまま固定される (ラッチ)。
  10-5 の D フリップフロップと同じ「透過・保持」の考え方
- 4511 は BCD が 10〜15 (1010〜1111) のとき、**どのセグメントも点けない**
  (無効なコードとして空白にする) — 単純なデコーダにはない、4511 の数字専用の
  性質
- 出力 (PIN 9・10・11・12・13・14・15、a〜g) は**そのまま H で点灯**するので、
  DS1 は**コモンカソード**の 7 セグメント (共通足 COM1・COM2 を GND へ) を使う。
  コモンアノード品を使うと全部反転して点かない

## 見るべき値

| D C B A | 10進 | 表示 |
| --- | --- | --- |
| 0 0 0 0 | 0 | **0** |
| 0 0 0 1 | 1 | **1** |
| 0 1 0 0 | 4 | **4** |
| 1 0 0 1 | 9 | **9** |
| 1 0 1 0 | 10 | **空白** (無効なコード) |
| 1 1 1 1 | 15 | **空白** (無効なコード) |

10 進で 9 まではふつうの数字の形、10 以上はセグメントが全部消える。
LE を一度 H にしてから BCD を変えると、表示は変わらないままになる
(直前の値を保持している)。

## 出典

自作。
