---
book: nanovna
chapter: 6
id: 6-1
title: LC ローパス (7 次)
tier: 50
source: 自作
board: PF
device: H4
---

# 6-1 LC ローパス (7 次)

コイルとコンデンサだけで作るローパスフィルタ。次数を上げるほど遮断は急になるが、
部品も増える。ここでは 7 次のバターワース (最平坦) 特性を、E12/E24 系列の実在の
値で作り、カットオフ周波数 30 MHz を狙う。

## この実験で確かめる式

7 次バターワースの LC はしご形回路 (π 型、両端が並列コンデンサ) の値は、
正規化定数 g (g1 = g7 = 0.445、g2 = g6 = 1.247、g3 = g5 = 1.802、g4 = 2.000) から

**C = g / (2π f_c R)**、**L = g R / (2π f_c)** (R = 50 Ω)

で決まる。計算値 (丸める前): C1 = C7 = 47.2 pF、L2 = L6 = 330.8 nH、
C3 = C5 = 191.2 pF、L4 = 530.5 nH。E12/E24 系列に丸めると
C1 = C7 = 47 pF、L2 = L6 = 330 nH、C3 = C5 = 200 pF、L4 = 560 nH になる。

## 回路図

```circuit
title: 図1 7 次 LC ローパス (C-L-C-L-C-L-C)
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 d4 47p
  L1: inductor b5 b7 330n
  C2: capacitor b8 d8 200p
  L2: inductor b9 b11 560n
  C3: capacitor b12 d12 200p
  L3: inductor b13 b15 330n
  C4: capacitor b16 d16 47p
  J2: sma b18 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d8
  G4: ground d12
  G5: ground d16
  G6: ground c18
wires:
  - J1.1 -- b4 -- b5
  - b7 -- b8 -- b9
  - b11 -- b12 -- b13
  - b15 -- b16 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c18
```

- 両端が並列コンデンサ (shunt C) の π 型。直列側はコイル
- C1 = C4 (図の 47 pF) が両端、C2 = C3 (200 pF) が内側。次数が奇数なので
  両端の素子は同じ種類 (コンデンサ) になる

## 実体配線図

```perfboard
board:
  size: 34x10
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 f3 47p
  L1: inductor e5 e9 330n
  C2: capacitor e11 f11 200p
  L2: inductor e13 e18 560n
  C3: capacitor e20 f20 200p
  L3: inductor e22 e26 330n
  C4: capacitor e28 f28 47p
  J2: sma/female-edge e34 f35
wires:
  - e1 -- e3
  - e3 -- e5
  - e9 -- e11
  - e11 -- e13
  - e18 -- e20
  - e20 -- e22
  - e26 -- e28
  - e28 -- e34
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- f3 black
  - h3 -- h11 black
  - h11 -- f11 black
  - h11 -- h20 black
  - h20 -- f20 black
  - h20 -- h28 black
  - h28 -- f28 black
  - h28 -- h33 black
  - h33 -- f35 black
```

- e 行が信号の通り道。4 つのコンデンサの下側の足 (f 行) を h 行の GND バスへ落とす
- コイルは軸物 (`inductor`)。330 nH と 560 nH は市販のカラーコード付きインダクタで買える

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz |
| 点数 | 201 |
| 校正 | SOLT (Thru はケーブル 2 本を直結) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

丸めた値 (47p/330n/200n/560n) で計算した**見えるはずの画面**。

```vna
device: h4
sweep: 1M-100M 201
title: 図3 7 次ローパスの S21・S11 (E12/E24 丸め後)
dut:
  - shunt C 47p
  - series L 330n
  - shunt C 200p
  - series L 560n
  - shunt C 200p
  - series L 330n
  - shunt C 47p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 28.4M
  - 100M
```

- 部品を E12/E24 系列に丸めたので、実際のカットオフ (−3 dB) は設計の 30 MHz より
  やや低い**約 28.4 MHz**になる (計算値)
- マーカー 3 (100 MHz) では −74 dB まで落ちる。急峻さは次数の証

## 見るべき値

計算値 (理想の集中定数、コイルは無損失として)。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 1 MHz | 約 0 dB | 通過帯域 |
| 20 MHz | −0.06 dB | まだほぼ平ら |
| 28.4 MHz | −3.0 dB | 実際のカットオフ (丸めた値のため 30 MHz より低い) |
| 40 MHz | −19.6 dB | 急な下がり (7 次) |
| 100 MHz | −74.4 dB | 阻止帯域。実測では部品の SRF (4-2・4-4) で頭打ちになる |

実測では、コイルの Q が有限なので通過帯域の S21 は 0 dB ちょうどにはならない
(小さな挿入損失が出る。6-4 で確かめる)。

## 出典

自作。7 次バターワースの g 値は標準的なフィルタ設計表による。
