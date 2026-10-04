---
book: circuits
chapter: 10
id: 10-7
title: 7 セグメントとデコーダ (4511)
tier: 100
source: 自作
---

# 10-7 7 セグメントとデコーダ (4511)

7 セグメント LED は、8 の字に並んだ 7 本の棒 (セグメント a〜g) の LED を点け分けて
数字を表す表示器。2 進数のままでは人が読みにくいので、数字の形に直す IC (デコーダ) を
間に入れる。

CD4511 は、2 進数 4 桁で表した 0〜9 (BCD: 10 進の 1 桁を 2 進数 4 桁で表す形) を、
7 セグメントの「0〜9 の形」に変換する IC。10-4 のバイナリカウンタの出力をここへ
つなげば、数字がそのまま見える表示器になる。この題ではまず、スイッチで直接 BCD を
入れてデコーダ単体の働きを確かめる。

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
  GND: ground h13f0
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
  - U1.5 -| h13f0
  - U1.8 -| j14a5
  - U1.16 -| e18a5
  - U1.13 -| g19i2
  - g19i2 |- DS1.a
  - U1.12 -| h18c8
  - h18c8 |- DS1.b
  - U1.11 -| h18g4
  - h18g4 |- DS1.c
  - U1.10 -| i18
  - i18 |- DS1.d
  - U1.9 -| i17e6
  - i17e6 |- DS1.e
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
  - text f10d5 small blue: "C (PIN 2)"
  - text j11d8 small blue: "D (PIN 6)"
  - text l12h5 small blue: "A (PIN 7)"
  - text p1 small left: "VDD は PIN 16 (+5V)、VSS は PIN 8 (GND)"
  - text q1 small left: "LT (PIN 3)・BI (PIN 4) は +5V、LE (PIN 5) は GND に固定"
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/07-seven-segment.svg)

- SWA〜SWD が BCD の A (LSB、1 の位)〜D (MSB、8 の位)。開けると 0、閉じると 1
  (プルダウン抵抗が、開いたときの入力を 0V に決める)
- LT̄ (PIN 3) と BĪ (PIN 4) は +5V に固定する。どちらも負論理 (10-2) の検査用の足で、
  LT̄ を GND に落とすと全セグメント点灯 (ランプテスト)、BĪ を GND に落とすと全消灯になる。
  ここでは使わないので無効にする
- LE (PIN 5) は GND に固定する。LE = 0 の間は、今の BCD がそのまま表示に出る (素通し)。
  LE を H にすると、そのときの表示のまま固定される (ラッチ、10-2)。10-5 の D フリップ
  フロップがクロックの立ち上がりの瞬間にだけ値を取り込むのに対し、LE は L の間ずっと
  素通しにする点が違う
- 4511 は BCD が 10〜15 (1010〜1111) のとき、どのセグメントも点けない
  (無効なコードとして空白にする)。数字の表示に絞った 4511 ならではの性質
- 出力 (PIN 9〜15、セグメント a〜g) は H で点灯させる向きに電流を出す。そのため DS1 は
  コモンカソード (全セグメントの LED のカソードを共通の足 COM1・COM2 にまとめた品) を使い、
  COM を GND へつなぐ。コモンアノード品 (アノードが共通) では向きが逆で点かない

## 見るべき値

| D C B A | 10進 | 表示 |
| --- | --- | --- |
| 0 0 0 0 | 0 | **0** |
| 0 0 0 1 | 1 | **1** |
| 0 1 0 0 | 4 | **4** |
| 1 0 0 1 | 9 | **9** |
| 1 0 1 0 | 10 | **空白** (無効なコード) |
| 1 1 1 1 | 15 | **空白** (無効なコード) |

スイッチは閉じると 1。10 進で 9 まではふつうの数字の形、10 以上はセグメントが全部消える。
LE を GND から外して +5V につなぎ替えてから BCD を変えると、表示は変わらないままになる
(直前の値を保持している)。

## 出典

自作。
