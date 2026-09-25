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
  V1: square a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  R1: resistor a5 a7 100
  D1: led a7 a9
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c9
  - a9 -- c9
```

- V1 (W1) は Square、Idle は Offset の値。Repeat 1 にすると、山 (High) → 谷 (Low)
  の 1 組だけ出て Idle に戻る — 谷は Idle と同じ電圧なので、見えるのは**山 1 個の
  パルス**だけになる
- R1 (100 Ω) と D1 (LED) が W1 の直列負荷。CH1 は W1 の出力そのもの (R1+D1 の
  両端) を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 100
  D1: led c12(A) c14(K) red
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - c10 -- c12 green
  - a14 -- -t14 black
```

R1 (100 Ω) と LED を直列にして 5〜14 列に組む。CH1 (`1+`) は W1 と同じ 5 列の
別の穴から取る。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、Frequency **2 kHz**、Amplitude 1.5 V、Offset 1.5 V、**Repeat: 1** (Run を押すたびに 1 周期だけ出す) |
| Scope | CH1: DC 結合、Range 1 V/div (0〜3 V が画面に入るように位置調整)、Time/div 100 µs/div。トリガ: レベル 1.5 V・立ち上がり・**Single** (Wavegen の Run を押す前に Single で待ち構える) |

Offset 1.5 V ± Amplitude 1.5 V なので、Idle (Low) は **0 V**、山 (High) は
**3.0 V**。2 kHz の半周期ぶんだけ High になる。

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の High レベル | 3.00 V (= Offset + Amplitude) | 3-1 と同じ Offset・Amplitude の読み方 |
| CH1 の Idle (Low) レベル | 0.00 V (= Offset − Amplitude) | Repeat 1 のときの待機電圧 |
| パルス幅 (High の継続時間) | 250 µs (= 1 / (2 × 2 kHz)、1 周期の前半) | Repeat 1 が「1 周期だけ」を作る仕組み |
| LED (D1) のピーク電流 | 10.0 mA (= (3.0 V − V<sub>F</sub> 2.0 V) ÷ 100 Ω) | ちょうど Wavegen の保証駆動電流 (3-5) と同じ値 |

分かること:

- **Single トリガ (1-6) と Repeat 1 の組み合わせで、狙った 1 回だけを確実に
  捕まえられる。** Normal トリガのままだと、Run を押すたびに再アームしないと
  次のパルスを取りこぼす
- 250 µs という短いパルスは 1 回だけでは目で追えないほど速い (LED はほぼ
  一瞬光るだけ)。**電流が流れた証拠として LED を見る**のであって、明るさや
  点滅の様子を目で確かめる実験ではない
- Repeat を大きな数 (または連続) に戻すと、3-1 で見た普通の連続 Square に戻る。
  周期的に単発パルスを繰り返したいときは、Repeat を周期的にしたうえで Scope を
  **Normal** トリガ・**ホールドオフ** (2-1) をパルス幅より長く取ると安定して見える

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen の節)。
