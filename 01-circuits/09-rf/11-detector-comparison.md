---
book: circuits
chapter: 9
id: 9-11
title: ダイオード検波とトランジスタ検波の比較
tier: 200
source: 自作
board: BB
---

# 9-11 ダイオード検波とトランジスタ検波の比較

AM の電波から音を取り出す**検波**を、2 つのやり方で比べる。9-2 のゲルマラジオの
**ダイオード検波**と、トランジスタのベース・エミッタ間の曲がりで検波して、同時に増幅もする
**トランジスタ検波**だ。Analog Discovery (AD) の W1 で**同じ AM の試験信号**
(搬送波 100 kHz、音 1 kHz、変調度 50 %) を作り、弱い入力と強い入力で出力の大きさと歪みを測る。

結論を先に書く。**弱い入力ではトランジスタ検波が約 660 倍大きな音を出し、
強い入力ではダイオード検波のほうがずっときれいな音を出す。** 検波の曲線のどこを
使っているかが、この差を決める。

- **2 乗検波と直線検波**: ダイオードの電流は電圧の指数関数で増える。入力が小さい
  (ゲルマニウムで数十 mV 以下) うちは、指数関数の頭の 2 乗の項だけが効いて、出力は
  **入力の 2 乗**に比例する (2 乗検波)。入力が十分大きいと、ダイオードは搬送波の山でだけ
  C を充電し、出力は**包絡線 (振幅の外形) をそのままなぞる** (直線検波)
- **2 乗検波は歪む**: 包絡線を A(1 + m sin ωt) とすると、2 乗は
  A²(1 + m²/2 + 2m sin ωt − (m²/2) cos 2ωt)。音 (ω) に対する 2 倍の音 (2ω) の比は
  **m/4**。変調度 m = 50 % なら **12.5 %** の 2 次歪みになる。これはダイオードでも
  トランジスタでも同じ
- **トランジスタ検波**: 2SC1815 のベースをわずかに順方向にバイアスし (コレクタ電流
  約 0.094 mA)、搬送波をベースに入れる。コレクタ電流は V<sub>BE</sub> の指数関数
  I<sub>C</sub> ∝ exp(V<sub>BE</sub>/26 mV) なので、ダイオードと同じく 2 乗検波が起きる。
  違いは、その電流の変化を**コレクタ抵抗 22 kΩ で電圧に変える**ので、検波と一緒に
  大きく増幅されること
- **トランジスタ検波は強い入力で振り切れる**: 搬送波の振幅が 26 mV の何倍にもなると、
  電流は包絡線の山で桁違いに増え、谷でほぼ 0 になる。コレクタの電圧は 0.6 V (飽和) と
  5 V (遮断) の間を行き来し、音は方形波に近くつぶれる

**計算の方法**: 下の値は、ダイオードの式 I = I<sub>S</sub>(exp(V/(n V<sub>T</sub>)) − 1)
(1N60 相当として、飽和電流 I<sub>S</sub> = 0.5 µA・理想係数 n = 1.2) と、
トランジスタの式 I<sub>C</sub> = I<sub>S</sub> exp(V<sub>BE</sub>/V<sub>T</sub>) を、1 µs より細かい刻みで解いた計算値。
V<sub>T</sub> = 25.85 mV は室温の熱電圧 (kT/q)。歪み率 (THD) は、出力の 1 kHz に対する 2〜5 倍の音 (高調波) の比。

## 回路図

### ダイオード検波

```circuit
title: 図1 ダイオード検波 (W1 の AM を D1 で検波し、CH2 と CH1 で比べる)
parts:
  W1: sine 2,3 2,5 l=$\mathrm{W1}$
  GW: ground 2,5
  M2: voltmeter 4,3 4,5 l=$\mathrm{CH2}$
  G2: ground 4,5
  D1: diode 5,3 8,3 1N60
  C1: capacitor 10,3 10,5 10n
  GC: ground 10,5
  R1: resistor 12,3 12,5 10k
  GR: ground 12,5
  M1: voltmeter 14,3 14,5 l=$\mathrm{CH1}$
  G1: ground 14,5
wires:
  - 2,3 -- 4,3
  - 4,3 -- 5,3
  - 8,3 -- 10,3
  - 10,3 -- 12,3
  - 12,3 -- 14,3
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/11-detector-comparison-1.svg)

- 9-2 のゲルマラジオの検波部と同じ形。**バイアスは掛けない** (9-3 のように直流を流して
  立ち上がりに乗せる工夫はしない)。ダイオードの曲がりそのものを見るため
- 負荷 C1 (10 nF) ∥ R1 (10 kΩ) の時定数は **100 µs**。搬送波の周期 10 µs より十分長く
  (山の間の放電が小さい)、音の周期 1 ms より短い。変調度 m の包絡線を追える上限は
  √(1 − m²)/(2π f<sub>m</sub> m) = 0.866/(2π × 1 kHz × 0.5) ≈ **276 µs** で、100 µs は
  その内側 (谷で包絡線に置いていかれる「斜めのクリップ」が起きない)

### トランジスタ検波

```circuit
title: 図2 トランジスタ検波 (ベースで検波し、コレクタで増幅して取り出す)
parts:
  VCC: vcc 5,1 5V
  R1: resistor 5,1 5,4 68k
  R2: resistor 5,4 5,6 18k
  G2: ground 5,6
  RC: resistor 7,1 7,3 22k
  Q1: npn 7,4
  CIN: capacitor 5,4 3,4 0.1u
  W1: sine 1,4 1,6 l=$\mathrm{W1}$
  M2: voltmeter 3,4 3,6 l=$\mathrm{CH2}$
  G4: ground 3,6
  RE: resistor 7,6 7,8 4.7k
  G3: ground 7,8
  CE: capacitor 9,6 9,8 100u
  CC: capacitor 11,3 11,5 2.2n
  GC: ground 11,5
  M1: voltmeter 14,3 14,5 l=$\mathrm{CH1}$
  G5: ground 14,5
wires:
  - 5,1 -- 7,1
  - 1,4 -- 3,4
  - 1,6 -- 3,6
  - 5,4 -- Q1.B
  - 7,3 -- Q1.C
  - 7,3 -- 11,3
  - 11,3 -- 14,3
  - Q1.E -- 7,6
  - 7,6 -- 9,6
  - 7,8 -- 9,8
notes:
  - text 7.5,4.7 small left: 2SC1815
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/11-detector-comparison-2.svg)

`+5V` は AD の電源出力 V+ (WaveForms の Supplies で 5 V にする)。形は 2-3 の
エミッタ接地増幅と同じで、値だけを検波向きに変えてある。

- **動作点**: R1・R2 の分圧で V<sub>B</sub> = 5 V × 18k/86k ≈ **1.05 V**。
  V<sub>E</sub> ≈ 1.05 − 0.61 ≈ 0.44 V、I<sub>C</sub> ≈ 0.44 V / 4.7 kΩ ≈ **0.094 mA**。
  V<sub>C</sub> = 5 − 0.094 mA × 22 kΩ ≈ **2.93 V**。電流を 2-3 (0.93 mA) の 1/10 に絞り、
  V<sub>BE</sub>–I<sub>C</sub> の曲がりが効く所で使う
- **CE (100 µF) は搬送波も音も素通しする**。エミッタの電圧は音の周期でも動かず、
  ベースに入った搬送波がそのまま V<sub>BE</sub> を振る。一方、直流では RE が効くので、
  平均のコレクタ電流は 0.094 mA に保たれる (RE × CE = 0.47 s より遅い変化だけ)
- **CC (2.2 nF) で搬送波を落とす**。RC × CC = 48 µs で、音の 1 kHz はほぼ通し
  (−0.4 dB)、100 kHz の残りは約 1/30 になる
- **出力は反転する**。包絡線が大きい所ほどコレクタ電流が増えて、V<sub>C</sub> が下がる
- CH1 は**直流結合**でコレクタを見る。動作点 (約 2.9 V) と、振り切れる上下の端
  (0.6 V と 5 V) が画面で読めるように

## 実体配線図

2 つの検波器を別々に組む。AD の W1 と CH1・CH2 は、測る回路へ付け替える。

```breadboard
title: 図3 ダイオード検波を組む (W1 と CH2 を 5 列、CH1 を 10 列へ)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 2+, W1, 2-, 1-, 1+]
  D1: diode c5(A) c10(K) 1N60
  C1: capacitor/ceramic b10 b13 10n
  R1: resistor d10 d17 10k
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 blue
  - AD.2- -- -t7 black
  - AD.1+ -- a10 orange
  - AD.1- -- -t9 black
  - a13 -- -t13 black
  - a17 -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/11-detector-comparison-1.svg)

- **入力 (5 列)**: W1 (黄) を `a5`、CH2 の 2+ (青) を `b5` に挿す。D1 のアノードも同じ列 (`c5`)
- **出力 (10 列)**: D1 のカソード (`c10`・帯の側)、C1 の左リード (`b10`)、R1 の左リード (`d10`) が同じ列。
  CH1 の 1+ (橙) を `a10` に挿す
- C1 の右リード (13 列) と R1 の右リード (17 列) は、黒の線で上の − レール (GND) へ
- AD の GND・2−・1− (黒) も上の − レールへ。この回路は電源を使わない

```breadboard
title: 図4 トランジスタ検波を組む (W1 と CH2 を 5 列、CH1 を 20 列へ)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 2+, W1, 2-, 1-, 1+]
  R1: resistor b3 b9 68k
  R2: resistor c9 c13 18k
  RC: resistor b15 b20 22k
  Q1: transistor e19(B) e20(C) e21(E) 2SC1815
  CIN: capacitor/ceramic d5 d9 0.1u
  RE: resistor a21 -t21 4.7k
  CE: capacitor/electrolytic b21(+) b29(-) 100uF
  CC: capacitor/ceramic c20 c23 2.2n
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 blue
  - AD.2- -- -t7 black
  - AD.1+ -- a20 orange
  - AD.1- -- -t18 black
  - +t3 -- a3 red
  - a13 -- -t13 black
  - e9 -- d19 orange [v10]
  - +t15 -- a15 red
  - a23 -- -t23 black
  - a29 -- -t29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/11-detector-comparison-2.svg)

2-3 のブレッドボードと同じ並びで、値を検波向きに替え、CC を足した。5V は AD の V+ (赤) から上の + レールへ。

- **Q1 は上のブロック** (`e19` B・`e20` C・`e21` E)
- **入力 (5 列)**: W1 (黄) を `a5`、CH2 の 2+ (青) を `b5`。CIN (0.1 µF) が 5 列から 9 列へ渡す
- **ベース (9 列)**: R1 の下端・R2 の上端・CIN の右リード。橙の線 1 本 (`e9`–`d19`) で Q1 の B へ
- **コレクタ (20 列)**: RC の下端 (`b20`)、CC の左リード (`c20`)、Q1 の C (`e20`)。CH1 の 1+ (橙) を `a20` に挿す。
  CC の右リード (23 列) は黒の線で − レールへ
- **エミッタ (21 列)**: RE を − レールへ縦に挿し、CE の + 側も同じ列。CE の − 側 (29 列) は − レールへ
- AD の GND・2−・1− (黒) は上の − レールへ

## 計器の設定

Analog Discovery だけを使う。搬送波は 100 kHz、音は 1 kHz で、どちらもオシロ (10 MHz 以下) で波形が見え、W1 の AM 変調で試験信号も作れるため。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を 5 V (図2 だけ) |
| Wavegen (W1) | Modulation。Carrier: Sine 100 kHz・Offset 0 V。AM: Sine 1 kHz・Index 50 %。振幅は弱い入力で 20 mV (40 mVpp)、強い入力で 1 V (2 Vpp) |
| Scope | CH2 = 入力 (W1)、CH1 = 検波出力。どちらも DC 結合。時間 200 µs/div、トリガは CH1 の立ち上がり (図8 だけ立ち下がり)。縦のレンジは図5〜図8 の画面の下に書いた値 |
| 弱い入力のとき | Average を 16 回ほど。図1 の出力は 1 mVpp に満たず、雑音に埋もれやすい |

同じ W1 の設定を、図1 と図2 の入力に付け替えて使う (2 つの回路を同時にはつながない)。

## 計器の画面

2 つの検波器に、弱い入力と強い入力を入れた 4 枚。CH2 (入力) は発生器の式、CH1 (出力) は
その CH2 を検波の操作に通して作った。

- ダイオード・弱い入力 (図5): 2 乗の式 (`ch2 * ch2`) を 100 µs の RC で平らにする
- ダイオード・強い入力 (図7): 順方向電圧 (約 0.25 V) を引き、山で充電して 100 µs で放電する (`peak`)
- トランジスタ (図6・図8): コレクタ電流の指数関数 exp((V<sub>in</sub> − ΔV)/25.85 mV) に 22 kΩ を掛け、
  48 µs の RC で平らにする。ΔV は平均の電流を 0.094 mA に保つエミッタの上がり分
  (弱い入力で 4 mV、強い入力で 1.213 V)。強い入力は、電流の山を約 1.8 mA で
  (22 kΩ で 40 V ぶん) 頭打ちにし、V<sub>C</sub> を 0.6 V (飽和) で切る近似

### 弱い入力 (搬送波 20 mV)

```scope
title: 図5 ダイオード検波・弱い入力 — 出力は 1mVpp に届かない
time: 200us/div
trigger: ch1 rising 0.46mV
ch2: {wave: "= 20mV * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t)", range: 20mV/div, position: 2.5div}
ch1: {wave: "= 2.05 * (20mV * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t))^2 / 1V | rc 100us", range: 200uV/div, position: -3.5div}
measure: [vpp, avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/11-detector-comparison-1.svg)

```scope
title: 図6 トランジスタ検波・弱い入力 — 同じ入力で約 0.66Vpp、反転して出る
time: 200us/div
trigger: ch1 rising 2.91V
ch2: {wave: "= 20mV * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t)", range: 20mV/div, position: 2.5div}
ch1: {wave: "= 5V - min(2.07V * exp((20mV * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t) - 4mV) / 25.85mV), 40V) | rc 48us", range: 200mV/div, position: -16.25div}
measure: [vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/11-detector-comparison-2.svg)

### 強い入力 (搬送波 1 V)

```scope
title: 図7 ダイオード検波・強い入力 — 包絡線をなぞる
time: 200us/div
trigger: ch1 rising 0.76V
ch2: {wave: "= 1V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t)", range: 1V/div, position: 2.5div}
ch1: {wave: = 1V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t) | offset -0.25V | clip 0V | peak 100us, range: 500mV/div, position: -4div}
measure: [vpp, avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/11-detector-comparison-3.svg)

```scope
title: 図8 トランジスタ検波・強い入力 — 0.6V と 5V の間で振り切れる
time: 200us/div
trigger: ch1 falling 2.8V
ch2: {wave: "= 1V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t)", range: 1V/div, position: 2.5div}
ch1: {wave: "= 5V - min(2.07V * exp((1V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 100kHz * t) - 1.213V) / 25.85mV), 40V) | rc 48us | clip 0.6V 5V", range: 1V/div, position: -4div}
measure: [vpp, avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/11-detector-comparison-4.svg)

## 見るべき値

計算値。入力は W1 の AM (搬送波 100 kHz、音 1 kHz、変調度 50 %)。

| 入力 (搬送波の振幅) | 検波 | 出力の音 (1 kHz の振幅) | 出力の Vpp | 出力の直流 | 歪み率 (THD) |
| --- | --- | --- | --- | --- | --- |
| 20 mV (40 mVpp) | ダイオード (図5) | 0.41 mV | 約 0.70 mVpp | 約 0.46 mV | 約 10 % (2 次) |
| 20 mV (40 mVpp) | トランジスタ (図6) | 0.27 V | 約 0.66 Vpp | 約 2.85 V | 約 13 % |
| 1 V (2 Vpp) | ダイオード (図7) | 0.46 V | 約 1.02 Vpp | 約 0.72 V | 約 1 % |
| 1 V (2 Vpp) | トランジスタ (図8) | 2.6 V (基本波) | 約 4.40 Vpp | 約 3.56 V | 約 53 % |

- **弱い入力の出力の比は約 660 倍** (0.27 V / 0.41 mV)。トランジスタ検波は 2 乗検波の
  電流の変化を 22 kΩ で電圧にするぶん大きい。ダイオード検波の 0.41 mV では
  クリスタルイヤホンはまず鳴らない
- 弱い入力の歪みは**どちらも 10〜13 %** で、2 乗検波の m/4 = 12.5 % に近い
  (図5・図6 の波形は、谷より山が尖る)
- **強い入力ではダイオードが 1 %、トランジスタが 53 %**。ダイオードは包絡線 (0.5〜1.5 V) から
  約 0.25 V 低い所をなぞり、出力の音は入力の包絡線の振幅 0.5 V とほぼ同じ。
  トランジスタは包絡線の山の近くで飽和 (0.6 V)、谷の近くで遮断 (5 V) に張り付く
- 入力を 20 mV から 1 V へ 50 倍にすると、ダイオードの出力は約 1,100 倍 (0.41 mV → 0.46 V)、
  トランジスタの出力は約 10 倍 (0.27 V → 2.6 V)。**ダイオードは弱い所で 2 乗 (感度が低い)、
  トランジスタは強い所で頭打ち**。中間の 0.1 V では、ダイオード 15 mV (歪み 15 %)、
  トランジスタ 2.3 V (歪み 30 %) で、2 つの弱点がちょうど入れ替わる所にいる
- 実際のラジオはこの 2 つを組み合わせる。検波の前で高周波を増幅して**ダイオードに十分大きな
  搬送波を渡す** (9-9 の 2 石ラジオ、9-10 のスーパーヘテロダイン)、または 9-3 のように
  ダイオードに直流を流して立ち上がりに乗せる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1 | ゲルマニウムダイオード | 1N60 |
| C1 | セラミックコンデンサ | 10 nF |
| R1 (図1) | 抵抗 (1/4 W) | 10 kΩ |
| R1 (図2) | 抵抗 (1/4 W) | 68 kΩ |
| R2 | 抵抗 (1/4 W) | 18 kΩ |
| RC | 抵抗 (1/4 W) | 22 kΩ |
| RE | 抵抗 (1/4 W) | 4.7 kΩ |
| CIN | セラミックコンデンサ | 0.1 µF |
| CC | セラミックコンデンサ | 2.2 nF |
| CE | 電解コンデンサ | 100 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 信号源・オシロ・電源 | Analog Discovery (W1、CH1・CH2、V+ 5 V) |

## 出典

自作。
2 乗検波の歪み (m/4) と、RC の負荷が包絡線を追える条件 (時定数 ≤ √(1 − m²)/(ω<sub>m</sub> m)) は、
AM の検波の教科書的な結果による (例: [Envelope detector — Wikipedia](https://en.wikipedia.org/wiki/Envelope_detector))。
