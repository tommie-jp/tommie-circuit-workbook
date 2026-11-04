---
book: circuits
chapter: 4
id: 4-16
title: ハイパス・バンドパス
tier: 200
source: 自作
---

# 4-16 ハイパス・バンドパス

4-10 のサレンキーのローパスは、**抵抗とコンデンサを入れ替えるとハイパス**になる。低い周波数を −40 dB/decade で切り、
高い周波数を通す 2 次のハイパスで、マイクの風の音や電源のうなり (50 Hz / 60 Hz) を落とすのに使う。
ハイパスの後ろにローパスをつなぐと、その間の帯域だけを通す**バンドパス**になる。

この題では、遮断周波数 約 300 Hz のハイパスと 約 3 kHz のローパスを LM358 の 2 回路で縦につなぎ、
電話の音声の帯域 (300 Hz〜3.4 kHz) に近い通過域を作る。1 kHz は素通りし、100 Hz と 10 kHz は約 1/10 に落ちることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 サレンキーのハイパス (U1) とローパス (U2) を縦につなぐ
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 3,9.5
  W1: sine 2,4 2,6 1 l=$\mathrm{W1}$
  GW: ground 2,6
  C1: capacitor 3,4 5,4 47n
  C2: capacitor 5,4 7,4 47n
  R2: resistor 7,4 7,6 16k
  GR2: ground 7,6
  R1: resistor 5,2 11,2 8.2k
  U1: opamp 9,4.38 +up
  R3: resistor 12,4.38 14,4.38 16k
  R4: resistor 14,4.38 16,4.38 16k
  C4: capacitor 16,4.38 16,6.4 2.2n
  GC4: ground 16,6.4
  C3: capacitor 14,2.6 21,2.6 4.7n
  U2: opamp 19,4.76 +up
  OUT: port 23,4.76 out
points:
  vp: 2,8
  vm: 2,11
  mid: 2,9.5
wires:
  - mid -- 3,9.5
  - 2,4 -- 3,4
  - 7,4 -| U1.+
  - 5,4 -- 5,2
  - 11,2 -- 11,4.38
  - U1.out -- 11,4.38 -- 12,4.38
  - 8,5.6 |- U1.-
  - 8,5.6 -- 11,5.6 -- 11,4.38
  - 14,4.38 -- 14,2.6
  - 16,4.38 -| U2.+
  - 21,2.6 -- 21,4.76
  - U2.out -- 21,4.76 -- 23,4.76
  - 18,6 |- U2.-
  - 18,6 -- 21,6 -- 21,4.76
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/16-highpass-bandpass.svg)

- 左下の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- **U1 はハイパス**。4-10 のローパスの R と C を入れ替えた形で、入力から C1・C2 (47 nF) を直列に通り、R2 (16 kΩ) で GND へ、
  C1 と C2 の間の節点から R1 (8.2 kΩ) で出力へ帰還する。R2 を R1 の約 2 倍にすると通過域が平らなバターワース (Q ≈ 0.7) になる。
  **f<sub>L</sub> = 1 / (2π × 47 nF × √(8.2 kΩ × 16 kΩ)) ≈ 296 Hz**
- **U2 はローパス**。4-10 と同じ形で、R3 = R4 = 16 kΩ、C3 (帰還) = 4.7 nF、C4 (GND へ) = 2.2 nF。C3 を C4 の約 2 倍にしてバターワースに近づける
  (4-10 の 20 nF・10 nF と同じ比。4.7 nF と 2.2 nF は E12 の値)。**f<sub>H</sub> = 1 / (2π × 16 kΩ × √(4.7 nF × 2.2 nF)) ≈ 3.09 kHz**
- U1 と U2 はどちらもフォロアの出力で、次の段を低いインピーダンスで駆動する。だから 2 段をつないでも互いの特性を崩さない (4-10 の終わりの話)
- 通過域の中心は 2 つの遮断周波数の相乗平均 √(296 × 3090) ≈ 960 Hz で、利得は 1 倍 (0 dB)。両側とも −40 dB/decade で落ちる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (上がハイパス、下がローパス)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies 5V・W1・Scope 1)
    pins: [V+, GND, W1, 1+, 1-]
  SC:
    type: device
    at: bottom
    label: AD3 (Supplies −5V・Scope 2)
    pins: [2+, V-, 2-]
  U1: dip8 @ e14 LM358
  C1: capacitor b26 b22 47n
  C2: capacitor c22 c17 47n cap=above:1,0
  R2: resistor a17 -t17 16k
  R1: resistor d22 d15 8.2k cap=right
  R3: resistor g18 g23 16k cap=right
  R4: resistor h23 h16 16k cap=right
  C3: capacitor i23 i14 4.7n
  C4: capacitor j16 -b16 2.2n
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.W1 -- a26 yellow
  - AD3.1+ -- a27 yellow
  - c26 -- c27 yellow
  - AD3.1- -- -t29 black
  - -t1 -- -b1 black
  - a14 -- +t14 red
  - c15 -- c16 white
  - b15 -- b18 orange
  - e18 -- f18 orange
  - g14 -- g15 white
  - SC.V- -- j17 blue
  - SC.2+ -- j14 green
  - SC.2- -- -b28 black
notes:
  - text below: 赤レール = +5V、青レール = GND (上下とも)。−5V は AD3 の V− から PIN 4 へ直に入れる
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/16-highpass-bandpass.svg)

- 上下の青レールはどちらも GND (1 列の黒で渡す)。+5 V は上の赤レールだけ。**−5 V はレールに置かず、AD3 の V− (青) から PIN 4 (17 列) へ直に入れる**。
  2 段とも GND に落とす部品 (R2 と C4) があるので、GND を上下のレールに置いた。電流は数 mA で、各レール約 50 mA の範囲に収まる
- LM358 は 14 列〜17 列。**上ブロック側の回路 (PIN 5〜7) が U1 (ハイパス)、下ブロック側 (PIN 1〜3) が U2 (ローパス)**。PIN 8 (14 列) は `a14 → +t14` で +5 V
- **ハイパス (上)**: W1 (黄) は 26 列。C1 (b 段) で 22 列 (C1 と C2 の間の節点) へ、C2 (c 段) で + 入力 (PIN 5、17 列) へ。R2 は 17 列から上の青レール (GND) へ、
  R1 (d 段) は 22 列と出力 (PIN 7、15 列) の間。白 `c15 → c16` で出力を − 入力 (PIN 6) に戻す (フォロア)
- **2 段の間**: ハイパスの出力 (15 列) を橙 `b15 → b18` で 18 列へ出し、`e18 → f18` で下ブロックへ下ろす
- **ローパス (下)**: R3 (g 段) で 18 列から 23 列 (R3 と R4 の間の節点) へ、R4 (h 段) で + 入力 (PIN 3、16 列) へ。C4 は 16 列から下の青レール (GND) へ、
  C3 (i 段) は 23 列と出力 (PIN 1、14 列) の間。白 `g14 → g15` で出力を − 入力 (PIN 2) に戻す
- Scope の 1+ は 27 列に挿し、黄の短い線 `c26 → c27` で W1 を見る。2+ (緑) は出力の 14 列 (`j14`)。2− は下の青レール (GND) へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。100 Hz〜10 kHz の正弦波の振幅と位相を読む題で、10 MHz よりずっと低いから
(周波数ごとの利得の曲線は、同じ配線のまま Network で描く。4-10 と同じ)。下の図は W1 を 100 Hz にしたときで、ハイパスが効いている所を見る。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、100 Hz (1 kHz・10 kHz にも変える)、振幅 1 V、オフセット 0 V |
| Scope CH1 (入力、27 列) | DC、500 mV/div |
| Scope CH2 (出力、14 列) | DC、50 mV/div |
| Time | 2 ms/div (100 Hz が 2 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 100 Hz を入れる — 出力 (CH2) は 0.11 倍に落ち、位相が 149° 進む
time: 2ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 100Hz 1V, range: 500mV/div}
ch2: {wave: sine 100Hz 0.113V phase 149deg, range: 50mV/div}
cursors: [-1.64ms, 2.5ms]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/16-highpass-bandpass.svg)

図3 の CH1 は 2 Vpp (4 目盛)、CH2 は 0.23 Vpp (約 4.5 目盛)。尺度が 10 倍違うので、同じくらいの高さに見えて振幅は約 1/9 になっている。
カーソル X2 (2.5 ms) は CH1 の山、X1 (−1.64 ms) は CH2 の山。CH2 の山は CH1 の山より 149° (4.14 ms) 早く来る。2 次のハイパスは低い周波数で
位相が最大 180° 進み、遮断周波数で 90° 進む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1, U2 | オペアンプ (1 個の LM358 の 2 回路) | LM358 |
| C1, C2 | フィルムコンデンサ (ハイパス) | 各 47 nF |
| R1 | 抵抗 (ハイパスの帰還) | 8.2 kΩ |
| R2 | 抵抗 (ハイパスの GND 側。R1 の約 2 倍) | 16 kΩ |
| R3, R4 | 抵抗 (ローパス) | 各 16 kΩ |
| C3 | セラミックコンデンサ (ローパスの帰還。C4 の約 2 倍) | 4.7 nF |
| C4 | セラミックコンデンサ (ローパスの GND 側) | 2.2 nF |
| — | 信号源 | 振幅 1 V の正弦波、周波数を変える |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (入力と出力)。Network でも測れる |

## 見るべき値

W1 の周波数を変えながら出力の振幅を読むか、Network で 10 Hz〜100 kHz を掃引する。表の値は計算値 (LTspice の読みと同じ)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 kHz の利得 | 約 1.0 倍 (0 dB) | 通過域の真ん中は素通り |
| 低い側の −3 dB の周波数 | 約 300 Hz | ハイパスの f<sub>L</sub> (296 Hz) |
| 高い側の −3 dB の周波数 | 約 3.2 kHz | ローパスの f<sub>H</sub> (3.09 kHz) に、ハイパスの影響が少し重なる |
| 100 Hz の利得と位相 | 0.11 倍 (−19 dB)、149° 進む | f<sub>L</sub> の 1/3。2 次なので約 (1/3)² ≈ 1/9 |
| 30 Hz の利得 | 0.010 倍 (−40 dB) | f<sub>L</sub> の 1/10 で 1/100。−40 dB/decade |
| 10 kHz の利得 | 0.095 倍 (−20 dB) | f<sub>H</sub> の約 3 倍。ローパスの側も 2 次 |

狭い帯域 (Q が 5 や 10) を 1 か所だけ通したいときは、ハイパスとローパスを並べるより、
1 個の OP アンプで組む多重帰還 (MFB) のバンドパスが部品が少ない。ここでは 2 つの遮断周波数を別々に決められる縦つなぎを使った。

## LTspice での確かめ

`sim/16-highpass-bandpass.cir` で図1 の周波数応答 (AC 解析、10 Hz〜100 kHz) を読んだ。
オペアンプは 1 極の簡易模型 (GBW 1 MHz。LM358 相当の**仮定**で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 kHz の利得 | 約 1.0 倍 | 0.995 倍 (最大 0.996 倍。山なし) | 合う |
| 低い側の −3 dB | 約 300 Hz | 299 Hz | 合う |
| 高い側の −3 dB | 約 3.2 kHz | 3.19 kHz | 合う |
| ハイパスだけの 296 Hz の利得 | 0.707 倍 | 0.699 倍 | 合う |
| 100 Hz の利得と位相 | 0.11 倍、149° | 0.113 倍、148.8° | 合う |
| 30 Hz の利得 | 0.010 倍 | 0.0103 倍 | 合う |
| 10 kHz の利得 | 0.095 倍 | 0.0954 倍 | 合う |

## 出典

自作。
参考: [Sallen–Key topology (Wikipedia)](https://en.wikipedia.org/wiki/Sallen%E2%80%93Key_topology)、[Band-pass filter (Wikipedia)](https://en.wikipedia.org/wiki/Band-pass_filter)、[TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)
