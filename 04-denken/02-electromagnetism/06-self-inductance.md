---
book: denken
chapter: 2
id: 2-6
title: 自己インダクタンス — 巻数と鉄心でコイルの L が変わる
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 2-6 自己インダクタンス — 巻数と鉄心でコイルの L が変わる

コイルに流れる電流が変わると、コイル自身の磁束が変わり、変化を妨げる向きに起電力が出る (自己誘導)。
その大きさを決めるのが**自己インダクタンス L**。紙筒に巻いたコイルを 3 つ (50 回・100 回・200 回) 作り、
AD で交流を流して L を測る。**L は巻数の 2 乗に比例**し、筒の中にフェライト棒を入れると何倍にも増える。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| L = μ N² S / l (× 長岡係数) | ソレノイドの L。N は巻数、S は断面積、l は長さ。短いコイルは長岡係数 (1 より小さい) を掛ける |
| L ∝ N² | 同じ筒・同じ長さに巻けば、巻数を 2 倍にすると L は 4 倍 |
| X_L = ω L = 2π f L | コイルのリアクタンス |
| L = V_L sin θ / (ω I) | 測った電圧 V_L、電流 I、位相差 θ から L を求める |

## 回路図

```circuit
title: 図1 コイルと基準抵抗を直列に (AD で測る)
style:
  standard: jis
  pitch: 1.2
parts:
  W1: sine c1 h1 l=$\mathrm{W1}$
  L1: inductor c4 e4 l=$\mathrm{L_x}$
  M1: voltmeter c6 e6 l=$\mathrm{CH1}$
  Rr: resistor e4 h4 150 l=$\mathrm{R_{ref}}$
  M2: voltmeter e8 h8 l=$\mathrm{CH2}$
  G1: ground h1
wires:
  - c1 -- c4 -- c6
  - e4 -- e6 -- e8
  - h1 -- h4 -- h8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/06-self-inductance-1.svg)

- W1 は AD の波形発生器。100 kHz、振幅 1 V。流れる電流は 7 mA 以下 (0-1 の 10 mA に収まる)
- L<sub>x</sub> が測るコイル。R<sub>ref</sub> = 150 Ω が電流を読む基準抵抗 (I = CH2 / 150 Ω)
- CH1 は差動でコイルの両端 (1+ を上、1− をコイルと R<sub>ref</sub> の間)。CH2 は R<sub>ref</sub> の両端 (GND 基準)

## 実体配線図

コイルは両端の被覆をはがし、リードをブレッドボードの穴に直に挿す。R<sub>ref</sub> も同じ板に載せる。

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  L1: inductor/axial c5 c10
  Rr: resistor d10 d15 150
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-", "2+", "2-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.1+ -- a5 blue
  - AD.1- -- b10 orange [h-10]
  - AD.2+ -- a10 white
  - AD.2- -- -t12 black
  - a15 -- -t15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/breadboard/06-self-inductance.svg)

- W1 は L<sub>x</sub> の左端 (5 列)。1+ も同じ 5 列に当て、コイルの両端を差動で見る
- 10 列がコイルと R<sub>ref</sub> の間。1− と 2+ をここに当てる。2− は GND レール
- R<sub>ref</sub> の右端 (15 列) を GND レールへ。3 個のコイルは 5 列と 10 列のリードを挿し替える
- 板に流れる電流は 7 mA 以下で、ブレッドボードの 1 穴 200 mA に十分収まる (計算値)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 (3 個) | 手巻きのコイル | 直径 20 mm の紙筒に φ0.3 mm のポリウレタン線。巻き幅はどれも 33 mm。50 回 (間を空けて 1 層)・100 回 (密に 1 層)・200 回 (密に 2 層) |
| Rref | 抵抗 (1/4 W) | 150 Ω |
| — | 鉄心 | フェライト棒 (バーアンテナ用、φ10 mm × 100 mm 程度) |

巻線の抵抗は 50 回 0.78 Ω・100 回 1.55 Ω・200 回 3.2 Ω (計算値)。

## 手順

1. 100 回のコイルをつなぎ、CH1・CH2 の振幅と位相差を読む。L = V_L sin θ / (ω I) で L を出す
2. 50 回・200 回に替えて同じことをする
3. 100 回のコイルの筒にフェライト棒を差し込み、同じく読む。棒を半分だけ入れた所も読む
4. (比べる) フェライト棒の代わりに鉄のボルトを入れる

## 計器の設定

計器は Analog Discovery 3 (AD3)。Wavegen W1 が 100 kHz の正弦波を出し、Scope の 2 ch で電圧と電流を同時に読めるため。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、100 kHz、Amplitude 1 V |
| Scope | CH1 = コイル (差動)、CH2 = Rref。Time base 2 µs/div。Measure で CH1・CH2 の Amplitude と、CH2 の Phase |

100 回のコイルの画面。コイルの電圧は電流 (CH2) より 88.5° 進む (CH2 が 88.5° 遅れる)。

```scope
title: 図3 100 回のコイル — 電流 (CH2) はコイルの電圧 (CH1) より 88.5° 遅れる
time: 2us/div
trigger: ch1 rising 0V
ch1: {wave: sine 100kHz 370mV, range: 200mV/div}
ch2: {wave: sine 100kHz 920mV phase -88.5deg, range: 500mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/scope/06-self-inductance.svg)

### オシロスコープと発振器

汎用の計器への読み替えの全体は [回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。AD の CH1 はコイルの両端を差動で挟み、
1− がコイルと R<sub>ref</sub> の間 (GND ではない) に当たる。汎用オシロのグランドクリップはそこに当てられない。

**回路はそのままで、2 本の先端をコイルの上と下に当て、コイルの電圧は CH1 − CH2 で引く** (図4)。
差 (コイルの電圧、振幅 0.37 V) は CH1 の振れ (約 1 V) の 4 割あり、8 bit でも埋もれない。電流は
CH2 (R<sub>ref</sub>、GND 基準) で、AD と同じに読める。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  FG: sine c1 h1 l=$\mathrm{FG}$
  M1: voltmeter c3 h3 l=$\mathrm{CH1}$
  L1: inductor c5 e5 l=$\mathrm{L_x}$
  Rr: resistor e5 h5 150 l=$\mathrm{R_{ref}}$
  M2: voltmeter e8 h8 l=$\mathrm{CH2}$
  G1: ground h1
wires:
  - c1 -- c3 -- c5
  - e5 -- e8
  - h1 -- h3 -- h5 -- h8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/circuit/06-self-inductance-2.svg)

- FG は High-Z、Sine、100 kHz、振幅 1 V (Vpp で入れる機種なら 2 Vpp)。負荷は 163 Ω ほどなので、
  FG の 50 Ω で CH1 の振幅は約 0.78 V に下がる (計算値)。電圧と電流の比 (L) は変わらない
- CH1 の先端をコイルの上 (FG の出力)、CH2 の先端をコイルと R<sub>ref</sub> の間。グランドクリップは 2 本とも GND
- Math で CH1 − CH2 を出し、その振幅と、CH2 に対する位相を Measure で読む

## 見るべき値

計算値 (コイルは線を細い輪の並びとした計算。100 kHz、W1 は振幅 1 V、R<sub>ref</sub> = 150 Ω)。

| コイル | L | X_L = ωL | 電流の振幅 (CH2 / 150 Ω) | コイルの電圧 (CH1) | 位相差 θ |
| --- | --- | --- | --- | --- | --- |
| 50 回 | 24.2 µH | 15.2 Ω | 6.60 mA | 0.10 V | 87.1° |
| 100 回 | 95.9 µH | 60.3 Ω | 6.13 mA (CH2 0.920 V) | 0.370 V | 88.5° |
| 200 回 (2 層) | 389 µH | 244 Ω | 3.47 mA | 0.847 V | 89.3° |
| 100 回 + フェライト棒 | 数倍 (目安 5 倍前後) | — | — | — | — |

巻数と L をグラフにすると、ほぼ L ∝ N² の放物線に乗る (図5。線は 100 回の 95.9 µH を N² 倍したもの。表の 200 回の 389 µH は、2 層目の分だけ線の 384 µH より上)。

```graph
title: 図5 L は巻数の 2 乗に比例する
x: 巻数 回 0..220
y: インダクタンス µH 0..450
lines:
  100 回から N² 比例 µH: 95.9 * (x / 100)^2
notes:
  - mark 50
  - mark 100
  - mark 200
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/02-electromagnetism/graph/06-self-inductance.svg)

分かること:

- **巻数を 2 倍にすると L は 4 倍** (24.2 → 95.9 → 389 µH)。巻数が 2 倍だと、同じ電流で磁束が 2 倍、
  その磁束を貫く巻数も 2 倍になるから。200 回は 2 層目の直径が少し大きい分、4 倍をわずかに超える
- 位相差がどれも 90° に近いのは、巻線の抵抗 (1〜3 Ω) が X_L より小さいから。θ が 90° に足りない分から
  巻線の抵抗が分かる (Analog Discovery の本の 6-3)
- **フェライト棒を入れると L が何倍にもなる。** 透磁率 μ の大きな鉄心が磁束を通しやすくする。
  棒が筒の断面の一部しか埋めず、磁路の残りは空気なので、μ の比 (数百〜数千) ほどは増えない
- 鉄のボルトでは、100 kHz では L があまり増えず、位相差が大きく 90° から離れる。鉄の中を流れる
  うず電流 (2-13) が損失になり、抵抗の分が増えるため。電力の変圧器の鉄心が薄い板を重ねる理由
- 相互インダクタンス (2-7) と和動・差動接続 (2-8) は、この 100 回のコイルを 2 つ使う

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
