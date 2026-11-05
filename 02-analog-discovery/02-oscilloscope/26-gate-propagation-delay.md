---
book: analog-discovery
chapter: 2
id: 2-26
title: 2 ch の時間差 — ゲートの伝搬遅延
tier: 200
source: 自作
board: BB
---

# 2-26 2 ch の時間差 — ゲートの伝搬遅延

論理ゲートは、入力が変わってから出力が変わるまでに少し時間がかかる。これが**伝搬遅延** t<sub>pd</sub> で、
74HC04 (インバータ 6 個入り) なら 4.5 V で典型 9 ns (データシート、負荷 50 pF)。AD3 の Scope の 1 標本は 8 ns なので、
1 段だけを測るのは苦しい。そこで **6 段を直列につなぎ、2 ch の時間差で 5 段ぶんをまとめて測り、5 で割る**。

2 ch の時間差を正しく読むには、2 本の波形の**形をそろえる**ことが要る。ここでは
CH1 を 1 段めの出力、CH2 を 6 段めの出力にする。どちらも 74HC04 の出力なので、立ち上がり・立ち下がりの速さが同じで、
同じ帯域の経路を通れば同じだけ丸まる。W1 (入力) と出力を比べると、W1 の遅い縁と出力の速い縁が違う形に丸まり、時間差がずれる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 74HC04 の 6 個のインバータを直列に。CH1 は 1 段め、CH2 は 6 段めの出力
parts:
  W1: square 2,3 2,5 2.5 l=$\mathrm{W1}$
  G1: ground 2,5
  U1A: not 4,3 74HC04
  U1B: not 6.5,3 74HC04
  U1C: not 9,3 74HC04
  U1D: not 11.5,3 74HC04
  U1E: not 14,3 74HC04
  U1F: not 16.5,3 74HC04
  M1: voltmeter 5.25,4 5.25,6 l=$\mathrm{CH1}$
  G2: ground 5.25,6
  M2: voltmeter 18.5,4 18.5,6 l=$\mathrm{CH2}$
  G3: ground 18.5,6
wires:
  - 2,3 -- U1A.in
  - U1A.out -- 5.25,3 -- U1B.in
  - 5.25,3 -- 5.25,4
  - U1B.out -- U1C.in
  - U1C.out -- U1D.in
  - U1D.out -- U1E.in
  - U1E.out -- U1F.in
  - U1F.out -| 18.5,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/26-gate-propagation-delay.svg)

- W1 は 1 MHz、0〜5 V の方形波 (図の 2.5 V は振幅で、オフセットも 2.5 V)。74HC04 の 1A へ
- 1Y → 2A → … → 6Y と 6 段を順につなぐ。CH1 は 1Y (1 段めの出力)、CH2 は 6Y (6 段めの出力)。
  1Y は入力の反転、6Y は反転を 6 回で入力と同じ向きなので、**CH1 の立ち下がりと CH2 の立ち上がりが組**になる
- 74HC04 の電源 (14 番 VCC = Supplies の V+ 5 V、7 番 GND) は図に描いていない。6 回路とも使うので、浮いた入力は無い

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (74HC04 の 6 段を順につなぐ)
board: half
parts:
  U1: dip14 @ e10 74HC04
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [GND, V+, 2+, W1, 1+, 1-, 2-]
wires:
  - AD.GND -- -b5 black
  - AD.V+ -- +b6 red
  - +b2 -- +t2 red
  - a10 -- +t10 red
  - j16 -- -b16 black
  - g11 -- g12 white
  - g13 -- g14 white
  - h15 -- h18 white
  - g18 -- d18 white
  - c18 -- c15 white
  - b16 -- b13 white
  - c14 -- c11 white
  - d12 -- d8 blue
  - e8 -- f8 blue
  - AD.2+ -- j8 blue
  - AD.W1 -- j10 yellow
  - AD.1+ -- j11 orange
  - AD.1- -- -b20 black
  - AD.2- -- -b22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/26-gate-propagation-delay.svg)

U1 (74HC04) は 10〜16 列。1 番 (1A) が左下の f10。下のブロックに 1A・1Y・2A・2Y・3A・3Y・GND、上のブロックに右から 4Y・4A・5Y・5A・6Y・6A・VCC が並ぶ。

- 1Y→2A (g11–g12)、2Y→3A (g13–g14) は下で隣どうしを白い線でつなぐ
- 3Y→4A は同じ 15 列の上下だが、IC の上を渡らないよう右へ回す: h15→h18、18 列で溝を渡り (g18–d18)、c18→c15
- 4Y→5A (b16–b13)・5Y→6A (c14–c11) は上で白い線
- 6Y (12 列) は青い線で d12→d8、8 列で溝を渡り (e8–f8)、j8 から CH2 (2+) へ
- W1 は j10 (1A)、CH1 (1+) は j11 (1Y)。V+ は下の + レールから 2 列で上の + レールへ渡し、a10 から VCC へ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Wavegen (W1) | 方形波、1 MHz、振幅 2.5 V、オフセット 2.5 V (0〜5 V) |
| Scope | CH1・CH2 とも DC、1 V/div、Time 20 ns/div、Trigger CH1 の立ち下がり 2.5 V、サンプリングは最速 |
| 平均 | Average 16〜64 回 (2-14)。50 % の点の位置の揺れを抑える |
| 読み方 | 縦カーソルを CH1 と CH2 の 50 % (2.5 V) の点に合わせ、ΔX を読む。WaveForms の Measurements に 2 ch の遅れの項目があれば、それでもよい (目安。版で名前が違う) |
| 校正 | **先に CH1 と CH2 を同じ点 (1Y) に挿して ΔX を読む** (ch どうしのずれ、スキュー)。本番の ΔX からこの値を引く |

段あたり 8 ns として、付属ワイヤの経路 (9 MHz、1 次で τ (タウ) = 17.7 ns) で描いたのが図3。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 段めの立ち下がり (CH1) から 6 段めの立ち上がり (CH2) まで約 40 ns (5 段)
time: 20ns/div
trigger: ch1 falling 2.5V at -3div
ch1: {wave: square 1MHz 2.5V offset 2.5V | delay 8ns | invert | offset 5V | rc 17.7ns, range: 1V/div, position: -3div}
ch2: {wave: square 1MHz 2.5V offset 2.5V | delay 48ns | rc 17.7ns, range: 1V/div, position: -3div}
cursors: [0, 40ns]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/26-gate-propagation-delay.svg)

2 本とも同じ 17.7 ns で丸まっているので、50 % の点の差はちょうど 5 段ぶん (40 ns) のまま残る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | インバータ × 6 | 74HC04 (DIP14) |
| — | 電源 | Analog Discovery 3 の V+ (5 V) |

## 見るべき値

計算値。データシートの t<sub>pd</sub> は V<sub>CC</sub> = 4.5 V、負荷 50 pF で典型 9 ns・最大 19 ns (25 °C)、6 V で典型 8 ns。
ここでの負荷は次の段の入力 (典型 3 pF) とブレッドボードの数 pF で 50 pF よりずっと軽く、5 V なので、段あたりは典型より短めに出るはず (目安で 5〜9 ns)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 同じ点に挿した CH1 と CH2 の ΔX (スキュー) | 0 ns に近い (数 ns 以内が目安) | 2 ch の経路が同じなら差は出ない。出た分は本番から引く |
| CH1 の立ち下がり 50 % → CH2 の立ち上がり 50 % | 25〜45 ns (図3 は 40 ns) | 2〜6 段の 5 段ぶんの遅れ |
| 段あたりの t<sub>pd</sub> = ΔX ÷ 5 | 5〜9 ns (図3 なら 8 ns) | データシートの典型 9 ns (50 pF) より軽い負荷のぶん短い |
| 段あたりの上限の目安 | 19 ns (最大、50 pF) × 5 = 95 ns を超えない | 超えたら配線の容量か、電源の電圧を疑う |
| V+ を 3.3 V に下げたとき | 段あたりが長くなる (2 V で典型 45 ns、4.5 V で 9 ns の間) | CMOS の遅れは電源の電圧で大きく変わる |
| CH1 の立ち上がりと CH2 の立ち下がりの組 | 上の組と少し違ってよい | t<sub>PLH</sub> と t<sub>PHL</sub> は同じとは限らない (データシートは大きいほうを t<sub>pd</sub> にしている) |

**5 段まとめて測るのは、1 標本 8 ns の壁を越えるため**。40 ns なら 5 標本ほどの幅があり、平均を掛ければ 1 ns ほどまで読める (目安)。
ch の経路が違う (片方だけ BNC アダプタ、片方だけ長いワイヤ) と、帯域の差がそのまま時間差に化ける。下の LTspice の表のとおり、
9 MHz と 30 MHz の組では 8 ns 違って出る。

## LTspice での確かめ

74HC04 は模型が無いので、遅れそのものは算術 (5 段 × 8 ns = 40 ns、40 ns ÷ 5 = 8 ns) で確かめた。
`sim/26-gate-delay-scope.cir` では、1Y と 6Y を 40 ns ずれた理想のパルス (縁は 8 ns。データシートの t<sub>t</sub> 典型) で置き、
CH1・CH2 の入力経路を 1 次の低域にして、50 % の点の差を読んだ (経路の模型は仮定)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 本当の遅れ (5 段) | 40 ns | 40.0 ns | 合う |
| 2 ch とも 9 MHz (τ = 17.7 ns) で読む差 | 40 ns (そろえれば残る) | 40.0 ns | 合う |
| CH2 だけ 30 MHz (τ = 5.3 ns) で読む差 | 8 ns ほど短く出る | 31.7 ns (−8.3 ns) | 合う |

## 出典

自作。t<sub>pd</sub> と t<sub>t</sub> の値は [SN74HC04 データシート (Texas Instruments, SCLS078H)](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf) の Switching Characteristics による。

参考: [Propagation delay (Wikipedia)](https://en.wikipedia.org/wiki/Propagation_delay)
