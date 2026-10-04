---
book: analog-discovery
chapter: 4
id: 4-9
title: 555 の出力スペクトル
tier: 100
source: 自作
board: BB
---

# 4-9 555 の出力スペクトル

2-8 で MSO のために組んだ NE555 の非安定発振を、そのまま Spectrum で見る。
NE555 の標準的な非安定接続は**デューティ比が必ず 50% を超える** (Ra + Rb を
充電、Rb だけで放電するため)。4-2 の理想の方形波 (デューティちょうど 50%、
奇数次だけ) と比べて、555 では偶数次がわずかに残ることを確かめる。

## 回路図

```circuit
title: 図1 555 の非安定発振
parts:
  U1: ic e6 NE555
  VCC: vcc b2
  Ra: resistor b2 c2 1k
  Rb: resistor d2f0 f2f0 10k
  Ct: capacitor f4f0 h4f0 68n
  G2: ground h4f0
  G1: ground h6f0
  Ccv: capacitor g8 h8f0 10n
  G3: ground h8f0
  AD:
    type: device
    at: d11
    label: Analog Discovery
    pins: [V+, 1+, 1-, GND]
  VCC: vcc b10
  G7: ground f10
wires:
  - b2 -- b6a5
  - U1.VCC |- b6
  - U1.RESET |- b6a5
  - c2 -- d2f0
  - U1.DISCH -| d2f0
  - U1.THRES -| e4
  - U1.TRIG -| e4f0
  - e4 -- f4f0
  - f2f0 -- f4f0
  - U1.GND |- h6f0
  - U1.CONT |- g8
  - U1.OUT -| e9
  - e9 |- AD.1+
  - AD.V+ -| b10
  - AD.1- -| f10
  - AD.GND -| f10
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/09-555-spectrum.svg)

2-8 と同じ 555 回路 (Ra 1 kΩ・Rb 10 kΩ・Ct 68 nF)。4017 の分周は使わず、
CH1 (`1+`) で OUT (3 番) をそのまま Spectrum に送る。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで 555 を組む
board: half
parts:
  U1: dip8 @ e10 NE555
  Ra: resistor b7 b11 1k
  Rb: resistor a11 a12 10k
  Ct: capacitor i9 i6 68n
  Ccv: capacitor d13 d17 10n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+, 1+, 1-]
wires:
  - AD.V+ -- +t8 red
  - AD.GND -- -t3 black
  - +t1 -- +b1 red
  - -t2 -- -b2 black
  - a10 -- +t10 red
  - d12 -- d9 purple
  - c9 -- g9 purple
  - h9 -- h11 purple
  - j6 -- -b6 black
  - +t7 -- a7 red
  - c17 -- -t17 black
  - j10 -- -b10 black
  - j13 -- +b13 red
  - i12 -- i16 yellow
  - AD.1+ -- g16 orange
  - AD.1- -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/09-555-spectrum.svg)

2-8 の配線から 4017 (U2) を外しただけ。Ra・Rb・Ct が発振の CR 網、Ccv は 5 番
(CV) の定番バイパス。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Spectrum | Source: Channel 1。Start 0 Hz、Stop 9 kHz。サンプル周波数 20 kHz、FFT 点数 32768。Window: Flat-top。単位: dBV |

出力を 0〜5 V・デューティ 52.4% の理想の方形波として描くと次のようになる。
0 Hz の線は直流分 (平均 2.62 V) である。

```spectrum
title: 図3 デューティが 50% からずれているので偶数次が −15 dBV ほどで残る
device: ad3
sweep: 0-9kHz
samples: 32768
window: flattop
ref: 20dBV
signal: pulse 1008Hz 2.5V offset 2.5V duty 52.4%
markers: [1008Hz, 2016Hz, 3024Hz, 4032Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/09-555-spectrum.svg)

## 見るべき値

計算値。2-8 と同じく f = 1.44 / ((Ra + 2Rb) × Ct) ≈ **1008 Hz**、
デューティ D = (Ra + Rb) / (Ra + 2Rb) = 11/21 ≈ **52.4%**。出力は理想的に
0〜Vcc (5 V) の方形波とみなす (実際は数百 mV 内側に留まる、目安)。0〜A の
矩形波の n 次高調波の振幅は (2A/nπ)×|sin(nπD)|。

| 次数 n | 周波数 | 振幅 (0-peak) | dBV |
| --- | --- | --- | --- |
| 1 | 1008 Hz | 3.174 V | +7.02 dBV |
| 2 | 2017 Hz | 0.237 V | −15.51 dBV |
| 3 | 3025 Hz | 1.034 V | −2.72 dBV |
| 4 | 4034 Hz | 0.235 V | −15.61 dBV |
| 5 | 5042 Hz | 0.593 V | −7.55 dBV |
| 6 | 6050 Hz | 0.230 V | −15.77 dBV |
| 7 | 7059 Hz | 0.394 V | −11.10 dBV |

参考: DC 平均 = Vcc×D ≈ 2.62 V (Scope の Average で確かめられる、3-1 と同じ考え方)。

分かること:

- **4-2 の理想方形波 (デューティ 50%) は偶数次が 0 だったが、555 はデューティが
  52.4% (50% から 2.4 ポイントずれている) なので、偶数次が完全には消えない。**
  2・4・6 次はどれも 0.23〜0.24 V 程度で、ほぼそろっている
- この「そろい方」には理由がある。偶数次 n の振幅 ≈ (2A/nπ)×sin(nπ(D−0.5)) は、
  n(D−0.5) が小さいうちは sin(x) ≈ x で近似でき、n が約分されて
  **2A(D−0.5) ≈ 0.238 V という n によらない値**になる。デューティが 50% から
  ずれているぶんだけ、偶数次がこの高さで居座り続ける
- 奇数次 (1・3・5・7) は理想の方形波と同じように大きく、次数が上がるほど
  下がっていく。**偶数次の有無で「デューティが正確に 50% かどうか」を
  Spectrum だけから判定できる** (2-2 で Scope のデューティ測定と併せて確認できる)

## 出典

自作。矩形波のフーリエ級数 (振幅 (2A/nπ)|sin(nπD)|) は信号処理の教科書に
載っている標準的な導出。555 の発振の式は 2-8 で使ったものと同じ。
