---
book: circuits
chapter: 9
id: 9-18
title: RC-CR で 90° を作る — 1 本の正弦から I と Q
tier: 100
source: 自作
board: BB
---

# 9-18 RC-CR で 90° を作る — 1 本の正弦から I と Q

位相が **90° ずれた 2 本の正弦**を、ひと組で **I と Q** と呼ぶ。I は in-phase (同相)、Q は quadrature (直交、90° ずれ) の頭文字。
9-19〜9-24 の I/Q の回路は、どれもこの 2 本から始まる。この題では、抵抗 2 本とコンデンサ 2 個だけで、
1 本の正弦から I と Q を作る。Analog Discovery 3 (AD3) のスコープで、時間の波形と XY の円を見る。

**RC-CR の回路**は、信号源から 2 本の枝を出す。

- **低域側 (RC)**: R1 を直列に通し、C2 で GND に落とす。出力は入力より**遅れる**
- **高域側 (CR)**: C1 を直列に通し、R2 で GND に落とす。出力は入力より**進む**

R と C を両方の枝で同じ値 (680 Ω・470 pF) にすると、2 つの出力の比は次の式になる。

V<sub>高域</sub> / V<sub>低域</sub> = jωRC = j × (f / f<sub>c</sub>)、f<sub>c</sub> = 1 / (2πRC)

j は位相を 90° 進める印だ。だから**位相の差は、どの周波数でもちょうど 90°** になる。
周波数で変わるのは**大きさの比 f / f<sub>c</sub> だけ**で、2 本の振幅がそろうのは f = f<sub>c</sub> のときに限る。

- f<sub>c</sub> = 1 / (2π × 680 Ω × 470 pF) **= 497.9 kHz**。この題の W1 は **498 kHz** にする
- 498 kHz では、低域側が −45°、高域側が +45° で、どちらも入力の 0.707 倍。**差が 90° で振幅も同じ**
- 300 kHz では低域側 0.856 倍・高域側 0.516 倍、800 kHz では低域側 0.528 倍・高域側 0.849 倍。
  振幅は大きく違うが、**位相の差は 90° のまま** (LTspice でも 300 k・498 k・800 kHz の 3 点とも 90.0°)

この題では、**高域側 (+45°) を I、低域側 (−45°) を Q** と呼ぶ。Q は I より 90° 遅れる。
I を cos、Q を sin と見るのと同じ向きだ。9-19 からも同じ名前で使う。

**90° の回路は、決まった 1 つの周波数に使う。** 振幅がそろうのは f<sub>c</sub> の近くだけなので、
周波数が動く信号 (受けたい電波 RF) をこの回路に通すと、I と Q の振幅がずれる。
受信機では、**周波数の決まった局部発振 (LO) のほうを 90° ずらす**。9-19 では、この題の回路をそのまま LO の 90° に使う。

## 回路図

```circuit
title: 図1 RC-CR で W1 から I (高域側 +45°) と Q (低域側 -45°) を作る
parts:
  W1: sine d1 f1 l=$\mathrm{W1}$
  G1: ground f1
  R1: resistor d2 d4 680
  C2: capacitor d6 f6 470p
  M2: voltmeter d9 f9 l=$\mathrm{CH2}$
  C1: capacitor b2 b4 470p
  R2: resistor b11 f11 680
  M1: voltmeter b13 f13 l=$\mathrm{CH1}$
wires:
  - b1 -- d1
  - b1 -- b2
  - d1 -- d2
  - d4 -- d6 -- d9
  - b4 -- b11 -- b13
  - f1 -- f6 -- f9 -- f11 -- f13
notes:
  - text a12f0 small center: I (+45°)
  - text c7f5 small center: Q (-45°)
style:
  pitch: 1.2
```

## 実体配線図

```breadboard
title: 図2 W1 は 10 列、Q は 6 列、I は 14 列
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 2-, 2+, W1, 1+, 1-]
  C2: capacitor/ceramic d3 d6 470p
  R1: resistor b6 b10 680
  C1: capacitor/ceramic c10 c14 470p
  R2: resistor d14 d17 680
wires:
  - AD.GND -- -t1 black
  - AD.2- -- -t2 black
  - a3 -- -t3 black
  - AD.2+ -- a6 blue
  - AD.W1 -- a10 yellow
  - AD.1+ -- a14 orange
  - a17 -- -t17 black
  - AD.1- -- -t16 black
```
