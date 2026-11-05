---
book: analog-discovery
chapter: 4
id: 4-11
title: 分解能帯域幅とサンプル数
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-11 分解能帯域幅とサンプル数

FFT の画面で「近い 2 本を分けて見られるか」を決めるのは**分解能帯域幅 (RBW)** で、
RBW = 窓の ENBW (ビン単位) × ビンの幅、ビンの幅 = サンプル周波数 f<sub>s</sub> ÷ FFT 点数 N。
4-6 で見たとおり、分けて見る力は**取り込み時間 T = N ÷ f<sub>s</sub>** で決まる。
この題では 100 Hz 離れた 3 本 (AM 波の搬送波と側波帯) を使い、点数と窓を替えて
「どこで分かれるか」を数で確かめる。点数を増やすと分かれるが、1 画面の更新に時間がかかる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ループバック (W1 を 1+ に直結)
parts:
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/11-rbw-samples.svg)

実体配線図は載せない。基板を使わず、W1 と 1+ を付属のワイヤで直につなぐだけで (GND と 1− は GND へ)、つなぎ方は 0-3 の図2 と同じ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Carrier Sine **10 kHz**、Amplitude 1 V。AM: Modulation Sine **100 Hz**、Depth **50%** (3-3・4-7 と同じ作り方) |
| Spectrum | Source: Channel 1。**Start 9.5 kHz、Stop 10.5 kHz**。FFT 点数 N を 1024・2048・4096・8192 と替える。Window を Flat-top と Hann で替える。単位: dBm |
| Scope | Time 2 ms/div、Trigger: Wavegen (W1) に同期 |

AM 波は搬送波 10 kHz (+10.00 dBm) の両側 ±100 Hz に側波帯 (振幅 0.25 V、−2.04 dBm) が 1 本ずつ立つ (4-7)。
図のサンプル周波数は f<sub>s</sub> = Stop × 2.56 = 26.88 kHz として描いた (目安)。
4-1 のとおり AD3 の f<sub>s</sub> はシステムクロックを整数で割った値に丸まるので、ビンの幅は画面の表示を読む。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 Flat-top・1024 点 — RBW 99 Hz では 100 Hz 離れた 3 本が 1 つの山に融ける
device: ad3
sweep: 9.5kHz-10.5kHz
samples: 1024
window: flattop
unit: dBm
ref: 15dBm
signal:
  - sine 10kHz 1V
  - sine 9.9kHz 0.25V
  - sine 10.1kHz 0.25V
markers: [10kHz, 9.9kHz, 10.05kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/11-rbw-samples-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 Hann・1024 点 — RBW 39 Hz なら 3 本に分かれ、間に谷ができる
device: ad3
sweep: 9.5kHz-10.5kHz
samples: 1024
window: hann
unit: dBm
ref: 15dBm
signal:
  - sine 10kHz 1V
  - sine 9.9kHz 0.25V
  - sine 10.1kHz 0.25V
markers: [10kHz, 9.9kHz, 10.05kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/11-rbw-samples-2.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 Flat-top・8192 点 — RBW 12 Hz で 3 本が細く立ち、谷はフロアまで落ちる
device: ad3
sweep: 9.5kHz-10.5kHz
samples: 8192
window: flattop
unit: dBm
ref: 15dBm
signal:
  - sine 10kHz 1V
  - sine 9.9kHz 0.25V
  - sine 10.1kHz 0.25V
markers: [10kHz, 9.9kHz, 10.05kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/11-rbw-samples-3.svg)

マーカーは搬送波 (M1)、下側側波帯 (M2)、搬送波と上側側波帯の真ん中の 10.05 kHz (M3、谷の深さ) に置いた。
図2 では M3 が搬送波とほとんど同じ高さで、谷が無い。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 時間で見た同じ AM 波 — 100 Hz のエンベロープが 1.5 V と 0.5 V の間を動く
time: 2ms/div
trigger: ch1 rising 0V
ch1: {wave: = 1V * (1 + 0.5 * cos(2 * pi * 100Hz * t)) * cos(2 * pi * 10kHz * t), range: 500mV/div}
cursors: [0, 10ms]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/11-rbw-samples.svg)

カーソルの間隔 10 ms がエンベロープの 1 周期 (100 Hz)。図2〜4 の側波帯の間隔 100 Hz と同じ数である。

## 見るべき値

計算値 (f<sub>s</sub> = 26.88 kHz、ENBW は Flat-top 3.77 ビン・Hann 1.50 ビン、4-3)。
「谷」は 10.05 kHz の読みで、搬送波の +10.00 dBm から何 dB 下がるか。

| N | 窓 | ビンの幅 | RBW | 取り込み時間 T | 10.05 kHz の読み | 3 本に分かれるか |
| --- | --- | --- | --- | --- | --- | --- |
| 1024 | Flat-top | 26.25 Hz | 99.0 Hz | 38.1 ms | 約 +8 dBm | 分かれない (図2) |
| 1024 | Hann | 26.25 Hz | 39.4 Hz | 38.1 ms | −24〜−30 dBm (ビンの位置で変わる) | 分かれる (図3) |
| 2048 | Flat-top | 13.13 Hz | 49.5 Hz | 76.2 ms | 約 −19 dBm | 分かれる (谷は浅い) |
| 4096 | Flat-top | 6.56 Hz | 24.7 Hz | 152 ms | フロアまで | 分かれる |
| 8192 | Flat-top | 3.28 Hz | 12.4 Hz | 305 ms | フロアまで | 分かれる (図4) |

| 項目 | 値 | 計算 |
| --- | --- | --- |
| 搬送波 | +10.00 dBm | 振幅 1 V の正弦 |
| 側波帯 | −2.04 dBm (搬送波の −12.04 dB) | 振幅 1 V × 0.5 ÷ 2 = 0.25 V |
| 分かれる目安 | 間隔 ≥ 約 2 × RBW | Flat-top で 100 Hz を分けるには RBW ≤ 50 Hz、N ≥ 2048 |

分かること:

- **ビンの幅と RBW は別の数**である。Flat-top は ENBW が 3.77 ビンあるので、ビンの幅が 26 Hz でも 100 Hz の間隔を分けられない。
  同じ 1024 点でも Hann にすると RBW が 2.5 分の 1 になり、3 本に分かれる (振幅の読みは 4-3 の誤差を受け入れる)
- **N を 2 倍にすると RBW は半分、取り込み時間 T は 2 倍**。8192 点では 1 画面に 0.3 s かかり、動く信号を追う速さが落ちる。
  見たい間隔を分けられる一番少ない N を選ぶのが基本
- 分けて見る力は T だけで決まり、Start・Stop を狭めて表示を拡大しても変わらない (4-6)。
  逆に Stop を下げると f<sub>s</sub> が下がり、同じ N で T が延びて RBW が細くなる
- ノイズフロアの高さも RBW で変わる。白色雑音の 1 ビンの電力は RBW に比例するので、RBW を半分にするとフロアは 3 dB 下がる (4-13 で使う)

## LTspice での確かめ (対象外)

計器の設定の算術と数値 FFT (Python の numpy・scipy) で確かめた。LTspice の対象ではない。
f<sub>s</sub> = 26.88 kHz で AM 波 (10 kHz、100 Hz、50%) を N 点取り、窓を掛けて 16 倍に 0 を詰めて読んだ。

| 項目 | 本文の数字 | 数値 FFT | 判定 |
| --- | --- | --- | --- |
| ENBW (Flat-top / Hann) | 3.77 / 1.50 ビン | 3.77 / 1.50 ビン | 合う |
| 1024 点 Flat-top の 10.05 kHz | 約 +8 dBm | +8.37 dBm (図2 の読み +7.87 dBm) | 合う |
| 1024 点 Hann の 10.05 kHz | −24〜−30 dBm | −23.97 dBm (図3 の読みはビンの上で −30.43 dBm) | 合う |
| 2048 点 Flat-top の 10.05 kHz | 約 −19 dBm | −19.00 dBm | 合う |
| 8192 点 Flat-top の側波帯 | −2.04 dBm | −2.04 dBm | 合う |
| 8192 点の T | 305 ms | 304.8 ms | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。窓の ENBW は信号処理の教科書に載っている標準的な値。

参考: [窓関数 (Wikipedia)](https://ja.wikipedia.org/wiki/窓関数)
