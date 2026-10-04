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
  U2: dip16 d5 CD4017 r180
  VCC: vcc c2
  G4: ground d4b0c0 r90
  G5: ground d4g0 r90
  G6: ground c7b0g0 r270
  AD:
    type: device
    at: d11c0e0
    label: Analog Discovery
    pins: [V+, DIO0, DIO3, DIO1, DIO2, GND]
  VCC: vcc b10
  G7: ground f10
wires:
  - a3 |- U2.14
  - a3 -- a9
  - a9 |- AD.DIO0
  - U2.13 -| d4b0c0
  - U2.15 -| d4g0
  - U2.16 -| c2
  - U2.8 -| c7b0g0
  - AD.V+ -| b10
  - AD.GND -| f10
  - U2.4 -| AD.DIO3
  - U2.3 -| AD.DIO1
  - U2.2 -| AD.DIO2
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/02-pattern-counter.svg)

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
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, DIO0, DIO2, DIO1, DIO3]
wires:
  - AD.V+ -- +b8 red
  - AD.GND -- -b9 black
  - AD.DIO0 -- j10 yellow
  - d10 -- g10 yellow
  - b10 -- b14 yellow
  - AD.DIO1 -- j14 white
  - AD.DIO2 -- j13 gray
  - AD.DIO3 -- j15 purple
  - j19 -- -b19 black
  - a12 -- +t12 red
  - a13 -- -t13 black
  - a15 -- -t15 black
  - +t22 -- +b22 red
  - -t23 -- -b23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/02-pattern-counter.svg)

16=VDD (e12) の列を +t で電源へ。13=CE・15=MR (上ブロック) を -t で GND に固定、
8=GND (下ブロック) は -b へ。AD は板の下に置き、V+・GND を下のレールへ入れて、
上のレールとは 22・23 列で渡す。3=Q0・2=Q1・4=Q2 は下ブロックの空いた行 (j) から
Logic の DIO1〜DIO3 へ。14=CLK (上ブロック) へは Pattern の DIO0 を空いた 10 列
(j10) に入れ、溝を跨いで (`g10 -- d10`) `b10 -- b14` で渡す (DIP の胴を
配線で覆わないため)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V (`DIO` の High と合わせる)、Master Enable を入れる |
| Pattern | DIO0 = Clock、100 Hz、Duty 50% |
| Logic | DIO0〜DIO3 を Enable。Rate は 100 Hz より十分速く (10 kS/s 程度) |

Pattern と Logic は同じ 16 本の DIO を共有する。**DIO0 は出力 (Pattern)、
DIO1〜DIO3 は入力 (Logic)** に設定を分ける。

AD の Scope にクロック (CH1) と Q0 (CH2) を入れると、Logic で見る波形を電圧で確かめられる。

```scope
title: 図3 Q0 (CH2) はクロック (CH1) 10 周期に 1 回、1 周期ぶんだけ H
time: 20ms/div
trigger: ch2 rising 1.65V at -4div
ch1: {wave: square 100Hz 1.65V offset 1.65V, range: 1V/div, position: 0.5div}
ch2: {wave: pulse 10Hz 1.65V offset 1.65V duty 10%, range: 1V/div, position: -3.5div}
cursors: [0, 100ms]
measure: [period, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/02-pattern-counter.svg)

2 本を同じ 1 V/div で上下に分けて並べた (重ねると H と L が見分けにくいため)。

## 見るべき値

計算値。Pattern のクロックは 100 Hz (周期 10 ms) に設定。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| DIO0 (クロック) の周期 | 10 ms | Pattern の設定どおり |
| DIO1 (Q0) が High の時間 | 10 ms に 1 回 | クロック 1 周期ぶんだけ High |
| DIO1〜DIO3 が順に High になる周期 | 100 ms (10 ms × 10) | 4017 は 10 進 — 10 クロックで 1 周する |
| クロックの立ち上がりから Q が切り替わるまでの遅れ | 数百 ns (データシートの 5 V で 0.3 µs ほど、3.3 V ではもっと長い。目安)。10 kS/s の Logic (100 µs 刻み) では 0 に見える | 4017 は CLK の立ち上がりで同期して切り替わる |

**7-1 と同じ 4017 の動きだが、クロックが 555 の発振ではなく Pattern の
きっちりした 100 Hz** なので、周期のばらつきが無く読みやすい。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)
(Pattern Generator の節)。
