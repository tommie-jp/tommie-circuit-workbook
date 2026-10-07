---
book: denken
chapter: 6
id: 6-8
title: エミッタフォロア — 入出力インピーダンス
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-8 エミッタフォロア — 入出力インピーダンス

エミッタから出力を取る**エミッタフォロア** (コレクタ接地) は、電圧はほぼ 1 倍で増やさないが、
**入力インピーダンスが高く、出力インピーダンスが低い**。弱い信号源から電流を取らずに受けて、
重い負荷を駆動する「緩衝 (バッファ)」に使う。直列の抵抗で入力インピーダンスを、
負荷をつなぐ前後の出力の差で出力インピーダンスを測る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| A_v = R_E / (r_e + R_E) ≒ 1 | 電圧増幅度。r_e = V_T / I_E (V_T ≒ 25.9 mV) |
| Z_b = (h_FE + 1)(r_e + R_E) | ベースから見たインピーダンス。R_E が h_FE 倍に見える |
| Z_in = R1 ∥ R2 ∥ Z_b | 入力インピーダンス (バイアスの抵抗と並列) |
| Z_out ≒ r_e + R_源 / (h_FE + 1) | 出力インピーダンス。信号源の抵抗が h_FE 分の 1 に見える |
| Z_in = R_S V₂ / (V₁ − V₂)、Z_out = R_L (V_開放 / V_負荷 − 1) | 測った電圧から求める式 |

## 回路図

```circuit
title: 図1 エミッタフォロアの入出力インピーダンスを測る
parts:
  V1: sine 1,4 1,7 0.1 l=$\mathrm{W1}$
  RS: resistor 1,4 3,4 22k
  S2: switch 1,2 3,2
  Cin: capacitor 4,4 5,4 10u
  VCC: vcc 6,1 5V
  R1: resistor 6,1 6,4 47k
  R2: resistor 7,4 7,7 47k
  Q1: npn 9,4 2SC1815
  RE: resistor 9,5 9,7 1k
  Cout: capacitor 9,5 11,5 100u
  S1: switch 11,5 13,5
  RL: resistor 13,5 13,7 100
  G1: ground 1,7
wires:
  - 1,2 -- 1,4
  - 3,2 -- 3,4 -- 4,4
  - 5,4 -- 6,4 -- 7,4 -| Q1.B
  - 6,1 -- 9,1 -| Q1.C
  - Q1.E -| 9,5
  - 1,7 -- 7,7 -- 9,7 -- 13,7
notes:
  - text 1,3 blue: CH1
  - text 3,3 blue: CH2 (1 回目)
  - text 11,4.5 blue: CH2 (2 回目)
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/circuit/08-emitter-follower.svg)

- R1・R2 (各 47 kΩ) がベースのバイアス、R_E (1 kΩ) がエミッタの抵抗。V_CC は AD の Supplies (+5 V)
- **1 回目 (入力インピーダンス)**: S2 を開いて R_S (22 kΩ) を信号の道に入れ、S1 も開く (負荷なし)。
  CH1 は R_S の手前、CH2 は R_S の後ろ。R_S と Z_in の分圧から Z_in が出る
- **2 回目 (出力インピーダンス)**: S2 を閉じて R_S を短絡し、W1 で直にベースを動かす。CH2 を
  出力 (Cout の先) に移し、S1 を開いて 1 回、閉じて (R_L = 100 Ω) 1 回読む
- Cin (10 µF)・Cout (100 µF) は直流を切る。1 kHz でのリアクタンスは 16 Ω と 1.6 Ω で、
  Z_in (21.5 kΩ) と R_L (100 Ω) に比べて小さい

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RS: resistor c3 c8 22k
  S2: switch e3 e8
  Cin: capacitor/electrolytic c12(+) c9 10u
  R1: resistor a12 +t12 47k
  R2: resistor j12 -b12 47k
  Q1: transistor e14(B) e15(C) e16(E) 2SC1815
  RE: resistor a17 -t17 1k
  Cout: capacitor/electrolytic c16(+) c20 100u
  S1: switch c21 c23
  RL: resistor d23 d28 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [1-, GND, W1, 1+, 2+, 2-, V+]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a3 yellow
  - AD.1+ -- b3 yellow [h10]
  - AD.1- -- -t1 black
  - b8 -- b9 green
  - e12 -- f12 green
  - b12 -- b14 green
  - b16 -- b17 green
  - a15 -- +t15 red
  - b20 -- b21 green
  - a28 -- -t28 black
  - AD.2- -- -t11 black
  - AD.2+ -- a8 blue
  - AD.V+ -- +t25 red
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/breadboard/08-emitter-follower.svg)

- Q1 (2SC1815) は平らな面を奥に向けて、左から B (14 列)・C (15 列)・E (16 列)。
  コレクタは赤い線で + のレールへ。R_E は 17 列から GND のレールへ (16 列と緑の線でつなぐ)
- ベースの列 12: R1 (+ のレールから)、Cin の +、R2 (溝を渡って下の段、j12 から下の GND のレールへ)。
  下の GND のレールは 30 列の黒い線で上の GND のレールとつなぐ
- R_S は 3〜8 列、S2 は 3・8 列の間 (R_S と並列)。Cin は − を 9 列、+ を 12 列に向ける
  (ベースの直流 2.34 V のほうが高い)。Cout も + をエミッタ (16 列) に向ける
- CH1 (1+) は 3 列、CH2 (2+) は 8 列 (1 回目)。2 回目は 2+ を 20 列 (出力) に挿し替える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.1 V、Offset 0 V |
| Scope | CH1 = W1、CH2 = R_S の後ろ (1 回目) / 出力 (2 回目)。2 ch とも 30 mV/div、Time base 200 µs/div |
| Measure | CH1・CH2 の Amplitude。Average を 16 回掛けると 1 mV まで読める |

入力を 0.1 V に抑えるのは、2 回目に R_L = 100 Ω をつないだとき、負の半周期でエミッタの電流
(直流 1.69 mA) が 0 まで減って波形が欠けないようにするため (R_E ∥ R_L = 91 Ω に山で 0.94 mA 流す)。

```scope
title: 図3 1 回目 — R_S (22 kΩ) の後ろ (CH2) は W1 (CH1) の 0.494 倍
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 100mV, range: 30mV/div}
ch2: {wave: ch1 | gain 0.494, range: 30mV/div}
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/scope/08-emitter-follower-1.svg)

```scope
title: 図4 2 回目 — R_L = 100 Ω をつなぐと出力 (CH2) は 98.5 mV から 85.6 mV へ
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 100mV, range: 30mV/div}
ch2: {wave: ch1 | gain 0.856, range: 30mV/div}
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/06-electronics/scope/08-emitter-follower-2.svg)

図4 は R_L をつないだとき。S1 を開くと CH2 の山は 98.5 mV (0.985 倍) に上がる。

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Sine、1 kHz、**200 mVpp** (AD の Amplitude 0.1 V は山の高さ)、Offset 0 V、出力は High-Z |
| V+ | 安定化電源の 5 V。電流制限は 10 mA (エミッタ 1.7 mA とバイアス 0.05 mA に余裕を見た値) |
| 1+ | CH1 の先端を 3 列 (R_S の手前)、グランドクリップを GND のレール |
| 2+ | CH2 の先端を 8 列 (1 回目) / 20 列 (2 回目)、グランドクリップを GND のレール |

- 1 回目は CH1 が FG の端子の電圧なので、FG の 50 Ω は式に入らない
- 2 回目は FG の 50 Ω がベースの信号源の抵抗になり、出力インピーダンスが 50 Ω ÷ 251 = 0.2 Ω
  増える (15.1 Ω → 15.5 Ω、計算値)。読みの違いは 0.2 % で無視できる
- 30 mV/div 前後で 0.1 V の波を読むので、Average (16 回) を掛け、CH1 と CH2 の先端を
  同じ点に当てたときの読みの差を先に見ておく

## 見るべき値

計算値。h_FE = 250、V_BE = 0.65 V と仮定。

| 測る所 | 期待する値 | 求め方 |
| --- | --- | --- |
| ベース・エミッタの直流電圧 | 2.34 V・1.69 V | テスターで。I_E = 1.69 mA、r_e = 25.9 mV ÷ 1.69 mA = 15.3 Ω |
| 1 回目 CH1 / CH2 の振幅 | 100 mV / 49.4 mV | Z_in = 22 kΩ × 49.4 ÷ (100 − 49.4) = **21.5 kΩ** |
| 2 回目 出力 (S1 開、無負荷) | 98.5 mV | A_v = 0.985 (≒ 1) |
| 2 回目 出力 (S1 閉、R_L = 100 Ω) | 85.6 mV | Z_out = 100 Ω × (98.5 ÷ 85.6 − 1) = **15.1 Ω** |

- Z_in の内訳: Z_b = 251 × (15.3 + 1000) = 255 kΩ で、R1 ∥ R2 (23.5 kΩ) が大半を決める。
  バイアスの抵抗を大きくすれば Z_in はさらに上がる
- Z_out (15.1 Ω) は R_E (1 kΩ) の 66 分の 1。出力を 100 Ω で引いても 13 % しか下がらない

分かること:

- **電圧は増えないが、電流は h_FE 倍に増える**。入力で 21.5 kΩ に見えた回路が、出力では
  15 Ω の信号源に化ける。インピーダンスの変換器として働く
- 6-3 のエミッタ接地の増幅 (出力インピーダンス ≒ R_C = 2.2 kΩ) の後ろにつなぐと、
  低い負荷でも増幅度が落ちない。OP アンプのボルテージフォロア (6-4 の非反転で R_f = 0) も同じ役目
- 出力は入力と同じ向き (位相 0°)。エミッタの電圧がベースに「ついていく」のが名前の由来

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
