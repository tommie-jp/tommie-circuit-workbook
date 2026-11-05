---
book: analog-discovery
chapter: 4
id: 4-18
title: 位相雑音のまね (裾の広がり)
tier: 200
source: 自作 (回路は回路の教科書 3-13 と同じ)
board: BB
---

# 4-18 位相雑音のまね (裾の広がり)

本物の発振回路の線は、スペクトルで見ると 1 本の針ではなく、根元に**裾**が広がっている。周波数がわずかにふらついている (位相がゆらぐ) からで、
この裾を**位相雑音**という。ふらつきは小さく、AD3 の Spectrum で直に見るのは難しい。そこで、回路の教科書 3-13 の 555 の VCO の 5 番 (CONT) を
W1 で**わざと揺らして**、周波数のふらつきがスペクトルの何になるかを見る。

1. W1 を直流 3.0 V にする: 826 Hz に細い線が立つ (図4)
2. W1 に 20 Hz・振幅 20 mV の正弦を足す: 線の両側 ±20 Hz に側波帯が立つ (図5)。周波数の変調 (FM) である
3. W1 を Noise にする: いろいろな周波数の揺れが重なり、側波帯が連なって**裾**になる。これが位相雑音のまね

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 555 の VCO (5 番 CONT を W1 で動かす。回路の教科書 3-13 と同じ値)
parts:
  VCC: vcc 4,1 5V
  Ra: resistor 4,2 4,4.5 10k
  Rb: resistor 4,4.5 4,6.5 10k
  C1: capacitor 5,6.5 5,9 68n
  G1: ground 5,9
  U1: ic 7,5 NE555
  G3: ground 7,9
  W1: vsource 9,7 9,9 l=$\mathrm{W1}$
  G4: ground 9,9
  M1: voltmeter 11,6 11,8 l=$\mathrm{CH1}$
  G5: ground 11,8
wires:
  - 4,1 -- 4,2
  - 4,1 -- 7,1
  - 7,1 -- 7.5,1
  - U1.8 |- 7,1
  - U1.4 |- 7.5,1
  - U1.7 -| 4,4.5
  - U1.6 -| 5,5
  - U1.2 -| 5,5.5
  - 5,5 -- 5,6.5
  - 4,6.5 -- 5,6.5
  - U1.1 |- 7,9
  - U1.5 |- 7.5,7
  - 7.5,7 -- 9,7
  - U1.3 -| 11,5
  - 11,5 -- 11,6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/18-phase-noise-mimic.svg)

3-13 と同じ値 (Ra・Rb 10 kΩ (Ω はオーム)、C1 68 nF)。CH1 は 3 番 (OUT)。5 番の電圧 V<sub>c</sub> が 2 つのしきい値 (V<sub>c</sub> と V<sub>c</sub>/2) を決めるので、
V<sub>c</sub> を揺らすと周波数が揺れる。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (3-13 の図2 から圧電スピーカーと CH2 を外す)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 (Supplies 5V と W1)
    pins: [V+, GND, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-]
  U1: dip8 @ e10 NE555
  Ra: resistor b7 b11 10k
  Rb: resistor a11 a15 10k
  C1: capacitor i5 i9 68n
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - c15 -- c12 orange
  - d12 -- d9 orange
  - e9 -- f9 orange
  - g9 -- g11 orange
  - j5 -- -b5 black
  - j10 -- -b10 black
  - i13 -- +b13 red
  - d13 -- d17 yellow
  - AD.W1 -- a17 yellow
  - SC.1+ -- j12 blue
  - SC.1- -- -b14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/18-phase-noise-mimic.svg)

3-13 の図2 と同じ穴に組み、R3・圧電スピーカー SP と CH2 の線を外した。W1 (黄) は 17 列から 5 番 (13 列) へ、CH1 (青) は 3 番 (`j12`)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Wavegen | 1: W1 DC 3.0 V。2: W1 Sine 20 Hz、Amplitude 20 mV、Offset 3.0 V。3: W1 Noise、Amplitude 20 mV、Offset 3.0 V (目安) |
| Scope | CH1: DC、1 V/div、Time 500 µs/div、Trigger: CH1 の立ち上がり 1.8 V |
| Spectrum | Source: Channel 1。**Start 766 Hz、Stop 886 Hz** (826 Hz の ±60 Hz)、FFT 点数 8192、Window: Flat-top (線の高さを正しく読む。Flat-top の RBW 約 1.0 Hz でも 20 Hz は分けられる、4-3・4-11)。単位: dBm。20 Hz を分けるため、ビンの幅は 1 Hz より細くする (4-11) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 5 番が 3.0 V のとき — 3 番の方形波は 826 Hz、High の割合 62%
time: 500us/div
trigger: ch1 rising 1.8V
ch1: {wave: pulse 826Hz 1.7V offset 1.8V duty 61.7%, range: 1V/div, position: -3div}
cursors: [0, 1.211ms]
measure: [freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/18-phase-noise-mimic.svg)

図3 は LTspice の周波数と High の割合で描いた想定の波形 (3-13 の図3 と同じ)。W1 を 20 Hz で揺らしても、Scope の画面では周期の 0.8% の揺れしか見えない。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 W1 が直流 3.0 V — 826 Hz に細い線が 1 本
device: ad3
sweep: 766Hz-886Hz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
signal: sine 826Hz 2.02V
markers: [826Hz, 806Hz, 846Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/18-phase-noise-mimic-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図5 W1 に 20 Hz・20 mV を足す — ±20 Hz に側波帯 (搬送波の 15.5 dB 下)
device: ad3
sweep: 766Hz-886Hz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
signal:
  - sine 826Hz 1.965V
  - sine 806Hz 0.328V
  - sine 846Hz 0.328V
  - sine 786Hz 0.0272V
  - sine 866Hz 0.0272V
markers: [826Hz, 806Hz, 846Hz, 866Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/18-phase-noise-mimic-2.svg)

図4・図5 は 3 番の方形波の基本波だけを描いた (高調波は 1652 Hz から上で画面の外)。図のサンプル周波数は Stop × 2.56 = 2268 Hz (目安) で、
ビンの幅 0.28 Hz、取り込み時間 3.6 s。実機の値は画面の表示を読む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| Ra, Rb | 抵抗 | 10 kΩ |
| C1 | フィルムコンデンサ | 68 nF (683) |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 信号源 | AD3 の Wavegen W1 (5 番へ。3-13 と同じく 5 番の中の分圧に勝つ) |

## 見るべき値

計算値と LTspice。VCO の傾き K<sub>v</sub> は 5 番を 2.9 V・3.1 V にしたときの周波数の差から求めた。
FM の側波帯は、変調指数 β = (周波数の振れ Δf) ÷ (揺らす周波数 f<sub>m</sub>) のベッセル関数 J<sub>n</sub>(β) で決まる。

| 項目 | 値 | 計算 |
| --- | --- | --- |
| 5 番 3.0 V の周波数 | 825.9 Hz (LTspice) | 3-13 の表の 0.83 kHz と同じ |
| VCO の傾き K<sub>v</sub> | −330 Hz/V | (793.2 − 859.1) Hz ÷ 0.2 V (LTspice、2.9 V と 3.1 V) |
| 周波数の振れ Δf (W1 20 mV) | ±6.6 Hz | 330 Hz/V × 20 mV |
| 変調指数 β | 0.33 | 6.6 Hz ÷ 20 Hz |
| 基本波の振幅 (変調なし) | 2.02 V (+16.11 dBm) | 0.1〜3.5 V・62% の方形波の 1 次: (2 × 3.4 V ÷ π) × sin(0.617π) |
| 搬送波 (826 Hz) | 1.965 V (+15.87 dBm) | 2.02 V × J<sub>0</sub>(0.33) = 2.02 × 0.973 |
| 1 次の側波帯 (806・846 Hz) | 0.328 V (+0.32 dBm)、−15.5 dBc | 2.02 V × J<sub>1</sub>(0.33) = 2.02 × 0.163 |
| 2 次の側波帯 (786・866 Hz) | 27 mV (−21.3 dBm)、−37.2 dBc | 2.02 V × J<sub>2</sub>(0.33) = 2.02 × 0.0135 |

分かること:

- **周波数のふらつきは、線の両側の側波帯になる**。揺れが小さい (β が小さい) うちは 1 次の側波帯だけが目立ち、高さは β/2 (−15.5 dBc は β = 0.33)。
  揺れを 2 倍の 40 mV にすると、側波帯は約 6 dB 上がる
- **揺れ方が雑音だと、側波帯が連続して裾になる**。W1 の Noise は、いろいろな f<sub>m</sub> の揺れの重なりで、それぞれが ±f<sub>m</sub> に側波帯を作る。
  裾の幅は「周波数の振れ」と「揺れの速さ」で決まり、W1 の Noise の振幅を上げると裾が持ち上がる (形は目安。W1 の Noise の帯域による)
- 本物の発振回路の位相雑音は、電源や素子の雑音が周波数を決める所 (555 なら 5 番のしきい値や C1 の充電の電流) を揺らして生まれる。
  5 番にコンデンサ (3-2 の Cc、10 nF) を付けて 5 番を静かにすると、裾が細くなるのはこのため
- 裾は**線の近く**の話なので、見るには RBW を細く (4-11)、取り込みを長くする。ここでは 20 Hz を分けるのに 3.6 s の取り込みを使った

## LTspice での確かめ

`sim/18-555-vco-slope.cir` で 5 番を 2.9・3.0・3.1 V にして周波数を測り、`sim/18-555-vco-fm.cir` で 5 番に 3.0 V + 20 mV・20 Hz を入れて 1 s を過渡解析し、
出力を FFT した (Hann、1 Hz 刻み。線が 1 Hz 刻みのビンに乗るので窓の誤差は小さい)。NE555 は 3-13 と同じ動作の模型 (仮定。実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 5 番 2.9 / 3.0 / 3.1 V の周波数 | 859 / 826 / 793 Hz | 859.1 / 825.9 / 793.2 Hz | 合う |
| High の割合 (3.0 V) | 62% | 61.7% | 合う |
| 1 次の側波帯 (806 Hz) | −15.5 dBc | −15.7 dBc | 合う |
| 1 次の側波帯 (846 Hz) | −15.5 dBc | −15.2 dBc | 合う |
| 2 次の側波帯 | −37.2 dBc | −45〜−60 dBc (左右で違う) | 合わない。5 番の電圧と周波数が直線でないぶん (3-13 の図4) と、High の割合も一緒に揺れる (振幅の変調) ぶんで、小さい線は理想の FM の式から外れる。本文の表の 2 次は理想の FM の値 |

搬送波の高さは LTspice で 1.80 V (+15.1 dBm) で、計算の 1.965 V より 0.8 dB 低い (模型の出力の段のなまりのぶん。目安)。

## 出典

自作。回路は回路の教科書 3-13 (VCO — 555 の 5 番ピン) と同じ。FM の側波帯のベッセル関数の式は通信工学の教科書に載っている標準的な導出。

参考: [Phase noise (Wikipedia)](https://en.wikipedia.org/wiki/Phase_noise)、[TI NE555 のデータシート](https://www.ti.com/lit/ds/symlink/ne555.pdf)
