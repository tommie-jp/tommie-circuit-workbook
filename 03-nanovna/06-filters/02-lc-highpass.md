---
book: nanovna
chapter: 6
id: 6-2
title: LC ハイパス
tier: 50
source: 自作
board: PF
device: H4
---

# 6-2 LC ハイパス

ローパス (6-1) の**双対**。直列と並列を入れ替え、コンデンサとコイルも入れ替えると、
低い周波数を落として高い周波数を通すハイパスになる。3 次のバターワースで
カットオフ 10 MHz を狙う。

## この実験で確かめる式

3 次バターワースの g 値は g1 = g3 = 1.000、g2 = 2.000 (両端の素子が同じ次数 3)。
ローパスの π 型 (shunt C1 - series L2 - shunt C3) を双対変換すると、
ハイパスは **shunt L1 - series C2 - shunt L3** になる。

**L = R / (2π f_c g)**、**C = 1 / (2π f_c R g)** (R = 50 Ω、f_c = 10 MHz)

計算値: L1 = L3 = 795.8 nH、C2 = 159.2 pF。E12/E24 系列に丸めると
L1 = L3 = 820 nH、C2 = 160 pF になる。

## 回路図

```circuit
title: 図1 3 次 LC ハイパス (L-C-L)
parts:
  J1: sma b2 mirror CH0
  L1: inductor b4 d4 820n
  C1: capacitor b5 b7 160p
  L2: inductor b8 d8 820n
  J2: sma b10 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d8
  G4: ground c10
wires:
  - J1.1 -- b4 -- b5
  - b7 -- b8 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c10
```

- shunt (地へ落とす) の 2 つがコイル、直列の 1 つがコンデンサ。ローパス (6-1) と
  ちょうど逆

## 実体配線図

```perfboard
board:
  size: 18x8
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge e1 f0
  L1: inductor e3 g3 820n
  C1: capacitor e5 e8 160p
  L2: inductor e10 g10 820n
  J2: sma/female-edge e18 f19
wires:
  - e1 -- e3
  - e3 -- e5
  - e8 -- e10
  - e10 -- e18
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- g3 black
  - h3 -- h10 black
  - h10 -- g10 black
  - h10 -- h17 black
  - h17 -- f19 black
```

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag、S11 の Log Mag |

```vna
device: h4
sweep: 1M-100M 201
title: 図3 3 次ハイパスの S21・S11 (E12/E24 丸め後)
dut:
  - shunt L 820n
  - series C 160p
  - shunt L 820n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1M
  - 9.87M
  - 30M
```

- 丸めた値での実際のカットオフ (−3 dB) は**約 9.87 MHz** (設計は 10 MHz)
- 1 MHz では −59 dB とよく落ちる。中波帯や短波の低い方を切り、それより上を通す
  ような用途に向く

## 見るべき値

計算値。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 1 MHz | −59.4 dB | 阻止帯域。中波を強く落とす |
| 5 MHz | −17.6 dB | 遷移域 |
| 9.87 MHz | −3.0 dB | 実際のカットオフ |
| 15 MHz | −0.36 dB | 通過帯域に入る |
| 30 MHz | −0.01 dB | ほぼ 0 dB |

ローパス (6-1) と比べると、通過・阻止が周波数の高い低いで入れ替わっているだけで、
次数と急峻さの考え方は同じ。

## 出典

自作。3 次バターワースの g 値、双対変換の式は標準的なフィルタ設計表による。
