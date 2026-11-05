---
book: analog-discovery
chapter: 6
id: 6-12
title: フェライトビーズ (10 MHz まで)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-12 フェライトビーズ (10 MHz まで)

フェライトビーズは、リード線にフェライトの筒をかぶせただけの部品で、電源の線に入れて高い周波数の雑音を止める。
コイルに似ているが、**周波数が上がるとリアクタンス X ではなく抵抗 R が主になり、雑音を熱にして捨てる**。
コイルとコンデンサの LC フィルタは共振して雑音を跳ね返すことがあるが、ビーズは R の分で共振を抑える。
Impedance で 100 kHz〜10 MHz を掃引し、直列の R<sub>s</sub> と X<sub>s</sub> に分けて、X が主の領域から R が主の領域へ
移る所を見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗とフェライトビーズ
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
    turn: mirror
  Rref: resistor 3,3 6,3 100
  FB1: ferrite-bead 9,3 12,3 l=$\mathrm{FB_{DUT}}$
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/12-ferrite-bead.svg)

- FB<sub>DUT</sub> はリード付き (アキシアル) のフェライトビーズ。Rref (基準抵抗) は 100 Ω (オーム)。
  ビーズの \|Z\| は 10 MHz で 80 Ω ほどになるので、その桁に合わせた
- ビーズの**等価回路**は、L と R<sub>p</sub> の並列に、線の直流抵抗 R<sub>dc</sub> が直列 (値は下の「見るべき値」)。
  L だけなら X が周波数に比例して増え続けるが、R<sub>p</sub> が並列にあるので、高い周波数では \|Z\| が R<sub>p</sub> に近づく

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (6-2 と同じ配置)
board: half
parts:
  Rref: resistor c5 c10 100
  FB1: ferrite-bead d10 d14
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/12-ferrite-bead.svg)

- 配線は 6-2 と同じで、10 列が Rref とビーズの中点。ビーズは極性が無い
- **3 MHz より上はブレッドボードの浮遊容量を含む目安。** 10 列と 14 列の間の容量 (数 pF、目安) は 10 MHz で
  数 kΩ (キロオーム) なので、ビーズの 80 Ω には 1〜2 % しか効かない。6-7 の Open / Short 補償を取れば、さらに小さくなる

## 計器の設定

計器は Analog Discovery 3 の Impedance (掃引) と、1 点を見る Scope。

| 計器 | 設定 |
| --- | --- |
| Impedance | Start 100 kHz、Stop 10 MHz、点数 201、Amplitude 1 V、Reference: 抵抗 100 Ω。表示は \|Z\|・R<sub>s</sub>・X<sub>s</sub> |
| 補償 | 6-7 と同じ Open (ビーズを抜く) と Short (ビーズの代わりに同じ長さの線) |
| Scope | 7.23 MHz で止めて見る。CH1 = Rref の両端、CH2 = ビーズの両端 |

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz、5-8) の端にあたるので、8〜10 MHz の振幅の読みは少し下がる。
Impedance は CH1 と CH2 の比で読むので、2 つのチャンネルが同じだけ下がる分は打ち消し合う (目安)。
R<sub>s</sub> と X<sub>s</sub> が等しくなる 7.23 MHz では、CH2 が CH1 より 45° 進む。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 7.23 MHz では R と X が同じ大きさ — CH2 (ビーズ) は CH1 (電流) より 45° 進む
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 7.23MHz 0.632V, range: 200mV/div}
ch2: {wave: sine 7.23MHz 0.447V phase 45deg, range: 200mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/12-ferrite-bead.svg)

コイルなら位相は +90°、抵抗なら 0°。その真ん中の 45° が、ビーズの性格が変わる所。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 100 Ω、1/4 W | 電流は 10 mA まで |
| FB<sub>DUT</sub> | リード付きのフェライトビーズ (アキシアル) | 定格電流と、100 MHz での \|Z\| がデータシートの代表値。10 MHz 以下の値は載っていないことが多い |

## 見るべき値

計算値。**等価回路の値は仮定**: L = 2.2 µH (マイクロヘンリー)、R<sub>p</sub> = 100 Ω、R<sub>dc</sub> = 0.02 Ω。
ビーズの容量 (SRF は 100 MHz より上) は 10 MHz までの掃引には効かないので省いた。
R と X が等しくなる周波数は f<sub>c</sub> = R<sub>p</sub> / (2πL) = **7.23 MHz**。

| 周波数 | \|Z\| | R<sub>s</sub> | X<sub>s</sub> | 位相 | CH1・CH2 | 分かること |
| --- | --- | --- | --- | --- | --- | --- |
| 100 kHz | 1.38 Ω | 0.04 Ω | 1.38 Ω | +88.4° | 1.00 V・13.8 mV | ほぼコイル (X = ωL)。電源の直流と低い周波数はそのまま通す |
| 1 MHz | 13.7 Ω | 1.89 Ω | 13.6 Ω | +82.0° | 0.973 V・0.133 V | まだ X が主 |
| 3 MHz | 38.3 Ω | 14.7 Ω | 35.4 Ω | +67.4° | 0.833 V・0.319 V | R が育ってくる |
| 7.23 MHz (f<sub>c</sub>) | 70.7 Ω | 50.0 Ω | 50.0 Ω | **+45.0°** | 0.632 V・0.447 V | **R と X が同じ** |
| 10 MHz | 81.0 Ω | 65.7 Ω | 47.5 Ω | +35.9° | 0.580 V・0.470 V | R が主。X はもう増えない |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 ビーズは 7.23 MHz より上で R が X を追い越す (X が主の領域から R が主の領域へ)
x: 周波数 Hz log 100k..10M
y: インピーダンス Ω log 0.01..200
lines:
  "|Z| Ω": sqrt((0.02+100*(2*pi*x*2.2u)^2/(10000+(2*pi*x*2.2u)^2))^2+(10000*2*pi*x*2.2u/(10000+(2*pi*x*2.2u)^2))^2)
  "R_s Ω": 0.02+100*(2*pi*x*2.2u)^2/(10000+(2*pi*x*2.2u)^2)
  "X_s Ω": 10000*2*pi*x*2.2u/(10000+(2*pi*x*2.2u)^2)
notes:
  - mark 1M
  - mark 3M
  - mark 7.234M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/12-ferrite-bead.svg)

分かること:

- **低い周波数ではビーズはただの小さなコイル** (100 kHz で 1.4 Ω)。電源の直流はほとんど落ちない
- R<sub>s</sub> は周波数の 2 乗で増え、f<sub>c</sub> より上で X<sub>s</sub> を追い越す。雑音の電流は R<sub>s</sub> で熱になるので、
  後ろのコンデンサと LC の共振を作りにくい
- データシートの「100 MHz で 60 Ω」のような値は、R が主の領域の値。10 MHz 以下の雑音 (スイッチング電源の数百 kHz など) には
  効きが小さいので、その帯域はコイルか RC で落とす

## LTspice での確かめ

`sim/12-ferrite-bead.cir` で図1 (Rref 100 Ω、ビーズは L 2.2 µH と R<sub>p</sub> 100 Ω の並列に R<sub>dc</sub> 0.02 Ω を直列、W1 の振幅 1 V) を
100 kHz〜10 MHz で交流解析した。等価回路の値は本文の仮定で、**実測ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| \|Z\| (1 MHz) | 13.7 Ω | RES1 | |
| \|Z\| と位相 (7.23 MHz) | 70.7 Ω、+45.0° | RES2 | |
| CH1・CH2 (7.23 MHz) | 0.632 V・0.447 V | RES3 | |
| \|Z\| (10 MHz) | 81.0 Ω | RES4 | |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。
参考: [フェライトビーズ — Wikipedia](https://ja.wikipedia.org/wiki/%E3%83%95%E3%82%A7%E3%83%A9%E3%82%A4%E3%83%88%E3%83%93%E3%83%BC%E3%82%BA)
