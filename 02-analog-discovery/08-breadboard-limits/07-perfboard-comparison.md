---
book: analog-discovery
chapter: 8
id: 8-7
title: 同じ回路を perfboard で作って比べる
tier: 100
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: [ BB, PF ]
---

# 8-7 同じ回路を perfboard で作って比べる

8-4 で測った RC ローパス (R = 10 kΩ、C = 10 pF) を、**そっくり同じ定数で
perfboard に組み直す**。perfboard は穴が 1 つ 1 つ独立していて、長い金属レール
どうしが並走するブレッドボードと違い、列間容量のような寄生が原理的に小さい。
同じ回路・同じ測り方で、板を変えるとどれだけ理論値に近づくかを比べる。

## 回路図

```circuit
title: 図1 RC ローパス (板に依らない共通の回路)
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 10k
  C1: capacitor c9 c12 10p
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c14
  - c6 -- c9
  - AD.2+ -| c9
  - AD.2- -| c14
  - c12 -- c14
  - AD.GND -| c14
```

R = 10 kΩ、C = 10 pF は 8-4 とまったく同じ値。1+ が入力 (W1)、2+ が出力
(R と C の中点)。この回路自体は板に依らない。

## 実体配線図 (breadboard)

```breadboard
title: 図2 ブレッドボードと Analog Discovery (8-4 と同じ配置)
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
  - AD.W1 -- a5 yellow [h-10]
  - AD.GND -- -t1 black
  - AD.1+ -- b5 white [h10]
  - e10 -- e15 blue
  - AD.1- -- -t11 black
  - AD.2+ -- a15 gray
  - AD.2- -- -t18 black
  - a20 -- -t20 black
```

8-4 と全く同じ配置 (R1 が 5〜10 列、C1 が 15〜20 列)。R1 と C1 の中点を渡す
配線 (10 列→15 列) が、そのまま隣の列との寄生容量を持ち込む。

## 実体配線図 (perfboard)

```perfboard
board: 16x10
title: 図3 perfboard と Analog Discovery
parts:
  R1: resistor f3 f7 10k
  C1: capacitor/ceramic f8 f11 10p
  AD:
    type: device
    at: -c3
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - a3 -- d3 yellow
  - d3 -- f3 yellow
  - AD.1+ -- a5 white
  - a5 -- d5 white
  - d5 -- d3 white
  - AD.2+ -- a7 gray
  - a7 -- f7 gray
  - f7 -- f8 gray
  - AD.GND -- a4 black
  - a4 -- b4 black
  - b4 -- b6 black
  - AD.1- -- a6 black
  - a6 -- b6 black
  - b6 -- b8 black
  - AD.2- -- a8 black
  - a8 -- b8 black
  - b8 -- b11 black
  - b11 -- f11 black
```

- AD の足は板の真上 (3〜8 列) に並べ、それぞれ a 行へまっすぐ降ろす
- R1 (f 行、3〜7 列) と C1 (f 行、8〜11 列) の中点をつなぐ配線は隣の穴へ渡す
  (f7 → f8) だけの最短の 1 本。breadboard のように**長い金属レールと並走する区間が
  無い**ので、隣に寄生が乗る心配がほとんど無い
- GND (1−・2−・AD.GND) は b 行に束ねて、C1 のもう一方の足 (f11) へまとめて配線する。
  この板は穴どうしが独立しているので、配線を引かない限りどこもつながらない
  (breadboard のような「同じ列は自動でつながる」という前提が無い)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Network | 掃引 100 kHz〜10 MHz、点数 101、振幅 1 V、Reference = CH1、DUT = CH2 |
| 表示 | S21 の Log Mag と位相 |

## 見るべき値

計算値。理想 (C = 10 pF のみ) の折れ点は 1.59 MHz (8-4 と同じ)。
breadboard 側は 8-4 の実測相当 (C + 2.5 pF = 12.5 pF、折れ点 1.27 MHz)。
perfboard 側は**列間容量の代わりに隣接パッド間の容量**が乗るが、長い並走区間が
無いぶん一桁小さいと見積もり、0.3 pF (**仮定・目安**) を足した 10.3 pF
(折れ点 1.55 MHz) とする。

| 周波数 | 理論値 (10 pF のみ) | breadboard 相当 (12.5 pF) | perfboard 相当 (10.3 pF) |
| --- | --- | --- | --- |
| 1 MHz | −1.45 dB、−32.1° | −2.09 dB (差 0.64 dB) | −1.52 dB (差 0.07 dB) |
| 10 MHz | −16.07 dB、−81.0° | −17.97 dB (差 1.90 dB) | −16.32 dB (差 0.25 dB) |

**perfboard は breadboard よりも理論値に近い。** 8-4 で見た「板のせいで
理論と実測がずれる」という問題は、板そのものの構造 (長い金属レールが並走
するかどうか) に原因があり、**perfboard に組み替えるだけで寄生の影響が
1/3〜1/8 程度に減る**という見積もりになる。10 MHz でもまだ完全に理論値とは
一致しないので、さらに正確に測るには 8-8 のように同軸コネクタで引き回す
必要がある。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
