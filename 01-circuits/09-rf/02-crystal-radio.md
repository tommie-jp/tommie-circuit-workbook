---
book: circuits
chapter: 9
id: 9-2
title: ゲルマラジオ
tier: 50
source: 自作
board: BB
era: 古
---

# 9-2 ゲルマラジオ

電池を使わず、電波のエネルギーだけで音を出すラジオ。アンテナで受けた電波を
LC 同調 (9-1 の共振) で選び、ゲルマニウムダイオードで検波して、クリスタルイヤホンで聞く。
ラジオに要る 3 つの働き (同調・検波・音にする) が、いちばん少ない部品で見える。

中波のラジオ放送は AM (振幅変調) で、音声を高い周波数の電波 (**搬送波**、数百 kHz〜1.6 MHz) の
振幅の変化として乗せて送る。**検波**は、その振幅の変化 (包絡線) から音声を取り出すこと。
増幅する石 (トランジスタのこと。1 石はトランジスタ 1 個) が無いので、
**長いアンテナと実際の大地アース**が必須になる。

## 回路図

```circuit
title: 図1 ゲルマラジオ
parts:
  ANT: antenna 1,1
  L1: inductor 3,1 3,3 250u
  GL: ground 3,3
  VC1: capacitor-var 5,1 5,3 l=$\mathrm{VC}_1$
  GVC: ground 5,3
  D1: diode 8,1 10,1 1N60
  C2: capacitor 11,1 11,3 1n
  GC2: ground 11,3
  R1: resistor 13,1 13,3 100k
  GR1: ground 13,3
  EAR: earphone 16,1 16,3 l=$\mathrm{EAR}$
  GEAR: ground 16,3
wires:
  - 1,1 -- 8,1
  - 10,1 -- 16,1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/02-crystal-radio.svg)

- L1 と VC1 が並列の同調回路。VC1 はポリバリコン (薄いポリエチレンの膜を挟んだ可変コンデンサ。
  軸を回すと容量が変わる)。L と C を並列にした同調回路は**タンク** (タンク回路) とも呼ぶ。
  アンテナとアースの間に入ったこのタンクが、受けた電波から 1 局分の周波数を選び出す
- 並列のタンクは、9-1 の直列とは逆に f<sub>0</sub> でインピーダンスが最大になる。
  f<sub>0</sub> の電波だけがタンクの両端に大きな電圧を作り、ほかの周波数は L1 か VC1 を通って
  アースへ抜ける。f<sub>0</sub> の式は直列と同じ (下の「同調周波数」)
- D1 (ゲルマニウムダイオード) が検波部。同調回路の電圧の正の側だけを通す。
  通った山の高さが包絡線をなぞるので、C2 で高周波をならすと音声の成分が残る
- C2 は残った高周波分をアースへ逃がすバイパス。無いとイヤホンからサーッという
  高周波の音が混じる
- R1 (100kΩ) は検波の負荷で、検波出力から直流を逃がす道。イヤホンは直流を通さない
  (下の項目) ので、R1 が無いと検波した電荷が抜けず、音が小さくひずむ
- **イヤホンのインピーダンス**: EAR は、いま売られているセラミック (圧電) 型の
  クリスタルイヤホンを想定する (容量 約 15nF、直流では 20MΩ 以上)。電気的には
  コンデンサなので、インピーダンスは周波数で変わり、**1kHz で約 10kΩ**
  (1/(2π×1kHz×15nF) ≈ 10.6kΩ)、100Hz で約 100kΩ。8Ω や 32Ω の
  ダイナミック型のイヤホンでは、電波からもらうだけの小さな電力では鳴らない
- イヤホンの容量 (15nF) は C2 (1nF) の 15 倍あり、中波では 10〜20Ω しかない
  (1MHz で約 10.6Ω)。高周波をアースへ逃がす役目は、実際にはイヤホン自身がほとんど担う
- イヤホンの直流の抵抗 (20MΩ 以上) だけでは、16nF (C2 と EAR) との時定数が約 0.3 秒もあり、
  検波した電荷が抜けない。R1 を並列に入れると時定数は約 1.6ms (100kΩ×16nF) まで縮む。
  次の 9-3 の R3 も同じ役目

**同調周波数**: f<sub>0</sub> = 1 / (2π√(LC))。L1 = 250µH、VC1 = 20〜260pF (ポリバリコン
の可変範囲) で

| VC1 | f<sub>0</sub> |
| --- | --- |
| 20pF (絞りきり) | 約2.25MHz |
| 260pF (開ききり) | 約624kHz |

中波放送帯 (531〜1602kHz) をほぼ覆う (下の端の 531〜624kHz は届かない。配線の浮遊容量が
足されると、実際の範囲は少し下へずれる)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [A, E]
  EAR:
    type: device
    at: top
    label: クリスタルイヤホン
    pins: [A, B]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (試験)
    pins: [W1, 2+, 1+, 1-, 2-, GND]
  L1: inductor/axial b5 b9 250u
  D1: diode d5(A) d12(K) 1N60
  C2: capacitor/ceramic b12 b14 1n
  R1: resistor h12 h17 100k
  RS: resistor e3 i3 1k
wires:
  - ANT.1 -- a3 yellow
  - c3 -- c5 yellow
  - VC1.A -- a5 yellow
  - VC1.E -- -t7 black
  - a9 -- -t9 black
  - EAR.A -- a12 green
  - EAR.B -- -t16 black
  - a14 -- -t14 black
  - e5 -- f5 yellow
  - e12 -- f12 green
  - AD.W1 -- j3 orange
  - AD.2+ -- j5 blue
  - AD.1+ -- j12 blue
  - AD.1- -- -b14 black
  - AD.2- -- -b15 black
  - AD.GND -- -b16 black
  - j17 -- -b17 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/02-crystal-radio.svg)

- **アンテナ線は 5〜10m** の被覆線を屋外か窓際に張る。長いほど受かる局が増える
- 上の -t レール (青) は**実物の大地アース**につなぐ。水道管やアース棒に線を
  這わせる (回路の共通線というだけでなく、本当に大地へ電流を逃がす経路)
- 3 列と 5 列がアンテナのネット (ANT・VC1 の A・L1 の左リード・D1 のアノード・RS の上のリード)。
  3 列と 5 列は c 行の黄色の短い線でつなぐ。L1 の右リード (9 列) は − レールへ
- 12 列が検波出力のネット (D1 のカソード・C2 の左リード・EAR の A)。C2 の右リード (14 列) と EAR の B は上の − レールへ。
  12 列は溝をまたぐ緑の短い線で下の 12 列へ渡し、R1 (100 kΩ) は下の h 行に置く。R1 の右リード (17 列) は下の − レールへ
- 上と下の − レールは 30 列の黒い線でつなぐ
- AD3 は、放送の電波が弱くて波形が見えにくいときの**試験用**に足した。W1 (Wavegen) の AM 信号を、
  RS (1 kΩ) を通して同調回路へ入れる。RS は 3 列で溝をまたいで縦に挿し (`e3` と `i3`)、W1 は下の 3 列 (`j3`) へ入れる。
  アンテナの代わりに W1 を使うので、試験のときは ANT の線を外してよい。
  5 列は溝をまたぐ黄色の短い線で下の 5 列へ渡し、AD3 の 2+ (CH2) を同調回路 (`j5`) に当てる。
  1+ (CH1) は検波出力 (下の 12 列、`j12`) に当てる。1−・2−・GND は下の − レールへ入れる。電池は無いので Supplies は使わない
- 1 つの穴にはピンか線を 1 本だけ挿す

## 計器の設定

計器は Analog Discovery 3 (AD3)。放送の電波の代わりに W1 で AM 信号を出し、Scope で同調回路と検波出力を見る。
信号は搬送波 1 MHz で、Scope の範囲 (10 MHz 以下) に入る。VC1 は約 100 pF に回しておく
(f<sub>0</sub> = 1 / (2π√(250 µH × 100 pF)) ≈ 1.007 MHz)。

| 項目 | 値 |
| --- | --- |
| Wavegen W1 | 搬送波 Sine 1 MHz、振幅 1 V (peak)、Modulation: AM、変調波 Sine 1 kHz、変調度 50 % |
| Scope CH1 (1+ = 検波出力) | Coupling DC、100 mV/div、Offset 1 V 前後 |
| Scope CH2 (2+ = 同調回路) | Coupling DC、1 V/div |
| Scope 時間軸・トリガ | 200 µs/div、CH1 の立ち上がり |

```scope
title: 図3 AM 信号の試験 — 同調回路 (CH2) は太り細り、検波出力 (CH1) は 1 kHz
time: 200us/div
trigger: ch1 rising 0.99V
ch1: {wave: = 0.99V + 0.197V * sin(2 * pi * 1kHz * t), range: 100mV/div, position: -10div}
ch2: {wave: = 0.93V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 1V/div, position: 2.5div}
measure: [vpp, avg, freq]
cursors: [250us, 750us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/02-crystal-radio.svg)

- 図3 は LTspice の計算 (1N60 は IS = 0.2 µA・RS = 25 Ω と仮定した目安) をもとにした画面。実測ではない
- CH1 は平均 約 1.0 V、1 kHz の振れは約 0.39 Vpp (0.80〜1.19 V)。包絡線 (CH2) の振れ幅 (約 1.4 Vpp) よりかなり小さい。
  R1 (100 kΩ) と C2・EAR (計 16 nF) の時定数が約 1.6 ms で、1 kHz の周期 (1 ms) より長く、検波出力がならされるため
- CH2 の搬送波 (1 MHz) は 200 µs/div では塗りつぶされた帯に見える。帯の外形が 1 kHz で太り細りするのが AM。
  帯の最大の振幅は約 1.4 V (peak)

### 同調回路だけを VNA で見る (補足)

W1 と Scope の代わりに LiteVNA64 を使うと、同調回路 (L1 と VC1 の並列) の共振周波数と鋭さを、放送の電波なしで測れる
(中波は 50 kHz〜の範囲に入る)。L1 と VC1 の並列を回路から外し、03-nanovna/03-fixtures/01-series-fixture.md (3-1) の直列治具のように
CH0 と CH1 の間に**直列**に挿して、S21 の Log Mag を 0.8〜1.3 MHz で掃引する。
並列共振では L1 と VC1 の並列のインピーダンスが非常に大きくなって信号が通らないので、S21 は f<sub>0</sub> だけ深い谷になる。
谷の位置が同調周波数で、VC1 を回すと動く。

見えるはずの画面 (理想の模型。VC1 = 100 pF、L1 の損失を並列の 158 kΩ (Q = 100) とした目安で、実測ではない)。

```vna
device: litevna64
sweep: 0.8M-1.3M 401
title: 図4 同調回路 (L1 250 µH ∥ VC1 100 pF) の S21 — f0 で深い谷
dut:
  - series L 250u cp 100p rp 158k
traces:
  - S21 logmag
markers:
  - 1.007M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/vna/02-crystal-radio.svg)

- 谷の位置は f<sub>0</sub> = 1 / (2π√(250 µH × 100 pF)) ≈ 1.007 MHz。図の読み値は 1.007 MHz で約 −64 dB
- 谷の幅が狭いほど L1 の損失が小さい (Q が高い)。実物は −64 dB まで深くならず、コイルの Q と治具の漏れで浅くなる
- VC1 を 20〜260 pF に回すと、谷は約 2.2 MHz から 0.62 MHz まで動く (計算値。配線の浮遊容量の分だけ低くなる)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 | インダクタ (アキシャル) | 250 µH |
| VC1 | ポリバリコン | 20〜260 pF |
| D1 | ゲルマニウムダイオード | 1N60 |
| C2 | セラミックコンデンサ | 1 nF |
| R1 | 抵抗 | 100 kΩ |
| EAR | クリスタルイヤホン | 容量 約 15 nF |
| RS | 抵抗 (試験用。W1 から同調回路へ入れる) | 1 kΩ |
| — | 試験用の信号源・オシロ | Analog Discovery 3 (W1、Scope の 1・2)。電池・Supplies は使わない |

## 見るべき値

目安 (実験で確かめる)。ゲルマニウムダイオード (1N60) は立ち上がりが 0.2〜0.3V とシリコンより
低く、電池の無い微弱な信号でも検波できる。

| 確かめること | 結果 |
| --- | --- |
| VC1 を回す | 受かる局が変わる (同調が動くのが分かる) |
| D1 を 1N4148 (シリコン) に差し替え | ほとんど聞こえなくなる (立ち上がり電圧が高すぎる) |
| アース線を外す | 音が小さくなるか消える (電流の戻り道が細る) |
| R1 を外す | 音が小さくなり、ひずむ (検波した電荷が抜けない。上の R1 の項目) |
| W1 の AM 信号 (1 MHz・1 V peak・1 kHz・50 %) を入れ、VC1 を約 100 pF に回す (試験用) | 図3 のとおり、CH1 は平均 約 1.0 V・1 kHz の振れ 約 0.39 Vpp (LTspice の計算値の目安) |

## 出典

自作。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
