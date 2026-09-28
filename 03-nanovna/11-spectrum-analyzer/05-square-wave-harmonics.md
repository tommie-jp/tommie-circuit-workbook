---
book: nanovna
chapter: 11
id: 11-5
title: 方形波の高調波 — 555 と CMOS の発振器
tier: 100
source: 自作
board: BB
device: SA
---

# 11-5 方形波の高調波 — 555 と CMOS の発振器

回路の教科書の 3-2 (555 非安定) は LED を点滅させるための遅い発振
(約 1.4 Hz) だった。その考え方はそのままに、**tinySA で測れる範囲
(100 kHz 台) まで周波数を上げた回路**を新しく組み、Analog Discovery の教科書の 4-2
(理想の方形波の高調波) と同じ式で、実物の 555 と CMOS (40106) の
発振器を見比べる。

**555 の非安定は、デューティ比がきっちり 50% にならない** (回路の教科書の 3-2・Analog Discovery の
教科書の 2-8 で確かめたとおり、充電に Ra+Rb、放電に Rb だけを使うので
High のほうが長い)。**40106 のシュミット RC 発振はほぼ 50%** (回路の教科書の 3-8)。
この違いが、スペアナで見る**偶数次高調波の有無**にそのまま出る。

## 回路図

555 (Ra 1 kΩ・Rb 3.3 kΩ・C 1 nF) にすると、f = 1.44 / ((Ra+2Rb)×C) ≈
**189.5 kHz**、デューティ D = (Ra+Rb)/(Ra+2Rb) ≈ **56.6%**。回路の教科書の 3-2 (1.4 Hz)
と比べて Ra・Rb を 1/10、C を 1/10000 にして周波数を上げている。

図 1 は発振器を 1 つの箱にまとめ、tinySA へつなぐ所を描く。**発振器の中は回路の教科書の
3-2 の図 1 と同じ形**で、値だけ上のとおりに替え、LED (R1・D1) は外す。部品の配線は図 2。

```circuit
title: 図1 555 の発振器を 20 dB パッドで tinySA へ
parts:
  X1:
    type: device
    at: b1
    label: NE555 189.5 kHz
    pins: [OUT, GND]
    turn: mirror
  P1: resistor b6 b8 43
  P2: resistor b8 d8 11
  P3: resistor b8 b10 43
  X2:
    type: device
    at: b12
    label: tinySA
    pins: [RF, GND]
  GO: ground d5
  GP: ground d8
  GM: ground d11
wires:
  - X1.OUT -| b6
  - b10 -| X2.RF
  - X1.GND -| d5
  - X2.GND -| d11
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/05-square-wave-harmonics-1.svg)

- 555 の出力は 0〜5 V を往復する方形波で、直接 tinySA (50 Ω) につなぐと
  基本波だけで +20 dBm 近くになる (見るべき値で計算)。**0-3 と同じ 20 dB
  T 型パッド (43 Ω・11 Ω・43 Ω) を必ず挟む** (図の P1〜P3)
- `Cc` (5 番 CTRL のバイパス) は回路の教科書の 3-2 と同じ理由で残す

40106 の版 (Rf 10 kΩ・C 470 pF、f = 1/(1.2×Rf×C) ≈ **177.3 kHz**、
デューティはほぼ 50%) は回路の教科書の 3-8 と同じ回路に周波数とパッドを足したもの。
こちらはブレッドボードには組まず、比較のための回路図だけ載せる。

```circuit
title: 図3 40106 の RC 発振 (177.3 kHz) + パッドで tinySA へ
parts:
  U1: not c3
  Rf: resistor a2 a4 10k
  C1: capacitor c2 e2 470p
  G1: ground e2
  U2: not c6
  P1: resistor c8 c10 43
  P2: resistor c10 e10 11
  P3: resistor c10 c12 43
  X2:
    type: device
    at: c14
    label: tinySA
    pins: [RF, GND]
  GP: ground e10
  GM: ground e13
wires:
  - a2 -- c2 -- U1.in
  - a4 -- c4
  - U1.out -- c4 -- U2.in
  - U2.out -- c8
  - c12 -| X2.RF
  - X2.GND -| e13
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/05-square-wave-harmonics-2.svg)

## 実体配線図

555 の版だけをブレッドボードに組む。回路の教科書の 3-2 の配線から LED (R1・D1) を外し、
代わりに 3 番 (OUT) を ATT 経由で tinySA へ出す。

```breadboard
title: 図2 ブレッドボードに組む (189.5 kHz 版)
board: half
parts:
  U1: dip8 @ e10 NE555
  Ra: resistor b7 b11 1k
  Rb: resistor c11 c12 3.3k
  C1: capacitor d12 d9 1n
  Cc: capacitor d13 d20 10n
  ATT:
    type: device
    at: bottom
    label: ATT 20dB
    pins: [IN, OUT]
  SA:
    type: device
    at: bottom
    label: tinySA
    pins: [RF, GND]
wires:
  - +t1 -- +b1 red
  - -t1 -- -b1 black
  - +t7 -- a7 red
  - +t10 -- a10 red
  - c9 -- -t9 black
  - c20 -- -t20 black
  - h11 -- c12 orange
  - j10 -- -b10 black
  - i13 -- +b13 red
  - g12 -- ATT.IN orange
  - ATT.OUT -- SA.RF orange
  - SA.GND -- -b19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/breadboard/05-square-wave-harmonics.svg)

- DIP8・電源・RESET の配線は回路の教科書の 3-2 と同じ (溝をまたいで挿す、4 番は +5V に固定)
- 3 番 OUT (下ブロック、列12) はそのまま `ATT.IN` へ。ATT (20 dB パッド) は
  実際には 3-5 のような小さな別基板で組み、ブレッドボードとは短い同軸か
  クリップ線でつなぐ (ブレッドボードの穴は高周波の 50 Ω 整合には向かない)

## 計器の設定

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 中心周波数 | 555: 189.5 kHz、40106: 177.3 kHz (それぞれ基本波に合わせる) | `FREQUENCY` → `CENTER` |
| スパン | 1 MHz (5 次高調波まで入る) | `FREQUENCY` → `SPAN` |
| RBW | 10 kHz (基本波と高調波、周りの信号を分けられる細かさ) | `FREQUENCY` → `RBW` |
| 基準レベル | 0 dBm | `LEVEL` → `REF LEVEL` |

## 見るべき値

計算値。0〜5 V の方形波の n 次高調波の振幅 (0-peak) は (2×5/(nπ))×\|sin(nπD)\|
(Analog Discovery の教科書の 4-2・4-9 と同じ式)。50 Ω に直接乗せた電力から 20 dB パッドを
引いた値。555 の出力を電圧源と見ると、43 Ω・11 Ω・43 Ω のパッドの先の電圧は
50 Ω に直接かけたときの 0.1001 倍 (−19.99 dB) なので、20 dB を引けばよい。

**555 (D ≈ 56.6%)**:

| 次数 n | 周波数 | パッド込みの電力 (計算値) |
| --- | --- | --- |
| 1 (基本波) | 189.5 kHz | −0.1 dBm |
| 2 | 378.9 kHz | −13.9 dBm |
| 3 | 568.4 kHz | −11.3 dBm |
| 4 | 757.9 kHz | −14.7 dBm |
| 5 | 947.4 kHz | −19.7 dBm |

**40106 (D ≈ 50%)**:

| 次数 n | 周波数 | パッド込みの電力 (計算値) |
| --- | --- | --- |
| 1 (基本波) | 177.3 kHz | +0.1 dBm |
| 2 | 354.6 kHz | 理想では 0 (ノイズフロアに埋もれる) |
| 3 | 531.9 kHz | −9.5 dBm |
| 4 | 709.2 kHz | 理想では 0 (ノイズフロアに埋もれる) |
| 5 | 886.5 kHz | −13.9 dBm |

分かること:

- **555 は 2・4 次 (偶数次) が −14 dB 前後の高さではっきり見える。40106 は
  理想どおりならノイズフロアに埋もれて見えない** — デューティが 50% から
  ずれているかどうかを、スペアナの画面だけで判定できる (11-3・AD の
  教科書の 4-9 と同じ考え方)
- 実際の 40106 も、電源電圧やしきい値 V<sub>T+</sub>・V<sub>T-</sub> の非対称で
  デューティが完全な 50% からわずかにずれるため、偶数次がノイズフロアぎりぎり
  まで顔を出すことがある。**理想値との差を実測して、自分の個体のデューティの
  ずれを逆算できる** (11-2 の式の使い方の応用)
- Analog Discovery の教科書の 4-9 は同じ発振の考え方を 1 kHz 帯で **FFT 型 (Spectrum)** で
  見ている。ここでの掃引型の見え方と比べると、**FFT 型は 1 回の取り込みで
  全体が出る (速い) が範囲がサンプル周波数で決まり、掃引型は 1 点ずつ
  時間をかけて広い範囲を見られる**、という 11-1 の違いがそのまま体感できる

## 出典

自作。555 の非安定接続は回路の教科書の 3-2 (基本形は 1.4 Hz、ここでは
Ra・Rb・C を変えて 189.5 kHz に上げている)。40106 の RC 発振は回路の
教科書の 3-8。矩形波のフーリエ級数の式は Analog Discovery の教科書の 4-2・4-9 と同じ。
パッドの値は 0-3 と同じ 20 dB T 型。
