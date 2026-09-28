---
book: denken
chapter: 4
id: 4-5
title: 三相電力 — P = √3 VI cos θ
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-5 三相電力 — P = √3 VI cos θ

平衡三相の負荷が使う電力は、1 相の電力の 3 倍だ。1 相の電力は相電圧・相電流・力率の積なので、
線間電圧 V と線電流 I で書き直すと **P = √3 VI cos θ** になる。4-1 の三相電源に、
コンデンサと抵抗の直列を Y 結線にした負荷 (進み力率) をつなぎ、1 相ずつ AD の Math で
v × i を平均して、3 つの和と式を比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| P_1 = V_p I_p cos θ | 1 相の有効電力。V_p・I_p は相電圧・相電流の実効値 |
| P = 3 V_p I_p cos θ | 平衡なら 3 相とも同じ電力 |
| V = √3 V_p、I = I_p (Y 結線) | 線間電圧は相電圧の √3 倍 (4-2)。Y では線電流 = 相電流 |
| P = √3 V I cos θ | 線間電圧と線電流で書いた三相電力 |
| cos θ = R / √(R² + X_C²) | 負荷の力率。X_C = 1/(ωC) |

## 回路図

```circuit
title: 図1 三相電源と C + R の Y 負荷 (N は GND)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 e1 l=$\mathrm{W1}$
  G1: ground e1
  V2: sine i1 k1 l=$\mathrm{W2}$
  G2: ground k1
  R1: resistor c3 e3 10k
  R2: resistor i4 g4 10k
  U1: opamp f8 +down TL071
  G3: ground g6
  Rf: resistor d7 d10 10k
  M1: voltmeter c12 e12 l=$\mathrm{CH1}$
  G4: ground e12
  Ca: capacitor c14 c16 220n
  Ra: resistor c18 c20 1k
  M2: voltmeter a18 a20 l=$\mathrm{CH2}$
  Cc: capacitor f14 f16 220n
  Rc: resistor f18 f20 1k
  Cb: capacitor i14 i16 220n
  Rb: resistor i18 i20 1k
  G5: ground k22
wires:
  - c1 -- c3 -- c12 -- c14
  - i1 -- i4 -- i14
  - e3 -- e4 -- e7
  - e4 -- g4
  - d7 -- e7
  - e7 |- U1.-
  - g6 |- U1.+
  - d10 -- f10
  - U1.out -- f10 -- f14
  - c16 -- c18
  - f16 -- f18
  - i16 -- i18
  - a18 -- c18
  - a20 -- c20
  - c20 -- c22 -- f22 -- i22 -- k22
  - f20 -- f22
  - i20 -- i22
notes:
  - text b9: 1 相目
  - text g11: 3 相目
  - text h9: 2 相目
  - text d22a3: N
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/05-three-phase-power.svg)

- 左が 4-1 の三相電源。1 相目・2 相目は AD の W1・W2、3 相目は U1 (TL071) の反転加算回路の出力
- 各相の負荷は C (220 nF) と R (1 kΩ) の直列。3 つの R の下の端が中性点 N で、GND につなぐ。
  平衡なので N に電流は流れず (4-4)、つないでも回路の動きは変わらない
- CH1 は 1 相目の相電圧 (GND 基準)。CH2 は Ra の両端で、**N が GND なので GND 基準で読める**。
  CH2 ÷ 1 kΩ が相電流

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (1 相目を測る)
# 上のブロック: TL071 の入力側と R1・R2、右に 3 相の C + R。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運ぶ
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  Ca: capacitor/film b35 b38 220n
  Ra: resistor d38 d41 1k
  Cb: capacitor/film b42 b45 220n
  Rb: resistor d45 d48 1k
  Cc: capacitor/film b49 b52 220n
  Rc: resistor d52 d55 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, W1, V+, GND, W2, 1-, 2-, 1+, 2+]
wires:
  - AD.V+ -- +t19 red
  - AD.GND -- -t21 black
  - AD.1- -- -t27 black
  - AD.2- -- -t29 black
  - AD.V- -- a13 purple
  - AD.W1 -- a17 yellow
  - AD.1+ -- a35 yellow
  - AD.W2 -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - e25 -- f25 orange
  - j25 -- j42 orange
  - h14 -- h49 blue
  - f35 -- e35 yellow
  - f42 -- e42 orange
  - f49 -- e49 blue
  - a41 -- -t41 black
  - a48 -- -t48 black
  - a55 -- -t55 black
  - AD.2+ -- a38 pink
notes:
  - text small: 35・42・49 列が 1・2・3 相目。R の右の端 (41・48・55 列) が N で、GND のレールへ
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/05-three-phase-power.svg)

- 三相電源の部分 (TL071・R1・R2・Rf と、g・h・j 行で右へ運ぶ線) は 4-4 と同じ
- 各相は C (b 行) と R (d 行) の直列。R の右の端から GND のレール (−t) へ黒い線を渡す。
  3 本の黒い線が中性点 N を GND につなぐ
- 1 相目を測るときは 1+ を 35 列 (1 相目)、2+ を 38 列 (Ca と Ra のつなぎ目)。1− と 2− は GND のレール。
  2 相目は 1+ を 42 列 (a42)、2+ を 45 列 (a45)。3 相目は 1+ を 49 列 (a49)、2+ を 52 列 (a52) に挿し替える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope | CH1 = 相電圧 (500 mV/div)、CH2 = R の電圧 = 1 kΩ × 相電流 (500 mV/div)。Average を 16 回 |
| Math | M1 = C1 × C2 / 1000 (その相の瞬時電力、単位 W、200 µW/div) |
| Measure | CH1・CH2 の Amplitude、CH1 に対する CH2 の Phase (= 力率角 θ)、M1 の Average (= P_1) |

3 つの相を順に測り、M1 の Average を足す。相電流は 0.81 mA で、W1・W2 の電流は加算回路の
0.1 mA と合わせても 1 mA に届かない。

```scope
title: 図3 1 相目 — 相電流 (CH2) は 35.9° 進み、p (Math) の平均 0.328 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 0.810V phase 35.9deg, range: 500mV/div}
math: {expr: ch1 * ch2 / 1000, unit: W, range: 200uW/div, position: 0div}
measure: [vmax, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/05-three-phase-power.svg)

### オシロスコープと発振器

N を GND につないだので、1− と 2− は GND のレールで、測り方は GND 基準のままでよい。
発振器・電源の読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 / W2 | 2 ch の FG の CH1 / CH2。Sine、1 kHz、2 Vpp、CH2 の Phase −120°。出力は High-Z |
| V+ / V− | 2 出力の安定化電源で ±5 V。電流制限は各 10 mA |
| 1+ / 2+ | CH1・CH2 の先端 (1 相目なら 35 列と 38 列)。グランドクリップは 2 本とも GND のレール |

- Math の CH1 × CH2 ÷ 1000 の平均が、その相の P_1。掛け算の無い機種は、CH1 と CH2 の RMS と位相差から
  P_1 = V_p I_p cos θ を出す
- FG の出力の 50 Ω で、1 相あたりの負荷 (1.23 kΩ と加算回路の 10 kΩ の並列) にかかる電圧は 3.7 % 下がり、
  電力は 7 % 下がる (0.985 → 0.914 mW、計算値)。3 相目は下がった 1・2 相目から作られるので、平衡のまま。
  **CH1 の振幅が 1.00 V になるまで FG の振幅を上げる** (約 2.08 Vpp) と、表がそのまま使える

## 見るべき値

計算値 (相電圧の振幅 1 V (実効値 0.707 V)、f = 1 kHz、C = 220 nF (X_C = 723 Ω)、R = 1 kΩ)。

| 量 | 計算 | 値 |
| --- | --- | --- |
| 1 相のインピーダンス | √(1000² + 723²) | 1234 Ω |
| 力率 cos θ (進み) | 1000 / 1234 | 0.810 (θ = 35.9°) |
| 相電流の振幅 (CH2 ÷ 1 kΩ) | 1 V / 1234 Ω | 0.810 mA (CH2 は 0.810 V) |
| CH1 に対する CH2 の Phase | | +35.9° |
| 1 相の電力 P_1 (M1 の Average) | 0.707 × 0.573 mA × 0.810 | **0.328 mW** |
| 3 相の和 P_1 + P_2 + P_3 | 3 × 0.328 | **0.985 mW** |
| 線間電圧 V (実効値) | √3 × 0.707 | 1.225 V |
| 線電流 I (実効値) | 0.810 / √2 | 0.573 mA |
| √3 V I cos θ | √3 × 1.225 × 0.573 mA × 0.810 | **0.985 mW** (3 相の和と同じ) |
| 皮相電力 √3 V I | | 1.215 mVA |
| 無効電力 √3 V I sin θ | | 0.712 mvar |

2 相目・3 相目も、CH1 を基準にした Phase と M1 の Average は 1 相目と同じ (+35.9°、0.328 mW) になる。

分かること:

- **三相電力は 1 相の 3 倍で、線間の量で書くと √3 V I cos θ。** 3 = √3 × √3 の片方が
  線間電圧 (V = √3 V_p) に入ると考えると覚えやすい
- 1 相の瞬時電力 p は 2 kHz で脈打ち、最大 0.733 mW・最小 −0.077 mW (図3)。3 相の p を足すと
  脈が打ち消し合って一定になる (4-15)
- 力率の θ は**相電圧と相電流の角**。線間電圧と線電流の角 (ここでは 5.9° や 65.9°) ではない。
  二電力計法 (4-8) で、線間電圧と線電流の角が 30° ずれることを使う

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
