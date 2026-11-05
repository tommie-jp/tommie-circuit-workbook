---
book: analog-discovery
chapter: 8
id: 8-11
title: 長いワイヤのアンテナ効果 (放送波の混入)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-11 長いワイヤのアンテナ効果 (放送波の混入)

ブレッドボードの入力の列に長いワイヤを挿したまま、先を何にもつながずに放っておくと、
そのワイヤは**中波のアンテナ**になる。周りには中波放送の電波 (531〜1602 kHz) が来ていて、
ワイヤに数 mV の電圧を起こす。入力のインピーダンスが高い (Scope の 1 MΩ (メガオーム) など) と、
それがほとんどそのまま入力に乗る。

ここでは何もつながないワイヤを 1 本、入力の列に挿して、**AD3 の Spectrum** で放送波の線を探す。
ワイヤの長さ (10 cm と 1 m) と、入力の列を 1 kΩ (キロオーム) で GND に落とす (終端する) かどうかで、
混入の大きさがどう変わるかを比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ワイヤのアンテナの等価回路 (誘起電圧 e とワイヤの容量 Cant)
parts:
  E1: sine 2,3 2,6 l=$e$
  Cant: capacitor 3,3 6,3 10p l=$\mathrm{C_{ant}}$
  RT: resistor 7,3 7,6 1k l=$\mathrm{R_T}$
  M1: voltmeter 9,3 9,6 l=$\mathrm{CH1}$
  G1: ground 7,6
wires:
  - 2,3 -- 3,3
  - 6,3 -- 7,3
  - 7,3 -- 9,3
  - 2,6 -- 7,6
  - 7,6 -- 9,6
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/11-wire-antenna.svg)

- e と C<sub>ant</sub> は部品ではなく、ワイヤを電波の中に置いたときの等価回路。e は放送波の電界がワイヤに起こす電圧
  (電界 × 実効高。短いワイヤの実効高は長さのおよそ半分)、C<sub>ant</sub> はワイヤと周り (GND・机・床) の間の容量
- R<sub>T</sub> は終端の抵抗。**はじめは挿さずに測り**、次に挿して測り直す
- CH1 (Scope の 1+) の入力は 1 MΩ ∥ 24 pF で、R<sub>T</sub> が無いときはこれが節点の負荷になる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 10 列にワイヤを挿して先を開放にする。RT は 6→10 列
board: half
parts:
  RT: resistor c10 c6 1k
  WIRE:
    type: device
    at: top
    label: ワイヤ 10 cm か 1 m (先は開放)
    pins: [端]
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, 1-, GND]
wires:
  - WIRE.端 -- b10 green [h-10]
  - AD.1+ -- a10 orange
  - AD.1- -- -t18 black
  - AD.GND -- -t20 black
  - a6 -- -t6 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/11-wire-antenna.svg)

- 10 列が入力の節点。緑のワイヤの先はどこにもつながず、机の上に伸ばしておく
- R<sub>T</sub> (6→10 列) と、6 列から GND のレールへ下ろす黒いジャンパは、終端するときだけ挿す
- AD の GND は USB を通して PC の GND とつながっている。ワイヤの「相手側の極」は、この GND と PC・電源の配線になる

## 計器の設定

計器は Analog Discovery 3 の Spectrum (放送波の線を周波数で見分けるため) と Scope。

| 計器 | 設定 |
| --- | --- |
| Spectrum | 0〜2 MHz、CH1、Window Flat Top、単位 dBm、Average 8 回 |
| Scope | CH1、Range 1 mV/div (いちばん細かい Range)、時間軸 500 ns/div |
| 手順 | ワイヤ 10 cm → 1 m に替える → R<sub>T</sub> を挿す、の 3 通りを読む |

線の周波数は地域で違う。東京なら NHK 第 1 の 594 kHz と第 2 の 693 kHz、ほかの地域は近くの局の周波数の線を探す
(中波の局は 9 kHz おきの周波数に置かれる)。図3 は 594 kHz の局 1 つだけが来ているとした長いワイヤ (1 m) の画面。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 1 m のワイヤで 594 kHz の放送波が −43.6 dBm (1.47 mV 実効値) に立つ
device: ad3
sweep: 0-2MHz
samples: 16384
window: flattop
unit: dBm
ref: -30dBm
signal: sine 594kHz 2.08mV
markers: [594kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/spectrum/11-wire-antenna.svg)

Scope で同じ節点を見ると、図4 のように 2 mV ほどの正弦波が見える。実際には放送の音声で振幅が揺れ (AM)、
ほかの局の波も重なるので、時間波形よりスペクトルのほうが読みやすい。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 1 m のワイヤの節点 — 594 kHz、振幅 2.08 mV の正弦波
time: 500ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 594kHz 2.08mV, range: 1mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/11-wire-antenna.svg)

AD3 の Scope は 14 ビットなので、±2.5 V の Range では 1 段がおよそ 0.3 mV (5 V ÷ 16384、目安)。
2 mV の波は 14 段ほどの階段に見える。Spectrum は多くの点の平均で読むので、これより小さい線 (10 cm のワイヤの −78 dBm) も読める。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| ワイヤ | 10 cm と 1 m の単線 (0.64 mm) | 先は開放。1 m は机の上にまっすぐ伸ばす |
| R<sub>T</sub> | 1 kΩ、1/4 W | 終端の抵抗。電流はほぼ 0 |
| 電源 | 使わない | 外から来る電波だけを見る |

## 見るべき値

計算値。電界 10 mV/m (実効値。80 dBµV/m (µ はマイクロ)、強い局から数十 km の目安、**仮定**)、ワイヤの実効高は長さの半分、
C<sub>ant</sub> は 10 cm で 1.5 pF・1 m で 10 pF (**仮定**。置き方で倍ほど変わる)。Scope の入力は 1 MΩ ∥ 24 pF。
dBm は AD の Spectrum と同じく 50 Ω (オーム) に置き直した電力。

| 条件 | 誘起電圧 e (実効値) | 節点の電圧 (実効値) | Spectrum の線 |
| --- | --- | --- | --- |
| 10 cm、終端なし | 0.5 mV | 29.4 µV | −77.6 dBm |
| 1 m、終端なし | 5 mV | **1.47 mV** | **−43.6 dBm** |
| 1 m、R<sub>T</sub> 1 kΩ | 5 mV | 0.185 mV | −61.6 dBm |

- 終端なしでは、節点は C<sub>ant</sub> とオシロの入力容量 24 pF の**容量の分圧**になる (8-5 の浮いた列と同じ形)。
  1 m のワイヤなら 10 / (10 + 24) = 29 % がそのまま入る
- ワイヤを 10 倍に長くすると、e が 10 倍、分圧の比が 5 倍になり、線は 34 dB 高くなる
- 1 kΩ で終端すると、594 kHz での C<sub>ant</sub> のインピーダンス 1 / (2π × 594 kHz × 10 pF) = 26.8 kΩ (π はパイ) との分圧になり、
  18 dB 下がる。ただし**消えはしない** — 線を短くするのがいちばん効く

**使わない入力にワイヤを挿したままにしない。** 計器へ引く線も、長い 1 本の線ではなく、
GND の線と撚り合わせる (撚り線) か、同軸ケーブル (BNC アダプタ) にする。撚り合わせた 2 本は、電波から
同じ電圧を受けて打ち消し合う。8-10 の GND のループも、同じように電波や磁界を拾う入口になる。

## LTspice での確かめ

`sim/11-wire-antenna.cir` で、誘起電圧 e → C<sub>ant</sub> → 節点 (1 MΩ ∥ 24 pF、R<sub>T</sub> の有無) を 594 kHz で交流解析した
(電界・実効高・容量は本文の仮定)。

| 条件 | 本文の数字 (節点の実効値) | LTspice | 判定 |
| --- | --- | --- | --- |
| 10 cm、終端なし | 29.4 µV | 29.41 µV、+0.6° | 合う |
| 1 m、終端なし | 1.47 mV | 1.4705 mV、+0.5° | 合う |
| 1 m、R<sub>T</sub> 1 kΩ | 0.185 mV | 0.18494 mV、+82.8° | 合う |

dBm は 10 log₁₀ (V<sub>rms</sub>² / 50 Ω / 1 mW) の算術で、LTspice の電圧から出した。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。

参考: [中波 (Wikipedia)](https://ja.wikipedia.org/wiki/中波)、[ツイストペアケーブル (Wikipedia)](https://ja.wikipedia.org/wiki/ツイストペアケーブル)
