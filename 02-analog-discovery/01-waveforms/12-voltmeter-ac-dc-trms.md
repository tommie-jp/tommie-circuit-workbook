---
book: analog-discovery
chapter: 1
id: 1-12
title: 電圧計の AC / DC / True RMS
tier: 200
source: 自作 (計器の名前は Digilent の Analog Discovery 3 の公式資料)
board: BB
---

# 1-12 電圧計の AC / DC / True RMS

WaveForms の **Voltmeter** は、1 つの入力について 3 つの値を並べて出す。

| 表示 | 意味 | 正弦波 (振幅 A・オフセット D) |
| --- | --- | --- |
| DC | 平均 (直流分) | D |
| AC RMS | 直流分を除いた残りの実効値 | A ÷ √2 |
| True RMS | 波全体の実効値 | √(D² + (A ÷ √2)²) |

3 つは **True RMS² = DC² + AC RMS²** で結ばれる (直流分と交流分は直交するので、2 乗が足し算になる)。
この題では、オフセットのある正弦波と、それを RC ローパスに通した波を Voltmeter で読み、この式を確かめる。
1-3 では DC だけを読んだ。AC RMS は「交流の大きさ」、True RMS は「抵抗を温める力」と読み分ける。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 を CH1 で読み、R1・C1 のローパスの出力を CH2 で読む
parts:
  W1: sine 1,2 1,4 l=$\mathrm{W1}$
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  R1: resistor 3,2 5,2 1k
  C1: capacitor 5,2 5,4 1u
  M2: voltmeter 7,2 7,4 l=$\mathrm{CH2}$
  G1: ground 1,4
wires:
  - 1,2 -- 3,2
  - 5,2 -- 7,2
  - 1,4 -- 3,4 -- 5,4 -- 7,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/12-voltmeter-ac-dc-trms.svg)

- W1 は 1 kHz の正弦波、振幅 1 V、オフセット 0.5 V (−0.5〜+1.5 V)。あとで方形波 (0〜2 V) にも替える
- R1 (1 kΩ (キロオーム))・C1 (1 µF (マイクロファラド)) の遮断周波数は 1 ÷ (2π × 1 kΩ × 1 µF) = 159 Hz。
  1 kHz の交流分は約 1/6 に減り、直流分はそのまま通る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 R1 (6〜10 列) と C1 (10 列と GND)。CH1 は 6 列、CH2 は 10 列
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, 2-, W1, 1+, 2+]
  R1: resistor c6 c10 1k
  C1: capacitor/film e10 e13 1u
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - AD.W1 -- a6 yellow
  - AD.1+ -- b6 orange [h10]
  - AD.2+ -- a10 blue
  - a13 -- -t13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/12-voltmeter-ac-dc-trms.svg)

- C1 はフィルムコンデンサ (極性なし)。W1 が負まで振れるので電解は使わない
- W1 が R1 に流す電流は最大 1.5 V ÷ 1 kΩ = 1.5 mA で、Wavegen の 30 mA の 1/20

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V、オフセット 0.5 V。後半は方形波、振幅 1 V、オフセット 1 V |
| Voltmeter | CH1・CH2 の DC・AC RMS・True RMS を並べて読む |
| Scope (Voltmeter と同時には動かない。読み終えてから) | CH1・CH2 とも 500 mV/div、200 µs/div。Measurements に Average・RMS・Peak2Peak |

Voltmeter と Scope は同じアナログ入力を使うので、同時には動かせない (Reference Manual の Voltmeter の節)。
先に Voltmeter で読み、止めてから Scope で波の形を見る。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CH1 は Vpp 2.00 V、CH2 は Vpp 0.314 V — 平均はどちらも 0.50 V
time: 200us/div
trigger: ch1 rising 500mV
ch1: {wave: sine 1kHz 1V offset 0.5V, range: 500mV/div}
ch2: {wave: ch1 | rc 1ms, range: 500mV/div}
measure: [avg, rms, vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/12-voltmeter-ac-dc-trms.svg)

Scope の RMS は True RMS (波全体)。AC RMS は Scope の Measurements には直接出ないので、Voltmeter で読む。

## 部品

| 記号 | 部品 | 値・型 | 備考 |
| --- | --- | --- | --- |
| R1 | 抵抗 | 1 kΩ、1/4 W | |
| C1 | フィルムコンデンサ | 1 µF | 極性なし。W1 が負に振れるため |

## 見るべき値

正弦波 (振幅 1 V・オフセット 0.5 V、1 kHz)。CH2 の振幅は 1 ÷ √(1 + (1 kHz ÷ 159 Hz)²) = 0.157 倍。

| 入力 | DC | AC RMS | True RMS | √(DC² + AC²) |
| --- | --- | --- | --- | --- |
| CH1 (W1) | 0.500 V | 0.707 V | 0.866 V | 0.866 V |
| CH2 (C1) | 0.500 V | 0.111 V | 0.512 V | 0.512 V |

方形波 (0〜2 V、デューティ 50 %、1 kHz) に替えたとき。

| 入力 | DC | AC RMS | True RMS | 分かること |
| --- | --- | --- | --- | --- |
| CH1 (W1) | 1.00 V | 1.00 V | 1.41 V | 0/2 V の方形波は AC と DC が同じ大きさ |
| CH2 (C1) | 1.00 V | 0.143 V | 1.01 V | 三角に近い波 (Vpp 0.49 V)。AC RMS ≈ Vpp ÷ (2√3) |

- **DC はローパスを通しても変わらない** (R1 が直流を通し、CH2 の入力 1 MΩ との分圧で 0.1 % 下がるだけ)。AC RMS だけが減る
- True RMS は DC が大きい波ほど AC の変化に鈍い。CH2 の True RMS (0.512 V) は DC (0.500 V) とほとんど同じ
- 正弦波なら AC RMS = 振幅 ÷ √2 だが、方形波では振幅と同じ。**AC RMS は波の形で変わる**ので、振幅の代わりには使えない

## LTspice での確かめ

`sim/12-voltmeter-ac-dc-trms.cir` で、正弦波と方形波を同じ R1・C1 (CH2 の 1 MΩ も負荷に入れた) に通し、
40〜60 ms (定常) の平均と実効値を `.meas` で読んだ。AC RMS は √(True RMS² − DC²) で出した。

| 項目 | 本文 | LTspice | 判定 |
| --- | --- | --- | --- |
| 正弦波 CH1 の DC / True RMS | 0.500 / 0.866 V | 0.500 / 0.866 V | 合う |
| 正弦波 CH2 の DC / AC RMS / True RMS | 0.500 / 0.111 / 0.512 V | 0.4995 / 0.1111 / 0.5117 V | 合う |
| 方形波 CH1 の DC / True RMS | 1.00 / 1.41 V | 1.000 / 1.414 V | 合う |
| 方形波 CH2 の DC / AC RMS / True RMS | 1.00 / 0.143 / 1.01 V | 0.9990 / 0.1426 / 1.0091 V | 合う |
| 方形波 CH2 の Vpp | 0.49 V | 0.490 V | 合う (2 tanh(T ÷ 4τ) = 0.4898 V) |

## 出典

自作。Voltmeter が DC・AC RMS・True RMS を出すこと、Voltmeter と Scope が同じ入力を使い同時に動かないことは Digilent の
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Voltmeter の節)。Wavegen の 30 mA は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(DC Current Drive)。

参考: [実効値 (Wikipedia)](https://ja.wikipedia.org/wiki/%E5%AE%9F%E5%8A%B9%E5%80%A4)
