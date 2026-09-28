---
book: denken
chapter: 8
id: 8-5
title: 電圧変動率 — 負荷をつなぐと二次電圧が下がる
tier: 100
source: 自作
board: BB
---

# 8-5 電圧変動率 — 負荷をつなぐと二次電圧が下がる

変圧器の 2 次に負荷をつなぐと、巻線の抵抗と漏れリアクタンスで電圧が下がり、2 次電圧は無負荷のときより低くなる。
その下がり方を無負荷の電圧との比で表したのが**電圧変動率**。
8-1〜8-4 と同じ小型トランス (10 kΩ:8 Ω) で、無負荷と負荷時の 2 次電圧を測り、8-3 の等価回路から出す式の値と比べる。
AC 出力の AC アダプタで同じことを見るのが 0-5 で、中身の変圧器を取り出して調べるのがこの題。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| ε = (V20 − V2n) / V2n × 100 % | 電圧変動率。V20 は無負荷の 2 次電圧、V2n は負荷をつないだときの 2 次電圧 |
| p = I2 × Req2 / V2n × 100 % | 百分率抵抗降下。Req2 は 2 次に換算した巻線抵抗 |
| q = I2 × Xeq2 / V2n × 100 % | 百分率リアクタンス降下。Xeq2 は 2 次に換算した漏れリアクタンス |
| ε ≒ p cos θ + q sin θ | 負荷の力率 cos θ から電圧変動率を見積もる式 (θ は遅れを正) |

8-3 の値を 2 次に換算すると Req2 = 925 Ω / 1250 = 0.74 Ω、Xeq2 = 300 Ω / 1250 = 0.24 Ω
(n² = 10000 / 8 = 1250)。

## 回路図

```circuit
title: 図1 無負荷と負荷時の 2 次電圧を測る回路
style:
  standard: jis
  pitch: 1.8
parts:
  W1: sine c1 e1 l=$\mathrm{W1}$
  M2: voltmeter c3 e3 l=$\mathrm{CH2}$
  T1: transformer d5 10kto8
  M1: voltmeter c7f0 d7f0 l=$\mathrm{CH1}$
  S1: switch c7f0 c9f0
  RL: resistor c9f0 d9f0 8
  G1: ground e1
wires:
  - c1 -- c3 -- c4 -- c4f0
  - c4f0 -| T1.A1
  - T1.A2 -| d4f0
  - d4f0 -- e4
  - e1 -- e3 -- e4
  - T1.B1 -| c7f0
  - T1.B2 -| d7f0
  - d7f0 -- d9f0
notes:
  - text e9 small: (16 Ω を 2 本並列。33 Ω・16 Ω にも替える)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/05-voltage-regulation.svg)

- W1 は AD の波形発生器 (Wavegen)。1 kHz、振幅 2 V。1 次にシャントは入れない (W1 の出力抵抗はほぼ 0 Ω なので、V1 は負荷によらず 2 V)
- S1 は RL をつなぐか外すか。実物ではスイッチを使わず、RL の片足を抜き挿しする
- M1 (CH1) は 2 次の端子の電圧 (V2)。S1 を開けば V20、閉じれば V2n を読む。M2 (CH2) は 1 次 (V1) で、2 V のままかを見る
- RL は 8 Ω (16 Ω を 2 本並列、このトランスの定格の負荷)。軽い負荷として 33 Ω・16 Ω でも測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (RL の片足を抜き挿しする)
# 上のブロックの 15・18 列が 1 次、下のブロックの 15・18 列が 2 次
board: half
parts:
  T1: transformer c15 c18 f15 f18 10kto8
  RL1: resistor h15 h18 16
  RL2: resistor j15 j18 16
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 2-, 1-, W1, 2+, 1+]
wires:
  - AD.W1 -- a15 yellow
  - AD.GND -- -t5 black
  - a18 -- -t18 black
  - AD.1+ -- a21 orange
  - e21 -- f21 orange
  - i21 -- i18 orange
  - AD.1- -- a12 white
  - e12 -- f12 white
  - i12 -- i15 white
  - AD.2+ -- b15 blue
  - AD.2- -- -t9 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/breadboard/05-voltage-regulation.svg)

- 配線は 8-4 と同じ。RL は 16 Ω の 2 本 (RL1 を h 行、RL2 を j 行) で、15・18 列の下ブロックに挿すと並列の 8 Ω になる
- 無負荷を測るときは RL1・RL2 の 18 列側の足を抜く (図1 の S1 を開くのに当たる)。
  33 Ω・16 Ω のときは RL1 の所に 1 本だけ挿す
- CH1 (1+/1−) は 2 次の両端 (18 列と 15 列、i 行)、CH2 (2+) は 1 次の上 (15 列)、2− は青レール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 2 V |
| Scope | CH1 = 2 次の端子 (V2、差動)。CH2 = 1 次巻線の両端 (V1) |
| Measure | CH1・CH2 の Amplitude。V2 の差は数 mV なので Average を 16 回にして雑音を減らす |

同じ設定で、無負荷 (図3) と RL = 8 Ω (図4) の 2 回を読む。V2 は数十 mV なので、CH1 だけ 20 mV/div に上げてある。

```scope
title: 図3 無負荷 — V2 (CH1、20 mV/div) は 56.6 mV
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 56.6mV, range: 20mV/div}
ch2: {wave: sine 1kHz 2V, range: 1V/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/05-voltage-regulation-1.svg)

```scope
title: 図4 RL 8 Ω — V2 (CH1) は 51.8 mV に下がる (図3 と同じ設定)
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 51.8mV phase -1.6deg, range: 20mV/div}
ch2: {wave: sine 1kHz 2V, range: 1V/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/05-voltage-regulation-2.svg)

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。8-4 と同じ測り方でよい。

- CH2 (V1) は先端を 15 列 (上のブロック)、グランドクリップを青レール
- CH1 (V2) は 2 次を差動で挟んでいるが、2 次はどこにもつながっていないので、**グランドクリップを 2 次の片側 (i15) の 1 か所にだけ当て**、
  先端を i18 に当てる。1 点で大地につながるだけなので電流の輪はできない (8-1 と同じ)
- W1 は FG の OUT (High-Z、Sine、1 kHz、振幅 2 V。Vpp で入れる機種なら 4 Vpp)。負荷は 1 次で約 11 kΩ (8 Ω × 1250 + 925 Ω) なので、
  FG の 50 Ω で V1 が下がるのは 0.5 % ほど (計算値)。V1 は CH2 で読めるので、下がったら振幅を戻してから V2 を読む
- CH1 は 20 mV/div (56 mV の山を 10 mV/div にすると画面の外に出る)。8 bit のオシロでは 1 段が 0.6 mV ほどある。差 (4.8 mV) は読めるが、33 Ω の差 (1.2 mV) は 2 段ほどしか無い。
  Average を 64 回にし、Measure の Amplitude を何回か読んで平均する

## 見るべき値

計算値。8-3 の Req = 925 Ω・Xeq = 300 Ω の等価回路で、無負荷の V20 = 2 V / n = 56.6 mV から計算した (振幅)。

| RL | V2 (振幅) | ε (測った V2 から) | p | q | p cos θ + q sin θ (cos θ = 1) |
| --- | --- | --- | --- | --- | --- |
| 無負荷 | 56.6 mV | — | — | — | — |
| 33 Ω | 55.3 mV | 2.25 % | 2.24 % | 0.73 % | 2.24 % |
| 16 Ω | 54.1 mV | 4.64 % | 4.62 % | 1.50 % | 4.62 % |
| 8 Ω | 51.8 mV | 9.29 % | 9.25 % | 3.00 % | 9.25 % |

- **負荷を重くする (RL を小さくする) ほど V2 は下がり、ε は負荷電流にほぼ比例して大きくなる**
- 負荷が抵抗 (cos θ = 1) なので ε ≒ p。q は sin θ = 0 で効かない。式の値 (9.25 %) と V2 から出した値 (9.29 %) の差は、
  式が落とした 2 次の小さな項 (約 0.04 %)
- 同じ 8 Ω 相当の電流で力率 0.8 (遅れ) の負荷なら、ε ≒ 9.25 × 0.8 + 3.00 × 0.6 = 9.2 % (計算値)。
  リアクタンス降下 q が効き始める。**このトランスは巻線抵抗が大きく p が主なので、力率が下がっても ε はあまり変わらない**。
  大きな電力用の変圧器は逆に q が大きく、遅れ力率で ε が大きくなる
- 巻線抵抗の無い理想変成器なら 8 Ω をつないでも V2 = 56.6 mV のまま。実際は 51.8 mV に下がり、その差がこの題の電圧変動率。
  8-1 の 2 回目の V2 (51.3 mV) もこの下がりを含む (1 次の Rs1 のぶん、さらに少し低い)

## 出典

自作。
