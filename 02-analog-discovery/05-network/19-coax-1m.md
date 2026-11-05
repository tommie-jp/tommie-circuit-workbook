---
book: analog-discovery
chapter: 5
id: 5-19
title: ケーブル 1 m の 10 MHz まで
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 5-19 ケーブル 1 m の 10 MHz まで

10 MHz の正弦波の波長は、同軸ケーブルの中で約 20 m (短縮率 0.66 のとき)。1 m のケーブルは波長の 1/20 で、
ほとんど「ただの線」に見える。それでも Network で比 CH2/CH1 を取ると、**位相がケーブルの長さの分だけ遅れ**、
先を開けたままなら**利得がわずかに持ち上がる**。この題では BNC の同軸ケーブル 1 m の両端を CH1・CH2 で見て、
その遅れから伝わる速さ (短縮率) を出す。5-22 で 25 MHz まで測るときの、ケーブルの分の見積りにもなる。

基板を使わない (BNC の T 型の分岐と同軸ケーブルと BNC の終端器だけでつなぐ) ので、実体配線図は描かない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 から同軸 1 m を通して CH2 へ。先は開放 (CH2 だけ) か 50 Ω の終端
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  G1: ground 1,3
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G2: ground 3,3
  T1: tline 4,1 8,1 50
  Rt: resistor 9,1 9,3 50 l=$\mathrm{R_t}$
  G3: ground 9,3
  M2: voltmeter 11,1 11,3 l=$\mathrm{CH2}$
  G4: ground 11,3
wires:
  - 1,1 -- 3,1
  - 3,1 -- 4,1
  - 8,1 -- 9,1
  - 9,1 -- 11,1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/19-coax-1m.svg)

- W1・CH1・CH2 は AD3 の **BNC アダプタ**の BNC から取る。W1 の出力に BNC の T 型の分岐をつなぎ、片側を CH1 へ、
  もう片側に 1 m の同軸 (50 Ω、RG-58 など) をつないで、先を CH2 へ入れる
- R<sub>t</sub> は BNC の 50 Ω の終端器 (CH2 の手前に挟むスルー型)。**外したとき (開放) と付けたときの 2 回**掃引する
- BNC アダプタの W1 の出力インピーダンスはジャンパで 0 Ω か 50 Ω を選べる (AD3 の仕様)。ここは 0 Ω で使う。
  比 CH2/CH1 を取るので、信号源の抵抗は結果に効かない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 0.5 V、Offset 0 V (終端 50 Ω で 10 mA。Wavegen の 30 mA より小さい) |
| Network | Start 100 kHz、Stop 10 MHz、Log、Steps 201、Reference: Channel 1 |
| 遅れを出す | 位相の読みから τ = −位相 / (360° × f)。1 MHz と 10 MHz の 2 点で読む |

BNC アダプタを付けると Scope の帯域は 30 MHz 以上になる (付属のワイヤでは 9 MHz)。CH1 と CH2 は同じ帯域なので、
比を取れば AD3 自身の落ちは打ち消される (5-8)。

50 Ω で終端したときの 10 MHz の時間波形が図3 (計算値)。CH2 は振幅がほぼ同じで、5.2 ns 遅れる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 終端 50 Ω・10 MHz — CH2 は 1 m ぶん 18.6° (5.2 ns) 遅れる
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 10MHz 0.5V, range: 200mV/div}
ch2: {wave: sine 10MHz 0.511V phase -18.6deg, range: 200mV/div}
cursors: [0ns, 5.17ns]
measure: [vpp, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/19-coax-1m.svg)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| T1 | BNC の同軸ケーブル | 1 m、50 Ω (RG-58 系、短縮率 0.66 の目安) |
| R<sub>t</sub> | BNC の終端器 (スルー型) | 50 Ω |
| — | BNC の T 型の分岐 | 1 個 |
| — | 電源 | 使わない |
| — | 計器 | AD3 + BNC アダプタの W1・Scope 1・Scope 2 |

## 見るべき値

計算値。ケーブルは損失なしの 50 Ω、遅れ τ = 1 m/(0.66 × 3×10⁸ m/s) = 5.05 ns (βl = 2πfτ。10 MHz で 18.2°) と仮定した。
CH2 の入力は 1 MΩ ∥ 24 pF (AD3 の仕様)。

| 周波数 | 開放 (CH2 だけ) | 終端 50 Ω |
| --- | --- | --- |
| 1 MHz | +0.01 dB、0° | 0.00 dB、−1.8° (遅れ 5.05 ns) |
| 10 MHz | **+0.66 dB**、0° | +0.20 dB、**−18.6°** (遅れ 5.17 ns) |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 開放の先は持ち上がり (位相 0°)、終端すると平らで位相が遅れる
x: 周波数 Hz log 100k..10M
y:
  - 利得 dB -0.2..0.8
  - 位相 deg -20..2
lines:
  開放 dB: -20*log10(cos(2*pi*x*5.05n)-2*pi*x*24p*50*sin(2*pi*x*5.05n))
  終端 50 Ω dB: -10*log10((cos(2*pi*x*5.05n)-2*pi*x*24p*50*sin(2*pi*x*5.05n))^2+sin(2*pi*x*5.05n)^2)
  開放 (位相) deg: 0*x
  終端 50 Ω (位相) deg: -deg(atan(sin(2*pi*x*5.05n)/(cos(2*pi*x*5.05n)-2*pi*x*24p*50*sin(2*pi*x*5.05n))))
notes:
  - mark 1M
  - mark 10M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/19-coax-1m.svg)

分かること:

- **開放の先は電圧が持ち上がる。** 損失のない線の先が開いていると、先の電圧は根元の 1/cos(βl) 倍になる (10 MHz で 1.05 倍、+0.44 dB)。
  CH2 の 24 pF が線を電気的に少し長く見せ、+0.66 dB になる。位相はほぼ 0° のまま (根元から見ると 101 pF ほどのコンデンサ)
- **終端すると平らになり、位相が長さの分だけ遅れる。** 遅れ 5.05 ns から、伝わる速さは 1 m/5.05 ns = 1.98×10⁸ m/s、
  短縮率 0.66。10 MHz では 24 pF の分で 5.17 ns と少し長く読める。遅れは低い周波数 (1 MHz) の位相で出すほうが確か
- **1 m のケーブルで 10 MHz の利得の誤差は 0.7 dB まで。** 5-22 のように 25 MHz まで測るなら βl は 45° に近づき、
  開放の持ち上がりは 3 dB を超える。高い周波数ほど、ケーブルは短く、先は 50 Ω で終端する
- 遅れの読みは長さに比例する。2 m・3 m と替えて位相が 2 倍・3 倍になれば、線の長さの効きだと確かめられる

## LTspice での確かめ

`sim/19-coax-1m.cir` で図1 を AC 解析した。線路は損失なしの 50 Ω・遅れ 5.05 ns、CH2 は 1 MΩ ∥ 24 pF (**仮定**。RG-58 の損失は
10 MHz・1 m で 0.02 dB ほどなので入れていない)。終端を 1 GΩ (開放) と 50 Ω に振った。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 開放・1 MHz | +0.01 dB | 1.0007 倍 (+0.006 dB) | 合う |
| 開放・10 MHz | +0.66 dB | 1.0793 倍 (+0.66 dB)、位相 0.00° | 合う |
| 終端・1 MHz の位相 | −1.8° (5.05 ns) | 1.82° の遅れ | 合う |
| 終端・10 MHz | +0.20 dB、−18.6° | 1.0228 倍 (+0.20 dB)、18.61° の遅れ | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。CH2 の入力インピーダンス・BNC アダプタの帯域と W1 の出力インピーダンスは Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)。
参考: [同軸ケーブル (Wikipedia)](https://ja.wikipedia.org/wiki/%E5%90%8C%E8%BB%B8%E3%82%B1%E3%83%BC%E3%83%96%E3%83%AB)
