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
  V1: sine 1,1 1,3 l=$\mathrm{W1}$
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  L1: inductor 5,1 7,1 10m
  C1: capacitor 7,1 9,1 100n
  S1: switch 7,2 9,2
  R1: resistor 10,1 10,3 100 i=I
  M2: voltmeter 12,1 12,3 l=$\mathrm{CH2}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 10,3 -- 12,3
  - 7,1 -- 7,2
  - 9,1 -- 9,2
  - 9,1 -- 10,1
  - 10,1 -- 12,1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/circuit/03-rl-lc-resonance.svg)

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
  C1: capacitor d10 d15 100n
  S1: switch b10 b15
  R1: resistor c15 c19 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t10 black
  - AD.2+ -- a15 blue
  - AD.2- -- -t17 black
  - a19 -- -t19 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/breadboard/03-rl-lc-resonance.svg)

S1 は C1 (10〜15 列) と**同じ 2 列**の別の行 (b 行) に挿すだけで並列になる
(同じ列は内部でつながっているため)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Amplitude 0.5 V |
| Network | S1 を閉じて (RL): Start 100 Hz、Stop 100 kHz、Log、Steps 101。S1 を開いて (LC): Start 1 kHz、Stop 20 kHz、Log、Steps 101 |

```scope
title: 図3 共振点 5.03 kHz では CH2 (R の両端) が CH1 と同じ振幅・同じ位相になる
time: 50us/div
trigger: ch1 rising 0V
ch1: {wave: sine 5.03kHz 0.5V, range: 200mV/div}
ch2: {wave: sine 5.03kHz 0.5V, range: 200mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/scope/03-rl-lc-resonance.svg)

図3 は S1 を開いて W1 を 5.03 kHz にしたときの画面 (計算値)。L と C のリアクタンスが打ち消し合って
回路のインピーダンスが R<sub>1</sub> だけになり、CH2 は CH1 に重なる (利得 0 dB・位相 0°)。
周波数をずらすと CH2 は小さくなり、f₀ の下では進み、上では遅れる (下の −3 dB 点で ±45°)。

## 見るべき値

計算値。**RL** (S1 閉、C1 短絡): 利得 (CH2/CH1) = R / √(R² + (2πfL)²)。
折れ点周波数 **f<sub>RL</sub> = R / (2πL) = 100 / (2π × 10 mH) ≈ 1.59 kHz**。

| RL: 周波数 | 利得 | 位相 |
| --- | --- | --- |
| 100 Hz | −0.02 dB | −3.6° |
| 1.59 kHz (f<sub>RL</sub>) | −3.01 dB | −45.0° |
| 10 kHz | −16.07 dB | −81.0° |

**LC** (S1 開、直列 RLC): 共振周波数 **f₀ = 1/(2π√(LC)) = 1/(2π√(10 mH × 100 nF))
≈ 5.03 kHz**。Q = ω₀L/R ≈ 3.16、帯域幅 BW = f₀/Q ≈ 1.59 kHz (RL のときの
折れ点と同じ値になる。直列 RLC の帯域幅は R/(2πL) で決まり、C に依らないため)。

| LC: 周波数 | 利得 (CH2/CH1) | 位相 |
| --- | --- | --- |
| 4.30 kHz (f₀ − BW/2、下側 −3 dB 点) | −3.01 dB | +45.0° |
| 5.03 kHz (f₀、共振点) | 0.00 dB (最大、電流最大) | 0.0° |
| 5.89 kHz (f₀ + BW/2、上側 −3 dB 点) | −3.01 dB | −45.0° |

図4 は S1 を閉じた RL と開いた LC を同じ 100 Hz〜100 kHz に並べたもの、
図5 は LC の山を計器の設定と同じ 1〜20 kHz で拡げたもの。

```graph
title: 図4 S1 を開くと 5.03 kHz に 0 dB の山が現れる — RL は 1.59 kHz から落ちるだけ
x: 周波数 Hz log 100..100k
y:
  - 利得 dB
  - 位相 deg
lines:
  RL (S1 閉) 利得 dB: -10*log10(1+(0.0628319*x/100)^2)
  LC (S1 開) 利得 dB: -10*log10(1+((0.0628319*x-1/(6.28319e-7*x))/100)^2)
  RL (S1 閉) 位相 deg: -deg(atan(0.0628319*x/100))
  LC (S1 開) 位相 deg: -deg(atan((0.0628319*x-1/(6.28319e-7*x))/100))
notes:
  - level -3dB
  - mark 100
  - mark 1.59k
  - mark 5.033k
  - mark 10k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/03-rl-lc-resonance-1.svg)

```graph
title: 図5 LC の山 — −3 dB の 2 点 (4.30 kHz・5.89 kHz) で位相は ±45°
x: 周波数 Hz log 1k..20k
y:
  - 利得 dB
  - 位相 deg
lines:
  利得 dB: -10*log10(1+((0.0628319*x-1/(6.28319e-7*x))/100)^2)
  位相 deg: -deg(atan((0.0628319*x-1/(6.28319e-7*x))/100))
notes:
  - level -3dB
  - band 4.30k 5.89k: 帯域幅 1.59 kHz
  - mark 4.30k
  - mark 5.033k
  - mark 5.89k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/05-network/graph/03-rl-lc-resonance-2.svg)

分かること:

- **S1 を閉じると RL の折れ点 (1.59 kHz) しか出ず、共振の山は見えない。**
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
