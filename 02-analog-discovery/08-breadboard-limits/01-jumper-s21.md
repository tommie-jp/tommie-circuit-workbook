---
book: analog-discovery
chapter: 8
id: 8-1
title: ジャンパ 1 本のスルーの S21 を 100 kHz〜10 MHz
tier: 50
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 8-1 ジャンパ 1 本のスルーの S21 を 100 kHz〜10 MHz

ブレッドボードの限界を測る前に、まず**基準**を作る。ジャンパ線 1 本だけを
挟んだだけの「スルー」を Network アナライザで 100 kHz〜10 MHz まで掃引し、
S21 (出力 ÷ 入力) がどれだけ 0 dB からずれるかを見る。ここで平らなら、
ブレッドボードの限界は 8-2 以降で測る**別の原因** (列間容量・ジャンパの
インダクタンス) だと分かる。

## 回路図

```circuit
title: 図1 ジャンパ 1 本のスルーと負荷抵抗
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  J1: short c3 c6
  Rload: resistor c6 c9 1k
  G1: ground c11
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c11
  - AD.2+ -| c6
  - AD.2- -| c11
  - c9 -- c11
  - AD.GND -| c11
```

- 1+ は W1 の節点 (ジャンパの手前)、2+ はジャンパの向こう側 (負荷抵抗の頭)。
  1−・2− はどちらも GND — 片側基準の測定
- 負荷 1 kΩ は**オシロの入力インピーダンス (1 MΩ) だけに頼らない**ため。
  1 MΩ だけだと僅かな漏れ電流でも電圧が動いてしまう

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rload: resistor c10 c15 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow [h-10]
  - e5 -- e10 orange
  - AD.1+ -- b5 white [h10]
  - AD.2+ -- b10 gray
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
  - AD.2- -- -t12 black
  - a15 -- -t15 black
```

- 橙の線 (5 列 → 10 列、約 5 cm) が**測るジャンパそのもの**。ほかの配線は
  測定のための接続で、長さは気にしなくてよい
- 1+ (5 列) と 2+ (10 列) の間、ジャンパだけを挟む。それ以外の寄り道が無いように

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | 掃引 100 kHz〜10 MHz、点数 101、振幅 1 V、Reference = CH1、DUT = CH2 |
| 表示 | S21 の Log Mag と位相 |

## 見るべき値

計算値。ジャンパ (約 5 cm) の直列インピーダンスは、抵抗分が数十 mΩ、
インダクタンスが約 43 nH (8-3 で計算する経験式と同じ)。負荷 1 kΩ に対して
どちらも無視できるほど小さい。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 100 kHz | ほぼ 0.0000 dB | ジャンパの抵抗・インダクタンスの影響は測定誤差以下 |
| 1 MHz | ほぼ 0.0000 dB | 同上 |
| 10 MHz | −0.0005 dB、位相 −0.15° | 10 MHz でもズレは 1 万分の 1 dB 以下 |

**ジャンパ線 1 本の「スルー」自体はブレッドボードの弱点ではない。** 弱いのは
使っていない列どうしの容量 (8-2) や、ジャンパ自身のインダクタンス
(単体では小さくても、低いインピーダンスの回路に入ると効いてくる。8-3・8-4)。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
