---
book: analog-discovery
chapter: 0
id: 0-2
title: 入力範囲 ±25 V と電源の限界 — 電流は直列抵抗で決める
tier: 50
source: 自作
board: BB
---

# 0-2 入力範囲 ±25 V と電源の限界 — 電流は直列抵抗で決める

Analog Discovery 3 (AD3) を壊さないための 2 つの上限を確かめる。**入力**
(オシロの 1+ / 1- など) は GND に対して ±25 V まで (連続で耐えるのは ±50 V DC または
±30 V RMS の過電圧保護の内側)。**電源**
(Supplies) は、USB だけで給電するときは AD3 全体で 5.5 W までが推奨で、
AD3 本体が最大約 3.5 W を使うので、Supplies に回せるのは 2 系統あわせて約 2 W
(5.5 W − 3.5 W の引き算で出した目安)。別売りの 5 V の外部電源 (3.1 A 以上を推奨) を
つなぐと、1 系統あたり最大 800 mA・2.4 W まで出せる。

Supplies の画面には Master Enable・Positive Supply／Negative Supply の
Enable・出力電圧・Tracking はあるが、**mA 単位で電流を決める Current Limit
という設定項目は無い**。設定できるのは、AD3 全体の電力の上限 (Max Power) と
温度の上限で、これは AD3 の内部部品を守るための値である。mA 単位の
制限ではなく、LED の定格 (20 mA) よりずっと大きい電流まで流れてしまうので、
**LED を守る役には立たない**。上限が働く前に LED が壊れる。したがって
LED の電流は、昔からの標準的な方法である**直列抵抗**で決める (回路の
教科書の 1-1 と同じ考え方)。実機で電圧と抵抗を組み合わせて電流を確かめる
詳しい手順は 1-8 で扱う。

## 回路図

```circuit
title: 図1 抵抗を直列に入れて LED を V+ につなぐ
parts:
  V1: vsource a1 c1 5
  R1: resistor a1 a3 330
  D1: led a3 a5 v=VF
  G1: ground c1
wires:
  - a5 -- c1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/02-input-range-power-limits.svg)

V+ (Supplies、5 V) → R1 (330 Ω) → LED → GND。抵抗を入れずに LED を V+ に
直結すると、LED の順方向抵抗はごく小さいので大電流が流れ、LED か AD3 自体を
壊す恐れがある。**これは実機では試さない**。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで V+ から 330 Ω と LED を GND へ
board: half
parts:
  R1: resistor c5 c10 330
  D1: led d10(A) d14(K) red
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND]
wires:
  - AD.V+ -- a5 red
  - AD.GND -- -t3 black
  - a14 -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/breadboard/02-input-range-power-limits.svg)

V+ は 5 列に入れ、R1 (330 Ω)・LED の順に 10 列でつなぐ。LED はピンの長い方 (アノード) を 10 列に、短い方 (カソード) を 14 列に挿し、14 列から GND のレールへ戻す。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |

この題はオシロの図を付けない — 時間で変わらない直流の電圧・電流だけを見る題で、電圧計の読み値で足りる。

## 見るべき値

LED の V<sub>F</sub> ≈ 2.0 V と仮定。電流 = (V+ − V<sub>F</sub>) ÷ 330 Ω。

| 測る所 | 期待する値（計算値） | 分かること |
| --- | --- | --- |
| LED の順方向電圧 | 約 2.0 V (仮定) | 電流が変わってもほぼ一定の値 |
| LED に流れる電流 | 約 **9.1 mA**（= (5 − 2.0) / 330） | LED の定格 (20 mA 前後) に対して十分小さく、余裕がある |
| V+ が使う電力 | 約 45.5 mW（= 5 V × 9.1 mA） | Supplies に回せる電力 (USB 給電で 2 系統あわせて約 2 W の目安、外部給電で 1 系統 2.4 W) に対して十分小さい |
| ±25 V の入力範囲との比較 | 今回の回路は最大 5 V | オシロの入力レンジ (±25 V) に対して十分小さく、壊れる心配は無い |

直列抵抗を変えたときの電流と、V+ が使う電力を計算で描くと次のようになる
(V+ = 5 V、V<sub>F</sub> = 2.0 V)。

```graph
title: 図3 330 Ω なら 9.1 mA・45.5 mW — 抵抗を小さくするほど電流が増える
x: 直列抵抗 Ω log 100..10k
y:
  - 電流 mA 0..30
  - 電力 mW 0..150
lines:
  LED の電流 mA: (5-2.0)/x*1000
  V+ の電力 mW: 5*(5-2.0)/x*1000
notes:
  - mark 330
  - level 20mA
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/graph/02-input-range-power-limits.svg)

分かること:

- 抵抗を 150 Ω まで小さくすると定格の 20 mA に届く。抵抗は電流を決める部品そのもの
- 電力は 100 Ω でも 150 mW で、Supplies の上限 (USB 給電で約 2 W の目安) よりずっと小さい。先に超えるのは LED の定格 (20 mA) のほう

Supplies に Current Limit という設定が無い以上、**抵抗を省いてよい場面は
無い**。同じ抵抗のまま V+ の電圧を変えると電流が変わることは 1-8 で
確かめる。

## 出典

自作。Supplies の操作 (Master Enable・Positive Supply・Negative Supply・
Voltage・Tracking) は Digilent の
[Using the Power Supplies](https://digilent.com/reference/test-and-measurement/guides/waveforms-supplies)。
Supplies の電圧範囲 (0.5〜5 V と −0.5〜−5 V)・1 系統 800 mA・2.4 W・USB 給電の
5.5 W・本体の約 3.5 W (700 mA)・入力の ±25 V・過電圧保護 (±50 V DC、±30 V RMS) は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf) と
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
による。Supplies に mA の Current Limit が無いことは、この 2 つの資料の Supplies の
説明に電力と温度の上限 (Max Power) しか載っていないことからの判断で、
**設定項目の有無は実機では未確認**。
