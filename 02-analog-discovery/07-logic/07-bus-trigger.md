---
book: analog-discovery
chapter: 7
id: 7-7
title: バスの値でトリガする
tier: 100
source: 自作 (計器の操作は Digilent の Using the Logic Analyzer)
board: BB
---

# 7-7 バスの値でトリガする

Logic の Trigger には Simple (各チャンネルを H・L・立ち上がり・立ち下がりで
個別に条件づける)・Pulse・Protocol の 3 モードがある。7-1 で使った「DIO0 の
立ち上がり」は Simple の 1 本トリガ。**Protocol モードでは複数の DIO をまとめた
Bus を作り、その Bus が特定の値になった瞬間でトリガできる。** ここでは 7-2 と
同じ Pattern + CD4017 の回路で、DIO1〜DIO3 (Q0〜Q2) をまとめた Bus の**値**で
トリガして、4017 が「今どの Q を出しているか」をピンポイントで捕まえる。

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

回路は 7-2 と同じ (**16=VDD・8=GND、13=CE・15=MR は GND に固定して常時
カウント**。14=CLK に Pattern の DIO0、3=Q0・2=Q1・4=Q2 を DIO1〜DIO3 で
観測)。**VDD は Supplies の V+ を 3.3 V にして受ける** (7-2 と同じ理由 —
DIO の H は 3.3 V 固定で、5 V で動かすと VIH に届かない)。

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
    pins: [V+, GND, DIO0, DIO1, DIO2, DIO3]
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

配線も 7-2 と同じ (16=VDD (e12) を +t で電源へ。13=CE・15=MR (上ブロック) を
-t で GND に固定、8=GND (下ブロック) は -b へ。3=Q0・2=Q1・4=Q2 は下ブロック
の空いた行から DIO1〜DIO3 へ。14=CLK (上ブロック) へは Pattern の DIO0 を
`g10 -- d10`・`b10 -- b14` で渡す)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Pattern | DIO0 = Clock、100 Hz、Duty 50% (7-2 と同じ) |
| Logic | DIO1〜DIO3 を選んで Bus1 (3 bit) を作る。**DIO1 を最下位ビットにする (この本の決めごと。DIO1=Q0=bit0、DIO2=Q1=bit1、DIO3=Q2=bit2)**。Trigger モードを Protocol/Bus にして、条件を Bus1 = `2` (2 進で `010`、Q1 だけ H) にする |

## 見るべき値

計算値。Pattern のクロックは 100 Hz (7-2 と同じ)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Bus1 が `2` (Q1 だけ H) になってトリガする間隔 | 100 ms に 1 回 | 4017 は 10 進 — 1 巡 (10 クロック = 100 ms) に Q1 は 1 回しか立たない |
| トリガした瞬間の波形 | Q0 (DIO1) が下がった直後に Q1 (DIO2) が上がる | Bus1 の値が `1`→`2` に変わった瞬間を捕まえている |
| トリガ位置から次に Bus1 が `4` (Q2 だけ H) になるまで | 10 ms 後 | 1 クロック (10 ms) ごとに次の Q へ進む |

**7-1・7-2 のようにエッジだけでトリガすると、10 個の Q のどれで止まったかは
波形を数えて確かめるしかない。Bus の値でトリガすれば「Q1 が立った瞬間」を
1 発で呼び出せる。** これはもっと大きなバス (例えばマイコンのアドレスバス) で
「特定のアドレスが出た瞬間」を捕まえるのと同じ考え方 —
複雑な回路のデバッグで多用する。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
Bus によるトリガは WaveForms のリファレンスマニュア (Logic Analyzer の章)
に基づく。
