---
book: analog-discovery
chapter: 8
id: 8-2
title: 隣の列との容量 (数 pF) を測る
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-2 隣の列との容量 (数 pF) を測る

8-1 でジャンパ 1 本は問題ないと分かった。次はブレッドボードの**構造そのもの**が
持つ寄生を測る。**何もつながず、ただ隣り合っているだけの 2 つの列**の間には、
金属レールが近接することで数 pF の容量ができる。6-1〜6-4 と同じ基準抵抗の
仕組みで、この小さな容量を測る。

## 回路図

```circuit
title: 図1 基準抵抗と列間の寄生容量
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor 3,3 6,3 330
  Cstray: capacitor 9,3 12,3 2.5p l=$\mathrm{C_{stray}}$
  G1: ground 14,3
  Cin: capacitor 9,3 9,5 48p l=$\mathrm{C_{in}}$
  G2: ground 9,5
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 9,3
  - AD.2+ -| 9,3
  - AD.2- -| 12,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/02-row-capacitance.svg)

- C<sub>stray</sub> は**部品ではない**。実装した部品ではなく、ブレッドボードの 2 つの列が
  近いことで生じる寄生容量を表す (実体配線図には現れない)
- C<sub>in</sub> も部品ではない。**AD のオシロ入力の容量** (1 入力あたり約 24 pF、2-9)。
  10 列には CH2 (2+) と CH1 の − 側 (1−) の 2 つの入力がつながるので、合わせて
  約 48 pF が C<sub>stray</sub> と並列に GND へつながる。**測りたい 2.5 pF より
  ずっと大きい**ので、1 回の測定では C<sub>stray</sub> だけを取り出せない。
  下の「差をとる」手順で入力容量を打ち消す
- Rref (330 Ω) は 10 MHz での 10 列のインピーダンス (C<sub>in</sub> + C<sub>stray</sub>
  ≈ 50 pF で約 320 Ω) に合わせた値

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 330
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow [h-10]
  - AD.GND -- -t3 black
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 black [h-10]
  - AD.2+ -- b10 purple [h-10]
  - AD.2- -- -t14 black
  - a11 -- -t11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/02-row-capacitance.svg)

- Rref の先 (10 列、a〜e) には部品を**わざと何もつながない** (計器の 1− と 2+ だけ)。
  10 列と、GND に落とした隣の 11 列 (同じ a〜e の側。`a11 -- -t11`) だけが、
  ブレッドボードの中で近接している
- 1− (a10) は Rref の先。CH1 は Rref の両端の電圧 (= 電流 × Rref) を測る
- 11 列から − レールへの黒線 (`a11 -- -t11`) は**抜き差しする線**。抜いた状態
  (11 列は浮き) と挿した状態 (11 列は GND) の 2 回測って差をとる
- 2+ (10 列) は Rref の先にしかつながっていない。ERC は「他につながっていない」
  と言うが、**これは承知のうえ** — 測りたいのはこの列が何にもつながっていない
  ときの、隣との寄生容量そのもの

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**10 MHz**、Amplitude 1 V |
| Scope | CH1 = Rref の両端、CH2 = 10 列 (浮いた側) の対 GND 電圧 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |
| 手順 | 11 列の黒線を**抜いて** 1 回、**挿して** 1 回測り、容量の差をとる |

低い周波数では X<sub>C</sub> が大きすぎて電流がほとんど流れず、挿す・抜くの差が
CH2 に現れない (ノイズに埋もれる)。
**10 MHz まで上げてやっと測れる**のがこの寄生の小ささを物語る。

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB、5-8) を超えるので、この題は
**BNC アダプタを付けて**測る (Scope 30+ MHz、Wavegen 12 MHz @ −3 dB)。CH1 を基準にした比を
読むので、2 つのチャンネルが同じ帯域を持つ限り、帯域の影響は小さい (目安)。

```scope
title: 図3 11 列の線を挿した 10 MHz — CH2 (10 列) が CH1 (Rref の両端) より 90° 遅れる
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 10MHz 0.723V, range: 200mV/div}
ch2: {wave: sine 10MHz 0.691V phase -90deg, range: 200mV/div}
cursors: [25ns, 50ns]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/02-row-capacitance.svg)

図3 は 11 列の線を挿したときの 10 MHz の画面 (計算値。BNC アダプタを付けて測る)。
CH1 は電流に比例し、容量にかかる CH2 の電圧は電流より 1/4 周期 (25 ns) 遅れる。
Vpp は CH1 1.45 V、CH2 1.38 V。11 列の線を抜くと CH2 の振幅は 0.709 V (Vpp 1.42 V) に増え、
その差 18 mV (0.036 V<sub>pp</sub>) が列間容量 2.5 pF の分。差は小さいので Average を増やして読む。

## 見るべき値

計算値。列間容量は 2.5 pF、AD の入力容量は 1 入力 24 pF × 2 = 48 pF と仮定
(列間容量は機種・列の間隔で、入力容量は個体と線の引き回しで変わるので実測で確かめる)。
10 列の容量は、CH1 の電流 I = V<sub>CH1</sub> / Rref と CH2 の電圧から
C = I / (2πf × V<sub>CH2</sub>) で求める (CH2 は CH1 より 90° 遅れる)。

| 測る所 | 11 列の線を抜く (C<sub>in</sub> だけ) | 11 列の線を挿す (C<sub>in</sub> + C<sub>stray</sub>) |
| --- | --- | --- |
| 10 列の容量 (仮定) | 48 pF | 50.5 pF |
| X<sub>C</sub> = 1/(2πfC) (10 MHz) | 332 Ω | 315 Ω |
| CH1 (Rref の両端) | 0.705 V (I ≈ 2.14 mA) | 0.723 V (I ≈ 2.19 mA) |
| CH2 (10 列の対 GND) | 0.709 V | 0.691 V |

- **C<sub>stray</sub> = (挿したときの C) − (抜いたときの C) ≈ 2.5 pF。** 1 回の測定で
  出る C は大半が計器の入力容量で、列間容量は差の中にしか現れない
- 差は CH2 で約 18 mV (2.6 %) と小さい。Average の回数を増やす (16〜64 回) と
  読みが安定する。抜き差しの間に AD の線を動かさない (線の容量が変わる)
- 1 MHz に落とすと、CH2 は抜いたとき 0.995 V・挿したとき 0.995 V とほぼ同じになり、
  差が読み取れない (X<sub>C</sub> が 10 倍になり、Rref との比が悪くなる)

同じ計算を周波数に対して並べると、2 本が分かれるのは数 MHz より上だけだと分かる。

```graph
title: 図4 CH2 の振幅は 1 MHz では挿しても抜いても同じ、10 MHz で 18 mV 分かれる
x: 周波数 Hz log 100k..30M
y: CH2 の振幅 V 0..1.1
lines:
  抜く (48 pF) V: 1/sqrt(1+(2*pi*x*330*48p)^2)
  挿す (50.5 pF) V: 1/sqrt(1+(2*pi*x*330*50.5p)^2)
notes:
  - mark 1M
  - mark 10M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/02-row-capacitance.svg)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
