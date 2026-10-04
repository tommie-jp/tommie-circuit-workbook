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

エミッタ接地 (2-1 で見た、エミッタを GND 側に置く形) で小さな交流の電圧を大きくする、
基本の 1 段アンプ。コレクタの抵抗でコレクタ電流の変化を電圧の変化に変え、
出力は**入力を反転して**大きく取り出す。この題では 10 mVpp の正弦波を入れ、
約 79 倍に増えて逆向きに出ることをオシロで確かめる。

増幅するには、信号が無いときにもトランジスタに適当な直流を流しておく。この直流の
電圧と電流の組を**動作点**と呼び、動作点を決めることをバイアスと呼ぶ。この回路は
`R1`・`R2` の分圧でベースの電圧を決め、エミッタに抵抗 `RE` を入れて、hFE の個体差が
あっても動作点が動かないようにする (自己バイアス)。コレクタ電流が増えようとすると
`RE` の電圧が上がってベース-エミッタ間の電圧が減り、電流を引き戻すからである。
分圧でベースを決めるので、2-8 ではこの形を分圧バイアスと呼び、別の方式と比べる。

## 回路図

```circuit
title: 図1 自己バイアスのエミッタ接地増幅 (W1 で入れ、CH2 と CH1 で比べる)
parts:
  VCC: vcc b6 5V
  R1: resistor b6 e6 20k
  R2: resistor e6 g6 10k
  G2: ground g6
  RC: resistor b8 d8 2.2k
  Q1: npn e8
  CIN: capacitor e6 e4 1u
  W1: sine e2 g2 l=$\mathrm{W1}$
  M2: voltmeter e4 g4 l=$\mathrm{CH2}$
  G4: ground g4
  RE: resistor g8 i8 1k
  G3: ground i8
  CE: capacitor g10 i10 100u
  COUT: capacitor d9 d11 1u
  OUT: port d11
  M1: voltmeter d12 f12 l=$\mathrm{CH1}$
  G5: ground f12
wires:
  - b6 -- b8
  - e2 -- e4
  - g2 -- g4
  - d11 -- d12
  - e6 -- Q1.B
  - d8 -- Q1.C
  - d8 -- d9
  - Q1.E -- g8
  - g8 -- g10
  - i8 -- i10
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/03-common-emitter.svg)

図1 の `+5V` は Analog Discovery の電源出力 V+ (WaveForms の Supplies で 5 V にする)。入力は W1 から `CIN` へ入れ、
CH2 で入力を、CH1 で出力を見る。`RE` (エミッタ抵抗) が動作点を安定させ、`CE` (バイパスコンデンサ) が交流だけ
`RE` を迂回させて利得を最大にする。`R1`・`R2` の分圧が動作点を決める。

9V の電源でよく使う値 (R1 = 47kΩ) のまま電源を 5V にすると、Vb が 0.9V 弱まで下がって
Ve が 0.2V 程度しか残らず、hFE のばらつきで動作点が大きく揺れてしまう。
そこで **R1 を 20kΩ に下げ**、分圧の開放電圧を確保し直した。

- 分圧の開放電圧: 5V × 10k/30k ≈ **1.67 V** (分圧の電流 167µA は
  ベース電流よりずっと大きいので、この近似でよい)
- ベース電流 (hFE = 150 と仮定して約 6 µA) が分圧の等価内部抵抗 (20k ∥ 10k ≈ 6.7kΩ) を流れる分だけ下がり、
  実際の Vb ≈ **1.63 V**
- Ve = Vb − 0.7 ≈ **0.93 V**、Ie = Ve / RE ≈ **0.93 mA**
- Vc = 5 − Ic×RC ≈ 5 − 0.93m×2.2k ≈ **2.95 V**、Vce ≈ **2.0 V** (活性領域。2-2 で見た)
- 電圧利得 (CE でバイパスあり): Av = −gm×RC。gm はベース-エミッタ間の電圧が 1 V 変わったときの
  コレクタ電流の変わり方 (相互コンダクタンス) で、gm = Ic / 26mV (26 mV は 2-2 で見た熱電圧) ≈ 35.8mA/V
  → Av ≈ −35.8m × 2.2k ≈ **−79 倍** (**反転**する。入力 10mVpp → 出力
  約 790mVpp、計算値)
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/03-common-emitter-1.svg)

図2 のとおり、5V は Analog Discovery の電源出力 V+ (赤) から上の + レールへ入れる
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
で並べる (尺度が 100 倍違うので、画面の上では入力 5 目盛・出力 4 目盛とほぼ同じ高さに見える)。

```scope
title: 図3 入力 (CH2) と出力 (CH1) — 出力は約 79 倍で逆位相
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 790mVpp phase -180deg, range: 200mV/div}
ch2: {wave: sine 1kHz 10mVpp, range: 2mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/03-common-emitter.svg)

図3 の CH1 は約 790 mVpp で、CH2 (10 mVpp) の約 79 倍。CH2 の山で CH1 が谷になる (位相 180°)
— 反転増幅であることが一目で分かる。10 mVpp の入力は AD の W1 では小さな設定なので、
波形が細かく乱れて見えるときは平均 (Average) を使う。

## NanoVNA で周波数特性を見る

AD の W1・CH1・CH2 の代わりに NanoVNA をつなぎ (図4)、50 kHz〜100 MHz の通り方 (S21) を見る (図5)。
S21・S11・Smith チャートの読み方と THRU の校正は 2-2 と同じ。

- `CIN` の − 側 (入力の列 5) に CH0 (アッテネータを通す)、`COUT` の − 側 (出力の列 27) に
  CH1 をつなぐ (図4)。板へは SMA-クリップのケーブルで、**芯線と外皮を組で**挿す。外皮は信号の穴のすぐ隣の
  − レールへ、線はできるだけ短く (GND の戻りが長いと 10 MHz あたりから特性が崩れる)
- NanoVNA の出力 (約 −7 dBm、50 Ω に 0.28 Vpp) はこの回路には大きすぎる。利得が 79 倍ある
  アンプの入力は数 mV までに抑えたい。**CH0 に 20 dB の SMA アッテネータを 2 個 (計 40 dB) 重ね、
  付けたまま THRU で校正する** (アッテネータの分は校正で消える)。40 dB でベースの振幅は約 6 mVpp
  (20 dB 1 個だと約 55 mVpp で、コレクタ電流が振り切れて波形がつぶれる)
- 電源は今までどおり AD の V+ (5 V)

```breadboard
title: 図4 NanoVNA をつなぐ (芯線と外皮を組で)
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
    label: AD (電源)
    pins: [V+, GND]
  CH0:
    type: device
    at: top
    label: CH0 (20 dB ATT ×2 経由)
    pins: [外皮, 芯線]
  CH1:
    type: device
    at: top
    label: CH1
    pins: [芯線, 外皮]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - CH0.芯線 -- a5 yellow
  - CH0.外皮 -- -t4 black
  - CH1.芯線 -- a27 orange
  - CH1.外皮 -- -t28 black
  - +t3 -- a3 red
  - a13 -- -t13 black
  - e9 -- d19 orange [v10]
  - +t15 -- a15 red
  - a26 -- -t26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/03-common-emitter-2.svg)

```vna
device: h4
sweep: 50k-100M 201
title: 図5 エミッタ接地増幅の S21 (計算) — 低い所で +10.6 dB・位相 180°、13 MHz で −3 dB
dut: series R 0
data: 03-common-emitter.s2p
traces:
  - S21 logmag
  - S21 phase
markers:
  - 1M
  - 13M
  - 50M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/vna/03-common-emitter-1.svg)

```vna
device: h4
sweep: 50k-100M 201
title: 図6 エミッタ接地増幅の入力側の S11 (計算) — 低い所で Smith の右端 (高インピーダンス) の近く
dut: series R 0
data: 03-common-emitter.s2p
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1M
  - 13M
  - 50M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/vna/03-common-emitter-2.svg)

- 破線は CH0 と CH1 を直につないだスルー (0 dB・0°)。実線は低い周波数で **約 +10.6 dB
  (|S21| ≈ 3.4)、位相 180°** (反転)。オシロで見た 79 倍 (+38 dB) よりずっと小さいのは、
  **CH1 の 50 Ω が `COUT` を通してコレクタの負荷になる**から。利得は gm × (RC ‖ 50 Ω)
  = 35.8 mA/V × 48.9 Ω ≈ **1.75 倍**まで下がる (RC 2.2 kΩ より 50 Ω のほうがずっと小さい)
- 入力側は、CH0 の 50 Ω から見たアンプの入力インピーダンスが R1 ‖ R2 ‖ β·re
  = 6.7 kΩ ‖ 4.2 kΩ ≈ **2.6 kΩ** と高い。50 Ω をほとんど食わないので、ベースには 50 Ω の線路に
  直につないだときの約 2 倍の電圧がかかる。S21 ≈ 2 × 1.75 ≈ 3.4 (+10.6 dB) はこの 2 つの積。
  S11 (図6) が Smith の右端 (開放) の近くにいるのも、入力が高インピーダンスだから
- **低い側に角はない**。`CIN` は 50 Ω + 2.6 kΩ と組んで約 60 Hz、`COUT` は 2.2 kΩ + 50 Ω と組んで
  約 70 Hz、`CE` はエミッタから見た約 29 Ω (re と信号源の分) と組んで約 56 Hz。どれも NanoVNA の
  下限 50 kHz よりずっと下なので、50 kHz から平ら。低い角を見たいときは AD のネットワーク
  アナライザ (1 Hz〜) を使う
- **高い側は 13 MHz で −3 dB** (+7.6 dB)、50 MHz で約 −1.0 dB (スルーより下)。位相も 180° から
  遅れていく。効くのは入力側の極:
  - 2SC1815 の fT は電流と V<sub>CE</sub> が小さいほど下がる。データシートの 80 MHz (最小) は
    V<sub>CE</sub> 10 V・I<sub>C</sub> 1 mA の値で、この回路 (0.93 mA・約 2 V) では 45 MHz 前後と仮定した。
    gm が大きいので、ベース-エミッタ間の容量 Cπ = gm / (2π fT) ≈ 127 pF と大きい
  - C<sub>ob</sub> (Cμ) は VCB 約 1.3 V で 4 pF。ミラー効果 (ベースとコレクタの間の容量が、
    利得の分だけ大きく見える現象) で (1 + gm × 48.9 Ω) ≈ 2.8 倍の約 11 pF に見える。50 Ω 負荷で利得が小さいぶん、ミラー効果は 2.2 kΩ を負荷にしたとき (約 80 倍) よりずっと軽い
  - その合計をベースの広がり抵抗 (rbb′ 約 50 Ω) と信号源の 50 Ω で充電するので、
    1 / (2π × 約 100 Ω × 約 138 pF) ≈ 12 MHz あたりに極 (利得が落ち始める周波数) ができる
  - SMA-クリップのリード線 (10 cm で約 80 nH) とブレッドボードの穴の浮遊容量 (1 か所 数 pF)
- `03-common-emitter.s2p` は **ハイブリッド π の模型で計算した値** (実測ではない)。
  Ic 0.93 mA・hFE 150・fT 45 MHz・Cob 4 pF・rbb′ 50 Ω に、クリップのリード 80 nH (入力・出力)
  と各節点の浮遊容量 5 pF を足した。実際の落ち始めはリード線の長さと組み方で変わる

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

直流の電圧 (ベース・エミッタ・コレクタ) は、W1 を止めてテスターの直流電圧レンジで GND を基準に測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電圧 | 約 1.6 〜 1.7 V | 分圧の計算どおり |
| エミッタ電圧 | 約 0.93 V | ベースより 0.6〜0.7V 低い |
| コレクタ電圧 | 約 3.0 V | 動作点が VCC と GND の間の適当な位置にある |
| 入力 10mVpp (1kHz) のときの出力 (CH1) | 約 790mVpp、入力と逆位相 (位相 180°) | 反転増幅、利得 約 79 倍 (計算値) |
| CE を外したときの出力 | 約 22mVpp まで低下 | 利得が −RC/RE ≈ 2.2 倍まで落ちる |

## 出典

自作。
