---
book: analog-discovery
chapter: 3
id: 3-5
title: 出力に 50 Ω を付けたときの落ち込み — 出力インピーダンス
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-5 出力に 50 Ω を付けたときの落ち込み — 出力インピーダンス

ベンチ (据え置き) の関数発生器の多くは**出力インピーダンス 50 Ω** を持つ。
50 Ω の負荷をつなぐと分圧で電圧がちょうど半分 (−6.02 dB) になるのは、
その手の発生器の常識になっている。

Analog Discovery 3 (AD3) の Wavegen の W1 はこれと**違う**。仕様の出力インピーダンスは
**0 Ω** (ヘッダ直結。「精密には制御されていない」と注記されている) で、ほぼ
理想の電圧源として振る舞う。50 Ω をつないでも電圧はほとんど落ちない — その代わり、
**電流**に無理をさせると波形の頭が潰れる。AD3 が歪みなく出せる電流は最大
**30 mA** (40 mA まではハードウェアの遮断の手前)。この実験では両方を実際に測る。

## 回路図

```circuit
title: 図1 出力インピーダンスを測る
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  S1: switch 5,1 7,1
  RL: resistor 7,1 9,1 50
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 9,3
  - 9,1 -- 9,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/05-output-impedance.svg)

- S1 を開けたままだと CH1 は開放電圧をそのまま読む (CH1 自身の入力抵抗は
  1 MΩ 以上あり、無視できる)
- S1 を閉じると R<sub>L</sub> = 50 Ω が W1 の出力と GND の間に入る。ベンチの
  発生器なら電圧が半分になる負荷だが、W1 でどうなるかを測るのがこの実験
- 50 Ω は E24 に無いので、**100 Ω を 2 本並列**にして作る (図2 の RL1・RL2)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3
board: half
parts:
  S1: switch c5 c8
  RL1: resistor b8 b13 100
  RL2: resistor d8 d13 100
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1+, W1, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.1- -- -t8 black
  - a13 -- -t13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/05-output-impedance.svg)

S1 を抜いたまま (開放) 測ってから、挿して (短絡) もう一度測る。実際にスイッチを
用意できないときはジャンパ線の抜き差しでよい。R<sub>L</sub> は 50 Ω に固定し、
振幅だけを変えて確かめる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Offset 0 V。**Amplitude を 0.5 V → 1 V → 1.5 V → 2 V の順に上げる** |
| Scope | CH1: DC 結合、Range は振幅に合わせて調整 (0.5 V/div など)。Measure の Amplitude (0-peak) だけでなく、**波形の頭の形も目で見る** |

```scope
title: 図3 50 Ω をつなぐ前 (CH1) とつないだ後 (CH2) の 1 kHz の正弦波 — 振幅の差は約 3 %
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.5V, range: 200mV/div}
ch2: {wave: sine 1kHz 0.485V, range: 200mV/div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/05-output-impedance.svg)

図3 は読み方の例の値 (V<sub>open</sub> = 0.500 V、V<sub>L</sub> = 0.485 V) を、同じ尺度で重ねた画面。
ベンチの発生器なら 50 Ω でちょうど半分 (0.25 V) になるところが、W1 では 3 % ほどしか下がらない。
実際の値は個体と配線で変わるので、手元の読み値で R<sub>o</sub> を計算し直す。

## 見るべき値

### 1. 出力インピーダンス R<sub>o</sub> を測る (Amplitude 0.5 V)

計算値と、読み方の例。**V<sub>L</sub> = V<sub>open</sub> × R<sub>L</sub> / (R<sub>L</sub> + R<sub>o</sub>)** を
R<sub>o</sub> について解くと、**R<sub>o</sub> = R<sub>L</sub> × (V<sub>open</sub> / V<sub>L</sub> − 1)**。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 開放時 CH1 (S1 off) | ほぼ 0.500 V (振幅どおり) | 出力段はほぼ理想電圧源 |
| 50 Ω 負荷時 CH1 (S1 on) | 0.500 V よりわずかに低いだけ (数 % 以内が目安) | R<sub>o</sub> が数 Ω しかない証拠。ベンチの発生器の −6.02 dB とは大きく違う |

**読み方の例** (実際の値は個体・配線で変わるので、あくまで計算のやり方の例):
V<sub>open</sub> = 0.500 V、V<sub>L</sub> = 0.485 V と読めたなら、
R<sub>o</sub> = 50 × (0.500 / 0.485 − 1) ≈ **1.5 Ω**。ここで測る R<sub>o</sub> は
**目安であって、データシートの規格値ではない** (PTC の抵抗と配線の抵抗の
合計で、個体差がある)。

### 2. 電流のほうが本当の制約 (R<sub>L</sub> = 50 Ω 固定、振幅を上げる)

計算値。負荷電流 (0-peak) ≈ Amplitude ÷ 50 Ω (R<sub>o</sub> が小さいので分母は
ほぼ R<sub>L</sub> のまま)。AD3 の仕様は、歪みなく出せる DC 電流を最大 30 mA、
ハードウェアの遮断までを 40 mA としている。

| Amplitude | 負荷電流 (0-peak) の計算値 | 見えるはずの波形 |
| --- | --- | --- |
| 0.5 V | 10.0 mA (30 mA の 1/3) | きれいな正弦波 |
| 1.0 V | 20.0 mA (30 mA の 2/3) | きれいな正弦波 |
| 1.5 V | 30.0 mA (歪みなく出せる上限ちょうど) | ここまでは仕様の範囲。頭が丸まり始めるかは個体次第 (**未確認**) |
| 2.0 V | 40.0 mA (ハードウェアの遮断の値ちょうど) | 30 mA を超えるので仕様の範囲外。頭が潰れて見えるはず (遮断されたときの見え方は**未確認**) |

```graph
title: 図4 負荷電流は Amplitude に比例し、1.5 V で歪みなしの上限 30 mA に届く
x: Amplitude V 0..2.5
y: 負荷電流 mA 0..60
lines:
  50 Ω 負荷 mA: x/50*1000
notes:
  - level 30mA
  - level 40mA
  - text 0.55 32mA: 歪みなしの上限 30 mA
  - text 0.55 42mA: ハードウェアの遮断 40 mA
  - mark 0.5
  - mark 1
  - mark 1.5
  - mark 2
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/graph/05-output-impedance.svg)

分かること:

- **落ち込みの正体は R<sub>o</sub> ではなく電流。** W1 は「50 Ω 負荷に耐える
  電圧源」ではなく、「30 mA までは歪みなく出せる、ほぼ理想の電圧源」というのが実像
- **頭が潰れ始めたら、それは分圧ではなく電流の限界。** 出力段が必要な電流を
  出しきれなくなり、ピークだけ平らになる (クリップ)。**頭が潰れたまま長時間
  動かし続けない**
- **Discovery BNC アダプタ**を使うと、AWG 出力に **50 Ω / 0 Ω を選べる
  ジャンパ**がある (既定は 0 Ω)。ここで 50 Ω 側を選べば、今度は本物の 50 Ω が直列に
  入るので、ベンチの発生器と同じ「50 Ω 負荷で電圧が半分」という挙動になる
  (この実験は 0 Ω 側の話)。AD3 のマニュアルは、容量の大きい負荷でエッジが
  リンギングするときにも 50 Ω 側にするとよいとしている

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。W1 の出力インピーダンス (0 Ω・精密には制御されていない)、
DC 電流 30 mA (歪みなく出せる最大値)・40 mA (ハードウェアの遮断まで)、BNC アダプタ
有りの 0 Ω / 50 Ω の選択は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Wavegen の節) と
[Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Analog Output の節) による。出力段の部品の型番は AD3 の資料に無く、書いていない。
