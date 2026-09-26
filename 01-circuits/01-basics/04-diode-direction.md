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

ダイオードは**決まった向きにしか電流を流さない**部品。LED はさらに、色によって
**順方向電圧 (V<sub>F</sub>)** が違う。同じ抵抗で赤と青の LED を光らせて比べ、
もう 1 つ LED を逆向きに挿して「光らない」ことも確かめる。

## 回路図

```circuit
title: 図1 色の違う LED と逆向きの LED
parts:
  V1: vsource a1 e1 5
  G1: ground e1
  R1: resistor a3 c3 330
  D1: led c3 e3
  R2: resistor a7 c7 330
  D2: led c7 e7
  R3: resistor a11 c11 330
  D3: led e11 c11
wires:
  - a1 -- a3
  - a3 -- a7
  - a7 -- a11
  - e1 -- e3
  - e3 -- e7
  - e7 -- e11
style:
  grid: on
```

D1 (赤) と D2 (青) は向きをそろえて挿し、D3 (赤) だけ**わざと逆向き**に
挿してある。電源はどれも同じ 5V、抵抗もどれも 330Ω。

- D1 (赤、V<sub>F</sub> ≈ 2.0V): I = (5 − 2.0) / 330 ≈ **9.1 mA**
- D2 (青、V<sub>F</sub> ≈ 3.2V): I = (5 − 3.2) / 330 ≈ **5.5 mA** (同じ抵抗でも
  V<sub>F</sub> が高い色は電流が少なく、暗めになる)
- D3 (赤、逆向き): 電流はほぼ 0。R3 の両端はほぼ 0V、D3 の両端にほぼ 5V が
  かかる。**抵抗が入っているので**、万一 LED の逆耐圧 (多くは 5V 前後) を
  超えても流れる電流は 5V/330Ω ≈ 15mA に抑えられ、壊れない

## 実体配線図

```breadboard
title: 図2 色の違う LED と逆向きの LED
# 上の + レール = +5V、上の − レール = GND (下のレールは使わない)
board: half
parts:
  R1: resistor a5 a8 330
  D1: led b8(A) b9(K) red
  R2: resistor a12 a15 330
  D2: led b15(A) b16(K) blue
  R3: resistor a19 a22 330
  D3: led b23(A) b22(K) red
wires:
  - +t5 -- c5 red
  - c9 -- -t9 black
  - +t12 -- c12 red
  - c16 -- -t16 black
  - +t19 -- c19 red
  - c23 -- -t23 black
```

D3 だけ **K (カソード) を抵抗の側 (22 列)、A (アノード) を GND の側 (23 列)** に挿してあるところに注目
(D1・D2 は A が抵抗の側、K が GND の側)。
他の 2 つと見比べると、どちらが逆かが分かる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1, R2, R3 | 抵抗 (1/4 W) | 330 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| D2 | LED (青、5 mm) | V<sub>F</sub> ≈ 3.2 V |
| D3 | LED (赤、5 mm、逆向きに実装) | — |
| — | 電源 | 5 V |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| D1 (赤) の両端 | 約 2.0 V | 色ごとに決まった V<sub>F</sub> |
| D2 (青) の両端 | 約 3.2 V | 赤より V<sub>F</sub> が高い (青・白は高め、赤・黄は低めが多い) |
| D2 の電流 (R2 の両端 ÷ 330Ω) | 約 5.5 mA | D1 の約 9.1mA より少ない → D2 のほうが暗く見える |
| D3 の両端 | 約 5 V (ほぼ電源電圧) | 電流が流れていない証拠。R3 の両端はほぼ 0V |

## 出典

自作。
