---
book: analog-discovery
chapter: 9
id: 9-15
title: プッシュプルのクロスオーバー歪を FFT で
tier: 200
source: 自作 (計器の操作は Digilent の Using the Spectrum Analyzer)
board: BB
---

# 9-15 プッシュプルのクロスオーバー歪を FFT で

回路の教科書の 2-10 の B 級プッシュプル (2SC1815 と 2SA1015 のエミッタフォロアを背中合わせにしたもの) は、
入力が ±0.7 V ほどの内にある間、どちらのトランジスタも流れず出力が 0 V に張り付く。これが**クロスオーバーひずみ**。
2-10 ではオシロで形を見た。ここでは同じ回路の出力を **Spectrum** (FFT) にかけ、ひずみが**奇数次の高調波**として並ぶこと、
入力を小さくするほどひずみの割合 (THD) が増えることを数で確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 B 級プッシュプル (回路の教科書の 2-10 と同じ。CH2 が入力、CH1 が出力)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [V-, 1+, V+, 2+, W1, 2-, 1-, GND]
  Q1: npn 10,4 2SC1815
  Q2: pnp 10,7 2SA1015
  RL: resistor 12,5.5 12,7.5 100
  G1: ground 12,7.5
  G2: ground 4,9
wires:
  - AD.V- -| 14,9
  - 14,9 -| Q2.C
  - AD.1+ -| 13,5.5
  - AD.V+ -| Q1.C
  - AD.2+ -| 8,5.5
  - AD.W1 -| 7.5,5.5
  - 7.5,5.5 -- 8,5.5
  - 8,5.5 -- 8.5,5.5
  - 8.5,5.5 |- Q1.B
  - 8.5,5.5 |- Q2.B
  - Q1.E -| 11,5.5
  - Q2.E -| 11,5.5
  - 11,5.5 -- 12,5.5
  - 12,5.5 -- 13,5.5
  - AD.2- -| 4,9
  - AD.1- -| 4,9
  - AD.GND -| 4,9
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/circuit/15-crossover-fft.svg)

- V+ (+5 V) と V− (−5 V) は AD3 の Supplies。Q1 (NPN) が正の半周期、Q2 (PNP) が負の半周期を受け持つ
- W1 は両方のベースに直に入る。CH2 (2+) が入力、CH1 (1+) が出力 (RL 100 Ω (オーム) の上端)。1−・2− は GND
- 図の向き (CH2 が入力) は 2-10 の配線に合わせた

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (2-10 と同じ配置)
board: half
parts:
  Q1: transistor c10(B) c11(C) c12(E) 2SC1815
  Q2: transistor h10(B) h11(C) h12(E) 2SA1015
  RL: resistor a12 -t12 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V-, V+, GND, 2-, 2+, W1, 1+, 1-]
wires:
  - AD.V- -- -b1 purple
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - AD.2- -- -t5 black
  - AD.2+ -- a7 blue
  - AD.W1 -- a8 yellow
  - AD.1+ -- a15 orange
  - AD.1- -- -t16 black
  - e7 -- e8 blue
  - b8 -- b10 yellow
  - +t11 -- a11 red
  - e10 -- f10 yellow
  - e12 -- f12 orange
  - b12 -- b15 orange
  - j11 -- -b11 purple
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/breadboard/15-crossover-fft.svg)

2-10 と同じ配置で、組み直しは要らない。Q1・Q2 の向きと線の色は 2-10 の説明のとおり。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = +5 V、V− = −5 V、Master Enable を入れる |
| Wavegen | W1: Sine、**1 kHz**、Amplitude 3 V (比べるときは 1 V) |
| Scope | CH1・CH2 とも 1 V/div、200 µs/div (µs はマイクロ秒) |
| Spectrum | CH1、Range 0〜10 kHz、窓 Flat Top、単位 dBm。Measurements の THD |

2-10 の 100 Hz を 1 kHz に上げたのは、Spectrum の 0〜10 kHz の画面に 9 次まで並べるため。
出力は最大 2.25 V<sub>p</sub> で RL に 23 mA、Supplies の各レールの平均は 7 mA (35 mW) と小さい。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力 (CH2) が ±0.75 V の内にある間、出力 (CH1) は 0 V に張り付く (計算)
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: "= 3V * sin(2 * pi * 1kHz * t) - clip(3V * sin(2 * pi * 1kHz * t), -0.75V, 0.75V)", range: 1V/div}
ch2: {wave: sine 1kHz 3V, range: 1V/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/scope/15-crossover-fft.svg)

図3 は 0.75 V の不感帯 (V<sub>BE</sub> の分) を角で切った計算値。実物と LTspice では V<sub>BE</sub> がなだらかに立ち上がるので、
平らな所の端は少し丸い。出力の山は 3 V − 0.75 V = 2.25 V。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 奇数次の高調波が並ぶ。3 次は基本波の 19 dB 下 (LTspice の出力を FFT にした値)
device: ad3
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
floor: -70dBm
signal:
  - sine 1kHz 2.053V
  - sine 3kHz 0.2377V
  - sine 5kHz 0.1306V
  - sine 7kHz 0.0690V
  - sine 9kHz 0.0351V
markers: [1kHz, 3kHz, 5kHz, 7kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/09-amplifiers/spectrum/15-crossover-fft.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 |
| Q2 | PNP トランジスタ | 2SA1015 |
| RL | 抵抗 (1/4 W、スピーカーの代わり) | 100 Ω (山で 23 mA、平均 26 mW) |
| — | 電源 | Analog Discovery の V+ / V− (±5 V)。両電源の題 |

## 見るべき値

LTspice の出力の波 (入力 3 V、1 kHz、10 周期) を FFT にした値と、角で切った模型の値。50 Ω の電力 (dBm) に直して図4 に描いた。

| 次数 | LTspice の振幅 | dBm | 基本波に対して | 角で切った模型の振幅 |
| --- | --- | --- | --- | --- |
| 1 次 (1 kHz) | 2.053 V | +16.25 | 0 dB | 2.058 V |
| 3 次 | 0.238 V | −2.48 | −18.7 dB | 0.288 V |
| 5 次 | 0.131 V | −7.68 | −23.9 dB | 0.144 V |
| 7 次 | 0.069 V | −13.2 | −29.5 dB | 0.076 V |
| 9 次 | 0.035 V | −19.1 | −35.4 dB | 0.036 V |
| 偶数次 | 2 mV 以下 | −43 以下 | −60 dB 以下 | 0 |

- **偶数次がほとんど出ない**のは、正と負の半周期が同じ形に切られる (対称なひずみ) から。Q1 と Q2 の V<sub>BE</sub> や hFE が違うと、
  その分だけ 2 次・4 次が顔を出す。実物で 2 次が大きければ、2 本の差の目印になる
- THD は入力 3 V で 13.7 % (LTspice)・16.2 % (角の模型)。**入力を 1 V にすると 47 % (LTspice)** に増える。不感帯の幅は振幅によらないので、
  小さい信号ほど割合が大きくなる。音楽の小さな音が汚れる理由
- 9-5 のクリップ (山の頭が切れる) は大きい信号で増えるひずみ。クロスオーバーひずみは小さい信号で増える。向きが逆
- 直し方は 2-10 の後半: ダイオード 2 本で 2 つのベースに V<sub>BE</sub> 分の差を付けて AB 級にする、またはオペアンプの帰還の輪の中に入れる

## LTspice での確かめ

`sim/15-crossover-fft.cir` で図1 を過渡解析で解き、入力 3 V と 1 V で出力を FFT にした (9 次まで)。Q1・Q2 は 2-10 と同じ代用の模型
(BF 250)。**仮定で、実測の値ではない**。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力の Vpp (入力 3 V) | 4.50 V (角の模型) | 4.51 V | 合う |
| 3 次 / 1 次 (入力 3 V) | −18.7 dB (角の模型は −17.1 dB) | −18.7 dB | 模型の角が丸い分だけ低い |
| THD (入力 3 V) | 16.2 % (角の模型) | 13.7 % | 同じ理由で LTspice が低い |
| THD (入力 1 V) | 55 % (角の模型) | 47 % | 小さい入力ほど大きいのは同じ |
| 偶数次 | 0 | −60 dB 以下 | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
参考: [全高調波歪](https://ja.wikipedia.org/wiki/全高調波歪)
