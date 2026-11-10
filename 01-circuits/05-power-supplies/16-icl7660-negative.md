---
book: circuits
chapter: 5
id: 5-16
title: 負電源 (ICL7660)
tier: 200
source: 自作
---

# 5-16 負電源 (ICL7660)

5-7 では 555 の方形波とダイオード 2 本とコンデンサで、+9 V から負の電圧を作った。ダイオードの順電圧 2 本ぶんが損になり、出力は入力より 1.5 V ほど小さかった。
**ICL7660** はこれを 1 個の IC にしたチャージポンプで、ダイオードの代わりに MOS のスイッチ 4 個を発振回路で開け閉めする。
外に付けるのはコンデンサ 2 個だけで、+5 V から −5 V に近い電圧が出る。両電源のオペアンプ (TL072 など) を、+5 V の 1 系統だけで動かしたいときに使う。

働きは 2 つの相の繰り返し (発振 10 kHz を 2 で割った 5 kHz、データシートの値)。

1. **相 A**: C1 の + を V+ に、− を GND につなぎ、C1 を 5 V に充電する
2. **相 B**: C1 の + を GND に、− を出力につなぐ。C1 の + が 0 V なので − は −5 V になり、C1 の電荷が C2 へ移る

スイッチに抵抗があり、C1 と C2 も 5 kHz ごとに少しずつしか電荷を運べないので、出力は抵抗 R<sub>O</sub> (データシートの典型 55 Ω (オーム)) の付いた −5 V の電源のように見える。
負荷の電流が増えるほど出力は 0 V の側へ寄る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ICL7660 で +5 V から -5 V を作る
parts:
  VCC: vcc 9,2 5V
  U1: dip8 6,4 ICL7660
  C1: ecap 2,4 2,4.8 10u
  C2: ecap 12,7 12,4.8 10u
  RL: resistor 14,4.8 14,7 1k
  M1: voltmeter 16,4.8 16,7 l=$\mathrm{CH1}$
  G1: ground 4.4,4.4 r90
  G2: ground 12,7
  G3: ground 14,7
  G4: ground 16,7
wires:
  - U1.8 -| 9,2
  - U1.2 -- 2,4
  - U1.4 -- 2,4.8
  - U1.3 -- 4.4,4.4
  - U1.5 -- 12,4.8
  - 12,4.8 -- 14,4.8 -- 16,4.8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/16-icl7660-negative.svg)

- ICL7660 (DIP-8) のピンは 1 NC・2 CAP+・3 GND・4 CAP−・5 VOUT・6 LV・7 OSC・8 V+ (データシートの図)
- C1 (10 µF (マイクロファラド)) はポンプのコンデンサで、+ を CAP+ (2 番)、− を CAP− (4 番) に。C2 (10 µF) は出力のコンデンサで、**+ を GND、− を VOUT** に入れる (出力が負なので向きが逆)
- 6 番 (LV) と 7 番 (OSC) は何もつながない。LV は電源が 3.5 V より低いときだけ GND につなぐ。OSC を開けておくと発振は 10 kHz
- RL (1 kΩ) が負荷。CH1 が出力 VOUT

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (ICL7660 の 6・7 番は何もつながない)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies と CH1)
    pins: [V+, GND, 1+, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH2)
    pins: [2+, 2-]
  U1: dip8 @ e10 ICL7660
  C1: capacitor/electrolytic h11(+) h13(-) 10uF v=16V
  C2: capacitor/electrolytic -t16(+) a16(-) 10uF v=16V
  RL: resistor a20 -t21 1k
wires:
  - AD.V+ -- +t5 red
  - AD.GND -- -t6 black
  - +t10 -- a10 red
  - j12 -- -b12 black
  - -t30 -- -b30 black
  - c13 -- c16 blue
  - d16 -- d20 blue
  - AD1.2+ -- j11 yellow
  - AD1.2- -- -b16 black
  - AD.1+ -- b16 green
  - AD.1- -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/16-icl7660-negative.svg)

- ICL7660 は切り欠きを左にして 10〜13 列に挿す。下の f 行が 1〜4 番、上の e 行が 8〜5 番 (左から)
- V+ (8 番、10 列の上) を上の赤いレールへ。GND (3 番、12 列の下) を下の青いレールへ。上下の青いレールは 30 列でつなぐ
- C1 は + を 11 列 (CAP+)、− を 13 列 (CAP−) の下のブロックに (`h11`–`h13`)
- VOUT (5 番、13 列の上) から青の線で 16 列へ。C2 は + を上の青いレール (GND)、− を 16 列に挿す。16 列から 20 列へ渡して RL を青いレールへ
- CH1 (1+) は 16 列 (VOUT)、CH2 (2+) は CAP+ (11 列の下)。1−・2− は GND

ブレッドボードを流れる電流は 5 mA ほどで、ブレッドボードの範囲 (1 穴 200 mA) に収まる。周波数は 5 kHz で 3 MHz の内側。

## 計器の設定

計器は AD3 の Supplies と Scope。V+ を 5 V にする。Scope は CH1・CH2 とも 1 V/div、時間軸 50 µs/div、トリガは CH2 の立ち上がり 2.5 V。
Measurements に CH1 の Average と Peak2Peak を出す。さざ波 (リップル) は 50 mV ほどなので、CH1 を 20 mV/div に拡大し、オフセットを +4.75 V
(画面の中央が −4.75 V) にすると形が見える。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 CAP+ (CH2) は 5 kHz で 0 V と 5 V を行き来し、出力 (CH1) は -4.75 V
time: 50us/div
trigger: ch2 rising 2.5V
ch1: {wave: triangle 5kHz 50mVpp offset -4.75V, range: 1V/div, position: 2div}
ch2: {wave: square 5kHz 4.93Vpp offset 2.47V, range: 1V/div, position: -3div}
measure: [avg, vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/16-icl7660-negative.svg)

図3 は理想 (計算) の画面。CH2 の CAP+ は 5 kHz (周期 200 µs) で 0 V と約 4.9 V の方形波で、これがポンプの拍。CH1 は −4.75 V で、
同じ 5 kHz で 50 mVpp のさざ波が乗る (さざ波の形は三角で近似した)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | チャージポンプ IC (DIP-8) | ICL7660 (入力 1.5〜10 V、発振 10 kHz) |
| C1 | 電解コンデンサ (16 V) | 10 µF (ポンプ) |
| C2 | 電解コンデンサ (16 V) | 10 µF (出力。+ を GND へ) |
| RL | 抵抗 (1/4 W) | 1 kΩ (負荷。損失 23 mW) |
| — | 電源 | AD3 の Supplies の V+ (5 V) |
| — | 計器 | AD3 の Scope (1+ = VOUT、2+ = CAP+) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| VOUT (RL 1 kΩ) | −4.75 V (4.75 mA) | 出力の抵抗 R<sub>O</sub> ≈ (5 − 4.75) V ÷ 4.75 mA ≈ 53 Ω |
| VOUT (RL を 470 Ω に替える) | −4.50 V (9.6 mA) | 電流を倍にすると、0 V の側へ寄る量も倍 |
| VOUT のさざ波 (RL 1 kΩ) | 約 50 mVpp | データシートの式 [1 ÷ (2 f<sub>PUMP</sub> C2) + 2 ESR] × I<sub>OUT</sub> = (10 + 1) Ω × 4.75 mA ≈ 52 mV |
| CAP+ (CH2) の周波数 | 5 kHz | 発振 10 kHz の半分がポンプの拍 |
| 入力の電流 | 約 4.9 mA (出力 4.75 mA + IC 自身の 0.17 mA) | 電荷を運ぶだけなので、入力の電流は出力とほぼ同じ (効率 95 % 前後) |

- 5-7 の 555 とダイオードのチャージポンプより出力が 0 V から遠い (ダイオードの順電圧の損が無い)
- C1・C2 を 100 µF にすると、データシートの近似の式の 1 ÷ (f<sub>PUMP</sub> C1) の項が 20 Ω から 2 Ω に減る。残りの大半はスイッチの 2 R<sub>SW</sub> ≈ 46 Ω なので、出力の抵抗は 2〜3 割しか減らない (見積り)。さざ波は (1 + 1) Ω × 4.75 mA ≈ 10 mV と 1/5 ほどに減る (ESR 0.5 Ω のとき)
- この −4.75 V を TL072 の V− に使えば、+5 V の 1 系統で両電源のオペアンプが動く。ただし負荷の電流で V− が動くので、精度の要る回路では 79L05 で安定化する

## LTspice での確かめ

`sim/16-icl7660-negative.cir` で図1 を 60 ms 動かし、最後の 10 ms で平均とさざ波を読んだ。ICL7660 は挙動の模型 (仮定): 5 kHz で相 A・B のスイッチを入れ替え、
スイッチ 1 個のオン抵抗 5.75 Ω (データシートの近似の式でスイッチ 4 個の合計 R<sub>SW</sub> の典型 23 Ω を 4 等分)。C1・C2 の ESR は 0.5 Ω の仮定。IC 自身の電流は入れていない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| VOUT (RL 1 kΩ・470 Ω) | −4.75 V・−4.50 V | −4.749 V・−4.495 V | 合う |
| 出力の電流 (1 kΩ・470 Ω) | 4.75 mA・9.6 mA | 4.75 mA・9.56 mA | 合う |
| 出力の抵抗 R<sub>O</sub> | 約 53 Ω (データシートの典型 55 Ω) | 52.8 Ω | 合う |
| さざ波 (1 kΩ・470 Ω) | 約 50 mVpp・100 mVpp | 50.0 mV・100.5 mV | 合う |
| CAP+ の振れ | 約 4.9 V | 4.93 V | 合う |
| 入力の電流 (1 kΩ) | 出力とほぼ同じ | 4.757 mA | 合う (IC 自身の 0.17 mA は模型に無い) |

## 出典

自作。

参考: [ICL7660 のデータシート (Renesas)](https://www.renesas.com/us/en/document/dst/icl7660-datasheet)、[チャージポンプ (Wikipedia)](https://ja.wikipedia.org/wiki/チャージポンプ)
