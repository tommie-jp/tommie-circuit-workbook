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
title: 図1 弛張発振でブザー
parts:
  V1: vsource vcc gnd 5
  G1: ground gnd
  R1: resistor a3 c3 330
  D1: led c3 e3 red
  R4: resistor a5 c5 10k
  R3: resistor a9 c9 10k
  R2: resistor a11 c11 330
  D2: led c11 e11 red
  Q1: npn g3 mirror 2SC1815
  Q2: npn g11 2SC1815
  C1: capacitor e4 e8 100n
  C2: capacitor d10 d6 100n
  R5: resistor f13 g13f0 100
  BZ1: buzzer g13f0 i13
points:
  vcc: a1
  gnd: i1
wires:
  - vcc -- a3 -- a5 -- a9 -- a11
  - e3 |- Q1.C
  - e11 -- f11
  - f11 |- Q2.C
  - f11 -- f13
  - e3 -- e4
  - e8 -- e9
  - c9 -- e9
  - e9 |- Q2.B
  - e10 -- e11
  - e10 -- d10
  - d6 -- d5
  - c5 -- d5
  - d5 |- Q1.B
  - Q1.E |- i3
  - Q2.E |- i11
  - gnd -- i3 -- i11 -- i13
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/04-relaxation-oscillator-buzzer.svg)

- 図1 は、R3・R4 を 100 kΩ→10 kΩ、C1・C2 を 10 µF→100 nF にしただけで、3-1 と
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
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  R1: resistor b1 b4 330
  D1: led c4(A) c6(K) red
  R4: resistor b7 b11 10k
  C1: capacitor/ceramic a6 a10 100nF
  R3: resistor b17 b21 10k
  C2: capacitor/ceramic a22 a18 100nF
  R2: resistor b24 b27 330
  D2: led c24(A) c22(K) red
  Q1: transistor h5(E) h6(C) h7(B) 2SC1815
  Q2: transistor h21(B) h22(C) h23(E) 2SC1815
  R5: resistor g24 g27 100
  BZ1: buzzer i27 i29
wires:
  - PS.+5V -- +t2 red
  - PS.GND -- -t3 black
  - +t1 -- a1 red
  - +t11 -- a11 red
  - +t17 -- a17 red
  - +t27 -- a27 red
  - a5 -- -t5 black
  - e5 -- f5 black
  - a23 -- -t23 black
  - e23 -- f23 black
  - e6 -- f6 orange
  - e7 -- f7 blue
  - e21 -- f21 blue
  - e22 -- f22 orange
  - d18 -- d7 green
  - e10 -- d21 yellow [v-10, h220, v-10]
  - j22 -- j24 purple
  - j29 -- -b29 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/04-relaxation-oscillator-buzzer.svg)

- 図2 は 3-1 の図2 と同じ並び (左に Q1 の組、右に Q2 の組) で、値だけ R3・R4 を 10 kΩ、
  C1・C2 を 100 nF にした。コレクタ (6・22 列) とベース (7・21 列) は溝をまたぐ短い線で上のブロックへ持ち上げ、
  交差結合の 2 本 (緑・黄) は別の行を平行に走らせる
- この図ではエミッタ (5・23 列) も溝をまたぐ黒い線で上へ持ち上げ、上の − レールへ落とす。
  下の右側をブザーの枝に空けるため
- **R5・BZ1 は Q2 のコレクタ (22 列) から紫の線で 24 列へ分け、R5 → BZ1 → 下の − レールへ落とす。**
  LED (D2) と並列に、音を出す枝が 1 本増えただけ。上と下の − レールは右端の 30 列でつなぐ
- Q1 は平らな面を手前 (j 行側) に向けて左から E・C・B、Q2 は平らな面を奥 (f 行側) に向けて左から B・C・E
- 圧電ブザーに極性は無い。どちら向きに挿してもよい
- C1・C2 は 3-1 の電解コンデンサから積層セラミック (極性無し) に替える。挿す向きは自由

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
| — | 電源 | 5 V |

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
