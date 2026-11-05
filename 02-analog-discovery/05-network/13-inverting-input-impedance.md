---
book: analog-discovery
chapter: 5
id: 5-13
title: 反転増幅の入力インピーダンスと周波数
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-13 反転増幅の入力インピーダンスと周波数

反転増幅の入力インピーダンスは R<sub>in</sub> だ、と習う。− 入力は仮想接地 (0 V に張り付く点) なので、
信号源からは R<sub>in</sub> の先が GND に見えるからだ。ところが仮想接地は、オペアンプの開ループ利得 A が
大きいときだけの近似である。− 入力から見たインピーダンスは R<sub>f</sub>/(1 + A) で、A が周波数とともに下がると
この値が上がり、入力インピーダンスは R<sub>in</sub> から R<sub>in</sub> + R<sub>f</sub> へ向かって増えていく。

この題では、信号源と回路の間に**直列の抵抗 R<sub>s</sub>** を 1 本入れ、その両端の電圧の比を Network で掃引する。
比 H = Z<sub>in</sub>/(R<sub>s</sub> + Z<sub>in</sub>) から Z<sub>in</sub> = R<sub>s</sub> · H/(1 − H) が出る (直列抵抗法)。
オペアンプは LM358 (GBW (利得帯域幅積) ≈ 1 MHz、データシートの代表値)、利得は −10 倍。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 反転増幅 (利得 -10 倍) の入力に Rs を入れて、X の電圧を測る
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
  G2: ground 3,3
  Rs: resistor 3,1 6,1 10k l=$\mathrm{R_s}$
  M2: voltmeter 6,1 6,3 l=$\mathrm{CH2}$
  G3: ground 6,3
  Rin: resistor 6,1 9,1 10k l=$\mathrm{R_{in}}$
  U1: opamp 11,3 +down
  G4: ground 10,5
  Rf: resistor 9,1 13,1 100k l=$\mathrm{R_f}$
  OUT: port 14,3 out
wires:
  - 1,1 -- 3,1
  - 9,1 |- U1.-
  - U1.+ -| 10,5
  - U1.out -| 13,1
  - U1.out -- 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/13-inverting-input-impedance.svg)

- R<sub>s</sub> (10 kΩ) は測るための抵抗で、増幅の回路の一部ではない。R<sub>in</sub> と同じ値にしたので、
  仮想接地が効く低い周波数では H = 1/2 (−6.02 dB) になる
- X (R<sub>s</sub> と R<sub>in</sub> の間) に CH2、W1 に CH1 をつなぐ。Network の比 CH2/CH1 がそのまま H
- 利得 −R<sub>f</sub>/R<sub>in</sub> = −10 倍。OUT は何にもつながない (出力の電圧は測らない)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3
board: half
parts:
  U1: dip8 @ f8 LM358
  Rf: resistor g9 g8 100k cap=left
  Rin: resistor h9 h14 10k
  Rs: resistor i14 i19 10k
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V-, 2+, W1, 1+, V+, GND, 1-, 2-]
wires:
  - -b1 -- -t1 black
  - a9 -- a10 green
  - a11 -- -t11 black
  - +t8 -- a8 red
  - j10 -- -b10 black
  - AD.V- -- j11 purple
  - AD.2+ -- j14 blue
  - AD.1+ -- h19 orange
  - AD.W1 -- j19 yellow
  - AD.V+ -- +b22 red
  - +b24 -- +t24 red
  - AD.GND -- -b26 black
  - AD.1- -- -b27 black
  - AD.2- -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/13-inverting-input-impedance.svg)

- U1 (LM358) の 1 回路目を使う。1 番 OUT1 (8 列)・2 番 IN1− (9 列)・3 番 IN1+ (10 列)・4 番 V− (11 列)。
  使わない 2 回路目は 5-6 と同じくフォロアにして (7 番と 6 番を短絡、5 番を GND)、入力を固定する
- R<sub>f</sub> (100 kΩ) は 8 列と 9 列の間、R<sub>in</sub> は 9 列から 14 列 (X)、R<sub>s</sub> は 14 列から 19 列 (W1)。
  14 列に CH2 (2+)、19 列に W1 と CH1 (1+) を挿す
- 3 番 (10 列) は黒の線で下の − レールへ落とす。V− は AD3 の V− から 4 番 (11 列) へ直に入れる
- V+ は下の + レールから 24 列の赤線で上の + レールへ渡して 8 番 (`a8`) に入れる。GND・1−・2− は下の − レールにまとめ、
  1 列目の黒線で上の − レールとつなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れる |
| Wavegen | W1: Amplitude 0.2 V、Offset 0 V (X は 0.1 V<sub>p</sub>、出力は最大 1 V<sub>p</sub> で、レールから遠い) |
| Network | Start 1 kHz、Stop 1 MHz、Log、Steps 101、Reference: Channel 1 |
| 書き出し | 掃引の結果を CSV に書き出し、H から Z<sub>in</sub> を表計算で出す (Network の画面は比しか出さない) |

掃引の途中の 1 点、100 kHz の時間波形が図3 (計算値)。X の振幅は W1 の 0.65 倍 (−3.76 dB) に増え、
しかも W1 より 11° **進む**。抵抗だけなら 0.5 倍・0° のはずで、進みは Z<sub>in</sub> が誘導性 (コイルのよう) になった印である。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 100 kHz — X (CH2) は W1 の 0.65 倍で、11° 進む
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: sine 100kHz 0.2V, range: 100mV/div}
ch2: {wave: sine 100kHz 0.129V phase 11.3deg, range: 100mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/13-inverting-input-impedance.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入り。1 回路目を使う) | LM358 |
| R<sub>in</sub> | 抵抗 (1/4 W) | 10 kΩ |
| R<sub>f</sub> | 抵抗 (1/4 W) | 100 kΩ |
| R<sub>s</sub> | 抵抗 (1/4 W、測るための直列抵抗) | 10 kΩ |
| — | 電源 | ±5 V (AD3 の Supplies)。LM358 の入力が 0 V の付近で動くよう両電源にした |
| — | 計器 | AD3 の W1・Scope 1+ (W1)・2+ (X) |

## 見るべき値

計算値。オペアンプは 1 次の模型 (DC 利得 100 dB、GBW 1 MHz) と仮定した。− 入力から見たインピーダンスは

Z<sub>x</sub> = R<sub>f</sub>/(1 + A) ≈ jω · R<sub>f</sub>/(2π · GBW)  (A ≫ 1 の所)

で、**仮想接地はインダクタンス L = R<sub>f</sub>/(2π · GBW) = 15.9 mH のコイルに見える**。
入力インピーダンスは Z<sub>in</sub> = R<sub>in</sub> + Z<sub>x</sub>。|Z<sub>x</sub>| が R<sub>in</sub> と等しくなるのは
f = R<sub>in</sub>/(2πL) ≈ 100 kHz で、閉ループの帯域 (GBW/(1 + R<sub>f</sub>/R<sub>in</sub>) = 90.9 kHz) とほぼ同じ所。

| 周波数 | \|Z<sub>x</sub>\| | Z<sub>in</sub> | H (CH2 の 24 pF なし) | H (24 pF あり、画面の値) |
| --- | --- | --- | --- | --- |
| 1 kHz | 100 Ω | 10.0 kΩ | −6.06 dB、0.3° | −6.06 dB、0.2° |
| 10 kHz | 1.00 kΩ | 10.06 kΩ | −6.03 dB、2.8° | −6.02 dB、2.4° |
| 100 kHz | 9.95 kΩ | 14.8 kΩ ∠42° | −3.96 dB、16.7° | −3.76 dB、11.3° |
| 300 kHz | 28.7 kΩ | 33.0 kΩ | −1.61 dB、12.1° | −1.54 dB、−9.6° |
| 1 MHz | 70.7 kΩ | 78.1 kΩ | −0.92 dB、4.2° | −5.13 dB、−52.1° |
| (上限) | 100 kΩ | 110 kΩ | −0.76 dB | — |

-6.06 dB が −6.02 dB より少し低いのは、CH2 の入力抵抗 1 MΩ が Z<sub>in</sub> に並列に入るから (1 MΩ ∥ 10 kΩ = 9.9 kΩ)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 Zin は 100 kHz から増え、H が持ち上がる (24 pF は 300 kHz より上を崩す)
x: 周波数 Hz log 1k..1M
y:
  - H dB -7..0
  - Zin kΩ 0..90
lines:
  H (24 pF なし) dB:
    - 1k -6.06
    - 2k -6.06
    - 5k -6.05
    - 10k -6.03
    - 20k -5.92
    - 50k -5.29
    - 100k -3.96
    - 200k -2.29
    - 300k -1.61
    - 500k -1.15
    - 1M -0.92
  H (24 pF あり) dB:
    - 1k -6.06
    - 2k -6.06
    - 5k -6.05
    - 10k -6.02
    - 20k -5.91
    - 50k -5.23
    - 100k -3.76
    - 200k -1.99
    - 300k -1.54
    - 500k -2.12
    - 1M -5.13
  Zin kΩ:
    - 1k 10.00
    - 2k 10.00
    - 5k 10.02
    - 10k 10.06
    - 20k 10.24
    - 50k 11.40
    - 100k 14.79
    - 200k 23.70
    - 300k 33.03
    - 500k 50.00
    - 1M 78.10
notes:
  - level -6.02dB
  - mark 100k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/13-inverting-input-impedance.svg)

分かること:

- **10 kHz までは Z<sub>in</sub> = R<sub>in</sub> (10 kΩ)。** 教科書の答えが成り立つのは、ループ利得が十分大きい周波数だけ
- **100 kHz で Z<sub>in</sub> は 14.8 kΩ、1 MHz で 78 kΩ。** 閉ループの帯域 (90.9 kHz) を越えると、オペアンプは − 入力を 0 V に
  保てなくなり、R<sub>f</sub> の先が見え始める。位相が進むのは、仮想接地がコイル (15.9 mH) のように見えるため
- **CH2 の入力容量 24 pF (AD3 の仕様、1 MΩ ∥ 24 pF) が、300 kHz より上の読みを崩す。** 1 MHz では 24 pF の
  リアクタンスが 6.6 kΩ で、78 kΩ の Z<sub>in</sub> より 1 桁小さい。CSV から Z<sub>in</sub> を出すときは、
  1/Z<sub>in</sub> = (1 − H)/(R<sub>s</sub> · H) − 1/1 MΩ − jω · 24 pF と、計器の分を引く。プローブとワイヤの容量も
  加わるので、引いても 300 kHz より上は目安
- R<sub>s</sub> を Z<sub>in</sub> と同じくらいに選ぶと H が −6 dB の付近になり、Z<sub>in</sub> の変化が H にいちばん大きく出る

## LTspice での確かめ

`sim/13-inverting-input-impedance.cir` で図1 を解いた。オペアンプは 5-6 と同じ 1 次の模型 (DC 利得 100 dB、GBW 1 MHz。
LM358 の代表値からの仮定で、実測ではない)。CH2 は 1 MΩ ∥ 24 pF とし、24 pF を 1 fF (無し) と 24 pF に振った。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 kHz の利得 (OUT/X) | −10 倍 | 9.998 倍 | 合う |
| 10 kHz の \|Z<sub>x</sub>\| (仮想接地) | 1.00 kΩ (15.9 mH) | 999.9 Ω | 合う |
| Z<sub>in</sub> (10 kHz・100 kHz・1 MHz) | 10.06 kΩ・14.8 kΩ ∠42°・78.1 kΩ | 10.06 kΩ・14.79 kΩ ∠42.0°・78.10 kΩ | 合う |
| H (1 kHz) | −6.06 dB | 0.4976 (−6.06 dB) | 合う |
| H (100 kHz、24 pF なし / あり) | −3.96 dB 16.7° / −3.76 dB 11.3° | 0.6335 16.66° / 0.6485 11.28° | 合う |
| H (300 kHz、なし / あり) | −1.61 dB / −1.54 dB | 0.8305 / 0.8373 | 合う |
| H (1 MHz、なし / あり) | −0.92 dB / −5.13 dB | 0.8998 / 0.5537 | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。CH2 の入力インピーダンス (1 MΩ ∥ 24 pF) は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
LM358 の GBW はデータシートの代表値。
