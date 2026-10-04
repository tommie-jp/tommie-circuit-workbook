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
LC 同調で選び、ゲルマニウムダイオードで検波して、クリスタルイヤホンで聞く。
増幅する石が無いので、**長いアンテナと実際の大地アース**が必須になる。

## 回路図

```circuit
title: 図1 ゲルマラジオ
parts:
  ANT: antenna a1
  L1: inductor a3 c3 250u
  GL: ground c3
  VC1: capacitor-var a5 c5 l=$\mathrm{VC}_1$
  GVC: ground c5
  D1: diode a8 a10 1N60
  C2: capacitor a11 c11 1n
  GC2: ground c11
  R1: resistor a13 c13 100k
  GR1: ground c13
  EAR: earphone a18 c18 l=$\mathrm{EAR}$
  GEAR: ground c18
wires:
  - a1 -- a8
  - a10 -- a18
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/02-crystal-radio.svg)

- L1 と VC1 (ポリバリコン) が並列の同調回路。アンテナ〜アースの間に浮かぶこの
  タンクだけが、受けた電波から 1 局分の周波数を選び出す
- D1 (ゲルマニウムダイオード) が検波部。同調回路の電圧の片側だけを通し、
  音声の成分を取り出す
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
  9-3 の R3 と同じ役目

**同調周波数**: f<sub>0</sub> = 1 / (2π√(LC))。L1 = 250µH、VC1 = 20〜260pF (ポリバリコン
の可変範囲) で

| VC1 | f<sub>0</sub> |
| --- | --- |
| 20pF (絞りきり) | 約2.25MHz |
| 260pF (開ききり) | 約624kHz |

中波放送帯 (531〜1602kHz) をほぼ覆う。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [E, A]
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  EAR:
    type: device
    at: top
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b5 b9 250u
  D1: diode e5(A) e12(K) 1N60
  C2: capacitor/ceramic b12 b14 1n
  R1: resistor d12 d17 100k
wires:
  - VC1.E -- -t3 black
  - VC1.A -- a5 yellow
  - ANT.1 -- c5 yellow
  - a9 -- -t9 black
  - EAR.A -- a12 green
  - a14 -- -t14 black
  - a17 -- -t17 black
  - EAR.B -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/02-crystal-radio.svg)

- **アンテナ線は 5〜10m** の被覆線を屋外か窓際に張る。長いほど受かる局が増える
- 上の -t レール (青) は**実物の大地アース**につなぐ。水道管やアース棒に線を
  這わせる (回路の共通線というだけでなく、本当に大地へ電流を逃がす経路)
- 5 列がアンテナのネット (VC1 の A・アンテナ・L1 の左足・D1 のアノード)。L1 の右足 (9 列) は − レールへ
- 12 列が検波出力のネット (D1 のカソード・C2 と R1 の左足・EAR の A)。C2 の右足 (14 列)・
  R1 の右足 (17 列)・EAR の B は − レールへ
- 1 つの穴には足か線を 1 本だけ挿す

## 見るべき値

目安 (実験で確かめる)。ゲルマニウムダイオード (1N60) は立ち上がりが 0.2〜0.3V とシリコンより
低く、電池の無い微弱な信号でも検波できる。

| 確かめること | 結果 |
| --- | --- |
| VC1 を回す | 受かる局が変わる (同調が動くのが分かる) |
| D1 を 1N4148 (シリコン) に差し替え | ほとんど聞こえなくなる (立ち上がり電圧が高すぎる) |
| アース線を外す | 音が小さくなるか消える (電流の戻り道が細る) |
| R1 を外す | 音が小さくなり、ひずむ (検波した電荷が抜けない。上の R1 の項目) |

## 出典

自作。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
