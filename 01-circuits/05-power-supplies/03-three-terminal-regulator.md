---
book: circuits
chapter: 5
id: 5-3
title: 3 端子レギュレータ (7805)
tier: 50
source: 自作
board: BB
---

# 5-3 3 端子レギュレータ (7805)

ツェナー + Tr (5-2) を 1 個の IC にまとめたのが三端子レギュレータ。
足を 3 本つなぐだけで、入力が多少ふらついても出力はきっちり 5 V に保たれる。

## 回路図

```circuit
title: 図1 7805 で 5V を作る
parts:
  V1: vsource vin gnd 9
  G1: ground gnd
  U1: regulator b5 7805
  Cin: capacitor b3 d3 0.33u
  Cout: capacitor b7 d7 0.1u
  RL: resistor b9 d9 100
  Rled: resistor b11 c11 330
  Dled: led c11 d11 red
points:
  vin: b1
  gnd: d1
wires:
  - vin -- b3 -- U1.in
  - U1.out -- b7 -- b9 -- b11
  - U1.gnd -- d5
  - gnd -- d3 -- d5 -- d7 -- d9 -- d11
style:
  grid: on
```

- **Cin (0.33 µF) は入力側、Cout (0.1 µF) は出力側**。どちらも発振防止と
  応答改善のためにデータシートが指定する定石の値
- RL (100 Ω) が主負荷、Rled・Dled は電源が来ているかを示す表示 LED
- 9 V 電池でも 12 V の AC アダプタでも、入力が 7 V を超えていれば出力は 5 V
  のまま (ドロップアウトは約 2 V)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  U1: regulator/to220 g5(in) g6(gnd) g7(out)
  Cin: capacitor f5 f3 0.33uF
  Cout: capacitor f7 f9 0.1uF
  RL: resistor h7 h12 100
  Rled: resistor i7 i16 330
  Dled: led j16(A) j18(K) red
  BAT:
    type: device
    at: top
    label: 電池 9V
    pins: ["+", "-"]
wires:
  - BAT.+ -- a5 red
  - e5 -- f5 red
  - BAT.- -- -t3 black
  - -t3 -- f3 black
  - g9 -- -t9 black
  - i12 -- -t12 black
  - i18 -- -b18 black
  - -t18 -- -b18 black
```

- **7805 (TO-220) は端子側を上にすると左から IN・GND・OUT。** 放熱板を後ろに
  向けて挿す
- Cin (5 列) は IN・GND の間、Cout (7 列) は OUT・GND の間。**リード線は
  短く、レギュレータのすぐ近くに**

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 三端子レギュレータ (TO-220) | 7805 |
| Cin | セラミックコンデンサ (入力側) | 0.33 µF |
| Cout | セラミックコンデンサ (出力側) | 0.1 µF |
| RL | 抵抗 (主負荷) | 100 Ω |
| Rled | 抵抗 (表示 LED 電流制限) | 330 Ω |
| Dled | LED (緑、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 9 V (電池、または AC アダプタ整流後) |

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| OUT の電圧 | 5.00 V (±4%) | 入力が 7〜20 V の範囲でほぼ一定 |
| RL の電流 | 50 mA | 5 V ÷ 100 Ω |
| Dled の電流 | 約 9.1 mA | (5 V − 2.0 V) ÷ 330 Ω |
| U1 の損失 | 約 236 mW | (9 V − 5 V) × 合計電流 (約 59 mA)。放熱板なしでも常温なら問題ない |
| 入力を 6 V まで下げた場合 | 出力が 5 V を割り始める | ドロップアウト電圧 (約 2 V) を切ると規制できなくなる |

負荷電流を増やす (RL を小さくする) と U1 の発熱が増える。1 A に近づくなら
放熱板が要る (データシートの熱抵抗から計算する、7-12 で扱う)。

## 出典

自作。
