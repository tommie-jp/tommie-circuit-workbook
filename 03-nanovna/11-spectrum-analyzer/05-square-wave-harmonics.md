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
High のほうが長い)。**40106 のシュミット RC 発振は 50% に近い** (回路の教科書の 3-8。データシートの標準の
しきい値なら約 48%)。
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
    at: 1,2
    label: NE555 189.5 kHz
    pins: [OUT, GND]
    turn: mirror
  P1: resistor 6,2 8,2 43
  P2: resistor 8,2 8,4 11
  P3: resistor 8,2 10,2 43
  X2:
    type: device
    at: 12,2
    label: tinySA
    pins: [RF, GND]
  GO: ground 5,4
  GP: ground 8,4
  GM: ground 11,4
wires:
  - X1.OUT -| 6,2
  - 10,2 -| X2.RF
  - X1.GND -| 5,4
  - X2.GND -| 11,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/05-square-wave-harmonics-1.svg)

- 555 (NE555、バイポーラ) の出力の High は電源より低い。TI のデータシートでは
  5 V・100 mA 引き出したときの V<sub>OH</sub> が標準 3.3 V (電源から約 1.7 V 落ちる)。
  パッドの入口は約 52.8 Ω なので、High のとき約 62 mA 流れ、出力は **0〜約 3.3 V** を
  往復する (出力の定格 200 mA の内)。見るべき値はこの 3.3 V で計算する
- それでも直接 tinySA (50 Ω) につなぐと基本波だけで約 +16 dBm になり、tinySA の入力の
  上限 (絶対最大 +6 dBm、11-1) を超える。**0-3 と同じ 20 dB T 型パッド (43 Ω・11 Ω・43 Ω) を
  必ず挟む** (図の P1〜P3)
- `Cc` (5 番 CTRL のバイパス) は回路の教科書の 3-2 と同じ理由で残す

40106 の版 (Rf 10 kΩ・C 470 pF、3-8 の目安の式 f = 1/(1.2×Rf×C) で ≈ **177.3 kHz**、
デューティは 50% に近い) は、発振の部分 (U1・Rf・C1) が回路の教科書の 3-8 と同じ回路で、
値を替えて周波数を上げてある。3-8 で緩衝に使った 2 つ目の 40106 (U2) だけを
**74HC14 の 1 回路**に替えた。**40106 の出力は 5 V で 1 mA 程度しか流せず
(TI のデータシートで 4.6 V のとき標準 1 mA)、約 53 Ω のパッドを駆動できない**ため。
74HC14 も出力の絶対最大定格は 1 本 ±25 mA なので、直接パッドにつなぐと
約 5 V ÷ (出力抵抗 約 45 Ω + 52.8 Ω) ≈ 51 mA で超える。**Rs 150 Ω を直列に入れて
約 20 mA に抑える** (出力抵抗 約 45 Ω は、データシートの 4.5 V・4 mA での V<sub>OH</sub> 4.3 V・
V<sub>OL</sub> 0.17 V から見積もった目安)。
こちらはブレッドボードには組まず、比較のための回路図だけ載せる。

```circuit
title: 図3 40106 の RC 発振 + 74HC14 の緩衝 + パッドで tinySA へ
parts:
  U1: not 3,3 40106
  Rf: resistor 2,1 4,1 10k
  C1: capacitor 2,3 2,5 470p
  G1: ground 2,5
  U2: not 6,3 74HC14
  Rs: resistor 8,3 9,3 150
  P1: resistor 9,3 11,3 43
  P2: resistor 11,3 11,5 11
  P3: resistor 11,3 13,3 43
  X2:
    type: device
    at: 15,3
    label: tinySA
    pins: [RF, GND]
  GP: ground 11,5
  GM: ground 14,5
wires:
  - 2,1 -- 2,3 -- U1.in
  - 4,1 -- 4,3
  - U1.out -- 4,3 -- U2.in
  - U2.out -- 8,3
  - 13,3 -| X2.RF
  - X2.GND -| 14,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/05-square-wave-harmonics-2.svg)

- パッドの入口の電圧は High で 5 V × 52.8 / (45 + 150 + 52.8) ≈ **1.07 V**、Low で 0 V。
  555 の版より振幅が小さいぶん、どの次数も約 10 dB 低く出る
- 40106 と 74HC14 の電源 (14 番 5 V・7 番 GND) と、使わない入力を GND へつなぐ線は
  図では省いた (3-8 と同じ)。74HC14 の入力は 40106 の出力 (0〜5 V) で十分に振れる

## 実体配線図

555 の版だけをブレッドボードに組む。回路の教科書の 3-2 の配線から LED (R1・D1) を外し、
代わりに 3 番 (OUT) を ATT 経由で tinySA へ出す。

```breadboard
title: 図2 ブレッドボードに組む (189.5 kHz 版)
board: half
parts:
  U1: dip8 @ e10 NE555
  Ra: resistor a11 +t11 1k
  Rb: resistor c11 c12 3.3k
  C1: capacitor i11 i7 1n
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
  - +t10 -- a10 red
  - c20 -- -t20 black
  - g11 -- g9 -- b9 -- b12 orange
  - j7 -- -b7 black
  - j10 -- -b10 black
  - i13 -- +b13 red
  - g12 -- ATT.IN orange
  - ATT.OUT -- SA.RF orange
  - SA.GND -- -b19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/breadboard/05-square-wave-harmonics.svg)

- DIP8 の挿し方と電源・RESET の考え方は回路の教科書の 3-2 と同じ (溝をまたいで挿す、
  4 番は +5V に固定)。部品の置き場所は、線が IC や部品の上を通らないように並べ替えた
- 2 番 (TRIG) と 6 番 (THR) は、IC の左を回る橙の線 (g11 → g9 → b9 → b12) で結ぶ。
  C1 (1 nF) は下ブロックで 2 番の列から GND へ、Ra は 7 番の列から上の +5V のレールへ
- 3 番 OUT (下ブロック、列12) はそのまま `ATT.IN` へ。ATT (20 dB パッド) は
  実際には 3-5 のような小さな別基板で組み、ブレッドボードとは短い同軸か
  クリップ線でつなぐ (ブレッドボードの穴は高周波の 50 Ω 整合には向かない)

## 計器の設定

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 開始・終了 | 100 kHz〜1.5 MHz (2 つの版とも 5 次高調波まで入る。40106 の版は周波数が 262 kHz まで上がっても 5 次の 1.31 MHz が入る) | `FREQUENCY` → `START` / `STOP` |
| RBW | 10 kHz (基本波と高調波、周りの信号を分けられる細かさ) | `FREQUENCY` → `RBW` |
| 基準レベル | +10 dBm (一番高い山 −3.7 dBm が上端から約 1.4 目盛下) | `LEVEL` → `REF LEVEL` |

## 見るべき値

計算値。High が V<sub>H</sub>、Low が 0 V の方形波の n 次高調波の振幅 (0-peak) は
(2×V<sub>H</sub>/(nπ))×\|sin(nπD)\| (Analog Discovery の教科書の 4-2・4-9 と同じ式)。
これがパッドの入口の電圧で、43 Ω・11 Ω・43 Ω のパッドの先 (tinySA の 50 Ω) の電圧は
その 0.1001 倍 (−19.99 dB)。電力は V<sub>peak</sub>² / (2×50 Ω)。立ち上がり・立ち下がり
(NE555 で標準 100 ns) による高次の目減りは 5 次でも 0.2 dB 未満なので無視した。

**555 (D ≈ 56.6%、V<sub>H</sub> ≈ 3.3 V)**:

| 次数 n | 周波数 | パッド込みの電力 (計算値) | 基本波との差 |
| --- | --- | --- | --- |
| 1 (基本波) | 189.5 kHz | −3.7 dBm | 0 dB |
| 2 | 378.9 kHz | −17.5 dBm | −13.8 dB |
| 3 | 568.4 kHz | −14.9 dBm | −11.1 dB |
| 4 | 757.9 kHz | −18.3 dBm | −14.5 dB |
| 5 | 947.4 kHz | −23.3 dBm | −19.6 dB |

**40106 + 74HC14 (D ≈ 47.9%、パッドの入口で V<sub>H</sub> ≈ 1.07 V)**:

D はデータシートの標準のしきい値 (5 V で V<sub>T+</sub> 2.9 V・V<sub>T−</sub> 1.9 V) から
計算した。74HC14 で反転すると D は 52.1% になるが、高調波の大きさは同じ。
周波数は 3-8 の目安の式の 177.3 kHz で書いた。同じ標準のしきい値で計算すると
周期は 0.81×Rf×C (約 262 kHz) になり、しきい値のばらつきで大きく動く。
**実際の基本波を tinySA で探し、2 次以上はその整数倍で読む**。

| 次数 n | 周波数 (目安) | パッド込みの電力 (計算値) | 基本波との差 | D = 50% ちょうどなら |
| --- | --- | --- | --- | --- |
| 1 (基本波) | 177.3 kHz | −13.4 dBm | 0 dB | −13.4 dBm |
| 2 | 354.6 kHz | −37.2 dBm | −23.8 dB | 0 (ノイズフロアに埋もれる) |
| 3 | 531.9 kHz | −23.1 dBm | −9.7 dB | −22.9 dBm |
| 4 | 709.2 kHz | −37.3 dBm | −23.9 dB | 0 (ノイズフロアに埋もれる) |
| 5 | 886.5 kHz | −27.8 dBm | −14.4 dB | −27.3 dBm |

分かること:

- **基本波との差で比べる** (2 つの版は振幅が違うので、dBm のままでは比べられない)。
  **555 は 2・4 次 (偶数次) が基本波の −14 dB 前後ではっきり見える。40106 の版は
  −24 dB 前後で、555 より約 10 dB 低い**。D がちょうど 50% ならノイズフロアに埋もれる —
  デューティが 50% からどれだけずれているかを、スペアナの画面だけで判定できる
  (11-3・AD の教科書の 4-9 と同じ考え方)
- 40106 のしきい値 V<sub>T+</sub>・V<sub>T-</sub> は個体と電源電圧でばらつき、D も動く。
  2 次と基本波の差 (dB) は 20 log₁₀(\|sin 2πD\| / (2\|sin πD\|)) なので、
  **差を実測すると自分の個体のデューティのずれを逆算できる** (−24 dB なら D ≈ 48%。
  11-2 の式の使い方の応用)
- Analog Discovery の教科書の 4-9 は同じ発振の考え方を 1 kHz 帯で **FFT 型 (Spectrum)** で
  見ている。ここでの掃引型の見え方と比べると、**FFT 型は 1 回の取り込みで
  全体が出る (速い) が範囲がサンプル周波数で決まり、掃引型は 1 点ずつ
  時間をかけて広い範囲を見られる**、という 11-1 の違いがそのまま体感できる

## 出典

自作。555 の非安定接続は回路の教科書の 3-2 (基本形は 1.4 Hz、ここでは
Ra・Rb・C を変えて 189.5 kHz に上げている)。40106 の RC 発振は回路の
教科書の 3-8 (緩衝だけ 74HC14 に替えた)。NE555 の V<sub>OH</sub>、CD40106B の
出力電流としきい値、SN74HC14 の出力の定格と V<sub>OH</sub>・V<sub>OL</sub> は TI のデータシート
([NE555](https://www.ti.com/lit/ds/symlink/ne555.pdf)、[CD40106B](https://www.ti.com/lit/ds/symlink/cd40106b.pdf)、
[SN74HC14](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf))。矩形波のフーリエ級数の式は Analog Discovery の教科書の 4-2・4-9 と同じ。
パッドの値は 0-3 と同じ 20 dB T 型。
