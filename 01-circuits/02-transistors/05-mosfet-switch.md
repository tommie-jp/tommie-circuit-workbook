---
book: circuits
chapter: 2
id: 2-5
title: MOSFET スイッチ (2N7000、ロジックレベル)
tier: 50
source: 自作
era: 今
board: BB
---

# 2-5 MOSFET スイッチ (2N7000、ロジックレベル)

MOSFET はゲートに電圧をかけるだけでオン・オフするスイッチ (ベース電流が
要らない)。2N7000 は**ロジックレベル**の MOSFET で、5V (3.3V でも) の
デジタル信号で十分にオンにできる。マイコンの GPIO で直接駆動できるのが利点。

## 回路図

```circuit
title: 図1 2N7000 でスイッチする (CH2 でゲート、CH1 でドレインを見る)
parts:
  VCC: vcc a4 5V
  R1: resistor a7 c7 330
  D1: led c7 d7
  Q1: nmos-e d7i0
  SW: switch a4 c4
  RG: resistor c4 e4 220
  RPD: resistor e4 g4 100k
  G2: ground g4
  G3: ground f7
  M2: voltmeter e2 g2 l=$\mathrm{CH2}$
  G4: ground g2
  M1: voltmeter d10 f10 l=$\mathrm{CH1}$
  G5: ground f10
wires:
  - a4 -- a7
  - e2 -- e4
  - d7 -- d10
  - d7 -- Q1.D
  - e4 |- Q1.G
  - Q1.S -- f7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/05-mosfet-switch.svg)

+5V は Analog Discovery の電源出力 V+ (WaveForms の Supplies で 5 V にして入れる)。
LED の 9 mA ほどなので V+ で足りる。CH2 はゲート、CH1 はドレインの電圧を GND から測る。

`SW` を閉じるとゲートに 5V がかかり、MOSFET がオンになって LED が点く。
`RPD` (100kΩ、プルダウン) が `SW` を開けたときにゲートを確実に 0V へ落とす。
`RG` (220Ω) はゲートを充電する瞬間の電流を抑える保護抵抗。

- 2N7000 のしきい値電圧 V<sub>GS(th)</sub> は 1〜3V (データシートの規格) で、
  5V を掛ければ確実にオン (オーバードライブが取れている)
- オン抵抗 R<sub>DS(on)</sub> は V<sub>GS</sub>=5V で数Ω程度 (十分小さい)
- LED の電流: I = (5 − V<sub>F</sub>) / R1 ≈ (5 − 2.0) / 330 ≈ **9.1 mA**
  (R<sub>DS(on)</sub> による電圧降下 数十mV は無視できるほど小さい)
- ゲートに流れる電流は**ほぼ 0** (MOSFET は電圧駆動)。`RG` があっても
  定常時の電圧降下はほぼ無い

## 実体配線図

```breadboard
title: 図2 2N7000 でスイッチする
# 5V は AD の V+ から上の + レールへ。下の − レールは 28 列で上の − レールとつなぐ
board: half
parts:
  R1: resistor b5 b8 330
  D1: led c8(A) c9(K) red
  Q1: transistor f13(S) f14(G) f15(D) 2N7000
  RG: resistor a18 a21 220
  RPD: resistor b21 b24 100k
  SW: button @ e17
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-, 2-, 2+]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a9 orange
  - AD.1- -- -t10 black
  - AD.2- -- -t19 black
  - AD.2+ -- a22 blue
  - e22 -- e21 blue
  - +t5 -- a5 red
  - d9 -- g15 orange
  - +t17 -- a17 red
  - g17 -- c18 orange
  - c21 -- g14 yellow
  - a24 -- -t24 black
  - g13 -- -b13 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/05-mosfet-switch.svg)

5V は Analog Discovery の V+ (赤) から上の + レールの `+t1` へ、GND (黒) は `-t2` へ入れる。

- **ドレイン (列 9)**: LED のカソードと同じ列。CH1 の 1+ (橙) を空いている `a9` に挿す
- **ゲート (列 21)**: CH2 の 2+ (青) は `a22` に挿し、`e22`–`e21` の青線でゲートの列へ渡す
- 1− と 2− (黒) は上の − レール (`-t10` `-t19`) へ

2N7000 は**平らな面を見て左から S・G・D** (2SC1815 とは並びが違うので注意)。
`RG` と `RPD` の分圧点 (列 21) がゲート。ソース (`f13`、下の − レール) と
`RPD` の下端 (上の − レール) が同じ GND になるよう、28 列の黒線で上下の − レールを
つなぐ。

## オシロで見る

CH2 (ゲート) の立ち上がり 2.5 V でトリガを掛け (Normal)、SW を押す。押した瞬間の 1 回を
画面に止める。ゲートは RG (220Ω) と 2N7000 の入力容量 (数十 pF) で 10 ns ほどで上がり、
V<sub>GS</sub> がしきい値を越えたところでドレインが落ちる。

```scope
title: 図3 SW を押した瞬間 — ゲート (CH2) が上がるとドレイン (CH1) が落ちる
time: 20ns/div
trigger: ch2 rising 2.5V
ch1: {wave: "= 3.5V - 3.47V * step(t + 3ns) * (1 - exp(-(t + 3ns) / 8ns))", range: 1V/div, position: -3div}
ch2: {wave: "= 5V * step(t + 10ns) * (1 - exp(-(t + 10ns) / 15ns))", range: 1V/div, position: -3div}
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/05-mosfet-switch.svg)

- CH2 は 0 V から約 5 V へ上がる (RG の電圧降下はほぼ 0)
- CH1 は押す前が約 3.5 V。オフの MOSFET と CH1 の入力抵抗 (1 MΩ) で LED に µA ほどしか
  流れず、LED の両端に 1.5 V ほど残るため 5 V にはならない。押すと約 0.03 V (数十 mV) まで落ちる
- タクトスイッチはチャタリング (接点の跳ね) で何度か開け閉めするが、トリガは最初の立ち上がりで
  止まるので、画面にはその 1 回が映る。時間軸を 1 ms/div ほどに広げると跳ねが見える

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 330 Ω |
| RG | 抵抗 (1/4 W) | 220 Ω |
| RPD | 抵抗 (1/4 W) | 100 kΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| Q1 | ロジックレベル N-MOSFET | 2N7000 |
| SW | タクトスイッチ | — |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| SW を押していないときのゲート電圧 (CH2) | 0 V | RPD がゲートを GND に落としている |
| SW を押していないときのドレイン電圧 (CH1) | 約 3.5 V | LED に µA しか流れず V<sub>F</sub> が 1.5 V ほど残る |
| SW を押したときのゲート電圧 (CH2) | 約 5 V | RG の電圧降下はほぼ 0 (ゲート電流がないため) |
| SW を押したときの LED の電流 | 約 9.1 mA | 計算値どおり。BJT のスイッチ (2-1) とほぼ同じ電流 |
| SW を押したときの Q1 の D-S 間電圧 (CH1) | 数十 mV 程度 (約 0.03 V) | R<sub>DS(on)</sub> が小さいので BJT の飽和電圧 (0.2V) よりさらに小さい |

## 出典

自作。
