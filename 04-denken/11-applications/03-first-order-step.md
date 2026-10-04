---
book: denken
chapter: 11
id: 11-3
title: 一次遅れ系のステップ応答 — RC で模す
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 11-3 一次遅れ系のステップ応答 — RC で模す

自動制御では、入力を急に一段変えたとき (ステップ入力) の出力の動きで、制御される物の
性質を表す。出力が遅れて近づき、行き過ぎない物が**一次遅れ系**で、ゲイン定数 K と
時定数 T の 2 つの数だけで決まる。5-1 の RC の充電回路に抵抗を 1 ピンすと、K と T を
別々に変えられる一次遅れ系の模型になる。ステップ応答から K と T を読む。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| G(s) = K / (1 + sT) | 一次遅れ系の伝達関数。K がゲイン定数、T が時定数 |
| y(t) = K U (1 − e^(−t/T)) | 大きさ U のステップ入力に対する出力 (ステップ応答) |
| y(∞) = K U | 十分に時間が経った後の出力 (定常値)。**K = 定常値 ÷ 入力** |
| y(T) = 0.632 K U | T 経つと定常値の 63.2 %。**T = 63.2 % に届く時間** |
| K = R2 / (R1 + R2)、T = C1 × R1R2 / (R1 + R2) | この回路の K と T (C1 から見た抵抗は R1 と R2 の並列) |

## 回路図

```circuit
title: 図1 RC で作る一次遅れ系
style:
  standard: jis
  pitch: 1.2
parts:
  V1: square c1 g1 l=$\mathrm{W1}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  R1: resistor c5 c7 20k
  C1: capacitor c9 g9 100n
  R2: resistor c11 g11 20k
  M2: voltmeter c14 g14 l=$\mathrm{CH2}$
  G1: ground g1
wires:
  - c1 -- c3 -- c5
  - c7 -- c9 -- c11 -- c14
  - g1 -- g3 -- g9 -- g11 -- g14
notes:
  - text a1 blue: 入力 u
  - text a13 blue: 出力 y
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/circuit/03-first-order-step.svg)

- W1 は AD の波形発生器 (Wavegen)。0 V と 5 V を行き来する方形波で、立ち上がりの 1 回ずつがステップ入力
- R1 (20 kΩ) と R2 (20 kΩ) の分圧で K = 0.5、C1 (100 nF) から見た抵抗は R1 と R2 の並列の 10 kΩ で
  T = 10 kΩ × 100 nF = 1.0 ms
- R2 を抜くと、5-1 と同じ RC の充電回路 (K = 1、T = 20 kΩ × 100 nF = 2.0 ms) になる。
  **1 本の抵抗で K と T が両方変わる**
- CH1 (M1) が入力 u、CH2 (M2) が出力 y (C1 の両端)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 20k
  C1: capacitor/ceramic c14 c18 100n
  R2: resistor e14 e22 20k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2-, 2+]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.1+ -- a5 yellow
  - AD.1- -- -t8 black
  - b10 -- b14 green
  - AD.2+ -- a14 green
  - AD.2- -- -t12 black
  - a18 -- -t18 black
  - a22 -- -t22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/breadboard/03-first-order-step.svg)

- 5〜10 列が R1、14〜18 列が C1、14〜22 列が R2。14 列が出力の節点で、10 列から緑の線で渡してある
- C1 の 18 列と R2 の 22 列は、黒い線で上の青いレール (GND) へ落とす
- CH1 (1+) は入力 (5 列)、CH2 (2+) は出力 (14 列)。1− と 2− は GND のレール
- R2 を抜けば K = 1・T = 2.0 ms の回路になる。抜き差しするのは R2 だけ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、25 Hz、Amplitude 2.5 V、Offset 2.5 V (0 V〜5 V の方形波)。半周期 20 ms は T の 10 倍以上あり、毎回ほぼ定常値まで届いてから次の段が来る |
| Scope | CH1 = 入力 u、CH2 = 出力 y。どちらも 1 V/div、Offset −3 div (0 V を下から 1 目盛)。Time base 1 ms/div、Trigger は CH1 の立ち上がり 2.5 V、Position を左へ 4 目盛寄せる |
| カーソル | X1 = 0 (立ち上がり)、X2 = 1 ms。CH2 の X2 の読みが 0.632 K U |
| Measure | CH2 の Maximum (定常値 K U) と Rise Time (10〜90 %。一次遅れ系では 2.2 T) |

入力と出力を同じ V/div で並べる。定常値が入力の何倍か (K) を、高さの比でそのまま読むため。
R2 を抜いた図4 は T が 2 倍になるので、Time base を 2 ms/div にして、立ち上がりから 9 T を画面に入れる
(1 ms/div のままだと 4.5 T で画面が切れ、定常値に届く前で終わる)。

```scope
title: 図3 R2 あり — 定常値は入力の半分 (K = 0.5)、1 ms で 63 %
time: 1ms/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: square 25Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms | gain 0.5, range: 1V/div, position: -3div}
cursors: [0, 1ms]
measure: [vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/scope/03-first-order-step-1.svg)

```scope
title: 図4 R2 を抜く — K = 1、2 ms で 63 % (T が倍なので横は 2 ms/div)
time: 2ms/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: square 25Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 2ms, range: 1V/div, position: -3div}
cursors: [0, 2ms]
measure: [vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/11-applications/scope/03-first-order-step-2.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Square、25 Hz、**5 Vpp、Offset 2.5 V** (AD の Amplitude 2.5 V は山の高さ。FG の多くは Vpp で決める)、出力は High-Z。High 5 V・Low 0 V で決められる機種はそれでよい |
| 1+ | CH1 の先端を 5 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 14 列 (出力)、グランドクリップを GND のレール |

FG の 50 Ω は R1 (20 kΩ) に直列に足されるだけで、K は 0.4994、T は 1.001 ms (計算値)。
0.1 % の違いは部品の誤差に隠れ、見るべき値はそのまま使える。プローブは ×10 にする。
×1 (1 MΩ) だと R2 に並列の 1 MΩ で K が 1 % ほど下がる。

## 見るべき値

計算値。U = 5 V のステップ。

| 読む所 | R2 あり (K = 0.5、T = 1.0 ms) | R2 を抜く (K = 1、T = 2.0 ms) |
| --- | --- | --- |
| 定常値 K U (CH2 の Maximum) | 2.50 V | 5.00 V |
| T 経ったときの出力 (カーソル X2) | 1.58 V (1 ms) | 3.16 V (2 ms) |
| 3 T 経ったときの出力 (定常値の 95 %) | 2.38 V (3 ms) | 4.75 V (6 ms) |
| Rise Time (10〜90 %、2.2 T) | 2.20 ms | 4.39 ms |
| 読み取った K と T | 2.50 ÷ 5 = 0.5、1.0 ms | 5.00 ÷ 5 = 1、2.0 ms |

分かること:

- **定常値と入力の比が K、定常値の 63.2 % に届く時間が T。** ステップ応答の 1 枚の図から、
  伝達関数 K / (1 + sT) の 2 つの数が読める
- 出力は**行き過ぎずに**定常値へ近づく。これが一次遅れ系の特徴で、振動する二次遅れ系 (LC を含む回路) との違い
- 立ち上がりの傾きは K U / T (R2 ありで 2.5 V/ms)。**原点の接線を延ばすと、ちょうど t = T で定常値の高さに届く**。
  図3 の 0〜1 ms の立ち上がりに定規を当てて確かめる
- 同じ形の式は、電熱の温度上昇 (熱容量と熱抵抗)、モータの回転の立ち上がり (慣性と摩擦) にも出る。
  制御の問題では、この RC の図に置き換えて考えられる。周波数で見た同じ回路が 11-4

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
