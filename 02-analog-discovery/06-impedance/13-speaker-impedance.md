---
book: analog-discovery
chapter: 6
id: 6-13
title: スピーカーのインピーダンス曲線
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 6-13 スピーカーのインピーダンス曲線

「8 Ω (オーム)」と書いたスピーカーも、\|Z\| が 8 Ω なのは一部の周波数だけだ。コーンとエッジのばね・質量が
**機械の共振 (最低共振周波数 f<sub>s</sub>)** を持ち、それがボイスコイルの電気の側に**並列の共振回路**として現れて、
f<sub>s</sub> で \|Z\| が山になる。高い周波数ではボイスコイルのインダクタンスで \|Z\| がまた上がる。
6-5 のインピーダンスアナライザアダプタにスピーカーを挟み、20 Hz〜20 kHz の \|Z\| と位相を取って、
f<sub>s</sub> と、共振の鋭さ Q<sub>ms</sub>・Q<sub>es</sub> を読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 アダプタにスピーカーを挟む (アダプタは Analog Discovery 3 に挿したまま)
parts:
  ADP:
    type: device
    at: 1,1
    label: AD3 + Z Analyzer Adapter
    pins: [DUT+, DUT-]
    turn: mirror
  SP1: speaker 9,2 9,4 8
wires:
  - ADP.DUT+ -| 9,2
  - ADP.DUT- -| 7,4
  - 7,4 -- 9,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/13-speaker-impedance.svg)

- アダプタは AD3 の 2×15 コネクタに挿す。W1・1±・2±・GND の 6 本はアダプタの中で結線済み (6-5 の図1)
- SP1 は直径 57 mm・8 Ω・0.5 W ほどの小型スピーカー (箱に入れない、裸のもの)
- 基準抵抗はアダプタの中にあり、WaveForms が \|Z\| に合わせて選ぶ (6-5)。8〜30 Ω の DUT には 10 Ω の段が選ばれると見た (目安)
- この題は実体配線図を付けない — スピーカーの 2 本の線をアダプタの端子台 (J2) に挟むだけで、基板に挿す部品も配線も無い

## 計器の設定

計器は Analog Discovery 3 の Impedance とインピーダンスアナライザアダプタ (Rref を自動で選ぶ)。
AD2 でも同じ設定で測れる。

| 計器 | 設定 |
| --- | --- |
| Impedance | Start 20 Hz、Stop 20 kHz、点数 201 (対数)、**Amplitude 0.1 V**、Reference: Adapter |
| 表示 | \|Z\| と位相 (Phase) |

**振幅を小さくする理由。** スピーカーは 8 Ω と低く、1 V で掃引すると W1 から 50 mA を超える電流を取ろうとする。
0.1 V なら電流は 10 mA 以下 (f<sub>s</sub> で 2.4 mA) で、スピーカーの音も小さい。
**スピーカーは机の上に寝かせず、コーンの前後を空けて吊るす** (前後の空気がふさがると f<sub>s</sub> が動く)。

f<sub>s</sub> (300 Hz) の 1 点を Scope で見ると、CH1 (アダプタの中の基準抵抗 10 Ω の両端) と CH2 (スピーカーの両端) は
同じ位相になる。共振の山の頂では、スピーカーはただの 31 Ω の抵抗に見えるからだ。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 f_s (300 Hz) ではスピーカーは 31 Ω の抵抗 — CH2 は CH1 と同じ位相で 3.1 倍
time: 1ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 300Hz 24.3mV, range: 10mV/div}
ch2: {wave: sine 300Hz 75.7mV phase 0.5deg, range: 50mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/13-speaker-impedance.svg)

CH1 は 10 mV/div、CH2 は 50 mV/div と尺度を分けてある。1 kHz では CH2 が 42.7 mV に下がり (\|Z\| = 7.4 Ω)、
CH1 は 57.5 mV に増える。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| SP1 | 小型スピーカー 8 Ω、0.5 W、57 mm | 箱に入れない。0.1 V なら f<sub>s</sub> で 0.2 mW |
| 計器 | Analog Discovery 3 + インピーダンスアナライザアダプタ | 6-5 と同じ |

## 見るべき値

計算値。スピーカーの**等価回路は仮定** (57 mm の小型スピーカーの目安): ボイスコイルの直流抵抗 R<sub>e</sub> = 7.2 Ω と
インダクタンス L<sub>e</sub> = 0.15 mH (ミリヘンリー) の直列に、機械の共振を表す R<sub>es</sub> = 24 Ω・L<sub>ces</sub> = 3.18 mH・
C<sub>mes</sub> = 88.4 µF (マイクロファラド) の並列。f<sub>s</sub> = 300 Hz、Q<sub>ms</sub> = 4、Q<sub>es</sub> = 1.2 になる値。

| 周波数 | \|Z\| | 位相 | 分かること |
| --- | --- | --- | --- |
| 50 Hz | 7.3 Ω | +8.4° | ほぼ R<sub>e</sub> |
| 231 Hz (f<sub>1</sub>) | 15.0 Ω | + | 山の高さの幾何平均 √(Z<sub>max</sub> × R<sub>e</sub>) を横切る下の点 |
| 300 Hz (f<sub>s</sub>) | **31.2 Ω** (= R<sub>e</sub> + R<sub>es</sub>) | +0.5° | 機械の共振。位相がほぼ 0° |
| 386 Hz (f<sub>2</sub>) | 15.0 Ω | − | 同じく上の点 |
| 1 kHz | 7.4 Ω | −7.9° | 谷 (1〜2 kHz) の入口。**公称の 8 Ω はこの辺り** |
| 10 kHz | 11.7 Ω | +52.1° | ボイスコイルの L<sub>e</sub> で上がる |

山の形から Thiele-Small の値を出す (r = Z<sub>max</sub> / R<sub>e</sub> = 4.33):

- Q<sub>ms</sub> = f<sub>s</sub>√r / (f<sub>2</sub> − f<sub>1</sub>) = 300 × 2.08 / 155 = **4.0** (機械の損失)
- Q<sub>es</sub> = Q<sub>ms</sub> / (r − 1) = **1.2** (電気の制動)、Q<sub>ts</sub> = 1 / (1/Q<sub>ms</sub> + 1/Q<sub>es</sub>) = 0.92
- R<sub>e</sub> はテスターの直流の抵抗で測り、Z<sub>max</sub> は山の頂で読む

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 300 Hz (f_s) で 31 Ω の山、1〜2 kHz で 7.4 Ω 前後の谷、高い所はコイルで上がる
x: 周波数 Hz log 20..20k
y:
  - インピーダンス Ω 0..35
  - 位相 deg -60..90
lines:
  "|Z| Ω": sqrt((7.2+0.041667/(0.0017361+(0.00055556*x-50/x)^2))^2+(0.00094248*x-(0.00055556*x-50/x)/(0.0017361+(0.00055556*x-50/x)^2))^2)
  "位相 deg": deg(atan2(0.00094248*x-(0.00055556*x-50/x)/(0.0017361+(0.00055556*x-50/x)^2), 7.2+0.041667/(0.0017361+(0.00055556*x-50/x)^2)))
notes:
  - mark 300
  - mark 1k
  - mark 10k
  - level 15Ω
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/13-speaker-impedance.svg)

分かること:

- **公称の 8 Ω は f<sub>s</sub> より上の谷の値。** アンプの負荷として 8 Ω と見てよいのは 500 Hz〜3 kHz ほどで、
  f<sub>s</sub> では 4 倍、10 kHz では 1.5 倍になる
- f<sub>s</sub> と Q は、箱 (エンクロージャ) を設計するときの出発点。同じスピーカーを箱に入れて測り直すと、
  箱の空気のばねが加わって f<sub>s</sub> が上がる
- コーンに小さな重り (粘土 数 g) を貼って f<sub>s</sub> の下がり方を見ると、振動系の質量が出せる (追加質量法)

## LTspice での確かめ

`sim/13-speaker-impedance.cir` で図1 の等価回路 (基準抵抗 10 Ω、R<sub>e</sub> 7.2 Ω + L<sub>e</sub> 0.15 mH の直列に、R<sub>es</sub> 24 Ω・
L<sub>ces</sub> 3.18 mH・C<sub>mes</sub> 88.4 µF の並列、W1 の振幅 0.1 V) を 20 Hz〜20 kHz で交流解析した。
等価回路の値は本文の仮定で、**実測ではない**。アダプタの中の基準抵抗は 10 Ω の 1 本で置き換えた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Z<sub>max</sub> と f<sub>s</sub> | 31.2 Ω、300 Hz | 31.20 Ω (300 Hz で 31.20 Ω、位相 +0.5° 前後) | 合う |
| CH1・CH2 (300 Hz) | 24.3 mV・75.7 mV | 24.27 mV・75.73 mV | 合う |
| \|Z\| (1 kHz・10 kHz) | 7.4 Ω・11.7 Ω | 7.43 Ω・11.72 Ω | 合う |
| f<sub>1</sub>・f<sub>2</sub> (15.0 Ω を横切る所) | 231 Hz・386 Hz | 231.1 Hz・385.8 Hz | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Impedance の節)。アダプタは
[Analog Discovery Impedance Analyzer Reference Manual](https://digilent.com/reference/add-ons/impedance-analyzer/reference-manual)
による。
参考: [Thiele/Small parameters — Wikipedia (英語)](https://en.wikipedia.org/wiki/Thiele/Small_parameters)
