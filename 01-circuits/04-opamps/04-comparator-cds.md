---
book: circuits
chapter: 4
id: 4-4
title: 比較器 — CdS でしきい値
tier: 50
source: 自作
board: BB
---

# 4-4 比較器 — CdS でしきい値

OP アンプを帰還無しで使うと**比較器** (コンパレータ) になる。OP アンプは入力の差を数万倍以上に
増幅するので、+ 入力と − 入力のどちらが高いかだけで、出力が + 電源側か − 電源側かに一気に張り付く。
OP アンプの基本形の 4 つ目。この題では CdS (硫化カドミウムセル、光で抵抗が変わる) で明るさを測り、
暗くなったら LED を点ける。

## 回路図

```circuit
title: 図1 比較器 (CdS)
parts:
  B1: battery vp mid 5
  B2: battery mid vm 5
  G1: ground mid
  CDS1: photoresistor a4 c4 l=$\mathrm{CDS1}$
  RFIX: resistor d4 f4 10k
  VR1: potentiometer a6 c6 10k l=$\mathrm{VR1}$
  U1: opamp c9 +up
  R1: resistor c10a5 c12a5 220
  D1: led c12a5 e12a5 red
  DP: diode e15a5 c15a5 1N4148
  GD1: ground e12a5
points:
  vp: a2
  vm: f2
  mid: c2
wires:
  - vp -- a4 -- a6
  - vm -- f4 -- f6
  - c4 -- d4
  - c6 -- f6
  - VR1.w |- U1.+
  - d4 -- d7a5 |- U1.-
  - U1.out -| c10a5
  - c12a5 -- c15a5
  - e12a5 -- e15a5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/04-comparator-cds.svg)

- 左の B1・B2 は ±5 V 電源 (4-1 と同じ)。図1 では CDS1・RFIX と VR1 の電源も兼ねる
- **CDS1・RFIX の分圧点が − 入力。** 明るいと CDS1 は低抵抗 (約 1 kΩ)、
  暗いと高抵抗 (約 200 kΩ) になり、分圧点の電圧が大きく動く
- **VR1 (しきい値の調整) の中点 (ワイパー) が + 入力。** 帰還が無いので、
  − 入力より + 入力が高ければ出力は +V 近く、低ければ −V 近くに張り付く
- R1・D1 は出力が高いときだけ光る LED。**帰還が無い比較器はヒステリシス
  (入力が上がるときと下がるときで、切り替わる点をずらす仕組み) が無い**ので、しきい値ぴったりで LED がちらつくことがある (直すなら 4-8 の
  シュミットトリガ)
- **出力が −V 側 (約 −4.5 V) に張り付くと、D1 の順方向とは逆に約 4.5 V の
  逆電圧がかかってしまう** (LED の逆耐圧は目安 5 V ぎりぎりで危険)。
  **D1 と逆向きに保護ダイオード DP (1N4148) を並列に入れる**。D1 が
  順方向のときは DP は逆バイアスで無視でき、出力が −V に張り付いたときは
  DP が順方向に導通して D1 の両端を DP の順方向降下 (約 0.7 V) までしか
  下げない。これで D1 の逆電圧は逆耐圧の目安 5 V を大きく下回る

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上のレールは +5V/GND。下の赤レールは +5V (1 列目で渡す)、下の青レールは V− (BAT.V− を 28 列の青い線で下ろす)
board: half
parts:
  U1: dip8 @ e10 LM358
  CDS1: photoresistor i14 i11
  RFIX: resistor h11 h7 10k
  VR1: potentiometer b26(1) b27(W) b28(3) 10k
  R1: resistor c9 c6 220
  D1: led b6(A) b3(K) red
  DP: diode d3(A) d6(K) 1N4148
  BAT:
    type: device
    at: top
    label: 電源 ±5V
    pins: [V+, GND, V-]
wires:
  - +t10 -- a10 red
  - +t1 -- +b1 red
  - BAT.V+ -- +t20 red
  - BAT.GND -- -t22 black
  - BAT.V- -- a28 blue
  - e28 -- g28 blue
  - j28 -- -b28 blue
  - +t26 -- a26 red
  - e27 -- f27 orange
  - g27 -- g12 orange
  - j13 -- -b13 blue
  - j7 -- -b7 blue
  - j14 -- +b14 red
  - g10 -- g9 orange
  - f9 -- d9 orange
  - a3 -- -t3 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/04-comparator-cds.svg)

- 図2 の BAT は図1 の B1・B2 (±5 V 電源) に当たる
- **CdS (11 列) と RFIX (11 列) の分圧点が IN− (PIN 2)。** VR1 (上ブロックの右端) の
  ワイパー (27 列) は溝をまたぐオレンジの線で IN+ (PIN 3、12 列) へ
- **V− は下の青レール。** GND (上の青レール) と取り違えない。PIN 4 (13 列)・RFIX・
  VR1 の端子 3 がここへつながる
- 出力 (PIN 1、10 列) は 9 列の線で上ブロックへ上げ、R1 (220 Ω)、D1 (LED) を通って
  GND (3 列、上の青レール) へ。**D1 と逆並列に DP (1N4148)。** DP は 3 列・6 列という
  D1 と同じ列を使うだけで配線が要らない (6 列で D1 のアノード側、3 列でカソード側と
  自動的に同じネットになる)。出力が −V に張り付いたときの逆電圧を DP の順方向降下
  (約 0.7 V) までクランプする。VR1 を回してしきい値の明るさを変える

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方、比較器として使用) | LM358 |
| CDS1 | 硫化カドミウムセル (CdS) | 明所 約 1 kΩ / 暗所 約 200 kΩ (代表値) |
| RFIX | 抵抗 | 10 kΩ |
| VR1 | 半固定抵抗 (しきい値調整) | 10 kΩ |
| R1 | 抵抗 (LED 電流制限) | 220 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| DP | 保護ダイオード (D1 と逆並列) | 1N4148 |
| — | 電源 | ±5 V (電池 2 個) |

## 見るべき値

CdS を手で覆ったり明かりを当てたりしながら、テスターの直流電圧レンジで GND を基準に − 入力 (11 列) と
出力 (10 列) を測り、LED を見る。表の値は計算値。分圧点の電圧 = V− + (V+ − V−) × RFIX / (CDS1 + RFIX)。VR1 を中点
(しきい値 0 V) にしたとき。LM358 の出力は無負荷に近い状態で **+V 側は約
1.5 V 落ち (≈ +3.5 V)、−V 側はほぼ V− まで (≈ −4.5 V)** 振れる (代表値)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 明所 (CDS1 ≈ 1 kΩ) の − 入力 | 約 +4.1 V | RFIX が支配的で +V 寄り |
| 暗所 (CDS1 ≈ 200 kΩ) の − 入力 | 約 −4.5 V | CDS1 が支配的で −V 寄り |
| 明所の出力・LED | 出力 約 −4.5 V、LED 消灯 | −入力 (+4.1V) > +入力 (0V) なので出力は Low。D1 の逆電圧は DP でクランプされ約 −0.7 V (計算値、逆耐圧の目安 5V 以下) |
| 暗所の出力・LED | 出力 約 +3.5 V、LED 点灯 | −入力 (−4.5V) < +入力 (0V) なので出力は High。LED 電流 ≈ (3.5 − 2.0) / 220 ≈ **6.8 mA** (計算値) |
| しきい値が切り替わる CDS1 の値 | 10 kΩ (VR1 が中点のとき) | − 入力 = + 入力 (0 V) になる点。VR1 でこの値を変えられる (電源電圧によらない) |
| 明所のとき R1 を流れる電流 (DP 経由) | 約 17 mA (計算値) | (4.5 − 0.7) / 220 ≈ 17.3 mA。LM358 が吸い込める電流 (典型 20 mA 前後) の内側。R1 の消費電力 ≈ 0.066 W |

CdS の抵抗値は個体差が大きい (データシートの代表値からもずれる)。
実際にテスターで CDS1 の抵抗を明所・暗所で測ってから VR1 を合わせるとよい。

## 出典

自作。
