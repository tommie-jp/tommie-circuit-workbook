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
  VCC: vcc 2,2 5V
  R1: resistor 2,2 2,4 2.2k
  MK1: mic 2,4 2,6 l=$\mathrm{MK1}$
  G1: ground 2,6
  C1: capacitor 2,4 4,4 1u
  VCC: vcc 4,2 5V
  R2: resistor 4,2 4,4 100k
  Q1: npn 6,6 2SC1815
  VCC: vcc 6,2 5V
  R3: resistor 6,2 6,4 220
  D1: led 6,4 6,5
  G2: ground 6,7
wires:
  - 4,4 |- Q1.B
  - 6,5 -- Q1.C
  - Q1.E -- 6,7
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
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
  R1: resistor b3 b7 2.2k
  C1: capacitor c7 c12 1u
  R2: resistor b12 b16 100k
  MK1: mic h7 h10
  Q1: transistor h12(B) h13(C) h14(E) 2SC1815
  D1: led f18(A) f13(K) red
  R3: resistor h18 h22 220
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
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

- AD3 の V+ (+5 V) と GND は上のレールに入れ、右端 (29・30 列) で下のレールへ渡す
- 上のブロックに R1 (3→7 列)・C1 (7→12 列)・R2 (12→16 列) を置く。7 列がマイクの節点、12 列が Q1 のベースの節点
- マイク (ECM) は下のブロックの 7・10 列に挿し、7 列を黄色の線で上の 7 列へ、10 列を下の − レールへつなぐ。
  図2 では向きの無い 2 ピンの部品として描いたが、実物の ECM には極性がある。
  裏の端子の印字か、ケースとつながったピン (GND 側) を確かめ、GND 側を 10 列に挿す
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
  W1: sine 2,4 2,6 l=$\mathrm{W1}$
  G0: ground 2,6
  RS: resistor 2,4 5,4 10k
  VCC: vcc 5,2 5V
  R1: resistor 5,2 5,4 2.2k
  RD: resistor 5,4 5,6 100
  G1: ground 5,6
  M2: voltmeter 6,5 6,7 l=$\mathrm{CH2}$
  G2: ground 6,7
  C1: capacitor 6,4 8,4 1u
  VCC: vcc 8,2 5V
  R2: resistor 8,2 8,4 100k
  Q1: npn 10,6 2SC1815
  VCC: vcc 10,2 5V
  R3: resistor 10,2 10,4 220
  D1: led 10,4 10,5
  G3: ground 10,7
  M1: voltmeter 12,5 12,7 l=$\mathrm{CH1}$
  G4: ground 12,7
wires:
  - 5,4 -- 6,4
  - 6,4 -- 6,5
  - 8,4 |- Q1.B
  - 10,5 -- Q1.C
  - Q1.E -- 10,7
  - 10,5 -- 12,5
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
  CH1 は直流 2.1 V に振れが乗る。AD3 本体のピンの入力は DC 結合だけなので、直流は WaveForms の CH の **Offset** で打ち消す。
  Offset を −2.1 V にすると 2.1 V が画面の中央に来て、振れだけを細かい目盛で拡大して見られる。
  手順: Scope の CH1 の設定で Range を 200 mV/div、Offset を −2.1 V にする。
  CH2 の節点は約 0.2 V の直流に 16.5 mVpp が乗るので、Range を 5 mV/div、Offset を −0.2 V にする。
  直流の値は個体で少し違うので、波が中央からずれたら、テスターで読んだ直流の値に Offset を合わせ直す
  (0.5 V/div 以下の細かい目盛で Offset が動かせるのは ±2.5 V まで。この題の直流はその中に入る)

```breadboard
title: 図4 マイクを外し、W1 を 10kΩ と 100Ω の分圧で入れる
# AD の V+ (5 V) を下の + レール、GND を下の − レールへ入れ、29・30 列で上のレールへ渡す
board: half
parts:
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
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
Analog Discovery はブレッドボードの下に置き、線は下のレールと j 行に挿す。

- W1 (黄): `j3` へ。R<sub>S</sub> (10 kΩ、`i3`〜`i7`) を通って、入力の節点 (下のブロックの 7 列) へつながる
- 7 列には、上の 7 列への黄色の線 (`f7`)、R<sub>D</sub> (`h7`)、R<sub>S</sub> の右リード (`i7`)、CH2 の 2+ (青、`j7`) が並ぶ (穴ごとにピンは 1 本)
- CH1 の 1+ (橙): Q1 のコレクタ (13 列) の `j13`
- AD の V+ は下の + レールへ (赤)、GND・2−・1− は下の − レールへ (黒)。上下のレールは右端の 29・30 列でつながっている

WaveForms の Supplies で V+ を 5 V にしてから W1 を出す。

```scope
title: 図5 入力 (CH2) と出力 (CH1) — 1 kHz、入力は数 mV、出力は約 38 倍で反転
time: 200us/div
trigger: ch2 rising 0.2V
ch1: {wave: sine 1kHz 0.62Vpp phase 193deg offset 2.1V, range: 200mV/div, position: -10.5div}
ch2: {wave: sine 1kHz 16.5mVpp offset 0.2V, range: 5mV/div, position: -40div}
measure: [vpp, freq, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/04-mic.svg)

CH2 (節点) は約 16.5 mVpp、CH1 (コレクタ) は約 0.62 Vpp の 1 kHz の正弦波で、
利得 (出力の振幅 ÷ 入力の振幅) は約 38 倍 (hFE = 100・コレクタ電流 4.3 mA の計算値)。ほぼ反転していて、
CH1 が谷のとき CH2 は山になる (C1 と入力抵抗のせいで 13° ほどずれる)。
LED は 1 kHz では揺れが速すぎて、ほぼ点きっぱなしに見える。
コレクタの振れは約 0.31 V (振幅) で、下の表の手拍子の見積もり (約 0.2 V) と同じ桁になる。
W1 の振幅を下げると、出力もそれに比例して小さくなる。
画面の中央は Offset で打ち消した直流の高さで、Measurements の Avg に直流の 2.10 V (CH1)・200 mV (CH2) が出る。

## 計器の設定

計器は Analog Discovery 3 (AD3) を使う。電源 (Supplies の V+ = 5 V)、信号源 (Wavegen の W1)、オシロ (Scope の 1・2)
を 1 台で賄え、波形は 10 MHz 以下の音声帯域なので Scope で見える。消費電流は LED の約 4.3 mA、
分圧の約 2 mA、マイクのバイアス約 0.3 mA の計 7 mA 前後で、電源 1 系統の約 50 mA に収まり、ブレッドボードの 1 穴 200 mA の範囲にも入る。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、出力 ON |
| Wavegen W1 | Sine、1 kHz、振幅 1 V (2 Vpp)、オフセット 0 V |
| Scope CH1 (1+ をコレクタ、1− を GND) | 200 mV/div、Offset −2.1 V (直流を打ち消す)、時間軸 200 µs/div |
| Scope CH2 (2+ を節点、2− を GND) | 5 mV/div、Offset −0.2 V。トリガは CH2 の立ち上がり 0.2 V (波の中央) |

図5 が、この設定で見える波形。

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
| — | 信号発生器・電源・オシロ | Analog Discovery 3 (W1、V+ = 5 V、Scope の 1・2)。図2 の電源も V+ |

## 見るべき値

表の値は計算値。hFE = 100 と仮定した (2SC1815 は実物の hFE のばらつきが
大きいので、LED がずっと明るく点きっぱなしなら R2 を大きく、暗すぎるなら小さくする)。
直流の電圧はテスターの DC 電圧レンジで測り、交流は図5 のようにオシロ (Offset で直流を打ち消す) で見る。

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
