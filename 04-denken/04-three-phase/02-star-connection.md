---
book: denken
chapter: 4
id: 4-2
title: Y 結線 — 線間電圧は相電圧の √3 倍、位相は 30° 進む
tier: 50
source: 自作
board: BB
---

# 4-2 Y 結線 — 線間電圧は相電圧の √3 倍、位相は 30° 進む

4-1 で作った三相電源 (1 相目・2 相目・3 相目) に、同じ値の抵抗 3 本を星形に
つないだ **Y 結線**の負荷を加える。3 本が集まる点 (中性点 N) は電源の GND に
つながない。相電圧 (相と中性点の間) と線間電圧 (相と相の間) を測って比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_AB = V_A − V_B | 線間電圧 (A 相と B 相の差) |
| \|V_AB\| = √3 × \|V_A\| | 線間電圧の大きさは相電圧の √3 倍 |
| ∠V_AB = ∠V_A + 30° | 線間電圧の位相は、その相電圧より 30° 進む |
| V_N = (V_A + V_B + V_C) / 3 | 中性点の電圧。平衡なら分子が 0 になるので V_N = 0 |

## 回路図

```circuit
title: 図1 三相電源に Y 結線の負荷
parts:
  V1: sine a1 c1 1 l=$\mathrm{W1}$
  G1: ground c1
  R1: resistor a1 a4 10k
  V2: sine e1 g1 1 l=$\mathrm{W2}$
  G2: ground g1
  R2: resistor e1 e5 10k
  U1: opamp c9 +up TL071
  G3: ground c6
  Rf: resistor d11 d14 10k
  OUT: port c16
  R3: resistor b20 b23 1k
  R4: resistor f20 f23 1k
  R5: resistor c20 c23 1k
wires:
  - a4 |- U1.-
  - e5 |- U1.-
  - c6 |- U1.+
  - d11 |- U1.-
  - U1.out -- c14 -- c16
  - d14 -- c14
  - a1 -- b20
  - e1 -- f20
  - c16 -- c20
  - b23 -- c23
  - f23 -- c23
notes:
  - text c16 blue: 3 相目
  - text d23 blue: N
style:
  standard: jis
  grid: on
  pitch: 1.4
```

- R3・R4・R5 (各 1 kΩ) が Y 結線の負荷。3 本が集まる点 (N) はどこにもつながず、
  浮かせたまま (**中性線なし**。中性線ありは 4-4)
- 電源側 (V1・V2・U1 の出力) は電流を流しても電圧が下がらない理想の電源として
  計算する。1 相あたりの電流は 1 V ÷ 1 kΩ = 1 mA で、オペアンプの出力にも
  AD の Wavegen にも十分小さい (Wavegen 側は R1・R2 の 0.1 mA と合わせても
  1.1 mA)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上のブロック (a〜e) に入力の抵抗と Y 結線の負荷、下のブロック (f〜j) に TL071
board: full
parts:
  R1: resistor c7 c11 10k
  R2: resistor c17 c21 10k
  Rf: resistor c24 c28 10k
  U1: dip8 @ f13 TL071
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, V-, GND, W1, W2, 1+, 1-, 2+, 2-]
  R3: resistor b35 b39 1k
  R4: resistor b42 b46 1k
  R5: resistor b49 b53 1k
wires:
  - AD.W1 -- a7 yellow
  - AD.W2 -- a17 orange
  - a11 -- U1.2 green
  - a21 -- U1.2 green
  - a24 -- U1.2 green
  - U1.6 -- a28 blue
  - AD.GND -- U1.3 black
  - AD.V- -- U1.4 black
  - AD.V+ -- U1.7 red
  - AD.1+ -- b7 yellow
  - AD.1- -- AD.GND black
  - AD.2+ -- b17 orange
  - AD.2- -- AD.GND black
  - a7 -- b35 yellow
  - a17 -- b42 orange
  - a28 -- b49 blue
  - b39 -- b46 green
  - b46 -- b53 green
notes:
  - text small: R3・R4・R5 (各 1k) が Y 結線。b53 (R5 の右) が中性点 N (浮かせたまま)
```

- 1 相目 (R3) を b35 の列、2 相目 (R4) を b42 の列、3 相目 (R5) を b49 の列から
  取り出し、右端 (b53) で 3 本を束ねて中性点 N にする
- N は GND のレールにはつながない。テスターや AD の 2 番目の入力の − 側を
  N に挿すときは、GND とは別の場所だと確かめてから挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope (1 回目) | CH1 = 1 相目 (AD.W1) − N (差動)、CH2 = 1 相目 − 2 相目 (差動) |
| Scope (2 回目) | CH1 は同じ。CH2 の − 側だけ GND に挿し替え、N の電圧 (GND 基準) を読む |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

## 見るべき値

計算値。V_A・V_B・V_C は 4-1 で確かめた振幅 1.00 V の三相 (0°、−120°、+120°)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 相電圧 (1 相目 − N) の振幅 | 1.00 V | R3・R4・R5 が等しいので、相電圧は電源の振幅のまま |
| 線間電圧 (1 相目 − 2 相目) の振幅 | 1.73 V (= √3 × 1.00 V) | 線間電圧は相電圧の √3 倍 |
| 線間電圧の位相 (相電圧に対して) | +30° | 線間電圧は相電圧より 30° 進む |
| N の電圧 (GND 基準) | 0 V (計算値) | 平衡負荷なので中性点は浮いていても GND と同じ電圧になる |

分かること:

- **線間電圧は相電圧より大きく、位相もずれる。** カタログの三相機器の定格が
  「200 V」のように 1 つの数字でも、それは線間電圧で、相電圧は 200/√3 ≒ 115 V
- 中性点 N を浮かせても電圧が暴れないのは、**この負荷が平衡している (3 本とも
  同じ値) から**。1 本だけ値を変えると N が動く (4-14 の中性点の移動で確かめる)

## 出典

自作。
