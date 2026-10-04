---
book: circuits
chapter: 1
id: 1-6
title: ポテンショメータで分圧 (電位差計)
tier: 100
board: BB
source: 自作
---

# 1-6 ポテンショメータで分圧 (電位差計)

1-2 の分圧は抵抗 2 本の**値で**比率を決めたが、ポテンショメータ (可変抵抗器、
3 本足。ボリュームとも呼ぶ) は**つまみの位置で**比率を連続的に変えられる。中の抵抗体の両端に
電源をかけ、真ん中の足につながった**ワイパー** (抵抗体の上を滑る接点) から出力を取り出す
仕組みで、昔は「電位差計」とも呼ばれた。音量や明るさのつまみの基本形で、
出力に負荷をつなぐと目盛りどおりの電圧が出なくなることも確かめる。

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

図1 の `P1` (10kΩ) の上端が +5V、下端が GND。ワイパーを**下端 (GND 側) から**測って
全体の **x** (0〜1) の位置にすると、無負荷の出力は単純な分圧と同じ式になる。

- V<sub>out</sub> = 5V × x (無負荷)
- x = 0.25 で 1.25V、x = 0.5 で 2.5V、x = 0.75 で 3.75V (計算値)

次にワイパーへ 10kΩ の負荷 `RL` をつないで (図2)、無負荷の値とどれだけ違うかを見る。

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

負荷 (RL) の抵抗がポテンショメータ自身の抵抗と同じ桁だと、**つまみの目盛りと
実際の出力がずれる**。0-4 で見た「自作テスターの内部抵抗による誤差」(負荷効果) と
同じ理屈。負荷の抵抗が大きいほど (RL ≫ P1 の抵抗) ずれは小さくなる。

## 実体配線図

図1・図2 は同じ組み方で、`RL` を挿すか抜くかだけが違う。電源は Analog Discovery 3 (AD3) の
Supplies の +5 V (電流は数 mA で、各レール約 50 mA の範囲に収まる)。出力の電圧は AD3 の Scope の
1+ / 1− を電圧計として当てて読む (テスターの DCV でも同じ値が読める)。
この題は直流の電圧だけを見るので、オシロの波形の図は付けない。

```breadboard
title: 図3 ポテンショメータの分圧を AD3 の電圧計で当たる
# 上の赤いレール = +5V、青いレール = GND
board: half
parts:
  P1: potentiometer b5(1) b6(W) b7(3) 10k
  RL: resistor e6 e11 10k
  SC:
    type: device
    at: bottom
    label: AD3 Scope (DC 電圧計)
    pins: [1-, 1+]
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a7 -- -t7 black
  - a11 -- -t11 black
  - SC.1+ -- d6 orange
  - SC.1- -- d11 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/06-potentiometer-divider.svg)

- `P1` の 3 本足を `b5` `b6` `b7` に挿す。端の足 `b5` が +5V 側 (赤の線で
  上の赤いレールから `a5` へ)、反対の端 `b7` が GND 側 (黒の線で `a7` から
  青いレールへ)、真ん中の `b6` がワイパー。
- `RL` (10kΩ) は `e6` と `e11` に挿す。`e6` はワイパーと同じ列 6 なので
  ジャンパ線なしでつながる。右の足の列 11 は黒の線 (`a11` → 青いレール) で GND へ。
  図1 の無負荷を測るときは `RL` を抜く。
- AD3 Scope の 1+ を `d6` (ワイパーの列)、1− を `d11` (GND の列) につなぐ。
  図ではそれぞれ橙・灰の線で描いた。Scope は DC カップリング、1 V/div 程度で、画面の Measurements の平均値 (DC) を読む。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| P1 | ポテンショメータ | 10 kΩ |
| RL | 抵抗 (1/4 W) | 10 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+ / 1− (直流の電圧を読む)。抵抗はテスターで測る |

## 見るべき値

ワイパーの位置 x は、電源を外し `RL` を抜いた状態で、テスターを Ω レンジにし、棒を `d6` (ワイパーの列) と
`c7` (GND 側の端の列) に当てて決める。読みが 2.5 kΩ なら x = 0.25、5 kΩ なら 0.5、7.5 kΩ なら 0.75。
つまみを合わせたら電源をつなぎ、出力を直流電圧レンジで読む。

| ワイパーの位置 x | 無負荷の出力 (計算値) | RL = 10kΩ をつないだときの出力 (計算値) |
| --- | --- | --- |
| 0.25 | 1.25 V | 約 1.05 V |
| 0.50 | 2.50 V | 約 2.00 V |
| 0.75 | 3.75 V | 約 3.16 V |

x = 0.5 のまま RL を 1kΩ に替えると、出力は 5V × (5k∥1k) / (5k + 5k∥1k) ≈ 0.71 V (計算値)
まで下がる。無負荷 (テスターの入力抵抗が大きい状態) の 2.5 V と比べると、ずれの大きさがはっきり分かる。

## 出典

自作。
