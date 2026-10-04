---
book: circuits
chapter: 13
id: 13-1
title: 定電圧 (CV) で使う — 電圧を決めて電流制限を掛ける
tier: 100
source: 自作
board: BB
---

# 13-1 定電圧 (CV) で使う — 電圧を決めて電流制限を掛ける

実験用の安定化電源 (ベンチ電源、ラボ電源) を使うときの基本の手順を、
1-1 と同じ LED 回路で確かめる。安定化電源には、電圧を一定に保つ CV (Constant Voltage、
定電圧) と、電流を一定に保つ CC (Constant Current、定電流) の 2 つの動き方がある (0-6)。
この題では CV での正しい使い方と、電流制限を「保険」として掛ける手順を追う。

## 説明

前面には主に次がある。

- **電圧つまみ (V)** と **電流つまみ (A)**、それぞれの表示 (デジタルなら数字、
  アナログなら針)
- **出力オン/オフ** のスイッチ
- **CV / CC の表示 (ランプ)**: CV で動いているときは CV が、CC に入っている
  ときは CC が点く

つなぐ手順は決まっている。**出力を切ったまま**電圧と電流制限を決め、
それから回路をつなぎ、最後に出力を入れる。

1. 出力オフを確かめる
2. 電圧つまみで **5.0 V** に合わせる
3. 電流つまみで電流制限を **20 mA** に合わせる (回路に流れるはずの電流
   9.1 mA (下の計算) に余裕を見た上限)
4. 電源の出力端子に回路をつなぐ
5. 出力オンにする

この順を守るのは、先に出力を入れてから配線すると、配線中に端子が短絡 (+ と − が
直接触れること) したとき、そのまま大きな電流が流れるため。電流制限を低めに決めてから
つなげば、万一の短絡でも制限値までしか流れない (0-6 で見た保険と同じ)。

## 回路図

```circuit
title: 図1 CV で LED を点ける (CH1・CH2 は Scope の当て所)
parts:
  U1:
    type: device
    at: b2
    label: PSU
    pins: ["+", "GND", "-"]
    turn: mirror
  R1: resistor b6 d6 330
  D1: led d6 f6
  M1: voltmeter d9 f9 l=$\mathrm{CH1}$
  M2: voltmeter b12 f12 l=$\mathrm{CH2}$
  G1: ground f6
  G2: ground c3
wires:
  - U1.+ -| b6
  - U1.- -| c3
  - d6 -- d9
  - f6 -- f9 -- f12
  - b6 -- b12
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/circuit/01-cv-mode.svg)

図1 の U1 が安定化電源。`GND` (シャーシ接地。電源の筐体とコンセントのアースにつながる
端子) の足はここでは使わない。回路の GND は電源の `-` 端子そのもの。

- 電圧 5.0 V、電流制限 20 mA に設定
- LED (順方向電圧 V<sub>F</sub> ≈ 2.0 V) と R1 (330 Ω) に流れる電流は
  I = (5.0 V − 2.0 V) / 330 Ω ≈ 9.1 mA (計算値)
- 制限値 20 mA は必要な 9.1 mA より十分大きいので、電源はずっと CV で
  動く。前面の表示は CV が点いたまま

## 実体配線図

```breadboard
title: 図2 板に R1 と LED、電源装置と AD3 をつなぐ
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
  R1: resistor b5 b10 330
  D1: led c10(A) c11(K) red
wires:
  - PSU.+ -- +t3 red
  - +t5 -- a5 red
  - a11 -- -t11 black
  - PSU.- -- -t9 black
  - AD.1+ -- a10 orange
  - AD.2+ -- +t13 gray
  - AD.1- -- -t17 black
  - AD.2- -- -t19 black
  - AD.GND -- -t21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/breadboard/01-cv-mode.svg)

- 電源の `+` を上の赤いレールへ、`-` を上の青いレールへ。抵抗と LED は
  1-1 と同じ列 (10 列) でつながる
- `GND` 端子は配線しない (前面の説明のとおり、シャーシ接地は今回使わない)
- AD3 の 1+ は R1 と LED の間 (10 列。LED の両端の電圧)、2+ は赤いレール (電源の出力)。
  1−・2−・GND は青いレール (電源の −)。電源の出力は接地から浮いているので、GND を − に挟んでよい
- 板を流れる電流は約 9.1 mA で、板の範囲 (1 穴 200 mA) に収まる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| — | Analog Discovery 3 | Scope の 1 ch (LED の電圧)・2 ch (出力電圧) |
| — | 安定化電源 | CV/CC 機能つき (電圧・電流とも可変) |

## 計器の設定

この題の主役は電源装置なので、電源は AD3 の Supplies ではなく安定化電源 (Supplies は 250 mW までで、電流制限の実験に向かない)。
AD3 は Scope で電源の出力を見るだけに使う。出力は直流なので、波形は出力を入れた瞬間の立ち上がりで見る。

| 項目 | 値 |
| --- | --- |
| 電源の電圧設定 | 5.0 V |
| 電源の電流制限 | 20 mA |
| 出力を入れる順番 | 電圧・電流制限を決めてから、回路をつないで、最後にオン |

WaveForms の Scope で、1 ch (LED の電圧) と 2 ch (出力電圧) をどちらも 1 V/div、時間軸を 1 ms/div にする。
トリガは単発 (Single) で 2 ch の立ち上がり 1 V に合わせ、待たせてから電源の出力をオンにする。
1−・2− は電源の − (GND) につなぐ。

```scope
title: 図3 出力オンで 2 ch が 5.0 V、1 ch (LED) が約 2.0 V に落ち着く
time: 1ms/div
trigger: ch2 rising 1V at -5div
ch1: {wave: "= 2.0V * step(t) * (1 - exp(-t / 300us))", range: 1V/div, position: -3div}
ch2: {wave: "= 5.0V * step(t) * (1 - exp(-t / 300us))", range: 1V/div, position: -3div}
cursors: [4ms]
measure: [vmax]
notes:
  - text ch2 4ms 5V: 出力は設定どおり 5.0 V (CV のまま)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/scope/01-cv-mode.svg)

図3 は理想 (計算) の画面で、立ち上がりは時定数 0.3 ms の目安の形に描いた。実際の立ち上がりは電源によって違う。
見るのは立ち上がりの速さではなく、落ち着いた値 (2 ch が 5.0 V、1 ch が約 2.0 V) と、2 ch が設定の 5.0 V のまま下がらないこと。
R1 の両端の電圧は 2 ch − 1 ch = 5.0 V − 2.0 V = 3.0 V。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 電源の出力電圧表示 | 5.0 V | 制限電流 (20 mA) より必要な電流 (9.1 mA) が小さいので CV のまま |
| 前面の CV / CC 表示 | CV が点灯 | CC には入っていない |
| 図3 の Scope の 2 ch・1 ch | 5.0 V・約 2.0 V に落ち着く。2 ch が 5.0 V のまま下がらない | 設定どおりの電圧が出る。CV のまま |
| R1 の両端の電圧 (テスターの直流電圧レンジ) | 約 3.0 V | ÷ 330 Ω で電流 (約 9.1 mA)。1-1 と同じ値 |
| 電流制限を 5 mA まで下げたとき | 表示が CC に変わり、出力電圧が約 3.6 V (330 Ω × 5 mA + V<sub>F</sub> 約 1.9 V、計算値) に下がる | 13-2・13-3 で CC の中身を詳しく見る |

## 出典

自作。
