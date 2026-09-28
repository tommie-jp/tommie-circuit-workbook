---
book: denken
chapter: 0
id: 0-4
title: 低圧の交流電源を作る — AD の波形発生器を OP アンプとプッシュプルで受ける
tier: 100
source: 自作
board: BB
---

# 0-4 低圧の交流電源を作る — AD の波形発生器を OP アンプとプッシュプルで受ける

AD の波形発生器 (W1) は電圧の波形は自由に作れるが、**出せる電流が小さい** (0-1。この本は 10 mA 以内で組む)。
負荷の抵抗が小さい実験 (第 3 章の R-L・電力、第 8 章の変圧器) では、W1 のまま負荷をつなぐと電流が足りない。
そこで W1 の電圧を **OP アンプで受け、トランジスタのプッシュプルで電流を足す**。W1 は OP アンプの入力に
ほとんど電流を流さず、負荷の電流は ±5 V の電源からトランジスタを通って流れる。

プッシュプルは NPN (2SC1815) が + の半周期、PNP (2SA1015) が − の半周期を受け持つ。トランジスタはベースと
エミッタの間に約 0.7 V が掛かるまで電流を流さないので、プッシュプルだけでは 0 V の前後 ±0.7 V で
出力が止まる (**クロスオーバーひずみ**。回路の本の 2-10)。OP アンプの帰還を**プッシュプルの出力から**取ると、
OP アンプがこの 0.7 V を自分で上乗せし、ひずみが消える。帰還をどこから取るかを 1 本の線で切り替えて比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vo = Vi | 電圧フォロワ。帰還をプッシュプルの出力から取ると、出力は入力と同じ電圧になる |
| Vo = Vi − 0.7 V (Vi > 0.7 V)、Vi + 0.7 V (Vi < −0.7 V)、0 (その間) | 帰還を OP アンプの出力から取ったとき。プッシュプルのベースとエミッタの間の 0.7 V がそのまま残る |
| I = Vo / RL | 負荷の電流。W1 の電流とは関係なく、電源から流れる |
| P = Vm² / (2 RL) | 正弦波を抵抗に掛けたときの平均電力 (Vm は振幅) |

## 回路図

```circuit
title: 図1 W1 を OP アンプとプッシュプルで受ける
style:
  standard: jis
  pitch: 1.2
parts:
  W1: sine d1 h1 l=$\mathrm{W1}$
  M1: voltmeter d3 h3 l=$\mathrm{CH1}$
  U1: opamp e6 +up
  Q1: npn c10
  Q2: pnp g10
  VCC: vcc a10
  VEE: vee i10
  RL: resistor e13 h13 47
  M2: voltmeter e15 h15 l=$\mathrm{CH2}$
  G1: ground h1
  G2: ground h13
wires:
  - d1 -- d3 -- d4
  - d4 |- U1.+
  - U1.out -- e8
  - c8 -- g8
  - c8 -- Q1.B
  - g8 -- Q2.B
  - a10 -- Q1.C
  - i10 -- Q2.C
  - Q1.E -- e10 -- Q2.E
  - e10 -- e12 -- e13 -- e15
  - e12 -- k12 -- k4
  - k4 |- U1.-
  - h1 -- h3
  - h13 -- h15
notes:
  - text a10a3 left: +5 V
  - text i10a3 left: -5 V
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/circuit/04-opamp-push-pull-ac.svg)

- W1 は AD の波形発生器。50 Hz、振幅 2 V (商用の周波数に合わせた)
- U1 は LM358 (2 回路入りの 1 回路だけ使う)。±5 V (AD の Supplies の V+ と V−) で動かす
- Q1 (2SC1815) と Q2 (2SA1015) がプッシュプル。エミッタどうしをつないだ所が出力
- 帰還は出力 (Q1・Q2 のエミッタ) から U1 の − 入力へ戻す (**B の配線**)。この線を外し、U1 の出力と
  − 入力を直につなぐと、プッシュプルが帰還の外に出る (**A の配線**、ひずみが出る)
- RL = 47 Ω が負荷。W1 だけでこの負荷に振幅 2 V を掛けると 42.6 mA 要り、AD3 の上限 (30 mA) も超える
- CH1 は入力 (W1)、CH2 は出力 (RL の両端)。どちらも GND 基準

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | OP アンプ (DIP-8) | LM358。1 番 OUT1・2 番 IN1−・3 番 IN1+・4 番 V−・5 番 IN2+・6 番 IN2−・7 番 OUT2・8 番 V+。ここでは 2 回路目 (5〜7 番) を使う |
| Q1 | NPN トランジスタ | 2SC1815 (Ic 最大 150 mA) |
| Q2 | PNP トランジスタ | 2SA1015 (Ic 最大 150 mA) |
| RL | 抵抗 (1/4 W) | 47 Ω。平均 42.6 mW |
| — | 電源 | ±5 V (AD の Supplies)。1 本の電源あたりの平均の電流は 13.6 mA (計算値) で、USB 給電の 250 mW に収まる |

2SC1815 と 2SA1015 は平らな面を手前にして左から E・C・B。図2 は平らな面を向こうにして挿す
(左から B・C・E になる)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U1: dip8 @ e10 LM358
  Q1: transistor c15(B) c16(C) c17(E)
  Q2: transistor h15(B) h16(C) h17(E)
  RL: resistor c20 c25 47
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V- -- -b1 purple
  - AD.V+ -- +t3 red
  - AD.GND -- -t4 black
  - AD.W1 -- b6 yellow
  - AD.1+ -- a6 yellow
  - AD.1- -- -t8 black
  - AD.2+ -- a20 green
  - AD.2- -- -t22 black
  - c6 -- c13 yellow
  - a10 -- +t10 red
  - j13 -- -b13 purple
  - b11 -- b15 orange
  - e15 -- f15 orange
  - a16 -- +t16 red
  - j16 -- -b16 purple
  - e17 -- f17 green
  - b17 -- b20 green
  - a25 -- -t25 black
  - d12 -- d17 white
notes:
  - text small: Q1 = 2SC1815、Q2 = 2SA1015 (平らな面を向こうに挿す。左から B・C・E)
  - text small: 白い線 (d12–d17) が B の帰還。A は白い線を外して d11–d12 をつなぐ
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/breadboard/04-opamp-push-pull-ac.svg)

- 上の + レールが +5 V、上の − レールが GND、下の − レールが −5 V (紫の線)。下の + レールは使わない
- W1 は 6 列に挿し、U1 の 13 列 (5 番、IN2+) へ黄色の線で渡す。CH1 も 6 列
- Q1 と Q2 はベース (15 列) を上下でつなぎ、エミッタ (17 列) も上下でつなぐ。17 列が出力
- RL は 20〜25 列。CH2 は 20 列 (出力) に当てる
- LM358 の使わない 1 回路目 (1〜3 番) はつながない。出力が揺れるなら 3 番を GND、1 番と 2 番をつなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Enable してから Master Enable を入れる |
| Wavegen | W1: Sine、50 Hz、Amplitude 2 V |
| Scope | CH1 = 入力 (W1)、CH2 = 出力 (RL の両端)。どちらも 1 V/div、Time base 5 ms/div。Measure で CH1・CH2 の Maximum |

A の配線 (帰還が OP アンプの出力から) の画面。トランジスタのベースとエミッタの間は 0.7 V 一定の模型で描いた
(実際は電流で 0.6〜0.75 V ほど変わる)。

```scope
title: 図3 A の配線 — 0 V の前後で出力が止まる
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 50Hz 2V, range: 1V/div}
ch2: {wave: "= max(ch1 - 0.7V, 0V) + min(ch1 + 0.7V, 0V)", range: 1V/div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/scope/04-opamp-push-pull-ac-1.svg)

B の配線 (帰還がプッシュプルの出力から) の画面。出力は入力と重なる。

```scope
title: 図4 B の配線 — 出力は入力と同じ
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 50Hz 2V, range: 1V/div}
ch2: {wave: sine 50Hz 2V, range: 1V/div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/scope/04-opamp-push-pull-ac-2.svg)

### オシロスコープと発振器

汎用の計器への読み替えの全体は [回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。この題は CH1・CH2 とも GND 基準なので、
回路はそのままでよい。

- W1 は FG の OUT に読み替える (High-Z、Sine、50 Hz、振幅 2 V。Vpp で入れる機種なら 4 Vpp)。
  FG がつながるのは OP アンプの入力で、電流はほとんど流れない。FG の 50 Ω で振幅は下がらない
- ±5 V は 2 出力の安定化電源で作る (+ 出力と − 出力の中点を GND)。電流制限はどちらも 100 mA。
  流れるのは 1 本あたり山で 42.6 mA、平均 13.6 mA (計算値)
- CH1 の先端を 6 列 (入力)、CH2 の先端を 20 列 (出力)。グランドクリップは 2 本とも上の − レール (GND)
- 設定は AD と同じ (1 V/div、5 ms/div)。Measure で CH1・CH2 の Max と Min を出す

## 見るべき値

計算値 (W1 の振幅 2 V、RL = 47 Ω、ベースとエミッタの間は 0.7 V)。

| 測る所 | A の配線 | B の配線 | 分かること |
| --- | --- | --- | --- |
| CH1 (入力) の Max | 2.00 V | 2.00 V | W1 の設定どおり |
| CH2 (出力) の Max | 1.30 V | 2.00 V | A は 0.7 V 低い。B は入力と同じ |
| CH2 (出力) の Min | −1.30 V | −2.00 V | − の半周期は Q2 が受け持つ |
| 出力が 0 V に止まる幅 | 入力が −0.7〜+0.7 V の間 (1 周期の 23 %) | 無い | クロスオーバーひずみ |
| RL の電流の山 (CH2 ÷ 47 Ω) | 27.7 mA | 42.6 mA | W1 から流れる電流ではない |
| RL の平均電力 | — | 42.6 mW | P = 2² / (2 × 47) |

分かること:

- **W1 から流れる電流は OP アンプの入力の分 (1 µA 以下) だけ**になる。負荷の 42.6 mA は ±5 V の電源から
  トランジスタを通って流れる。W1 の電流の上限 (0-1) は、負荷の大きさと関係なくなる
- A の出力が 0 V に止まるのは、入力の絶対値が 0.7 V 以下の間。sin θ = 0.7 / 2 から θ = 20.5° で、
  0 V の前後それぞれ 41° ぶん、1 周期 360° の 23 % にあたる
- B では OP アンプの出力が、出力より 0.7 V 高い (負の半周期は低い) 電圧を自分で作る。**帰還の中に
  入れた部分のひずみは、OP アンプが打ち消す**。0 V をまたぐ瞬間だけ OP アンプの出力が 1.4 V 跳ぶので、
  周波数を数 kHz に上げると小さな段が残る (LM358 の出力の速さは 0.3 V/µs ほど)
- この題の出力 (50 Hz、振幅 2 V、47 Ω で 42.6 mA) は、第 3 章以降で AD の W1 の代わりに使える。
  電流の上限は Q1・Q2 (150 mA) より先に、AD の Supplies (USB 給電で 1 本 250 mW) で決まる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Wavegen・Scope の節)。LM358 の出力の速さ (スルーレート) はデータシートの代表値。
