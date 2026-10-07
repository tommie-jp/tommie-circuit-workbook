---
book: analog-discovery
chapter: 3
id: 3-6
title: バースト・トリガで単発パルス
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-6 バースト・トリガで単発パルス

Wavegen は Repeat (くり返し回数) を 1 にすると、Run を押すたびに**波形をちょうど
1 周期だけ出し、あとは Idle (待機) の電圧に戻る**。これがバースト動作で、
連続波形 (3-1) の特別な場合にあたる。ここでは Square の 1 周期を単発パルスとして
出し、Scope の **Single** (1-6) で捕まえて、LED をその電流の証拠にする。

## 回路図

```circuit
title: 図1 バースト出力で LED を光らせる
parts:
  V1: square 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  R1: resistor 5,1 7,1 100
  D1: led 7,1 9,1
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 9,3
  - 9,1 -- 9,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/06-burst-pulse.svg)

- V1 (W1) は Square、Idle は Offset の値。Repeat 1 にすると、山 (High) → 谷 (Low)
  の 1 組だけ出て Idle に戻る — 谷は Idle と同じ電圧なので、見えるのは**山 1 個の
  パルス**だけになる
- R1 (100 Ω) と D1 (LED) が W1 の直列負荷。CH1 は W1 の出力そのもの (R1+D1 の
  両端) を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3
board: half
parts:
  R1: resistor c5 c10 100
  D1: led d10(A) d12(K) red
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, 1+, W1, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.1- -- -t8 black
  - a12 -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/breadboard/06-burst-pulse.svg)

R1 (100 Ω) と LED を直列にして 5〜12 列に組む。CH1 (`1+`) は W1 と同じ 5 列の
別の穴から取る。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、Frequency **2 kHz**、Amplitude 1.5 V、Offset 1.5 V、**Repeat: 1** (Run を押すたびに 1 周期だけ出す) |
| Scope | CH1: DC 結合、Range 500 mV/div、Offset (位置) を −1.5 V にして 0 V を下から 1 目盛に置く (0〜3 V が 6 目盛を占める)、Time/div 100 µs/div。トリガ: レベル 1.5 V・立ち上がり・**Single** (Wavegen の Run を押す前に Single で待ち構える) |

Offset 1.5 V ± Amplitude 1.5 V なので、Idle (Low) は **0 V**、山 (High) は
**3.0 V**。2 kHz の半周期ぶんだけ High になる。

```scope
title: 図3 Run 1 回で 0 V から 3.0 V に 250 µs だけ上がる
time: 100us/div
trigger: ch1 rising 1.5V at -3div
ch1: {wave: = 3V * step(t) * step(250us - t), range: 500mV/div, position: -3div}
cursors: [0, 250us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/06-burst-pulse.svg)

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の High レベル | 3.00 V (= Offset + Amplitude) | 3-1 と同じ Offset・Amplitude の読み方 |
| CH1 の Idle (Low) レベル | 0.00 V (= Offset − Amplitude) | Repeat 1 のときの待機電圧 |
| パルス幅 (High の継続時間) | 250 µs (= 1 / (2 × 2 kHz)、1 周期の前半) | Repeat 1 が「1 周期だけ」を作る仕組み |
| LED (D1) のピーク電流 | 10.0 mA (= (3.0 V − V<sub>F</sub> 2.0 V) ÷ 100 Ω) | AD3 の歪みなく出せる上限 30 mA (3-5) の 1/3。Wavegen の負荷として問題ない |

分かること:

- **Single トリガ (1-6) と Repeat 1 の組み合わせで、狙った 1 回だけを確実に
  捕まえられる。** Auto トリガのままだと、パルスの無い間もトリガを待たずに
  画面を更新し続けるので、1 回きりのパルスが流れて消える
- 250 µs という短いパルスは 1 回だけでは目で追えないほど速い (LED はほぼ
  一瞬光るだけ)。**電流が流れた証拠として LED を見る**のであって、明るさや
  点滅の様子を目で確かめる実験ではない
- Repeat を大きな数 (または連続) に戻すと、3-1 で見た普通の連続 Square に戻る。
  単発パルスを間を空けてくり返したいときは、Wavegen の Wait (休みの時間) と
  Repeat を組み合わせ、Scope は **Normal** トリガにして**ホールドオフ** (2-1) を
  パルス幅より長く取ると安定して見える

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
