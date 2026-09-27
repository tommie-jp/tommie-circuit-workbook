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

コイルとコンデンサを直列につなぐと、ある周波数だけでインピーダンスが最小になる。
これが**直列共振**で、f<sub>0</sub> = 1 / (2π√(LC)) で決まる。ファンクションジェネレータの
周波数を動かし、共振点だけ LED が明るく光るようすを見る。ラジオの同調回路と同じ原理。
あわせてオシロスコープで輪を流れる電流を読み、**周波数と電流のグラフ (共振曲線)** を描く。

## 回路図

```circuit
title: 図1 直列共振と向きの違う 2 本の LED
parts:
  V1: sine a1 d1 3
  M1: voltmeter a3 d3 l=$\mathrm{CH1}$
  L1: inductor a4 a5 10m
  C1: capacitor a5 a6 10n
  D1: led a7 b7 red
  D2: led b9 a9 red
  R1: resistor b10 d10 100 i=I
  M2: voltmeter b12 d12 l=$\mathrm{CH2}$
  G1: ground d1
wires:
  - a1 -- a3 -- a4
  - a6 -- a7 -- a9
  - b7 -- b9 -- b10 -- b12
  - d1 -- d3 -- d10 -- d12
```

L1・C1・LED・R1 が直列の 1 つの輪になっている。

- 共振周波数 f<sub>0</sub> = 1 / (2π√(10mH × 10nF)) **≈ 15.9kHz**
- 共振ではコイルのリアクタンス (jωL) とコンデンサのリアクタンス (1/jωC) が
  ちょうど打ち消し合い、輪の中は R1 とコイルの巻線抵抗 (小さな 10mH のコイルで
  実測 20Ω ほど) と LED だけになる
- 共振から離れると打ち消し合わなくなり、リアクタンスの分だけインピーダンスが
  跳ね上がって電流が減る

**LED は向きを逆にして 2 本並べる。** C1 は直流を通さないので、LED が 1 本だと
LED が流した電流で C1 が片側に充電され、数周期で LED を逆向きに押さえ込んで
消えてしまう (LTspice で確かめると、15.9kHz でも 20ms 後の電流は 0.01mA 程度)。
2 本あれば正の半周期は D1、負の半周期は D2 が流し、C1 に直流がたまらない。

**R1 は GND の側に置く。** オシロのプローブの GND クリップは GND にしか付けられない。
R1 の下の端を GND にしておけば、CH2 で R1 の上の端の電圧を測るだけで、
輪を流れる電流が I = V<sub>R1</sub> / 100Ω で分かる。CH1 は発生器の出力を見る。

## 実体配線図

```breadboard
title: 図2 発生器とオシロスコープをつなぐ
board: half
parts:
  L1: inductor/axial c3 c8 10m
  C1: capacitor/ceramic a8 a10 10n
  D1: led c10(A) c11(K) red
  D2: led e11(A) e10(K) red
  R1: resistor b11 b16 100
  SCOPE:
    type: device
    at: top
    label: オシロスコープ
    pins: [CH1, CH2, GND]
  GEN:
    type: device
    at: bottom
    label: 信号発生器
    pins: [OUT, GND]
wires:
  - SCOPE.CH1 -- a3 orange
  - SCOPE.CH2 -- a11 blue
  - SCOPE.GND -- -t20 black
  - a16 -- -t16 black
  - GEN.OUT -- e3 yellow
  - GEN.GND -- -b6 black
  - -t28 -- -b28 black
```

- GEN (信号発生器) は正弦波 3V<sub>peak</sub> (6V<sub>pp</sub>) を出すファンクション
  ジェネレータ。周波数を 2kHz〜32kHz の間で動かす
- 列 3 に発生器の出力 (e3)・CH1 (a3)・L1 の左の足が集まる
- 列 10 に C1・D1 のアノード・D2 のカソード、列 11 に D1 のカソード・D2 の
  アノード・R1・CH2 (a11) が集まる。これで 2 本の LED が逆向きに並ぶ
- R1 の右の端 (列 16) は上の − レールへ。上の − レールにはオシロの GND、
  下の − レールには発生器の GND が入り、2 本のレールは 28 列の黒線でつなぐ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 | インダクタ (アキシャル) | 10 mH |
| C1 | セラミックコンデンサ | 10 nF (103) |
| D1, D2 | 赤色 LED | 同じものを 2 本 |
| R1 | 抵抗 (1/4 W) | 100 Ω |

## 計器の設定

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
| 電圧レンジ | CH1 2 V/div、CH2 0.2 V/div (共振点で 0.9〜1.2V<sub>pp</sub> が 6 目盛りに入る) |
| 時間レンジ | 20 µs/div (15.9kHz の 1 周期 63µs が約 3 目盛り)。周波数を変えたら 2〜3 周期が見えるように合わせ直す |
| トリガ | CH1、立ち上がり、レベル 0V |
| 測定 | CH2 の Vpp (自動測定があれば使う) |

PC オシロは付属ソフトの Scope 画面、AD2 は WaveForms の Scope で同じように設定する。

## 見るべき値

周波数ごとに CH2 の Vpp を読み、電流のピークに直す。

I<sub>peak</sub> = (CH2 の Vpp ÷ 2) ÷ 100Ω (例: 0.91V<sub>pp</sub> → 4.5mA)

LTspice のシミュレーション値。LED は赤色 (順方向電圧 約 1.8V)、コイルの巻線抵抗は 20Ω とした。
多くのファンクションジェネレータは出力に 50Ω の抵抗を持ち、それが輪に直列に入る。
出力抵抗がほぼ 0Ω の発生器 (AD2 の W1 など) のときの値も並べた。

| 周波数 | CH2 (出力 50Ω) | I<sub>peak</sub> (出力 50Ω) | CH2 (出力 ≈ 0Ω) | I<sub>peak</sub> (出力 ≈ 0Ω) | 測った CH2 | 測った I<sub>peak</sub> |
| --- | --- | --- | --- | --- | --- | --- |
| 2kHz | 0.11V<sub>pp</sub> | 0.56mA | 0.12V<sub>pp</sub> | 0.58mA | | |
| 5kHz | 0.29V<sub>pp</sub> | 1.4mA | 0.30V<sub>pp</sub> | 1.5mA | | |
| 8kHz | 0.47V<sub>pp</sub> | 2.3mA | 0.49V<sub>pp</sub> | 2.4mA | | |
| 10kHz | 0.55V<sub>pp</sub> | 2.8mA | 0.57V<sub>pp</sub> | 2.9mA | | |
| 12kHz | 0.64V<sub>pp</sub> | 3.2mA | 0.69V<sub>pp</sub> | 3.4mA | | |
| 14kHz | 0.80V<sub>pp</sub> | 4.0mA | 0.96V<sub>pp</sub> | 4.8mA | | |
| 15kHz | 0.89V<sub>pp</sub> | 4.4mA | 1.16V<sub>pp</sub> | 5.8mA | | |
| **15.9kHz (f<sub>0</sub>)** | **0.91V<sub>pp</sub>** | **4.5mA** | **1.24V<sub>pp</sub>** | **6.2mA** | | |
| 17kHz | 0.83V<sub>pp</sub> | 4.2mA | 1.08V<sub>pp</sub> | 5.4mA | | |
| 18kHz | 0.73V<sub>pp</sub> | 3.6mA | 0.89V<sub>pp</sub> | 4.4mA | | |
| 20kHz | 0.56V<sub>pp</sub> | 2.8mA | 0.63V<sub>pp</sub> | 3.1mA | | |
| 25kHz | 0.35V<sub>pp</sub> | 1.8mA | 0.38V<sub>pp</sub> | 1.9mA | | |
| 32kHz | 0.25V<sub>pp</sub> | 1.2mA | 0.26V<sub>pp</sub> | 1.3mA | | |

### グラフに描く

測った I<sub>peak</sub> を、横軸に周波数、縦軸に電流をとってグラフにする
(2kHz〜32kHz と 16 倍の幅があるので、片対数の方眼紙で横軸を対数にすると見やすい)。
f<sub>0</sub> = 15.9kHz で頂点になる山 (共振曲線) が描ければよい。

- 山の頂点の周波数が計算の 15.9kHz からずれていたら、L1 と C1 の実際の値がずれている
  (f<sub>0</sub> は √(LC) に反比例するので、L と C がともに 10% 大きければ f<sub>0</sub> は 10% 下がる)
- 山の鋭さ (Q の高さ) は、輪の抵抗を小さくするほど増す。R1 を 47Ω に替えると、
  f<sub>0</sub> の電流は 4.5mA → 6.3mA に上がるが、12kHz と 20kHz ではほとんど変わらない
  (出力 50Ω でのシミュレーション値。電流は CH2 の Vpp ÷ 2 ÷ 47Ω で読む)
- 出力 50Ω の発生器では頂点が低く平らになる。その 50Ω も輪の抵抗に入るため
- 山は左右で揃わず、低い側のすそが高い (f<sub>0</sub>/2 の 8kHz は 2f<sub>0</sub> の 32kHz の約 2 倍)。
  LED が電流を細い山に刻むので、低い周波数でも電流の中に f<sub>0</sub> に近い成分が混じるため。
  LED の無いただの直列共振なら、横軸を対数にした山は左右で揃う (後の図3 で確かめる)

### 波形の形も見る

- **f<sub>0</sub> の近くでは CH2 がきれいな正弦波**になり、2 本の LED がともに明るい
- **f<sub>0</sub> から離れると、CH2 は半周期ごとの細い山になる**。LED は約 1.8V を超えるまで
  電流を流さないので、発生器の電圧が頂上に近い間だけ電流が流れるため。このとき LED は
  ほぼ点かない。電流を正弦波の実効値ではなく Vpp で読むのはこのため
- 出力 50Ω の発生器では、共振点で CH1 の振幅も少し下がる (6.0 → 約 5.6V<sub>pp</sub>)。
  電流が増えた分だけ発生器の中の 50Ω で電圧が落ちるため

## LED を輪の外に出す — トランジスタで点ける

図1 では LED が共振の輪の中にある。LED は約 1.8V を超えるまで電流を流さないので、
輪の電流を細い山に刻んでしまう。そのせいで f<sub>0</sub> の電流は 4.5mA に抑えられ
(LED が無ければ 17.6mA)、共振曲線も左右で揃わない。
LED を光らせる役目と共振させる役目が、同じ輪の中でぶつかっている。

そこで輪を L1・C1・R1 だけにし、LED は別の 5V からトランジスタ Q1 で点ける。
Q1 は R1 の両端の電圧を R2 を通して受け取るだけで、輪にはほとんど手を出さない。

```circuit
title: 図3 R1 の電圧でトランジスタを開き LED を点ける
parts:
  V1: sine f1 h1 3
  M1: voltmeter f3 h3 l=$\mathrm{CH1}$
  L1: inductor f4 f5 10m
  C1: capacitor f5 f6 10n
  R1: resistor f7 h7 100 i=I
  M2: voltmeter f9 h9 l=$\mathrm{CH2}$
  R2: resistor f10 f11 10k
  VCC: vcc c12
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

- 輪の電流 I は R1 に I × 100Ω の電圧を作る。正の半周期でこれが約 0.6V を超えると
  Q1 のベースに電流が流れ、Q1 が開いて VCC (5V) → R3 → D1 → Q1 と LED に電流が流れる
- ベースの電流は R2 (10kΩ) で絞られ、多くて 0.2mA ほど。輪の電流 (17.6〜24.9mA) の
  1% に満たないので、輪の電流はほとんど変わらない (LTspice で Q1 を外したときと比べて差は 0.5% 未満)
- LED の電流は R3 で決まる。Q1 が開いている間は (5V − 1.8V − 0.2V) ÷ 330Ω ≈ 9mA。
  開くのは正の半周期の頂上の近くだけなので、平均では 3mA ほど
- 負の半周期は R1 の電圧が Q1 のベースを逆向きに押す。その大きさは最大でも 2.5V
  (出力 ≈ 0Ω の発生器のとき) で、2SC1815 のエミッタ・ベース間の耐圧 5V より小さい
- MOSFET (2N7000 など) ならゲートに電流が流れず、輪への影響はさらに小さい。
  ただしゲートのしきい値電圧が 0.8〜3V とばらつき、R1 の電圧は共振でも 1.8V ほど
  (出力 50Ω のとき) なので、個体によっては開かない。バイポーラのトランジスタは
  約 0.6V でそろって開くので、ここではこちらを使う

```breadboard
title: 図4 トランジスタで LED を点ける
board: half
parts:
  L1: inductor/axial d3 d8 10m
  C1: capacitor/ceramic b8 b10 10n
  R1: resistor d10 d14 100
  R2: resistor i10 i15 10k
  Q1: transistor g15(B) g16(C) g17(E) 2SC1815
  D1: led c17(A) c16(K) red
  R3: resistor b17 b21 330
  SCOPE:
    type: device
    at: top
    label: オシロスコープ
    pins: [CH1, CH2, GND]
  PSU:
    type: device
    at: top
    label: 電源 5V
    pins: [V+, GND]
  GEN:
    type: device
    at: bottom
    label: 信号発生器
    pins: [OUT, GND]
wires:
  - SCOPE.CH1 -- a3 orange
  - SCOPE.CH2 -- a10 blue
  - SCOPE.GND -- -t12 black
  - a14 -- -t14 black
  - e10 -- f10 blue
  - f16 -- e16 green
  - a21 -- +t21 red
  - i17 -- -b19 black [h40]
  - PSU.V+ -- +t25 red
  - PSU.GND -- -t27 black
  - GEN.OUT -- e3 yellow
  - GEN.GND -- -b6 black
  - -t29 -- -b29 black
```

- 上の半分は図2 とほぼ同じ輪。列 3 に発生器の出力・CH1・L1、列 10 に C1・R1・CH2 が集まる。
  R1 の右の端 (列 14) は上の − レールへ
- 列 10 の輪の電圧を青の線で下の半分へ渡し、R2 で Q1 のベース (列 15) に入れる。
  2SC1815 は平らな面を見て左から E・C・B。図のとおり左から B・C・E に挿すには、
  平らな面を奥 (f 行側) に向ける
- コレクタ (列 16) は緑の線で上の半分へ戻り、D1 のカソードにつながる。
  D1 のアノード (列 17) から R3 を通って上の + レール (5V) へ
- エミッタ (列 17 の下の半分) は下の − レールへ。上の − レール (オシロと電源の GND) と
  下の − レール (発生器の GND) は 29 列の黒線でつなぐ。上の + レールには電源の 5V だけを入れる

### 図3 の部品と設定

図1 の部品のうち L1・C1・R1 はそのまま使い、D2 は使わない。

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| R3 | 抵抗 (1/4 W) | 330 Ω |
| D1 | 赤色 LED | 1 本 |
| Q1 | NPN トランジスタ | 2SC1815 |
| VCC | 電源 | 5 V。GND は発生器・オシロの GND とつなぐ |

発生器とオシロの設定は図1 と同じ。ただし R1 の電圧が大きくなるので、
CH2 の電圧レンジは 1 V/div にする (共振点で 3.5〜5.0V<sub>pp</sub>)。

### 図3 で見るべき値

LTspice のシミュレーション値。電流の読み方は図1 と同じで、
I<sub>peak</sub> = (CH2 の Vpp ÷ 2) ÷ 100Ω。LED の電流は出力 50Ω のときの平均。

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

- **山が高く鋭くなる。** f<sub>0</sub> の電流は 17.6mA で、図1 (4.5mA) の約 4 倍。
  輪の中の抵抗は R1・巻線・発生器の出力の 170Ω だけになり、Q = (1/170Ω) × √(L/C) ≈ 5.9
  (出力 ≈ 0Ω なら 120Ω で Q ≈ 8.3)
- **山が左右で揃う。** f<sub>0</sub>/2 の 8kHz と 2f<sub>0</sub> の 32kHz がどちらも 2.0mA。
  図1 では 2.3mA と 1.2mA だった。LED が電流を刻まなくなったので、横軸を対数にした山は
  左右対称になる。同じ方眼紙に図1 の山と重ねて描くと違いがよく分かる
- **CH2 は、f<sub>0</sub> から離れてもきれいな正弦波のまま。** 図1 のような細い山にはならない
- **LED は 14〜18kHz の間だけ点く。** Q1 は R1 の電圧が約 0.6V を超えるまで開かないので、
  LED は山の頂上の近くだけを切り取って見せる。明るさからは山の鋭さを読めないので、
  山の形は CH2 で読む
- **共振では C1 の両端に発生器の約 Q 倍の電圧がかかる。** 15.9kHz の C1 のリアクタンスは
  約 1kΩ なので、17.6mA × 1kΩ ≈ 17.6V<sub>peak</sub> (出力 ≈ 0Ω なら約 25V<sub>peak</sub>)。
  発生器の 3V<sub>peak</sub> よりずっと大きい。C1 は耐圧 50V のセラミックコンデンサを使う

## 出典

自作。
