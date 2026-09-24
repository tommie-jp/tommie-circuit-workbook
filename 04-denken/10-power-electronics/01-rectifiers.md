---
book: denken
chapter: 10
id: 10-1
title: 単相の半波整流と全波整流 — 平均値は 0.45 V と 0.9 V
tier: 50
source: 自作
board: BB
---

# 10-1 単相の半波整流と全波整流 — 平均値は 0.45 V と 0.9 V

ダイオード 1 個で片側だけを通す**半波整流**と、4 個をブリッジに組んで両側を通す
**全波整流**を、同じ交流電源から同時に作って比べる。平均値 (直流分) の違いを
実測する。AD の波形発生器を商用周波数に見立てた 50 Hz で使う (商用電源には繋がない)。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vavg(半波) = Vm / π ≒ 0.45 × Vrms | 半波整流の平均値 (理想ダイオード) |
| Vavg(全波) = 2Vm / π ≒ 0.9 × Vrms | 全波整流の平均値。半波のちょうど 2 倍 |
| Vavg(実際) ≒ (Vm − nVf) / π × (1 or 2) | 実際はダイオードの順電圧 Vf の分だけ低くなる (n = 直列に通る個数) |

## 回路図

```circuit
title: 図1 半波整流と全波整流ブリッジを並べて比べる
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  D1: diode c1 c3 1N4148
  RL1: resistor c3 g3 1.5k
  M1: voltmeter c5 g5 l=$\mathrm{CH1}$
  D2: diode e10 c13 1N4148
  D3: diode e16 c13 1N4148
  D4: diode g13 e10 1N4148
  D5: diode g13 e16 1N4148
  RL2: resistor c13 g13 1.5k
  M2: voltmeter c15 g15 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- a1 -- a10 -- e10
  - g1 -- i1 -- i16 -- e16
  - g1 -- g3
  - c3 -- c5
  - g3 -- g5
  - c13 -- c15
  - g13 -- g15
```

- W1 は AD の波形発生器 (Wavegen)。50 Hz、振幅 5 V
- 左側 (D1 + RL1) が半波整流、右側 (D2〜D5 のブリッジ + RL2) が全波整流。
  同じ W1 から並列に取り出している
- CH1 は半波整流の出力 (RL1 の両端)、CH2 は全波整流の出力 (RL2 の両端) を同時に読む

## 実体配線図

```breadboard
title: 図2 半波整流のブレッドボード
board: half
parts:
  D1: diode a5(A) a10(K) 1N4148
  RL1: resistor c10 c15 1500
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b15 black
  - AD.1+ -- b10 orange
  - AD.1- -- b15 black [h22]
```

```breadboard
title: 図3 全波整流 (ブリッジ) のブレッドボード
board: half
parts:
  D2: diode a5(A) a12(K) 1N4148
  D3: diode c9(A) c12(K) 1N4148
  D4: diode e16(A) e5(K) 1N4148
  D5: diode d16(A) d9(K) 1N4148
  RL2: resistor b12 b16 1500
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 2+, 2-]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b9 black
  - AD.2+ -- d12 orange
  - AD.2- -- c16 black
```

- 半波整流 (図2) は D1 と RL1 だけ。CH1 (1+/1−) は RL1 の両端 (13・18 列)
- 全波整流 (図3) は D2〜D5 の 4 本でブリッジを組む。5 列が AC の一方 (W1)、
  9 列が AC の他方 (GND)、12 列が正、16 列が負。RL2 (12・16 列) が正負の間の
  負荷。D4・D5 は列を逆に挿す (アノードが 16 列側)
- CH2 (2+/2−) は RL2 の両端 (12 列側が正、16 列側が負) にあてる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、50 Hz、Amplitude 5 V |
| Scope | CH1 = 半波整流の出力。CH2 = 全波整流の出力。どちらも Measure で Average を読む |

## 見るべき値

計算値。ダイオードの順電圧 Vf ≒ 0.6 V (1N4148) とした。

| 測る所 | 理想の式 | 実際 (Vf を考えた計算値) |
| --- | --- | --- |
| CH1 平均値 (半波) | 0.45 × 3.54 V = 1.59 V | (5 − 0.6) / π ≒ 1.40 V |
| CH2 平均値 (全波) | 0.9 × 3.54 V = 3.18 V | 2×(5 − 1.2) / π ≒ 2.42 V |
| CH2 / CH1 の比 | 2.00 (理想) | 約 1.73 (Vf 2 個分だけ理想より小さい) |

**全波は半波のちょうど 2 倍にはならない。** ブリッジは電流が常に 2 個の
ダイオードを通るので、Vf の効き方が半波 (1 個分) より大きいため。この差は
5 V 程度の低い電圧で特に目立ち、電圧を上げるほど比は 2 に近づく。

## 出典

自作。
