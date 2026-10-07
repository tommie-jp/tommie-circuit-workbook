---
book: circuits
chapter: 3
id: 3-5
title: 水晶発振 — CMOS インバータ + 水晶
tier: 50
source: 自作
board: BB
---

# 3-5 水晶発振 — CMOS インバータ + 水晶

**インバータ**は、入力が High なら Low を、Low なら High を出す論理ゲート (NOT。第 10 章)。
74HC04 は、**CMOS** のインバータを 6 個入れた IC。CMOS は、P チャネルと N チャネルの MOSFET (2-5 で見た) を対にして作る回路の方式で、
出力が切り替わる一瞬を除くと電流がほとんど流れない。入力にも電流がほとんど流れ込まないので、1 MΩ の抵抗を付けても動作点が崩れない。
そのインバータ 1 個を帰還抵抗で直線領域 (入力に比例して出力が変わる、増幅器として働く範囲)
で動かし、**水晶振動子** (決まった周波数でだけ強く振動する水晶の部品) で発振周波数を
決めるのが「ピアース発振」。マイコンのクロック (動作の拍子) やラジオの局部発振に使われる
基本形で、RC の発振 (3-1〜3-3) よりけた違いに周波数が正確。もう 1 個のインバータで
緩衝 (バッファ) してから外に出す。

## 回路図

```circuit
title: 図1 水晶発振 (ピアース)
parts:
  U1A: not 3,3 74HC04
  U1B: not 8,2 74HC04
  Rf: resistor 1,2 5,2 1M
  Rd: resistor 5,3 7,3 330
  X1: crystal 1,4 7,4 4M
  C1: capacitor 1,4 1,5 22p
  C2: capacitor 7,4 7,5 22p
  G1: ground gnd
  OUT: port 10,2
  U1C: not 9,4 74HC04
  GUx: ground 8,4 r90
points:
  gnd: 4,5
wires:
  - 1,2 -- 1,3 -- 1,4
  - 1,3 -- U1A.in
  - U1A.out -- 5,3
  - 5,2 -- 5,3
  - 7,3 -- 7,4
  - 1,5 -- gnd -- 7,5
  - 5,2 -- U1B.in
  - U1B.out -- 10,2
  - U1C.in -| 8,4
notes:
  - text 9,5 blue center: "残り4ゲート (入力はGND)"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/05-crystal-oscillator.svg)

- 図1 の U1A・U1B・U1C は、同じ 74HC04 (U1、1 個) の中のインバータ。U1A (1 番入力・2 番出力) が発振、U1B (3 番入力・4 番出力) が緩衝、
  U1C (5 番入力・6 番出力) は使わない残り 4 個をまとめて描いたもの (9・11・13 番の入力と 8・10・12 番の出力も同じ扱い)
- **Rf (1 MΩ) が U1A を直線領域でバイアス** (動作点を決めること) する。CMOS インバータは本来
  0 か 1 のスイッチだが、出力を入力へ抵抗で戻すと**アンプ**として使える
- **Rd (330 Ω) は水晶の駆動レベルを落とす ダンピング抵抗。** 無いと水晶に
  流れ込む電流が大きすぎて、水晶が過駆動で劣化する
- C1・C2 (22 pF) は**負荷容量**。水晶の指定 (多くは 18〜22 pF) に合わせる。
  値がずれると発振周波数もわずかにずれる
- U1B は緩衝用。U1A の出力に直接オシロや次段をつなぐと発振が止まることがあるので、
  1 段はさんで外に出す

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 1A (1 番) を 6 列の線で上ブロックへ上げ、水晶と C1・C2 は上、Rf・Rd は下に組む。上の赤レール = +5V、青レール = GND (上下の青レールは 1 列でつなぐ)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  U1: dip14 @ e8 74HC04
  Rf: resistor h8 h9 1M
  Rd: resistor h10 h16 330
  X1: crystal/hc49 b6 b16
  C1: capacitor c3 c6 22p
  C2: capacitor c16 c19 22p
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 1-]
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t4 black
  - +t8 -- a8 red
  - -t1 -- -b1 black
  - g8 -- g6 orange
  - f6 -- d6 orange
  - g9 -- g10 orange
  - d16 -- g16 orange
  - a3 -- -t3 black
  - a19 -- -t19 black
  - j14 -- -b14 black
  - j11 -- SC.1+ gray
  - SC.1- -- -b22 black
  - j12 -- -b12 black
  # 使わない 4 ゲートの入力 (PIN 5・9・11・13) を GND へ
  - a9 -- -t9 black
  - a11 -- -t11 black
  - a13 -- -t13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/05-crystal-oscillator.svg)

- 図2 の **U1 は 14 ピンの 74HC04。使うのは 1 番・2 番 (発振用。図1 の U1A) と 3 番・4 番
  (緩衝用。図1 の U1B) の 2 ゲートだけ。** 7 番が GND、14 番が VCC
- 水晶 (HC-49/U) は極性が無いので向きは自由。**リード線は短く**、6 列 (1 番から
  上げた線) と 16 列 (Rd・C2 の点。溝をまたぐ線で下の Rd へ) の間に置く
- **使わない入力は GND へ。** 残り 4 ゲートの入力 (5・9・11・13 番) を GND に
  つなぐ。浮いた CMOS 入力は勝手に振れて消費電流が増え、発振の邪魔にもなる。
  5 番 (12 列の下) は j 行から下の青レールへ、13・11・9 番 (9・11・13 列の上) は
  a 行から上の青レールへ。上下の青レールは 1 列でつなぐ。出力 (6・8・10・12 番)
  は何もつながずに開けておく

**ブレッドボードで組んでよい理由 (3 MHz の例外)。** 4 MHz はこの教科書の
ブレッドボードの目安 (ブレッドボードの上の回路は 3 MHz 以下) をわずかに超える。あえて例外にした。
周波数を決めるのは水晶で、低インピーダンスの CMOS インバータが水晶を駆動するので、
ブレッドボードの浮遊容量は周波数をわずかに引っ張るだけで、発振そのものは崩れない。
リード線は短くし、電源は 5 V、電流は数 mA で、ブレッドボードの電圧・電流の範囲にも十分収まる。
この実験で見たいのは発振のしくみと波形で、周波数の正確さではない
(読みが 4.000 MHz から少しずれても、実験の目的は損なわれない)。

- 電源は AD3 の Supplies (V+ を 5 V にする)。74HC04 の消費電流は 4 MHz で数 mA で、V+ の 50 mA (USB 給電で 250 mW) に収まる。
  V+ は上の + レール、GND は上の − レールへ入れる
- Scope はブレッドボードの下に別の箱 (AD3 Scope) で描いた。1+ (灰) は U1B の出力 (4 番、11 列。`j11`)、1− (黒) は下の − レール (GND) へ挿す

## 計器の設定

オシロには AD3 の Scope を使う。4 MHz は 10 MHz 以下で、波形の形も見たいから。ただし帯域と標本化を先に確かめておく。

- **帯域**: ブレッドボードへ付属ワイヤで直に挿す場合の AD3 の帯域は 9 MHz (−3 dB。0-5 で測った値)。4 MHz の正弦波は約 91 % (−0.8 dB) に落ちる
  (1 次遅れとして 1 ÷ √(1 + (4/9)²) ≈ 0.91)。方形波の平らな部分は、半周期 125 ns が時定数 17.7 ns の 7 倍あるので、ほぼ 5 V まで届く。
  3 倍の高調波 (12 MHz) は約 60 %、5 倍 (20 MHz) は約 41 % まで落ちるので、角は少し丸く見える
- **標本化**: AD3 は最大 125 MS/s で標本を取る (Digilent の公表値。手元の機器で確かめていない目安)。4 MHz の 1 周期 (250 ns) に約 31 点入る。
  方形波の形を見るには 1 周期に 10 点以上あれば足りる。Time を 50 ns/div にすると、画面 (10 目盛 = 500 ns) に 2 周期が入る
- 周波数は Scope の Measure の Frequency でも読める。精度まで確かめるなら周波数カウンタ (0-9) を使う

| 設定 | 値 |
| --- | --- |
| Scope CH1 (U1B の出力、4 番) | DC、1 V/div |
| Time | 50 ns/div (500 ns で 2 周期)。Sample Rate は最大にする |
| Trigger | CH1、立ち上がり、2.5 V |

```scope
title: 図3 U1B の出力 (4 番) — 4 MHz の方形波 (周期 250 ns)
time: 50ns/div
trigger: ch1 rising 2.5V
ch1: {wave: square 4MHz 2.5V offset 2.5V | rc 17.7ns, range: 1V/div}
cursors: [-62.5ns, 187.5ns]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/05-crystal-oscillator.svg)

図3 は計算の想定図で、実測ではない。5 V の方形波に、AD3 の 9 MHz の帯域を 1 次遅れ (時定数 17.7 ns = 1 ÷ (2π × 9 MHz)) で重ねた。
カーソルの間隔 250 ns が 1 周期で、周波数に直すと 4 MHz。立ち上がりの丸みは、74HC04 自身の遅れではなく、ほぼ計器の帯域によるもの。

### 水晶単体を VNA で見る (補足)

発振回路に組む前に、水晶そのものの共振を LiteVNA64 の S21 で確かめられる (下限 50 kHz なので 4 MHz は範囲に入る)。
3-1 の直列治具のように水晶を CH0 と CH1 の間に直列に挿し、校正のあと S21 の Log Mag を 3.99〜4.02 MHz で掃引する。
直列共振 f<sub>s</sub> では信号がよく通り、そのすぐ上の並列共振 f<sub>p</sub> では通らない。
発振回路の周波数は、この 2 つの間 (22 pF の負荷容量で決まる所) に来る。測り方と読み方の詳細は
03-nanovna/04-components/06-crystal.md (4-6)。

見えるはずの画面 (理想の模型。HC-49/U の 4 MHz の典型値として C<sub>m</sub> = 31.66 fF、L<sub>m</sub> = 50 mH、R<sub>m</sub> = 50 Ω、C<sub>0</sub> = 5 pF を仮定した目安で、実測ではない)。

```vna
device: litevna64
sweep: 3.99M-4.02M 401
title: 図4 4 MHz 水晶の S21 — fs (通る) と fp (通らない)
dut:
  - series C 31.66f esl 50m esr 50 cp 5p
traces:
  - S21 logmag
markers:
  - 4.0001M
  - 4.0127M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/vna/05-crystal-oscillator.svg)

f<sub>p</sub> = f<sub>s</sub>·√(1 + C<sub>m</sub>/C<sub>0</sub>) ≈ 4.0127 MHz で、f<sub>s</sub> との差は約 13 kHz。
図の読み値は、f<sub>s</sub> (4.000 MHz) で −4.0 dB (R<sub>m</sub> = 50 Ω が 50 Ω の 2 つの間に直列に入るため 0 dB にはならない)、
f<sub>p</sub> (4.013 MHz) で −76 dB。
水晶の刻印 (4.000 MHz) は、負荷容量 (ここでは C1・C2 の直列 約 11 pF) を付けた状態の周波数なので、
単体で測る f<sub>s</sub> と f<sub>p</sub> の間に収まるのが正しい。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 (図1 の U1A・U1B・U1C) | CMOS 6 回路入りインバータ (2 回路だけ使用) | 74HC04 |
| Rf | 抵抗 (バイアス) | 1 MΩ |
| Rd | 抵抗 (ダンピング) | 330 Ω |
| X1 | 水晶振動子 (HC-49/U) | 4.000 MHz |
| C1, C2 | セラミックコンデンサ (負荷容量) | 22 pF |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+ (U1B の出力) |

## 見るべき値

計算値・実測値。周波数は水晶の刻印どおりで、抵抗・コンデンサでは変えられない。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| U1B の出力 (OUT) の周波数 | 4.000 MHz ± 30 ppm (± 約 120 Hz) | 水晶自体の精度。抵抗の精度は無関係 |
| 波形 | 方形波に近い (立ち上がり・立ち下がりはややなまる) | CMOS インバータのバッファ出力 |
| U1A の入力 (1 番、8 列) の直流電圧 | 約 Vcc/2 (2.5 V) | Rf の帰還でインバータのしきい値付近にバイアスされている |
| Rd を外した場合 | 発振はするが水晶の発熱が増える | ダンピングが効いている証拠 (長時間は試さない) |

周波数カウンタ (0-9) があれば OUT を直接数えられる。オシロだけなら (図3)
周期を読んで逆数を取る (0.25 µs 前後で読み取れれば十分)。±30 ppm の違いはオシロの読みでは
分からないので、精度まで確かめるなら周波数カウンタを使う。U1 の入力の直流電圧はテスターの
直流電圧レンジで、1 番 (8 列) と GND の間を測る。

## 出典

自作。
