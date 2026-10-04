---
book: nanovna
chapter: 4
id: 4-13
title: ダイオードの接合容量
tier: 100
source: 自作
board: PF
device: H4
---

# 4-13 ダイオードの接合容量

バリキャップ (4-9) でなくても、ダイオードは逆向きの電圧で**接合容量**を持つ。整流用の
ダイオードは電流を多く流すために接合が広く、そのぶん容量も大きい。この容量が、
高い周波数の整流や切り替えの速さを決める。4-9 と同じ治具で、整流用の **1N4007** と
ショットキーの **1N5819** を、データシートと同じ **逆電圧 4 V** で測り比べる。

## 回路図

4-9 の治具のバリキャップをダイオードに替え、バイアスの電源を 5 V にしたもの。

```circuit
title: 図1 ダイオードに逆向きの 4 V をかけて直列治具で測る
parts:
  J1: sma e2 mirror CH0
  C1: capacitor e3 e5 100n
  D1: diode e8 e6 1N4007
  C2: capacitor e9 e11 100n
  J2: sma e12 CH1
  R1: resistor c6 e6 100k
  R2: resistor c8 e8 100k
  VR1: potentiometer b8 b4 l=$\mathrm{VR}_1$
  V1: vsource a4 a8 5
  G1: ground f2
  G2: ground f12
wires:
  - J1.1 -- e3
  - e5 -- e6
  - e8 -- e9
  - e11 -- J2.1
  - J1.2 -- f2
  - J2.2 -- f12
  - c6 |- VR1.w
  - c8 -- b8
  - b4 -- a4
  - b8 -- a8
notes:
  - text b5d0 center: 10 kΩ
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/13-junction-capacitance.svg)

- D1 は**カソードが CH0 側 (左)**。R1 がカソードへ +、R2 がアノードへ − をつなぎ、
  逆向きの電圧をかける。VR1 で 4.0 V に合わせる (テスターで D1 の両ピンの間を測る)
- C1・C2 (100 nF) は NanoVNA のポートに直流を入れないためのもの (4-9 と同じ)
- 電源は USB の 5 V。PC の USB から取ると − が NanoVNA の GND とつながることがあるが、
  R2 の側が 0 V に決まるだけで、D1 にかかる電圧は変わらない

## 実体配線図

4-9 のユニバーサル基板の D1 を替え、電池を USB の 5 V にする。

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 直列治具にダイオードとバイアス
points:
  GND: j0
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  C1: capacitor/ceramic i2 i4 100n
  D1: diode/do41 i9 i6 1N4007
  C2: capacitor/ceramic i11 i13 100n
  R1: resistor f6 h6 100k
  R2: resistor f9 h9 100k
  VR1: potentiometer/trimmer e2 f3 e4 10k
  V1:
    type: device
    at: -c8
    label: USB 5V
    pins: + -
wires:
  - i1 -- i2
  - i4 -- i6
  - i9 -- i11
  - i13 -- i24
  - i6 -- h6
  - i9 -- h9
  - f3 -- f6
  - e4 -- e9
  - e9 -- f9
  - V1.+ -- a8 red
  - a8 -- a2 red
  - a2 -- e2 red
  - V1.- -- a9 blue
  - a9 -- e9 blue
  - j0 -- j25 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/13-junction-capacitance.svg)

- D1 は帯 (カソード) を i6 (左) に向ける。1N5819 に替えるときも帯を左に
- **D1 のピンは i6〜i9 の幅に曲げて、短く**。ピンの長さがインダクタンスになり、
  1N5819 のように容量の大きい物では 300 MHz より下に直列共振が出る (図5)

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| D1 | 1N4007 (整流用) と 1N5819 (ショットキー) を挿し替える | 接合容量の代表値 (4 V・1 MHz): 1N4007 は 15 pF、1N5819 は 110 pF (Vishay のデータシート) |
| C1・C2 | 100 nF | 直流を止める |
| R1・R2 | 100 kΩ | 直流をかけ、高周波は通さない |
| VR1 | 10 kΩ (半固定) | 4.0 V を作る |
| 電源 | 5 V (USB) | |

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz (1N5819 の容量だけは 1 MHz〜50 MHz でも。図4) |
| 点数 | 201 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag と位相 (直列共振は S11 の Log Mag と S21 の位相。図5) |
| 模型の仮定 | D1 のピンと治具の線を 7 nH (4-7 の 1 cm) とする |

**1N4007 (15 pF)** のときに見えるはずの画面。

```vna
device: h4
sweep: 1M-300M 201
title: 図3 1N4007 (15 pF) — 10 MHz で S21 は −20.6 dB
dut:
  - series C 100n
  - series C 15p esl 7n
  - series C 100n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 10M
  - 106M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/13-junction-capacitance-1.svg)

**1N5819 (110 pF)** のとき。容量が大きいぶん低い周波数から通り、1〜300 MHz の掃引では
S21 の立ち上がりが左端の 10 MHz までに潰れる。**容量を読む図と、ピンの共振を見る図に分ける**。
まず 1〜50 MHz で、10 MHz の S21 と X = 100 Ω の 14.5 MHz を読む。

```vna
device: h4
sweep: 1M-50M 201
title: 図4 1N5819 (110 pF) — 10 MHz で −4.9 dB (1〜50 MHz)
dut:
  - series C 100n
  - series C 110p esl 7n
  - series C 100n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 10M
  - 14.5M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/13-junction-capacitance-2.svg)

次に図3 と同じ 1〜300 MHz で、ピンの 7 nH との直列共振 (181 MHz) を見る。S21 の大きさは
このあたりでほぼ 0 dB のまま動かないので、**S11 (CH0 に返る反射) の谷と S21 の位相**で見る。
共振で D1 の Z が 0 に近づくと、CH0 から見えるのは CH1 の 50 Ω だけになり S11 が深く落ちる。
位相は 0° を横切り、その上では − (コイル) になる。

```vna
device: h4
sweep: 1M-300M 201
title: 図5 1N5819 の直列共振 — 181 MHz で S11 が谷、位相が 0°
dut:
  - series C 100n
  - series C 110p esl 7n
  - series C 100n
traces:
  - S11 logmag
  - S21 phase
markers:
  - 10M
  - 181M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/13-junction-capacitance-3.svg)

## 見るべき値

計算値。容量は 4-9 と同じ式 C = 1 / (2π f × 100 × √(1/|S21|² − 1)) で、
ピンの L が効かない低い周波数 (10 MHz) で読む。

| ダイオード | C (4 V、代表値) | 10 MHz の S21 | 10 MHz の位相 | 容量だけで X = 100 Ω | 直列共振 (7 nH と) |
| --- | --- | --- | --- | --- | --- |
| 1N4007 | 15 pF | −20.6 dB | +84.6° | 106 MHz (S21 は −2.8 dB、ピンの L のぶん −3 dB より上) | 491 MHz (掃引の外) |
| 1N5819 | 110 pF | −4.9 dB | +55.3° | 14.5 MHz (S21 は −3.0 dB。図4) | 181 MHz (S11 の谷 −65.9 dB、位相 0°。図5) |

分かること:

- **整流用のダイオードでも 15 pF、ショットキーの 1N5819 は 110 pF もある。**
  小信号用の 1N4148 はデータシートで 0 V でも 4 pF 以下。高い周波数の検波や
  切り替えには、接合の小さい小信号用を使う理由がこの差
- 1N5819 は 181 MHz より上で**コイルに見える** (図5 の位相が + から − へ)。容量の大きい
  部品ほど、ピンの長さの影響が低い周波数に下りてくる (4-2 のセラミックコンデンサと同じ)
- 電圧を 1 V・2 V…と変えて測ると、4-9 のバリキャップほどではないが容量が変わる。
  データシートの曲線 (Typical Junction Capacitance) と比べる

## 出典

自作。接合容量の代表値は Vishay のデータシート (1N4001〜1N4007: 4.0 V・1 MHz で 15 pF、
1N5817〜1N5819: 同じ条件で 1N5819 は 110 pF、1N4148: 0 V・1 MHz で 4 pF 以下) による。
