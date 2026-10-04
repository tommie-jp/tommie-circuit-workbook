---
book: nanovna
chapter: 5
id: 5-8
title: λ/4 変成器
tier: 100
source: 自作
board: —
device: H4
---

# 5-8 λ/4 変成器

長さがちょうど λ/4 の線路は、先端の負荷 Z_L を入口で **Z₀² / Z_L** に見せる
(5-7 で開放と短絡が入れ替わったのと同じ性質)。これを使うと、部品を足さずに
ケーブル 1 本で 50 Ω と違う負荷を整合できる。100 Ω の負荷を、**75 Ω の
テレビ用同軸 (3C-2V) を 50 cm** 挟んで 50 Ω 系に合わせる。

## この実験で確かめる式

入口の Z は **Z_in = Z₀² / Z_L** (長さ λ/4 の周波数で)。100 Ω を 50 Ω に
ぴったり合わせる Z₀ は √(50 × 100) = 70.7 Ω だが、そんな同軸は売っていないので
手に入る 75 Ω で代える。

- Z_in = 75² / 100 = **56.25 Ω** → SWR = 56.25 / 50 = **1.125**
- 長さ λ/4 になる周波数: f₀ = vf·c / (4L) = 0.67 × 2.998×10⁸ / (4 × 0.5 m) ≈ **100.4 MHz**
  (3C-2V は充実ポリエチレンで vf ≈ 0.67 と仮定。5-2 の方法で先に測っておく)

## 回路図

```circuit
title: 図1 100 Ω の負荷を 75 Ω・50 cm の同軸で CH0 へ
parts:
  J1: sma b2 mirror CH0
  TL1: tline b3 b6 75 l=$\mathrm{TL}_1$
  R1: resistor b7 d7 100
  G1: ground c2
  G2: ground d7
wires:
  - J1.1 -- b3
  - b6 -- b7
  - J1.2 -- c2
notes:
  - text b4h5 center: 3C-2V・50 cm
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/08-quarter-wave-transformer.svg)

| 部品 | 値 | メモ |
| --- | --- | --- |
| TL1 | 3C-2V (75 Ω) 50 cm | 手前は F 型プラグ + F-SMA 変換で CH0 へ |
| R1 | 100 Ω (1/4 W 金属皮膜) | 先端の芯線と外皮の間に、足を 2〜3 mm に切って半田付け |

- 100 Ω だけを CH0 に直につなぐと SWR = 2 (5-5 の図3)。それを TL1 で下げる
- F-SMA 変換の数 cm も線路の一部になり、λ/4 の周波数を少し下げる
  (見るべき値の表より数 MHz 低く出る目安)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の 100 Ω の負荷 (端面 SMA の先に付ける)
points:
  GND: l2
parts:
  J2: sma/female-edge i1 h0 j0
  R1: resistor i5 l5 100
wires:
  - i1 -- i5
  - l5 -- GND black
  - j0 -- j2 black
  - j2 -- GND black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/perfboard/08-quarter-wave-transformer.svg)

J2 に 75 Ω・50 cm の同軸 (TL1) をつなぎ、TL1 の反対側を NanoVNA の CH0 につなぐ。TL1 は図の部品ではなくケーブルで、基板に付けるのは R1 (100 Ω) の負荷だけ。
板に流れる電流は、NanoVNA の出力が 0 dBm 以下なので数 mA 以下で、板の範囲 (1 穴 200 mA) に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10 MHz〜250 MHz (f₀ とその 2 倍を入れる) |
| 点数 | 241 (1 MHz おき) |
| 校正 | SOLT。CH0 のケーブルの先 (F-SMA 変換を挿す手前) で Open / Short / Load |
| 表示 | S11 の SWR と Smith |

見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 10M-250M 241
title: 図3 λ/4 (100.4 MHz) で SWR 1.125 まで下がる。2 倍では 2 に戻る
dut:
  - line 75 50cm vf 0.67
  - series R 100
  - short
traces:
  - S11 swr
  - S11 smith
markers:
  - 10M
  - 62.4M
  - 100.43M
  - 200.87M
notes:
  - band 62.4M 138.5M: SWR 1.5 以下
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/08-quarter-wave-transformer.svg)

## 見るべき値

計算値 (損失の無い理想の線路)。

| マーカー | 周波数 | 線路の長さ | Z_in | SWR |
| --- | --- | --- | --- | --- |
| 1 | 10 MHz | λ/40 (短い) | 98.1 − j8.8 Ω | 1.98 (ほぼ 100 Ω のまま) |
| 2 | 62.4 MHz | 0.16λ | 65.2 − j17.7 Ω | 1.50 (帯の下の端) |
| 3 | 100.43 MHz | **λ/4** | **56.25 Ω** | **1.125** (画面は 1.13) |
| 4 | 200.87 MHz | λ/2 | 100 Ω | 2.00 (先端がそのまま見える) |

- SWR 1.5 以下の帯は **62.4〜138.5 MHz** (中心の ±38 %)。λ/4 変成器は
  狭帯域の整合ではなく、かなり広い範囲で効く
- 仮に 70.7 Ω の線路があれば f₀ で SWR = 1.00 になり、帯は 61.1〜139.8 MHz。
  **75 Ω で代えた損は f₀ の SWR が 1.125 に上がることだけ**で、帯の広さは
  ほとんど変わらない

分かること:

- **Smith チャートでは、Z は 100 Ω の点 (中心の右) から回り始め、λ/4 で
  56.25 Ω (中心のすぐ右)、λ/2 で 100 Ω に戻る。** 100 Ω と 56.25 Ω を直径の
  両端とする円を、周波数とともに 1 周する — 線路は長さに応じて Z を回す
- 長さの間違いに強い: λ/4 の周波数が ±30 % ずれても SWR は 1.5 に収まる。
  だから vf の見込み違い (0.66 と 0.67) くらいでは困らない
- 同じ考えで、λ/4 の 75 Ω 同軸を 2 本並列にすると 37.5 Ω の線路になり、
  25 Ω (50 Ω のアンテナ 2 つを並列にした所) を 56 Ω まで上げられる。
  アンテナを 2 本並べるときの給電線の組み方の 1 つ

## 出典

自作。
