---
book: analog-discovery
chapter: 5
id: 5-17
title: 位相余裕 (ループを切る)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-17 位相余裕 (ループを切る)

5-14 では、容量負荷のフォロアの周波数特性に立つ山の高さから、帰還の余裕を間接に推し量った。
この題では帰還の輪 (ループ) を 1 か所で切り、**ループを 1 周した利得 T (ループ利得) を Network で直接**測る。
|T| が 1 (0 dB) になる周波数で、位相が −180° まであと何度残っているかが**位相余裕**。
5-10 では発振回路の帰還路を切って同じことをした。

アンプは直流の動作点を保たないと飽和するので、輪を**直流だけ閉じて交流では切る**。
出力から − 入力へ 1 MΩ を戻して直流の帰還を残し、W1 を 1 µF で − 入力へ注入する。1 µF は数 kHz より上で W1 の側を
低いインピーダンスにするので、− 入力の電圧は W1 が決め、1 MΩ を通って戻る交流は無視できる。
CH1 で − 入力、CH2 で出力を見ると、比 CH2/CH1 は −A(f) × (出力の RC の効き) = −T になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フォロアの輪を交流だけ切る (Rdc 1 MΩ で直流を閉じ、Cinj から W1 を注入)
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  G1: ground 1,3
  Cinj: capacitor 1,1 4,1 1u l=$\mathrm{C_{inj}}$
  M1: voltmeter 4,1 4,3 l=$\mathrm{CH1}$
  G2: ground 4,3
  U1: opamp 11,3 +down
  G3: ground 10,5
  Rdc: resistor 9,1 13,1 1meg l=$\mathrm{R_{dc}}$
  CL: capacitor 15,3 15,5 470p l=$\mathrm{C_L}$
  G4: ground 15,5
  M2: voltmeter 17,3 17,5 l=$\mathrm{CH2}$
  G5: ground 17,5
wires:
  - 4,1 -- 9,1
  - 9,1 |- U1.-
  - U1.+ -| 10,5
  - U1.out -- 13,3
  - 13,3 -- 13,1
  - 13,3 -- 15,3 -- 17,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/17-phase-margin.svg)

- U1 は 5-14 と同じ LM358 のフォロアで、出力に C<sub>L</sub> (470 pF。外す・1 nF にも替える)。違うのは帰還の線だけ
- R<sub>dc</sub> (1 MΩ) と C<sub>inj</sub> (1 µF) の角周波数は 1/(2π × 1 MΩ × 1 µF) = 0.16 Hz。掃引の 10 kHz では C<sub>inj</sub> の
  リアクタンスが 16 Ω で、1 MΩ より 5 桁小さい
- 測る比 H = CH2/CH1 = −T。**|H| = 1 の周波数での H の位相が、そのまま位相余裕**になる (T の位相 + 180°)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (CL 470 pF)
board: half
parts:
  U1: dip8 @ f8 LM358
  Rdc: resistor g8 g9 1M cap=left
  CL: capacitor j8 -b8 470p cap=left
  Cinj: capacitor h4 h9 1u
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [W1, 2+, 1+, V-, V+, GND, 1-, 2-]
wires:
  - -b1 -- -t1 black
  - a9 -- a10 green
  - a11 -- -t11 black
  - +t8 -- a8 red
  - j10 -- -b10 black
  - AD.W1 -- j4 yellow
  - AD.2+ -- i8 blue
  - AD.1+ -- i9 orange
  - AD.V- -- j11 purple
  - AD.V+ -- +b22 red
  - +b24 -- +t24 red
  - AD.GND -- -b26 black
  - AD.1- -- -b27 black
  - AD.2- -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/17-phase-margin.svg)

- 5-14 の図2 から、白の帰還の線 (1 番と 2 番の間) を R<sub>dc</sub> (1 MΩ) に替え、W1 を C<sub>inj</sub> (1 µF) を通して 2 番 (IN1−、9 列) へ入れる
- CH1 (1+) は 9 列 (− 入力)、CH2 (2+) は 8 列 (出力)。C<sub>L</sub> は 8 列から下の − レールへ
- 3 番 (IN1+、10 列) は GND。使わない 2 回路目はフォロアにして入力を固定する (5-6 と同じ)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる |
| Wavegen | W1: Amplitude 5 mV、Offset 0 V |
| Network | Start 10 kHz、Stop 3 MHz、Log、Steps 201、Reference: Channel 1。平均を多めに (信号が小さい) |
| 読む所 | 利得が 0 dB を横切る周波数にカーソルを置き、そこの位相を読む |

W1 を 5 mV と小さくするのは、低い周波数でループ利得が大きいため。10 kHz で |T| = 120 倍 (41.6 dB) なので、
出力は 0.6 V<sub>p</sub>。開始を 10 kHz より下げると出力が大きくなりすぎるので、下げるなら W1 も比例して下げる。

0 dB の周波数 (C<sub>L</sub> 470 pF で 861 kHz) の時間波形が図3 (計算値)。CH1 と CH2 は同じ振幅で、CH2 が 26° 進む。
この 26° が位相余裕。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CL 470 pF・861 kHz — 振幅は同じ (|T| 1)、CH2 が 26° 進む = 位相余裕 26°
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 861kHz 5mV, range: 2mV/div}
ch2: {wave: sine 861kHz 5mV phase 26.4deg, range: 2mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/17-phase-margin.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入り。1 回路目を使う) | LM358 |
| R<sub>dc</sub> | 抵抗 (1/4 W、直流の帰還) | 1 MΩ |
| C<sub>inj</sub> | フィルムコンデンサ (105、注入) | 1 µF |
| C<sub>L</sub> | セラミックコンデンサ (C0G、容量負荷) | 470 pF (471) と 1 nF (102) を差し替える |
| — | 電源 | ±5 V (AD3 の Supplies)。入力 0 V の付近で動かすため両電源 |
| — | 計器 | AD3 の W1・Scope 1+ (− 入力)・2+ (出力) |

## 見るべき値

計算値。オペアンプの模型は 5-14 と同じ (GBW 1.2 MHz・第 2 の極 1.63 MHz・R<sub>O</sub> 270 Ω、仮定)。C<sub>L</sub> は CH2 の 24 pF を足した値。

| 負荷 | 0 dB の周波数 | 位相余裕 | 5-14 で見た山 |
| --- | --- | --- | --- |
| C<sub>L</sub> なし (24 pF) | 1.02 MHz | 56° | +0.70 dB |
| C<sub>L</sub> 470 pF | 861 kHz | **26°** | +7.27 dB |
| C<sub>L</sub> 1 nF | 700 kHz | **16°** | +11.5 dB |
| R<sub>iso</sub> 1 kΩ + 470 pF (C<sub>L</sub> を R<sub>iso</sub> の先に) | 857 kHz | 58° | 山なし |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 ループ利得 (上) と位相 (下)。0 dB の所の位相が位相余裕 — 56°・26°・16°
x: 周波数 Hz log 10k..3M
y:
  - 利得 dB -20..45
  - 位相 deg -60..100
lines:
  CL 24 pF dB:
    - 10k 41.58
    - 20k 35.56
    - 50k 27.60
    - 100k 21.57
    - 200k 15.50
    - 300k 11.90
    - 500k 7.21
    - 700k 3.94
    - 1M 0.19
    - 1.5M -4.62
    - 2M -8.45
    - 3M -14.45
  CL 470 pF dB:
    - 10k 41.58
    - 20k 35.56
    - 50k 27.59
    - 100k 21.54
    - 200k 15.38
    - 300k 11.63
    - 500k 6.51
    - 700k 2.66
    - 1M -2.11
    - 1.5M -8.72
    - 2M -14.23
    - 3M -23.03
  CL 1 nF dB:
    - 10k 41.58
    - 20k 35.56
    - 50k 27.57
    - 100k 21.44
    - 200k 15.00
    - 300k 10.85
    - 500k 4.77
    - 700k 0.00
    - 1M -5.84
    - 1.5M -13.52
    - 2M -19.59
    - 3M -28.88
  Riso 1 kΩ + 470 pF dB:
    - 10k 41.58
    - 20k 35.55
    - 50k 27.54
    - 100k 21.34
    - 200k 14.81
    - 300k 10.81
    - 500k 5.65
    - 700k 2.17
    - 1M -1.72
    - 1.5M -6.61
    - 2M -10.46
    - 3M -16.44
  CL 24 pF (位相) deg:
    - 10k 89.6
    - 20k 89.3
    - 50k 88.1
    - 100k 86.3
    - 200k 82.5
    - 300k 78.9
    - 500k 71.8
    - 700k 65.1
    - 1M 56.1
    - 1.5M 43.9
    - 2M 34.5
    - 3M 21.6
  CL 470 pF (位相) deg:
    - 10k 89.2
    - 20k 88.3
    - 50k 85.8
    - 100k 81.7
    - 200k 73.5
    - 300k 65.5
    - 500k 50.2
    - 700k 36.4
    - 1M 18.5
    - 1.5M -4.1
    - 2M -20.0
    - 3M -39.8
  CL 1 nF (位相) deg:
    - 10k 88.7
    - 20k 87.3
    - 50k 83.3
    - 100k 76.6
    - 200k 63.8
    - 300k 52.0
    - 500k 32.0
    - 700k 16.2
    - 1M -1.6
    - 1.5M -21.6
    - 2M -34.8
    - 3M -50.6
notes:
  - level 0dB
  - mark 1.017M
  - mark 861k
  - mark 700k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/17-phase-margin.svg)

分かること:

- **C<sub>L</sub> を足すと、0 dB の周波数は少し下がり、位相余裕は大きく減る。** 利得の線はほとんど変わらないのに、
  R<sub>O</sub> と C<sub>L</sub> の極 (470 pF で 1.19 MHz) が 0 dB の付近の位相だけを削る
- **位相余裕と 5-14 の山は 1 対 1 に対応する。** 56° で +0.7 dB、26° で +7.3 dB、16° で +11.5 dB。
  目安は位相余裕 45° 以上 (山 +2 dB 以下、方形波の行き過ぎ 20 % 程度まで)
- R<sub>iso</sub> を挟むと位相余裕は 58° に戻る。ループから見ると負荷が 1 kΩ の抵抗に見えるため
- Network の位相の表示は ±180° で折り返す。C<sub>L</sub> 1 nF で 3 MHz の付近は位相が 0° を下回る。0 dB の所だけ読めばよい
- 低い周波数 (1 kHz 以下) の |T| は 60 dB を超え、5 mV の注入でも出力が飽和に近づく。位相余裕を読むには、
  ループ利得が 0 dB を横切る前後の 1〜2 桁を掃引すれば足りる

## LTspice での確かめ

`sim/17-phase-margin.cir` で図1 を AC 解析した。オペアンプは 5-14 と同じ線形の模型 (仮定で、実測ではない)。
C<sub>L</sub> を 24 pF・494 pF・1.024 nF、R<sub>iso</sub> 1 kΩ + 494 pF に振り、H = V(出力)/V(− 入力) の 0 dB の点を読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 10 kHz の \|H\| | 120 倍 (41.6 dB) | 119.96 倍 | 合う |
| 0 dB の周波数・位相 (24 pF) | 1.02 MHz・56° | 1.017 MHz・55.7° | 合う |
| 0 dB の周波数・位相 (470 pF) | 861 kHz・26° | 860.6 kHz・26.4° | 合う |
| 0 dB の周波数・位相 (1 nF) | 700 kHz・16° | 700.2 kHz・16.2° | 合う |
| 0 dB の周波数・位相 (R<sub>iso</sub> 1 kΩ) | 857 kHz・58° | 856.7 kHz・58.2° | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。LM358B の位相余裕は [TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf) の代表値。
参考: [Phase margin (Wikipedia)](https://en.wikipedia.org/wiki/Phase_margin)
