---
book: circuits
chapter: 1
id: 1-6
title: ポテンショメータで分圧 (電位差計)
tier: 100
source: 自作
---

# 1-6 ポテンショメータで分圧 (電位差計)

1-2 の分圧は抵抗 2 本の**値で**比率を決めたが、ポテンショメータ (可変抵抗器、
3 本足) は**つまみの位置で**比率を連続的に変えられる。中の抵抗体の両端に
電源をかけ、真ん中の**ワイパー**から出力を取り出す仕組みで、昔は
「電位差計」とも呼ばれた。

## 回路図

まずワイパーに何もつながない (無負荷) 状態。

```circuit
title: 図1 ポテンショメータの無負荷の出力
parts:
  V1: vsource a1 e1 5
  G0: ground e1
  P1: potentiometer a3 e3 10k
  OUT: port c5
wires:
  - a1 -- a3
  - e1 -- e3
  - P1.w |- b5 -- c5
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/06-potentiometer-divider-1.svg)

`P1` (10kΩ) の上端が +5V、下端が GND。ワイパーを**下端 (GND 側) から**測って
全体の **x** (0〜1) の位置にすると、無負荷の出力は単純な分圧と同じ式になる。

- V<sub>out</sub> = 5V × x (無負荷)
- x = 0.25 で 1.25V、x = 0.5 で 2.5V、x = 0.75 で 3.75V (計算値)

次にワイパーへ 10kΩ の負荷 `RL` をつないで、無負荷の値とどれだけ違うかを見る。

```circuit
title: 図2 ポテンショメータに負荷をつないだとき
parts:
  V1: vsource a1 e1 5
  G0: ground e1
  P1: potentiometer a3 e3 10k
  RL: resistor c7 e7 10k
  G1: ground e7
wires:
  - a1 -- a3
  - e1 -- e3
  - P1.w |- b5 -| c7
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/06-potentiometer-divider-2.svg)

`RL` (10kΩ) は `P1` の下側の抵抗と並列になるので、ワイパーより下の抵抗が
見かけ上小さくなり、出力が無負荷より**下がる**。x = 0.5 (ちょうど中点、
上下とも 5kΩ) で計算すると:

- 下側の抵抗と RL の並列: 5k∥10k = (5k×10k)/15k ≈ **3.33 kΩ**
- 出力: 5V × 3.33k / (5k + 3.33k) ≈ **2.0 V** (無負荷の 2.5V より 20% ほど低い)

**負荷 (RL) がポテンショメータ自身の抵抗と同じ桁だと、つまみの目盛りと
実際の出力がずれる** — 0-4 で見た「自作テスターの内部抵抗による誤差」と
同じ理屈。負荷が大きいほど (RL ≫ P1 の抵抗) ずれは小さくなる。

## 実体配線図

図1・図2 は同じ組み方で、`RL` を挿すか抜くかだけが違う。電圧はテスター (DCV) で
当たるので、波形を見るオシロスコープは要らない。

```breadboard
title: 図3 ポテンショメータの分圧をテスターで当たる
# 上の赤いレール = +5V、青いレール = GND
board: half
parts:
  P1: potentiometer b5(1) b6(W) b7(3) 10k
  RL: resistor e6 e11 10k
  MULT:
    type: device
    at: bottom
    label: テスター (DCV)
    pins: ["+", COM]
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a7 -- -t7 black
  - a11 -- -t11 black
  - MULT.+ -- d6 orange
  - MULT.COM -- d11 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/06-potentiometer-divider.svg)

- `P1` の 3 本足を `b5` `b6` `b7` に挿す。端の足 `b5` が +5V 側 (赤の線で
  上の赤いレールから `a5` へ)、反対の端 `b7` が GND 側 (黒の線で `a7` から
  青いレールへ)、真ん中の `b6` がワイパー。
- `RL` (10kΩ) は `e6` と `e11` に挿す。`e6` はワイパーと同じ列 6 なので
  ジャンパ線なしでつながる。右の足の列 11 は黒の線 (`a11` → 青いレール) で GND へ。
  図1 の無負荷を測るときは `RL` を抜く。
- テスターの赤の棒 (+) を `d6` (ワイパーの列)、黒の棒 (COM) を `d11`
  (GND の列) に当てる。図ではそれぞれ橙・灰の線で描いた。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| P1 | ポテンショメータ | 10 kΩ |
| RL | 抵抗 (1/4 W) | 10 kΩ |
| — | 電源 | 5V (USB) |

## 見るべき値

| ワイパーの位置 x | 無負荷の出力 (計算値) | RL = 10kΩ をつないだときの出力 (計算値) |
| --- | --- | --- |
| 0.25 | 1.25 V | 約 1.05 V |
| 0.50 | 2.50 V | 約 2.00 V |
| 0.75 | 3.75 V | 約 3.16 V |

x = 0.5 の行を実測して、無負荷 (テスターの入力抵抗が大きい状態) と、
1kΩ 程度の低い抵抗を負荷にした状態を比べると、ずれの大きさがはっきり分かる。

## 出典

自作。
