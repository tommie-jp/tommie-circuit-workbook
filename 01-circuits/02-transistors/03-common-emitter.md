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
  V1: vsource a1 j1 9
  G1: ground j1
  R1: resistor a3 c3 47k
  R2: resistor c3 e3 10k
  G2: ground e3
  RC: resistor a7 c7 2.2k
  Q1: npn f9
  CIN: capacitor b6 d6 1u
  IN: port b6
  RE: resistor f13 h13 1k
  G3: ground h13
  CE: capacitor f17 h17 100u
  COUT: capacitor e8 e10 1u
  OUT: port e10
wires:
  - a1 -- a7
  - c3 -| Q1.B
  - d6 -| Q1.B
  - c7 -| Q1.C
  - c7 -- e8
  - Q1.E -| f13
  - f13 -- f17
  - h13 -- h17
style:
  grid: on
```

`RE` (エミッタ抵抗) が動作点を安定させ、`CE` (バイパスコンデンサ) が交流だけ
`RE` を迂回させて利得を最大にする。`R1`・`R2` の分圧が動作点を決める。

- 分圧の開放電圧: 9V × 10k/57k ≈ **1.58 V** (分圧の電流 158µA は
  ベース電流よりずっと大きいので、この近似でよい)
- Ve = Vb − 0.7 ≈ **0.88 V**、Ie = Ve / RE ≈ **0.88 mA**
- Vc = 9 − Ic×RC ≈ 9 − 0.88m×2.2k ≈ **7.1 V**、Vce ≈ **6.2 V** (活性領域)
- 電圧利得 (CE でバイパスあり): Av = −gm×RC、gm = Ic/26mV ≈ 33.8mA/V
  → Av ≈ −33.8m × 2.2k ≈ **−74 倍** (**反転**する。入力 10mVpp → 出力
  約 740mVpp、計算値)
- CE を外す (RE がそのまま利く) と Av ≈ −RC/RE = −2.2k/1k ≈ **−2.2 倍**
  まで下がる。バイパスの効果がよく分かる比較

## 実体配線図

```breadboard
title: 図2 自己バイアスのエミッタ接地増幅
# 上のレール = +9V、下のレール = GND
board: half
parts:
  R1: resistor a3 a8 47k
  R2: resistor b8 b13 10k
  RC: resistor a16 a21 2.2k
  Q1: transistor f19(B) f20(C) f21(E) 2SC1815
  CIN: capacitor c6(-) c9(+) 1uF
  RE: resistor a24 a27 1k
  CE: capacitor/electrolytic b24(+) b27(-) 100uF
  COUT: capacitor c21(+) c25(-) 1uF
  OUT:
    type: device
    at: bottom
    label: OUT
    pins: [SIG]
wires:
  - +t3 -- d3 red
  - d13 -- -t13 black
  - d8 -- g19 orange
  - d9 -- g19 yellow
  - +t16 -- b16 red
  - g20 -- b21 blue
  - g21 -- d24 green
  - d27 -- -t27 black
  - OUT.SIG -- d25 gray
```

`R1`/`R2` の分圧点 (列 8) と `CIN` の出力 (列 9) をベースへ。`RC` の下端
(列 21) がコレクタ、`RE` の上端 (列 24) がエミッタ。`CE` は `RE` と並列
(同じ列 24 と 27 のすぐ隣)。`COUT` の右側 (列 25) が出力の取り出し口。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 47 kΩ |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| RC | 抵抗 (1/4 W) | 2.2 kΩ |
| RE | 抵抗 (1/4 W) | 1 kΩ |
| CIN, COUT | フィルムコンデンサ | 1 µF |
| CE | 電解コンデンサ | 100 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | 9V |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電圧 | 約 1.5 〜 1.6 V | 分圧の計算どおり |
| エミッタ電圧 | 約 0.88 V | ベースより 0.6〜0.7V 低い |
| コレクタ電圧 | 約 7.1 V | 動作点が VCC と GND の間の適当な位置にある |
| 入力 10mVpp (1kHz) のときの出力 | 約 740mVpp、入力と逆位相 | 反転増幅、利得 約 74 倍 (計算値) |
| CE を外したときの出力 | 約 22mVpp まで低下 | 利得が −RC/RE ≈ 2.2 倍まで落ちる |

## 出典

自作。
