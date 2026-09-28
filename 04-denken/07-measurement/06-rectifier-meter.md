---
book: denken
chapter: 7
id: 7-6
title: 整流形の計器 — 平均値を測って実効値を表示する (波形率 1.11)
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 7-6 整流形の計器 — 平均値を測って実効値を表示する (波形率 1.11)

整流形の計器は、交流を全波整流して可動コイル形の計器 (平均値に振れる) で読み、目盛を
**正弦波の波形率 1.11 倍**で刻んで実効値として表示する。正弦波なら正しいが、ほかの波形では
ずれる。0-2 でテスターの読みの違いとして見た現象を、中身の回路を組んで確かめる。
ダイオードの 0.6 V の落ちを消すために OP アンプの**精密全波整流**で v の絶対値を作り、コンデンサで
平均をとる。この平均が可動コイルの振れに当たる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| 波形率 = 実効値 / 平均値 | 正弦波は π / (2√2) = 1.11、方形波は 1.00、三角波は 2/√3 = 1.155 |
| 表示 = 1.11 × 平均値 (v の絶対値の平均) | 整流形の計器の目盛 |
| 誤差 = 1.11 / 波形率 − 1 | 正弦波で 0 %、方形波で +11 %、三角波で −3.8 % |
| V_out = −(v + 2X)、X = −v (v > 0)・0 (v < 0) | 精密全波整流の出力。どちらの半周期でも v の絶対値になる |

## 回路図

```circuit
title: 図1 整流形の計器の模型 (精密全波整流と平均)
parts:
  V1: sine c1 h1 2 l=$\mathrm{W1}$
  R1: resistor f2 f4 10k
  U1: opamp g6 +down
  R2: resistor e4 e8 10k
  D1: diode e8 g8 1N4148
  D2: diode i8 i4 1N4148
  R4: resistor e8 e10 10k
  R3: resistor c2 c10 20k
  U2: opamp e12 +down
  R5: resistor b10 b13 20k
  C1: capacitor a10 a13 1u
  OUT: port e15
  G1: ground h1
  G2: ground h5
  G3: ground h11
wires:
  - c1 -- c2 -- f2
  - e4 -- f4 -- g4 -- i4
  - g4 |- U1.-
  - U1.+ -| h5
  - U1.out -- g8 -- i8
  - c10 -- e10
  - e10 |- U2.-
  - U2.+ -| h11
  - a10 -- b10 -- c10
  - U2.out -| a13
  - b13 -- a13
  - U2.out -- e15
notes:
  - text b1 blue: 入力 (CH1)
  - text d8 blue: X
  - text d14 blue: 出力 (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/06-rectifier-meter.svg)

- U1・U2 は TL072 の 2 回路。電源は AD の Supplies の ±5 V
- **1 段目 (U1、R1・R2・D1・D2)** は精密半波整流。v > 0 のとき X = −v、v < 0 のとき X = 0。
  ダイオードは OP アンプの帰還の中にあるので、0.6 V の落ちが出力に出ない
- **2 段目 (U2、R3・R4・R5)** は加算。入力 v を R3 (20 kΩ) で、X を R4 (10 kΩ、2 倍の重み) で足す。
  出力は −(v + 2X) = v の絶対値
- C1 (1 µF) を R5 に並べて時定数 R5 C1 = 20 ms の低域フィルタにし、v の絶対値の平均 (直流) を出す。
  これが可動コイルの計器の振れに当たる。表示の値は、この直流を 1.11 倍して求める

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip8 @ f14 r180 TL072
  R1: resistor c6 c10 10k
  D2: diode/do35 a17(A) a16(K)
  R2: resistor d16 d21 10k
  D1: diode/do35 b21(A) b17(K)
  R4: resistor g21 g15 10k
  R3: resistor i6 i15 20k
  R5: resistor h15 h16 20k
  C1: capacitor/film j15 j16 1u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, GND, 1-, V-, V+, 2-, 2+]
wires:
  - AD.GND -- -t12 black
  - AD.W1 -- a6 yellow
  - AD.1+ -- b6 yellow [h10]
  - AD.1- -- -t13 black
  - b10 -- b16 green
  - a15 -- -t15 black
  - AD.V- -- a14 purple
  - e21 -- f21 green
  - e6 -- f6 yellow
  - i16 -- i24 blue
  - AD.2+ -- j24 blue
  - AD.2- -- -t22 black
  - j14 -- -b14 black
  - j17 -- +b17 red
  - AD.V+ -- +t20 red
  - +t29 -- +b29 red
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/breadboard/06-rectifier-meter.svg)

- TL072 は `r180` で置き、上の段 (e14〜e17) が 4・3・2・1 番 (1 段目)、下の段 (f14〜f17) が 5・6・7・8 番 (2 段目)
- 1 段目: 3 番 (15 列) は黒い線で GND。R1 (6〜10 列) から緑の線で 2 番 (16 列) へ。D2 (16〜17 列、帯を 16 列)
  が 2 番と 1 番の間、D1 (17〜21 列、帯を 17 列) と R2 (16〜21 列) で X (21 列) を作る
- 2 段目: X を緑の線で下の段 21 列へ運び、R4 (15〜21 列) で 6 番 (15 列) へ。入力は 6 列から黄色の線で
  下の段へ渡し、R3 (6〜15 列) で 6 番へ。R5 と C1 は 6 番と 7 番 (16 列) の間に並べる
- 5 番 (14 列の下の段) は下の GND のレール、8 番 (17 列) は下の + のレール (V+)。4 番 (14 列の上の段) に V−
- CH1 (1+) は入力 (6 列)、CH2 (2+) は出力 (7 番から青い線で 24 列へ)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V |
| Wavegen | W1: 1 kHz、Amplitude 2 V、Offset 0 V。Sine → Square → Triangle と切り替える |
| Scope | CH1 = 入力 (1 V/div)、CH2 = 出力 (1 V/div)。Time base 200 µs/div |
| Measure | CH1 の RMS (真の実効値)、CH2 の Average (平均値)。表示の値 = 1.11 × CH2 の Average |

波形を切り替えたら 0.1 s (5 R5C1) 待ってから読む。

```scope
title: 図3 正弦波 — 出力 (CH2) は平均値 1.27 V、1.11 倍すると CH1 の RMS 1.41 V と合う
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2V, range: 1V/div, position: 0div}
ch2: {wave: ch1 | abs | rc 20ms, range: 1V/div, position: 0div}
measure: [vmax, rms, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/scope/06-rectifier-meter-1.svg)

```scope
title: 図4 方形波 — 平均値 2.00 V は RMS と同じ。1.11 倍の表示 2.22 V は 11 % 大きい
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1kHz 2V, range: 1V/div, position: 0div}
ch2: {wave: ch1 | abs | rc 20ms, range: 1V/div, position: 0div}
measure: [vmax, rms, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/scope/06-rectifier-meter-2.svg)

図の CH2 は v の絶対値を時定数 20 ms で均した理想の線 (リップルは 1 % 足らず)。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。1 kHz、**4 Vpp** (AD の Amplitude 2 V は山の高さ)、Offset 0 V、出力は High-Z。Sine・Square・Triangle |
| V+ / V− | 2 出力の安定化電源で ±5 V。電流制限は各 10 mA |
| 1+ | CH1 の先端を 6 列 (入力)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 24 列 (出力)、グランドクリップを GND のレール |

- FG が見る負荷は R1 ∥ R3 (約 6.7 kΩ) で、50 Ω による低下は 0.7 %。CH1 の RMS と CH2 の平均を
  同じ波で読むので、比 (波形率) には効かない
- CH2 の平均はテスターの直流レンジで読んでもよい。整流形の計器そのものになる

## 見るべき値

計算値。入力の山は 2 V。

| 波形 | 真の実効値 (CH1 の RMS) | 平均値 (CH2 の Average) | 表示 (1.11 × 平均値) | 誤差 |
| --- | --- | --- | --- | --- |
| 正弦波 | 1.41 V | 1.27 V | 1.41 V | 0 % |
| 方形波 | 2.00 V | 2.00 V | 2.22 V | +11 % |
| 三角波 | 1.15 V | 1.00 V | 1.11 V | −3.8 % |

分かること:

- **整流形の計器が正しいのは正弦波だけ。** 目盛の 1.11 は正弦波の波形率で、方形波は平らなので
  平均値と実効値が同じ (波形率 1)、三角波はとがっているので実効値のほうが大きい (波形率 1.155)
- 波形率が 1.11 より小さい波形は大きく、大きい波形は小さく表示される。ひずんだ電流
  (インバータ・整流器の電流) を測るときは、真の実効値形の計器を使う
- ダイオード 4 本のブリッジで作った計器は、0.6 V × 2 の落ちで小さい電圧の目盛が狂う。
  実物の整流形の計器が低い電圧のレンジで目盛を別に刻むのはこのため

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
