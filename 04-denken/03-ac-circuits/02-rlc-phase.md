---
book: denken
chapter: 3
id: 3-2
title: R・L・C の電圧と電流の位相
tier: 50
source: 自作
board: BB
---

# 3-2 R・L・C の電圧と電流の位相

抵抗・コイル・コンデンサはどれも電圧と電流の**大きさの関係**はオームの
法則に似ているが、**位相 (タイミング)** の関係がまったく違う。同じ治具
(シャント抵抗で電流を電圧に変える、0-3 の形) に部品を挿し替えるだけで、
3 つの位相差を測って比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R: 位相差 0° | 電圧と電流はいつも同じ向き (同位相) |
| L: 電圧が電流より 90° 進む | 電流は電圧より 90° 遅れる |
| C: 電圧が電流より 90° 遅れる | 電流は電圧より 90° 進む |

## 回路図

```circuit
title: 図1 DUT の電圧と電流を同時に見る (図は R のとき)
style:
  standard: jis
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c5 10 i=I
  M2: voltmeter a1 a5 l=$\mathrm{CH2}$
  M1: voltmeter c5 g5 l=$\mathrm{CH1}$
  R1: resistor c8 g8 1k
  G1: ground g5
wires:
  - a1 -- c1
  - a5 -- c5
  - c5 -- c8
  - g1 -- g5 -- g8
```

- CH1 が DUT (R1 の位置) の両端の電圧、CH2 が Rs (シャント、10 Ω) の両端
  = 電流に比例した電圧。**CH1 と CH2 の位相差が DUT の位相差そのもの**
  (Rs は十分小さいので、電流の位相をほぼそのまま伝える)
- R1 の場所を、抵抗 (1 kΩ) → コイル (100 mH) → コンデンサ (100 nF) の順に
  差し替えて 3 回測る。図は抵抗を入れた状態

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rs: resistor c5 c10 10
  R1: resistor d10 d15 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "2+", "1+", "2-", "1-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 blue [h10]
  - AD.1+ -- a10 orange
  - AD.2- -- b10 white [h10]
  - AD.1- -- -t12 black
  - d15 -- -t15 black
notes:
  - text: "DUT (10〜15 列)。R (1kΩ)・L (100mH)・C (100nF) を順に挿し替える"
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1・CH2 とも DC 結合。Measure で CH1 に対する CH2 の Phase を読む |

## 見るべき値

計算値 (Wavegen 振幅 1 V、1 kHz、シャント Rs = 10 Ω)。

| DUT | 電流の振幅 (CH2 ÷ 10 Ω) | CH1 (DUT の電圧) | 位相 (CH1 基準の電流) |
| --- | --- | --- | --- |
| R = 1 kΩ | 0.99 mA | 0.99 V | 0° (同位相) |
| L = 100 mH | 1.59 mA | 1.00 V | −90° (電流が電圧より 90° 遅れる) |
| C = 100 nF | 0.63 mA | 1.00 V | +90° (電流が電圧より 90° 進む) |

分かること:

- **R では電圧と電流の波形がぴったり重なる。** L と C では波形が 1/4 周期
  (90°) だけずれる
- **L と C は位相のずれる向きが逆。** L は「電流に例えると"あとから"ついてくる」
  (電流が遅れる)、C は「電流が"先に"流れ出す」(電流が進む) と覚えるとよい
- この位相差が、3-3・3-4 のインピーダンスのベクトル図の元になる

## 出典

自作。
