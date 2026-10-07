---
book: denken
chapter: 7
id: 7-7
title: 計器用変流器 (CT) — 二次を開放しない理由
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 7-7 計器用変流器 (CT) — 二次を開放しない理由

大きな電流は、**計器用変流器 (CT)** で小さな電流に変えてから電流計で測る。CT の一次電流は
線路の負荷が決めるので、CT から見ると**電流源**につながっている。二次に電流計 (小さな抵抗) が
つながっていれば、二次電流が一次の磁束を打ち消し、鉄心の磁束も二次の電圧も小さい。
**二次を開くと打ち消す電流が無くなり、一次電流が全部鉄心を磁化して、二次に高い電圧が出る**。
フェライトのリングに線を巻いた貫通形の CT の模型で、二次を閉じたときと開いたときの電圧を比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I₂ = I₁ × N₁ / N₂ | 二次を小さな負担 (抵抗) で閉じたときの二次電流 (変流比) |
| V₂ = I₂ R_B | 二次を閉じたときの二次の電圧。負担が小さいほど小さい |
| V₂ = (N₂ / N₁) × ωL₁ I₁ (二次を開いたとき) | 一次電流が全部励磁電流になり、巻数比倍の電圧が出る |
| L = A_L N² | リングに巻いたコイルのインダクタンス (A_L はリングの値) |

## 回路図

```circuit
title: 図1 CT の模型 (一次 5 回・二次 100 回)
parts:
  V1: sine 1,2 1,6 5 l=$\mathrm{W1}$
  RLN: resistor 1,2 4,2 510 l=$\mathrm{R_{line}}$ i=I1
  T1: transformer 6,4
  RS: resistor 3,6 5,6 10 l=$\mathrm{R_S}$
  S1: switch 9,2 11,2
  RB: resistor 11,2 11,6 10 l=$\mathrm{R_B}$
  G1: ground 1,6
  G2: ground 8,6
wires:
  - 4,2 -| T1.A1
  - T1.A2 |- 5,6
  - 1,6 -- 3,6
  - T1.B1 -| 9,2
  - T1.B2 -| 8,6
  - 8,6 -- 11,6
notes:
  - text 2,5 blue: CH1 (RS の電圧)
  - text 9.5,3.7 blue: CH2
style:
  standard: jis
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/circuit/07-current-transformer.svg)

- CT はフェライトのリング (FT-37-43 など、外径 9.5 mm) に**二次を 100 回**巻き、リングの穴に
  **一次の線を 5 回**通して作る (貫通形)。変流比は 5 : 100 = 1 : 20。回路図では変圧器の記号で描く
- 一次は AD の Wavegen (W1、10 kHz、5 V) から R_line (510 Ω) を通して流す。CT の一次の
  インピーダンス (1 Ω 足らず) は 510 Ω に比べて小さく、一次電流は負担によらず 9.6 mA で決まる
  (**電流源**。実際の CT が線路に入っているのと同じ)
- R_S (10 Ω) で一次電流を測る (CH1)。二次は R_B (10 Ω、電流計の模型) を S1 で入れたり外したりし、
  二次の電圧を CH2 で測る。二次の片側は GND につなぐ (実物の CT も二次の片側を接地する)

## 実体配線図

CT の模型 (リング) はブレッドボードの外に置き、一次の 2 本の端 (5 回通した線の両端) と二次の 2 本の端 (100 回巻いた線の両端) をブレッドボードの穴に挿す。
一次は上の半分 (a〜e 行)、二次は下の半分 (f〜j 行) を使う。

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  RLN: resistor e3 e7 510
  T1: transformer c10 c13 f10 f13 5to100
  RS: resistor d13 d18 10
  S1: switch h10 h14
  RB: resistor i14 i19 10
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, "1+", "1-", "2+", "2-"]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a3 yellow
  - b7 -- b10 yellow
  - AD.1+ -- a13 orange
  - AD.1- -- -t14 black
  - a18 -- -t18 black
  - AD.2+ -- j10 blue
  - AD.2- -- -b22 black
  - j13 -- -b13 black
  - j19 -- -b19 black
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/breadboard/07-current-transformer.svg)

- 一次: W1 → R<sub>line</sub> (3〜7 列) → CT の一次 (10 列と 13 列) → R<sub>S</sub> (13〜18 列) → GND レール。
  CH1 (1+) は 13 列 (R<sub>S</sub> の上の端)
- 二次: CT の二次 (下の半分の 10 列と 13 列)。13 列を GND レール、10 列を S1 (10〜14 列) → R<sub>B</sub> (14〜19 列) → GND レール。
  CH2 (2+) は 10 列 (S1 の手前)。S1 を開けると二次は開放になる
- 上と下の GND レールは 29 列の黒い線でつなぐ
- ブレッドボードに流れる電流は一次の 9.6 mA だけ (計算値)。ブレッドボードの 1 穴 200 mA に十分収まる

## 計器の設定

計器は Analog Discovery 3 (AD3)。W1 が 10 kHz の正弦波を出し、Scope の 2 ch で一次電流 (R_S の電圧) と二次の電圧を同時に読める。W1 の電流 9.6 mA は 30 mA 以内に収まる。

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、10 kHz、Amplitude 5 V、Offset 0 V |
| Scope | CH1 = R_S の電圧 (一次電流 × 10 Ω)、CH2 = 二次の電圧。Time base 50 µs/div。Average を 16 回 |
| Measure | CH1・CH2 の Amplitude、CH1 に対する CH2 の Phase |
| Impedance (はじめに) | 二次の巻線だけのインダクタンスを 10 kHz で測り、A_L を確かめる (100 回で 4.2 mH のはず)。Impedance Analyzer のアダプタを使うか、基準抵抗 (Reference、たとえば 1 kΩ) を W1 と巻線の間に直列に入れる |

一次電流は 9.6 mA (山) で、Wavegen の 10 mA に収まる。二次を閉じたときの 4.8 mV は小さいので、
CH2 は 2 mV/div にし、Average で雑音を落とす。二次を開いたら CH2 を 50 mV/div に上げる。

```scope
title: 図3 二次を閉じた (R_B = 10 Ω) — 二次の電圧 (CH2、2 mV/div) は 4.8 mV
time: 50us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 96.2mV, range: 25mV/div}
ch2: {wave: sine 10kHz 4.81mV, range: 2mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/scope/07-current-transformer-1.svg)

```scope
title: 図4 二次を開いた — 二次の電圧 (CH2、50 mV/div) は 127 mV に跳ね、位相は 90° 進む
time: 50us/div
trigger: ch1 rising 0V
ch1: {wave: sine 10kHz 96.2mV, range: 25mV/div}
ch2: {wave: sine 10kHz 127mV phase 90deg, range: 50mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/07-measurement/scope/07-current-transformer-2.svg)

2 枚は CH2 の V/div が 25 倍違う。同じ 9.6 mA の一次電流で、二次の電圧が 26 倍になる。

### オシロスコープと発振器

1− と 2− は GND なので、測り方は GND 基準のままでよい
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。一次と二次は CT の中では
つながっていないが、この模型では二次の片側を GND に落として一次と同じ GND を共有する。
グランドクリップは 2 本とも GND に当ててよい。

| AD | 汎用の計器 |
| --- | --- |
| W1 | FG の OUT。Sine、10 kHz、**10 Vpp** (AD の Amplitude 5 V は山の高さ)、出力は High-Z |
| 1+ | CH1 の先端を R_S の上の端、グランドクリップを GND |
| 2+ | CH2 の先端を二次の上の端 (S1 の手前)、グランドクリップを GND |

- FG の 50 Ω は R_line (510 Ω) に足され、一次電流は 5 V ÷ 570 Ω = 8.8 mA (計算値) に下がる。
  二次の電圧もその比 (0.91 倍) で下がり、閉じて 4.4 mV、開いて 116 mV。26 倍の比は変わらない
- 10 Vpp を出せない FG は出せる振幅で測り、比で読む

## 見るべき値

計算値。FT-37-43 の A_L を 420 nH/回² と仮定 (L₁ = 10.5 µH、L₂ = 4.2 mH、10 kHz で ωL₂ = 264 Ω)。

| 二次 | 一次電流 (CH1 ÷ 10 Ω) | 二次の電圧 (CH2) | 位相 (CH1 に対して) | 二次電流 |
| --- | --- | --- | --- | --- |
| 閉 (R_B = 10 Ω) | 9.6 mA | 4.8 mV | ほぼ 0° | 0.48 mA (= 9.6 mA ÷ 20) |
| 開 | 9.6 mA | 127 mV | 90° 進み | 0 |

- 閉じたときの変流比の誤差は、R_B (10 Ω) が ωL₂ (264 Ω) より十分小さいので 0.1 % 足らず
- 開いたときの 127 mV は (100 / 5) × ωL₁ × I₁ = 20 × 0.66 Ω × 9.6 mA

分かること:

- **CT の二次を開くと、負担が小さいときの何十倍もの電圧が出る。** 一次電流は線路が決めるので、
  CT の側からは減らせない。実物の CT (一次数百 A、二次 5 A) では開いた二次に数 kV が出て、
  絶縁を壊し、鉄心が飽和して過熱する
- だから CT の二次は**電流計を外す前に短絡する**。計器用変圧器 (VT、二次を短絡してはいけない) と逆
- CT の二次は負担が小さいほど正確 (変流比の誤差が小さい)。負担を大きくしたときの比誤差は 8-11 で扱う

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope・Impedance の節)。フェライトのリングの A_L はメーカー (Fair-Rite / Amidon) の表の値。
