---
book: circuits
chapter: 1
id: 1-17
title: RC フィルタを Spectrum と VNA で見る — 計器の選び方
tier: 100
source: 自作
board: BB
---

# 1-17 RC フィルタを Spectrum と VNA で見る — 計器の選び方

**先に 1-5 (RC ローパス・ハイパス) を組んでおく。** この題は 1-5 のフィルタの周波数特性を、Network 以外の計器で見る。
まず f<sub>c</sub> のある帯ごとに計器の選び方をまとめ、次に AD の Spectrum で方形波の高調波の減り方 (図1・図2)、
最後に VNA (LiteVNA64) で値を替えて MHz 帯 (図3・図4) を見る。ボード線図・位相・−20 dB/decade の意味は 1-5 のとおり。

Spectrum の節は 1-5 の図6 の基板をそのまま使い、VNA の節は同じ基板の C を挿し替えて測り方だけを足すので、
実体配線図・AD3・オシロの図は再掲しない (VNA の節は S パラメータを見るので、AD3 とオシロの図も入らない)。

## 計器の選び方: 1 kHz 前後のフィルタは Analog Discovery の Network で測る

f<sub>c</sub> が 1 kHz 前後のフィルタなら、おすすめの順は次のとおり。

1. **Analog Discovery の Network (ネットワークアナライザ)**。10 Hz〜100 kHz を
   1 分ほどで掃引し、利得と位相を 1 枚に描く。入力は 1 MΩ で、1.5 kΩ の回路を乱さない。
   この回路をそのまま測れる
2. **発振器と 2 ch のオシロ**。周波数を手で変えて、CH1 (入力) と CH2 (出力) の振幅の比を
   数点読む。ボード線図を描く機能 (Bode Plot・FRA などの名前) のあるオシロなら 1 と同じ図になる
3. **スマホのトーンとテスター**。1-5 の「見るべき値」の 3 点を目安で確かめるだけならこれで足りる。
   テスターの交流電圧レンジが正しく読めるのは、機種により数百 Hz〜数 kHz まで
   (取扱説明書の「周波数範囲」を見る)。その先の減り方はテスターのせいで大きく見える

**VNA と tinySA は、この回路には使えない。** 下限 (50 kHz・100 kHz) の外で、
入出力が 50 Ω なので 1.5 kΩ の回路の出力を潰す。スペクトラムアナライザ (AD の Spectrum) は
利得を読むこともできるが、本来は**信号の中身** (高調波・雑音) を見る計器で、
フィルタの周波数特性なら Network のほうが早い。

周波数帯ごとのおすすめ:

| f<sub>c</sub> のある帯 | おすすめ | 次の手 | 向かない |
| --- | --- | --- | --- |
| 〜100 kHz (音の帯) | AD の Network | 発振器 + 2 ch のオシロ。数百 Hz までならテスター | VNA・tinySA (下限の外) |
| 100 kHz〜数 MHz | AD の Network (上は 9 MHz ほどで AD 自身の帯域が効く。AD の教科書の 5-8) | VNA。回路を 50 Ω の入出力で組み直す (下の「VNA で見る」) | テスター |
| 数 MHz〜6.3 GHz | VNA (LiteVNA64) | tinySA と信号源 (VNA の CH0 など。NanoVNA の教科書の第 11 章)。800 MHz より上は tinySA Ultra の Ultra モード | AD (帯域の外)、ブレッドボード (数十 MHz からブレッドボードの寄生が効く) |

Network での見方は 1-5。以下では Spectrum と VNA で実際に見る。

以下の値は f<sub>c</sub> = 1 / (2π × 1.5 kΩ × 100 nF) = **1.06 kHz** で計算した
(1-5 の 1.1 kHz はこれを丸めた値)。

## スペクトラムアナライザで高調波の減り方を見る

スペクトラムアナライザは、信号に含まれる周波数ごとの大きさを見る計器。
**方形波**は基本波の奇数倍 (3 倍・5 倍 …) の周波数の正弦波 (高調波) を含み、
その大きさは n 倍の周波数で 1/n に並ぶ (Analog Discovery の教科書の 4-2)。
これをローパスに通すと、f<sub>c</sub> より上の高調波ほど強く削られる。
入力 (CH1) と出力 (CH2) のスペクトルを並べると、**高調波ごとの差がそのままフィルタの利得**になる。

つなぎ方は 1-5 の図5・図6 と同じ。W1 を方形波にして、AD の **Spectrum** で CH1 と CH2 を見る。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、**500 Hz**、Amplitude 1 V、Offset 0 V、Duty 50 % |
| Spectrum | Channel 1 と Channel 2 を表示、**Start 0 Hz、Stop 10 kHz**、Window: Flat-top、単位: dBm |

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図1 入力 (CH1) — 方形波 500 Hz の高調波
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 13dBm
signal: square 500Hz 1V
markers: [500Hz, 1.5kHz, 4.5kHz, 9.5kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/spectrum/17-rc-filter-spectrum-vna-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 出力 (CH2) — ローパスを通した後
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 13dBm
signal:
  - sine 500Hz 1151.76mV
  - sine 1.5kHz 245.09mV
  - sine 2.5kHz 99.49mV
  - sine 3.5kHz 52.77mV
  - sine 4.5kHz 32.47mV
  - sine 5.5kHz 21.93mV
  - sine 6.5kHz 15.78mV
  - sine 7.5kHz 11.89mV
  - sine 8.5kHz 9.28mV
  - sine 9.5kHz 7.44mV
markers: [500Hz, 1.5kHz, 4.5kHz, 9.5kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/spectrum/17-rc-filter-spectrum-vna-2.svg)

| 高調波 | 周波数 | CH1 (計算値) | CH2 (計算値) | 差 = フィルタの利得 |
| --- | --- | --- | --- | --- |
| 1 (基本波) | 500 Hz | +12.10 dBm | +11.23 dBm | −0.87 dB |
| 3 | 1.5 kHz | +2.56 dBm | −2.21 dBm | −4.77 dB |
| 9 | 4.5 kHz | −6.99 dBm | −19.77 dBm | −12.78 dB |
| 19 | 9.5 kHz | −13.48 dBm | −32.57 dBm | −19.09 dB |

分かること:

- 差の列は、ネットワークアナライザで見たローパスの利得の曲線 (1-5 の図7) と同じ値になる。
  スペクトラムアナライザでも、**入力と出力の差を取れば周波数特性が読める**
- 入力の高調波は 1/n (10 倍ごとに −20 dB) で並ぶが、出力は f<sub>c</sub> より上で
  さらに −20 dB/decade が掛かり、1/n² に近い減り方になる。時間波形で見ると、
  方形波の角が丸まった形 (1-3 の充放電の曲線) になる
- W1 を **Noise** (白色雑音、どの周波数も同じくらい含む) にすると、CH2 のスペクトルが
  そのままローパスの曲線の形になる。雑音は 1 回ごとにばらつくので、Spectrum で
  数十回の平均を取って見る

tinySA のような掃引型のスペクトラムアナライザは下限が 100 kHz なので、この回路には
使えない。次の VNA 用の値 (MHz 帯) なら、信号源と組み合わせて同じ見方ができる
(NanoVNA の教科書の第 11 章)。

## VNA で見る (値を替えて MHz 帯へ)

VNA (ベクトルネットワークアナライザ) は CH0 から信号を出し、CH1 に届いた大きさと位相 (S21) を測る。
この本の標準の機種は LiteVNA64 (50 kHz〜6.3 GHz)。歴史的な機種の NanoVNA-H4 も、同じ手順で測れる。
そのまま使えない理由は 2 つ:

- 掃引の下限が **50 kHz** (LiteVNA64)。f<sub>c</sub> = 1.06 kHz は範囲の外
- CH0 の出力と CH1 の入力は、どちらも **50 Ω**。1.5 kΩ の R1 の後ろに 50 Ω の
  CH1 がつながると、出力はほぼ 0 まで落ちてしまう

そこで **R1 を外し、VNA の 50 Ω に R の役目をさせる**。C を 1 つ置くだけで RC フィルタになる。

- ローパス: C を信号の線と GND の間に置く (並列)。C から見た R は CH0 の 50 Ω と
  CH1 の 50 Ω の並列で **25 Ω**。f<sub>c</sub> = 1 / (2π × 25 Ω × 10 nF) = **637 kHz**
- ハイパス: C を信号の線に直列に置く。R は 50 Ω + 50 Ω = **100 Ω**。
  f<sub>c</sub> = 1 / (2π × 100 Ω × 10 nF) = **159 kHz**

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図3 VNA の入出力の抵抗を R にしたローパス (C1 は 10 nF)
parts:
  J1: sma 2,1 mirror CH0
  C1: capacitor 4,1 4,2 10n
  J2: sma 6,1 CH1
  G1: ground 2,2
  G2: ground 4,2
  G3: ground 6,2
wires:
  - J1.1 -- 4,1 -- J2.1
  - J1.2 -- 2,2
  - J2.2 -- 6,2
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/17-rc-filter-spectrum-vna.svg)

C1 は 10 nF (103) のセラミックコンデンサ。ブレッドボードへは SMA とワニ口 (かピン) のケーブル 2 本で
つなぎ、2 本の GND は C1 の GND 側の同じ列に集める。ハイパスは C1 を CH0 と CH1 の間に
直列に入れ、GND は 2 本のケーブルの GND どうしをつなぐだけにする。

| 項目 | 値 |
| --- | --- |
| 機種 | LiteVNA64 (NanoVNA-H4 でも同じ) |
| 範囲 | 50 kHz〜10 MHz |
| 点数 | 201 |
| 校正 | ケーブルの先 (ワニ口) で THRU を取る。できれば SOLT (NanoVNA の教科書の 1-1) |
| 表示 | S21 の Log Mag と Phase |

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: litevna64
sweep: 50k-10M 201
title: 図4 C 1 つのローパスの S21 (fc = 637 kHz)
dut:
  - shunt C 10n
traces:
  - S21 logmag
  - S21 phase
markers:
  - 50k
  - 637k
  - 6.37M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/vna/17-rc-filter-spectrum-vna.svg)

| 周波数 | ローパス S21 (計算値) | ハイパス S21 (計算値) |
| --- | --- | --- |
| 50 kHz | −0.03 dB | −10.47 dB |
| 159 kHz (ハイパスの f<sub>c</sub>) | −0.26 dB | −3.01 dB |
| 637 kHz (ローパスの f<sub>c</sub>) | −3.01 dB | −0.26 dB |
| 6.37 MHz | −20.05 dB | 0.00 dB |

ブレッドボードの目安 (ブレッドボードの上の回路は 3 MHz 以下) を超える **3 MHz より上の値は、
ブレッドボードの浮遊インダクタンス・浮遊容量を含み、上の計算値はおおよその目安** として読む
(6.37 MHz の行が該当する。浮遊の影響は数十 MHz でいっそう大きくなる)。

分かること:

- f<sub>c</sub> と −20 dB/decade の下がり方は、R が計器の 50 Ω に替わっただけで
  1-5 の図5 の回路と同じ
- **計器をつなぐと、計器の抵抗も回路の一部になる**。1.5 kΩ のフィルタを 50 Ω の
  計器で測れないのはこのため。AD の CH1・CH2 の入力は 1 MΩ なので、1-5 の図5 では無視できた
- Stop を 30 MHz まで広げると、ローパスの S21 が十数 MHz あたりで底を打って戻り始める。
  C1 のピンとブレッドボードのインダクタンス (10 nH ほど) と C1 の直列共振で、
  その先はコンデンサとして働かない (NanoVNA の教科書の 4-2)

## LTspice での確かめ

`sim/05-rc-filter.cir` (1-5 の 1.5 kΩ + 100 nF。図1・図2) と `sim/17-rc-filter-vna.cir` (図3・図4 の 50 Ω + 10 nF) を AC 解析した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 高調波の利得 500 Hz・1.5 kHz・4.5 kHz・9.5 kHz (図1・図2 の差) | −0.87・−4.77・−12.78・−19.09 dB | −0.87・−4.77・−12.78・−19.09 dB | 合う |
| VNA ローパスの S21 50 kHz・159 kHz・637 kHz・6.37 MHz | −0.03・−0.26・−3.01・−20.05 dB | −0.03・−0.26・−3.01・−20.05 dB | 合う |
| VNA ハイパスの S21 50 kHz・159 kHz・637 kHz・6.37 MHz | −10.47・−3.01・−0.26・0.00 dB | −10.47・−3.01・−0.26・0.00 dB | 合う |

## 出典

自作。

参考: [ローパスフィルタ (Wikipedia)](https://ja.wikipedia.org/wiki/ローパスフィルタ)、[ハイパスフィルタ (Wikipedia)](https://ja.wikipedia.org/wiki/ハイパスフィルタ)
