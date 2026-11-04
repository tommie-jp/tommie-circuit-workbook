---
book: circuits
chapter: 3
id: 3-15
title: リングオシレータ (インバータ 3 段)
tier: 200
source: 自作
---

# 3-15 リングオシレータ (インバータ 3 段)

インバータ (NOT) を**奇数個、輪につなぐ**と、それだけで発振する。1 段目の出力が High なら 2 段目は Low、3 段目は High、
その出力が 1 段目の入力に戻って 1 段目を Low にする。どの状態にも落ち着けず、変化が輪を回り続ける。これがリングオシレータ (ring oscillator)。
偶数個だと、輪を 1 周しても向きが戻るだけで、止まってしまう (ラッチになる)。

- **周期は遅れの合計で決まる**: 変化が 1 段を通るのにかかる時間 (伝搬遅延) を t<sub>d</sub>、段の数を N とすると、変化が輪を 2 周 (High→Low→High) して 1 周期で、
  T = 2 × N × t<sub>d</sub>、f = 1 / (2N t<sub>d</sub>)
- **IC だけの輪は速すぎる**: CD4069UB の伝搬遅延は 5 V で典型 55 ns・最大 110 ns (データシート、負荷 50 pF)。3 段だけなら f ≈ 1 / (6 × 55 ns) ≈ 3 MHz。
  74HC04 なら 5 V 近くで典型 9 ns なので約 18 MHz で、ブレッドボードの範囲 (3 MHz 以下) を超える。IC の中の遅れは個体と温度でばらつき、周波数が決まらない
- **各段に R と C を入れて遅れを決める**: 段の出力から R (10 kΩ。Ω はオーム) を通して C (1 nF) を充電し、その電圧を次の段の入力にする。
  C の電圧が次の段のしきい値 (電源の半分の 2.5 V) を横切るまでの時間が、IC の遅れの 100 倍ほどになり、周波数は R と C で決まる

この題では、CD4069UB の 3 つのインバータで、R と C を入れたリングオシレータを組み、周波数と 1 段の遅れをオシロで測る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 リングオシレータ (CD4069UB のインバータ 3 段、各段に R と C)
parts:
  U1A: not 3,3 CD4069UB
  R1: resistor 4,3 6,3 10k
  C1: capacitor 6,3 6,5 1n
  G1: ground 6,5
  M1: voltmeter 4,4 4,6 l=$\mathrm{CH1}$
  G2: ground 4,6
  M2: voltmeter 10,4 10,6 l=$\mathrm{CH2}$
  G3: ground 10,6
  U1B: not 9,3 CD4069UB
  R2: resistor 10,3 12,3 10k
  C2: capacitor 12,3 12,5 1n
  G4: ground 12,5
  U1C: not 14,3 CD4069UB
  R3: resistor 15,3 17,3 10k
  C3: capacitor 17,3 17,5 1n
  G5: ground 17,5
wires:
  - U1A.out -- 4,3
  - 4,3 -- 4,4
  - 6,3 -- U1B.in
  - U1B.out -- 10,3
  - 10,3 -- 10,4
  - 12,3 -- U1C.in
  - U1C.out -- 15,3
  - 17,3 -- 18,3
  - 18,3 -- 18,7
  - 18,7 -- 1,7
  - 1,7 -- 1,3
  - 1,3 -- U1A.in
notes:
  - text 9,7.6 small: "PIN 14 (VDD) は +5V、PIN 7 (VSS) と PIN 9・11・13 は GND"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/15-ring-oscillator.svg)

- 図1 は 3 つのインバータ U1A・U1B・U1C (同じ CD4069UB の中) と、各段の R1〜R3・C1〜C3。C3 から先の線が下を回って U1A の入力へ戻る輪
- CD4069UB はバッファの無いインバータ (UB) で、入力がゆっくり変わっても出力が暴れにくい。74HC04 (バッファ付き) は入力の変化を 4.5 V で 500 ns 以内にするよう
  決められていて (データシートの推奨動作条件)、この題の数 µs (µ はマイクロ) かけて変わる入力には向かない
- CH1 は 1 段目の出力 (2 番)、CH2 は 2 段目の出力 (4 番)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (R は隣の列へ立てて、C は下の − レールへ)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1-, 1+, 2+, 2-]
  U1: dip14 @ e12 CD4069UB
  R1: resistor g13 g14 10k cap=left
  C1: capacitor j14 -b14 1n
  R2: resistor g15 g16 10k cap=right
  C2: capacitor j16 -b16 1n
  R3: resistor i17 i12 10k cap=right
  C3: capacitor j12 -b12 1n
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - -t1 -- -b1 black
  - +t12 -- a12 red
  - a13 -- -t13 black
  - a15 -- -t15 black
  - a17 -- -t17 black
  - j18 -- -b18 black
  - SC.1+ -- j13 orange
  - SC.2+ -- j15 green
  - SC.1- -- -b10 black
  - SC.2- -- -b20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/15-ring-oscillator.svg)

図2 は CD4069UB を溝をまたいで 12〜18 列に挿した (切り欠きを左、1 番が左下の `f12`)。使うのは下の側のインバータ 3 つ (1→2、3→4、5→6 番)。

- 電源は AD3 の Supplies (V+ を 5 V)。14 番 VDD (`e12`) を上の + レールへ、7 番 VSS (`f18`) を下の − レールへ。上と下の − レールは 1 列でつなぐ
- **使わないインバータの入力 (9・11・13 番) は GND へ** (上の − レールへ黒い線)。浮かせると入力が中途の電圧になり、電流が増えたり出力が揺れたりする。出力 (8・10・12 番) は何もつながない
- R1 (`g13`–`g14`) は 2 番の列から 3 番の列へ、R2 (`g15`–`g16`) は 4 番から 5 番へ、隣の列に渡して挿す。R3 (`i17`–`i12`) は 6 番から 1 番へ戻る
- C1〜C3 は各段の入力の列 (14・16・12 列) から下の − レールへ縦に挿す
- Scope の 1+ (橙) は 2 番の列 (`j13`)、2+ (緑) は 4 番の列 (`j15`)。1− と 2− は下の − レールへ

## 計器の設定

オシロには AD3 の Scope を使う。31 kHz の方形波の周期と、段から段への遅れを見る題で、10 MHz よりずっと遅いから。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (1 段目の出力、2 番) | DC、2 V/div、0 V を中央に |
| Scope CH2 (2 段目の出力、4 番) | DC、2 V/div、0 V を下の端に |
| Time | 10 µs/div (100 µs に約 3 周期) |
| Trigger | CH1、立ち上がり、2.5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 段目 (CH1) と 2 段目 (CH2) — 約 31 kHz、2 段目は 5.4 µs 遅れて逆向き
time: 10us/div
trigger: ch1 rising 2.5V
ch1: {wave: square 30.98kHz 2.4V offset 2.5V, range: 2V/div, position: 0div}
ch2: {wave: ch1 | delay 5.38us | invert | offset 5V, range: 2V/div, position: -4div}
cursors: [0, 5.38us]
measure: [freq, vmax, vmin, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/15-ring-oscillator.svg)

図3 は LTspice の値で描いた想定の波形で、実測ではない。CH1 が上がってから 5.4 µs (カーソルの間隔) で CH2 が下がる。これが 1 段の遅れ t<sub>d</sub> で、
6 倍 (32.3 µs) が 1 周期。出力の High と Low は 50 % ずつ。2 つの波は同じ尺度 (2 V/div) で、重ならないよう 0 V の位置だけを上下にずらした。

R と C の間 (各段の入力。例えば 3 番の列) を CH2 で見ると、方形波ではなく、1.0 V と 4.0 V の間を指数の曲線で上下する波になる。
しきい値 2.5 V を挟んで上下に 1.5 V ずつで、次の段が切り替わった瞬間に向きが変わる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | CMOS インバータ (バッファ無し、6 回路) | CD4069UB |
| R1, R2, R3 | 抵抗 | 10 kΩ |
| C1, C2, C3 | セラミックコンデンサ | 1 nF (102) |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+/2+ |

## 見るべき値

1 段の遅れは、C の電圧が 1.0 V (前の切り替わりの所) から、出力の 4.9 V へ向かって充電され、しきい値 2.5 V に届くまでの時間。
R に IC の出力の抵抗 (1 kΩ ほど。仮定) を足した 11 kΩ と C の時定数 τ (タウ) = 11 µs で:

t<sub>d</sub> ≈ τ × ln((4.9 − 1.0) / (4.9 − 2.5)) = 11 µs × ln(1.63) ≈ **5.3 µs**、f = 1 / (6 × 5.3 µs) ≈ **31 kHz**

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 発振の周波数 (CH1) | 約 31 kHz | 1 / (2 × 3 × t<sub>d</sub>)。IC だけの輪 (3 MHz ほど) の 100 分の 1 |
| 1 段の遅れ (CH1 の立ち上がりから CH2 の立ち下がり) | 約 5.4 µs | R と C で決まる。周期の 6 分の 1 |
| 出力の High の割合 | 約 50 % | 3 段とも同じ R・C なので、上がりと下がりが同じ時間 |
| 各段の入力 (R と C の間) の振れ | 約 1.0〜4.0 V | しきい値 (2.5 V) の上下に同じだけ |
| C1〜C3 を 2.2 nF に替えたとき | 約 14 kHz | 周波数は C に反比例 (2.2 倍で 1/2.2) |

CD4069UB のしきい値は電源の半分の近くで個体ごとに少しずれるので、周波数も 1 割ほどずれてよい (目安)。5 段 (インバータを 2 つ足す) にすると、
周波数は 3/5 になる。CD4069UB は入力が電源の半分の近くにいる間、中で電源から GND へ電流が流れるので、この回路の電源の電流は静かなときより多い (数 mA の目安)。

## LTspice での確かめ

`sim/15-ring-oscillator.cir` で図1 を過渡解析で走らせ、周波数・High の割合・1 段の遅れ・各点の振れを読んだ。
CD4069UB は動作の模型 (しきい値 2.5 V、利得 約 25 倍、出力の抵抗 1 kΩ、入力の容量 10 pF) で、データシートの値から置いた仮定であり、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 周波数 (C 1 nF) | 約 31 kHz | 30.98 kHz | 合う |
| 周波数 (C 2.2 nF) | 約 14 kHz | 14.16 kHz | 合う (1 nF の 1/2.19) |
| 1 段の遅れ (C 1 nF) | 約 5.3〜5.4 µs | 5.38 µs | 合う |
| 1 段の遅れ (C 2.2 nF) | 約 12 µs | 11.8 µs | 合う |
| 出力の High の割合 | 約 50 % | 50.0 % | 合う |
| 出力の振れ | 0.1〜4.9 V | 0.10〜4.90 V | 合う (模型に置いた出力の抵抗の分) |
| 各段の入力の振れ | 約 1.0〜4.0 V | 1.00〜4.00 V | 合う |

## 出典

自作。

参考: [Ring oscillator (Wikipedia)](https://en.wikipedia.org/wiki/Ring_oscillator)、[CD4069UB データシート (Texas Instruments, SCHS054E)](https://www.ti.com/lit/ds/symlink/cd4069ub.pdf)、[SN74HC04 データシート (Texas Instruments, SCLS078H)](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf)
