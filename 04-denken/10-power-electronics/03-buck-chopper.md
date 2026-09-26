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
  Vin: vsource c1 l1 5
  D1: schottky h3 c3 1N5819
  L1: inductor h5 f5 1m
  Q1: nmos-e j5
  Vg: square l3 k3 l=$\mathrm{PWM}$
  Cout: ecap c7 f7 10u
  RL: resistor f9 c9 100
  M1: voltmeter c11 f11 l=$\mathrm{CH1}$
  G1: ground l1
wires:
  - c1 -- c3 -- c7 -- c9 -- c11
  - f5 -- f7 -- f9 -- f11
  - h3 -- h5
  - h5 -- Q1.D
  - Q1.G -| k3
  - Q1.S |- l5
  - l1 -- l3 -- l5
notes:
  - text b7 blue: P (Vin の +)
  - text g8 blue: X
```

- Vin は DC 5 V (AD の Supplies か電池)。Vg は AD の Wavegen で作る PWM
  (方形波、100 kHz、デューティ比 50 %、0〜5 V の振幅)
- Q1 (2N7000、N チャネル) が高速スイッチ。**ソースを GND に置く (ローサイド)** ので、
  0〜5 V の PWM でそのまま V_GS = 0 V / 5 V になり、確実にオン・オフする。
  N チャネルを + 側 (ハイサイド) に置くとソースフォロワになり、出力は
  ゲート電圧 − しきい値 (2 V 前後) までしか上がらず Vout = D × Vin にならない
- そのかわり負荷 (Cout・RL) は GND 側ではなく **Vin の + 側 (節点 P) と節点 X の
  間**に置く。Q1 がオンの間は P → 負荷 → L1 → Q1 → GND と流れて L1 に電流を
  ためる。オフの間は L1 の電流が D1 (1N5819、ショットキー) → P → 負荷 → L1 と
  回る (還流)。電流の流れ方はふつうの降圧チョッパと同じなので、
  Vout (P と X の間) = D × Vin がそのまま成り立つ
- L1 (1 mH) と Cout (10 µF) で平らにならし、RL (100 Ω) が負荷。CH1 は P と X の
  間の電圧 (出力) を差動で読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 下の赤レール (+b) = 電源 (5 V) の +、青レール (-b) = GND。電源は AD の Supplies か電池
board: half
parts:
  Q1: transistor h5(S) h6(G) h7(D) 2N7000
  D1: schottky f7(A) f9(K) 1N5819
  L1: inductor/axial g7 g12 1m
  Cout: capacitor/electrolytic i15(+) i12(-) 10u
  RL: resistor j12 j15 100
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - g5 -- -b5 black
  - g9 -- +b9 red
  - g15 -- +b15 red
  - AD.W1 -- g6 yellow
  - AD.GND -- -b3 black
  - AD.1+ -- h15 orange
  - AD.1- -- h12 black
```

- Q1 (2N7000) は平らな面を手前にして左から S・G・D (5・6・7 列)。S (5 列) を
  青レール (GND) へ、G (6 列) を AD の Wavegen (W1) へ
- Q1.D (7 列) がスイッチの節点。D1 (ショットキー) の A を同じ 7 列に挿し、K (9 列) を
  赤レール (+5 V) へ
- L1 (7→12 列) がスイッチの節点から節点 X (12 列) へ。Cout (+ が 15 列、− が 12 列)
  と RL (12・15 列) が出力の平滑と負荷で、15 列 (節点 P) を赤レールへつなぐ
- 出力は GND 基準ではなく、**赤レール (P、15 列) と節点 X (12 列) の間**に出る。
  CH1 は差動入力なので、1+ を 15 列、1− を 12 列にあてて Vout をそのまま読む

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| 電源 | Vin = 5 V (AD の Supplies か電池) |
| Wavegen | PWM: Square、100 kHz、Amplitude 2.5 V、Offset 2.5 V (Duty 50 %、0〜5 V を往復) |
| Scope | CH1 = 出力 (Cout・RL の両端、1+ を P、1− を X にあてる差動)。Time base は 5 µs/div 程度 |
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
D = 75 % なら約 3.68 V。どちらも D1 の順電圧の分だけ理想よりわずかに低い。
式にすると Vout ≒ D × Vin − (1 − D) × 0.3 V)。実物では Q1 のオン抵抗
(2N7000 は V_GS = 5 V で数 Ω) の電圧降下も加わり、さらに数十 mV 低く出る。

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
