---
book: circuits
chapter: 2
id: 2-2
title: エミッタフォロア
tier: 50
source: 自作
board: BB
---

# 2-2 エミッタフォロア

コレクタを電源に直結し、エミッタから出力を取る回路。**電圧はほぼ 1 倍のまま
変えず、電流だけを大きくする**。信号源のインピーダンスが高く、負荷が小さいときの
「橋渡し」役として使う。

## 回路図

```circuit
title: 図1 エミッタフォロア (W1 で入れ、CH2 と CH1 で比べる)
parts:
  V1: vsource b12 d12 5
  G1: ground d12
  R1: resistor b6 d6 22k
  R2: resistor d6 f6 10k
  G2: ground f6
  Q1: npn d8
  CIN: ecap d5 d4 10u
  W1: sine d2 f2 l=$\mathrm{W1}$
  M2: voltmeter d4 f4 l=$\mathrm{CH2}$
  G5: ground f4
  RE: resistor f8 h8 1k
  G3: ground h8
  COUT: ecap f8 f11 10u
  RL: resistor f11 h11 1k
  G4: ground h11
  OUT: port f11
  M1: voltmeter f13 h13 l=$\mathrm{CH1}$
wires:
  - b6 -- b8 -- b12
  - b8 -- Q1.C
  - d5 -- d6 -- Q1.B
  - Q1.E -- f8
  - d2 -- d4
  - f2 -- f4
  - f11 -- f13
  - h11 -- h13
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/02-emitter-follower.svg)

`V1` (5V) は Analog Discovery の電源出力 V+。`R1` (22kΩ) と `R2` (10kΩ) でベースを分圧し、`RE` (1kΩ) がエミッタの電位を決める。
`CIN` / `COUT` は直流を切って信号だけ通す結合コンデンサ。

- 分圧の開放電圧: 5V × 10k/(22k+10k) ≈ **1.56 V**、等価内部抵抗 ≈ 6.9kΩ
- hFE = 150 と仮定すると、ベース電流を差し引いた実際の Vb ≈ **1.52 V**
- エミッタ電圧: Ve = Vb − 0.7 ≈ **0.83 V**、Ie = Ve / RE ≈ **0.83 mA**
- Vce = 5 − 0.83 = **約 4.2 V** (コレクタは電源に直結なので損失は Vce×Ic ≈ 3.4mW)
- 電圧利得: Av = RE / (RE + re)、re = 26mV/Ie ≈ 31.5Ω → Av ≈ 1000/1031.5 ≈
  **0.97 倍** (1 倍よりわずかに小さいだけ。反転しない)

## 実体配線図

```breadboard
title: 図2 エミッタフォロア (W1 と CH2 を入力へ、CH1 を出力へ)
# 5V は AD の V+ から上の + レールへ (下のレールは使わない)
board: half
parts:
  R1: resistor b5 b10 22k
  R2: resistor a10 -t10 10k
  CIN: capacitor/electrolytic d4(-) d10(+) 10uF
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RE: resistor a14 -t14 1k
  COUT: capacitor/electrolytic b14(+) b18(-) 10uF
  RL: resistor a18 -t18 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 2-, 2+, W1, 1+, 1-, V+]
wires:
  - AD.V+ -- +t24 red
  - AD.GND -- -t1 black
  - AD.2- -- -t2 black
  - AD.2+ -- b4 blue
  - AD.W1 -- a4 yellow
  - AD.1+ -- c18 orange
  - AD.1- -- -t21 black
  - +t5 -- a5 red
  - +t12 -- a12 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/02-emitter-follower-1.svg)

部品はすべて上半分に挿す。5V は Analog Discovery の電源出力 V+ (赤) から上の + レールへ入れる
(WaveForms の Supplies で V+ を 5 V にして入れる)。この回路が流すのは 1 mA ほどなので V+ で足りる。

- **ベース (列 10)**: `R1` の右端・`R2` の上端・`CIN` の + 側・`Q1` の B が同じ列に
  並ぶので、線は要らない。`R1` の左端 (列 5) は赤線で +5V へ
- **コレクタ (列 12)**: 赤線で +5V レールへ直接
- **エミッタ (列 14)**: `RE` と `COUT` の + 側が同じ列。`R2`・`RE`・`RL` は
  − レールへ縦に挿す
- **入力 (列 4)**: `CIN` の − 側。Analog Discovery の W1 (黄) を `a4` に、
  CH2 の 2+ (青) はそのすぐ下の `b4` に挿す
- **出力 (列 18)**: `COUT` の − 側と `RL`。CH1 の 1+ (橙) は
  空いている `c18` に挿す
- AD の GND・2−・1− (黒) は上の − レールへ

## オシロで見る

W1 を 1 kHz・1 Vpp の正弦波にし、CH2 (入力) と CH1 (出力) を同じ 200 mV/div で重ねる。

```scope
title: 図3 入力 (CH2) と出力 (CH1) — 振幅はほぼ同じ、位相も揃う
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 0.97Vpp, range: 200mV/div}
ch2: {wave: sine 1kHz 1Vpp, range: 200mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/02-emitter-follower.svg)

CH1 は CH2 の約 0.97 倍 (0.97 Vpp) で、2 本の山と谷がほぼ重なる。反転しないこと、
電圧がほぼ 1 倍のまま出ることが一目で分かる。結合コンデンサ (10 µF) と 1 kΩ の
遮断周波数は約 16 Hz なので、1 kHz では位相のずれは 1° ほどで画面では見えない。

## NanoVNA で周波数特性を見る

W1 と CH1・CH2 の代わりに NanoVNA をつなぎ (図4)、50 kHz〜100 MHz の通り方 (S21) を見る (図5)。

- `CIN` の − 側 (入力の列 4) に CH0 (アッテネータを通す)、`COUT` の − 側 (出力の列 18) に
  CH1 をつなぐ (図4)。**RL は外す** — CH1 の 50 Ω がそのまま負荷になる。板へは SMA-クリップのケーブルで、**芯線と外皮を組で**挿す。外皮は信号の穴のすぐ隣の
  − レールへ、線はできるだけ短く (GND の戻りが長いと 10 MHz あたりから特性が崩れる)
- NanoVNA の出力はこの回路には大きすぎる (出力が 50 Ω を駆動するとエミッタの
  0.83 mA では下の半分が切れる)。**CH0 に 20 dB の SMA アッテネータを付け、
  付けたまま THRU で校正する** (アッテネータの分は校正で消える)
- 電源は今までどおり AD の V+ (5 V)

```breadboard
title: 図4 NanoVNA をつなぐ (芯線と外皮を組で、RL は外す)
board: half
parts:
  R1: resistor b5 b10 22k
  R2: resistor a10 -t10 10k
  CIN: capacitor/electrolytic d4(-) d10(+) 10uF
  Q1: transistor e10(B) e12(C) e14(E) 2SC1815
  RE: resistor a14 -t14 1k
  COUT: capacitor/electrolytic b14(+) b18(-) 10uF
  CH0:
    type: device
    at: top
    label: CH0 (20 dB ATT 経由)
    pins: [外皮, 芯線]
  CH1:
    type: device
    at: top
    label: CH1
    pins: [芯線, 外皮]
  AD:
    type: device
    at: top
    label: AD (電源)
    pins: [GND, V+]
wires:
  - CH0.芯線 -- a4 yellow
  - CH0.外皮 -- -t3 black
  - CH1.芯線 -- a18 orange
  - CH1.外皮 -- -t19 black
  - AD.GND -- -t24 black
  - AD.V+ -- +t25 red
  - +t5 -- a5 red
  - +t12 -- a12 red
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/02-emitter-follower-2.svg)

```vna
device: h4
sweep: 50k-100M 201
title: 図5 エミッタフォロアの S21 (計算) — 低い所で +1.5 dB、数 MHz から落ちる
dut: series R 0
data: 02-emitter-follower.s2p
traces:
  - S21 logmag
  - S21 phase
  - S11 smith
markers:
  - 1M
  - 20M
  - 50M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/vna/02-emitter-follower.svg)

- 破線は CH0 と CH1 を直につないだスルー (0 dB・0°)。実線はそれより上にいて、
  **S21 は約 +1.5 dB (|S21| ≈ 1.19)**。電圧利得は 1 倍未満なのに S21 が 1 を超えるのは、
  入力が高インピーダンス (低い周波数で約 4.4 kΩ) で CH0 の 50 Ω をほとんど食わず、出力が低い
  インピーダンス (約 32 Ω) で CH1 の 50 Ω を駆動できるから。50 Ω の線路に直につないだ
  ときの 2 倍の電圧を受け、それを 0.6 倍にして 50 Ω へ渡している — これがインピーダンス変換
- **数 MHz から落ちる**。1 MHz で +1.5 dB、20 MHz で約 0 dB (スルーと同じ)、50 MHz で約 −2.3 dB。
  理由は 3 つ重なる:
  - 2SC1815 の fT は**コレクタ電流で下がる** — データシートの 80 MHz は大きな電流のときで、
    この回路の 0.83 mA では 40 MHz 前後。周波数が上がると β が下がり、出力のインピーダンスが上がる
  - ベースの広がり抵抗 (rbb′ 約 50 Ω) と C<sub>ob</sub> (VCB 約 4 V で 3 pF) で、入力側にも極ができる
  - SMA-クリップのリード線 (10 cm で約 80 nH) とブレッドボードの穴の浮遊容量 (1 か所 数 pF)
- S11 は低い周波数で Smith の右端 (開放) の近く。周波数が上がるとトランジスタの容量で
  下 (容量性) へ回り込む
- `02-emitter-follower.s2p` は **ハイブリッド π の模型で計算した値** (実測ではない)。
  Ie 0.83 mA・hFE 150・fT 40 MHz・Cob 3 pF・rbb′ 50 Ω に、クリップのリード 80 nH (入力・出力)
  と各節点の浮遊容量 5 pF を足した。実際の落ち始めはリード線の長さと組み方で変わる —
  リードを短くするほど高い周波数まで平らに伸びる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 22 kΩ |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| RE, RL | 抵抗 (1/4 W) | 1 kΩ |
| CIN, COUT | 電解コンデンサ | 10 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース (R1/R2 の分圧点) の電圧 | 約 1.5 〜 1.6 V | 分圧の計算どおり |
| エミッタの電圧 | 約 0.83 V | ベースよりダイオード 1 個分 (0.6〜0.7V) 低い |
| Q1 の C-E 間電圧 | 約 4.2 V | 活性領域で安定して動いている |
| 入力に 1Vpp の交流を入れたときの出力 (RL の両端) | 約 0.97 Vpp、位相は同じ | 電圧はほぼそのまま、反転もしない |

## 出典

自作。
