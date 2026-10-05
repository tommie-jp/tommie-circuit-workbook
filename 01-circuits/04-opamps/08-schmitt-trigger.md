---
book: circuits
chapter: 4
id: 4-8
title: シュミットトリガ (ヒステリシス)
tier: 100
board: BB
source: 自作
---

# 4-8 シュミットトリガ (ヒステリシス)

4-4 の比較器は帰還が無いので、しきい値ぴったりで LED がちらつくことがあると
書いた。**出力の一部を + 入力へ戻す**と、しきい値が 2 つに分かれて
(ヒステリシス)、ちらつきが止まる。+ 入力へ戻すと、出力の変化をさらに同じ向きに押す
(正帰還。4-1 の負帰還の逆)。4-4 の CdS 回路に 2 本の抵抗を足すだけで直せる。
この題では、点くときと消えるときで、CdS の抵抗のしきい値が違うことを確かめる。

## 回路図

```circuit
title: 図1 シュミットトリガ (CdS + ヒステリシス)
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground c3f0
  CDS1: photoresistor a4 c4 l=$\mathrm{CDS1}$
  RFIX: resistor d4 f4 10k
  VR1: potentiometer a6 c6 10k l=$\mathrm{VR1}$
  Rref: resistor c7 c9 10k
  Rh: resistor b12 b9 100k
  U1: opamp d11 +up
  R1: resistor d13 d15 220
  D1: led d15 f15 red
  DP: diode f18 d18 1N4148
  GD1: ground f15
points:
  vp: a2
  vm: f2
  mid: c2f0
wires:
  - mid -- c3f0
  - a2 -- a4 -- a6
  - f2 -- f4
  - f4 -- f6 -- c6
  - c4 -- d4
  - d4 -- d10 |- U1.-
  - VR1.w |- c7
  - b9 -- c9
  - c9 |- U1.+
  - U1.out -- d12 -- d13
  - b12 -- d12
  - d15 -- d18
  - f15 -- f18
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/08-schmitt-trigger.svg)

- 左の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1・4-4 と同じ)
- − 入力 (CdS・RFIX の分圧) は 4-4 と同じ。VR1 のワイパーはしきい値の基準電圧を
  作るが、**Rref (10 kΩ) を通してから + 入力へ**入れる (4-4 では直結だった)
- **Rh (100 kΩ、出力から + 入力への正帰還) が新顔。** + 入力の電圧は
  「VR1 の基準電圧」と「出力の電圧」を Rref と Rh で分圧した値になり、
  **出力が High か Low かで + 入力のしきい値そのものが動く**
- 出力が High (+3.5V) のときのしきい値は基準電圧より高め、Low (−4.5V) の
  ときは低めにずれる。**一度暗いと判定したら、明るさがしきい値を大きく
  超えるまで戻らない**というのがヒステリシスの効果で、CdS の抵抗が
  しきい値ぴったりで揺れてもちらつかなくなる

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
  Rref: resistor c27 c23 10k
  Rh: resistor d11 d23 100k
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
  - e23 -- g14 orange
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/08-schmitt-trigger.svg)

- 図2 は 4-4 のブレッドボードに Rref と Rh を足した形。左上の AD3 Supplies は図1 の VP・VN (±5 V 電源) に当たる。V+ は上の赤レール、
  GND は上の青レール、V− はブレッドボードの左端を下ろして下の青レールへ入れる (下の赤レールは 1 列目の赤い線で +5V をもらう)。
  PIN 8 (12 列) は `+t12 → a12` で +5V、PIN 4 (15 列) は `j15 → -b15` で −5V へ
- **CdS (13 列) と RFIX (13 列) の分圧点が IN− (PIN 2)。** CdS の他端 (16 列) は下の赤レール (+5V) へ
- VR1 のワイパー (27 列) から Rref (10 kΩ、27 列〜23 列) を通り、橙の線 `e23 → g14` で IN+ (PIN 3、14 列) へ入る
- **Rh (100 kΩ) は出力の 11 列 (上ブロック) から IN+ の 23 列へ渡す。** これで出力の一部が + 入力へ戻る (正帰還)。
  出力 (PIN 1、12 列) は `g12 → g11` と溝をまたぐ線で上ブロックの 11 列へ上げ、R1 (220 Ω)、D1 (LED) を通って GND (6 列) へ。
  DP (1N4148) は D1 と逆並列 (4-4 と同じ。6 列・9 列を D1 と共有)
- Scope はブレッドボードの下に別の箱 (AD3 Scope) で描いた。1+ (橙) は − 入力の 13 列 (`j13`)、2+ (緑) は出力の 12 列 (`j12`)。
  1− と 2− (黒) は上の青レール (GND) へ戻す
- AD3 の電流は 4-4 と同じ。+5V 側は LED の約 7 mA と数 mA、−5V 側は最大約 17 mA で、各レール約 50 mA (USB 給電の目安 250 mW) に収まる

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。CdS を手でゆっくり覆って開く間の − 入力 (CH1) と出力 (CH2) を見る。
電圧がゆっくり動く題で、10 MHz よりずっと遅いから (見る時間は 1 秒)。VR1 は中点 (基準電圧 0 V) に合わせておく。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (− 入力、13 列) | DC、1 V/div |
| Scope CH2 (出力、12 列) | DC、2 V/div |
| Time | 100 ms/div。Mode は Single か Screen にして、手で CdS を覆い、1 秒かけて開く |
| Trigger | CH1、立ち下がり、+1 V (覆い始めた直後) |

```scope
title: 図3 − 入力 (CH1) を下げて上げる — 出力 (CH2) はしきい値が 2 つ
time: 100ms/div
trigger: ch1 falling 0.999V at -5div
ch1: {wave: "= 1V - 10V * (t / 1s) + 20V * ((t - 0.3s) / 1s) * step(t - 0.3s) | clip -2V 1V", range: 1V/div}
ch2: {wave: = -4.5V + 8V * (step(t - 0.141s) - step(t - 0.532s)), range: 2V/div}
cursors: [141ms, 532ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/08-schmitt-trigger.svg)

図3 は − 入力が直線で下がって上がると仮定した想定図で、実際の CdS はなだらかに変わる。CH1 は +1 V (左端のトリガ点) から 0.3 秒で −2 V へ下がり、同じ傾きで戻る。
下がるとき、CH1 が −0.41 V (カーソル X1、0.141 秒) を切った所で CH2 が −4.5 V から +3.5 V に跳ぶ。上がるとき、CH2 が戻るのは +0.32 V (X2、0.532 秒) を越えた所。
カーソルは CH2 が跳ぶ瞬間に置いたので、CH2 の読みは跳びの途中の値になる。CH1 の読み (−0.41 V と +0.32 V) を見る。
切り替わる電圧が 0.73 V ずれることが、この画面でヒステリシスとして見える。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方、比較器として使用) | LM358 |
| CDS1 | 硫化カドミウムセル (CdS) | 明所 約 1 kΩ / 暗所 約 200 kΩ (代表値) |
| RFIX | 抵抗 | 10 kΩ |
| VR1 | 半固定抵抗 (しきい値調整) | 10 kΩ |
| Rref | 抵抗 (基準電圧側) | 10 kΩ |
| Rh | 抵抗 (正帰還、ヒステリシス幅を決める) | 100 kΩ |
| R1 | 抵抗 (LED 電流制限) | 220 Ω |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V |
| DP | 保護ダイオード (D1 と逆並列、4-4 と同じ理由) | 1N4148 |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の Scope 1+/2+ (− 入力と出力)、テスター |

## 見るべき値

4-4 と同じく、CdS を手で覆う量を少しずつ変えながら、テスターで + 入力と − 入力の電圧を測り、
LED が点く所と消える所を探す。表の値は計算値。VR1 を中点 (基準電圧 0 V) にしたときの値。4-4 と同じく
出力は **+3.5 V (High) / −4.5 V (Low)** と仮定する。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| + 入力のしきい値 (出力 High のとき) | 約 +0.32 V | 0 + 3.5 × Rref/(Rh+Rref) = 3.5 × 10/110 |
| + 入力のしきい値 (出力 Low のとき) | 約 −0.41 V | 0 + (−4.5) × 10/110 |
| ヒステリシス幅 (+入力のしきい値の差) | 約 0.73 V | 0.32 − (−0.41) |
| 暗くなって点灯する CdS の抵抗 | 約 11.8 kΩ 以上 | −入力が −0.41 V (出力 Low のときのしきい値) まで下がる CdS の値を分圧式から逆算 |
| 明るくなって消灯する CdS の抵抗 | 約 8.8 kΩ 以下 | −入力が +0.32 V (出力 High のときのしきい値) まで上がる CdS の値を同じ式で逆算 |

**8.8 kΩ〜11.8 kΩ の間は「点いたままか消えたままか、直前の状態で決まる」不感帯。**
4-4 のように帰還が無いと、この不感帯がゼロになってしきい値ぴったりで
ちらつく。Rh を小さく (正帰還を強く) するほど不感帯は広がり、
Rh を大きくするほど 4-4 の無帰還の比較器に近づく。

## 出典

自作。
