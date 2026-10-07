---
book: denken
chapter: 7
id: 7-8
title: 交流ブリッジで C と L を測る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 7-8 交流ブリッジで C と L を測る

ホイートストンブリッジ (1-6) を交流で働かせると、コンデンサやコイルの値を、値の分かった
部品との比で測れる。4 つの辺のインピーダンスが **Z₁ Z₄ = Z₂ Z₃** になると、真ん中の検出器の
電圧が 0 になる (平衡)。交流では大きさと位相の 2 つがそろう必要がある。C は標準のコンデンサと
比べる**容量ブリッジ**で、L は C と抵抗で作る**マクスウェルブリッジ**で測る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Z₁ Z₄ = Z₂ Z₃ | 交流ブリッジの平衡条件 (複素数で。大きさと位相の 2 つの式になる) |
| C_X = C_S R1 / R2 | 容量ブリッジ (図1)。周波数によらない |
| L_X = R2 R3 C4 | マクスウェルブリッジ (図2) の L の条件。周波数によらない |
| r_X = R2 R3 / R4 | 同じく、コイルの巻線抵抗の条件 |

## 回路図

```circuit
title: 図1 容量ブリッジ (ド・ソーティ) で Cx を測る
parts:
  V1: sine 1,2 1,6 1 l=$\mathrm{W1}$
  R1: resistor-var 4,2 4,4 1k
  CS: capacitor 4,4 4,6 100n l=$\mathrm{C_S}$
  R2: resistor 8,2 8,4 1k
  CX: capacitor 8,4 8,6 47n l=$\mathrm{C_X}$
  M1: voltmeter 5,4 7,4 l=$\mathrm{CH1}$
  G1: ground 1,6
wires:
  - 1,2 -- 4,2 -- 8,2
  - 4,4 -- 5,4
  - 7,4 -- 8,4
  - 1,6 -- 4,6 -- 8,6
notes:
  - text 4.5,3.5 blue: P
  - text 8.5,3.5 blue: Q
  - text 1,1 blue: A (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/08-ac-bridge-1.svg)

- 左の辺は R1 (半固定抵抗 1 kΩ) と C_S (標準、100 nF)、右の辺は R2 (1 kΩ) と C_X (測る物、表示 47 nF)
- CH1 は P と Q の間の電圧 (検出器)。AD の CH1 を差動 (1+ が P、1− が Q) で使う。CH2 は電源 A
- R1 を回して CH1 の振幅を最小にする。そのときの R1 をテスターで測り (回路から外して)、
  C_X = C_S × R1 ÷ R2 で出す。C_X = 47 nF なら R1 = 470 Ω で平衡する

```circuit
title: 図2 マクスウェルブリッジで Lx を測る
parts:
  V1: sine 1,2 1,6 1 l=$\mathrm{W1}$
  LX: inductor 4,2 4,4 10m l=$\mathrm{L_X}$
  R3: resistor-var 4,4 4,6 2k
  R2: resistor 8,2 8,4 1k
  R4: resistor-var 8,4 8,6 100k
  C4: capacitor 10,4 10,6 10n
  M1: voltmeter 5,4 7,4 l=$\mathrm{CH1}$
  G1: ground 1,6
wires:
  - 1,2 -- 4,2 -- 8,2
  - 4,4 -- 5,4
  - 7,4 -- 8,4 -- 10,4
  - 1,6 -- 4,6 -- 8,6 -- 10,6
notes:
  - text 4.5,3.5 blue: P
  - text 8.5,3.5 blue: Q
  - text 1,1 blue: A (CH2)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/08-ac-bridge-2.svg)

- 左の辺は L_X (測る物、10 mH、巻線抵抗 r_X) と R3 (半固定 2 kΩ)、右の辺は R2 (1 kΩ) と、
  R4 (半固定 100 kΩ) と C4 (標準、10 nF) の並列
- R3 と R4 を**交互に**回して CH1 を最小にする。R3 が L の条件、R4 が巻線抵抗の条件を受け持つ。
  1 つだけでは 0 まで下がらない (大きさか位相のどちらかが残る)

## 実体配線図

```breadboard
title: 図3 容量ブリッジのブレッドボード
board: half
parts:
  R1: potentiometer/trimmer h5(1) h6(w) h7(3) 1k
  CS: capacitor/film h9 h12 100n
  R2: resistor c14 c19 1k
  CX: capacitor/film d19 d22 47n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2-, 1+, 2+, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- a14 yellow
  - AD.2- -- -t8 black
  - b5 -- b14 yellow
  - e5 -- f5 yellow
  - g6 -- g9 blue
  - e9 -- f9 blue
  - AD.1+ -- a9 blue
  - j12 -- -b12 black
  - AD.1- -- a19 green
  - a22 -- -t22 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/breadboard/08-ac-bridge-1.svg)

- 5 列が A (W1)。黄色の線で 14 列へ運んで R2 (14〜19 列) と CH2 (2+、14 列)。19 列が Q で CH1 の 1−、
  C_X (19〜22 列) の先を GND のレールへ
- 5 列から溝を渡って下の段の R1 (半固定、1 番を 5 列、ワイパ w を 6 列)。6 列が P。
  青い線で 9 列へ出して C_S (9〜12 列)。9 列は短い青い線で溝を渡して上の段へ上げ、
  CH1 の 1+ を上の段の 9 列に挿す。R1 の 3 番のピン (7 列) は使わない

```breadboard
title: 図4 マクスウェルブリッジのブレッドボード
board: half
parts:
  LX: inductor/axial c5 c10 10m
  R3: potentiometer/trimmer h10(1) h11(w) h12(3) 2k
  R2: resistor c18 c23 1k
  R4: potentiometer/trimmer h23(1) h24(w) h25(3) 100k
  C4: capacitor/film d23 d27 10n
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 2-, 1+, 2+, 1-]
wires:
  - AD.GND -- -t7 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- a18 yellow
  - AD.2- -- -t9 black
  - b5 -- b18 yellow
  - AD.1+ -- a10 blue
  - e10 -- f10 blue
  - f11 -- f14 black
  - j14 -- -b14 black
  - AD.1- -- a23 green
  - e23 -- f23 green
  - f24 -- f27 black
  - j27 -- -b27 black
  - a27 -- -t27 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/breadboard/08-ac-bridge-2.svg)

- 5 列が A。L_X (5〜10 列) の先の 10 列が P で CH1 の 1+、溝を渡って R3 (1 番を 10 列、w を 11 列)。
  w から黒い線で 14 列へ出して GND のレールへ
- A から黄色の線で 18 列へ運んで R2 (18〜23 列) と CH2 (2+)。23 列が Q で CH1 の 1−。C4 (23〜27 列) と
  R4 (1 番を 23 列、w を 24 列) を Q と GND の間に並べる。半固定抵抗の 3 番のピンは使わない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Offset 0 V |
| Scope | CH1 = P − Q (差動、検出器)、CH2 = A。CH1 は平衡に近づくにつれて 100 mV/div → 10 mV/div → 1 mV/div と上げる。Average を 16 回 |
| Measure | CH1 の Amplitude |

1 kHz は平衡の条件には入らない (どちらのブリッジも周波数によらない)。周波数を変えても
平衡がずれないことを確かめると、配線の浮遊容量が効いていないかの確かめになる。

### オシロスコープと発振器

AD 版は CH1 を P と Q の差動で当てる。P も Q も GND ではないので、汎用オシロのグランドクリップを
どちらかに当てると、その点が GND に落ちて C_S か C_X (マクスウェルでは R3 か R4 ∥ C4) が短絡される
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) の落とし穴)。

**回路はそのまま、P と Q を GND 基準で 1 本ずつ測り、Math の CH1 − CH2 を検出器にする** (図5)。
平衡の近くでは差が振れ (約 0.96 V) の 1 % を切り、8 bit のオシロでは Math の読みが分解能に埋もれる。
そこで**差を見るより 2 本の波が重なるのを見る**: CH1 と CH2 を同じ V/div・同じ位置にし、振幅と位相が
そろう所を探す。最後は Math を 10 mV/div にして最小を探す (8 bit の目安で ±1 % 程度まで詰められる)。

```circuit
title: 図5 汎用オシロでの測り方 (容量ブリッジ)
parts:
  V1: sine 1,2 1,6 1 l=$\mathrm{FG}$
  R1: resistor-var 4,2 4,4 1k
  CS: capacitor 4,4 4,6 100n l=$\mathrm{C_S}$
  M1: voltmeter 6,4 6,6 l=$\mathrm{CH1}$
  R2: resistor 8,2 8,4 1k
  CX: capacitor 8,4 8,6 47n l=$\mathrm{C_X}$
  M2: voltmeter 10,4 10,6 l=$\mathrm{CH2}$
  G1: ground 1,6
wires:
  - 1,2 -- 4,2 -- 8,2
  - 4,4 -- 6,4
  - 8,4 -- 10,4
  - 1,6 -- 4,6 -- 6,6 -- 8,6 -- 10,6
notes:
  - text 4.5,3.5 blue: P
  - text 8.5,3.5 blue: Q
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/08-ac-bridge-3.svg)

- FG は Sine、1 kHz、**2 Vpp** (AD の Amplitude 1 V は山の高さ)、出力は High-Z
  ([0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))
- CH1 の先端を P (容量ブリッジは下の段の 9 列、マクスウェルブリッジは 10 列)、CH2 の先端を Q
  (19 列・23 列)。グランドクリップは 2 本とも GND のレール。AD の 1+・1−・2+ の線は外す
- FG の 50 Ω は A の電圧を少し下げるが、平衡の条件 (比) には入らない

## 見るべき値

計算値。W1 は振幅 1 V。

容量ブリッジ (C_X = 47 nF、C_S = 100 nF、R2 = 1 kΩ):

| R1 | 検出器 (CH1) の振幅 |
| --- | --- |
| 390 Ω | 46.8 mV |
| 430 Ω | 23.3 mV |
| **470 Ω** | **0 (平衡)** |
| 510 Ω | 23.0 mV |
| 560 Ω | 51.2 mV |

```graph
title: 図6 容量ブリッジの検出器の振幅 (計算) — R1 = 470 Ω で 0 になる
x: R1 Ω 0..1000
y: 検出器の振幅 mV 0..300
lines:
  検出器 mV: 1000 * abs(0.2953 - 0.00062832 * x) / sqrt(1 + (0.00062832 * x) ^ 2) / sqrt(1 + 0.2953 ^ 2)
notes:
  - mark 470
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/graph/08-ac-bridge.svg)

式の 0.2953 は ωC_X R2、0.00062832 は ωC_S (1 Ω あたり)。

マクスウェルブリッジ (L_X = 10 mH、巻線抵抗 25 Ω と仮定、R2 = 1 kΩ、C4 = 10 nF):

| 平衡のときの値 | 計算 |
| --- | --- |
| R3 | L_X ÷ (R2 C4) = 10 mH ÷ (1 kΩ × 10 nF) = **1.00 kΩ** |
| R4 | R2 R3 ÷ r_X = 1 kΩ × 1 kΩ ÷ 25 Ω = **40 kΩ** |
| P・Q の電圧 (平衡時) | どちらも 0.974 V (A と同じ振幅の 97 %) |

分かること:

- **交流ブリッジは 2 つの条件を同時に満たして初めて 0 になる**。容量ブリッジは C_S・C_X とも
  損失の小さいフィルムコンデンサなので 1 つ (R1) で足りるが、コイルは巻線抵抗を持つので、
  マクスウェルブリッジでは R3 と R4 の 2 つを回す
- どちらの平衡条件にも ω が入らない。**周波数の誤差や波形の歪みが測定値に入らない**のが
  ブリッジの長所
- マクスウェルブリッジは、測りにくい L を、精度の良い C と R で測る。可変のコンデンサより
  可変の抵抗のほうが作りやすいため、C を固定にして R で合わせる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
