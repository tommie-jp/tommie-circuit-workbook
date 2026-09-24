---
book: denken
chapter: 6
id: 6-4
title: OP アンプの反転・非反転増幅 — 仮想短絡
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 6-4 OP アンプの反転・非反転増幅 — 仮想短絡

オペアンプは負帰還がかかると、+ と − の 2 つの入力の電圧が等しくなるように
出力を動かす (**仮想短絡**。電流は流れ込まないが電圧は同じになる)。同じ入力
信号を、反転増幅と非反転増幅の 2 通りに増幅して比べる。1 個のパッケージ
(TL072、2 回路入り) の両方を使う。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_− = V_+ (仮想短絡) | 負帰還がかかったオペアンプの基本 |
| A_v = −R_f / R_in (反転) | 反転入力に信号、+ は GND。V_− ≈ 0 V (仮想接地) |
| A_v = 1 + R_f / R_1 (非反転) | + に信号を直接入れる。V_− ≈ V_+ = 入力そのもの |

## 回路図

```circuit
title: 図1 反転増幅と非反転増幅
parts:
  V1: sine a1 c1 0.3 l=$\mathrm{W1}$
  G1: ground c1
  Rin: resistor a1 a4 10k
  U1: opamp c7 +up TL072
  G2: ground c5
  Rf1: resistor d9 d12 100k
  OUT1: port c14
  U2: opamp h7 +up
  R2b: resistor i3 j3 10k
  G3: ground j3
  R3b: resistor i3 i6 90k
  OUT2: port h14
wires:
  - a4 |- U1.-
  - c5 |- U1.+
  - d9 |- U1.-
  - U1.out -- c12 -- c14
  - d12 -- c12
  - a1 -- h3
  - h3 |- U2.+
  - i3 |- U2.-
  - U2.out -- h5 -- h14
  - i6 -- h5
notes:
  - text c1h0 blue: 反転
  - text h1h0 blue: 非反転
style:
  standard: jis
  grid: on
  pitch: 1.3
```

- 上 (U1) が反転増幅。R_in (10 kΩ) を通して − へ、+ は GND。ゲイン = −R_f1/R_in
  = −100k/10k = **−10 倍**
- 下 (U2) が非反転増幅。入力は直接 + へ (電流が流れ込まないので抵抗を挟まなくてよい)。
  ゲイン = 1 + R3b/R2b = 1 + 90k/10k = **+10 倍**
- 大きさが同じ (10 倍) で符号だけ違うように値を選んである。同じ入力からどちらも作れる

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: full
parts:
  U1: dip8 @ f10 TL072
  Rin: resistor c5 c9 10k
  Rf1: resistor c14 c18 100k
  R2b: resistor c22 c26 10k
  R3b: resistor c30 c34 90k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, V-, GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a5 yellow
  - c9 -- U1.2 green
  - c14 -- U1.2 green
  - U1.1 -- c18 blue
  - AD.GND -- U1.3 black
  - AD.W1 -- U1.5 yellow
  - c26 -- U1.6 green
  - c30 -- U1.6 green
  - U1.7 -- c34 blue
  - c22 -- -t22 black
  - AD.V- -- U1.4 black
  - AD.V+ -- U1.8 red
  - AD.1+ -- a5 yellow
  - AD.1- -- AD.GND black
  - AD.2+ -- U1.1 blue
  - AD.2- -- AD.GND black
notes:
  - text small: TL072 (1 回路目が反転、2 回路目が非反転)。1=OUT1 2=IN1- 3=IN1+ 4=V- 5=IN2+ 6=IN2- 7=OUT2 8=V+
  - text small: 2 回目の測定は AD.2+ を U1.7 (OUT2、非反転側) に挿し替える
```

- Rin・Rf1 が 1 回路目 (反転)、R2b・R3b が 2 回路目 (非反転)。配線は足の名前
  (`U1.2` など) で指しているので、同じ穴を 2 度挿す心配がない

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V |
| Wavegen | W1: Sine、1 kHz、Amplitude 0.3 V、Offset 0 V |
| Scope (1 回目) | CH1 = 入力、CH2 = OUT1 (反転) |
| Scope (2 回目) | CH2 を OUT2 (非反転) に挿し替える |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

## 見るべき値

計算値。オペアンプは理想 (仮想短絡) として計算している。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 入力の振幅 | 0.3 V | — |
| OUT1 (反転) の振幅 | 3.0 V | ゲイン 10 倍。位相は入力と 180° ずれる |
| OUT2 (非反転) の振幅 | 3.0 V | ゲイン 10 倍。位相は入力と同じ (0°) |
| U1.− の電圧 (仮想接地) | ほぼ 0 V | 仮想短絡 (V_− = V_+ = GND) の直接の証拠 |

分かること:

- **大きさは同じでも位相が違う。** 反転は 180°、非反転は 0°。オシロで重ねると
  上下が逆さまの同じ大きさの波形になる
- 反転増幅の入力インピーダンスは R_in (10 kΩ) で決まるが、非反転増幅は
  オペアンプの入力そのもの (非常に高い) — この違いはエミッタフォロワ (6-8) の
  役割と同じ発想
- U1.− を直接測ると、入力振幅が変わってもほぼ 0 V のまま。**仮想短絡は
  電圧が同じという意味で、電流が流れるという意味ではない** (オペアンプの
  入力には電流がほぼ流れ込まない)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
