---
book: circuits
chapter: 2
id: 2-6
title: 差動増幅
tier: 50
source: 自作
board: BB
---

# 2-6 差動増幅

トランジスタ 2 つのエミッタを 1 本の抵抗 (テール抵抗) でまとめると、
**2 つの入力の差**に反応する回路になる。片方を基準電圧、もう片方を
可変にして、電流がどちらのコレクタに流れるかをLED で見る。

## 回路図

```circuit
title: 図1 差動対で電流を振り分ける (2 つのコレクタを CH1・CH2 で見る)
parts:
  VCC: vcc a4 5V
  R1: resistor a4 d4 10k
  R2: resistor f4 h4 10k
  G2: ground h4
  VR1: potentiometer a14 e14 10k
  G3: ground e14
  RC1: resistor a7 c7 220
  D1: led c7 e7
  Q1: npn f7
  RC2: resistor a11 c11 220
  D2: led c11 e11
  Q2: npn f11 mirror
  RE: resistor h9 j9 220
  G4: ground j9
  M1: voltmeter e8 g8 l=$\mathrm{CH1}$
  G5: ground g8
  M2: voltmeter e10 g10 l=$\mathrm{CH2}$
  G6: ground g10
wires:
  - e7 -- e8
  - e11 -- e10
  - a4 -- a7 -- a11 -- a14
  - d4 -- f4 -- Q1.B
  - VR1.w |- Q2.B
  - e7 -- Q1.C
  - e11 -- Q2.C
  - Q1.E -- h7
  - Q2.E -- h11
  - h7 -- h9 -- h11
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/06-differential-amp.svg)

`VCC` (+5V) は Analog Discovery (AD) の電源出力 V+ (WaveForms の Supplies で 5 V にして入れる)。
CH1 は `Q1` のコレクタ、CH2 は `Q2` のコレクタの電圧を GND 基準で見る。

`Q1` のベースは `R1`・`R2` (どちらも 10kΩ) の分圧で固定 (基準)。`Q2` のベースは
`VR1` (ポテンショメータ) のつまみで 0〜5V に動かせる。`RE` (テール抵抗) が
2 つのエミッタ電流の合計をほぼ一定に保つ。

- 基準電圧: 5V × 10k/20k = **2.5 V**
- **両方が同じ電圧 (2.5V) のとき**: エミッタ電流はほぼ半分ずつに分かれる。
  Ve ≈ 2.5 − 0.7 = 1.8V、I<sub>tail</sub> = 1.8V / 220Ω ≈ 8.2mA、
  各コレクタ電流 ≈ **4.1 mA** ずつ (LED はどちらも同じ明るさ。`RE` を
  1kΩ にすると 5 V では Itail が 1.8mA しか流れず LED が暗すぎるので、
  220Ω にしてある)
- **VR1 を基準よりわずかに (0.1V ほど) 高くする**: バイポーラの差動対は
  入力差が ±4V<sub>T</sub> (常温で約 ±100mV) を超えると、電流はほぼ片側に
  寄ってしまう。Q2 側の LED がほぼフル (約 8.2mA 相当) に明るくなり、
  Q1 側はほぼ消える — **わずかな電位差を大きく増幅する**のがこの回路の仕事

## 実体配線図

```breadboard
title: 図2 差動対で電流を振り分ける (電源は AD の V+、CH1・CH2 を 2 つのコレクタへ)
# 上の + レール = +5V (AD の V+)、上の − レール = GND
board: full
parts:
  R1: resistor b3 b8 10k
  R2: resistor c8 c13 10k
  VR1: potentiometer b17(1) b18(w) b19(3) 10k
  RC1: resistor b25 b28 220
  D1: led c28(A) c29(K) red
  Q1: transistor f25(B) f26(C) f27(E) 2SC1815
  RC2: resistor b35 b38 220
  D2: led c38(A) c39(K) red
  Q2: transistor f35(B) f36(C) f37(E) 2SC1815
  RE: resistor b31 b34 220
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+, 2-, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1- -- -t28 black
  - AD.1+ -- a29 orange
  - AD.2- -- -t38 black
  - AD.2+ -- a39 blue
  - +t3 -- a3 red
  - +t17 -- a17 red
  - +t25 -- a25 red
  - +t35 -- a35 red
  - a13 -- -t13 black
  - a19 -- -t19 black
  - d8 -- g25 orange
  - c18 -- g35 blue
  - d29 -- g26 yellow
  - d39 -- g36 yellow
  - g27 -- c31 green
  - g37 -- d31 green
  - a34 -- -t34 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/06-differential-amp.svg)

`R1`・`R2` の分圧 (列 8) が `Q1` のベース (基準)。`VR1` のつまみ (列 18) が
`Q2` のベース。`Q1`・`Q2` のエミッタはどちらも `RE` の上端 (列 31) に集まる。

- 電源: AD の V+ (赤) を `+t1`、GND (黒) を `-t2` へ。上の + レールが +5V、− レールが GND
  (下のレールは使わない)。LED 2 つで 10 mA 弱なので V+ で足りる
- CH1: 1+ (橙) を `a29` (D1 のカソード = `Q1` のコレクタの列)、1− (黒) を `-t28` へ
- CH2: 2+ (青) を `a39` (D2 のカソード = `Q2` のコレクタの列)、2− (黒) を `-t38` へ

## オシロで見る

WaveForms の Scope で CH1・CH2 を 1 V/div・DC 結合にし、`VR1` を回しながら 2 本の直流の高さを見る
(電圧は時間で動かないので、水平の 2 本の線の上下で読む)。

```scope
title: 図3 VR1 を基準 (2.5 V) に合わせたとき — 2 つのコレクタは同じ高さ
time: 1ms/div
trigger: ch1 rising 0V
ch1: {wave: dc 2.1V, range: 1V/div, position: -3div}
ch2: {wave: dc 2.1V, range: 1V/div, position: -3div}
measure: [avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/06-differential-amp-1.svg)

```scope
title: 図4 VR1 を 0.1 V 上げたとき — CH1 は上がり、CH2 は下がる
time: 1ms/div
trigger: ch1 rising 0V
ch1: {wave: dc 3.3V, range: 1V/div, position: -3div}
ch2: {wave: dc 2.0V, range: 1V/div, position: -3div}
measure: [avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/06-differential-amp-2.svg)

- 釣り合い (図3): コレクタ電圧 = 5 − 220Ω × 4.1mA − 2.0 (LED) ≈ **2.1 V** で、2 本が重なる
- VR1 を上げる (図4): 電流を失った `Q1` 側は `RC1` と D1 の降下が消えて **約 3.3 V** へ上がり、
  電流を集めた `Q2` 側は **約 2.0 V** へ下がる。2 本は**逆向き**に動く。
  `Q2` のコレクタはエミッタ (約 1.9 V) より下へは行けない (飽和) ので、ここで止まる —
  このため D2 の電流は計算の 8.2 mA までは増えず、4〜5 mA ほどで頭打ちになる
- `VR1` を逆に下げると、CH1 と CH2 の役が入れ替わる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2 | 抵抗 (1/4 W) | 10 kΩ |
| RC1, RC2 | 抵抗 (1/4 W) | 220 Ω |
| RE | 抵抗 (1/4 W) | 220 Ω |
| VR1 | ポテンショメータ | 10 kΩ |
| D1, D2 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1, Q2 | NPN トランジスタ (特性のそろった 2 個が望ましい) | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| VR1 のつまみを基準と同じ電圧に合わせたときの D1・D2 | どちらも同じ明るさ (約 4.1mA ずつ、計算値) | 電流が半分ずつに分かれている |
| VR1 を少しだけ (0.1V ほど) 上げたとき | D2 がほぼフルに点き、D1 がほぼ消える | 差動対は小さな電位差で電流がほぼ全部片側に寄る |
| VR1 を逆に少し下げたとき | D1 がほぼフルに点き、D2 がほぼ消える | 入力差の**符号**で振り分け先が変わる |
| 釣り合いのときの 2 つのコレクタ (CH1・CH2) | どちらも約 2.1 V | 2 つの電流が等しい |
| VR1 を 0.1V 上げたときの CH1・CH2 | CH1 約 3.3 V、CH2 約 2.0 V | 2 つのコレクタは逆向きに動く (Q2 は飽和の手前で止まる) |
| テールの電流 (RE の両端 ÷ 220Ω) | 常に約 8.2 mA (どちらに振っても一定) | 2 つのコレクタ電流の合計は変わらず、配分だけが変わる |

## 出典

自作。
