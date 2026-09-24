---
book: nanovna
chapter: 4
id: 4-2
title: セラミックコンデンサの SRF と ESL
tier: 50
source: 自作
board: PF
device: H4
---

# 4-2 セラミックコンデンサの SRF と ESL

コンデンサは低い周波数では容量どおりに振る舞うが、リード線と電極が持つ
わずかなインダクタンス (ESL) のせいで、ある周波数から先はコイルのように見える。
容量とインダクタンスが打ち消し合って |Z| が最小になる周波数が**自己共振周波数
(SRF)**。3-1 の直列治具に積層セラミックコンデンサ 0.1 µF を挿して確かめる。

## 回路図

```circuit
title: 図1 直列治具にセラミックコンデンサを挿す
parts:
  J1: sma b2 mirror CH0
  C1: capacitor b4 b6 100n
  J2: sma b8 CH1
  G1: ground c2
  G2: ground c8
wires:
  - J1.1 -- b4
  - b6 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c8
```

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 perfboard の直列治具に積層セラミックコンデンサ
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  C1: capacitor/ceramic e6 e11 100n
wires:
  - e1 -- e6
  - e11 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

積層セラミック (2012 サイズ相当) はリード線が無いぶん ESL が小さい。ここでは
基板の穴までの配線を含めて ESL ≈ 2 nH、ESR ≈ 0.05 Ω と見積もる。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の \|Z\| (対数)。最後を短絡にして 1 端子の Z 測定にする |

見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 1M-300M 401
title: 図3 0.1 µF セラミックコンデンサの SRF (理想)
dut:
  - series C 100n esr 0.05 esl 2n
  - short
traces:
  - S11 z
markers:
  - 1M
  - 11.25M
  - 100M
```

## 見るべき値

計算値。SRF = 1 / (2π√(ESL·C))。

| 周波数 | \|Z\| | 支配する成分 |
| --- | --- | --- |
| 1 MHz | 1.58 Ω | 容量性 (1 / ωC) |
| 11.25 MHz (SRF) | 0.05 Ω | ESR のみ (谷) |
| 100 MHz | 1.24 Ω | 誘導性 (ωL) |

分かること:

- SRF より下では |Z| は周波数に**反比例**して下がり (容量性)、SRF より上では
  周波数に**比例**して上がる (誘導性)。谷の深さが ESR
- **0.1 µF は「低い周波数用」の容量**。SRF (約 11 MHz) より高い周波数では
  もはやコンデンサとして働かず、コイルとして振る舞う。デカップリングに
  もっと高い周波数まで効かせたいなら、もっと小さい容量 (ESL が同じなら SRF は
  1/√C で上がる) を足す — 4-8 で確かめる
- 治具のリード分もこの ESL に含まれる。**測る部品のリードは短いほど正しい値に近づく**
  (3-1 の注意と同じ)

## 出典

自作。
