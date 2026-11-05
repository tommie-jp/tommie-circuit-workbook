---
book: analog-discovery
chapter: 7
id: 7-13
title: I2C のプルアップと立ち上がり (アナログ ch 併用)
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Protocol の I2C と Scope)
board: BB
---

# 7-13 I2C のプルアップと立ち上がり (アナログ ch 併用)

7-4 では Protocol で LM75 を読み、0 と 1 の並びだけを見た。I2C の線はオープンドレインで、L へは素子が引き下げるが、
H へは**プルアップ抵抗 R<sub>p</sub> がバスの容量 C<sub>b</sub> を充電して戻る**。だから立ち上がりは
時定数 τ (タウ) = R<sub>p</sub> · C<sub>b</sub> でなまる。この題では Protocol で読み出しを続けながら、
同じ線を **Scope (アナログの 2 ch)** で見て、R<sub>p</sub> を替えたときの立ち上がり時間を測り、I2C の仕様の上限と比べる。

I2C の仕様は立ち上がり時間 t<sub>r</sub> を V<sub>DD</sub> の 30 % から 70 % までの時間で決め、標準モード (100 kHz) で 1000 ns、
ファストモード (400 kHz) で 300 ns までとしている。1 次の充電では

- t<sub>r</sub> = τ · ln(0.7 ÷ 0.3) = 0.847 · R<sub>p</sub> · C<sub>b</sub>
- R<sub>p</sub> の下限 = (V<sub>DD</sub> − V<sub>OL</sub>) ÷ I<sub>OL</sub> = (3.3 V − 0.4 V) ÷ 3 mA ≈ 0.97 kΩ (オーム) (L のとき素子が 3 mA で 0.4 V 以下に引けること)

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 SCL・SDA のプルアップ Rp と 220 pF (バスの容量の代わり)
parts:
  AD:
    type: device
    at: 2,4
    label: Analog Discovery 3
    pins: [V+, DIO0, 2+, DIO1, 1+, GND, 1-, 2-]
    turn: mirror
  U1:
    type: device
    model: LM75
    at: 13,4.25
    label: LM75
    pins: [VS, SDA, SCL, OS, GND, A2, A1, A0]
  R1: resistor 8,1 8,2 4.7k l=$R_\mathrm{pSCL}$
  R2: resistor 6,1 6,2 4.7k l=$R_\mathrm{pSDA}$
  C1: capacitor 11,6 11,7 220p
  C2: capacitor 9,6 9,7 220p
  G1: ground 5,8
  G2: ground 12,6.5
wires:
  - AD.V+ -| 5,1
  - 5,1 -- 6,1
  - 6,1 -- 8,1
  - 8,1 -- 12,1
  - U1.VS -| 12,1
  - AD.DIO0 -- 5.5,3.5
  - 5.5,3.5 -- 5.5,3.75
  - AD.2+ -- 5.5,3.75
  - 5.5,3.75 -- 6,3.75
  - 6,2 -- 6,3.75
  - 6,3.75 -- 9,3.75
  - 9,3.75 -- U1.SDA
  - 9,3.75 -- 9,6
  - AD.DIO1 -- 6.5,4
  - AD.1+ -- 6.5,4.25
  - 6.5,4.25 -- 6.5,4
  - 6.5,4 -- 8,4
  - 8,2 -- 8,4
  - 8,4 -- 11,4
  - 11,4 -- U1.SCL
  - 11,4 -- 11,6
  - AD.GND -| 5,8
  - AD.1- -| 5,8
  - AD.2- -| 5,8
  - 5,8 -- 9,8
  - 9,7 -- 9,8
  - 9,8 -- 11,8
  - 11,7 -- 11,8
  - U1.GND -| 12,6.5
  - U1.A2 -| 12,6.5
  - U1.A1 -| 12,6.5
  - U1.A0 -| 12,6.5
notes:
  - text 6.5,9 small left: "Rp は 1k・2.2k・4.7k・10k に差し替える (SCL・SDA を同じ値に)"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/13-i2c-pullup-rise.svg)

- 7-4 と同じ LM75 (アドレス 0x48) を、電源 3.3 V で使う (DIO の H と同じ電圧)。R<sub>p</sub> は SCL・SDA に 1 本ずつ
- C1・C2 (220 pF) は、長い配線や多くの素子がつながったバスの容量の代わり。ブレッドボードと LM75 と AD3 の入力の容量を
  30 pF と見て (仮定)、C<sub>b</sub> ≈ 250 pF とする
- 1+ を SCL、2+ を SDA に。Protocol の DIO と同じ点を Scope でも見る

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (LM75 は変換基板に載せた形)
board: half
parts:
  U1: dip8/sop @ e10 LM75
  R2: resistor i6 i3 4.7k
  C2: capacitor j6 -b6 220p
  R1: resistor i15 i19 4.7k
  C1: capacitor j15 -b15 220p
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [V+, GND, 1-, 2-, DIO0, 2+, DIO1, 1+]
wires:
  - AD.V+ -- +b1 red
  - AD.GND -- -b2 black
  - AD.1- -- -b4 black
  - AD.2- -- -b8 black
  - AD.2+ -- j10 green
  - AD.DIO0 -- i10 yellow
  - AD.DIO1 -- j11 white
  - AD.1+ -- i11 blue
  - g10 -- g6 yellow
  - g11 -- g15 white
  - j3 -- +b3 red
  - j19 -- +b19 red
  - a10 -- +t10 red
  - a11 -- -t11 black
  - a12 -- -t12 black
  - a13 -- -t13 black
  - j13 -- -b13 black
  - +t24 -- +b24 red
  - -t25 -- -b25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/13-i2c-pullup-rise.svg)

- LM75 は SO-8 しか無いので、変換基板 (`dip8/sop`) に載せて e10 に挿す (7-4 と同じ。1 番 SDA が f10、2 番 SCL が f11、4 番 GND が f13、8 番 VS が e10)
- SDA は g 行の黄の線で 6 列へ延ばし、R2 (i6〜i3) で + レール、C2 (j6) で − レールへ。SCL は g 行の白い線で 15 列へ延ばし、R1 と C1 を同じ形で
- A0〜A2 (11〜13 列の上) は上の − レールへ (アドレス 0x48)。上下のレールは 24・25 列でつなぐ
- AD3 は下に置く。DIO0 (黄) と 2+ (緑) を SDA の 10 列、DIO1 (白) と 1+ (青) を SCL の 11 列へ。ピンの並びは線が交わらない順 (実物とは違う)
- R<sub>p</sub> を替えるときは R1 と R2 を同じ値に挿し替える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Protocol | I2C、SDA = DIO0、SCL = DIO1、Frequency 100 kHz。Master で Address 0x48 を Read 2 バイト、Repeat で読み続ける |
| Scope CH1 (1+) | SCL。1 V/div、0 V を中央の 2 目盛下 |
| Scope CH2 (2+) | SDA (比べるときは Reference に替える。下) |
| Scope の時間 | 1 µs/div (マイクロ秒)。トリガは CH1 の立ち上がり 0.99 V (30 %)、トリガの点を左から 1 目盛 |
| Measurements | CH1 の Rise。設定の High を 70 %、Low を 30 % にすると I2C の定義の t<sub>r</sub> を直接出す (既定は 90 % と 10 %) |

Protocol は Pattern と Logic の資源を使うが、Scope は別の資源なので同時に動く。R<sub>p</sub> を替えた波形を同じ画面に残すには、
Scope の Add Channel で **Reference** を足し、いまの CH1 を保存してから抵抗を挿し替える。図3 の CH2 はこの Reference の代わりに描いた。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 SCL の立ち上がり — Rp 4.7 kΩ (CH1) と 1 kΩ (CH2 は保存した Reference)
time: 1us/div
trigger: ch1 rising 0.99V at -4div
ch1: {wave: = 3.3V * step(t + 419ns) * (1 - exp(-(t + 419ns) / 1.175us)), range: 1V/div, position: -2div}
ch2: {wave: = 3.3V * step(t + 419ns) * (1 - exp(-(t + 419ns) / 250ns)), range: 1V/div, position: -2div}
cursors: [0, 996ns]
measure: [rise, vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/13-i2c-pullup-rise.svg)

図3 は計算で作った理想の画面で、実測ではない (C<sub>b</sub> 250 pF と仮定)。X1 は 30 % (0.99 V)、X2 は 70 % (2.31 V) を切る点で、
ΔX = 996 ns が R<sub>p</sub> 4.7 kΩ の t<sub>r</sub>。標準モードの上限 1000 ns の**ちょうど縁**にある。1 kΩ の線 (CH2) は 212 ns。
Rise は 10〜90 % の読み値 (2.58 µs と 549 ns)。Measurements の High・Low を変えないと、この値が出る。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 立ち上がり時間 (30〜70 %) は Rp に比例する (Cb 250 pF)
x: プルアップ抵抗 kΩ log 0.2..20
y: 立ち上がり時間 ns log 50..5000
lines:
  計算 ns: 0.8473 * x * 1000 * 250e-12 * 1e9
notes:
  - mark 1
  - mark 2.2
  - mark 4.7
  - mark 10
  - level 1000ns
  - level 300ns
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/graph/13-i2c-pullup-rise.svg)

図4 は t<sub>r</sub> = 0.847 · R<sub>p</sub> · 250 pF の計算の線。縦の破線が挿し替える 4 つの値、横の破線が仕様の上限。
測った 4 点を重ねると、傾きが 1 (R<sub>p</sub> に比例) の線に乗るかで、C<sub>b</sub> を逆算できる (C<sub>b</sub> = t<sub>r</sub> ÷ (0.847 · R<sub>p</sub>))。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 温度センサー | LM75 (SO-8 を DIP 化の変換基板に載せる。3.3 V で使う) |
| R1・R2 | 抵抗 (1/4 W)、プルアップ R<sub>p</sub> | 1 kΩ・2.2 kΩ・4.7 kΩ・10 kΩ を 2 本ずつ (挿し替える) |
| C1・C2 | セラミックコンデンサ | 220 pF (221) × 2 |
| — | 電源・計器 | Analog Discovery 3 (Supplies 3.3 V、Protocol、Scope) |

1 kΩ のとき、L の間に R<sub>p</sub> を流れる電流は 3.3 V ÷ 1 kΩ = 3.3 mA で、I2C の仕様が素子に求める引き下げの電流 3 mA (0.4 V で) を少し超える。
L の電圧が 0.4 V より上がらないかを Scope で見る (上がるなら 1 kΩ は小さすぎ)。抵抗の電力は 11 mW で 1/4 W に余裕がある。

## 見るべき値

| 測る所 | 期待する値 (C<sub>b</sub> 250 pF の計算値) | 分かること |
| --- | --- | --- |
| R<sub>p</sub> 10 kΩ の t<sub>r</sub> (30〜70 %) | 約 2.1 µs | 標準モードの上限 1000 ns を超える。Protocol が読めても仕様の外 |
| R<sub>p</sub> 4.7 kΩ | 約 1.0 µs | 標準モードの縁。7-4 の 4.7 kΩ は容量の小さい配線だから足りていた |
| R<sub>p</sub> 2.2 kΩ | 約 470 ns | 標準モードは余裕、ファストモード (300 ns) には足りない |
| R<sub>p</sub> 1 kΩ | 約 210 ns | ファストモードにも入る。ただし下限 0.97 kΩ の際 |
| 4 点の傾き | R<sub>p</sub> に比例 (図4 の線) | 立ち上がりは RC の充電で決まる |
| 立ち下がり | どの R<sub>p</sub> でも数十 ns 以下 (目安) | L へは素子が能動的に引くので速い |
| L のときの電圧 | 0.4 V より下 | R<sub>p</sub> が小さすぎないか |
| C1・C2 を外したときの t<sub>r</sub> (4.7 kΩ) | 約 120 ns (C<sub>b</sub> 30 pF と見た計算値) | 外して測れば、仮定した 30 pF の実際の値が分かる |

Protocol の I2C の主は、ヘルプによれば SCL が実際に H に上がるのを待つ (クロックストレッチに対応する) 作りになっている。
R<sub>p</sub> を大きくすると、Scope で読む SCL の周期が 10 µs より少し延びることがある (目安。待つしきい値は資料に無い)。

## LTspice での確かめ

`sim/13-i2c-pullup-rise.cir` で、R<sub>p</sub> と C<sub>b</sub> 250 pF の充電を、オープンドレインを理想のスイッチ (オン 20 Ω、仮定) にして解き、
R<sub>p</sub> を 1k・2.2k・4.7k・10k に振って 0.99 V から 2.31 V までの時間を読んだ。C<sub>b</sub> の 30 pF は仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| t<sub>r</sub> (1 kΩ) | 約 210 ns (図4 212 ns) | 212 ns | 合う |
| t<sub>r</sub> (2.2 kΩ) | 約 470 ns (図4 466 ns) | 467 ns | 合う |
| t<sub>r</sub> (4.7 kΩ) | 約 1.0 µs (図3 996 ns) | 996 ns | 合う |
| t<sub>r</sub> (10 kΩ) | 約 2.1 µs (図4 2120 ns) | 2123 ns | 合う |
| 10〜90 % (1 kΩ・10 kΩ) | 549 ns・— (図3 の Rise) | 550 ns・5.50 µs | 合う (4.7 kΩ は 2.2 · τ = 2.58 µs) |

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Protocol の I2C、Scope の Reference と Measurements) と Digilent の
[Using the Protocol Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-protocol-analyzer)。
立ち上がり時間の式 (0.8473 · R<sub>p</sub> · C<sub>b</sub>) と上限 (1000 ns・300 ns) は Texas Instruments の
[I2C Bus Pullup Resistor Calculation (SLVA689)](https://www.ti.com/lit/an/slva689/slva689.pdf)。

参考: [I2C (Wikipedia)](https://ja.wikipedia.org/wiki/I2C)
