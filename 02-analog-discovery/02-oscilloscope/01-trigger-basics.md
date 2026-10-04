---
book: analog-discovery
chapter: 2
id: 2-1
title: トリガの基本 — エッジ・レベル・ホールドオフ
tier: 50
source: 自作 (公式は Digilent Using the Oscilloscope ガイド)
board: BB
---

# 2-1 トリガの基本 — エッジ・レベル・ホールドオフ

オシロが波形を止めて見せるのは**トリガ**のおかげ。方形波を材料に、
エッジ・レベル・ホールドオフの 3 つを確かめる。

## 回路図

```circuit
title: 図1 方形波を作って測る
parts:
  W1: square a1 c1 1.65
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/circuit/01-trigger-basics.svg)

W1 は振幅 1.65 V・オフセット 1.65 V の方形波 (0 V〜3.3 V を往復する)。
R1 (1 kΩ) は負荷、CH1 で読む。

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/breadboard/01-trigger-basics.svg)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、2 kHz、振幅 1.65 V、オフセット 1.65 V (0〜3.3 V) |
| Scope (CH1) | DC、Range 0〜3.3 V 程度 |
| トリガ (Edge) | Source CH1、Rising、Level 1.65 V |
| トリガ (Level) | Source CH1、Above/Below 1.65 V (エッジではなくレベルで止める) |
| トリガ (Holdoff) | 0.45 ms 程度 (周期 0.5 ms よりわずかに短く) |

立ち上がり (Rising) で止めると t = 0 (画面の中央) で波が上がり、
立ち下がり (Falling) にすると同じ波が半周期 (250 μs) ずれて中央で下がる。

```scope
title: 図3 Rising・1.65 V で止めると中央で立ち上がる
time: 100us/div
trigger: ch1 rising 1.65V
ch1: {wave: square 2kHz 1.65V offset 1.65V, range: 500mV/div, position: -3div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/01-trigger-basics-1.svg)

```scope
title: 図4 Falling に変えると中央で立ち下がる
time: 100us/div
trigger: ch1 falling 1.65V
ch1: {wave: square 2kHz 1.65V offset 1.65V, range: 500mV/div, position: -3div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/02-oscilloscope/scope/01-trigger-basics-2.svg)

## 見るべき値

| 設定 | 見え方 | 分かること |
| --- | --- | --- |
| Edge・Rising・Level 1.65 V | 立ち上がりで波形が止まる | 最も基本のトリガ |
| Edge を Falling に変える | 立ち下がりで止まる位置が半周期ずれる | エッジの向きで捕まえる瞬間が変わる |
| Level トリガ | 信号が閾値を跨いだ瞬間に反応 (Edge とほぼ同じ見え方だが、跨ぎ続ける限り再トリガしない設定もできる) | レベルとエッジの違い |
| Holdoff を周期よりわずかに短く設定 | 表示が安定して揺れない | 同じような形の縁が続く信号で、意図しない早いトリガを間引ける |
| Holdoff を 0 にする | (この方形波では変化なし。ノイズが乗った信号だと揺れが出る) | ホールドオフの効果は信号が汚いときほど分かる (ノイズの乗った波の見え方は 2-7) |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
