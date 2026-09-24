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
近づける。ここではダミー負荷 (25 − j15 Ω、7-3 のホイップのように少し低くて
容量性の負荷を想定) を 50 MHz で 50 Ω に合わせる。

## この実験で確かめる式

負荷 Z_L = R_L + jX_L (R_L < 50 Ω) を 50 Ω に合わせる L 型整合は、
入口にシャントのリアクタンス X_p、負荷側に直列のリアクタンス X_s を 1 個ずつ入れる。

R_L = 25 Ω、X_L = −15 Ω (25 − j15 Ω) を 50 Ω に合わせる計算値
(50 MHz、連立方程式を解いた結果): **直列 L = 127.3 nH**、**シャント C = 63.7 pF**。
E12/E24 系列に丸めると **L = 130 nH**、**C = 62 pF**。

負荷そのものは R = 25 Ω + 直列 C (50 MHz で 15 Ω 分、計算値 212.2 pF → 丸めて 220 pF)
で模する。

## 回路図

```circuit
title: 図1 L 型整合 (シャント C・直列 L) とダミー負荷
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 62p
  L1: inductor b4 b6 130n
  R1: resistor b6 b8 25
  C2: capacitor b8 b10 220p
  G1: ground c2
  G2: ground d4
  G3: ground c10
wires:
  - J1.1 -- b4
  - b10 -- c10
  - J1.2 -- c2
```

- C1 (入口のシャント) と L1 (直列) が整合回路。R1・C2 がダミー負荷
  (25 − j15 Ω を模したもの)

## 実体配線図

```perfboard
board:
  size: 18x10
title: 図2 perfboard に組む (整合回路 + ダミー負荷)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 g3 62p
  L1: inductor e5 e9 130n
  R1: resistor e11 e13 25
  C2: capacitor e15 g15 220p
wires:
  - e1 -- e3
  - e3 -- e5
  - e9 -- e11
  - e13 -- e15
  - g3 -- h3 black
  - h3 -- h15 black
  - h15 -- g15 black
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
```

- C1 の下側 (g3) と C2 の下側 (g15) を h 行の GND バスでつなぐ。J1 の外皮も
  同じバスへ

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 30 MHz〜70 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S11 の Log Mag、SWR |

E12/E24 丸め後の**見えるはずの画面**。

```vna
device: h4
sweep: 30M-70M 201
title: 図3 整合後の S11・SWR (E12/E24 丸め後)
dut:
  - shunt C 62p
  - series L 130n
  - series R 25
  - series C 220p
  - short
traces:
  - S11 logmag
  - S11 swr
markers:
  - 49M
  - 50M
```

- 丸めた値での最良点は設計の 50 MHz よりわずかに低い**約 49 MHz** (S11 約 −33 dB、
  SWR 約 1.05)。整合していない負荷単体 (25 − j15 Ω) の SWR は 2.22 なので、
  大きく改善する

## 見るべき値

計算値。

| 状態 | 周波数 | Z (入口から見た) | SWR |
| --- | --- | --- | --- |
| 整合回路なし (負荷のみ) | 50 MHz | 25 − j14.5 Ω | 2.22 |
| 整合回路あり | 49 MHz | 50.4 + j2.3 Ω | 1.05 (最良点) |
| 整合回路あり | 50 MHz | 52.8 + j1.4 Ω | 1.06 |
| 整合回路あり | 60 MHz | 69.4 − j26.6 Ω | 1.74 |

- **L 型整合は狭帯域**。50 MHz ちょうどでは良く合うが、60 MHz まで離れると
  SWR は 1.74 まで悪化する。広い帯域で使うアンテナには不向き
- 部品を E12/E24 系列に丸めた分だけ、最良点が設計の 50 MHz から 49 MHz へ
  1 MHz ほどずれる。ぴったり合わせたいときはトリマコンデンサで微調整する

## 出典

自作。L 型整合の設計式 (連立方程式) は標準的なインピーダンス整合の教科書による。
