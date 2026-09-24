---
book: denken
chapter: 5
id: 5-2
title: RC の放電 — τ で 37 %
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-2 RC の放電 — τ で 37 %

5-1 と同じ RC 直列回路で、今度は方形波が立ち下がったあとの**放電**を見る。
コンデンサに溜まった電圧は一気には抜けず、時定数 τ = CR で決まる速さで
減っていく。1 τ 経った時点でちょうど 37 % が残っていることを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| τ = CR | 時定数。電圧が初めの値の 36.8 % まで減るのにかかる時間 |
| v(t) = V₀ e^(−t/τ) | コンデンサの電圧 (V₀ から放電を始めたとき) |
| v(τ) = 0.368 V₀、v(2τ) = 0.135 V₀、v(3τ) = 0.050 V₀、v(5τ) = 0.007 V₀ | τ の倍数ごとの残り |

## 回路図

```circuit
title: 図1 RC 直列の放電 (5-1 と同じ回路)
parts:
  V1: square a1 c1 1 l=$\mathrm{W1}$
  R1: resistor a1 a5 10k
  C1: capacitor a5 c5 100n
  G1: ground c1
wires:
  - c1 -- c5
notes:
  - text a1 blue: 入力
  - text a5 blue: 出力 (Vc)
style:
  standard: jis
  grid: on
```

- 回路は 5-1 と同じ (R1 = 10 kΩ、C1 = 100 nF、τ = 1.0 ms)。**方形波の立ち下がり**
  (2 V → 0 V) の直後を見る所だけが 5-1 と違う
- Wavegen が 0 V に落ちると、コンデンサに溜まった電荷は R1 を通って抜けていく

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (5-1 と同じ配線)
board: half
parts:
  R1: resistor c5 c10 10k
  C1: capacitor/ceramic c15 c20 100n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - a10 -- a15 green
  - a20 -- -t20 black
  - AD.GND -- -t2 black
  - AD.1+ -- a5 yellow [h10]
  - AD.1- -- -t7 black
  - AD.2+ -- a15 green [h10]
  - AD.2- -- -t17 black
```

- 配線は 5-1 と同じ。Wavegen の設定と、スコープで見る区間 (立ち下がりのあと) だけが違う

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、100 Hz、Amplitude 1 V、Offset 1 V (5-1 と同じ) |
| Scope | CH1 = 入力、CH2 = 出力。Trigger は CH1 の**立ち下がり**にする |

## 見るべき値

計算値。τ = CR = 1.0 ms。立ち下がり直前の電圧を 2 V (5-1 で 5 τ 待って
ほぼ満充電になった値) として計算する。

| 時間 (立ち下がりから) | 出力の電圧 | 直前の値 (2 V) に対する割合 |
| --- | --- | --- |
| 0 (τ = 0) | 2.00 V | 100 % |
| 1 τ (1.0 ms) | 0.74 V | 36.8 % |
| 2 τ (2.0 ms) | 0.27 V | 13.5 % |
| 3 τ (3.0 ms) | 0.10 V | 5.0 % |
| 5 τ (5.0 ms) | 0.01 V | 0.7 % |

分かること:

- **充電の 63 % と放電の 37 % は表裏の関係** (63.2 + 36.8 = 100)。同じ τ が
  「あとどれだけ残っているか」の目安にもなる
- 方形波の周期を τ に対して短くしていくと、出力は満充電・完全放電に届かず、
  三角波に近い波形になる (5-4 の方形波で確かめる時定数と周期の比)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
