---
book: circuits
chapter: 1
id: 1-4
title: ダイオードの向きと順方向電圧 — LED の色で比べる
tier: 50
source: 自作
board: BB
---

# 1-4 ダイオードの向きと順方向電圧 — LED の色で比べる

ダイオードは**決まった向き (アノード → カソード) にしか電流を流さない**部品で、
LED (発光ダイオード) もその一種。電流を流す向きを**順方向**、流さない向きを**逆方向**と呼ぶ。
LED はさらに、色によって**順方向電圧 (V<sub>F</sub>、1-1)** が違う。同じ抵抗で赤と青の LED を
光らせて比べ、もう 1 つ LED を逆向きに挿して「光らない」ことも確かめる。
ダイオードの向きは、後の整流 (第 5 章) や保護の回路の基本になる。

## 回路図

```circuit
title: 図1 色の違う LED と逆向きの LED
parts:
  V1: vsource 2,1 2,5 5
  G1: ground 2,5
  R1: resistor 4,1 4,3 330
  D1: led 4,3 4,5
  R2: resistor 6,1 6,3 330
  D2: led 6,3 6,5
  R3: resistor 8,1 8,3 330
  D3: led 8,5 8,3
wires:
  - 2,1 -- 4,1
  - 4,1 -- 6,1
  - 6,1 -- 8,1
  - 2,5 -- 4,5
  - 4,5 -- 6,5
  - 6,5 -- 8,5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/circuit/04-diode-direction.svg)

図1 の D1 (赤) と D2 (青) は向きをそろえて挿し、D3 (赤) だけ**わざと逆向き**に
挿してある。電源はどれも同じ 5V、抵抗もどれも 330Ω。

- D1 (赤、V<sub>F</sub> ≈ 2.0V): I = (5 − 2.0) / 330 ≈ **9.1 mA**
- D2 (青、V<sub>F</sub> ≈ 3.2V): I = (5 − 3.2) / 330 ≈ **5.5 mA** (同じ抵抗でも
  V<sub>F</sub> が高い色は電流が少なく、暗めになる)
- D3 (赤、逆向き): 電流はほぼ 0。R3 の両端はほぼ 0V、D3 の両端にほぼ 5V が
  かかる。LED が逆向きに耐えられる電圧 (逆耐圧) は多くが 5V 前後。万一それを超えても、
  抵抗が入っているので流れる電流は 5V/330Ω ≈ 15mA 以下に抑えられ、壊れない

## 実体配線図

```breadboard
title: 図2 色の違う LED と逆向きの LED
# 上の + レール = +5V、上の − レール = GND (下のレールは使わない)
board: half
parts:
  R1: resistor b5 b8 330
  D1: led c8(A) c9(K) red
  R2: resistor b12 b15 330
  D2: led c15(A) c16(K) blue
  R3: resistor b19 b22 330
  D3: led c23(A) c22(K) red
  PS:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies)
    pins: [V+, GND]
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t5 -- a5 red
  - a9 -- -t9 black
  - +t12 -- a12 red
  - a16 -- -t16 black
  - +t19 -- a19 red
  - a23 -- -t23 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/01-basics/breadboard/04-diode-direction.svg)

5 V の電源は Analog Discovery 3 (AD3) の Supplies の V+ を使う (WaveForms で V+ を 5 V にして出力を入れる)。図2 の「電源」の箱がそれで、V+ を上の + レール、GND を上の − レールへつなぐ。電流は全部で約 15 mA で、ブレッドボードの範囲と AD3 の電源 (各レール約 50 mA まで) に収まる。

図2 では、D3 だけ **K (カソード) を抵抗の側 (22 列)、A (アノード) を GND の側 (23 列)** に挿してあるところに注目
(D1・D2 は A が抵抗の側、K が GND の側)。
他の 2 つと見比べると、どちらが逆かが分かる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2, R3 | 抵抗 (1/4 W) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| D2 | LED (青、5 mm) | V<sub>F</sub> ≈ 3.2 V |
| D3 | LED (赤、5 mm、逆向きに実装) | — |
| — | 電源 | Analog Discovery 3 の V+ (5 V) |

オシロスコープの図は付けない。この題は直流の電圧と電流だけを見るので、テスターの読み値で足りる (オシロは 0-3)。

## 見るべき値

テスターの直流電圧レンジで、各 LED と抵抗の両端を測る。電流は抵抗の両端の電圧を 330 Ω で割って求める。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| D1 (赤) の両端 | 約 2.0 V | 色ごとに決まった V<sub>F</sub> |
| D2 (青) の両端 | 約 3.2 V | 赤より V<sub>F</sub> が高い (青・白は高め、赤・黄は低めが多い) |
| D2 の電流 (R2 の両端 ÷ 330Ω) | 約 5.5 mA | D1 の約 9.1mA より少ない → D2 のほうが暗く見える |
| D3 の両端 | 約 5 V (ほぼ電源電圧) | 電流が流れていない証拠。R3 の両端はほぼ 0V |

## 出典

自作。
