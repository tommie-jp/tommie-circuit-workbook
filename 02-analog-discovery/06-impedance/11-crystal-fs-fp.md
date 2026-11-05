---
book: analog-discovery
chapter: 6
id: 6-11
title: 水晶の fs / fp (10 MHz 以下)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-11 水晶の fs / fp (10 MHz 以下)

水晶振動子は、電気的には**直列の L・C・R (水晶の機械的な振動) に、電極の容量 C<sub>0</sub> が並列に付いた**部品として振る舞う。
直列の枝が共振する **fs (直列共振)** で \|Z\| は R<sub>m</sub> まで下がり、そのすぐ上の **fp (並列共振)** で C<sub>0</sub> と
並列に共振して \|Z\| が跳ね上がる。回路の教科書の 3-5 で発振させた 4 MHz の水晶を、6-1〜6-4 と同じ基準抵抗の回路で掃引し、
fs と fp の 2 つを読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗と 4 MHz の水晶
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
    turn: mirror
  Rref: resistor 3,3 6,3 1k
  X1: crystal 9,3 12,3 4M
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 9,3
  - AD.2+ -| 9,3
  - AD.2- -| 12,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/11-crystal-fs-fp.svg)

- X1 は 4 MHz の水晶振動子 (HC-49/U、回路の教科書の 3-5 と同じ物)
- Rref (基準抵抗) は 1 kΩ (オーム)。fs の 40 Ω から fp の数 MΩ まで \|Z\| が 5 桁動くので、どれかに合わせると
  どこかで読みにくい。ここでは掃引の大半 (数 kΩ〜十数 kΩ) に合わせた
- 図1 には描いていないが、水晶の**等価回路**は L<sub>m</sub>・C<sub>m</sub>・R<sub>m</sub> の直列に C<sub>0</sub> が並列 (値は下の「見るべき値」)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (6-2 と同じ配置)
board: half
parts:
  Rref: resistor c5 c10 1k
  X1: crystal/hc49 d10 d12 4MHz
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 green
  - AD.2+ -- b10 white [h10]
  - AD.2- -- b12 gray
  - a12 -- -t12 black
  - AD.GND -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/11-crystal-fs-fp.svg)

- 配線は 6-2 と同じで、10 列が Rref と水晶の中点。水晶は極性が無い
- **ブレッドボードで測ってよい理由。** 4 MHz はブレッドボードの範囲 (3 MHz) を少し超える。ただし fs は水晶の中の
  直列の枝だけで決まり、ブレッドボードの浮遊容量 (10 列と 12 列の間に 1〜2 pF、目安) は C<sub>0</sub> に足されるだけなので、
  **fs は動かず、fp だけが下がる**。fp は浮遊容量を含む目安として読む (下の「見るべき値」)

## 計器の設定

計器は Analog Discovery 3 の Impedance (掃引) と、1 点を見る Scope。水晶の共振の幅は 60 Hz ほどしか無いので、
**広い掃引で場所を探し、狭い掃引で読む**。

| 計器 | 設定 |
| --- | --- |
| Impedance (1 回目) | Start 3.99 MHz、Stop 4.02 MHz、点数 1001 (30 Hz 刻み)、Amplitude 1 V、Reference: 抵抗 1 kΩ |
| Impedance (2 回目) | fs のまわり 1 kHz (1 Hz 刻み) と、fp のまわり 1 kHz の 2 回。どちらも 1001 点 |
| Scope | fs で止めて見る。CH1 = Rref の両端、CH2 = 水晶の両端 |

1 回目の掃引で、30 Hz 刻みは共振の幅 (60 Hz) の半分なので、谷の底は踏み外して浅く出る。場所が分かったら 2 回目で詰める。
**水晶に入る電力は小さくする。** W1 の振幅 1 V なら fs で 37 µW (マイクロワット。= (1 V / 1040 Ω)² × 40 Ω)。
HC-49/U の駆動レベルの上限 (多くは 100〜500 µW、データシートで確かめる) より十分小さい。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 fs (4.000 MHz) では水晶は 40 Ω の抵抗 — CH2 は CH1 と同じ位相で 1/25
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 4MHz 0.962V, range: 500mV/div, position: 2div}
ch2: {wave: sine 4MHz 38.5mV phase -0.2deg, range: 20mV/div, position: -2div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/11-crystal-fs-fp.svg)

CH1 と CH2 は振幅が 25 倍違うので、尺度を 500 mV/div と 20 mV/div に分けた。そのままでは 2 本が重なるので、CH1 を 2 目盛上、CH2 を 2 目盛下にずらしてある。fs から 4 kHz 上 (4.004 MHz) では
CH2 が 0.99 V に増え、位相は +89° (コイルの側) に変わる。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 1 kΩ、1/4 W | |
| X1 | 水晶振動子 4 MHz、HC-49/U | 回路の教科書の 3-5 と同じ。負荷容量の指定は fs・fp の読みに関係しない |

## 見るべき値

計算値。等価回路の値は**仮定** (4 MHz の HC-49/U の目安): R<sub>m</sub> = 40 Ω、C<sub>m</sub> = 15 fF (フェムトファラド)、
C<sub>0</sub> = 4 pF、L<sub>m</sub> = 1 / ((2π × 4 MHz)² × C<sub>m</sub>) = 0.1055 H。

| 量 | 値 | 式 |
| --- | --- | --- |
| fs | 4.000 000 MHz、\|Z\| = 40 Ω、位相 −0.2° | 1 / (2π√(L<sub>m</sub>C<sub>m</sub>)) |
| fp | 4.007 49 MHz、\|Z\| = 2.46 MΩ (山の頂。図4 の印の 4.0075 MHz では 2.40 MΩ) | fs × √(1 + C<sub>m</sub> / C<sub>0</sub>) |
| fp − fs | 7.49 kHz | ≈ fs × C<sub>m</sub> / (2C<sub>0</sub>) |
| Q | 66,000 (共振の幅 fs / Q = 60 Hz) | 2πfs L<sub>m</sub> / R<sub>m</sub> |
| fs の 10 kHz 下 (3.990 MHz) | \|Z\| = 5.7 kΩ、−89.9° | C<sub>0</sub> と C<sub>m</sub> の直列の容量 |
| fs と fp の間 (4.004 MHz) | \|Z\| = 11.4 kΩ、+89.1° | **ここだけコイル** (水晶の発振はこの区間で起きる) |
| 浮遊容量 2 pF を足したとき | fp = 4.005 00 MHz (2.5 kHz 下がる)、fs は動かない | C<sub>0</sub> = 6 pF で計算 |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 fs (4.000 MHz) で谷、fp (4.0075 MHz) で山。その間だけ位相が +90° (コイル)
x: 周波数 kHz 3995..4012
y:
  - インピーダンス Ω log
  - 位相 deg -100..100
lines:
  "水晶 4 MHz Ω": sqrt(1600+(0.6631455962k*x-10610329.539k/x)^2)/sqrt((267.66667-16.666667µ*x^2)^2+(1.0053096µ*x)^2)
  "水晶 4 MHz の位相 deg": deg(atan2(0.6631455962k*x-10610329.539k/x, 40))-deg(atan2(1.0053096µ*x, 267.66667-16.666667µ*x^2))
notes:
  - mark 4000
  - mark 4004
  - mark 4007.5
  - level 0deg
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/11-crystal-fs-fp.svg)

図4 は式の線で、点の刻みが共振の幅より粗いので、fs の谷と fp の山の頂は線の上では浅く描かれる (値は表のとおり)。

分かること:

- **fs は直列の枝だけで決まり、fp は C<sub>0</sub> (と配線の容量) で動く。** 水晶の周波数の表示は、直列共振で使うか、
  指定の負荷容量を付けた並列共振で使うかで意味が違う。回路の教科書の 3-5 のピアース発振は、fs と fp の間 (コイルの区間) で
  発振し、C1・C2 (負荷容量) で周波数を少し引っ張る
- 共振の幅 60 Hz は 4 MHz の 1/66,000。LC の同調回路 (Q は 100 前後) とは桁が違う。水晶で周波数を決める理由がここにある
- AD3 の Wavegen の周波数は 1 Hz より細かく合わせられる (目安) ので、2 回目の掃引で谷の底まで詰められる

## LTspice での確かめ

`sim/11-crystal-fs-fp.cir` で図1 (Rref 1 kΩ、水晶は L<sub>m</sub> 0.1055 H・C<sub>m</sub> 15 fF・R<sub>m</sub> 40 Ω の直列に C<sub>0</sub> 4 pF を並列、
W1 の振幅 1 V) を 3.99〜4.02 MHz で 0.1 Hz 刻みに交流解析した。等価回路の値は本文の仮定で、**実測ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| fs と \|Z\| | 4.000 000 MHz、40 Ω | 3.999 9998 MHz、40.00 Ω | 合う |
| fp と \|Z\| | 4.007 49 MHz、2.46 MΩ | 4.007 493 MHz (CH2 の位相が 0° を横切る所)、2.464 MΩ | 合う |
| CH1・CH2 (fs) | 0.962 V・38.5 mV | 0.9615 V・38.46 mV | 合う |
| \|Z\| (3.990 MHz・4.004 MHz) | 5.7 kΩ・11.4 kΩ | 5.695 kΩ・11.37 kΩ | 合う |
| fp (C<sub>0</sub> = 6 pF) | 4.005 00 MHz | 4.004 998 MHz (山は 1.10 MΩ に下がる) | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
参考: [水晶振動子 — Wikipedia](https://ja.wikipedia.org/wiki/%E6%B0%B4%E6%99%B6%E6%8C%AF%E5%8B%95%E5%AD%90)
