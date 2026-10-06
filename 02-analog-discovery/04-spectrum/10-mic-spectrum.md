---
book: analog-discovery
chapter: 4
id: 4-10
title: マイクの音のスペクトル
tier: 100
source: 自作
board: BB
---

# 4-10 マイクの音のスペクトル

回路の教科書 8-4 (マイクで音に反応) と同じマイクアンプの段を使い、LED の
代わりに CH1 へ交流結合して、声や手拍子のスペクトルを Spectrum で見る。
周期信号だった 3-1〜4-9 と違い、ここで扱うのは**その場その場で変わる音**。
FFT の読み方そのものは同じでも、平均化 (4-5) が使えないなど勝手が違う所がある。

## 回路図

```circuit
title: 図1 マイクアンプの出力を交流結合で CH1 へ
parts:
  VCC: vcc a1 5V
  R1: resistor a1 a3 2.2k
  MK1: mic a3 a5
  G1: ground a5
  C1: capacitor a3 d3 1u
  VCC: vcc d1 5V
  R2: resistor d1 d3 100k
  Q1: npn f5
  VCC: vcc c7 5V
  RC: resistor c7 e7 470
  G2: ground h5
  C2: capacitor e7 e9 1u
  M1: voltmeter e9 h9 l=$\mathrm{CH1}$
  G3: ground h9
wires:
  - d3 |- Q1.B
  - Q1.C |- e7
  - Q1.E |- h5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/10-mic-spectrum.svg)

- MK1・R1・C1・R2・Q1 は回路の教科書 8-4 と同じマイクバイアス+1 石増幅
  (エミッタ接地)。RC (470 Ω) が Q1 のコレクタ負荷 (8-4 の LED の代わり)
- C2 (1 µF) は直流を止め、交流 (音の振動ぶん) だけを CH1 へ渡す**交流結合**。
  CH1 の `1-` は GND、`1+` は C2 の先 — AD3 の入力 (1 MΩ ∥ 24 pF) がそのまま
  直流の基準を作るので、追加の抵抗は要らない

## 想定するマイク

MK1 は 2 ピンのエレクトレットコンデンサマイク (ECM、中に FET の入った
ドレイン出力の型) を想定する。φ6〜10 mm のよく売られている品の、代表的な
仕様で計算している。

| 項目 | 想定する値 | この節での使い方 |
| --- | --- | --- |
| 形 | 2 端子 (出力と GND)、内蔵 FET のドレイン出力 | 電源から R1 で電流を流し、R1 との中点から音の信号を取り出す |
| 感度 | −44 dB (0 dB = 1 V/Pa)、つまり約 6.3 mV/Pa | 出力の大きさの見積もり |
| 動作電圧 | 1.5〜10 V (標準 2〜3 V) | 5 V から R1 を通すと、マイクの両端には 2〜3 V ほどが残る |
| 消費電流 | 0.5 mA 以下 (代表 0.3 mA ほど) | R1 = 2.2 kΩ の電圧降下は 0.3 mA × 2.2 kΩ ≈ 0.7 V |
| 出力インピーダンス | 2.2 kΩ ほど (負荷抵抗 R1 で決まる) | 推奨の負荷 2.2 kΩ を R1 にした |
| 周波数範囲 | 20 Hz〜16 kHz ほど | 声 (〜5 kHz) は平らな所に収まる |

出力の見積もり: 30 cm ほど離れた普通の話し声は 60 dB SPL (約 0.02 Pa) なので、
マイクの出力は 6.3 mV/Pa × 0.02 Pa ≈ 0.13 mV (R1 だけを負荷にしたとき)。
C1 の先には Q1 の入力抵抗 h<sub>ie</sub> ≈ h<sub>FE</sub> × 26 mV ÷ 4.3 mA ≈ 0.6 kΩ が
R1 と並列に付くので、ベースに届くのは 0.13 mV × 0.6 kΩ ÷ (2.2 kΩ + 0.6 kΩ) ≈ 0.03 mV。
Q1 の電圧利得は g<sub>m</sub> × RC = (4.3 mA ÷ 26 mV) × 470 Ω ≈ 78 倍なので、CH1 には
2 mV (peak) ほどが来る。図3 の基本周波数の山 (約 −57 dBV) はこの見積もり (計算値)。
実物のデータシートがあれば、感度と推奨の負荷抵抗をそちらの値に置き換える。

## 実体配線図

```breadboard
title: 図2 ブレッドボードでマイクアンプを組み AD で読む
board: half
parts:
  R1: resistor b2 b5 2.2k
  MK1: mic e5 e8
  C1: capacitor c5 c10 1u
  R2: resistor +t10 b10 100k
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RC: resistor +t16 b16 470
  C2: capacitor d16 d21 1u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t12 black
  - a2 -- +t2 red
  - a8 -- -t8 black
  - a14 -- -t14 black
  - c12 -- c16 green
  - AD.1+ -- b21 yellow
  - AD.1- -- -t23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/10-mic-spectrum.svg)

8-4 の回路から LED を外し、コレクタ負荷 (RC) の先を C2 経由で AD の `1+` へ。
ブレッドボードの上では 1 枚の上半分 (`a`〜`e` 行) に収めた: R2 と RC は + レールから直に
挿し、Q1 はピンを 1 穴ずつ広げて B・C・E を 10・12・14 列に置く。C (12 列) と
RC (16 列) は緑のジャンパでつなぐ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Scope | CH1: DC 結合のまま (C2 が直流を切るので、CH1 に直流は乗らない)、Range 5 mV/div 程度 (音は数 mV と小さいので絞る、2-4 と同じ考え方) |
| Spectrum | Source: Channel 1。Start 0 Hz、Stop 5 kHz (声の基本周波数と主な倍音が入る範囲)。Window: Hann (声のような変化する信号には Flat-top より Hann、4-3) |

## スペクトルの例

```spectrum
title: 図3 「あー」の声は基本周波数とその整数倍に山が並ぶ (理想の例)
device: ad3
sweep: 0-2kHz
samples: 8192
window: hann
ref: -40dBV
signal:
  - sine 150Hz 2mV
  - sine 300Hz 1.4mV
  - sine 450Hz 0.8mV
  - sine 600Hz 1mV
  - sine 750Hz 0.4mV
  - sine 900Hz 0.3mV
  - sine 1200Hz 0.2mV
markers: [150Hz, 300Hz, 450Hz, 600Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/10-mic-spectrum.svg)

- 基本周波数 150 Hz (男性の声のおおよその高さ) の声を、倍音の高さを
  適当に決めて足し合わせた**理想の例**。実際の声では山の高さの並びが人と
  母音ごとに変わり、山の裾も少し広がる
- 倍音の高さは 1/n にきれいには下がらない (4 次 600 Hz が 3 次より高い)。
  これが声色の違いになる
- 図は山が見やすいよう 0〜2 kHz に絞った。実測では Stop を 5 kHz にして、
  もっと高い倍音と子音の広がりも見る

## 見るべき値

計算値 (バイアス点、8-4 と同じ h<sub>FE</sub> = 100 の仮定) と、測定で確かめる値。

| 測る所 | 期待する値 (計算値) | 分かること |
| --- | --- | --- |
| Q1 のベース電流 | 約 43 µA (= (5 − 0.7) / 100 kΩ) | 8-4 と同じ R2 |
| Q1 のコレクタ電流 (無音時) | 約 4.3 mA | |
| Q1 の C-E 間電圧 (無音時) | 約 2.98 V (= 5 − 4.3 mA × 470 Ω) | RC = 470 Ω を選んだのは、この電圧を電源の半分近くにして振幅の余地を持たせるため |
| 声 (母音を伸ばした声) のスペクトル | 100〜300 Hz あたりに基本周波数の山、その整数倍に倍音の列 | 人の声の基本周波数のおおよその範囲 (実測) |
| 手を叩いた音のスペクトル | 特定の山ではなく、広い周波数に薄く広がる | インパルスに近い音は特定の周波数を持たない (実測) |

分かること:

- **4-5 の平均化 (Average) はここでは使わない。** Average は「毎回同じ位相で
  くり返す周期信号」が前提で、声や手拍子はそのたびに波形が変わるので、
  平均するとむしろ信号そのものが消えてしまう
- 声のような周期的な音は基本周波数とその整数倍 (倍音) の列として FFT に現れ、
  4-2 の方形波の高調波と見た目は似ているが、**倍音の高さの並び方は毎回同じでは
  ない** (方形波のように 1/n できれいには下がらない) — 声色の違いはこの倍音の
  高さの分布の違い
- C1 (1 µF) から見た抵抗は、R1 (2.2 kΩ) と Q1 の入力 (h<sub>ie</sub> ≈ 0.6 kΩ。
  R2 の 100 kΩ は並列でほとんど効かない) の和で約 2.8 kΩ。結合の高域通過の折れ点は
  1/(2π × 1 µF × 2.8 kΩ) ≈ 57 Hz (計算値) で、声の基本周波数 (100〜300 Hz) より
  低いので、声の帯域への影響は小さい

## 出典

自作。マイクアンプの段は回路の教科書 8-4 (マイクで音に反応) と同じ。
