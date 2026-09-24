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
  R2: resistor d6 d8 36
  R3: resistor b6 b8 27
  J2: sma b10
  G1: ground c2
  G2: ground d9
  G3: ground c10
wires:
  - J1.1 -- b4
  - b6 -- d6
  - b8 -- J2.1
  - d8 -- d9
  - J1.2 -- c2
  - J2.2 -- c10
notes:
  - text a2 center: CH0
  - text a10 center: CH1
```

## 実体配線図

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 perfboard の 10 dB アッテネータ
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  R1: resistor e3 e5 27
  R2: resistor f5 h5 36
  R3: resistor e6 e9 27
  J2: sma/female-edge e16 f17
wires:
  - e1 -- e3
  - e5 -- f5
  - e5 -- e6
  - e9 -- e16
  - h5 -- GND black
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

- R1・R3 (27 Ω) は e 行を通る本線に、R2 (36 Ω) はそこから GND へ落ちる
  分岐に載る
- **分岐 (R2) のリード線もできるだけ短く。** 長いとインダクタンスが乗り、
  高い周波数で減衰量がずれる (3-6)

## 掃引の設定

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
title: 図3 27 Ω・36 Ω・27 Ω の 10 dB パッドの画面 (理想)
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
```

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
