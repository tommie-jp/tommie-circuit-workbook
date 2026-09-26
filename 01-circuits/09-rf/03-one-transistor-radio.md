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
  ANT: port e1
  L1: inductor e2 g2 250u
  GL: ground g2
  VC1:
    type: device
    at: f5
    pins: [A, E]
  GVC: ground g4
  C1: capacitor e6 e7 0.01u
  Q1: npn e10
  VCC: vcc a10
  Rc: resistor c10 a10 1.5k
  Rb: resistor c8 c10 180k
  GE: ground f10
  D1: diode c11 c13 1N60
  C3: capacitor c14 e14 0.001u
  GC3: ground e14
  R3: resistor c16 e16 100k
  GR3: ground e16
  EAR:
    type: device
    at: d19
    pins: [A, B]
  GEAR: ground f18
wires:
  - e1 -- e6
  - e3 |- VC1.A
  - VC1.E -| g4
  - e7 -- e8
  - e8 -- Q1.B
  - c8 -- e8
  - c10 -- Q1.C
  - Q1.E -- f10
  - c10 -- c11
  - c13 -- c17
  - c17 |- EAR.A
  - EAR.B -| f18
```

- **タンク → C1 → ベース**: L1・VC1 の並列タンクで選んだ電波を、結合コンデンサ
  C1 で Q1 のベースへ渡す
- **コレクタ帰還バイアス**: Rb (180kΩ) がコレクタからベースへ戻る。hFE が
  100〜300 に散っても動作点が安定する (2-8 と同じ考え方)
- **検波**: D1 は Q1 のコレクタに直結。Rc → コレクタ → D1 → R3 → GND の道が
  常に電流を流しているので、ダイオードはあらかじめゲルマニウムの立ち上がりに
  乗っている。弱い電波でも検波が始まる
- C3 が残った高周波を GND へ落とし、R3 が検波の負荷。EAR (クリスタルイヤホン)
  は R3 と並列 (A 端子を検波出力、B 端子を GND) につないで音を出す

**動作点の計算値** (V<sub>CC</sub> = 3V、hFE = 200、V<sub>BE</sub> = 0.6V):

I<sub>C</sub> = (V<sub>CC</sub> − V<sub>BE</sub>) / (R<sub>b</sub>/hFE + R<sub>c</sub>) ≈ 1.0mA、
V<sub>C</sub> ≈ 1.5V (電源のほぼ半分、安定に振れる余地がある)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [A, E]
  EAR:
    type: device
    at: top
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b3 b7 250u
  C1: capacitor/ceramic d3 d9 0.01u
  Q1: transistor f13(B) f15(C) f17(E) 2SC1815
  Rb: resistor c20 c24 180k
  Rc: resistor c26 c29 1.5k
  D1: diode d32(A) d38(K) 1N60
  C3: capacitor/ceramic d41 d44 0.001u
  R3: resistor c41 c44 100k
wires:
  - ANT.1 -- a3 yellow
  - VC1.A -- c3 yellow
  - VC1.E -- -t2 black
  - a7 -- -t7 black
  - a9 -- g13 orange
  - a20 -- c9 orange
  - a24 -- b15 blue
  - a15 -- g15 blue
  - a26 -- c15 blue
  - a29 -- +t29 red
  - g17 -- -t17 black
  - b32 -- d15 gray
  - b38 -- b41 green
  - a44 -- -t44 black
  - EAR.A -- a38 green
  - EAR.B -- -t48 black
  - -t50 -- -b50 black
```

- 上の赤レール = +3V (単3 電池 2 本)、青レール = GND。50 列で上下の − レールを
  渡している
- Q1 のベース (f13) は 9 列の橋渡し (a9・c9) を通じて C1 の右足・Rb の左足 (20 列) と
  つながる。コレクタ (f15) は 15 列の橋渡し (a15〜d15) を通じて Rb の右足 (24 列)・
  Rc の左足 (26 列)・D1 のアノード (32 列) とつながる
- 1 つの穴には足か線を 1 本だけ挿す。部品の足がある列へは、同じ列の空いた穴から
  線を出す (c24 の Rb の足には a24 から、など)
- D1 のカソード (d38) から b38 → b41 へ渡し、41 列で C3・R3 の左足と、38 列 (a38) で
  EAR の A 端子が同じ検波出力のネットに並列に入る。C3・R3 の右足 (44 列、a44 から) と
  EAR の B 端子は上の − レール (GND) へ

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| Q1 のコレクタ電圧 (Vcc 基準) | 約1.5V (電源の半分) |
| Q1 のコレクタ電流 | 約1.0mA |
| 電圧利得 (g<sub>m</sub>·R<sub>c</sub>) | 約58倍 (35dB) |

- タンクだけのゲルマラジオ (9-2) より弱い局まで聞こえるようになる。
  高周波を増幅してから検波するぶん、検波に必要な振幅を作りやすい
- Rb を外して Rc だけの固定バイアスにすると、hFE のばらつきで Vc が
  0V 近く (飽和) か 3V 近く (遮断) に張り付きやすくなる。コレクタ帰還の
  効果を確かめられる

## 出典

自作。
