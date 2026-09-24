---
book: analog-discovery
chapter: 3
id: 3-2
title: 周波数掃引 (Sweep) をオシロで追う
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-2 周波数掃引 (Sweep) をオシロで追う

Wavegen の **Sweep** 機能は、W1 の周波数を時間とともに自動で変える (チャープ)。
RC ローパスに通して Scope で眺めると、周波数が上がるにつれて出力の振幅が
小さくなっていく様子が**時間軸のまま**見える。第 5 章のネットワークアナライザが
自動でやることを、まず手動で追いかける実験。

## 回路図

```circuit
title: 図1 RC ローパス (Sweep で追う)
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 1k
  C1: capacitor a7 c7 100n
  M2: voltmeter a9 c9 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c7 -- c9
  - a7 -- a9
```

- R1 (1 kΩ) と C1 (100 nF) で **f<sub>c</sub> = 1 / (2πRC) ≈ 1.59 kHz**
- CH1 が入力 (W1 そのもの)、CH2 が C1 の両端 (出力)。掃引の間、CH2 の振幅が
  f<sub>c</sub> を境に小さくなっていく

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor c15 c20 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - a10 -- a15 green
  - AD.2+ -- b15 blue [h10]
  - AD.2- -- -t18 black
  - a20 -- -t20 black
```

- 5 列が入力 (W1 と CH1)、10 列と 15 列を緑のジャンパでつなぎ R1 と C1 を直列にする、
  20 列が C1 の GND 側。CH2 (2+) は 15 列 (C1 の上側 = 出力) に挿す
- CH1・CH2 の − 側 (1−・2−) と AD の GND は同じ青いレールにまとめる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、Amplitude 1 V、Offset 0 V。Sweep: Start 100 Hz、Stop 20 kHz、Time 1 s、Type **Log**、Repeat: Run を 1 回 |
| Scope | Time/div 100 ms/div (10 div で 1 s、掃引 1 回ぶんが画面に収まる)。CH1・CH2 とも Range 500 mV/div。Trigger: Wavegen の Sync 出力 (掃引の開始に同期) |

## 見るべき値

計算値。ゲイン (dB) = 20 log₁₀ (CH2 の振幅 ÷ CH1 の振幅)。Log 掃引なので、
時刻 t での周波数は f(t) = 100 Hz × (20 kHz / 100 Hz)^(t / 1 s)。

| 時刻 | 周波数 | ゲイン | CH2 の Vpp (CH1 は 2 V 一定) |
| --- | --- | --- | --- |
| 0 s (掃引の頭) | 100 Hz | −0.02 dB (ほぼ 0) | 2.00 V (減衰なし) |
| 0.52 s (掃引の中ほど) | 1.59 kHz (f<sub>c</sub>) | −3.01 dB | 1.41 V (√2 分の 1、折れ点) |
| 1 s (掃引の末尾) | 20 kHz | −22.0 dB | 0.16 V (ほとんど見えない) |

分かること:

- **掃引の前半 (低い周波数) は CH2 がほぼ CH1 と重なる**。f<sub>c</sub> の少し手前から
  差が付き始め、f<sub>c</sub> を過ぎると急に小さくなる — Log 掃引なら折れ点が
  ちょうど時間軸の真ん中あたりに来るように Start・Stop を選んだ (幾何平均
  √(100 Hz × 20 kHz) ≈ 1.41 kHz が f<sub>c</sub> に近い)
- Time/div を掃引の Time (1 s) に合わせておくと、画面いっぱいに 1 回の掃引が
  収まる。合っていないと波形が途中で切れたり、何回も重なって見づらくなる
- 同じ RC を Log ではなく Linear 掃引にすると、低い周波数の変化がほんの一瞬で
  終わり、折れ点の様子が見えにくくなる (掃引時間のほとんどが高い周波数側に
  使われるため)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
