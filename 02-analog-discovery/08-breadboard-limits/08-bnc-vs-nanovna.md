---
book: analog-discovery
chapter: 8
id: 8-8
title: 同じスルーを BNC で 25 MHz まで、NanoVNA で 1〜100 MHz
tier: 100
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: PF
---

# 8-8 同じスルーを BNC で 25 MHz まで、NanoVNA で 1〜100 MHz

perfboard に端面 SMA を 2 つ載せただけの「スルー治具」——**NanoVNA の教科書の
3-3 と同じ物**——を、まず AD3 に BNC アダプタ経由でつないで 25 MHz まで測り、
続けて同じ治具を NanoVNA につなぎ替えて 1〜100 MHz まで測る。2 つの計器が
重なる範囲 (1〜25 MHz) で値が揃うかどうかが、この治具を橋渡しに使ってよい
かどうかの確認になる。**10 MHz より上を測るときの本命は NanoVNA** — ここから先は
NanoVNA の教科書で続ける。

## 回路図

```circuit
title: 図1 SMA スルー治具を AD の BNC 入力へ
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  J1: sma c5 mirror
  J2: sma c10
  G1: ground e5
  G2: ground e10
  G3: ground c14
notes:
  - text a5 center: P1
  - text a10 center: P2
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - c3 -- J1.1
  - J1.1 -- J2.1
  - J2.1 -- c12
  - AD.2+ -| c12
  - AD.1- -| c14
  - AD.2- -| c14
  - AD.GND -| c14
  - J1.2 -- e5
  - J2.2 -- e10
```

- J1 (P1) が入力側、J2 (P2) が出力側。AD の BNC アダプタ経由の配線なので、
  1+・2+ の名前は BNC を挟んでも変わらない (0-5 で確かめたとおり)
- 中身は単なる導通 (スルー)。J1 と J2 の中心導体を結ぶ横線が治具の線 (実体配線図の
  e 行)。理想値は S21 = 0 dB
- NanoVNA へつなぎ替えるときは、この図の AD を外して NanoVNA の CH0 を P1、
  CH1 を P2 に直結する (SMA なのでアダプタ不要)

## 実体配線図

治具そのものは NanoVNA の教科書の 3-3 と同じ perfboard (端面 SMA 2 つ、
中心導体どうしを 1 本の線でつなぐだけ)。**1 度作れば両方の計器で使い回す。**

```perfboard
board:
  size: 16x8
  slots: on
title: 図2 perfboard の SMA スルー治具
points:
  GND: h2
parts:
  J1: sma/female-edge e1 d0 f0
  J2: sma/female-edge e16 d17 f17
wires:
  - e1 -- e16
  - f0 -- f2 black
  - f2 -- GND black
  - f17 -- f15 black
  - f15 -- h15 black
  - h15 -- GND black
```

- J1 (P1) が e1、J2 (P2) が e16。中心導体どうしを e 行 1 本でつなぐだけの、
  部品を挟まない「素通し」の治具
- AD へは BNC-SMA 変換アダプタ経由、NanoVNA へは SMA ケーブルで直結する

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| AD Network | BNC アダプタ (W1 側ジャンパは 50 Ω 側にして NanoVNA と条件を揃える)。掃引 100 kHz〜25 MHz、点数 101、振幅 1 V、Reference = CH1、DUT = CH2 |
| NanoVNA | 掃引 1 MHz〜100 MHz、点数 101。校正は SOLT (Open / Short / Load / Thru を P1・P2 の SMA 面で)。表示 S21 の Log Mag |

## 見るべき値

計算値。治具の中心導体 (e1〜e16、15 穴 ≒ 38.1 mm) を経験式 (8-3 と同じ) で
見積もったインダクタンスは約 30.7 nH。

| 周波数 | AD (1 MΩ 入力、電圧比) | NanoVNA (50 Ω 系、真の S21) |
| --- | --- | --- |
| 1 MHz | 0.00 dB (差は測定限界以下) | −0.00 dB |
| 10 MHz | 0.00 dB (同上) | −0.0016 dB |
| 25 MHz | 0.00 dB (同上、AD の上限) | −0.0101 dB |
| 100 MHz | 測れない (AD の範囲外) | **−0.16 dB** |

**AD の読みは 25 MHz まで数字の上ではほぼ完璧に 0 dB のまま動かない。** これは
治具が優秀だからというより、**AD の入力が 1 MΩ と高いせいで、治具のわずかな
インダクタンス (数十 nH) の影響がほとんど埋もれてしまう**ため — AD の
Network アナライザは 50 Ω の系ではなく、高い入力インピーダンスでの電圧比を
測っている。NanoVNA は本物の 50 Ω の系で測るので、同じインダクタンスが
S21 の低下としてそのまま見える。**1〜25 MHz の重なる範囲では、AD の
「ほぼ 0 dB」と NanoVNA の「ほぼ 0 dB」が矛盾なく一致する**ので橋渡しとして
使えるが、**治具の限界そのものを追い詰めるには NanoVNA が要る** —
これがそのまま NanoVNA の教科書の 3-6 (治具の限界周波数) につながる。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
治具は NanoVNA の教科書の 3-3 (スルー治具) と同じもの。
