---
book: analog-discovery
chapter: 6
id: 6-4
title: 自己共振 (SRF) — 100 µH のコイルが容量になる所
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-4 自己共振 (SRF) — 100 µH のコイルが容量になる所

コイルの巻線どうしは小さな**寄生容量 Cp**を持つ。周波数を上げていくと、ある点
(**自己共振周波数 SRF**) で L と Cp が共振し、それより上ではコイルなのに
**容量として振る舞う**。100 µH の小さなインダクタを 100 kHz〜10 MHz で掃引して、
SRF をまたぐ様子を見る。

## 回路図

```circuit
title: 図1 基準抵抗と 100 µH のコイル (掃引)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Rref: resistor 3,3 6,3 10k
  Ldut: inductor 9,3 12,3 100u l=$\mathrm{L_{DUT}}$
  Cp: capacitor 9,6 12,6 5p
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 9,3
  - 9,3 -- 9,6
  - AD.2+ -| 9,3
  - AD.2- -| 12,3
  - 12,3 -- 12,6
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/04-self-resonance.svg)

- L<sub>DUT</sub> と並列に描いた **Cp (5 pF)** は実装した部品ではなく、コイルの巻線間に
  できる寄生容量。実物には無いラベルだが、SRF を計算するために書いてある
- SRF = 1 / (2π√(L·Cp)) ≈ **7.12 MHz** (Cp は仮定値。実測の SRF から逆算もできる)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rref: resistor c5 c10 10k
  Ldut: inductor/axial d10 d14 100uH
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
  - AD.2- -- b14 gray
  - a14 -- -t14 black
  - AD.GND -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/04-self-resonance.svg)

配線の考え方は 6-1〜6-3 と同じ。寄生容量はブレッドボードの上には現れない (コイルの中の話)
ので、実体配線図には出てこない。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**100 kHz〜10 MHz を掃引**、Amplitude 1 V |
| Scope | CH1 = Rref の両端、CH2 = L<sub>DUT</sub> の両端 |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase (周波数ごとに記録) |

Rref (10 kΩ) は**共振点付近に合わせてある**。低い周波数では L<sub>DUT</sub> の Z が
Rref よりずっと小さく、CH2 の読みが小さくなって誤差が増えるが、この題の目的は
正確な \|Z\| そのものより**位相が反転する周波数を見つけること**なので実害は小さい。

```scope
title: 図3 SRF の上 (7.5 MHz) では CH2 (コイルの両端) が CH1 (電流) より約 90° 遅れる
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 7.5MHz 0.228V, range: 100mV/div}
ch2: {wave: sine 7.5MHz 0.972V phase -89.7deg, range: 500mV/div}
cursors: [33.3ns, 66.5ns]
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/04-self-resonance.svg)

図3 は 7.5 MHz の 1 点を、オシロの時間波形で見た画面 (計算値)。CH1 (Rref の両端) は電流に比例し、CH2 は L<sub>DUT</sub> の電圧。
コンデンサは電圧が電流より 90° 遅れるので、CH2 が CH1 より 1/4 周期 (33 ns) 遅れる。SRF の下の 7.0 MHz では CH2 が約 89° 進む。
CH1 は 100 mV/div、CH2 は 500 mV/div と尺度を変えてあり、CH2 の Vpp は 1.94 V、CH1 は 0.46 V。

## 見るべき値

計算値 (L = 100 µH、Cp = 5 pF、巻線抵抗 Rs = 3 Ω と仮定)。

| 周波数 | \|Z\| | 位相 | 分かること |
| --- | --- | --- | --- |
| 100 kHz | 63 Ω | +87.3° | ほぼ理想の L (XL = ωL) |
| 3 MHz | 2.3 kΩ | +89.9° | 共振に近づき \|Z\| が急に増える |
| 7.0 MHz (SRF 直前) | 134 kΩ | +88.8° | まだインダクタ (位相は +) |
| 7.5 MHz (SRF 直後) | 43 kΩ | **−89.7°** | **コンデンサに変わっている** (位相が −) |

**位相の符号が + から − に変わる周波数が SRF。** ここで計算した SRF (7.12 MHz)
の前後で符号が反転しているのが分かる。実際の巻線抵抗や測定のばらつきで、
\|Z\| のピークの高さは計算値ほど鋭くは出ない。
また 7〜10 MHz は 5-8 で見た AD 自身の帯域の壁 (BNC アダプタ無しで約 9 MHz) に近く、
振幅と位相の読みが少しずつずれ始める域なので、SRF 付近の値は目安として読む。

掃引で記録した \|Z\| と位相を周波数に対して並べると、次の形になる。

```graph
title: 図4 7.12 MHz (SRF) で |Z| が山になり、位相が +90° から −90° へ反転する
x: 周波数 Hz log 100k..10M
y:
  - インピーダンス Ω log
  - 位相 deg -100..100
lines:
  "|Z| Ω": sqrt(3^2+(2*pi*x*100u)^2)/sqrt((1-(2*pi*x)^2*100u*5p)^2+(2*pi*x*3*5p)^2)
  位相 deg: deg(atan2(2*pi*x*100u, 3)) - deg(atan2(2*pi*x*3*5p, 1-(2*pi*x)^2*100u*5p))
notes:
  - mark 100k
  - mark 3M
  - mark 7.5M
  - level 0deg
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/04-self-resonance.svg)

分かること:

- 1 MHz 付近までは \|Z\| が周波数にほぼ比例して増え、位相は +90° 近くで平ら (インダクタ)
- 7.12 MHz を越えると位相が −90° に跳び、\|Z\| は下がり始める (コンデンサ)
- 山の頂は Q が高く細いので、101 点程度の掃引では頂を踏まないことが多い

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
