---
book: denken
chapter: 12
id: 12-4
title: 単相 3 線式 — 中性線が切れると電圧が偏る
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 12-4 単相 3 線式 — 中性線が切れると電圧が偏る

家庭への配電の単相 3 線式は、変圧器の二次巻線の中点から中性線を出し、両側の 2 本との間に
100 V ずつ、外側の 2 本の間に 200 V を取り出す。中性線がつながっていれば、両側の負荷の大きさが違っても
それぞれに 100 V が掛かる。**中性線が切れると、2 つの負荷は 200 V に直列につながり、軽い (抵抗の大きい)
負荷の側の電圧が上がる。** AD の Supplies の ±5 V を 2 つの巻線に見立て、5 V を 100 V の代わりにして確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Va = Vb = V | 中性線があるとき。両側の負荷には、負荷の大きさによらず V ずつ掛かる |
| I_N = Ib − Ia | 中性線の電流は、両側の負荷の電流の差 (向きが逆なので打ち消し合う) |
| Va = 2V × Ra / (Ra + Rb) | 中性線が切れたとき。Ra と Rb が 2V に直列になった分圧 |
| Ra > Rb なら Va > V | 軽い負荷 (抵抗の大きい Ra) の側が V を超える |

実際の配電は交流だが、2 つの巻線の電圧は向きが逆で大きさが同じなので、抵抗の負荷なら直流の +V と −V で
同じ電圧の比になる。ここでは直流で模す。

## 回路図

```circuit
title: 図1 単相 3 線式の模型 (S1 が中性線)
style:
  standard: jis
  pitch: 1.2
parts:
  V1: vsource 1,1 1,5 5
  V2: vsource 1,5 1,9 5
  G1: ground 3,5
  S1: switch 5,5 7,5
  Ra: resistor 10,1 10,5 1k i=Ia
  Rb: resistor 10,5 10,9 470 i=Ib
  M1: voltmeter 12,1 12,5 l=$\mathrm{CH1}$
  M2: voltmeter 12,5 12,9 l=$\mathrm{CH2}$
wires:
  - 1,1 -- 10,1 -- 12,1
  - 1,5 -- 3,5 -- 5,5
  - 7,5 -- 10,5 -- 12,5
  - 1,9 -- 10,9 -- 12,9
notes:
  - text 5,4 blue: 中性線
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/circuit/04-single-phase-three-wire-1.svg)

- V1 と V2 が変圧器の二次巻線の両半分。AD の Supplies の V+ (+5 V) と V− (−5 V)。2 つの中点
  (AD の GND) が中性線の出どころで、ここを接地する (試験の図の B 種接地にあたる)
- Ra (1 kΩ) が軽い負荷、Rb (470 Ω) が重い負荷。電流で言えば Rb が Ra の約 2 倍
- S1 が中性線。閉じれば中性線あり、開けば中性線が切れた状態
- CH1 (M1) が Ra に掛かる電圧 Va、CH2 (M2) が Rb に掛かる電圧 Vb。どちらも差動で挟む

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Ra: resistor c8 c13 1k
  S1: switch b15 b18
  Rb: resistor e13 e21 470
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [1+, V+, GND, 1-, 2+, 2-, V-]
wires:
  - AD.V+ -- +t10 red
  - AD.GND -- -t11 black
  - AD.V- -- b21 blue
  - +t8 -- a8 red
  - AD.1+ -- b8 orange
  - AD.1- -- a13 white
  - AD.2+ -- a15 green
  - AD.2- -- a21 purple
  - d13 -- d15 yellow
  - a18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/breadboard/04-single-phase-three-wire.svg)

- 上の赤いレールが +5 V (V+)、上の青いレールが中性線の元の GND。−5 V (V−) は青い線で 21 列へ直に入れる
- Ra (8〜13 列) が +5 V と負荷の中点 (13 列) の間、Rb (13〜21 列) が中点と −5 V の間
- 中点 (13 列) から黄の線で 15 列へ渡し、S1 (15〜18 列) と 18 列の黒い線で GND へ戻すのが中性線。
  S1 を抜くと中性線が切れる
- CH1 (1+/1−) が Ra の両端 (8 列と 13 列)、CH2 (2+/2−) が Rb の両端 (中点とつながった 15 列と 21 列)。**1− と 2− を GND に
  つながない** (つなぐと中性線を足したことになる)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、V− = −5 V。電流は V− 側で最大 10.6 mA (53 mW)、USB の 250 mW に収まる |
| Voltmeter | CH1 = Va (Ra の両端)、CH2 = Vb (Rb の両端)。どちらも DC |

この題はオシロの図を付けない — 見るのは時間で変わらない直流の電圧だけで、Voltmeter (テスターの読み値) で足りる。

### オシロスコープと発振器

この題は差動の題で、AD の 1− は負荷の中点 (13 列)、2− は −5 V (21 列) に当たっている
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md))。汎用オシロのグランドクリップは
大地につながっていて、**中性線の切れた中点に当てると、クリップが中性線の代わりになる**。S1 を抜いても
中点が GND に結ばれたままになり、電圧の偏りが見えない (電源の COM が大地につながっている場合)。
21 列に当てれば −5 V を大地へ短絡する。

そこで Supplies は ±5 V の出せる安定化電源 (2 出力を直列にして中点を COM に) に替え、電流制限は各 20 mA
にする ([0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。この回路は最大 10.6 mA)。COM を
中性線の元 (上の青いレール) にし、グランドクリップはそこだけに当てる。**中点の電位 Vn を CH1 の先端で
GND 基準に測り**、Va と Vb は計算で出す (図3)。

```circuit
title: 図3 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: vsource 1,1 1,5 5
  V2: vsource 1,5 1,9 5
  G1: ground 3,5
  S1: switch 5,5 7,5
  Ra: resistor 10,1 10,5 1k
  Rb: resistor 10,5 10,9 470
  M1: voltmeter 12,5 12,7 l=$\mathrm{CH1}$
  G2: ground 12,7
wires:
  - 1,1 -- 10,1
  - 1,5 -- 3,5 -- 5,5
  - 7,5 -- 10,5 -- 12,5
  - 1,9 -- 10,9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/12-power-systems/circuit/04-single-phase-three-wire-2.svg)

- CH1 の先端を 13 列 (中点)、グランドクリップを上の青いレール (COM)。ブレッドボードの部品は図2 のまま
- Va = 5 V − Vn、Vb = Vn + 5 V (電源の ±5 V は CH2 で一度ずつ確かめておく。先端を 8 列と 21 列、
  クリップは COM)
- S1 を閉じると Vn = 0 V、抜くと Vn = −1.80 V (計算値)。Vn が 0 から動いた分だけ、両側の電圧が偏る
- プローブの入力抵抗 (1 MΩ か 10 MΩ) も中点と COM の間の「細い中性線」になるが、中点から見た抵抗
  (Ra と Rb の並列、320 Ω) の 3000 倍以上あり、Vn への影響は 0.03 % 以下
- テスター (電池で動き、大地から浮いている) なら、図1 のとおり Ra と Rb の両端を直に挟んでよい

## 見るべき値

計算値。V = 5 V (両側)、Ra = 1 kΩ、Rb = 470 Ω。

| 状態 | Va (CH1) | Vb (CH2) | 中点の電位 Vn | 電流 | 分かること |
| --- | --- | --- | --- | --- | --- |
| S1 を閉じる (中性線あり) | 5.00 V | 5.00 V | 0 V | Ia = 5.00 mA、Ib = 10.6 mA、I_N = 5.64 mA | 負荷が違っても両側とも 5 V |
| S1 を開く (中性線が切れた) | 6.80 V | 3.20 V | −1.80 V | Ia = Ib = 6.80 mA、I_N = 0 | 軽い側 (Ra) が 1.36 倍に上がる |
| Rb も 1 kΩ にして S1 を開く (平衡) | 5.00 V | 5.00 V | 0 V | Ia = Ib = 5.00 mA | 平衡なら切れても偏らない |

分かること:

- **中性線が切れると、軽い負荷の側の電圧が上がる。** 実際の 100 V の配電なら、同じ比で 136 V が
  軽い側の機器に掛かり、機器を壊すことがある。重い側は 64 V に下がって動かなくなる
- 中性線の電流は両側の電流の差 (5.64 mA)。両側の負荷をそろえる (平衡させる) ほど中性線の電流は減り、
  切れたときの偏りも小さくなる
- このため配線の決まり (電気設備の技術基準の解釈や内線規程) では、**中性線にはヒューズなどの過電流遮断器を入れず**、
  開閉器は 3 本を同時に切るものにする (中性線だけが切れると上の偏りが起きる)。住宅の主幹には、中性線が切れたときに
  電圧の上がりを検出して切る「中性線欠相保護」付きの遮断器が使われる
- 中性線の電流が小さいことは、線路の損失の面でも有利。Ra = Rb なら中性線に電流が流れず、200 V の 2 線で
  送るのと同じになる

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Voltmeter の節)。
