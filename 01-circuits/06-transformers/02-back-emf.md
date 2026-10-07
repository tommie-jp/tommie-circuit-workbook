---
book: circuits
chapter: 6
id: 6-2
title: コイルの逆起電力 — 切った瞬間に LED が光る、フライバックダイオード
tier: 50
source: 自作
board: BB
---

# 6-2 コイルの逆起電力 — 切った瞬間に LED が光る、フライバックダイオード

コイルは、流れている電流を保とうとする部品。電流を急に断つと、保とうとする働きが
電圧になって現れる。これを**逆起電力** (フライバック電圧ともいう) という。スイッチを開けた瞬間だけ LED を光らせて、
この電圧を目で見る。リレーやモータもコイルなので、トランジスタで入り切りするときはこの電圧から守る必要がある。
LED の代わりにダイオードを入れて逆起電力を逃がすのが、7-1 のリレー駆動で使う**フライバックダイオード**だ。

## 回路図

```circuit
title: 図1 コイルを切った瞬間に LED が光る (CH1 は L1 の上端の電圧)
parts:
  V1: battery 2,2 2,4 5
  S1: switch 2,2 4,2
  R1: resistor 4,2 7,2 180 i=I
  L1: inductor 7,2 7,4 100m
  D1: led 9,4 9,2
  M1: voltmeter 11,2 11,4 l=$\mathrm{CH1}$
  G1: ground 2,4
wires:
  - 7,2 -- 9,2 -- 11,2
  - 2,4 -- 7,4 -- 9,4 -- 11,4
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/circuit/02-back-emf.svg)

- D1 は、アノードを GND 側、カソードを L1 の上側に向けて、L1 と並列に入れる。
  ふだん電流が流れる向きとは逆向きだ
- S1 を閉じると、電源 (5 V) → R1 (180 Ω、電流を決める) → L1 (100 mH) →
  GND の道で一定の電流 I が流れる。LED (D1) にはこの間、逆向きの電圧が掛かるだけで、
  光らない
- S1 を開くと、L1 は流れていた電流を保とうとして、L1 の上側の電圧を
  一気に下げる (GND より低くなる)。これで D1 が順方向になり、L1 に残っていた
  電流が D1 を通って一瞬だけ流れ、LED が一瞬光る
- 電源は 5 V までにする。S1 を閉じた瞬間は L1 にまだ電流が流れないので、L1 の両端 (= D1 の両端) に
  電源の 5 V がそのまま逆向きに掛かる。LED が逆向きに耐えられる電圧 (逆耐圧) は普通 5 V ほどなので、
  これより高い電源では壊れる恐れがある

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (5 V は AD の V+、1+ を L1 の上端へ)
# 上の赤いレール = +5V、青いレール = GND
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery (Supplies V+ と Scope)
    pins: [V+, GND, 1+, 1-]
  S1: switch b3 b5
  R1: resistor b8 b12 180
  L1: inductor/axial b15 b20 100m
  D1: led d20(A) d15(K)
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- c15 orange
  - AD.1- -- -t10 black
  - +t3 -- a3 red
  - a5 -- a8 orange
  - a12 -- a15 yellow
  - a20 -- -t20 black
notes:
  - text: D1 は L1 と同じ 15・20 列 (別の行) に置き、コイルと並列にする
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/breadboard/02-back-emf.svg)

- 5 V は Analog Discovery の Supplies の V+ (WaveForms で 5 V にする) から上の + レールへ、GND は − レールへ入れる。
  回路の電流は約 24 mA で、Supplies の各レール 50 mA (USB 給電で 250 mW) に収まる。
  Scope の 1+ (橙) は L1 の上端の 15 列 (`c15`)、1− (黒) は − レール (`-t10`) へつなぐ
- 電源の + は 3 列から S1 (3・5 列) → R1 (8・12 列) → L1 (15・20 列) と線でつなぎ、20 列を − レールへ落とす
- D1 (LED) は L1 と同じ 15・20 列の別の行 (d 行) に置くだけで、同じ列の
  導通でコイルと並列につながる
- D1 はカソードが L1 の上端側 (15 列)、アノードが GND 側 (20 列)。図1 の向きと
  同じで、光るのはスイッチを開けた瞬間だけ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| S1 | スイッチ (押しボタンなど) | 1 回路 |
| R1 | 抵抗 (1/4 W) | 180 Ω |
| L1 | インダクタ (軸リード) | 100 mH (巻線抵抗 約 25 Ω) |
| D1 | LED (5 mm) | 赤、V<sub>F</sub> ≈ 2 V |
| — | 電源・計器 | Analog Discovery 3 の Supplies V+ = 5 V (電流 約 24 mA) と Scope (1+ = L1 の上端、1− = GND) |

## 計器の設定

計器は Analog Discovery 3 の Scope (1+ = L1 の上端、1− = GND)。LED が光るのは約 1 ms の一瞬なので、波形でないと電圧が見えない。
トリガは CH1 の立ち下がり (0 V) に合わせ、WaveForms の Single (1 回だけ取り込む) にして待ち、S1 を開く。時間軸は 500 µs/div、縦軸は 1 V/div。

```scope
title: 図3 S1 を開いた瞬間の L1 の上端の電圧 (近似の形)
time: 500us/div
trigger: ch1 falling 0V
ch1: {wave: "= 0.61V * (1 - step(t)) - 2V * step(t) * (1 - step(t - 1.06ms))", range: 1V/div, position: 0div}
cursors: [-500us, 500us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/06-transformers/scope/02-back-emf.svg)

図3 は下の「見るべき値」の計算値を使った近似で、実測ではない。S1 を開く前は、L1 の上端に巻線抵抗ぶんの電圧
(24.4 mA × 25 Ω ≈ 0.61 V) が出ている。開いた瞬間に上端は LED の順方向電圧 V<sub>F</sub> = 2 V の逆向き (−2 V) に落ち、
L1 の電流が尽きる約 1.06 ms の間そのまま。L1 の電流は時間とともに減るので、実物の電圧は −2 V からゆっくり 0 V に戻るように見える。
カーソルは S1 を開く前 (−0.5 ms、0.61 V) と開いた後 (+0.5 ms、−2.00 V) に置いた。−2 V が続く約 1.06 ms が LED の光る時間で、下の表の「1 ms ほど」と合う
(1.06 ms は L/R<sub>L</sub> × ln(1 + I R<sub>L</sub> / V<sub>F</sub>) = 0.1 H / 25 Ω × ln(1 + 0.61 / 2) の値)。
S1 の接点が跳ねる (チャタリング) と、波形が何度か現れることがある。

## 見るべき値

表の値は計算値。コイル (100 mH) の巻線抵抗は 25 Ω とする (テスターの抵抗レンジで実測した値に置き換えて、計算し直すとよい)。
LED の順方向電圧 V<sub>F</sub> は 2 V とした。電流と電圧は S1 を閉じたまま、テスターで測る。
LED が光るのは一瞬なので、明るい所では見逃しやすい。部屋を暗くして、S1 を開く瞬間の LED を見る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| S1 を閉じている間の定常電流 | 24.4 mA (= 5 V / (180 + 25) Ω) | R1 とコイルの抵抗で決まる普通のオームの法則 |
| S1 を閉じている間の D1 の電圧 | 約 −0.6 V (= −24.4 mA × 25 Ω。光らない) | 電流が一定になると、L1 の両端には巻線抵抗ぶんの電圧しか残らない。D1 には逆向きなので電流はほぼ流れない |
| S1 を開けた瞬間に L1 に蓄えられているエネルギー | 約 30 µJ (= 0.5 × 0.1 H × 0.0244² A²) | このエネルギーが D1 で光と熱になって消える |
| LED が光っている時間 (目安) | 1 ms ほど (= L × I / V<sub>F</sub> = 0.1 × 0.0244 / 2 = 1.22 ms。巻線抵抗ぶんを入れると図3 の 1.06 ms) | 人の目にはごく短い点滅として見える。コイルを大きくするか電流を増やすと長く光る |

## 出典

自作。
