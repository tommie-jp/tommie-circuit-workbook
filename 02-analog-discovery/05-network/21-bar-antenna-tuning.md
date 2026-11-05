---
book: analog-discovery
chapter: 5
id: 5-21
title: バーアンテナ + バリコンの同調曲線
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-21 バーアンテナ + バリコンの同調曲線

AM ラジオの入口は、バーアンテナのコイル L とバリコン (可変コンデンサ) C の並列共振回路で、
f<sub>0</sub> = 1/(2π√(LC)) の局だけを大きく取り出す。6-8 で測ったバーアンテナ (L ≈ 330 µH、Q ≈ 100 の目安) にポリバリコンを並列につなぎ、
Network で**同調曲線** (共振の山) を描く。バリコンを回すと山がどこまで動くか (受信できる範囲)、
山の鋭さ (Q) がどれだけか (隣の局を分ける力) を確かめる。回路の教科書の 9-2 (ゲルマラジオ) の入口と同じ回路。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 から 470 kΩ で弱く注入し、同調回路 (L と VC) の両端を CH2 で見る
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  G1: ground 1,3
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G2: ground 3,3
  Rinj: resistor 3,1 6,1 470k l=$\mathrm{R_{inj}}$
  Lant: inductor 7,1 7,3 330u l=$\mathrm{L_{ANT}}$
  G3: ground 7,3
  VC: capacitor-var 9,1 9,3 260p l=$\mathrm{VC}$
  G4: ground 9,3
  M2: voltmeter 11,1 11,3 l=$\mathrm{CH2}$
  G5: ground 11,3
wires:
  - 1,1 -- 3,1
  - 6,1 -- 7,1
  - 7,1 -- 9,1
  - 9,1 -- 11,1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/21-bar-antenna-tuning.svg)

- R<sub>inj</sub> (470 kΩ) は信号源を同調回路から切り離す抵抗。W1 (0 Ω) を直につなぐと同調回路が短絡されて山が出ない。
  ラジオでは、アンテナから入る電波がこの「弱い注入」に当たる
- L<sub>ANT</sub> はバーアンテナの巻線全体 (6-8 と同じ両端)。VC はポリバリコン (AM 用、最大 260 pF・最小 20 pF ほどのもの)
- CH2 の入力 (1 MΩ ∥ 24 pF、AD3 の仕様) も同調回路に並列に入る。24 pF はバリコンに足され、1 MΩ は Q を下げる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (アンテナとバリコンは外)
board: half
parts:
  Rinj: resistor c5 c12 470k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1-, GND, 1+, W1, 2+, 2-]
  ANT:
    type: device
    at: bottom
    label: Bar Antenna
    pins: [B, A]
  VC:
    type: device
    at: bottom
    label: ポリバリコン
    pins: [A, B]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.GND -- -t3 black
  - AD.1- -- -t2 black
  - AD.2+ -- a12 blue
  - AD.2- -- -t14 black
  - d12 -- g12 white
  - ANT.A -- j12 brown
  - ANT.B -- -b10 brown
  - VC.A -- i13 green
  - h12 -- h13 white
  - VC.B -- -b17 green
  - -b1 -- -t1 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/21-bar-antenna-tuning.svg)

- R<sub>inj</sub> は 5 列 (W1・CH1) から 12 列 (同調回路の上の端)。12 列に CH2 (2+) を挿し、白の線で溝を渡して下のブロックへ延ばす
- バーアンテナとポリバリコンは基板に挿せないので、6-8 と同じく**基板の外の機器**として描いた。それぞれの 2 本の線を
  12・13 列と下の − レールへつなぐ (13 列は白の短い線で 12 列とつなぐ)。線は短くし、束ねない (線の容量も同調の C に足される)
- AD3 の GND・1−・2− は上の − レール、アンテナとバリコンの GND 側は下の − レール。1 列目の黒線で 2 本のレールをつなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V、Offset 0 V |
| Network | Start 300 kHz、Stop 2 MHz、Log、Steps 1001 (山が細いので点を多く)、Reference: Channel 1 |
| 3 回 | バリコンを最大 (羽根を全部入れる)・中ほど・最小 (全部抜く) にして掃引する |
| 山を読む | 山の頂の周波数と高さ、高さから −3 dB の 2 点の幅を読む。Q<sub>L</sub> = f<sub>0</sub> ÷ 幅 |

山の幅は 7〜21 kHz と細い。Steps を 1001 にしても 300 kHz〜2 MHz の対数の掃引では点の間が 1.9 kHz ほどになるので、
幅を読むときは山の前後 ±50 kHz だけを掃引し直す。

バリコン 100 pF のとき、山の頂 (757 kHz) の時間波形が図3 (計算値)。CH2 は CH1 の 0.224 倍で、位相はほぼ 0° (共振で L と C の電流が打ち消し合い、
同調回路は抵抗に見える)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 VC 100 pF・757 kHz — CH2 は 0.22 倍、位相はほぼ 0°
time: 500ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 757kHz 1V, range: 500mV/div}
ch2: {wave: sine 757kHz 0.224V, range: 100mV/div}
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/21-bar-antenna-tuning.svg)

CH1 は 500 mV/div、CH2 は 100 mV/div。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L<sub>ANT</sub> | AM 用のフェライトバーアンテナ (6-8 で測ったもの) | 約 330 µH (巻線全体)、Q 約 100 (目安) |
| VC | ポリバリコン (AM 用、単連) | 最大 260 pF・最小 20 pF ほど (品により違う。親子 2 連なら親の側を使う) |
| R<sub>inj</sub> | 抵抗 (1/4 W、弱く注入する) | 470 kΩ |
| — | 電源 | 使わない |
| — | 計器 | AD3 の W1・Scope 1+ (W1)・2+ (同調回路) |

## 見るべき値

計算値。L = 330 µH、Q = 100 (同調の周波数で)、浮遊容量 10 pF (配線とコイル自身。仮定) と CH2 の 24 pF をバリコンに足した。
同調回路の損失を並列の抵抗 R<sub>p</sub> = Q × 2πf<sub>0</sub>L で表し、CH2 の 1 MΩ と R<sub>inj</sub> も並列に効く (Q<sub>L</sub> は負荷を含む Q)。

| バリコン | C の合計 | f<sub>0</sub> | 山の高さ | Q<sub>L</sub> | −3 dB の幅 |
| --- | --- | --- | --- | --- | --- |
| 260 pF (最大) | 294 pF | **511 kHz** | 0.169 倍 (−15.4 dB) | 75 | 6.8 kHz |
| 100 pF | 134 pF | **757 kHz** | 0.224 倍 (−13.0 dB) | 67 | 11.3 kHz |
| 20 pF (最小) | 54 pF | **1.19 MHz** | 0.296 倍 (−10.6 dB) | 56 | 21.1 kHz |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 バリコンを回すと山は 511 kHz から 1.19 MHz まで動き、高い所ほど幅が広い
x: 周波数 Hz log 300k..2M
y: 利得 dB -50..-5
lines:
  VC 260 pF dB: -20*log10(sqrt(5.906^2+(470k*(2*pi*x*294p-1/(2*pi*x*330u)))^2))
  VC 100 pF dB: -20*log10(sqrt(4.465^2+(470k*(2*pi*x*134p-1/(2*pi*x*330u)))^2))
  VC 20 pF dB: -20*log10(sqrt(3.371^2+(470k*(2*pi*x*54p-1/(2*pi*x*330u)))^2))
notes:
  - band 531k 1602k: AM 放送 (日本)
  - mark 511k
  - mark 757k
  - mark 1.19M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/21-bar-antenna-tuning.svg)

分かること:

- **この組み合わせで同調できるのは 511 kHz〜1.19 MHz。** 日本の AM 放送 (531〜1602 kHz) の上の端に届かないのは、
  CH2 の 24 pF と浮遊容量 10 pF が最小の容量を 54 pF に押し上げているため。CH2 を外したラジオなら最小は 30 pF ほどで、
  上の端は 1.6 MHz に近づく。測定の器具が測る物を変える例 (5-20)
- **f<sub>0</sub> は C の平方根に反比例する。** C を 294 pF → 54 pF と 5.4 倍変えても、f<sub>0</sub> は √5.4 = 2.3 倍しか動かない
- **高い周波数ほど幅が広い。** 幅 = f<sub>0</sub>/Q<sub>L</sub> で、f<sub>0</sub> が上がるうえ、R<sub>inj</sub> と CH2 の 1 MΩ の負荷で Q<sub>L</sub> も下がる。
  ラジオで高い周波数の局ほど混信しやすい理由の 1 つ
- 山の位相は 0° を横切る。山の頂より低い側では + (コイルが勝つ)、高い側では − (コンデンサが勝つ)。頂は位相の 0° で読むと確か
- 実測の f<sub>0</sub> から C の合計を逆算できる (C = 1/((2πf<sub>0</sub>)² L))。バリコンの目盛りの較正にも使える

## LTspice での確かめ

`sim/21-bar-antenna-tuning.cir` で図1 を AC 解析した。L 330 µH・Q 100・浮遊容量 10 pF・CH2 1 MΩ ∥ 24 pF (**仮定**。L と Q は 6-8 の目安)。
バリコンを 260 pF・100 pF・20 pF に振り、山の周波数・高さ・Q<sub>L</sub>・幅を読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 260 pF の山 | 511 kHz・−15.4 dB・Q<sub>L</sub> 75・6.8 kHz | 511.1 kHz・−15.44 dB・75.1・6.80 kHz | 合う |
| 100 pF の山 | 757 kHz・−13.0 dB・Q<sub>L</sub> 67・11.3 kHz | 756.9 kHz・−13.00 dB・67.2・11.26 kHz | 合う |
| 20 pF の山 | 1.19 MHz・−10.6 dB・Q<sub>L</sub> 56・21.1 kHz | 1.193 MHz・−10.56 dB・56.5・21.12 kHz | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。CH2 の入力インピーダンスは Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
バーアンテナの L と Q、ポリバリコンの容量の範囲は一般的な AM ラジオ用部品の目安。
