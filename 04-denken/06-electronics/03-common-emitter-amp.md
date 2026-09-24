---
book: denken
chapter: 6
id: 6-3
title: エミッタ接地増幅 — 電圧増幅度とバイアス
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-3 エミッタ接地増幅 — 電圧増幅度とバイアス

トランジスタ 1 個で電圧を増幅する、最も基本の**エミッタ接地増幅回路**。
分圧バイアス (R1・R2) で動作点を決め、エミッタの抵抗 R_E をそのまま残す
(バイパスコンデンサを入れない) ことで、増幅度が h_FE によらず
**A_v ≈ −R_C / R_E** という簡単な式になる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_B = V_CC × R2 / (R1 + R2) | 分圧バイアスのベース電圧 (ベース電流の分は無視) |
| V_E = V_B − V_BE、I_E ≈ V_E / R_E | エミッタの電圧と電流。V_BE ≈ 0.6 V |
| V_C = V_CC − I_C × R_C (I_C ≈ I_E) | コレクタの電圧 |
| A_v ≈ −R_C / R_E | 電圧増幅度。R_E をバイパスしないので h_FE によらず決まる |

## 回路図

```circuit
title: 図1 エミッタ接地増幅 (分圧バイアス)
parts:
  VCC: vcc a3
  R1: resistor a3 a9 39k
  RC: resistor c3 c13 2.2k
  R2: resistor a9 e9 10k
  Cin: capacitor a9 a15 10u
  IN: port a18
  Cout: capacitor c13 c19 10u
  OUT: port c22
  Q1: npn e11 2SC1815
  RE: resistor g11 g15 470
  G1: ground e9
  G2: ground g15
wires:
  - a3 -- c3
  - a9 |- Q1.B
  - c13 |- Q1.C
  - a15 -- a18
  - c19 -- c22
  - Q1.E -| g11
style:
  standard: jis
  grid: on
  pitch: 1.5
```

- R1 (39 kΩ)・R2 (10 kΩ) が分圧バイアス、R_C (2.2 kΩ) がコレクタ抵抗、
  R_E (470 Ω) がエミッタ抵抗
- Cin・Cout (各 10 µF) は直流を遮って交流だけを通す結合コンデンサ
- Q1 は 2SC1815。V_CC は AD の Supplies (+5 V)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  R1: resistor c5 c9 39k
  R2: resistor d9 d13 10k
  RC: resistor c20 c24 2.2k
  RE: resistor d30 d34 470
  Cin: capacitor/electrolytic a9(+) a3 10u
  Cout: capacitor/electrolytic b24(+) b28 10u
  Q1: transistor e9(B) e10(C) e11(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t5 red
  - +t5 -- a5 red
  - +t20 -- b20 red
  - AD.W1 -- b3 yellow
  - AD.1+ -- b3 yellow
  - AD.1- -- AD.GND black
  - AD.2+ -- a28 green
  - AD.2- -- AD.GND black
  - AD.GND -- -t2 black
  - c13 -- -t13 black
  - c34 -- -t34 black
  - Q1.C -- a24 blue
  - Q1.E -- a30 orange
```

- 列 9 が分圧の中点 (ベース)、列 24 がコレクタ、列 30 がエミッタ。
  Q1 の足からは名前 (`Q1.C` `Q1.E`) で配線し、同じ穴を 2 度挿さないようにしている
- Cin の + (9 列側) がベースの直流電位、Cout の + (24 列側) がコレクタの直流電位
  (どちらも 0 V より高いので、電解コンデンサの + はそちら向き)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Wavegen | W1: Sine、1 kHz、Amplitude 50 mV、Offset 0 V |
| Scope | CH1 = 入力 (Cin の手前)、CH2 = 出力 (Cout の先) |
| Measure | CH1・CH2 の Amplitude |

## 見るべき値

計算値。h_FE = 250 と仮定 (実測は個体差で変わるが、A_v は h_FE によらない)。

| 測る所 | 期待する値 |
| --- | --- |
| ベース電圧 V_B | 1.02 V |
| エミッタ電圧 V_E | 0.42 V |
| エミッタ電流 I_E | 0.89 mA |
| コレクタ電圧 V_C | 3.03 V |
| V_CE | 2.61 V (能動領域) |
| 電圧増幅度 A_v (= −R_C / R_E) | −4.68 倍 |
| 出力の振幅 (入力 50 mV のとき) | 約 230 mV (実測は内部抵抗 r_e′ のぶんだけ少し小さく、−4.4 倍前後になる) |

分かること:

- **R_E を残す (バイパスしない) と、増幅度は R_C と R_E の比だけで決まる。**
  h_FE が個体でばらついても A_v はほとんど変わらない — 実用回路で R_E を
  残す理由
- 出力は入力に対して**位相が 180° 反転**する (マイナス符号)。エミッタ接地の特徴
- R_E に並列にコンデンサを足す (バイパス) と増幅度は −g_m R_C まで上がるが、
  h_FE (g_m) の個体差の影響を受けやすくなる (6-9 の負帰還で詳しく)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
