---
book: circuits
chapter: 3
id: 3-4
title: 弛張発振 — Tr 2 石でブザー
tier: 50
source: 自作
board: BB
era: 古
---

# 3-4 弛張発振 — Tr 2 石でブザー

3-1 と同じトランジスタ 2 石の非安定マルチバイブレータを、**音が聞こえる速さ**まで
上げてブザーを鳴らす。LED の点滅も RC の値を変えれば音になる、という
つながりを確かめる 1 題。

## 回路図

```circuit
title: 図1 弛張発振でブザー
parts:
  V1: vsource vcc gnd 9
  G1: ground gnd
  R1: resistor a3 c3 330
  D1: led c3 e3 red
  R4: resistor a5 c5 10k
  R3: resistor a9 c9 10k
  R2: resistor a11 c11 330
  D2: led c11 e11 red
  Q1: npn g3 mirror 2SC1815
  Q2: npn g11 2SC1815
  C1: capacitor e4 e8 100n
  C2: capacitor d10 d6 100n
  R5: resistor e13 g13 100
  BZ1: buzzer g13 i13
points:
  vcc: a1
  gnd: i1
wires:
  - vcc -- a3 -- a5 -- a9 -- a11
  - e3 |- Q1.C
  - e11 |- Q2.C
  - e3 -- e4
  - e8 -- e9
  - c9 -- e9
  - e9 |- Q2.B
  - e10 -- e11 -- e13
  - e10 -- d10
  - d6 -- d5
  - c5 -- d5
  - d5 |- Q1.B
  - Q1.E |- i3
  - Q2.E |- i11
  - gnd -- i3 -- i11 -- i13
style:
  grid: on
```

- R3・R4 を 100 kΩ→10 kΩ、C1・C2 を 10 µF→100 nF にしただけで、3-1 と
  **回路そのものは同じ**。周期が 1/1000 になり、耳に聞こえる周波数になる
- **R5 (100 Ω) はブザーの保護。** 圧電ブザーはコンデンサに近い部品なので、
  スイッチの切り替わり (Q2 が急に ON/OFF) で流れ込む突入電流を抑える
- LED も 3-1 と同じ速さでは点滅が見えず、うっすら点いたままに見える
  (残像。目に見える上限は 30〜60 Hz 程度)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 下ブロック (f〜j 行) だけで組む。下の青レール = GND、下の赤レール = +9V
board: half
parts:
  Q1: transistor h4(E) h5(C) h6(B) 2SC1815
  R1: resistor f5 f8 330
  D1: led g9(A) g8(K) red
  R4: resistor g6 g11 10k
  Q2: transistor h14(E) h15(C) h16(B) 2SC1815
  R2: resistor f15 f18 330
  D2: led g19(A) g18(K) red
  R3: resistor g16 g21 10k
  R5: resistor g22 g25 100
  BZ1: buzzer i25 i28
  C1: capacitor/ceramic i5 i7 100nF
  C2: capacitor/ceramic i15 i17 100nF
wires:
  - j7 -- j16 orange
  - j17 -- j6 orange
  - i9 -- +b9 red
  - i11 -- +b11 red
  - i19 -- +b19 red
  - i21 -- +b21 red
  - j4 -- -b4 black
  - j14 -- -b14 black
  - j15 -- j22 orange
  - j28 -- -b28 black
```

- **R5・BZ1 は Q2 のコレクタ (15 列) から `j15--j22` で分けて GND へ落とす。**
  LED (D2) と並列に、音を出す枝が 1 本増えただけ
- 圧電ブザーに極性は無い。どちら向きに挿してもよい
- C1・C2 は 3-1 の電解コンデンサから積層セラミック (極性無し) に替える。挿す向きは自由

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| R1, R2 | 抵抗 (LED 電流制限) | 330 Ω |
| R3, R4 | 抵抗 (ベース) | 10 kΩ |
| R5 | 抵抗 (ブザー保護) | 100 Ω |
| C1, C2 | 積層セラミックコンデンサ | 100 nF (0.1 µF) |
| D1, D2 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| BZ1 | 圧電ブザー素子 (アンプ無し) | — |
| — | 電源 | 9 V |

## 見るべき値

計算値。周期は T = 1.386 × R × C (3-1 と同じ式)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 発振周波数 | 約 720 Hz (周期 約 1.39 ms) | 1 / (1.386 × 10 kΩ × 100 nF) |
| デューティ比 | 50% | R3=R4、C1=C2 で対称 |
| ブザーの音量 | R5 を小さくすると大きくなる (下限は突入電流と相談) | R5 が電流を制限している |
| Q1・Q2 のコレクタ損失 | 数 mW 程度 | 330 Ω 側は 3-1 と同じ計算 |

3-2 の 555 (Ra・Rb・C だけで周波数が決まる) と比べると、Tr 2 石は**式は同じ形でも
再現性が hFE でぶれる**。ばらつきを気にするなら 555 のほうが実用的、という
体験がこの 2 題の対比になる。

## 出典

自作。
