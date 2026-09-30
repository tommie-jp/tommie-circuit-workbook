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
同じ回路・同じ測り方で、板を変えると寄生の分がどれだけ変わるかを比べる。
出力を読む AD3 の CH2 入力容量 (24 pF) はどちらの板にも同じだけ乗るので、共通の土台として
先に数に入れる (8-4)。

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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/07-perfboard-comparison.svg)

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/07-perfboard-comparison.svg)

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

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/perfboard/07-perfboard-comparison.svg)

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

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB、5-8) を超えるので、この題は
**BNC アダプタを付けて**測る (Scope 30+ MHz、Wavegen 12 MHz @ −3 dB)。CH1 を基準にした比を
読むので、2 つのチャンネルが同じ帯域を持つ限り、帯域の影響は小さい (目安)。

## 見るべき値

計算値。理想 (C = 10 pF のみ) の折れ点は 1.59 MHz (8-4 と同じ)。
どちらの板にも AD3 の入力容量 24 pF が乗る (共通)。
breadboard 側は 8-4 の実測相当 (10 + 2.5 + 24 = 36.5 pF、折れ点 436 kHz)。
perfboard 側は**列間容量の代わりに隣接パッド間の容量**が乗るが、長い並走区間が
無いぶん一桁小さいと見積もり、0.3 pF (**仮定・目安**) を足した 34.3 pF
(10 + 0.3 + 24、折れ点 464 kHz) とする。

| 周波数 | 理論値 (10 pF のみ) | breadboard 相当 (36.5 pF) | perfboard 相当 (34.3 pF) |
| --- | --- | --- | --- |
| 1 MHz | −1.45 dB、−32.1° | −7.97 dB、−66.4° | −7.52 dB、−65.1° |
| 10 MHz | −16.07 dB、−81.0° | −27.22 dB、−87.5° | −26.68 dB、−87.3° |

2 枚の板の差は 1 MHz で約 0.45 dB、10 MHz で約 0.5 dB。どちらも理論値 (10 pF のみ) との
差 (6〜11 dB) に比べるとずっと小さい。

```graph
title: 図4 入力容量 24 pF が共通の土台で、板の差 (36.5 pF と 34.3 pF) はその上の小さい差
x: 周波数 Hz log 100k..10M
y: 利得 dB -30..0
lines:
  理論 10 pF dB: -10*log10(1+(2*pi*x*10k*10p)^2)
  breadboard 36.5 pF dB: -10*log10(1+(2*pi*x*10k*36.5p)^2)
  perfboard 34.3 pF dB: -10*log10(1+(2*pi*x*10k*34.3p)^2)
notes:
  - mark 1M
  - mark 10M
  - level -3dB
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/07-perfboard-comparison.svg)

**perfboard は breadboard より板の寄生が小さい。** 板の寄生の見積もりは
2.5 pF から 0.3 pF (仮定) へ、約 1/8 に減る。ただし**この回路では計器の入力容量
(24 pF) のほうがずっと大きい**ので、Network の曲線の上では板の差は 0.5 dB ほどしか
出ない。板の差を大きく見たいときは、入力容量の小さい測り方 (10:1 プローブなど)
に替えるか、8-2 の挿す・抜くの差で寄生だけを取り出す。さらに正確に測るには
8-8 のように同軸コネクタで引き回す必要がある。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
