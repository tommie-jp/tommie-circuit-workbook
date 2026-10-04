---
book: circuits
chapter: 5
id: 5-9
title: 逆接続保護 — ダイオード / P-MOSFET
tier: 100
board: BB
source: 自作
era: 今
---

# 5-9 逆接続保護 — ダイオード / P-MOSFET

電池や電源を逆向きにつないでも、回路が壊れないようにする。電池ボックスの向きの入れ間違いはよく起きるので、
電池で動く機器には欠かせない回路だ。2 つの方式を比べる。

- **直列ダイオード** (図1): 昔からの定番。ただし、順方向電圧ぶんの電圧と電力をいつも捨ててしまう
- **P チャネル MOSFET** (図2): ゲートを GND に固定して (ゲート接地) 使う。電圧降下を、電流 × オン抵抗まで小さくできる。
  今どきの低電圧・大電流の機器の定番

## 回路図

```circuit
title: 図1 ダイオード方式
parts:
  V1: battery vin gnd 5
  G1: ground gnd
  D1: schottky vin a3 1N5819
  RL1: resistor a3 c3 100
  G2: ground c3
points:
  vin: a1
  gnd: c1
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/09-reverse-polarity-protection-1.svg)

```circuit
title: 図2 P-MOSFET 方式 (ゲート接地)
parts:
  V2: battery vin2 gnd2 5
  G3: ground gnd2
  Q1: pmos a4 r90 mirror IRF9540
  RL2: resistor a6 c6 100
  G4: ground c4
  G5: ground c6
points:
  vin2: a1
  gnd2: c1
wires:
  - vin2 -- Q1.D
  - Q1.S -- a6
  - Q1.G -- c4
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/09-reverse-polarity-protection-2.svg)

- 図1: D1 (ショットキーダイオード、1N5819) を電源の + 側に直列に入れるだけ。
  正しい向きなら D1 が導通して電流が流れ、逆向きなら D1 が電流を止める。
  D1 の順方向電圧 (電流によるが約 0.4〜0.5 V) ぶんを、いつも消費し続けるのが弱点
- 図2: P チャネル MOSFET (IRF9540) の**ドレインを電池側、ソースを負荷側**に入れ、
  ゲートを GND (電池のマイナス) に固定する。ふつうの使い方 (2-5) とは D と S が逆向きなのが要点だ
- MOSFET の中には、ドレインからソースへ向かう寄生ダイオード (ボディダイオード) がある。
  正しい向きにつなぐと、まずこのダイオードが導通して、ソースが約 4.6 V まで上がる
- するとゲートとソースの間の電圧 V<sub>GS</sub> (2-5 で見た) が大きく負になる
  (ソースがほぼ +5 V、ゲートが 0 V なので V<sub>GS</sub> ≈ −5 V)。P チャネルは V<sub>GS</sub> が負で ON になるので、
  チャネルが深く ON して寄生ダイオードを短絡し、電流はオン抵抗だけを通って流れる
  (チャネルはドレインからソースの向きにも電流を通せる)
- 逆向きにつなぐと、ドレインが −5 V になって寄生ダイオードには逆向きの電圧が掛かる。
  ソースは負荷を通して 0 V、ゲートも 0 V なので V<sub>GS</sub> = 0 V で OFF のままになり、電流は流れない。
  ソースを電池側にすると、逆接続のとき寄生ダイオードが導通して素通りしてしまい、保護にならない
- MOSFET 方式の電圧降下は電流に比例する (I × R<sub>DS(on)</sub>)。ダイオード方式の降下はほぼ一定なので、
  電流が小さいほど MOSFET が有利になり、電流が大きいとオン抵抗の発熱が効いてくる

## 実体配線図

負荷電流は約 50 mA で、AD3 の Supplies の 1 レールの目安 (約 50 mA) の上限になる。**ここは USB アダプタ (5 V) を電源にし、AD3 は電圧を読む Scope だけに使う。**
板を通る電流は 50 mA で、1 穴 200 mA の範囲に収まる。逆接続の実験は、電源の線を入れ替える (+5V を GND の穴へ、GND を +5V の穴へ) ことで行う。
この題は直流の電圧だけを見るので、オシロの波形の図は付けない。

```breadboard
title: 図3 ダイオード方式 (図1) を組む。Scope 1+ を負荷、2+ を電源へ
# 上の赤レール = +5V、青レール = GND
board: half
parts:
  PS:
    type: device
    at: top
    label: 5 V 電源 (USB アダプタ)
    pins: [+5V, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope (DC 電圧計)
    pins: [1+, 2+, 1-, 2-]
  D1: diode b10(A) b14(K) 1N5819
  RL1: resistor/half c14 c18 100
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - +t10 -- a10 red
  - a18 -- -t18 black
  - SC.1+ -- d14 orange
  - SC.2+ -- +t20 green
  - SC.1- -- -t22 black
  - SC.2- -- -t23 black
notes:
  - text below: 上の赤レール = +5V、青レール = GND。逆接続の実験は PS の線を入れ替える
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/09-reverse-polarity-protection-1.svg)

- D1 (1N5819) はアノードを 10 列、カソード (帯のある側) を 14 列に挿す。+5V は赤の線 `+t10 → a10` で D1 のアノードの列へ。RL1 (100 Ω、1/2 W 以上) は D1 のカソードの列 14 から 18 列へ渡し、黒の線 `a18 → -t18` で GND へ
- Scope の 1+ (橙) は D1 のカソードの 14 列 (`d14`、負荷に届く電圧)、2+ (緑) は上の赤レール (電源の電圧)。1− と 2− (黒) は上の青レールへ。2 つの差が D1 の電圧降下 (約 0.4 V)

```breadboard
title: 図4 P-MOSFET 方式 (図2) を組む。Scope 1+ を負荷、2+ を電源へ
# 上の赤レール = +5V、青レール = GND。IRF9540 は G・D・S の順 (図2 と同じく D を電源側、S を負荷側に)
board: half
parts:
  PS:
    type: device
    at: top
    label: 5 V 電源 (USB アダプタ)
    pins: [+5V, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope (DC 電圧計)
    pins: [1+, 2+, 1-, 2-]
  Q1: transistor/to220 e10(G) e11(D) e12(S) IRF9540
  RL2: resistor/half b12 b16 100
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - a10 -- -t10 black
  - +t11 -- a11 red
  - a16 -- -t16 black
  - SC.1+ -- d12 orange
  - SC.2+ -- +t20 green
  - SC.1- -- -t22 black
  - SC.2- -- -t23 black
notes:
  - text below: 上の赤レール = +5V、青レール = GND。ゲート (10 列) は GND、ドレイン (11 列) は電源側
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/09-reverse-polarity-protection-2.svg)

- Q1 (IRF9540、TO-220) は、印字のある面を手前に、足を下に向けて、左から G (ゲート)・D (ドレイン)・S (ソース) の順。図は G を 10 列、D を 11 列、S を 12 列に挿す。足の並びは使う品のデータシートで確かめる
- **ゲート (10 列) は黒の線 `a10 → -t10` で GND へ、ドレイン (11 列) は赤の線 `+t11 → a11` で電源の + 側へ、ソース (12 列) は負荷へ**。2-5 の MOSFET スイッチと D・S の向きが逆。RL2 (100 Ω、1/2 W 以上) は 12 列から 16 列へ渡し、黒の線 `a16 → -t16` で GND へ
- Scope の 1+ (橙) はソースの 12 列 (`d12`、負荷に届く電圧)、2+ (緑) は上の赤レール (電源の電圧)。差が MOSFET の電圧降下 (約 0.01 V)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1 | ショットキーバリアダイオード | 1N5819 (V<sub>F</sub> ≈ 0.45V @0.1A 前後) |
| Q1 | P チャネル MOSFET | IRF9540 (R<sub>DS(on)</sub> ≈ 0.2Ω、TO-220。0.2Ω は V<sub>GS</sub> = −10V での値で、−5V ではこれより大きくなる。表の計算は 0.2Ω と仮定) |
| RL1, RL2 | 抵抗 (負荷、2 W 級を使う。0.2〜0.25 W ほど消費するため) | 各 100 Ω |
| — | 電源 | 5 V (USB アダプタ。負荷電流が約 50 mA で AD3 の Supplies の 1 レールの目安に当たるため) |
| — | 計器 | AD3 の Scope 1+ / 2+ (負荷と電源の直流の電圧)、テスター |

## 見るべき値

表の値は、RL = 100 Ω のときの計算値。ダイオードの順方向電圧は 0.40 V、MOSFET のオン抵抗は 0.2 Ω と仮定した。
測り方: テスターの DC 電圧レンジで、電池の両端と RL の両端を測る。その差が保護素子の電圧降下になる。
負荷電流は RL の電圧を 100 Ω で割って求める。電池を逆向きにつなぎ直すと、どちらの方式でも RL の電圧は 0 V になる。

| 測る所 | ダイオード方式 | P-MOSFET 方式 | 分かること |
| --- | --- | --- | --- |
| 負荷電流 | 約 46.0 mA | 約 49.9 mA | MOSFET は電圧降下が少ない分、電流もわずかに多く流れる |
| 保護素子の電圧降下 | 約 0.40 V (V<sub>F</sub> 一定と仮定) | 約 0.010 V (0.0499 A × 0.2 Ω) | MOSFET はダイオードの 1/40 ほど |
| 保護素子の消費電力 | 約 18.4 mW | 約 0.5 mW | MOSFET は発熱もずっと少ない |
| 負荷に届く電圧 | 約 4.60 V | 約 4.99 V | 5V からの目減りが少ない分、MOSFET が有利 |
| RL の消費電力 | 約 0.21 W | 約 0.25 W | 1/4 W 抵抗では定格ぎりぎり。RL1・RL2 は 2 W 級の抵抗を使う (消費は定格の半分以下で余裕がある) |

電流をもっと増やすと話が変わる。ダイオードの損失は電流にほぼ比例
(I × V<sub>F</sub>) するのに対し、MOSFET の損失は電流の 2 乗に比例 (I² × R<sub>DS(on)</sub>)
して増える。この 2 つが並ぶのは I = V<sub>F</sub> / R<sub>DS(on)</sub> ≈ 0.45 / 0.2 = 2.25 A
あたり (計算上の目安。V<sub>F</sub> は電流が増えると大きくなるので 0.45 V とした)。
それより大きい電流では、ダイオードのほうが損失が少なくなる。MOSFET 方式が有利なのは「そこそこの電流まで」と覚えておく。
数百 mA 以下の軽い負荷なら、部品点数の少ないダイオード方式で十分なことも多い。

## 出典

自作。
