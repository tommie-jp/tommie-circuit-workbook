---
book: analog-discovery
chapter: 0
id: 0-8
title: トリガ入出力 (T1 / T2) で 2 台を同期する
tier: 200
source: 自作 (結線と役目は Digilent の Analog Discovery 3 の公式資料と Dual Mode の記事)
board: —
---

# 0-8 トリガ入出力 (T1 / T2) で 2 台を同期する

Analog Discovery 3 (AD3) のオシロは 2 ch しかない。3 か所以上の波形を同じ時刻で比べたいときは、
AD3 を 2 台並べ、**トリガ入出力のピン T1 と T2** で結ぶ。WaveForms はこの 2 台を 1 台の 4 ch の
オシロとして扱える (Dual Mode)。

- **T1** は基準のクロックを渡す。AD3 の Trigger 1 は 10〜50 MHz の外部の基準クロックを受けられ、
  2 台目は 1 台目のクロックで標本化する (Reference Manual の External Clocking の節)
- **T2** はトリガを渡す。1 台目のトリガが T2 に出て、2 台目は同じ瞬間に記録を始める

この題では 1 台目の Wavegen の W1 を 2 台の CH1 に同時に入れ、同じ波が同じ時刻に並ぶかを見る。
T1・T2 を結ばないときとの違いも確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2 台の T1・T2・GND を結び、W1 を両方の CH1 に入れる
parts:
  A:
    type: device
    at: 2,3
    label: AD3 A
    turn: mirror
    pins: [W1, 1+, T1, T2, 1-, GND]
  B:
    type: device
    at: 9,3.25
    label: AD3 B
    pins: [1+, T1, T2, 1-, GND]
  G1: ground 6,4.25
wires:
  - A.W1 -- 4,2.5 -- 4,2.75
  - A.1+ -- 4,2.75
  - 4,2.75 -- B.1+
  - A.T1 -- B.T1
  - A.T2 -- B.T2
  - A.1- -- 5,3.5
  - 5,3.5 -- B.1-
  - 5,3.5 -- 5,3.75
  - A.GND -- 5,3.75
  - 5,3.75 -- 6,3.75
  - 6,3.75 -- B.GND
  - 6,3.75 -- 6,4.25
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/08-trigger-io-dual.svg)

- A が 1 台目、B が 2 台目。A の W1 (1 kHz の正弦波) を、1 台目の 1+ と 2 台目の 1+ の両方に入れる
- T1 は T1 に、T2 は T2 に結ぶ。**GND も必ず結ぶ** (クロストークを減らすため。T1 は GND の線と撚り合わせ、線は短く)
- 両方の 1− は GND につなぐ (0-1 の差動入力)

この題は実体配線図を付けない — 基板を使わず、付属ワイヤどうしを AD3 の付属の 6 ピンのピンヘッダで継ぐ
(W1 と 2 本の 1+ を 1 本のピンヘッダの隣り合うピンに挿し、ピンどうしを短い線で半田付けしておく)。図1 がそのまま結線表になる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Device Manager | 2 台を USB で挿し、**Select + Dual** で 1 台目を選び、2 台目に同じ機種を選ぶ |
| Wavegen (1 台目の W1) | 正弦波、1 kHz、振幅 1 V |
| Scope | 1 台目の CH1 と 2 台目の CH1 (Dual Mode では 2 台目の入力の組が 1 台目の隣に並ぶ) を表示。DC、Range ±2 V 程度。トリガは 1 台目の CH1、立ち上がり、0 V |

Dual Mode の操作の名前は Digilent の記事 (出典) による。WaveForms の版で画面の名前は変わることがある (目安)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 T1・T2 で結ぶと 2 台の CH1 が重なる — 位相差 0°、どちらも Vpp 2.00 V
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V, range: 500mV/div, position: 0.5div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/scope/08-trigger-io-dual.svg)

図2 の ch2 は 2 台目の CH1。重なって見えないよう、基準の位置だけ 0.5 目盛上げてある (尺度は同じ 500 mV/div)。

## 見るべき値

| 確かめる所 | T1・T2 を結んだとき (Dual Mode) | 結ばないとき (2 台を別々の窓で) |
| --- | --- | --- |
| 2 本の波の位相差 | 0° (図2。Measurements の Phase) | 決まらない。2 台が別々にトリガするので、時刻 0 が別々の瞬間になる |
| 2 本の周波数 | どちらも 1.000 kHz (同じクロックで標本化) | 1 台目と 2 台目の発振子の差だけずれた値が出ることがある |
| 1 台目の Run を押す | 2 台目も同時に記録を始める | 2 台目は自分の Run で始まる |

トリガの時刻の分解能は 10 ns (既定の system frequency 100 MHz のとき。Specifications の Trigger System)。
1 kHz の 1 周期 (1 ms) に対しては 1 ms ÷ 10 ns = 10 万分の 1 で、角度にすると 360° × 10 ns × 1 kHz = 0.0036°。
1 kHz では 2 本は重なって見えるはずである。

周波数を上げると残りのずれが見えてくる。Digilent の記事は、クロックが T1 の線を伝わる遅れで、
同期しても 2 台の間に小さな位相差が残ることがあり、トリガの点を拡大して位相のずれを補正するよう勧めている。
ずれを時間 Δt で読めば、位相差は 360° × f × Δt。たとえば Δt が 5 ns なら 1 MHz で 1.8°、10 kHz で 0.018° になる
(5 ns は計算の例で、実機の値ではない)。

AD3 を 3 台以上つなぐ手順と、AD2 と AD3 を混ぜる手順はこの題では扱わない (記事は**同じ機種の 2 台**を対象にしている)。

## LTspice での確かめ (対象外)

回路は配線だけ (W1 を 2 つの入力に分ける) で、算術で確かめた。1 kHz の 1 周期は 1 ms、トリガの分解能 10 ns との比は
1 ms / 10 ns = 100,000、角度は 360 × 10 ns × 1 kHz = 0.0036°。Δt = 5 ns の例は 360 × 1 MHz × 5 ns = 1.8°、
360 × 10 kHz × 5 ns = 0.018°。本文の値と合う。

## 出典

自作。T1 で基準のクロック (10〜50 MHz) を渡すこと、トリガのピンが外からの信号を受け、トリガの母線の信号を出せることは
Digilent の
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(External Clocking・Trigger System の節)。トリガの分解能 10 ns は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Trigger System)。T1 どうし・T2 どうし・GND を結ぶこと、T1 を撚り線にすること、Select + Dual の操作、残る位相差の補正は
[Extending Channel Counts Using Dual Mode with Analog Discovery 3 (DesignSpark に載った Digilent の記事)](https://www.rs-online.com/designspark/extending-channel-counts-using-dual-mode-with-analog-discovery-3)
による。
