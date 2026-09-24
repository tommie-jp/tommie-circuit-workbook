---
book: nanovna
chapter: 6
id: 6-3
title: LC バンドパス
tier: 50
source: 自作
board: PF
device: H4
---

# 6-3 LC バンドパス

ローパスの素子を**並列共振**と**直列共振**に置き換えると、ある帯域だけを通す
バンドパスになる。3 共振器 (シャント・直列・シャント) で中心 21 MHz、
比帯域 10% (帯域幅 2.1 MHz) を狙う。

## この実験で確かめる式

3 次バターワース (g1 = g3 = 1、g2 = 2) をバンドパス変換する。
比帯域 Δ = 帯域幅 / 中心周波数として、

シャント側 (LPF のコンデンサ): **C = g / (2π f₀ R Δ)**、**L = R Δ / (2π f₀ g)**
(並列共振、f₀ で共振)

直列側 (LPF のコイル): **L = g R / (2π f₀ Δ)**、**C = Δ / (2π f₀ R g)**
(直列共振、f₀ で共振)

f₀ = 21 MHz、Δ = 0.10、R = 50 Ω での計算値: シャント L = 37.9 nH、C = 1516 pF、
直列 L = 7.58 µH、C = 7.58 pF。E12/E24 系列に丸めると
シャント L = 39 nH、C = 1500 pF、直列 L = 7.5 µH、C = 7.5 pF になる
(どちらも 21.0 MHz ちょうどで共振する組み合わせ)。

## 回路図

```circuit
title: 図1 3 共振器バンドパス (シャント-直列-シャント)
parts:
  J1: sma b2 mirror CH0
  L1: inductor b4 d4 39n
  C1: capacitor b7 d7 1500p
  L2: inductor b9 b11 7.5u
  C2: capacitor b11 b13 7.5p
  L3: inductor b16 d16 39n
  C3: capacitor b19 d19 1500p
  J2: sma b21 CH1
  G1: ground c2
  G2: ground d4
  G3: ground d7
  G4: ground d16
  G5: ground d19
  G6: ground c21
wires:
  - J1.1 -- b4 -- b7 -- b9
  - b13 -- b16 -- b19 -- b21 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c21
```

- L1・C1 が並列で入口のシャント共振器、L3・C3 が出口のシャント共振器 (どちらも
  21 MHz で並列共振し、そこだけ高いインピーダンスで地に落とさない)
- L2・C2 は信号経路に直列に入る直列共振器 (21 MHz で直列共振し、そこだけ
  インピーダンスがほぼ 0 になって通す)

## 実体配線図

```perfboard
board:
  size: 20x10
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge e1 f0
  L1: inductor e3 g3 39n
  C1: capacitor e4 g4 1500p
  L2: inductor e6 e10 7.5u
  C2: capacitor e11 e13 7.5p
  L3: inductor e14 g14 39n
  C3: capacitor e15 g15 1500p
  J2: sma/female-edge e20 f21
wires:
  - e1 -- e3
  - e3 -- e4
  - e4 -- e6
  - e10 -- e11
  - e13 -- e14
  - e14 -- e15
  - e15 -- e20
  - g3 -- g4
  - g14 -- g15
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- g3 black
  - h3 -- h14 black
  - h14 -- g14 black
  - h14 -- h19 black
  - h19 -- f21 black
```

- L1/C1 と L3/C3 はそれぞれ g 行で 1 本にまとめてから GND バス (h 行) へ落とす
  (2 素子が同じ節点から並列に地へ落ちる)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜60 MHz |
| 点数 | 301 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag、S11 の Log Mag |

```vna
device: h4
sweep: 1M-60M 301
title: 図3 バンドパスの S21・S11 (E12/E24 丸め後)
dut:
  - shunt L 39n
  - shunt C 1500p
  - series L 7.5u
  - series C 7.5p
  - shunt L 39n
  - shunt C 1500p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 21M
  - 40M
```

- 丸めた値でのピークは**約 21.75 MHz** (ほぼ 0 dB)。−3 dB の帯域は
  約 20.06 MHz〜22.17 MHz (帯域幅 約 2.12 MHz、比帯域 約 10%。計算値)
- 2 つのシャント共振器の共振 (20.8 MHz) と直列共振器の共振 (21.2 MHz) が
  E12/E24 丸めでわずかにずれ、通過帯域の中に小さな谷ができる (次項で読む)

## 見るべき値

計算値 (無損失として)。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 1 MHz | −138.9 dB | 阻止帯域 (下側) |
| 20.06 MHz | −3.6 dB | 通過帯域の下端 (−3 dB) |
| 21.0 MHz | −0.63 dB | 通過帯域内。2 つの共振周波数がわずかにずれた谷 |
| 21.75 MHz | 約 0 dB | 通過帯域のピーク |
| 22.17 MHz | −3.6 dB | 通過帯域の上端 (−3 dB) |
| 40 MHz | −68.2 dB | 阻止帯域 (上側) |

E12/E24 の丸めで理論どおりぴったり 1 点には共振しないので、通過帯域の中に
0.6 dB ほどの小さな谷が出る。これは設計ミスではなく部品の丸め誤差。

## 出典

自作。バンドパス変換の式は標準的なフィルタ設計表による。
