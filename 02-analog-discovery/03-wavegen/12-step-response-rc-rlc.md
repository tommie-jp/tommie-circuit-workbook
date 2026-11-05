---
book: analog-discovery
chapter: 3
id: 3-12
title: 任意波形でステップ応答 (RC・RLC)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-12 任意波形でステップ応答 (RC・RLC)

回路に「0 V から 1 V へ一段上がる」電圧 (ステップ) を入れ、出力が落ち着くまでの形 (ステップ応答) を Scope で読む。
方形波でも段は作れるが、Wavegen の **Custom** (3-4) で 1 周期を自分で書くと、段の前後の待ち時間と**段の傾き**を自由に決められる。
RC (1 次) では時定数 τ (タウ) を、RLC (2 次) では行き過ぎ (オーバーシュート) と減衰の速さから Q を読み、
最後に段をゆっくり上げると RLC の揺れが小さくなることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 同じ W1 で RC と RLC を駆動する
parts:
  V1: square 1,2 1,6 l=$\mathrm{W1}$
  M1: voltmeter 3,4 3,6 l=$\mathrm{CH1}$
  R1: resistor 5,2 7,2 1k
  C1: capacitor 7,2 7,4 100n
  M2: voltmeter 9,2 9,4 l=$\mathrm{CH2a}$
  R2: resistor 5,6 7,6 100
  L1: inductor 7,6 9,6 10m
  C2: capacitor 9,6 9,8 100n
  M3: voltmeter 11,6 11,8 l=$\mathrm{CH2b}$
  G1: ground 1,8
  G2: ground 9,4
wires:
  - 1,2 -- 5,2
  - 7,2 -- 9,2
  - 3,4 -- 3,2
  - 1,6 -- 1,8 -- 3,8
  - 3,6 -- 3,8 -- 9,8 -- 11,8
  - 7,4 -- 9,4
  - 4,2 -- 4,6 -- 5,6
  - 9,6 -- 11,6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/12-step-response-rc-rlc.svg)

- 上が RC (R1 1 kΩ・C1 100 nF、τ = 100 µs)、下が RLC (R2 100 Ω・L1 10 mH・C2 100 nF)。W1 の同じ出力を両方へ配る
- CH2 は 1 本しかないので、RC の出力 (CH2a) と RLC の出力 (CH2b) を差し替えて読む。CH1 は W1 そのもの
- V1 の記号は方形波だが、実際は Custom の 1 周期 (下の「計器の設定」) を出す

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上のブロックに RC、下のブロックに RLC (2+ は RLC の出力)
board: half
parts:
  R1: resistor c5 c9 1k
  C1: capacitor d9 d12 100n
  R2: resistor g5 g8 100
  L1: inductor h8 h12 10m
  C2: capacitor g12 g15 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, W1, 1+, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a5 orange
  - e5 -- f5 yellow
  - a12 -- -t12 black
  - j15 -- -b15 black
  - -t27 -- -b27 black
  - AD.2+ -- f12 blue
  - AD.2- -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/12-step-response-rc-rlc.svg)

- W1 (黄) は 5 列。R1 (5→9 列)・C1 (9→12 列) が RC で、C1 の 12 列を − レールへ落とす。RC の出力は 9 列
- 5 列から黄の線で下のブロックへ渡し、R2 (5→8 列)・L1 (8→12 列)・C2 (12→15 列) が RLC。C2 の 15 列を下の − レールへ
- 図は 2+ (青) を RLC の出力の 12 列 (`f12`) に挿した所。RC を読むときは 2+ を上のブロックの 9 列 (`e9`) に差し替える
- 上と下の − レールは 27 列でつなぐ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 | 1 kΩ |
| C1・C2 | フィルムコンデンサ | 100 nF |
| R2 | 抵抗 | 100 Ω |
| L1 | インダクタ (アキシャルかラジアル) | 10 mH。巻線の抵抗は 25 Ω と仮定 (品によって 10〜40 Ω ほど。テスターか 6-3 で測る) |
| — | 計器 | Analog Discovery 3 (W1、Scope の CH1・CH2) |

## 計器の設定

Custom の 1 周期は 4 ms (Frequency 250 Hz) にする。前の 2 ms が 0、後ろの 2 ms が 1 の 4000 点 (1 点 1 µs) を
CSV に書いて読み込み (3-4)、Amplitude 1 V・Offset 0 V で 0 V〜1 V を振らせる (値の正規化のしかたは**目安**。CH1 で 0 V と 1 V を確かめる)。
2 ms は RC の τ の 20 倍・RLC の揺れが消えるまでの時間より十分長いので、毎回落ち着いた所から段が始まる。
2 枚目の CSV は、段の所を **203 µs かけて直線で上げる** (0 から 1 へ 203 点)。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Custom (上の CSV)、Frequency 250 Hz、Amplitude 1 V、Offset 0 V |
| Scope | CH1・CH2 とも DC 結合、Range 200 mV/div、位置 −4 div (0 V を下から 1 目盛)。Time 50 µs/div、トリガ CH1 立ち上がり 0.5 V、位置 −4 div (段を左から 1 目盛に置く)。カーソル 2 本 |

段を入れると、RC は 1 τ で 63 % まで上がり、RLC は 1.53 V まで行き過ぎてから揺れながら 1 V に落ち着く (図3)。
CH2a と CH2b は 2 回に分けて測った波形を 1 枚に重ねた (図3 では CH2 と CH3)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 段に RC (CH2) は 100 µs で 63 %、RLC (CH3) は 1.53 V まで行き過ぎる
time: 50us/div
trigger: ch1 rising 500mV at -4div
ch1: {wave: = 1V * step(t), range: 200mV/div, position: -4div}
ch2: {wave: ch1 | rc 100us, range: 200mV/div, position: -4div}
ch3: {wave: ch1 | lc 5.033kHz 2.53, range: 200mV/div, position: -4div}
cursors: [100us, 304us]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/12-step-response-rc-rlc-1.svg)

段を 203 µs の傾きにすると、RLC の行き過ぎは 8 % ほどに減る (図4)。203 µs は RLC が揺れる 1 周期で、
傾きの間に起きる揺れどうしが打ち消し合う。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 段を 203 µs かけて上げると RLC の行き過ぎは 1.08 V まで減る
time: 50us/div
trigger: ch1 rising 500mV at -4div
ch1: {wave: "= 1V * clip(t / 203us, 0, 1)", range: 200mV/div, position: -4div}
ch2: {wave: ch1 | lc 5.033kHz 2.53, range: 200mV/div, position: -4div}
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/12-step-response-rc-rlc-2.svg)

## 見るべき値

計算値。RLC の Q は巻線の抵抗 25 Ω を含めた R = 125 Ω で Q = (1/R)√(L/C) = 316 / 125 = 2.53 と仮定した。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RC: 段から 100 µs の CH2a | 632 mV (1 − e<sup>−1</sup>) | τ = RC = 100 µs を読む (2-3) |
| RC: 10 % → 90 % の時間 | 220 µs (= 2.2 τ) | 立ち上がり時間と τ の関係 |
| RLC: 最初の山 (101 µs) | 1.53 V (行き過ぎ 53 %) | 行き過ぎ = exp(−πζ / √(1 − ζ<sup>2</sup>))、ζ (ゼータ) = 1/(2Q) = 0.198 |
| RLC: 最初の谷 (203 µs) | 0.72 V | 揺れの周期 203 µs (4.93 kHz)。f<sub>0</sub> = 1/(2π√(LC)) = 5.03 kHz より少し低い |
| RLC: 2 つめの山 (304 µs) | 1.15 V | 山の行き過ぎの比 0.53 / 0.15 = 3.55 倍 |
| RLC: 傾き 203 µs のときの山 | 1.08 V (行き過ぎ 8 %) | 段の傾きを揺れの周期に合わせると揺れが小さい |
| W1 の電流の最大 | 約 3 mA (RLC) | W1 の上限 30 mA (3-5) の 1/10 |

**山の比から Q を逆に求める**: 山の行き過ぎの比を r とすると、対数減衰率 δ (デルタ) = ln r = 1.27、Q ≈ π / δ = 2.48。
読んだ Q から R = 316 / Q を出せば、巻線の抵抗 (R − 100 Ω) が分かる。Q が 2.53 より小さく読めたら、巻線の抵抗が 25 Ω より大きい。

方形波 (Square 250 Hz) でも図3 は同じになる。Custom にする理由は、図4 の傾きのような**段の形そのもの**を変えられることにある。
同じやり方で、段の途中に休みを入れた 2 段の階段や、モータの起動のようなゆっくりした立ち上がりも作れる。

## LTspice での確かめ

`sim/12-step-response-rc-rlc.cir` で、図1 の 2 つの回路に 0 → 1 V の段 (立ち上がり 1 ns) と 203 µs の傾きを入れた (過渡解析)。
W1 は理想の電圧源、巻線の抵抗 25 Ω は仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| RC: 100 µs の値 | 632 mV | 632.1 mV | 合う |
| RC: 10 % → 90 % | 220 µs | 219.7 µs | 合う |
| RLC: 最初の山 | 1.53 V | 1.531 V | 合う |
| RLC: 最初の谷 | 0.72 V | 0.718 V | 合う |
| RLC: 2 つめの山 | 1.15 V | 1.150 V | 合う |
| RLC: 傾き 203 µs のときの山 | 1.08 V | 1.078 V | 合う |
| W1 の電流の最大 (段) | 約 3 mA | 3.05 mA | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の Custom の節)。2 次の系のステップ応答と対数減衰率は標準的な導出。
参考: [過渡応答 (Wikipedia)](https://ja.wikipedia.org/wiki/過渡応答)、[RLC 回路 (Wikipedia)](https://ja.wikipedia.org/wiki/RLC回路)
