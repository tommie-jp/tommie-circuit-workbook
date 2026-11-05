---
book: analog-discovery
chapter: 3
id: 3-15
title: 出力の帯域 (12 MHz) — 10 MHz の方形波はどう見えるか
tier: 200
source: 自作 (帯域の数値は Digilent の Analog Discovery 3 の公式仕様)
board: —
---

# 3-15 出力の帯域 (12 MHz) — 10 MHz の方形波はどう見えるか

Wavegen の Frequency には 10 MHz の Square も打ち込める。しかし出てくる波は方形ではない。
AD3 の Wavegen の帯域は BNC アダプタ有りで **12 MHz (−3 dB)** なので (付属ワイヤだけなら 9 MHz)、
方形波を作る 3 倍・5 倍の高調波 (30 MHz・50 MHz) がほとんど通らず、基本波の正弦に少しの高調波が乗っただけの形になる。
同じ経路に 1 MHz の方形波と 10 MHz の正弦を通して比べ、「どの周波数までなら方形波として使えるか」を数で決める。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ループバック (W1 を 1+ に直結、BNC アダプタと同軸)
parts:
  V1: square 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/15-output-bandwidth-10mhz-square.svg)

実体配線図は載せない。BNC アダプタの W1 の BNC と CH1 の BNC を 50 cm ほどの同軸ケーブル 1 本で結ぶだけで、基板を使わない (付属ワイヤで結ぶなら 3-3 の図2 と同じ)。
BNC アダプタの W1 の出力ジャンパは 0 Ω 側 (0-6 と同じ)、CH1 は 1 MΩ のまま終端しない。ケーブルが短いので反射は無視する (目安)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: **Square 10 MHz** → **Square 1 MHz** → **Sine 10 MHz**、Amplitude 1 V、Offset 0 V |
| Scope | CH1: DC 結合、Range 500 mV/div、Time 20 ns/div (1 MHz のときは 200 ns/div)。トリガ CH1 立ち上がり 0 V。Measure に Peak2Peak・Rise Time・Frequency |

経路は W1 (12 MHz) と Scope (BNC アダプタ有りで 30 MHz) の 2 段で、それぞれを 1 次のローパスと仮定して描く
(時定数 τ (タウ) = 1/(2π × 12 MHz) = 13.3 ns と 1/(2π × 30 MHz) = 5.3 ns)。0-6 と同じ考え方で、実機の角はこれより複雑に崩れる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 10 MHz の Square (CH1) は 1.85 Vpp、Sine (CH2) は 1.46 Vpp
time: 20ns/div
trigger: ch1 rising 0V
ch1: {wave: square 10MHz 1V | rc 13.26ns | rc 5.305ns, range: 500mV/div}
ch2: {wave: sine 10MHz 1V | rc 13.26ns | rc 5.305ns, range: 500mV/div}
measure: [vpp, rise, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/15-output-bandwidth-10mhz-square-1.svg)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 MHz の Square は角が立ち、立ち上がりは約 33 ns
time: 200ns/div
trigger: ch1 rising 0V
ch1: {wave: square 1MHz 1V | rc 13.26ns | rc 5.305ns, range: 500mV/div}
measure: [vpp, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/15-output-bandwidth-10mhz-square-2.svg)

## 見るべき値

計算値 (2 段の 1 次ローパスの模型)。方形波の振幅 1 V のフーリエ級数は (4/π)(sin ωt + sin 3ωt / 3 + sin 5ωt / 5 + …) で、
各成分に経路の利得を掛けて足すと形が出る。

| 成分 (10 MHz の方形波) | 元の振幅 | 経路の利得 | 出てくる振幅 |
| --- | --- | --- | --- |
| 基本波 10 MHz | 1.273 V | 0.729 | 0.928 V |
| 3 倍 30 MHz | 0.424 V | 0.263 | 0.112 V |
| 5 倍 50 MHz | 0.255 V | 0.120 | 0.031 V |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 10 MHz の Square の Vpp | 1.85 V (2.00 V の 93 %) | 基本波 0.928 V に、遅れた 3 倍の高調波 0.112 V が乗る。山が後ろへ傾いた「サメのひれ」の形 (図2) |
| 同じく立ち上がり (10 → 90 %) | 約 29 ns | 半周期 50 ns の 6 割が立ち上がりで、平らな所がほとんど残らない |
| 10 MHz の Sine の Vpp | 1.46 V (利得 0.729 = −2.7 dB) | 正弦は高調波を持たないので、利得がそのまま見える |
| 1 MHz の Square の Vpp | 2.00 V | 半周期 500 ns は τ の 40 倍近く。立ち切ってから次の段が来る |
| 1 MHz の Square の立ち上がり | 約 33 ns | 経路の立ち上がり時間 √(29.2<sup>2</sup> + 11.7<sup>2</sup>) ≈ 31 ns に近い (2-10・2-24) |
| 経路全体の −3 dB | 約 10.6 MHz | W1 の 12 MHz と Scope の 30 MHz の重なりで、12 MHz より低い |

分かること:

- **方形波として使える上限は、立ち上がり時間が半周期の 1 割ほどに収まる周波数**で、ここでは 31 ns × 10 × 2 の逆数の約 1.6 MHz
  (目安の決め方。1 割を 2 割に緩めれば約 3 MHz)。10 MHz の Square は方形波ではなく、10 MHz の正弦に高調波が少し乗ったものと思って使う
- Wavegen の速さには帯域のほかに**スルーレート 400 V/µs** (仕様、10 V の段) の上限がある。Amplitude 1 V の段 (2 V) は
  帯域で決まる傾き 2 V / 13.3 ns ≈ 150 V/µs で上限の内側だが、Amplitude 5 V (10 Vpp) では帯域の傾きが 750 V/µs になり、
  スルーレートが効いて立ち上がりが 25 ns 以上の直線になる (**未確認**)
- 標本化は 125 MS/s で、10 MHz の 1 周期は 12.5 点しかない。角を点の上にどう並べるか (周期ごとに揺れるか) は公開されておらず**未確認**。
  Persistence (2-7) で角の揺れを見ておくとよい
- 付属ワイヤだけ (W1 も Scope も 9 MHz) だと経路の −3 dB は約 5.8 MHz (0-5) まで下がり、10 MHz の Square はさらに小さい正弦になる

## LTspice での確かめ

`sim/15-output-bandwidth-10mhz.cir` (過渡解析) と `sim/15-output-bandwidth-10mhz-ac.cir` (交流解析) で、−3 dB 12 MHz と 30 MHz の
1 次ローパスをバッファで 2 段に重ねた模型に、振幅 1 V の方形波と正弦を通した。模型は仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 10 MHz の Square の Vpp | 1.85 V | 1.851 V | 合う |
| 10 MHz の Square の立ち上がり | 約 29 ns | 28.8 ns | 合う |
| 10 MHz の利得 (Sine の Vpp) | 0.729 (1.46 V) | 0.7288 | 合う |
| 30 MHz・50 MHz の利得 | 0.263・0.120 | 0.2626・0.1201 | 合う |
| 1 MHz の Square の Vpp・立ち上がり | 2.00 V・約 33 ns | 2.000 V・32.7 ns | 合う |
| 経路全体の −3 dB | 約 10.6 MHz | 10.59 MHz | 合う |

## 出典

自作。帯域とスルーレートは Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Arbitrary Waveform Generator の Bandwidth・Slew Rate、BNC アダプタ有り・無しの 2 列)。計器の名前と操作は
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
参考: [矩形波 (Wikipedia)](https://ja.wikipedia.org/wiki/矩形波)
