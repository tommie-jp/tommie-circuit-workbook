---
book: analog-discovery
chapter: 3
id: 3-17
title: 波形発生器をシリアル信号源にする (Pattern の代替)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-17 波形発生器をシリアル信号源にする (Pattern の代替)

シリアル (UART) の信号は、ふつう Patterns (パターン発生器) が DIO から出す。ただし DIO の出力は 0 V / 3.3 V に決まっている (仕様)。
RS-232 のように**負の電圧**を使う信号や、5 V・12 V の振れ、わざと鈍らせた辺が欲しいときは、Wavegen の **Custom** (3-4) で
1 フレームを電圧の並びとして書けば、±5 V の範囲で好きな形の信号源になる。
ここでは W1 で RS-232 の向き (1 が負、0 が正) の ±5 V の 'A' を出し、2SC1815 の 1 段で 0 V / 3.3 V に直して DIO0 に入れ、
Logic の UART の読み下しで 'A' に戻ることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 正負 5 V のシリアルを 2SC1815 で 3.3 V の論理に直す
parts:
  V1: square 1,4 1,6 l=$\mathrm{W1}$
  M1: voltmeter 3,4 3,6 l=$\mathrm{CH1}$
  R1: resistor 3,4 5,4 10k
  D1: diode 5,6 5,4 1N4148
  Q1: npn 7,4 2SC1815
  VCC: vcc 7,1 3.3V
  R2: resistor 7,1 7,3 4.7k
  M2: voltmeter 9,3 9,6 l=$\mathrm{CH2}$
  DIO: port 11,3 out
  G1: ground 1,7
wires:
  - 1,4 -- 3,4
  - 5,4 -- 6,4
  - 6,4 -- Q1.B
  - 7,3 -- Q1.C
  - 7,3 -- 9,3 -- 11,3
  - Q1.E -- 7,6
  - 1,6 -- 1,7 -- 3,7 -- 5,7 -- 7,7 -- 9,7
  - 3,6 -- 3,7
  - 5,6 -- 5,7
  - 7,6 -- 7,7
  - 9,6 -- 9,7
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/17-wavegen-serial-source.svg)

- V1 (W1) は Custom の 1 フレーム。R1 (10 kΩ) がベース電流を決める。W1 が +5 V なら I<sub>B</sub> = (5 − 0.7) / 10 kΩ = 0.43 mA で Q1 が飽和し、
  コレクタは約 0 V。−5 V なら Q1 は切れ、R2 (4.7 kΩ) がコレクタを 3.3 V に引き上げる。W1 の向きが反転して出る
- D1 (1N4148) は W1 が −5 V のときベースを約 −0.6 V に止める。2SC1815 のエミッタ・ベース間の逆の耐圧は 5 V (データシート) で、守りが無いとちょうど限界になる
- コレクタ (ポート DIO) を DIO0 に入れる。CH1 は W1、CH2 はコレクタ。3.3 V は Supplies の V+

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 2SC1815 の 1 段 (コレクタを DIO0 と 2+ へ)
board: half
parts:
  Q1: transistor e14 e15 e16 2SC1815 cap=below
  R1: resistor c16 c22 10k
  D1: diode b16(K) b19(A) 1N4148 cap=above
  R2: resistor b10 b15 4.7k cap=above
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, 2-, V+, 2+, DIO0, 1+, W1]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - a10 -- +t10 red
  - a14 -- -t14 black
  - a19 -- -t19 black
  - AD.V+ -- +t8 red
  - AD.2+ -- c15 blue
  - AD.DIO0 -- d15 purple
  - AD.1+ -- b22 orange
  - AD.W1 -- a22 yellow
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/17-wavegen-serial-source.svg)

- Q1 (2SC1815) は平らな面を手前にして e 行の 14・15・16 列に挿す。左から E・C・B。E (14 列) は − レールへ
- R1 は 22 列 (W1・1+) から 16 列 (B) へ。D1 はカソード (帯) を 16 列 (B)、アノードを 19 列に挿し、19 列を − レールへ
- R2 は 15 列 (C) から 10 列へ、10 列を + レール (V+ 3.3 V) へ。15 列から DIO0 (紫) と 2+ (青) を取る

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 (GR か Y) |
| R1 | 抵抗 (ベース) | 10 kΩ |
| R2 | 抵抗 (コレクタのプルアップ) | 4.7 kΩ |
| D1 | 小信号ダイオード | 1N4148 |
| — | 電源 | 3.3 V (AD3 の Supplies の V+。DIO の論理の電圧に合わせる) |
| — | 計器 | Analog Discovery 3 (W1、Scope の CH1・CH2、Logic の DIO0) |

## 計器の設定

'A' は 0x41 = 0100 0001。UART は LSB (最下位のビット) から送るので、論理の 1 と 0 の並びは
待機 1 → スタート 0 → 1 0 0 0 0 0 1 0 → ストップ 1。W1 はこれを反転し、1 を −5 V、0 を +5 V で出す。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Custom、1 周期を 20 ビット (先頭からスタート・データ 8・ストップ・待機 10)。1 ビットを 10 点にした 200 点の CSV (値は +1 / −1)。**Frequency 480 Hz** (9600 ÷ 20)、Amplitude 5 V、Offset 0 V |
| Supplies | V+ 3.3 V を on |
| Scope | CH1: Range 2 V/div、CH2: Range 1 V/div、位置 −3 div。Time 200 µs/div、トリガ CH1 立ち上がり 0 V、位置 −4 div |
| Logic | DIO0 を入力。Interpreter (読み下し) を UART、9600 bit/s・8 bit・パリティ無し・ストップ 1 (8N1) |

1 周期 20 ビットのうち後ろの 10 ビットは待機 (−5 V) なので、フレームどうしの間が 1 ms あき、毎回スタートの辺で揃う。
点の間を WaveForms が階段にするか直線で結ぶかは**未確認**。1 ビットを 10 点にしておけば、どちらでも辺の幅は 1 ビットの 1 割以下に収まる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 (CH1) の ±5 V がコレクタ (CH2) では向きが反転した 0 V / 3.3 V になる
time: 200us/div
trigger: ch1 rising 0V at -4div
ch1: {wave: = -5V + 10V * (step(t) * step(104.17us - t) + step(t - 208.33us) * step(729.17us - t) + step(t - 833.33us) * step(937.5us - t)), range: 2V/div}
ch2: {wave: = 1.66V - 0.324 * ch1, range: 1V/div, position: -3div}
cursors: [52us, 156us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/17-wavegen-serial-source.svg)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 DIO0 の UART を読み下すと 'A' (0x41)
device: ad3
time: 200us/div
start: -200us
sample: 1MHz
signals:
  RXD: dio0 pattern 10100000101 bit 104.17us from -104.17us
decode:
  Serial: uart RXD baud 9600 8N1 ascii
cursors: [52us, 156us]
trigger: RXD falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/logic/17-wavegen-serial-source.svg)

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の高さ / 低さ | +5.00 V / −5.00 V | Custom の値 ±1 に Amplitude 5 V が掛かる |
| CH2 の低さ (W1 が +5 V) | 約 0.04 V | Q1 が飽和。DIO の L の上限 0.8 V (仕様) より十分低い |
| CH2 の高さ (W1 が −5 V) | 約 3.28 V | R2 と DIO の 1 MΩ のプルダウン (仕様) の分圧。H の下限 2.0 V より十分高い |
| 1 ビットの幅 | 104.17 µs (9600 bit/s) | 480 Hz × 20 ビット = 9600。カーソルはスタート (52 µs) と d0 (156 µs) のビットの真ん中 |
| ベースの最も負の電圧 | 約 −0.55 V | D1 が止める。逆の耐圧 5 V から十分離れる |
| W1 の電流 | ±0.44 mA | 上限 30 mA (3-5) よりずっと小さい |
| Logic の読み下し | 'A' (0x41) を 1 ms ごとに 1 文字 | 向きを反転して出したのが、トランジスタでもう一度反転して元に戻った |

Patterns の代わりに Wavegen を使うときの得失:

- **得**: 電圧が ±5 V の範囲で自由 (負の電圧・5 V の論理・中途半端な電圧)。辺を Custom の点で鈍らせたり、
  わざと雑音 (3-7) を足して受け側の強さを試したりできる
- **失**: 線は W1・W2 の 2 本だけ (DIO は 16 本)。速さも帯域 12 MHz (3-15) と点の数で上限がある。
  1 フレームを自分で CSV に書く手間がかかり、文字を変えるたびに CSV を作り直す (Script (1-5) で作ると楽)

## LTspice での確かめ

`sim/17-wavegen-serial-source.cir` で、W1 を ±5 V の 'A' のフレーム (辺 1 µs の折れ線) にして図1 の回路を過渡解析した。
2SC1815 は他の題と同じ近似のモデル、DIO0 は 1 MΩ と 10 pF (容量は仮定) で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| CH2 の低さ | 約 0.04 V | 0.038 V | 合う |
| CH2 の高さ | 約 3.28 V | 3.285 V | 合う |
| ベースの最も負の電圧 | 約 −0.55 V | −0.548 V | 合う |
| W1 の電流 | ±0.44 mA | +0.434 / −0.445 mA | 合う |
| 辺の遅れ (1.65 V を通る時刻) | 1 ビットの 1 % 以下 | 下がり 0.71 µs・上がり 0.56 µs | 合う (104 µs の 0.7 %) |

読み下しの 'A' は logic フェンスの読み値で確かめた (図4。並び 1010000010 1 → 0x41)。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の Custom、Logic の Interpreter の節)。DIO の論理の電圧と 1 MΩ のプルダウンは
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Digital Channels の表)。
参考: [RS-232 (Wikipedia)](https://ja.wikipedia.org/wiki/RS-232)
