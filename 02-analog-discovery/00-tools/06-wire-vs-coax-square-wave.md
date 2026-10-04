---
book: analog-discovery
chapter: 0
id: 0-6
title: 付属ワイヤと同軸で同じ 5 MHz の方形波を見比べる
tier: 100
source: 自作 (帯域の数値は Digilent の Analog Discovery 3 の公式仕様)
board: BB
---

# 0-6 付属ワイヤと同軸で同じ 5 MHz の方形波を見比べる

0-5 で確かめた帯域の違いを、実際の波形の**形**で見る。同じブレッドボードの
同じ 1 点を、まず付属ワイヤ、次に（持っていれば）BNC アダプタ＋同軸ケーブルで
測り、5 MHz の方形波の角の丸まり方を比べる。第 8 章「ブレッドボードの限界」の
伏線でもある。

## 回路図

```circuit
title: 図1 方形波を負荷抵抗に流す
parts:
  W1: square a1 c1 1
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/06-wire-vs-coax-square-wave.svg)

W1（5 MHz、振幅 1 V、オフセット 0 V の方形波）に負荷 R1（1 kΩ）をつなぎ、CH1 で
その両端を読む。Wavegen の出力インピーダンスはほぼ 0 Ω（AD3 の仕様。
BNC アダプタの出力ジャンパも 0 Ω 側のまま使う。50 Ω 側にすると 1 kΩ との分圧で振幅が
約 5 % 下がる (1k ÷ 1.05k ≈ 0.95)）なので、R1 は負荷を定義するためだけの抵抗（1-2 と同じ役目）。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで方形波を測る
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 1-, GND]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b10 black
  - AD.1+ -- a5 orange
  - AD.1- -- a10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/breadboard/06-wire-vs-coax-square-wave.svg)

図では付属ワイヤ（`yellow` / `black` の細いリード線）でつないである。BNC アダプタで
測るときは、この同じ 5 列・10 列の点に同軸プローブのグラバーを挟むだけで、
図自体は変わらない（BNC アダプタは足の意味を変えないので描き分けない。0-5 参照）。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、5 MHz、振幅 1 V、オフセット 0 V |
| Scope (CH1) | DC、Range ±1.5 V 程度、Time/div 20〜50 ns、Auto トリガ |

次の 2 枚は、経路全体を 1 次のローパスとみなして描いた目安で、V/div と Time/div は
同じにしてある。発生器とオシロが直列に効くので、それぞれの立ち上がり時間
（t<sub>r</sub> = 0.35 / BW）を二乗和の平方根で合成した値（2-10 と同じ計算）に
時定数を合わせた：ワイヤは √(38.9² + 38.9²) ≈ 55 ns（τ = 55 ÷ 2.2 = 25 ns）、
同軸は √(29.2² + 11.7²) ≈ 31 ns（τ ≈ 14.3 ns）。5 MHz の半周期は 100 ns で、ワイヤの時定数（25 ns）では振幅が 1.93 V
までしか立ち切らないため、図 3 の読みは約 51 ns と 55 ns より少し短くなる。実機の角はこれより複雑に崩れる。

```scope
title: 図3 付属ワイヤ — 角が丸く、立ち上がり (10→90 %) が約 51 ns
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: square 5MHz 1V | rc 25ns, range: 500mV/div}
measure: [vpp, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/scope/06-wire-vs-coax-square-wave-1.svg)

```scope
title: 図4 BNC アダプタ + 同軸 — 立ち上がりが約 31 ns に縮み角が立つ
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: square 5MHz 1V | rc 14.3ns, range: 500mV/div}
measure: [vpp, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/scope/06-wire-vs-coax-square-wave-2.svg)

## 見るべき値

5 MHz の方形波の高調波は 15 MHz（3 次）、25 MHz（5 次）…と続く。角が立つには
これらの高調波がほぼそのまま通る帯域が要る。

| 経路 | −3 dB の帯域（発生器 / オシロ） | 合成の立ち上がり（実効の帯域 = 0.35 ÷ t<sub>r</sub>） | 5 MHz の見え方（目安） |
| --- | --- | --- | --- |
| BNC アダプタ＋同軸（この教科書の標準） | 12 MHz / 30 MHz+ | 約 31 ns（約 11 MHz。発生器側が全体のボトルネック。0-5 参照） | 基本波はほぼそのまま通り、3 次（15 MHz）は少し減衰するが 5 次よりは残る。ワイヤのときより明らかに角が立つ |
| 付属ワイヤ（ヘッダ直結） | 9 MHz / 9 MHz | 約 55 ns（約 6 MHz） | 基本波の 5 MHz 自体が減衰域に近く、3 次（15 MHz）以上はほぼ削られる。角がかなり丸く、台形に近い波形になる |

どちらの経路でも 3 次以上の高調波が完全には揃わないので、**理想的な直角の
方形波にはならない**——それでも見比べれば、同軸のほうが角の丸まりが小さいことが
はっきり分かる。BNC アダプタを持っていないときは、この比較は 0-5 の表の数字
（−3 dB / −0.5 dB / −0.1 dB の周波数）から丸まり方を推測する。

出典（帯域）は 0-5 と同じ AD3 の仕様。図 3・図 4 の立ち上がりは計算値で、実測ではない。

## 出典

自作。帯域の数値は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
（Bandwidth の項）による。
