---
book: analog-discovery
chapter: 10
id: 10-5
title: デカップリングの効果
tier: 200
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 10-5 デカップリングの効果

電源の線に乗った雑音 (10-1 のリップル、10-6 のスイッチングの雑音) を、IC の電源のピンに届く前に減らすのもデカップリングの仕事だ。
アンプの段ごとに電源へ 100 Ω (オーム) を入れ、その先に電解コンデンサを置く「RC のデカップリング」は、オーディオ回路の定番になっている。
抵抗とコンデンサの組は 1 次のローパスで、雑音は折れ点 f<sub>c</sub> = 1/(2πRC) から上で 10 倍ごとに 20 dB 減る。
ところが実物のコンデンサには ESR (等価直列抵抗) があり、減り方はある所で止まる。

この題では、雑音の乗った電源の代わりに W1 を使い、R1 (100 Ω) の先の VCC にコンデンサを替えて挿しながら、**Network** で
W1 (CH1) から VCC (CH2) への利得を 10 Hz〜1 MHz で掃引する。時間で見る負荷の沈み (回路の教科書の 5-14) と、
1 点のインピーダンスで見る置き場所 (8-9) に続いて、ここでは**電源の雑音が何 dB 減るか**を周波数で見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 雑音の乗った電源 (W1) を R1 とコンデンサで落とし、VCC の揺れを測る
parts:
  W1: sine 2,3 2,6 l=$\mathrm{W1}$
  M1: voltmeter 4,3 4,6 l=$\mathrm{CH1}$
  R1: resistor 5,3 7,3 100
  C2: ecap 9,3 9,6 100u
  C3: capacitor 12,3 12,6 10u
  C1: capacitor 15,3 15,6 0.1u
  M2: voltmeter 18,3 18,6 l=$\mathrm{CH2}$
  G1: ground 2,6
wires:
  - 2,3 -- 4,3 -- 5,3
  - 7,3 -- 9,3 -- 12,3 -- 15,3 -- 18,3
  - 2,6 -- 4,6 -- 9,6 -- 12,6 -- 15,6 -- 18,6
notes:
  - text 12,1 center: C1・C2・C3 は抜き差しして比べる
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/05-decoupling.svg)

- W1 は雑音の乗った電源の代わり。Offset 1 V に振幅 0.5 V の正弦波を乗せる (電解コンデンサにいつも順の電圧がかかる)。R1 に流れる電流は 5 mA 以下
- R1 (100 Ω) がデカップリングの抵抗、VCC が IC の電源のピンに当たる点。CH1 は W1、CH2 は VCC
- C1 (0.1 µF (マイクロファラド) のセラミック)、C2 (100 µF の電解)、C3 (10 µF のセラミック) を、下の表の組で抜き差しする。直流の負荷は無い (直流の電圧降下は 5-14 で見た)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上の赤レールが VCC。C1〜C3 は上のレールの間に抜き差しする
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, W1, 1+, 2+, 1-, 2-]
  R1: resistor c4 c8 100
  C2: capacitor/electrolytic +t13(+) -t13(-) 100uF
  C3: capacitor +t17 -t17 10uF
  C1: capacitor +t21 -t21 0.1uF
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a4 green
  - AD.1+ -- b4 orange [h10]
  - AD.2+ -- +t25 yellow
  - AD.1- -- -t27 black
  - AD.2- -- -t29 black
  - a8 -- +t8 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/05-decoupling.svg)

- W1 (緑) と 1+ (橙) を 4 列へ。R1 (4〜8 列) の先の 8 列から上の赤レールへ渡す。**上の赤レールが VCC**、上の青レールが GND
- C2 (+ を赤レール)・C3・C1 はレールの間に挿す (13・17・21 列)。比べるときに片方ずつ抜き差しする
- 2+ は赤レール、1−・2− と AD3 の GND は青レールへ。電流は 5 mA 以下で、掃引は 1 MHz まで (3 MHz の内側)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | Start 10 Hz、Stop 1 MHz、Log、Steps 100 (目安)。Wavegen は W1・Amplitude 0.5 V・Offset 1 V。Reference は CH1 |
| 比べる組 | (1) なし (2) C1 0.1 µF (3) C2 100 µF (4) C2 + C3 (100 µF + 10 µF)。組ごとに掃引して、画面の線を残して重ねる (目安) |

10 kHz の雑音が VCC にどれだけ残るかを、時間波形に描くと図3 になる (計算)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 10 kHz の残り — 0.1 µF (CH2) は 0.42 V、100 µF (CH3) は 1.7 mV
time: 20us/div
trigger: ch1 rising 1V
ch1: {wave: sine 10kHz 0.5V offset 1V, range: 200mV/div, position: -4div}
ch2: {wave: ch1 | rc 10us, range: 200mV/div, position: -4div}
ch3: {wave: sine 10kHz 1.7mV phase -28deg, range: 1mV/div}
measure: [vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/05-decoupling.svg)

CH2 は C1 (0.1 µF) だけのとき。時定数 100 Ω × 0.1 µF = 10 µs は 10 kHz に対して短く、雑音はほとんど減らない。
CH3 は C2 (100 µF、ESR 0.3 Ω と仮定) のときの揺れ (直流の 1 V を除いた分、尺度は 1 mV/div)。0.5 V の雑音が 1.7 mV になり、約 300 分の 1。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 W1 から VCC への利得 — 電解だけでは −50 dB で止まり、セラミックを足すと下がり続ける
x: 周波数 Hz log 10..1M
y: 利得 dB -90..0
lines:
  C1 0.1µF dB:
    - 10 0
    - 1k -0.02
    - 3k -0.15
    - 10k -1.45
    - 30k -6.58
    - 100k -16.1
    - 300k -25.5
    - 1M -36.1
  C2 100µF dB:
    - 10 -1.45
    - 30 -6.60
    - 120 -17.6
    - 300 -25.5
    - 1k -35.8
    - 3k -44.3
    - 10k -49.4
    - 30k -50.3
    - 100k -50.5
    - 300k -50.4
    - 1M -50.3
  C2 + C3 10µF dB:
    - 10 -1.70
    - 30 -7.26
    - 120 -18.5
    - 300 -26.4
    - 1k -36.7
    - 3k -45.2
    - 10k -50.3
    - 30k -52.2
    - 100k -57.4
    - 300k -66.6
    - 1M -83.7
notes:
  - mark 120
  - mark 10k
  - mark 100k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/graph/05-decoupling.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 100 Ω (デカップリングの抵抗) |
| C1 | セラミックコンデンサ (104) | 0.1 µF |
| C2 | 電解コンデンサ (16 V) | 100 µF (ESR 約 0.3 Ω と仮定。品種で数倍変わる) |
| C3 | 積層セラミックコンデンサ (106) | 10 µF |
| — | 電源 | 使わない (W1 が雑音の乗った電源の代わり) |
| — | 計器 | AD3 の Wavegen (W1) と Network (CH1 = W1、CH2 = VCC) |

## 見るべき値

計算値。コンデンサの ESR と ESL (等価直列インダクタンス。リードとブレッドボードを含む) は、電解 0.3 Ω・10 nH、セラミック 5 mΩ・3 nH と仮定した。

| 組 | 折れ点 (−3 dB) | 120 Hz | 10 kHz | 100 kHz | 分かること |
| --- | --- | --- | --- | --- | --- |
| C1 0.1 µF | 15.9 kHz | 0 dB | −1.5 dB | −16 dB | 折れ点が高く、電源のリップル (120 Hz) は 1 dB も減らない |
| C2 100 µF | 15.9 Hz | −17.6 dB | −49 dB | −50.5 dB | 1 kHz を過ぎると ESR で止まる。底は 20 log₁₀(0.3 Ω / 100 Ω) ≒ −50.5 dB |
| C2 + C3 | 15 Hz | −18.5 dB | −50 dB | −57 dB | ESR の小さい C3 が高い周波数を受け持ち、1 MHz で −84 dB |

- **大きい容量の電解が低い周波数を、ESR の小さいセラミックが高い周波数を受け持つ。** 2 つを並べる理由が、図4 の 2 本の線の離れ方で読める
- 0.1 µF を電解に足しても、1 MHz より下ではほとんど変わらない (0.1 µF のリアクタンスは 100 kHz で 16 Ω で、電解の 0.3 Ω より大きい)。0.1 µF が効くのは数 MHz から上で、この基板の範囲の外
- R1 を大きくすれば折れ点は下がるが、IC の電流で直流が落ちる (10 mA で 1 V)。この組は数 mA のアンプ向き
- −80 dB を超える所は 0.5 V × 10<sup>−84/20</sup> ≒ 30 µV で、AD3 の Network の床に近い (目安)。セラミックの ESL とブレッドボードのインダクタンスも、この辺りから効き始める
- 電解の ESR は温度で大きく変わる。冷えると増え、底が浅くなる

## LTspice での確かめ

`sim/05-decoupling.cir` で図1 を交流解析した。パラメータ `k` で 4 つの組に替えた。ESR と ESL は上の仮定。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| C1 の折れ点 | 15.9 kHz | 15.9 kHz (10 kHz で −1.45 dB) | 合う |
| C2 の 120 Hz | −17.6 dB | −17.6 dB | 合う |
| C2 の底 (100 kHz) | −50.5 dB | −50.5 dB | 合う |
| C2 + C3 の 100 kHz・1 MHz | −57 dB・−84 dB | −57.4 dB・−83.7 dB | 合う (ESR・ESL は仮定) |
| 図3 の CH2・CH3 の振幅 | 0.42 V・1.7 mV | 0.423 V・1.70 mV | 合う |

## 出典

自作。計器の名前と操作は Digilent の [Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
参考: [Decoupling capacitor (Wikipedia)](https://en.wikipedia.org/wiki/Decoupling_capacitor)、[Equivalent series resistance (Wikipedia)](https://en.wikipedia.org/wiki/Equivalent_series_resistance)
