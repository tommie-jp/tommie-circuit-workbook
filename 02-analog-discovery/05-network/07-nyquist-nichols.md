---
book: analog-discovery
chapter: 5
id: 5-7
title: Nyquist / Nichols 表示
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-7 Nyquist / Nichols 表示

Network の掃引結果は Bode 線図 (周波数を横軸に利得と位相) だけでなく、
**Nyquist** (複素平面に H(jω) の軌跡)・**Nichols** (位相を横軸、利得を縦軸) でも
表示できる。5-1 と同じ RC ローパスを掃引し、同じデータが 3 つの見方でどう
並ぶかを見比べる。

## 回路図

5-1 と同じ回路 (R1 = 1 kΩ、C1 = 100 nF)。

```circuit
title: 図1 RC ローパス (5-1 と同じ)
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 1k
  C1: capacitor a7 c7 100n
  M2: voltmeter a9 c9 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c7 -- c9
  - a7 -- a9
```

f<sub>c</sub> = 1 / (2πRC) ≈ 1.59 kHz (5-1 と同じ)。

## 実体配線図

5-1 と同じ配線。

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor d10 d14 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
  - a14 -- -t14 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 100 Hz、Stop 100 kHz、Log、Steps 101、Reference: Channel 1。表示を **Nyquist** に切り替えて掃引、続けて **Nichols** に切り替えて同じデータを見る |

Nyquist・Nichols とも、掃引そのものは Bode と同じ (Start/Stop/Steps の設定は共通)。
**表示形式を選ぶだけ**で、同じ測定結果を 3 通りに見られる。

## 見るべき値

計算値。H(jω) = 1 / (1 + jωRC)。

**Nyquist (複素平面、Re・Im)**:

| 周波数 | Re(H) | Im(H) | \|H\| |
| --- | --- | --- | --- |
| 15.9 Hz (0.01×f<sub>c</sub>) | +1.000 | −0.010 | 1.000 |
| 795.8 Hz (0.5×f<sub>c</sub>) | +0.800 | −0.400 | 0.894 |
| 1.59 kHz (f<sub>c</sub>) | +0.500 | −0.500 | 0.707 |
| 3.18 kHz (2×f<sub>c</sub>) | +0.200 | −0.400 | 0.447 |
| 15.9 kHz (10×f<sub>c</sub>) | +0.010 | −0.099 | 0.100 |

**Nichols (位相 vs 利得)**:

| 位相 | 利得 |
| --- | --- |
| −0.6° | −0.00 dB |
| −45.0° (f<sub>c</sub>) | −3.01 dB |
| −84.3° | −20.04 dB |
| −89.4° | −40.00 dB |

分かること:

- **Nyquist の軌跡は 1 次ローパスでは半円になる。** Re と Im をプロットすると、
  (1, 0) から (0, 0) へ、下側 (Im < 0) を通って弧を描く。中心は (0.5, 0)、
  半径 0.5 のちょうど半円 — これは 1 次系に共通の形で、Bode の「−20 dB/dec・
  45° ずつ」という情報を 1 本の曲線に畳んだもの
- **Nichols は位相を横軸、利得を縦軸にした Bode の言い換え。** 周波数の目盛りは
  消えるが、**位相と利得がどこで組になっているか**が一目で分かる。5-4 の
  「−3 dB 点で 45°」という関係は、Nichols 上では (−45°, −3.01 dB) の 1 点として
  現れる
- どちらも新しい情報を測っているわけではない。**同じ掃引データの見せ方が違うだけ**
  — フィードバック系の安定判別 (中級で扱う位相余裕) には Nyquist・Nichols の
  ほうが読みやすい場面がある

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
