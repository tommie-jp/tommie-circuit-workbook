---
book: nanovna
chapter: 3
id: 3-5
title: 10 dB アッテネータの製作と S21 / S11
tier: 50
source: 自作
board: PF
device: H4
---

# 3-5 10 dB アッテネータの製作と S21 / S11

抵抗 3 本で作る **50 Ω 系の T 型アッテネータ**。測定器の前に挟んで
電力を落としたり (0-3)、反射を抑えたりするのに使う定番の回路を、
自分で作って NanoVNA で確かめる。

## 抵抗値の計算

10 dB (電圧比 √10 ≈ 3.162) の T 型アッテネータの理屈どおりの値は、

```text
直列側 (2 本) = 50 × (√10 − 1) / (√10 + 1) ≈ 26.0 Ω
分岐側 (1 本) = 50 × 2√10 / (10 − 1)        ≈ 35.1 Ω
```

**E24 系列 (よく売っている値) に寄せると 27 Ω と 36 Ω** になる。この値では
理屈のぴったり 10.0 dB からわずかにずれて 10.1 dB (計算値) になる。

## 回路図

```circuit
title: 図1 10 dB T 型アッテネータ
parts:
  J1: sma b2 mirror
  R1: resistor b4 b6 27
  R2: resistor b6 d6 36
  R3: resistor b6 b8 27
  J2: sma b10
  G1: ground c2
  G2: ground d6
  G3: ground c10
wires:
  - J1.1 -- b4
  - b8 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c10
notes:
  - text a2 center: CH0
  - text a10 center: CH1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/05-attenuator.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の 10 dB アッテネータ
points:
  GND: b7
parts:
  J1: sma/female-edge a10 011 09
  R1: resistor c10 f10 27
  R2: resistor h10 h8 36
  R3: resistor j10 m10 27
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - f10 -- h10
  - h10 -- j10
  - m10 -- x10
  - h8 -- h7 black
  - h7 -- GND black
  - 09 -- b9 black
  - b9 -- GND black
  - y9 -- o9 black
  - o9 -- o7 black
  - o7 -- h7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/05-attenuator.svg)

- R1・R3 (27 Ω) は i 行を通る本線に、R2 (36 Ω) はそこから GND へ落ちる
  分岐に載る
- **分岐 (R2) のリード線もできるだけ短く。** 長いとインダクタンスが乗り、
  高い周波数で減衰量がずれる (3-6)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (アッテネータの SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag、S11 の Log Mag |

27 Ω・36 Ω・27 Ω で組んだときに**見えるはずの画面** (理想の模型)。

```vna
device: h4
sweep: 1M-300M 101
title: 図3 E24 (27・36・27 Ω) の 10 dB パッドは平ら
dut:
  - series R 27
  - shunt R 36
  - series R 27
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 300M
notes:
  - text 20M -55dB: S21 は −10.07 dB、S11 は E24 の丸めで −36.43 dB
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/05-attenuator.svg)

## 見るべき値

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| S21 (減衰量) | −10.07 dB | 理屈どおりの 10.0 dB に近い (E24 に丸めた誤差) |
| S11 (反射) | −36.43 dB | 50 Ω からわずかにずれる (理屈どおりの 26.0 / 35.1 Ω なら −79.33 dB まで下がる) |

**理屈どおりの値 (26.0 Ω・35.1 Ω) と E24 の値 (27 Ω・36 Ω) を比べると**、
減衰量 (S21) はほとんど変わらないが、**反射 (S11) は E24 のほうがずっと
悪くなる**。手に入りやすさと性能のどちらを取るかは、用途 (測定器の
前に挟むだけなら E24 で十分、精密な整合が要るなら理屈どおりの値を
探す) で決める。

## 出典

自作。
