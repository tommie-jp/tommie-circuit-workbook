---
book: denken
chapter: 5
id: 5-1
title: RC の充電 — 時定数 τ = CR で 63 %
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-1 RC の充電 — 時定数 τ = CR で 63 %

AD の波形発生器 (Wavegen) で方形波を作り、抵抗とコンデンサの直列回路 (RC 回路)
に加える。コンデンサの電圧は電源の電圧へ一気には届かず、**時定数 τ = CR** で
決まる速さで近づく。1 τ 経った時点でちょうど 63 % まで来ていることを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| τ = CR | 時定数。電圧が最終値の 63.2 % に達するまでの時間 |
| v(t) = V(1 − e^(−t/τ)) | コンデンサの電圧 (0 から充電を始めたとき) |
| v(τ) = 0.632 V、v(2τ) = 0.865 V、v(3τ) = 0.950 V、v(5τ) = 0.993 V | τ の倍数ごとの到達率 |

## 回路図

```circuit
title: 図1 RC 直列の充電回路
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

- R1 (10 kΩ) と C1 (100 nF) で τ = CR = 1.0 ms
- 入力は AD の Wavegen (W1) の方形波。0 V と 2 V を行き来する
  (Amplitude 1 V、Offset 1 V)
- 出力 (Vc、C1 の両端) を見ると、方形波の**角が取れた**波形になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
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

- 5〜10 列が R1、15〜20 列が C1。10 列と 15 列をつなぐ緑の線の所が出力の節点
- CH1 (1+) は入力 (Wavegen の直後)、CH2 (2+) は出力 (C1 の両端) に挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Square、100 Hz、Amplitude 1 V、Offset 1 V (0 V〜2 V の方形波) |
| Scope | CH1 = 入力、CH2 = 出力。Time base は 1 ms/div 前後、Trigger は CH1 の立ち上がり |

## 見るべき値

計算値。τ = CR = 10 kΩ × 100 nF = 1.0 ms。方形波の半周期 5 ms は 5τ ぶんあるので、
毎回ほぼ 0 V (または 2 V) まで戻ってから次の充電が始まる。

| 時間 (立ち上がりから) | 出力の電圧 | 最終値 (2 V) に対する割合 |
| --- | --- | --- |
| 0 (τ = 0) | 0 V | 0 % |
| 1 τ (1.0 ms) | 1.26 V | 63.2 % |
| 2 τ (2.0 ms) | 1.73 V | 86.5 % |
| 3 τ (3.0 ms) | 1.90 V | 95.0 % |
| 5 τ (5.0 ms) | 1.99 V | 99.3 % |

分かること:

- **τ 後の到達率はいつも 63.2 %** で、R や C の値によらない。R を 2 倍にすると
  τ も 2 倍になり、波形が横に間延びするだけで形は変わらない
- 5 τ でほぼ 100 % (99.3 %) に届く。**「5 τ でほぼ終わる」という目安**は
  タイマー回路や電源のリップルの計算でもよく使う

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
