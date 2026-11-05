---
book: analog-discovery
chapter: 4
id: 4-14
title: 2 トーンで相互変調 (IMD) の入口
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-14 2 トーンで相互変調 (IMD) の入口

増幅回路に周波数の違う 2 本 (f<sub>1</sub> = 10 kHz、f<sub>2</sub> = 11 kHz) を同時に入れると、回路が少しでも非線形なら、
出力に 2 本の和と差の周波数が現れる。これが**相互変調 (IMD)** である。

- **2 次** (IM2): f<sub>2</sub> − f<sub>1</sub> = 1 kHz と f<sub>1</sub> + f<sub>2</sub> = 21 kHz。2 本から遠いので、フィルタで落とせる
- **3 次** (IM3): 2f<sub>1</sub> − f<sub>2</sub> = 9 kHz と 2f<sub>2</sub> − f<sub>1</sub> = 12 kHz。**2 本のすぐ隣**に出るので、フィルタでは落とせない

9-4 ではオペアンプの増幅で IMD を測る。この題はその入口として、トランジスタ 1 段 (2SC1815) の指数関数の非線形で IMD を作り、
**入力を 6 dB 下げると IM2 は約 12 dB、IM3 は約 18 dB 以上下がる** (次数の倍で動く) ことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1・W2 を 1 kΩ ずつで足し、エミッタ接地 1 段 (2SC1815) に入れる
parts:
  V1: sine 1,2 1,4 l=$\mathrm{W1}$
  G1: ground 1,4
  R1: resistor 1,2 3,2 1k
  V2: sine 1,6 1,8 l=$\mathrm{W2}$
  G2: ground 1,8
  R2: resistor 1,6 3,6 1k
  M2: voltmeter 4,6 4,8 l=$\mathrm{CH2}$
  G3: ground 4,8
  C1: ecap 5,4 3,4 10u
  VCC: vcc 5,1 5V
  RB1: resistor 5,1 5,4 47k
  RB2: resistor 5,4 5,7 10k
  G4: ground 5,7
  Q1: npn 7,4 2SC1815
  VCC: vcc 9,1 5V
  RC: resistor 9,1 9,3 1k
  RE: resistor 7,6 7,8 100
  CE: ecap 9,6 9,8 100u
  G5: ground 7,8
  C2: ecap 9,3 11,3 10u
  M1: voltmeter 11,3 11,5 l=$\mathrm{CH1}$
  G6: ground 11,5
wires:
  - 3,2 -- 3,4
  - 3,6 -- 3,4
  - 3,6 -- 4,6
  - 5,4 -- Q1.B
  - Q1.C |- 9,3
  - Q1.E |- 7,6
  - 7,6 -- 9,6
  - 7,8 -- 9,8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/14-two-tone-imd.svg)

- W1・W2 を 1 kΩ ずつで足す (4-6 と同じ)。和の点を CH2 で見る。トランジスタの入力 (RB1 ∥ RB2 ∥ h<sub>ie</sub>、約 2.6 kΩ) が
  和の点に負荷として付くので、和の点の 1 本ぶんは W の振幅の半分より少し小さい (W 10 mV で 4.23 mV)
- RB1・RB2 の分圧でベースを 0.82 V にし、エミッタ電流は約 1.7 mA (RE 100 Ω の両端 0.17 V)。CE (100 µF。µ はマイクロ) が
  10 kHz で RE を短絡するので、交流ではエミッタ接地そのもの。利得は約 60 倍
- **わざと非線形を大きくしてある**。RE をバイパスしないと、帰還で IMD がずっと小さくなる (「分かること」)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (上半分が増幅、下半分が 2 トーンの和)
board: half
parts:
  Q1: transistor e12(B) e16(C) e20(E) 2SC1815
  RB1: resistor +t8 b8 47k
  RB2: resistor a12 -t12 10k
  C1: capacitor/electrolytic d8 g8 10u
  RC: resistor +t16 b16 1k
  C2: capacitor/electrolytic c16 c13 10u
  RE: resistor b20 -t20 100
  CE: capacitor/electrolytic d20 d26 100u
  R1: resistor h3 h8 1k
  R2: resistor i13 i8 1k
  AD:
    type: device
    at: top
    label: AD3 (Supplies と CH1)
    pins: [V+, GND, 1+, 1-]
  WG:
    type: device
    at: bottom
    label: AD3 (Wavegen と CH2)
    pins: [W1, 2+, 2-, W2]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - -t1 -- -b1 black
  - c8 -- c12 white
  - a26 -- -t26 black
  - AD.1+ -- a13 yellow
  - AD.1- -- -t29 black
  - WG.W1 -- j3 yellow
  - WG.W2 -- j13 orange
  - WG.2+ -- j8 blue
  - WG.2- -- -b10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/14-two-tone-imd.svg)

- 電源は AD3 の Supplies の V+ (5 V)。Q1 は 2SC1815 のピンを 4 穴ずつ広げ、B・C・E を 12・16・20 列に挿す
- RB1 は + レールから 8 列へ、白の線で 8 列をベース (12 列) へ。C1 は 8 列から溝をまたいで下半分の 8 列 (和の点) へ、+ をベースの側に
- 下半分は 2 トーンの和。W1 (黄) は 3 列から R1、W2 (橙) は 13 列から R2 で 8 列に集め、CH2 (2+、青) も 8 列
- C2 は C (16 列) から 13 列へ、+ を C の側に。13 列から CH1 (1+、黄)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Wavegen | W1: Sine 10 kHz、Amplitude 10 mV。W2: Sine 11 kHz、Amplitude 10 mV。次に両方を 5 mV にする |
| Scope | CH1: 200 mV/div (出力)、CH2: 5 mV/div (和の点)。Time 500 µs/div。Trigger: CH1 |
| Spectrum | Source: Channel 1 (次に Channel 2)。Start 0 Hz、Stop 25 kHz、FFT 点数 8192、Window: Flat-top。単位: dBm |

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 出力 — 2 本の隣に IM3 (9・12 kHz)、遠くに IM2 (1・21 kHz)
device: ad3
sweep: 0-25kHz
samples: 8192
window: flattop
unit: dBm
ref: 10dBm
floor: -100dBm
signal:
  - sine 10kHz 250mV
  - sine 11kHz 250mV
  - sine 9kHz 0.289mV
  - sine 12kHz 0.298mV
  - sine 1kHz 14.9mV
  - sine 21kHz 15.0mV
  - sine 20kHz 7.49mV
  - sine 22kHz 7.49mV
markers: [10kHz, 9kHz, 12kHz, 1kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/14-two-tone-imd.svg)

図3 の線の高さは LTspice の値 (下の表)。20 kHz・22 kHz は各トーンの 2 次高調波 (2f<sub>1</sub>・2f<sub>2</sub>)。
CH2 (和の点) に替えると、10・11 kHz の 2 本だけが −37.47 dBm に立ち、IMD の線は出ない (抵抗の足し算は線形)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 出力の時間波形 — 2 本の和は 1 kHz (f₂ − f₁) でうなる
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: "= 250mV * sin(2 * pi * 10kHz * t) + 250mV * sin(2 * pi * 11kHz * t)", range: 200mV/div}
ch2: {wave: "= 4.23mV * sin(2 * pi * 10kHz * t) + 4.23mV * sin(2 * pi * 11kHz * t)", range: 5mV/div}
cursors: [0, 1ms]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/14-two-tone-imd.svg)

うなりの周期 1 ms (カーソルの間隔) が f<sub>2</sub> − f<sub>1</sub> = 1 kHz。Scope の画面では IMD (振幅の 0.1% ほど) は見えないので、Spectrum で読む。
CH2 は 2 本の和の Vpp 16.9 mV、CH1 は Vpp 1.00 V (約 60 倍)。図4 は理想の 2 本の和で、ひずみは描いていない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 |
| R1, R2 | 抵抗 (2 トーンを足す) | 1 kΩ |
| RB1, RB2 | 抵抗 (ベースの分圧) | 47 kΩ、10 kΩ |
| RC | 抵抗 (コレクタ負荷) | 1 kΩ |
| RE | 抵抗 (エミッタ) | 100 Ω (Ω はオーム) |
| C1, C2 | 電解コンデンサ (結合) | 10 µF |
| CE | 電解コンデンサ (RE のバイパス) | 100 µF |
| — | 電源 | 5 V (AD3 の Supplies の V+。流れる電流は約 2.2 mA) |

## 見るべき値

LTspice の値 (2SC1815 は仮定の模型、下の節)。dBc は 1 本の基本波 (10 kHz) との差。

| 線 | 周波数 | W 10 mV のとき | dBc | W 5 mV のとき | 6 dB 下げたときの下がり |
| --- | --- | --- | --- | --- | --- |
| 基本波 f<sub>1</sub>・f<sub>2</sub> | 10・11 kHz | −2.04 dBm (250 mV) | 0 | −8.04 dBm | 6.0 dB |
| IM3 | 9 kHz | −60.77 dBm | −58.7 dBc | −81.99 dBm | 21.2 dB |
| IM3 | 12 kHz | −60.52 dBm | −58.5 dBc | −82.67 dBm | 22.2 dB |
| IM2 | 1 kHz | −26.53 dBm | −24.5 dBc | −38.55 dBm | 12.0 dB |
| IM2 | 21 kHz | −26.48 dBm | −24.4 dBc | −38.50 dBm | 12.0 dB |
| 2 次高調波 | 20・22 kHz | −32.51 dBm | −30.5 dBc | −44.5 dBm | 12.0 dB |
| 和の点 (CH2) の 1 本 | 10・11 kHz | −37.47 dBm (4.23 mV) | — | −43.50 dBm | 6.0 dB |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 入力と出力の線 — 基本波は傾き 1、IM3 は傾き 3 (理論) で動く
x: ベースに入る 1 本の電力 dBm -50..-30
y: 出力の電力 dBm -110..10
lines:
  基本波 (傾き 1) dBm: x + 35.43
  IM3 (傾き 3) dBm: 3 * x + 51.77
  LTspice 基本波 dBm:
    - -43.50 -8.04
    - -37.47 -2.04
  LTspice IM3 dBm:
    - -43.50 -82.33
    - -37.47 -60.65
notes:
  - mark -37.47
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/graph/14-two-tone-imd.svg)

傾き 3 の線は W 10 mV の点 (−37.47 dBm) で LTspice に合わせて引いた。

分かること:

- **IM2 は入力の 2 乗、IM3 は 3 乗で増える**。dB では入力を 1 dB 下げると IM2 は 2 dB、IM3 は 3 dB 下がる。LTspice では 6 dB 下げて IM2 が 12.0 dB、
  IM3 が 21〜22 dB 下がった。IM3 が 18 dB より多く下がるのは、5 次などの高い次数が 3 次の線に重なって打ち消し合うため (この模型での目安)
- **IM3 は 2 本の 1 kHz 隣にあり、フィルタで分けられない**。受信機で強い 2 局が近くにあると、その間や外側に無い局が聞こえるのはこのため。
  傾き 1 と 3 の線を延ばした交点が IP3 (3 次インターセプト点) で、9-4 と第 9 章で使う
- RE のバイパス (CE) を抜くと、利得は約 8.5 倍に下がり、W を 40 mV に上げても IM3 は基本波の約 80 dB 下 (−78〜−83 dBc) にとどまる (LTspice)。エミッタの帰還はひずみを減らす
- 測る側の限界は 4-12 の SFDR。Wavegen 自身の 2 トーンを CH2 で見て IMD が出ないことを先に確かめ、その差を回路の IMD とする

## LTspice での確かめ

`sim/14-two-tone-imd.cir` で図1 を過渡解析し (10 kHz と 11 kHz、W 10 mV と 5 mV)、2〜22 ms の 20 ms を FFT した (1 kHz の整数倍の線がビンにちょうど乗る)。
2SC1815 は 01-circuits の `09-rf/sim/agc.cir` と同じ仮定の模型 (BF = 250)。**実測ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ベースの電圧 | 0.82 V | 0.822 V | 合う |
| エミッタ電流 | 約 1.7 mA | 1.70 mA (RE の両端 0.170 V) | 合う |
| コレクタの電圧 | 約 3.3 V | 3.31 V | 合う |
| 利得 (基本波) | 約 60 倍 | 250 mV ÷ 4.23 mV = 59.1 倍 | 合う |
| IM3 (9 kHz、W 10 mV) | −58.7 dBc | −60.77 dBm (基本波 −2.04 dBm) | 合う |
| IM2 の傾き | 6 dB で 12 dB | 12.0 dB | 合う |
| IM3 の傾き | 6 dB で 18 dB 以上 | 21.2・22.2 dB | 合う (理論 18 dB より多い、上の注) |

手計算の目安: エミッタ電流 0.17 V ÷ 100 Ω = 1.7 mA、g<sub>m</sub> = 1.7 mA ÷ 25.9 mV = 65.6 mS で、利得 g<sub>m</sub> × RC = 66 倍
(LTspice の 59 倍はベースの広がり抵抗のぶん小さい)。IM2 の目安は入力の振幅 ÷ (2 × 25.9 mV) = 4.23 ÷ 51.8 = −21.8 dBc (LTspice −24.5 dBc)。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Spectrum の節)。2SC1815 のピンの並びは `datasheets.md` の資料。

参考: [Intermodulation (Wikipedia)](https://en.wikipedia.org/wiki/Intermodulation)、[Third-order intercept point (Wikipedia)](https://en.wikipedia.org/wiki/Third-order_intercept_point)
