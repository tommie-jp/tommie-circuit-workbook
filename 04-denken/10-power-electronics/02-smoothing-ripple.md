---
book: denken
chapter: 10
id: 10-2
title: 平滑コンデンサとリップル
tier: 50
source: 自作
board: BB
---

# 10-2 平滑コンデンサとリップル

10-1 の全波整流の出力に大きなコンデンサを並列に入れると、山と山の間を
コンデンサが電気を出して埋め、電圧の落ち込み (リップル) が小さくなる。
リップルの大きさと、負荷電流・容量・周波数の関係を確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vpp ≒ Iload / (f_ripple × C) | リップルの peak-to-peak。負荷電流が大きい・容量が小さいほど増える |
| f_ripple = 2f (全波) | 全波整流のリップル周波数は電源周波数の 2 倍 |
| Vdc ≒ Vpeak − Vpp / 2 | 平均の直流電圧は、山の電圧からリップルの半分を引いた値に近い |

## 回路図

```circuit
title: 図1 全波整流にコンデンサを足す
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  D2: diode e10 c13 1N4148
  D3: diode e16 c13 1N4148
  D4: diode g13 e10 1N4148
  D5: diode g13 e16 1N4148
  C1: ecap c15 g15 100u
  M1: voltmeter c17 g17 l=$\mathrm{CH1}$
  RL: resistor c19 g19 1.5k
  G1: ground g1
wires:
  - c1 -- a1 -- a10 -- e10
  - g1 -- i1 -- i16 -- e16
  - c13 -- c15 -- c17 -- c19
  - g13 -- g15 -- g17 -- g19
```

- 10-1 の全波整流ブリッジ (D2〜D5) と同じ形。出力に C1 (100 µF) を並列に足す
- RL (1.5 kΩ) が負荷。CH1 (M1) は C1・RL の両端を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (コンデンサ入り)
board: half
parts:
  D2: diode a5(A) a12(K) 1N4148
  D3: diode c9(A) c12(K) 1N4148
  D4: diode e16(A) e5(K) 1N4148
  D5: diode d16(A) d9(K) 1N4148
  C1: capacitor/electrolytic b12(+) b16(-) 100u
  RL: resistor a20 a25 1500
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b9 black
  - AD.1+ -- d12 orange
  - e12 -- a20 orange [h30]
  - AD.1- -- c16 black
  - a16 -- a25 black [h30]
```

- 10-1 の図3 と同じブリッジ (D2〜D5)。12 列 (+) と 16 列 (−) の間に電解
  コンデンサ C1 を足し、その先に負荷 RL (20・25 列) をつなぐ
- CH1 (1+/1−) は 12 列・16 列 (C1 と RL の両端) にあてる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、50 Hz、Amplitude 5 V |
| Scope | CH1 = C1・RL の両端。Time/div は 5 ms 程度でリップルの山谷が見える範囲に |
| Measure | CH1 の Average (Vdc) と Peak-Peak (リップル Vpp) |

## 見るべき値

計算値。ダイオードの順電圧 (2 個分 1.2 V) を考えた近似。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 山の電圧 (Vpeak ≒ 5 − 1.2) | 約 3.8 V | コンデンサが充電される最大値 |
| リップル Vpp (Iload ≒ 2.5 mA、f_ripple = 100 Hz) | 約 0.25 V | Vpp = 2.5 mA ÷ (100 Hz × 100 µF) |
| Vdc (= Vpeak − Vpp/2) | 約 3.67 V | C1 が無いとき (10-1) の 2.42 V よりずっと平らで高い |
| C1 を 10 µF に替えたとき | 約 2.5 V ぶんリップルが拡大 | 容量を 1/10 にするとリップルは 10 倍 (式のとおり) |

コンデンサが無い 10-1 では出力が 0 まで落ち込んでいたが、C1 を入れると谷が
浅くなり、平均値 (Vdc) も持ち上がる。100 µF を 10 µF に替えると、リップルが
目に見えて大きくなることも確かめておく。

## 出典

自作。
