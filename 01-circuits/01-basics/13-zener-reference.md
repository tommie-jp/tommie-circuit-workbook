---
book: circuits
chapter: 1
id: 1-13
title: ツェナーで基準電圧
tier: 200
source: 自作
board: BB
---

# 1-13 ツェナーで基準電圧

1-4 で見たとおり、ダイオードは逆向きには電流を流さない。ところが逆向きの電圧を上げていくと、
ある電圧で急に電流が流れ始め、その先は電流が増えても電圧がほとんど変わらない。この電圧を**ツェナー電圧** V<sub>Z</sub> といい、
これをわざと使うように作ったのが**ツェナーダイオード**。抵抗 1 本と組めば、入力の電圧が揺れても
ほぼ一定の**基準電圧**が取り出せる (シャント形の定電圧回路)。5-2 のシリーズレギュレータも、3 端子レギュレータ (5-3) の中も、
基準はこの「決まった電圧で流れ始める」性質から作る。

この題では 5.1 V のツェナーに抵抗 R<sub>1</sub> で電流を流し、次の 3 つを測る。

1. **入力が揺れても出力はほとんど揺れない**。揺れの比は R<sub>1</sub> とツェナーの**動作抵抗** r<sub>Z</sub> (電流の変化に対する電圧の変化 ΔV / ΔI) の分圧で決まる
2. **負荷に電流を取られるとツェナーの電流が減り**、電流が少ないほど r<sub>Z</sub> が大きくなって揺れが増える
3. ツェナーに流れる電流がほぼ 0 になると、もう基準にならない (ただの分圧回路に戻る)

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ツェナーのシャント形定電圧。電池のマイナスを W1 で揺らして入力に揺れを足す
parts:
  W1: sine 2,6 2,8 l=$\mathrm{W1}$
  B1: battery 2,4 2,6 9
  G1: ground 2,8
  M2: voltmeter 4,4 4,8 l=$\mathrm{CH2}$
  G2: ground 4,8
  R1: resistor 4,4 6,4 680
  DZ: zener 7,6 7,4 5V1
  G3: ground 7,6
  RL: resistor 9,4 9,6 2.2k
  G4: ground 9,6
  M1: voltmeter 11,4 11,6 l=$\mathrm{CH1}$
  G5: ground 11,6
wires:
  - 2,4 -- 4,4
  - 6,4 -- 7,4
  - 7,4 -- 9,4
  - 9,4 -- 11,4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/13-zener-reference.svg)

入力は 9 V の電池 (006P) で、その − を Analog Discovery 3 (AD3) の Wavegen の W1 に載せる。W1 を 100 Hz・1 Vpp の正弦にすると、
入力は 8.5〜9.5 V で揺れる (整流した電源のリップルの代わり)。`DZ` はカソード (帯の側) を上にした逆向き。CH2 で入力を、CH1 で出力を見る。

- **ツェナーの電流**: I<sub>Z</sub> = (9 V − V<sub>Z</sub>) / 680 Ω − (負荷の電流)。負荷なしなら (9 − 4.85) / 680 ≈ **6.1 mA**
- **V<sub>Z</sub>**: 1N5231B は 20 mA で 5.1 V (±5 %) と決めてある。6 mA ではそれより低く、約 **4.85 V** (計算値。5-2 と同じ見積もり)
- **揺れの比**: 出力の揺れ / 入力の揺れ ≈ r<sub>Z</sub> / (R<sub>1</sub> + r<sub>Z</sub>)。r<sub>Z</sub> ≈ 20 Ω なら 20 / 700 ≈ 1/35 で、
  入力の 1 Vpp が出力では約 **29 mVpp** になる
- **負荷をつなぐと**: 2.2 kΩ は 4.8 V / 2.2 kΩ ≈ 2.2 mA を取るので I<sub>Z</sub> は約 4 mA、1 kΩ なら約 1.5 mA まで減る
- **損失**: DZ は 4.85 V × 6.1 mA ≈ 30 mW (0.5 W 品の 1/16)、R<sub>1</sub> は (4.15 V)² / 680 Ω ≈ 25 mW (1/4 W の 1/10)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 電池の − を W1 へ。R1 から先が定電圧の出力
board: half
parts:
  B1: battery c6(+) c3(-) 9V
  R1: resistor b6 b11 680
  DZ: zener -t11 a11 1N5231B cap=left
  RL: resistor c11 c16 2.2k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, W1, 2+, 2-, 1+, 1-]
wires:
  - AD.GND -- -t1 black
  - AD.W1 -- a3 yellow
  - AD.2+ -- a6 blue
  - AD.2- -- -t8 black
  - e11 -- e14 orange
  - AD.1+ -- a14 orange
  - AD.1- -- -t18 black
  - a16 -- -t16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/13-zener-reference.svg)

- **列 3**: W1 (黄) と電池の − (電池のスナップの黒い線)。**列 6**: 電池の + と CH2 の 2+。電池の + を赤い線にしない (+ レールに入れないので、電源の印の赤は使わない)
- **列 11 が出力**: `R1` (680 Ω) が列 6 から列 11 へ。`DZ` はアノードを上の − レールに、カソード (帯) を列 11 に縦に挿す
- 負荷 `RL` は列 11 から列 16、列 16 を − レールへ。抜けば負荷なし。CH1 の 1+ は列 14 (列 11 から橙の線で渡す)
- 回路の GND (上の − レール) は AD3 の GND。電池はどこにも GND がなく、W1 の上に浮いている

電池から W1 へ流れ込む電流は 6.3 mA ほどで、W1 の約 10 mA に収まる。

## 計器の設定

計器は AD3 の Wavegen と Scope。入力の揺れが出力でどれだけ小さくなるかを、時間の波形で比べる。

| 項目 | 値 |
| --- | --- |
| Wavegen W1 | 正弦波、100 Hz、振幅 0.5 V (1 Vpp)、オフセット 0 V |
| Scope CH1 (出力) | 10 mV/div、Offset −4.85 V (出力の直流ぶんを差し引いて、揺れだけを画面の中央へ) |
| Scope CH2 (入力) | 200 mV/div、Offset −9 V |
| 時間 | 5 ms/div (100 Hz の 5 周期) |
| トリガ | CH2 の立ち上がり、揺れの中心 (Offset を差し引いた 0 V) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力 (CH2) の 1 Vpp が出力 (CH1) では 29 mVpp — CH1 は 20 倍に拡大
time: 5ms/div
trigger: ch2 rising 0V
ch1: {wave: sine 100Hz 29mVpp, range: 10mV/div}
ch2: {wave: sine 100Hz 1Vpp, range: 200mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/13-zener-reference.svg)

図3 は負荷なしのとき。どちらの ch も Offset で直流ぶん (4.85 V と 9 V) を差し引いてあるので、画面の 0 は揺れの中心。
CH1 は CH2 の 20 倍に拡大してあり、同じ尺度なら出力はほぼ平らな線になる。出力の揺れは入力と同じ向き (同じ位相) で揺れる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| DZ | ツェナーダイオード (0.5 W) | 5.1 V (1N5231B など。20 mA で 5.1 V の品) |
| R1 | 抵抗 (1/4 W) | 680 Ω |
| RL | 抵抗 (1/4 W) | 2.2 kΩ。ほかに 1 kΩ (負荷を重くする) |
| B1 | 電源 | 9 V の電池 (006P) とスナップ — 5.1 V のツェナーを働かせるには、入力が 5.1 V より十分高い要があるため。5 V では電流が流れない |
| — | 揺れ | AD3 の W1 (100 Hz、1 Vpp) |

## 見るべき値

直流の値は W1 を止めて (0 V にして) テスターで、揺れは図3 の設定の CH1 で読む。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| 出力の電圧 (負荷なし) | 約 4.85 V | 20 mA で 5.1 V の品も、6 mA では 0.25 V ほど低い |
| R1 の両端の電圧 → I<sub>Z</sub> | 約 4.15 V → 6.1 mA | 負荷が無いと R1 の電流が全部ツェナーへ |
| 揺れ (負荷なし) | 約 29 mVpp | 入力の 1 Vpp の約 1/35。r<sub>Z</sub> ≈ 20 Ω |
| 出力・揺れ (RL 2.2 kΩ) | 約 4.80 V・32 mVpp | I<sub>Z</sub> が 4 mA に減って r<sub>Z</sub> が増える |
| 出力・揺れ (RL 1 kΩ) | 約 4.74 V・46 mVpp | I<sub>Z</sub> は 1.5 mA。基準として使える限界に近い |

**電池を替えて入力の電圧そのものを変える**: 6 V (単 3 電池 4 本) にすると、負荷なしでは出力は約 4.75 V で 0.1 V しか下がらない。
ところが RL 1 kΩ では 3.57 V まで落ちる。これは 6 V × 1 k / (680 + 1 k) の分圧そのもので、ツェナーに電流が来ていない。
**R<sub>1</sub> は、入力が一番低く負荷が一番重いときにも I<sub>Z</sub> が 1 mA 以上残るように選ぶ**のが、シャント形の決め方。

**温度で動く**: データシートの温度係数は 1N5231 で +0.03 %/K (1 °C で約 +1.5 mV)。3.3 V 品 (1N5226) は −0.07 %/K で向きが逆になり、
5〜6 V あたりで 0 に近づく。DZ を指でつまんで温めると、CH1 の平均がわずかに上がるのが見える (10 mV/div で読む)。

## LTspice での確かめ

`sim/13-zener-reference.cir` で、図1 の入力に 100 Hz・1 Vpp を足した .tran (20〜60 ms) を回し、負荷を 3 通りにして出力の平均と揺れを読んだ。
入力の電圧を 4〜12 V に振る .dc は `sim/13-zener-reference-dc.cir`。DZ は 5-2 と同じ「20 mA で 5.1 V、動作抵抗 17 Ω」に合わせた模型 (仮定。実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力・I<sub>Z</sub> (負荷なし) | 約 4.85 V・6.1 mA | 4.85 V・6.11 mA | 合う |
| 揺れ (負荷なし) | 約 29 mVpp | 28.9 mVpp | 合う |
| 出力・揺れ・I<sub>Z</sub> (2.2 kΩ) | 4.80 V・32 mVpp・4 mA | 4.80 V・31.8 mVpp・3.99 mA | 合う |
| 出力・揺れ・I<sub>Z</sub> (1 kΩ) | 4.74 V・46 mVpp・1.5 mA | 4.74 V・46.2 mVpp・1.53 mA | 合う |
| 入力 6 V (負荷なし / 1 kΩ) | 4.75 V / 3.57 V | 4.75 V / 3.57 V | 合う |
| 入力 9 → 10 V の出力の変化 (負荷なし) | 小さい | +28 mV (4.847 → 4.875 V) | 合う (揺れの比 1/35 と同じ) |

実物の V<sub>Z</sub> は ±5 % (4.85〜5.36 V、20 mA で) ばらつくので、組んだら出力を測り、表の値をその実測から読み替える。

## 出典

自作。

参考: [ツェナーダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/ツェナーダイオード)、[1N5221〜1N5267 データシート (Vishay, 85588)](https://www.vishay.com/docs/85588/1n5221.pdf)
