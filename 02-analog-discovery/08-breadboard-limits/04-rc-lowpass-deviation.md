---
book: analog-discovery
chapter: 8
id: 8-4
title: RC ローパスの理論と実測のずれ (1 MHz と 10 MHz)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 8-4 RC ローパスの理論と実測のずれ (1 MHz と 10 MHz)

8-1〜8-3 で確かめた 2 つの寄生 (列間容量・ジャンパのインダクタンス) を、
実際の RC ローパスに当てはめて、**理論値と実測値がどれだけずれるか**を見る。
R = 10 kΩ・C = 10 pF (理想の折れ点 1.59 MHz) という高いインピーダンスの回路を
選ぶと、8-2 の列間容量 (数 pF) が C 自身と同じ桁になり、ずれが目立つ。

## 回路図

```circuit
title: 図1 RC ローパスと並列に乗る寄生容量
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 10k
  C1: capacitor c9 c12 10p
  Cstray: capacitor f9 f12 2.5p l=$\mathrm{C_{stray}}$
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c14
  - c6 -- c9
  - c6 -- f9
  - AD.2+ -| c9
  - AD.2- -| c14
  - c12 -- c14
  - f12 -- c14
  - AD.GND -| c14
```

- C<sub>stray</sub> は 8-2 で測った**列間の寄生容量**。C1 (10 pF) と並列に乗るので、
  実際に効いている容量は 10 + 2.5 = 12.5 pF — **理論値より 25% も大きい**
- 1+ が入力 (W1)、2+ が出力 (R と C の中点)。1−・2− は GND

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c5 c10 10k
  C1: capacitor/ceramic c15 c20 10p
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 white [h5]
  - a10 -- a15 blue
  - AD.2+ -- b15 gray [h5]
  - AD.1- -- -t8 black
  - AD.2- -- -t18 black
  - c20 -- -t20 black
  - AD.GND -- -t3 black
```

- R1 (10 列) と C1 (15 列) の間を渡す配線が**そのまま 8-2 の「隣の列」**にもなる。
  この図に寄生容量は描かれていない — **描かなくても勝手に乗る**のがブレッドボードの
  限界そのもの
- 1+ は R1 の手前 (5 列)、2+ は R1 と C1 の中点 (15 列)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | 掃引 100 kHz〜10 MHz、点数 101、振幅 1 V、Reference = CH1、DUT = CH2 |
| 表示 | S21 の Log Mag と位相 |

## 見るべき値

計算値。理想 (C = 10 pF のみ) の折れ点 f<sub>c</sub> = 1/(2πRC) = **1.59 MHz**。
実測相当 (C + C<sub>stray</sub> = 12.5 pF) の折れ点は **1.27 MHz**。

| 周波数 | 理論値 (10 pF のみ) | 実測相当 (12.5 pF) | ずれ |
| --- | --- | --- | --- |
| 1 MHz | −1.44 dB、−32.1° | −2.09 dB、−38.1° | 約 0.65 dB、6° |
| 10 MHz | −16.07 dB、−81.0° | −17.97 dB、−82.7° | 約 1.9 dB、2° |

**ジャンパのインダクタンス (8-3) はここではほぼ効かない。** R = 10 kΩ という
高いインピーダンスの前では、数十 nH の直列リアクタンス (10 MHz でも数 Ω) は
無視できるほど小さい。**寄生が効くかどうかは、回路自身のインピーダンスとの
比で決まる** — 高インピーダンス回路は寄生容量に弱く、低インピーダンス回路
(9-1 のような増幅段など) は寄生インダクタンスに弱い。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
