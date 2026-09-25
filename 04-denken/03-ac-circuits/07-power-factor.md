---
book: denken
chapter: 3
id: 3-7
title: 力率改善 — コンデンサを並列にして線電流を減らす
tier: 50
source: 自作
board: BB
---

# 3-7 力率改善 — コンデンサを並列にして線電流を減らす

遅れ力率の負荷 (抵抗 + コイル) にコンデンサを並列に入れると、負荷の有効電力は
そのままで、線路を流れる電流が減る。電験では理論 (交流の電力)・電力 (調相と送電損失)・
機械 (誘導機の力率)・法規 (力率改善コンデンサの容量) のどの科目にも出る単元。

Analog Discovery (AD) の波形発生器を電源にし、2 ch のオシロスコープで受電端の電圧と
線電流を同時に測る。コンデンサを入れる前と後で、力率・線電流・線路の損失を比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| cos θ = R / √(R² + X_L²) | 負荷の力率 (遅れ)。X_L = ωL |
| P = V I cos θ | 有効電力。コンデンサを入れても変わらない |
| Q = Q_L − Q_C、Q_C = ωC V² | 無効電力。コンデンサの進み無効電力が、負荷の遅れ無効電力を打ち消す |
| p = I² r | 線路の損失。線電流の 2 乗で減る |

## 回路図

```circuit
title: 図1 遅れ力率の負荷とコンデンサ
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{W1}$
  Rs: resistor c1 c4 10 i=I
  M2: voltmeter a1 a4 l=$\mathrm{CH2}$
  M1: voltmeter c6 g6 l=$\mathrm{CH1}$
  R1: resistor c8 e8 47
  L1: inductor e8 g8 10m
  S1: switch c10 e10
  C1: capacitor e10 g10 1.5u i=IC
  G1: ground g6
wires:
  - a1 -- c1
  - a4 -- c4
  - c4 -- c6 -- c8 -- c10
  - g1 -- g6 -- g8 -- g10
```

- V1 は AD の波形発生器 W1。1 kHz、振幅 0.5 V
- Rs (10 Ω) は線電流 I を測るシャント。同時に**線路の抵抗**の役もする。
  CH2 は Rs の両端 (差動入力) で、読みの 1/10 が線電流 (1 mV = 0.1 mA)
- CH1 は受電端の電圧。R1 + L1 が遅れ力率の負荷、S1 を閉じるとコンデンサ C1 が並列に入る
- 試験の図なら Rs の所に電流計、受電端に電力計を描く。ここでは AD の 2 ch で両方を測る

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上の青いレール = GND。コンデンサの枝は溝を渡って下の段へ、下の青いレールも GND
board: half
parts:
  Rs: resistor c5 c10 10
  R1: resistor d10 d15 47
  L1: inductor/axial c15 c20 10m
  S1: switch g10 g13
  C1: capacitor/film h13 h17 1.5u
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 2+, 1+, 2-, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.2+ -- b5 blue [h10]      # 半列ずらして W1 の線と重ねない
  - AD.1+ -- a10 orange
  - AD.2- -- b10 white [h10]    # 同じく 1+ の線と重ねない
  - AD.1- -- -t12 black
  - a20 -- -t20 black
  - e10 -- f10 green
  - j17 -- -b17 black
  - -t28 -- -b28 black
```

- 10 列が受電端。Rs・R1・CH1 (1+)・CH2 (2−) と、下の段へ渡る緑の線が集まる
- CH2 の 2+ と 2− を Rs の両端 (5 列と 10 列) に挿す。**2− を GND につながない**
  (つなぐと受電端が GND に落ちる)
- 28 列の黒い線で上下の GND のレールをつなぐ。S1 を切り替えて C1 を入れたり外したりする

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.5 V、Offset 0 V |
| Scope | CH1 = 受電端の電圧 v、CH2 = Rs の電圧 (= 10 Ω × i)。Range は CH1 が 100 mV/div、CH2 が 20 mV/div。Average を 16 回 |
| Math | M1 = C1 × C2 / 10 (瞬時電力 p、単位 W)。Measure で M1 の Average が有効電力 P |
| Measure | CH1 と CH2 の RMS、CH1 に対する CH2 の Phase (位相差 θ。cos θ が力率) |

**電流の上限**: AD の波形発生器は 10 mA まで。この回路の線電流は最大値で 5.9 mA。
振幅を上げるなら 0.8 V まで (9.4 mA)。

## 見るべき値

計算値。10 mH の小さなコイルは巻線抵抗 (数 Ω〜数十 Ω) を持ち、その分だけ R が大きく
見えて力率は計算より良くなる。巻線抵抗をテスターで測り、R1 に足して計算し直す。

| 測る所 | C なし | C = 1.5 µF | C = 2.2 µF |
| --- | --- | --- | --- |
| 力率 (受電端) | 0.60 遅れ | 0.99 遅れ | 0.90 進み |
| 線電流の最大値 (CH2 ÷ 10 Ω) | 5.9 mA | 3.6 mA | 3.9 mA |
| 負荷の有効電力 P | 0.82 mW | 0.82 mW | 0.82 mW |
| 線路 Rs の損失 | 0.17 mW | 0.064 mW | 0.077 mW |
| 受電端の電圧の最大値 (CH1) | 0.462 V | 0.465 V | 0.464 V |

分かること:

- **P は変わらない。** コンデンサは有効電力を使わない。減るのは無効電力と線電流
- **線電流が 6 割になると、線路の損失は 4 割弱になる** (電流の 2 乗)。受電端の電圧も
  わずかに上がる (線路の電圧降下が減る)。送電線の目で見直すのが 12-3
- **入れすぎると進み力率になり、電流がまた増える** (2.2 µF)。力率をちょうど 1 にする
  容量は C = X_L / {ω (R² + X_L²)} ≒ 1.6 µF

## 出典

自作。
