---
book: nanovna
chapter: 3
id: 3-6
title: 治具の限界周波数 — どこまで信じるか
tier: 50
source: 自作
board: PF
device: H4
---

# 3-6 治具の限界周波数 — どこまで信じるか

3-3 のスルー治具は理想では 0 Ω だが、実物には**中心導体をつなぐ線の
長さぶんのインダクタンス**が残る。周波数を上げるとこのインダクタンスの
リアクタンスが無視できなくなり、「治具のせいで DUT の値がずれて見える」
限界が来る。その限界を見積もり、**線の長さでどれだけ変わるか**を
3-3 の板と、線を詰めた板で比べる。

## 回路図

3-3 と同じ形のスルー治具。中心導体をつなぐ線の長さがそのまま寄生インダクタンス
になる。

```circuit
title: 図1 スルー治具 (3-3 と同じ形)
parts:
  J1: sma b2 mirror
  J2: sma b8
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b8
  - J2.1 -- b8
  - J1.2 -- c2
  - J2.2 -- c8
notes:
  - text a2 center: CH0
  - text a8 center: CH1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/06-fixture-limit.svg)

## 実体配線図

```perfboard
board:
  size: 4x8
  slots: on
title: 図2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e4 f5
wires:
  - e1 -- e4
  - f0 -- f5 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/06-fixture-limit.svg)

図 2 は、3-3 の板の SMA を寄せて**中心導体の間を 3 穴 (7.6 mm) に詰めた**スルー
(部品面から見た図)。GND は凹の腕どうし (f0〜f5) を信号の線のすぐ隣でつなぐ。

- J1 から J2 までの e 行の線が長いほど、寄生インダクタンスが大きくなる。
  4-7 の「リード線 1 cm で約 7 nH」で見積もると、次のとおり (目安)

| 板 | 中心導体の間 | 線のインダクタンス | S11 が −20 dB になる周波数 |
| --- | --- | --- | --- |
| 3-3 の板 (e1〜e16) | 15 穴 (3.8 cm) | 約 27 nH | 約 60 MHz |
| 図 2 の板 (e1〜e4) | 3 穴 (7.6 mm) | 約 5 nH | 約 320 MHz |

- 3-3 の板は線が長く、**60 MHz あたりで −20 dB の目安を超える**。perfboard の治具で
  300 MHz まで測るには、図 2 のように SMA を寄せて**中心導体の間を 1 cm 以下**にする。
  GND の線 (f0〜f5) も信号の線のすぐ隣に通し、帰り道を短くする
- 以下の模型は図 2 の板の 5 nH で描く

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜320 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag、S11 の Log Mag |

0 Ω のスルーに寄生インダクタンス 5 nH を直列に足した模型。

```vna
device: h4
sweep: 1M-320M 101
title: 図3 5 nH が残るスルー — S11 は 320 MHz で −20 dB
dut:
  - series R 0 esl 5n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 100M
  - 320M
notes:
  - text 100M -60dB: S11 が −20 dB を超える所が限界の目安
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/06-fixture-limit.svg)

## 見るべき値

| 周波数 | S21 (計算値) | S11 (計算値) |
| --- | --- | --- |
| 100 MHz | 0.00 dB | −30.06 dB |
| 320 MHz | −0.04 dB | −20.00 dB |

- **S21 はほとんど動かない。** 5 nH のリアクタンスは 320 MHz でも 10 Ω
  程度で、通り抜ける量にはほぼ効かない
- **S11 のほうがずっと敏感。** 100 MHz では −30 dB (十分小さい) だが、
  320 MHz では −20 dB まで悪化する。**S11 が −20 dB (VSWR 約 1.22) を
  超えて悪化し始める周波数が、この治具を信じられる目安**になる
- 3-1・3-2 で 100 Ω や大きな値の部品を測るときも、この治具そのものの
  限界より高い周波数では**部品の値と治具の寄生分が区別できなくなる**。
  3-1・3-2 の板も、SMA から部品までの線を短くするほど限界が上がる

**治具を作ったら、まず DUT 無し (このスルー) を測って自分の治具の限界を
知っておく。** 線を短くするほど寄生インダクタンスが減り、限界周波数は
上がる (5 nH → 2.5 nH なら、同じ −20 dB の目安はおよそ 2 倍の周波数まで
伸びる)。

## 出典

自作。
