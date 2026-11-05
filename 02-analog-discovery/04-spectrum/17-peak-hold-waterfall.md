---
book: analog-discovery
chapter: 4
id: 4-17
title: ピークホールドとウォーターフォール
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 4-17 ピークホールドとウォーターフォール

FFT の画面は、1 回の取り込み (取り込み時間 T) の「今」のスペクトルしか見せない。周波数が動く信号 (掃引・ホッピング・ふらつく発振回路) は、
その瞬間の 1 本しか映らない。そこで 2 つの見せ方を使う。

- **ピークホールド** (最大値の保持): 取り込みのたびに、周波数ごとの最大値を残す。動いた範囲が「帯」になって残る。tinySA の MAX HOLD と同じ
- **ウォーターフォール** (スペクトログラム): 横を周波数、縦を時間にして、取り込みを 1 行ずつ積む。周波数が**いつ**どこにあったかが残る

W1 の Sweep (3-2) で 4 kHz から 7 kHz まで 10 s かけて動く正弦波を作り、2 つで見比べる。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/17-peak-hold-waterfall.svg)

実体配線図は載せない。基板を使わず、W1 と 1+ を付属のワイヤで直につなぐだけで (GND と 1− は GND へ)、つなぎ方は 0-3 の図2 と同じ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、Amplitude 1 V。Sweep: Start 4 kHz、Stop 7 kHz、Time 10 s、Type Linear、繰り返し |
| Scope | Time 100 µs/div、Trigger: CH1 の立ち上がり 0 V |
| Spectrum | Source: Channel 1。Start 3 kHz、Stop 8 kHz、FFT 点数 1024、Window: Flat-top。単位: dBm。トレースの種類を「今」(通常) と「最大値の保持」で替える |

Spectrum のトレースの種類 (最大値の保持・平均など) の名前と、ウォーターフォール (スペクトログラム) の表示の有無は、WaveForms の版で違う (目安)。
ウォーターフォールの表示が無い版では、取り込みを Script か SDK で並べて描く (第 11 章)。

**取り込みの間に周波数が動きすぎない設定にする**。図のサンプル周波数を Stop × 2.56 = 20.48 kHz (目安、4-11) とすると、
1024 点の取り込み時間は T = 50 ms、その間に周波数は 300 Hz/s × 50 ms = 15 Hz しか動かず、ビンの幅 20 Hz より小さい。
8192 点 (T = 400 ms、120 Hz 動く) にすると、山が太って低く読める。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 最大値の保持 — 10 s の掃引で 4〜7 kHz が +10 dBm の帯として残る (青は今の 1 回)
device: ad3
sweep: 3kHz-8kHz
samples: 1024
window: flattop
unit: dBm
ref: 20dBm
signal: sine 5.5kHz 1V
hold: sine 4kHz..7kHz/100Hz 1V
markers: [4kHz, 5.54kHz, 7kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/17-peak-hold-waterfall.svg)

図2 は保持を 100 Hz おきの 31 回の取り込みで描いたので、帯の上に 4 dB ほどの凸凹がある (M2 は谷の 5.54 kHz で +6.17 dBm)。
実機の掃引は取り込みごとに 15 Hz しか進まないので、帯の上はほぼ平らになる。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 ウォーターフォールに残る線 — 10 s で 4 kHz から 7 kHz へ上がって戻る
x: 時間 s 0..20
y: 周波数 Hz 3k..8k
lines:
  W1 の周波数 Hz:
    - 0 4k
    - 10 7k
    - 10.01 4k
    - 20 7k
notes:
  - mark 5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/graph/17-peak-hold-waterfall.svg)

図3 はウォーターフォールの画面ではなく、そこに明るく残る線 (時刻と周波数の組) を x-y のグラフにした物。
ウォーターフォールの 1 行は 1 回の取り込み (50 ms) なので、10 s の掃引は 200 行の斜めの線になる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 時間で見ると、ある瞬間の W1 は 1 本の正弦波 (ここでは 5.5 kHz)
time: 100us/div
trigger: ch1 rising 0V
ch1: {wave: sine 5.5kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/17-peak-hold-waterfall.svg)

Scope の Frequency の読みは掃引につれて 4〜7 kHz を動く。図4 はその 1 瞬 (掃引の始めから 5 s) を描いた。

## 見るべき値

計算値。

| 項目 | 値 | 計算 |
| --- | --- | --- |
| 掃引の速さ | 300 Hz/s | (7 kHz − 4 kHz) ÷ 10 s |
| 1 回の取り込み時間 T (1024 点) | 50 ms | 1024 ÷ 20.48 kHz |
| T の間に動く周波数 | 15 Hz | 300 Hz/s × 50 ms。ビンの幅 20 Hz より小さい |
| 保持した帯の高さ | +10.00 dBm | 振幅 1 V の正弦 |
| 帯の幅 | 4〜7 kHz (3 kHz) | Sweep の Start・Stop |
| 「今」のトレース | +10.00 dBm の 1 本 | 図2 の青 |
| 5 s 後の周波数 | 5.5 kHz | 4 kHz + 300 Hz/s × 5 s (図3 の mark、図4) |
| ウォーターフォールの行の数 (1 掃引) | 200 行 | 10 s ÷ 50 ms |

分かること:

- **ピークホールドは「どこまで動いたか」、ウォーターフォールは「いつどこにいたか」を残す**。発振回路の周波数のふらつき (4-18) の幅はピークホールド、
  ふらつき方 (ゆっくりか速いか) はウォーターフォールで見る
- ピークホールドはスイッチを入れた後の最大だけを残すので、一度だけ出た大きな線も消えない。読む前にリセットする
- 平均 (4-5) はピークホールドと逆で、動く線は平均で低く広がる。周波数が動く信号に平均を掛けない
- 取り込み時間 T はウォーターフォールの縦の刻みでもある。点数を増やすと周波数は細かく、時間は粗くなる (4-11 と同じ取り換え)

## LTspice での確かめ (対象外)

回路は線 1 本で、SPICE の対象ではない。計器の設定の算術で確かめた。掃引の速さ 3 kHz ÷ 10 s = 300 Hz/s、T = 1024 ÷ 20.48 kHz = 50.0 ms、
動く周波数 300 × 0.05 = 15 Hz、5 s 後は 4000 + 1500 = 5500 Hz、行の数 10 ÷ 0.05 = 200。図2 の `check` の読みは保持した帯の端で +10.00 dBm、
図3 の mark は 5 s で 5.50 kHz で、本文と合う。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Spectrum の節)。

参考: [Spectrogram (Wikipedia)](https://en.wikipedia.org/wiki/Spectrogram)
