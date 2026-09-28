---
book: denken
chapter: 3
id: 3-8
title: RLC 並列共振 — 共振で電流が最小
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 3-8 RLC 並列共振 — 共振で電流が最小

3-5 の直列共振では、共振で電流が**最大**になった。R・L・C を**並列**にすると逆に、
共振で電源から流れ込む電流が**最小**になる。L に流れる電流と C に流れる電流が
向きの逆な同じ大きさになり、電源から見ると打ち消し合うからだ。電源の電圧を一定にして
周波数を変え、電源の電流を測る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| f0 = 1 / (2π√(LC)) | 共振周波数。直列共振と同じ式 |
| Y = 1/R + j(ωC − 1/(ωL)) | 並列のアドミタンス。共振では虚部が 0 |
| Z_max = R | 共振のインピーダンスは最大で、R だけ |
| I_min = V / R | 共振の電源の電流は最小 |
| I_L = I_C = V / (ω0 L) | 共振でも L と C には電流が流れる。向きが逆で打ち消し合う |

## 回路図

```circuit
title: 図1 RLC 並列 (電流は Rs で読む)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 i1 l=$\mathrm{W1}$
  M1: voltmeter c3 i3 l=$\mathrm{CH1}$
  R1: resistor c5 g5 4.7k
  L1: inductor c7 g7 100m i=IL
  C1: capacitor c9 g9 100n i=IC
  Rs: resistor g11 i11 100 i=I
  M2: voltmeter g13 i13 l=$\mathrm{CH2}$
  G1: ground i1
wires:
  - c1 -- c3 -- c5 -- c7 -- c9
  - g5 -- g7 -- g9 -- g11 -- g13
  - i1 -- i3 -- i11 -- i13
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/circuit/08-parallel-resonance.svg)

- V1 は AD の波形発生器 W1。R1・L1・C1 が並列の回路 (並列共振回路、タンク回路とも呼ぶ)
- Rs (100 Ω) は電源の電流 I を測るシャント。GND 側に置いたので、CH2 は Rs の上を
  GND 基準で読むだけでよい (CH2 ÷ 100 Ω が電流)
- CH1 は電源の電圧。W1 は出力のインピーダンスがほぼ 0 Ω なので、周波数を変えても 1 V のまま
- L1 は 100 mH の小さなコイル (例: Bourns RL622-104K、直流抵抗 235 Ω 以下、許容電流 20 mA)。
  **この大きさのコイルは巻線抵抗 r が数百 Ω ある**。図3〜5 と表の左の列は r = 0 の理想のコイル、
  表の右の 2 列は r = 235 Ω (データシートの上限) のときの計算値

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の段: C1 と Rs。下の段: R1 と L1 (溝を渡る緑の線で 10 列と 15 列へ)
board: half
parts:
  C1: capacitor/ceramic d10 d15 100n
  Rs: resistor b15 b20 100
  R1: resistor g10 g15 4.7k
  L1: inductor/axial i10 i15 100m
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, "1-", "2-", W1, "1+", "2+"]
wires:
  - AD.GND -- -t2 black
  - AD.1- -- -t3 black
  - AD.2- -- -t4 black
  - AD.W1 -- a7 yellow
  - AD.1+ -- a10 orange
  - AD.2+ -- a15 blue
  - c7 -- c10 yellow
  - e10 -- f10 green
  - e15 -- f15 green
  - a20 -- -t20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/breadboard/08-parallel-resonance.svg)

- 10 列が並列の回路の上の端 (電源の側)、15 列が下の端。C1 は上の段、R1 と L1 は下の段に置き、
  e10–f10・e15–f15 の緑の線で溝を渡して 3 つを並列にする
- Rs は 15 列と 20 列の間。20 列から GND のレール (−t) へ黒い線を渡す
- AD の 1− と 2− は GND のレール。1+ は並列の回路の上の端 (10 列。W1 と同じネット)、2+ は Rs の上 (15 列)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、Amplitude 1 V、Offset 0 V。周波数を 500 Hz〜5 kHz の間で振る |
| Scope | CH1 = 電源の電圧 (W1)、CH2 = Rs の電圧 (= 100 Ω × I)。どちらも DC 結合、Average を 16 回 |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

電流の最大は 500 Hz の 2.7 mA で、この本の目安 10 mA (0-1) に収まる。

共振 (1.59 kHz) と 1 kHz の 2 つの画面。CH1 は 2 枚とも 500 mV/div。CH2 は小さいので CH1 と違う V/div にし、
共振の画面は 1 kHz の画面より CH2 を 2.5 倍に拡げてある。高さではなく位相と Measure の数を見る。

```scope
title: 図3 理想のコイルの共振 (1.59 kHz) — 電流 (CH2、20 mV/div) は 0.21 mA で電圧と同相
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1.59kHz 1V, range: 500mV/div}
ch2: {wave: sine 1.59kHz 20.8mV, range: 20mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/08-parallel-resonance-1.svg)

```scope
title: 図4 理想のコイルの 1 kHz — 電流 (CH2、50 mV/div) は 0.96 mA に増え、72° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 96.2mV phase -72.2deg, range: 50mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/scope/08-parallel-resonance-2.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい。端子の読み替えは
[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

- W1 は FG の OUT (出力の設定は High-Z)。振幅 1 V は、Vpp で入れる機種なら 2 Vpp
- CH1 の先端は 10 列 (FG の出力とつながる)、CH2 の先端は 15 列 (Rs の上)。グランドクリップは 2 本とも
  GND のレール。電源は要らない
- 共振の CH2 は 21 mV と小さい。CH2 は **×1 のプローブ** で 10〜20 mV/div にする (×10 では粗すぎる)
- FG の出力の 50 Ω が Rs に足される。回路のインピーダンスは 350 Ω 以上なので、CH1 は
  500 Hz と 5 kHz で 0.95 V、1〜3 kHz で 0.98〜0.99 V に下がるだけ (計算値)。電流も同じ割合で
  下がる。表と同じ値にするなら、周波数を変えるたびに CH1 の振幅が 1.00 V になるよう FG の振幅を合わせる

## 見るべき値

計算値 (R1 = 4.7 kΩ、L1 = 100 mH、C1 = 100 nF、Rs = 100 Ω、W1 の振幅 1 V)。
共振周波数 f0 = 1 / (2π√(0.1 × 100×10⁻⁹)) ≈ **1.59 kHz**、そのときのリアクタンスは
X_L = X_C = 1000 Ω。位相は CH1 (電源の電圧) に対する CH2 (電流)。

| 周波数 | 電流の振幅 (CH2 ÷ 100 Ω) | CH2 の振幅 | 電流の位相 | r = 235 Ω の電流 | r = 235 Ω の位相 | 備考 |
| --- | --- | --- | --- | --- | --- | --- |
| 500 Hz | 2.71 mA | 271 mV | −70° | 2.07 mA | −36° | L の電流が支配的 (遅れ) |
| 1 kHz | 0.96 mA | 96.2 mV | −72° | 0.99 mA | −42° | |
| 1.3 kHz | 0.45 mA | 45.0 mV | −60° | 0.59 mA | −29° | |
| **1.59 kHz (f0)** | **0.208 mA (最小)** | **20.8 mV** | **0°** | 0.42 mA | +7° | L と C の電流が打ち消し合う |
| 2 kHz | 0.50 mA | 49.7 mV | +63° | 0.58 mA | +51° | C の電流が支配的 (進み) |
| 3 kHz | 1.33 mA | 133 mV | +74° | 1.34 mA | +71° | |
| 5 kHz | 2.67 mA | 267 mV | +70° | 2.67 mA | +70° | |

共振のとき: 並列の回路にかかる電圧は 0.979 V、R1 の電流は 0.208 mA。一方 L1 と C1 には
それぞれ **0.98 mA** (= 0.979 V ÷ 1000 Ω) が流れていて、電源の電流の 4.7 倍になる。
L1 と C1 の電流は向きが逆で、2 つの間を行ったり来たりするだけなので、電源からは見えない。

```graph
title: 図5 電源の電流は共振 (1.59 kHz) で谷になる
x: 周波数 Hz log 200..10k
y: 電流の振幅 mA
lines:
  電源の電流 (理想のコイル) mA: 1000*sqrt(0.2128m^2+(2*pi*x*100n-1/(2*pi*x*0.1))^2)/sqrt(1.0213^2+(100*(2*pi*x*100n-1/(2*pi*x*0.1)))^2)
notes:
  - mark 1.59k
  - mark 500
  - mark 5k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/03-ac-circuits/graph/08-parallel-resonance.svg)

分かること:

- **並列共振では電源の電流が最小になり、インピーダンスが最大 (= R) になる。** 直列共振
  (3-5) と逆。R1 を外すと (R → ∞) 電流はもっと 0 に近づく
- **電流の位相は共振の前後で入れ替わる。** 低い周波数では L の電流が大きくて遅れ、
  高い周波数では C の電流が大きくて進む。共振でちょうど 0°
- **実物のコイルの巻線抵抗 r は、共振の谷を浅くする。** 並列の回路では、共振の近くで L/(C r) の抵抗が
  R1 に並列に入ったのと同じになる。r = 235 Ω なら 4.26 kΩ が並列に入り、共振の電流は 0.21 mA から
  0.42 mA に倍増する (計算値)。電流が 0° になる周波数 (1.55 kHz) と電流が最小になる周波数 (1.62 kHz) も
  f0 から少しずれる。r をテスターで測り、表の右の列と比べる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
