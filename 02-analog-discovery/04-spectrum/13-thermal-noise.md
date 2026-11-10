---
book: analog-discovery
chapter: 4
id: 4-13
title: 抵抗の熱雑音と 1/f ノイズ (増幅して)
tier: 200
source: 自作 (オペアンプの雑音の値は TI の TL07x のデータシート)
board: BB
---

# 4-13 抵抗の熱雑音と 1/f ノイズ (増幅して)

抵抗は電流を流さなくても、両端に**熱雑音** (ジョンソン雑音) の電圧を出している。大きさは雑音密度で
e<sub>R</sub> = √(4kTR) (k はボルツマン定数、T は絶対温度)。27 °C で 100 kΩ (Ω はオーム) なら 40.7 nV/√Hz で、
AD3 の Scope で直に見るには小さすぎる。そこで TL072 の 2 段 (各 101 倍、計 10201 倍 = 80.2 dB) で増やし、
Spectrum で**抵抗を替えるとフロアが √R で上がる**ことを確かめる。

増やす側のオペアンプにも雑音がある。TL07x の新しいダイの入力の電圧雑音は 1 kHz で 37 nV/√Hz、10 kHz で 21 nV/√Hz
(データシートの代表値) で、低い周波数ほど大きい。これが **1/f ノイズ** (周波数に反比例する電力の雑音) で、
フロアが左へ行くほど持ち上がる形で見える。抵抗の熱雑音は周波数によらず平ら (白色) なので、2 つは形で見分けられる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 TL072 の 2 段 (各 101 倍) で R の雑音を 10201 倍にする
parts:
  RD: resistor 2,4 2,6 100k
  G1: ground 2,6
  U1B: opamp 6,3 +up TL072
  Rg1: resistor 4,4 4,5.5 1k
  Cg1: ecap 4,5.5 4,7 47u
  G2: ground 4,7
  Rf1: resistor 5,4 8,4 100k
  U1A: opamp 12,3 +up TL072
  Rg2: resistor 10,4 10,5.5 1k
  Cg2: ecap 10,5.5 10,7 47u
  G3: ground 10,7
  Rf2: resistor 11,4 14,4 100k
  M1: voltmeter 17,3 17,6 l=$\mathrm{CH1}$
  G4: ground 17,6
wires:
  - U1B.+ -| 2,4
  - 4,4 |- U1B.-
  - 4,4 -- 5,4
  - 8,4 -- 9,4 -- 9,3
  - U1B.out -- 9,3
  - U1A.+ -| 9,3
  - 10,4 |- U1A.-
  - 10,4 -- 11,4
  - 14,4 -- 15,4 -- 15,3
  - U1A.out -- 15,3 -- 17,3
notes:
  - text 7,8: U1 は TL072 (2 回路入り)。電源は +5 V と -5 V
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/13-thermal-noise.svg)

- 1 段め (U1B) の + 入力と GND の間に、測る抵抗 RD を挿す。RD を 0 Ω (線)・10 kΩ・100 kΩ・1 MΩ と挿し替える
- 利得は 1 + Rf/Rg = 1 + 100 kΩ / 1 kΩ = 101 倍。Rg に直列の Cg (47 µF。µ はマイクロ) が直流の利得を 1 倍にするので、
  入力のオフセット電圧 (数 mV) は 10201 倍されない。Rg と Cg の折れ点は 1 / (2π × 1 kΩ × 47 µF) = 3.4 Hz
- 2 段めは 1 段めの出力をそのまま受ける。TL072 の利得帯域幅 5.25 MHz を 101 倍で割ると、各段の帯域は 52 kHz

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボード (上半分が 1 段め、下半分が 2 段め)
board: half
parts:
  U1: dip8 @ e14 TL072
  Rf1: resistor b16 b21 100k
  RD: resistor d17 d25 100k
  Rg1: resistor d16 d8 1k
  Cg1: capacitor/electrolytic b8 -t8 47u v=16V
  Rf2: resistor g14 g9 100k
  Rg2: resistor h15 h21 1k
  Cg2: capacitor/electrolytic i21 -b21 47u v=16V
  AD:
    type: device
    at: top
    label: AD3 (Supplies)
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 (V− と Scope)
    pins: [V-, 1+, 1-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - -t1 -- -b1 black
  - SC.V- -- +b2 blue
  - +t14 -- a14 red
  - j17 -- +b17 blue
  - a25 -- -t25 black
  - a21 -- a15 green
  - c15 -- c12 orange
  - e12 -- f12 orange
  - j12 -- j16 orange
  - i9 -- i15 white
  - SC.1+ -- h14 yellow
  - SC.1- -- -b12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/13-thermal-noise.svg)

- 電源は AD3 の Supplies。V+ (+5 V) は上の + レールから 8 番 (VCC+) へ、V− (−5 V) は下の + レールから 4 番 (VCC−) へ (青)。GND は上下の − レールを 1 列でつなぐ
- 上半分が 1 段め (2 回路め、5〜7 番)。RD は 17 列 (2IN+) から 25 列へ寝かせ、25 列から − レールへ。Rf1 は 16 列 (2IN−) と 21 列、緑の線で 21 列を 15 列 (2OUT) へ戻す
- 1 段めの出力 (15 列) は、橙の線で 12 列へ出て溝を渡り、下半分の 16 列 (1IN+) へ入る
- 下半分が 2 段め (1 回路め、1〜3 番)。Rf2 は 14 列 (1OUT) と 9 列、白の線で 9 列を 15 列 (1IN−) へ戻す。Scope の 1+ (黄) は 14 列

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = +5 V、V− = −5 V、Master Enable |
| Scope | CH1: DC、Range ±2.5 V 側 (500 mV/div ほど) |
| Spectrum | Source: Channel 1。Start 0 Hz、Stop 10 kHz、FFT 点数 8192、Window: Hann (雑音のフロアを見るので振幅の読みより山の細さ、4-3)。単位: dBm。Average を 16 回ほどにして、ばらつくフロアを読みやすくする (4-5) |

RD が 1 MΩ だと、商用電源の 50 Hz / 60 Hz (地域による) とその高調波を拾いやすい。基板を金属の缶や
アルミ箔で覆い (GND につなぐ)、線を短くする。線が立っても、フロアを読む周波数 (1〜10 kHz) から外して読めばよい。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 RD 100 kΩ — 5 kHz のフロアは −46.6 dBm (1 ビン、RBW 4.69 Hz)
device: ad3
sweep: 0-10kHz
samples: 8192
window: hann
unit: dBm
ref: -20dBm
floor: -46.6dBm
markers: [5kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/13-thermal-noise.svg)

図3 はフロアを平らな線で描いた (5 kHz の計算値)。実測では 3 kHz より下でオペアンプの 1/f ノイズが足され、左ほど持ち上がる (図5)。

**校正**: 利得 10201 倍は、RD の代わりに W1 を 10 kΩ と 10 Ω の分圧で入れて確かめる (W1 → 10 kΩ → 2IN+、2IN+ → 10 Ω → GND)。
W1 を Sine 1 kHz・Amplitude 0.1 V にすると、2IN+ には 0.1 V × 10 / 10010 = 99.9 µV が入り、CH1 には振幅 1.02 V が出る。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 校正 — 入力 99.9 µV の 1 kHz が CH1 で振幅 1.02 V (10201 倍)
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1.019V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/13-thermal-noise.svg)

図4 は雑音を描いていない。実際は 10 Ω の分圧のときの出力の雑音 (実効値 50 mV ほど) が波形に重なるので、Scope の Average (4-5) で消して読む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | JFET 入力のオペアンプ (2 回路) | TL072 (DIP8) |
| RD | 測る抵抗 (金属皮膜) | 0 Ω (線)・10 kΩ・100 kΩ・1 MΩ を挿し替える |
| Rf1, Rf2 | 抵抗 | 100 kΩ |
| Rg1, Rg2 | 抵抗 | 1 kΩ |
| Cg1, Cg2 | 電解コンデンサ | 47 µF (+ を Rg の側) |
| — | 校正の分圧 | 10 kΩ と 10 Ω (校正のときだけ RD の代わりに挿す) |
| — | 電源 | ±5 V (AD3 の Supplies。TL072 は 1 回路 1.13 mA なので、10 V × 2.3 mA = 23 mW) |

## 見るべき値

入力換算の雑音密度 (計算値、27 °C)。オペアンプの電圧雑音 e<sub>n</sub> は 37 nV/√Hz (1 kHz)・21 nV/√Hz (10 kHz) を
e<sub>n</sub>² = (18.4 nV)² + (1015 nV)² × (1 Hz / f) で結んだ (1/f の角は約 3 kHz、仮定)。
ほかに入力の電流雑音 80 fA/√Hz × RD、Rf ∥ Rg (990 Ω) の熱雑音 4.05 nV/√Hz、RD と + 入力の浮遊容量 5 pF (仮定) の折れ点を入れた。

| RD | 熱雑音 √(4kTR) | 入力換算の合計 (1 kHz) | 合計 (5 kHz) | CH1 の 1 ビン (5 kHz、Hann、RBW 4.69 Hz) |
| --- | --- | --- | --- | --- |
| 0 Ω | 0 | 37.2 nV/√Hz | 23.7 nV/√Hz | −52.70 dBm |
| 10 kΩ | 12.9 nV/√Hz | 39.4 nV/√Hz | 27.0 nV/√Hz | −51.57 dBm |
| 100 kΩ | 40.7 nV/√Hz | 55.7 nV/√Hz | 47.8 nV/√Hz | −46.60 dBm (図3) |
| 1 MΩ | 128.7 nV/√Hz | 156 nV/√Hz | 152 nV/√Hz | −36.57 dBm |

dBm から密度へは e = √(P × 50 Ω ÷ RBW) ÷ 利得。−46.60 dBm は P = 10^(−4.66) mW = 21.9 nW で、
√(21.9 nW × 50 Ω ÷ 4.69 Hz) = 483 µV/√Hz。5 kHz での利得は各段の帯域 52 kHz のぶん 10201 より 0.9% 小さい 10107 倍なので、÷ 10107 = 47.8 nV/√Hz。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図5 入力換算の雑音密度 — 抵抗の熱雑音は平らで、3 kHz より下はオペアンプの 1/f ノイズが持ち上げる
x: 周波数 Hz log 10..10k
y: 入力換算の雑音密度 nV/√Hz log 10..1000
lines:
  RD 0Ω nV/√Hz: sqrt(354.3 + 1.031M / x)
  RD 100kΩ nV/√Hz: sqrt(354.3 + 1.031M / x + 1721)
  RD 1MΩ nV/√Hz: sqrt(354.3 + 1.031M / x + 22970 / (1 + (x / 31.8k)^2))
notes:
  - mark 100
  - mark 1k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/graph/13-thermal-noise.svg)

分かること:

- **熱雑音は √R**。10 倍の抵抗で √10 = 3.16 倍 (+10 dB)。100 kΩ と 1 MΩ のフロアの差は 5 kHz で 10.0 dB (−46.60 → −36.57 dBm)。
  0 Ω と 10 kΩ はほとんど差が無い — 10 kΩ の熱雑音 12.9 nV/√Hz がオペアンプの雑音 (5 kHz で 23 nV/√Hz) に埋もれる
- **1/f ノイズはオペアンプの側**。RD を 0 Ω にすると図5 の一番下の線になり、100 Hz では 1 kHz の 2.8 倍 (103 nV/√Hz)。
  RD が 1 MΩ なら熱雑音が勝って、線はほぼ平ら
- 1 MΩ では電流雑音 80 fA/√Hz × 1 MΩ = 80 nV/√Hz も足され、合計 (156 nV/√Hz) は熱雑音 (128.7 nV/√Hz) より大きい。
  高い抵抗の熱雑音を測るときは、電流雑音の小さい JFET 入力でも効いてくる
- 炭素皮膜の抵抗に直流を流すと、抵抗そのものも 1/f の雑音 (過剰雑音) を出す。金属皮膜は小さい。この回路は RD に直流を流さないので、RD の 1/f は出ない

## LTspice での確かめ

`sim/13-thermal-noise.cir` で図1 を .noise で解き、RD を 1 Ω・10 kΩ・100 kΩ・1 MΩ に替えた。オペアンプは仮定の模型 (1 次遅れ、GBW 5.25 MHz) に、
入力の電圧雑音の**白色の部分 18.4 nV/√Hz** と電流雑音 80 fA/√Hz、浮遊容量 5 pF を足した (TL072 の模型そのものではない。1/f は入れていない)。
比べる相手は、同じ白色の仮定で計算した出力の雑音密度 (1 kHz)。

| RD | 本文の計算 (白色だけ、出力) | LTspice (出力、1 kHz) | 判定 |
| --- | --- | --- | --- |
| 1 Ω | 192 µV/√Hz | 191.9 µV/√Hz | 合う |
| 10 kΩ | 233 µV/√Hz | 232.5 µV/√Hz | 合う |
| 100 kΩ | 465 µV/√Hz | 464.2 µV/√Hz | 合う |
| 1 MΩ | 1557 µV/√Hz | 1555.6 µV/√Hz | 合う |

1/f の部分 (37 nV/√Hz → 1 kHz の合計) は、データシートの 2 点から算術で足した。出力の実効値 (1 Hz〜1 MHz) は RD 1 MΩ で約 250 mV で、
±2.5 V のレンジに収まる (計算値)。

## 出典

自作。オペアンプの雑音・利得帯域幅・電流の値は TI の [TL07x のデータシート (SLOS080W)](https://www.ti.com/lit/ds/symlink/tl071.pdf) の新しいダイの代表値。
計器の操作は Digilent の [WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。

参考: [熱雑音 (Wikipedia)](https://ja.wikipedia.org/wiki/熱雑音)、[ピンクノイズ (Wikipedia)](https://ja.wikipedia.org/wiki/ピンクノイズ)
