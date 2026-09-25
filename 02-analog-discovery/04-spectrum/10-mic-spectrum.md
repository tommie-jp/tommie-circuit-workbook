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
  VCC: vcc a1
  R1: resistor a1 a3 2.2k
  MK1: mic a3 a5
  G1: ground a5
  C1: capacitor a3 d3 1u
  VCC: vcc d1
  R2: resistor d1 d3 100k
  Q1: npn f5
  VCC: vcc h1
  RC: resistor h1 h3 470
  G2: ground f8
  C2: capacitor h3 j3 1u
  M1: voltmeter j3 l3 l=$\mathrm{CH1}$
  G3: ground l3
wires:
  - d3 |- Q1.B
  - Q1.C -| h3
  - Q1.E -| f8
```

- MK1・R1・C1・R2・Q1 は回路の教科書 8-4 と同じマイクバイアス+1 石増幅
  (エミッタ接地)。RC (470 Ω) が Q1 のコレクタ負荷 (8-4 の LED の代わり)
- C2 (1 µF) は直流を止め、交流 (音の振動ぶん) だけを CH1 へ渡す**交流結合**。
  CH1 の `1-` は GND、`1+` は C2 の先 — AD の入力 (1 MΩ、established) がそのまま
  直流の基準を作るので、追加の抵抗は要らない

## 実体配線図

```breadboard
title: 図2 ブレッドボードでマイクアンプを組み AD で読む
board: full
parts:
  R1: resistor a3 a6 2.2k
  MK1: mic a9 a12
  C1: capacitor a16 a19 1u
  R2: resistor a23 a26 100k
  Q1: transistor e29(B) e30(C) e31(E) 2SC1815
  RC: resistor a34 a37 470
  C2: capacitor a40 a43 1u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1+, 1-]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t2 black
  - +t3 -- b3 red
  - b6 -- b9
  - -t12 -- b12 black
  - b9 -- b16
  - b19 -- b26
  - +t23 -- b23 red
  - b26 -- d29
  - +t34 -- b34 red
  - d30 -- c37
  - c37 -- c40
  - AD.1+ -- b43 yellow
  - AD.1- -- -t44 black
  - -t31 -- d31 black
```

8-4 の配線から LED を外し、コレクタ負荷 (RC) の先を C2 経由で AD の `1+` へ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Scope | CH1: **AC 結合**、Range 50 mV/div 程度 (音は小さいので絞る、2-4 と同じ考え方) |
| Spectrum | Source: Channel 1。Start 0 Hz、Stop 5 kHz (声の基本周波数と主な倍音が入る範囲)。Window: Hann (声のような変化する信号には Flat-top より Hann、4-3) |

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
- C1 (1 µF) と R2 (100 kΩ) が作る結合の高域通過の折れ点は 1/(2π×1µF×100kΩ)
  ≈ 1.6 Hz と可聴域よりずっと低いので、声の帯域には影響しない

## 出典

自作。マイクアンプの段は回路の教科書 8-4 (マイクで音に反応) と同じ。
