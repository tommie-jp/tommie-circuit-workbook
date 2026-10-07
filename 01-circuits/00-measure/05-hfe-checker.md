---
book: circuits
chapter: 0
id: 0-5
title: hFE チェッカー
tier: 100
board: BB
source: 自作
era: 古
---

# 0-5 hFE チェッカー

トランジスタは B (ベース)・C (コレクタ)・E (エミッタ) の 3 ピンの部品で、ベースに流す
小さな電流 I<sub>B</sub> で、コレクタからエミッタへ流れる大きな電流 I<sub>C</sub> を操る
(くわしくは第 2 章)。その比が電流増幅率 **hFE = I<sub>C</sub> / I<sub>B</sub>** で、
同じ型番でも個体差が大きい (2SC1815 は 70〜700 まで幅がある)。
ベース電流を大きな抵抗 1 本で一定に決めてやり、コレクタ電流を読めば hFE が計算できる。
これが昔の簡易 hFE チェッカーの仕組みで、手持ちのトランジスタを選り分けるのに使える。

## 回路図

```circuit
title: 図1 一定のベース電流でコレクタ電流を読む
parts:
  V1: vsource 2,1 2,3 5
  RB: resistor 4,1 4,3 1M
  A1: ammeter 4,3 4,5
  RC: resistor 7,1 7,3 1k
  A2: ammeter 7,3 7,5
  Q1: npn 7,6
  G1: ground 7,7
wires:
  - 2,1 -- 4,1 -- 7,1
  - 4,5 -- 4,6 -- Q1.B
  - 7,5 -- Q1.C
  - Q1.E -- 7,7
  - 2,3 -- 2,7 -- 7,7
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/circuit/05-hfe-checker.svg)

`RB` (1MΩ) がベース電流を、トランジスタの種類によらずほぼ一定に決める。

- ベース電流: I<sub>B</sub> = (5 − 0.7) / 1MΩ ≈ **4.3 µA** (`A1` の読み)。
  0.7 V はベースとエミッタの間の電圧 V<sub>BE</sub>。V<sub>BE</sub> が 0.6〜0.7V の範囲で
  多少動いても、I<sub>B</sub> の差は 2 % ほどで無視できる
- コレクタ電流 (`A2` の読み) は hFE に比例する: I<sub>C</sub> = hFE × I<sub>B</sub>
- `RC` (1kΩ) はどんな hFE でも飽和させないための値。**飽和**は、RC で電流が頭打ちになって
  I<sub>C</sub> が hFE × I<sub>B</sub> まで増えられない状態で、こうなると hFE を読めない。
  I<sub>C</sub> = hFE × I<sub>B</sub> が成り立つ状態を**活性領域**と呼ぶ。2SC1815 の上限
  hFE = 700 でも I<sub>C</sub> = 700 × 4.3µA ≈ 3.01mA、V<sub>C</sub> = 5 − 3.01mA×1kΩ
  ≈ **1.99 V** で、まだ活性領域に余裕がある (計算値)
- hFE は測ったあとで **hFE = I<sub>C</sub>(A2 の読み) / I<sub>B</sub>(A1 の読み)** を
  手計算で求める

## 実体配線図

```breadboard
title: 図2 RB と RC を 5V につなぎ、Q1 のベースとコレクタへ入れる
board: half
parts:
  RB: resistor b12 b17 1M
  RC: resistor c8 c13 1k
  Q1: transistor e12(B) e13(C) e14(E) 2SC1815
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t8 -- a8 red
  - +t17 -- a17 red
  - a14 -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/breadboard/05-hfe-checker.svg)

5V は Analog Discovery 3 (AD3) の Supplies の V+ から上の + レールへ、GND は上の − レールへ。
電流は 3 mA ほどで、ブレッドボードの範囲と AD3 の電源 (各レール約 50 mA まで) に収まる。
`RB` の下端 (列 12) はベース、`RC` の下端 (列 13) はコレクタと同じ列で、エミッタ (列 14) は黒線で − レールへ落とす。
`Q1` は平らな面を奥に向けて挿す (2-1 と同じ)。

回路図の電流計 `A1`・`A2` は、ブレッドボードでは線で埋めた形に描いてある。電流を読むときは、`RB` か `RC` の下端のピンを 1 本抜き、
その穴と抵抗のピンの間にテスターの電流端子を挟む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RB | 抵抗 (1/4 W) | 1 MΩ |
| RC | 抵抗 (1/4 W) | 1 kΩ |
| Q1 | NPN トランジスタ (測るもの) | 2SC1815 など |
| — | 電源 | Analog Discovery 3 の V+ (5 V) |

## 計器の設定

計器は、直流の電流を読むテスターと、電源の AD3 (Supplies の V+ を 5 V にする)。
オシロの図は付けない。見るのは時間で変わらない直流の電流 (I<sub>B</sub>・I<sub>C</sub>) と電圧 (V<sub>C</sub>) だけで、テスターの読みで足りるため。

## 見るべき値

テスターを直流電流レンジにし、A1 は µA のレンジで、A2 は mA のレンジで読む。
テスターが 1 台なら片方ずつ測り、測らない側の隙間はジャンパ線でつないでおく。
V<sub>C</sub> は直流電圧レンジで Q1 のコレクタと GND の間に当てる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| A1 の読み (I<sub>B</sub>) | 約 4.3 µA (ほぼ一定) | どの Q1 を挿しても RB が決めるベース電流はほぼ変わらない |
| A2 の読み (I<sub>C</sub>、2SC1815-GR ランク hFE 200〜400 相当) | 約 0.86〜1.72 mA | hFE × 4.3µA (計算値)。個体差がそのまま I<sub>C</sub> の差になる |
| Vc (Q1 の C-GND 間) | 約 3.3〜4.1 V (上の hFE の範囲で) | 飽和 (0.2V 付近) までまだ余裕があり、活性領域で計算どおり動く |
| hFE = A2 ÷ A1 | データシートの hFE ランクの範囲に入るはず | 実測でランク (O・Y・GR・BL) を判定できる |

RB を 100kΩ に替えると I<sub>B</sub> は 10 倍 (約 43µA) になる。hFE が高い個体
(400〜700) では I<sub>C</sub> が 17〜30 mA 要ることになるが、RC (1kΩ) では 5 mA
までしか流せないので飽和してしまう。ベース電流を一定に保つことと、飽和させない RC を
選ぶことが、この回路の要。

## 出典

自作。
