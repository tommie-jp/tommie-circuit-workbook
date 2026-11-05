---
book: analog-discovery
chapter: 4
id: 4-19
title: AM ラジオの IF 455 kHz を見る
tier: 200
source: 自作 (フィルタの規格は Murata CERAFIL のカタログ Cat.No.P05E-16 の CFULA455KE4A-B0)
board: BB
---

# 4-19 AM ラジオの IF 455 kHz を見る

スーパーヘテロダインの AM ラジオ (回路の教科書 9-10) は、受けた局を**中間周波 (IF) 455 kHz** に移してから、セラミックフィルタで
その局だけを通す。IF の信号は「455 kHz の搬送波と ±音の周波数の側波帯」の AM 波で、隣の局は 9 kHz 離れて来る
(日本の中波は 9 kHz おき)。この題では IF の段だけを取り出し、W1 で IF の AM 波を、W2 で隣の局を作ってセラミックフィルタに通し、
**フィルタの前 (CH1) と後 (CH2) のスペクトル**で「その局は通り、隣の局は落ちる」(選択度) を確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 455 kHz の AM (W1) と隣の局 (W2) をセラミックフィルタに通す
parts:
  V1: sine 1,2 1,4 l=$\mathrm{W1}$
  G1: ground 1,4
  R1: resistor 1,2 3,2 3k
  V2: sine 1,6 1,8 l=$\mathrm{W2}$
  G2: ground 1,8
  R2: resistor 1,6 3,6 3k
  M1: voltmeter 4,5 4,7 l=$\mathrm{CH1}$
  G3: ground 4,7
  U1: ceramic-filter 7,4 SFU455B
  G4: ground 7,6
  R3: resistor 10,5 10,7 1.5k
  G5: ground 10,7
  M2: voltmeter 12,5 12,7 l=$\mathrm{CH2}$
  G6: ground 12,7
wires:
  - 3,2 -- 3,4
  - 3,6 -- 3,4
  - 3,4 -- 4,4
  - 4,4 -- U1.IN
  - 4,4 -- 4,5
  - U1.GND -- 7,6
  - U1.OUT -- 10,4
  - 10,4 -- 10,5
  - 10,4 -- 12,4 -- 12,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/circuit/19-am-radio-if-455k.svg)

- W1・W2 を 3 kΩ ずつで足すと、フィルタから見た信号源の抵抗は 3 kΩ ∥ 3 kΩ = 1.5 kΩ (Ω はオーム) になる。出口の R3 も 1.5 kΩ で、
  455 kHz のセラミックフィルタの規格の終端 (入出力 1.5 kΩ) に合わせた
- 通過帯域では、フィルタの入力も 1.5 kΩ に見える。CH1 の電圧は W の開放の半分 (足し算) のさらに半分 (終端) で、W 1 V のとき 0.25 V
- AD3 の Wavegen の 455 kHz・464 kHz は 3 MHz 以下で、ブレッドボードの範囲に入る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery 3 (下半分だけ使う)
board: half
parts:
  U1: sip3 @ f12 SFU455B
  R1: resistor g5 g12 3k
  R2: resistor i12 i20 3k
  R3: resistor g14 g18 1.5k
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [W1, 1+, 2+, W2, GND, 1-, 2-]
wires:
  - AD.W1 -- j5 yellow
  - AD.1+ -- j12 orange
  - AD.2+ -- j14 blue
  - AD.W2 -- j20 green
  - AD.GND -- -b22 black
  - AD.1- -- -b24 black
  - AD.2- -- -b26 black
  - j13 -- -b13 black
  - j18 -- -b18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/breadboard/19-am-radio-if-455k.svg)

- U1 (SFU455B) は 12〜14 列に `IN` `GND` `OUT` の順で挿す。ピンの並びは型番の資料で確かめてから挿す
- W1 (黄) は 5 列から R1 で 12 列 (IN) へ、W2 (緑) は 20 列から R2 で 12 列へ。CH1 (1+、橙) は 12 列
- R3 は 14 列 (OUT) から 18 列、18 列から下の − レールへ。CH2 (2+、青) は 14 列。13 列 (GND) も − レールへ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Carrier Sine **455 kHz**、Amplitude 1 V。AM: Modulation Sine 1 kHz、Depth 50% (3-3)。W2: Sine **464 kHz**、Amplitude 1 V (隣の局の搬送波) |
| Scope | CH1: 200 mV/div、CH2: 100 mV/div。Time 200 µs/div。Trigger: CH1 |
| Spectrum | Source: Channel 1、次に Channel 2。**Start 449 kHz、Stop 469 kHz**、FFT 点数 32768、Window: Flat-top。単位: dBm |

フィルタの規格は CFULA455KE4A-B0 の値 (中心 455 ± 1.5 kHz、6 dB 幅 ±7.5 kHz 以上、40 dB 幅 ±15 kHz 以下、挿入損失 6.0 dB 以下) で計算した。
**SFU455B の帯域と入出力のインピーダンスは資料で確かめられなかったので、同じ程度と仮定する** (実機で CH1 と CH2 の比を測って確かめる)。
464 kHz (中心から 9 kHz) の減衰は、規格の 2 点 (7.5 kHz で 6 dB・15 kHz で 40 dB) の間を dB で直線に結んで **12.8 dB** と見積もった (目安)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 フィルタの前 (CH1) — 455 kHz の AM と 464 kHz の隣の局が同じ高さ
device: ad3
sweep: 449kHz-469kHz
samples: 32768
window: flattop
unit: dBm
ref: 10dBm
signal:
  - sine 455kHz 0.25V
  - sine 454kHz 0.0625V
  - sine 456kHz 0.0625V
  - sine 464kHz 0.25V
markers: [455kHz, 454kHz, 456kHz, 464kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/19-am-radio-if-455k-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図4 フィルタの後 (CH2) — その局は 6 dB 下がるだけ、隣の局はさらに 12.8 dB 下 (目安)
device: ad3
sweep: 449kHz-469kHz
samples: 32768
window: flattop
unit: dBm
ref: 10dBm
signal:
  - sine 455kHz 0.125V
  - sine 454kHz 0.03125V
  - sine 456kHz 0.03125V
  - sine 464kHz 0.0286V
markers: [455kHz, 454kHz, 456kHz, 464kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/spectrum/19-am-radio-if-455k-2.svg)

図3 の 464 kHz の高さは、通過帯域の外でもフィルタの入力が 1.5 kΩ と仮定した目安 (外れると高さが変わる)。図4 は挿入損失を規格の上限 6 dB とした。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図5 時間で見ると — CH1 は 2 局が重なって 9 kHz でうなり、CH2 はほぼ 1 kHz の AM だけ
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: "= 0.25V * (1 + 0.5 * cos(2 * pi * 1kHz * t)) * cos(2 * pi * 455kHz * t) + 0.25V * cos(2 * pi * 464kHz * t)", range: 200mV/div}
ch2: {wave: "= 0.125V * (1 + 0.5 * cos(2 * pi * 1kHz * t)) * cos(2 * pi * 455kHz * t) + 0.0286V * cos(2 * pi * 464kHz * t)", range: 100mV/div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/04-spectrum/scope/19-am-radio-if-455k.svg)

CH2 は CH1 の半分の目盛 (100 mV/div) で描いた。CH1 のエンベロープは隣の局とのうなり (9 kHz) で大きく揺れ、AM の 1 kHz が読めない。CH2 では 1 kHz のエンベロープ (3-3 の AM) がほぼそのまま見え、
9 kHz の小さな揺れが残る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 455 kHz セラミックフィルタ | SFU455B (村田)。CFULA455KE4A でもよい。入出力は 1.5 kΩ と仮定 |
| R1, R2 | 抵抗 (2 つの信号を足す。並列で信号源の 1.5 kΩ) | 3 kΩ |
| R3 | 抵抗 (出口の終端) | 1.5 kΩ |
| — | 信号源・計器 | AD3 の W1・W2 (振幅 1 V。流れる電流は 0.3 mA 以下)、Scope 1+・2+ |

## 見るべき値

計算値。CH1 の通過帯域の値は「W の振幅 × 1/2 (足し算) × 1/2 (終端)」、CH2 はそれに挿入損失 6 dB (仮定) と、帯域の外ではフィルタの減衰を掛けた。

| 線 | 周波数 | CH1 (前) | CH2 (後) | CH1 → CH2 |
| --- | --- | --- | --- | --- |
| 搬送波 | 455 kHz | 0.25 V (−2.04 dBm) | 0.125 V (−8.06 dBm) | −6.0 dB (挿入損失) |
| 側波帯 | 454・456 kHz | 62.5 mV (−14.08 dBm) | 31.3 mV (−20.10 dBm) | −6.0 dB |
| 隣の局 | 464 kHz | 0.25 V (−2.04 dBm、目安) | 28.6 mV (−20.9 dBm、目安) | −18.8 dB (6.0 + 12.8) |
| 隣の局と目当ての局の差 | — | 0 dB | 12.8 dB | フィルタの選択度 (目安) |

分かること:

- **IF の AM 波は、搬送波と ±音の周波数の側波帯でできている**。音の帯域 (±1 kHz) はフィルタの通過帯域 (±7.5 kHz) の中なので、形を変えずに通る
- **9 kHz 隣の局は 1 段のフィルタで 10 dB あまりしか落ちない** (目安)。ラジオは IF の段を 2〜3 段にし (IF トランスも帯域を絞る)、
  合わせて 30 dB ほどの選択度を作る。帯域を狭くしすぎると、今度は高い音 (側波帯の外側) が削られる
- 変調を 1 kHz から 5 kHz・7 kHz に上げると、側波帯がフィルタの肩に近づいて下がり始める。AM ラジオの音が 5 kHz ほどで頭打ちになるのは、
  局の間隔 (9 kHz) とこのフィルタの幅で決まっている
- 回路の教科書 9-10 のラジオがあれば、IF トランスの 2 次側を CH1 で同じ設定で見ると、受けている局の搬送波が 455 kHz に立つ

## LTspice での確かめ

`sim/19-if-455k-terminations.cir` で、W1・W2 を 3 kΩ ずつで足し、フィルタの入力を通過帯域の 1.5 kΩ に置き換えた回路を .ac で解いた。
セラミックフィルタそのものの SPICE の模型は無いので、フィルタの減衰は規格の値からの算術 (目安) で、LTspice では確かめていない。

| 項目 | 本文の数字 | LTspice・算術 | 判定 |
| --- | --- | --- | --- |
| CH1 の搬送波 (W1 1 V) | 0.25 V | 0.2498 V (LTspice、CH1 の 1 MΩ を含む) | 合う |
| フィルタから見た信号源の抵抗 | 1.5 kΩ | 3 kΩ ∥ 3 kΩ = 1.5 kΩ (算術) | 合う |
| 側波帯 (深さ 50%) | 搬送波の 1/4 | 0.5 ÷ 2 = 0.25 (算術、4-7) | 合う |
| 464 kHz の減衰 | 12.8 dB (目安) | 6 + (40 − 6) × (9 − 7.5) ÷ (15 − 7.5) = 12.8 dB (算術) | 合う (規格の間を直線で結んだ見積もり) |

## 出典

自作。フィルタの規格は Murata の CERAFIL のカタログ (Cat.No.P05E-16、CFULA455KE4A-B0) の値で、NanoVNA の教科書 6-12 と同じ。
IF の段の位置づけは回路の教科書 9-10 (スーパーヘテロダイン)。

参考: [スーパーヘテロダイン受信機 (Wikipedia)](https://ja.wikipedia.org/wiki/スーパーヘテロダイン受信機)、[中波放送 (Wikipedia)](https://ja.wikipedia.org/wiki/中波放送)
