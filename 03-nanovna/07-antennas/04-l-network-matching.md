---
book: nanovna
chapter: 7
id: 7-4
title: L 型整合
tier: 50
source: 自作
board: PF
device: H4
---

# 7-4 L 型整合

コイル 1 個・コンデンサ 1 個の**L 型整合回路**で、50 Ω からずれた負荷を 50 Ω に
近づける。ここではダミー負荷 (約 25 − j15 Ω、7-3 のホイップのように少し低くて
容量性の負荷を想定) を 50 MHz で 50 Ω に合わせる。

## この実験で確かめる式

負荷 Z_L = R_L + jX_L (R_L < 50 Ω) を 50 Ω に合わせる L 型整合は、
入口にシャントのリアクタンス X_p、負荷側に直列のリアクタンス X_s を 1 個ずつ入れる。

負荷そのものは R + 直列 C で模する。R は 25 Ω が E24 に無いので **51 Ω を 2 本並列**
(25.5 Ω)、C は 50 MHz で 15 Ω 分 (計算値 212.2 pF) を E12 に丸めて 220 pF にする。
この負荷は 50 MHz で **25.5 − j14.5 Ω** になる。

これを 50 Ω に合わせる計算値 (50 MHz、連立方程式を解いた結果):
**直列 L = 125.6 nH**、**シャント C = 62.4 pF**。
E12 系列に丸めると **L = 120 nH**、**C = 68 pF**。

## 回路図

```circuit
title: 図1 L 型整合 (シャント C・直列 L) とダミー負荷
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 68p
  L1: inductor b4 b6 120n
  R1: resistor b6 b8 51
  R2: resistor d6 d8 51
  C2: capacitor b8 b10 220p
  G1: ground c2
  G2: ground d4
  G3: ground c10
wires:
  - J1.1 -- b4
  - b6 -- d6
  - b8 -- d8
  - b10 -- c10
  - J1.2 -- c2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/circuit/04-l-network-matching.svg)

- C1 (入口のシャント) と L1 (直列) が整合回路。R1・R2 (51 Ω 2 本並列で 25.5 Ω) と C2 が
  ダミー負荷 (50 MHz で 25.5 − j14.5 Ω)

## 実体配線図

```perfboard
board:
  size: 7x5cm
title: 図2 perfboard に組む (整合回路 + ダミー負荷)
parts:
  J1: sma/female-edge i1 j0
  C1: capacitor i3 k3 68p
  L1: inductor i5 i9 120n
  R1: resistor i11 i13 51
  R2: resistor k11 k13 51
  C2: capacitor i15 k15 220p
wires:
  - i1 -- i3
  - i3 -- i5
  - i9 -- i11
  - i11 -- k11
  - i13 -- i15
  - i13 -- k13
  - k3 -- l3 black
  - l3 -- l15 black
  - l15 -- k15 black
  - j0 -- j2 black
  - j2 -- l2 black
  - l2 -- l3 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/perfboard/04-l-network-matching.svg)

- R1 (i 行) と R2 (k 行) を 11 列と 13 列の線で並列にする
- C1 の下側 (k3) と C2 の下側 (k15) を l 行の GND バスでつなぐ。J1 の外皮も
  同じバスへ

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 30 MHz〜70 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S11 の Log Mag、SWR |

E12 丸め後の**見えるはずの画面**。

```vna
device: h4
sweep: 30M-70M 201
title: 図3 L 型整合後の S11・SWR (丸め後) — 50 MHz で SWR 1.12
dut:
  - shunt C 68p
  - series L 120n
  - series R 25.5
  - series C 220p
  - short
traces:
  - S11 logmag
  - S11 swr
markers:
  - 50M
  - 60M
notes:
  - text 50M 2.18: 整合なしなら 2.18 (負荷単体)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/04-l-network-matching.svg)

- 丸めた値でも 50 MHz で **S11 約 −25 dB、SWR 約 1.12**。最良点は 50.5 MHz で、
  SWR は 50 MHz とほとんど変わらない。整合していない負荷単体 (25.5 − j14.5 Ω) の
  SWR は 2.18 なので、大きく改善する

## 見るべき値

計算値。

| 状態 | 周波数 | Z (入口から見た) | SWR |
| --- | --- | --- | --- |
| 整合回路なし (負荷のみ) | 50 MHz | 25.5 − j14.5 Ω | 2.18 |
| 整合回路あり | 50 MHz | 46.3 − j4.0 Ω | 1.12 (最良点の 50.5 MHz でも 1.12) |
| 整合回路あり | 60 MHz | 56.7 − j26.0 Ω | 1.65 |

- **L 型整合は狭帯域**。50 MHz ちょうどでは良く合うが、60 MHz まで離れると
  SWR は 1.65 まで悪化する。広い帯域で使うアンテナには不向き
- 部品を E12 系列に丸めた分だけ、SWR が 1.0 まで下がらない (最良でも 1.12)。
  ぴったり合わせたいときはトリマコンデンサで微調整する

## 出典

自作。L 型整合の設計式 (連立方程式) は標準的なインピーダンス整合の教科書による。
