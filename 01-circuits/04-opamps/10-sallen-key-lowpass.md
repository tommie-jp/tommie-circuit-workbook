---
book: circuits
chapter: 4
id: 4-10
title: アクティブ ローパス (サレンキー)
tier: 100
board: BB
source: 自作
---

# 4-10 アクティブ ローパス (サレンキー)

1-5 の RC ローパスは 1 段で −20 dB/decade (10 倍の周波数で 1/10) までしか
落ちない。抵抗とコンデンサを 2 段にして OP アンプでバッファする (4-1 のフォロアで受ける) と、
−40 dB/decade (10 倍の周波数で 1/100) まで急に落ちるローパスが組める。傾きが 1 次 (RC 1 段) の
2 倍なので 2 次ローパスと呼ぶ。利得 1 倍 (フォロア) の帰還だけで組める**サレンキー型**が
いちばん部品が少ない。この題では周波数を変えながら出力の振幅を測り、遮断周波数と傾きを確かめる。

## 回路図

```circuit
title: 図1 サレンキー ローパス (利得 1 倍)
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 2,3
  V1: sine 3,3 3,5 0.1
  G2: ground 3,5
  R1: resistor 3,3 5,3 10k
  R2: resistor 5,3 7,3 10k
  C1: capacitor 5,3 5,1 20n
  C2: capacitor 7,3 7,5 10n
  G3: ground 7,5
  U1: opamp 9,3.21 +up
  OUT: port 12,3.21
points:
  vp: 1,1
  vm: 1,5
  mid: 1,3
wires:
  - mid -- 2,3
  - 7,3 -| U1.+
  - 8,4 |- U1.-
  - 8,4 -- 10,4 -- 10,3.21
  - 5,1 -- 11,1 -- 11,3.21
  - U1.out -- 10,3.21 -- 11,3.21 -- 12,3.21
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/10-sallen-key-lowpass.svg)

- 左の VP・VN は OP アンプの ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- 図1 で、**R1・R2 が直列 (c3→c5→c7)、C2 が後段の R2 の先で GND へ**、
  そして **C1 が前段の節点 (c5) から出力へ帰還**するのがサレンキーの骨格。
  出力 (交流的に低インピーダンス) から C1 を通して戻る正帰還が、
  ふつうの RC 2 段より急な特性を作る
- U1 は**利得 1 倍のボルテージフォロア** (出力を − 入力に直結)。
  信号を増幅せず、+ 入力 (R1・R2・C2 でできた 2 次ローパス) を
  低インピーダンスでそのまま出力に伝える役目
- R1=R2=10 kΩ、C1=20 nF、C2=10 nF (**C1 が C2 の 2 倍**) にすると、
  通過域がいちばん平らで、遮断周波数の手前で山を作らないバターワース特性になる。
  Q は遮断周波数の付近の山の鋭さを表す数で、バターワースは Q ≈ 0.71。
  遮断周波数は **f<sub>c</sub> = 1/(2πR√(C1C2)) ≈ 1.13 kHz**

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V (赤) と GND (青)。下の青レールは −5V (V−)。下の赤レールは使わない
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1)
    pins: [V+, GND, V-, W1]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
  U1: dip8 @ e10 LM358
  R1: resistor c22 c26 10k
  R2: resistor j17 j22 10k
  C1: capacitor g22 g28 10n
  C1b: capacitor i22 i28 10n
  C2: capacitor i12 i15 10n
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t2 black
  - AD3.V- -- -b3 blue
  - AD3.W1 -- a26 yellow
  - SC.1+ -- b26 orange
  - SC.2+ -- j28 green
  - SC.1- -- -t29 black
  - SC.2- -- -t30 black
  - g10 -- g11 green
  - h10 -- h28 green
  - g12 -- g17 orange
  - e22 -- f22 orange
  - f15 -- -t15 black
  - +t10 -- a10 red
  - j13 -- -b13 blue
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/10-sallen-key-lowpass.svg)

- 図2 の AD3 は、Supplies (V+・V−) が図1 の VP・VN、W1 が V1 に当たる。電源のレールの分け方は 4-2 と同じ
  (下の青レールは −5V で、GND ではない)。電流は数 mA で、各レール約 50 mA の範囲に収まる
- 出力 (PIN 1、10 列) は `g10 → g11` で − 入力 (PIN 2、11 列) に直結する (フォロア)。出力は `h10 → h28` で右の 28 列へも広げる
- 前段の節点 (図1 の c5) は **22 列**。上ブロックの R1 (10 kΩ、22 列〜26 列) の先で、橙の線 `e22 → f22` で溝をまたいで下ブロックへ下ろす。
  R1 の入力側 (26 列) に W1 (黄) と Scope 1+ (橙) をつなぐ
- R2 (10 kΩ) は 22 列と 17 列の間。17 列は橙の線 `g12 → g17` で + 入力 (PIN 3、12 列) につながる。
  C2 (10 nF) は + 入力の 12 列から 15 列へ渡し、黒の線 `f15 → -t15` で GND へ落とす
- **C1 (20 nF) は 10 nF を 2 本並列** (C1 と C1b) にして、22 列 (前段の節点) と 28 列 (出力) の間に挿す
- Scope の 2+ (緑) は出力の 28 列 (`j28`)。1− と 2− (黒) は上の青レール (GND) へ。PIN 8 (10 列) は `+t10 → a10` で +5V へ、PIN 4 (13 列) は `j13 → -b13` で −5V へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz 付近の正弦波の振幅を読む題で、10 MHz よりずっと低いから
(周波数ごとの利得の曲線を描くなら、同じ配線のまま Network を使う)。
W1 は遮断周波数 f<sub>c</sub> ≈ 1.13 kHz のときの正弦波 (振幅 0.1 V)、Scope は CH1 を入力 (26 列)、CH2 を出力 (28 列) にする。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、1.13 kHz、振幅 0.1 V、オフセット 0 V |
| Scope CH1 (入力、26 列) | DC、50 mV/div |
| Scope CH2 (出力、28 列) | DC、50 mV/div |
| Time | 200 µs/div (1.13 kHz が 2 周期ほど) |
| Trigger | CH1、立ち上がり、0 V |

```scope
title: 図3 遮断周波数 1.13 kHz — 出力 (CH2) は入力 (CH1) の 0.707 倍で、位相が 90° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.13kHz 0.1V, range: 50mV/div}
ch2: {wave: sine 1.13kHz 0.0707V phase -90deg, range: 50mV/div}
cursors: [221us, 442us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/10-sallen-key-lowpass.svg)

図3 は CH1 が 0.2 Vpp (4 目盛)、CH2 が 0.141 Vpp (約 2.8 目盛)。f<sub>c</sub> で振幅が 1/√2 になり、バターワース (Q ≈ 0.71) の 2 次ローパスは位相が 90° 遅れる
(1 周期 885 µs の 1/4 で約 221 µs)。カーソルを入力の山 (X1、221 µs) と出力の山 (X2、442 µs) に置くと、CH1 の 100 mV と CH2 の 70.7 mV (入力の 0.707 倍) が読め、山のずれ 221 µs が位相の 90° に当たる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (ボルテージフォロア) | LM358 |
| R1, R2 | 抵抗 (2 次ローパス、周波数設定) | 各 10 kΩ |
| C1 | セラミックコンデンサ (正帰還、C2 の 2 倍) | 20 nF (10 nF を 2 本並列、ブレッドボードの図では C1 と C1b。20 nF は店に並ばないことが多い) |
| C2 | セラミックコンデンサ (2 次ローパス) | 10 nF |
| — | 信号源 | 振幅 0.1 V、周波数を掃引 |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (入力と出力) |

## 見るべき値

1-5 と同じく、Analog Discovery のネットワークアナライザ (Network) で入力と出力の比を周波数ごとに描くか、
W1 の周波数を変えながらオシロで振幅を読む。表の値は計算値。f<sub>c</sub> = 1/(2πR√(C1C2))、Q = √(C1C2)/(2C2) ≈ 0.71 (バターワース)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 遮断周波数 (f<sub>c</sub>。1-5 で見た) | 約 1.13 kHz | 1/(2π×10kΩ×√(20n×10n)) |
| 遮断周波数での出力振幅 | 約 0.071 V (0.1 V × 0.707) | 2 次フィルタでも遮断点は −3 dB (振幅 1/√2) |
| 遮断周波数の 10 倍 (約 11.3 kHz) での減衰 | 約 −40 dB (振幅は 1/100 の約 0.001 V) | 2 次 (−40 dB/decade)。1-5 の 1 次 RC (−20 dB/decade) の 2 倍の傾き |
| 遮断周波数の 1/10 (約 113 Hz) での出力 | ほぼ 0.1 V (減衰なし) | 通過域はフォロアなので利得 1 倍のまま |

1-5 の RC ローパスを 2 段単純に直列につないだだけでは、後段が前段に
負荷をかけて計算どおりの特性にならない (バッファが要る)。サレンキーは
**正帰還で Q を持ち上げる分、バッファ 1 個で 2 次の急峻さが手に入る**のが利点。

## 出典

自作。
