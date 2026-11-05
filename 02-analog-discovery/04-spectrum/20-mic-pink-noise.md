---
book: analog-discovery
chapter: 4
id: 4-20
title: マイクの周波数特性 (ピンクノイズ)
tier: 200
source: 自作 (マイクアンプは 4-10、スピーカーの鳴らし方は 3-9 と同じ)
board: BB
---

# 4-20 マイクの周波数特性 (ピンクノイズ)

スピーカーから**ピンクノイズ**を出し、マイク (4-10 のマイクアンプ) で拾って、どの周波数がどれだけ届くかを Spectrum で 1 度に見る。
ピンクノイズは**どのオクターブにも同じ電力**が入った雑音で、電力の密度が 1/f で下がる。FFT のビンは幅が一定なので、
画面では **−10 dB/dec (−3 dB/oct) の右下がり**に見える。

測る物は「スピーカー + 部屋 + マイク + マイクアンプ」をまとめた特性になる。W1 そのもの (CH2) とマイクアンプの出力 (CH1) を同時に取り、
**CH1 − CH2 (dB)** を周波数ごとに読めば、ピンクノイズの傾きが打ち消されて、まとめた特性だけが残る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 のピンクノイズでスピーカーを鳴らし、マイクアンプ (4-10) で拾う
parts:
  VCC: vcc 1,1 5V
  R1: resistor 1,1 3,1 2.2k
  MK1: mic 3,1 5,1
  G1: ground 5,1
  C1: capacitor 3,1 3,4 1u
  VCC: vcc 1,4 5V
  R2: resistor 1,4 3,4 100k
  Q1: npn 5,6
  VCC: vcc 7,3 5V
  RC: resistor 7,3 7,5 470
  G2: ground 5,8
  C2: capacitor 7,5 9,5 1u
  M1: voltmeter 9,5 9,8 l=$\mathrm{CH1}$
  G3: ground 9,8
  VW: sine 1,11 1,13 l=$\mathrm{W1}$
  MW: voltmeter 3,11 3,13 l=$\mathrm{CH2}$
  RS: resistor 5,11 7,11 150
  SPK: speaker 7,11 9,11
  GW: ground 1,13
wires:
  - 3,4 |- Q1.B
  - Q1.C |- 7,5
  - Q1.E |- 5,8
  - 1,11 -- 3,11 -- 5,11
  - 1,13 -- 3,13 -- 9,13
  - 9,11 -- 9,13
notes:
  - text 8,9.8 blue: 音 (約 2 cm)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/20-mic-pink-noise.svg)

- 上はマイクアンプ (4-10 の図1 と同じ)。MK1 の音を Q1 で約 15 倍 (LTspice) にして CH1 へ
- 下はスピーカー (3-9 の図1 と同じ)。W1 から RS 150 Ω (Ω はオーム) を通して 8 Ω のスピーカーを鳴らし、CH2 は W1 そのものを読む
- MK1 をスピーカーの正面 2 cm ほどに向ける。間の距離と向きを変えると特性も変わるので、テープで固定して比べる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上半分がマイクアンプ (4-10)、下半分がスピーカー (3-9)
board: half
parts:
  R1: resistor b2 b5 2.2k
  MK1: mic e5 e8
  C1: capacitor c5 c10 1u
  R2: resistor +t10 b10 100k
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RC: resistor +t16 b16 470
  C2: capacitor d16 d21 1u
  RS: resistor h20 h24 150
  SPK: speaker i24 i28
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1+, 1-]
  WG:
    type: device
    at: bottom
    label: AD3 (W1 と CH2)
    pins: [2+, W1, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t12 black
  - a2 -- +t2 red
  - a8 -- -t8 black
  - a14 -- -t14 black
  - c12 -- c16 green
  - AD.1+ -- b21 yellow
  - AD.1- -- -t23 black
  - -t30 -- -b30 black
  - WG.W1 -- j20 yellow
  - WG.2+ -- i20 orange
  - WG.2- -- -b22 black
  - j28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/20-mic-pink-noise.svg)

上半分は 4-10 の図2 と同じ穴、下半分に RS (20〜24 列) とスピーカー (24〜28 列) を足した。W1 (黄) と CH2 (2+、橙) は 20 列。
GND は 30 列で上下の − レールをつなぐ。スピーカーのリードが挿せないときはワニ口クリップで (3-9)。
オシロの図は載せない。雑音の波形は理想の図に描けず、この題で読む値はすべてスペクトルにあるため。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable (マイクアンプだけ) |
| Wavegen | W1: Custom (3-4)、下の CSV (4096 点の周期的なピンクノイズ)。Frequency 5 Hz (1 点 48.8 µs、20.48 kS/s)、Amplitude 4 V |
| Scope | CH1・CH2: DC。Trigger: Wavegen に同期 (周期的なピンクノイズなので、平均で形がそろう) |
| Spectrum | Source: Channel 1 と Channel 2。Start 0 Hz、Stop 10 kHz、FFT 点数 8192、Window: Flat-top。単位: dBm。トレースを平均 (16 回ほど) にする (名前は版で違う、目安) |

ピンクノイズの CSV は PC の Python (numpy) で作る。白色の雑音の各周波数の振幅を 1/√f 倍し (電力で 1/f)、10 kHz より上を 0 にする。
4096 点を Frequency 5 Hz でくり返すので、W1 の中身は 5 Hz おきの線が 10 kHz まで並んだ「周期的な雑音」になる。

```python
# 4096 点の周期的なピンクノイズ (CSV、1 列) を作る
import numpy as np
N = 4096                      # 1 周期の点数
rng = np.random.default_rng(1)
k = np.arange(N // 2 + 1)     # 周波数の番号 (1 周期あたりの波の数)
amp = np.zeros(k.size)
amp[1:] = 1 / np.sqrt(k[1:])  # 電力が 1/f (ピンク)
amp[k > 2000] = 0             # 帯域を 2000 番まで (Frequency 5 Hz なら 10 kHz)
X = amp * np.exp(2j * np.pi * rng.random(k.size))
x = np.fft.irfft(X, N)
x = x / np.max(np.abs(x))     # 最大を 1 に (Amplitude で振幅を決める)
np.savetxt("pink4096.csv", x, fmt="%.6f")
print(np.sqrt(np.mean(x**2)))
```

Amplitude 4 V の振幅の最大で、RS と スピーカーに流れる電流は 4 V ÷ 158 Ω = 25 mA (W1 の歪みなく出せる 30 mA の内、3-9)。
雑音の実効値は最大の 0.27 倍の 1.08 V で、実効の電流 6.8 mA、スピーカーの電力は約 0.37 mW (計算値)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 W1 (CH2) のピンクノイズ — 10 倍の周波数で 10 dB 下がる右下がり (計算)
device: ad3
sweep: 0-10kHz
samples: 8192
window: flattop
unit: dBm
ref: 10dBm
scale: 5dB
data: 20-pink-drive.csv 計算
markers: [100Hz, 1kHz, 8kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/20-mic-pink-noise.svg)

図3 は、上の CSV を W1 で出し、Flat-top の 8192 点で 16 回平均したときの読みを計算した物 (`20-pink-drive.csv`、凡例は「計算」。測った値ではない)。
5 Hz おきの線は RBW (11.8 Hz) より細かく並ぶので、平らな帯に見える。1 本ずつの高さは ±1 dB ほどばらつく (M1〜M3)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| MK1 | エレクトレットコンデンサマイク (2 端子、4-10 と同じ) | — |
| R1, R2, RC | 抵抗 | 2.2 kΩ、100 kΩ、470 Ω |
| C1, C2 | フィルムかセラミックのコンデンサ | 1 µF (µ はマイクロ) |
| Q1 | NPN トランジスタ | 2SC1815 |
| RS | 抵抗 (スピーカーの電流を決める) | 150 Ω |
| SPK | 小型スピーカー | 8 Ω |
| — | 電源 | 5 V (AD3 の Supplies の V+、マイクアンプの約 4.6 mA) |

## 見るべき値

計算値。CH2 のピンクノイズの高さは図3 の帯の平均 (中心の ±10% のビン)。

| 周波数 | CH2 (W1) | 100 Hz との差 | ピンクノイズの理屈 |
| --- | --- | --- | --- |
| 100 Hz | −5.1 dBm | 0 | — |
| 1 kHz | −14.7 dBm | −9.6 dB | −10 dB (10 倍で 1/10) |
| 8 kHz | −25.1 dBm | −20.0 dB | −19.0 dB (80 倍) |

8 kHz で理屈より約 1 dB 多く下がるのは、W1 が 1 点 48.8 µs の階段で出すため (高い周波数ほど階段の平均で弱まる) と、平均のばらつきのぶん。

CH1 − CH2 の形の予想 (1 kHz を 0 dB とした)。マイクアンプは LTspice、スピーカーは仮定 (小型スピーカーの低い共振 f<sub>0</sub> を 300 Hz とし、
それより下は 2 次で落ちる)。マイクは 20 Hz〜16 kHz で平ら (4-10 の想定) とした。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 CH1 − CH2 の予想 — 低い側はスピーカーとマイクアンプで落ちる
x: 周波数 Hz log 20..10k
y: 1 kHz を 0 とした利得 dB -30..5
lines:
  マイクアンプ dB: 20 * log10((x / 57) / sqrt(1 + (x / 57)^2))
  スピーカー (仮定) dB: 20 * log10((x / 300)^2 / sqrt((1 - (x / 300)^2)^2 + (x / 300)^2)) - 0.37
  合計 dB: 20 * log10((x / 57) / sqrt(1 + (x / 57)^2)) + 20 * log10((x / 300)^2 / sqrt((1 - (x / 300)^2)^2 + (x / 300)^2)) - 0.37
notes:
  - mark 100
  - mark 300
  - level -3dB
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/graph/20-mic-pink-noise.svg)

分かること:

- **ピンクノイズの右下がりは信号の性質で、測る物の特性ではない**。CH1 だけを見ると高い周波数が弱く見えるが、CH2 と引き算すると打ち消される
- ピンクノイズを使うのは、低い周波数にも十分な電力が入るから (白色の雑音だと、電力の 9 割が 1〜10 kHz に入り、100 Hz の帯はほとんど空になる)。
  対数の周波数で見ると、どのオクターブにも同じ電力が入っている
- 予想 (図4) では、100 Hz で約 20 dB 下がる。小型のスピーカーは低い音が出ないので、マイクの低い側を測るには**スピーカーの特性を別に知る**必要がある
  (特性の分かっているマイクで同じ測定をして引く、など)。この測定が言えるのは「スピーカー + マイク」の組の特性である
- 部屋の反射で、数 kHz より上に細かい凹凸が出る。マイクを近づけるほど直接の音が勝ち、凹凸は小さくなる (目安)
- 周期的なピンクノイズは 5 Hz おきの線なので、Scope を Wavegen に同期させた平均 (4-5) も使える。ふつうの (周期の無い) ピンクノイズなら、Spectrum の平均だけを使う

## LTspice での確かめ

`sim/20-mic-pink-noise.cir` で、マイクアンプ (図1 の上の回路) の周波数特性を .ac で解いた (MK1 は 4-10 と同じテブナン等価、Q1 は h<sub>FE</sub> = 100 の仮定の模型)。
スピーカーと音の伝わり方は SPICE に入れていない (図4 の仮定の線)。ピンクノイズの高さは数値計算 (上の Python と、FFT の読みの計算) で確かめた。

| 項目 | 本文の数字 | LTspice・数値計算 | 判定 |
| --- | --- | --- | --- |
| マイクアンプの利得 (1 kHz) | 約 15 倍 | 15.14 倍 (LTspice) | 合う |
| 57 Hz での下がり | −3 dB | 10.96 ÷ 15.14 → −2.8 dB (LTspice) | 合う |
| 20 Hz での下がり | −9.6 dB (図4) | 5.22 ÷ 15.14 → −9.2 dB (LTspice) | 合う |
| ピンクノイズの傾き (100 Hz → 1 kHz) | −10 dB | −9.6 dB (数値計算) | 合う |
| 雑音の実効値 ÷ 最大 | 0.27 | 0.270 (数値計算) | 合う |

## 出典

自作。マイクアンプは 4-10、スピーカーの鳴らし方は 3-9 と同じ。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の Custom・Spectrum の節)。

参考: [ピンクノイズ (Wikipedia)](https://ja.wikipedia.org/wiki/ピンクノイズ)
