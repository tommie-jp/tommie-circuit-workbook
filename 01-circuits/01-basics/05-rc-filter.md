---
book: circuits
chapter: 1
id: 1-5
title: RC ローパス・ハイパス
tier: 50
source: 自作
board: BB
---

# 1-5 RC ローパス・ハイパス

抵抗とコンデンサ 1 つずつで、**低い周波数だけ通す (ローパス)** か
**高い周波数だけ通す (ハイパス)** かが決まる。並び順を入れ替えるだけで
働きが逆になる。こうした回路を**フィルタ**と呼び、雑音を除く・音の高い所を削る・
直流を切って交流だけを通す、といった用途で後の章に何度も出てくる。
ここでは正弦波の周波数を変えながら、出力が入力の何倍になるかを読む。

この題の流れ:

- 前半 (回路図〜見るべき値): ローパスとハイパスを組み、AD3 の発振器・オシロとテスター (図3・図4) で
  3 つの周波数の出力を読む。ここまでで題のねらいは押さえられる
- 後半「周波数特性を計器で見る」: 周波数特性 (周波数ごとの利得) をまとめて見る測り方。
  計器の選び方の結論のあと、Analog Discovery の Network でボード線図 (図5〜図7)、
  スペクトラムアナライザで方形波の高調波の減り方 (図8・図9)、VNA (LiteVNA64) で値を替えて
  MHz 帯 (図10・図11) を見る

## 回路図

```circuit
title: 図1 RC ローパス
parts:
  IN: port a1
  R1: resistor a1 a2 1.5k
  C1: capacitor a2 b2 100n
  OUT: port a3
  G1: ground b2
wires:
  - a2 -- a3
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-1.svg)

図1 のように出力を**コンデンサの両端**から取ると、ローパスになる。コンデンサは
周波数が高いほど電流を通しやすい (低い周波数ではほとんど通さない)。そのため高い周波数は
コンデンサで GND へ逃げて弱まり、低い周波数はそのまま出てくる。

```circuit
title: 図2 RC ハイパス
parts:
  IN: port a1
  C2: capacitor a1 a2 100n
  R2: resistor a2 b2 1.5k
  OUT: port a3
  G2: ground b2
wires:
  - a2 -- a3
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-2.svg)

図2 のようにコンデンサと抵抗の**順番を入れ替え**、出力を**抵抗の両端**から取るとハイパスになる。
低い周波数はコンデンサに阻まれて弱まり、高い周波数はそのまま出てくる。

- 遮断周波数 (効き始めの目安の周波数): f<sub>c</sub> = 1 / (2π × R × C) = 1 / (2π × 1.5kΩ × 100nF)
  ≈ **1.1 kHz** (計算値。ローパスもハイパスも同じ式)
- f<sub>c</sub> では、出力は入力の 1/√2 ≈ **70.7%** (−3dB) になる
- 出力 ÷ 入力の比を**利得**と呼び、**dB** (デシベル) で表すことが多い。電圧の比 A は
  20 × log<sub>10</sub>A [dB] で、1 倍が 0 dB、0.707 倍が −3 dB、0.1 倍が −20 dB、0.01 倍が −40 dB

## 実体配線図

```breadboard
title: 図3 RC ローパスを組み、AD3 の W1 と Scope をつなぐ
board: half
parts:
  R1: resistor c5 c10 1.5k
  C1: capacitor/ceramic d10 d13 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (W1・Scope)
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - a13 -- -t13 black
  - AD.W1 -- a5 yellow
  - AD.GND -- -t3 black
  - AD.1+ -- e5 orange
  - AD.1- -- -t7 black
  - AD.2+ -- e10 green
  - AD.2- -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/05-rc-filter-1.svg)

図3 の `R1` の右端 (`c10`) と `C1` の左端 (`d10`) は同じ列 10 でつながる。この列が出力。
`C1` の右端の列 13 は、上の − レール (GND) へ黒線で落とす。
この題の計器は Analog Discovery 3 (AD3)。波形発生器 W1 の出力を `R1` の左端の列 5 へ、
AD3 の GND を上の − レールへ入れる。Scope は 1+ を入力の列 5、2+ を出力の列 10 に当て、
1−・2− は上の − レールへ落とす。発振器とオシロの GND は同じ − レールで 1 つになる。
W1 の出力は 100 µA 以下で、ブレッドボードの範囲に十分収まる。
テスターで読むときは、黒の棒を − レールに、赤の棒を列 5 (入力) と列 10 (出力) に
順に当てる。

ハイパスにしたいときは、`R1` と `C1` を入れ替えて挿し (入力 → C → R → GND)、
出力は R の上端から取る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 (R2) | 抵抗 (1/4 W) | 1.5 kΩ |
| C1 (C2) | セラミックコンデンサ | 100 nF (0.1µF) |
| — | 発振器・オシロ | Analog Discovery 3 (W1 と Scope) |

## 見るべき値

発振器 (0-6。スマホのトーン生成アプリでも可) で振幅 1 V 前後の正弦波を入れ、テスターの
交流電圧レンジか、AD3 の Scope (入力は直流を含まない正弦波なので、DC 結合のままでよい) で入力 (列 5) と出力 (列 10) を読み、出力 ÷ 入力を計算する。
周波数ごとに入力も読み直す (発振器によっては周波数で振幅が少し変わる)。下の表は**ローパス**の場合。

| 入れる周波数 | 期待する出力 (入力を 1 としたとき) | 分かること |
| --- | --- | --- |
| 100 Hz (f<sub>c</sub> の 1/10 以下) | 約 1.0 倍 (ほぼ素通し) | 低い周波数はそのまま通る |
| 1.1 kHz (f<sub>c</sub>) | 約 0.71 倍 (−3dB、計算値) | ここが「効き始め」の目安 |
| 11 kHz (f<sub>c</sub> の 10 倍) | 約 0.10 倍 (−20dB、計算値) | 高くなるほどよく弱まる |

**ハイパス**はこの逆 (100Hz で弱く、11kHz でよく通る) になる。

### オシロで f<sub>c</sub> の波形を見る

W1 を **1.06 kHz** (f<sub>c</sub> の計算値 1/(2π×1.5kΩ×100nF) = 1061 Hz)、振幅 1 V の正弦波にし、Scope の 1+ (入力) と 2+ (出力) を同じ 500 mV/div、
時間 200 µs/div で重ねる。ローパスの出力 (図の CH2) は、入力 (CH1) に対して振幅が 1/√2 = **0.707 倍**になり、位相が **45 度遅れる** (1 周期 943 µs の 1/8 = 118 µs)。

```scope
title: 図4 ローパスの遮断周波数 (1.06 kHz) — 出力 (CH2) は入力 (CH1) の 0.707 倍
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.06kHz 1V, range: 500mV/div, position: 0div}
ch2: {wave: ch1 | rc 150us, range: 500mV/div, position: 0div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/scope/05-rc-filter.svg)

読み値は CH1 が Vpp 2.00 V、CH2 が Vpp 1.41 V (どちらも 1.06 kHz)。比は 0.707 で、見るべき値の表の f<sub>c</sub> の行と合う。

## 周波数特性を計器で見る

上の表は周波数を 1 つずつ変えて読んだ。計器に周波数を**掃引** (少しずつ自動で変えること) させると、
利得と位相を周波数の関数として 1 枚のグラフ (**ボード線図**) で見られる。**位相**は、
出力の波の山が入力の山からどれだけずれるかを、1 周期を 360° として表した角度
(遅れは −、進みは +)。この節は Analog Discovery などの計器を持っている人向け。

### 結論: 1 kHz 前後のフィルタは Analog Discovery の Network で測る

f<sub>c</sub> が 1 kHz 前後のフィルタなら、おすすめの順は次のとおり。

1. **Analog Discovery の Network (ネットワークアナライザ)**。10 Hz〜100 kHz を
   1 分ほどで掃引し、利得と位相を 1 枚に描く。入力は 1 MΩ で、1.5 kΩ の回路を乱さない。
   この回路をそのまま測れる
2. **発振器と 2 ch のオシロ**。周波数を手で変えて、CH1 (入力) と CH2 (出力) の振幅の比を
   数点読む。ボード線図を描く機能 (Bode Plot・FRA などの名前) のあるオシロなら 1 と同じ図になる
3. **スマホのトーンとテスター**。上の「見るべき値」の 3 点を目安で確かめるだけならこれで足りる。
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

以下では、上の 3 つの計器 (Network・Spectrum・VNA) で実際に見る。

以下の値は f<sub>c</sub> = 1 / (2π × 1.5kΩ × 100nF) = **1.06 kHz** で計算した
(上の 1.1 kHz はこれを丸めた値)。

### ネットワークアナライザでボード線図を見る

Analog Discovery (AD) の **Network** は、W1 の正弦波の周波数を自動で変えながら、
CH1 (入力) に対する CH2 (出力) の利得と位相を測ってグラフにする。
操作の詳しい説明は Analog Discovery の教科書の 5-1 (ローパス)・5-2 (ハイパス)。

```circuit
title: 図5 AD の W1 で掃引し、CH1 (入力) と CH2 (出力) を比べる
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a4 a6 1.5k
  C1: capacitor a6 c6 100n
  M2: voltmeter a8 c8 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a4
  - c1 -- c3 -- c6 -- c8
  - a6 -- a8
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-3.svg)

```breadboard
title: 図6 図3 の基板に Analog Discovery をつなぐ
board: half
parts:
  R1: resistor c5 c10 1.5k
  C1: capacitor/ceramic d10 d13 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, W1, 1-, 2+, 2-]
wires:
  - a13 -- -t13 black
  - AD.GND -- -t3 black
  - AD.W1 -- b5 yellow
  - AD.1+ -- a5 orange
  - AD.1- -- -t7 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/05-rc-filter-2.svg)

部品の挿し方は図3 と同じ。W1 (黄) と CH1 の 1+ (橙) を入力の列 5 に、CH2 の 2+ (青) を
出力の列 10 に挿す。AD の GND と、CH1・CH2 の − 側 (1−・2−) は上の − レールへ落とす。
発振器とオシロの代わりを AD 1 台がする。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V、Offset 0 V (周波数は Network が動かす) |
| Network | Start 10 Hz、Stop 100 kHz、**Log**、Steps 101、Reference: Channel 1、表示: 利得 (dB) と位相 (deg) |

| 周波数 | ローパスの利得・位相 (計算値) | ハイパスの利得・位相 (計算値) |
| --- | --- | --- |
| 100 Hz | −0.04 dB・−5.4° | −20.55 dB・+84.6° |
| 1.06 kHz (f<sub>c</sub>) | −3.01 dB・−45.0° | −3.01 dB・+45.0° |
| 10 kHz | −19.53 dB・−83.9° | −0.05 dB・+6.1° |
| 100 kHz | −39.49 dB・−89.4° | 0.00 dB・+0.6° |

分かること:

- **f<sub>c</sub> から先は 10 倍ごとに約 20 dB ずつ下がる** (−20 dB/decade)。
  10 kHz と 100 kHz の差が約 20 dB になっているのをカーソルで確かめる
- **−3 dB になる周波数と、位相が ±45° になる周波数が同じ**。カーソルで −3 dB の点を
  探し、その周波数が 1.06 kHz 付近 (部品の誤差で ±5〜10 %) になることを見る
- ハイパス (図2 の並び) にすると、利得のグラフが左右に裏返り、位相の符号が + になる

Network に見えるはずのボード線図 (計算値)。上が利得、下が位相で、横軸は同じ周波数 (対数)。

```graph
title: 図7 Network のボード線図 — −3 dB の所が −45°
x: 周波数 Hz log 10..100k
y:
  - 利得 dB
  - 位相 deg
lines:
  利得 dB: 20*log10(1/sqrt(1+(x/1.06k)^2))
  位相 deg: -deg(atan(x/1.06k))
notes:
  - level -3dB
  - mark 100
  - mark 1.06k
  - mark 10k
  - mark 100k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/graph/05-rc-filter.svg)

図7 はグラフのフェンス (graph) で書いた。印 (mark) の 4 つの周波数は上の表の 4 行と同じで、
図の下の読み値も表と同じ数になる。

汎用のオシロスコープにも、発振器と組み合わせてボード線図を描く機能
(Bode Plot、周波数応答解析、FRA などの名前) を持つ機種がある。設定の意味は同じで、
入力を CH1、出力を CH2 に当てる。

### スペクトラムアナライザで高調波の減り方を見る

スペクトラムアナライザは、信号に含まれる周波数ごとの大きさを見る計器。
**方形波**は基本波の奇数倍 (3 倍・5 倍 …) の周波数の正弦波 (高調波) を含み、
その大きさは n 倍の周波数で 1/n に並ぶ (Analog Discovery の教科書の 4-2)。
これをローパスに通すと、f<sub>c</sub> より上の高調波ほど強く削られる。
入力 (CH1) と出力 (CH2) のスペクトルを並べると、**高調波ごとの差がそのままフィルタの利得**になる。

つなぎ方は図5・図6 と同じ。W1 を方形波にして、AD の **Spectrum** で CH1 と CH2 を見る。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、**500 Hz**、Amplitude 1 V、Offset 0 V、Duty 50 % |
| Spectrum | Channel 1 と Channel 2 を表示、**Start 0 Hz、Stop 10 kHz**、Window: Flat-top、単位: dBV |

```spectrum
title: 図8 入力 (CH1) — 方形波 500 Hz の高調波
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
signal: square 500Hz 1V
markers: [500Hz, 1.5kHz, 4.5kHz, 9.5kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/spectrum/05-rc-filter-1.svg)

```spectrum
title: 図9 出力 (CH2) — ローパスを通した後
device: ad2
sweep: 0-10kHz
samples: 8192
window: flattop
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

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/spectrum/05-rc-filter-2.svg)

| 高調波 | 周波数 | CH1 (計算値) | CH2 (計算値) | 差 = フィルタの利得 |
| --- | --- | --- | --- | --- |
| 1 (基本波) | 500 Hz | −0.91 dBV | −1.78 dBV | −0.87 dB |
| 3 | 1.5 kHz | −10.45 dBV | −15.22 dBV | −4.77 dB |
| 9 | 4.5 kHz | −20.00 dBV | −32.78 dBV | −12.78 dB |
| 19 | 9.5 kHz | −26.49 dBV | −45.58 dBV | −19.09 dB |

分かること:

- 差の列は、ネットワークアナライザで見たローパスの利得の曲線と同じ値になる。
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

### VNA で見る (値を替えて MHz 帯へ)

VNA (ベクトルネットワークアナライザ) は CH0 から信号を出し、CH1 に届いた大きさと位相 (S21) を測る。
この本の標準の機種は LiteVNA64 (50 kHz〜6.3 GHz)。歴史的な機種の NanoVNA-H4 も、同じ手順で測れる。
そのまま使えない理由は 2 つ:

- 掃引の下限が **50 kHz** (LiteVNA64)。f<sub>c</sub> = 1.06 kHz は範囲の外
- CH0 の出力と CH1 の入力は、どちらも **50 Ω**。1.5 kΩ の R1 の後ろに 50 Ω の
  CH1 がつながると、出力はほぼ 0 まで落ちてしまう

そこで **R1 を外し、VNA の 50 Ω に R の役目をさせる**。C を 1 つ置くだけで RC フィルタになる。

- ローパス: C を信号の線と GND の間に置く (並列)。C から見た R は CH0 の 50 Ω と
  CH1 の 50 Ω の並列で **25 Ω**。f<sub>c</sub> = 1 / (2π × 25Ω × 10nF) = **637 kHz**
- ハイパス: C を信号の線に直列に置く。R は 50 Ω + 50 Ω = **100 Ω**。
  f<sub>c</sub> = 1 / (2π × 100Ω × 10nF) = **159 kHz**

```circuit
title: 図10 VNA の入出力の抵抗を R にしたローパス (C1 は 10 nF)
parts:
  J1: sma a2 mirror CH0
  C1: capacitor a4 b4 10n
  J2: sma a6 CH1
  G1: ground b2
  G2: ground b4
  G3: ground b6
wires:
  - J1.1 -- a4 -- J2.1
  - J1.2 -- b2
  - J2.2 -- b6
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-4.svg)

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
device: litevna64
sweep: 50k-10M 201
title: 図11 C 1 つのローパスの S21 (fc = 637 kHz)
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

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/vna/05-rc-filter.svg)

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
  図5 の回路と同じ
- **計器をつなぐと、計器の抵抗も回路の一部になる**。1.5 kΩ のフィルタを 50 Ω の
  計器で測れないのはこのため。AD の CH1・CH2 の入力は 1 MΩ なので、図5 では無視できた
- Stop を 30 MHz まで広げると、ローパスの S21 が十数 MHz あたりで底を打って戻り始める。
  C1 のピンとブレッドボードのインダクタンス (10 nH ほど) と C1 の直列共振で、
  その先はコンデンサとして働かない (NanoVNA の教科書の 4-2)

## 出典

自作。
