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
title: 図1 エミッタフォロア (W1 で入れ、CH2 と CH1 で比べる)
parts:
  V1: vsource b12 d12 5
  G1: ground d12
  R1: resistor b6 d6 22k
  R2: resistor d6 f6 10k
  G2: ground f6
  Q1: npn d8
  CIN: ecap d5 d4 10u
  W1: sine d2 f2 l=$\mathrm{W1}$
  M2: voltmeter d4 f4 l=$\mathrm{CH2}$
  G5: ground f4
  RE: resistor f8 h8 1k
  G3: ground h8
  COUT: ecap f8 f11 10u
  RL: resistor f11 h11 1k
  G4: ground h11
  OUT: port f11
  M1: voltmeter f13 h13 l=$\mathrm{CH1}$
wires:
  - b6 -- b8 -- b12
  - b8 -- Q1.C
  - d5 -- d6 -- Q1.B
  - Q1.E -- f8
  - d2 -- d4
  - f2 -- f4
  - f11 -- f13
  - h11 -- h13
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/02-emitter-follower.svg)

`R1` (22kΩ) と `R2` (10kΩ) でベースを分圧し、`RE` (1kΩ) がエミッタの電位を決める。
`CIN` / `COUT` は直流を切って信号だけ通す結合コンデンサ。

- 分圧の開放電圧: 5V × 10k/(22k+10k) ≈ **1.56 V**、等価内部抵抗 ≈ 6.9kΩ
- hFE = 150 と仮定すると、ベース電流を差し引いた実際の Vb ≈ **1.52 V**
- エミッタ電圧: Ve = Vb − 0.7 ≈ **0.83 V**、Ie = Ve / RE ≈ **0.83 mA**
- Vce = 5 − 0.83 = **約 4.2 V** (コレクタは電源に直結なので損失は Vce×Ic ≈ 3.4mW)
- 電圧利得: Av = RE / (RE + re)、re = 26mV/Ie ≈ 31.5Ω → Av ≈ 1000/1031.5 ≈
  **0.97 倍** (1 倍よりわずかに小さいだけ。反転しない)

## 実体配線図

```breadboard
title: 図2 エミッタフォロア (W1 と CH2 を入力へ、CH1 を出力へ)
# 5V は上の +/− レールへ直接入れる (下のレールは使わない)
board: half
parts:
  R1: resistor b5 b10 22k
  R2: resistor a10 -t10 10k
  CIN: capacitor/electrolytic d4(-) d10(+) 10uF
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RE: resistor a14 -t14 1k
  COUT: capacitor/electrolytic b14(+) b18(-) 10uF
  RL: resistor a18 -t18 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 2-, 2+, W1, 1+, 1-]
  PS:
    type: device
    at: top
    label: 電源 5V (USB)
    pins: [+5V, GND]
wires:
  - PS.+5V -- +t28 red
  - PS.GND -- -t29 black
  - AD.GND -- -t1 black
  - AD.2- -- -t2 black
  - AD.2+ -- a3 blue
  - e3 -- e4 blue
  - AD.W1 -- a4 yellow
  - AD.1+ -- a20 orange
  - e18 -- e20 orange
  - AD.1- -- -t21 black
  - +t5 -- a5 red
  - +t12 -- a12 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/02-emitter-follower.svg)

部品はすべて上半分に挿し、電源 5V (USB) は上の + / − レールへ直接入れる。

- **ベース (列 10)**: `R1` の右端・`R2` の上端・`CIN` の + 側・`Q1` の B が同じ列に
  並ぶので、線は要らない。`R1` の左端 (列 5) は赤線で +5V へ
- **コレクタ (列 12)**: 赤線で +5V レールへ直接
- **エミッタ (列 14)**: `RE` と `COUT` の + 側が同じ列。`R2`・`RE`・`RL` は
  − レールへ縦に挿す
- **入力 (列 4)**: `CIN` の − 側。Analog Discovery の W1 (黄) を `a4` に、
  CH2 の 2+ (青) は `a3` に挿して `e3`–`e4` で渡す
- **出力 (列 18)**: `COUT` の − 側と `RL`。CH1 の 1+ (橙) は `a20` に挿して
  `e18`–`e20` で渡す
- AD の GND・2−・1− (黒) は上の − レールへ

## オシロで見る

W1 を 1 kHz・1 Vpp の正弦波にし、CH2 (入力) と CH1 (出力) を同じ 200 mV/div で重ねる。

```scope
title: 図3 入力 (CH2) と出力 (CH1) — 振幅はほぼ同じ、位相も揃う
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 0.97Vpp, range: 200mV/div}
ch2: {wave: sine 1kHz 1Vpp, range: 200mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/02-emitter-follower.svg)

CH1 は CH2 の約 0.97 倍 (0.97 Vpp) で、2 本の山と谷がほぼ重なる。反転しないこと、
電圧がほぼ 1 倍のまま出ることが一目で分かる。結合コンデンサ (10 µF) と 1 kΩ の
遮断周波数は約 16 Hz なので、1 kHz では位相のずれは 1° ほどで画面では見えない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 22 kΩ |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| RE, RL | 抵抗 (1/4 W) | 1 kΩ |
| CIN, COUT | 電解コンデンサ | 10 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | 5V (USB) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース (R1/R2 の分圧点) の電圧 | 約 1.5 〜 1.6 V | 分圧の計算どおり |
| エミッタの電圧 | 約 0.83 V | ベースよりダイオード 1 個分 (0.6〜0.7V) 低い |
| Q1 の C-E 間電圧 | 約 4.2 V | 活性領域で安定して動いている |
| 入力に 1Vpp の交流を入れたときの出力 (RL の両端) | 約 0.97 Vpp、位相は同じ | 電圧はほぼそのまま、反転もしない |

## 出典

自作。
