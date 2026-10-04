---
book: circuits
chapter: 1
id: 1-8
title: コンデンサの直列・並列と時定数の比較
tier: 100
source: 自作
---

# 1-8 コンデンサの直列・並列と時定数の比較

抵抗は直列で足し算、並列で逆数の足し算 (1-2) だったが、コンデンサは
**逆**になる — 並列は容量が足し算、直列は逆数の足し算で**小さくなる**。
同じ 2 個のコンデンサを並列・直列にまとめ、同じ抵抗で充電して、
1-3 の時定数 τ = RC がどう変わるかを比べる。

## 回路図

並列 (C1 = C2 = 100µF を並列にすると 200µF)。

```circuit
title: 図1 並列にしたコンデンサを充電する
parts:
  V1: vsource b2 d2 5
  G0: ground d2
  S1: switch b3 b5
  R1: resistor b5 b7 1k
  C1: ecap b7 d7 100u
  C2: ecap b10 d10 100u
  G1: ground d7
wires:
  - b2 -- b3
  - b7 -- b10
  - d7 -- d10
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/08-cap-series-parallel-1.svg)

直列 (C1 = C2 = 100µF を直列にすると 50µF)。

```circuit
title: 図2 直列にしたコンデンサを充電する
parts:
  V1: vsource b2 d2 5
  G0: ground d2
  S1: switch b3 b5
  R2: resistor b5 b7 1k
  C3: ecap b7 d7 100u
  C4: ecap d7 f7 100u
  G2: ground f7
wires:
  - b2 -- b3
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/08-cap-series-parallel-2.svg)

`R1` = `R2` = 1kΩ (同じ抵抗を使う)。

- 並列: C<sub>par</sub> = C1 + C2 = **200 µF**、τ<sub>par</sub> = R × C<sub>par</sub>
  = 1kΩ × 200µF = **0.20 秒**
- 直列: C<sub>ser</sub> = (C1×C2)/(C1+C2) = **50 µF**、τ<sub>ser</sub> = 1kΩ × 50µF
  = **0.05 秒** (並列の 1/4)

1-3 と同じ式 (1τ で 63%、3τ で 95%、5τ でほぼ満充電) を、この 2 つの
時定数にあてはめる。**直列のほうが容量が小さい分、同じ抵抗では 4 倍速く
充電が進む** — 直列・並列で「大きい容量ほど時間がかかる」という 1-3 の
教訓がそのまま確かめられる。

## 実体配線図

図1 (並列) をブレッドボードに組むと図3 になる。

```breadboard
title: 図3 並列にした C1・C2 を、押しボタンを押している間だけ充電する
board: half
parts:
  SW1: button @ e5
  R1: resistor g7 g12 1k
  C1: capacitor/electrolytic h12(+) h15(-) 100uF
  C2: capacitor/electrolytic h18(+) h21(-) 100uF
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - -t28 -- -b28 black
  - j15 -- -b15 black
  - f12 -- f18 orange
  - j21 -- -b21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/08-cap-series-parallel-1.svg)

押しボタン `SW1` は溝をまたいで `e5` に挿す。上側の足 (列 5 の上半分) に + レールから
赤線を下ろし、押すと下側の足 (列 7 の下半分) に 5V が出る。`R1` はその列 7 の `g7` から
列 12 の `g12` へ。`C1` は + を `h12`、− (帯のある側) を `h15` に挿し、`C2` は + を `h18`、
− を `h21` に挿す。列 12 と列 18 を橙の線 (`f12`〜`f18`) で結ぶと 2 個の + がつながり、
並列になる。両方の − は黒線で下の − レールへ落とし、28 列の黒線で上下の − レールを
つなぐ。

図2 (直列) は、同じ板の `C2` と橙の線を外して図4 のように挿し替える。

```breadboard
title: 図4 直列にした C3・C4 を充電する
board: half
parts:
  SW1: button @ e5
  R2: resistor g7 g12 1k
  C3: capacitor/electrolytic h12(+) h15(-) 100uF
  C4: capacitor/electrolytic g15(+) g18(-) 100uF
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - -t28 -- -b28 black
  - j18 -- -b18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/08-cap-series-parallel-2.svg)

`C3` の − (`h15`) と `C4` の + (`g15`) は同じ列 15 の下半分でつながる。これが 2 個の
コンデンサの間の点。`C4` の − (`g18`) から列 18 の黒線で − レールへ落とす。
充電し直す前には、`C` の + と − を 1 kΩ の抵抗で数秒つないで放電しておく。

### Analog Discovery で充電曲線を見る

τ = 0.05 秒は目では追えないので、充電の曲線は Analog Discovery (AD) で見る。
押しボタンと電源を外し、AD の W1 から 0 V ↔ 5 V の方形波を入れて、充電と放電を
くり返させる (W1 が 0 V の間は、同じ `R` を通して放電する)。図5 は並列の場合。

```breadboard
title: 図5 並列の C1・C2 に Analog Discovery をつなぐ
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor/electrolytic d10(+) d13(-) 100uF
  C2: capacitor/electrolytic b10(+) b16(-) 100uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, W1, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a5 orange
  - AD.1- -- -t7 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
  - a13 -- -t13 black
  - a16 -- -t16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/08-cap-series-parallel-3.svg)

`R1` は列 5 と列 10 の上半分。W1 (黄) と CH1 の 1+ (橙) を入力の列 5 に、CH2 の 2+ (青) を
コンデンサの + がある列 10 に挿す。`C1` は + を `d10`、− を `d13`、`C2` は + を `b10`、
− を `b16` に挿し、2 個の − は黒線で上の − レールへ。AD の GND、1−・2− も上の − レールへ
落とす。直列を見るときは、`C2` を外して `C1` の − (列 13) と `C2` の + を同じ列に、
`C2` の − を黒線で − レールへ、と図4 と同じ形に挿し替える。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、**0.5 Hz** (半周期 1 秒 = 並列の 5τ)、Amplitude 2.5 V、Offset 2.5 V (0 V ↔ 5 V) |
| Scope | CH1・CH2 とも 1 V/div、時間 200 ms/div、Trigger: CH1 立ち上がり 2.5 V |

```scope
title: 図6 並列 (200 µF、τ = 0.20 秒) — 1τ で 63 %
time: 200ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 0.5Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 200ms, range: 1V/div, position: -3div}
cursors: [0, 200ms]
measure: [vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/08-cap-series-parallel-1.svg)

```scope
title: 図7 直列 (50 µF、τ = 0.05 秒) — 同じ尺度で 4 倍速く立ち上がる
time: 200ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 0.5Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | rc 50ms, range: 1V/div, position: -3div}
cursors: [0, 50ms]
measure: [vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/08-cap-series-parallel-2.svg)

図6 と図7 は同じ 200 ms/div で並べてある。カーソル X2 の所で CH2 はどちらも約 3.16 V
(5V × 0.63) — そこまでにかかる時間が 0.20 秒と 0.05 秒で、4 倍違う。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2 | 抵抗 (1/4 W) | 1 kΩ |
| C1, C2, C3, C4 | 電解コンデンサ | 100 µF (16V 以上) |
| S1 | スイッチ (押している間だけ充電) | — |
| — | 電源 | 5V (USB) |

## 見るべき値

| 経過時間 | 並列 (τ = 0.20秒) の充電率 | 直列 (τ = 0.05秒) の充電率 |
| --- | --- | --- |
| 0.05 秒 | 約 22% (計算値) | 約 63% (1τ) |
| 0.20 秒 (1τ<sub>par</sub>) | 約 63% | 約 98% (4τ) |
| 0.60 秒 (3τ<sub>par</sub>) | 約 95% | ほぼ 100% |
| 1.00 秒 (5τ<sub>par</sub>) | 約 99% (ほぼ満充電) | ほぼ 100% |
| CH2 が 3.16 V (63%) になる時間 (図6・図7 のカーソル) | 約 0.20 秒 | 約 0.05 秒 |
| CH2 の Rise (10〜90 %、図6・図7) | 約 0.44 秒 (2.2τ、計算値) | 約 0.11 秒 (2.2τ、計算値) |

同じ 1 秒待つと、直列 (50µF) はとうに満充電で、並列 (200µF) はようやく
99% に届く — **同じ部品でも、直列・並列で「充電にかかる時間」が大きく違う**
ことが分かる。

## 出典

自作。
