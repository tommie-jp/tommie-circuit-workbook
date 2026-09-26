---
book: denken
chapter: 12
id: 12-2
title: 送電線の模型 — R と L の線路で電圧降下と電力損失
tier: 50
source: 自作
board: BB
---

# 12-2 送電線の模型 — R と L の線路で電圧降下と電力損失

送電線は抵抗 R とリアクタンス X (コイルの L) を持つ。電源電圧・線路の
インピーダンス・受電端の電圧はベクトルで足し合わさるので、単純な引き算には
ならない。線路のコイルを短絡できるスイッチを付け、R だけの線路と比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vs = Vr + I × (R + jX) | 送電端電圧はベクトル和 (3-4 の RC 直列と同じ考え方) |
| P_loss = I² × R | 線路の損失。線電流の 2 乗に比例する |
| X = ωL | 線路のリアクタンス。周波数に比例して増える |

## 回路図

```circuit
title: 図1 送電線の模型 (R + L、S1 で L を短絡)
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  Rline: resistor c1 c3 10 i=I
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  Lline: inductor c3 e3 10m
  S1: switch c5 e5
  Rload: resistor e3 g3 100
  M1: voltmeter a7 a9 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- c5
  - e3 -- e5
  - a7 |- e3
  - a9 |- g3
  - g1 -- g3
```

- W1 は AD の波形発生器。1 kHz、振幅 1 V。Rline (10 Ω) が線路の抵抗を兼ねる
  電流検出用シャント、Lline (10 mH) が線路のリアクタンス
- S1 を閉じると Lline が短絡され、R だけの線路になる (開けば R + L の線路)
- CH1 (M1) が受電端電圧 Vr (Rload の両端)、CH2 (M2) が Rline の両端 (線電流 I)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rline: resistor c12 c16 10
  Lline: inductor/axial g16 g8 10m
  S1: switch i16 i8
  Rload: resistor c8 c4 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t6 black
  - a4 -- -t4 black
  - AD.1+ -- a8 orange
  - AD.1- -- -t10 black
  - b3 -- b12 yellow
  - AD.2+ -- a12 yellow
  - AD.2- -- a16 green
  - e8 -- f8 orange
  - e16 -- f16 green
```

- W1 (3 列) は黄の線で 12 列へ延ばし、Rline (12・16 列) の入口にする。16 列と
  8 列は溝をまたぐ短い線で下のブロックへ降ろしてある
- Lline (10 mH、下のブロックの 8・16 列) と S1 (同じ 8・16 列、別の穴) は同じ
  2 つの列を共有する。S1 を挿すと L が短絡され、抜くと L だけを通る
- 8 列 (受電端) から Rload (100 Ω、4〜8 列) を通って 4 列から青レール (GND) へ戻る
- CH1 (1+/1−) が Rload の両端 (受電端電圧)、CH2 (2+/2−) が Rline の両端 (線電流)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1 = 受電端電圧。CH2 = Rline の両端 (I = 読み ÷ 10 Ω)。Measure で振幅と位相 |

## 見るべき値

計算値。Rline = 10 Ω、Lline = 10 mH (X_L = 62.8 Ω、1 kHz)、Rload = 100 Ω とした。

| 状態 | I (振幅) | Vr = I×Rload | 線路の損失 (I_rms²×Rline) | 分かること |
| --- | --- | --- | --- | --- |
| S1 を開く (R + L の線路) | 7.89 mA | 0.789 V | 0.312 mW | X_L が効いて電流が減る |
| S1 を閉じる (R だけの線路) | 9.09 mA | 0.909 V | 0.413 mW | 電流・受電端電圧とも大きくなる |

**Vs (1 V) は Vr (0.789 V) と線路の電圧降下の単純な足し算にならない。**
線路の電圧降下 (I×√(R²+X_L²) ≒ 0.502 V) を Vr に足すと 1.29 V になり、
Vs の 1 V を超えてしまう — 両者の位相がずれているため、ベクトル和でしか
一致しない (3-4 の RC 直列と同じ性質)。リアクタンスが線路の電圧降下を
余分に大きくすることが、S1 の開閉で数値として確かめられる。

## 出典

自作。
