---
book: circuits
chapter: 6
id: 6-7
title: インダクタの飽和
tier: 200
source: 自作
---

# 6-7 インダクタの飽和

コイルに一定の電圧 V を掛けると、電流は I = V × t / L で**直線に**増えていく (傾きが V/L)。ところが鉄やフェライトの芯 (コア) のコイルでは、
電流がある所を超えると芯がそれ以上磁化できなくなり (**飽和**)、インダクタンス L が急に小さくなる。L が小さくなると傾き V/L が大きくなり、
電流が**急に跳ね上がる**。スイッチング電源 (5-5・6-6) でコイルが壊れたり MOSFET が焼けたりする原因の一つで、
コイルの「定格電流」(飽和電流) はこの曲がり目で決まる。

この題では、FT37-43 に 80 回巻いたコイルに、2N7000 で 5 V を数十 µs (µ はマイクロ) だけ掛け、電流の波形をオシロで見る。
最初は直線で増え、40 µs を過ぎたあたりで傾きが急に大きくなる所が飽和である。

- **小さい電流の L**: A<sub>L</sub> (350 nH/回²) × 80² ≈ 2.2 mH (FT37-43 の目安、±25 %)。傾き 5 V / 2.2 mH ≈ 2.2 mA/µs
- **飽和の目安**: コアの中の磁束密度 B は、巻数 × 電流に比例して大きくなり、43 材では 0.3 T (テスラ) ほどで頭打ちになる (目安)。
  80 回では 0.1 A を超えるあたりから L が下がり始める (下の LTspice の模型)
- **電流を止める物**: 飽和すると電流を決めるのは抵抗だけになる。R1 (15 Ω。Ω はオーム) と RS (1 Ω) と MOSFET のオンの抵抗で、
  電流の上限は約 0.23 A に抑える (2N7000 とブレッドボードの範囲)

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 インダクタの飽和を見る (L1 は FT37-43 に 80 回、RS で電流を読む)
parts:
  VCC: vcc 7,1 5V
  CB: ecap 5,1.5 5,3.5 470u
  G1: ground 5,3.5
  L1: inductor 7,1.5 7,3.5 2.4m
  DF: diode 9,3.5 9,1.5 1N4148
  R1: resistor 7,3.5 7,5 15
  M1: nmos 7,6 2N7000
  RS: resistor 7,7 7,8.5 1
  G2: ground 7,8.5
  RG: resistor 4,6 5.5,6 100
  RGS: resistor 6,6.5 6,8.5 10k
  G3: ground 6,8.5
  W1: square 3,6 3,8 l=$\mathrm{W1}$
  G4: ground 3,8
  M2: voltmeter 8.5,7 8.5,8.5 l=$\mathrm{CH2}$
  G5: ground 8.5,8.5
  M3: voltmeter 2,6 2,8 l=$\mathrm{CH1}$
  G6: ground 2,8
wires:
  - 7,1 -- 7,1.5
  - 5,1.5 -- 5,1
  - 5,1 -- 7,1
  - 7,1 -- 9,1
  - 9,1 -- 9,1.5
  - 7,5 -- M1.D
  - 7,5 -- 8,5
  - 8,5 -- 8,4
  - 8,4 -- 9,4
  - 9,4 -- 9,3.5
  - M1.S -- 7,7
  - 7,7 -- 8.5,7
  - 3,6 -- 4,6
  - 2,6 -- 3,6
  - 5.5,6 -- 6,6
  - 6,6 -- M1.G
  - 6,6 -- 6,6.5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/circuit/07-inductor-saturation.svg)

- 図1 の L1 は FT37-43 に 80 回巻いた手巻きのコイル (値 2.4 mH は小さい電流での目安)。R1 は電流の上限を決める抵抗
- M1 (2N7000) が W1 のパルス (0/5 V) の間だけ導通して、L1 に約 5 V を掛ける。RS (1 Ω) の両端の電圧が電流 (1 mV が 1 mA) で、CH2 で読む
- DF (1N4148) は、パルスが終わって M1 が切れたときに L1 の電流を電源へ逃がす (6-2 のフライバックダイオード)。
  CB (470 µF) はパルスの間の 0.2 A を出す電源の溜め。AD3 の V+ は平均の数 mA だけを補う
- CH1 は W1 (ゲートを駆動するパルス)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (L1 は手巻きのトロイダルコイル)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  AD1:
    type: device
    at: bottom
    label: AD3 (Wavegen と Scope)
    pins: [2+, 1-, W1, 1+, 2-]
  CB: capacitor/electrolytic b3(+) b6(-) 470uF
  L1: inductor/toroid b10 b14 FT37-43 80t
  R1: resistor c14 c18 15
  DF: diode d18 d20 1N4148 cap=below:3,0
  M1: transistor h16 h17 h18 2N7000
  RS: resistor i16 i12 1
  RGS: resistor j17 -b17 10k cap=right
  RG: resistor g17 g22 100
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t30 -- -b30 black
  - +t3 -- a3 red
  - a6 -- -t6 black
  - +t10 -- a10 red
  - +t20 -- a20 red
  - e18 -- f18 white
  - j12 -- -b12 black
  - h22 -- h24 yellow
  - AD1.2+ -- j16 green
  - AD1.1- -- -b20 black
  - AD1.W1 -- j22 yellow
  - AD1.1+ -- j24 orange
  - AD1.2- -- -b26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/breadboard/07-inductor-saturation.svg)

図2 は上のブロックに CB・L1・R1・DF、下のブロックに M1 と RS・RG・RGS を置いた。

- 電源は AD3 の Supplies (V+ を 5 V)。上の + レールと − レールへ入れ、30 列の黒い線で下の − レールへも渡す
- CB は + を 3 列 (+ レールへ)、− を 6 列 (− レールへ) に挿す。L1 は 10 列 (+ レール) と 14 列に挿し、R1 (`c14`–`c18`) で 18 列へ
- DF はアノードを 18 列 (ドレイン)、カソードを 20 列 (+ レール) に挿す
- **2N7000 は平らな面を手前にして左から S・G・D** (`h16`・`h17`・`h18`)。D は白の線で上の 18 列へ。S は RS (`i16`–`i12`) を通して 12 列から − レールへ
- W1 (黄) は `j22` へ挿し、RG (`g17`–`g22`) でゲートへ。RGS はゲートから − レールへ縦に。`h22`–`h24` の黄の線で 24 列へ出し、CH1 (1+、橙) を `j24` に挿す
- CH2 (2+、緑) は S の列 (`j16`)。1− と 2− は下の − レールへ
- **ブレッドボードの範囲**: 電流の山は約 0.23 A で、1 穴のピーク 0.3 A 以下。1 kHz で幅 60 µs なので、デューティは 6 % (ピークの条件の 10 % 以下)。
  平均の電流は約 10 mA

## 計器の設定

オシロには AD3 の Scope を使う。数十 µs の電流の立ち上がりの形 (直線か、曲がるか) を見る題で、10 MHz よりずっと遅いから。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Pulse、1 kHz、0〜5 V、幅 60 µs (デューティ 6 %)。幅は 20 µs から始めて 60 µs まで少しずつ広げる |
| Scope CH1 (W1、24 列) | DC、2 V/div |
| Scope CH2 (RS の上、16 列) | DC、50 mV/div (50 mA/div) |
| Time | 10 µs/div、トリガの位置を左から 1 目盛 |
| Trigger | CH1、立ち上がり、2.5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 L1 の電流 (CH2) — 40 µs までは直線、そこから飽和して跳ね上がる
time: 10us/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: "= 5V * step(t) * (1 - step(t - 60us))", range: 2V/div, position: -3div}
ch2: {wave: "= (2.095mV/1us*clip(t,0s,20us)+2.7mV/1us*clip(t-20us,0s,10us)+4.46mV/1us*clip(t-30us,0s,10us)+11.15mV/1us*clip(t-40us,0s,10us)+0.4mV/1us*clip(t-50us,0s,10us))*(1-step(t-60us))", range: 50mV/div, position: -3div}
cursors: [20us, 40us]
measure: [vmax]
notes:
  - text ch2 45us 169mV: 飽和で傾きが急になる
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/scope/07-inductor-saturation.svg)

図3 は LTspice の値 (10〜20 µs ごとの電流) を直線でつないで描いた想定の波形で、実測ではない。カーソル X1 (20 µs) で約 42 mA、X2 (40 µs) で約 114 mA。
初めの 20 µs の傾きは 2.1 mA/µs で、そのまま直線なら 40 µs で 84 mA のはずが、114 mA まで増えている。40〜50 µs の 10 µs で 111 mA 増え (傾き 11 mA/µs、初めの 5 倍)、
50 µs からは抵抗で決まる上限 (約 0.23 A) に張り付く。パルスが終わると RS の電流は 0 に落ち、L1 の電流は DF を通って電源へ戻る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 | 手巻きのトロイダルコイル (FT37-43) | 80 回 (0.2〜0.3 mm のエナメル線。2 層になる)。小さい電流で約 2.2〜2.4 mH (目安) |
| R1 | 抵抗 (電流の上限) | 15 Ω (1/4 W。平均の電力は数十 mW) |
| RS | 抵抗 (電流を測る) | 1 Ω |
| M1 | N チャネル MOSFET | 2N7000 |
| DF | 小信号ダイオード | 1N4148 |
| CB | 電解コンデンサ (電源の溜め) | 470 µF・16 V |
| RG | 抵抗 | 100 Ω |
| RGS | 抵抗 | 10 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 信号源・計器 | AD3 の Wavegen W1、Scope 1+/2+ |

## 見るべき値

| 測る所 | 期待する値 (LTspice) | 分かること |
| --- | --- | --- |
| 初めの 20 µs の傾き (CH2) | 約 2.1 mA/µs (20 µs で 42 mA) | 5 V / L。ここから L ≈ 2.4 mH と読める |
| 40 µs の電流 | 約 114 mA (直線なら 84 mA) | 飽和が始まり、傾きが大きくなっている |
| 40〜50 µs の傾き | 約 11 mA/µs (初めの 5 倍) | L が 5 分の 1 ほどに下がった |
| 電流の上限 (50 µs から) | 約 0.23 A | 5 V ÷ (R1 + RS + MOSFET + 巻線) |
| W1 の幅 20 µs / 40 µs のときの山 | 約 42 mA / 114 mA | 幅を広げると、ある所から山が急に増える |
| CB の電圧の下がり (幅 60 µs) | 約 12 mV | CB がパルスの電流を出している |

コイルを 40 回巻きに替えると、L は 4 分の 1 (約 0.6 mH) で傾きは 4 倍になるが、飽和の電流は 2 倍になり、この回路の上限 0.23 A の中では飽和が見えにくくなる。
巻数を増やすほど L は大きくなるが、飽和する電流は小さくなる (巻数 × 電流で決まるため)。スイッチング電源のコイルを選ぶときは、
L だけでなく流す電流の山が飽和の電流より小さいことを確かめる。

## LTspice での確かめ

`sim/07-inductor-saturation.cir` で W1 の幅を 20・40・60・80 µs に振って過渡解析を走らせ、4 発目のパルスの電流を 10 µs ごとに読んだ。
コアの飽和は鎖交磁束の式 (N × A × B<sub>s</sub> × tanh(I/I<sub>0</sub>)) で表し、断面積・磁路長は FT37 の寸法、初透磁率 850・B<sub>s</sub> 0.29 T は 43 材の目安から置いた。
2N7000 は 2-17 と同じ代用の模型、電源の V+ の内部の抵抗 1 Ω も仮定。どれも実測ではない。実物のコアの曲がり目は、この模型と 2 倍ほど違ってもおかしくない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 小さい電流の L | 約 2.2 mH (A<sub>L</sub> の目安) | 2.41 mH (模型の値。10 µs で 20.3 mA から 2.4 mH) | 合う (A<sub>L</sub> の許容差 ±25 % の中) |
| 20 µs / 40 µs の電流 | 約 42 / 114 mA | 41.9 / 113.5 mA | 本文の値は LTspice の読み |
| 50 µs の電流 | 約 0.23 A | 0.225 A | 合う |
| 電流の上限 | 約 0.23 A | 0.229 A | 合う |
| CB の電圧の下がり (幅 60 µs) | 約 12 mV | 11.7 mV | 合う |

## 出典

自作。

参考: [磁気飽和 (Wikipedia)](https://ja.wikipedia.org/wiki/磁気飽和)、[Saturation (magnetic) (Wikipedia)](https://en.wikipedia.org/wiki/Saturation_(magnetic))
