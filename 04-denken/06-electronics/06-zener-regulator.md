---
book: denken
chapter: 6
id: 6-6
title: ツェナーダイオードの定電圧
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-6 ツェナーダイオードの定電圧

ツェナーダイオードは、逆方向の電圧がツェナー電圧 V_Z に届くと急に電流を流し始め、
それ以上は電圧がほとんど上がらない。直列の抵抗 R で電流を決めてやると、
入力の電圧や負荷が変わっても出力は V_Z 近くに保たれる (**定電圧回路**)。
入力をゆっくり上げ下げして入出力の関係を描き、負荷をつないだときの変化も見る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_out = V_in (V_in < V_Z、無負荷) | ツェナーに電流が流れないうちは入力がそのまま出る |
| V_out ≒ V_Z0 + I_Z r_Z | 降伏したあと。V_Z0 は折れ点の電圧、r_Z は動抵抗 |
| I = (V_in − V_out) / R = I_Z + I_L | R の電流がツェナーと負荷に分かれる |
| ΔV_out / ΔV_in = r_Z / (R + r_Z) | 入力の変動がどれだけ出力に残るか (無負荷)。小さいほど良い |
| V_in ≧ V_Z (R + R_L) / R_L | 負荷 R_L をつないでも定電圧になる入力の条件 |

## 回路図

```circuit
title: 図1 ツェナーダイオードの定電圧回路
parts:
  V1: triangle b1 d1 3 l=$\mathrm{W1}$
  R1: resistor b1 b4 220 i=I
  D1: zener d6 b6 3.3V
  S1: switch b6 b9
  RL: resistor b9 d9 1k
  G1: ground d1
wires:
  - b4 -- b6
  - d1 -- d6 -- d9
notes:
  - text a1f0 blue: 入力 (CH1)
  - text a6f0 blue: 出力 (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/06-zener-regulator.svg)

- W1 は AD の Wavegen の三角波。Amplitude 3 V、Offset 2 V なので、−1 V から 5 V まで
  10 Hz でゆっくり動く
- D1 は 3.3 V のツェナーダイオード (BZX55C3V3・RD3.3E などの 500 mW 級)。**カソードを
  出力の側**に向けて、逆方向に電圧をかける
- R1 (220 Ω) が電流を決める。5 V のとき R1 に流れるのは 7.6 mA (Wavegen の 10 mA 以内)
- S1 を閉じると負荷 R_L (1 kΩ) がつながる。開けて 1 回、閉じて 1 回測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c6 c11 220
  D1: zener c16 c13 3.3V
  S1: switch c18 c20
  RL: resistor c21 c26 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a6 yellow
  - AD.1+ -- b6 yellow [h10]
  - AD.1- -- -t9 black
  - b11 -- b13 green
  - a16 -- -t16 black
  - e13 -- e18 green
  - b20 -- b21 green
  - AD.2+ -- b18 blue
  - AD.2- -- -t22 black
  - a26 -- -t26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/breadboard/06-zener-regulator.svg)

- R1 は 6〜11 列、D1 は 13〜16 列。D1 の**帯 (カソード) を 13 列** (出力の側) に向ける。
  16 列 (アノード) は黒い線で GND のレールへ
- 11 列と 13 列を緑の線でつなぎ、13 列から下の e 行の線で S1 (18〜20 列) へ運ぶ。
  S1 の先に R_L (21〜26 列)、26 列を GND のレールへ
- CH1 (1+) は入力 (6 列)、CH2 (2+) は出力 (18 列)。1− と 2− は GND のレール

## 計器の設定

計器は Analog Discovery 3 (AD3)。入力の三角波は Wavegen W1、入力と出力の波形は Scope の 2 ch で読む。回路の電流は最大 7.6 mA で、W1 の 30 mA 以内に収まる。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Triangle、10 Hz、Amplitude 3 V、Offset 2 V (−1 V〜5 V) |
| Scope | CH1 = 入力、CH2 = 出力。2 ch とも 1 V/div |
| XY | X = CH1、Y = CH2。入出力の折れ線が出る |
| Cursors | XY の画面で X = 4 V と 5 V の所の Y を読む |

表の値は、XY の画面にカーソルを当てるか、時間軸の画面で CH1 が 4 V・5 V を通る瞬間の CH2 を
読む。三角波の上りと下りで同じ線をなぞるかも見る。

時間軸の画面 (S1 を開けた無負荷) は図3 になる。入力 (CH1) の三角波が 4 V・5 V を通る所にカーソルを当てると、
出力 (CH2) は 3.21 V・3.33 V と読める (表の値。V_Z0 = 3.1 V、r_Z = 30 Ω の仮定)。

```scope
title: 図3 入力 (CH1) が 4 → 5 V のとき、出力 (CH2) は 3.21 → 3.33 V
time: 10ms/div
trigger: ch1 rising 2V
ch1: {wave: triangle 10Hz 3V offset 2V phase 90deg, range: 1V/div, position: -2div}
ch2: {wave: "= max(min(ch1, 3.1V + (ch1 - 3.1V) * 30 / 250), -0.65V + (ch1 + 0.65V) * 10 / 230)", range: 1V/div, position: -2div}
cursors: [16.667ms, 25ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/scope/06-zener-regulator.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Triangle、10 Hz、**6 Vpp、Offset 2 V** (AD の Amplitude 3 V は山の高さ)、出力は High-Z |
| 1+ | CH1 の先端を 6 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 18 列 (出力)、グランドクリップを GND のレール |

- 表の横軸は CH1 (FG の端子の電圧) なので、FG の 50 Ω は入出力の関係に入らない。
  ただし FG の端子は電流の分だけ下がる。5 V まで届かせるなら、CH1 の山が 5 V になるまで
  振幅を上げる (7.6 mA × 50 Ω = 0.38 V ぶん、計算値)
- High 5 V・Offset 2 V の三角波を出せない FG は、Offset を上げて負の側を削ってよい
  (見たいのは 3〜5 V の所)
- 多くの汎用オシロは XY 表示がある。X = CH1、Y = CH2 で同じ折れ線が出る

## 見るべき値

計算値。ツェナーの特性は電流の小さい所ではなめらかに曲がり、値は個体差もある。
ここでは**折れ点 V_Z0 = 3.1 V、動抵抗 r_Z = 30 Ω と仮定**した (順方向は 0.65 V、10 Ω)。

| 入力 (CH1) | 出力 無負荷 (CH2) | R1 の電流 | 出力 R_L = 1 kΩ (CH2) | 負荷の電流 / ツェナーの電流 |
| --- | --- | --- | --- | --- |
| −1 V | −0.67 V (順方向) | −1.5 mA | −0.66 V | — |
| 3 V | 3.00 V (まだ降伏しない) | 0 mA | 2.46 V (分圧だけ) | 2.46 mA / 0 mA |
| 4 V | 3.21 V | 3.6 mA | 3.13 V | 3.13 mA / 0.85 mA |
| 5 V | 3.33 V | 7.6 mA | 3.24 V | 3.24 mA / 4.75 mA |

- 入力が 4 V → 5 V と 1 V 変わっても、出力 (無負荷) は 0.12 V しか変わらない
  (ΔV_out / ΔV_in = 30 ÷ 250 = 0.12)
- R_L をつなぐと出力は 5 V のとき 3.33 V → 3.24 V に下がる。定電圧になるのは入力が
  3.1 V × 1220 ÷ 1000 = 3.78 V を越えてから (それより下では R1 と R_L の分圧)

```graph
title: 図4 入出力の関係 (計算) — 3.1 V を越えると出力が頭打ちになる
x: 入力 V -1..5
y: 出力 V -1..4
lines:
  無負荷 V: max(min(x, 3.1 + (x - 3.1) * 30 / 250), -0.65 + (x + 0.65) * 10 / 230)
  負荷 1 kΩ V: max(min(0.8197 * x, 3.1 + (0.8197 * x - 3.1) * 30 / 210.3), -0.65 + (0.8197 * x + 0.65) * 10 / 190.3)
notes:
  - mark 3
  - mark 4
  - mark 5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/graph/06-zener-regulator.svg)

R_L をつないだ線の 0.8197 は分圧の比 1000 ÷ 1220、210.3 は R1 ∥ R_L (180.3 Ω) に r_Z を足した値。

分かること:

- **ツェナーの電流が増えても電圧はほとんど増えない**。入力の変動は R1 の電圧降下が
  引き受け、出力に残るのは r_Z / (R1 + r_Z) の割合だけ
- 負荷に電流を取られると、ツェナーの電流 (4.75 mA) が減り、出力も少し下がる。負荷の電流が
  R1 の電流を上回ると (R_L が小さすぎると) 定電圧にならない。R1 は「最大の負荷の電流 +
  ツェナーを降伏させておく電流」が流れるように選ぶ
- 順方向 (入力が負) では普通のダイオード (6-1) と同じく −0.65 V あたりで止まる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
