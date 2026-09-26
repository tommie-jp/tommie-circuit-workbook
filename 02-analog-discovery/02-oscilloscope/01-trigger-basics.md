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
    label: Analog Discovery
    pins: [1+, W1, 1-, GND]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b10 black
  - AD.1+ -- a5 orange
  - AD.1- -- a10 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、2 kHz、振幅 1.65 V、オフセット 1.65 V (0〜3.3 V) |
| Scope (CH1) | DC、Range 0〜3.3 V 程度 |
| トリガ (Edge) | Source CH1、Rising、Level 1.65 V |
| トリガ (Level) | Source CH1、Above/Below 1.65 V (エッジではなくレベルで止める) |
| トリガ (Holdoff) | 0.3 ms 程度 (周期 0.5 ms の 6 割) |

## 見るべき値

| 設定 | 見え方 | 分かること |
| --- | --- | --- |
| Edge・Rising・Level 1.65 V | 立ち上がりで波形が止まる | 最も基本のトリガ |
| Edge を Falling に変える | 立ち下がりで止まる位置が半周期ずれる | エッジの向きで捕まえる瞬間が変わる |
| Level トリガ | 信号が閾値を跨いだ瞬間に反応 (Edge とほぼ同じ見え方だが、跨ぎ続ける限り再トリガしない設定もできる) | レベルとエッジの違い |
| Holdoff を周期よりわずかに短く設定 | 表示が安定して揺れない | 同じような形の縁が続く信号で、意図しない早いトリガを間引ける |
| Holdoff を 0 にする | (この方形波では変化なし。ノイズが乗った信号だと揺れが出る) | ホールドオフの効果は信号が汚いときほど分かる (2-7 で確かめる) |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
