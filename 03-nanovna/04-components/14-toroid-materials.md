---
book: nanovna
chapter: 4
id: 4-14
title: トロイダルコアの材質比較
tier: 100
source: 自作
board: PF
device: H4
---

# 4-14 トロイダルコアの材質比較

同じ大きさ・同じ巻き数でも、トロイダルコアの**材質**でインダクタンスは 100 倍近く
変わり、使える周波数も変わる。外径 9.5 mm の 3 種類 — フェライト **#43**・フェライト
**#61**・鉄粉 (カーボニル鉄) **#2** — に同じ 10 回を巻き、3-1 の直列治具で R と X を
読み比べる。

## 回路図

4-4 と同じく、3-1 の直列治具に挿して CH1 側を Short で終わらせ、1 端子の Z として測る。

```circuit
title: 図1 直列治具にトロイダルコイルを挿す (CH1 側は Short)
parts:
  J1: sma b2 mirror CH0
  L1: inductor b4 b6
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
notes:
  - text a5f0 center: 10 回巻き
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/14-toroid-materials.svg)

| コア | 材質 | 初透磁率 µi | A<sub>L</sub> (メーカーの表) | 10 回の L (計算値) | 使いどころの目安 |
| --- | --- | --- | --- | --- | --- |
| FT37-43 | フェライト #43 | 800 | 350 nH/回² | 35 µH | 広帯域トランス・ノイズ止め (損失が大きい) |
| FT37-61 | フェライト #61 | 125 | 55 nH/回² | 5.5 µH | 数 MHz〜十数 MHz のコイル・トランス |
| T37-2 | 鉄粉 #2 | 10 | 4.0 nH/回² | 0.40 µH | 1〜30 MHz の同調コイル (Q が高い) |

L = A<sub>L</sub> × 巻き数²。巻線はポリウレタン線 0.4 mm を 10 回 (コアの穴を 10 回通す)。
手巻き。

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 直列治具にトロイダルコイル (3-1 と同じユニバーサル基板)
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  L1: inductor f10 i10 巻線10回
wires:
  - a10 -- f10
  - i10 -- x10
  - 09 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/14-toroid-materials.svg)

- 図の L1 は軸物のコイルの形で描かれる (フェンスにトロイダルの形が無い)。実物はコアを
  ユニバーサル基板に寝かせ、巻線の両端を i6 と i9 に挿す
- 3 つのコアで巻線の引き出しの長さをそろえる。引き出しの長さの違いは、そのまま
  インダクタンスの違いになる (4-7)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜30 MHz |
| 点数 | 301 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の \|Z\| (対数)。CH1 側の SMA に Short を挿して 1 端子にする |
| 模型の仮定 | L は A<sub>L</sub> から。巻線の抵抗 0.1 Ω と巻線の間の容量 2 pF は 3 つとも同じと見積もる。**コアの損失は入れない** |

3 つを同じ設定で並べる。

```vna
device: h4
sweep: 100k-30M 301
title: 図3 FT37-43 (35 µH) — 19 MHz で自己共振
dut:
  - series L 35u esr 0.1 cp 2p
  - short
traces:
  - S11 z
markers:
  - 1M
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/14-toroid-materials-1.svg)

```vna
device: h4
sweep: 100k-30M 301
title: 図4 FT37-61 (5.5 µH) — 1 MHz の |Z| は #43 の約 1/6
dut:
  - series L 5.5u esr 0.1 cp 2p
  - short
traces:
  - S11 z
markers:
  - 1M
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/14-toroid-materials-2.svg)

```vna
device: h4
sweep: 100k-30M 301
title: 図5 T37-2 (0.40 µH) — 1 MHz の |Z| は #43 の約 1/90
dut:
  - series L 0.4u esr 0.1 cp 2p
  - short
traces:
  - S11 z
markers:
  - 1M
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/14-toroid-materials-3.svg)

## 見るべき値

計算値 (模型から)。

| コア | 1 MHz の \|Z\| | 10 MHz の \|Z\| | 自己共振 (2 pF と) |
| --- | --- | --- | --- |
| FT37-43 | 220.5 Ω | 3.04 kΩ | 19.0 MHz |
| FT37-61 | 34.6 Ω | 361.3 Ω | 48.0 MHz |
| T37-2 | 2.5 Ω | 25.2 Ω | 178 MHz (掃引の外) |

分かること:

- **同じ 10 回でも L は 35 µH と 0.40 µH で約 90 倍違う** (µi の比 80 倍に近い)。小さい L で済む高い周波数の
  同調コイルは鉄粉、大きな L が要る広帯域トランス (4-10) やノイズ止めはフェライト
- **実物の R は模型とまるで違う。** #43 は数 MHz から上でコアの損失が大きくなり、
  R が X に並ぶほど増える (4-5 のフェライトビーズと同じ仕組み)。#61 はそれより高い
  周波数まで R が小さく、#2 は 30 MHz まで R が小さいまま。**R を読み比べるのがこの題の
  本題** — 破線 (損失なし) からのずれが材質の損失
- Q = X / R で比べると、同調コイルに鉄粉を使う理由が数で分かる。表に R も書き足して
  Q を出す

## 出典

自作。A<sub>L</sub> と初透磁率はトロイダルコアのメーカーの表 (フェライト #43・#61、
鉄粉 #2、外径 0.375 インチ) の値。使いどころは同じ表の推奨周波数を目安にまとめた。
