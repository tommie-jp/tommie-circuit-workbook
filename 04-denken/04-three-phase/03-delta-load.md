---
book: denken
chapter: 4
id: 4-3
title: Δ 負荷 — 線電流は相電流の √3 倍
tier: 50
source: 自作
board: BB
---

# 4-3 Δ 負荷 — 線電流は相電流の √3 倍

4-1 で作った三相電源に、抵抗 3 本を三角形につないだ **Δ (デルタ) 結線**の負荷を
つなぐ。Δ の 1 辺を流れる電流 (相電流) と、電源から出て行く電流 (線電流) を
それぞれ抵抗の両端の電圧から求めて比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I_a = I_ab − I_ca | 線電流 (a 線) は、Δ の 2 つの辺の電流の差 (キルヒホッフの電流則) |
| \|I_a\| = √3 × \|I_ab\| | 平衡負荷なら、線電流の大きさは相電流 (Δ の 1 辺の電流) の √3 倍 |
| ∠I_a = ∠I_ab − 30° | 線電流の位相は、その相電流より 30° 遅れる |

## 回路図

```circuit
title: 図1 三相電源にデルタ結線の負荷
parts:
  V1: sine c1 e1 1 l=$\mathrm{W1}$
  G1: ground e1
  V2: sine i1 k1 1 l=$\mathrm{W2}$
  G2: ground k1
  R1: resistor c3 e3 10k
  R2: resistor i4 g4 10k
  U1: opamp f8 +down TL071
  G3: ground g6
  Rf: resistor d7 d10 10k
  RLA: resistor c13 c15 20 l=$\mathrm{R_{LA}}$
  RLC: resistor f13 f15 20 l=$\mathrm{R_{LC}}$
  RLB: resistor i13 i15 20 l=$\mathrm{R_{LB}}$
  RCA: resistor c17 f17 1k l=$\mathrm{R_{CA}}$
  RBC: resistor f17 i17 1k l=$\mathrm{R_{BC}}$
  RAB: resistor c20 i20 1k l=$\mathrm{R_{AB}}$
wires:
  - e3 -- e4 -- e7
  - e4 -- g4
  - d7 -- e7
  - e7 |- U1.-
  - g6 |- U1.+
  - d10 -- f10
  - c1 -- c3 -- c13
  - i1 -- i4 -- i13
  - U1.out -- f10 -- f13
  - c15 -- c17 -- c20
  - f15 -- f17
  - i15 -- i17 -- i20
notes:
  - text b12: 1 相目
  - text g12: 3 相目
  - text h12: 2 相目
  - text b17: a
  - text f17a3: c
  - text j17: b
style:
  standard: jis
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/03-delta-load-1.svg)

- RLA・RLB・RLC (各 20 Ω) は**線電流を測るためのシャント**。値は小さく、
  電源の電圧をほとんど下げない
- RAB・RBC・RCA (各 1 kΩ) が Δ 結線の負荷本体。a・b・c の 3 点を三角形につなぐ
- RLA の両端の電圧を Rline = 20 Ω で割ると線電流、RAB の両端の電圧を
  1 kΩ で割ると相電流になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上のブロック: TL071 の入力側と R1・R2、右に d 行の線電流シャントと b・c 行の Δ の 2 辺。下のブロック: 出力側と Rf、g・h・j 行で 3 相を右へ運び、i 行に Δ の残り 1 辺 (RCA)
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  RLA: resistor d35 d38 20
  RLB: resistor d41 d44 20
  RLC: resistor d53 d56 20
  RAB: resistor b38 b44 1k
  RBC: resistor c44 c56 1k
  RCA: resistor i38 i56 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+, V-, W1, W2, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t6 black [v11, h-208]
  - AD.V+ -- +t8 red [v19, h-218]
  - AD.V- -- a13 purple [v27, h-148, v79, h-10]
  - AD.W1 -- c17 yellow [v35, h-128]
  - AD.W2 -- b25 orange
  - AD.1+ -- a35 yellow [v27, h172]
  - AD.1- -- c38 green [v19, h172]
  - AD.2+ -- a38 green [v11, h152]
  - AD.2- -- a44 brown [v3, h232]
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - e25 -- f25 orange
  - j25 -- j41 orange
  - h14 -- h53 blue
  - f35 -- e35 yellow
  - f41 -- e41 orange
  - f53 -- e53 blue
  - e38 -- f38 green
  - e56 -- f56 pink
notes:
  - text small: 列 38 が a 点、44 が b 点、56 が c 点 (どれも a〜e 行の同じ列は同じネット)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/03-delta-load.svg)

- 35・41・53 列は AD.W1・AD.W2・U1.6 (3 相目) を下の段の g・j・h 行で右へ運び、
  溝を渡る短い線 (e35・e41・e53) で上の段へ戻したもの。
  d 行のシャント (RLA・RLB・RLC) を通って a・b・c の 3 点になる
- **a〜e 行は同じ列なら同じネット**なので、a 点 (列 38) は RLA (d38)・RAB (b38)・
  緑の線 (e38) に AD の 2+ (a38)・1− (c38) を加えた 5 つの穴に分かれて出る。
  別の行の穴を使うのは、実物のブレッドボードで同じ穴に 2 本挿せないため。
  b 点は列 44、c 点は列 56 も同じ考え方
- RCA は a 点と c 点を結ぶ。上の段に置くと RAB・RBC の上をまたぎ、AD の線を挿す穴に
  上から届かなくなるので、e38–f38・e56–f56 の短い線で溝を渡して下の段の i 行
  (i38–i56) に置く
- AD の 1+・1− は RLA の両端 (a35・c38) に挿し、線電流 a を差動で測る。
  2+・2− は RAB の両端 (a38・a44) に挿し、相電流 ab を差動で測る。
  1− も 2− も GND のレールには挿さない (挿すと a 点か b 点が GND に落ちる)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope | CH1 = RLA の両端 (差動、線電流 a。1+ を a35、1− を c38)、CH2 = RAB の両端 (差動、相電流 ab。2+ を a38、2− を a44) |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

RLA の両端は数十 mV しかないので、CH1 は 20 mV/div、CH2 は 500 mV/div と
V/div を分けてある。高さではなく位相を見る。

```scope
title: 図3 相電流 (CH2) は線電流 (CH1) より 30° 進む (V/div は別)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 56.6mV, range: 20mV/div}
ch2: {wave: sine 1kHz 1.63V phase 30deg, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/03-delta-load.svg)

### オシロスコープと発振器

発振器・電源・プローブの読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。違うのは測り方と、線のシャントの値だ。
AD 版は RLA と RAB の両端を差動で挟む。汎用オシロでは、どちらの端にも
グランドクリップを当てられない (当てた点が GND に落ち、FG の出力か三相の 1 点を短絡する)。

**線のシャント RLA・RLB・RLC を 20 Ω から 200 Ω に替え、回路はそのまま、両端を
GND 基準で測って Math で引く** (図4)。20 Ω のままだと RLA の両端は 49 mV (計算値) で、
a 点の電圧の 6 % しかない。2 本の先端で引くと、ch どうしの利得の差 (数 %) だけで
同じくらいの誤差が出て読めない。シャントを GND 側へ移すこともできない。
線電流 I_a は b・c の線を通って電源へ戻り、I_a だけが流れる GND 側の線が無いからだ。
200 Ω なら RLA の両端は a 点の電圧の 6 割になる。線電流と相電流の比 √3 と
位相の 30° は、シャントの値によらない (見るべき値の下の説明)。

```circuit
title: 図4 汎用オシロでの測り方
parts:
  U1: port a1
  V1: sine e1 g1 1 l=$\mathrm{FG}_1$
  G1: ground g1
  V2: sine i1 k1 1 l=$\mathrm{FG}_2$
  G2: ground k1
  M2: voltmeter e4 g4 l=$\mathrm{CH2}$
  G3: ground g4
  RLC: resistor a6 a9 200
  RLA: resistor e6 e9 200
  RLB: resistor i6 i9 200
  M1: voltmeter e11 g11 l=$\mathrm{CH1}$
  G4: ground g11
  M3: voltmeter i11 k11 l=$\mathrm{CH2}$
  G5: ground k11
  RCA: resistor a14 e14 1k
  RAB: resistor e14 i14 1k
  RBC: resistor a18 i18 1k
wires:
  - a1 -- a6
  - a9 -- a14 -- a18
  - e1 -- e4 -- e6
  - e9 -- e11 -- e14
  - i1 -- i6
  - i9 -- i11 -- i14 -- i18
notes:
  - text a2f5 blue: 3 相目
  - text e2f5 blue: 1 相目
  - text i2f5 blue: 2 相目
  - text a13d6 blue: c
  - text e13d6 blue: a
  - text i13d6 blue: b
  - text f5 small: 1 回目
  - text j12 small: 2 回目
style:
  standard: jis
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/03-delta-load-2.svg)

- U1 は図1 の OP アンプの出力 (3 相目)。FG₁・FG₂ は FG の CH1・CH2
- ブレッドボードでは d35–d38・d41–d44・d53–d56 の 20 Ω を 200 Ω に挿し替えるだけ。
  グランドクリップは 2 本とも GND のレール
- CH1 は 2 回とも a 点 (38 列)。1 回目は CH2 を RLA の電源側 (35 列)、2 回目は b 点 (44 列) に当てる

| 回 | CH1 | CH2 | Math | 求めるもの |
| --- | --- | --- | --- | --- |
| 1 回目 | a 点 | RLA の電源側 | CH2 − CH1 = RLA の両端 (引く順を選べない機種は CH1 − CH2 を読み、位相を 180° ずらす) | ÷ 200 Ω で線電流 I_a |
| 2 回目 | a 点 | b 点 | CH1 − CH2 = RAB の両端 | ÷ 1 kΩ で相電流 I_ab |

- 位相は、Math と CH1 のゼロ交差の時間差 Δt をカーソルで読み、θ = 360° × 1 kHz × Δt
  で求める。CH1 (a 点) を 2 回とも同じにしたので、2 回の θ の差が線電流と相電流の
  位相差になる。1 回目は約 0° (I_a は a 点の電圧と同相)、2 回目は約 +30° (83 µs 進み)
- 測る前に 2 本の先端を同じ点に当て、Math が 0 V 近くになるかを見る

**値が変わる** (計算値。FG の 50 Ω を含む)。

| 測る所 | 200 Ω のシャントでの値 |
| --- | --- |
| FG の CH1 の端子 (RLA の電源側) の振幅 | 0.914 V |
| RLA の両端 (1 回目の Math) | 343 mV → 線電流 1.71 mA |
| RAB の両端 (2 回目の Math) | 0.990 V → 相電流 0.990 mA |
| 線電流 ÷ 相電流、位相 | 1.73 (= √3)、−30° (見るべき値と同じ) |

## 見るべき値

計算値。線のシャント (20 Ω) を含めて計算している。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| RAB の両端 (振幅) | 1.63 V | 相電流 1.63 V ÷ 1 kΩ = 1.63 mA |
| RLA の両端 (振幅) | 56.6 mV | 線電流 56.6 mV ÷ 20 Ω = 2.83 mA |
| 線電流 ÷ 相電流 | 1.73 (= √3) | 線電流は相電流の √3 倍 |
| 線電流の位相 (相電流に対して) | −30° | 線電流は相電流より 30° 遅れる |

分かること:

- **線電流のほうが相電流より大きい。** カタログのモータの定格電流は線電流な
  ので、内部が Δ 結線なら 1 相の巻線に流れる電流はその 1/√3
- シャント (20 Ω) を入れたぶんだけ Δ の両端の電圧は理想 (1.73 V) よりわずかに
  下がる (1.63 V)。**線電流と相電流の比 √3 は、シャントの値によらず成り立つ**
  (キルヒホッフの電流則そのものだから)

## AD3 を 2 台使う — 3 本の線電流を同時に

AD3 を 2 台使うと、オシロの入力が 4 ch になる。2 台の配線・GND の共通化・T2 での同期は
[4-1 の「AD3 を 2 台使う」](01-three-phase-source.md) と同じ。W1・W2 と Supplies は AD-A だけが出し、
AD-B は測るだけ (Wavegen も Supplies も使わない)。
Δ 負荷の線には 3 本とも 20 Ω のシャント (RLA・RLB・RLC) が入っているので、3 本の線電流を 1 回で見られる。

| 台 | CH1 | CH2 |
| --- | --- | --- |
| AD-A | RLA の両端 (差動、線電流 a) | RAB の両端 (差動、相電流 ab) |
| AD-B | RLB の両端 (差動、線電流 b) | RLC の両端 (差動、線電流 c) |

計算値。

| 台 | 測る所 | 期待する値 |
| --- | --- | --- |
| AD-A | RLA の両端の振幅、RAB の両端の振幅 | 56.6 mV、1.63 V (線電流 ÷ 相電流 = √3) |
| AD-B | RLB・RLC の両端の振幅 | どちらも 56.6 mV (3 本の線電流が等しい) |
| AD-B | CH1 (b 線) に対する CH2 (c 線) の位相 | −120° (= +240°) |

- 3 本の線電流はどれも 2.83 mA (振幅) で 120° ずつずれ、瞬時値の和は 0 (キルヒホッフの電流則)。
  2 台の画面で 1 つの時刻に合わせて読み、足す
- 1− と 2− は GND のレールに挿さない。RLB・RLC の両端の穴は、d 行のシャントの両側 (a 点・b 点・c 点の列) から取る
  (同じ穴に 2 本挿せないときは、同じ列の別の行)
- 実機では確かめていない (計算値)

## 出典

自作。
