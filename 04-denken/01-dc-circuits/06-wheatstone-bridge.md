---
book: denken
chapter: 1
id: 1-6
title: ホイートストンブリッジの平衡条件
tier: 50
source: 自作
board: BB
---

# 1-6 ホイートストンブリッジの平衡条件

4 本の抵抗をひし形につなぎ、対角線に検流計を入れる。**検流計の電流が
ちょうど 0 になるように 1 本を調整すると、4 本の抵抗の比だけから
未知の抵抗が分かる**。電源の電圧にも検流計の感度にも左右されない、
精度の良い測り方。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| R1 / R2 = R3 / Rx (平衡条件) | 検流計の電流が 0 になる条件。対辺の比が等しい |
| R3 = Rx × R1 / R2 | R1 = R2 のとき、可変抵抗 R3 の目盛りがそのまま未知抵抗 Rx |

## 回路図

```circuit
title: 図1 ホイートストンブリッジ
style:
  standard: jis
parts:
  R1: resistor c9 e5 1k
  R2: resistor e5 g9 1k
  R3: resistor-var c9 e13 5k
  Rx: resistor e13 g9 3300
  GA1: galvanometer e5 e13
  E1: battery c1 g1 5
  G1: ground g9
wires:
  - c9 -| c1
  - g9 -| g1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/circuit/06-wheatstone-bridge.svg)

- R1・R2 (ともに 1 kΩ) が比較の基準の枝。R3 は 0〜5 kΩ の可変抵抗、
  Rx は値を知りたい抵抗 (ここでは 3.3 kΩ の実物を入れて確かめる)
- E1 は 5 V の電源 (USB の 5 V か AD の Supplies。単 3 電池 3 本の 4.5 V でも可)
- 検流計 GA1 が対角線 (節点 B・D の間)。R3 を回して GA1 の針が 0 になる点を探す

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: full
parts:
  R1: resistor c5 c10 1k
  R2: resistor d10 d15 1k
  Rx: resistor b33 b38 3300
  R3: potentiometer/trimmer d30(1) d33(W) d36(2) 5k
  GA:
    type: device
    at: bottom
    label: "検流計"
    pins: ["+", "-"]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+]
wires:
  - AD.V+ -- a5 red
  - AD.GND -- -t8 black
  - b5 -- b30 red
  - a15 -- -t15 black
  - a38 -- -t38 black
  - GA.+ -- e10 orange
  - GA.- -- e33 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/01-dc-circuits/breadboard/06-wheatstone-bridge.svg)

- R1 (c 行) と R2 (d 行) が 10 列でつながり、節点 B を作る。R3 (半固定抵抗器) が節点 A
  (30 列、電源の + 側から b 行の赤い線で渡る) から分かれて節点 D (R3 のワイパー) を
  作り、Rx が節点 D から GND (38 列) へつながる
- GA (検流計) はブレッドボードの外の機器として描き、節点 B (10 列) と節点 D (R3 のワイパー、
  33 列) を直接つなぐ。ここが対角線
- R3 は 3 ピンの半固定抵抗器を**片方の端 + ワイパーの 2 本だけ**使う
  (もう片方の端は使わない。ERC が未使用のピンを言うが、これは意図した配線)
- 63 列の full サイズを使う (4 本の枝と検流計を並べるため半分のブレッドボードでは狭い)

## 計器の設定

この題の計器は Analog Discovery 3 (AD3) の Supplies (電源) とテスター。電流は 1 辺あたり 1.5 mA 前後で、各レール約 50 mA (USB 給電で 250 mW) とブレッドボードの 1 穴 200 mA に収まる。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V。Enable してから Master Enable を入れる |
| テスター | 直流電流レンジ (最小レンジ、µA まで読めるとよい)。GA の位置で読む |
| R3 | 0〜5 kΩ の半固定抵抗器。目盛りかテスターの抵抗レンジで読む |

この題はオシロの図を付けない — 直流の量だけを見る (テスターの読みで足りる)。

## 見るべき値

計算値 (E1 = 5 V、R1 = R2 = 1 kΩ、Rx = 3.3 kΩ)。節点の電圧は検流計を外したときの値。

| R3 の値 | 検流計の電流 | 節点 B の電圧 | 節点 D の電圧 |
| --- | --- | --- | --- |
| 2.0 kΩ | 0 でない (振れる) | 2.50 V | 3.11 V |
| 3.3 kΩ (平衡) | **0** | 2.50 V | 2.50 V |
| 4.5 kΩ | 0 でない (逆に振れる) | 2.50 V | 2.12 V |

分かること:

- **平衡したときの R3 の目盛りがそのまま Rx (3.3 kΩ) になる。** R1 = R2 なので
  R3 = Rx × R1 / R2 = Rx
- 平衡が取れている限り、電源の電圧 (5 V) を変えても検流計は 0 のまま
  (両方の節点電圧が電源の電圧に比例して動くだけなので、差は常に 0)
- 交流ブリッジ (7-8) も同じ考え方で、抵抗の代わりにコンデンサやコイルの
  インピーダンスを比べる

## 出典

自作。
