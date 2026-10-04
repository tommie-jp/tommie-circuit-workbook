---
book: denken
chapter: 10
id: 10-6
title: 単相インバータ — H ブリッジで直流から交流
tier: 100
source: 自作
board: BB
---

# 10-6 単相インバータ — H ブリッジで直流から交流

4 つのスイッチを H の字に組み、対角の 2 つずつを交互にオンにすると、負荷に掛かる電圧の向きが入れ替わり、
直流から交流ができる (**インバータ**)。周波数はスイッチを切り替える速さで決まる。
スイッチには MOSFET 4 つ入りの H ブリッジの IC (DRV8833、TI) を載せたモジュールを使い、AD のディジタル出力で切り替える。
負荷は抵抗と、向きを逆にして並べた 2 つの LED。電流の向きが変わるたびに光る LED が入れ替わる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| S1・S4 がオン → vo = +Vd、S3・S2 がオン → vo = −Vd | 出力は ±Vd の方形波 (振幅 Vd、Vpp = 2 Vd) |
| Vo (実効値) = Vd | 方形波の実効値は振幅そのもの |
| V1 = (4 / π) Vd / √2 ≒ 0.90 Vd | 出力に含まれる基本波 (正弦波の成分) の実効値 |
| f = 切り替えの周波数 | 周波数は直流の電圧と関係なく自由に決まる |

Vd = 5 V なら vo は ±5 V、Vpp 10 V、実効値 5 V、基本波の実効値 4.50 V。

## 回路図

```circuit
title: 図1 単相フルブリッジインバータ (スイッチは DRV8833 の中)
style:
  standard: jis
  pitch: 1.2
parts:
  Vd: vsource b1 h1 5
  S1: switch b4 e4
  S2: switch e4 h4
  S3: switch b14 e14
  S4: switch e14 h14
  R1: resistor e6 e8 220
  D1: led e8 e10
  D2: led c10 c8
  M1: voltmeter g7 g10 l=$\mathrm{CH1}$
  G1: ground h1
wires:
  - b1 -- b4 -- b14
  - h1 -- h4 -- h14
  - e4 -- e5 -- e6
  - e5 -- g5 -- g7
  - c8 -- e8
  - c10 -- e10
  - e10 -- e12 -- e14
  - g10 -- g12 -- e12
notes:
  - text d4f5 blue: A
  - text d13f5 blue: B
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/circuit/06-single-phase-inverter.svg)

- 試験の図と同じく、スイッチ 4 つで描いた。S1〜S4 は DRV8833 の中の MOSFET で、AIN1 = H・AIN2 = L なら S1・S4 がオン (A が +)、
  AIN1 = L・AIN2 = H なら S3・S2 がオン (B が +)。上下の 2 つが同時にオンになって短絡しないよう、IC の中で切り替えの間を空けている
- Vd は AD の Supplies の V+ (5 V)。負荷の電流は 14 mA ほどで、Supplies の 1 レール 250 mW (5 V で 50 mA) に収まる
- 負荷は R1 (220 Ω) と、逆向きに並べた赤い LED 2 つ (D1・D2)。どちらの向きでも片方が光り、もう片方の逆電圧は光る方の順電圧 (約 1.9 V) に抑えられる
- M1 (CH1) は A と B の間 (差動)。出力 vo = vA − vB

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 赤レール = 5 V (AD の V+)、青レール = GND。上下は 29・30 列でつなぐ
board: half
parts:
  D1: led b16(A) b18(K) red
  D2: led d18(A) d16(K) red
  R1: resistor h10 h16 220
  DRV:
    type: device
    at: top
    label: DRV8833 モジュール
    pins: [AIN1, VM, AIN2, nSLEEP, GND, AOUT1, AOUT2]
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, DIO0, 2+, DIO1, 1+, 2-, 1-]
wires:
  - AD.V+ -- +b2 red
  - AD.GND -- -b3 black
  - +b29 -- +t29 red
  - -b30 -- -t30 black
  - DRV.VM -- +t5 red
  - DRV.nSLEEP -- +t7 red
  - DRV.GND -- -t8 black
  - DRV.AIN1 -- a4 yellow
  - e4 -- f4 yellow
  - AD.DIO0 -- j4 yellow
  - DRV.AIN2 -- a6 green
  - e6 -- f6 green
  - AD.DIO1 -- j6 green
  - DRV.AOUT1 -- a10 orange
  - e10 -- f10 orange
  - e16 -- f16 white
  - DRV.AOUT2 -- a18 purple
  - AD.1+ -- j10 orange
  - e18 -- f18 purple
  - AD.1- -- j18 purple
  - AD.2+ -- i4 blue
  - AD.2- -- -b12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/breadboard/06-single-phase-inverter.svg)

- DRV8833 のモジュールはブレッドボードの外に置き、線でつなぐ。ピンの名前は IC の名前で書いた (モジュールによって IN1・OUT1・EEP などと印字が違う)。
  nSLEEP (EEP) を 5 V にしないと IC が眠ったままになる
- 4 列が AIN1、6 列が AIN2。上のブロックでモジュールへ、溝を渡って下のブロックで AD の DIO0・DIO1 へ。10 列が A (AOUT1)、18 列が B (AOUT2)
- R1 は下のブロック (h10→h16)。10・16 列は溝を渡る線で上とつなぐ。16 列と 18 列の間に D1 (b 行、A が 16 列) と D2 (d 行、A が 18 列) を逆向きに挿す
- AD はブレッドボードの下に置いた。CH1 は A と B の間 (1+ を j10、1− を j18。18 列は溝を渡って下へ延ばす)。CH2 (2+) は i4 (AIN1) と青レール

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | Supplies: V+ = 5 V |
| Patterns | DIO0: Clock、Frequency 50 Hz、Duty 50 %、Phase 0°。DIO1: 同じで Phase 180° |
| Scope | CH1 = A と B の間 (差動、vo)。CH2 = AIN1。CH1 は 2 V/div、CH2 は 1 V/div、Time base 5 ms/div |
| Measure | CH1 の Peak-Peak・RMS・Frequency |

Frequency を 1 Hz に下げると、D1 と D2 が 0.5 秒ずつ交互に光るのが見える。50 Hz では目が追いつかず、2 つとも光って見える。

```scope
title: 図3 50 Hz — 出力 vo (CH1) は ±5 V の方形波、AIN1 (CH2) と同じ向き
time: 5ms/div
trigger: ch2 rising 1.65V
ch1: {wave: square 50Hz 5V, range: 2V/div, position: 1div}
ch2: {wave: square 50Hz 1.65V offset 1.65V, range: 1V/div, position: -3.8div}
measure: [vpp, rms, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/10-power-electronics/scope/06-single-phase-inverter.svg)

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH1 は A (10 列) と B (18 列) を差動で挟んでいる。B は GND ではない (どちらのピンも 0 V と 5 V を行き来する) ので、
グランドクリップを当てると B が GND に固定され、S3 がオンの間 5 V を短絡する。出力は各点の振れ (5 V) と同じ大きさなので、
**回路はそのままで、CH1 の先端を A (j10)、CH2 の先端を B (j18) に当て、Math の CH1 − CH2 で vo を作る**。
グランドクリップは 2 本とも青レール。2 ch はこれで使い切るので、AIN1 は見ない。

- 要るのは **逆向きの 2 本の方形波** (AIN1 と AIN2)。2 ch の発振器なら、2 ch 目を 1 ch 目の反転 (位相 180°) にする。
  High 3.3 V / Low 0 V (DRV8833 の入力の H は 2 V 以上なので 5 V でもよい)
- Vd は安定化電源の 5 V、電流制限 50 mA (ふだんは 14 mA)
- 1 ch の発振器しかなければ、AIN2 を GND にして AIN1 だけを方形波にすると、A は 5 V と 0 V (空き) を行き来する片方向の出力になる。
  これはインバータではない (出力が負にならない)

## 見るべき値

計算値 (Vd = 5 V、スイッチの抵抗は 0 とした理想)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 の Peak-Peak | 10.0 V | 出力は +5 V と −5 V を行き来する (2 Vd) |
| CH1 の RMS | 5.00 V | 方形波の実効値は振幅そのもの |
| CH1 の Frequency | 50.00 Hz | Patterns の周波数そのもの |
| 基本波の実効値 (計算) | 4.50 V | 0.90 Vd。残りは 3 次・5 次… の高調波 |
| 負荷の電流 | ±14 mA | (5 V − 1.9 V) / 220 Ω。向きが半周期ごとに入れ替わる |

- **直流の 5 V から、周波数を自由に選べる交流ができる。** 周波数を変えても出力の大きさは変わらない。大きさも変えたいときは、
  各半周期の中を PWM で細かく切る (正弦波 PWM、10-8)。周波数と電圧を一緒に変えてモータを回すのが VVVF (10-13)
- 出力は方形波で、高調波を多く含む。モータや変圧器に掛けるなら、LC のフィルタで基本波を取り出す
- 実物は DRV8833 のオン抵抗 (上下合わせて約 0.4 Ω) で、負荷の電流 14 mA では数 mV しか下がらない

## 出典

自作。DRV8833 の働きと入力の電圧は TI の DRV8833 のデータシート。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Patterns・Supplies・Scope の節)。
