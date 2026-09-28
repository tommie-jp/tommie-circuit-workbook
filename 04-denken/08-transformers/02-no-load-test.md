---
book: denken
chapter: 8
id: 8-2
title: 無負荷試験 — 励磁電流と鉄損
tier: 50
source: 自作
board: BB
---

# 8-2 無負荷試験 — 励磁電流と鉄損

2 次を開放したまま 1 次に電圧をかけると、鉄心を磁化するための**励磁電流**だけが流れる。
8-1 と同じ小型トランス (10 kΩ:8 Ω) で、この電流の大きさと位相を測る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I0 = V1 × Y0 | 励磁電流。Y0 は励磁アドミタンス (鉄損分 + 磁化分) |
| cos φ0 = G0 / \|Y0\| | 励磁電流の力率。鉄損の分だけ電流が電圧より少し遅れる |
| P0 = V1 × I0 × cos φ0 | 無負荷損 (≒ 鉄損)。銅損は I0 が小さいので無視できる |

励磁電流はほとんどが磁化のための無効分で、鉄損を表す有効分はごく一部
(この実験の設定では cos φ0 ≒ 0.10、位相差 φ0 ≒ 84°) しかない。

## 回路図

```circuit
title: 図1 無負荷試験の回路 (2 次は開放)
style:
  standard: jis
  pitch: 1.8
parts:
  W1: sine c1 e1 l=$\mathrm{W1}$
  Rs1: resistor c1 c3 4.7k i=I0
  M2: voltmeter b1 b3 l=$\mathrm{CH2}$
  M1: voltmeter c4f0 d4f0 l=$\mathrm{CH1}$
  T1: transformer d5 10kto8
  G1: ground e1
wires:
  - b1 -- c1
  - b3 -- c3
  - c3 -- c4 -- c4f0
  - c4f0 -| T1.A1
  - T1.A2 -| d4f0
  - d4f0 -- e4
  - e1 -- e4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/02-no-load-test-1.svg)

- 2 次 (T1.B1 / T1.B2) は**わざと開放のまま**にする。8-1・8-3 と同じ 1 次側の
  配線に、2 次だけ何もつながない形。ERC が T1.B1 / T1.B2 の未接続を言うが、
  無負荷試験の条件そのものなので直さない
- Rs1 (4.7 kΩ) は励磁電流 I0 を読むシャント。励磁電流は 8-1 で測った負荷時の
  1 次電流よりずっと小さいので、大きめの抵抗にして読み取れる電圧に変える
- M1 (CH1) は 1 次巻線の両端 (V1)、M2 (CH2) は Rs1 の両端 (I0)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (2 次は開放)
board: half
parts:
  Rs1: resistor e3 e7 4700
  T1: transformer c15 c18 f15 f18 10kto8
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t5 black
  - AD.1+ -- a7 orange
  - AD.1- -- -t9 black
  - AD.2+ -- a11 blue
  - AD.2- -- a15 white
  - c3 -- c11 yellow
  - b7 -- b15 orange
  - a18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/breadboard/02-no-load-test.svg)

- T1 の 2 次リード (下ブロックの 15 列・18 列) には**何も挿さない**。8-1 の図から
  RL を抜いただけの形
- 配線は 8-1 と同じ。Rs1 の値だけ 100 Ω → 4.7 kΩ に変える

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 2 V |
| Scope | CH1 = 1 次巻線の両端 (V1)。CH2 = Rs1 の両端 (差動、I0 = 読み ÷ 4.7 kΩ) |
| Measure | CH2 の CH1 に対する Phase (φ0)。Average を 16 回以上にして雑音を減らす |

CH2 は CH1 の約 1/40 しかないので、CH2 だけ 20 mV/div に上げてある。

```scope
title: 図3 励磁電流の分 (CH2、20 mV/div) は V1 (CH1、1 V/div) より 84° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2V, range: 1V/div}
ch2: {wave: sine 1kHz 47.2mV phase -84deg, range: 20mV/div}
measure: [vmax, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/scope/02-no-load-test.svg)

### オシロスコープと発振器

汎用の計器での読み替えは[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。

AD の CH2 は Rs1 の両端を差動で挟んでいる。Rs1 の電圧 (47 mV) は振れ (2 V) の 2 % ほどしかないので、
2 本の先端で引く方法は使えない。8-1 と同じく **Rs1 を 1 次巻線の GND 側へ移し**、CH2 の 1 本で
直に読む (図4)。2 次は開放のままで、どこにもクリップを当てない (1 次の GND だけが大地につながる)。

```circuit
title: 図4 汎用オシロでの測り方
style:
  standard: jis
parts:
  FG: sine c1 g1 l=$\mathrm{FG}$
  M1: voltmeter c3 g3 l=$\mathrm{CH1}$
  T1: transformer d7 10kto8
  M2: voltmeter e4 g4 l=$\mathrm{CH2}$
  Rs1: resistor e6 g6 4.7k i=I0
  G1: ground g1
wires:
  - c1 -- c3 -- c6 |- T1.A1
  - e6 |- T1.A2
  - e4 -- e6
  - g1 -- g3 -- g4 -- g6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/08-transformers/circuit/02-no-load-test-2.svg)

- ブレッドボードは 8-1 と同じ組み替え: Rs1 (e3–e7) を抜いて 3 列と 7 列を線でつなぎ、
  18 列から − レールへの黒い線を Rs1 (4.7 kΩ) に替える
- FG は High-Z、Sine、1 kHz、振幅 2 V (Vpp で入れる機種なら 4 Vpp)。負荷は数百 kΩ なので、FG の 50 Ω は効かない
- CH1 の先端を 3 列 (FG の出力)、CH2 の先端を 18 列。グランドクリップはどちらも − レール。
  CH2 は 20 mV/div (振れは約 94 mVpp で、10 mV/div では縦 8 div を超える)、Average を 16 回以上
- 位相は Measure の Phase (CH1 に対する CH2)。掛け算の Math は要らない。P0 は V1・I0・cos φ0 から計算する

CH1 は V1 に Rs1 の電圧が乗った値で、振幅はほぼ同じだが位相が少しずれる。CH1 に対する
CH2 の遅れは約 83° (計算値、V1 に対しては約 84°)。1° の差を気にするなら、V1 を Math の
CH1 − CH2 で作り、それに対する位相を読む (Math の位相を測れない機種もある)。

## 見るべき値

計算値。励磁電流はごく小さいので、実測は AD のノイズフロアに近く、桁や位相の
向きを確かめる程度になる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (V1、振幅) | 2.00 V | Wavegen の設定どおり |
| CH2 (Rs1 の両端、振幅) | 47.2 mV | I0 = 47.2 mV ÷ 4.7 kΩ ≒ 10.0 µA |
| φ0 (CH1 に対する CH2 の遅れ) | 約 84° | ほぼ 90° 遅れ = ほとんど無効電流 (磁化分) |
| P0 (計算値、V1×I0×cos φ0) | 約 1.0 µW | 鉄損に当たる有効分。桁がとても小さい |
| 8-1 の負荷時 1 次電流との比 (I0 / I1) | 約 0.05 | 励磁電流は負荷時電流の 5 % ほど。良いトランスほど小さい |

実際の鉄損は電圧の 2 乗にほぼ比例するので、定格電圧で測る本来の無負荷試験では
mW 〜 W のオーダーになる。ここでは AD の電流制限に収めるため電圧を落として
いるぶん、P0 は測れないほど小さい。**主に確かめるのは、励磁電流が負荷時より
ずっと小さく、ほぼ 90° 遅れる (無効分が主) という性質**である。

## 出典

自作。
