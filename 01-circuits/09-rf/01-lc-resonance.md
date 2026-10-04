---
book: circuits
chapter: 9
id: 9-1
title: LC 同調 — 共振を LED で見る
tier: 50
source: 自作
board: BB
---

# 9-1 LC 同調 — 共振を LED で見る

コイルとコンデンサを直列につなぐと、ある周波数だけでインピーダンス (交流の流れにくさ。
抵抗と、次に説明するリアクタンスを合わせたもの) が最小になる。
これが**直列共振**で、その周波数 f<sub>0</sub> は 1 / (2π√(LC)) で決まる。ファンクションジェネレータの
周波数を動かし、共振点の近くだけ LED が光るようすを見る。ラジオの同調回路と同じ原理。
あわせてオシロスコープで輪を流れる電流を読み、**周波数と電流のグラフ (共振曲線)** を描く。

## 回路図

```circuit
title: 図1 R1 の電圧でトランジスタをオンにして LED を点ける
parts:
  V1: sine f1 h1 3
  M1: voltmeter f3 h3 l=$\mathrm{CH1}$
  L1: inductor f4 f5 10m
  C1: capacitor f5 f6 10n
  R1: resistor f7 h7 100 i=I
  M2: voltmeter f9 h9 l=$\mathrm{CH2}$
  R2: resistor f10 f11 10k
  VCC: vcc c12 5V
  R3: resistor c12 d12 330
  D1: led d12 e12 red
  Q1: npn f12 2SC1815
  G1: ground h1
wires:
  - f1 -- f3 -- f4
  - f6 -- f7 -- f9 -- f10
  - f11 -- Q1.B
  - e12 -- Q1.C
  - Q1.E -- h12
  - h1 -- h3 -- h7 -- h9 -- h12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/01-lc-resonance.svg)

L1・C1・R1 が直列の 1 つの輪になっている。LED はこの輪の外にあり、別の 5V から点ける。

- 共振周波数 f<sub>0</sub> = 1 / (2π√(10mH × 10nF)) **≈ 15.9kHz**
- コイルとコンデンサが交流を妨げる度合いを**リアクタンス**という。コイルは
  X<sub>L</sub> = 2πfL で周波数が高いほど大きく、コンデンサは X<sub>C</sub> = 1/(2πfC) で
  周波数が低いほど大きい。直列につなぐと 2 つは逆向きに働き、差し引きになる
- f<sub>0</sub> では X<sub>L</sub> と X<sub>C</sub> が等しくなり (どちらも約 1kΩ)、
  ちょうど打ち消し合う。輪の中に残るのは R1 とコイルの巻線抵抗 (小さな 10mH のコイルで
  実測 20Ω ほど) だけになる
- 共振から離れると打ち消し合わなくなり、リアクタンスの分だけインピーダンスが
  跳ね上がって電流が減る

**R1 の電圧で LED を点ける。** 輪の電流 I は R1 に I × 100Ω の電圧を作る。

- 正の半周期でこれが約 0.6V を超えると Q1 のベースに電流が流れ、Q1 がオンになる
  (コレクタに電流を通す)。すると VCC (5V) → R3 → D1 → Q1 の道で LED に電流が流れる
- ベースの電流は R2 (10kΩ) で絞られ、多くて 0.2mA ほど。輪の電流 (共振で 17.6〜24.9mA) の
  1% に満たないので、輪の電流はほとんど変わらない。LTspice (回路の電圧と電流をパソコンで
  計算する無料のシミュレータ) で、Q1 を外したときと比べた差は 0.5% 未満
- LED の電流は R3 で決まる。Q1 がオンの間は (5V − 1.8V − 0.2V) ÷ 330Ω ≈ 9mA
  (1.8V は LED の順方向電圧、0.2V はオンの Q1 に残る電圧)。
  オンになるのは正の半周期の頂上の近くだけなので、平均では 3mA ほど
- 負の半周期は R1 の電圧が Q1 のベースを逆向きに押す。その大きさは最大でも 2.5V
  (出力 ≈ 0Ω の発生器のとき) で、2SC1815 のエミッタ・ベース間の耐圧 5V より小さい
- MOSFET (2N7000 など) ならゲートに電流が流れず、輪への影響はさらに小さい。
  ただしゲートのしきい値電圧が 0.8〜3V とばらつき、R1 の電圧は共振でも 1.8V ほど
  (出力 50Ω のとき) なので、個体によってはオンにならない。バイポーラのトランジスタは
  どれも約 0.6V でオンになるので、ここではこちらを使う

**LED は輪の中に入れない。** LED を輪に直列に入れても光りはするが、共振を乱す。
LED は約 1.8V を超えるまで電流を流さないので、輪の電流を半周期ごとの細い山に刻んでしまう。
LTspice で確かめると、向きを逆にした LED 2 本を輪に入れたとき、f<sub>0</sub> の電流は
17.6mA から 4.5mA に落ち、共振曲線も左右で揃わなくなる (8kHz で 2.3mA、32kHz で 1.2mA)。
LED が 1 本だけだと、C1 が LED の流した電流で片側に充電され、数周期で LED を逆向きに
押さえ込んで消えてしまう。光らせる役目と共振させる役目を分けるため、LED は輪の外に置く。

**R1 は GND の側に置く。** オシロのプローブの GND クリップは GND にしか付けられない。
R1 の下の端を GND にしておけば、CH2 で R1 の上の端の電圧を測るだけで、
輪を流れる電流が I = V<sub>R1</sub> / 100Ω で分かる。CH1 は発生器の出力を見る。

## 実体配線図

```breadboard
title: 図2 トランジスタで LED を点ける
board: half
parts:
  L1: inductor/axial d3 d8 10m
  C1: capacitor/ceramic b8 b10 10n
  R1: resistor d10 d14 100
  R2: resistor i10 i15 10k
  Q1: transistor g15(B) g16(C) g17(E) 2SC1815
  D1: led c17(A) c16(K) red
  R3: resistor b17 b21 330
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- b3 yellow
  - AD.1+ -- a3 orange
  - AD.2+ -- a10 blue
  - AD.1- -- -t12 black
  - AD.2- -- -t13 black
  - AD.GND -- -t11 black
  - a14 -- -t14 black
  - e10 -- f10 blue
  - f16 -- e16 green
  - a21 -- +t21 red
  - i17 -- -b19 black [h40]
  - AD.V+ -- +t25 red
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/01-lc-resonance.svg)

- AD3 の W1 (Wavegen) が図1 の V1。正弦波を出し、周波数を 2kHz〜32kHz の間で動かす (中身は部品表)。オシロは Scope の 1 (CH1) と 2 (CH2)
- 上の半分が共振の輪。列 3 に W1 (b3)・CH1 の 1+ (a3)・L1 の左の足、
  列 10 に C1・R1・CH2 (a10) が集まる。R1 の右の端 (列 14) は上の − レールへ
- 列 10 の輪の電圧を青の線で下の半分へ渡し、R2 で Q1 のベース (列 15) に入れる。
  2SC1815 は平らな面を見て左から E・C・B。図のとおり左から B・C・E に挿すには、
  平らな面を奥 (f 行側) に向ける
- コレクタ (列 16) は緑の線で上の半分へ戻り、D1 のカソードにつながる。
  D1 のアノード (列 17) から R3 を通って上の + レール (5V) へ
- エミッタ (列 17 の下の半分) は下の − レールへ。上の − レール (AD3 の GND・1−・2−) と
  下の − レールは 29 列の黒線でつなぐ。上の + レールには AD3 の V+ (5V) だけを入れる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| V1 | 信号発生器 (AD3 の Wavegen W1。出力は約 0 Ω) | 正弦波、6 V<sub>pp</sub> (図1 の 3 V は peak)、2 kHz〜32 kHz、AD3 の W1 は出力抵抗 ≈ 0 Ω (出力 50 Ω の発生器でもよい。値は「見るべき値」の表の 2 列) |
| L1 | インダクタ (アキシャル) | 10 mH |
| C1 | セラミックコンデンサ | 10 nF (103)、耐圧 50 V |
| R1 | 抵抗 (1/4 W) | 100 Ω |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| R3 | 抵抗 (1/4 W) | 330 Ω |
| D1 | 赤色 LED | 1 本 |
| Q1 | NPN トランジスタ | 2SC1815 |
| VCC | 電源 | 5 V (AD3 の Supplies の V+)。GND は W1・Scope の GND と共通 |

## 計器の設定

計器は Analog Discovery 3 (AD3)。信号源 (Wavegen)・オシロ (Scope)・5 V (Supplies) が 1 台で足り、波形は 2〜32 kHz で Scope の範囲に入る。

発生器:

| 項目 | 値 |
| --- | --- |
| 波形 | 正弦波 |
| 振幅 | 3V<sub>peak</sub> (6V<sub>pp</sub>)、オフセット 0V |
| 周波数 | 2kHz〜32kHz (下の表の周波数に順に合わせる) |

オシロスコープ:

| 項目 | 値 |
| --- | --- |
| 結合 | CH1・CH2 とも DC |
| 電圧レンジ | CH1 2 V/div、CH2 1 V/div (共振点の 3.5〜5.0V<sub>pp</sub> が 3.5〜5 目盛りに入る) |
| 時間レンジ | 20 µs/div (15.9kHz の 1 周期 63µs が約 3 目盛り)。周波数を変えたら 2〜3 周期が見えるように合わせ直す |
| トリガ | CH1、立ち上がり、レベル 0V |
| 測定 | CH2 の Vpp (自動測定があれば使う) |

AD3 では WaveForms の Wavegen (W1)・Scope・Supplies (V+ = 5 V) で設定する。PC オシロでも同じ設定でよい。LED を光らせる 5 V の電流 (約 3〜9 mA) は AD3 の電源 1 系統の約 50 mA に収まる。
共振から離れると CH2 は 0.1V<sub>pp</sub> ほどまで小さくなるので、読みにくければ CH2 のレンジを下げる。

## 見るべき値

周波数ごとに CH2 の Vpp を読み、電流のピークに直す。

I<sub>peak</sub> = (CH2 の Vpp ÷ 2) ÷ 100Ω (例: 3.52V<sub>pp</sub> → 17.6mA)

LTspice のシミュレーション値。LED は赤色 (順方向電圧 約 1.8V)、コイルの巻線抵抗は 20Ω とした。
多くのファンクションジェネレータは出力に 50Ω の抵抗を持ち、それが輪に直列に入る。
出力抵抗がほぼ 0Ω の発生器 (AD3 の W1 など) のときの値も並べた。LED の電流は出力 50Ω のときの平均。

| 周波数 | CH2 (出力 50Ω) | I<sub>peak</sub> (出力 50Ω) | LED の平均電流 | CH2 (出力 ≈ 0Ω) | I<sub>peak</sub> (出力 ≈ 0Ω) | 測った CH2 | 測った I<sub>peak</sub> |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2kHz | 0.08V<sub>pp</sub> | 0.38mA | 0 | 0.08V<sub>pp</sub> | 0.38mA | | |
| 5kHz | 0.21V<sub>pp</sub> | 1.0mA | 0 | 0.21V<sub>pp</sub> | 1.0mA | | |
| 8kHz | 0.40V<sub>pp</sub> | 2.0mA | 0 | 0.40V<sub>pp</sub> | 2.0mA | | |
| 10kHz | 0.61V<sub>pp</sub> | 3.1mA | 0 | 0.62V<sub>pp</sub> | 3.1mA | | |
| 12kHz | 1.01V<sub>pp</sub> | 5.0mA | 0 | 1.03V<sub>pp</sub> | 5.1mA | | |
| 13kHz | 1.36V<sub>pp</sub> | 6.8mA | 0.03mA | 1.41V<sub>pp</sub> | 7.1mA | | |
| 14kHz | 1.95V<sub>pp</sub> | 9.7mA | 1.1mA | 2.11V<sub>pp</sub> | 10.6mA | | |
| 15kHz | 2.89V<sub>pp</sub> | 14.4mA | 2.7mA | 3.55V<sub>pp</sub> | 17.7mA | | |
| **15.9kHz (f<sub>0</sub>)** | **3.52V<sub>pp</sub>** | **17.6mA** | **3.1mA** | **4.99V<sub>pp</sub>** | **24.9mA** | | |
| 17kHz | 2.78V<sub>pp</sub> | 13.9mA | 2.6mA | 3.36V<sub>pp</sub> | 16.7mA | | |
| 18kHz | 2.00V<sub>pp</sub> | 10.0mA | 1.2mA | 2.18V<sub>pp</sub> | 10.9mA | | |
| 20kHz | 1.22V<sub>pp</sub> | 6.1mA | 0 | 1.26V<sub>pp</sub> | 6.3mA | | |
| 25kHz | 0.63V<sub>pp</sub> | 3.2mA | 0 | 0.64V<sub>pp</sub> | 3.2mA | | |
| 32kHz | 0.39V<sub>pp</sub> | 2.0mA | 0 | 0.40V<sub>pp</sub> | 2.0mA | | |

- **f<sub>0</sub> で電流が最大になる。** 輪の中の抵抗は R1・巻線・発生器の出力の 170Ω だけになる。
  山の鋭さは Q という数で表し、直列共振では Q = (1/R) × √(L/C) (R は輪の中の抵抗の合計)。
  Q = (1/170Ω) × √(10mH / 10nF) = 1000Ω / 170Ω ≈ 5.9 (出力 ≈ 0Ω なら 120Ω で Q ≈ 8.3)
- **LED は 14〜18kHz の間だけ点く。** Q1 は R1 の電圧が約 0.6V を超えるまでオンにならないので、
  LED は山の頂上の近くだけを切り取って見せる。明るさからは山の鋭さを読めないので、
  山の形は CH2 で読む
- **共振では C1 の両端に発生器の約 Q 倍の電圧がかかる。** 15.9kHz の C1 のリアクタンスは
  約 1kΩ なので、17.6mA × 1kΩ ≈ 17.6V<sub>peak</sub> (出力 ≈ 0Ω なら約 25V<sub>peak</sub>)。
  発生器の 3V<sub>peak</sub> よりずっと大きい。C1 は耐圧 50V のセラミックコンデンサを使う

### グラフに描く

測った I<sub>peak</sub> を、横軸に周波数、縦軸に電流をとってグラフにする
(2kHz〜32kHz と 16 倍の幅があるので、片対数の方眼紙で横軸を対数にすると見やすい)。
f<sub>0</sub> = 15.9kHz で頂点になる山 (共振曲線) が描ければよい。

見えるはずの共振曲線 (上の表のシミュレーション値)。横軸は周波数 (対数)。

```graph
title: 図3 共振曲線 — 15.9kHz で山になり、発生器の出力抵抗が小さいほど高い
x: 周波数 Hz log 2k..32k
y: 電流 mA
lines:
  出力 50Ω mA:
    - 2k 0.38
    - 5k 1.0
    - 8k 2.0
    - 10k 3.1
    - 12k 5.0
    - 13k 6.8
    - 14k 9.7
    - 15k 14.4
    - 15.9k 17.6
    - 17k 13.9
    - 18k 10.0
    - 20k 6.1
    - 25k 3.2
    - 32k 2.0
  出力 ≈0Ω mA:
    - 2k 0.38
    - 5k 1.0
    - 8k 2.0
    - 10k 3.1
    - 12k 5.1
    - 13k 7.1
    - 14k 10.6
    - 15k 17.7
    - 15.9k 24.9
    - 17k 16.7
    - 18k 10.9
    - 20k 6.3
    - 25k 3.2
    - 32k 2.0
notes:
  - band 14k 18k: LED が点く
  - mark 8k
  - mark 15.9k
  - mark 32k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/graph/01-lc-resonance.svg)

測った I<sub>peak</sub> は同じ軸の方眼紙に点で打ち、この 2 本と比べる。

- 山の頂点の周波数が計算の 15.9kHz からずれていたら、L1 と C1 の実際の値がずれている
  (f<sub>0</sub> は √(LC) に反比例するので、L と C がともに 10% 大きければ f<sub>0</sub> は 1/1.1 倍、約 9% 下がる)
- 横軸を対数にした山は左右で揃う。f<sub>0</sub>/2 の 8kHz と 2f<sub>0</sub> の 32kHz が、どちらも 2.0mA
- 表の出力 50Ω と出力 ≈ 0Ω の 2 列を重ねると (図3)、Q の違いが見える。
  すそ (12kHz より下と 20kHz より上) はほとんど同じで、頂点だけが 17.6mA と 24.9mA で違う。
  発生器の 50Ω も輪の抵抗に入り、その分だけ山が低く平らになるため
- 山の鋭さ (Q の高さ) は、輪の抵抗を小さくするほど増す。R1 を 47Ω に替えると、
  f<sub>0</sub> の電流は 17.6mA → 25.6mA に上がるが、12kHz (5.0 → 5.1mA) と 20kHz (6.1 → 6.3mA) では
  ほとんど変わらない (出力 50Ω でのシミュレーション値。電流は CH2 の Vpp ÷ 2 ÷ 47Ω で読み、
  CH2 は 0.5 V/div にする)。R1 の電圧は共振で約 1.2V<sub>peak</sub> あるので、Q1 はオンになり LED も点く
- R1 を 47Ω にするのは出力 50Ω の発生器のときだけにする。出力 ≈ 0Ω の発生器では
  f<sub>0</sub> の電流が約 45mA になり、Analog Discovery 3 の Wavegen が歪みなく出せる 30mA を超える。
  C1 の電圧も約 45V<sub>peak</sub> になり、耐圧 50V に近づく

### 波形の形も見る

出力 50Ω の発生器で見える画面。CH1 は発生器の出力、CH2 は R1 の電圧 (輪の電流 × 100Ω)。

```scope
title: 図4 共振点 (15.9kHz) — CH2 が最大になり、CH1 と位相が揃う
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 15.9kHz 4.23Vpp, range: 2V/div}
ch2: {wave: sine 15.9kHz 3.52Vpp, range: 1V/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/01-lc-resonance-1.svg)

```scope
title: 図5 共振より下 (12kHz) — CH2 は 1.01Vpp に下がり、CH1 より進む
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 12kHz 5.88Vpp, range: 2V/div}
ch2: {wave: sine 12kHz 1.01Vpp phase 78deg, range: 200mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/01-lc-resonance-2.svg)

- **CH2 は、どの周波数でもきれいな正弦波になる。** 輪の中には L1・C1・R1 しか無いので、
  電流の形は発生器の電圧の形のまま
- **共振点では CH1 と CH2 の位相が揃う (図4)。** L1 と C1 のリアクタンスが打ち消し合い、
  輪が抵抗だけに見えるため
- **共振より下では CH2 が CH1 より進む (図5、約 78°)。** C1 のリアクタンスが勝ち、輪がコンデンサのように
  振る舞うため。共振より上では逆にコイルが勝ち、CH2 は遅れる (20kHz で約 75° の遅れ)。
  位相は Measurements の Phase か、2 つの波の山の時間差 ÷ 周期 × 360° で読む
- 出力 50Ω の発生器では、共振点で CH1 の振幅が下がる (6.0 → 約 4.2V<sub>pp</sub>、図4)。
  電流が増えた分だけ発生器の中の 50Ω で電圧が落ちるため。出力 ≈ 0Ω の発生器では下がらない
- 図5 は CH2 を 200 mV/div に下げてあるので、画面では CH1 より大きく見える。1 V/div のままだと
  1 目盛りほどにしかならない。大きさは目盛りではなく Vpp の読み値で比べる

## 出典

自作。
