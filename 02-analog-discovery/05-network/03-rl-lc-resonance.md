---
book: analog-discovery
chapter: 5
id: 5-3
title: RL と LC の共振
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 5-3 RL と LC の共振

コイル L とコンデンサ C を直列にすると、ある周波数で互いのリアクタンスが
打ち消し合い、電流 (抵抗の両端の電圧) が最大になる — **共振**。スイッチ S1 で
C1 を短絡すると L と R だけの回路 (RL、共振しない) に、開けると L・C・R の
直列共振回路になる。同じ部品で 2 つの性質を見比べる。

## 回路図

```circuit
title: 図1 RL と LC の共振
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  L1: inductor a5 a7 10m
  C1: capacitor a7 a9 100n
  S1: switch b7 b9
  R1: resistor a10 c10 100 i=I
  M2: voltmeter a12 c12 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c10 -- c12
  - a7 -- b7
  - a9 -- b9
  - a9 -- a10
  - a10 -- a12
```

- S1 は C1 と**並列** (バイパス)。**S1 を閉じると C1 が短絡され**、L1 (10 mH) と
  R1 (100 Ω) だけの RL 回路になる。**S1 を開くと** C1 (100 nF) が直列に効いて
  LC 共振回路になる
- CH2 は R1 の両端 (= 電流 I に比例) を読む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  L1: inductor/axial c5 c10 10m
  C1: capacitor c12 c17 100n
  S1: switch e12 e17
  R1: resistor c19 c24 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t2 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - a10 -- a12 green
  - a17 -- a19 green
  - AD.2+ -- b19 blue [h10]
  - AD.2- -- -t22 black
  - a24 -- -t24 black
```

S1 は C1 (12〜17 列) と**同じ 2 列**の別の行 (d 行) に挿すだけで並列になる
(同じ列は内部でつながっているため)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 0.5 V |
| Network | S1 を閉じて (RL): Start 100 Hz、Stop 100 kHz、Log、Steps 101。S1 を開いて (LC): Start 1 kHz、Stop 20 kHz、Log、Steps 101 |

## 見るべき値

計算値。**RL** (S1 閉、C1 短絡): 利得 (CH2/CH1) = R / √(R² + (2πfL)²)。
角周波数 corner **f<sub>RL</sub> = R / (2πL) = 100 / (2π × 10 mH) ≈ 1.59 kHz**。

| RL: 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 Hz | −0.02 dB | −3.6° |
| 1.59 kHz (f<sub>RL</sub>) | −3.01 dB | −45.0° |
| 10 kHz | −16.07 dB | −81.0° |

**LC** (S1 開、直列 RLC): 共振周波数 **f₀ = 1/(2π√(LC)) = 1/(2π√(10 mH × 100 nF))
≈ 5.03 kHz**。Q = ω₀L/R ≈ 3.16、帯域幅 BW = f₀/Q ≈ 1.59 kHz (RL のときの
corner と同じ値になる — これは R/(2πL) が Q に依らず帯域幅を決めるため)。

| LC: 周波数 | 利得 (CH2/CH1) | 位相 |
| --- | --- | --- |
| 4.30 kHz (f₀ − BW/2、下側 −3 dB 点) | −3.01 dB | +45.0° |
| 5.03 kHz (f₀、共振点) | 0.00 dB (最大、電流最大) | 0.0° |
| 5.89 kHz (f₀ + BW/2、上側 −3 dB 点) | −3.01 dB | −45.0° |

分かること:

- **S1 を閉じると RL の corner (1.59 kHz) しか出ず、共振の山は見えない。**
  S1 を開いた瞬間に 5.03 kHz を頂点にした山 (0 dB) が現れる — C1 が直列に
  入って初めて共振が起きることが目で分かる
- **共振点では利得がちょうど 0 dB** (L と C のリアクタンスが打ち消し合い、
  回路のインピーダンスが R だけになるため、CH2 = CH1 になる)
- **Q が高いほど山が鋭くなる。** ここでは Q ≈ 3.16 (10 mH の巻線抵抗を無視した
  計算値)。実測では巻線抵抗の分だけ R が実質大きくなり、山はもう少し丸くなる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節)。
