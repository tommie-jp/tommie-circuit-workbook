---
book: circuits
chapter: 2
id: 2-3
title: エミッタ接地増幅 (自己バイアス)
tier: 50
source: 自作
board: BB
---

# 2-3 エミッタ接地増幅 (自己バイアス)

エミッタに抵抗を入れて自分で動作点を安定させる (自己バイアス)、電圧を
増幅する基本の 1 段アンプ。コレクタの抵抗で電流の変化を電圧の変化に変え、
出力は**入力を反転して**大きく取り出す。

## 回路図

```circuit
title: 図1 自己バイアスのエミッタ接地増幅
parts:
  V1: vsource a1 h1 5
  G1: ground h1
  R1: resistor a5 d5 20k
  R2: resistor d5 f5 10k
  G2: ground f5
  RC: resistor a7 c7 2.2k
  Q1: npn d7
  CIN: capacitor d5 d3 1u
  IN: port d3
  RE: resistor f7 h7 1k
  G3: ground h7
  CE: capacitor f9 h9 100u
  COUT: capacitor c8 c10 1u
  OUT: port c10
wires:
  - a1 -- a5 -- a7
  - d5 -- Q1.B
  - c7 -- Q1.C
  - c7 -- c8
  - Q1.E -- f7
  - f7 -- f9
  - h7 -- h9
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/03-common-emitter.svg)

`RE` (エミッタ抵抗) が動作点を安定させ、`CE` (バイパスコンデンサ) が交流だけ
`RE` を迂回させて利得を最大にする。`R1`・`R2` の分圧が動作点を決める。

元の 9V 設計 (R1 = 47kΩ) をそのまま 5V にすると、Vb が 0.9V 弱まで下がって
Ve が 0.2V 程度しか残らず、hFE のばらつきで動作点が大きく揺れてしまう。
そこで **R1 を 20kΩ に下げ**、分圧の開放電圧を確保し直した。

- 分圧の開放電圧: 5V × 10k/30k ≈ **1.67 V** (分圧の電流 167µA は
  ベース電流よりずっと大きいので、この近似でよい)
- Ve = Vb − 0.7 ≈ **0.93 V**、Ie = Ve / RE ≈ **0.93 mA**
- Vc = 5 − Ic×RC ≈ 5 − 0.93m×2.2k ≈ **2.96 V**、Vce ≈ **2.04 V** (活性領域)
- 電圧利得 (CE でバイパスあり): Av = −gm×RC、gm = Ic/26mV ≈ 35.6mA/V
  → Av ≈ −35.6m × 2.2k ≈ **−78 倍** (**反転**する。入力 10mVpp → 出力
  約 780mVpp、計算値)
- CE を外す (RE がそのまま利く) と Av ≈ −RC/RE = −2.2k/1k ≈ **−2.2 倍**
  まで下がる。バイパスの効果がよく分かる比較

## 実体配線図

```breadboard
title: 図2 自己バイアスのエミッタ接地増幅
# 上の + レール = +5V、上の − レール = GND (下のレールは使わない)
board: half
parts:
  R1: resistor a3 a8 20k
  R2: resistor b8 b13 10k
  RC: resistor a16 a21 2.2k
  Q1: transistor f19(B) f20(C) f21(E) 2SC1815
  CIN: capacitor c6(-) c9(+) 1uF
  RE: resistor a24 a27 1k
  CE: capacitor/electrolytic b24(+) b27(-) 100uF
  COUT: capacitor c21(+) c25(-) 1uF
  IN:
    type: device
    at: bottom
    label: IN
    pins: [SIG]
  OUT:
    type: device
    at: bottom
    label: OUT
    pins: [SIG]
wires:
  - +t3 -- d3 red
  - d13 -- -t13 black
  - d8 -- g19 orange
  - d9 -- h19 yellow
  - +t16 -- b16 red
  - g20 -- b21 blue
  - g21 -- d24 green
  - d27 -- -t27 black
  - IN.SIG -- d6 gray
  - OUT.SIG -- d25 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/03-common-emitter.svg)

`R1`/`R2` の分圧点 (列 8) と `CIN` の出力 (列 9) をベースへ (同じ穴に 2 本は挿せないので g19 と h19 に分ける)。`CIN` の左側 (列 6) が入力の取り込み口。`RC` の下端
(列 21) がコレクタ、`RE` の上端 (列 24) がエミッタ。`CE` は `RE` と並列
(同じ列 24 と 27 のすぐ隣)。`COUT` の右側 (列 25) が出力の取り出し口。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 20 kΩ |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| RC | 抵抗 (1/4 W) | 2.2 kΩ |
| RE | 抵抗 (1/4 W) | 1 kΩ |
| CIN, COUT | フィルムコンデンサ | 1 µF |
| CE | 電解コンデンサ | 100 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | 5V (USB) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電圧 | 約 1.6 〜 1.7 V | 分圧の計算どおり |
| エミッタ電圧 | 約 0.93 V | ベースより 0.6〜0.7V 低い |
| コレクタ電圧 | 約 3.0 V | 動作点が VCC と GND の間の適当な位置にある |
| 入力 10mVpp (1kHz) のときの出力 | 約 780mVpp、入力と逆位相 | 反転増幅、利得 約 78 倍 (計算値) |
| CE を外したときの出力 | 約 22mVpp まで低下 | 利得が −RC/RE ≈ 2.2 倍まで落ちる |

## 出典

自作。
