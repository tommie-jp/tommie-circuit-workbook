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
title: 図1 差動対で電流を振り分ける
parts:
  V1: vsource a1 j1 9
  G1: ground j1
  R1: resistor a3 c3 10k
  R2: resistor c3 e3 10k
  G2: ground e3
  VR1: potentiometer a7 c7 10k
  G3: ground c7
  RC1: resistor a13 c13 220
  D1: led c13 e13
  Q1: npn g13
  RC2: resistor a17 c17 220
  D2: led c17 e17
  Q2: npn g17
  RE: resistor i13 k13 1k
  G4: ground k13
wires:
  - a1 -- a17
  - c3 -| Q1.B
  - VR1.w -| Q2.B
  - e13 -| Q1.C
  - e17 -| Q2.C
  - Q1.E -| i13
  - Q2.E -| i17
  - i13 -- i17
style:
  grid: on
```

`Q1` のベースは `R1`・`R2` (どちらも 10kΩ) の分圧で固定 (基準)。`Q2` のベースは
`VR1` (ポテンショメータ) のつまみで 0〜9V に動かせる。`RE` (テール抵抗) が
2 つのエミッタ電流の合計をほぼ一定に保つ。

- 基準電圧: 9V × 10k/20k = **4.5 V**
- **両方が同じ電圧 (4.5V) のとき**: エミッタ電流はほぼ半分ずつに分かれる。
  Ve ≈ 4.5 − 0.7 = 3.8V、I<sub>tail</sub> = 3.8V / 1kΩ ≈ 3.8mA、
  各コレクタ電流 ≈ **1.9 mA** ずつ (LED はどちらも同じ明るさで薄暗い)
- **VR1 を基準よりわずかに (0.1V ほど) 高くする**: バイポーラの差動対は
  入力差が ±4V<sub>T</sub> (常温で約 ±100mV) を超えると、電流はほぼ片側に
  寄ってしまう。Q2 側の LED がほぼフル (約 3.8mA 相当) に明るくなり、
  Q1 側はほぼ消える — **わずかな電位差を大きく増幅する**のがこの回路の仕事

## 実体配線図

```breadboard
title: 図2 差動対で電流を振り分ける
# 上のレール = +9V、下のレール = GND
board: full
parts:
  R1: resistor a3 a8 10k
  R2: resistor b8 b13 10k
  VR1: potentiometer a17(1) a18(w) a19(3) 10k
  RC1: resistor a25 a28 220
  D1: led b28(A) b29(K) red
  Q1: transistor f25(B) f26(C) f27(E) 2SC1815
  RC2: resistor a35 a38 220
  D2: led b38(A) b39(K) red
  Q2: transistor f35(B) f36(C) f37(E) 2SC1815
  RE: resistor a31 a34 1k
wires:
  - +t3 -- c3 red
  - +t17 -- b17 red
  - +t25 -- c25 red
  - +t35 -- c35 red
  - c13 -- -t13 black
  - c19 -- -t19 black
  - c8 -- g25 orange
  - b18 -- g35 blue
  - c29 -- g26 yellow
  - c39 -- g36 yellow
  - g27 -- d31 green
  - g37 -- d31 green
  - d34 -- -t34 black
```

`R1`・`R2` の分圧 (列 8) が `Q1` のベース (基準)。`VR1` のつまみ (列 18) が
`Q2` のベース。`Q1`・`Q2` のエミッタはどちらも `RE` の上端 (列 31) に集まる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2 | 抵抗 (1/4 W) | 10 kΩ |
| RC1, RC2 | 抵抗 (1/4 W) | 220 Ω |
| RE | 抵抗 (1/4 W) | 1 kΩ |
| VR1 | ポテンショメータ | 10 kΩ |
| D1, D2 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1, Q2 | NPN トランジスタ (特性のそろった 2 個が望ましい) | 2SC1815 |
| — | 電源 | 9V |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| VR1 のつまみを基準と同じ電圧に合わせたときの D1・D2 | どちらも同じ明るさ (約 1.9mA ずつ、計算値) | 電流が半分ずつに分かれている |
| VR1 を少しだけ (0.1V ほど) 上げたとき | D2 がほぼフルに点き、D1 がほぼ消える | 差動対は小さな電位差で電流がほぼ全部片側に寄る |
| VR1 を逆に少し下げたとき | D1 がほぼフルに点き、D2 がほぼ消える | 入力差の**符号**で振り分け先が変わる |
| テールの電流 (RE の両端 ÷ 1kΩ) | 常に約 3.8 mA (どちらに振っても一定) | 2 つのコレクタ電流の合計は変わらず、配分だけが変わる |

## 出典

自作。
