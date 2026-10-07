---
book: denken
chapter: 9
id: 9-4
title: 直流モータの速度制御 — 電圧 (PWM) で速さが変わる
tier: 100
source: 自作
board: BB
---

# 9-4 直流モータの速度制御 — 電圧 (PWM) で速さが変わる

直流モータの回転数は N = (V − I Ra) / Ke で決まる。速さを変えるには、端子電圧 V を変えるのが一番素直
(電圧制御)。抵抗を直列に入れて電圧を落とすと抵抗が熱を出すので、今は MOSFET を速く入り切りして
**平均の電圧をデューティ比 D で変える** (PWM。10-3 の降圧チョッパと同じ考え)。
9-1・9-2 と同じ小型 DC モータを電池 3 本 (4.5 V) で回し、D を変えて平均電圧と回転数を確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vavg = D × Vs | モータに掛かる平均の電圧。Vs は電源の電圧、D はオンの時間の割合 |
| E = Vavg − I × Ra | 逆起電力 (9-1)。無負荷では I が小さいので E ≒ Vavg |
| N = E / Ke | 回転数は逆起電力に比例する (9-2) |

この題のモータは 9-1・9-2 の値を使う: Ra ≒ 3 Ω、無負荷電流 I ≒ 15 mA、Ke ≒ 0.67 mV/rpm。
回転数は、PWM を止めた直後の端子電圧 (惰性で回るモータが発電する E) から N = E / Ke で求める。

## 回路図

```circuit
title: 図1 MOSFET でモータを PWM 駆動する
style:
  standard: jis
  pitch: 1.2
parts:
  B1: battery 1,3 1,9 4.5
  W1: square 3,7 3,9 l=$\mathrm{W1}$
  M2: voltmeter 5,7 5,9 l=$\mathrm{CH2}$
  RGS: resistor 7,7 7,9 10k
  RG: resistor 7,7 10,7 470
  D1: schottky 10,6 10,3 1N5819
  M1: motor 12,3 12,6
  M3: voltmeter 14,3 14,6 l=$\mathrm{CH1}$
  Q1: nmos-e 12,7 IRLZ44N
  G1: ground 1,9
wires:
  - 1,3 -- 10,3 -- 12,3 -- 14,3
  - 10,6 -- 12,6 -- 14,6
  - 12,6 -- Q1.D
  - 3,7 -- 5,7 -- 7,7
  - 10,7 -| Q1.G
  - Q1.S |- 12,9
  - 1,9 -- 3,9 -- 5,9 -- 7,9 -- 12,9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/circuit/04-pwm-speed-control.svg)

- B1 は単 3 電池 3 本 (4.5 V)。起動の一瞬はモータに Vs / Ra = 1.5 A ほど流れる (巻線が止まっていて E = 0 のため)。
  AD の Supplies (1 レール 250 mW) では足りないので電池にする
- W1 は AD の波形発生器 (Wavegen) の方形波 (0〜5 V、20 kHz)。RG (470 Ω) はゲートの容量を充電する電流の山を 5 V ÷ 470 Ω ≒ 11 mA に抑え (Wavegen の目安 10 mA 程度)、
  RGS (10 kΩ) は W1 を外したときに RG を通してゲートを GND に落とし、Q1 を切る
- Q1 は IRLZ44N (ロジックレベルの N チャネル MOSFET、ゲート 5 V でオン抵抗 0.035 Ω 以下)。
  2N7000 (回路の本の 7-2) は起動の 1.5 A に耐えないので、大きいものにした
- D1 (1N5819、ショットキー) は還流ダイオード。Q1 がオフの間、モータの巻線のインダクタンスが流し続ける電流を D1 に回す
- M3 (CH1) はモータの両端 (差動)、M2 (CH2) は W1 (ゲートを駆動する方形波)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 下の赤レール = 電池の + (4.5 V)、青レール = GND (上の青レールと 28 列でつなぐ)
board: half
parts:
  RGS: resistor c9 c5 10k
  RG: resistor j9 j14 470
  Q1: transistor/to220 f14(G) f15(D) f16(S) IRLZ44N
  D1: schottky g19(A) g23(K) 1N5819
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2+, 2-, 1-, 1+]
  BAT:
    type: device
    at: bottom
    label: 電池 3本 4.5V
    pins: ["+", "-"]
  MOT:
    type: device
    at: bottom
    label: DCモータ
    pins: ["-", "+"]
wires:
  - AD.W1 -- a9 yellow
  - AD.2+ -- b9 blue
  - e9 -- f9 yellow
  - a5 -- -t5 black
  - AD.GND -- -t7 black
  - AD.2- -- -t13 black
  - -t28 -- -b28 black
  - j16 -- -b16 black
  - i15 -- i19 green
  - j23 -- +b23 red
  - BAT.+ -- +b3 red
  - BAT.- -- -b4 black
  - MOT.+ -- i23 red
  - MOT.- -- j19 green
  - AD.1+ -- a23 orange
  - e23 -- f23 orange
  - AD.1- -- a19 white
  - e19 -- f19 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/breadboard/04-pwm-speed-control.svg)

- Q1 (IRLZ44N、TO-220) は印字の面を手前にして左から G・D・S。下のブロックの 14 列 (G)・15 列 (D)・16 列 (S)。
  胴が穴を覆うので、各列の空いた j 行から線を出す。S (j16) は下の青レール (GND) へ
- 9 列が W1 (ゲートの駆動)。上のブロックの 9 列に W1 と CH2 を挿し、溝を渡って下の 9 列へ。
  RG (j9→j14) でゲートへ。RGS (9→5 列、5 列は上の青レールへ) が W1 の側を GND に落とす
- 電池は下の赤レール (+) と青レール (−)。上下の青レールは 28 列の黒い線でつなぐ
- ドレインは緑の線 (i15→i19) で 19 列へ延ばす。19 列にモータの − と D1 の A、23 列 (下の赤レールから) にモータの + と D1 の K
- CH1 はモータの両端。1+ は上の 23 列から溝を渡って 23 列 (+)、1− は上の 19 列から 19 列 (ドレイン)。CH2 は 9 列 (W1) と上の青レール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、20 kHz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)、Symmetry (デューティ比) を 25・50・75 % に変える |
| Scope | CH1 = モータの両端 (差動)。CH2 = W1。Time base は 20 µs/div |
| Measure | CH1 の Average (Vavg)、CH2 の Duty |
| 回転数 (E) | Scope の Mode を Screen にして 100 ms/div。回っている間に Wavegen の Stop を押し、止めた直後の CH1 の値を読む (惰性で回るモータの E) |

20 kHz は耳に聞こえない周波数 (回路の本の 7-2)。1 kHz に下げると巻線が鳴る。

D = 50 % の画面。モータの端子は、Q1 がオンの間は電池の 4.5 V、オフの間は 0 V (理想) を行き来し、平均が 2.25 V になる。

```scope
title: 図3 D 50 % — モータの電圧 (CH1) の平均は 2.25 V
time: 20us/div
trigger: ch2 rising 2.5V
ch1: {wave: square 20kHz 2.25V offset 2.25V, range: 2V/div, position: -3div}
ch2: {wave: square 20kHz 2.5V offset 2.5V, range: 2V/div, position: 1div}
measure: [avg, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/09-rotating-machines/scope/04-pwm-speed-control.svg)

図は理想の形。実物では、オフの間にモータの電流が D1 を通って流れ続けるあいだ、端子は −0.3 V
(D1 の順電圧) になる。無負荷の小さい電流だと、電流がオフの途中で 0 まで落ちて (不連続)、残りの時間は
端子に E が見える。どちらもオフの間の形が変わるだけで、**平均の電圧で速さが決まる**ことは変わらない。

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH1 はモータの両端 (23 列と 19 列) を差動で挟んでいる。19 列 (Q1 のドレイン) は GND ではない。
ここにグランドクリップを当てると Q1 がクリップで短絡され、モータが電池にじかにつながって全速で回る (PWM が効かない)。
モータの電圧は 0〜4.5 V と振れの全部なので、**回路はそのままで、2 本の先端を 23 列と 19 列に当て、CH1 − CH2 で引く**。
2 ch はこれで使い切るので、ゲートの方形波は FG の設定 (Duty) で読む。

- W1 は FG の OUT (High-Z)。Square、20 kHz、Duty 25・50・75 %、High 5 V / Low 0 V (Amplitude と Offset で入れる機種なら 5 Vpp・2.5 V)。
  FG の GND は青レール。ゲートは約 1.5 nF の容量なので、FG の 50 Ω と RG 470 Ω で立ち上がりが 1〜2 µs ほど鈍る (時定数 約 0.8 µs) が、周期 50 µs に比べて短い
- CH1 の先端は 23 列 (モータの +)、CH2 の先端は 19 列 (ドレイン)、グランドクリップは 2 本とも青レール。
  電池は大地から浮いているので、青レールが大地につながっても回路は変わらない
- Vavg は Math の CH1 − CH2 の Mean か、CH1 と CH2 の Mean の差。23 列は電池の + そのものなので CH1 はほぼ 4.5 V の直流で、
  CH2 の Mean を 4.5 V から引いてもよい
- E は FG の出力を切った直後の CH1 − CH2 (Roll の表示で読む)

## 見るべき値

計算値。Vs = 4.5 V、Ra = 3 Ω、無負荷電流 15 mA (I × Ra = 0.045 V)、Ke = 0.67 mV/rpm。Vavg は理想 (D1 の順電圧と Q1 のオン抵抗を無視)。

| D | Vavg (CH1 の Average) | E (止めた直後の CH1) | N = E / Ke | 分かること |
| --- | --- | --- | --- | --- |
| 25 % | 1.13 V | 1.08 V | 約 1600 rpm | ゆっくり回る |
| 50 % | 2.25 V | 2.21 V | 約 3300 rpm | D に比例して速くなる |
| 75 % | 3.38 V | 3.33 V | 約 5000 rpm | |
| 100 % (オンのまま) | 4.50 V | 4.46 V | 約 6600 rpm | 電池にじかにつないだのと同じ |

**回転数はデューティ比にほぼ比例する。** PWM は抵抗で電圧を落とすのと違い、Q1 はオンかオフのどちらかなので
Q1 での損失がほとんど無い (オン抵抗 0.035 Ω × 15 mA の 2 乗 ≒ 8 µW)。電車のチョッパ制御や、今のインバータの元になった考え方。

- 実物では D1 の順電圧の分だけ Vavg が少し下がるか、電流が不連続になって E の分だけ少し上がる。
  E (止めた直後の値) は Vavg と数 % しか違わず、回転数の比は D の比にほぼ合う
- D を小さくしすぎると (10 % 以下)、摩擦に負けて止まる。止まると E = 0 になり、電流は D × Vs / Ra まで増える

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
