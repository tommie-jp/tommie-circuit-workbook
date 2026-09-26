---
book: denken
chapter: 4
id: 4-1
title: 三相の信号を作る — AD の 2 ch (位相 120°) と OP アンプで 3 相目
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-1 三相の信号を作る — AD の 2 ch (位相 120°) と OP アンプで 3 相目

三相交流は 120° ずつずれた 3 つの正弦波。Analog Discovery (AD) の波形発生器
(Wavegen) は W1・W2 の 2 ch しか無いので、1 相目・2 相目は AD からそのまま出し、
3 相目はオペアンプの反転加算回路で作る。**平衡三相は 3 つの和が常に 0** という
性質を使うと、3 相目 = −(1 相目 + 2 相目) で作れる。この回路を 4-2〜4-4 でも
そのまま使う。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| v₁ = Vm sin θ、v₂ = Vm sin(θ − 120°) | AD の W1・W2 (振幅 Vm、位相差 120°) |
| v₃ = −(v₁ + v₂) | 3 相目。オペアンプの反転加算 (ゲイン −1 を 2 つ足す) |
| v₁ + v₂ + v₃ = 0 | 平衡三相の性質。3 つの瞬時値の和は常に 0 |
| v₃ = Vm sin(θ + 120°) | 上の式を展開すると、3 相目も同じ振幅で 120° 進んだ正弦波になる |

## 回路図

```circuit
title: 図1 三相の信号を作る
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
wires:
  - a4 |- U1.-
  - e5 |- U1.-
  - c6 |- U1.+
  - d11 |- U1.-
  - U1.out -- c14 -- c16
  - d14 -- c14
notes:
  - text c16 blue: 3 相目
style:
  standard: jis
  grid: on
  pitch: 1.4
```

- V1 (W1) が 1 相目 (0°)、V2 (W2) が 2 相目 (−120°)。どちらも AD の Wavegen が
  そのまま出す — AD の Wavegen 出力インピーダンスは低いので、バッファなしで
  1 相目・2 相目として使ってよい
- U1 (TL071) は R1・R2・Rf が全部 10 kΩ の**反転加算回路**。出力 = −(1 相目 + 2 相目)。
  非反転入力は GND (G3) に落として仮想接地を作る
- R1・R2 (各 10 kΩ) が AD の Wavegen から引く電流は 1 V ÷ 10 kΩ = 0.1 mA だけ。
  Wavegen の上限 10 mA に対して十分小さい

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (1 回目)
# 上のブロック (a〜e) に TL071 の入力側と R1・R2、下のブロック (f〜j) に出力側と Rf
board: half
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 2-, V-, W1, 1+, W2, 2+]
wires:
  - AD.V+ -- +t4 red
  - AD.GND -- -t6 black
  - AD.1- -- -t8 black
  - AD.2- -- -t10 black
  - AD.V- -- a13 purple
  - AD.W1 -- c17 yellow [h-10]
  - AD.1+ -- a17 yellow
  - AD.W2 -- b25 orange [h-10]
  - AD.2+ -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
notes:
  - text small: 2 番 (IN-) に R1・R2・Rf が集まる。2 回目は AD.2+ を U1.6 に挿し替える
```

- TL071 (dip8) は `r180` で置き、1 番が e16 に来る。上の段 (e13〜e16) が 4・3・2・1 番、
  下の段 (f13〜f16) が 5・6・7・8 番。ピン: 1 = NC、2 = IN−、3 = IN+、4 = V−、
  5 = NC、6 = OUT、7 = V+、8 = NC。**1・5・8 番はオフセット調整用**
  (データシートどおり未使用。空けたままでよい)
- IN− (15 列) は d 行の緑の線で 21 列へ延ばし、R1・R2 と、溝を渡って下の段の Rf が集まる。
  IN+ (14 列) は GND レール (−t)、V+ (7 番、下の段 15 列) は下の + レールから取る
  (左端の赤い線で上の + レールとつなぐ)
- V+ (7 番) と V− (4 番) は AD の Supplies の ±5 V。オペアンプの出力は最大でも
  1 V 程度なので、±5 V の電源に対して十分な余裕がある

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: Sine、1 kHz、Amplitude 1 V、Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れてから波形を出す |
| Scope (1 回目) | CH1 = W1 (1 相目)、CH2 = W2 (2 相目)。どちらも DC 結合 |
| Scope (2 回目) | CH2 を U1 の 6 番 (3 相目) に挿し替える。CH1 は 1 相目のまま |
| Measure | CH1 に対する CH2 の Phase (位相差) と、CH1・CH2 の振幅 (Amplitude) |

## 見るべき値

計算値。オペアンプは理想 (仮想短絡) として計算している。

| 測る所 | 1 回目 (CH1=1 相目, CH2=2 相目) | 2 回目 (CH1=1 相目, CH2=3 相目) |
| --- | --- | --- |
| CH1 の振幅 | 1.00 V | 1.00 V |
| CH2 の振幅 | 1.00 V | 1.00 V |
| CH1 に対する CH2 の位相 | −120° | +120° |

分かること:

- **3 相目も 1・2 相目と同じ振幅 1.00 V になる。** −(v₁+v₂) を計算すると、
  自動的に「同じ振幅・120° 進み」の正弦波が出てくる
- 3 つの位相差はどの組も 120°(絶対値)。1 相目を基準にすると 2 相目は −120°、
  3 相目は +120°(= −240°) で、これが**相順**(4-9 で扱う)を決める
- オシロの 2 ch では 3 つを同時に見られないので、2 回に分けて測る。**同時に見たい
  ときは 3-19 のリサジュー図形の要領で、1 相目と 3 相目を X-Y 表示にしてもよい**

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
