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
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor c3 c6 330
  Cstray: capacitor c9 c12 2.5p l=$\mathrm{C_{stray}}$
  G1: ground c14
  Cin: capacitor c9 e9 48p l=$\mathrm{C_{in}}$
  G2: ground e9
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c6
  - c6 -- c9
  - AD.2+ -| c9
  - AD.2- -| c12
  - c12 -- c14
  - AD.GND -| c14
```

- C<sub>stray</sub> は**部品ではない**。実装した部品ではなく、板の 2 つの列が
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
  - AD.W1 -- a5 yellow
  - AD.GND -- -t3 black
  - AD.1+ -- b5 orange [h5]
  - AD.1- -- d10 black [h5]
  - AD.2+ -- b10 purple [h5]
  - AD.2- -- -t13 black
  - a11 -- -t11 black
```

- Rref の先 (10 列、a〜e) には部品を**わざと何もつながない** (計器の 1− と 2+ だけ)。
  10 列と、GND に落とした隣の 11 列 (同じ a〜e の側。`a11 -- -t11`) だけが、
  板の中で近接している
- 1− (d10) は Rref の先。CH1 は Rref の両端の電圧 (= 電流 × Rref) を測る
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

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
