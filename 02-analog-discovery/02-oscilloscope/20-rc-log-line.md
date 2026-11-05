---
book: analog-discovery
chapter: 2
id: 2-20
title: 充放電を Math の log で直線にする
tier: 200
source: 自作
board: BB
---

# 2-20 充放電を Math の log で直線にする

2-3 では、充電の曲線が 63.2 % に届く 1 点をカーソルで読んで τ (タウ、時定数) を出した。
1 点だけで読むので、終わりの値 (100 %) の読み違いやノイズがそのまま τ の誤差になる。
放電の電圧 V = V<sub>0</sub> e<sup>−t/τ</sup> は、対数を取ると **ln(V / V<sub>0</sub>) = −t / τ** で、時間に対する直線になる。
Scope の Custom の Math で `Math.log` (自然対数) を掛ければ、曲線が直線に変わり、**傾きから τ を読める**。
直線であること自体が「1 次の RC だけで決まっている」ことの確かめになり、直線が曲がり始める所で ADC の分解能の限界も見える。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 RC ローパスの放電を見る (2-3 と同じ RC、W1 は 0 V と 2 V)
parts:
  M1: voltmeter 1,1 1,3 l=$\mathrm{CH1}$
  W1: square 3,1 3,3 1
  R1: resistor 3,1 5,1 10k
  C1: capacitor 5,1 5,3 100n
  M2: voltmeter 7,1 7,3 l=$\mathrm{CH2}$
  G1: ground 3,3
wires:
  - 1,1 -- 3,1
  - 5,1 -- 7,1
  - 1,3 -- 3,3 -- 5,3 -- 7,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/20-rc-log-line.svg)

W1 (50 Hz、0〜2 V の方形波) を R1 (10 kΩ (キロオーム))・C1 (100 nF) に通す。τ = 10 kΩ × 100 nF = 1.00 ms。
半周期 10 ms は 10 τ で、立ち下がりの直前に C1 は 2 V の 99.995 % まで充電しきっている。CH1 は W1、CH2 は C1 の両端。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (2-3 と同じ RC。1+ は黄の線で 5 列へ渡す)
board: half
parts:
  R1: resistor c7 c10 10k
  C1: capacitor d10 d15 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 2+, 1-, GND, 2-]
wires:
  - AD.W1 -- a7 yellow
  - d7 -- d5 yellow
  - AD.GND -- b15 black
  - AD.1+ -- a5 orange
  - AD.1- -- a15 black
  - AD.2+ -- b10 blue
  - AD.2- -- c15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/20-rc-log-line.svg)

2-3 の基板をそのまま使う (1+ と W1 の線が交わらないよう、W1 の 7 列から黄の線で 5 列へ渡して 1+ を挿した)。変えるのは W1 の振幅 (0〜2 V) と周波数 (50 Hz) と、Scope の Math だけ。
振幅を 2 V に下げるのは、CH2 を 500 mV/div (14 bit の 1 段が 0.336 mV の細かい帯。2-14) に収めて、小さく減った電圧まで刻めるようにするため。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | Square、50 Hz、Amplitude 1 V、Offset 1 V (0〜2 V) |
| Scope (CH1・CH2) | DC、500 mV/div、0 V を下から 2 目盛に置く。Time 500 µs/div (µs はマイクロ秒)、トリガの位置を左から 1 目盛 |
| Trigger | CH1、Falling、1 V (放電の始まり) |
| Math | Custom。式は `Math.log(C2/2)` (C2 は CH2 の電圧、2 は V<sub>0</sub> = 2 V)。単位なし、1/div |
| 平均 | Sample Mode を Average にし、取り込みを数十回平均すると直線の端が長く伸びる (2-14) |

WaveForms の Custom の Math は Script と同じ書き方 (JavaScript) で、`C1` `C2` が CH1・CH2 の電圧、`Math.log` が自然対数 (WaveForms 付属のヘルプによる)。
立ち下がりの前 (C2 ≈ 2 V) では 0 になり、放電が始まると下がっていく。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 放電の CH2 は曲線、Math の ln(CH2 / 2 V) は傾き −1 / τ の直線
time: 500us/div
trigger: ch1 falling 1V at -4div
ch1: {wave: square 50Hz 1V offset 1V phase 180deg, range: 500mV/div, position: -2div}
ch2: {wave: ch1 | rc 1ms, range: 500mV/div, position: -2div}
math: {expr: -t / 1ms * step(t), unit: 1, range: 1/div, position: 3div}
cursors: [500us, 3.5ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/20-rc-log-line.svg)

図3 は理想の形。scope フェンスの式には対数が無いので、Math の線は ln(CH2 / 2 V) を計算で書き直した −t / τ (t ≥ 0) で描いた (理想では同じ線)。
X1 (0.5 ms) と X2 (3.5 ms) で、CH2 は 1.21 V → 60.4 mV と 20 分の 1 に減るが、Math は −0.50 → −3.50 と等しい刻みで下がる。
傾きは −3.00 / 3.00 ms = −1 / ms で、**τ = 1.00 ms**。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 | 10 kΩ |
| C1 | コンデンサ (フィルム。セラミックの高誘電率系は電圧で容量が変わり、直線が曲がる) | 100 nF (104) |
| — | 計器 | AD3 の Wavegen (W1)・Scope (1+ = W1、2+ = C1) |

## 見るべき値

表の値は計算値 (理想の R・C、τ = 1.00 ms)。

| 項目 | 期待する値 | 計算・読み方 |
| --- | --- | --- |
| Math の X1 (0.5 ms) | −0.50 | ln(1.21 / 2) = −0.50 |
| Math の X2 (3.5 ms) | −3.50 | ln(0.0604 / 2) = −3.50 |
| Math の傾き | −1.00 / ms | (−3.50 − (−0.50)) / 3.00 ms |
| τ | 1.00 ms | −1 / 傾き。2-3 の 63.2 % の読みと比べる |
| 直線が保てる下限 | 約 6 τ (CH2 ≈ 5 mV) | ここで CH2 は 1 段 0.336 mV の約 15 段。7 τ (1.8 mV) では約 5 段しかなく、Math はぎざぎざに折れる |
| ゼロ点が 1 mV ずれたとき | 5 τ で +0.07、7 τ で +0.44 | ln((V + 1 mV) / 2 V) − ln(V / 2 V)。直線が上へ反って、τ が長く読める |

確かめ方の手順:

1. X1 と X2 を 0.5 ms と 3.5 ms に置き、Math の差 ÷ 時間の差で傾きを出す。2-3 のカーソルで読んだ τ と比べる
2. 式の V<sub>0</sub> を 2 から 1.9 に替える。線は全体が +0.05 だけ上に平行移動するが、**傾き (τ) は変わらない**。
   放電の対数は、終わりの値の読み違いに強い。1 点読みの 2-3 との違いがここ
3. CH2 の Offset (ゼロ点) を数 mV ずらすと、線の右の端だけが上に反る。直線が曲がるのはゼロ点のずれか、
   RC 以外の要素 (C1 の誘電吸収など) が効いているしるし。なお Scope の入力抵抗 1 MΩ は C1 と並列で、
   τ を (10 kΩ ∥ 1 MΩ) × 100 nF = 0.990 ms に縮めるが、これは直線のまま傾きを 1 % 変えるだけ
4. 充電の側は `Math.log(1-C2/2)` で同じ直線になる。こちらは V<sub>0</sub> (2 V) の読み違いで線が曲がる。
   充電で τ を読むなら、終わりの値を時間をかけて平均してから式に入れる

C2 が 0 以下になる点 (ノイズで負に振れた所) は対数が取れず、線が途切れる。7 τ より右の乱れは故障ではない。

## LTspice での確かめ

`sim/20-rc-log-line.cir` で 50 Hz・0〜2 V の方形波を R1 10 kΩ・C1 100 nF に通した (理想の素子、過渡解析)。
2 周期目の立ち下がり (t = 30 ms) から読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 立ち下がり直前の C1 | 2 V の 99.995 % | 1.99991 V | 合う |
| 0.5 ms の CH2 / ln | 1.21 V / −0.50 | 1.210 V / −0.503 | 合う |
| 3.5 ms の CH2 / ln | 60.4 mV / −3.50 | 60.41 mV / −3.500 | 合う |
| 2 点の傾きから出した τ | 1.00 ms | 1.0009 ms | 合う |
| 5 τ・7 τ の CH2 | 13.5 mV・1.8 mV | 13.50 mV・1.835 mV | 合う |

## 出典

自作。Custom の Math の書き方と `Math.log` は WaveForms 付属のヘルプ (Oscilloscope の Math Channels と、Script の節) による。

参考: [時定数 (Wikipedia)](https://ja.wikipedia.org/wiki/時定数)、[RC回路 (Wikipedia)](https://ja.wikipedia.org/wiki/RC回路)
