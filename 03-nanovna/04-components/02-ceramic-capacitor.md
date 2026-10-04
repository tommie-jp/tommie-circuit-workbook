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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/02-ceramic-capacitor.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の直列治具に積層セラミックコンデンサ
points:
  GND: j0
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  C1: capacitor/ceramic i6 i9 100n
wires:
  - i1 -- i6
  - i9 -- i24
  - j0 -- j25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/02-ceramic-capacitor.svg)

部品はリード付きの積層セラミック (ラジアル形) を使い、リードを数 mm に切りつめて
挿す。リードが短いほど ESL は小さい。ここでは短いリードと基板の穴までの配線を
含めて ESL ≈ 2 nH、ESR ≈ 0.05 Ω と見積もる (目安)。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

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
title: 図3 0.1 µF セラミックの |Z| — 11.25 MHz の SRF で谷、上は誘導性
dut:
  - series C 100n esr 0.05 esl 2n
  - short
traces:
  - S11 z
markers:
  - 1M
  - 11.25M
  - 100M
notes:
  - text 60M 0.2Ω: 谷の底 0.05 Ω (ESR) は枠の下端 0.1 Ω より下
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/02-ceramic-capacitor-1.svg)

SRF の近く (5〜17.5 MHz) を広げ、|Z| に X を重ねて線形の目盛で見る。

```vna
device: h4
sweep: 5M-17.5M 401
title: 図4 SRF の近くを広げる — X が 0 を横切り、|Z| は ESR まで下がる
dut:
  - series C 100n esr 0.05 esl 2n
  - short
traces:
  - S11 z
  - S11 x
markers:
  - 11.25M
notes:
  - text 9M -0.15Ω: SRF で X = 0、|Z| = ESR (0.05 Ω)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/02-ceramic-capacitor-2.svg)

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
