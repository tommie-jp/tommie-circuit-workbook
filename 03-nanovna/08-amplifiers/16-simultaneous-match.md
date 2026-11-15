---
book: nanovna
chapter: 8
id: 8-16
title: 入出力を同時に整合する
tier: 200
source: 自作。2SC3355 の定格は NEC (現 Renesas) のデータシート
board: PF
device: H4
---

# 8-16 入出力を同時に整合する

> **値は LTspice と式で出したもので、実機では測っていない。** 2SC3355 の模型 (hFE 100・f<sub>T</sub> 約 7 GHz) は仮定。

12-6 では受け身の負荷を 1 つだけ整合した。アンプは**入力と出力の 2 か所**に整合が要り、しかも**片方の整合がもう片方の見え方を変える**
(S12 (逆方向の伝達) が 0 でない限り、出力に付けた回路が入力のインピーダンスを動かす)。この 2 つを同時に満たす整合が
**同時共役整合** (simultaneous conjugate match) で、そのとき利得は最大有能電力利得 (MAG) になる。
この題では 2SC3355 の 1 段を 21 MHz で考え、S パラメータ (8-4 で測る量) から同時共役整合の点を計算し、入力と出力に L 形を付けて
S11 と S22 が同時に下がり、S21 が MAG に届くことを VNA で確かめる。

## この実験で確かめる式

アンプの S パラメータ (21 MHz、下の回路の Q1 にバイアスと安定化の抵抗を含めた 2 ポート。LTspice で出した値):

| | 大きさ | 複素数 |
| --- | --- | --- |
| S11 | −0.90 dB | 0.901 − j0.024 |
| S21 | +10.48 dB | −3.342 − j0.035 |
| S12 | −48.7 dB | 0.00005 + j0.00368 |
| S22 | −1.87 dB | 0.805 + j0.049 |

**安定か** (8-5): K = (1 − \|S11\|² − \|S22\|² + \|Δ\|²) / (2 \|S12 S21\|) = **2.71** (Δ = S11 S22 − S12 S21、\|Δ\| = 0.73)。
K > 1 かつ \|Δ\| < 1 なので、どんな受け身の整合を付けても発振しない。**これを確かめてからでないと同時共役整合の点は求まらない**
(K < 1 では解が無い)。安定にしているのはコレクタの R<sub>S</sub> (470 Ω (オーム)、C<sub>S</sub> で直流を切る) と、エミッタの R<sub>E</sub> (22 Ω) で、
R<sub>S</sub> を外すと K = 0.06 で不安定になる (LTspice)。

**同時共役整合の点** (Γ (ガンマ) は 50 Ω で正規化した反射係数):

- B<sub>1</sub> = 1 + \|S11\|² − \|S22\|² − \|Δ\|²、C<sub>1</sub> = S11 − Δ S22*。**Γ<sub>MS</sub> = (B<sub>1</sub> − √(B<sub>1</sub>² − 4\|C<sub>1</sub>\|²)) / (2 C<sub>1</sub>)**
- 出力の Γ<sub>ML</sub> も 1 と 2 を入れ替えた同じ形

数を入れると Γ<sub>MS</sub> = 0.905 + j0.052 (信号源の側に見せる Z<sub>S</sub> = **759 + j444 Ω**)、Γ<sub>ML</sub> = 0.816 + j0.010 (負荷の側に見せる Z<sub>L</sub> = **493 + j30 Ω**)。
このとき **MAG = \|S21\| / \|S12\| × (K − √(K² − 1)) = 22.4 dB**。整合なし (50 Ω のまま) の S21 は 10.5 dB なので、整合で 12 dB 増える。

**別々に整合すると**: 入力を S11 の共役 (Q1 の入力 904 − j226 Ω の共役)、出力を S22 の共役に合わせる「片側ずつの整合」は、
S12 = 0 とみなした近似。ここでは S12 が −49 dB と小さいが、それでも Z<sub>S</sub> は 904 + j226 Ω と 759 + j444 Ω で大きく違う。
S11 が 1 に近い (入力が高い抵抗) ので、わずかな S12 でも整合点が大きく動く。片側ずつの整合の誤差の目安 (単方向化の指標 U = 0.14) は利得で −1.1〜+1.3 dB。

**L 形の値** (12-6 と同じく、G の円と R の円で解く): 入力は 50 Ω から Z<sub>S</sub> へ、直列 L<sub>i</sub> = **1.67 µH**・並列 C<sub>i</sub> = **28.4 pF**。
出力は Z<sub>L</sub> から 50 Ω へ、並列 C<sub>o</sub> = **44.7 pF**・直列 L<sub>o</sub> = **1.13 µH**。E12 の 1 本では整合がずれる (1.8 µH・27 pF・1.2 µH・47 pF で
S11 −18 dB・S22 −15 dB、LTspice) ので、**2 本ずつで作る**: L<sub>i</sub> = 1.5 µH + 150 nH、C<sub>i</sub> = 27 pF + 1.5 pF、C<sub>o</sub> = 39 pF + 5.6 pF、L<sub>o</sub> = 1.0 µH + 120 nH。

**バイアス**: R1 (6.8 kΩ) と R2 (2.2 kΩ) でベースは約 1.2 V、エミッタの電流は約 13 mA (計算の目安)。コレクタは L1 (10 µH) から 5 V。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2SC3355 の段に入出力の L 形の整合 (21 MHz)
parts:
  J1: sma 1,6 mirror CH0
  Li1: inductor 2,6 3,6 1.5u
  Li2: inductor 4,6 5,6 150n
  Ci1: capacitor 6,6 6,8 27p
  Ci2: capacitor 8,6 8,8 1.5p
  Cin: capacitor 9,6 10,6 100n
  R1: resistor 11,2 11,4 6.8k
  R2: resistor 10,7.5 10,9 2.2k
  Q1: npn 12,6 2SC3355
  RE: resistor 12,8 12,9 22
  L1: inductor 13,2 13,4 10u
  RS: resistor 14,6 14,7.5 470
  CS: capacitor 14,8 14,9 100n
  Cout: capacitor 15,5 16,5 100n
  Co1: capacitor 17,5 17,7 39p
  Co2: capacitor 19,5 19,7 5.6p
  Lo1: inductor 20,5 21,5 1u
  Lo2: inductor 22,5 23,5 120n
  J2: sma 24,5 CH1
  VCC: vcc 11,1 5V
  G1: ground 1,7
  G2: ground 6,8
  G3: ground 8,8
  G4: ground 10,9
  G5: ground 12,9
  G6: ground 14,9
  G7: ground 17,7
  G8: ground 19,7
  G9: ground 24,6
wires:
  - J1.1 -- 2,6
  - 3,6 -- 4,6
  - 5,6 -- 6,6 -- 8,6 -- 9,6
  - 10,6 -- 11,6
  - 11,4 -- 11,6
  - 10,6 -- 10,7.5
  - 11,6 -- Q1.B
  - 11,1 -- 11,2
  - 11,1 -- 13,1 -- 13,2
  - 13,4 -- 13,5
  - Q1.C |- 13,5
  - 13,5 -- 15,5
  - 14,5 -- 14,6
  - 14,7.5 -- 14,8
  - Q1.E -- 12,8
  - 16,5 -- 17,5 -- 19,5 -- 20,5
  - 21,5 -- 22,5
  - 23,5 -- J2.1
  - J1.2 -- 1,7
  - J2.2 -- 24,6
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/16-simultaneous-match.svg)

- 左から入力の L 形 (L<sub>i1</sub>・L<sub>i2</sub> が直列、C<sub>i1</sub>・C<sub>i2</sub> が並列)、Q1 の段、出力の L 形 (C<sub>o1</sub>・C<sub>o2</sub> が並列、L<sub>o1</sub>・L<sub>o2</sub> が直列)
- **R<sub>S</sub> と C<sub>S</sub> は安定化** (コレクタを 470 Ω で交流的に GND に落とし、出力の Q を下げる)。外すと発振のおそれ
- 上の S パラメータは C<sub>in</sub>・R1・R2・Q1・R<sub>E</sub>・L1・R<sub>S</sub>・C<sub>S</sub>・C<sub>out</sub> をまとめた 2 ポートの値

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  silk: board
  slots: on
title: 図2 ユニバーサル基板に組む (部品面。端面 SMA 2 つ)
parts:
  J1: sma/female-edge a10 09
  Li1: inductor b10 d10 1.5u
  Li2: inductor e10 g10 150n
  Ci1: capacitor h10 h7 27p
  Ci2: capacitor j10 j7 1.5p
  Cin: capacitor k10 l10 100n
  R2: resistor m10 m7 2k2
  R1: resistor n13 n10 6k8
  Q1: transistor o10 p10 q10 2SC3355
  RE: resistor p9 p6 22
  L1: inductor q11 q14 10u
  RS: resistor r10 r8 470
  CS: capacitor s8 s6 100n
  Cout: capacitor s10 u10 100n
  Co1: capacitor v10 v7 39p
  Co2: capacitor w10 w7 5p6
  Lo1: inductor w11 w14 1u
  Lo2: inductor x16 x12 120n
  J2: sma/female-edge x11 y10
  PSU:
    type: device
    at: f21
    label: 電源 5V
    pins: ["-", "+"]
wires:
  - a10 -- b10
  - d10 -- e10
  - g10 -- h10
  - h10 -- j10
  - j10 -- k10
  - l10 -- m10
  - m10 -- n10
  - n10 -- o10
  - p10 -- p9
  - q10 -- q11
  - q10 -- r10
  - r10 -- s10
  - r8 -- s8
  - u10 -- v10
  - v10 -- w10
  - w10 -- w11
  - w14 -- w16
  - w16 -- x16
  - x12 -- x11
  - n13 -- n15 red
  - n15 -- q15 red
  - q14 -- q15 red
  - PSU.+ -- g18 red
  - g18 -- n18 red
  - n18 -- n15 red
  - PSU.- -- f18 black
  - f18 -- c18 black
  - c18 -- 018 black
  - 018 -- 011 black
  - 09 -- b9 black
  - b9 -- b6 black
  - b6 -- h6 black
  - h7 -- h6 black
  - h6 -- j6 black
  - j7 -- j6 black
  - j6 -- m6 black
  - m7 -- m6 black
  - m6 -- p6 black
  - p6 -- s6 black
  - s6 -- v6 black
  - v7 -- v6 black
  - v6 -- w6 black
  - w7 -- w6 black
  - w6 -- y6 black
  - y6 -- y10 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/16-simultaneous-match.svg)

- 信号は 10 行目を左から右へ。GND の筋は 6 行目、5 V の筋は 15 行目 (赤)。電源の − は左の縁のパッドを伝って J1 の腕 (GND) へ
- Q1 (2SC3355) は `o10` (B)・`p10` (E)・`q10` (C) の順。**2SC3355 は印字面を手前にして B・E・C** (2SC1815 の E・C・B と違う)
- L<sub>o1</sub>・L<sub>o2</sub> は右の縁で上へ折り返して J2 へ。21 MHz では折り返しの線の長さは効かない
- L<sub>i1</sub>・L<sub>o1</sub> はアキシアルのインダクタ。C<sub>i</sub>・C<sub>o</sub> は C0G のセラミック。21 MHz は perfboard の治具で測れる (3-6)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN 高周波トランジスタ (TO-92) | 2SC3355 |
| Li1, Li2 | アキシアルのインダクタ | 1.5 µH + 150 nH (直列で 1.65 µH) |
| Ci1, Ci2 | セラミックコンデンサ (C0G) | 27 pF + 1.5 pF (並列で 28.5 pF) |
| Co1, Co2 | セラミックコンデンサ (C0G) | 39 pF + 5.6 pF (並列で 44.6 pF) |
| Lo1, Lo2 | アキシアルのインダクタ | 1.0 µH + 120 nH (直列で 1.12 µH) |
| L1 | アキシアルのインダクタ (チョーク) | 10 µH |
| R1, R2 | 抵抗 (1/4 W) | 6.8 kΩ、2.2 kΩ |
| RE | 抵抗 (1/4 W) | 22 Ω |
| RS | 抵抗 (1/4 W) | 470 Ω (安定化) |
| Cin, Cout, CS | 積層セラミックコンデンサ | 0.1 µF (104) |
| J1, J2 | SMA コネクタ (端面実装) | — |
| — | 電源 | 5 V (約 15 mA) |

## 掃引の設定

計器は VNA (NanoVNA-H4。LiteVNA64 でも同じ)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 15〜27 MHz |
| 点数 | 201 |
| 校正 | SOLT。CH0 に 20 dB の SMA アッテネータを付けたまま (THRU も) |
| 表示 | S21 と S11 の Log Mag。S22 は基板を裏返して S11 として測る (8-2) |
| 順番 | 整合なし (L<sub>i</sub>・L<sub>o</sub> の代わりに線、C<sub>i</sub>・C<sub>o</sub> を付けない) で S パラメータを測り、K を確かめてから整合を付ける |

**CH0 にアッテネータを付ける理由**: 利得 22 dB で CH0 の出力をそのまま入れると、出力が数 dBm になって Q1 が飽和に近づく (13 mA × 約 470 Ω の振れ)。
20 dB 落として小信号のまま測る。出力は CH1 の上限 (0-3) より十分小さい。

入力の側は、出力が整合しているときの Q1 の入力 (Z<sub>S</sub> の共役 = 759 − j444 Ω、21 MHz で 759 Ω と 17.1 pF の直列) を負荷にした**等価回路**で描ける。
21 MHz の 1 点でだけ本物と同じで、ほかの周波数では Q1 の入力の変化を描いていない。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 15M-27M 201
title: 図3 入力の S11 (21 MHz でだけ正しい等価回路) — 21 MHz で深い谷
dut:
  - series L 1.65u
  - shunt C 28.5p
  - series C 17.07p
  - series R 759
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 19M
  - 21M
  - 23M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/16-simultaneous-match.svg)

S21・S22 は利得があって `dut:` で描けないので、LTspice で計算した線を図4 に置く。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 同時共役整合したアンプの S21・S11・S22 (LTspice)
x: 周波数 Hz 15M..27M
y:
  - dB
lines:
  S21 dB:
    - 15M 16.74
    - 17M 18.97
    - 19M 21.21
    - 20M 22.03
    - 21M 22.40
    - 22M 22.16
    - 23M 21.36
    - 25M 18.76
    - 27M 15.66
  S11 dB:
    - 15M -2.49
    - 17M -3.91
    - 19M -7.70
    - 20M -12.60
    - 21M -33.58
    - 22M -13.95
    - 23M -8.18
    - 25M -3.92
    - 27M -2.31
  S22 dB:
    - 15M -3.64
    - 17M -5.27
    - 19M -9.27
    - 20M -14.19
    - 21M -33.43
    - 22M -16.28
    - 23M -10.37
    - 25M -5.87
    - 27M -3.87
notes:
  - level 22.4dB
  - mark 21M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/graph/16-simultaneous-match.svg)

- **S11 と S22 が同じ 21 MHz で同時に谷**になり、S21 はそこで 22.4 dB (= MAG) の山。整合の帯域 (S11 が −10 dB より下) は約 20〜22.5 MHz と狭い。
  Q1 の入力が 900 Ω 近い高い抵抗で、50 Ω からの変換比が大きい (L 形の Q が約 4) ため
- 図3 の等価回路の谷は 21 MHz の 1 点でだけ本物と合う。帯域の形は図4 の LTspice の線で見る

## 見るべき値

計算値 (LTspice。2 本ずつで作った値)。

| 周波数 | S21 | S11 | S22 |
| --- | --- | --- | --- |
| 19 MHz | +21.2 dB | −7.7 dB | −9.3 dB |
| 21 MHz | **+22.4 dB** | **−33.6 dB** | **−33.4 dB** |
| 23 MHz | +21.4 dB | −8.2 dB | −10.4 dB |

| 比べ (21 MHz) | S21 | S11 | S22 |
| --- | --- | --- | --- |
| 整合なし | +10.5 dB | −0.9 dB | −1.9 dB |
| 計算の値そのもの (1.67 µH・28.4 pF・44.7 pF・1.13 µH) | +22.4 dB | −50.6 dB | −55.2 dB |
| E12 の 1 本ずつ (1.8 µH・27 pF・47 pF・1.2 µH) | +22.2 dB | −18.3 dB | −15.1 dB |

- **整合で S21 が 12 dB 増える**のが一番大きな変化。増えた分は、入力と出力の反射で捨てていた電力
- **入力だけ整合して出力を 50 Ω のまま**にすると、入力の谷は 21 MHz からずれ、浅くなる (出力の整合が入力の見え方を変える)。
  組むときは出力の L 形を先に付け、次に入力の L 形を付けて、最後に両方を少しずつ詰める
- S11 と S22 の谷がずれるなら、C<sub>i</sub> と C<sub>o</sub> を 1 pF ずつ替えて詰める。谷が浅いのは L の損失 (Q) とトランジスタの模型の違い

## LTspice での確かめ

`sim/16-simultaneous-match-sparam.cir` で Q1 の段の S パラメータ (21 MHz、前向きと後ろ向きの 2 回)、`sim/16-simultaneous-match.cir` で
整合を付けたアンプの S11・S21・S22 を `.ac` で読んだ。K・Γ<sub>MS</sub>・Γ<sub>ML</sub>・MAG は、その S パラメータから上の式で計算した。
2SC3355 の模型 (Q3355) は仮定、コイルは損失なし。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| K (R<sub>S</sub> 470 Ω) | 2.71 | S パラメータ (LTspice) から計算 | — |
| K (R<sub>S</sub> を外す) | 不安定 | 0.06 | 合う |
| MAG | 22.4 dB (式) | S21 22.40 dB (計算の値の L 形) | 合う |
| S11・S22 (21 MHz、計算の値) | 0 (式) | −50.6 dB・−55.2 dB | 合う |
| S11・S22 (21 MHz、2 本ずつ) | −33.6 dB・−33.4 dB | 同じ (図4) | 合う |
| 図3 の S11 (21 MHz、等価回路) | −35.08 dB (49.7 − j1.7 Ω) | アンプ全体で −33.58 dB | 合う (等価回路は Q1 の入力を 21 MHz の値に固定したもの) |
| S12 (整合後、21 MHz) | — | −36.8 dB | 逆方向は整合後も小さい |

## 出典

- [NEC, 2SC3355 データシート (P10355EJ3V1DS00)](https://static.chipdip.ru/lib/225/DOC000225164.pdf): 定格、f<sub>T</sub>、ピンの並び B・E・C
- 同時共役整合と MAG の式は、マイクロ波のアンプの設計の標準の式 (G. Gonzalez, *Microwave Transistor Amplifiers* などの教科書にある)

参考: [Impedance matching (Wikipedia)](https://en.wikipedia.org/wiki/Impedance_matching)、[Smith chart (Wikipedia)](https://en.wikipedia.org/wiki/Smith_chart)
