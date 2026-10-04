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

音に反応して LED の明るさが揺れる回路を作る。
エレクトレットコンデンサマイク (ECM) は、音による空気の振動を、ごくわずかな電圧の
変化 (数 mV) に変える。そのままでは小さすぎて目に見えないので、トランジスタ 1 石の
増幅回路 (2-3 で見たエミッタ接地) に通し、LED の明るさの揺れとして音を目で見えるようにする。
後半では、マイクの代わりに Analog Discovery の信号発生器で決まった大きさの信号を入れ、増幅の倍率をオシロで確かめる。

## 回路図

```circuit
title: 図1 マイクの音で LED が揺れる
parts:
  VCC: vcc a2 5V
  R1: resistor a2 c2 2.2k
  MK1: mic c2 e2 l=$\mathrm{MK1}$
  G1: ground e2
  C1: capacitor c2 c4 1u
  VCC: vcc a4 5V
  R2: resistor a4 c4 100k
  Q1: npn e6 2SC1815
  VCC: vcc a6 5V
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

- ECM は中に小さな増幅素子 (FET) を持ち、動かすのに直流の電流 (バイアス電流) が要る。
  MK1 (マイク) は R1 (2.2 kΩ) を通して電源からバイアス電流をもらう。これがいちばん一般的な ECM の使い方だ。
  マイクの出力 (音の振動ぶんの小さな交流の電圧) は C1 (1 µF、2-2 で見た結合コンデンサ) を通って次の段に伝わり、
  直流の電圧は C1 で止まる
- R2 (100 kΩ) は、Q1 のベースに直流の動作点 (音が無いときの電流・電圧) を与える固定バイアス抵抗 (電源からベースへ抵抗 1 本で電流を流す、いちばん簡単なバイアスの掛け方)。
  Q1 は、コレクタに直接 LED (D1) を入れた増幅回路だ。音が無いときも
  LED はうっすら点きっぱなしになり、音が来ると振動に合わせて明るさが揺れる
- R3 (220 Ω) は、LED の電流を制限する抵抗。コレクタの電圧がどれだけ振れるかも、R3 で決まる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤いレール = +5V、青いレール = GND (29・30 列で下のレールへ渡す)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源 5V
    pins: ["+", "-"]
  R1: resistor b3 b7 2.2k
  C1: capacitor c7 c12 1u
  R2: resistor b12 b16 100k
  MK1: mic h7 h10
  Q1: transistor h12(B) h13(C) h14(E) 2SC1815
  D1: led f18(A) f13(K) red
  R3: resistor h18 h22 220
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - +t3 -- a3 red
  - +t16 -- a16 red
  - e7 -- f7 yellow
  - j10 -- -b10 black
  - e12 -- f12 green
  - j14 -- -b14 black
  - j22 -- +b22 red
  - -t29 -- -b29 black
  - +t30 -- +b30 red
notes:
  - text: マイクに息を吹きかけたり手を叩いたりすると LED の明るさが揺れる
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/04-mic-1.svg)

- 電源の + と GND は上のレールに入れ、右端 (29・30 列) で下のレールへ渡す
- 上のブロックに R1 (3→7 列)・C1 (7→12 列)・R2 (12→16 列) を置く。7 列がマイクの節点、12 列が Q1 のベースの節点
- マイク (ECM) は下のブロックの 7・10 列に挿し、7 列を黄色の線で上の 7 列へ、10 列を下の − レールへつなぐ。
  図2 では向きの無い 2 本足の部品として描いたが、実物の ECM には極性がある。
  裏の端子の印字か、ケースとつながった足 (GND 側) を確かめ、GND 側を 10 列に挿す
- Q1 (2SC1815) は、平らな面を手前にして見ると左から E・C・B。ここでは平らな面を奥 (f 行側) に向けて挿し、
  B・C・E を h 行の 12・13・14 列に入れる。ベース (12 列) は緑の線で上の 12 列へ、エミッタ (14 列) は下の − レールへ
- コレクタ (13 列) に D1 のカソード、D1 のアノード (18 列) から R3 (18→22 列) を通して下の + レールへつなぐ

## マイクの代わりに AD の信号発生器 (1kHz) で試す

マイクを声や手拍子で鳴らす代わりに、Analog Discovery の信号発生器 W1 から
1 kHz の正弦波を入れれば、いつでも同じ大きさの音を「聞かせる」ことができる。
回路の増幅や LED の揺れを、何度でも同じ信号で確かめられる。

エレクトレットマイクの出力は、話し声の大きさで数 mV〜数十 mV (実効値) ほど。
W1 の出力は大きすぎる (最小でも数十 mV、ふつう 1 V 前後) ので、
10 kΩ (R<sub>S</sub>) と 100 Ω (R<sub>D</sub>) の分圧で 1/100 ほどに下げて、
マイクが付いていた節点 (R1 と C1 の間) に入れる (図3)。マイクは外し、
結合コンデンサ C1 から先は元のままにする。

```circuit
title: 図3 マイクの代わりに W1 を分圧して入れる (CH2 は入力、CH1 は出力)
parts:
  W1: sine c2 e2 l=$\mathrm{W1}$
  G0: ground e2
  RS: resistor c2 c5 10k
  VCC: vcc a5 5V
  R1: resistor a5 c5 2.2k
  RD: resistor c5 e5 100
  G1: ground e5
  M2: voltmeter d6 f6 l=$\mathrm{CH2}$
  G2: ground f6
  C1: capacitor c6 c8 1u
  VCC: vcc a8 5V
  R2: resistor a8 c8 100k
  Q1: npn e10 2SC1815
  VCC: vcc a10 5V
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
- 分圧の比は 100 Ω ÷ (10 kΩ + 100 Ω) ≈ 1/101。ただし R1 (2.2 kΩ) のもう一端の電源は、
  交流から見ると GND と同じ (電源は電圧が揺れないため) なので、R1 は R<sub>D</sub> と並列になって 96 Ω になる (比は約 1/106)。
  さらに C1 (1 kHz で約 160 Ω) の先の Q1 の入力抵抗 (約 0.6 kΩ = hFE × 26 mV / 4.3 mA) が負荷になる。
  これらを合わせると節点の交流は W1 の約 1/121、16.5 mVpp (約 5.8 mV 実効値) になり、話し声のマイクと同じ桁になる
- 節点の直流は R1 と R<sub>D</sub> の分圧で約 0.2 V。C1 が止めるので Q1 のバイアスには響かない。
  R<sub>D</sub> に電源から約 2 mA 流れるが、V+ には十分な余裕がある
- 節点に CH2 (2+) を、Q1 のコレクタ (LED のカソード側) に CH1 (1+) を当てる (2− と 1− は GND)。
  CH1 は直流 2.1 V に振れが乗るので、Scope の入力を AC カップリングにするか、
  オフセットで 2.1 V 分を打ち消す

```breadboard
title: 図4 マイクを外し、W1 を 10kΩ と 100Ω の分圧で入れる
# AD の V+ (5 V) を下の + レール、GND を下の − レールへ入れ、29・30 列で上のレールへ渡す
board: half
parts:
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, W1, 2+, 2-, 1+, 1-]
  R1: resistor b3 b7 2.2k
  C1: capacitor c7 c12 1u
  R2: resistor b12 b16 100k
  RS: resistor i3 i7 10k
  RD: resistor h7 h10 100
  Q1: transistor h12(B) h13(C) h14(E) 2SC1815
  D1: led f18(A) f13(K) red
  R3: resistor h18 h22 220
wires:
  - AD.V+ -- +b1 red
  - AD.GND -- -b2 black
  - AD.W1 -- j3 yellow
  - AD.2+ -- j7 blue
  - AD.2- -- -b8 black
  - AD.1+ -- j13 orange
  - AD.1- -- -b15 black
  - +t3 -- a3 red
  - +t16 -- a16 red
  - e7 -- f7 yellow
  - j10 -- -b10 black
  - e12 -- f12 green
  - j14 -- -b14 black
  - j22 -- +b22 red
  - -t29 -- -b29 black
  - +t30 -- +b30 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/04-mic-2.svg)

図2 からマイク MK1 を抜き、その 7・10 列に R<sub>D</sub> (100 Ω) を挿す。10 列から下の − レールへの黒線はそのまま使う。
ほかの部品は図2 のまま。電源は図2 の電源の代わりに、Analog Discovery の V+ (5 V) を使う。
Analog Discovery は板の下に置き、線は下のレールと j 行に挿す。

- W1 (黄): `j3` へ。R<sub>S</sub> (10 kΩ、`i3`〜`i7`) を通って、入力の節点 (下のブロックの 7 列) へつながる
- 7 列には、上の 7 列への黄色の線 (`f7`)、R<sub>D</sub> (`h7`)、R<sub>S</sub> の右足 (`i7`)、CH2 の 2+ (青、`j7`) が並ぶ (穴ごとに足は 1 本)
- CH1 の 1+ (橙): Q1 のコレクタ (13 列) の `j13`
- AD の V+ は下の + レールへ (赤)、GND・2−・1− は下の − レールへ (黒)。上下のレールは右端の 29・30 列でつながっている

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
利得 (出力の振幅 ÷ 入力の振幅) は約 38 倍 (hFE = 100・コレクタ電流 4.3 mA の計算値)。ほぼ反転していて、
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

表の値は計算値。hFE = 100 と仮定した (2SC1815 は実物の hFE のばらつきが
大きいので、LED がずっと明るく点きっぱなしなら R2 を大きく、暗すぎるなら小さくする)。
直流の電圧はテスターの DC 電圧レンジで測り、交流は図5 のようにオシロで見る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Q1 のベース電流 | 約 43 µA (= (5 − 0.7) / 100 kΩ) | R2 で決まる |
| Q1 のコレクタ電流 (無音時) | 約 4.3 mA | LED はうっすら点いた状態が動作点 |
| Q1 の C-E 間電圧 (無音時) | 約 2.1 V (= 5 − 2.0 − 4.3 mA × 220 Ω) | 信号を受けて上下に振れる余地がある |
| W1 1 kHz・2 Vpp (マイクの代わり) のときの入力の節点 (CH2) | 約 16.5 mVpp | 分圧と Q1 の入力抵抗の負荷で約 1/121 |
| 同じときの Q1 のコレクタ (CH1) | 約 0.62 Vpp、ほぼ反転 (利得 約 38 倍) | hFE = 100 での計算値 |
| 手を叩いたときの LED の電圧の揺れ (概算) | 約 0.2 V (振幅) | マイクの感度を −44 dBV/Pa (1 Pa の音圧で約 6.3 mV を出す) と仮定した見積もり |

マイクのバイアス電流 (R1 = 2.2 kΩ) は、代表的な ECM の値 (0.3 mA ほど) を仮定した。
実物のデータシートがあれば、そちらの値で R1 を選び直すとよい。

## 出典

自作。
