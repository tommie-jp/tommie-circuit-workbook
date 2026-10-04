---
book: circuits
chapter: 1
id: 1-7
title: ホイートストンブリッジ
tier: 100
board: BB
source: 自作
era: 古
---

# 1-7 ホイートストンブリッジ

抵抗 4 本を輪にして、対角に電源、もう一方の対角に検流計 (小さな電流を針で示す計器。0-4)
をつなぐと**ブリッジ**になる。左右の分圧比 (1-2) が同じになるまで片側の抵抗を調整すると、
検流計の電流がゼロになる (**平衡**)。このときの比の式から、未知の抵抗を精密に求められる。
検流計に電流が流れない所で比べるので、計器の内部抵抗が読みを狂わせない (0-4 の負荷効果が
起きない)。昔の抵抗測定の定番。

## 回路図

```circuit
title: 図1 ホイートストンブリッジ
parts:
  V1: vsource a1 e1 5
  G0: ground e1
  R1: resistor a3 c3 1k
  R3: resistor-var c3 e3 2k
  R2: resistor a7 c7 1k
  RX: resistor c7 e7 680
  GA: galvanometer c3 c7
wires:
  - a1 -- a3
  - a3 -- a7
  - e1 -- e3
  - e3 -- e7
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/07-wheatstone-bridge.svg)

図1 の `R1` = `R2` = 1kΩ (比を決める既知の 2 本)、`R3` は 0〜2 kΩ の可変抵抗 (図の値は最大値)、
`RX` = 680Ω は測りたい未知の抵抗 (ここでは正解を 680Ω として計算する)。
平衡条件は **R1/R3 = R2/RX**、R1 = R2 なので **R3 = RX のときに平衡**する。

- `R3` を 1kΩ に合わせた (まだ平衡していない) ときの左右の中点電圧:
  V<sub>A</sub> (R1-R3 の中点) = 5V × R3/(R1+R3) = 5×1k/2k = **2.5 V**、
  V<sub>B</sub> (R2-RX の中点) = 5V × RX/(R2+RX) = 5×680/1680 ≈ **2.02 V**
- 検流計の両端の電圧差: V<sub>A</sub> − V<sub>B</sub> ≈ **0.48 V** (不平衡、
  検流計の針が振れる)
- `R3` を **680Ω** まで下げると V<sub>A</sub> = 5×680/1680 ≈ 2.02V = V<sub>B</sub>
  となり、差は **0 V** (平衡、検流計の針がゼロに戻る)
- 平衡したときの `R3` の目盛りがそのまま `RX` の値 (計算値。R1 = R2 の
  比が 1:1 なので、目盛りをそのまま読める)

感度の良い検流計ほど、わずかな不平衡でも針が振れるので、より正確に
`R3` を追い込める。0-4 で見た検流計の性質がここでも生きる。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤いレール = +5 V、青いレール = GND
board: half
parts:
  R1: resistor b5 b9 1k
  R3: potentiometer/trimmer d9(1) d11(W) d13(2) 2k
  R2: resistor b20 b24 1k
  RX: resistor d24 d28 680
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
  - +t20 -- a20 red
  - a11 -- -t11 black
  - a28 -- -t28 black
  - SC.1+ -- a9 orange
  - SC.1- -- a24 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/07-wheatstone-bridge.svg)

直流のブリッジなので、オシロの波形の図は付けない。電源は Analog Discovery 3 (AD3) の
Supplies の +5 V (電流は約 5 mA で、各レール約 50 mA の範囲に収まる)。図2 では検流計の代わりに
**AD3 の Scope (1+ / 1−) を DC の電圧計として**2 つの中点の間に当て (テスターの DCV でもよい)、
差の電圧が 0 V になるまで `R3` を回す。Scope は 1 V/div から始め、0 V に近づいたら 10 mV/div まで上げる。平衡したら電源を外し、`R3` を板から抜いて、1 と W の間の抵抗を
テスターの Ω レンジで測る。その値が `RX` の値になる (多回転トリマには目盛りが無いため)。

- 左の腕: `R1` (1 kΩ) を **b5〜b9**、`R3` (2 kΩ の半固定抵抗) を
  **d9 (1)・d11 (W)・d13 (2)** に挿す。列 9 で `R1` と `R3` がつながり、
  ここが中点 A になる。`R3` は 1 と W の間を可変抵抗として使い、
  2 の足 (13 列) はどこにもつながない
- 右の腕: `R2` (1 kΩ) を **b20〜b24**、`RX` (680 Ω) を **d24〜d28** に挿す。
  列 24 が中点 B
- 赤の線は + だけ: `+t5 → a5`、`+t20 → a20` で `R1` `R2` の上端に 5 V を配る
- 黒の線は GND だけ: `a11 → -t11` (`R3` の W)、`a28 → -t28` (`RX` の下端)
- Scope の 1+ (橙) を **a9** (中点 A)、1− (灰) を **a24** (中点 B) に挿す。
  読みが V<sub>A</sub> − V<sub>B</sub> で、0 V なら平衡

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2 | 抵抗 (1/4 W、精度の良いもの) | 1 kΩ |
| R3 | 可変抵抗 (値の分かる箱、または多回転トリマ) | 0〜2 kΩ 程度 |
| RX | 抵抗 (測りたい未知の抵抗、ここでは正解 680Ω) | 680 Ω |
| GA | 検流計 (ブレッドボードでは AD3 の Scope を電圧計にして代用) | — |
| — | 電源 | 5 V (AD3 の Supplies の V+) |

## 見るべき値

| R3 の値 | 検流計の両端の電圧差 (計算値) | 状態 |
| --- | --- | --- |
| 1000 Ω | 約 0.48 V | 不平衡 (V<sub>A</sub> > V<sub>B</sub>、電流は A→B) |
| 800 Ω | 約 0.20 V | 不平衡 (まだ差がある) |
| 680 Ω | 0 V | 平衡 (検流計の針がゼロ) — RX = R3 = 680Ω と分かる |
| 600 Ω | 約 −0.15 V | 不平衡 (今度は逆向き、V<sub>B</sub> > V<sub>A</sub>) |

## 出典

自作。
