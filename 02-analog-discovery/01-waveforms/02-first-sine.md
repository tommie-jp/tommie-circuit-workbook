---
book: analog-discovery
chapter: 1
id: 1-2
title: 1 kHz の正弦波を出してオシロで見る (最初の 1 本)
tier: 50
source: 自作 (公式は Digilent Using the Oscilloscope ガイド)
board: BB
---

# 1-2 1 kHz の正弦波を出してオシロで見る (最初の 1 本)

Wavegen (波形発生器) で正弦波を作り、ブレッドボードに実際に組んだ負荷に流して
Scope (オシロスコープ) で見る。0-3 のループバックとの違いは、**間に本物の
部品 (抵抗) を挟む**こと。

## 回路図

```circuit
title: 図1 正弦波を作って測る
parts:
  W1: sine a1 c1 1
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

W1 (Wavegen の `W1`) に負荷 R1 (1 kΩ) をつなぎ、CH1 で R1 の両端 (= W1 の
出力そのもの) を読む。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで正弦波を測る
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- a10 black
  - AD.1+ -- b5 yellow
  - AD.1- -- b10 black
```

- R1 は W1 と GND の間の負荷。5 列が W1 側、10 列が GND 側
- CH1 (`1+` / `1-`) は R1 の両端に、5 列・10 列の別の穴から挿す
  (同じ列は中でつながっているので、R1 の足と同じ穴を使わなくてよい)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V (2 Vpp)、オフセット 0 V |
| Scope (CH1) | DC、Range ±2 V 程度、Auto トリガ、Time/div 0.2 ms 程度 (1 周期が画面に 5 つ) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Vpp | 2.00 V (計算値。振幅 1 V の 2 倍) | 負荷 1 kΩ をつないでも振幅は変わらない (Wavegen の出力インピーダンスは 1 kΩ に対して十分小さい) |
| CH1 の周波数 | 1.000 kHz | Time/div を変えても表示が伸び縮みするだけで値は変わらない |
| 1 周期の時間 | 1.00 ms (= 1 / 1 kHz) | カーソルや自動計測 (2-2) で読める |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
