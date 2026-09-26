---
book: circuits
chapter: 2
id: 2-5
title: MOSFET スイッチ (2N7000、ロジックレベル)
tier: 50
source: 自作
era: 今
board: BB
---

# 2-5 MOSFET スイッチ (2N7000、ロジックレベル)

MOSFET はゲートに電圧をかけるだけでオン・オフするスイッチ (ベース電流が
要らない)。2N7000 は**ロジックレベル**の MOSFET で、5V (3.3V でも) の
デジタル信号で十分にオンにできる。マイコンの GPIO で直接駆動できるのが利点。

## 回路図

```circuit
title: 図1 2N7000 でスイッチする
parts:
  V1: vsource a2 c2 5
  G1: ground c2
  R1: resistor a7 c7 330
  D1: led c7 d7
  Q1: nmos-e d7i0
  SW: switch a4 c4
  RG: resistor c4 e4 220
  RPD: resistor e4 g4 100k
  G2: ground g4
  G3: ground f7
wires:
  - a2 -- a4 -- a7
  - d7 -- Q1.D
  - e4 |- Q1.G
  - Q1.S -- f7
style:
  grid: on
  pitch: 1.2
```

`SW` を閉じるとゲートに 5V がかかり、MOSFET がオンになって LED が点く。
`RPD` (100kΩ、プルダウン) が `SW` を開けたときにゲートを確実に 0V へ落とす。
`RG` (220Ω) はゲートを充電する瞬間の電流を抑える保護抵抗。

- 2N7000 のしきい値電圧 V<sub>GS(th)</sub> は 1〜3V (データシートの規格) で、
  5V を掛ければ確実にオン (オーバードライブが取れている)
- オン抵抗 R<sub>DS(on)</sub> は V<sub>GS</sub>=5V で数Ω程度 (十分小さい)
- LED の電流: I = (5 − V<sub>F</sub>) / R1 ≈ (5 − 2.0) / 330 ≈ **9.1 mA**
  (R<sub>DS(on)</sub> による電圧降下 数十mV は無視できるほど小さい)
- ゲートに流れる電流は**ほぼ 0** (MOSFET は電圧駆動)。`RG` があっても
  定常時の電圧降下はほぼ無い

## 実体配線図

```breadboard
title: 図2 2N7000 でスイッチする
# 5V は上の +/− レールへ。下の − レールは 28 列で上の − レールとつなぐ
board: half
parts:
  R1: resistor a5 a8 330
  D1: led b8(A) b9(K) red
  Q1: transistor f13(S) f14(G) f15(D) 2N7000
  RG: resistor a18 a21 220
  RPD: resistor b21 b24 100k
  SW: button @ e17
wires:
  - +t5 -- c5 red
  - c9 -- g15 orange
  - +t17 -- a17 red
  - g17 -- c18 orange
  - c21 -- g14 yellow
  - c24 -- -t24 black
  - g13 -- -b13 black
  - -t28 -- -b28 black
```

2N7000 は**平らな面を見て左から S・G・D** (2SC1815 とは並びが違うので注意)。
`RG` と `RPD` の分圧点 (列 21) がゲート。ソース (`f13`、下の − レール) と
`RPD` の下端 (上の − レール) が同じ GND になるよう、28 列の黒線で上下の − レールを
つなぐ。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 330 Ω |
| RG | 抵抗 (1/4 W) | 220 Ω |
| RPD | 抵抗 (1/4 W) | 100 kΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1 | ロジックレベル N-MOSFET | 2N7000 |
| SW | タクトスイッチ | — |
| — | 電源 | 5V |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| SW を押していないときのゲート電圧 | 0 V | RPD がゲートを GND に落としている |
| SW を押したときのゲート電圧 | 約 5 V | RG の電圧降下はほぼ 0 (ゲート電流がないため) |
| SW を押したときの LED の電流 | 約 9.1 mA | 計算値どおり。BJT のスイッチ (2-1) とほぼ同じ電流 |
| SW を押したときの Q1 の D-S 間電圧 | 数十 mV 程度 | R<sub>DS(on)</sub> が小さいので BJT の飽和電圧 (0.2V) よりさらに小さい |

## 出典

自作。
