---
book: circuits
chapter: 8
id: 8-4
title: マイクで音に反応
tier: 50
source: 自作
board: BB
---

# 8-4 マイクで音に反応

エレクトレットコンデンサマイク (ECM) は、音の空気の振動をごくわずかな電圧の
変化に変える。そのままでは小さすぎて目に見えないので、トランジスタ 1 石の
増幅回路に通し、LED の明るさの揺れとして音を目で見えるようにする。

## 回路図

```circuit
title: 図1 マイクの音で LED が揺れる
parts:
  VCC: vcc a2
  R1: resistor a2 c2 2.2k
  MK1: mic c2 e2 l=$\mathrm{MK1}$
  G1: ground e2
  C1: capacitor c2 c4 1u
  VCC: vcc a4
  R2: resistor a4 c4 100k
  Q1: npn e6
  VCC: vcc a6
  R3: resistor a6 c6 220
  D1: led c6 d6
  G2: ground f6
wires:
  - c4 |- Q1.B
  - d6 -- Q1.C
  - Q1.E -- f6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/04-mic-1.svg)

- MK1 (マイク) は R1 (2.2 kΩ) で電源からバイアス電流をもらう、いちばん
  一般的な ECM の使い方。マイクの出力 (音の振動ぶんの小さな AC 電圧) は
  C1 (1 µF) を通してだけ次の段に伝わり、直流のバイアス電圧はここで止まる
- R2 (100 kΩ) は Q1 のベースに直流の動作点を与える固定バイアス抵抗。
  Q1 は**コレクタに直接 LED (D1) を入れた増幅回路**で、音が無いときも
  LED はうっすら点きっぱなしになり、音が来ると振動に合わせて**明るさが揺れる**
- R3 (220 Ω) は LED の電流を決める抵抗。Q1 の動作点をここで決めている

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤いレール = +5V、青いレール = GND
board: full
parts:
  R1: resistor a3 a6 2.2k
  MK1: mic a9 a12
  C1: capacitor a16 a19 1u
  R2: resistor a23 a26 100k
  Q1: transistor e29(B) e30(C) e31(E) 2SC1815
  R3: resistor a34 a37 220
  D1: led c37(A) c39(K) red
wires:
  - +t3 -- b3 red
  - b6 -- b9
  - -t12 -- b12 black
  - c9 -- c16
  - b19 -- b26
  - +t23 -- b23 red
  - c26 -- d29
  - d30 -- b39
  - +t34 -- b34 red
  - -t31 -- d31 black
notes:
  - text: マイクに息を吹きかけたり手を叩いたりすると LED の明るさが揺れる
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/04-mic-1.svg)

- マイク (ECM) は 2 本足の部品として置ける (向きは無い扱い)。実物には裏に
  端子の印字があるので、GND 側を確かめて挿す
- 配線は部品の足そのものではなく、同じ列の空いた行 (b・d 行) を経由させてある

## マイクの代わりに AD の信号発生器 (1kHz) で試す

マイクを声や手拍子で鳴らす代わりに、Analog Discovery の信号発生器 W1 から
1 kHz の正弦波を入れれば、いつでも同じ大きさの音を「聞かせる」ことができる。
回路の増幅や LED の揺れを、再現性のある信号で確かめられる。

エレクトレットマイクの出力は、話し声の大きさで数 mV〜数十 mV (実効値) ほど。
W1 の出力は大きすぎる (最小でも数十 mV、ふつう 1 V 前後) ので、
**10 kΩ (R<sub>S</sub>) と 100 Ω (R<sub>D</sub>) の分圧で 1/100 ほどに下げて**、
マイクが付いていた節点 (R1 と C1 の間) に入れる。マイクは外し、
結合コンデンサ C1 以降は元のままにする。

```circuit
title: 図3 マイクの代わりに W1 を分圧して入れる (CH2 は入力、CH1 は出力)
parts:
  W1: sine c2 e2 l=$\mathrm{W1}$
  G0: ground e2
  RS: resistor c2 c5 10k
  VCC: vcc a5
  R1: resistor a5 c5 2.2k
  RD: resistor c5 e5 100
  G1: ground e5
  M2: voltmeter d6 f6 l=$\mathrm{CH2}$
  G2: ground f6
  C1: capacitor c6 c8 1u
  VCC: vcc a8
  R2: resistor a8 c8 100k
  Q1: npn e10
  VCC: vcc a10
  R3: resistor a10 c10 220
  D1: led c10 d10
  G3: ground f10
  M1: voltmeter d12 f12 l=$\mathrm{CH1}$
  G4: ground f12
wires:
  - c5 -- c6
  - c6 -- d6
  - c8 |- Q1.B
  - d10 -- Q1.C
  - Q1.E -- f10
  - d10 -- d12
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/04-mic-2.svg)

- W1 は 1 kHz、振幅 1 V (2 Vpp)、オフセット 0 V の正弦波。WaveForms の Wavegen で W1 を Sine にする
- 分圧の比は 100 Ω ÷ (10 kΩ + 100 Ω) ≈ 1/101。ただし R1 (2.2 kΩ) は電源側で
  交流的には GND なので、R<sub>D</sub> と並列になって 96 Ω (比は約 1/106)。
  さらに C1 の先の Q1 の入力抵抗 (約 0.6 kΩ) が負荷になり、節点の交流は
  **W1 の約 1/121、16.5 mVpp (約 5.8 mV 実効値)**。話し声のマイクと同じ桁になる
- 節点の直流は R1 と R<sub>D</sub> の分圧で約 0.2 V。C1 が止めるので Q1 のバイアスには響かない。
  R<sub>D</sub> に電源から約 2 mA 流れるが、V+ には十分な余裕がある
- 節点に CH2 (2+) を、Q1 のコレクタ (LED のカソード側) に CH1 (1+) を当てる。
  CH1 は直流 2.1 V に振れが乗るので、Scope の入力を AC カップリングにするか、
  オフセットで 2.1 V 分を打ち消す

```breadboard
title: 図4 マイクを外し、W1 を 10kΩ と 100Ω の分圧で入れる
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 2+, 2-, 1+, 1-]
  R1: resistor a3 a6 2.2k
  RS: resistor c9 c12 10k
  RD: resistor a12 -t12 100
  C1: capacitor a16 a19 1u
  R2: resistor a23 a26 100k
  Q1: transistor e29(B) e30(C) e31(E) 2SC1815
  R3: resistor a34 a37 220
  D1: led c37(A) c39(K) red
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.W1 -- a9 yellow
  - AD.2+ -- e12 blue
  - AD.2- -- -t13 black
  - AD.1+ -- a30 orange
  - AD.1- -- -t33 black
  - +t3 -- b3 red
  - b6 -- b12
  - d12 -- b16
  - b19 -- b26
  - +t23 -- b23 red
  - c26 -- d29
  - d30 -- b39
  - +t34 -- b34 red
  - -t31 -- d31 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/04-mic-2.svg)

図2 からマイク MK1 と、その GND への黒線 (`-t12`〜`b12`)、`b6`〜`b9`・`b9`〜`b16` の線を外し、
R1 の線と C1 の線を 12 列へつなぎ直す (右の部品は図2 のまま。列が 39 まであるので板はフルサイズのまま)。

- **W1 (黄)**: `a9` へ。同じ 9 列の `c9` に R<sub>S</sub> (10 kΩ) の左足が挿さっている
- **R<sub>S</sub>**: `c9`〜`c12`。右足 (`c12`) が入力の節点 (12 列)
- **R<sub>D</sub> (100 Ω)**: `a12` から上の − レールへ縦に。12 列には R1 からの線 (`b6`〜`b12`)、
  R<sub>S</sub> (`c12`)、C1 への線 (`d12`)、CH2 の 2+ (青、`e12`) が並ぶ (穴ごとに足は 1 本)
- **CH1 (橙)**: Q1 のコレクタ (30 列) の `a30`
- AD の V+ は上の + レールへ (赤)、GND・2−・1− は − レールへ (黒)。電源は 5 V

WaveForms の Supplies で V+ を 5 V にしてから W1 を出す。

```scope
title: 図5 入力 (CH2) と出力 (CH1) — 1 kHz、入力は数 mV、出力は約 38 倍で反転
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 0.62Vpp phase 193deg, range: 200mV/div}
ch2: {wave: sine 1kHz 16.5mVpp, range: 5mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/04-mic.svg)

CH2 (節点) は約 16.5 mVpp、CH1 (コレクタ) は約 0.62 Vpp の 1 kHz の正弦波で、
**利得は約 38 倍** (h<sub>FE</sub> = 100・コレクタ電流 4.3 mA の計算値)。ほぼ反転していて、
CH1 が谷のとき CH2 は山になる (C1 と入力抵抗のせいで 13° ほどずれる)。
LED は 1 kHz では揺れが速すぎて、ほぼ点きっぱなしに見える。
コレクタの振れは約 0.31 V (振幅) で、下の表の手拍子の見積もり (約 0.2 V) と同じ桁になる。
W1 の振幅を下げると、出力もそれに比例して小さくなる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| MK1 | エレクトレットコンデンサマイク | — |
| R1 | 抵抗 (マイクのバイアス) | 2.2 kΩ |
| C1 | 電解コンデンサ (結合用) | 1 µF |
| R2 | 抵抗 (ベースバイアス) | 100 kΩ |
| Q1 | NPN トランジスタ | 2SC1815 |
| R3 | 抵抗 (LED 電流) | 220 Ω |
| RS | 抵抗 (W1 の分圧、マイクの代わりの試験用) | 10 kΩ |
| RD | 抵抗 (W1 の分圧、マイクの代わりの試験用) | 100 Ω |
| D1 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |
| — | 信号発生器・電源 (試験用) | Analog Discovery (W1、V+ = 5 V) |

## 見るべき値

計算値。h<sub>FE</sub> = 100 と仮定 (2SC1815 は実物の h<sub>FE</sub> のばらつきが
大きいので、LED がずっと点きっぱなしなら R2 を大きく、暗すぎるなら小さくする)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Q1 のベース電流 | 約 43 µA (= (5 − 0.7) / 100 kΩ) | R2 で決まる |
| Q1 のコレクタ電流 (無音時) | 約 4.3 mA | LED はうっすら点いた状態が動作点 |
| Q1 の C-E 間電圧 (無音時) | 約 2.1 V | 振幅を受けて上下に振れる余地がある |
| W1 1 kHz・2 Vpp (マイクの代わり) のときの入力の節点 (CH2) | 約 16.5 mVpp | 分圧と Q1 の入力抵抗の負荷で約 1/121 |
| 同じときの Q1 のコレクタ (CH1) | 約 0.62 Vpp、ほぼ反転 (利得 約 38 倍) | h<sub>FE</sub> = 100 での計算値 |
| 手を叩いたときの LED の電圧の揺れ (概算) | 約 0.2 V (振幅) | マイクの感度を −44 dB (1 V/Pa) と仮定した見積もり |

**マイクのバイアス電流** (R1 = 2.2 kΩ) は代表的な ECM の値 (0.3 mA ほど) を仮定。
実物のデータシートがあれば、そちらの値で R1 を選び直すとよい。

## 出典

自作。
