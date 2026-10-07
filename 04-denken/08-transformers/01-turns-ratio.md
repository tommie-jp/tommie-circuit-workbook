---
book: denken
chapter: 8
id: 8-1
title: 巻数比と電圧比・電流比
tier: 50
source: 自作
board: BB
---

# 8-1 巻数比と電圧比・電流比

変圧器は 1 次巻線と 2 次巻線の**巻数の比**で電圧と電流を変える。小型の出力トランス
(10 kΩ:8 Ω、巻数比 約 35:1) を Analog Discovery (AD) の波形発生器で低い電圧のまま
駆動し、電圧比と電流比の両方が巻数比に合うことを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| n = N1 / N2 | 巻数比。1 次巻線 (N1) と 2 次巻線 (N2) の巻数の比 |
| n = √(Z1 / Z2) | 整合が取れた負荷のとき、インピーダンス比の平方根が巻数比に等しい |
| V1 / V2 = n | 電圧比は巻数比に等しい |
| I2 / I1 = n | 電流は巻数に反比例する。2 次の電流は 1 次の n 倍 (電圧比の逆) |

このトランスは 1 次 10 kΩ・2 次 8 Ω 用なので、n = √(10000 / 8) ≒ 35.4。

## 回路図

```circuit
title: 図1 巻数比を測る回路
style:
  standard: jis
  pitch: 1.8
parts:
  W1: sine 1,3 1,5 l=$\mathrm{W1}$
  Rs1: resistor 1,3 3,3 100 i=I1
  M2: voltmeter 1,2 3,2 l=$\mathrm{CH2}$
  M1: voltmeter 4,3.5 4,4.5 l=$\mathrm{CH1}$
  T1: transformer 5,4 10kto8
  RL: resistor 7,3.5 7,4.5 8
  G1: ground 1,5
wires:
  - 1,2 -- 1,3
  - 3,2 -- 3,3
  - 3,3 -- 4,3 -- 4,3.5
  - 4,3.5 -| T1.A1
  - T1.A2 -| 4,4.5
  - 4,4.5 -- 4,5
  - 1,5 -- 4,5
  - T1.B1 -| 7,3.5
  - T1.B2 -| 7,4.5
notes:
  - text 7.05,4.54 left small: (16 Ω を 2 本並列)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/01-turns-ratio-1.svg)

- W1 は AD の波形発生器 (Wavegen)。1 kHz、振幅 2 V
- Rs1 (100 Ω) は 1 次電流 I1 を読むシャント。10 kΩ に反射した 2 次負荷に対して
  1 % ほどなので、電圧比・電流比の計算にはほぼ効かない
- M1 (CH1) は 1 次巻線の両端、M2 (CH2) は Rs1 の両端 (差動)。1 回目はこの配線で
  V1 と I1 (= 読みの 1/100) を読む
- RL (8 Ω) は 2 次巻線に合わせた負荷。8 Ω は E24 に無いので、16 Ω を 2 本並列にして作る。2 回目は CH1 を RL の両端に挿し替えて V2 を読む
  (2 ch しか無いので 2 回に分けて測る)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の各列は a〜e が 1 つのネット、f〜j が別のネット。T1 は溝をまたいで 1 次・2 次を配る
board: half
parts:
  Rs1: resistor e3 e7 100
  T1: transformer c15 c18 f15 f18 10kto8
  RL1: resistor h15 h18 16
  RL2: resistor j15 j18 16
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - AD.1+ -- a7 orange
  - AD.1- -- -t9 black
  - AD.2+ -- a11 blue
  - AD.2- -- a15 white
  - c3 -- c11 yellow
  - b7 -- b15 orange
  - a18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/breadboard/01-turns-ratio.svg)

- T1 の 1 次リード (10 kΩ側) を 15・18 列の上ブロック、2 次リード (8 Ω側) を同じ
  15・18 列の下ブロックに挿す。上下は別ネットなので、4 ピンがそのまま 1 次・2 次を分ける
- RL は 16 Ω の 2 本 (RL1 を h 行、RL2 を j 行)。15・18 列の下ブロックに挿すだけで、
  2 本が並列になり T1 の 2 次ともつながる (列でつながる)
- Rs1 は 3 列と 7 列。3 列 (W1 側) は黄の線で 11 列へ、7 列 (T1 側) は橙の線で
  15 列 (T1 の 1 次) へ延ばし、AD のピンの並びどおりに左から挿せるようにしてある
- CH2 (2+/2−) は Rs1 の両端 (11 列と 15 列) にあて、I1 を読む。CH1 (1+/1−) は
  T1 の 1 次 (7 列と − レール) にあて、V1 を読む
- 2 回目は 1+ を g15、1− を g18 (どちらも下ブロックの 15・18 列、RL と同じネット) へ
  挿し替えて V2 を読む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 2 V |
| Scope (1 回目) | CH1 = 1 次巻線の両端 (V1)。CH2 = Rs1 の両端 (差動、I1 = 読み ÷ 100 Ω) |
| Scope (2 回目) | CH1 を RL の両端に挿し替え、V2 を読む |

1 回目の画面。CH2 は CH1 の約 1/100 しかないので、CH2 だけ 10 mV/div に上げ、2 本が重ならないよう CH1 を上、CH2 を下にずらしてある。
2 次の負荷は抵抗 (8 Ω) なので、I1 は V1 とほぼ同じ位相になる (巻線のリアクタンスと励磁電流の分で 5° ほど遅れる)。
値は巻線抵抗 (8-3) と励磁電流 (8-2) を入れた計算値 (1.98 V・18.3 mV) で描いた。

```scope
title: 図3 1 回目 — V1 (CH1、1 V/div) と I1 の分 (CH2、10 mV/div) はほぼ同じ位相
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1.98V, range: 1V/div, position: 2div}
ch2: {wave: sine 1kHz 18.3mV phase -4.7deg, range: 10mV/div, position: -2div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/01-turns-ratio-1.svg)

2 回目は CH1 を RL の両端へ挿し替える。V2 は I1 の分と同じ桁なので、2 本とも 20 mV/div で並べる。

```scope
title: 図4 2 回目 — V2 (CH1) は V1 の 1/39 (巻線の電圧降下の分だけ 1/35 より小さい)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 51.3mV, range: 20mV/div}
ch2: {wave: sine 1kHz 18.3mV, range: 20mV/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/01-turns-ratio-2.svg)

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH2 は Rs1 の両端を差動で挟み、1− は巻線の下の端 (GND) に当てている。Rs1 の電圧 (18 mV) は
振れ (2 V) の 1 % しかないので、2 本の先端で引く方法は使えない。**Rs1 を 1 次巻線の GND 側へ
移し**、CH2 の 1 本で直に読む (図5)。直列の順を入れ替えただけなので、I1 は変わらない。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
parts:
  FG: sine 1,3 1,7 l=$\mathrm{FG}$
  M1: voltmeter 3,3 3,7 l=$\mathrm{CH1}$
  T1: transformer 7,4 10kto8
  M2: voltmeter 4,5 4,7 l=$\mathrm{CH2}$
  Rs1: resistor 6,5 6,7 100 i=I1
  RL: resistor 9,3 9,5 8
  M3: voltmeter 11,3 11,5 l=$\mathrm{CH1}$
  G1: ground 1,7
  G2: ground 11,5
wires:
  - 1,3 -- 3,3 -- 6,3 |- T1.A1
  - 6,5 |- T1.A2
  - 4,5 -- 6,5
  - 1,7 -- 3,7 -- 4,7 -- 6,7
  - 8,3 |- T1.B1
  - 8,5 |- T1.B2
  - 8,3 -- 9,3 -- 11,3
  - 8,5 -- 9,5 -- 11,5
notes:
  - text 11.4,4 left: (2回目)
  - text 9.2,4.4 left small: (16 Ω を 2 本並列)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/01-turns-ratio-2.svg)

- ブレッドボードは Rs1 (e3–e7) を抜いて 3 列と 7 列を線でつなぎ、18 列から − レールへの
  黒い線 (a18) を Rs1 (100 Ω) に替える。18 列が T1 の 1 次の下と Rs1 のつなぎ目になる
- FG の OUT を 3 列、FG の GND を − レール。High-Z、Sine、1 kHz、振幅 2 V (Vpp で入れる機種なら 4 Vpp)。
  負荷は約 10 kΩ なので、FG の 50 Ω で下がる振幅は 0.5 % ほどで無視できる
- 1 回目: CH1 の先端を 3 列 (FG の出力)、CH2 の先端を 18 列。グランドクリップはどちらも − レール。
  CH1 は V1 に Rs1 の電圧が乗った値なので、V1 は Math の CH1 − CH2 で読む
  (差は 1 % なので、CH1 をそのまま V1 としてもよい)。CH2 は 10 mV/div (振れは約 37 mVpp)、Average を 16 回
- 2 回目: CH1 の先端を g15、グランドクリップを g18 (2 次の B2 側) に当てて V2 を読む。
  AD の 2 回目と同じく 2 ch では 3 つ (V1・I1・V2) を同時に取れない。4 ch の機種なら 1 回で済む

**1 次と 2 次の GND。** 2 回目は CH2 のクリップ (1 次の GND) と CH1 のクリップ (2 次の B2) が
オシロの中で大地につながり、1 次と 2 次が 1 点でつながる。1 点だけなら電流の輪はできないので、
この題 (1 kHz、数 V) では構わない。ただし 2 次の 2 本のピンの両方にクリップを当てると、
2 次が大地を通って短絡する (V2 が 0 になる)。2 次のクリップは B2 の 1 か所だけにする。
V2 の位相の向きは、どちらのピンにクリップを当てるかで反転する。

## 見るべき値

計算値。巻線の抵抗と漏れリアクタンスは 8-3 の値 (1 次換算 Req ≒ 925 Ω・Xeq ≒ 300 Ω)、
励磁電流は 8-2 の値を入れた。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (V1、振幅) | 1.98 V | Wavegen の 2 V から Rs1 の分 (1 %) だけ下がる |
| CH2 (Rs1 の両端、振幅) | 18.3 mV | I1 = 18.3 mV ÷ 100 Ω = 183 µA |
| CH1 を挿し替えた V2 (振幅) | 51.3 mV | V1 / V2 = 1.98 / 0.0513 ≒ 38.6 (n より 9 % 大きい) |
| RL の電流 I2 (= V2 ÷ 8 Ω) | 6.41 mA | I2 / I1 = 6.41 mA / 183 µA ≒ 35.0 ≒ n |

電流比は巻数比 n ≒ 35.4 によく合う。電流は巻数に反比例するので、2 次の電流が 1 次の n 倍になる
(I1 / I2 = 1 / n で、電圧比 V1 / V2 = n の逆数。電力の釣り合い V1×I1 ≒ V2×I2 で確かめられる)。電圧比は巻線抵抗 (1 次換算 925 Ω) での電圧降下の分だけ
n より大きく出る。巻線抵抗を無視した理想変成器なら V2 = 2.00 V ÷ 35.4 = 56.6 mV で、
これは 2 次を開いたとき (8-4 の無負荷の行) の値に当たる。

## 出典

自作。
