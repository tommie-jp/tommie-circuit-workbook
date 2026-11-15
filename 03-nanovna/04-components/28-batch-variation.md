---
book: nanovna
chapter: 4
id: 4-28
title: 部品 10 個のばらつき (バッチ)
tier: 200
source: 自作
board: PF
device: H4
---

# 4-28 部品 10 個のばらつき (バッチ)

部品の値には**許容差**がある。100 pF・±5% (記号 J) のコンデンサなら、1 個ずつの値は 95〜105 pF の
どこかにある、という約束である。同じ袋の 10 個を同じ治具で順に測ると、値がどれだけ散らばっているか
(ばらつき) と、許容差の中に収まっているかが分かる。

ばらつきを読むには、**測り方そのものの散らばり**を先に知っておく必要がある。同じ 1 個を 10 回挿し直して測った
散らばりが、10 個を測った散らばりと同じくらいなら、見えているのは部品ではなく挿し方の差である。
この題では、4-1 の直列治具で C0G (温度で値の動かない誘電体。4-21) の 100 pF を 10 MHz で測り、

1. 同じ 1 個を 10 回挿し直す (測り方の散らばり σ<sub>m</sub>)
2. 10 個を 1 回ずつ測る (全体の散らばり σ)

の 2 つから、部品だけの散らばり σ<sub>p</sub> = √(σ² − σ<sub>m</sub>²) を出す。σ (シグマ) は標準偏差。
10 個の掃引と保存を手で繰り返すのは手間なので、10-3 で NanoVNA-Saver とスクリプトに任せる。ここでは手で 1 回通す。

## 回路図

4-1 の直列治具に C1 を挿し、CH1 側の SMA には校正キットの Short を挿す (1 端子にして C1 の Z を読む)。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 直列治具にコンデンサを挿し、先を短絡する
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 6,2 100p
  J2: sma 8,2 Short
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 4,2
  - 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/28-batch-variation.svg)

## 実体配線図

4-1 と同じ基板。C1 を f10–i10 に挿す。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 直列治具に 100 pF を挿す (10 個を順に挿し替える)
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  C1: capacitor/ceramic f10 i10 100p
wires:
  - a10 -- f10
  - i10 -- x10
  - 09 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/28-batch-variation.svg)

- 挿し替えのたびに半田付けするとピンの長さが変わる。**10 個のピンを先に同じ長さ (胴から 5 mm) に切りそろえ**、
  f10・i10 に丸ピンのソケット (IC ソケットをばらした物) を半田付けして、そこへ挿す
- 胴の向き (表の印字を手前) もそろえる。向きで治具の線との間の容量がわずかに変わる

## 部品

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| C1 | 100 pF ±5% (J)、C0G の積層セラミック (リード品) を 10 個 | 同じ袋 (同じロット) から取る。1 個に印 (1〜10) を付けて区別する |
| ソケット | 丸ピンの IC ソケットのピン 2 本 | 挿し替えでピンの長さを変えない |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 5 MHz〜15 MHz |
| 点数 | 101 (0.1 MHz おき) |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru。**10 個を測り終えるまで校正し直さない** |
| 表示 | S11 の \|Z\| と Smith。マーカーは 10 MHz に固定し、Smith の読み値の X を書き取る |
| 平均 | NanoVNA の平均 (または NanoVNA-Saver の Averaging、2-9) を 4 回。読みの揺れを抑える |

10 MHz を選ぶのは、100 pF の X が −159 Ω で 50 Ω から遠すぎず (反射の読みが確か)、ESL の効きも小さいから。

100 pF (ESL 5 nH) — 見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 5M-15M 101
title: 図3 100 pF (C0G) を 10 MHz で — X = −158.8 Ω
dut:
  - series C 100p esl 5n
  - short
traces:
  - S11 z
  - S11 smith
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/28-batch-variation.svg)

読んだ X から容量に直す: C = −1 / (2πf X)。10 MHz なら C [pF] = 15,915.5 / (−X [Ω])。ESL の 5 nH は X を
+0.31 Ω ずらし、読む C を 0.2% 大きくするが、10 個とも同じだけずれるので**ばらつきには効かない**。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 10 MHz の X から容量を読む — ±5% (J) は −167.2〜−151.3 Ω
x: 容量 pF 90..110
y: リアクタンス Ω -180..-140
lines:
  X Ω: 0.314 - 15915.5/x
notes:
  - band 95 105: ±5%
  - mark 95
  - mark 100
  - mark 105
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/graph/28-batch-variation.svg)

## 見るべき値

計算値 (模型)。

| C1 | 10 MHz の X | X から読む C |
| --- | --- | --- |
| 95 pF (−5%) | −167.2 Ω | 95.2 pF |
| 100 pF (公称) | −158.8 Ω | 100.2 pF |
| 105 pF (+5%) | −151.3 Ω | 105.2 pF |

**記録の表** (測って書き込む。下は書き方の見本で、数は入れていない):

| 番号 | 10 MHz の X | C |
| --- | --- | --- |
| 1 | | |
| … | | |
| 10 | | |
| 平均 C̄ | | |
| 標準偏差 σ | | |

平均と標準偏差は C̄ = (1/n) Σ C<sub>i</sub>、σ = √((1/(n − 1)) Σ (C<sub>i</sub> − C̄)²) (n = 10)。
同じ 1 個を 10 回挿し直した値からも同じ式で σ<sub>m</sub> を出す。

分かること:

- ±5% の幅は X で 16 Ω (−167.2〜−151.3 Ω)。Smith の読み値は 0.1 Ω まで出るので、読みの細かさは十分
- **σ<sub>m</sub> が σ の半分より小さければ**、見えているばらつきの大半は部品のもの (σ<sub>p</sub> は σ の 87% 以上)。
  σ<sub>m</sub> のほうが大きいなら、ソケットの接触とピンの長さをそろえ直してから測り直す
- 許容差は「全部がこの中に入る」約束で、10 個の分布が正規分布だとは限らない。10 個では分布の形までは
  分からないので、平均が公称からどちらにずれているかと、σ の大きさを読む
- 10 個の X を 1 つずつ書き取るのは、計る人の読み違いも入る。10-3 では Touchstone を保存して、
  スクリプトで 10 MHz の値を取り出す

## LTspice での確かめ

`sim/28-batch-variation.cir` で、図3 の `dut:` の模型と、95 pF・105 pF に替えた模型を LTspice の AC 解析にかけた
(50 Ω の電源で CH0 を駆動し、先を短絡。CH0 から見た Z = 50·V(n0) / (Vs − V(n0)))。図4 の線は式の算術で確かめた。
理想の模型どうしの比べで、実測ではない。

| 図・表 | 周波数 | 項目 | 図・表の値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (100 pF) | 10 MHz | R / \|X\| | 0.0 Ω / 158.8 Ω | 0.0 Ω / 158.84 Ω | 合う |
| 表 (95 pF) | 10 MHz | \|X\| | 167.2 Ω | 167.22 Ω | 合う |
| 表 (105 pF) | 10 MHz | \|X\| | 151.3 Ω | 151.26 Ω | 合う |
| 図4 | 95 / 100 / 105 pF | X | −167 / −159 / −151 Ω | (算術) 0.314 − 15,915.5 / C で −167.2 / −158.8 / −151.3 Ω | 合う |

4 点すべて合う。LTspice の .meas の出力では X の符号を確かめていないので大きさで比べた (符号はコンデンサなので −)。

## 出典

自作。

参考: [Wikipedia「コンデンサ」](https://ja.wikipedia.org/wiki/コンデンサ)、[Wikipedia「標準偏差」](https://ja.wikipedia.org/wiki/標準偏差)
