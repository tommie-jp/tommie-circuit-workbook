---
book: circuits
chapter: 9
id: 9-23
title: I/Q をマイコンで読む — Pico 2 の ADC で位相と大きさを計算する
tier: 200
source: 自作
board: BB
era: 今
---

# 9-23 I/Q をマイコンで読む — Pico 2 の ADC で位相と大きさを計算する

9-22 の Tayloe 検波器は、RF を LO の周りの低い周波数の **I と Q** の 2 本に下ろした。
2 本の先後で「RF が LO の上か下か」が分かり、2 本の大きさで RF の強さが分かる。
ここまではオシロで目で読んでいた。この題では、I と Q を **Raspberry Pi Pico 2 の ADC で読み、
位相・周波数・大きさを式で計算する**。検波も復調も、ここから先は計算になる。これがソフトウェア無線 (SDR) の入口だ。

**I と Q を 1 つの複素数とみる。** 時刻 t の I と Q を z = I + jQ と書くと、z は平面の上の 1 点になる。
RF と LO の差が Δf なら、点は半径一定のまま 1 秒に Δf 回まわる (2-5 の XY の円と同じ)。だから

- **位相** φ = atan2(Q, I) (点の向き)。続けて読み、2π の飛びをつないで (unwrap) 1 本の量にする
- **周波数** Δf = (1/2π) × dφ/dt (向きの変わる速さ)。**回る向き (符号) が RF の上・下**を言う
- **大きさ** A = √(I² + Q²) (円の半径)。位相に関係なく一定に出る

1 本 (I だけ) では、cos は Δf の符号で変わらず、振幅も位相と一緒に揺れるので、この 3 つを分けられない。
2 本そろって初めて計算できる。

**符号に注意。** 9-22 と同じ配線 (1Q → S0、2Q → S1、I = A0 − A3、Q = A1 − A2) では、
RF が LO より上 (499 kHz) のとき **Q が I より 90° 進む**。I = cos ωt、Q = −sin ωt なので、
I + jQ = e<sup>−jωt</sup> は**負の向き**に回り、atan2(Q, I) は減っていく。
そこでプログラムは **atan2(−Q, I)** を使い、上なら正 (+1.000 kHz) と出るようにした。
I と Q を入れ替える、または S0 と S1 の線を入れ替えると、符号は逆になる。

**この題で変えたこと** (9-22 から):

- **電源を Pico 2 の 3V3 (3.3 V) にした。** Pico 2 の ADC が読めるのは 0〜3.3 V なので、
  74HC74・74HC4052・オペアンプをすべて同じ 3.3 V で動かし、出口がこの範囲に収まるようにする。
  W1 の方形波も 0〜3.3 V、W2 の直流の偏りも 1.65 V にする
- **I と Q を MCP6002 の差動増幅 (利得 2) で 1 本ずつの電圧にした。** ADC は GND を基準に 1 本ずつ読むので、
  差 (A0 − A3) を 1.65 V を中心にした 1 本の電圧に直す。出力は 1.65 V ± 2 × (A0 − A3)
- **差動増幅の抵抗は 100 kΩ / 200 kΩ にした (10 kΩ / 20 kΩ にしない)。**
  Tayloe のコンデンサは 1 周期の 1/4 しかスイッチにつながらず、残りの間は差動増幅の入力の抵抗が電荷を抜く。
  スイッチ側の抵抗は実質 4 × (1 kΩ + R<sub>on</sub>) ≈ 4.4 kΩ で、10 kΩ の入力を付けると無視できない。
  スイッチと RC を時間で解いた計算 (R<sub>on</sub> 100 Ω) では、1 kHz の I の振幅は負荷なしで 0.434 V、
  10 kΩ / 20 kΩ で 0.307 V (−3.0 dB)、**100 kΩ / 200 kΩ で 0.417 V (−0.35 dB)** だった。
  MCP6002 の入力電流は pA の桁なので、100 kΩ 台でも誤差にならない

**なぜ 500 kS/s で読むのか。** RP2350 の ADC は 1 つしかなく、ADC0 (I) と ADC1 (Q) を**交互に**読む
(ラウンドロビン)。全体の速さは 48 MHz ÷ 96 = **500 kS/s** で、I と Q の間は **2 µs**。
1 kHz の I/Q にとって 2 µs は **0.72°** (360° × 1 kHz × 2 µs) で、円はほとんど崩れない。
このあと 10 個ずつ平均して、**I と Q をそれぞれ 25 kS/s** にする (平均は 40 µs の窓の低域フィルタにもなる)。
I を読んでから Q を読むまでが長いと、その時間がそのまま位相のずれになる。例えば 250 µs 空くと、1 kHz では 90° ずれ、
Q が I と同じ形になって円が直線につぶれる (上・下の区別が消える)。
**速く交互に読み、平均で落とす**のが I/Q を正しく読むこつだ。読み取りは DMA (CPU を通さずに ADC の値をメモリへ運ぶ仕組み) に任せ、
CPU は 4 ms ごとに届く 2000 個の値を計算するだけにする。

**RTL-SDR との関係。** 安い USB の SDR (RTL-SDR) が PC に送ってくるのも、まさにこの I と Q の数の列
(8 bit、毎秒 240 万組など) だ。PC の SDR のソフトは、ここで書く atan2 と √(I² + Q²) と同じ計算で AM・FM を復調している。
この題は、その計算を手の届く速さ (25 kS/s) で 1 から書いてみる。

## 回路図

```circuit
title: 図1 Tayloe 検波器 (3.3 V。A0・A1・A2・A3 は図2 の差動増幅へ)
parts:
  P1: vcc 6,5 3.3V
  U1: ic 8,8 74HC74
  G2: ground 8,10
  W1: square 3.5,10 3.5,12 l=$\mathrm{W1}$
  G1: ground 3.5,12
  U2: ic 35,8 74HC4052
  P1: vcc 35,4 3.3V
  G3: ground 34,12
  G4: ground 38.5,10
  C1: capacitor 19.5,12 19.5,14 10n
  G5: ground 19.5,14
  C2: capacitor 23.5,12 23.5,14 10n
  G6: ground 23.5,14
  C3: capacitor 27.5,12 27.5,14 10n
  G7: ground 27.5,14
  C4: capacitor 31.5,12 31.5,14 10n
  G8: ground 31.5,14
  X1:
    type: device
    at: 15,17
    pins: [A0, A1, A2, A3]
    turn: mirror
  R1: resistor 39,8 41,8 1k
  W2: sine 42,8 42,10 l=$\mathrm{W2}$
  G9: ground 42,10
  P1: vcc 3,18 3.3V
  C5: capacitor 3,18 3,20 100n
  G10: ground 3,20
  P1: vcc 7,18 3.3V
  C6: capacitor 7,18 7,20 100n
  G11: ground 7,20
wires:
  - 6,5 -- 9,5
  - 7,5 |- U1.VCC
  - 7.5,5 |- U1.1PRE
  - 8,5 |- U1.1CLR
  - 8.5,5 |- U1.2PRE
  - 9,5 |- U1.2CLR
  - U1.GND |- 8,10
  - U1.1CLK -| 3.5,8
  - 3.5,8 -- 3.5,9
  - U1.2CLK -| 3.5,9
  - 3.5,9 -- 3.5,10
  - U1./2Q -| 11,9
  - 11,9 -- 11,14 -- 1,14 -- 1,7.5
  - 1,7.5 -| U1.1D
  - U1.1Q -| 11.5,7.5
  - 11.5,7.5 -- 13,7.5
  - 13,7.5 -- 13,20
  - 11.5,7.5 -- 11.5,2 -- 2,2 -- 2,8.5
  - 2,8.5 -| U1.2D
  - U1.2Q -| 12,8.5
  - 12,8.5 -- 12,21
  - 13,20 -| U2.S0
  - 12,21 -| U2.S1
  - U2.VCC |- 35,4
  - 34,12 |- U2.GND
  - U2.VEE |- 34.5,12
  - U2.E |- 35,12
  - 34,12 -- 35,12
  - U2.BN -| 38.5,10
  - U2.A0 -| 18,6.5
  - 18,6.5 -- 18,12
  - U2.A1 -| 22,7
  - 22,7 -- 22,12
  - U2.A2 -| 26,7.5
  - 26,7.5 -- 26,12
  - U2.A3 -| 30,8
  - 30,8 -- 30,12
  - 18,12 -- 19.5,12
  - 22,12 -- 23.5,12
  - 26,12 -- 27.5,12
  - 30,12 -- 31.5,12
  - X1.A0 -| 18,12
  - X1.A1 -| 22,12
  - X1.A2 -| 26,12
  - X1.A3 -| 30,12
  - U2.AN -| 39,8
  - 41,8 -- 42,8
notes:
  - text 4,11 small left: 1.992 MHz (0 - 3.3 V)
  - text 43,9 small left: 499 kHz
  - text 43,10 small left: 直流 1.65 V
  - text 15,19 small center: 図2 の差動増幅へ
  - text 5,21 small center: パスコン (C5 は U1、C6 は U2)
  - text 25,19.5 small center: LO 0° (S0)
  - text 25,22 small center: LO 90° (S1)
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/23-iq-pico2-adc-1.svg)

回路図は 2 枚に分けた。図1 が Tayloe 検波器、図2 が I と Q の差動増幅と Pico 2 だ。
図1 の左下の箱 X1 と図2 の左の箱 X2 は部品ではなく、A0〜A3 の 4 本の線が図をまたいで続くことを示す。

- **右**: W2 (RF) を R1 (1 kΩ) を通して U2 (74HC4052) の AN (PIN 13) へ。W2 は 0.5 V<sub>pp</sub>・直流 1.65 V にして、
  部品を足さずに 3.3 V の電源の真ん中に偏らせる。A0〜A3 は C1〜C4 (10 nF) で GND へ (9-22 と同じ)
- U2 はピンを働きで並べた箱で描いた (左にチャネル、右に共通の AN、下に GND・VEE・E・S0・S1)。
  この箱は左右を裏返せず、共通の AN が右にあるので、**RF は右から入り、左の C1〜C4 へ流れる**
- **左**: W1 (1.992 MHz、0〜3.3 V の方形波) で 74HC74 の 2 つのフリップフロップを同時に叩く。
  1D ← /2Q、2D ← 1Q のジョンソンカウンタで、(Q1, Q2) が 00 → 10 → 11 → 01 と回る。
  **S0 ← 1Q、S1 ← 2Q** なので (S1, S0) は 00 → 01 → 11 → 10 で、選ばれる出口は **A0 → A1 → A3 → A2** (0°・90°・180°・270°)。
  番号の順ではない。だから **I = A0 − A3、Q = A1 − A2** (9-22 と同じ)。帰還の 2 本は箱の上と下を回り、
  線の交差が 2 か所ある (黒丸の無い交差はつながっていない)
- C5・C6 (100 nF) は U1・U2 の電源のパスコン

```circuit
title: 図2 I と Q の差動増幅から Pico 2 の ADC へ
parts:
  X2:
    type: device
    at: 4,6.75
    pins: [A0, A3, A1, A2]
    turn: mirror
  R2: resistor 9,6 11,6 100k
  R4: resistor 9,8 11,8 100k
  R3: resistor 11,4 11,6 200k
  VREF: vcc 11,4 1.65V
  U3A: opamp 13,7 +up MCP6002
  R5: resistor 11,9 14,9 200k
  R6: resistor 9,15 11,15 100k
  R8: resistor 9,17 11,17 100k
  R7: resistor 11,13 11,15 200k
  VREF: vcc 11,13 1.65V
  U4A: opamp 13,16 +up MCP6002
  R9: resistor 11,18 14,18 200k
  M1: voltmeter 18,7 18,9 l=$\mathrm{CH1}$
  G1: ground 18,9
  M2: voltmeter 18,16 18,18 l=$\mathrm{CH2}$
  G2: ground 18,18
  U5:
    type: device
    at: 25,11
    label: Pico 2
    pins: [3V3, GP26, GP27, GND]
  P1: vcc 23.5,8 3.3V
  G3: ground 23.5,13
  P1: vcc 3,21 3.3V
  R10: resistor 3,21 3,23 10k
  R11: resistor 3,23 3,25 10k
  G4: ground 3,25
  U4B: opamp 7,23 +down MCP6002
  VREF: vcc 9,21 1.65V
  U3B: opamp 13,23 +down MCP6002
  G5: ground 11,24
  P1: vcc 19,21 3.3V
  C7: capacitor 19,21 19,23 100n
  G6: ground 19,23
  P1: vcc 22,21 3.3V
  C8: capacitor 22,21 22,23 100n
  G7: ground 22,23
wires:
  - X2.A0 -| 9,6
  - X2.A3 -| 8,8
  - 8,8 -- 9,8
  - X2.A1 -| 7,15
  - 7,15 -- 9,15
  - X2.A2 -| 6,17
  - 6,17 -- 9,17
  - U3A.+ -| 11,6
  - U3A.- -| 11,8
  - 11,8 -- 11,9
  - 14,9 -- 14,7
  - U3A.out -- 14,7
  - U4A.+ -| 11,15
  - U4A.- -| 11,17
  - 11,17 -- 11,18
  - 14,18 -- 14,16
  - U4A.out -- 14,16
  - 14,7 -- 18,7
  - 18,7 -- 22,7
  - U5.GP26 -| 22,7
  - 14,16 -- 18,16
  - 18,16 -- 22.5,16
  - U5.GP27 -| 22.5,16
  - U5.3V3 -| 23.5,8
  - U5.GND -| 23.5,13
  - 3,23 -- 5,23
  - U4B.+ -| 5,23
  - U4B.- -| 6,21
  - 6,21 -- 9,21
  - 9,21 -- 9,23
  - U4B.out -- 9,23
  - U3B.+ -| 11,24
  - U3B.- -| 12,21
  - 12,21 -- 15,21
  - 15,21 -- 15,23
  - U3B.out -- 15,23
notes:
  - text 4,4 small center: 図1 の C1 - C4 から
  - text 20,6.5 small center: I (ADC0)
  - text 20,15.5 small center: Q (ADC1)
  - text 7,25 small center: U4B で VREF (+1.65 V) を作る
  - text 20.5,24 small center: パスコン (C7 は U3、C8 は U4)
  - text 17,25 small left: U3・U4 (MCP6002) の電源は PIN 8 が +3.3V、PIN 4 が GND
  - text 17,26 small left: U3B は使わない (+ を GND、- を出力へつなぐ)
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/23-iq-pico2-adc-2.svg)

- **上**: U3A が I の差動増幅。R2 (100 kΩ)・R3 (200 kΩ) で + 入力を (2·A0 + VREF)/3 にし、
  R4 (100 kΩ)・R5 (200 kΩ) で出力 = **VREF + 2 × (A0 − A3)**。出力は Pico 2 の **GP26 (ADC0)** へ
- **下**: U4A が Q の差動増幅。I と同じ形で、出力 = VREF + 2 × (A1 − A2) を **GP27 (ADC1)** へ。
  I も Q も左から右へ流れ、右端の Pico 2 に入る
- **左下**: VREF (+1.65 V) は 3.3 V を R10・R11 (10 kΩ ずつ) で半分にし、U4B のボルテージフォロワで低い出力抵抗にしたもの。
  R3 と R7 (200 kΩ) へ配る。U3B は使わないので、+ を GND、− を出力につないで遊ばせる
- **電源**: すべて Pico 2 の **3V3 (PIN 36)** から。MCP6002 は 1.8〜6 V、74HC は 2〜6 V で動く。
  C7・C8 (100 nF) は U3・U4 の電源のパスコン
- CH1・CH2 は AD3 の Scope。ADC の入口 (GP26・GP27) を GND に対して見る

## 実体配線図

```breadboard
title: 図3 ブレッドボードに組む (Pico 2 は図4 の別のブレッドボード)
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, W2, GND]
  PI:
    type: device
    at: bottom
    label: 図4 の GP26 へ
    pins: [I]
  PQ:
    type: device
    at: bottom
    label: 図4 の GP27 へ
    pins: [Q]
  PP:
    type: device
    at: bottom
    label: 図4 の 3V3・GND へ
    pins: [3V3, GND]
  U1: dip14 @ e2 74HC74
  U2: dip16 @ e12 r180 74HC4052
  U3: dip8 @ e30 MCP6002
  U4: dip8 @ e50 MCP6002
  R1: resistor i10 i16 1k
  C1: capacitor/ceramic j15 -b15 10n
  C2: capacitor/ceramic j17 -b17 10n
  C3: capacitor/ceramic j18 -b18 10n
  C4: capacitor/ceramic j14 -b14 10n
  R4: resistor g23 g31 100k
  R2: resistor i22 i32 100k
  R5: resistor j30 j31 200k
  R3: resistor h32 h38 200k
  R8: resistor g43 g51 100k
  R6: resistor i42 i52 100k
  R9: resistor j50 j51 200k
  R7: resistor h52 h58 200k
  R10: resistor d55 d60 10k
  R11: resistor a55 -t55 10k
  C5: capacitor/ceramic +t9 -t9 100n
  C6: capacitor/ceramic +b21 -b21 100n
  C7: capacitor/ceramic +t29 -t29 100n
  C8: capacitor/ceramic +t49 -t49 100n
wires:
  - +t1 -- +b1 red
  - -t62 -- -b62 black
  - a2 -- +t2 red
  - a3 -- +t3 red
  - a6 -- +t6 red
  - j2 -- +b2 red
  - j5 -- +b5 red
  - j8 -- -b8 black
  - AD.W1 -- b5 green
  - c5 -- i4 green
  - g6 -- g13 blue
  - h6 -- d4 blue
  - d7 -- h12 purple
  - c8 -- h3 white
  - AD.W2 -- j10 yellow
  - AD.GND -- -t26 black
  - a12 -- -t12 black
  - a13 -- -t13 black
  - a14 -- -t14 black
  - a17 -- -t17 black
  - j19 -- +b19 red
  - h14 -- h23 orange
  - g15 -- g22 orange
  - i17 -- b20 brown [v10, h70]
  - i18 -- c21 pink
  - b20 -- b42 brown
  - c21 -- c43 pink
  - d42 -- h42 brown
  - d43 -- h43 pink
  - a30 -- +t30 red
  - j33 -- -b33 black
  - d31 -- d32 gray
  - a33 -- -t33 black
  - a50 -- +t50 red
  - j53 -- -b53 black
  - c51 -- c52 gray
  - c55 -- c53 gray
  - a60 -- +t60 red
  - a51 -- i38 gray
  - b51 -- i58 gray [h170]
  - h30 -- PI.I orange [h-25]
  - h50 -- PQ.Q brown [h-10]
  - PP.3V3 -- +b61 red
  - PP.GND -- -b60 black
notes:
  - text: レールは上下とも 赤 = +3.3V (図4 の Pico 2 の 3V3)、青 = GND
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/23-iq-pico2-adc-1.svg)

- ブレッドボードは **full (63 列)**。部品が多いので、Pico 2 は図4 の別のハーフのブレッドボードに挿し、
  I・Q・3V3・GND の 4 本のジャンパ線でつなぐ (図3 の下の 3 つの箱)
- **電源**: 図4 の Pico 2 の 3V3 を図3 の下の + レールへ (赤)、GND を − レールへ (黒)。
  上下のレールは 1 列 (+、赤) と 62 列 (−、黒) で渡す。**図3 の + レールはどれも +3.3 V** (5 V ではない)
- **U1 (74HC74)** は 2〜8 列。VCC・2CLR・2PRE (上の列) と 1CLR・1PRE (下の列) は + レールへ、GND (8 列の下) は − レールへ。
  W1 (緑) は 2CLK (5 列の上) に挿し、緑の線で 1CLK (4 列の下) へも渡す。
  1Q (6 列の下) は青で S0 と 2D へ、2Q (7 列の上) は紫で S1 へ、/2Q (8 列の上) は白で 1D へ
- **U2 (74HC4052)** は 12〜19 列に**逆向き (切り欠きが右)** に挿す。信号のピン (S1・S0・A3・A0・AN・A1・A2) が下の列に、
  GND・VEE・E・BN が上の列に並び、上の − レールへ短く落とせるため。VCC (19 列の下) は下の + レールへ。
  B0〜B3 は使わない (開けておく。スイッチの B 側は BN = GND とつながるだけ)
- **RF**: W2 (黄) を 10 列へ。R1 (1 kΩ、i10〜i16) で AN (16 列) へ。C1〜C4 (103) は A0・A3・A1・A2 の列の j 行から − レールへ
- **I の差動増幅 (U3 の下の半分、30〜33 列)**: A3 (14 列) を橙で 23 列へ運び R4 (g23〜g31) で VINA− へ。
  A0 (15 列) を橙で 22 列へ運び R2 (i22〜i32) で VINA+ へ。R5 (j30〜j31) は VOUTA と VINA− の間に**立てて**挿す。
  R3 (h32〜h38) は VINA+ から VREF (38 列) へ
- **Q の差動増幅 (U4 の下の半分、50〜53 列)**: A1 (17 列、茶) と A2 (18 列、桃) は、I の部品をよけて上の段の b・c 行を通し、
  42・43 列で下の段へ下ろす。R6 (i42〜i52) で VINA+、R8 (g43〜g51) で VINA−。R9 は j50〜j51 に立てる。R7 (h52〜h58) は VREF (58 列) へ
- **VREF**: R10 (d55〜d60、60 列は + レール)・R11 (a55 から − レール) の中点を U4 の VINB+ へ。
  U4 の VOUTB (51 列の上) と VINB− をつないでフォロワにし、灰色の線で 38 列と 58 列の VREF へ配る。
  U3 の上の半分 (VINB+ を − レール、VOUTB と VINB− をつなぐ) は使わない
- **出力**: U3 の VOUTA (30 列) を橙で Pico 2 の GP26 へ、U4 の VOUTA (50 列) を茶で GP27 へ
- **ブレッドボードで組んでよい理由**: いちばん高い周波数は W1 の 1.992 MHz で、ブレッドボードの 3 MHz 以下に収まる。
  電流は IC 4 個で数 mA で、Pico 2 の 3V3 (最大 300 mA) にも、ブレッドボードの 500 mA にも遠い

```breadboard
title: 図4 Pico 2 は別のブレッドボードに (USB で PC から給電)
board: half
parts:
  BB:
    type: device
    at: top
    label: 図3 のブレッドボードから
    pins: [GND, 3V3, Q, I]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Scope)
    pins: [2+, 1+, 1-, 2-]
  U5: pico2 @ h5
wires:
  - b9 -- +t9 red
  - a7 -- -t7 black
  - BB.GND -- -t3 black
  - BB.3V3 -- +t4 red
  - BB.Q -- a13 brown
  - BB.I -- a14 orange
  - AD.2+ -- b13 brown
  - AD.1+ -- b14 orange
  - AD.1- -- -t27 black
  - AD.2- -- -t28 black
notes:
  - text: GP26 (ADC0) = I、GP27 (ADC1) = Q。赤レール = +3.3V (3V3 OUT)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/23-iq-pico2-adc-2.svg)

- Pico 2 は PC の USB から給電し、プログラムの表示もこの USB のシリアルで受ける。GND38 (PIN 38) を − レールへ、3V3 (PIN 36) を + レールへ
- GP26 (PIN 31) と GP27 (PIN 32) の a 行に図3 からの I・Q を挿し、b 行に AD3 の 1+・2+ を挿す。1−・2− は GND
- **電源を入れる順**: 先に Pico 2 の USB をつなぎ (3.3 V が立ってから)、そのあと AD3 の W1・W2 を出す。
  電源の無い 74HC74・74HC4052 に W1・W2 を入れると、入力の保護ダイオードを通して電源の側へ電流が流れ込む

## 部品

| 記号 | 部品 | 値・型番 | 備考 |
| --- | --- | --- | --- |
| U1 | D フリップフロップ ×2 | 74HC74 | ジョンソンカウンタで 1/4 と 90° の 2 本 |
| U2 | アナログマルチプレクサ (4 チャネル ×2) | 74HC4052 | A 側だけ使う。B0〜B3 は開け、BN・E・VEE は GND |
| U3・U4 | オペアンプ (2 回路、レールツーレール) | MCP6002 (DIP-8) | U3A = I、U4A = Q、U4B = VREF、U3B は使わない |
| U5 | マイコンボード | Raspberry Pi Pico 2 | 3V3 で全体に給電。別のハーフのブレッドボード (図4) |
| R1 | 抵抗 | 1 kΩ | 9-22 と同じ |
| R2・R4・R6・R8 | 抵抗 | 100 kΩ | 金属皮膜 ±1 % をすすめる (下の注) |
| R3・R5・R7・R9 | 抵抗 | 200 kΩ (E24) | 同上 |
| R10・R11 | 抵抗 | 10 kΩ | VREF の分圧 |
| C1〜C4 | セラミックコンデンサ | 10 nF (103) | NP0/C0G がよい。4 本の容量がそろうほど I と Q の振幅がそろう |
| C5〜C8 | セラミックコンデンサ | 100 nF (104) | 各 IC のパスコン |
| — | 信号源・計器 | Analog Discovery 3 | W1・W2 と Scope。Supplies は使わない |

- **電源は 3.3 V** (既定の 5 V ではない)。Pico 2 の ADC の範囲 (0〜3.3 V) に出力を収めるため
- 差動増幅の利得と、I と Q の利得のそろい方は R2〜R9 の比で決まる。±5 % の抵抗だと I と Q の利得が数 % ずれ、
  円が少しつぶれて大きさ A が 2f で揺れる (位相の平均と周波数は変わらない)。±1 % ならほぼ見えない
- 同相 (1.65 V の直流) の抵抗のずれは出力の直流のずれになるだけで、プログラムが引く

## 計器の設定

Analog Discovery 3 (AD3) で W1 (クロック) と W2 (RF) を作り、Scope で ADC の入口を見る。I/Q は 1 kHz と低いので AD3 のオシロで十分見え、
計算の答えは Pico 2 が USB のシリアルに出す。WaveForms の振幅 (Amplitude) は **peak** で入れる。

| 項目 | 設定 |
| --- | --- |
| Supplies | 使わない (電源は Pico 2 の 3V3)。AD3 の GND は図3 の − レールへ |
| Wavegen W1 (クロック) | Square、**1.992 MHz**、振幅 1.65 V、オフセット 1.65 V (0〜3.3 V)、Symmetry 50 % |
| Wavegen W2 (RF) | Sine、**499 kHz** (次に 497 kHz)、振幅 0.25 V (0.5 V<sub>pp</sub>)、オフセット 1.65 V |
| Scope (時間) | CH1 = GP26 (I)、CH2 = GP27 (Q)、どちらも GND 基準。250 mV/div、オフセットで 1.65 V を中央に。200 µs/div、トリガは CH1 の立ち上がり 1.65 V |
| Scope (XY) | X = CH1、Y = CH2。同じ 250 mV/div |

- LO は 1.992 MHz ÷ 4 = **498.000 kHz**。W2 = 499 kHz なら差は **+1.000 kHz**、497 kHz なら **−1.000 kHz**。
  W1 と W2 は AD3 の同じクロックから作るので、差は 1 Hz の桁までぴったり出る
- W2 は 3.3 V の電源の中に収める (1.65 V ± 0.25 V)。74HC4052 のスイッチは 0〜3.3 V の範囲の電圧しか通さない

### プログラム

C/C++ (Pico SDK) を第 1、MicroPython を第 2 に並べる。どちらも 0.5 秒ごとに
「差の周波数 (符号つき)・大きさ (V<sub>pp</sub>)」を USB のシリアルに出す。C/C++ は AM と FM を見るために、
0.5 秒の間の大きさの最小〜最大と、1 ms ごとの周波数の最小〜最大も出す。

**C/C++ (Pico SDK)**。`iqread.c`。ADC0・ADC1 の交互読みを 500 kS/s で回し、DMA の 2 本で 2 つのバッファへ交互に書かせる
(片方を計算している間に、もう片方へ書く)。

```c
#include <stdio.h>
#include <math.h>
#include "pico/stdlib.h"
#include "hardware/adc.h"
#include "hardware/dma.h"
#include "hardware/irq.h"

#define NAVG        10                 // 1 チャネルあたり平均する数
#define PAIRS       1000               // 1 ブロック = 1000 組 (4 ms)
#define BLOCK_LEN   (2 * PAIRS)        // ADC0, ADC1, ADC0, ... の順に並ぶ
#define FS          25000.0f           // 平均後の I・Q の標本化 (1 チャネル)
#define LSB_V       (3.3f / 4096.0f)   // ADC の 1 目盛
#define GAIN        2.0f               // 差動増幅の利得
#define DC_ALPHA    (1.0f / 2500.0f)   // 直流 (VREF の読み) を 0.1 s で追う
#define SEG         25                 // 瞬時周波数を 25 標本 (1 ms) ごとに出す
#define REPORT      125                // 125 ブロック = 0.5 s ごとに表示

static uint16_t buf[2][BLOCK_LEN];
static int dma_ch[2];
static volatile int ready = -1;        // 書き終えたブロックの番号

static void dma_isr(void) {
    for (int k = 0; k < 2; k++) {
        if (dma_channel_get_irq0_status(dma_ch[k])) {
            dma_channel_acknowledge_irq0(dma_ch[k]);
            dma_channel_set_write_addr(dma_ch[k], buf[k], false);  // 次の番に備える
            ready = k;
        }
    }
}

static void start_adc_dma(void) {
    adc_init();
    adc_gpio_init(26);                 // ADC0 = I
    adc_gpio_init(27);                 // ADC1 = Q
    adc_select_input(0);               // ADC0 から始める
    adc_set_round_robin(0x03);         // ADC0 と ADC1 を交互に
    adc_fifo_setup(true, true, 1, false, false);
    adc_set_clkdiv(0);                 // 48 MHz ÷ 96 = 500 kS/s (全体)

    dma_ch[0] = dma_claim_unused_channel(true);
    dma_ch[1] = dma_claim_unused_channel(true);
    for (int k = 0; k < 2; k++) {
        dma_channel_config c = dma_channel_get_default_config(dma_ch[k]);
        channel_config_set_transfer_data_size(&c, DMA_SIZE_16);
        channel_config_set_read_increment(&c, false);
        channel_config_set_write_increment(&c, true);
        channel_config_set_dreq(&c, DREQ_ADC);
        channel_config_set_chain_to(&c, dma_ch[1 - k]);   // 終わったらもう片方へ
        dma_channel_configure(dma_ch[k], &c, buf[k], &adc_hw->fifo, BLOCK_LEN, false);
        dma_channel_set_irq0_enabled(dma_ch[k], true);
    }
    irq_set_exclusive_handler(DMA_IRQ_0, dma_isr);
    irq_set_enabled(DMA_IRQ_0, true);
    dma_channel_start(dma_ch[0]);
    adc_run(true);
}

int main(void) {
    stdio_init_all();
    start_adc_dma();

    float dc_i = 2048.0f, dc_q = 2048.0f;
    float phi_prev = 0.0f, dphi_sum = 0.0f, seg_sum = 0.0f;
    float amp_sum = 0.0f, amp_min = 1e9f, amp_max = 0.0f;
    float f_min = 1e9f, f_max = -1e9f;
    int count = 0, seg_n = 0, blocks = 0;

    while (true) {
        while (ready < 0) tight_loop_contents();
        const uint16_t *p = buf[ready];
        ready = -1;

        for (int n = 0; n < BLOCK_LEN; n += 2 * NAVG) {
            uint32_t si = 0, sq = 0;
            for (int m = 0; m < 2 * NAVG; m += 2) {
                si += p[n + m] & 0x0FFF;          // ADC0 (I)
                sq += p[n + m + 1] & 0x0FFF;      // ADC1 (Q)。I より 2 µs あと
            }
            float i = si / (float)NAVG, q = sq / (float)NAVG;
            dc_i += (i - dc_i) * DC_ALPHA;        // VREF の読みを引く
            dc_q += (q - dc_q) * DC_ALPHA;
            i = (i - dc_i) * LSB_V / GAIN;        // Tayloe の出口の電圧に戻す
            q = (q - dc_q) * LSB_V / GAIN;

            // 1Q→S0・2Q→S1 の配線では、RF が LO より上のとき Q が I より 90° 進む。
            // I + jQ は負の向きに回るので、-Q を虚部にして「上なら正」にする。
            float phi = atan2f(-q, i);
            float d = phi - phi_prev;
            if (d > (float)M_PI) d -= 2.0f * (float)M_PI;
            if (d < -(float)M_PI) d += 2.0f * (float)M_PI;
            phi_prev = phi;
            dphi_sum += d;
            seg_sum += d;

            float a = sqrtf(i * i + q * q);      // 円の半径 = I の振幅 (peak)
            amp_sum += a;
            if (a < amp_min) amp_min = a;
            if (a > amp_max) amp_max = a;
            count++;

            if (++seg_n == SEG) {                // 1 ms ごとの瞬時周波数 (FM を見る)
                float f = seg_sum / (2.0f * (float)M_PI) * FS / SEG;
                if (f < f_min) f_min = f;
                if (f > f_max) f_max = f;
                seg_sum = 0.0f;
                seg_n = 0;
            }
        }

        if (++blocks == REPORT) {
            float f_khz = dphi_sum / (2.0f * (float)M_PI) * FS / count / 1000.0f;
            printf("%+.3f kHz  %.2f Vpp  (amp %.2f..%.2f Vpp, f %+.2f..%+.2f kHz)\n",
                   f_khz, 2.0f * amp_sum / count, 2.0f * amp_min, 2.0f * amp_max,
                   f_min / 1000.0f, f_max / 1000.0f);
            dphi_sum = amp_sum = 0.0f;
            amp_min = 1e9f; amp_max = 0.0f;
            f_min = 1e9f; f_max = -1e9f;
            count = blocks = 0;
        }
    }
}
```

同じフォルダに `pico_sdk_import.cmake` (SDK の `external/` にあるものをコピーする) と `CMakeLists.txt` を置く。

```cmake
cmake_minimum_required(VERSION 3.13)
set(PICO_BOARD pico2 CACHE STRING "Board type")
include(pico_sdk_import.cmake)
project(iqread C CXX ASM)
pico_sdk_init()
add_executable(iqread iqread.c)
target_link_libraries(iqread pico_stdlib hardware_adc hardware_dma)
pico_enable_stdio_usb(iqread 1)
pico_add_extra_outputs(iqread)
```

```sh
cmake -B build -DPICO_BOARD=pico2
cmake --build build
```

`build/iqread.uf2` を、BOOTSEL ボタンを押しながら USB でつないだ Pico 2 のドライブへコピーする (9-16 と同じ)。

- `adc_set_round_robin(0x03)` で ADC0 → ADC1 → ADC0 … と交互に読み、`adc_set_clkdiv(0)` で最速 (500 kS/s)。
  FIFO の値は ADC0 から始まる順に並ぶので、偶数番目が I、奇数番目が Q
- DMA の 2 本 (`dma_ch[0]`・`dma_ch[1]`) は終わるともう片方を起こす (`chain_to`)。取りこぼしなく 4 ms ごとに 2000 個のブロックが届く
- 直流 (VREF の読み、約 2048) は 0.1 秒の時定数で追って引く。そのため **0 Hz 付近 (W2 = 498.000 kHz) の信号は消える** (下の表)
- `atan2f(-q, i)` の差をつないで (±π を越えたら 2π を足し引き) 足し、0.5 秒の和 ÷ 2π ÷ 0.5 秒が周波数。
  25 kS/s なら ±12.5 kHz まで、1 標本の間に半周を越えないので向きを取り違えない
- 大きさ √(I² + Q²) は円の半径 = I の peak。2 倍して V<sub>pp</sub> で出す。ADC の目盛 (3.3 V ÷ 4096) で電圧に直し、利得 2 で割って **Tayloe の出口 (A0 − A3) の電圧**に戻している

C/C++ のプログラムは、この環境で `PICO_BOARD=pico2` の `.uf2` までビルドが通ることを確かめた。**実機では動かしていない。**

**MicroPython**。MicroPython からは ADC の DMA と 500 kS/s の交互読みを簡単には使えない。そこで `read_u16()` を
**I・Q の順に続けて呼ぶ**ループで 2000 組を集め、集め終えてから計算する (読みながらは計算しない)。
1 組にかかる時間はその場で `ticks_us()` で測って周波数の計算に使う。

```python
from machine import ADC, Pin
import array, math, time

adc_i = ADC(Pin(26))           # ADC0 = I
adc_q = ADC(Pin(27))           # ADC1 = Q
N = 2000                       # 1 回に集める組の数
GAIN = 2.0                     # 差動増幅の利得
V_PER = 3.3 / 65535            # read_u16() は 0〜65535

bi = array.array('H', bytes(2 * N))
bq = array.array('H', bytes(2 * N))

def capture():
    ri = adc_i.read_u16
    rq = adc_q.read_u16
    t0 = time.ticks_us()
    for n in range(N):
        bi[n] = ri()
        bq[n] = rq()           # I より 10〜20 µs あと (目安)
    return time.ticks_diff(time.ticks_us(), t0) / N   # 1 組の時間 (µs)

while True:
    dt_us = capture()
    mi = sum(bi) / N           # 直流 (VREF の読み) はブロックの平均で引く
    mq = sum(bq) / N
    prev = 0.0
    total = 0.0
    amp = 0.0
    for n in range(N):
        i = (bi[n] - mi) * V_PER / GAIN
        q = (bq[n] - mq) * V_PER / GAIN
        phi = math.atan2(-q, i)        # RF が LO より上なら増える向き
        if n:
            d = phi - prev
            if d > math.pi:
                d -= 2 * math.pi
            elif d < -math.pi:
                d += 2 * math.pi
            total += d
        prev = phi
        amp += math.sqrt(i * i + q * q)
    f = total / (2 * math.pi) / ((N - 1) * dt_us * 1e-6)
    print('%+.3f kHz  %.2f Vpp  (%.1f us/組)' % (f / 1000, 2 * amp / N, dt_us))
```

- **I と Q の読みの間 (スキュー) が長い。** `read_u16()` 1 回に数 µs〜十数 µs かかるので、
  Q は I より **10〜20 µs ほど**あとに読まれる (目安。この環境では測っていない)。1 kHz では **3.6〜7.2°** のずれで、
  C/C++ の 2 µs (0.72°) の 5〜10 倍
- ずれが一定なら、位相の傾き (周波数) は変わらない。ただし I と Q が 90° からずれるので、円が少し斜めの楕円になり、
  大きさ A が 2 kHz で数 % 揺れる (平均は出る)。AM の包絡線を細かく見るなら C/C++ を使う
- 1 組の時間が数十 µs なので、取り込みは数万組/秒。集める間だけ読み、計算の間は読まないので、連続した音声の復調には向かない。
  MicroPython 版は「数を見る」ための簡単な版、と割り切る

MicroPython のプログラムは実行していない (未確認)。

## 計器の画面

計算値 (スイッチと RC を時間で解いた結果)。W2 = 499 kHz・0.5 V<sub>pp</sub>、R<sub>on</sub> を 100 Ω とした。
Tayloe の出口の I・Q は 0.417 V peak (1 kHz)、差動増幅で 2 倍して ADC の入口では **1.65 V ± 0.834 V (1.67 V<sub>pp</sub>)**。

```scope
title: 図5 ADC の入口 (W2 499 kHz) — Q (CH2) が I より 250 µs 進む
time: 200us/div
trigger: ch1 rising 1.65V
ch1: {wave: sine 1kHz 0.834V offset 1.65V, range: 250mV/div, position: -6.6div}
ch2: {wave: sine 1kHz 0.834V offset 1.65V phase 90deg, range: 250mV/div, position: -6.6div}
cursors: [-250us, 0]
measure: [vpp, avg, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/23-iq-pico2-adc-1.svg)

- CH1 (GP26 = I) と CH2 (GP27 = Q) は同じ 1 kHz・1.67 V<sub>pp</sub>・平均 1.65 V。0〜3.3 V の ADC の範囲の真ん中に収まる
- CH2 は CH1 より 250 µs (90°) **早く**同じ所を通る。これが「RF が LO より上」の印で、プログラムは +1.000 kHz と出す。
  W2 を 497 kHz にすると、CH2 は 250 µs **遅れ**、−1.000 kHz と出る

```scope
title: 図6 XY (X = I、Y = Q) — 半径 0.834 V の円。1 秒に 1000 回まわる
view: xy
ch1: {wave: sine 1kHz 0.834V offset 1.65V, range: 250mV/div, position: -6.6div}
ch2: {wave: sine 1kHz 0.834V offset 1.65V phase 90deg, range: 250mV/div, position: -6.6div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/23-iq-pico2-adc-2.svg)

- 中心が (1.65 V, 1.65 V) の円。プログラムはこの中心 (VREF) を引いて、点の向き φ と半径 A を計算している
- 回る向きは止まった画面では分からない (時間の図5 で先後を見る)。円がつぶれていれば I と Q の利得か位相がずれている

## 見るべき値

計算値 (スイッチと RC を時間で解いた結果。R<sub>on</sub> 100 Ω、差動増幅 100 kΩ / 200 kΩ の負荷込み)。
「表示」は C/C++ のプログラムが USB のシリアルに出す値で、大きさは Tayloe の出口 (A0 − A3) の V<sub>pp</sub>。

| 確かめること | 期待する値 |
| --- | --- |
| ADC の入口 (CH1・CH2、W2 499 kHz) | 1 kHz、1.67 V<sub>pp</sub> (0.82〜2.48 V)、平均 1.65 V (図5) |
| CH2 と CH1 の先後 (W2 499 kHz) | CH2 (Q) が 250 µs (+90°) 進む。497 kHz では 250 µs 遅れる |
| 表示 (W2 499 kHz) | `+1.000 kHz  0.83 Vpp` |
| 表示 (W2 497 kHz) | `-1.000 kHz  0.83 Vpp` (符号だけ変わる) |
| 表示 (W2 500 kHz・502 kHz) | `+2.000 kHz  0.76 Vpp`、`+4.000 kHz  0.59 Vpp` (Tayloe の低域の角 約 3.6 kHz で下がる) |
| 表示 (W2 498.000 kHz) | 大きさが 0 に近づき、周波数は定まらない。I・Q が直流になり、プログラムが VREF と一緒に引いてしまうため |
| I と Q の読みの時間差 (C/C++) | 2 µs (1 kHz で 0.72°) |
| I と Q の読みの時間差 (MicroPython) | 10〜20 µs (目安、未測定。1 kHz で 3.6〜7.2°) |
| AM: W2 499 kHz に WaveForms の AM (100 Hz、50 %) | `+1.000 kHz`、大きさ 0.42〜1.25 V<sub>pp</sub> (0.83 V<sub>pp</sub> × (1 ± 0.5))。大きさの揺れが 100 Hz の音 (包絡線) |
| FM: W2 500 kHz に WaveForms の FM (100 Hz、偏移 ±1 kHz) | `+2.000 kHz`、1 ms ごとの周波数 +1.00〜+3.00 kHz。周波数の揺れ (dφ/dt) が 100 Hz の音。大きさは 0.68〜0.83 V<sub>pp</sub> と少し揺れるが、周波数には効かない |
| I と Q を入れ替える (または S0 と S1 の線を入れ替える) | 表示の符号が逆になる (499 kHz で −1.000 kHz) |

- AM は大きさ √(I² + Q²) に、FM は位相の傾き dφ/dt に音が乗る。**同じ I と Q から、式を替えるだけで AM も FM も復調できる**。
  9-7 の AM は包絡線を 1 本で取り出したが、ここでは中心の周波数が 1 kHz ずれていても大きさが正しく出る
- 9-13 のスロープ検波は、FM を共振回路の斜面で AM に変えてから検波した。ここでは周波数そのもの (dφ/dt) を計算するので、斜面のゆがみが無い
- FM の例で中心を +2 kHz にしたのは、±1 kHz 振っても 0 Hz (直流を引く所) をまたがないため
- 表示の数は理想。実物は ADC の雑音 (数目盛) と抵抗・コンデンサのずれで、大きさが数 % 動く (目安)。
  周波数は W1 と W2 の差で決まり、Pico 2 の水晶の誤差 (数十 ppm) は 1 kHz に対して 0.1 Hz 以下しか効かない

## 出典

自作。I/Q を複素数とみて atan2 で位相を、√(I² + Q²) で大きさを出す考え方は、直交検波の一般的な式による。
スイッチとコンデンサの直交検波器は D. Tayloe が 2001 年ごろに発表した形 (Tayloe 検波器) で、回路は 9-22 を 3.3 V にしたもの。
74HC4052 のピンの並びと電源電圧は [TI CD74HC4052 データシート](https://www.ti.com/lit/ds/symlink/cd74hc4052.pdf)、
74HC74 は [TI SN74HC74 データシート](https://www.ti.com/lit/ds/symlink/sn74hc74.pdf)、
MCP6002 の電源電圧 (1.8〜6 V)・レールツーレール・GBW (1 MHz)・入力電流は [Microchip MCP6002 の製品ページとデータシート](https://www.microchip.com/en-us/product/MCP6002)、
RP2350 の ADC (12 bit、48 MHz で 96 サイクル = 500 kS/s、ラウンドロビン、FIFO と DMA) は
[RP2350 データシート](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf)、
Pico 2 のピン (GP26 = ADC0、GP27 = ADC1、3V3 OUT) は [Pico 2 データシート](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf)、
Pico SDK の関数は [Raspberry Pi Pico SDK のドキュメント (hardware_adc・hardware_dma)](https://www.raspberrypi.com/documentation/pico-sdk/hardware.html)、
MicroPython の `ADC.read_u16()` は [MicroPython の RP2 クイックリファレンス](https://docs.micropython.org/en/latest/rp2/quickref.html) による。
I/Q の振幅と低域の角は、スイッチ 4 個 (R<sub>on</sub> 100 Ω)・1 kΩ・10 nF・差動増幅の入力の抵抗を時間で解いた計算値。
