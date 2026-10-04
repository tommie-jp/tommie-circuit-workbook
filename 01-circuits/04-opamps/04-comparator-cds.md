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
  VP: vsource vp mid 5
  VN: vsource mid vm 5
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

- 左の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)。図1 では CDS1・RFIX と VR1 の電源も兼ねる
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
# 上のレールは +5V (赤) と GND (青)。下の赤レールは +5V (1 列目で渡す)、下の青レールは −5V (V−)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 Supplies ±5V
    pins: [V+, GND, V-]
  SC:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1+, 2+, 1-, 2-]
  U1: dip8 @ e12 LM358
  CDS1: photoresistor i16 i13
  RFIX: resistor h13 h9 10k
  VR1: potentiometer b26(1) b27(W) b28(3) 10k
  R1: resistor c11 c9 220
  D1: led b9(A) b6(K) red
  DP: diode d6(A) d9(K) 1N4148
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.V- -- -b4 blue
  - +t1 -- +b1 red
  - +t12 -- a12 red
  - +t26 -- a26 red
  - e28 -- g28 blue
  - j28 -- -b28 blue
  - e27 -- f27 orange
  - g27 -- g14 orange
  - j15 -- -b15 blue
  - j9 -- -b9 blue
  - j16 -- +b16 red
  - g12 -- g11 orange
  - f11 -- e11 orange
  - a6 -- -t6 black
  - SC.1+ -- j13 orange
  - SC.2+ -- j12 green
  - SC.1- -- -t19 black
  - SC.2- -- -t20 black
notes:
  - text below: 上は 赤 +5V・青 GND、下は 赤 +5V・青 −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/04-comparator-cds.svg)

- 図2 の左上の AD3 Supplies は図1 の VP・VN (±5 V 電源) に当たる。V+ は上の赤レール、GND は上の青レール、
  V− は板の左端を下ろして下の青レールへ入れる。下の赤レールは 1 列目の赤い線で上の赤レールから +5V をもらう
- **V− は下の青レール。** GND (上の青レール) と取り違えない。PIN 4 (15 列)・RFIX・
  VR1 の端子 3 がここへつながる。PIN 8 (12 列) は `+t12--a12` で +5V へ
- **CdS (13 列) と RFIX (13 列) の分圧点が IN− (PIN 2)。** CdS の他端 (16 列) は下の赤レール (+5V) へ。
  VR1 (上ブロックの右端) のワイパー (27 列) は溝をまたぐオレンジの線と `g27--g14` で IN+ (PIN 3、14 列) へ
- 出力 (PIN 1、12 列) は `g12--g11` と溝をまたぐ線で上ブロックの 11 列へ上げ、R1 (220 Ω)、D1 (LED) を通って
  GND (6 列、上の青レール) へ。**D1 と逆並列に DP (1N4148)。** DP は 6 列・9 列という
  D1 と同じ列を使うだけで配線が要らない (9 列で D1 のアノード側、6 列でカソード側と
  自動的に同じネットになる)。出力が −V に張り付いたときの逆電圧を DP の順方向降下
  (約 0.7 V) までクランプする。VR1 を回してしきい値の明るさを変える
- Scope は板の下に別の箱 (AD3 Scope) で描いた。1+ (橙) は − 入力の 13 列 (`j13`)、2+ (緑) は出力の 12 列 (`j12`) に挿し、
  1− と 2− (黒) は板の右の空いた所から上の青レール (GND) へ戻す
- AD3 の Supplies の電流は、+5V 側が LED の約 7 mA と CdS・VR1・OP アンプの数 mA、−5V 側が
  明所で R1・DP を通って吸い込む約 17 mA が最大。どちらも USB 給電の目安 50 mA (250 mW) に収まる

## 計器の設定

テスターの代わりに AD3 の Scope で、CdS を手で覆った瞬間の − 入力 (CH1) と出力 (CH2) の変わり方を見る。
電圧が 1 回だけ大きく変わる題で、10 MHz よりずっと遅いから (見る時間は数秒)。VR1 は中点 (しきい値 0 V) に合わせておく。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (− 入力、13 列) | DC、2 V/div |
| Scope CH2 (出力、12 列) | DC、2 V/div |
| Time | 100 ms/div。Mode は Repeated でなく Single か Screen にして、手で CdS を覆う |
| Trigger | CH1、立ち下がり、0 V (− 入力が + 入力の 0 V を下回った瞬間) |

```scope
title: 図3 CdS を覆った瞬間 — − 入力 (CH1) が 0 V を切ると出力 (CH2) が High に
time: 100ms/div
trigger: ch1 falling 0V
ch1: {wave: = 4.1V - 8.6V * step(t), range: 2V/div}
ch2: {wave: = -4.5V + 8V * step(t), range: 2V/div}
cursors: [-300ms, 300ms]
measure: [vmax, vmin]
notes:
  - text ch2 0 3.5V: 出力が +3.5 V へ (LED 点灯)
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/04-comparator-cds.svg)

図3 の波形は表の計算値を階段で描いた想定図で、実際の CdS は変わり方が数十 ms ほどなだらかになる。CH1 が +4.1 V (明るい) から
−4.5 V (暗い) に動き、0 V を横切った所で CH2 が −4.5 V から +3.5 V に跳ぶ。CH1 が 0 V を越えるたびに CH2 が反転するので、
しきい値ぴったりでちらつく様子 (ヒステリシスが無いこと) もこの画面で見える。

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
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の Scope 1+/2+ (− 入力と出力)、テスター |

## 見るべき値

CdS を手で覆ったり明かりを当てたりしながら、テスターの直流電圧レンジか AD3 の Scope (図3) で GND を基準に − 入力 (13 列) と
出力 (12 列) を測り、LED を見る。表の値は計算値。分圧点の電圧 = V− + (V+ − V−) × RFIX / (CDS1 + RFIX)。VR1 を中点
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
