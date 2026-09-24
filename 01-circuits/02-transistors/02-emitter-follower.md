---
book: circuits
chapter: 2
id: 2-2
title: エミッタフォロア
tier: 50
source: 自作
board: BB
---

# 2-2 エミッタフォロア

コレクタを電源に直結し、エミッタから出力を取る回路。**電圧はほぼ 1 倍のまま
変えず、電流だけを大きくする**。信号源のインピーダンスが高く、負荷が小さいときの
「橋渡し」役として使う。

## 回路図

```circuit
title: 図1 エミッタフォロア
parts:
  V1: vsource a1 j1 9
  G1: ground j1
  R1: resistor a5 c5 22k
  R2: resistor c5 e5 10k
  G2: ground e5
  Q1: npn g7
  CIN: capacitor b7 d7 10u
  IN: port b7
  RE: resistor g9 g11 1k
  G3: ground g11
  COUT: capacitor g9 i9 10u
  RL: resistor i9 i11 1k
  G4: ground i11
  OUT: port i9
wires:
  - a1 -- a9
  - a9 -| Q1.C
  - c5 -| Q1.B
  - d7 -| Q1.B
  - Q1.E -| g9
style:
  grid: on
```

`R1` (22kΩ) と `R2` (10kΩ) でベースを分圧し、`RE` (1kΩ) がエミッタの電位を決める。
`CIN` / `COUT` は直流を切って信号だけ通す結合コンデンサ。

- 分圧の開放電圧: 9V × 10k/(22k+10k) ≈ **2.81 V**、等価内部抵抗 ≈ 6.9kΩ
- hFE = 150 と仮定すると、ベース電流を差し引いた実際の Vb ≈ **2.72 V**
- エミッタ電圧: Ve = Vb − 0.7 ≈ **2.0 V**、Ie = Ve / RE ≈ **2.0 mA**
- Vce = 9 − 2.0 = **約 7.0 V** (コレクタは電源に直結なので損失は Vce×Ic ≈ 14mW)
- 電圧利得: Av = RE / (RE + re)、re = 26mV/Ie ≈ 13Ω → Av ≈ 1000/1013 ≈
  **0.99 倍** (1 倍よりわずかに小さいだけ。反転しない)

## 実体配線図

```breadboard
title: 図2 エミッタフォロア
# 上のレール = +9V、下のレール = GND
board: half
parts:
  R1: resistor a3 a8 22k
  R2: resistor b8 b13 10k
  Q1: transistor f16(B) f17(C) f18(E) 2SC1815
  CIN: capacitor c11(-) c14(+) 10uF
  RE: resistor a20 a23 1k
  COUT: capacitor/electrolytic b20(+) b26(-) 10uF
  RL: resistor c26 c29 1k
wires:
  - +t3 -- c3 red
  - c8 -- g16 orange
  - c13 -- -t13 black
  - d14 -- g16 yellow
  - g17 -- +b17 red
  - g18 -- d20 blue
  - d23 -- -t23 black
  - d29 -- -t29 black
```

`R1`・`R2` の分圧点 (列 8) がベース、`RE` の上端 (列 20) がエミッタ。
`Q1` のコレクタ (`f17`) は直接 +9V レールへ。`CIN` の左端 (`c11`) が
信号の入り口 (音声入力など)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 22 kΩ |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| RE, RL | 抵抗 (1/4 W) | 1 kΩ |
| CIN, COUT | 電解コンデンサ | 10 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | 9V |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース (R1/R2 の分圧点) の電圧 | 約 2.7 〜 2.8 V | 分圧の計算どおり |
| エミッタの電圧 | 約 2.0 V | ベースよりダイオード 1 個分 (0.6〜0.7V) 低い |
| Q1 の C-E 間電圧 | 約 7 V | 活性領域で安定して動いている |
| 入力に 1Vpp の交流を入れたときの出力 (RL の両端) | 約 0.99 Vpp、位相は同じ | 電圧はほぼそのまま、反転もしない |

## 出典

自作。
