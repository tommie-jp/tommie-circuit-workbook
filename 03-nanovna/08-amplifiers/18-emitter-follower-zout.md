---
book: nanovna
chapter: 8
id: 8-18
title: エミッタフォロアの出力インピーダンス
tier: 200
source: 自作
board: PF
device: H4
---

# 8-18 エミッタフォロアの出力インピーダンス

> **値は式と LTspice で出したもので、実機では測っていない。** 2SC1815 の模型 (hFE 200・f<sub>T</sub> 約 80〜90 MHz) は仮定。

**エミッタフォロア** (コレクタ接地) は電圧の利得が 1 で、出力のインピーダンスが低い。低い抵抗の負荷や 50 Ω (オーム) の線を駆動する
バッファに使う。ところが、その出力のインピーダンスは**周波数とともに増え、しかもコイルのように見える** (誘導性)。
出力にコンデンサの負荷を付けると、このコイルと共振してリンギングや発振のもとになる。
この題では、エミッタを VNA の CH0 で直接覗き (1 ポートの S11)、出力のインピーダンスの抵抗分と誘導性の分を読む。

## この実験で確かめる式

ベースの側の信号源の抵抗を R<sub>s</sub> (ここでは R<sub>B</sub> = 1 kΩ。R1・R2 の分圧は C<sub>B</sub> で交流的に GND)、トランジスタの電流利得を β (ベータ) とする。

- **低い周波数**: Z<sub>out</sub> ≈ r<sub>e</sub> + (R<sub>s</sub> + r<sub>bb′</sub>) / β<sub>0</sub>。r<sub>e</sub> = 26 mV / I<sub>E</sub>
- **周波数を上げると** β が f<sub>T</sub> / f で下がるので、(R<sub>s</sub> + r<sub>bb′</sub>) / β の項が jω (R<sub>s</sub> + r<sub>bb′</sub>) / ω<sub>T</sub> に変わる。
  **Z<sub>out</sub> ≈ r<sub>e</sub> + (R<sub>s</sub> + r<sub>bb′</sub>) / β<sub>0</sub> + jω L<sub>eq</sub>**、**L<sub>eq</sub> = (R<sub>s</sub> + r<sub>bb′</sub>) / (2π f<sub>T</sub>)**

数を入れる (I<sub>E</sub> = 8.5 mA、β<sub>0</sub> = 200、r<sub>bb′</sub> = 30 Ω、f<sub>T</sub> = 90 MHz):

- r<sub>e</sub> = 26 mV / 8.5 mA = **3.1 Ω**、(1000 + 30) / 200 = **5.2 Ω**。エミッタの抵抗分 1 Ω (模型) を足して約 9.3 Ω、R<sub>E</sub> (180 Ω) と並列で **約 8.9 Ω**
- **L<sub>eq</sub> = 1030 / (2π × 90 MHz) ≈ 1.8 µH**。1 MHz で 11 Ω、10 MHz で 114 Ω (R<sub>E</sub> と並列になって頭打ち)

**R<sub>s</sub> が L<sub>eq</sub> を決める**: R<sub>B</sub> を 51 Ω にすると L<sub>eq</sub> = 81 / (2π × 90 MHz) ≈ 0.14 µH と 13 分の 1 になる。
エミッタフォロアを低いインピーダンスの源で駆動するのは、この誘導性を小さくするため。

**バイアス**: R1・R2 (10 kΩ ずつ) でベースは約 2.24 V、エミッタは約 1.54 V、I<sub>E</sub> = 1.54 / 180 ≈ 8.5 mA (LTspice)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 エミッタフォロアの出力をエミッタから CH0 で覗く (RB 1 kΩ)
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,2 2,4 10k
  R2: resistor 2,6 2,8 10k
  CB: capacitor 4,6 4,8 100n
  RB: resistor 5,5 6.2,5 1k
  Q1: npn 7,5 2SC1815
  RE: resistor 7,8 7,10 180
  Cout: capacitor 8,7 9,7 1u
  J1: sma 11,7 CH0
  CV: capacitor 9,1 9,3 100n
  G1: ground 2,8
  G2: ground 4,8
  G3: ground 7,10
  G4: ground 11,8
  G5: ground 9,3
wires:
  - 2,1 -- 2,2
  - 2,1 -- 7,1 -- 9,1
  - 2,4 -- 2,5 -- 2,6
  - 2,5 -- 4,5 -- 5,5
  - 4,5 -- 4,6
  - 6.2,5 -- Q1.B
  - Q1.C |- 7,1
  - Q1.E -- 7,7
  - 7,7 -- 7,8
  - 7,7 -- 8,7
  - 9,7 -- J1.1
  - J1.2 -- 11,8
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/18-emitter-follower-zout.svg)

- 図は左がベース側 (バイアスと R<sub>B</sub>)、右がエミッタの出力。ふだんの信号は左から右へ流れ、VNA は右の J1 から逆向きに覗く
- C<sub>B</sub> (0.1 µF) が R1・R2 の分圧を交流的に GND に落とすので、ベースが見る信号源の抵抗は R<sub>B</sub> だけ
- C<sub>out</sub> (1 µF) はエミッタの直流 (1.5 V) を CH0 から切る。100 kHz で 1.6 Ω
- C<sub>V</sub> (0.1 µF) はコレクタを交流的に GND にする (コレクタ接地)

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  silk: board
  slots: on
title: 図2 ユニバーサル基板に組む (部品面。エミッタを左の SMA へ)
parts:
  J1: sma/female-edge a10 09
  Cout: capacitor c10 e10 1u
  RE: resistor g10 g7 180
  Q1: transistor i10 j10 k10 2SC1815
  RB: resistor l10 o10 1k
  R1: resistor o11 o14 10k
  R2: resistor p10 p7 10k
  CB: capacitor q10 q7 100n
  CV: capacitor s12 s10 100n
  PSU:
    type: device
    at: s21
    label: 電源 5V
    pins: ["+", "-"]
wires:
  - a10 -- c10
  - e10 -- g10
  - g10 -- i10
  - k10 -- l10
  - o10 -- o11
  - o10 -- p10
  - p10 -- q10
  - j10 -- j14 red
  - j14 -- o14 red
  - o14 -- s14 red
  - s14 -- s12 red
  - PSU.+ -- s18 red
  - s18 -- s14 red
  - PSU.- -- t18 black
  - t18 -- t6 black
  - 09 -- b9 black
  - b9 -- b6 black
  - b6 -- g6 black
  - g7 -- g6 black
  - g6 -- p6 black
  - p7 -- p6 black
  - p6 -- q6 black
  - q7 -- q6 black
  - q6 -- s6 black
  - s10 -- s6 black
  - s6 -- t6 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/18-emitter-follower-zout.svg)

- J1 (CH0) を左の縁に置き、エミッタの出力を SMA へ最短で出す。Q1 (2SC1815) は `i10` (E)・`j10` (C)・`k10` (B) の順 (印字面を手前に E・C・B)
- **R<sub>B</sub> を 51 Ω に差し替えて** もう一度測る (下の表の 2 段め)。差し替えは `l10`〜`o10` の 1 本だけ
- C<sub>V</sub> はコレクタの 5 V の筋の端に。ここが浮くとコレクタ接地にならず、Z<sub>out</sub> が上の式から外れる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ (TO-92) | 2SC1815 |
| R1, R2 | 抵抗 (1/4 W) | 10 kΩ |
| RB | 抵抗 (1/4 W) | 1 kΩ (差し替え用に 51 Ω も) |
| RE | 抵抗 (1/4 W) | 180 Ω |
| CB, CV | 積層セラミックコンデンサ | 0.1 µF (104) |
| Cout | 積層セラミックコンデンサ | 1 µF (105) |
| J1 | SMA コネクタ (端面実装) | — |
| — | 電源 | 5 V (約 9 mA) |

## 掃引の設定

計器は VNA (NanoVNA-H4。LiteVNA64 でも同じ)。1 ポート (S11) だけを使う。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜5 MHz (図3)。続けて 30 MHz まで広げて、上で抵抗が増えて頭打ちになるのを見る |
| 点数 | 201 |
| 校正 | SOL を CH0 のケーブルの先で |
| 表示 | S11 の R と X (インピーダンスの実部と虚部) と Smith |

**CH0 の出力の大きさに注意**: CH0 の波 (0 dBm 以下) はエミッタに直接かかる。エミッタの交流の電流 (数 mA) が I<sub>E</sub> (8.5 mA) に近づくと
トランジスタが切れかけ、読みが動く。VNA の出力を下げられる機種なら下げる。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 100k-5M 201
title: 図3 エミッタの Z (等価回路、RB 1 kΩ) — 抵抗 9 Ω と 1.8 µH
dut:
  - series C 1u
  - shunt R 180
  - series R 9.75 esl 1.8u
  - short
traces:
  - S11 r
  - S11 x
  - S11 smith
markers:
  - 100k
  - 1M
  - 3M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/18-emitter-follower-zout.svg)

- 等価回路は R<sub>E</sub> (180 Ω) と、9.75 Ω + 1.8 µH の直列の並列 (上の式の 2 項)。**1 MHz で X が R と同じくらいになり、上ではコイルとして振る舞う**
- 数 MHz より上では、本物のトランジスタの β の下がり方が単純な式から外れる (下の LTspice の表)。等価回路は 3 MHz くらいまでの目安

## 見るべき値

LTspice の値 (CH0 から見たエミッタの Z。C<sub>out</sub> と R<sub>E</sub> を含む)。

| 周波数 | Z (R<sub>B</sub> 1 kΩ) | Z (R<sub>B</sub> 51 Ω) |
| --- | --- | --- |
| 100 kHz | 9.3 − j0.5 Ω | 4.5 − j1.6 Ω |
| 1 MHz | 10.3 + j11.5 Ω | 4.5 + j0.8 Ω |
| 10 MHz | 68 + j65 Ω | 6.2 + j9.1 Ω |
| 30 MHz | 127 + j40 Ω | 16.7 + j21.5 Ω |

- **1 MHz の X から L<sub>eq</sub> を読む**: 11.5 Ω / (2π × 1 MHz) = 1.8 µH。式の 1.8 µH と合う。逆に、測った L<sub>eq</sub> と R<sub>s</sub> から f<sub>T</sub> が出る
  (f<sub>T</sub> = (R<sub>s</sub> + r<sub>bb′</sub>) / (2π L<sub>eq</sub>))
- R<sub>B</sub> を 51 Ω にすると、10 MHz の X は 65 Ω から 9 Ω に下がる。**出力に容量 (ケーブルや次段の入力) を付けるなら、R<sub>B</sub> の小さいほうが共振しにくい**
- 低い周波数の抵抗分 (9.3 Ω・4.5 Ω) から r<sub>e</sub> と β が読める。I<sub>E</sub> を変える (R<sub>E</sub> を替える) と r<sub>e</sub> の分だけ動く

## LTspice での確かめ

`sim/18-emitter-follower-zout.cir` で図1 を CH0 から `.ac` にかけ、Z = V(o) / I を読んだ (信号源 2 V・50 Ω)。R<sub>B</sub> は 1 kΩ と 51 Ω の 2 通り。
2SC1815 の模型 (Q1815) は 8-1 などと同じ仮定の値。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| エミッタの電圧・I<sub>E</sub> | 約 1.54 V・8.5 mA | 1.535 V (8.53 mA) | 合う |
| Z の実部 (100 kHz、R<sub>B</sub> 1 kΩ) | 約 8.9 Ω (式) | 9.25 Ω | 近い (式は r<sub>e</sub> を 26 mV で丸めた) |
| L<sub>eq</sub> (1 MHz の X から) | 1.8 µH (式) | 1.82 µH (11.45 Ω) | 合う |
| Z の実部 (100 kHz、R<sub>B</sub> 51 Ω) | 約 4.3 Ω (式: 3.0 + 0.4 + 1 Ω) | 4.47 Ω | 合う |
| 図3 の等価回路 (100 kHz・1 MHz) | 9.3 − j0.6 Ω・9.9 + j10.0 Ω | 9.25 − j0.50 Ω・10.28 + j11.45 Ω | 近い (等価回路は 1 MHz で X を 13 % 小さく出す) |

## 出典

自作。エミッタフォロアの出力インピーダンスが誘導性になることは、トランジスタのハイブリッド π の等価回路から出る標準の結果。

参考: [Common collector (Wikipedia)](https://en.wikipedia.org/wiki/Common_collector)
