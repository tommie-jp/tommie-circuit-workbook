---
book: analog-discovery
chapter: 7
id: 7-2
title: パターンジェネレータでカウンタを叩く
tier: 50
source: 自作 (計器の操作は Digilent の Using the Logic Analyzer)
board: BB
---

# 7-2 パターンジェネレータでカウンタを叩く

**Pattern** (パターンジェネレータ) は DIO から好きな論理波形を出せる計器。
7-1 では 555 の発振で CD4017 を動かしたが、ここでは **Pattern が直接クロックを
作り**、Logic (ロジックアナライザ) で Q0〜Q2 を同時に捕まえる。発振回路が無いぶん
配線は簡単になる。

## 回路図

```circuit
title: 図1 Pattern でクロックを作り 4017 を動かす
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1, DIO2, DIO3]
  U2: dip16 h3 CD4017
wires:
  - AD.V+ -| U2.16
  - AD.GND -| U2.8
  - AD.GND -| U2.13
  - AD.GND -| U2.15
  - AD.DIO0 -| U2.14
  - AD.DIO1 -| U2.3
  - AD.DIO2 -| U2.2
  - AD.DIO3 -| U2.4
```

- 16=VDD、8=GND、**13=CE・15=MR は GND に固定**して常時カウントさせる
- 14=CLK に Pattern の DIO0、3=Q0・2=Q1・4=Q2 を Logic の DIO1〜DIO3 で観測
- **VDD (16 番) は Supplies の V+ を 3.3 V にして受ける。** `DIO` の出力 High は
  3.3 V (LVCMOS3V3) 固定で、CD4017 を 5 V で動かすと VIH (H と認識する下限、
  データシートで 3.5 V) に届かず、クロックが不安定になりうる。VDD も 3.3 V に
  そろえれば CD4017 の VIH は下がり (目安 70% VDD ≈ 2.3 V)、確実に H と読める

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  U2: dip16 @ e12 CD4017
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO1, DIO2, DIO3]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - a12 -- +t12 red
  - a15 -- -t15 black
  - a13 -- -t13 black
  - j19 -- -b19 black
  - AD.DIO0 -- a14 yellow
  - AD.DIO1 -- j14 white
  - AD.DIO2 -- j13 gray
  - AD.DIO3 -- j15 purple
  - -t25 -- -b25 black
```

16=VDD (e12) の列を +t で電源へ。13=CE・15=MR (上ブロック) を -t で GND に固定、
8=GND (下ブロック) は -b から -t へつないで共通にする。14=CLK は Pattern の
DIO0 から直に、3=Q0・2=Q1・4=Q2 は下ブロックの空いた行 (j) から Logic の
DIO1〜DIO3 へ。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V (`DIO` の High と合わせる)、Master Enable を入れる |
| Pattern | DIO0 = Clock、100 Hz、Duty 50% |
| Logic | DIO0〜DIO3 を Enable。Rate は 100 Hz より十分速く (10 kS/s 程度) |

Pattern と Logic は同じ 16 本の DIO を共有する。**DIO0 は出力 (Pattern)、
DIO1〜DIO3 は入力 (Logic)** に設定を分ける。

## 見るべき値

計算値。Pattern のクロックは 100 Hz (周期 10 ms) に設定。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| DIO0 (クロック) の周期 | 10 ms | Pattern の設定どおり |
| DIO1 (Q0) が High の時間 | 10 ms に 1 回 | クロック 1 周期ぶんだけ High |
| DIO1〜DIO3 が順に High になる周期 | 100 ms (10 ms × 10) | 4017 は 10 進 — 10 クロックで 1 周する |
| クロックの立ち上がりから Q が切り替わるまでの遅れ | ほぼ 0 (数十 ns 以下) | 4017 は CLK の立ち上がりで同期して切り替わる |

**7-1 と同じ 4017 の動きだが、クロックが 555 の発振ではなく Pattern の
きっちりした 100 Hz** なので、周期のばらつきが無く読みやすい。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)
(Pattern Generator の節)。
