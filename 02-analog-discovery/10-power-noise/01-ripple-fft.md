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
  V1: sine a5 e5 12.7
  D1: diode a5 a9 1N4007
  D2: diode e5 a9 1N4007
  D3: diode e12 a5 1N4007
  D4: diode e12 e5 1N4007
  Csmooth: capacitor a9 e12 470u
  Rload: resistor h9 h12 1k
  AD:
    type: device
    at: k1
    label: Analog Discovery
    pins: [GND, 1+, 1-]
wires:
  - a9 -- h9
  - e12 -- h12
  - AD.1+ -| h9
  - AD.1- -| h12
  - AD.GND -| h12
```

- V1 は AC アダプタの二次側 (9 V<sub>rms</sub> ≒ 振幅 12.7 V、商用周波数を仮に
  60 Hz とする。50 Hz 地域では読み替える)
- D1〜D4 がブリッジ。AC のどちらの極性でも、DC+ (a9/e12 の上) には順方向、
  DC− には逆向きに電流が流れる
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
  D1: diode/do41 c5(A) c12(K)
  D2: diode/do41 d8(A) d12(K)
  D3: diode/do41 e3(A) e5(K)
  D4: diode/do41 b3(A) b8(K)
  Rload: resistor f3 f12 1k
  Csmooth: capacitor/electrolytic i12(+) i3(-) 470uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1+, 1-]
wires:
  - ADP.~1 -- a5
  - ADP.~2 -- a8
  - d3 -- f3
  - e12 -- f12
  - AD.1+ -- g12
  - AD.1- -- g3
  - AD.GND -- h3
```

- D1・D2 の向いた先 (12 列) が DC+、D3・D4 の元 (3 列) が DC−。4 つのダイオード
  それぞれ**アノード側の帯の無い方**を図の向きに挿す
- Rload・Csmooth は下ブロックへ渡し、AD で両端を読む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Spectrum | Range 0〜1 kHz、窓 Hann、平均 8 回、CH1 = Rload の両端 (直結でよい。FFT は交流成分だけを示す) |

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
