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
  Rin: resistor a3 a5 10k
  Rf1: resistor a6 a9 100k
  U1: opamp c7 +down TL072
  G2: ground d6
  OUT1: port c12
  U2: opamp g7 +up
  R3b: resistor i6 i9 90k
  R2b: resistor i5 k5 10k
  G3: ground k5
  OUT2: port g12
wires:
  - a1 -- a3
  - a5 -- a6
  - a5 |- U1.-
  - d6 |- U1.+
  - a9 -- a10 -- c10
  - U1.out -- c10 -- c12
  - a2 |- U2.+
  - i5 |- U2.-
  - i5 -- i6
  - i9 -- i10 -- g10
  - U2.out -- g10 -- g12
notes:
  - text c1h0 blue: 反転
  - text h3h0 blue: 非反転
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
board: half
parts:
  U1: dip8 @ f14 r180 TL072
  Rin: resistor c10 c16 10k
  Rf1: resistor b16 b17 100k
  R2b: resistor i11 i15 10k
  R3b: resistor h15 h16 90k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, W1, 1+, 1-, V-, 2+, 2-]
wires:
  - AD.V+ -- +t6 red
  - AD.GND -- -t8 black
  - AD.W1 -- a10 yellow
  - AD.1+ -- b10 yellow [h10]
  - AD.1- -- -t12 black
  - AD.V- -- a14 purple
  - AD.2+ -- a17 blue
  - AD.2- -- -t19 black
  - a15 -- -t15 black
  - e10 -- f10 yellow
  - g10 -- g14 yellow
  - j11 -- -b11 black
  - j17 -- +b17 red
  - -t2 -- -b2 black
  - +t29 -- +b29 red
notes:
  - text small: TL072 (1 回路目が反転、2 回路目が非反転)。1=OUT1 2=IN1- 3=IN1+ 4=V- 5=IN2+ 6=IN2- 7=OUT2 8=V+
  - text small: 2 回目の測定は AD.2+ を U1.7 (OUT2、非反転側) に挿し替える
```

- Rin・Rf1 が 1 回路目 (反転)、R2b・R3b が 2 回路目 (非反転)。U1 は `r180` で置き、
  上の段 (e14〜e17) が 4・3・2・1 番 (1 回路目の側)、下の段 (f14〜f17) が 5・6・7・8 番
  (2 回路目の側)。帰還抵抗 Rf1 (2 番↔1 番) と R3b (6 番↔7 番) は隣り合う列に立てて挿す
- 入力 (W1) は 10 列。黄色の線で溝を渡り、下の段の g 行で 5 番 (IN2+) へ運ぶ。
  上の段は −t が GND、下の段は左端の黒い線で −b も GND、右端の赤い線で +b も V+ にしてある

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
