---
book: denken
chapter: 10
id: 10-3
title: 降圧チョッパ — 出力電圧 = デューティ比 × 入力
tier: 50
source: 自作
board: BB
---

# 10-3 降圧チョッパ — 出力電圧 = デューティ比 × 入力

MOSFET を高い周波数でオン・オフし、コイルとコンデンサで平らにならすと、
入力より低い直流電圧が出力に得られる。オンの割合 (デューティ比 D) で
出力電圧が決まることを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vout = D × Vin | 出力電圧はデューティ比に比例する (連続モード) |
| ΔI = Vin × D × (1−D) / (L × f) | コイルに流れる電流のリップル |
| ΔVout ≒ ΔI / (8 × f × C) | 出力電圧のリップル (コンデンサの ESR を無視) |

## 回路図

```circuit
title: 図1 降圧チョッパ
style:
  standard: jis
parts:
  Vin: vsource c1 g1 5
  Vg: square a3 a5 l=$\mathrm{PWM}$
  Q1: nmos-e e5
  D1: schottky g7 e7 1N5819
  L1: inductor e9 e13 1m
  Cout: ecap e15 g15 10u
  RL: resistor e17 g17 100
  M1: voltmeter e19 g19 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - c1 |- Q1.D
  - a5 |- Q1.G
  - g1 -- g3 -- g5 -- g7 -- g13 -- g15 -- g17 -- g19
  - a3 -- g3
  - Q1.S -| e7
  - e7 -- e9
  - e13 -- e15 -- e17 -- e19
```

- Vin は DC 5 V (AD の Supplies か電池)。Vg は AD の Wavegen で作る PWM
  (方形波、100 kHz、デューティ比 50 %、0〜5 V の振幅)
- Q1 (2N7000) が高速スイッチ。D1 (1N5819、ショットキー) は Q1 が切れた
  瞬間にコイルの電流を逃がす還流ダイオード
- L1 (1 mH) と Cout (10 µF) で平らにならし、RL (100 Ω) が負荷。CH1 は出力を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上下の赤レール = 電源 (5 V) の+、青レール = GND。電源は AD の Supplies か電池
board: half
parts:
  Q1: transistor h5(G) h6(D) h7(S) 2N7000
  D1: schottky f9(A) f7(K) 1N5819
  L1: inductor/axial g7 g12 1m
  Cout: capacitor/electrolytic i12(+) i15(-) 10u
  RL: resistor j12 j15 100
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - +b6 -- g6 red
  - -b9 -- g9 black
  - -b15 -- g15 black
  - AD.W1 -- g5 yellow
  - AD.GND -- h15 black
  - AD.1+ -- h12 orange
  - AD.1- -- i9 black [h20]
```

- Q1 (2N7000) の D (6 列) を赤レールへ、S (7 列) を D1・L1 の側へ
- D1 (ショットキー) の K (7 列) が Q1.S と同じ列。A (9 列) を青レールへ
- L1 (7→12 列) がスイッチの節点から出力へ、Cout・RL (12・15 列) が出力の平滑と負荷
- AD の Wavegen (W1) を Q1.G (5 列) に、GND を青レールに。CH1 (1+/1−) は
  出力 (12 列) と GND (青レール) の間にあてる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | Vin = 5 V (AD の Supplies か電池) |
| Wavegen | PWM: Square、100 kHz、Amplitude 2.5 V、Offset 2.5 V (Duty 50 %、0〜5 V を往復) |
| Scope | CH1 = 出力 (Cout・RL の両端)。Time base は 5 µs/div 程度 |
| Measure | CH1 の Average (Vout) |

## 見るべき値

計算値 (Vin = 5 V、D = 50 %、f = 100 kHz、L = 1 mH、C = 10 µF、R_L = 100 Ω)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Vout (理想、D × Vin) | 2.50 V | デューティ比 50 % なら入力の半分 |
| Vout (実際、D1 の順電圧 0.3 V を考えた値) | 約 2.35 V | オフの間、電流は D1 を通るので、その分だけ理想より低くなる |
| Iout (= Vout / R_L) | 23.5 mA | 負荷抵抗を流れる直流分の電流 |
| コイルの電流リップル ΔI | 12.5 mA | Iout (23.5 mA) の半分 (6.25 mA) より大きいので、電流は 0 まで落ちずに連続して流れる (連続モード) |
| 出力電圧のリップル ΔVout | 約 1.6 mV | 100 kHz と 10 µF のおかげでとても平らになる (10-2 の整流の直後よりずっと小さい) |

デューティ比を変えると、Vout はほぼそれに比例して変わる (D = 25 % なら約 1.03 V、
D = 75 % なら約 3.68 V。どちらも D1 の順電圧の分だけ理想よりわずかに低い)。

分かること:

- **出力電圧はデューティ比だけで決まる。** 周波数や部品の値を変えなくても、
  PWM の Duty を変えるだけで出力電圧が変わる — これがモータの速度制御 (9-4) や
  電源の出力可変にそのまま使われる
- **コイルの電流が 0 まで落ちない (連続モード) なら、Vout = D × Vin がそのまま成り立つ。**
  負荷が非常に軽い (R_L が大きい) と電流が 0 まで落ちる不連続モードになり、
  この式から外れる
- スイッチング周波数を上げるほど、同じ L・C でも電流・電圧のリップルは小さくなる
  (ΔI も ΔVout も f に反比例)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
