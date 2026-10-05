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
直列 L = 7.58 µH、C = 7.58 pF。E12 系列に丸めると
シャント L = 39 nH、C = 1500 pF、直列 L = 6.8 µH、C = 8.2 pF になる。
丸めたので共振は 21 MHz ちょうどにならない — シャント側は 20.8 MHz、
直列側は 21.3 MHz で共振する。

## 回路図

```circuit
title: 図1 3 共振器バンドパス (シャント-直列-シャント)
parts:
  J1: sma b2 mirror CH0
  L1: inductor b4 d4 39n
  C1: capacitor b7 d7 1500p
  L2: inductor b9 b11 6.8u
  C2: capacitor b11 b13 8.2p
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/03-lc-bandpass.svg)

- L1・C1 が並列で入口のシャント共振器、L3・C3 が出口のシャント共振器 (どちらも
  21 MHz で並列共振し、そこだけ高いインピーダンスで地に落とさない)
- L2・C2 は信号経路に直列に入る直列共振器 (21 MHz で直列共振し、そこだけ
  インピーダンスがほぼ 0 になって通す)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge a10 09
  L1: inductor c10 c8 39n
  C1: capacitor e10 e8 1500p
  L2: inductor h10 l10 6.8u
  C2: capacitor n10 p10 8.2p
  L3: inductor r10 r8 39n
  C3: capacitor t10 t8 1500p
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - c10 -- e10
  - e10 -- h10
  - l10 -- n10
  - p10 -- r10
  - r10 -- t10
  - t10 -- x10
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- c7 black
  - c7 -- c8 black
  - c7 -- e7 black
  - e7 -- e8 black
  - e7 -- r7 black
  - r7 -- r8 black
  - r7 -- t7 black
  - t7 -- t8 black
  - t7 -- w7 black
  - y9 -- w9 black
  - w9 -- w7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/03-lc-bandpass.svg)

- L1/C1 と L3/C3 はそれぞれ k 行で 1 本にまとめてから GND バス (l 行) へ落とす
  (2 素子が同じ節点から並列に地へ落ちる)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜60 MHz |
| 点数 | 301 |
| 校正 | SOLT |
| 表示 | S21 の Log Mag (S11 は帯域の中の 2 MHz ほどでしか動かず、1〜60 MHz の掃引では針になるので出さない) |

```vna
device: h4
sweep: 1M-60M 301
title: 図3 バンドパスの全体 (1〜60 MHz) — 通過帯域の外を見る
dut:
  - shunt L 39n
  - shunt C 1500p
  - series L 6.8u
  - series C 8.2p
  - shunt L 39n
  - shunt C 1500p
traces:
  - S21 logmag
markers:
  - 21.91M
  - 40M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/03-lc-bandpass-1.svg)

通過帯域の中を見るには、掃引を 16〜26 MHz に狭める (帯域幅の約 5 倍)。

```vna
device: h4
sweep: 16M-26M 201
title: 図4 16〜26 MHz に狭めた S21 — 塗った所が −3 dB の帯域 (2.27 MHz)
dut:
  - shunt L 39n
  - shunt C 1500p
  - series L 6.8u
  - series C 8.2p
  - shunt L 39n
  - shunt C 1500p
traces:
  - S21 logmag
markers:
  - 20.04M
  - 21.22M
  - 21.91M
  - 22.3M
notes:
  - band 20.04M 22.3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/03-lc-bandpass-2.svg)

- 丸めた値でのピークは**約 21.91 MHz** (ほぼ 0 dB)。−3 dB の帯域は
  約 20.04 MHz〜22.30 MHz (帯域幅 約 2.27 MHz、比帯域 約 11%。計算値)
- 2 つのシャント共振器の共振 (20.8 MHz) と直列共振器の共振 (21.3 MHz) が
  E12 の丸めでずれ、通過帯域の中 (21.22 MHz) に小さな谷ができる (次項で読む)

## 見るべき値

計算値 (無損失として)。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 1 MHz | −138.1 dB | 阻止帯域 (下側) |
| 20.04 MHz | −3.0 dB | 通過帯域の下端 (−3 dB) |
| 21.22 MHz | −0.89 dB | 通過帯域内。2 つの共振周波数がずれてできた谷 |
| 21.91 MHz | 約 0 dB | 通過帯域のピーク |
| 22.30 MHz | −2.95 dB | 通過帯域の上端 (−3 dB) |
| 40 MHz | −67.3 dB | 阻止帯域 (上側) |

E12 の丸めで理論どおりぴったり 1 点には共振しないので、通過帯域の中に
0.9 dB ほどの小さな谷が出る。これは設計ミスではなく部品の丸め誤差。

## 出典

自作。バンドパス変換の式は標準的なフィルタ設計表による。
