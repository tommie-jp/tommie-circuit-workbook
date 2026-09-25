---
book: circuits
chapter: 7
id: 7-7
title: ハイサイドとローサイド
tier: 100
source: 自作
---

# 7-7 ハイサイドとローサイド

負荷を ON/OFF するスイッチは、**負荷より GND 側 (ローサイド)** に置くか
**負荷より電源側 (ハイサイド)** に置くかの 2 通りがある。2-1・7-2 は
どちらもローサイド (N チャネル) だった。同じ負荷を今度はハイサイド
(P チャネル) で切ってみて、駆動のしかたの違いを比べる。

## 回路図

```circuit
title: 図1 ローサイド (左) とハイサイド (右) の比較
parts:
  VCC: vcc b6
  R1: resistor b6 d6 330
  D1: led d6 e6
  Q1: nmos-e f6 2N7000
  IN1: port f2
  Rg1: resistor f2 f4 100
  Rpd1: resistor f4 h4 10k
  G1: ground g6
  G2: ground h4
  VCC: vcc b13
  Q2: pmos-e d13 BSS84
  R2: resistor e13 g13 330
  D2: led g13 h13
  IN2: port d10
  Rg2: resistor d10 d12 100
  Rpu2: resistor d12 b12 10k
  VCC: vcc b12
  G3: ground h13
wires:
  - e6 -- Q1.D
  - Q1.S -- g6
  - f4 |- Q1.G
  - b13 -- Q2.S
  - Q2.D -- e13
  - d12 |- Q2.G
notes:
  - line a8 h8 ink
  - text a3 center: ローサイド (N ch)
  - text a11 center: ハイサイド (P ch)
style:
  grid: on
  pitch: 1.2
```

- **ローサイド (左)**: 負荷 (R1・D1) を VCC 側に固定し、GND 側を Q1 (N チャネル
  MOSFET) で開閉する。2-1・7-2 と同じ形。ゲートは IN1 (GPIO) が **H で ON**
  という素直な向き。Rpd1 (10 kΩ) は GPIO が高インピーダンスのとき Q1 を
  確実に OFF に保つプルダウン
- **ハイサイド (右)**: 負荷 (R2・D2) を GND 側に固定し、VCC 側を Q2 (P チャネル
  MOSFET) で開閉する。Q2 のソースが VCC、ドレインが負荷側になるので、
  **ゲート-ソース間電圧 (V<sub>GS</sub>) は「GPIO の電圧 − VCC」**になる —
  IN2 が VCC (H) のとき V<sub>GS</sub> = 0 で **OFF**、IN2 が GND (L) のとき
  V<sub>GS</sub> = −VCC で **ON**。**ローサイドと ON/OFF の論理が逆になる**のが
  ハイサイドの特徴。Rpu2 (10 kΩ、VCC へのプルアップ) は GPIO が高インピーダンスの
  とき Q2 を確実に OFF (H) に保つ
- この回路は VCC = 5 V (GPIO と同じ電源) を前提にしている。**VCC が GPIO より
  高い電源 (例えば 12 V のモータ電源) だと、GPIO の H (5 V や 3.3 V) では
  ゲートを VCC まで持ち上げきれず、Q2 を確実に OFF にできない**。その場合は
  NPN 1 石でゲートを VCC まで引っ張る回路が要る (2-11 の PNP ハイサイドスイッチ、
  7-8 のゲートドライバ IC 参照)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | N チャネル MOSFET (ロジックレベル) | 2N7000 |
| Q2 | P チャネル MOSFET (ロジックレベル) | BSS84 |
| R1・R2 | 抵抗 (負荷電流を決める) | 330 Ω |
| D1・D2 | LED (赤、負荷の代わり) | V<sub>F</sub> ≈ 2.0 V |
| Rg1・Rg2 | 抵抗 (ゲート直列) | 100 Ω |
| Rpd1 | 抵抗 (ゲートプルダウン) | 10 kΩ |
| Rpu2 | 抵抗 (ゲートプルアップ) | 10 kΩ |
| — | 電源 | 5 V (GPIO と共通) |

## 見るべき値

計算値。VCC = 5 V、LED V<sub>F</sub> ≈ 2.0 V とする。

| 測る所 (ローサイド) | 期待する値 | 分かること |
| --- | --- | --- |
| IN1 = L (0 V) のとき Q1 の状態 | OFF (Rpd1 でゲートが GND) | 消灯 |
| IN1 = H (5 V) のとき Q1 の状態 | ON | D1 に約 9.1 mA (= (5−2)/330) 流れ点灯 |

| 測る所 (ハイサイド) | 期待する値 | 分かること |
| --- | --- | --- |
| IN2 = H (5 V) のとき Q2 の V<sub>GS</sub> | 0 V (Rpu2 でゲートが VCC) | OFF、消灯 |
| IN2 = L (0 V) のとき Q2 の V<sub>GS</sub> | −5 V | ON、D2 に約 9.1 mA 流れ点灯 (**論理がローサイドと逆**) |

## 出典

自作。
