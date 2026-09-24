---
book: circuits
chapter: 9
id: 9-1
title: LC 同調 — 共振を LED で見る
tier: 50
source: 自作
board: BB
---

# 9-1 LC 同調 — 共振を LED で見る

コイルとコンデンサを直列につなぐと、ある周波数だけでインピーダンスが最小になる。
これが**直列共振**で、f<sub>0</sub> = 1 / (2π√(LC)) で決まる。ファンクションジェネレータの
周波数を動かし、共振点だけ LED が明るく光るようすを見る。ラジオの同調回路と同じ原理。

## 回路図

```circuit
title: 図1 直列共振でLEDを光らせる
parts:
  V1: sine a1 c1 3
  R1: resistor a1 a3 100 i=I
  L1: inductor a3 a5 10m
  C1: capacitor a5 a7 10n
  D1: led a7 c7 red
  G1: ground c1
wires:
  - c1 -- c7
```

R1・L1・C1・D1 が直列の 1 つの輪になっている。R1 は電流を測るためと、
共振したときに電流を流しすぎないための抵抗。

- 共振周波数 f<sub>0</sub> = 1 / (2π√(10mH × 10nF)) **≈ 15.9kHz**
- 共振ではコイルのリアクタンス (jωL) とコンデンサのリアクタンス (1/jωC) が
  ちょうど打ち消し合い、輪の中は R1 とコイルの巻線抵抗 (小さな 10mH のコイルで
  実測 20Ω ほど) だけの抵抗回路になる
- 共振から離れると打ち消し合わなくなり、リアクタンスの分だけインピーダンスが
  跳ね上がって電流が減る

## 実体配線図

```breadboard
title: 図2 ファンクションジェネレータで振って見る
board: half
parts:
  R1: resistor a5 a8 100
  L1: inductor/axial a10 a15 10m
  C1: capacitor/ceramic a17 a19 10n
  D1: led b22(A) b23(K) red
  GEN:
    type: device
    at: top
    label: 信号発生器
    pins: [OUT, GND]
wires:
  - GEN.OUT -- a5 yellow
  - a8 -- a10 yellow
  - a15 -- a17 yellow
  - a19 -- b22 yellow
  - b23 -- -t23 black
  - GEN.GND -- -t2 black
```

- GEN (信号発生器) は正弦波 3V<sub>peak</sub> (6V<sub>pp</sub>) を出すファンクション
  ジェネレータ。周波数を 1kHz〜30kHz の間でゆっくり動かす
- 上の -t レール (青) が GND。GEN.GND と D1 のカソードが同じレールに集まる
- R1・L1・C1・D1 は a〜b 列を伝って 1 本の輪になっている (a8→a10、a15→a17、
  a19→b22 は同じ列の中や隣の橋渡し)

## 計器の設定

| 項目 | 値 |
| --- | --- |
| 波形 | 正弦波 |
| 振幅 | 3V<sub>peak</sub> (6V<sub>pp</sub>)、オフセット 0V |
| 周波数 | 1kHz〜30kHz を手で掃引 |

## 見るべき値

計算値。LED の順方向電圧を赤色の目安 2.0V として、輪の抵抗 (R1 100Ω + コイルの
巻線抵抗 20Ω ≈ 120Ω) から流れる電流を求める。

| 周波数 | インピーダンス | 電流 (ピーク) | LED |
| --- | --- | --- | --- |
| 7.96kHz (f<sub>0</sub>/2) | 約1.5kΩ (容量性が勝つ) | 約0.7mA | ほぼ点かない |
| **15.9kHz (f<sub>0</sub>)** | **約120Ω (抵抗だけ)** | **約8.3mA** | **一番明るい** |
| 31.8kHz (2f<sub>0</sub>) | 約1.5kΩ (誘導性が勝つ) | 約0.7mA | ほぼ点かない |

周波数を 15.9kHz の前後でゆっくり動かすと、その一点だけで LED が急に明るくなり、
離れると急に暗くなる。この鋭さ (Q の高さ) は R1 を小さくするほど増す。

## 出典

自作。
