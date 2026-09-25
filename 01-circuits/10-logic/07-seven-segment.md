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
  VCC: vcc j5
  SWA: switch j5 l5
  RpdA: resistor l5 l3 10k
  GA: ground l3 r90
  VCC: vcc b8
  SWB: switch b8 d8
  RpdB: resistor d8 d6 10k
  GB: ground d6 r90
  VCC: vcc c5
  SWC: switch c5 e5
  RpdC: resistor e5 e3 10k
  GC: ground e3 r90
  VCC: vcc i8
  SWD: switch i8 k8
  RpdD: resistor k8 k6 10k
  GD: ground k6 r90
  U1: dip16 h13 CD4511
  VCC: vcc g10e6
  VCC: vcc f14g0
  GND: ground h11c7 r90
  GU1: ground j12
  DS1: seg7 k19
  GCOM: ground m17a5
wires:
  - d8 -- d12
  - d12 |- U1.1
  - e5 -- e11a6
  - e11a6 |- U1.2
  - k8 -- k11
  - k11 |- U1.6
  - l5 -- l11a4
  - l11a4 |- U1.7
  - U1.3 -| g10e6
  - U1.4 -| g10e6
  - U1.5 -| h11c7
  - U1.8 -| j12
  - U1.16 -| f14g0
  - U1.13 -| g15i8
  - g15i8 |- DS1.a
  - U1.12 -| h15c4
  - h15c4 |- DS1.b
  - U1.11 -| h15g0
  - h15g0 |- DS1.c
  - U1.10 -| i14a6
  - i14a6 |- DS1.d
  - U1.9 -| i14e2
  - i14e2 |- DS1.e
  - U1.14 -| n20a4
  - n20a4 -- n17a1
  - n17a1 |- DS1.g
  - U1.15 -| o20a8
  - o20a8 -- o16a7
  - o16a7 |- DS1.f
  - DS1.COM1 -| m17a5
  - DS1.COM2 -| m17a5
notes:
  - text j1a5 blue: "A (足7、LSB)"
  - text a9 blue: "B (足1)"
  - text b2a5 blue: "C (足2)"
  - text h4 blue: "D (足6、MSB)"
style:
  grid: on
  pitch: 1.2
```

- SWA〜SWD が BCD の A(LSB)〜D(MSB)。開けると 0、閉じると 1 (プルダウンで
  開いた側を 0V に決める)
- **LT̄ (足3) と BĪ (足4) は Vcc に固定** — どちらも負論理で、LT̄ を GND に
  落とすと全セグメント点灯 (ランプテスト)、BĪ を GND に落とすと全消灯になる
  検査用の足。ここでは使わないので無効化する
- **LE (足5) は GND に固定** — LE = 0 の間はラッチが透過 (今の BCD がそのまま
  表示に出る)。LE を H にすると、そのときの表示のまま固定される (ラッチ)。
  10-5 の D フリップフロップと同じ「透過・保持」の考え方
- 4511 は BCD が 10〜15 (1010〜1111) のとき、**どのセグメントも点けない**
  (無効なコードとして空白にする) — 単純なデコーダにはない、4511 の数字専用の
  性質
- 出力 (足9・10・11・12・13・14・15、a〜g) は**そのまま H で点灯**するので、
  DS1 は**コモンカソード**の 7 セグメント (共通足 COM1・COM2 を GND へ) を使う。
  コモンアノード品を使うと全部 反転して点かない

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
