---
book: analog-discovery
chapter: 10
id: 10-4
title: 出力インピーダンス vs 周波数
tier: 200
source: 自作 (値の目安は TI LM340 のデータシート、計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 10-4 出力インピーダンス vs 周波数

レギュレータの出力は、負荷の電流が変わっても電圧を保とうとする。どれだけ保てるかを**出力インピーダンス** Z<sub>out</sub> で表す。
負荷の電流を Δi だけ揺らしたとき出力が Δv 揺れたら、Z<sub>out</sub> = Δv / Δi。7805 のデータシート (TI LM340) は 1 kHz で 8 mΩ (ミリオーム) と書き、
図7 では 10 kHz から上で周波数に比例して増え、1 MHz で 1 Ω に届く。中の誤差増幅器の利得が高い周波数で落ち、直しきれなくなるためで、
出力はコイルのように見える。10-2 の負荷過渡応答の沈み込みも、この Z<sub>out</sub> と負荷の電流の変化の積で決まる。

この題では 10-3 の基板の出力に、W1 から R4 (100 Ω) を通して小さな交流の電流を流し込み、**Network** で R4 の両端 (CH1 = 電流) と
出力 (CH2 = 揺れ) の比を 100 Hz〜1 MHz で掃引する。CH1 は R4 の両端なので電流 i = v<sub>1</sub> / 100 Ω、出力の揺れは v<sub>2</sub> = i × Z<sub>out</sub>。
だから **Z<sub>out</sub> = 100 Ω × v<sub>2</sub> / v<sub>1</sub>**。Network の利得 (dB) を Ω に直すには Z<sub>out</sub> = 100 Ω × 10<sup>(dB/20)</sup>。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 7805 の出力に R4 を通して W1 の電流を流し、出力の揺れを測る
parts:
  VP: vsource 3,4 3,6 5
  VM: vsource 3,6 3,8 5
  G2: ground 2,6
  R1: resistor 4,4 6,4 100
  C1: capacitor 8,4 8,8 0.33u
  U1: regulator 11,4 7805
  C2: capacitor 14,4 14,8 0.1u
  R2: resistor 16,4 16,8 1k
  M2: voltmeter 18,4 18,8 l=$\mathrm{CH2}$
  R4: resistor 20,4 22,4 100
  M1: voltmeter 22,2 20,2 l=$\mathrm{CH1}$
  C4: capacitor 23,4 25,4 10u
  W1: sine 26,4 26,6 l=$\mathrm{W1}$
  G1: ground 26,6
wires:
  - 3,4 -- 4,4
  - 3,6 -- 2,6
  - 6,4 -- 8,4 -- U1.in
  - U1.out -- 14,4 -- 16,4 -- 18,4 -- 20,4
  - 20,4 -- 20,2
  - 22,2 -- 22,4 -- 23,4
  - 25,4 -- 26,4
  - U1.gnd -- 11,8
  - 3,8 -- 8,8 -- 11,8 -- 14,8 -- 16,8 -- 18,8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/04-output-impedance.svg)

- 入力の側 (V<sub>P</sub>・V<sub>M</sub>・R1・C1・7805) は 10-3 と同じ。入力のリップルを足す R3・C3 は外す
- W1 は C4 (10 µF (マイクロファラド)) で直流を止め、R4 (100 Ω) を通して出力に電流を出し入れする。W1 の振幅 0.5 V で電流は 5 mA (振幅) 以下
- CH1 は R4 の両端を差動で読む (1+ を C4 の側、1− を出力)。CH2 は出力と V− の間
- 出力は AD3 の GND から見てほぼ 0 V (V− の −5 V に 7805 の 5 V を足した所) なので、C4 にかかる直流は小さい。C4 は極性の無い積層セラミックにする
- 出力には C2 (0.1 µF) と R2 (1 kΩ) がつながったまま。測るのはそれらと 7805 を並べた、出力の端子から見たインピーダンス

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 10-3 の基板から R3・C3 を抜き、OUT の右に R4・C4 を足す
board: half
parts:
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, V-, 2+, 1-, 1+, W1, 2-]
  U1: regulator/to220 f15 f16 f17 7805
  R1: resistor g7 g11 100
  C1: capacitor i15 i16 0.33uF cap=left
  C2: capacitor g16 g17 0.1uF cap=right
  R2: resistor f20 f25 1k
  R4: resistor i20 i24 100
  C4: capacitor h24 h28 10uF
wires:
  - AD.V+ -- +b1 red
  - AD.V- -- -b2 black
  - AD.2+ -- j17 yellow
  - AD.1- -- j20 blue
  - AD.1+ -- j24 orange
  - AD.W1 -- j28 green
  - AD.2- -- -b30 black
  - +b7 -- j7 red
  - h11 -- h15 orange
  - j16 -- -b16 black
  - h17 -- h20 yellow
  - j25 -- -b25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/04-output-impedance.svg)

- 10-3 の図2 から R3・C3 を抜く。R2 は f20〜f25 へ移し、OUT (17 列) と 20 列を黄の線でつなぐ
- R4 (20〜24 列) と C4 (24〜28 列) を足す。W1 は 28 列、1+ は 24 列、1− は 20 列 (出力)、2+ は 17 列、2− は青レール (V−)
- 電解コンデンサを足す比べ (下の表の 3 つめ) では、100 µF の電解の + を 20 列の空いた穴 (g20)、− を青レールに挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = +5 V、V− = −5 V (10-3 と同じ) |
| Network | Start 100 Hz、Stop 1 MHz、Log、Steps 100 (目安)。Wavegen は W1・Amplitude 0.5 V・Offset 0 V。Reference は CH1 |
| 読み方 | 利得 (CH2/CH1) の dB を Z<sub>out</sub> = 100 Ω × 10<sup>(dB/20)</sup> で Ω に直す (Network の画面は dB のまま。書き出した CSV を 11-4 の手順で直す) |

100 kHz で Network が取り出す 2 つの成分を、時間波形に描くと図3 になる (計算。CH2 は直流 5 V を除いた揺れだけで、Scope で直に見えるものではない)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 100 kHz — CH1 (R4 の両端) 0.5 V に対し CH2 (出力) は 1.04 mV で 76° 進む
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: sine 100kHz 0.5V, range: 200mV/div}
ch2: {wave: sine 100kHz 1.04mV phase 76deg, range: 500uV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/04-output-impedance.svg)

CH2 の振幅は 4.99 mA × 0.208 Ω = 1.04 mV。CH2 が CH1 より進むのは、出力がコイルのように見えるからだ (コイルの電圧は電流より 90° 進む。抵抗分があるので 76°)。

見えるはずの Z<sub>out</sub> は図4。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 出力インピーダンス — 10 kHz から上で増え、電解を足すと 0.24 Ω で頭打ち
x: 周波数 Hz log 100..1M
y: 出力インピーダンス Ω log 0.01..2
lines:
  C2 0.1µF Ω:
    - 100 0.0179
    - 1k 0.0190
    - 3k 0.0244
    - 10k 0.0379
    - 30k 0.0704
    - 100k 0.208
    - 300k 0.606
    - 600k 1.07
    - 1M 1.20
  C2 なし Ω:
    - 100 0.0179
    - 1k 0.0190
    - 3k 0.0244
    - 10k 0.0379
    - 30k 0.0703
    - 100k 0.206
    - 300k 0.552
    - 600k 0.871
    - 1M 1.05
  C2 + 100µF 電解 Ω:
    - 100 0.0179
    - 1k 0.0190
    - 3k 0.0244
    - 10k 0.0362
    - 30k 0.0643
    - 100k 0.153
    - 300k 0.226
    - 600k 0.239
    - 1M 0.240
notes:
  - mark 1k
  - mark 100k
  - mark 1M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/graph/04-output-impedance.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1・R1・R2・C1・C2 | 10-3 と同じ | 7805・100 Ω・1 kΩ・0.33 µF・0.1 µF |
| R4 | 抵抗 (1/4 W) | 100 Ω (電流を読む抵抗。損失 0.13 mW) |
| C4 | 積層セラミックコンデンサ (106) | 10 µF (直流を止める。100 Hz で 160 Ω) |
| — | 電解コンデンサ (16 V。比べるときに足す) | 100 µF (ESR 約 0.3 Ω と仮定) |
| — | 電源 | AD3 の V+ と V− の間の 10 V (10-3 と同じ理由) |
| — | 計器 | AD3 の Supplies、Wavegen (W1)、Network (CH1 = R4 の両端、CH2 = 出力) |

## 見るべき値

計算値。7805 は 10-3 と同じ模型 (データシートの図7 に合わせた仮定)。

| 周波数 | 利得 (CH2/CH1) | Z<sub>out</sub> (C2 0.1 µF) | 分かること |
| --- | --- | --- | --- |
| 100 Hz〜1 kHz | −75 dB | 18〜19 mΩ | データシートの 8 mΩ に、R1 を通った入力の揺れが PSRR (81 dB) を越して漏れる分 (100 Ω ÷ 11,000 ≒ 9 mΩ) が足される |
| 10 kHz | −68 dB | 38 mΩ | ここから上で周波数に比例して増える |
| 100 kHz | −54 dB | 0.21 Ω | 出力はコイル (0.32 µH 相当) のように見える |
| 1 MHz | −38 dB | 1.2 Ω (871 kHz で 1.21 Ω の山) | C2 (0.1 µF) とコイルの共振。C2 が無いと 1.05 Ω |

- **0.1 µF は 1 MHz より下ではほとんど効かない** (図4 の C2 なしと重なる)。0.1 µF のリアクタンスは 100 kHz で 16 Ω もあり、0.2 Ω の Z<sub>out</sub> に並べても変わらない
- 100 µF の電解を足すと、100 kHz で 0.15 Ω、それより上は電解の ESR (0.3 Ω と 7805 の Z<sub>out</sub> の並列) で **0.24 Ω に頭打ち**になる。
  高い周波数の Z<sub>out</sub> を下げるのは容量の大きいコンデンサの ESR で、0.1 µF ではない (デカップリングの話は 10-5)
- 低い周波数の 18 mΩ は、出力の揺れで 0.09 mV ほど (5 mA × 18 mΩ)。AD3 の Network の床に近い (目安) ので、読みが揺れるなら 10 kHz から上で比べる
- 10-2 の負荷の切り替え (24 mA の段) に当てはめると、7805 の後ろの沈みは 24 mA × 19 mΩ ≒ 0.5 mV。整流・平滑だけの 427 mV からほぼ消える

## LTspice での確かめ

`sim/04-output-impedance.cir` で図1 を交流解析した。7805 は 10-3 と同じ模型 (仮定)、電解の ESR は 0.3 Ω (仮定)。`.step` で 3 通りに替えた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Z<sub>out</sub> 1 kHz | 19 mΩ | 19.0 mΩ | 合う (模型) |
| Z<sub>out</sub> 100 kHz (C2・なし・電解) | 0.21・0.21・0.15 Ω | 0.208・0.206・0.153 Ω | 合う (模型) |
| Z<sub>out</sub> の山 (C2) | 871 kHz で 1.21 Ω | 871 kHz で 1.21 Ω | 合う |
| Z<sub>out</sub> 1 MHz (電解) | 0.24 Ω | 0.240 Ω | 合う |
| CH1 の振幅 1 kHz (W1 0.5 V) | 0.49 V | 0.494 V (W1 1 V で 0.987 V) | 合う |

## 出典

自作。出力インピーダンスの目安は [TI LM340 / LM7805 のデータシート (SNOSBT0L)](https://www.ti.com/lit/ds/symlink/lm340.pdf) の表と図7。
計器の名前と操作は Digilent の [Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
