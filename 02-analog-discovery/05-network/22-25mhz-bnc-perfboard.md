---
book: analog-discovery
chapter: 5
id: 5-22
title: 25 MHz まで (BNC、perfboard)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: PF
---

# 5-22 25 MHz まで (BNC、perfboard)

5-8 で見たとおり、付属のワイヤ (2×15 ヘッダ) のままでは AD3 の入力の帯域が 9 MHz で頭打ちになる。
**BNC アダプタ**を付けると Scope の帯域は 30 MHz 以上に伸び (AD3 の仕様)、Network の掃引も、WaveForms で選べる上限
(システムクロックの 1/4、既定で 25 MHz) まで意味のある値になる。この題では 15 MHz の 3 次のローパスを
ユニバーサル基板に組み、端面の SMA と同軸で AD3 につないで 25 MHz まで掃引する。
10 MHz を超えるのでブレッドボードは使わない (第 8 章)。5-19 で見た同軸の効きが、ここでは無視できない大きさになる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 50 Ω 系の 3 次 LPF を BNC と同軸 30 cm で AD3 につなぐ
parts:
  V1: sine 1,2 1,4 l=$\mathrm{W1}$
  G1: ground 1,4
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  G2: ground 3,4
  T1: tline 4,2 7,2 50
  R1: resistor 8,2 10,2 51
  C1: capacitor 11,2 11,4 220p
  G3: ground 11,4
  L1: inductor 11,2 14,2 1u
  C2: capacitor 14,2 14,4 220p
  G4: ground 14,4
  T2: tline 15,2 18,2 50
  Rt: resistor 19,2 19,4 50 l=$\mathrm{R_t}$
  G5: ground 19,4
  M2: voltmeter 21,2 21,4 l=$\mathrm{CH2}$
  G6: ground 21,4
wires:
  - 1,2 -- 3,2
  - 3,2 -- 4,2
  - 7,2 -- 8,2
  - 10,2 -- 11,2
  - 14,2 -- 15,2
  - 18,2 -- 19,2
  - 19,2 -- 21,2
notes:
  - text 7.5,1.5 small center: J1
  - text 14.5,1.5 small center: J2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/22-25mhz-bnc-perfboard.svg)

- C1・L1・C2 は 50 Ω 系の 3 次のバターワース (計算の値 212 pF・1.06 µH を E12 の 220 pF・1.0 µH に丸めた)。−3 dB は 15.4 MHz
- R1 (51 Ω) が信号源の抵抗。W1 は BNC アダプタのジャンパで **0 Ω** にし、基板の入口で 50 Ω の信号源を作る。
  CH1 は W1 の BNC の T 型の分岐で W1 そのもの (起電力) を見るので、帯域の中の比は 1/2 (−6.02 dB) になる
- T1・T2 は 50 Ω の同軸 (BNC–SMA) **30 cm**。R<sub>t</sub> は CH2 の手前に挟む BNC の 50 Ω のスルー終端器。J1・J2 は基板の端面の SMA

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
title: 図2 ユニバーサル基板の LPF (端面 SMA 2 つ、50 Ω 系)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  slots: on
  silk: board
parts:
  J1: sma/female-edge a10 011
  R1: resistor b10 e10 51
  C1: capacitor f10 f9 220p
  L1: inductor h10 p10 1u
  C2: capacitor r10 r9 220p
  J2: sma/female-edge x10 y11
wires:
  - a10 -- b10
  - e10 -- f10
  - f10 -- h10
  - p10 -- r10
  - r10 -- x10
  - 09 -- f9 black
  - f9 -- r9 black
  - r9 -- y9 black
notes:
  - text b13 red bold: W1 から (同軸 30 cm)
  - text p13 red bold: CH2 へ (50 Ω 終端)
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/perfboard/22-25mhz-bnc-perfboard.svg)

- 5×7 cm のユニバーサル基板を横に使い、10 行目を信号の通り道、9 行目を GND の筋にした。J1 (左) と J2 (右) は端面の SMA で、
  外側の金物を縁のパッド (0 列と Y 列) で 9 行目の GND の筋に半田付けする
- 部品のピンは短く切る。C1・C2 は 10 行目から 9 行目へ、隣の穴に立てる (ピンが長いと 25 MHz で数 nH のインダクタンスになり、
  減衰の深さが変わる)。L1 は 1.0 µH のアキシアルのインダクタ
- AD3 とは同軸だけでつなぐ (基板の図に AD3 は描かない)。J1 へは W1 の T 型の分岐から 30 cm の同軸、J2 からは 30 cm の同軸で CH2 の 50 Ω の終端器へ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| ハードウェア | BNC アダプタを付ける。W1 の出力のジャンパは 0 Ω |
| Wavegen | W1: Amplitude 0.5 V、Offset 0 V (R1 と LPF の入力で 100 Ω 前後、電流 5 mA ほど) |
| Network | Start 100 kHz、Stop 25 MHz、Log、Steps 201、Reference: Channel 1。上限を 9 MHz より上に選ぶ (仕様では 1/4 のシステムクロックまで選べ、入力の帯域で頭打ちになる) |
| 平均 | 多めに。Wavegen の帯域は BNC で 12 MHz @ −3 dB なので、25 MHz では信号が小さくなる (比を取るので落ちは打ち消されるが、雑音は増える。目安) |

15 MHz の時間波形が図3 (計算値)。CH2 は CH1 の 0.37 倍 (−8.6 dB) で、LPF と同軸 2 本の分 149° 遅れる。
125 MS/s で 15 MHz は 1 周期 8.3 点なので、時間波形でも形は読める。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 15 MHz — CH2 は 0.37 倍で 149° 遅れる (LPF の肩と同軸 2 本の遅れ)
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 15MHz 0.5V, range: 200mV/div}
ch2: {wave: sine 15MHz 0.185V phase -149deg, range: 200mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/22-25mhz-bnc-perfboard.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| C1, C2 | セラミックコンデンサ (C0G、221) | 各 220 pF |
| L1 | インダクタ (アキシアル) | 1.0 µH。SRF が 100 MHz 以上のもの (目安) |
| R1 | 抵抗 (1/4 W、信号源の抵抗) | 51 Ω |
| J1, J2 | 端面の SMA (メス) | 2 個 |
| — | ユニバーサル基板 | 5×7 cm、1.6 mm の FR-4、縁のパッド付き |
| T1, T2 | BNC–SMA の同軸 (50 Ω) | 各 30 cm |
| R<sub>t</sub> | BNC の 50 Ω のスルー終端器 | 1 個 |
| — | BNC の T 型の分岐 | 1 個 |
| — | 電源 | 使わない |
| — | 計器 | AD3 + BNC アダプタの W1・Scope 1・Scope 2 |

## 見るべき値

計算値。L と C は理想、同軸は損失なしの 50 Ω (遅れ 1.52 ns/30 cm)、CH2 は 1 MΩ ∥ 24 pF と 50 Ω の終端 (仮定)。
比較に、同じ LPF を理想の 50 Ω の系に入れた S21 から 6.02 dB 引いた線 (CH1 が起電力なので帯域の中は −6.02 dB) を並べる。

| 周波数 | 理想の S21 − 6.02 dB | 同軸 30 cm (この題) | 同軸 1 m (比べる) |
| --- | --- | --- | --- |
| 1 MHz | −6.02 dB | −6.11 dB | −6.10 dB |
| 10 MHz | −6.26 dB | −6.33 dB | −6.08 dB |
| −3 dB の点 (−9.02 dB) | 15.4 MHz | 15.5 MHz | 18.9 MHz |
| 25 MHz | −19.4 dB | −18.9 dB | **−14.7 dB** |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 3 次 LPF を 25 MHz まで — 同軸 30 cm なら理想に近い。1 m では肩が膨らむ
x: 周波数 Hz log 1M..25M
y: 利得 dB -25..0
lines:
  理想の S21 − 6 dB dB:
    - 100k -6.02
    - 1M -6.02
    - 3M -6.02
    - 5M -6.02
    - 7M -6.04
    - 10M -6.26
    - 12M -6.80
    - 14M -7.90
    - 15M -8.68
    - 16M -9.59
    - 18M -11.68
    - 20M -13.93
    - 22M -16.17
    - 25M -19.35
  同軸 30 cm dB:
    - 100k -6.11
    - 1M -6.11
    - 3M -6.11
    - 5M -6.10
    - 7M -6.12
    - 10M -6.33
    - 12M -6.85
    - 14M -7.90
    - 15M -8.64
    - 16M -9.51
    - 18M -11.50
    - 20M -13.66
    - 22M -15.82
    - 25M -18.88
  同軸 1 m dB:
    - 100k -6.11
    - 1M -6.10
    - 3M -6.07
    - 5M -6.03
    - 7M -6.01
    - 10M -6.08
    - 12M -6.26
    - 14M -6.65
    - 15M -6.94
    - 16M -7.32
    - 18M -8.38
    - 20M -9.86
    - 22M -11.67
    - 25M -14.70
notes:
  - level -9.02dB
  - mark 15.4M
  - mark 25M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/22-25mhz-bnc-perfboard.svg)

分かること:

- **BNC アダプタと 50 Ω の系で、9 MHz の壁の先の 25 MHz まで LPF の肩と減衰が読める。** 25 MHz で帯域の中から約 13 dB 下がる
  (理想の 3 次のバターワースで −13.3 dB)
- **同軸の長さが、10 MHz を超えると読みを変える。** 30 cm なら 25 MHz の誤差は 0.5 dB ほどだが、1 m では +4.7 dB 膨らみ、
  −3 dB の点も 18.9 MHz に動く。LPF の阻止域では入力の反射が大きく、信号源 (0 Ω) と R1 の間の同軸の長さで
  基板に届く電圧が変わるため。高い周波数ほど、同軸は短くする
- 1 MHz で −6.11 dB と 0.09 dB 低いのは、R1 が 50 Ω でなく 51 Ω の分と、CH2 の 1 MΩ の分
- 理想どおりの S21 を読みたいなら、信号源の 50 Ω を AD3 の側 (BNC アダプタのジャンパ 50 Ω) に置き、基板の入口で入射の電圧を
  取り出す方向性結合器か、VNA (NanoVNA の冊) で測る。AD3 の Network は 2 点の電圧の比しか見ないので、反射の分を分けられない
- 動かないときは、基板を SMA のスルー (中継ぎ) に替えて掃引し、0 dB の付近で平らかを先に確かめる。R1 が無いので帯域の中は 0 dB、
  25 MHz では CH2 の 24 pF と同軸 60 cm の分で +0.7 dB ほど持ち上がる (計算値)

## LTspice での確かめ

`sim/22-25mhz-bnc-perfboard.cir` で図1 を AC 解析した。L・C は理想、同軸は損失なし (**仮定**)。同軸の遅れを 1.52 ns (30 cm)・
5.05 ns (1 m)・1 fs (無し) に振り、同じ LPF を理想の 50 Ω の系に入れた S21 も同じデッキで解いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 理想の S21 (15 MHz・25 MHz) | −2.66 dB・−13.3 dB | 0.7364 (−2.66 dB)・0.2154 (−13.33 dB) | 合う |
| 30 cm の 1 MHz・10 MHz | −6.11 dB・−6.33 dB | 0.4950 (−6.11 dB)・0.4824 (−6.33 dB) | 合う |
| 30 cm の 15 MHz | 0.37 倍 (図3) | 0.3698 | 合う |
| 30 cm の 25 MHz | −18.9 dB | 0.1137 (−18.88 dB) | 合う |
| 1 m の 25 MHz | −14.7 dB | 0.1840 (−14.70 dB) | 合う |
| −9.02 dB の点 (30 cm・1 m) | 15.5 MHz・18.9 MHz | 15.45 MHz・18.93 MHz | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。BNC アダプタの帯域、W1 の出力インピーダンス (0 Ω か 50 Ω)、Network と Impedance の周波数の上限は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [Butterworth filter (Wikipedia)](https://en.wikipedia.org/wiki/Butterworth_filter)
