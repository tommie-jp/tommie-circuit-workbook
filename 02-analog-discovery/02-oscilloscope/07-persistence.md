---
book: analog-discovery
chapter: 2
id: 2-7
title: Persistence でノイズとジッタを見る
tier: 50
source: 自作
board: BB
---

# 2-7 Persistence でノイズとジッタを見る

**Persistence** (残光表示) は、何度もトリガした波形を消さずに重ねて
表示するモード。1 本ずつでは分からない**ジッタ (トリガのたびの時間の
ばらつき)** と**ノイズ (振幅のばらつき)** が、線の「太さ」として見える。

## 回路図

```circuit
title: 図1 方形波を作って測る (2-1 と同じ)
parts:
  W1: square a1 c1 1.65
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

2-1 と同じ、方形波 → 負荷抵抗 → CH1 の回路。

## 実体配線図

```breadboard
title: 図2 ブレッドボードで方形波を測る (2-1 と同じ)
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- a10 black
  - AD.1+ -- b5 yellow
  - AD.1- -- b10 black
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 方形波、2 kHz、振幅 1.65 V、オフセット 1.65 V |
| Scope (CH1) | DC、Edge トリガ、Rising、Level 1.65 V |
| 表示 | **Persistence を On**、時間を「無限 (Infinite)」か数秒に設定 |

## 見るべき値

| 見る所 | 期待する見え方 | 分かること |
| --- | --- | --- |
| 通常表示 (Persistence Off) | 1 本のきれいな方形波 | 1 回ぶんの波形しか見えない |
| Persistence On、しばらく待つ | 立ち上がり・立ち下がりの縁が**わずかに帯状ににじむ** | 毎回のトリガで縁の位置が数 ns〜数十 ns ずれている (ジッタ)。にじみの幅はサンプル周期 (100 MS/s なら 10 ns) が目安 |
| 平らな部分 (0 V や 3.3 V の区間) | 細い線のまま (にじみが少ない) | 平らな部分は振幅のノイズが小さければ太くならない。縁だけがにじむのはジッタが主な原因という証拠 |
| Persistence をクリア (Reset) | また 1 本の細い線に戻る | 残光は積算表示であることの確認 |

にじみの幅が気になるほど大きいときは、まず 0-3 のループバックに戻って
Analog Discovery 自体のジッタなのか、外の回路 (この題では方形波と
抵抗だけなので考えにくい) のせいかを切り分けるとよい。

## 出典

自作。
