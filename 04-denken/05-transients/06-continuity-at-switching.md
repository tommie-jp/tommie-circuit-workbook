---
book: denken
chapter: 5
id: 5-6
title: 切り替えの瞬間 — C の電圧と L の電流は急に変わらない
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-6 切り替えの瞬間 — C の電圧と L の電流は急に変わらない

過渡現象の問題は「切り替えた直後に何が決まっているか」から解き始める。答えは 2 つ —
**コンデンサの電圧は急に変わらない**、**コイルの電流は急に変わらない**。どちらも
蓄えたエネルギー (CV²/2・LI²/2) が一瞬では動かせないためである。逆に言えば、
コンデンサの電流とコイルの電圧は一瞬で跳ぶ。同じ抵抗 R に C か L を直列にして方形波を加え、
入力が 0 V から 2 V に跳んだ直前と直後を並べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| v_C(0+) = v_C(0−) | コンデンサの電圧は切り替えの前後で同じ。i = C dv/dt が有限だから |
| i_L(0+) = i_L(0−) | コイルの電流は切り替えの前後で同じ。v = L di/dt が有限だから |
| RC 直列: i(0+) = V / R、v_C(0+) = 0 | 空のコンデンサは直後に短絡と同じに見える |
| RL 直列: i(0+) = 0、v_L(0+) = V | 電流の無いコイルは直後に開放と同じに見える |

## 回路図

```circuit
title: 図1 C と L を切り替えて R と直列にする
parts:
  V1: square b1 e1 1 l=$\mathrm{W1}$
  S1: spdt b3
  C1: capacitor a5 a7 10n
  L1: inductor c5 c7 10m
  R1: resistor c9 e9 1k i=i
  G1: ground e1
wires:
  - b1 -- S1.in
  - S1.1 |- a5
  - S1.2 |- c5
  - a7 -- a9 -- c9
  - c7 -- c9
  - e1 -- e9
notes:
  - text a1 blue: 入力 (CH1)
  - text c9 blue: R の電圧 (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/circuit/06-continuity-at-switching.svg)

- S1 を上 (1 側) に倒すと C1 (10 nF)、下 (2 側) に倒すと L1 (10 mH) が R1 (1 kΩ) と直列に入る。
  時定数はどちらも 10 µs (CR = 10 nF × 1 kΩ、L / R = 10 mH ÷ 1 kΩ)
- 入力は AD の Wavegen (W1) の方形波 (0 V〜2 V、2 kHz)。半周期 250 µs は 25 τ あるので、
  立ち上がりの直前には C は空 (0 V)、L の電流は 0 に戻っている
- R1 の電圧 (CH2) は電流 i × 1 kΩ。C か L の電圧は入力との差 (CH1 − CH2) で、AD の Math で出す

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  SW1: slide-switch c8(1) c9(C) c10(2)
  C1: capacitor/film c12 c14 10n
  L1: inductor/axial h12 h17 10m
  R1: resistor c20 c25 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a9 yellow
  - AD.1+ -- b9 yellow
  - AD.1- -- -t6 black
  - b8 -- b12 green
  - e10 -- f10 green
  - g10 -- g12 green
  - b14 -- b20 green
  - g17 -- g20 green
  - f20 -- e20 green
  - AD.2+ -- a20 blue
  - AD.2- -- -t22 black
  - a25 -- -t25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/breadboard/06-continuity-at-switching.svg)

- SW1 (スライドスイッチ) の真ん中 (9 列) に W1 と CH1 (1+)。1 側 (8 列) から C1 (12〜14 列、上の段)、
  2 側 (10 列) から溝を渡って L1 (12〜17 列、下の段) へ
- C1 と L1 の出口は 20 列で合わさり、R1 (20〜25 列) を通って GND のレールへ。CH2 (2+) は 20 列
- 1− と 2− は GND のレール。S1 を倒して C と L を入れ替え、2 回測る

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、2 kHz、Amplitude 1 V、Offset 1 V (0 V〜2 V) |
| Scope | CH1 = 入力、CH2 = R1 の電圧 (電流 × 1 kΩ)。2 ch とも 500 mV/div、0 V を下から 1 目盛。Time base 10 µs/div、Trigger は CH1 の立ち上がりで、位置を左から 2 目盛 |
| Math | M1 = C1 − C2 (C か L の電圧)。CH1・CH2 と同じ 500 mV/div |
| Cursors | X1 = −5 µs (切り替えの直前)、X2 = +1 µs (直後) |

2 枚は同じ設定で、変えたのは S1 だけ。赤の Math が C か L の電圧。

```scope
title: 図3 C を入れたとき — 電流 (CH2) は跳び、C の電圧 (Math) は 0 から滑らかに上がる
time: 10us/div
trigger: ch1 rising 1V at -3div
ch1: {wave: square 2kHz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | hp 10us, range: 500mV/div, position: -3div}
math: {expr: ch1 - ch2, unit: V, range: 500mV/div, position: -3div}
cursors: [-5us, 1us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/06-continuity-at-switching-1.svg)

```scope
title: 図4 L を入れたとき — 電流 (CH2) は 0 から滑らかに上がり、L の電圧 (Math) が跳ぶ
time: 10us/div
trigger: ch1 rising 1V at -3div
ch1: {wave: square 2kHz 1V offset 1V, range: 500mV/div, position: -3div}
ch2: {wave: ch1 | rc 10us, range: 500mV/div, position: -3div}
math: {expr: ch1 - ch2, unit: V, range: 500mV/div, position: -3div}
cursors: [-5us, 1us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/05-transients/scope/06-continuity-at-switching-2.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。
C と L を R より入力の側に置いたのは、R の電圧 (電流) を GND 基準の 1 本で読むため。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Square、2 kHz、**2 Vpp、Offset 1 V** (AD の Amplitude 1 V は山の高さ)、出力は High-Z |
| 1+ | CH1 の先端を 9 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 20 列 (R1 の上の端)、グランドクリップを GND のレール |
| Math | CH1 − CH2。R1 の電圧も入力も 2 V 近く振れるので、8 bit でも引き算が埋もれない |

**FG の 50 Ω で値が少し変わる** (計算値)。50 Ω が R1 に直列に足され、時定数は 10.5 µs になる。
C を入れたときの直後の電流は 2 V ÷ 1050 Ω = 1.90 mA で、CH2 は 1.81 V ではなく 1.73 V (直後 1 µs)、
CH1 も跳んだ直後は 1.90 V にへこむ。L を入れたときは直後の電流がほぼ 0 なので、CH1 は 2 V のまま。
跳ぶもの・跳ばないものの区別は変わらない。

## 見るべき値

計算値。τ = 10 µs、入力は 0 V → 2 V の段。直後 (+1 µs) の値は e^(−0.1) = 0.905 から。

| | 測る所 | 直前 (−5 µs、X1) | 直後 (+1 µs、X2) | 1 τ (10 µs) | 跳ぶか |
| --- | --- | --- | --- | --- | --- |
| C を入れたとき | R1 の電圧 (CH2) = 電流 × 1 kΩ | 0 V | 1.81 V | 0.74 V | **跳ぶ** (0 → 2 mA) |
| | C の電圧 (Math) | 0 V | 0.19 V | 1.26 V | 跳ばない |
| L を入れたとき | R1 の電圧 (CH2) = 電流 × 1 kΩ | 0 V | 0.19 V | 1.26 V | 跳ばない |
| | L の電圧 (Math) | 0 V | 1.81 V | 0.74 V | **跳ぶ** (0 → 2 V) |

直後の 0.19 V は、跳んだのではなく 1 µs の間に傾き (2 V ÷ 10 µs) で上がった分である。
Time base を 1 µs/div まで縮めても、跳ばない側は 0 V から線を引いたように上がる。

分かること:

- **C は直後に短絡、L は直後に開放**と見なしてよい。空の C・電流の無い L から
  始めるとき、直後の回路はこれで解ける。十分時間が経ったあとは逆に、C は開放、L は短絡
- 2 つの表は C と L で行が入れ替わっただけの同じ数になる。RC と RL の過渡が
  同じ指数の形 (5-1・5-3) になるのは、この入れ替わりのため
- 電流が流れているコイルを急に切ると、電流を保とうとして大きな電圧が出る
  (逆起電力。2-18 で確かめる)。リレーのコイルにダイオードを並べる理由

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope・Math の節)。
