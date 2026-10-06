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
  寄ってしまう。**下げる向きは完全に切り替わる**: Q1 側の LED が約 6 mA で明るくなり、Q2 側はほぼ消える。
  **上げる向きは完全には切り替わらない**: Q2 が飽和して約 5 mA で頭打ちになり、Q1 側にも 2.5〜3 mA が残る
  (下の「オシロで見る」。LTspice で確かめた) — **わずかな電位差で電流の配分が大きく動く**のがこの回路の仕事

## 実体配線図

```breadboard
title: 図2 差動対で電流を振り分ける (電源は AD の V+、CH1・CH2 を 2 つのコレクタへ)
# 上の + レール = +5V (AD の V+)、上の − レール = GND。Q2 は左右を逆にして挿し、線が交差しないようにした
board: full
parts:
  R1: resistor b2 b6 10k
  R2: resistor c6 c10 10k
  RC1: resistor b13 b16 220
  D1: led c16(A) c17(K) red
  RE: resistor b20 b23 220
  RC2: resistor b25 b28 220
  D2: led c28(A) c29(K) red
  VR1: potentiometer b32(1) b33(w) b34(3) 10k
  Q1: transistor g25(B) g26(C) g27(E) 2SC1815
  Q2: transistor g31(B) g30(C) g29(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+, 2-, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1- -- -t15 black
  - AD.1+ -- a17 orange
  - AD.2- -- -t27 black
  - AD.2+ -- a29 blue
  - +t2 -- a2 red
  - +t13 -- a13 red
  - +t25 -- a25 red
  - +t32 -- a32 red
  - a10 -- -t10 black
  - a23 -- -t23 black
  - a34 -- -t34 black
  - d6 -- g25 orange
  - d17 -- g26 yellow
  - d20 -- g27 green
  - c20 -- g29 green
  - d29 -- g30 yellow
  - c33 -- g31 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/06-differential-amp.svg)

図2 では、`R1`・`R2` の分圧 (列 6) が `Q1` のベース (基準)、`VR1` のつまみ (列 33) が `Q2` のベース。
`Q1`・`Q2` は溝の下のブロックに挿し、上のブロックの部品と 6 本の線 (橙・黄・緑・緑・黄・青) でつなぐ。
**`Q2` は左右を逆にして (左から E・C・B の順に) 挿す**。上の部品の並びと、下のピンの並びが同じ順になり、6 本が交差しない。

- 電源: AD の V+ (赤) を `+t1`、GND (黒) を `-t2` へ。上の + レールが +5V、− レールが GND
  (下のレールは使わない)。LED 2 つで 10 mA 弱なので V+ で足りる
- 基準: `d6` (R1・R2 の中点) → `g25` (`Q1` のベース、橙)。つまみ: `c33` → `g31` (`Q2` のベース、青)
- コレクタ: `d17` (D1 のカソード) → `g26` (`Q1` の C)、`d29` (D2 のカソード) → `g30` (`Q2` の C) (黄)
- エミッタ: `RE` の上端 (列 20) から `g27` (`Q1` の E) と `g29` (`Q2` の E) へ (緑 2 本)。`RE` の下端は `a23` から − レールへ
- CH1: 1+ (橙) を `a17` (D1 のカソード = `Q1` のコレクタの列)、1− (黒) を `-t15` へ
- CH2: 2+ (青) を `a29` (D2 のカソード = `Q2` のコレクタの列)、2− (黒) を `-t27` へ

## オシロで見る

WaveForms の Scope で CH1・CH2 を 500 mV/div・DC 結合 (中央を 2.5 V) にし、`VR1` を基準 (2.5 V) に合わせてから
0.1 V ほど上げる。CH1 の立ち上がりでトリガを掛けると、上げた瞬間の前後が 1 画面に入る
(直流は時間で動かないので、動かした瞬間を捉えて前後の高さを比べる。図3)。

```scope
title: 図3 VR1 を 0.1 V 上げた瞬間 — CH1 は少し上がり、CH2 は少し下がる
time: 1ms/div
trigger: ch1 rising 2.25V
ch1: {wave: = 2.1V + 0.3V * step(t), range: 500mV/div, position: -5div}
ch2: {wave: = 2.1V - 0.3V * step(t), range: 500mV/div, position: -5div}
cursors: [-2ms, 2ms]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/06-differential-amp.svg)

- 釣り合い (カーソル X1、上げる前): コレクタ電圧 = 5 − 220Ω × 4.1mA − 2.0 (LED) ≈ **2.1 V** で、2 本が重なる
- VR1 を上げた後 (カーソル X2): 電流を集める `Q2` 側は **約 1.8 V** へ下がる。`Q2` のコレクタはエミッタ (約 1.7 V) より下へは
  行けない (飽和) ので、ここで止まり、D2 の電流は約 5 mA で頭打ちになる。飽和した `Q2` はベースとコレクタの間が順方向になり、
  ベースの電圧が約 2.4 V で押さえられる。エミッタが 1.7 V より上がらないので、`Q1` (ベース 約 2.4 V) は切れず、
  **約 2.5〜3 mA が残って**、CH1 は約 **2.4 V** まで上がるだけ。2 本は**逆向き**に動くが、動きは小さい
  (LTspice。2SC1815 を IS = 1e-14・BF = 150、LED を 4 mA で 2.0 V と置いた)
- 反対に `VR1` を基準より 0.1 V 以上**下げる**と、`Q1` が約 6 mA を取り、`Q2` はほぼ切れて D2 が消え、CH2 は約 3.3 V
  (D2 にはオシロの入力へ流れるわずかな電流しか流れず、2-1 と同じ理由で 5 V までは上がらない)、CH1 は約 1.5 V になる。
  こちらの向きでは完全に切り替わる
- 実際は手でつまみを回すので段はなだらかになり、指の震えで少し揺れる

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
| VR1 を少しだけ (0.1V ほど) 上げたとき | D2 が明るく点き (約 5 mA で頭打ち)、D1 は暗くなるが 2.5〜3 mA は流れたまま (LTspice) | 上げる側は Q2 が飽和してベースが押さえられ、完全には切り替わらない |
| VR1 を逆に 0.1V ほど下げたとき | D1 が明るく点き (約 6 mA)、D2 がほぼ消える (LTspice) | 入力差の**符号**で振り分け先が変わる。下げる側は完全に切り替わる |
| 釣り合いのときの 2 つのコレクタ (CH1・CH2) | どちらも約 2.1 V | 2 つの電流が等しい |
| VR1 を 0.1V 上げたときの CH1・CH2 | CH1 約 2.4 V、CH2 約 1.8 V (LTspice) | 2 つのコレクタは逆向きに動くが、Q2 が飽和して止まる。下げたときは CH1 約 1.5 V、CH2 約 3.3 V |
| テールの電流 (RE の両端 ÷ 220Ω) | 釣り合いの近くで約 8.2 mA | 合計はほぼ一定で配分だけが変わる。大きく振って片側が飽和すると、そのベース電流が増えて一定ではなくなる |

## 出典

自作。
