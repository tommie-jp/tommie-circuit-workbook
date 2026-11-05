---
book: analog-discovery
chapter: 2
id: 2-25
title: プローブの GND リードのリンギング
tier: 200
source: 自作
board: BB
---

# 2-25 プローブの GND リードのリンギング

10:1 プローブの先には、ワニ口の付いた 15 cm ほどの GND リードが付いている。このリードは輪を作るので**インダクタンス**を持ち、
プローブの先の**入力容量**と直列共振回路になる。速いエッジを測ると、回路には無い減衰振動 (リンギング) が画面に乗る。
原因は回路ではなくプローブの当て方にある。

実物の数は目安で、リード 15 cm の輪が 150 nH ほど (1 cm あたり 10 nH)、10:1 プローブの先の容量が 10〜15 pF。共振は
f<sub>0</sub> = 1/(2π√(LC)) (π (パイ)) = 1/(2π√(150 nH × 12 pF)) ≈ **119 MHz**。AD3 の Scope の帯域 (BNC アダプタで 30 MHz 以上) より上なので、
AD3 ではこの鳴りそのものはほとんど見えず、帯域で丸められたこぶになる。そこでこの題では、L と C を
**22 µH (マイクロヘンリー) と 220 pF に置き換えた模型**をブレッドボードに組み、同じ現象を約 1/55 の速さ (2.2 MHz) で見る。
特性インピーダンス √(L/C) は実物が約 110 Ω (オーム)、模型が約 300 Ω で、桁は同じ。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GND リードとプローブの容量を 22 µH と 220 pF に置き換えた模型
parts:
  W1: square 2,2 2,5 1 l=$\mathrm{W1}$
  G1: ground 2,5
  M2: voltmeter 4,2 4,5 l=$\mathrm{CH1}$
  G4: ground 4,5
  RD: resistor 5.5,2 8.5,2 620
  L1: inductor 9.5,2 12.5,2 22u
  C1: capacitor 14,2 14,5 220p
  G2: ground 14,5
  M1: voltmeter 16,2 16,5 l=$\mathrm{CH2}$
  G3: ground 16,5
wires:
  - 2,2 -- 4,2 -- 5.5,2
  - 8.5,2 -- 9.5,2
  - 12.5,2 -- 14,2 -- 16,2
notes:
  - text 11,1.2 center: GND リードの代わり
  - text 14,5.8 center: プローブの容量の代わり
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/25-probe-ground-ringing.svg)

- W1 (50 kHz、0〜2 V の方形波。図の 1 V は振幅で、オフセットも 1 V) がエッジの速い信号源。測りたい「本当の信号」は W1 の出力で、CH1 で直接見る
- L1 (22 µH) が GND リードの代わり、C1 (220 pF) がプローブの先の容量の代わり。CH2 は C1 の両端、つまり「プローブが見せる電圧」を読む。
  CH2 の入力 (1 MΩ ∥ 24 pF、2-9) も C1 に並ぶので、容量は合わせて 244 pF
- RD は減衰の抵抗。まず RD の代わりに線をつなぎ (0 Ω)、次に 620 Ω を挿す

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (RD を線に替えると減衰なし)
board: half
parts:
  RD: resistor d5 d10 620
  L1: inductor c10 c15 22u
  C1: capacitor e15 e18 220p
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1-, 1+, W1, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - b5 -- b3 white
  - AD.1+ -- a3 orange
  - AD.2+ -- a15 blue
  - a18 -- -t18 black
  - AD.GND -- -t1 black
  - AD.1- -- -t2 black
  - AD.2- -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/25-probe-ground-ringing.svg)

W1 は 5 列 (a5)。5 列から白い線で 3 列へ渡し、3 列の a3 に CH1 (1+) を挿す (W1 と同じ点を見る)。
RD は d5〜d10、L1 は c10〜c15、C1 は e15〜e18 で、18 列を − レールへ。CH2 (2+) は 15 列 (a15)。
GND・1−・2− は上の − レール。RD を外して d5〜d10 を線でつなげば 0 Ω の場合になる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、50 kHz、振幅 1 V、オフセット 1 V (0〜2 V) |
| Scope | CH1・CH2 とも DC、1 V/div、Time 1 µs/div、Trigger CH1 の立ち上がり 1 V、トリガ位置を左から 1 目盛 |
| カーソル | 縦カーソルを CH2 の 1 つめと 2 つめの山に合わせ、時間差 (振動の周期) を読む |

RD = 0 Ω と 620 Ω で見えるはずの画面が図3・図4。2 次の低域 (共振 2.17 MHz、Q = 33 と 0.48) で描いた。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 RD = 0 Ω (線) — 2 V の段が 3.9 V まで跳ね、2.17 MHz で鳴り続ける
time: 1us/div
trigger: ch1 rising 1V at -4div
ch1: {wave: square 50kHz 1V offset 1V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | lc 2.17MHz 33, range: 1V/div, position: -3div}
cursors: [0.23us, 0.69us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/25-probe-ground-ringing-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 RD = 620 Ω — 行き過ぎなく 2 V に着く (臨界減衰の近く)
time: 1us/div
trigger: ch1 rising 1V at -4div
ch1: {wave: square 50kHz 1V offset 1V, range: 1V/div, position: -3div}
ch2: {wave: ch1 | lc 2.17MHz 0.48, range: 1V/div, position: -3div}
measure: [vmax, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/25-probe-ground-ringing-2.svg)

図3 は段の前にも小さな揺れが残っている。1 つ前の立ち下がりで始まった振動が 10 µs では消え切らないためで、
減衰の時定数 2L/R (R は直列の抵抗の合計 9 Ω) が 4.9 µs ある。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 | インダクタ (アキシアル・リード) | 22 µH (GND リードの代わり) |
| C1 | セラミックコンデンサ | 220 pF (221。プローブの先の容量の代わり) |
| RD | 抵抗 (1/4 W) | 620 Ω (0 Ω のときは線に替える) |

電源は使わない (W1 だけで動く)。流れる電流の山は 2 V ÷ 300 Ω ≈ 6.7 mA で、W1 が歪みなく出せる 30 mA (3-5) の内側。

## 見るべき値

計算値。L = 22 µH、C = 220 pF + 24 pF = 244 pF、√(L/C) = 300 Ω。直列の損失は、W1 の出力抵抗 1.5 Ω (3-5 の読み方の例) と、
L1 の 2.2 MHz での損失 (Q を 40 と仮定して 2π × 2.17 MHz × 22 µH / 40 = 7.5 Ω) の合計 9 Ω。

| 測る所 | RD = 0 Ω (線) | RD = 150 Ω (参考) | RD = 620 Ω |
| --- | --- | --- | --- |
| 減衰の割合 ζ (ゼータ) = R / (2√(L/C)) | 0.015 | 0.27 | 1.05 |
| CH2 の山 (2 V の段) | 約 3.9 V (行き過ぎ 95 %) | 約 2.84 V (42 %) | 2.00 V (行き過ぎなし) |
| 振動の周期 (カーソル) | 0.46 µs (2.17 MHz) | 0.48 µs | 振動しない |
| 10 µs 後の残り | ±0.25 V ほど | 見えない | 見えない |
| CH1 (W1 そのもの) | 0→2 V のきれいな段 | 同じ | 同じ |

- **CH1 はきれいなのに CH2 だけ鳴る**。本当の信号は鳴っていない。プローブの当て方 (L と C) が作った鳴り
- **鳴りの周波数は L と C で決まる**: L を小さく (リードを短く) すると周波数が上がり、√(L/C) が下がって鳴り方も変わる。
  実物のプローブでは 15 cm のリードを先のバネ (1 cm ほど、約 10 nH) に替えると f<sub>0</sub> ≈ 459 MHz で、オシロの帯域の外へ追い出せる
- **抵抗で減衰させると鳴りは止まる** (図4)。ただし立ち上がりは遅くなる (10→90 % で約 0.26 µs、図4 の読み値)。実物のプローブでは
  抵抗を足すより、GND を短く取るほうが正しい直し方
- 実物の速いエッジ (74HC の数 ns) を AD3 で見るときに 119 MHz の鳴りは帯域で削られるが、その代わり段の頭に小さなこぶが出ることがある。
  こぶを回路のせいにする前に、GND を短くして変わるかを確かめる

## LTspice での確かめ

`sim/25-ground-lead-ringing.cir` で図1 を解いた (W1 の出力抵抗 1.5 Ω、L1 の損失 7.5 Ω、CH2 の入力 1 MΩ ∥ 24 pF。L1 の Q は仮定)。
RD を 0・150・620 Ω に振り、0→2 V の 1 回めの段で山と周期を読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| RD = 0 Ω の山 | 約 3.9 V | 3.89 V | 合う |
| RD = 0 Ω の振動の周期 | 0.46 µs (2.17 MHz) | 0.460 µs (2.17 MHz) | 合う |
| RD = 150 Ω の山 / 周期 | 約 2.84 V / 0.48 µs | 2.84 V / 0.477 µs | 合う |
| RD = 620 Ω の山 | 2.00 V (行き過ぎなし) | 2.00 V | 合う |
| RD = 0 Ω の 10 µs 後の残り | ±0.25 V ほど | 2.25 V (2 V から +0.25 V) | 合う |

図3 の読み値の山 (3.98 V) が 3.89 V より高いのは、図が繰り返しの定常で描かれ、前の立ち下がりの振動の残りが重なるため。
実物のプローブの共振 (119 MHz・459 MHz) は f<sub>0</sub> = 1/(2π√(LC)) の算術。

## 出典

自作。

参考: [RLC circuit (Wikipedia)](https://en.wikipedia.org/wiki/RLC_circuit)、[Test probe (Wikipedia)](https://en.wikipedia.org/wiki/Test_probe) (Oscilloscope probes の節)
