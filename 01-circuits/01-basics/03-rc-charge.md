---
book: circuits
chapter: 1
id: 1-3
title: コンデンサの充放電 — RC 時定数を LED で見る
tier: 50
source: 自作
board: BB
---

# 1-3 コンデンサの充放電 — RC 時定数を LED で見る

コンデンサは電圧をかけるとすぐには満タンにならず、抵抗を通して**じわじわ**
充電・放電する。その速さの目安が**時定数 τ = R × C** (秒)。切替スイッチで
充電と放電を切り替え、放電時に LED を光らせて時定数を目で見る。
LED を使わず、オシロスコープで充電の曲線そのものを見て時定数を読む測り方は
後半の「オシロスコープで時定数を見る」。

## 回路図

```circuit
title: 図1 充電と放電を切り替える
parts:
  V1: vsource a1 d1 5
  G1: ground d1
  S1: slide-switch b5 mirror
  R1: resistor a1 a4 1k
  C1: ecap b7 d7 1000u
  G2: ground d7
  R2: resistor c3 d3 1k
  D1: led d3 e3
  G3: ground e3
wires:
  - a4 |- S1.1
  - S1.in -- b7
  - S1.2 -| c3
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/03-rc-charge-1.svg)

スイッチを **1 (R1) 側**にすると、電池 → R1 → C1 の道だけがつながり、
C1 は R1 を通して充電される。**2 (R2) 側**にすると電池から切り離され、
C1 に貯まった電荷が R2 と LED を通して放電する。

- 時定数: τ = R × C = 1kΩ × 1000µF = **1.0 秒** (充電・放電とも同じ値になる)
- 充電: 1τ (1秒) で満充電の 63%、3τ (3秒) でほぼ 95%、5τ (5秒) でほぼ満タン
- 放電時の LED の電流 (放電の最初、C1 が 5V まで充電されている前提):
  I = (5V − V<sub>F</sub>) / R2 = (5 − 2) / 1k = **3 mA** (LED としては控えめな
  明るさだが、時定数を目で追うのが目的なのでこの程度でも十分見える)
- LED は C1 の電圧が V<sub>F</sub> (約 2V) を下回ると消える。5V から 2V まで
  下がるのに掛かる時間 ≈ τ × ln(5/2) ≈ 1.0 × 0.92 = **約 0.9 秒**
  (計算値。目に見える長さの「消えるまでの時間」になる)

## 実体配線図

```breadboard
title: 図2 スイッチで充電・放電を切り替える
# 5V は上の +/− レールへ。下の − レールは 28 列で上の − レールとつなぐ
board: half
parts:
  R1: resistor b10 b15 1k
  S1: slide-switch e15(1) e16(C) e17(2)
  C1: capacitor/electrolytic f16(+) i19(-) 1000uF
  R2: resistor a19 a24 1k
  D1: led b24(A) b25(K) red
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - +t10 -- a10 red
  - d16 -- g16 orange
  - h19 -- -b19 black
  - c17 -- b19 orange
  - a25 -- -t25 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/03-rc-charge-1.svg)

`R1` の下端 (`b15`) とスイッチの `1` 番 (`e15`) は同じ列 15 でつながる。
スイッチの `C` (共通) はコンデンサの + 側へ、`2` 番は放電側の `R2` へ配線した。
コンデンサは電解なので**帯のある側 (−) を GND 側**に挿す。C1 の − (下の − レール) と
LED のカソード (上の − レール) が同じ GND になるよう、28 列の黒線で上下の − レールを
つなぐ。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2 | 抵抗 (1/4 W) | 1 kΩ |
| C1 | 電解コンデンサ | 1000 µF (16V 以上) |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| S1 | スライドスイッチ | 1 回路 2 接点 |
| — | 電源 | 5V (USB) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 充電開始 1 秒後の C1 の電圧 | 約 3.15 V (5V × 0.63) | 1τ で 63% まで充電される (計算値) |
| 充電開始 5 秒後の C1 の電圧 | 約 4.97 V (ほぼ満充電) | 5τ でほぼ収束する |
| 放電に切り替えた瞬間の LED の電流 | 約 3 mA (計算値) | 抵抗を 470Ω に替えると電流は約 6.4mA に増えて明るくなるが、時定数 τ = 0.47 秒は逆に短くなる |
| LED が消えるまでの時間 | 約 0.9 秒 (計算値) | ストップウォッチや動画のコマ送りで実測して比べる |

## オシロスコープで時定数を見る (LED なし)

LED の点き方を目で追う代わりに、コンデンサの電圧が上がっていく曲線をオシロスコープで
見て、時定数を**時間の目盛りで読む**。LED は使わない。オシロの基本の使い方は 0-3。

τ = 1 秒のままだと 1 回の充電を見るのに何秒も待つので、R はそのまま、C を
**1000 µF → 1 µF** に替えて τ = 1kΩ × 1µF = **1 ms** にする。スイッチの代わりに
発振器の**方形波 (0 V と 5 V を 100 Hz で繰り返す)** を入れる。5 V の間 (5 ms = 5τ) に
充電し、0 V の間に放電する、を 1 秒に 100 回繰り返すので、止まった波形として見られる。

```circuit
title: 図3 方形波で RC を充放電し、2 ch で見る
parts:
  V1: square a1 d1 5
  M1: voltmeter a3 d3 l=$\mathrm{CH1}$
  R1: resistor a4 a6 1k
  C1: capacitor a7 d7 1u
  M2: voltmeter a9 d9 l=$\mathrm{CH2}$
  G1: ground d1
wires:
  - a1 -- a3 -- a4
  - a6 -- a7 -- a9
  - d1 -- d3 -- d7 -- d9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/03-rc-charge-2.svg)

CH1 で入力 (方形波)、CH2 で C1 の両端の電圧を見る。2 本のプローブの GND は
どちらも図の下の GND (発振器の GND と同じ点) に当てる。

```breadboard
title: 図4 R と C を 1 つずつ挿し、発振器とオシロをつなぐ
board: half
parts:
  R1: resistor a10 a15 1k
  C1: capacitor/film b15 b18 1u
  FG:
    type: device
    at: top
    label: 発振器 / AD (W1)
    pins: [OUT, GND]
  SCOPE:
    type: device
    at: bottom
    label: オシロ / AD (CH1・CH2)
    pins: [CH1, CH2, GND]
wires:
  - FG.OUT -- c10 yellow
  - FG.GND -- -t8 black
  - a18 -- -t18 black
  - SCOPE.CH1 -- e10 yellow
  - SCOPE.CH2 -- e15 green
  - SCOPE.GND -- -b20 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/03-rc-charge-2.svg)

`R1` の右端 (`a15`) と `C1` の左端 (`b15`) は同じ列 15 でつながる。発振器の出力は
`R1` の左端の列 10 へ、`C1` の右端の列 18 は上の − レール (GND) へ落とす。
CH1 は列 10、CH2 は列 15 に当てる。上下の − レールは 28 列の黒線でつなぎ、
発振器とオシロの GND を同じにする。

- C1 は**フィルムコンデンサ** (向きなし) を使う。積層セラミックの 1 µF は、
  直流の電圧がかかると容量が大きく減る品種 (高誘電率系) が多く、τ が短く出る
- 汎用の発振器は出力に 50 Ω を持つので、τ = (1kΩ + 50Ω) × 1µF ≈ **1.05 ms** になる
  (5 % 長い)。発振器の負荷の設定は **High-Z** にしておく (50 Ω にすると
  表示の 2 倍の電圧が出る)。AD の W1 は出力の抵抗がほぼ 0 Ω なので τ = 1.00 ms のまま
- 電源装置の 5V とスライドスイッチは使わない。発振器の方形波がスイッチの代わりになる

### 計器の設定

| 項目 | 値 |
| --- | --- |
| 発振器 (AD は W1) | 方形波、100 Hz、**0 V 〜 5 V** (振幅 2.5 V + オフセット 2.5 V。振幅を Vpp で入れる機種は 5 Vpp) |
| 結合 | CH1・CH2 とも DC |
| 電圧レンジ | CH1・CH2 とも 1 V/div、0 V の基準を下から 1 目盛りに揃える |
| 時間レンジ | 1 ms/div (1 目盛りが 1τ) |
| トリガ | CH1 の立ち上がり、レベル 2.5 V |

```scope
title: 図5 入力 (CH1) と C の電圧 (CH2)、カーソルで 1τ を読む
time: 1ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 1V/div, position: -3div}
cursors: [0, 1ms]
measure: [vpp, vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/03-rc-charge-1.svg)

### カーソルで τ を読む

1. 縦のカーソル X1 を CH1 の立ち上がり (トリガの点、t = 0) に置く
2. X2 を動かし、CH2 が **3.16 V (5 V の 63 %)** になる所で止める
3. X1 から X2 までの時間 ΔX が τ。計算では **1.00 ms** (50 Ω の発振器なら 1.05 ms)

逆に X2 を 1 ms に置いて CH2 の電圧を読んでもよい (約 3.16 V なら τ = 1 ms)。
Measurements に Rise (10 % → 90 % の時間) があれば、それは **2.2τ** になる
(τ × ln 9 ≈ 2.2 ms)。

### 放電と、周波数を上げたときの画面

トリガを CH1 の**立ち下がり**に替えると、放電の曲線が画面の真ん中から始まる。
X1 を立ち下がり、X2 を 1 ms に置くと、CH2 は 4.97 V から **1.83 V (37 %)** まで下がる。
充電と同じ τ で、1τ ごとに残りが 37 % になる。

```scope
title: 図6 放電 — 立ち下がりから 1τ で 37 % まで下がる
time: 1ms/div
trigger: ch1 falling 2.5V
ch1: {wave: square 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 1V/div, position: -3div}
cursors: [0, 1ms]
measure: [vpp, vmin, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/03-rc-charge-2.svg)

発振器の周波数を **1 kHz** に上げると、半周期は 0.5 ms (0.5τ) しかない。C1 は満充電に
届く前に放電に切り替わり、CH2 は 1.89 V と 3.11 V の間を行き来する、角の丸い三角波になる。
平均はどちらも 2.50 V のまま。時間レンジは 200 µs/div にする。

```scope
title: 図7 1 kHz に上げると (半周期 0.5τ) 満充電に届かない
time: 200us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 1kHz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 1ms, range: 1V/div, position: -3div}
measure: [vpp, vmax, vmin, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/03-rc-charge-3.svg)

### 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 立ち上がりから 1 ms 後の CH2 | 約 3.16 V (5V × 0.632、計算値) | 1τ で 63 % まで充電される |
| 立ち下がりから 1 ms 後の CH2 | 約 1.84 V (5V × 0.368、計算値) | 放電も同じ τ で、1τ で 37 % まで下がる |
| CH2 の Rise (10〜90 %) | 約 2.2 ms (計算値) | 2.2τ。τ を Measurements の数字 1 つで確かめられる |
| 半周期 (5 ms) の終わりの CH2 | 約 4.97 V (計算値) | 5τ でほぼ満充電 |
| 1 kHz に上げたときの CH2 (図7) | 約 1.89 V 〜 3.11 V (Vpp 約 1.22 V、計算値) | 半周期が τ より短いと満充電に届かず、三角波に近づく |
| C1 を 0.47 µF に替えたとき | CH2 が 3.16 V になるまで約 0.47 ms | τ は C に比例する |

図1 の回路 (1000 µF、τ = 1 秒) のまま見ることもできる。LED を外して R2 の下端を
直接 GND につなぎ、CH1 を C1 の + に当てて、時間レンジを 1 s/div の**ロール表示**
(波形が右から左へ流れる表示。AD の WaveForms では Mode を Shift) にする。
スイッチを切り替えるたびに、1 目盛りで 63 % まで上がる (37 % まで下がる) 曲線が描かれる。

下の図は、放電側に 5 秒置いてから充電側へ切り替えた所。ロール表示はトリガで止まらない
ので、充電の曲線が画面に入ったら **Stop** で止め、X1 を充電の出だし (曲線が 0 V から
上がり始める所)、X2 をそこから 1 秒後に置く。C1 の電圧 (CH1) は約 3.18 V (63 %)。
図では充電の出だしを真ん中に揃えるため、立ち上がり 50 mV でトリガを掛けた形で描いた。

```scope
title: 図8 図1 のまま (τ = 1 秒)、5 秒ごとにスイッチを切り替える
time: 1s/div
trigger: ch1 rising 50mV
ch1: {wave: square 0.1Hz 2.5V offset 2.5V | rc 1s, range: 1V/div, position: -3div}
cursors: [0, 1s]
measure: [vmax, vmin, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/03-rc-charge-4.svg)

## 出典

自作。
