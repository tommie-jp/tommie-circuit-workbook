---
book: circuits
chapter: 13
id: 13-2
title: 定電流 (CC) で使う — 抵抗なしで LED を光らせる
tier: 100
source: 自作
board: BB
---

# 13-2 定電流 (CC) で使う — 抵抗なしで LED を光らせる

13-1 は電流制限を「もしもの保険」として使った。この題では逆に、
電流制限そのものに LED の電流を決めさせる。電源が電圧を下げてでも、制限値の電流を
流し続ける CC (Constant Current、定電流) の動きを、抵抗なしの LED で確かめる。

## 説明

LED を抵抗なしで定電圧の電源に直につなぐと、LED の順方向電圧 V<sub>F</sub> を
わずかでも超えた電圧で電流が急に増えて、LED が壊れる。1-1 で抵抗が
電流を決めていたのはこのため。ここでは抵抗の代わりに**電源の電流制限**
に電流を決めさせる。

手順は 13-1 と同じ順を守る。

1. 出力オフ
2. 電圧つまみを **5.0 V** に (LED の V<sub>F</sub> より十分高い値。CC に入る限り
   この値どおりには出ない)
3. 電流つまみで電流制限を **10 mA** に合わせる (LED の定格 20 mA 以下)
4. LED を出力端子に直につなぐ
5. 出力オン

## 回路図

```circuit
title: 図1 CC で LED を光らせる (電流制限は電源、RS は測るだけ)
parts:
  U1:
    type: device
    at: 2,2
    label: PSU
    pins: ["+", "GND", "-"]
    turn: mirror
  D1: led 6,2 6,4
  RS: resistor 6,4 6,6 10
  M1: voltmeter 9,4 9,6 l=$\mathrm{CH1}$
  M2: voltmeter 12,2 12,6 l=$\mathrm{CH2}$
  G1: ground 6,6
  G2: ground 3,3
wires:
  - U1.+ -| 6,2
  - U1.- -| 3,3
  - 6,4 -- 9,4
  - 6,6 -- 9,6 -- 12,6
  - 6,2 -- 12,2
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/circuit/02-cc-mode.svg)

- RS (10 Ω) は電流を電圧に変えて見るためのシャント抵抗。10 mA が流れると両端に
  10 Ω × 10 mA = 0.1 V が出る。CH1 がその電圧 (= 電流)、CH2 が電源の出力電圧
- 電圧設定 5.0 V は LED の V<sub>F</sub> (約 2.0 V) より高いので、抵抗が
  無ければ CV のままでは電流が流れすぎる
- 電流制限を 10 mA にすると、電源は電圧を下げてでも電流を 10 mA に
  抑える。出力電圧は LED の V<sub>F</sub> まで自動で下がり、
  LED の分が約 2.0 V、RS の分が 0.1 V で、出力は約 2.1 V になる (計算値、個体差あり)
- 前面の表示は CC が点灯したまま。13-1 の CV とちょうど逆

電圧つまみを 5.0 V から 8.0 V に上げても、CC が効いている限り出力電圧は
変わらず 2.1 V 前後、電流も 10 mA のまま。電圧つまみは「これより高くは出さない」
という上限を決めているだけで、実際の電圧は電流制限と LED の V<sub>F</sub> で決まる。
(以下、図1 の RS の 0.1 V を含めて出力電圧を 2.1 V と書く。)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに LED と RS、電源装置と AD3 をつなぐ
board: half
parts:
  PSU:
    type: device
    at: top
    label: PSU
    pins: ["+", "-", "GND"]
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, 2+, 1-, 2-, GND]
  D1: led c10(A) c11(K) red
  RS: resistor e11 e15 10
wires:
  - PSU.+ -- +t3 red
  - +t10 -- a10 red
  - a15 -- -t15 black
  - PSU.- -- -t9 black
  - AD.1+ -- a11 orange
  - AD.2+ -- +t13 gray
  - AD.1- -- -t17 black
  - AD.2- -- -t19 black
  - AD.GND -- -t21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/breadboard/02-cc-mode.svg)

- LED のアノード (10 列) を赤いレールへ、カソード (11 列) から RS (10 Ω) を通して青いレールへ。AD3 の 1+ は 11 列 (RS の上端)、2+ は赤いレール、1−・2−・GND は青いレール。
  LED に直列の抵抗を挟まないのが 13-1 との違い (RS は電流を見るための 10 Ω で、電流を決めるものではない)
- 抵抗が無い分、電流を決めているのが電源の電流制限だけになる。電流制限を
  誤って大きい値 (LED の定格を超える値) にしたまま出力を入れると LED が
  壊れる。手順どおり、電流制限は出力を入れる前に決める
- 電源によっては、出力を入れた瞬間や CV から CC へ切り替わる瞬間に、出力のコンデンサの電荷で
  電流制限を超える電流が一瞬流れる。気になるなら電圧つまみを 3 V ほどまで下げておく (目安)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V (10 mA 時) |
| RS | 抵抗 (1/4 W) | 10 Ω (電流を電圧に変えるシャント) |
| — | Analog Discovery 3 | Scope の 1 ch (RS の電圧)・2 ch (出力電圧) |
| — | 安定化電源 | CV/CC 機能つき (電圧・電流とも可変) |

## 計器の設定

この題の主役は電源装置なので、電源は AD3 の Supplies ではなく安定化電源 (Supplies は 250 mW までで、電流制限の実験に向かない)。
AD3 は Scope で電源の出力を見るだけに使う。出力は直流なので、波形は出力を入れた瞬間の立ち上がりで見る。
ブレッドボードを流れる電流は 10 mA で、ブレッドボードの範囲 (1 穴 200 mA) に収まる。

| 項目 | 値 |
| --- | --- |
| 電源の電圧設定 | 5.0 V (CC に入るので実際には出ない) |
| 電源の電流制限 | 10 mA |
| 出力を入れる順番 | 13-1 と同じ (電圧・電流制限を決めてから接続し、最後にオン) |

WaveForms の Scope で、1 ch (RS の電圧) を 20 mV/div、2 ch (出力電圧) を 0.5 V/div、時間軸を 1 ms/div にする。
トリガは単発 (Single) で 2 ch の立ち上がり 1 V に合わせ、待たせてから電源の出力をオンにする。
1−・2− は電源の − (GND) につなぐ。電源の出力は接地から浮いているので、GND を − に挟んでよい。

```scope
title: 図3 出力オンで 2 ch が約 2.1 V、1 ch が 100 mV に落ち着く
time: 1ms/div
trigger: ch2 rising 1V at -5div
ch1: {wave: "= 100mV * step(t) * (1 - exp(-t / 300us))", range: 20mV/div, position: -3div}
ch2: {wave: "= 2.1V * step(t) * (1 - exp(-t / 300us))", range: 500mV/div, position: -3div}
cursors: [4ms]
measure: [vmax]
notes:
  - text ch2 4ms 2.1V: 出力は 5 V ではなく約 2.1 V
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/scope/02-cc-mode.svg)

図3 は理想 (計算) の画面で、立ち上がりは時定数 0.3 ms の目安の形に描いた。実際の立ち上がりは電源によって違う。
見るのは立ち上がりの速さではなく、落ち着いた値 (2 ch が約 2.1 V、1 ch が 100 mV = 10 mA) と、設定の 5.0 V にならないこと。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 電源の出力電流表示 | 10.0 mA (設定どおり) | 抵抗が無くても電源が電流を決める |
| 電源の出力電圧表示 | 約 2.1 V (計算値、5.0 V の設定より下がる。LED の約 2.0 V + RS の 0.1 V)。LED の両端をテスターで測ると約 2.0 V | CC に入ると出力電圧は負荷 (ここでは LED) が決める |
| 図3 の Scope の 2 ch・1 ch | 約 2.1 V・100 mV (= 10 mA、RS 10 Ω) に落ち着く | 5.0 V の設定でも出力は 2.1 V。電流は制限の 10 mA |
| 前面の CV / CC 表示 | CC が点灯 | 13-1 (CV) と逆の状態 |
| 電圧つまみを 8.0 V に上げたとき | 出力電流・出力電圧とも変わらない | CC の間、電圧つまみは上限を決めるだけ |

2-9 の JFET の定電流源も、電源電圧を変えても電流がほぼ変わらない例だった。
そちらは部品 1 つで作る定電流、こちらは電源自身の CC 機能で作る定電流という違い。

## 出典

自作。
