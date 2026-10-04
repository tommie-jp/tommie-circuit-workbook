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

トランジスタ 2 つのエミッタをつないで 1 本の抵抗 (テール抵抗。尾のように下へ伸びるのでこう呼ぶ)
で GND へ落とすと、**2 つのベースの電圧の差**に反応する回路になる。この 2 つ組を差動対と呼ぶ。
片方のベースを基準電圧、もう片方を可変にして、電流がどちらのコレクタに流れるかを LED と
オシロで見る。OP アンプ (第 4 章) の入り口は、この差動対でできている。

## 回路図

```circuit
title: 図1 差動対で電流を振り分ける (2 つのコレクタを CH1・CH2 で見る)
parts:
  VCC: vcc b4 5V
  R1: resistor b4 e4 10k
  R2: resistor g4 i4 10k
  G2: ground i4
  VR1: potentiometer b14 f14 10k
  G3: ground f14
  RC1: resistor b7 d7 220
  D1: led d7 f7
  Q1: npn g7
  RC2: resistor b11 d11 220
  D2: led d11 f11
  Q2: npn g11 mirror
  RE: resistor i9 k9 220
  G4: ground k9
  M1: voltmeter f8 h8 l=$\mathrm{CH1}$
  G5: ground h8
  M2: voltmeter f10 h10 l=$\mathrm{CH2}$
  G6: ground h10
wires:
  - f7 -- f8
  - f11 -- f10
  - b4 -- b7 -- b11 -- b14
  - e4 -- g4 -- Q1.B
  - VR1.w |- Q2.B
  - f7 -- Q1.C
  - f11 -- Q2.C
  - Q1.E -- i7
  - Q2.E -- i11
  - i7 -- i9 -- i11
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/06-differential-amp.svg)

図1 の `VCC` (+5V) は Analog Discovery (AD) の電源出力 V+ (WaveForms の Supplies で 5 V にして入れる)。
CH1 は `Q1` のコレクタ、CH2 は `Q2` のコレクタの電圧を GND 基準で見る。

`Q1` のベースは `R1`・`R2` (どちらも 10kΩ) の分圧で固定 (基準)。`Q2` のベースは
`VR1` (1-6 で使ったポテンショメータ) のつまみで 0〜5V に動かせる。`RE` (テール抵抗) が
2 つのエミッタ電流の合計をほぼ一定に保つ。

- 基準電圧: 5V × 10k/20k = **2.5 V**
- **両方が同じ電圧 (2.5V) のとき**: エミッタ電流はほぼ半分ずつに分かれる。
  Ve ≈ 2.5 − 0.7 = 1.8V、I<sub>tail</sub> = 1.8V / 220Ω ≈ 8.2mA、
  各コレクタ電流 ≈ **4.1 mA** ずつ (LED はどちらも同じ明るさ。`RE` を
  1kΩ にすると 5 V では Itail が 1.8mA しか流れず LED が暗すぎるので、
  220Ω にしてある)
- **VR1 を基準よりわずかに (0.1V ほど) 高くする**: バイポーラの差動対は
  入力差が ±4V<sub>T</sub> (V<sub>T</sub> は 2-2 で見た熱電圧 26 mV。常温で約 ±100mV) を超えると、電流はほぼ片側に
  寄ってしまう。Q2 側の LED が明るくなり (Q2 が飽和して約 4.5mA で頭打ち)、
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
  Q1: transistor h25(B) h26(C) h27(E) 2SC1815
  RC2: resistor b35 b38 220
  D2: led c38(A) c39(K) red
  Q2: transistor h35(B) h36(C) h37(E) 2SC1815
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

図2 では、`R1`・`R2` の分圧 (列 8) が `Q1` のベース (基準)。`VR1` のつまみ (列 18) が
`Q2` のベース。`Q1`・`Q2` のエミッタはどちらも `RE` の上端 (列 31) に集まる。

- 電源: AD の V+ (赤) を `+t1`、GND (黒) を `-t2` へ。上の + レールが +5V、− レールが GND
  (下のレールは使わない)。LED 2 つで 10 mA 弱なので V+ で足りる
- CH1: 1+ (橙) を `a29` (D1 のカソード = `Q1` のコレクタの列)、1− (黒) を `-t28` へ
- CH2: 2+ (青) を `a39` (D2 のカソード = `Q2` のコレクタの列)、2− (黒) を `-t38` へ

## オシロで見る

WaveForms の Scope で CH1・CH2 を 500 mV/div・DC 結合 (中央を 2.5 V) にし、`VR1` を基準 (2.5 V) に合わせてから
0.1 V ほど上げる。CH1 の立ち上がりでトリガを掛けると、上げた瞬間の前後が 1 画面に入る
(直流は時間で動かないので、動かした瞬間を捉えて前後の高さを比べる。図3)。

```scope
title: 図3 VR1 を 0.1 V 上げた瞬間 — CH1 は上がり、CH2 は下がる
time: 1ms/div
trigger: ch1 rising 2.7V
ch1: {wave: = 2.1V + 1.2V * step(t), range: 500mV/div, position: -5div}
ch2: {wave: = 2.1V - 0.1V * step(t), range: 500mV/div, position: -5div}
cursors: [-2ms, 2ms]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/06-differential-amp.svg)

- 釣り合い (カーソル X1、上げる前): コレクタ電圧 = 5 − 220Ω × 4.1mA − 2.0 (LED) ≈ **2.1 V** で、2 本が重なる
- VR1 を上げた後 (カーソル X2): 電流を失った `Q1` 側は `RC1` の電圧降下が消えて **約 3.3 V** へ上がり
  (D1 にはオシロの入力へ流れるわずかな電流しか流れず、2-1 と同じ理由で 5 V までは上がらない)、
  電流を集めた `Q2` 側は **約 2.0 V** へ下がる。2 本は**逆向き**に動く。
  `Q2` のコレクタはエミッタ (約 1.9 V) より下へは行けない (飽和) ので、ここで止まる —
  このため D2 の電流は計算の 8.2 mA までは増えず、4〜5 mA ほどで頭打ちになる
- 実際は手でつまみを回すので段はなだらかになり、指の震えで少し揺れる。`VR1` を逆に下げると、
  CH1 と CH2 の役が入れ替わる

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
| VR1 を少しだけ (0.1V ほど) 上げたとき | D2 が明るく点き (約 4.5 mA で頭打ち)、D1 がほぼ消える | 差動対は小さな電位差で電流がほぼ全部片側に寄る |
| VR1 を逆に少し下げたとき | D1 が明るく点き (約 4.5 mA で頭打ち)、D2 がほぼ消える | 入力差の**符号**で振り分け先が変わる |
| 釣り合いのときの 2 つのコレクタ (CH1・CH2) | どちらも約 2.1 V | 2 つの電流が等しい |
| VR1 を 0.1V 上げたときの CH1・CH2 | CH1 約 3.3 V、CH2 約 2.0 V | 2 つのコレクタは逆向きに動く (Q2 は飽和の手前で止まる) |
| テールの電流 (RE の両端 ÷ 220Ω) | 釣り合いの近くで約 8.2 mA | 合計はほぼ一定で配分だけが変わる。大きく振って片側が飽和すると、そのベース電流が増えて一定ではなくなる |

## 出典

自作。
