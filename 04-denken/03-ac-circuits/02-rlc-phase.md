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
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c4 10 i=I
  M2: voltmeter a1 a4 l=$\mathrm{CH2}$
  M1: voltmeter c6 g6 l=$\mathrm{CH1}$
  R1: resistor c8 g8 1k
  G1: ground g6
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c6 -- c8
  - g1 -- g6 -- g8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/02-rlc-phase-1.svg)

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
  - AD.W1 -- b5 yellow [h-10]
  - AD.2+ -- a5 blue
  - AD.1+ -- b10 orange [h-10]
  - AD.2- -- a10 white
  - AD.1- -- -t12 black
  - a15 -- -t15 black
notes:
  - text: "DUT (10〜15 列)。R (1kΩ)・L (100mH)・C (100nF) を順に挿し替える"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/02-rlc-phase.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1・CH2 とも DC 結合。Measure で CH1 に対する CH2 の Phase を読む |

L と C の 2 つの画面。電流 (CH2) は mV の桁なので、CH1 と違う V/div で大きく見せている。

```scope
title: 図3 L — 電流 (CH2、5 mV/div) が電圧 (CH1) より 90° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 15.9mV phase -90deg, range: 5mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/02-rlc-phase-1.svg)

```scope
title: 図4 C — 電流 (CH2、2 mV/div) が電圧 (CH1) より 90° 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 6.28mV phase 90deg, range: 2mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/02-rlc-phase-2.svg)

### オシロスコープと発振器

AD の CH2 は Rs の両端を差動で挟むが、汎用オシロのグランドクリップは大地につながっていて挟めない
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。Rs の電圧は 6〜16 mV と小さく、
CH1 − CH2 の引き算では 8 bit の分解能に埋もれるので、0-3 の図3 と同じく **Rs を GND 側へ移す** (図5)。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{FG}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  R1: resistor c5 e5 1k
  Rs: resistor e7 g7 10 i=I
  M2: voltmeter e9 g9 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3 -- c5
  - e5 -- e7 -- e9
  - g1 -- g3 -- g7 -- g9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/02-rlc-phase-2.svg)

- W1 は FG の OUT (High-Z)。1 kHz、振幅 1 V は Vpp で入れる機種なら 2 Vpp。
  CH1 の先端は FG の出力 (DUT の上)、CH2 の先端は Rs の上、グランドクリップは 2 本とも GND
- ブレッドボードは図2 から、Rs を 5〜10 列から抜いて FG の芯を 10 列へ挿す。15 列から GND のレールへの
  黒い線を外し、Rs を 15〜20 列 (c15–c20) に挿して、20 列から GND のレールへ黒い線を渡す。
  DUT は 10〜15 列のまま差し替える。CH1 の先端は 10 列、CH2 の先端は 15 列
- CH1 は DUT と Rs を合わせた電圧になる。DUT だけの電圧は Math の CH1 − CH2。CH1 をそのまま使うと、
  位相差は L で −89.1°、C で +89.6° と読める (計算値)。90° を見る題なので、この 1° 弱のずれは気にしなくてよい
- FG の出力の 50 Ω で、R (1 kΩ) のときは電流が 0.94 mA、DUT の電圧が 0.94 V に下がる (計算値)。
  L と C では 1.58 mA、0.63 mA で表とほぼ同じ
- CH2 は 5〜10 mV/div、Average を 16 回。プローブは ×1 のほうが読みやすい (0-3)

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
- **L と C は位相のずれる向きが逆。** L では電流が電圧の「あとから」ついてくる (遅れる)。
  C では電流が「先に」流れ出す (進む)
- この位相差が、3-3・3-4 のインピーダンスのベクトル図の元になる

## 出典

自作。
