---
book: analog-discovery
chapter: 6
id: 6-16
title: サーミスタ・CdS のインピーダンス vs 温度・光
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-16 サーミスタ・CdS のインピーダンス vs 温度・光

回路の教科書の 8-1 (CdS) と 8-2 (サーミスタ) で使ったセンサーは、温度や光で値の変わる**抵抗**だ。
6-1 と同じ基準抵抗の回路で 1 kHz の \|Z\| と位相を読み、温度と明るさを変えて抵抗の変わり方を数で追う。
直流のテスターでも読めるが、交流の小さな電流で測ると、**位相が 0° (純粋な抵抗) であること**も同時に確かめられ、
流す電流が小さいので自己発熱も無視できる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗とサーミスタ (CdS も同じ所に差し替える)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
    turn: mirror
  Rref: resistor 3,3 6,3 10k
  TH1: thermistor-ntc 9,3 12,3 10k
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/16-thermistor-cds.svg)

- TH1 は NTC サーミスタ 10 kΩ (オーム) @ 25 °C、B 定数 3950 (回路の教科書の 8-2 と同じ物)。CdS は GL5528 (8-1 と同じ物) で、
  同じ穴に差し替える
- Rref (基準抵抗) は 10 kΩ。25 °C のサーミスタと、10 lux の CdS (どちらも 10 kΩ 前後) と同じ値にした

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (6-2 と同じ配置)
board: half
parts:
  Rref: resistor c5 c10 10k
  TH1: thermistor-ntc d10 d14 10k
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/16-thermistor-cds.svg)

- 配線は 6-2 と同じで、10 列が Rref とセンサーの中点。サーミスタも CdS も極性は無い
- 0 °C と 50 °C を測るときは、サーミスタを 2 本の線 (10 列・14 列へ) で延ばし、ポリ袋に入れて氷水やぬるま湯に沈める
  (水に直に浸けない)

## 計器の設定

計器は Analog Discovery 3 の Wavegen と Scope (1 点ずつ読む)。Impedance を 1 kHz の 1 点にして読んでもよい。AD2 でも同じ。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V |
| Scope | CH1 = Rref の両端、CH2 = センサーの両端。Range は両方 100 mV/div |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase。R = Rref × V<sub>CH2</sub> / V<sub>CH1</sub> |

**温度の作り方。** 室温 (25 °C と仮定)、指でつまむ (32 °C ほど)、氷水 (0 °C)、50 °C のぬるま湯。温度計を並べて読む。
**光の作り方。** 手で覆う (1 lux ほど)、薄暗い室内 (10 lux)、明るい室内 (100 lux)、窓辺 (1,000 lux)。lux の値は目安
(スマートフォンの照度計アプリで読むとよい)。
**流す電流は小さい。** 最大でも 0.5 V / 10.4 kΩ ≈ 48 µA (マイクロアンペア)、センサーの電力は数 µW で、自己発熱は 0.01 °C の桁 (目安)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 32 °C (指でつまむ) — CH2 (サーミスタ) は CH1 より小さく、位相は 0° (抵抗)
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.288V, range: 100mV/div}
ch2: {wave: sine 1kHz 0.212V, range: 100mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/16-thermistor-cds.svg)

25 °C では CH1 と CH2 がどちらも 0.25 V で重なる。指でつまむと CH2 が下がり (NTC は温まると抵抗が下がる)、
比 0.212 / 0.288 = 0.74 から R = 7.38 kΩ と読める。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 10 kΩ、1/4 W | |
| TH1 | NTC サーミスタ 10 kΩ @ 25 °C、B 定数 3950 | 回路の教科書の 8-2 と同じ |
| CdS | GL5528 (10 lux で 8〜20 kΩ) | 回路の教科書の 8-1 と同じ |

## 見るべき値

計算値。サーミスタは R(T) = 10 kΩ × exp{3950 × (1/T − 1/298.15)} (T は絶対温度 [K] = °C + 273.15)、
CdS は 8-1 と同じ 10 lux で 10 kΩ に、**R ∝ (照度)<sup>−0.7</sup> と仮定** (GL5528 の目安。個体差が大きい)。

| センサー | 条件 | R | CH1 | CH2 | 位相 |
| --- | --- | --- | --- | --- | --- |
| サーミスタ | 0 °C (氷水) | 33.6 kΩ | 0.115 V | 0.385 V | 0° |
| サーミスタ | 25 °C (室温) | 10.0 kΩ | 0.250 V | 0.250 V | 0° |
| サーミスタ | 32 °C (指) | 7.38 kΩ | 0.288 V | 0.212 V | 0° |
| サーミスタ | 50 °C (ぬるま湯) | 3.59 kΩ | 0.368 V | 0.132 V | 0° |
| CdS | 1 lux (手で覆う) | 50.1 kΩ | 0.083 V | 0.417 V | 0° |
| CdS | 10 lux | 10.0 kΩ | 0.250 V | 0.250 V | 0° |
| CdS | 100 lux | 2.00 kΩ | 0.417 V | 0.083 V | 0° |
| CdS | 1,000 lux | 398 Ω | 0.481 V | 0.019 V | 0° |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 NTC は 0 °C の 33.6 kΩ から 50 °C の 3.59 kΩ へ約 1/10
x: 温度 °C 0..60
y: 抵抗 Ω log 2k..50k
lines:
  NTC 10 kΩ B3950 Ω: 10k*exp(3950*(1/(x+273.15)-1/298.15))
notes:
  - mark 0
  - mark 25
  - mark 32
  - mark 50
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/16-thermistor-cds-1.svg)

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 CdS は照度が 10 倍になると抵抗が 1/5 になる (両対数で直線)
x: 照度 lx log 1..1000
y: 抵抗 Ω log 100..100k
lines:
  CdS GL5528 Ω: 10k*(x/10)^(-0.7)
notes:
  - mark 1
  - mark 10
  - mark 100
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/16-thermistor-cds-2.svg)

分かること:

- **どの条件でも位相は 0°** で、どちらのセンサーも 1 kHz では純粋な抵抗。抵抗の値だけが温度・光で動く
- サーミスタは温度に対して指数で変わり、25 °C の近くでは 1 °C で約 −4.4 % (B / T² = 3950 / 298² の計算値)
- **高い抵抗は計器の入力で低く読める。** CH1 の 1− と CH2 の 2+ がどちらもセンサーの上の端につながり、AD3 の入力 (1 MΩ (メガオーム)) が 2 本
  並列 = 500 kΩ がセンサーに並ぶ。1 lux の CdS (50.1 kΩ) は 45.6 kΩ と 9 % 低く読む。暗い CdS (数百 kΩ〜) を測るときは、
  6-7 の Open 補償でこの分を引くか、直流のテスターで読む
- CdS は光が変わってから値が落ち着くまで、暗くするほうが遅い (数秒、目安)。読みが止まるのを待ってから記録する

## LTspice での確かめ

`sim/16-thermistor-cds.cir` で図1 (Rref 10 kΩ、W1 の振幅 0.5 V) のセンサーを表の抵抗に振り (`.step`)、1 kHz で交流解析した。
抵抗の値は本文の式と仮定から出した値で、**実測ではない**。計器の入力 (2 本で 500 kΩ) を付けた場合も解いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 32 °C (7.38 kΩ) の CH1・CH2 | 0.288 V・0.212 V | 0.2877 V・0.2123 V、位相 0° | 合う |
| 0 °C (33.6 kΩ) の CH1・CH2 | 0.115 V・0.385 V | 0.1146 V・0.3854 V | 合う |
| 1,000 lux (398 Ω) の CH2 | 0.019 V | 0.0191 V | 合う |
| 1 lux (50.1 kΩ) を入力 500 kΩ 付きで読んだ R | 45.6 kΩ (−9 %) | 45.55 kΩ (V<sub>CH2</sub> を Rref の電流で割った値) | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen と Scope の節)。サーミスタと CdS の値は、回路の教科書の 8-2・8-1 と同じ仮定。
参考: [サーミスタ — Wikipedia](https://ja.wikipedia.org/wiki/%E3%82%B5%E3%83%BC%E3%83%9F%E3%82%B9%E3%82%BF)
