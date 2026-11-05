---
book: analog-discovery
chapter: 5
id: 5-14
title: ボルテージフォロアの容量負荷とピーキング
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-14 ボルテージフォロアの容量負荷とピーキング

ボルテージフォロアの出力にコンデンサをつなぐと、方形波の角で出力が跳ねて揺れる (回路の教科書の 4-20 で時間波形を見た)。
同じことを周波数で見ると、利得 1 倍のはずのフォロアの周波数特性に**山 (ピーキング)** が立つ。
揺れの周波数と山の周波数はほぼ同じで、山が高いほど揺れが長く続く。

原因は、オペアンプの出力の内部抵抗 R<sub>O</sub> (開ループの出力抵抗) と負荷の容量 C<sub>L</sub> がローパスを作り、
帰還の信号を遅らせることにある。遅れの余裕 (位相余裕) が減ると、帰還が打ち消しきれずに山ができる。
この題では LM358 のフォロアの C<sub>L</sub> を 3 通りに替えて Network で掃引し、最後に R<sub>iso</sub> (切り離しの抵抗) で山を消す。
位相余裕そのものをループを切って測るのは 5-17。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フォロアの出力に Riso と CL。Riso を 0 Ω (ジャンパ) にすると CL を直に駆動する
parts:
  V1: sine 1,2 1,4 l=$\mathrm{W1}$
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  G1: ground 1,4
  G2: ground 3,4
  U1: opamp 6,3 +up
  Riso: resistor 8,3 11,3 1k l=$\mathrm{R_{iso}}$
  CL: capacitor 11,3 11,5 470p l=$\mathrm{C_L}$
  G3: ground 11,5
  M2: voltmeter 13,3 13,5 l=$\mathrm{CH2}$
  G4: ground 13,5
wires:
  - 1,2 -- 3,2
  - 3,2 -- 4,2 |- U1.+
  - U1.out -- 8,3
  - 8,3 -- 8,4.6 -- 4,4.6
  - 4,4.6 |- U1.-
  - 11,3 -- 13,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/14-follower-capacitive-load.svg)

- U1 は利得 1 倍のフォロア。帰還は U1 の出力 (R<sub>iso</sub> の手前) から取る
- **測定 A〜C は R<sub>iso</sub> を 0 Ω のジャンパに替え**、C<sub>L</sub> を 0 (外す)・470 pF・1 nF と替える。
  **測定 D は R<sub>iso</sub> = 1 kΩ** に戻し、C<sub>L</sub> = 470 pF。CH2 はどれも C<sub>L</sub> の上 (C) で測る
- CH2 の入力容量 24 pF (AD3 の仕様、1 MΩ ∥ 24 pF) も C<sub>L</sub> に足される。C<sub>L</sub> を外しても 24 pF は残る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (測定 D)
board: half
parts:
  U1: dip8 @ f8 LM358
  Riso: resistor i8 i3 1k cap=above
  CL: capacitor j3 -b3 470p cap=right
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [2+, 1+, W1, V-, V+, GND, 1-, 2-]
wires:
  - -b1 -- -t1 black
  - a9 -- a10 green
  - a11 -- -t11 black
  - +t8 -- a8 red
  - g8 -- g9 white
  - AD.V- -- j11 purple
  - AD.W1 -- i10 yellow
  - AD.1+ -- j10 orange
  - AD.2+ -- h3 blue
  - AD.V+ -- +b22 red
  - +b24 -- +t24 red
  - AD.GND -- -b26 black
  - AD.1- -- -b27 black
  - AD.2- -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/14-follower-capacitive-load.svg)

- U1 (LM358) の 1 回路目をフォロアにする。1 番 OUT1 (8 列) と 2 番 IN1− (9 列) を白の短い線でつなぎ、
  3 番 IN1+ (10 列) に W1 と CH1 (1+) を挿す。使わない 2 回路目は 5-6 と同じくフォロアにして入力を GND に固定する
- R<sub>iso</sub> は 8 列から左の 3 列 (C) へ。入力の 10・11 列の上を通らないよう、出力を左へ取り出した。C<sub>L</sub> は 3 列から下の − レールへ、ピンを短く切って挿す。CH2 (2+) は 3 列
- 測定 A〜C では R<sub>iso</sub> を抜き、同じ穴 (`i8`・`i3`) に 0 Ω のジャンパ線を挿す。C<sub>L</sub> を替えるときも同じ穴に挿し直す
- V− は AD3 の V− から 4 番 (11 列) へ直に、V+ は 24 列の赤線で上の + レールへ渡して 8 番 (`a8`) に入れる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる |
| Wavegen | W1: Amplitude 10 mV、Offset 0 V |
| Network | Start 10 kHz、Stop 3 MHz、Log、Steps 201、Reference: Channel 1。平均 (Average) を数回に増やす |

W1 を 10 mV と小さくするのは、山の上でも出力の傾きを LM358 のスルーレート (約 0.3 V/µs) より十分小さくするため。
1 nF の山 (3.75 倍、733 kHz) で 2π × 733 kHz × 37.5 mV ≈ 0.17 V/µs。これより大きいと山の頂が削れ、低く読めてしまう。
2×15 ヘッダのワイヤのままでよい (掃引の上限 3 MHz は入力の帯域 9 MHz の内側)。

測定 B の山の上、933 kHz の時間波形が図3 (計算値)。出力は入力の 2.31 倍に膨らみ、97° 遅れる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CL 470 pF・933 kHz — 出力 (CH2) は入力の 2.31 倍で 97° 遅れる
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 933kHz 10mV, range: 10mV/div}
ch2: {wave: sine 933kHz 23.1mV phase -97deg, range: 10mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/14-follower-capacitive-load.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入り。1 回路目を使う) | LM358 |
| C<sub>L</sub> | セラミックコンデンサ (容量負荷。C0G) | 470 pF (471) と 1 nF (102) を差し替える |
| R<sub>iso</sub> | 抵抗 (1/4 W、容量の切り離し) | 1 kΩ (測定 A〜C は 0 Ω のジャンパ線) |
| — | 電源 | ±5 V (AD3 の Supplies)。入力 0 V の付近でフォロアを動かすため両電源 |
| — | 計器 | AD3 の W1・Scope 1+ (入力)・2+ (C) |

## 見るべき値

計算値。オペアンプの模型は GBW 1.2 MHz・第 2 の極 1.63 MHz・R<sub>O</sub> 270 Ω (仮定。下の節)。C<sub>L</sub> は CH2 の 24 pF を足した値で計算した。

| 測定 | 負荷 | 山の高さ | 山の周波数 | −3 dB 点 | 位相余裕 (模型、5-17 で測る) |
| --- | --- | --- | --- | --- | --- |
| A | C<sub>L</sub> なし (24 pF) | +0.70 dB | 約 0.9 MHz | 1.68 MHz | 56° |
| B | C<sub>L</sub> 470 pF | **+7.27 dB (2.31 倍)** | 933 kHz | 1.41 MHz | 26° |
| C | C<sub>L</sub> 1 nF | **+11.5 dB (3.75 倍)** | 733 kHz | 1.10 MHz | 16° |
| D | R<sub>iso</sub> 1 kΩ + 470 pF (C で) | 山なし (0 dB) | — | 358 kHz | 58° (容量が輪の外に出た) |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 CL を増やすと山が高くなり周波数が下がる。Riso 1 kΩ で山が消える
x: 周波数 Hz log 10k..3M
y: 利得 dB -30..15
lines:
  CL 24 pF (CH2 だけ) dB:
    - 10k 0.00
    - 30k 0.00
    - 100k 0.02
    - 200k 0.07
    - 300k 0.15
    - 400k 0.25
    - 500k 0.37
    - 600k 0.50
    - 650k 0.56
    - 700k 0.61
    - 733k 0.64
    - 770k 0.67
    - 800k 0.68
    - 850k 0.70
    - 900k 0.70
    - 933k 0.68
    - 970k 0.65
    - 1M 0.62
    - 1.1M 0.43
    - 1.2M 0.11
    - 1.4M -0.92
    - 1.7M -3.14
    - 2M -5.62
    - 2.5M -9.49
    - 3M -12.79
  CL 470 pF dB:
    - 10k 0.00
    - 30k 0.01
    - 100k 0.08
    - 200k 0.30
    - 300k 0.70
    - 400k 1.28
    - 500k 2.09
    - 600k 3.15
    - 650k 3.78
    - 700k 4.48
    - 733k 4.98
    - 770k 5.54
    - 800k 6.00
    - 850k 6.69
    - 900k 7.17
    - 933k 7.27
    - 970k 7.14
    - 1M 6.82
    - 1.1M 4.75
    - 1.2M 2.09
    - 1.4M -2.74
    - 1.7M -8.26
    - 2M -12.51
    - 2.5M -18.08
    - 3M -22.55
  CL 1 nF dB:
    - 10k 0.00
    - 30k 0.01
    - 100k 0.14
    - 200k 0.58
    - 300k 1.37
    - 400k 2.61
    - 500k 4.51
    - 600k 7.40
    - 650k 9.27
    - 700k 11.01
    - 733k 11.49
    - 770k 10.87
    - 800k 9.61
    - 850k 7.01
    - 900k 4.50
    - 933k 3.01
    - 970k 1.48
    - 1M 0.35
    - 1.1M -2.90
    - 1.2M -5.56
    - 1.4M -9.86
    - 1.7M -14.83
    - 2M -18.83
    - 2.5M -24.24
    - 3M -28.68
  Riso 1 kΩ + 470 pF (C) dB:
    - 10k -0.00
    - 30k -0.03
    - 100k -0.33
    - 200k -1.19
    - 300k -2.31
    - 400k -3.51
    - 500k -4.70
    - 600k -5.85
    - 650k -6.42
    - 700k -6.99
    - 733k -7.37
    - 770k -7.80
    - 800k -8.15
    - 850k -8.74
    - 900k -9.35
    - 933k -9.76
    - 970k -10.23
    - 1M -10.61
    - 1.1M -11.94
    - 1.2M -13.32
    - 1.4M -16.18
    - 1.7M -20.40
    - 2M -24.30
    - 2.5M -29.93
    - 3M -34.65
notes:
  - mark 933k
  - mark 733k
  - level -3dB
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/14-follower-capacitive-load.svg)

分かること:

- **C<sub>L</sub> が増えるほど山は高く、周波数は低くなる。** R<sub>O</sub> と C<sub>L</sub> の極 (470 pF で 1/(2π × 270 Ω × 494 pF) = 1.19 MHz、
  1 nF で 576 kHz) が、ループ利得が 1 になる周波数 (約 1 MHz) に近づくほど、遅れが増える
- **山の高さから位相余裕が分かる。** 2 次の系と見ると、山が +7.3 dB なら位相余裕は 26° 前後、+11.5 dB なら 16° 前後。
  位相余裕 45° を下回ると山が +2 dB を越え始め、方形波の行き過ぎも 20 % を越える (回路の教科書の 4-20)
- **R<sub>iso</sub> 1 kΩ を挟むと山が消える** (測定 D)。代わりに C の側は R<sub>iso</sub> と C<sub>L</sub> の 1 次のローパス
  (1/(2π × 1 kΩ × 494 pF) = 322 kHz に、R<sub>O</sub> の 270 Ω が足されて 358 kHz) で帯域が下がる
- 測定 A の山 (+0.7 dB) は LM358 自身の位相余裕 (約 58°、TI のデータシートの代表値) と CH2 の 24 pF の分。
  ワイヤや 10:1 プローブで容量が変わると、A の山も少し変わる (5-20)

## LTspice での確かめ

`sim/14-follower-capacitive-load.cir` で図1 を AC 解析した。オペアンプは線形の 2 極と開ループの出力抵抗の模型
(GBW 1.2 MHz、第 2 の極 1.63 MHz、R<sub>O</sub> 270 Ω)。第 2 の極と R<sub>O</sub> は、TI の LM358B のデータシートの位相余裕
(利得 1 倍で 0 pF のとき約 58°、330 pF のとき約 33°) に合うように選んだ**仮定**で、実測ではない。
C<sub>L</sub> を 24 pF・494 pF・1.024 nF、R<sub>iso</sub> を 0.001 Ω・1 kΩ に振った。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| A の山・−3 dB 点 | +0.70 dB・1.68 MHz | 1.084 倍 (+0.70 dB)・1.684 MHz | 合う |
| B の山・周波数・−3 dB 点 | +7.27 dB・933 kHz・1.41 MHz | 2.311 倍 (+7.27 dB)・933 kHz・1.413 MHz | 合う |
| B の山の位相 (図3) | −97° | −97.1° | 合う |
| C の山・周波数・−3 dB 点 | +11.5 dB・733 kHz・1.10 MHz | 3.755 倍 (+11.49 dB)・733 kHz・1.104 MHz | 合う |
| D の C の山・−3 dB 点 | 山なし・358 kHz | 1.000 倍・358.3 kHz | 合う |
| D の U1 の出力の山 | (小さい) | 1.078 倍 (+0.65 dB) | 参考 |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。CH2 の入力容量は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
LM358B の位相余裕と出力抵抗は [TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf) の代表値。
