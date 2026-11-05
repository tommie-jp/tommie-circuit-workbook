---
book: analog-discovery
chapter: 10
id: 10-3
title: レギュレータの PSRR
tier: 200
source: 自作 (値の目安は TI LM340 のデータシート、計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 10-3 レギュレータの PSRR

10-2 の平滑の後ろには、ふつう 3 端子レギュレータを置く。入力に残ったリップルを、レギュレータが出力でどれだけ小さくするかを
**PSRR** (Power Supply Rejection Ratio、電源電圧変動除去比。データシートでは Ripple Rejection) という。
入力のリップルの振幅 v<sub>in</sub> と出力に漏れたリップル v<sub>out</sub> の比を dB で表し、PSRR = 20 log₁₀(v<sub>in</sub> / v<sub>out</sub>)。
7805 のデータシート (TI LM340) は 120 Hz で 80 dB (代表値) と書く。1 万分の 1 だ。

この題では、回路の教科書の 5-3 の 7805 の入力に AD3 の W1 から小さな正弦波を足し、**Network** で入力 (CH1) と出力 (CH2) の比を
10 Hz〜100 kHz で掃引する。Network が出す利得 (CH2 / CH1) がそのまま −PSRR になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 7805 の入力に W1 のリップルを足し、出力との比を測る
parts:
  W1: sine 2,1 2,3 l=$\mathrm{W1}$
  G1: ground 2,3
  R3: resistor 3,1 5,1 150
  C3: ecap 7,4 7,1 100u
  VP: vsource 3,4 3,6 5
  VM: vsource 3,6 3,8 5
  G2: ground 2,6
  R1: resistor 4,4 6,4 100
  C1: capacitor 8,4 8,8 0.33u
  M1: voltmeter 11,4 11,8 l=$\mathrm{CH1}$
  U1: regulator 13,4 7805
  C2: capacitor 15,4 15,8 0.1u
  R2: resistor 17,4 17,8 1k
  M2: voltmeter 19,4 19,8 l=$\mathrm{CH2}$
wires:
  - 2,1 -- 3,1
  - 5,1 -- 7,1
  - 3,4 -- 4,4
  - 6,4 -- 7,4 -- 8,4 -- 11,4 -- U1.in
  - 3,6 -- 2,6
  - U1.out -- 15,4 -- 17,4 -- 19,4
  - U1.gnd -- 13,8
  - 3,8 -- 8,8 -- 11,8 -- 13,8 -- 15,8 -- 17,8 -- 19,8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/03-psrr.svg)

- V<sub>P</sub>・V<sub>M</sub> は AD3 の Supplies の V+ (+5 V) と V− (−5 V)。5-3 と同じく **7805 の GND を V− につなぎ**、
  入力を V+ − V− = 10 V にする。7805 は入力と出力の差が 2 V ほど要るので、AD3 の 5 V だけでは動かない
- R1 (100 Ω) は入力の電源とリップルを足す点を分ける抵抗。V+ の出力インピーダンスはほぼ 0 Ω なので、R1 が無いと W1 のリップルは
  V+ に吸われて入力に乗らない。7805 の入力の電流 (出力 5 mA + 消費電流 約 5 mA) で 1 V 落ち、入力は 9 V になる
- W1 は R3 (150 Ω) と C3 (100 µF) を通って入力に正弦波を足す。C3 は直流を止め、R3 は W1 の電流を 1 V ÷ 150 Ω ≒ 6.7 mA 以下に抑える
- C1 (0.33 µF) と C2 (0.1 µF) はデータシートが入力と出力に置く値。R2 (1 kΩ) は 5 mA の負荷
- CH1 は 7805 の入力、CH2 は出力。どちらも 1− と 2− を V− に当てて差動で読む (AD3 の Scope は差動入力)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 下の赤レールが V+、下の青レールが V− (7805 の GND)
board: half
parts:
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, V-, W1, 1+, 2+, 1-, 2-]
  U1: regulator/to220 f15 f16 f17 7805
  R3: resistor f4 f8 150
  C3: capacitor/electrolytic i11(+) i8(-) 100uF
  R1: resistor g7 g11 100
  C1: capacitor i15 i16 0.33uF cap=left
  C2: capacitor g16 g17 0.1uF cap=right
  R2: resistor i17 i21 1k
wires:
  - AD.V+ -- +b1 red
  - AD.V- -- -b2 black
  - AD.W1 -- j4 green
  - AD.1+ -- j15 orange
  - AD.2+ -- j17 yellow
  - AD.1- -- -b24 black
  - AD.2- -- -b26 black
  - +b7 -- j7 red
  - h11 -- h15 orange
  - j16 -- -b16 black
  - j21 -- -b21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/03-psrr.svg)

- 7805 (TO-220) は印字面を手前にして左から IN・GND・OUT。ピンを下のブロックの f15〜f17 に挿す (胴は溝の上に出る)
- V+ (赤) は下の赤レール、V− (黒) は下の青レール。下の青レールが 7805 の GND (V−) で、1−・2− もここへ
- R1 は赤レール (7 列) から 11 列へ。11 列と IN の 15 列を橙の線でつなぐ。C3 は + を 11 列、− を 8 列に挿し、R3 (4〜8 列) を通って W1 (4 列) へ
- C1 は IN と GND (15・16 列)、C2 は GND と OUT (16・17 列) の間に、ピンのすぐ下へ挿す。R2 は OUT から 21 列へ、21 列は青レールへ
- 流れる電流は 10 mA ほどで、ブレッドボードの範囲 (1 穴 200 mA) に収まる。掃引は 100 kHz までで 3 MHz の内側

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = +5 V、V− = −5 V (両方を入れる。V− が先でも後でもよい) |
| Network | Start 10 Hz、Stop 100 kHz、Log、Steps 100 (目安)。Wavegen は W1・Amplitude 1 V・Offset 0 V。Reference は CH1 |
| Scope の範囲 (Network の中) | CH1 は 9 V の直流に乗った 0.4 V<sub>p</sub>、CH2 は 5 V に乗った数十 µV。直流ごと読むので両方とも 50 V のレンジ (目安) |
| 時間 (Network の中) | 低い周波数で読みが揺れるときは、1 点あたりの周期 (Periods) か平均を増やす (目安) |

まず Scope で直流の電圧を確かめる。CH1 が 9 V 前後、CH2 が 5 V 前後なら 7805 が働いている。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 kHz を足したときの Scope の画面 — CH1 は揺れ、CH2 は平らに見える
time: 500us/div
trigger: ch1 rising 9V
ch1: {wave: sine 1kHz 0.4V offset 9V, range: 2V/div, position: -3div}
ch2: {wave: dc 5V, range: 2V/div, position: -3div}
measure: [vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/03-psrr.svg)

図3 は 2 V/div の同じ尺度で入力と出力を並べた画面 (計算)。CH1 は 9 V の上で 0.8 Vpp 揺れ、CH2 は平らな 5 V に見える。
出力に漏れるリップルは 40 µV ほどで、Scope の 1 目盛の 1 万分の 1 にも満たない。**時間波形では見えない大きさを、
Network は掃引の周波数だけを取り出して (同じ周波数の成分だけを足し合わせて) 読む。** だから PSRR は Scope でなく Network で測る。

Network の画面は、利得 (CH2 / CH1) を dB で描く。見えるはずの線は図4。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 Network の利得 (CH2/CH1) — 低い周波数で −81 dB、2 kHz から上で浅くなる
x: 周波数 Hz log 10..300k
y: 利得 dB -90..-30
lines:
  模型 (LTspice) dB:
    - 10 -81.0
    - 120 -81.0
    - 300 -80.9
    - 1k -80.1
    - 3k -76.4
    - 10k -67.9
    - 30k -58.9
    - 100k -48.8
    - 300k -38.9
  データシート (1 A) dB:
    - 100 -81
    - 1k -76
    - 10k -67
    - 100k -49
notes:
  - mark 120
  - mark 10k
  - mark 100k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/graph/03-psrr.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 3 端子レギュレータ (TO-220) | 7805 (LM7805 など) |
| R1 | 抵抗 (1/4 W) | 100 Ω (損失 10 mW) |
| R2 | 抵抗 (1/4 W) | 1 kΩ (負荷 5 mA、損失 25 mW) |
| R3 | 抵抗 (1/4 W) | 150 Ω (W1 の電流を抑える) |
| C1 | セラミックコンデンサ (334) | 0.33 µF |
| C2 | セラミックコンデンサ (104) | 0.1 µF |
| C3 | 電解コンデンサ (16 V) | 100 µF (+ を 7805 の入力の側へ。入力は AD3 の GND から見て +4 V) |
| — | 電源 | AD3 の V+ と V− の間の 10 V — 7805 は入力と出力の差が 2 V ほど要り、5 V では動かない |
| — | 計器 | AD3 の Supplies (V+・V−)、Wavegen (W1)、Network (CH1 = 入力、CH2 = 出力) |

## 見るべき値

計算値。7805 は TI LM340 のデータシートの図5 (Ripple Rejection) と図7 (Output Impedance) に合わせた模型 (仮定。下の LTspice の節)。
データシートの図は出力 1 A で描かれ、この題の 5 mA とは違う。実物の数は品と電流で変わるので、表の数は目安として読む。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の直流 (入力) | 9.0 V | R1 で 100 Ω × 10 mA = 1 V 落ちる |
| CH2 の直流 (出力) | 5.0 V | 7805 が働いている |
| 入力のリップル (CH1 の振幅) | 0.40 V (1 kHz まで)、0.25 V (10 kHz)、32 mV (100 kHz) | 高い周波数では C1 に吸われて小さくなる。比は CH1 で割るので狂わない |
| 利得 (CH2/CH1) 120 Hz | **−81 dB** (PSRR 81 dB) | データシートは 80 dB (代表値)、62 dB (LM7805 の最小) |
| 利得 10 kHz | −68 dB | 2 kHz あたりから浅くなる。中の誤差増幅器の利得が周波数とともに落ちるため |
| 利得 100 kHz | −49 dB | 120 Hz より 30 dB 悪い (リップルが約 30 倍漏れる) |
| 出力のリップル | 36 µV (120 Hz)、145 µV (100 kHz) | Scope の時間波形では見えない大きさ |

- **60 Hz 地域のリップルは 120 Hz、50 Hz 地域は 100 Hz** (10-1)。図4 の線はこのあたりで平らなので、どちらの地域でも 81 dB と読む
- −80 dB の出力は 36 µV しかなく、AD3 の Network の床 (雑音で読みが揺れる所) に近い (目安)。読みが −70 dB あたりで止まって揺れるなら床で、
  7805 の値ではない。そのときは 10 kHz から上 (出力が 100 µV を超える所) で比べる
- スイッチング電源 (10-6) の雑音は数十 kHz〜数百 kHz にある。図4 のとおり 7805 はそこで 50 dB 前後しか抑えないので、
  スイッチング電源の後ろにリニアを置いても、高い周波数の雑音は残る (10-7)
- 7805 の入力と出力の差を 2 V より詰めると PSRR は大きく落ちる。V+ を 4 V に下げて (入力 7 V) 比べると分かる

## LTspice での確かめ

`sim/03-psrr.cir` で図1 を交流解析した (直流の動作点は `sim/03-psrr-op.cir`)。7805 の中身は SPICE に起こさず、データシートの図に合わせた模型にした (仮定):
入力のリップルを 81 dB 下げて出し、2 kHz から上で 20 dB/dec で漏れを増やす。出力インピーダンスは 8 mΩ と 0.32 µH (1.2 Ω と並列)、消費電流は 5 mA。
LTspice で確かめたのは、注入の回路 (R1・R3・C1・C3) が入力にどれだけ乗せるかと、模型が図に合っているかで、7805 そのものの値ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 入力の直流 | 9.0 V (10 mA) | 9.00 V (10.0 mA) | 合う |
| 入力のリップル 120 Hz・10 kHz・100 kHz | 0.40 V・0.25 V・32 mV | 0.399 V・0.251 V・32.1 mV | 合う |
| W1 の電流 (最大) | 6.7 mA 以下 | 6.67 mA (1 MHz) | 合う |
| 利得 120 Hz | −81 dB | −81.0 dB | 模型 (データシート 80 dB) |
| 利得 10 kHz | −68 dB | −67.9 dB | 模型 (データシート 約 −67 dB) |
| 利得 100 kHz | −49 dB | −48.8 dB | 模型 (データシート 約 −49 dB) |
| 出力のリップル 120 Hz・100 kHz | 36 µV・145 µV | 35.6 µV・145 µV | 合う |

## 出典

自作。PSRR と出力インピーダンスの目安は [TI LM340 / LM7805 のデータシート (SNOSBT0L)](https://www.ti.com/lit/ds/symlink/lm340.pdf) の 6.5 節の表と図5・図7。
計器の名前と操作は Digilent の [Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
