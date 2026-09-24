---
book: nanovna
chapter: 4
id: 4-1
title: 抵抗 (カーボン・金属皮膜) の |Z|
tier: 50
source: 自作
board: PF
device: H4
---

# 4-1 抵抗 (カーボン・金属皮膜) の |Z|

「抵抗は抵抗」と思いがちだが、高い周波数ではリード線と抵抗体そのものが持つ
わずかなインダクタンス (ESL) のせいで、抵抗値どおりの値からずれていく。ここでは
同じ 100 Ω でも作り方が違う 2 種類 —**金属皮膜**と**炭素皮膜 (カーボン)** — を
3-1 で作った直列治具に挿し替えて、その差を見る。

金属皮膜抵抗は精密な値に合わせるため、抵抗体をらせん状に溝切り (トリミング) して
値を micro 調整することが多く、これがわずかなコイルになる。炭素皮膜抵抗は溝を切らない
厚膜の抵抗体なので、この効果が小さい。ここではリード線ぶんも含めて、金属皮膜は
ESL ≈ 15 nH、炭素皮膜は ESL ≈ 6 nH と見積もる (実測ではなく代表的な値の見積もり。
実物の差は個体やリード長で変わる)。

## 回路図

3-1 の直列治具をそのまま使う。R1 の位置に測る抵抗を挿す。

```circuit
title: 図1 直列治具に抵抗を挿す
parts:
  J1: sma b2 mirror CH0
  R1: resistor b4 b6 100
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
title: 図2 perfboard の直列治具 (3-1 と同じ)
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 f17
  R1: resistor e6 e11 100
wires:
  - e1 -- e6
  - e11 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

R1 を金属皮膜 100 Ω と炭素皮膜 100 Ω で挿し替えて、2 回測る。

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜1.5 GHz (H4 の上限いっぱい) |
| 点数 | 301 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の R と X (Ω)。最後を短絡にして 1 端子の Z 測定にする |

CH1 側の SMA には結線せず、代わりに校正キットの Short を挿す
(フェンスの模型では最後に `short` と書いて表す)。R1 単体のインピーダンス
Z = R + jωL が S11 から直接読める。

金属皮膜 (ESL 15 nH) — 見えるはずの画面。

```vna
device: h4
sweep: 1M-1500M 301
title: 図3 金属皮膜 100 Ω (ESL 15 nH) の R と X
dut:
  - series R 100 esl 15n
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 300M
  - 1G
  - 1.4G
```

炭素皮膜 (ESL 6 nH) — 見えるはずの画面。

```vna
device: h4
sweep: 1M-1500M 301
title: 図4 炭素皮膜 100 Ω (ESL 6 nH) の R と X
dut:
  - series R 100 esl 6n
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 300M
  - 1G
  - 1.4G
```

## 見るべき値

計算値。|Z| = √(R² + X²)、X = ωL。

| 周波数 | 金属皮膜 (ESL 15 nH) の \|Z\| | 炭素皮膜 (ESL 6 nH) の \|Z\| |
| --- | --- | --- |
| 300 MHz | 103.9 Ω | 100.6 Ω |
| 1 GHz | 137.4 Ω | 106.9 Ω |
| 1.4 GHz | 165.6 Ω | 113.1 Ω |

分かること:

- **R (実部) はどちらもほぼ 100 Ω のまま一定。** ずれているのは X (虚部) —
  ESL によるインダクタンス性のリアクタンス
- **1 GHz では金属皮膜が公称値から 37% もずれる**のに対し、炭素皮膜は 7% ほど。
  VHF 帯までの実験では気にしなくてよいが、UHF 帯 (300 MHz〜) では抵抗の種類も
  効いてくる
- 治具そのものの限界 (3-1 で見た SMA 間の漏れ) と、抵抗自身の ESL は別の要因。
  どちらも高い周波数で |Z| をずらす

## 出典

自作。
