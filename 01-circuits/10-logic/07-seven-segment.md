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
  VCC: vcc b2
  SWA: switch b5 c5
  RpdA: resistor c5 d5 10k
  GA: ground d5
  SWB: switch e5 f5
  RpdB: resistor f5 g5 10k
  GB: ground g5
  SWC: switch h5 i5
  RpdC: resistor i5 j5 10k
  GC: ground j5
  SWD: switch k5 l5
  RpdD: resistor l5 m5 10k
  GD: ground m5
  U1: ic g14 CD4511
  VCC: vcc c13a5
  GU1: ground j14
  DS1: seg7 g20h0e5 5161AS
  GCOM: ground j18a5
wires:
  - b2 -- k2
  - b2 -- b5
  - e2 -- e5
  - h2 -- h5
  - k2 -- k5
  - c5 -- c11a5
  - c11a5 |- U1.INA
  - f5 -- f11
  - f11 |- U1.INB
  - i5 -- i11
  - i11 |- U1.INC
  - l5 -- l11a5
  - l11a5 |- U1.IND
  - U1.VDD |- c13a5
  - U1.LT |- d14
  - d14 -- d13a5
  - U1.BL |- d14a5
  - d14a5 -- d14
  - U1.VSS |- j14
  - U1.LE/STROBE |- j14a5
  - j14a5 -- j14
  - U1.Oa -- DS1.a
  - U1.Ob -- DS1.b
  - U1.Oc -- DS1.c
  - U1.Od -- DS1.d
  - U1.Oe -- DS1.e
  - U1.Of -- DS1.f
  - U1.Og -- DS1.g
  - DS1.COM1 -| j18a5
  - DS1.COM2 -| j18a5
notes:
  - text b7g0 blue: "A (足7、LSB)"
  - text e7g0 blue: "B (足1)"
  - text h7g0 blue: "C (足2)"
  - text k7g0 blue: "D (足6、MSB)"
style:
  grid: on
  pitch: 1.0
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/07-seven-segment.svg)

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
