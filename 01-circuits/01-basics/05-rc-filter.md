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
- 後半「周波数特性を計器で見る」: 周波数特性 (周波数ごとの利得) を、Analog Discovery の Network で
  ボード線図 (図5〜図7) にまとめて見る

帯ごとの計器の選び方と、スペクトラムアナライザ (高調波の減り方)・VNA (値を替えて MHz 帯) での見方は 1-17 に分けた。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 RC ローパス
parts:
  IN: port 1,1
  R1: resistor 1,1 2,1 1.5k
  C1: capacitor 2,1 2,2 100n
  OUT: port 3,1
  G1: ground 2,2
wires:
  - 2,1 -- 3,1
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-1.svg)

図1 のように出力を**コンデンサの両端**から取ると、ローパスになる。コンデンサは
周波数が高いほど電流を通しやすい (低い周波数ではほとんど通さない)。そのため高い周波数は
コンデンサで GND へ逃げて弱まり、低い周波数はそのまま出てくる。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 RC ハイパス
parts:
  IN: port 1,1
  C2: capacitor 1,1 2,1 100n
  R2: resistor 2,1 2,2 1.5k
  OUT: port 3,1
  G2: ground 2,2
wires:
  - 2,1 -- 3,1
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-2.svg)

図2 のようにコンデンサと抵抗の**順番を入れ替え**、出力を**抵抗の両端**から取るとハイパスになる。
低い周波数はコンデンサに阻まれて弱まり、高い周波数はそのまま出てくる。

- 遮断周波数 (効き始めの目安の周波数): f<sub>c</sub> = 1 / (2π × R × C) = 1 / (2π × 1.5 kΩ × 100 nF)
  ≈ **1.1 kHz** (計算値。ローパスもハイパスも同じ式)
- f<sub>c</sub> では、出力は入力の 1/√2 ≈ **70.7%** (−3 dB) になる
- 出力 ÷ 入力の比を**利得**と呼び、**dB** (デシベル) で表すことが多い。電圧の比 A は
  20 × log<sub>10</sub>A [dB] で、1 倍が 0 dB、0.707 倍が −3 dB、0.1 倍が −20 dB、0.01 倍が −40 dB

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
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
  - AD.W1 -- a5 yellow [h23, v106]
  - AD.GND -- -t3 black
  - AD.1+ -- b5 orange [h-7, v126]
  - AD.1- -- -t7 black
  - AD.2+ -- a10 green
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
| C1 (C2) | セラミックコンデンサ | 100 nF (0.1 µF) |
| — | 発振器・オシロ | Analog Discovery 3 (W1 と Scope) |

## 見るべき値

発振器 (0-6。スマホのトーン生成アプリでも可) で振幅 1 V 前後の正弦波を入れ、テスターの
交流電圧レンジか、AD3 の Scope (入力は直流を含まない正弦波なので、DC 結合のままでよい) で入力 (列 5) と出力 (列 10) を読み、出力 ÷ 入力を計算する。
周波数ごとに入力も読み直す (発振器によっては周波数で振幅が少し変わる)。下の表は**ローパス**の場合。

| 入れる周波数 | 期待する出力 (入力を 1 としたとき) | 分かること |
| --- | --- | --- |
| 100 Hz (f<sub>c</sub> の 1/10 以下) | 約 1.0 倍 (ほぼ素通し) | 低い周波数はそのまま通る |
| 1.1 kHz (f<sub>c</sub>) | 約 0.71 倍 (−3 dB、計算値) | ここが「効き始め」の目安 |
| 11 kHz (f<sub>c</sub> の 10 倍) | 約 0.10 倍 (−20 dB、計算値) | 高くなるほどよく弱まる |

**ハイパス**はこの逆 (100 Hz で弱く、11 kHz でよく通る) になる。

### オシロで f<sub>c</sub> の波形を見る

W1 を **1.06 kHz** (f<sub>c</sub> の計算値 1/(2π×1.5 kΩ×100 nF) = 1061 Hz)、振幅 1 V の正弦波にし、Scope の 1+ (入力) と 2+ (出力) を同じ 500 mV/div、
時間 200 µs/div で重ねる。ローパスの出力 (図の CH2) は、入力 (CH1) に対して振幅が 1/√2 = **0.707 倍**になり、位相が **45 度遅れる** (1 周期 943 µs の 1/8 = 118 µs)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
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

f<sub>c</sub> が 1 kHz 前後のフィルタは、Analog Discovery の Network で測るのがよい (計器の選び方は 1-17)。
以下の値は f<sub>c</sub> = 1 / (2π × 1.5 kΩ × 100 nF) = **1.06 kHz** で計算した
(上の 1.1 kHz はこれを丸めた値)。

### ネットワークアナライザでボード線図を見る

Analog Discovery (AD) の **Network** は、W1 の正弦波の周波数を自動で変えながら、
CH1 (入力) に対する CH2 (出力) の利得と位相を測ってグラフにする。
操作の詳しい説明は Analog Discovery の教科書の 5-1 (ローパス)・5-2 (ハイパス)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図5 AD の W1 で掃引し、CH1 (入力) と CH2 (出力) を比べる
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  R1: resistor 4,1 6,1 1.5k
  C1: capacitor 6,1 6,3 100n
  M2: voltmeter 8,1 8,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 4,1
  - 1,3 -- 3,3 -- 6,3 -- 8,3
  - 6,1 -- 8,1
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/05-rc-filter-3.svg)

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
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
# グラフ (tommie-fence の graph フェンス)
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

## LTspice での確かめ

`sim/05-rc-filter.cir` (図1〜図7 の 1.5 kΩ + 100 nF) を AC 解析した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ローパスの利得 10 kHz・100 kHz | −19.53 dB・−39.49 dB | −19.53 dB・−39.49 dB | 合う |
| ハイパスの利得 100 Hz・1.06 kHz・10 kHz | −20.55 dB・−3.01 dB・−0.05 dB | −20.55 dB・−3.01 dB・−0.05 dB | 合う |

## 出典

自作。

参考: [ローパスフィルタ (Wikipedia)](https://ja.wikipedia.org/wiki/ローパスフィルタ)、[ハイパスフィルタ (Wikipedia)](https://ja.wikipedia.org/wiki/ハイパスフィルタ)
