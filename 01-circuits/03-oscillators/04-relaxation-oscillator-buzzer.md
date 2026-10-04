---
book: circuits
chapter: 3
id: 3-4
title: 弛張発振 — Tr 2 石でブザー
tier: 50
source: 自作
board: BB
era: 古
---

# 3-4 弛張発振 — Tr 2 石でブザー

3-1 と同じトランジスタ (Tr) 2 石の非安定マルチバイブレータを、**音が聞こえる速さ**まで
上げてブザーを鳴らす。LED の点滅も RC の値を変えれば音になる、という
つながりを確かめる 1 題。**弛張発振**は、コンデンサをゆっくり充電 (または放電) し、
ある電圧に届いたら一気に切り替える、を繰り返す発振の呼び名で、非安定マルチバイブレータも
その一つ。出てくる波は正弦波ではなく、方形波やのこぎり波に近い。

## 回路図

```circuit
title: 図1 弛張発振でブザー (Q1・Q2 を左右に、C1・C2 が中央で交差する。ブザーの枝は右)
parts:
  VCC: vcc a1 5V
  R1: resistor a1 c1 330
  D1: led c1 d1 red
  Q1: npn f1 mirror 2SC1815
  G1: ground g1
  R4: resistor a4 c4 10k
  R3: resistor a7 c7 10k
  R2: resistor a10 c10 330
  D2: led c10 d10 red
  Q2: npn f10 2SC1815
  G2: ground g10
  C1: capacitor d2 d3 100n
  C2: capacitor d9 d8 100n
  R5: resistor d13 f13 100
  BZ1: buzzer f13 h13
  G3: ground h13
wires:
  - a1 -- a4 -- a7 -- a10
  - d1 |- Q1.C
  - d10 |- Q2.C
  - Q1.E |- g1
  - Q2.E |- g10
  - d1 -- d2
  - d10 -- d9
  - d10 -- d13
  - d3 -- f7
  - d8 -- f4
  - c4 -- f4
  - c7 -- f7
  - f4 -- Q1.B
  - f7 -- Q2.B
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/04-relaxation-oscillator-buzzer.svg)

- 図1 は 3-1 と同じく左右対称に描いた (左が Q1、右が Q2。X 字の線は C1・C2 で、つながっていない)。R3・R4 を 100 kΩ→10 kΩ、C1・C2 を 10 µF→100 nF にしただけで、3-1 と
  **回路そのものは同じ**。周期が 1/1000 になり、耳に聞こえる周波数になる
- **R5 (100 Ω) はブザーの保護。** 圧電ブザーはコンデンサに近い部品なので、
  スイッチの切り替わり (Q2 が急に ON/OFF) の瞬間に大きな電流 (突入電流) が流れ込む。
  R5 がそれを抑える
- LED は約 940 Hz で点滅するので目では点滅が見えず、うっすら点いたままに見える
  (残像。目で追える点滅は 30〜60 Hz 程度まで)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (3-1 と同じ並びに、ブザーの枝を右下に足す)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
  R1: resistor b2 b5 330
  D1: led c5(A) c7(K) red
  R4: resistor b8 b12 10k
  C1: capacitor/ceramic a7 a11 100nF
  R3: resistor b18 b22 10k
  C2: capacitor/ceramic a23 a19 100nF
  R2: resistor b25 b28 330
  D2: led c25(A) c23(K) red
  Q1: transistor h6(E) h7(C) h8(B) 2SC1815
  Q2: transistor h22(B) h23(C) h24(E) 2SC1815
  R5: resistor h26 h29 100
  BZ1: buzzer j27 j29
wires:
  - AD3.V+ -- +t1 red
  - AD3.GND -- -t3 black
  - +t2 -- a2 red
  - +t12 -- a12 red
  - +t18 -- a18 red
  - +t28 -- a28 red
  - a6 -- -t6 black
  - e6 -- f6 black
  - a24 -- -t24 black
  - e24 -- f24 black
  - e7 -- f7 orange
  - e8 -- f8 blue
  - e22 -- f22 blue
  - e23 -- f23 orange
  - d19 -- d8 green
  - e11 -- d22 yellow [v-10, h220, v-10]
  - g23 -- g26 purple
  - i27 -- -b27 black
  - -t30 -- -b30 black
  - SC.1+ -- j7 orange
  - SC.2+ -- j23 green
  - SC.1- -- -b12 black
  - SC.2- -- -b13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/04-relaxation-oscillator-buzzer.svg)

- 図2 は 3-1 の図2 と同じ並び (左に Q1 の組、右に Q2 の組) で、値だけ R3・R4 を 10 kΩ、
  C1・C2 を 100 nF にした。コレクタ (7・23 列) とベース (8・22 列) は溝をまたぐ短い線で上のブロックへ持ち上げ、
  交差結合の 2 本 (緑・黄) は別の行を平行に走らせる
- この図ではエミッタ (6・24 列) も溝をまたぐ黒い線で上へ持ち上げ、上の − レールへ落とす。
  下の右側をブザーの枝に空けるため
- **R5・BZ1 は Q2 のコレクタ (23 列) から紫の線で 26 列へ分け、R5 (26→29 列) → BZ1 (29 列の足) → 27 列の足から下の − レールへ落とす。**
  LED (D2) と並列に、音を出す枝が 1 本増えただけ。上と下の − レールは右端の 30 列でつなぐ
- 電源は AD3 の Supplies (V+ を 5 V にする)。流れる電流は LED 約 8 mA とブザーの枝で、V+ の 50 mA (USB 給電で 250 mW) に収まる。
  V+ は上の + レール、GND は上の − レールへ入れる。+5V の線は 2・12・18・28 列、エミッタの GND の線は 6・24 列に立てた
- Scope は板の下に別の箱 (AD3 Scope) で描いた。1+ (橙) は Q1 のコレクタの 7 列 (`j7`)、2+ (緑) は Q2 のコレクタの 23 列 (`j23`) に挿し、
  1− と 2− (黒) は下の − レール (GND) へ挿す
- Q1 は平らな面を手前 (j 行側) に向けて左から E・C・B、Q2 は平らな面を奥 (f 行側) に向けて左から B・C・E
- 圧電ブザーに極性は無い。どちら向きに挿してもよい
- C1・C2 は 3-1 の電解コンデンサから積層セラミック (極性無し) に替える。挿す向きは自由

## 計器の設定

オシロには AD3 の Scope を使う。周期 約 1 ms (約 940 Hz) の方形波の形を見る題で、10 MHz よりずっと遅いから。
CH1 に Q1 のコレクタ、CH2 に Q2 のコレクタをつなぐ。3-1 と同じく交互に上下する。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (Q1 のコレクタ、7 列) | DC、1 V/div |
| Scope CH2 (Q2 のコレクタ、23 列) | DC、1 V/div |
| Time | 200 µs/div (2 ms で周期が約 2 つ見える) |
| Trigger | CH1、立ち上がり、1.8 V |

```scope
title: 図3 Q1 (CH1) と Q2 (CH2) のコレクタ — 周期 約 1.06 ms で交互に上下する
time: 200us/div
trigger: ch1 rising 1.8V
ch1: {wave: square 943Hz 1.55V offset 1.75V, range: 1V/div}
ch2: {wave: square 943Hz 1.55V offset 1.75V phase 180deg, range: 1V/div}
cursors: [-250us, 810us]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/04-relaxation-oscillator-buzzer.svg)

図3 は SPICE の値 (周期 約 1.06 ms、オフの側 約 3.3 V、オンの側 約 0.2 V) で描いた想定の波形で、実測ではない。実物の立ち上がりは、
ブザーの容量と C1・C2 の充電で図より少し丸くなる。カーソルの間隔 1.06 ms が 1 周期で、周波数に直すと約 940 Hz。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| R1, R2 | 抵抗 (LED 電流制限) | 330 Ω |
| R3, R4 | 抵抗 (ベース) | 10 kΩ |
| R5 | 抵抗 (ブザー保護) | 100 Ω |
| C1, C2 | 積層セラミックコンデンサ | 100 nF (0.1 µF) |
| D1, D2 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| BZ1 | 圧電ブザー素子 (アンプ無し) | — |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+/2+ (Q1 と Q2 のコレクタ) |

## 見るべき値

式の目安は T = 1.386 × R × C (3-1 と同じ式) で 1.39 ms (720 Hz) だが、3-1 と同じく LED の分
(オフの側のコレクタが約 3.3 V で止まる) だけ短くなる。SPICE (LTspice、2SC1815 と赤 LED の模型、
ブザーは 20 nF の容量と仮定) で確かめると、周期は **約 1.06 ms (約 940 Hz)**。ベース電流が
(5 − 0.7) V ÷ 10 kΩ ≈ 0.43 mA と大きいので、3-1 と違って hFE 120〜400 のどれでも同じ値だった。
周波数はオシロ (0-3) で Q2 のコレクタ (22 列) の波形の周期を読むか、
周波数レンジ (Hz) のあるテスターで測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 発振周波数 | 約 940 Hz (周期 約 1.06 ms、SPICE) | 式の 1 / (1.386 × 10 kΩ × 100 nF) = 720 Hz より高いのは LED の分 |
| デューティ比 | 50% | R3=R4、C1=C2 で対称 |
| ブザーの音量 | R5 を小さくすると大きくなる (下限は突入電流と相談) | R5 が電流を制限している |
| Q1・Q2 のコレクタ損失 | 数 mW 程度 | 330 Ω 側は 3-1 と同じ計算 |

3-2 の 555 (Ra・Rb・C だけで周波数が決まる) と比べると、Tr 2 石は式は同じ形でも、
トランジスタの hFE (0-5) や LED の電圧で周波数がぶれ、作るたびに同じにはなりにくい。
ばらつきを気にするなら 555 のほうが実用的、という体験がこの 2 題の対比になる。

## 出典

自作。
