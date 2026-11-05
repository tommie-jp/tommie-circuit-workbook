---
book: analog-discovery
chapter: 4
id: 4-12
title: SFDR
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-12 SFDR

**SFDR (Spurious-Free Dynamic Range、スプリアスの無いダイナミックレンジ)** は、基本波と、
画面の中で一番高い不要な線 (スプリアス) の差を dB で表した数である。高調波でも、高調波でない線でもよい。
4-4 の THD が高調波を全部まとめた量なのに対し、SFDR は**一番悪い 1 本**だけを見る。
小さい信号を大きい信号のそばで探すとき (4-14 の相互変調など) に、「これより小さい線は測定系のものと区別できない」境目になる。
この題では W1 の正弦をそのまま測り、SFDR を dBc と dBFS の 2 通りで読み、**見る帯域を狭めると SFDR を良く読み違える**ことを確かめる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/12-sfdr.svg)

実体配線図は載せない。基板を使わず、W1 と 1+ を付属のワイヤで直につなぐだけで (GND と 1− は GND へ)、つなぎ方は 0-3 の図2 と同じ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1000 Hz、Amplitude 1 V |
| Scope | CH1 の Range は ±2.5 V 側 (1 V の信号で自動に選ばれる側、4-1) |
| Spectrum | Source: Channel 1。**Start 0 Hz、Stop 20 kHz**、FFT 点数 8192。Window: Flat-top (線の高さを正しく読む、4-3)。単位: dBm。Marker の測定に SFDR を選べるなら選ぶ (無ければ基本波と一番高いスプリアスに Marker を置いて差を読む) |

図2・図3 のスプリアス (2〜5 次の高調波の高さ) と、フロアの −100 dBm は**説明のために置いた例** (仮定) で、実機の値ではない。
4-4 の THD の目安 (0.1〜1%) の中に入るように選んだ。実測では Marker で読み、表の「実測」の列を埋める。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 SFDR は基本波と一番高いスプリアス (3 次) の差 — 60 dBc (例)
device: ad3
sweep: 0-20kHz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
scale: 15dB
floor: -100dBm
signal:
  - sine 1kHz 1V
  - sine 2kHz 0.5mV
  - sine 3kHz 1mV
  - sine 4kHz 0.1mV
  - sine 5kHz 0.178mV
markers: [1kHz, 3kHz, 2kHz, 5kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/12-sfdr-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 Stop 2.5 kHz では 3 次が外に出て SFDR を 66 dBc と読み違える (例)
device: ad3
sweep: 0-2.5kHz
samples: 8192
window: flattop
unit: dBm
ref: 20dBm
scale: 15dB
floor: -100dBm
signal:
  - sine 1kHz 1V
  - sine 2kHz 0.5mV
  - sine 3kHz 1mV
  - sine 4kHz 0.1mV
  - sine 5kHz 0.178mV
markers: [1kHz, 2kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/12-sfdr-2.svg)

図3 は図2 と同じ信号で、Stop だけを替えた。3 kHz 以上の線は画面に入らない。実機では Stop を下げるとサンプル周波数も下がり、高い次数が折り返して別の周波数に出ることもある (2-16)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 時間で見た W1 — 振幅 1 V の正弦にスプリアスは見えない
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/12-sfdr.svg)

3 次の 1 mV は振幅 1 V の 0.1% で、500 mV/div の画面では 1 画素にも満たない。

## 見るべき値

計算値。dBc は基本波 (carrier) を 0 とした dB、dBFS は Scope の満振幅 (±2.5 V の正弦、+17.96 dBm) を 0 とした dB。
スプリアスの高さは図2 の例。

| 線 | 周波数 | 振幅 (0-peak、例) | dBm | dBc | 実測 |
| --- | --- | --- | --- | --- | --- |
| 基本波 | 1 kHz | 1 V | +10.00 dBm | 0 dBc | |
| 2 次 | 2 kHz | 0.5 mV | −56.02 dBm | −66.0 dBc | |
| 3 次 (一番高いスプリアス) | 3 kHz | 1 mV | −50.00 dBm | −60.0 dBc | |
| 4 次 | 4 kHz | 0.1 mV | −70.00 dBm | −80.0 dBc | |
| 5 次 | 5 kHz | 0.178 mV | −64.99 dBm | −75.0 dBc | |

| 量 | 値 | 計算 |
| --- | --- | --- |
| SFDR (dBc) | 60.0 dBc | +10.00 − (−50.00) |
| 基本波の dBFS | −7.96 dBFS | 20 log (1 V ÷ 2.5 V) |
| SFDR (dBFS) | 67.96 dBFS | +17.96 − (−50.00)。満振幅から一番高いスプリアスまで |
| 図3 での読み | 66.0 dBc | 2 次しか画面に無い (読み違い) |
| THD (同じ例) | 0.114% (−58.9 dB) | √(0.5² + 1² + 0.1² + 0.178²) mV ÷ 1 V |
| 雑音で決まる上限 | 110 dB | 基本波 +10 dBm とフロア −100 dBm の差 (1 ビンあたり) |

分かること:

- **SFDR は一番高い 1 本で決まる**。図2 では 3 次。THD (−58.9 dB) は全部の高調波を足すので、SFDR (60 dBc) より少し悪い数になる
- **dBc と dBFS は 7.96 dB 違う**。dBc は「今の信号に対して」、dBFS は「Scope の満振幅に対して」の値。
  資料の SFDR の数を比べるときは、どちらの基準かを確かめる
- **見る帯域が狭いと SFDR を良く読み違える** (図3)。少なくとも 5 次 (5 kHz) までが入る Stop にする。高調波でないスプリアス
  (USB の電源・クロックのもれ) も入るように、一度は Stop を広げて全体を見る
- SFDR はフロア (雑音で決まる上限 110 dB) よりずっと手前で決まる。平均 (4-5) で下がるのはフロアだけで、スプリアスは周期的なので平均しても下がらない。
  SFDR を良くするには、平均ではなく信号源の低ひずみ化 (フィルタを通す) が要る

## LTspice での確かめ (対象外)

dB の算術で確かめた。回路は線 1 本で、SPICE の対象ではない。振幅 A の正弦は 10 log ((A/√2)² ÷ 50 Ω ÷ 1 mW) dBm。
1 V → +10.00 dBm、1 mV → −50.00 dBm、0.5 mV → −56.02 dBm、0.178 mV → −64.99 dBm、2.5 V → +17.96 dBm。
SFDR = 10.00 + 50.00 = 60.0 dBc、dBFS では 17.96 + 50.00 = 67.96 dBFS。THD = √(0.25 + 1 + 0.01 + 0.0317) mV = 1.137 mV → 0.114%・−58.9 dB。
図2 の Marker の読み (+10.00・−50.00・−56.02・−64.99 dBm) も同じ数になった。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Spectrum の節)。SFDR・dBc・dBFS の定義は AD 変換・DA 変換の教科書に載っている標準的なもの。

参考: [Spurious-free dynamic range (Wikipedia)](https://en.wikipedia.org/wiki/Spurious-free_dynamic_range)
