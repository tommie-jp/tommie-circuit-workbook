---
book: analog-discovery
chapter: 7
id: 7-20
title: 静止電流で品種を見分ける — 74LS00 と 74HC00 の電源電流をシャントで測る
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 7-20 静止電流で品種を見分ける — 74LS00 と 74HC00 の電源電流をシャントで測る

74LS00 (TTL、バイポーラ) と 74HC00 (CMOS) はピンの並びも働きも同じ NAND × 4 で、刻印が読めなければ見分けにくい。
違いがはっきり出るのは、入力を止めたときに流れる**静止電流** I<sub>CC</sub>。LS は抵抗とトランジスタに電流が流れ続けて mA、
HC は入力が電源か GND に張り付いている限り µA (マイクロアンペア) 以下しか流れない。GND の側に**シャント** (電流を測るための小さな抵抗) R1 を入れ、
R1 の両端の電圧を **Scope** で読んで I = V / R1 で電流に直す。同じ穴に 2 つの IC を差し替えて測り、桁の違いで品種を当てる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GND の側にシャント R1 を入れ、電源電流を電圧で読む
parts:
  AD:
    type: device
    at: 2,6
    label: AD3
    turn: mirror
    pins: [V+, 1+, 1-, GND]
  P1: vcc 11.6,2.5 5V
  U1: dip14 10,6 74HC00
  R1: resistor 7,7.2 7,9.2 47
  G1: ground 4,9.2
wires:
  - AD.V+ -| 5,2.5
  - 5,2.5 -- 8.4,2.5 -- 11.6,2.5
  - U1.1 -| 8.4,4.8
  - U1.2 -| 8.4,5.2
  - U1.4 -| 8.4,6
  - U1.5 -| 8.4,6.4
  - 8.4,6.4 -- 8.4,6 -- 8.4,5.2 -- 8.4,4.8 -- 8.4,2.5
  - U1.14 -| 11.6,4.8
  - U1.13 -| 11.6,5.2
  - U1.12 -| 11.6,5.6
  - U1.10 -| 11.6,6.4
  - U1.9 -| 11.6,6.8
  - 11.6,6.8 -- 11.6,6.4 -- 11.6,5.6 -- 11.6,5.2 -- 11.6,4.8 -- 11.6,2.5
  - U1.7 -| 7,7.2
  - AD.1+ -| 6,7.2
  - 6,7.2 -- 7,7.2
  - AD.1- -| 4.5,9.2
  - AD.GND -| 4,9.2
  - 4,9.2 -- 4.5,9.2 -- 7,9.2
notes:
  - text 5.2,2.1 blue: 入力 8 本を全部 V+ へ (状態 H)
  - text 1,10.6 small left: "74LS00 もピンの並びは同じ。R1 は LS で 47 Ω、HC で 10 kΩ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/20-quiescent-current-ls-hc.svg)

- **シャントは GND の側 (7 番と GND の間) に入れる。** AD3 の Scope の 1+ を 7 番、1− を GND につなげば、
  1+ の電圧がほぼ 0 V の所で読める。電源の側 (14 番) に入れると、両方の入力が 5 V 近くに浮き、
  同相の誤差 (CMRR ±0.5 % で 25 mV) と 1− の入力 1 MΩ (メガオーム) に流れる 5 µA が測る電流に混ざる
- **入力は 8 本とも IC の電源か IC の GND に直に張り付ける。** 状態 H は V+ (図の形)、状態 L は 7 番の節点 (R1 の上) へ。
  L のとき LS の入力から流れ出る電流 (I<sub>IL</sub>、1 本 最大 0.4 mA) も 7 番の節点に戻って R1 を通るので、
  R1 にはデータシートの I<sub>CC</sub> (14 番に入る電流) がそのまま流れる。入力を AD3 の GND へつなぐと、この分が R1 を通らない
- **入力を浮かせない。** HC の入力が浮くと中途半端な電圧で上下のトランジスタが両方少し点き、µA〜mA が流れて、
  品種の違いが分からなくなる (目安)
- 静止電流を見る題なので、パスコンは付けない (付けても直流の読みは変わらない)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (状態 H)
board: half
parts:
  U1: dip14 @ e10 74HC00
  R1: resistor h16 h20 47
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, 1+, GND, 1-]
wires:
  - AD.V+ -- +b3 red
  - +b2 -- +t2 red
  - a10 -- +t10 red
  - a11 -- a12 yellow
  - b12 -- b14 yellow
  - a14 -- a15 yellow
  - j10 -- j11 yellow
  - i11 -- i13 yellow
  - j13 -- j14 yellow
  - c11 -- c8 yellow
  - d8 -- g8 yellow
  - h8 -- h10 yellow
  - a8 -- +t8 orange
  - g16 -- g18 blue
  - AD.1+ -- j18 blue
  - j20 -- -b20 black
  - AD.GND -- -b22 black
  - AD.1- -- -b23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/20-quiescent-current-ls-hc.svg)

U1 は e10 (1 番が f10)。入力は上の列の 13・12・10・9 番 (a11〜a12、b12〜b14、a14〜a15) と
下の列の 1・2・4・5 番 (j10〜j11、i11〜i13、j13〜j14) を黄の線でまとめ、IC の左の 8 列で溝を渡して 1 つの節点にする。
**状態を切り替えるのは橙の線 1 本**: 状態 H は端を +t8 (V+)、状態 L は端を h16 (7 番の列。R1 の上) へ挿し替える。
R1 (h16〜h20) は 7 番の列から −b へ。1+ は g16〜g18 を通して j18、GND と 1− は −b。
V+ は下の +b から 2 列で上の +t へ渡す。74LS00 と 74HC00 は U1 の同じ穴に差し替え、HC のときは R1 も 10 kΩ に替える。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5.0 V、Master Enable を入れる |
| Scope | CH1 (1+・1−) のみ。Range 20 mV/div (LS) か 5 mV/div (HC)、Time 10 ms/div。Trigger は Auto (直流なので掛からない)。Measure に Average。Average のモードで 16 回ほど平均する |
| 0 点 | U1 を抜いて (電流 0) CH1 の Average を読み、その値を以後の読みから引く |

AD3 の Scope の確度は 0.5 V/div 以下の範囲で ±10 mV ± 0.5 % なので、**HC の数 mV より 0 点のずれの方が大きいことがある。**
IC を抜いたときの読みを 0 として差を取る。分解能は 0.336 mV (同じ範囲) で、R1 = 10 kΩ なら 34 nA に当たる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 74LS00・状態 H (出力 L) — R1 47 Ω に 112.8 mV = 2.4 mA
time: 10ms/div
trigger: ch1 rising 50mV
ch1: {wave: dc 112.8mV, range: 20mV/div, position: -3div}
measure: [avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/20-quiescent-current-ls-hc.svg)

時間で変わらない直流なので、線は平らな 1 本になる。状態 L (出力 H) では 37.6 mV (0.8 mA) に下がる。
HC に替えて R1 = 10 kΩ にすると、0 点を引いた読みは 1 mV 未満 (0.1 µA 未満) になる (目安)。

## 部品

| 部品 | 値・型番 | 備考 |
| --- | --- | --- |
| U1 | 74LS00 (SN74LS00N) と 74HC00 (SN74HC00N) | 同じ穴に差し替える。どちらも DIP14 で同じピンの並び。図は 74HC00 で描いた |
| R1 | 47 Ω (LS 用) / 10 kΩ (HC 用) | シャント。LS の最大 4.4 mA で 0.21 V・0.9 mW、HC の最大 2 µA で 20 mV |
| 電源 | 5 V (AD3 の Supplies の V+) | LS の電源の範囲 4.75〜5.25 V。最大 4.4 mA × 5 V = 22 mW で 250 mW に収まる |
| 線 | ジャンパ線 | 橙の 1 本で状態を切り替える |

## 見るべき値

計算値。電流はデータシートの値 (LS は TI の SN74LS00、HC は SN74HC00) で、R1 の電圧は I × R1 と Scope の入力 1 MΩ の並列で求めた。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 74LS00・状態 H (出力 L) の R1 の電圧 | 112.8 mV (I<sub>CCL</sub> typ 2.4 mA)。最大 4.4 mA なら 206.8 mV | LS は出力 L で電流が多い |
| 74LS00・状態 L (出力 H) の R1 の電圧 | 37.6 mV (I<sub>CCH</sub> typ 0.8 mA)。最大 1.6 mA なら 75 mV | 出力の状態で電流が 3 倍変わる |
| 74HC00・状態 H と L の R1 (10 kΩ) の電圧 | 最大 19.8 mV (I<sub>CC</sub> 最大 2 µA、25 °C)。実際は 1 mV 未満 (目安) | 状態に依らずほぼ 0。LS と 3〜4 桁違う |
| IC にかかる電圧 (LS、最大の電流) | 5 − 0.21 = 4.79 V | R1 の電圧の分だけ下がるが、LS の下限 4.75 V より上 |

**見分け方**: 47 Ω で数十〜百 mV 出れば LS (バイポーラ)、出なければ R1 を 10 kΩ に替え、それでも mV に届かなければ HC (CMOS)。
LS は出力の状態で電流が変わり、HC は変わらない。**動かないとき** (LS で 0 に近い): 14 番と 7 番の列に線が届いているか、
橙の線が入力の節点の 8 列に挿さっているかを、Scope の 1+ を各列に当てて電圧で確かめる。

## LTspice での確かめ

`02-analog-discovery/07-logic/sim/20-quiescent-current.cir`。IC を電源電流 I<sub>CC</sub> の電流源で置き換え
(仮定: データシートの値がそのまま流れる)、R1 と Scope の入力 1 MΩ を並べて `.op` で解いた。

| 本文の数字 | LTspice | 判定 |
| --- | --- | --- |
| LS・2.4 mA・47 Ω で 112.8 mV | 112.79 mV | 合う |
| LS・0.8 mA・47 Ω で 37.6 mV | 37.60 mV | 合う |
| LS・4.4 mA・47 Ω で 206.8 mV、IC に 4.79 V | 206.79 mV、5 − 0.207 = 4.793 V | 合う |
| HC・2 µA・10 kΩ で 19.8 mV (1 MΩ に 1 % 取られる) | 19.80 mV (R1 に 1.980 µA) | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
I<sub>CCH</sub>・I<sub>CCL</sub>・I<sub>IL</sub>・電源の範囲は [TI SN74LS00 データシート](https://www.ti.com/lit/ds/symlink/sn74ls00.pdf)、
HC の I<sub>CC</sub> は [TI SN74HC00 データシート](https://www.ti.com/lit/ds/symlink/sn74hc00.pdf)。Scope の確度・分解能・入力 1 MΩ・CMRR は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
