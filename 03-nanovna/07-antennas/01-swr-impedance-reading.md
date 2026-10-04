---
book: nanovna
chapter: 7
id: 7-1
title: SWR とインピーダンスの読み方
tier: 50
source: 自作
board: —
device: H4
---

# 7-1 SWR とインピーダンスの読み方

アンテナの章の最初に、**負荷を変えると SWR と Smith チャートがどう動くか**を
確かめる。CH0 に抵抗を 1 個だけ直につないだ簡単な負荷で、読み方を身につける。

## この実験で確かめる式

50 Ω 系に抵抗 R だけをつなぐと、反射係数とインピーダンスの関係は

**Γ = (R − 50) / (R + 50)**、**SWR = (1 + |Γ|) / (1 − |Γ|)**

R = 50 Ω なら Γ = 0 (SWR = 1、反射なし)。R が大きくても小さくても Γ の絶対値は
大きくなり、SWR も大きくなる (符号は無関係。100 Ω も 25 Ω も式の分母分子が
入れ替わるだけで |Γ| は同じ)。

## 回路図

抵抗を SMA コネクタに直付けした 1 端子の負荷 (基板は使わない)。

```circuit
title: 図1 抵抗 1 個の負荷
parts:
  J1: sma b2 mirror CH0
  R1: resistor b4 d4 100
  G1: ground c2
  G2: ground d4
wires:
  - J1.1 -- b4
  - J1.2 -- c2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/circuit/01-swr-impedance-reading.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の抵抗 1 個の負荷 (CH0 の先に付ける)
points:
  GND: j0
parts:
  J1: sma/female-edge i1 h0 j0
  R1: resistor i4 i7 100
wires:
  - i1 -- i4
  - i7 -- j7 black
  - j7 -- j0 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/perfboard/01-swr-impedance-reading.svg)

R1 を 25 Ω・50 Ω・100 Ω・200 Ω と挿し替えて、SWR と Smith チャートの動きを見る
(E24 に無い値は 5-5 の表の作り方で作る)。ユニバーサル基板に流れる電流は数 mA 以下で、ユニバーサル基板の範囲に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10 MHz〜100 MHz (抵抗だけなので周波数によらずほぼ一定) |
| 点数 | 101 |
| 校正 | SOLT |
| 表示 | S11 の Smith チャート、SWR |

100 Ω を負荷にしたときの**見えるはずの画面**。

```vna
device: h4
sweep: 10M-100M 101
title: 図3 100 Ω 負荷 — Smith は r = 2 の 1 点、SWR は 2.00 で平ら (枠の上端)
dut:
  - series R 100
  - short
traces:
  - S11 smith
  - S11 swr
markers:
  - 50M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/01-swr-impedance-reading.svg)

- Smith チャートでは実軸上、中心 (50 Ω) より右の r = 2 (100 Ω) の点で止まったまま
  動かない (純抵抗、周波数に依らない)
- SWR も周波数によらず一定 (2.00)

## 見るべき値

計算値。R = 50 Ω を挟んで対称になることを確かめる。

| 負荷 | Γ | SWR | Smith 上の位置 |
| --- | --- | --- | --- |
| 短絡 (0 Ω) | −1.00 | ∞ | 左端 |
| 25 Ω | −0.33 | 2.00 | 中心より左 (r = 0.5) |
| 50 Ω | 0.00 | 1.00 | ちょうど中心 |
| 100 Ω | +0.33 | 2.00 | 中心より右 (r = 2) |
| 開放 | +1.00 | ∞ | 右端 |

- **SWR は 25 Ω も 100 Ω も同じ 2.00** になる — SWR だけでは高い方に外れたのか
  低い方に外れたのかは分からない。**Smith チャートか R + jX の表示**で初めて
  分かる (中心より右か左か)
- 短絡と開放はどちらも SWR = ∞ だが、Smith 上では正反対の端に来る。
  1-2 で作った校正キットの 3 点 (Open・Short・Load) がちょうどこの 3 つの代表例

## 出典

自作。
