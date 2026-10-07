---
book: analog-discovery
chapter: 10
id: 10-1
title: リップルを FFT で
tier: 50
source: 自作 (計器の操作は Digilent の Using the Spectrum Analyzer)
board: BB
---

# 10-1 リップルを FFT で

**商用電源には直につながない。** 9 V の AC アダプタ (トランスで絶縁された
低電圧の交流出力) をダイオードブリッジで整流し、平滑コンデンサと負荷抵抗を
つないだ直流電源のリップルを、AD の **Spectrum** (FFT) で見る。AD は測るだけ
で、この回路に電力を供給しない。

## 回路図

```circuit
title: 図1 ブリッジ整流と平滑
parts:
  V1: sine 5,1 5,5 12.7
  D1: diode 5,1 9,1 1N4007
  D2: diode 5,5 9,1 1N4007
  D3: diode 12,5 5,1 1N4007
  D4: diode 12,5 5,5 1N4007
  Csmooth: capacitor 9,1 12,5 470u
  Rload: resistor 9,8 12,8 1k
  AD:
    type: device
    at: 1,11
    label: Analog Discovery
    pins: [GND, 1+, 1-]
wires:
  - 9,1 -- 9,8
  - 12,5 -- 12,8
  - AD.1+ -| 9,8
  - AD.1- -| 12,8
  - AD.GND -| 12,8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/01-ripple-fft.svg)

- V1 は AC アダプタの二次側 (9 V<sub>rms</sub> ≒ 振幅 12.7 V、商用周波数を仮に
  60 Hz とする。50 Hz 地域では読み替える)
- **電源は 5 V ではなく 9 V の AC アダプタ** — 整流と平滑のリップルを見る題なので、
  交流の電源が要る (この本の既定の 5 V は直流で、代わりにならない)
- D1〜D4 がブリッジ。AC のどちらの極性でも、電流は DC+ (a9) から負荷へ流れ出し、
  DC− (e12) へ戻る
- Csmooth (470 µF) と Rload (1 kΩ) が平滑・負荷。AD は Rload の両端を見るだけ

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  ADP:
    type: device
    at: top
    label: AC アダプタ 9V
    pins: ["~1", "~2"]
  D1: diode/do41 c6(A) c10(K)
  D2: diode/do41 d14(A) d10(K)
  D3: diode/do41 b3(A) b6(K)
  D4: diode/do41 b17(A) b14(K)
  Rload: resistor i10 i6 1k
  Csmooth: capacitor/electrolytic g10(+) g14(-) 470uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, 1-]
wires:
  - ADP.~1 -- a6 orange
  - ADP.~2 -- a14 yellow
  - a3 -- -t3 black
  - a17 -- -t17 black
  - e10 -- f10 red
  - j14 -- -b14 black
  - j6 -- -b6 black
  - -t16 -- -b16 black
  - a10 -- +t10 red
  - AD.GND -- -t19 black
  - AD.1+ -- +t22 red
  - AD.1- -- -t23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/01-ripple-fft.svg)

- D1・D2 の向いた先 (10 列) が DC+、D3・D4 の元 (3 列・17 列) を上の − レールへ
  落として DC− にする。4 つのダイオードそれぞれ**アノード側の帯の無い方**を図の向きに挿す
- DC+ は `a10 -- +t10` で上の + レールへも出し、AD の 1+ はそのレールで読む。
  1−・GND は上の − レールへ
- Rload・Csmooth は溝越し (`e10 -- f10`) に下ブロックへ渡し、− 側を下の − レールへ
  落とす (上下の − レールは 16 列で渡す)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Spectrum | Range 0〜1 kHz、窓 Hann、平均 8 回、CH1 = Rload の両端 (直結でよい。FFT は交流成分だけを示す) |

リップルを「200 mV<sub>pp</sub>・120 Hz の鋸歯状波」と見なして描いた画面 (直流の 11 V は
0 Hz の線になるので省いた。平均の回数は描けない)。鋸歯状波の n 次は基本波の 1/n。

```spectrum
title: 図3 リップルの線が 120 Hz とその整数倍に並ぶ (鋸歯状波の模型)
device: ad3
sweep: 0-1kHz
window: hann
samples: 8192
ref: -20dBV
signal: sawtooth 120Hz 200mVpp
markers: [120Hz, 240Hz, 360Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/spectrum/01-ripple-fft.svg)

Scope の時間波形でも見ると、リップルの形が分かる。ただし約 11 V の直流に乗った 0.2 V の揺れなので、
AD3 本体のピン (2×15 のヘッダー) では拡大できない。本体の入力は DC 結合だけで、直流を打ち消す Offset も
0.5 V/div 以下の細かい目盛では ±2.5 V までしか動かせないからだ。時間波形を見るときは AD3 に **BNC アダプタ** を付け、
CH1 のジャンパを AC にする (AC 結合。約 1.6 Hz より低い成分を切る)。BNC ケーブル (先がクリップのもの) の芯を
上の + レール、外皮を上の − レールに当てる。FFT は直流を 0 Hz の線に分けるので、Spectrum はヘッダーのまま (DC 結合) でよい。

```scope
title: 図4 Rload の電圧の交流分 — 120 Hz で約 0.2 V の鋸歯状のリップル (AC 結合、計算)
time: 5ms/div
trigger: ch1 rising 0V
ch1: {wave: sine 60Hz 12.7V | abs | offset -1.4V | clip 0V | peak 470ms | offset -11.2V, range: 50mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/01-ripple-fft.svg)

図4 は整流後の電圧の 11 V ほどの直流を、BNC アダプタの AC 結合で除いた画面。山ごとにコンデンサが充電され、次の山までの間に負荷へ放電して
電圧が下がる。この下がり幅がリップルで、FFT の 120 Hz の線と同じ現象を時間で見たもの。

## 見るべき値

計算値。二次側 9 V<sub>rms</sub>、ブリッジの順方向電圧を 2 段ぶん (1.4 V) と仮定、
Csmooth = 470 µF、Rload = 1 kΩ、リップル周波数 = 商用周波数の 2 倍 (全波整流)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 整流後のピーク電圧 | 9√2 − 1.4 ≒ 11.3 V | ダイオード 2 段ぶんの落ち |
| 平均負荷電流 | 約 11.3 mA (11.3 V / 1 kΩ) | Csmooth を充放電させる電流 |
| リップル電圧 (peak-to-peak) ≒ I / (f<sub>ripple</sub>・C) | 約 200 mV | f<sub>ripple</sub> = 120 Hz (60 Hz 地域) |
| FFT のピーク周波数 | **120 Hz** とその高調波 (240 Hz、360 Hz…) | 全波整流は商用周波数の 2 倍が基本波 |

**50 Hz 地域ではリップルの基本波は 100 Hz になる。** Csmooth を大きくする
(例: 1000 µF) と、リップルは反比例して約 1/2 に減る。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Spectrum Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-spectrum-analyzer)。
