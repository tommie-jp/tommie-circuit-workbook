---
book: analog-discovery
chapter: 5
id: 5-18
title: トランスの周波数特性
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-18 トランスの周波数特性

トランスは「巻数比どおりに電圧を変える部品」と習う (回路の教科書の 6-1)。それが成り立つのは、ある帯域の中だけだ。
低い周波数では 1 次の巻線のインダクタンス (励磁インダクタンス) が信号源を短絡するように効いて落ち、
高い周波数では 2 つの巻線の結合しきれない分 (漏れインダクタンス) が直列に入って落ちる。
この題では、フェライトのトロイダルコア FT37-43 に 20 回ずつ巻いた 1:1 のトランスを Network で掃引し、
**帯域の下の端が R/L で決まる**ことを、信号源と負荷の抵抗を 100 Ω と 1 kΩ に替えて確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 トランスの通過特性 (Rs と RL は 100 Ω か 1 kΩ)
parts:
  W1: sine 1,2 1,4 l=$\mathrm{W1}$
  G1: ground 1,4
  M1: voltmeter 2.5,2 2.5,4 l=$\mathrm{CH1}$
  G6: ground 2.5,4
  Rs: resistor 2.5,2 4.5,2 100 l=$\mathrm{R_s}$
  T1: transformer 6,3 20t-20t
  G2: ground 4.5,4.5
  G3: ground 7.5,4.5
  RL: resistor 8.5,2 8.5,4.5 100 l=$\mathrm{R_L}$
  G4: ground 8.5,4.5
  M2: voltmeter 10,2 10,4 l=$\mathrm{CH2}$
  G5: ground 10,4
wires:
  - 1,2 -- 2.5,2
  - 4.5,2 -- 5,2
  - 5,2 |- T1.A1
  - T1.A2 -| 4.5,4.5
  - T1.B1 -| 7.5,2
  - 7.5,2 -- 8.5,2
  - 8.5,2 -- 10,2
  - T1.B2 -| 7.5,4.5
style:
  pitch: 1.6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/18-transformer-response.svg)

- T1 は 1:1 (20 回 : 20 回)。A1・B1 が巻き始めで、CH2 は CH1 と同じ向き (位相 0°) に出る
- R<sub>s</sub> は信号源の抵抗の代わり、R<sub>L</sub> は負荷。図は 100 Ω。**両方を 1 kΩ に替えて 2 回目を掃引する**
- 帯域の中の利得は R<sub>L</sub>/(R<sub>s</sub> + R<sub>L</sub>) = 1/2 (−6.02 dB)。1:1 のトランスは抵抗の分圧をそのまま通す

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (T1 は FT37-43 に 20 回ずつ)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, GND, 1-, 2+, 2-]
  Rs: resistor c5 c10 100
  T1: transformer/toroid b10(A1) b13(A2) b18(B1) b21(B2) FT37-43 20t:20t
  RL: resistor e18 e21 100 cap=right
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.GND -- -t7 black
  - a13 -- -t13 black
  - a21 -- -t21 black
  - AD.1- -- -t11 black
  - AD.2+ -- a18 blue
  - AD.2- -- -t19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/18-transformer-response.svg)

- T1 は回路の教科書の 6-8 と同じ巻き方: FT37-43 に、0.4 mm 程度のエナメル線で 1 次を 20 回、その上に 2 次を 20 回 (巻き方向をそろえる)。
  1 次は 10 列 (A1、巻き始め) と 13 列 (A2)、2 次は 18 列 (B1、巻き始め) と 21 列 (B2)
- R<sub>s</sub> は 5 列 (W1・CH1) から 10 列、R<sub>L</sub> は 18 列と 21 列の間 (2 次の両端)。A2 と B2 は上の − レールへ落とす
- 部品は上のブロックだけに置き、AD3 を上の帯に置いた。2×15 ヘッダのワイヤのまま測る

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V、Offset 0 V (100 Ω のとき電流は最大 5 mA で、Wavegen の 30 mA より十分小さい) |
| Network | Start 1 kHz、Stop 10 MHz、Log、Steps 201、Reference: Channel 1 |
| 2 回目 | R<sub>s</sub> と R<sub>L</sub> を 1 kΩ に替えて同じ掃引 |

3 MHz より上はブレッドボードの浮遊容量 (第 8 章) と AD3 の入力の帯域 (9 MHz) が効き始めるので、目安として読む。
比 CH2/CH1 を取るので、Wavegen の出力の落ちは打ち消される。

R<sub>s</sub> = R<sub>L</sub> = 100 Ω で、帯域の下の端 (56.6 kHz) の時間波形が図3 (計算値)。CH2 は帯域の中の値 (0.494 V) の
1/√2 の 0.350 V になり、45° **進む** (ハイパスの −3 dB 点と同じ)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 100 Ω・56.6 kHz — CH2 は 0.35 倍で 45° 進む (帯域の下の端)
time: 5us/div
trigger: ch1 rising 0V
ch1: {wave: sine 56.6kHz 1V, range: 500mV/div}
ch2: {wave: sine 56.6kHz 0.350V phase 45deg, range: 500mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/18-transformer-response.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| T1 | トロイダルコア (フェライト 43 材) に 2 つの巻線 | FT37-43、1 次 20 回・2 次 20 回 (0.4 mm 程度のエナメル線、手巻き)。L は各 約 140 µH (AL 350 nH/回² の目安、±25 %) |
| R<sub>s</sub> | 抵抗 (1/4 W、信号源の抵抗の代わり) | 100 Ω と 1 kΩ を差し替える |
| R<sub>L</sub> | 抵抗 (1/4 W、負荷) | 100 Ω と 1 kΩ を差し替える |
| — | 電源 | 使わない |
| — | 計器 | AD3 の W1・Scope 1+ (W1)・2+ (2 次) |

## 見るべき値

計算値。L = 140 µH (目安)、結合係数 k = 0.99 と仮定した (漏れインダクタンスは 1 次・2 次それぞれ (1 − k)L = 1.4 µH)。
コアの損失と巻線の容量は入れていない。

- 下の端: f<sub>L</sub> ≈ (R<sub>s</sub> ∥ R<sub>L</sub>)/(2πL)。100 Ω で 50 Ω/(2π × 140 µH) = **56.8 kHz**、1 kΩ で **568 kHz**
- 上の端: f<sub>H</sub> ≈ (R<sub>s</sub> + R<sub>L</sub>)/(2π × 2(1 − k)L)。100 Ω で 200 Ω/(2π × 2.8 µH) = **11.4 MHz**、1 kΩ では 114 MHz

| R<sub>s</sub> = R<sub>L</sub> | 帯域の中 | 下の端 (−3 dB) | 上の端 (−3 dB) | 10 kHz | 1 MHz | 10 MHz |
| --- | --- | --- | --- | --- | --- | --- |
| 100 Ω | −6.12 dB | 56.6 kHz | 11.5 MHz (掃引の外) | −21.4 dB | −6.12 dB | −8.56 dB |
| 1 kΩ | −6.11 dB | 566 kHz | 115 MHz (掃引の外) | −41.2 dB | −7.29 dB | −6.11 dB |

帯域の中が −6.02 dB より 0.1 dB 低いのは、巻線の抵抗 (各 0.1 Ω と仮定) と、1:1 からわずかにずれる結合の分。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 1:1 トランスの通過特性 — R を 10 倍にすると帯域の下の端も 10 倍に上がる
x: 周波数 Hz log 1k..10M
y: 利得 dB -60..0
lines:
  Rs = RL = 100 Ω dB:
    - 1k -41.22
    - 2k -35.20
    - 5k -27.27
    - 10k -21.35
    - 20k -15.70
    - 50k -9.71
    - 100k -7.30
    - 200k -6.42
    - 500k -6.14
    - 1M -6.12
    - 2M -6.21
    - 5M -6.84
    - 10M -8.56
  Rs = RL = 1 kΩ dB:
    - 1k -61.20
    - 2k -55.18
    - 5k -47.22
    - 10k -41.20
    - 20k -35.19
    - 50k -27.26
    - 100k -21.33
    - 200k -15.68
    - 500k -9.69
    - 1M -7.29
    - 2M -6.41
    - 5M -6.13
    - 10M -6.11
notes:
  - mark 56.6k
  - mark 566k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/18-transformer-response.svg)

分かること:

- **下の端は R/L で決まる。** 抵抗を 10 倍にすると、同じ L が信号源を短絡しきれなくなる周波数も 10 倍に上がる。
  低い周波数まで通したいトランスは、巻数を増やして L を大きくする (L は巻数の 2 乗)
- 下の端より低い所は +20 dB/dec の 1 次のハイパスの形。位相は下の端で +45° 進む (図3)
- 上の端は漏れインダクタンスと抵抗で決まり、抵抗が小さいほど低い。100 Ω で 11 MHz と見積もったが、43 材は 1 MHz を超えると
  透磁率が下がって損失が増えるので、実測の上の端は見積りより低く、肩もなまる (目安)
- 実測の下の端から L を逆算できる: L = (R<sub>s</sub> ∥ R<sub>L</sub>)/(2πf<sub>L</sub>)。6-3 の Impedance で測った L と比べる

## LTspice での確かめ

`sim/18-transformer-response.cir` で図1 を AC 解析した。巻線は 140 µH × 2、結合係数 0.99、巻線抵抗 0.1 Ω (**仮定**。
コアの損失・巻線の容量は入れていない)。R<sub>s</sub> = R<sub>L</sub> を 100 Ω と 1 kΩ に振った。上の端は同じ式を python で解いた値。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 帯域の中 (100 Ω・1 kΩ) | −6.12 dB・−6.11 dB | 0.4945 倍 (−6.12 dB)・0.4950 倍 (−6.11 dB) | 合う |
| 下の端 (100 Ω・1 kΩ) | 56.6 kHz・566 kHz | 56.58 kHz・564.3 kHz (−9.13 dB の点) | 合う |
| 10 kHz (100 Ω・1 kΩ) | −21.4 dB・−41.2 dB | 0.0856 倍 (−21.35 dB)・0.00871 倍 (−41.20 dB) | 合う |
| 1 MHz (1 kΩ) | −7.29 dB | 0.4319 倍 (−7.29 dB) | 合う |
| 10 MHz (100 Ω) | −8.56 dB | 0.3733 倍 (−8.56 dB) | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。Wavegen の電流は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
FT37-43 の AL (350 nH/回²、許容差 ±25 %) は一般に流通する 43 材の FT37 の代表値で、目安。
