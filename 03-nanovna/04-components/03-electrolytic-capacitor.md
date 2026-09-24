---
book: nanovna
chapter: 4
id: 4-3
title: 電解コンデンサの ESR vs 周波数
tier: 50
source: 自作
board: PF
device: H4
---

# 4-3 電解コンデンサの ESR vs 周波数

電解コンデンサは容量が大きいぶん、直列の抵抗分 (ESR) も無視できない。3-1 の
直列治具にアルミ電解コンデンサ 100 µF を挿し、|Z| が容量・ESR・リードの
インダクタンス (ESL) のどれに支配されているかを、周波数ごとに読み分ける。

## 回路図

```circuit
title: 図1 直列治具に電解コンデンサを挿す
parts:
  J1: sma b2 mirror CH0
  C1: ecap b4 b6 100u
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

C1 は極性がある。先に書いた足 (J1 側) が +。

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 perfboard の直列治具にアルミ電解コンデンサ
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  C1: capacitor/electrolytic e6 e11 100u
wires:
  - e1 -- e6
  - e11 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

リード品の電解コンデンサは積層セラミックより ESL が大きい。ここでは
ESR ≈ 0.8 Ω (汎用品の代表値)、ESL ≈ 8 nH と見積もる。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜50 MHz |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の \|Z\| (対数)。最後を短絡にして 1 端子の Z 測定にする |

見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 50k-50M 401
title: 図3 100 µF 電解コンデンサの |Z| (理想)
dut:
  - series C 100u esr 0.8 esl 8n
  - short
traces:
  - S11 z
markers:
  - 178k
  - 1M
  - 15.9M
  - 50M
```

## 見るべき値

計算値。容量性から ESR の谷 (SRF = 1 / (2π√(ESL·C))) を経て誘導性に移る。

| 周波数 | \|Z\| | 支配する成分 |
| --- | --- | --- |
| 178 kHz (SRF) | 0.80 Ω | ESR のみ (谷の底) |
| 1 MHz | 0.80 Ω | ほぼ ESR (X はまだ 0.05 Ω) |
| 15.9 MHz (X = ESR) | 1.13 Ω | ESR と ESL が同じ大きさ |
| 50 MHz | 2.64 Ω | 誘導性 (ωL) |

容量性から ESR に変わる角周波数 (Xc = ESR となる点) は
1 / (2π·C·ESR) ≈ 2 kHz で、**H4 の下限 (50 kHz) より下**。つまりこの容量と
ESR の組み合わせでは、H4 で掃引できる範囲はほぼ最初から ESR (または ESL) が
支配していて、容量性の下り坂は掃引の外にある。

分かること:

- **大きい容量の電解コンデンサは、低い周波数のほとんどで「ただの抵抗 (ESR)」
  として振る舞う。** |Z| が周波数によらずほぼ一定なのはこのため
- 178 kHz〜1 MHz あたりは ESR がそのまま読める区間。データシートが ESR を
  1 点の周波数 (100 kHz や 120 Hz) で書くのはこの理由
- 15.9 MHz を超えると ESL が効き始め、電解コンデンサはもう高い周波数の
  デコンデンサとしては使えない。4-8 の並列デカップリングにつながる

## 出典

自作。
