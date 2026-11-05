---
book: analog-discovery
chapter: 4
id: 4-16
title: スイッチング電源のノイズのスペクトル
tier: 200
source: 自作 (回路は回路の教科書 5-6 と同じモジュール。発振周波数は TI の LM2596 のデータシート)
board: BB
---

# 4-16 スイッチング電源のノイズのスペクトル

スイッチング電源 (回路の教科書 5-6 の降圧モジュール) の出力には、スイッチの周波数の**リプル**と、切り替わりの瞬間の**スパイク**が乗る。
Scope で見ると「5 V に乗った小さなギザギザ」だが、Spectrum で見ると**スイッチの周波数とその整数倍の線の列 (くし)** になる。
リプル (三角波に近い) の高調波は 1/n² で速く下がるのに、細いスパイクの高調波はほとんど下がらずに MHz まで続く。
この「下がらないくし」が、近くのラジオや測定に入り込むスイッチング電源のノイズの正体である。

モジュール (秋月の MBC2596-01) の IC は LM2596 で、データシートの発振周波数は 150 kHz (25 °C で 127〜173 kHz)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 降圧モジュール (LM2596) の出力を直流を切って CH1 へ
parts:
  V1: vsource vin gnd 12
  G1: ground gnd
  M1:
    type: device
    model: MBC2596-01
    at: 7,3
    label: Buck DC-DC
    pins: [IN+, IN-, OUT+, OUT-]
  Rload: resistor 7,5 7,7 100
  G2: ground 7,7
  Cb: capacitor 9,5 11,5 1u
  M2: voltmeter 11,5 11,7 l=$\mathrm{CH1}$
  G3: ground 11,7
  G4: ground 4,7
points:
  vin: 2,2
  gnd: 2,4
wires:
  - vin -- 4.5,2 |- M1.IN+
  - gnd -- 3.5,4 |- M1.IN-
  - M1.OUT+ -| 5,5
  - 5,5 -- 7,5
  - 7,5 -- 9,5
  - M1.OUT- -| 4,7
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/16-smps-noise-spectrum.svg)

- 12 V の AC アダプタを M1 の IN+・IN− へ。M1 は出力をトリマで 5 V に合わせておく (5-6 と同じ)。Rload 100 Ω で 50 mA を流す (0.25 W なので 1/2 W の抵抗)
- 5 V の直流を Cb (1 µF。µ はマイクロ) で切って CH1 へ入れる。CH1 の入力 1 MΩ との高域通過の折れ点は 1 / (2π × 1 µF × 1 MΩ) = 0.16 Hz で、
  150 kHz のノイズはそのまま通る。直流を切るので、Scope は細かい目盛 (±2.5 V 側) のまま使える
- AD3 の Supplies は 12 V を出せないので、電源は AC アダプタ。AD3 は Scope だけに使う

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 モジュールの出力 5 V に負荷と直流を切るコンデンサをつなぐ
board: half
parts:
  ADP:
    type: device
    at: top
    label: 12 V AC アダプタ (DC 出力)
    pins: [GND, 12V]
  M1:
    type: device
    model: MBC2596-01
    at: top
    label: Buck DC-DC モジュール (5 V に調整済み)
    pins: [IN+, OUT+, OUT-, IN-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-]
  Rload: resistor/half c10 c14 100
  Cb: capacitor d18 g18 1u
wires:
  - ADP.12V -- M1.IN+ red
  - ADP.GND -- -t1 black
  - M1.IN- -- -t26 black
  - M1.OUT+ -- +t3 red [v36, h-272]
  - M1.OUT- -- -t4 black [v50, h-325]
  - +t10 -- a10 red
  - a14 -- -t14 black
  - +t18 -- a18 red
  - -t2 -- -b2 black
  - SC.1+ -- j18 orange
  - SC.1- -- -b20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/16-smps-noise-spectrum.svg)

5-6 の図2 から LED を外し、上の + レール (出力の 5 V) の 18 列から Cb を溝をまたいで下半分の 18 列へ挿した。CH1 の 1+ (橙) は下の 18 列、1− は下の − レール。
12 V は M1 へ直接つなぎ、ブレッドボードのレールには入れない (+ レールは 5 V だけ)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Scope | CH1: DC (Cb が直流を切る)、5 mV/div。Time 2 µs/div。Trigger: CH1 の立ち上がり 0 V |
| Spectrum | Source: Channel 1。Start 0 Hz、Stop 2 MHz、FFT 点数 8192 (ビンの幅 625 Hz)、Window: Flat-top。単位: dBm |

Cb は電源を入れた直後に 5 V で充電されるので、CH1 には一瞬 5 V が入る (±25 V までなので壊れない)。数秒で 0 V のまわりに落ち着いてから読む。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 出力のリプル — 150 kHz の三角波 Vpp 20 mV と仮定した目安 (スパイクは描いていない)
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: triangle 150kHz 10mV, range: 5mV/div}
cursors: [0, 6.667us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/16-smps-noise-spectrum.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 リプルとスパイクのくし — スパイクの線は MHz まで −48 dBm ほどで下がらない (目安)
device: ad3
sweep: 0-2MHz
samples: 8192
window: flattop
unit: dBm
ref: -20dBm
signal:
  - triangle 150kHz 10mV
  - pulse 150kHz 15mV offset 14.4mV duty 2%
markers: [150kHz, 300kHz, 450kHz, 1.5MHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/16-smps-noise-spectrum.svg)

図3・図4 のリプルとスパイクの大きさは**仮定** (リプル: 三角波 Vpp 20 mV、スパイク: 高さ 30 mV・幅は周期の 2% = 133 ns、平均は 0) で、
実物はモジュール・負荷・配線で変わる。周波数の並び (150 kHz の整数倍) は仮定ではなく IC が決める。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | 降圧 DC-DC モジュール (LM2596、秋月 MBC2596-01) | 出力 5 V に調整 |
| Rload | 抵抗 (負荷、1/2 W 品) | 100 Ω (Ω はオーム) |
| Cb | フィルムかセラミックのコンデンサ (直流を切る、耐圧 16 V 以上) | 1 µF (105) |
| — | 電源 | 12 V の AC アダプタ — 降圧は出力より高い入力が要る (5-6 と同じ) |

## 見るべき値

計算値 (仮定の波形から)。三角波 (振幅 A) の n 次は 8A ÷ (π²n²) で奇数次だけ、パルス (高さ H・デューティ D) の n 次は
2HD × |sin(πnD) ÷ (πnD)| で、nD が小さいうちはほぼ一定。

| 線 | 周波数 | リプルだけ | リプル + スパイク (図4) |
| --- | --- | --- | --- |
| 1 次 | 150 kHz | 8.11 mV (−31.82 dBm) | −31.73 dBm |
| 2 次 | 300 kHz | 0 (三角波に偶数次は無い) | −48.44 dBm (スパイクだけ) |
| 3 次 | 450 kHz | 0.90 mV (−50.91 dBm) | −46.51 dBm |
| 10 次 | 1.5 MHz | 0 | −49.00 dBm (スパイクだけ) |
| スパイクの線の高さ | 150 kHz〜2 MHz | — | 1.20〜1.12 mV (−48.4〜−49.0 dBm) |
| くしが半分 (−6 dB) に下がる所 | — | — | sin(x)/x = 0.5 の x = 1.90 から 1.90 ÷ (π × 133 ns) ≈ 4.5 MHz |

分かること:

- **線の間隔がスイッチの周波数**。M1 の個体と温度で 127〜173 kHz のどこかに立ち、負荷を変えても間隔はほとんど変わらない (固定周波数の IC)
- **リプルは速く下がり、スパイクは下がらない**。リプルの 3 次は 1 次の 19 dB 下 (1/9) だが、スパイクのくしは 2 MHz でも 1 次の 17 dB 下にとどまる。
  スパイクが細い (切り替わりが速い) ほど、くしは高い周波数まで続く。中波ラジオ (0.53〜1.6 MHz) にも、くしの何本かが入る
- 出力に LC のフィルタ (フェライトビーズとコンデンサ) を足すと、くしの高い側から下がる。リニアの 7805 (5-3) の出力には、この線は出ない
- Scope の時間波形ではスパイクの高さは読みにくい (帯域とプローブの GND の線で変わる)。Spectrum の線の高さで比べると、対策の前後を数で比べられる

## LTspice での確かめ

降圧モジュールの中身 (LM2596 のスイッチ) は SPICE に起こしていない。`sim/16-smps-dc-block.cir` で、直流を切る Cb と CH1 の入力 (1 MΩ ∥ 24 pF) の
高域通過だけを .ac で解いた。くしの高さは仮定の波形のフーリエ級数を算術で計算し、`check` の読みと突き合わせた。

| 項目 | 本文の数字 | LTspice・算術 | 判定 |
| --- | --- | --- | --- |
| Cb と 1 MΩ の折れ点 | 0.16 Hz | 0.159 Hz (LTspice) | 合う |
| 150 kHz の通り方 | ほぼ 1 倍 | 0.99998 倍 (LTspice) | 合う |
| 三角波の 1 次 | 8.11 mV (−31.82 dBm) | 8 × 10 mV ÷ π² = 8.106 mV | 合う |
| 三角波の 3 次 | 0.90 mV (−50.91 dBm) | 8.106 ÷ 9 = 0.901 mV | 合う |
| スパイクの 1 次 | 1.20 mV | 2 × 30 mV × 0.02 × 0.9993 = 1.199 mV | 合う |

## 出典

自作。モジュールと配線は回路の教科書 5-6 と同じ。発振周波数は TI の [LM2596 のデータシート (SNVS124G)](https://www.ti.com/lit/ds/symlink/lm2596.pdf) の Oscillator frequency。

参考: [DC-DCコンバータ (Wikipedia)](https://ja.wikipedia.org/wiki/DC-DCコンバータ)、[Buck converter (Wikipedia)](https://en.wikipedia.org/wiki/Buck_converter)
