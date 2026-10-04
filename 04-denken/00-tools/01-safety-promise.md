---
book: denken
chapter: 0
id: 0-1
title: 安全の約束 — 商用電源に触れない。低圧の交流の作り方と電流の上限
tier: 50
source: 自作
board: BB
---

# 0-1 安全の約束 — 商用電源に触れない。低圧の交流の作り方と電流の上限

電験三種の理論は、実際には 100 V や 200 V、あるいはもっと高い電圧で使われる式を
たくさん扱う。この本ではその式を**低い電圧の実験で確かめる**。最初に守る約束を
決めておく。

- **商用電源 (AC 100 V) には直に繋がない。** コンセントから直接電源を取る実験は
  この本には出てこない
- 交流が要る実験は、**Analog Discovery (AD) の波形発生器**か、**二次側 12 V 以下の
  AC 出力アダプタ**から取る。AD の波形発生器は**出せる電流に上限がある**
  (Analog Discovery 3 の仕様で 1 ch あたり 30 mA。これは「歪みなく出せる最大値」で、
  40 mA までは出せるが、それを超えるとハードウェアの保護が働く。出力インピーダンスは 0 Ω、
  振幅は ±5 V まで)。これを超える負荷
  (低い抵抗) をつなぐと、波形がひずんだり、電圧が下がったりする
- 直流は 5 V が既定 (USB の 5 V、AD の Supplies、単 3 電池 3 本の 4.5 V のどれでもよい)。
  この本の直流の実験はどれもこれらと乾電池で組める

この約束から、**使ってよい抵抗の下限**が決まる。オームの法則を電流の上限に
当てはめるだけなので、電験三種の最初の 1 題にちょうどよい。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I = V / R | オームの法則。電源の電圧と負荷の抵抗から電流が決まる |
| R_min = V / I_max | 電流の上限 I_max を守るための、抵抗の最小値 |

## 回路図

```circuit
title: 図1 AD の波形発生器と抵抗負荷
style:
  standard: jis
parts:
  V1: sine a1 a3 l=$\mathrm{W1}$
  A1: ammeter a3 a5
  R1: resistor a5 a7 100
  G1: ground a1
wires:
  - a7 -- e7
  - e7 -- e1
  - e1 -- a1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/circuit/01-safety-promise.svg)

- V1 は AD の波形発生器 (W1)。振幅を決めて出力する
- A1 はテスターの電流レンジ (交流)。R1 に流れる電流を直に読む
- R1 = 100 Ω は**振幅 3 V のときの下限ぴったり**の値 (見るべき値で計算する)。
  実際に使うときはもっと大きい値にして余裕を持たせる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  R1: resistor c10 c15 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 blue
  - AD.1- -- -t3 black [h-10]
  - c15 -- -t15 black
notes:
  - text: "テスターの電流レンジ (A1) を 5 列と 10 列の間に挿す。R1 と直列になる"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/breadboard/01-safety-promise.svg)

- W1 の出力は 5 列へ。テスターのリードを 5 列と 10 列に当てると、電流は W1 → テスター → R1 → GND の順に流れる
- Scope の 1+ は 5 列 (W1 の出力)、1− は GND のレール。波形の振幅が設定どおりか見る
- 図の R1 = 100 Ω は下限ぴったりの値。最初は Amplitude 1 V (電流 10 mA) で試し、振幅は 1 V ずつ上げて電流を読む
- 板を流れる電流は最大 30 mA で、ブレッドボードの 1 穴 200 mA の範囲に収まる

## 計器の設定

この題の計器は Analog Discovery 3 (AD3) の Wavegen と Scope、それにテスター。Wavegen が試す電源で、Scope が電源の電圧、テスターが電流を読む。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine。周波数はどれでもよい (例 1 kHz)。Amplitude は表の値に合わせる |
| テスター | 交流電流レンジ (mA)。R1 と直列に入れる |
| Scope | CH1 (1+ / 1−) = W1 の電圧。DC 結合、500 mV/div、200 µs/div。Measure で Amplitude を読む |

```scope
title: 図3 W1 の波形 (CH1) — 振幅 1 V のとき R1 = 100 Ω に 10 mA
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/00-tools/scope/01-safety-promise.svg)

## 見るべき値

計算値 (I = V / R)。

| 振幅 Vm | 下限 R_min = Vm / 30 mA | 図の R1 = 100 Ω での電流 |
| --- | --- | --- |
| 1 V | 33 Ω | 10 mA |
| 3 V | 100 Ω | 30 mA (上限ぴったり) |
| 5 V | 167 Ω | 50 mA (**上限を超える。R1 = 100 Ω では不可**) |

分かること:

- **振幅を上げるほど、下限の抵抗も大きくなる。** この本で交流を使う実験は、
  どれも組む前に R_min を計算してから抵抗を選ぶ
- 100 Ω ちょうどは上限ぎりぎりなので、実際には **150 Ω 以上**にして 3 割ほど
  余裕を持たせる
- 30 mA は AD3 の仕様。以後の題は余裕を見て、**10 mA 以内** (AD3 の仕様の 1/3) に
  収まる値で決めている
- AC アダプタ (二次側 12 V 以下) は波形発生器より大きな電流を出せるが、
  その分**ヒューズや電流制限抵抗**で上限を決めておく (0-6 で扱う)。二次側でも
  12 V を超えないこと、濡れた手で触らないことは変わらない

## この本の標準の計器 Analog Discovery 3 の数字

この本の計器は Analog Discovery 3 (AD3) にそろえる。使う数字を並べる
(出典はこの節の下)。

| 項目 | AD3 の値 |
| --- | --- |
| Wavegen (W1・W2) | 振幅 ±5 V、出力インピーダンス 0 Ω、電流は 30 mA まで (歪みなし)・40 mA で保護 |
| Supplies (V+・V−) | +0.5〜+5 V、−0.5〜−5 V。USB からだけで使うと、装置全体で約 5.5 W が目安。5 V の補助電源 (3.1 A 以上) を付けると 1 ch あたり 800 mA・2.4 W まで |
| Scope の入力 | ±25 V (±2.5 V のレンジもある)、入力抵抗と容量は 1 MΩ‖24 pF、14 bit、125 MS/s |
| Scope の帯域 | BNC アダプタ付き 30 MHz 以上 (−3 dB)、2×15 のヘッダのままでは 9 MHz (−3 dB) |

- この本の実験は 1 kHz 前後の低い周波数なので、帯域の差は結果に響かない
- 補助電源なしの USB 給電では、Supplies の電流を欲張ると Wavegen や Scope の分が
  足りなくなる。TL071 1 個 (約 1.4 mA) のような小さい負荷なら問題ない
- Wavegen の出力インピーダンス 0 Ω は、ヘッダから出すときの値。BNC アダプタを付けた
  ときは、ジャンパで 0 Ω と 50 Ω を選べる

## 出典

自作。AD の波形発生器の電流の上限 (30 mA、保護は 40 mA) と出力インピーダンス (0 Ω) は
Digilent の [Analog Discovery 3 リファレンスマニュアル](https://digilent.com/reference/test-and-measurement/analog-discovery-3/reference-manual)
の仕様 (Arbitrary Waveform Generator の節)。
電流の値の注記 (30 mA は「歪みなく出せる最大値」、40 mA まででハードウェアの保護) は
Digilent の Analog Discovery 3 Specifications の Arbitrary Waveform Generator の表の注。

上の表の Scope の入力・帯域、Supplies、USB の電力の目安は、Digilent の
Analog Discovery 3 Specifications と Reference Manual (Programmable Power Supply の節)。
