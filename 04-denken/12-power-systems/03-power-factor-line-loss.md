---
book: denken
chapter: 12
id: 12-3
title: 力率と送電損失 — 同じ電力を運ぶ電流が力率で変わる
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 12-3 力率と送電損失 — 同じ電力を運ぶ電流が力率で変わる

受電端の電圧 V と、負荷が使う有効電力 P が同じでも、負荷の力率 cos θ が低いと線路の電流は
I = P / (V cos θ) に増え、線路の損失 I²r は **1 / cos²θ 倍**になる。電力会社が需要家に力率の改善を
求める理由がこれ。3-7 では力率を改善して電流を減らした。ここでは逆に、**有効電力を変えずに
力率だけを下げ**、線路の電流と損失が増えるのを測る。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| P = V I cos θ (実効値) | 有効電力。V と P が同じなら、I は cos θ に反比例する |
| I = P / (V cos θ) | 同じ電力を運ぶ線電流 |
| p = I² r | 線路の損失。同じ P と V なら 1 / cos²θ に比例する |
| cos θ = X / √(R² + X²) | 抵抗 R とリアクタンス X を並列にした負荷の力率 (X = 1 / ωC) |

## 回路図

```circuit
title: 図1 線路 Rs と、力率を変えられる負荷
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c4 10 i=I
  M2: voltmeter a1 a4 l=$\mathrm{CH2}$
  M1: voltmeter c6 g6 l=$\mathrm{CH1}$
  RL: resistor c8 g8 100
  S1: switch c10 e10
  C1: capacitor e10 g10 1.5u i=IC
  G1: ground g6
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c6 -- c8 -- c10
  - g1 -- g6 -- g8 -- g10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/circuit/03-power-factor-line-loss-1.svg)

- W1 は AD の波形発生器。1 kHz。Rs (10 Ω) が**線路の抵抗**で、同時に線電流 I を測るシャント。
  CH2 は Rs の両端 (差動入力) で、読みの 1/10 が I (1 mV = 0.1 mA)
- RL (100 Ω) が有効電力を使う負荷。受電端の電圧 (CH1) が同じなら、RL の電力は P = V² / RL で決まる
- S1 を閉じると C1 (1.5 µF、X = 106 Ω) が RL に**並列**に入る。C1 は有効電力を使わないので、
  P は変わらず、力率だけが 1 から 0.73 に下がる
- 実際の負荷 (モータなど) は遅れ力率だが、損失の無いコンデンサで模した進み力率でも、線電流と線路の損失は
  同じ式に従う (コイルは巻線抵抗が有効電力を使い、P が変わってしまう)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rs: resistor c5 c10 10
  RL: resistor d10 d15 100
  S1: switch g10 g13
  C1: capacitor/film h13 h17 1.5u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2+, 1+, 2-, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- b5 yellow [h-10]
  - AD.2+ -- a5 blue
  - AD.1+ -- b10 orange [h-10]
  - AD.2- -- a10 white
  - AD.1- -- -t12 black
  - a15 -- -t15 black
  - e10 -- f10 green
  - j17 -- -b17 black
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/breadboard/03-power-factor-line-loss.svg)

- 10 列が受電端。Rs・RL・CH1 (1+)・CH2 (2−) と、下の段へ渡る緑の線が集まる
- CH2 の 2+ と 2− を Rs の両端 (5 列と 10 列) に挿す。**2− を GND につながない** (受電端が GND に落ちる)
- RL (10〜15 列) の 15 列は黒い線で上の青いレール (GND) へ。S1 (10〜13 列) を挿すと C1 (13〜17 列) が
  入り、17 列から下の青いレールへ戻る。28 列の黒い線で上下の青いレールをつなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Offset 0 V。Amplitude は **CH1 (受電端) の振幅が 0.500 V になるよう**合わせる (S1 を開いて 0.550 V、閉じて 0.552 V) |
| Scope | CH1 = 受電端の電圧 v (200 mV/div)、CH2 = Rs の電圧 (= 10 Ω × i、20 mV/div)。Average を 16 回 |
| Math | M1 = C1 × C2 / 10 (瞬時電力 p、単位 W)。Measure で M1 の Average が負荷の有効電力 P。CH1 は受電端の電圧、CH2 ÷ 10 は負荷へ流れ込む電流なので、線路の損失は入らない |
| Measure | CH1 と CH2 の RMS、CH1 に対する CH2 の Phase (θ。cos θ が力率) |

受電端の電圧を 0.500 V にそろえるのは、「同じ電圧で同じ電力を運ぶ」比べ方にするため。そろえ直す
W1 の差は 0.4 % しかない。線路の電圧降下 (I r) は受電端の電圧と位相がずれるので、電流が 1.4 倍に
なっても送電端の電圧はほとんど変わらない。

**電流の上限**: 線電流は最大で 6.9 mA。この本の目安 10 mA (0-1) に収まる。

```scope
title: 図3 S1 を開く (力率 1) — 線電流 (CH2) 5.0 mA、P は Math の Avg で 1.25 mW
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.5V, range: 200mV/div, position: 1div}
ch2: {wave: sine 1kHz 50mV, range: 20mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 1mW/div, position: -2div}
measure: [vmax, rms, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/scope/03-power-factor-line-loss-1.svg)

```scope
title: 図4 S1 を閉じる (力率 0.73) — 線電流 (CH2) は 6.9 mA に増え、P は同じ
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.5V, range: 200mV/div, position: 1div}
ch2: {wave: sine 1kHz 68.7mV phase 43.3deg, range: 20mV/div}
math: {expr: ch1 * ch2 / 10, unit: W, range: 1mW/div, position: -2div}
measure: [vmax, rms, avg, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/scope/03-power-factor-line-loss-2.svg)

### オシロスコープと発振器

AD の CH2 は Rs の両端を差動で挟む (2− が 10 列)。汎用オシロのグランドクリップは大地につながって
いるので、10 列には当てられない ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。Rs の電圧は 50〜69 mV で、
受電端 (0.5 V) との差を 8 bit で引くと分解能に埋もれる。そこで 3-7 と同じく **Rs を戻りの線
(GND 側) へ移す** (図5)。線路の抵抗は行きと帰りのどちらにあっても直列なので、電流と損失は変わらない。
試験の図とは位置が変わる。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 i1 l=$\mathrm{FG}$
  M1: voltmeter c3 i3 l=$\mathrm{CH1}$
  RL: resistor c5 g5 100
  S1: switch c8 e8
  C1: capacitor e8 g8 1.5u i=IC
  Rs: resistor g10 i10 10 i=I
  M2: voltmeter g12 i12 l=$\mathrm{CH2}$
  G1: ground i1
wires:
  - c1 -- c3 -- c5 -- c8
  - g5 -- g8 -- g10 -- g12
  - i1 -- i3 -- i10 -- i12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/circuit/03-power-factor-line-loss-2.svg)

- W1 は FG の OUT (Sine、1 kHz、High-Z)。CH1 の先端は FG の出力 (受電端の上)、CH2 の先端は Rs の上、
  グランドクリップは 2 本とも GND
- ブレッドボードは図2 から次の 3 か所を変える。Rs を 5〜10 列から抜いて FG の芯を 10 列へ挿す。
  15 列から上の青いレールへの黒い線を外し、Rs を 15〜20 列 (c15–c20) に挿して、20 列から上の青いレールへ
  黒い線を渡す。C1 の戻りの黒い線 (j17 から下の青いレール) を外し、j17 から 15 列の上の段 (a15) へ
  黒以外の線を渡す (GND ではなくなるため)。CH1 の先端は 10 列、CH2 の先端は 15 列
- 受電端の電圧は Math の CH1 − CH2、線電流は CH2 ÷ 10 Ω。負荷の電力は、Math の C1 × C2 / 10 の平均
  (負荷と Rs を合わせた電力) から Rs の損失 (CH2 の RMS² ÷ 10 Ω) を引く。掛け算の無い機種は、CH1 と CH2 の
  RMS と位相差から V I cos φ を出して、同じく Rs の損失を引く
- CH1 に対する CH2 の位相は Rs を含んだ角度になる。S1 を開いて 0°、閉じて 38.4° 進み (計算値)。
  受電端の力率 (表の 1・0.73) は cos θ = P / (V I) で出す。V は Math (CH1 − CH2) の RMS
- FG の出力の 50 Ω で、FG の電圧は負荷に届く前に下がる。**S1 を切り替えるたびに、Math (CH1 − CH2) の
  振幅が 0.500 V になるよう FG の振幅を合わせ直す** (設定は開いて約 0.80 V、閉じて約 0.85 V。
  Vpp で入れる機種は 1.60 / 1.70 Vpp。計算値)。そうすれば見るべき値の表がそのまま使える

## 見るべき値

計算値。受電端の振幅 0.500 V (実効値 0.354 V)、RL = 100 Ω、C1 = 1.5 µF (1 kHz で X = 106 Ω)、Rs = 10 Ω。

| 測る所 | S1 を開く (C なし) | S1 を閉じる (C = 1.5 µF) |
| --- | --- | --- |
| 力率 cos θ | 1.00 | 0.73 (進み、θ = 43.3°) |
| 負荷の有効電力 P (Math の Avg) | 1.25 mW | 1.25 mW |
| 線電流の最大値 (CH2 ÷ 10 Ω) | 5.00 mA | 6.87 mA |
| 線電流の実効値 | 3.54 mA | 4.86 mA |
| 線路 Rs の損失 (I_rms² × 10 Ω) | 0.125 mW | 0.236 mW |
| 送電端の振幅 (W1) | 0.550 V | 0.552 V |

分かること:

- **同じ 1.25 mW を運ぶのに、力率 0.73 では電流が 1.37 倍 (1 / 0.73)** になる。C1 の枝の電流は
  有効電力を運ばず、線路を往復するだけ
- **線路の損失は 1.89 倍 (1 / 0.73²)**。電流の 2 乗で効くので、力率の低下は損失に 2 乗で出る。
  損失の比率 (損失 ÷ P) は 10 % から 19 % に上がる
- 送電端の電圧はほとんど変わらない (0.4 %)。**電圧計では気付かない損失の増え方**で、電流計か
  電力量計で見るしかない
- 力率を 1 に戻すのが力率改善 (3-7)。遅れ力率の負荷には C を、進み力率の負荷には L を並列に入れる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope の節)。
