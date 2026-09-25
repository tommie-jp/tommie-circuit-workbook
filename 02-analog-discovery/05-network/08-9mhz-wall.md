---
book: analog-discovery
chapter: 5
id: 5-8
title: 9 MHz の壁 — スルーで NA 自身の特性を取る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 5-8 9 MHz の壁 — スルーで NA 自身の特性を取る

5-5 では低い周波数でスルー (W1 を CH1・CH2 に直結) を測り、掃引設定の効きを見た。
ここでは同じスルーを**10 MHz まで**引っ張り上げる。DUT が無いのに利得が
0 dB から落ちていくとしたら、それは DUT ではなく **AD 自身の入力帯域**が
見えているということ。この「壁」の高さを測るのがこの題。

## 回路図

```circuit
title: 図1 スルー (基準) の結線
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  M2: voltmeter a5 c5 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

板は使わない。5-5 と同じ結線 (W1 を CH1・CH2 の両方に直結) だが、掃引を
10 MHz まで伸ばす。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 1 V |
| Network | Start 100 kHz、Stop 10 MHz、Log、Steps 101、Reference: Channel 1 |

付属のワイヤ (MTE ワイヤ) を使う。BNC アダプタに替えると壁の位置がもっと高くなる
(0-5 参照)。

## 見るべき値

計算値。AD のオシロ入力帯域を**1 次ローパス、f<sub>BW</sub> ≈ 9 MHz** の
フィルタと見立てると、利得 (dB) = −10 log₁₀(1 + (f/f<sub>BW</sub>)²)、
位相 = −arctan(f/f<sub>BW</sub>)。

| 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 kHz | −0.00 dB (ほぼ 0) | −0.6° |
| 1 MHz | −0.05 dB | −6.3° |
| 5 MHz | −1.17 dB | −29.1° |
| **9 MHz (f<sub>BW</sub>)** | **−3.01 dB** | **−45.0°** |
| 10 MHz | −3.49 dB | −48.0° |

分かること:

- **DUT が無いのに 9 MHz 付近から利得が落ちる。** これは測っている回路の問題では
  なく、**AD の入力 (付属ワイヤ使用時) の帯域そのもの**が見えている
- **この壁は 8 章のすべての測定に効く。** 8-1〜8-4 (ブレッドボードの寄生) や
  5-22・6-10・8-8 (25〜30 MHz まで) で BNC アダプタに替えるのは、この壁を
  高い側へ押し上げるため
- **DUT の f<sub>c</sub> が 9 MHz に近いと、測った値は DUT と AD の帯域が合成された
  ものになる。** 5-1〜5-4 のような 1〜10 kHz 台の DUT では無視できる差だが、
  5-22 のように DUT 自身が 25 MHz まで伸びる測定では、この壁を差し引いて
  考える必要がある

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。AD のオシロ入力帯域 (付属ワイヤで約 9 MHz) は公式の仕様値。
