---
book: denken
chapter: 6
id: 6-7
title: トランジスタのスイッチ — 飽和と遮断
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-7 トランジスタのスイッチ — 飽和と遮断

トランジスタは増幅 (6-3) のほかに、**スイッチ**としても使う。ベースに電流を流さなければ
コレクタには流れず (**遮断**、スイッチが切れた状態)、ベースに十分な電流を流すと
コレクタとエミッタの間がほぼ 0 V まで下がる (**飽和**、スイッチが入った状態)。
入力を 0 V と 5 V で切り替えてコレクタの電圧を見たあと、入力をゆっくり動かして、
遮断・能動・飽和の 3 つの領域をつないだ入出力の線を描く。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_B = (V_in − V_BE) / R_B | ベース電流。V_BE ≒ 0.65 V |
| I_C(sat) = (V_CC − V_CE(sat)) / R_C | 飽和したときのコレクタ電流。R_C で決まり、h_FE によらない |
| I_B > I_C(sat) / h_FE | 飽和する条件。実用では 2〜10 倍の余裕を持たせる |
| V_out = V_CC − h_FE I_B R_C | 能動領域 (遮断と飽和の間) の出力 |

## 回路図

```circuit
title: 図1 トランジスタのスイッチ
parts:
  V1: square d1 f1 2.5 l=$\mathrm{W1}$
  RB: resistor d1 d3 47k i=IB
  Q1: npn d5 2SC1815
  RC: resistor a5 c5 1k i=IC
  VCC: vcc a5
  G1: ground f1
wires:
  - d3 -| Q1.B
  - c5 -| Q1.C
  - Q1.E -| f5
  - f1 -- f5
notes:
  - text c1 blue: 入力 (CH1)
  - text c5h5 blue: コレクタ (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/07-transistor-switch.svg)

- R_B (47 kΩ) がベース電流を決め、R_C (1 kΩ) が飽和のときのコレクタ電流を決める
- V_CC は AD の Supplies (+5 V)。入力は AD の Wavegen (W1) で、0 V と 5 V を行き来させる
- 出力はコレクタの電圧 (CH2)。入力が 5 V のとき 0.1 V 近く、0 V のとき 5 V になる (入力と逆)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RB: resistor c10 c15 47k
  Q1: transistor e15(B) e16(C) e17(E) 2SC1815
  RC: resistor c24 c16 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-, V+]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a10 yellow
  - AD.1+ -- b10 yellow [h10]
  - AD.1- -- -t13 black
  - a17 -- -t17 black
  - AD.2+ -- a16 green
  - AD.2- -- -t21 black
  - AD.V+ -- +t27 red
  - +t24 -- a24 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/breadboard/07-transistor-switch.svg)

- Q1 (2SC1815) は**平らな面を奥に向けて**挿すと、左から B (15 列)・C (16 列)・E (17 列)。
  足の並びをデータシートで確かめてから挿す
- R_B は 10〜15 列で、W1 と CH1 (1+) を 10 列に挿す。R_C は 16〜24 列、24 列を赤い線で
  上の + のレール (V+ = 5 V) へ。エミッタ (17 列) は黒い線で GND のレールへ
- CH2 (2+) はコレクタ (16 列)。1− と 2− は GND のレール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Wavegen (1 回目) | W1: Square、1 kHz、Amplitude 2.5 V、Offset 2.5 V (0 V〜5 V) |
| Wavegen (2 回目) | W1: Triangle、10 Hz、Amplitude 2.5 V、Offset 2.5 V (0 V〜5 V) |
| Scope | CH1 = 入力、CH2 = コレクタ。2 ch とも 1 V/div、0 V を下から 1 目盛。Time base 200 µs/div |
| Measure | CH2 の Maximum・Minimum |
| XY (2 回目) | X = CH1、Y = CH2。入出力の線が出る |

```scope
title: 図3 入力 5 V で飽和 (0.1 V)、0 V で遮断 (5 V) — 出力は入力の裏返し
time: 200us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 1kHz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | invert | gain 0.98 | offset 5V, range: 1V/div, position: -3div}
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/scope/07-transistor-switch.svg)

図3 の CH2 は、V_CE(sat) を 0.1 V とした理想の形 (5 V − 0.98 × 入力)。実物では、入力が
0 V に落ちてから出力が上がるまでに数 µs の遅れ (蓄積時間) がある。Time base を 2 µs/div に
縮めると見える。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。1 回目は Square、2 回目は Triangle。**5 Vpp、Offset 2.5 V** (AD の Amplitude 2.5 V は山の高さ)、出力は High-Z。High 5 V・Low 0 V で決められる機種はそれでよい |
| V+ | 安定化電源の 5 V。電流制限は 10 mA (飽和しても I_C は 5 mA まで) |
| 1+ | CH1 の先端を 10 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 16 列 (コレクタ)、グランドクリップを GND のレール |

- FG が流すのはベース電流 (最大 93 µA) だけで、50 Ω による低下は 5 mV 足らずと無視できる
- 2 回目の XY は、汎用オシロの XY 表示 (X = CH1、Y = CH2) でそのまま出る

## 見るべき値

計算値。h_FE = 250、V_BE = 0.65 V、V_CE(sat) = 0.1 V と仮定した (h_FE は個体差が大きい)。

| 入力 (CH1) | I_B | h_FE × I_B | コレクタ (CH2) | 領域 |
| --- | --- | --- | --- | --- |
| 0 V〜0.65 V | 0 | 0 | 5.00 V | 遮断 |
| 1.0 V | 7.4 µA | 1.9 mA | 3.14 V | 能動 |
| 1.5 V | 18.1 µA | 4.5 mA | 0.48 V | 能動 (飽和の手前) |
| 5 V | 92.6 µA | 23 mA (流せるのは 4.9 mA) | 0.10 V | 飽和 |

- 飽和に要るベース電流は I_C(sat) / h_FE = 4.9 mA ÷ 250 = 19.6 µA、入力で言えば 1.57 V。
  入力 5 V では 92.6 µA 流すので、**4.7 倍の余裕**で飽和している
- h_FE が 100 の個体でも 92.6 µA × 100 = 9.3 mA > 4.9 mA で飽和する。余裕を持たせる理由

```graph
title: 図4 入出力の関係 (計算) — 0.65 V まで遮断、1.57 V から飽和
x: 入力 V 0..5
y: コレクタの電圧 V 0..5.5
lines:
  コレクタ V: max(min(5, 5 - 5.319 * (x - 0.65)), 0.1)
notes:
  - band 0 0.65: 遮断
  - band 1.57 5: 飽和
  - mark 1.0
  - mark 1.5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/graph/07-transistor-switch.svg)

式の 5.319 は h_FE R_C / R_B = 250 × 1 kΩ ÷ 47 kΩ (能動領域の傾き)。

分かること:

- **スイッチとして使うのは遮断と飽和の 2 つの端だけ**。どちらもトランジスタの損失
  (V_CE × I_C) がほぼ 0 になる。能動領域 (1.0 V の所で 3.14 V × 1.9 mA = 5.9 mW) を
  速く通り抜けるほど発熱が少ない。パワーエレクトロニクス (10 章) のスイッチも同じ考え
- 飽和すると出力は h_FE によらず 0.1 V 近くに決まる。増幅 (6-3) では h_FE の
  ばらつきを負帰還で抑えたが、スイッチでは余裕のあるベース電流で抑える
- 出力は入力の裏返し (入力 H で出力 L)。論理回路の NOT (インバータ) の元の形

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。2SC1815 の足の並びと V_CE(sat) はメーカーのデータシート。
