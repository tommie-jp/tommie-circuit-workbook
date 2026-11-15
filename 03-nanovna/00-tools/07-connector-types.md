---
book: nanovna
chapter: 0
id: 0-7
title: コネクタの種類 (SMA / RP-SMA / U.FL / BNC / N) と変換
tier: 200
source: 自作
board: —
device: H4
---

# 0-7 コネクタの種類 (SMA / RP-SMA / U.FL / BNC / N) と変換

NanoVNA のポートは SMA のメス。ところが測りたい物には、Wi-Fi のアンテナの RP-SMA、
モジュールの U.FL、計測器の BNC、屋外のアンテナの N が付いている。
**変換アダプタを挟めば物理的にはつながるが、アダプタ 1 つごとに電気長と反射が足される**。
この題では、コネクタの違いを表で押さえ、アダプタを挟んだときに画面がどう変わるかを見る。

## 5 つのコネクタ

| コネクタ | 特性インピーダンス | 使える周波数 (目安) | 締め方 | 抜き差しの寿命 | よく見る所 |
| --- | --- | --- | --- | --- | --- |
| SMA | 50 Ω (オーム) | DC〜18 GHz | ねじ | 500 回 (トルクで締めたとき) | NanoVNA・tinySA・治具 |
| RP-SMA | 50 Ω | SMA と同じ | ねじ | SMA と同じ | Wi-Fi のルーターとアンテナ |
| U.FL | 50 Ω | DC〜6 GHz | 押し込み | 約 30 回 | 無線モジュールの基板の上 |
| BNC | **50 Ω と 75 Ω の 2 種類** | 4 GHz まで (多くは 2 GHz まで) | バヨネット (差して回す) | — | オシロ・信号発生器・映像 |
| N | 50 Ω (75 Ω もある) | DC〜11 GHz | ねじ | — | 屋外のアンテナ・大電力 |

- **RP-SMA (逆極性 SMA)** は、ねじの向きはそのままで**中心のピンとソケットを入れ替えた**もの。
  RP-SMA のメス (外にねじ) の中心はピン、RP-SMA のオス (内にねじ) の中心はソケット。
  **SMA と RP-SMA は、ねじは締まるのに中心がつながらない** (下の図4)。SMA オスと RP-SMA メスは
  ピンどうしが突き当たり、ピンを曲げることもある
- **U.FL** は抜き差しが約 30 回までの「付けたら外さない」コネクタ。U.FL–SMA の変換ケーブルを
  付けたままにし、校正は SMA の側で取る。抜くときは真上へ引く (斜めに引くと基板のパッドごと剥がれる)
- **BNC の 50 Ω と 75 Ω は、外から見分けにくい**。75 Ω の BNC は映像機器の物で、50 Ω の系に混ぜると
  反射が出る (図3)
- **N** は大きく丈夫で、屋外のアンテナの給電点に多い。N–SMA のアダプタで NanoVNA につなぐ

## 変換するときの決め

1. **アダプタは少なく。** 1 つごとに電気長 (1-10) と小さな反射が足される。SMA→BNC→SMA のように
   往復するなら、BNC を使わずに済む道を先に探す
2. **アダプタを付けた先で校正する** (基準面をアダプタの先へ。1-5)。校正キットに合う形 (SMA)
   にならないなら、校正はアダプタの手前で取り、アダプタはポート延長で消す (1-10)。消えるのは
   電気長だけで、アダプタの反射は残る
3. **75 Ω の物 (TV のアンテナ・F 形・75 Ω の BNC) を 50 Ω の系で測るなら、その旨を書く**。
   NanoVNA の読みは 50 Ω を基準にした値で、75 Ω の系の SWR とは違う (5-6)
4. **締める**: SMA は 0-2 のトルク、BNC は最後まで回してロックを確かめる。ロックが半分だと
   接触が揺れて、読みが掃引ごとに変わる (0-8)

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CH0 と CH1 の間に変換アダプタ 2 個 (SMA-BNC-SMA)
parts:
  M1:
    type: device
    at: 2,2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  J1: sma 4,2
  T1: tline 5,2 7,2 50 l=$\mathrm{25mm}$
  L1: inductor 7,2 8,2 0.5n
  T2: tline 8,2 10,2 50 l=$\mathrm{25mm}$
  J2: sma 11,2
  G1: ground 4,3
  G2: ground 11,3
wires:
  - M1.CH0 -- J1.1
  - J1.1 -- 5,2
  - 10,2 -- J2.1
  - J1.2 -- 4,3
  - J2.2 -- 11,3
notes:
  - text 7.5,3 blue center: アダプタ 2 個の模型 (BNC の継ぎ目を 0.5 nH と仮定)
  - text 11.6,2 blue left: CH1 へ
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/circuit/07-connector-types.svg)

T1・T2 はアダプタの中の 50 Ω の線 (片側 25 mm、PTFE で VF 0.7)、L1 は BNC の継ぎ目に残る
インダクタンス。どちらも**仮定の値**で、アダプタごとに違う。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 市販のアダプタを校正の後の Thru に挟んで見る題で、基板に組む物が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 10 MHz〜1.5 GHz |
| 点数 | 150 |
| 校正 | 両方のケーブルの先で SOLT (Thru はメス–メス) |
| 測る物 | 図2: SMA→BNC と BNC→SMA のアダプタ 2 個 (50 Ω)。図3: SMA の線の途中に 75 Ω の線 3 cm。図4: SMA と RP-SMA を取り違えた継ぎ目 |
| 表示 | S11 の Log Mag と S21 の Log Mag (図3 は S21 の代わりに S11 の SWR) |

50 Ω の BNC を挟んだときの**見えるはずの画面** (仮定の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 10M-1.5G 150
title: 図2 SMA→BNC→SMA — S11 は周波数とともに上がり 1.5 GHz で −26.5 dB
dut:
  - line 50 25mm vf 0.7
  - series L 0.5n
  - line 50 25mm vf 0.7
traces:
  - S11 logmag
  - S21 logmag
markers:
  - 100M
  - 500M
  - 1G
  - 1.5G
notes:
  - text 700M -60dB: 周波数が 10 倍で反射は +20 dB
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/vna/07-connector-types-1.svg)

- S21 はほぼ 0 dB のまま (1.5 GHz で −0.01 dB)。**通過だけ見ていると、アダプタの影響に気づかない**
- S11 は 100 MHz の −50 dB から 1.5 GHz の −26.5 dB まで上がる。これがアダプタを挟んだときの
  「読める反射の下限」になる (1-7 の Load と同じ考え方)

75 Ω の線 (75 Ω の BNC の中身など) が 3 cm 混ざったとき。設定は図2 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 10M-1.5G 150
title: 図3 75 Ω の線 3 cm を挟む — 1.5 GHz で S11 −8.5 dB
dut: line 75 3cm vf 0.7
traces:
  - S11 logmag
  - S11 swr 0.5
markers:
  - 100M
  - 500M
  - 1G
  - 1.5G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/vna/07-connector-types-2.svg)

- 3 cm でも 1 GHz で S11 −10.2 dB (SWR 1.9)。この反射は Z0 が違うことから来るので、
  **ポート延長でも消えない**
- 線が λ/4 (この長さなら 1.75 GHz、H4 の範囲の外) になると、50 Ω が 75² ÷ 50 = 112.5 Ω に見えて反射がいちばん大きい

SMA の Thru のつもりで、片方に RP-SMA のアダプタが混ざっていたとき (中心がつながらず、
0.1 pF ほどの容量だけでつながると**仮定**)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 10M-1.5G 150
title: 図4 SMA と RP-SMA の取り違え — 中心が開いて S21 は −44 dB (100 MHz)
dut: series C 0.1p
traces:
  - S11 logmag
  - S21 logmag
markers:
  - 100M
  - 500M
  - 1G
  - 1.5G
notes:
  - text 300M -70dB: S11 はほぼ 0 dB (開放)
expect:
  - match: S11 LOGMAG は掃引の中で
    why: 開放で S11 が 0 dB に張り付くのを見せる図
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/vna/07-connector-types-3.svg)

- S21 は 100 MHz で −44 dB、1.5 GHz で −20.6 dB。**容量でつながるので、周波数を上げると
  少し通る**。S21 が右上がりで、S11 が 0 dB に張り付いていたら、まず中心のつながりを疑う
- アンテナを測るときに RP-SMA を取り違えると、S11 はアンテナではなく開放を測る (どの周波数でも
  ほぼ 0 dB で、共振の谷が出ない)

## 見るべき値

計算値 (仮定の模型)。

| 周波数 | 図2 BNC 往復の S11 | 図3 75 Ω 3 cm の S11 / SWR | 75 Ω 3 cm の S21 (図に無い) | 図4 RP 取り違えの S21 |
| --- | --- | --- | --- | --- |
| 100 MHz | −50.06 dB | −28.55 dB / 1.08 | −0.01 dB | −44.04 dB |
| 500 MHz | −36.08 dB | −14.99 dB / 1.43 | −0.14 dB | −30.06 dB |
| 1 GHz | −30.06 dB | −10.18 dB / 1.90 | −0.44 dB | −24.05 dB |
| 1.5 GHz | −26.54 dB | −8.49 dB / 2.21 | −0.66 dB | −20.55 dB |

**3 つの見分け方**: 50 Ω のアダプタは S11 が周波数とともにゆっくり上がる (図2)。75 Ω が混ざると
S11 が大きく波打つ (図3。長いほど低い周波数から)。中心が開くと S21 が右上がりで S11 が 0 dB (図4)。

## LTspice での確かめ

`sim/07-connector-types.cir` で、図2〜図4 の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端、伝送線路は損失なしの T 素子、コイルの直列抵抗は 1 µΩ)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図2 (BNC 往復) | 100 MHz / 500 MHz / 1 GHz / 1.5 GHz | S11 | −50.06 / −36.08 / −30.06 / −26.54 dB | −50.06 / −36.08 / −30.06 / −26.54 dB | 合う |
| 同 | 1.5 GHz | S21 | −0.01 dB | −0.010 dB | 合う |
| 図3 (75 Ω 3 cm) | 同 | S11 | −28.55 / −14.99 / −10.18 / −8.49 dB | −28.55 / −14.99 / −10.18 / −8.49 dB | 合う |
| 同 | 同 | S21 | −0.01 / −0.14 / −0.44 / −0.66 dB | −0.006 / −0.140 / −0.438 / −0.664 dB | 合う |
| 図4 (0.1 pF) | 同 | S21 | −44.04 / −30.06 / −24.05 / −20.55 dB | −44.04 / −30.06 / −24.05 / −20.55 dB | 合う |

## 出典

自作。コネクタの周波数範囲・抜き差しの寿命・RP-SMA の中心の向き・BNC の 50 Ω と 75 Ω は
[SMA connector (Wikipedia)](https://en.wikipedia.org/wiki/SMA_connector)、
[Hirose U.FL (Wikipedia)](https://en.wikipedia.org/wiki/Hirose_U.FL)、
[BNC connector (Wikipedia)](https://en.wikipedia.org/wiki/BNC_connector)、
[N connector (Wikipedia)](https://en.wikipedia.org/wiki/N_connector) による。アダプタの模型の値は仮定。
