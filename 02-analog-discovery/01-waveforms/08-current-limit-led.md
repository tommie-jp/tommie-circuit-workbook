---
book: analog-discovery
chapter: 1
id: 1-8
title: 電源の電圧と直列抵抗で LED の電流を決める
tier: 100
source: 自作
board: BB
---

# 1-8 電源の電圧と直列抵抗で LED の電流を決める

0-2 で確かめたとおり、**Supplies の画面には mA 単位の Current Limit（電流制限）が
見当たらない**（AD3 のリファレンスマニュアルの Supplies の説明にあるのは、AD3 全体の
電力の上限 Max Power と温度の上限だけ。実機の画面での確認は未確認）。
Supplies (Positive Supply / Negative Supply) で決められるのは
**Master Enable・個別の Enable・出力電圧（+0.5〜+5 V と −0.5〜−5 V）・Tracking** で、
LED を守れるような mA 単位の電流制限は無い。AD3 が守っているのは自分の内部部品
（外部の 5 V 電源を付けたとき 1 系統 800 mA・2.4 W、USB だけなら全体で 5.5 W が推奨）で、
LED の定格 (20 mA) よりずっと高い。**AD3 自体を守るものであって LED を守るものではなく**、
上限が働く前に LED が壊れる。

**したがって、抵抗なしで LED を守る方法は無い。** この題では、0-2 と同じく
回路の教科書 1-1 と同じ**直列抵抗**で LED の
電流を決める。そのうえで、Supplies が**出力電圧**を変えられることを利用し、
同じ抵抗のまま電圧を変えると電流がどう変わるかを確かめる。「電流を直接
制限する」のではなく、「電圧と抵抗の組み合わせで電流を決める」のが実機でできる
やり方だと分かる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/08-current-limit-led.svg)

V+（Supplies）→ R1（330 Ω）→ LED → GND。R1 が無いと LED の順方向抵抗はごく
小さいので大電流が流れ、LED か AD3 自体を壊す恐れがある。**これは実機では
試さない**。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで抵抗ありで LED を V+ につなぐ
board: half
parts:
  R1: resistor b5 b8 330
  D1: led c8(A) c10(K) red
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, 1+, 1-, GND]
wires:
  - AD.V+ -- a5 red
  - AD.1+ -- a8 orange
  - a10 -- -t10 black
  - AD.1- -- -t12 black
  - AD.GND -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/08-current-limit-led.svg)

R1（5〜8 列）の先（8 列）が LED のアノード。CH1（`1+` / `1-`）は LED の両端
（8 列と GND）を読み、LED の順方向電圧をそのまま示す。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ を Enable、電圧を下表のとおり変える。Master Enable |
| Scope (CH1) | DC、Range ±3 V 程度 |

## 見るべき値

LED の V<sub>F</sub> ≈ 2.0 V と仮定（0-2 と同じ）。電流 = (V+ − V<sub>F</sub>) ÷ 330 Ω。

| V+ の設定 | 期待する値（計算値） | 分かること |
| --- | --- | --- |
| 5 V | CH1 ≈ 2.0 V、電流 ≈ **9.1 mA**（= (5 − 2.0) / 330）、LED の電力 ≈ 18 mW（= 2.0 V × 9.1 mA。0-2 の V+ が使う電力 45.5 mW とは別） | 抵抗と 5 V の組み合わせで、LED の定格 (20 mA) に十分収まる |
| 3 V | CH1 ≈ 2.0 V（ほぼ変わらない）、電流 ≈ **3.0 mA**（= (3 − 2.0) / 330） | **電圧を下げると、同じ抵抗のまま電流が下がる**。これが実機でできる「電流を加減する」方法 |
| 2.0 V 付近まで下げる | 電流はほぼ 0 mA に近づく | V+ が V<sub>F</sub> を下回ると LED はほとんど点灯しなくなる |

V+ を 2〜5 V で動かしたときの電流を計算で描くと、V<sub>F</sub> (2.0 V) から先で
傾き 1/330 Ω の直線になる。

```graph
title: 図3 R1 = 330 Ω のまま V+ を変える — 3 V で 3.0 mA、5 V で 9.1 mA
x: V+ の設定 V 1.5..5.5
y: LED の電流 mA 0..12
lines:
  計算 (V_F = 2.0 V) mA: max(x-2.0,0)/330*1000
notes:
  - mark 2
  - mark 3
  - mark 5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/graph/08-current-limit-led.svg)

mA の Current Limit が無い以上、**抵抗を省いてよい場面は無い**。LED の
電流は、ここで確かめたとおり電圧と直列抵抗の組み合わせで決める。

## 出典

自作。Supplies の操作 (Master Enable・Positive Supply・Negative Supply・
Voltage・Tracking) は Digilent の
[Using the Power Supplies](https://digilent.com/reference/test-and-measurement/guides/waveforms-supplies)。
Supplies の電圧範囲・1 系統 800 mA・2.4 W・USB 給電の 5.5 W は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
と
[Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Power Supplies の節) による。mA の Current Limit が無いことは、この 2 つの資料に
電力と温度の上限しか載っていないことからの判断で、**設定項目の有無は実機では未確認**。
