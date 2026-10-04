---
book: circuits
chapter: 2
id: 2-7
title: カレントミラー
tier: 100
source: 自作
---

# 2-7 カレントミラー

2 つのトランジスタの**ベースとエミッタを共通**にし、片方のコレクタと
ベースを短絡 (ダイオード接続) すると、もう片方のコレクタには
**ほぼ同じ電流が「写し取られる」**。基準側の電流を 1 本の抵抗で決めるだけで、
出力側は負荷の変化にほとんど左右されない定電流源 (いつも同じ電流を流す回路) になる。
この題では、出力側に LED をつないで流れる電流を測り、LED を 2 個に増やしても電流が
変わらないことを確かめる。

## 回路図

```circuit
title: 図1 カレントミラーで LED を定電流点灯する (CH2 で RREF、CH1 で RS の電圧を見る)
parts:
  VCC: vcc b1 5V
  M2: voltmeter b2 d2 l=$\mathrm{CH2}$
  RREF: resistor b4 d4 560
  Q1: npn f4 mirror
  RS: resistor b7 c7 47
  D1: led c7 d7
  Q2: npn f7
  M1: voltmeter b9 c9 l=$\mathrm{CH1}$
  G0: ground g5
wires:
  - b1 -- b2 -- b4 -- b7 -- b9
  - d2 -- d4
  - c7 -- c9
  - d4 -- Q1.C
  - d4 -- d5
  - d5 -- f5
  - Q1.B -- f5
  - f5 -- Q2.B
  - d7 -- Q2.C
  - Q1.E -- g4
  - Q2.E -- g7
  - g4 -- g5 -- g7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/07-current-mirror.svg)

図1 の +5V は Analog Discovery の V+ (WaveForms の Supplies で 5 V にして入れる)。
流れるのは基準側と出力側を合わせて 15 mA ほどなので V+ で足りる。
AD の入力は差動 (1+ と 1− の間の電圧を測り、1− を GND につながなくてよい) なので、
CH2 は `RREF` の両端、CH1 は `RS` の両端の電圧をそのまま測る。
`RS` (47Ω) は出力側の電流を電圧に変えて読むための抵抗 (電流を見る抵抗) で、
ミラーの働きには関わらない。

`Q1` はコレクタとベースを短絡した**ダイオード接続** (ベース-エミッタ間がダイオード 1 個と同じに働く) で、
`RREF` に流れる基準電流を受けて、それに見合う V<sub>BE</sub> を作る。`Q2` は `Q1` とベース・エミッタを共通にしているので、
`Q1` と同じコレクタ電流を**写し取る** (ミラーする)。

- 基準電流: I<sub>ref</sub> = (5 − 0.7) / 560Ω ≈ **7.68 mA** (8.2kΩ では
  (5−0.7)/8.2k ≈ 0.52mA しか流れず LED が暗すぎる。5 V の電源で LED を
  見える明るさにするため 560Ω にしてある)
- hFE が十分大きければ I<sub>out</sub> ≈ I<sub>ref</sub>。実際は 2 つのベース電流の
  ぶんだけ少し目減りする: I<sub>out</sub>/I<sub>ref</sub> = hFE/(hFE+2)
  - hFE = 100: 比 ≈ 0.980 → I<sub>out</sub> ≈ **7.53 mA**
  - hFE = 200: 比 ≈ 0.990 → I<sub>out</sub> ≈ **7.60 mA**
  - hFE = 400: 比 ≈ 0.995 → I<sub>out</sub> ≈ **7.64 mA**
- `RS` の両端 (CH1) は 47Ω × 7.53〜7.64 mA ≈ **0.35〜0.36 V**。÷47Ω で I<sub>out</sub> が読める
- LED (`D1`, V<sub>F</sub> ≈ 2.0V) を流れる電流はほぼ I<sub>out</sub> そのもの。
  Q2 の C-E 間電圧 = 5 − 0.36 − 2.0 = **約 2.6 V** の余裕があるので、活性領域で
  安定に動く (この余裕を**コンプライアンス電圧**と呼ぶ)

1-1 の「抵抗 1 本で LED の電流を決める」方法では、LED の V<sub>F</sub> が変わると
電流も変わる。カレントミラーは **`RREF` と電源電圧だけで決まる基準電流**を
写すので、出力側の負荷 (ここでは LED の V<sub>F</sub>) が変わっても電流は
ほとんど変わらない。

## 実体配線図

```breadboard
title: 図2 カレントミラーで LED を定電流点灯する
# 5V は AD の V+ から上の + レールへ、GND は上の − レール (下のレールは使わない)
board: half
parts:
  RREF: resistor b6 b11 560
  Q1: transistor e10(E) e11(C) e12(B) 2SC1815
  Q2: transistor e13(B) e14(C) e15(E) 2SC1815
  D1: led c17(A) c14(K) red
  RS: resistor b22 b17 47
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 2+, 2-, 1-, 1+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.2+ -- +t8 blue
  - AD.2- -- a11 blue
  - AD.1- -- a17 orange
  - AD.1+ -- +t20 orange
  - +t6 -- a6 red
  - d11 -- d12 green
  - c12 -- c13 green
  - a10 -- -t10 black
  - a15 -- -t15 black
  - +t22 -- a22 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/07-current-mirror.svg)

図2 のとおり、5V は Analog Discovery の V+ (赤) から上の + レールの `+t1` へ、GND (黒) は `-t2` へ入れる。

- **Q1・Q2 は上のブロックの e 行に、ベースどうしが隣り合うように挿す**
  (Q1 は `e10` E・`e11` C・`e12` B、Q2 は `e13` B・`e14` C・`e15` E。Q2 は 180 度回す)。
  上の a〜d 行が空くので、線を真っすぐ挿せる
- **ダイオード接続**: Q1 のコレクタ (列 11) とベース (列 12) を緑の短い線 `d11`–`d12` でつなぐ
- **ベースの共通**: 緑の短い線 `c12`–`c13` で Q1 と Q2 のベースをつなぐ
- **基準側**: + レールから `a6` へ赤線、`RREF` は `b6`–`b11` で Q1 のコレクタの列へ
- **出力側**: + レールから `a22` へ赤線、`RS` (`b22`–`b17`)、LED (アノード `c17`・カソード `c14`) で Q2 のコレクタへ
- **エミッタ**: `a10` と `a15` から上の − レールへ (黒)
- **CH2 (青)**: 2+ を + レール (`+t8`)、2− を Q1 のコレクタの列 (`a11`) に挿す → `RREF` の両端
- **CH1 (橙)**: 1+ を + レール (`+t20`)、1− を LED のアノードの列 (`a17`) に挿す → `RS` の両端

## AD で測る

どの電圧も時間で変わらない直流なので、オシロの波形は平らな線になるだけで見どころがない。
WaveForms の **Voltmeter** (または Scope の Measurements の Average) で CH1・CH2 の値を読む。

- CH2 ≈ 4.3 V → I<sub>ref</sub> = 4.3 / 560 ≈ 7.7 mA
- CH1 ≈ 0.35〜0.36 V → I<sub>out</sub> = CH1 / 47 ≈ 7.5〜7.6 mA
- LED を 2 個直列にしても CH1 はほとんど動かない。I<sub>out</sub> が負荷によらないことが数字で分かる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RREF | 抵抗 (1/4 W) | 560 Ω |
| RS | 抵抗 (1/4 W、電流を見る) | 47 Ω |
| Q1, Q2 | NPN トランジスタ (特性のそろった 2 個が望ましい) | 2SC1815 |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RREF の両端の電圧 (CH2、÷560Ω で I<sub>ref</sub>) | 約 4.3 V (I<sub>ref</sub> ≈ 7.68mA) | 基準電流は抵抗と電源電圧だけで決まる |
| RS の両端の電圧 (CH1、÷47Ω で I<sub>out</sub>) | 約 0.35〜0.36 V (I<sub>out</sub> ≈ 7.53〜7.64 mA、Q1・Q2 の hFE 次第) | I<sub>ref</sub> にほぼ等しい |
| D1 を 2 個直列 (V<sub>F</sub> 合計 4V) に替えたときの CH1 | ほとんど変わらない (約 0.35 V、I<sub>out</sub> ≈ 7.5 mA) | 出力側の負荷電圧が変わっても電流は一定。Q2 の C-E 間は 5 − 0.36 − 4 ≈ 0.6 V で、まだ飽和 (約 0.2 V) していない |
| Q2 の C-E 間電圧 (LED 1 個) | 約 2.6 V | 活性領域に十分な余裕がある |

## 出典

自作。
