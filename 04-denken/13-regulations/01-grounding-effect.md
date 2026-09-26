---
book: denken
chapter: 13
id: 13-1
title: 接地の効果 — 漏電した機器に触れたときの電圧 (抵抗の模型、5 V)
tier: 50
source: 自作
board: BB
---

# 13-1 接地の効果 — 漏電した機器に触れたときの電圧 (抵抗の模型、5 V)

**これは抵抗だけで作った模型で、考え方を確かめるためのもの。** 実際の漏電は
商用電源 (100 V 以上) で起きる危険な現象で、この実験のように手で触れられる
ものではない。ここでは安全な 5 V のもとで、絶縁不良の抵抗・人体の抵抗・接地の
抵抗を模した 3 つの抵抗だけを使い、「接地があると触れたときの電圧が下がる」
という関係だけを数字で確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vbody = V × Rbody / (Rleak + Rbody) | 接地が無いとき、人体に掛かる電圧 (単純な分圧) |
| Rpar = Rbody・Rground / (Rbody + Rground) | 接地があるとき、人体と接地抵抗の並列合成 |
| Vbody' = V × Rpar / (Rleak + Rpar) | 接地があるときの人体電圧。Rpar は Rbody よりずっと小さいので Vbody' は小さくなる |

## 回路図

```circuit
title: 図1 漏電の模型 (S1 で接地の有無を切り替える)
style:
  standard: jis
parts:
  V1: vsource c1 g1 5
  Rleak: resistor c1 c3 1k i=Ileak
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  Rbody: resistor c3 g3 1k
  S1: switch c5 e5
  Rground: resistor e5 g5 100
  M1: voltmeter a7 a9 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- c5
  - g3 -- g5
  - g1 -- g3
  - a7 |- c3
  - a9 |- g3
```

- Rleak (1 kΩ) が絶縁不良を模した「漏れ」の抵抗。Rbody (1 kΩ) が人体の抵抗
  (電気設備の安全計算でよく使う目安値)。Rground (100 Ω) が接地極の抵抗
  (D 種接地工事の上限 100 Ω を模した値)
- S1 を開くと「接地していない機器」、閉じると「接地した機器」になる
- CH1 (M1) が人体に掛かる電圧 (Rbody の両端)、CH2 (M2) が Rleak の両端

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rleak: resistor e3 e7 1000
  Rbody: resistor c15 c19 1000
  S1: switch e15 e20
  Rground: resistor b20 b24 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- a3 red
  - AD.GND -- -t5 black
  - AD.1+ -- a7 orange
  - AD.1- -- -t9 black
  - AD.2+ -- a11 blue
  - AD.2- -- a15 white
  - c3 -- c11 red
  - b7 -- b15 orange
  - a19 -- -t19 black
  - a24 -- -t24 black
```

- Rleak (3〜7 列)、Rbody (15〜19 列) が直列。7 列 (人体側の節点) は橙の線で
  15 列へ、3 列 (V+) は赤の線で 11 列へ延ばし、AD の足の並びどおりに左から挿す
- S1 + Rground (15〜24 列) は 15 列 (人体側の節点) から分かれて 24 列から
  GND (青レール) へ戻る、Rbody と並列の枝。S1 を挿すと接地ありになる
- CH1 (1+/1−) が Rbody の両端 (人体電圧)、CH2 (2+/2−) が Rleak の両端

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | AD の Supplies (V+) を 5 V に設定 |
| Scope | CH1 = Rbody の両端 (Vbody)。CH2 = Rleak の両端 (Ileak = 読み ÷ 1 kΩ) |

## 見るべき値

計算値。Rleak = Rbody = 1 kΩ、Rground = 100 Ω とした。

| 状態 (S1) | Vbody | 人体を流れる電流 (Vbody÷1kΩ) | 分かること |
| --- | --- | --- | --- |
| 開く (接地なし) | 2.50 V | 2.50 mA | 漏電電圧の半分が丸ごと人体に掛かる |
| 閉じる (接地あり) | 0.417 V | 0.417 mA | 電圧も電流も 1/6 に下がる |

**接地があると、漏れた電流のほとんどが接地極 (低い抵抗) を通って逃げ、
人体を通る分はわずかになる。** この模型では Rground が Rbody よりずっと
小さい (100 Ω に対して 1 kΩ) ため、並列合成 Rpar ≒ 90.9 Ω となり、
人体電圧が大きく下がる。実際の 100 V 以上の回路でも同じ比の関係が働き、
これが接地工事 (D 種など) が感電を防ぐしくみである。

## 出典

自作。
