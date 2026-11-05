---
book: analog-discovery
chapter: 6
id: 6-9
title: セラミックの DC バイアス依存 (X7R)
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-9 セラミックの DC バイアス依存 (X7R)

積層セラミックコンデンサの X7R・X5R (高誘電率系) は、**直流の電圧をかけると容量が減る**。
誘電体のチタン酸バリウムの分極が直流の電界でそろってしまい、交流に応える分が減るためだ。
表示が 10 µF (マイクロファラド) でも、5 V の回路で使うと 6 µF ほどしか働かないことがある。
6-2・6-6 と同じ基準抵抗の回路で、W1 のオフセットを 0〜4 V と変え、同じ 1 kHz の振幅比から
容量を読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準抵抗と X7R のセラミック (W1 のオフセットが直流のバイアス)
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
    turn: mirror
  Rref: resistor 3,3 6,3 22
  Cdut: capacitor 9,3 12,3 10u l=$\mathrm{C_{DUT}}$
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 6,3
  - 6,3 -- 9,3
  - AD.2+ -| 9,3
  - AD.2- -| 12,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/circuit/09-ceramic-dc-bias.svg)

- C<sub>DUT</sub> は 10 µF・25 V の X7R (リード付きの積層セラミック)
- Rref (基準抵抗) は 22 Ω (オーム)。1 kHz の X<sub>C</sub> (15.9〜26 Ω) と同じ桁にして、CH1 と CH2 が同じくらい振れるようにした
- 直流のバイアスは W1 のオフセットで与える。Rref に直流は流れない (充電は 22 Ω × 10 µF = 0.22 ms で終わる) ので、
  オフセットはそのまま C<sub>DUT</sub> の両端にかかる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードと Analog Discovery (6-2 と同じ配置)
board: half
parts:
  Rref: resistor c5 c10 22
  Cdut: capacitor/ceramic d10 d14 10uF
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, 1+, 1-, 2+, 2-, GND]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- a10 green
  - AD.2+ -- b10 white [h10]
  - AD.2- -- b14 gray
  - a14 -- -t14 black
  - AD.GND -- -t17 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/breadboard/09-ceramic-dc-bias.svg)

- 配線は 6-2 と同じで、10 列が Rref と C<sub>DUT</sub> の中点。セラミックは極性が無いので向きは自由
- 電解と違い、オフセットを 0 V から上げても逆電圧の心配は無い

## 計器の設定

計器は Analog Discovery 3 の Wavegen と Scope (6-2 と同じ。1 kHz で読む)。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.2 V、**Offset 0 V → 1 V → 2 V → 3 V → 4 V** と変える |
| Scope | CH1 = Rref の両端、CH2 = C<sub>DUT</sub> の両端。Range は両方 50 mV/div。CH2 は Offset をバイアスと同じだけ引いて中央に |
| Measure | CH1・CH2 の Amplitude、CH2 の CH1 に対する Phase |

**手順。** オフセットを変えたら 10 秒ほど待ってから読む (X7R は電圧を変えた直後に容量が少し動く。待つ時間は目安)。
読んだ振幅の比から C = 1 / (2πf × Rref × V<sub>CH2</sub> / V<sub>CH1</sub>) と出す。
位相はどのバイアスでも −90° のままで、変わるのは振幅の比だけ。
オフセット + 振幅は 4.2 V で、W1 の出せる ±5 V に収まる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 バイアス 4 V では CH2 (C) が CH1 (電流) より大きい — 6.1 µF に減った
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.129V, range: 50mV/div}
ch2: {wave: sine 1kHz 0.153V offset 4V phase -90deg, range: 50mV/div, position: -80div}
measure: [vpp, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/scope/09-ceramic-dc-bias.svg)

図3 は 4 V の 1 点 (計算値)。0 V なら CH1 0.162 V・CH2 0.117 V で、大小が入れ替わる。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| Rref | 22 Ω、1/4 W | 電流は振幅で 7.4 mA まで。電力は 0.6 mW |
| C<sub>DUT</sub> | 10 µF・25 V、X7R、リード付き積層セラミック | 比べるなら同じ 10 µF のフィルムか、1 µF 以下の C0G (容量が電圧で変わらない) |
| 電源 | W1 のオフセット 0〜4 V | 直流のバイアスは 5 V の回路で掛かる電圧の範囲 |

## 見るべき値

計算値。**容量の減り方は仮定** で、C(V) = 10 µF / (1 + (V / 5 V)²) (4 V で約 4 割減る) と置いた。
減り方は品・大きさ・定格電圧で大きく違い (小さく定格の低い品ほど減る)、実測で置き換える。

| バイアス | 仮定の C | X<sub>C</sub> | CH1 (Rref) | CH2 (C<sub>DUT</sub>) | V<sub>CH2</sub> / V<sub>CH1</sub> |
| --- | --- | --- | --- | --- | --- |
| 0 V | 10.0 µF | 15.9 Ω | 0.162 V | 0.117 V | 0.723 |
| 1 V | 9.62 µF | 16.5 Ω | 0.160 V | 0.120 V | 0.752 |
| 2 V | 8.62 µF | 18.5 Ω | 0.153 V | 0.129 V | 0.839 |
| 3 V | 7.35 µF | 21.6 Ω | 0.143 V | 0.140 V | 0.984 |
| 4 V | 6.10 µF | 26.1 Ω | 0.129 V | 0.153 V | 1.186 |

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 X7R の容量はバイアスとともに下がる (4 V で 6.1 µF、仮定の曲線)
x: バイアス電圧 V 0..4.5
y: 容量 µF 0..11
lines:
  X7R 10 µF µF: 10/(1+(x/5)^2)
notes:
  - mark 0
  - mark 2
  - mark 4
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/06-impedance/graph/09-ceramic-dc-bias.svg)

分かること:

- **表示の容量は 0 V のときの値。** 5 V の電源のデカップリングや平滑に X7R を使うと、働く容量は表示より小さい。
  データシートやメーカーの特性の表で、使う電圧での容量を確かめて選ぶ
- 同じ 10 µF でも、定格電圧の高い品・形の大きい品ほど減りにくい (誘電体の層が厚く、電界が弱い)
- C0G (NP0) やフィルムは、この測り方で比が変わらない。6-6 の「セラミックは ESR が小さい」と合わせて、
  セラミックは**容量の正確さでは C0G、容量の大きさでは X7R** と使い分ける

## LTspice での確かめ

`sim/09-ceramic-dc-bias.cir` で図1 (Rref 22 Ω、C<sub>DUT</sub> は各バイアスでの仮定の容量、W1 の振幅 0.2 V) を 1 kHz で交流解析した。
SPICE の C は電圧で変わらないので、**バイアスごとに容量を振って** (`.step`) 解いた。容量の減り方は本文の仮定で、**実測ではない**。ESR は 6-6 と同じ 0.02 Ω を仮定した。
位相は V(CH2) の位相から Rref の電流の位相を引いて出した。

| バイアス | 本文の数字 (CH1・CH2・位相) | LTspice | 判定 |
| --- | --- | --- | --- |
| 0 V (10.0 µF) | 0.162 V・0.117 V・比 0.723・−90° | 0.162 V・0.117 V・比 0.723・−89.93° | 合う |
| 2 V (8.62 µF) | 0.153 V・0.129 V・比 0.839 | 0.153 V・0.128 V・比 0.839 | 合う |
| 4 V (6.10 µF) | 0.129 V・0.153 V・比 1.186・−90° | 0.129 V・0.153 V・比 1.186・−89.96° | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen と Scope の節)。
