---
book: circuits
chapter: 8
id: 8-14
title: 静電容量タッチ — 発振周波数の変化
tier: 200
source: 自作
board: BB
era: 今
---

# 8-14 静電容量タッチ — 発振周波数の変化

8-3 のタッチスイッチは、2 本の電極を指で**つないで**、皮膚を流れる電流でトランジスタを動かした。
スマートフォンの画面やエレベーターのボタンのタッチは、電極が絶縁物の下にあって電流は流れない。
代わりに、**指が近づくと電極の容量 (静電容量) が増える**ことを使う。人の体は大地との間に 100 pF (ピコファラド) ほどの容量を持つ導体で、
指が電極に近づくと、電極から指を通って大地へ向かう容量が電極の容量に足される。

容量の変化は数十 pF と小さく、直流では見えない。そこで、3-8 の 40106 の RC 発振の C に電極を並べる。
周波数は 1 / (0.81 × R × C) なので、**C が増えると周波数が下がる**。容量を周波数に変えて数えるのが、
マイコンのタッチ入力やタッチセンサー IC の基本の形である。

この題では、同じ発振を 2 組作る。1 組は基準 (電極なし)、もう 1 組に電極をつなぐ。
Analog Discovery 3 (AD3) のオシロに 2 つの出力を並べ、触れたときだけ片方の周波数が約 2 割下がるのを見る。
基準を並べるのは、温度や電源電圧で 2 組が一緒に動く分を差し引いて、指の分だけを取り出すため (実際のタッチ IC も基準と比べる)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 40106 の RC 発振を 2 組 (A は基準、B の C2 に電極を並べる)
parts:
  RfA: resistor 3,2 5,2 1M
  C1: capacitor 3,4 3,6 100p
  GC1: ground 3,6
  U1E: not 4,4 CD40106B
  U1F: not 7,4 CD40106B
  M1: voltmeter 9,4 9,6 l=$\mathrm{CH1}$
  GM1: ground 9,6
  RfB: resistor 3,8 5,8 1M
  C2: capacitor 3,10 3,12 100p
  GC2: ground 3,12
  CT: capacitor 1.6,9 1.6,11 30p l=$C_{\mathrm{T}}$
  GCT: ground 1.6,11
  U1A: not 4,10 CD40106B
  U1B: not 7,10 CD40106B
  M2: voltmeter 9,10 9,12 l=$\mathrm{CH2}$
  GM2: ground 9,12
  VDD: vcc 12,2 5V
  C3: capacitor 12,2 12,4 100n
  GC3: ground 12,4
wires:
  - 3,2 -- 3,4 -- U1E.in
  - 5,2 -- 5,4
  - U1E.out -- 5,4 -- U1F.in
  - U1F.out -- 9,4
  - 3,8 -- 3,9 -- 3,10 -- U1A.in
  - 1.6,9 -- 3,9
  - 5,8 -- 5,10
  - U1A.out -- 5,10 -- U1B.in
  - U1B.out -- 9,10
notes:
  - text 1,7 blue left: "CT は電極に触れた指の容量 (等価回路)"
  - text 11,6 blue left: "C3 は U1 の 14 番 (VDD) と 7 番 (VSS) の間"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/14-capacitive-touch.svg)

- **発振 A (U1E・U1F)**: 3-8 と同じ形で、Rf を 1 MΩ、C を 100 pF に替えた。しきい値が典型値 (5 V で V<sub>T+</sub> 2.9 V・V<sub>T−</sub> 1.9 V) なら、
  周期は 0.81 × R × C。C には部品の 100 pF のほかに、配線と 40106 の入力の容量 (浮遊容量) が並ぶ。浮遊容量を 10 pF と**仮定**すると、
  T = 0.812 × 1 MΩ × 110 pF ≈ 89 µs (マイクロ秒)、周波数は約 **11.2 kHz**
- **発振 B (U1A・U1B)**: A と同じ部品で、C2 の上 (U1A の入力) に電極をつなぐ。触れていなければ A と同じ約 11.2 kHz
- **触れると** (CT)、指の容量が C2 に並ぶ。CT を 30 pF と**仮定**すると、C が 140 pF になり、周期は約 114 µs、周波数は約 **8.8 kHz** (約 21 % 下がる)
- C を 100 pF と小さくしたのは、指の数十 pF を大きな割合の変化にするため。C を 10 nF (3-8) にすると、30 pF は 0.3 % にしかならず見分けにくい。
  その代わり周期が短くなるので、Rf を 1 MΩ に上げて 10 kHz 前後に戻した
- U1F・U1B は緩衝 (3-8 と同じ)。オシロのプローブ (AD3 の入力は 1 MΩ と十数 pF) を発振の C の点に直接当てると、
  プローブの容量が C に足されて周波数が変わる。緩衝の出力で見れば発振に影響しない
- U1 は 1 個の 40106 で、6 回路のうち 4 回路を使う。回路の名前 (A〜F) は TI の CD40106B の端子の名前で、入力が A〜F、出力が G〜L

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 2 組の発振を 1 個の 40106 に組む (上が基準 A、下が電極つき B)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・CH1)
    pins: [V+, GND, 1+, 1-]
  U1: dip14 @ e12 CD40106B
  C3: capacitor/ceramic c9 c12 100n
  RfA: resistor b16 b20 1M
  C1: capacitor/ceramic c20 c24 100p
  C2: capacitor/ceramic h4 h8 100p
  RfB: resistor i8 i13 1M
  PAD:
    type: device
    at: bottom
    label: タッチ電極 (銅テープ 2 cm 角 + ビニールテープ)
    pins: [PAD]
  SC:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH2)
    pins: [2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t1 -- -b1 black
  - +t12 -- a12 red
  - a9 -- -t9 black
  - j18 -- -b18 black
  - d15 -- d20 yellow
  - a24 -- -t24 black
  - c16 -- c13 green
  - a17 -- -t17 black
  - j16 -- -b16 black
  - g12 -- g8 blue
  - j4 -- -b4 black
  - g13 -- g14 orange
  - AD.1+ -- a14 yellow
  - AD.1- -- -t27 black
  - PAD.PAD -- j8 white
  - SC.2+ -- j15 blue
  - SC.2- -- -b22 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/14-capacitive-touch.svg)

- 5 V は AD3 の Supplies の V+ から上の + レールへ。上下の − レールを左端でつなぐ
- **40106** は溝をまたいで、切り欠きを左に。14 番 (VDD) を + レールへ、7 番 (VSS、下の 18 列) を − レールへ。C3 は 9〜12 列 (上) で 14 番の隣
- **発振 B (下のブロック、3-8 と同じ並び)**: 1 番 (A、列 12) を青の線で列 8 へ延ばし、C2 (列 4〜8) と RfB (列 8〜13) をつなぐ。
  2 番 (G、列 13) と 3 番 (B、列 14) を橙の線でつなぎ、4 番 (H、列 15) が緩衝の出力。**電極の線は列 8 の `j8`** に挿す
- **発振 A (上のブロック)**: 11 番 (E、上の列 15) を黄の線で列 20 へ延ばし、C1 (列 20〜24、24 列は − レールへ) と RfA (列 16〜20) をつなぐ。
  10 番 (K、列 16) を緑の線で 13 番 (F、列 13) へ渡し、12 番 (L、列 14) が緩衝の出力
- **使わない入力**: 5 番 (C、下の列 16) と 9 番 (D、上の列 17) は − レールへ。使わない出力 (6 番 I・8 番 J) はつながない
- **電極**: 銅テープ (なければアルミ箔) を 2 cm 角に切り、厚紙に貼って上からビニールテープで覆う (指が金属に直に触れないようにする)。
  銅テープに線を半田付けするか、みの虫クリップで挟んで `j8` まで 10 cm 以内で引く。線が長いと、その容量と、線に近づいた手でも周波数が動く
- オシロは 1+ を A の出力 (上の `a14`)、2+ を B の出力 (下の `j15`) に挿す
- 電流は 40106 の数 mA 以下 (10 kHz の切り替わりと、オシロの入力の 1 MΩ に流れる 5 µA)。AD3 の Supplies とブレッドボードの範囲に十分収まる

## 計器の設定

計器は AD3。Supplies の V+ を 5 V。Scope は CH1 を A (基準)、CH2 を B (電極) にして、横 50 µs/div、縦はどちらも 2 V/div
(CH1 を上、CH2 を下に分けて置く)。トリガは CH1 の立ち上がり 2.5 V。Measurements に両方の Frequency を出す。
2 組は別々に発振しているので、CH2 の波は CH1 に対して流れて見える。周波数は Measurements の数で読む。

見えるはずの画面 (電極に指で触れた状態。浮遊容量 10 pF・指の容量 30 pF を**仮定**した計算値で、実測ではない)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 触れると B (CH2) の周波数が基準 A (CH1) より約 2 割下がる
time: 50us/div
trigger: ch1 rising 2.5V at -4div
ch1: {wave: pulse 11.14kHz 2.5V offset 2.5V duty 52.1%, range: 2V/div, position: 1div}
ch2: {wave: pulse 8.76kHz 2.5V offset 2.5V duty 52.1%, range: 2V/div, position: -3.5div}
measure: [freq, period, duty]
cursors: [0, 114.2us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/14-capacitive-touch.svg)

- 触れていないとき、CH1 と CH2 はどちらも約 11.1 kHz (部品のばらつきで数 % ずれる。ずれは触れたときの変化よりずっと小さい)
- 電極に触れると CH2 だけが約 8.8 kHz に下がる。カーソル X1・X2 の差 (114 µs) が、触れたときの B の 1 周期
- 指を電極から 1 cm ほど離しても、周波数は少し下がる (容量は距離が近いほど大きい)。ビニールテープの上からでも反応するのは、
  電流ではなく容量で感じているから
- **電源の手に注意**: AD3 の GND につながった物 (パソコンの筐体) に別の手で触れていると、指から大地への容量が大きく見えて、変化が増える

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | CMOS 6 回路入りシュミットインバータ (4 回路を使用) | 40106 (TI の CD40106B など) |
| RfA, RfB | 抵抗 (1/4 W、発振用) | 1 MΩ |
| C1, C2 | セラミックコンデンサ (発振用、温度で動きにくい CH 特性か C0G がよい) | 100 pF (101) |
| C3 | 積層セラミックコンデンサ (デカップリング) | 0.1 µF (104) |
| — | タッチ電極 | 銅テープかアルミ箔 2 cm 角 + ビニールテープ、線 10 cm 以内 |
| — | 電源 | 5 V (AD3 の Supplies の V+。1 mA 程度) |

## 見るべき値

周波数は計算値。浮遊容量と指の容量は仮定で、配線・電極の大きさ・触れ方で変わる。しきい値のばらつきでも数 % 動く。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| A の周波数 (CH1) | 約 11.1 kHz | f = 1 / (0.81 × 1 MΩ × (100 + 10) pF)。浮遊容量も C に入る |
| B の周波数、触れていない (CH2) | 約 11.1 kHz (A と数 % 以内) | 同じ部品なら同じ周波数 |
| B の周波数、触れている | 約 8.8 kHz (約 21 % 下がる) | 指の容量 (30 pF と仮定) が C2 に並ぶ |
| 触れたときの B の周期 | 約 114 µs | 0.81 × 1 MΩ × 140 pF |
| デューティ比 (どちらも) | 約 52 % | 緩衝の出力が H の間は U1E・U1A の出力が L (放電、0.423 × RC)。3-8 の U1 の出力 (48 %) の裏返し |
| 逆算した指の容量 | (f<sub>A</sub> ÷ f<sub>B</sub> − 1) × 110 pF | 2 つの周波数の比から、指の容量を pF で読める |

## LTspice での確かめ

`sim/14-capacitive-touch.cir` で、発振 A と B を同時に解き、B の CT を 0 と 30 pF に振った。40106 は LTspice の SCHMITT
(V<sub>T+</sub> 2.9 V・V<sub>T−</sub> 1.9 V) で置き、浮遊容量 10 pF を両方の C に並べた (仮定)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| A の周波数 | 約 11.2 kHz (計算 11.19 kHz) | 11.14 kHz | 合う (切り替わりの遅れ 0.1 µs の分だけ低い) |
| B の周波数、触れていない | A と同じ | 11.14 kHz | 合う |
| B の周波数、触れている (CT 30 pF) | 約 8.8 kHz (計算 8.79 kHz) | 8.76 kHz | 合う (−21.4 %) |
| C2 の電圧の上と下 | 2.9 V と 1.9 V | 2.90 V と 1.90 V | 合う (しきい値の間を往復する) |

指の容量の 30 pF は仮定で、電極の大きさ、ビニールテープの厚さ、体と大地の間の容量で大きく変わる。測ったら、
「見るべき値」の最後の行の式で逆算した値を本文に書く。

## 出典

自作。しきい値は Texas Instruments の [CD40106B データシート](https://www.ti.com/lit/ds/symlink/cd40106b.pdf) (5 V の V<sub>T+</sub>・V<sub>T−</sub> の典型値。3-8 と同じ)。

参考: [Capacitive sensing (Wikipedia)](https://en.wikipedia.org/wiki/Capacitive_sensing)
