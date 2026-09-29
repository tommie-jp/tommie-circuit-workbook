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
title: 図1 自己バイアスのエミッタ接地増幅 (W1 で入れ、CH2 と CH1 で比べる)
parts:
  VCC: vcc a5 5V
  R1: resistor a5 d5 20k
  R2: resistor d5 f5 10k
  G2: ground f5
  RC: resistor a7 c7 2.2k
  Q1: npn d7
  CIN: capacitor d5 d3 1u
  W1: sine d1 f1 l=$\mathrm{W1}$
  M2: voltmeter d3 f3 l=$\mathrm{CH2}$
  G4: ground f3
  RE: resistor f7 h7 1k
  G3: ground h7
  CE: capacitor f9 h9 100u
  COUT: capacitor c8 c10 1u
  OUT: port c10
  M1: voltmeter c11 e11 l=$\mathrm{CH1}$
  G5: ground e11
wires:
  - a5 -- a7
  - d1 -- d3
  - f1 -- f3
  - c10 -- c11
  - d5 -- Q1.B
  - c7 -- Q1.C
  - c7 -- c8
  - Q1.E -- f7
  - f7 -- f9
  - h7 -- h9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/03-common-emitter.svg)

`+5V` は Analog Discovery の電源出力 V+ (WaveForms の Supplies で 5 V にする)。入力は W1 から `CIN` へ入れ、
CH2 で入力を、CH1 で出力を見る。`RE` (エミッタ抵抗) が動作点を安定させ、`CE` (バイパスコンデンサ) が交流だけ
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
title: 図2 自己バイアスのエミッタ接地増幅 (W1 と CH2 を入力へ、CH1 を出力へ)
# 5V は AD の V+ から上の + レールへ、上の − レール = GND (下のレールは使わない)
board: half
parts:
  R1: resistor b3 b9 20k
  R2: resistor c9 c13 10k
  RC: resistor b15 b20 2.2k
  Q1: transistor e19(B) e20(C) e21(E) 2SC1815
  CIN: capacitor d5(-) d9(+) 1uF
  RE: resistor a21 -t21 1k
  CE: capacitor/electrolytic b21(+) b26(-) 100uF
  COUT: capacitor d20(+) d27(-) 1uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 2+, W1, 2-, 1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.2+ -- a4 blue
  - e4 -- e5 blue
  - AD.W1 -- a5 yellow
  - AD.2- -- -t7 black
  - AD.1+ -- a27 orange
  - AD.1- -- -t28 black
  - +t3 -- a3 red
  - a13 -- -t13 black
  - e9 -- d19 orange [v10]
  - +t15 -- a15 red
  - a26 -- -t26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/03-common-emitter.svg)

5V は Analog Discovery の電源出力 V+ (赤) から上の + レールへ入れる
(WaveForms の Supplies で V+ を 5 V にする)。この回路が流すのは 1 mA ほどなので V+ で足りる。

- **Q1 は上のブロック** (`e19` B・`e20` C・`e21` E)。溝をまたぐ線が要らない
- **ベース (列 9)**: `R1` の下端・`R2` の上端・`CIN` の + 側が同じ列。橙の線 1 本 (`e9`–`d19`) で Q1 の B へ
- **コレクタ (列 20)**: `RC` の下端と `COUT` の + 側が、Q1 の C と同じ列
- **エミッタ (列 21)**: `RE` を − レールへ縦に挿し、`CE` の + 側も同じ列
- **入力 (列 5)**: `CIN` の − 側。W1 (黄) を `a5` に、CH2 の 2+ (青) は `a4` に挿して
  `e4`–`e5` で渡す
- **出力 (列 27)**: `COUT` の − 側。CH1 の 1+ (橙) を `a27` に挿す
- AD の GND・2−・1− (黒) は上の − レールへ

## オシロで見る

W1 を 1 kHz・10 mVpp の正弦波にする。CH2 (入力) は 2 mV/div、CH1 (出力) は 200 mV/div
で並べる (尺度が 100 倍違うので、画面の上では入力 5 目盛・出力 3.9 目盛とほぼ同じ高さに見える)。

```scope
title: 図3 入力 (CH2) と出力 (CH1) — 出力は約 78 倍で逆位相
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 780mVpp phase -180deg, range: 200mV/div}
ch2: {wave: sine 1kHz 10mVpp, range: 2mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/03-common-emitter.svg)

CH1 は約 780 mVpp で、CH2 (10 mVpp) の約 78 倍。CH2 の山で CH1 が谷になる (位相 180°)
— 反転増幅であることが一目で分かる。10 mVpp の入力は AD の W1 では小さな設定なので、
波形が細かく乱れて見えるときは平均 (Average) を使う。

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
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電圧 | 約 1.6 〜 1.7 V | 分圧の計算どおり |
| エミッタ電圧 | 約 0.93 V | ベースより 0.6〜0.7V 低い |
| コレクタ電圧 | 約 3.0 V | 動作点が VCC と GND の間の適当な位置にある |
| 入力 10mVpp (1kHz) のときの出力 (CH1) | 約 780mVpp、入力と逆位相 (位相 180°) | 反転増幅、利得 約 78 倍 (計算値) |
| CE を外したときの出力 | 約 22mVpp まで低下 | 利得が −RC/RE ≈ 2.2 倍まで落ちる |

## 出典

自作。
