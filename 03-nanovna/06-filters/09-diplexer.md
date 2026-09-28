---
book: nanovna
chapter: 6
id: 6-9
title: ダイプレクサ
tier: 100
source: 自作
board: PF
device: H4
---

# 6-9 ダイプレクサ

1 本の線に乗った信号を、周波数で 2 つの出口に振り分けるのが**ダイプレクサ**。
入口の 1 点からローパス (LPF) とハイパス (HPF) を枝分かれさせる。
ここでは分かれ目 (クロスオーバー) を 50 MHz にして、短波 (〜30 MHz) を LPF の
出口へ、FM 放送や 144 MHz を HPF の出口へ分ける。

ただの LPF と HPF を並べただけでは、互いの入口のインピーダンスが邪魔をして
分かれ目で整合が崩れる。**2 つを組にしたときに入口が 50 Ω になるよう
設計した (相補形の) 組**を作り、1 つずつ測ったときと 2 つ組んだときの違いを見る。

## この実験で確かめる式

片側だけ終端した 3 次バターワースの g 値 (入口の側から) g1 = 1.5、g2 = 1.333、
g3 = 0.5 を使う。LPF と HPF の入口の素子が**どちらも直列**になる並べ方
(LPF は L-C-L、HPF は C-L-C) にすると、クロスオーバーで 2 つの入口の
インピーダンスが足し合って 50 Ω になる。f_c = 50 MHz、R = 50 Ω で:

| 枝 | 入口の直列 (g1) | 真ん中の並列 (g2) | 出口の直列 (g3) |
| --- | --- | --- | --- |
| LPF: L = gR / (2πf_c)、C = g / (2πf_c R) | L1 = 238.7 nH → **220 nH** (E12) | C2 = 84.9 pF → **82 pF** (E12) | L3 = 79.6 nH → **82 nH** (E12) |
| HPF: C = 1 / (2πf_c R g)、L = R / (2πf_c g) | C1 = 42.4 pF → **43 pF** (E24) | L2 = 119.4 nH → **120 nH** (E12) | C3 = 127.3 pF → **130 pF** (E24) |

## 回路図

```circuit
title: 図1 ダイプレクサ (上が LPF の枝、下が HPF の枝)
parts:
  J1: sma d2 mirror CH0
  L1: inductor b4 b6 220n
  C2: capacitor b7 d7 82p
  L3: inductor b8 b10 82n
  J2: sma b12 CH1
  C1: capacitor f4 f6 43p
  L2: inductor f7 h7 120n
  C3: capacitor f8 f10 130p
  J3: sma f12 Load
  G1: ground e2
  G2: ground d7
  G3: ground c12
  G4: ground h7
  G5: ground g12
wires:
  - J1.1 -- d3
  - d3 -- b3 -- b4
  - d3 -- f3 -- f4
  - b6 -- b7 -- b8
  - b10 -- J2.1
  - f6 -- f7 -- f8
  - f10 -- J3.1
  - J1.2 -- e2
  - J2.2 -- c12
  - J3.2 -- g12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/09-diplexer.svg)

- 図は LPF の出口を CH1 につなぎ、HPF の出口を校正キットの Load (50 Ω) で
  終端した測り方。HPF の側を測るときは、CH1 と Load を入れ替える
- 1 つずつ測るときは、測らない側の入口の素子 (L1 か C1) を片足だけ外しておく

## 実体配線図

部品面から見た図。3 つの SMA は端面に付ける (J1 は左、J2・J3 は右)。

```perfboard
board:
  size: 20x14
title: 図2 perfboard に組む (e 行 LPF・k 行 HPF)
parts:
  J1: sma/female-edge e1 f0
  L1: inductor e4 e8 220n
  C2: capacitor e9 c9 82p
  L3: inductor e10 e14 82n
  J2: sma/female-edge e20 f21
  C1: capacitor k4 k6 43p
  L2: inductor k7 m7 120n
  C3: capacitor k8 k10 130p
  J3: sma/female-edge k20 l21
wires:
  - e1 -- e3
  - e3 -- e4
  - e8 -- e9
  - e9 -- e10
  - e14 -- e20
  - e3 -- k3
  - k3 -- k4
  - k6 -- k7
  - k7 -- k8
  - k10 -- k20
  - d0 -- d2 black
  - d2 -- c2 black
  - c2 -- c9 black
  - c9 -- c19 black
  - d21 -- d19 black
  - d19 -- c19 black
  - f0 -- f2 black
  - f2 -- m2 black
  - m2 -- m7 black
  - m7 -- m19 black
  - l21 -- l19 black
  - l19 -- m19 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/09-diplexer.svg)

- GND は c 行 (LPF の上) と m 行 (HPF の下) の 2 本の筋。2 本は左の J1 の凹の
  上下の先端でつながり、右では c 行が J2 の凹に、m 行が J3 の凹に落ちる。信号の線と交差しないように、
  LPF の並列の C2 は上へ、HPF の並列の L2 は下へ落とした
- 分かれ目 (e3) から LPF と HPF の入口の素子までは短く。ここが長いと、
  2 つの枝の足し合わせがずれる

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜200 MHz |
| 点数 | 199 (約 1 MHz おき) |
| 校正 | SOLT (Thru はケーブル 2 本を直結) |
| 表示 | S21 と S11 の Log Mag |

vna フェンスの模型は部品を 1 列に縦続する形しか書けず、枝分かれした
ダイプレクサ全体は描けない。そこで図は**それぞれの枝を 1 つずつ測ったときの
見えるはずの画面**にし、2 つを組んだときの値は見るべき値の表に計算で書く。
2 枚とも掃引とマーカー (30・50・100 MHz) を同じにする。LPF の枝だけ。

```vna
device: h4
sweep: 1M-200M 199
title: 図3 LPF の枝だけ — 50 MHz で −1.26 dB、S11 は −6 dB (単独では整合しない)
dut:
  - series L 220n
  - shunt C 82p
  - series L 82n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 30M
  - 50M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/09-diplexer-1.svg)

HPF の枝だけ。

```vna
device: h4
sweep: 1M-200M 199
title: 図4 HPF の枝だけ — 50 MHz で −1.63 dB、S11 は −5 dB
dut:
  - series C 43p
  - shunt L 120n
  - series C 130p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 30M
  - 50M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/09-diplexer-2.svg)

## 見るべき値

計算値 (無損失として)。「1 つずつ」は図3・図4 と同じ模型の値 (30・50・100 MHz はマーカーの読み値)、「組んだとき」は
測らない側の出口を 50 Ω で終端した値 (手で計算した)。

| 周波数 | LPF の S21 (1 つずつ → 組んだとき) | HPF の S21 (1 つずつ → 組んだとき) | 入口の S11 (組んだとき) |
| --- | --- | --- | --- |
| 10 MHz | −0.02 → −0.00 dB | −35.67 → −41.61 dB | −42.4 dB |
| 30 MHz | −0.20 → −0.21 dB | −8.56 → −13.42 dB | −27.8 dB |
| 50 MHz | −1.26 → **−2.59 dB** | −1.63 → **−3.52 dB** | −23.1 dB |
| 100 MHz | −11.86 → −17.05 dB | −0.16 → −0.09 dB | −32.1 dB |
| 150 MHz | −21.98 → −27.73 dB | −0.06 → −0.01 dB | −37.0 dB |

- 1 つずつ測ると、どちらの枝も **50 MHz で入口の S11 が −5〜−6 dB** と整合していない
  (片側だけ終端する設計なので、単独では 50 Ω にならない)
- 2 つを組むと、**入口の S11 は 1〜200 MHz のどこでも −23 dB 以下**になる。
  50 MHz では電力がほぼ半分ずつ (−2.6 dB と −3.5 dB) 2 つの出口に分かれる。
  理想の値 (丸める前) なら両方 −3.01 dB。E12/E24 に丸めたので少しずれる
- 組むと阻止側の減衰も深くなる (30 MHz の HPF は −8.6 → −13.4 dB)。
  もう片方の枝がその周波数の電力を引き受けるから

分かること:

- **ダイプレクサは 2 つのフィルタの組で 1 つの回路**。片方だけ測って
  「整合していない」と判断しない。組んで入口の S11 を見る
- 出口の片方を開放のままにすると、その枝の入口のインピーダンスが変わって
  もう片方の特性が崩れる。**使わない出口も 50 Ω で終端**して測る
- 同じ考え方で、送信機の高調波をフィルタで反射せずに吸収させる
  (HPF の側を 50 Ω の抵抗で終える) 回路が作れる

## 出典

自作。片側終端のバターワースの g 値は標準的なフィルタ設計表による。
