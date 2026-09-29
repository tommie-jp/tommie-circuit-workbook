---
book: analog-discovery
chapter: 8
id: 8-5
title: クロストーク — 隣の列に何が漏れるか
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 8-5 クロストーク — 隣の列に何が漏れるか

8-2 で測った列間の寄生容量 (約 2.5 pF) は、**片方の列に信号が乗っているとき**
隣の列に何が漏れるかという形でも効いてくる。ここでは駆動している列 (加害側)
の隣に、何もつながない列 (被害側) を置き、そこにオシロの入力 (1 MΩ ∥ 24 pF)
だけをつないだときにどれだけ漏れるかを測る。加害側は W1 の出力 (ほぼ 0 Ω)
で直接駆動するので、漏れの大きさは**被害側の負荷インピーダンスだけ**で決まる。

## 回路図

```circuit
title: 図1 加害側と被害側、寄生容量と終端抵抗
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  Cstray: capacitor c3 c9 2.5p l=$\mathrm{C_{stray}}$
  Rterm: resistor c9 c12 100
  G1: ground c12
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.2+ -| c9
  - AD.1- -| c12
  - AD.2- -| c12
  - AD.GND -| c12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/05-crosstalk.svg)

- 加害側 (c3) は W1 が直接駆動し、1+ でその振幅を確かめる
- 被害側 (c9) は Cstray 経由でしかつながっていない。Rterm (100 Ω) は
  被害側を GND に軽く落とす**対策**の抵抗 — まずこれを外した状態 (被害側が
  完全に浮いた状態) で測り、次に挿して測り直す
- C<sub>stray</sub> は 8-2 と同じく部品ではなく、列が近いことで生じる寄生容量

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rterm: resistor c6 c11 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- b5 yellow [h-10]
  - AD.GND -- -t3 black
  - AD.1+ -- a5 orange
  - AD.1- -- -t8 black
  - AD.2+ -- b6 purple [h10]
  - AD.2- -- -t13 black
  - a11 -- -t11 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/05-crosstalk.svg)

- 5 列 (加害側) と 6 列 (被害側) は、8-2 (10 列と 11 列) と同じく隣り合った列
  (どちらも a〜e の側)。Rterm は 6 列から GND レールへ (11 列を経由)。**外した状態も試すので、いったん挿さずに測ってから
  追加する**

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、振幅 1 V。まず 1 kHz、次に 10 MHz |
| Scope | CH1 = 加害側 (5 列)、CH2 = 被害側 (6 列)。どちらも Amplitude を測定 |
| Measure | CH2 / CH1 の比を電卓で計算 (dB 表示は無いので手計算) |

## 見るべき値

計算値。C<sub>stray</sub> = 2.5 pF (8-2)、オシロ入力 1 MΩ ∥ 24 pF (器具の仕様)。
被害側の負荷が Rterm か、オシロの入力だけ (浮いた状態) かで大きく変わる。

| 条件 | 周波数 | 漏れ (CH2/CH1) | 分かること |
| --- | --- | --- | --- |
| 被害側が浮いたまま (Rterm 無し) | 1 kHz | −36.2 dB (1.5%) | 低い周波数では Xc が大きく、漏れは小さい |
| 被害側が浮いたまま (Rterm 無し) | 10 MHz | **−20.5 dB (9.4%)** | 高い周波数ほど Xc が下がり、漏れが増える |
| Rterm (100 Ω) を追加 | 10 MHz | −36.2 dB (1.5%) | **終端を軽くするだけで漏れが 1/6 に減る** |

被害側が浮いたままだと、10 MHz では加害側の振幅の**約 1 割**が漏れて見える。
これはオシロの入力 (1 MΩ ∥ 24 pF) と C<sub>stray</sub> (2.5 pF) が作る容量分圧で、
**周波数が十分高いところでは一定の比 (C<sub>stray</sub> / (C<sub>stray</sub> + 24 pF) ≒ 9.4%)
に収束する** — 分圧の比が容量の比だけで決まるため。Rterm を足すと被害側の
インピーダンスが下がり、漏れが大きく減る。**使っていない列を浮かせたままに
しない**というのが、ここでの実用上の教訓 (8-9 のデカップリングの置き場所にも
通じる考え方)。

```graph
title: 図3 浮いた列の漏れは −20.5 dB で頭打ち、100 Ω の終端で 10 MHz でも −36 dB
x: 周波数 Hz log 100..100M
y: 漏れ dB -80..0
lines:
  浮いたまま dB: 20*log10(2*pi*x*2.5p*1M/sqrt(1+(2*pi*x*26.5p*1M)^2))
  Rterm 100 Ω dB: 20*log10(2*pi*x*2.5p*99.99/sqrt(1+(2*pi*x*26.5p*99.99)^2))
notes:
  - mark 1k
  - mark 10M
  - level -20.5dB
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/05-crosstalk.svg)

分かること:

- 浮いた被害側の漏れは 20 kHz あたりで −20.5 dB (容量の比) に達し、
  それより上は周波数によらない
- 100 Ω で終端すると、漏れは 1 MHz で −56 dB と小さく、周波数が 10 倍になるごとに 20 dB 増える

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)。
