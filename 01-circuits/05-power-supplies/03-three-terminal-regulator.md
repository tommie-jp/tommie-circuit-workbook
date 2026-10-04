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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/03-three-terminal-regulator.svg)

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
  U1: regulator/to220 c8(in) c9(gnd) c10(out)
  Cin: capacitor g5 g8 0.33uF
  Cout: capacitor g10 g13 0.1uF
  RL: resistor b14 b18 100
  Rled: resistor d14 d20 330
  Dled: led b20(A) b23(K) red
  BAT:
    type: device
    at: top
    label: 電池 9V
    pins: ["+", "-"]
wires:
  - BAT.+ -- +t2 red
  - BAT.- -- -t3 black
  - +t8 -- a8 red
  - e8 -- f8 red
  - e9 -- f9 black
  - j9 -- -b9 black
  - j5 -- -b5 black
  - j13 -- -b13 black
  - e10 -- f10 orange
  - a10 -- a14 orange
  - a18 -- -t18 black
  - a23 -- -t23 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/03-three-terminal-regulator.svg)

- **7805 (TO-220) は端子側を上にすると左から IN・GND・OUT。** 放熱板を後ろに
  向けて挿す
- U1 の足 (IN・GND・OUT = 8・9・10 列) は、上のブロックの e 行から線で下のブロックへ渡す
- **GND の足 (9 列) は必ず − レールへ** (j9 から黒線)。ここが浮くと出力は 5 V に
  ならない
- Cin (5・8 列) は IN・GND の間、Cout (10・13 列) は OUT・GND の間。**リード線は
  短く、レギュレータのすぐ近くに**
- 出力は a10 から 14 列へ渡し、RL と Rled に配る。上下の − レールは 29 列でつなぐ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 三端子レギュレータ (TO-220) | 7805 |
| Cin | セラミックコンデンサ (入力側) | 0.33 µF |
| Cout | セラミックコンデンサ (出力側) | 0.1 µF |
| RL | 抵抗 (主負荷、1/2 W。消費は 0.25 W) | 100 Ω |
| Rled | 抵抗 (表示 LED 電流制限) | 330 Ω |
| Dled | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 9 V — 7805 は入出力差 (ドロップアウト) が約 2V 要るので、出力 5V に対して入力は 7V 以上が要る |

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
