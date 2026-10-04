---
book: circuits
chapter: 2
id: 2-8
title: コレクタ帰還バイアスと分圧バイアスの比較
tier: 100
board: BB
source: 自作
---

# 2-8 コレクタ帰還バイアスと分圧バイアスの比較

2-3 は `R1`・`R2` の分圧でベースを固定する**分圧バイアス**だった (2-3 の題名では自己バイアスと呼んだ形)。
ここではもう 1 つの定番、**コレクタ帰還バイアス** (ベース抵抗をコレクタから引く)
と並べて、hFE が個体ごとに違ってもコレクタ電流がどれだけブレるかを比べる。
手持ちのトランジスタを何本か差し替え、コレクタの電圧がどれだけ動くかをテスターで確かめる。

## 回路図

コレクタ帰還バイアス (抵抗 2 本だけで組める、簡単だが hFE に弱い)。

```circuit
title: 図1 コレクタ帰還バイアス
parts:
  VCC: vcc b5 5V
  RC: resistor b5 d5 4.7k
  RB: resistor d3 f3 680k
  Q1: npn f5
  G1: ground g5
wires:
  - d3 -- d5 -- Q1.C
  - f3 -| Q1.B
  - Q1.E -- g5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/08-bias-comparison-1.svg)

分圧バイアス (2-3 と同じ形。抵抗 4 本要るが hFE に強い)。

```circuit
title: 図2 分圧バイアス (2-3 と同じ形)
parts:
  VCC: vcc b3 5V
  R1: resistor b3 d3 47k
  R2: resistor d3 f3 15k
  G1: ground f3
  RC: resistor b6 d6 4.7k
  Q1: npn e6
  RE: resistor f6 h6 1k
  G2: ground h6
wires:
  - b3 -- b6
  - d3 -| Q1.B
  - d6 -- Q1.C
  - Q1.E -- f6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/08-bias-comparison-2.svg)

どちらも `RC` = 4.7kΩ で揃え、2SC1815 の hFE の幅 (70〜700) を仮定して
コレクタ電流 I<sub>C</sub> を計算する。

**図1 (コレクタ帰還)**: ベース電流は `RB` (680kΩ) を通ってコレクタからベースへ流れる。
コレクタ電流が増えるとコレクタの電圧が下がり、ベース電流が減って増えすぎを抑える。
出力の変化を打ち消す向きに入力へ戻すことを**負帰還**と呼ぶ。
I<sub>C</sub> = hFE(5−0.7) / (RB + hFE×RC)。

| hFE | I<sub>C</sub> (計算値) | V<sub>C</sub> |
| --- | --- | --- |
| 70 | 0.30 mA | 3.60 V |
| 200 | 0.53 mA | 2.50 V |
| 700 | 0.76 mA | 1.44 V |

hFE が 70→700 (10倍) で I<sub>C</sub> は **約 2.5 倍**動く。

**図2 (分圧バイアス)**: `R1` = 47kΩ、`R2` = 15kΩ の分圧で `Q1` のベースを
ほぼ固定し、`RE` (1kΩ) がエミッタ電位を決める (2-3 と同じ考え方。R1 を
68kΩ にすると 5 V では Vth が 0.9V ほどまで下がり、Ve が 0.2V を切って
Vbe の近似誤差に埋もれてしまうので、47kΩ にして Vth を確保している)。

| hFE | I<sub>C</sub> (計算値) | V<sub>C</sub> |
| --- | --- | --- |
| 70 | 0.43 mA | 2.96 V |
| 200 | 0.48 mA | 2.74 V |
| 700 | 0.50 mA | 2.65 V |

同じ hFE の幅 (70→700) でも、I<sub>C</sub> の動きは **約 1.16 倍**にしか
広がらない。**分圧バイアスは `RE` の負帰還と、ベースを電流でなく電圧で
固定する分圧のおかげで、hFE のばらつきに強い** — 部品を 2 本余分に使う
だけの価値がある。

## 実体配線図

2 つの回路を別々の板に組む (同じ板で差し替えてもよい)。電源は Analog Discovery 3 (AD3) の
Supplies の +5 V で、どちらも電流は 1 mA 未満なので各レール約 50 mA の範囲に収まり、
ブレッドボードの 1 穴 200 mA の範囲にも収まる。電圧は AD3 の Scope の 1+ / 2+ を電圧計として当てて読む
(テスターの DCV でもよい)。この題は直流の動作点だけを見るので、オシロの波形の図は付けない。

```breadboard
title: 図3 コレクタ帰還バイアスを組む (図1。Scope 1+ をコレクタへ)
# 上の赤いレール = +5V、青いレール = GND
board: half
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: top
    label: AD3 Scope (DC 電圧計)
    pins: [1+, 1-]
  RB: resistor a2 a6 680k
  RC: resistor b9 b6 4.7k
  Q1: transistor e5(B) e6(C) e7(E) 2SC1815
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t9 -- a9 red
  - d5 -- d2 yellow
  - a7 -- -t7 black
  - SC.1+ -- c6 orange
  - SC.1- -- -t12 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/08-bias-comparison-1.svg)

- Q1 を e5 (B)・e6 (C)・e7 (E) に挿す。2SC1815 は平らな面を見て左から E・C・B (2-1 で見た)。図は B・C・E の順に挿すので、平らな面を奥に向けて挿す
- RC (4.7 kΩ) は b9 と b6 (コレクタの列) の間。+5 V は赤の線 `+t9 → a9` で RC の上端へ
- RB (680 kΩ) はコレクタの列 6 (`a6`) から列 2 (`a2`) へ。列 2 から黄の線 `d2 → d5` でベースの列 5 へ戻す。これで RB がコレクタとベースをつなぐ
- エミッタ (列 7) は黒の線 `a7 → -t7` で GND へ
- Scope の 1+ (橙) をコレクタの列 6 (`c6`)、1− (黒) を GND のレールへ

```breadboard
title: 図4 分圧バイアスを組む (図2。Scope 1+ をコレクタ、2+ をベースへ)
# 上の赤いレール = +5V、青いレール = GND
board: half
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: top
    label: AD3 Scope (DC 電圧計)
    pins: [1+, 2+, 1-, 2-]
  R1: resistor a19 +t19 47k
  R2: resistor c20 c16 15k
  RC: resistor b21 b24 4.7k
  Q1: transistor e20(B) e21(C) e22(E) 2SC1815
  RE: resistor a22 -t22 1k
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - b19 -- b20 yellow
  - +t24 -- a24 red
  - a16 -- -t16 black
  - SC.1+ -- a21 orange
  - SC.2+ -- a20 green
  - SC.1- -- -t27 black
  - SC.2- -- -t28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/08-bias-comparison-2.svg)

- Q1 を e20 (B)・e21 (C)・e22 (E) に挿す。R1 (47 kΩ) は +5 V のレールから列 19 (`a19`) へ立てて挿し、黄の線 `b19 → b20` でベースの列 20 へつなぐ。R2 (15 kΩ) はベースの列 20 から列 16 へ渡し、黒の線 `a16 → -t16` で GND へ落とす
- RC (4.7 kΩ) はコレクタの列 21 (b21) と列 24 (b24) の間。+5 V は赤の線 `+t24 → a24`
- RE (1 kΩ) はエミッタの列 22 の `a22` から GND のレールへ立てて挿す
- Scope の 1+ (橙) をコレクタ (`a21`)、2+ (緑) をベース (`a20`) へ。1−・2− (黒) は GND のレールへ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RC (共通) | 抵抗 (1/4 W) | 4.7 kΩ |
| RB (図1) | 抵抗 (1/4 W) | 680 kΩ |
| R1 (図2) | 抵抗 (1/4 W) | 47 kΩ |
| R2 (図2) | 抵抗 (1/4 W) | 15 kΩ |
| RE (図2) | 抵抗 (1/4 W) | 1 kΩ |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+ / 2+ (直流の電圧を読む)。hFE はテスターか 0-5 の hFE チェッカー |

## 見るべき値

図1 と図2 を別々に組み、テスターの直流電圧レンジで Q1 のコレクタ (と図2 のベース) を GND から測る。
自分の Q1 の hFE は、0-5 の hFE チェッカーで先に測っておくと、下の表の計算値と比べられる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 図1、Q1 のコレクタ電圧 (自分の Q1 の hFE で) | 1.4〜3.6 V 程度 (個体差が大きい、計算値の範囲) | コレクタ帰還バイアスは hFE が高い個体だと飽和に近づく |
| 図2、Q1 のコレクタ電圧 (自分の Q1 の hFE で) | 約 2.6〜3.0 V (個体差が小さい、計算値の範囲) | 分圧バイアスは動作点が安定している |
| 図2、ベース電圧 | 約 1.1〜1.2 V (hFE によらずほぼ一定) | 分圧電流がベース電流よりずっと大きいため |
| 手持ちの Q1 を差し替えたとき | 図1 は V<sub>C</sub> が大きく動き、図2 はあまり動かない | 実測でバイアス方式の違いが体感できる |

## 出典

自作。
