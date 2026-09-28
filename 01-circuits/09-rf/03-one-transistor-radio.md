---
book: circuits
chapter: 9
id: 9-3
title: 1 石ラジオ (トランジスタ検波)
tier: 50
source: 自作
board: BB
era: 古
---

# 9-3 1 石ラジオ (トランジスタ検波)

ゲルマラジオの同調タンクはそのままに、**検波の前にトランジスタ 1 石で高周波を
増幅**する。ダイオードに直流のバイアス電流をあらかじめ流しておく検波方式で、
弱い電波でも音が大きくなる。電池が要る代わりに、アンテナが短くても聞こえる。

## 回路図

```circuit
title: 図1 1石ラジオ
parts:
  ANT: antenna e1
  L1: inductor e2 g2 250u
  GL: ground g2
  VC1: capacitor-var e4 g4 l=$\mathrm{VC}_1$
  GVC: ground g4
  C1: capacitor e6 e7 0.01u
  Q1: npn e10
  VCC: vcc a10
  Rc: resistor c10 a10 1.5k
  Rb: resistor c8 c10 220k
  GE: ground f10
  D1: diode c11 c13 1N60
  C3: capacitor c14 e14 0.001u
  GC3: ground e14
  R3: resistor c16 e16 100k
  GR3: ground e16
  EAR: earphone c19 e19 l=$\mathrm{EAR}$
  GEAR: ground e19
wires:
  - e1 -- e6
  - e7 -- e8
  - e8 -- Q1.B
  - c8 -- e8
  - c10 -- Q1.C
  - Q1.E -- f10
  - c10 -- c11
  - c13 -- c17
  - c17 -- c19
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/03-one-transistor-radio.svg)

- **タンク → C1 → ベース**: L1・VC1 の並列タンクで選んだ電波を、結合コンデンサ
  C1 で Q1 のベースへ渡す
- **コレクタ帰還バイアス**: Rb (220kΩ) がコレクタからベースへ戻る。hFE が
  100〜300 に散っても動作点が安定する (2-8 と同じ考え方)
- **検波**: D1 は Q1 のコレクタに直結。Rc → コレクタ → D1 → R3 → GND の道が
  常に電流を流しているので、ダイオードはあらかじめゲルマニウムの立ち上がりに
  乗っている。弱い電波でも検波が始まる
- C3 が残った高周波を GND へ落とし、R3 が検波の負荷。EAR (クリスタルイヤホン)
  は R3 と並列 (A 端子を検波出力、B 端子を GND) につないで音を出す
- **イヤホンのインピーダンス**: EAR は、いま売られているセラミック (圧電) 型の
  クリスタルイヤホンを想定する (容量 約 15nF、直流では 20MΩ 以上)。電気的には
  コンデンサなので、インピーダンスは周波数で変わり、**1kHz で約 10kΩ**
  (1/(2π×1kHz×15nF) ≈ 10.6kΩ)、100Hz で約 100kΩ。8Ω や 32Ω の
  ダイナミック型のイヤホンでは、この小さな電流では鳴らない
- 1kHz ではイヤホン (約 10kΩ) が R3 (100kΩ) よりずっと低いので、音声の負荷はほぼイヤホン。
  イヤホンは直流を通さないので、D1 にバイアス電流を流す直流の道は R3 が作る。
  イヤホンの容量 (15nF) は C3 (1nF) と並列に入り、高周波のバイパスも助ける

**動作点の計算値** (V<sub>CC</sub> = 5V、hFE = 200、V<sub>BE</sub> = 0.6V):

I<sub>C</sub> = (V<sub>CC</sub> − V<sub>BE</sub>) / (R<sub>b</sub>/hFE + R<sub>c</sub>) ≈ 1.7mA、
V<sub>C</sub> ≈ 2.5V (電源のほぼ半分、安定に振れる余地がある)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [E, A]
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  EAR:
    type: device
    at: bottom
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b8 b12 250u
  C1: capacitor/ceramic d8 d14 0.01u
  Q1: transistor j14(B) j18(C) j22(E) 2SC1815
  Rb: resistor h14 h18 220k
  Rc: resistor d18 d15 1.5k
  D1: diode a18(A) a24(K) 1N60
  C3: capacitor/ceramic b24 b28 0.001u
  R3: resistor d24 d28 100k
wires:
  - ANT.1 -- c8 yellow
  - VC1.A -- a8 yellow
  - VC1.E -- -t6 black
  - a12 -- -t12 black
  - e14 -- f14 orange
  - e18 -- f18 blue
  - +t15 -- a15 red
  - i22 -- i23 black
  - j23 -- -b23 black
  - e24 -- f24 green
  - EAR.A -- j24 green
  - EAR.B -- -b26 black
  - a28 -- -t28 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/03-one-transistor-radio.svg)

- 上の赤レール = +5V (USB や電池)、青レール = GND。30 列で上下の − レールを渡している
- 前段は 8 列にアンテナ・VC1・L1・C1 をまとめる。L1 の右足 (12 列) は上の − レールへ
- Q1 は下のブロックの j 行 (14 列 B・18 列 C・22 列 E)。ベース (14 列) とコレクタ (18 列) は
  e–f の短い線で上のブロックへも出し、足の多いネットを上下に分ける。
  Rb はベースとコレクタの間 (h 行)、Rc はコレクタと 15 列 (+5V) の間
- D1 のアノードはコレクタ (a18)、カソード (a24) が検波出力。24 列に C3・R3 の左足が並び、
  e–f の線で下へ出して EAR の A 端子 (j24) へ。C3・R3 の右足 (28 列) と EAR の B 端子は GND へ
- 1 つの穴には足か線を 1 本だけ挿す

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| Q1 のコレクタ電圧 (Vcc 基準) | 約2.5V (電源の半分) |
| Q1 のコレクタ電流 | 約1.7mA |
| 電圧利得 (g<sub>m</sub>·R<sub>c</sub>) | 約98倍 (40dB) |

- タンクだけのゲルマラジオ (9-2) より弱い局まで聞こえるようになる。
  高周波を増幅してから検波するぶん、検波に必要な振幅を作りやすい
- Rb を外して Rc だけの固定バイアスにすると、hFE のばらつきで Vc が
  0V 近く (飽和) か 5V 近く (遮断) に張り付きやすくなる。コレクタ帰還の
  効果を確かめられる

## 出典

自作。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
