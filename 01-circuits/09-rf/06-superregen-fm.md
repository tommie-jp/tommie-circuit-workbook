---
book: circuits
chapter: 9
id: 9-6
title: 超再生 FM ラジオ
tier: 100
source: 自作
board: PF
era: 古
---

# 9-6 超再生 FM ラジオ

**超再生検波**は、9-4 と同じコルピッツ発振回路を、**わざと間欠的に発振・
停止させながら**受信に使う方式。発振が立ち上がる速さが電波の強さで変わる
ことを利用し、1 石だけで信じられないほどの感度を得る、古い時代の知恵。

> [!WARNING]
> この回路は**受信専用**だが、超再生検波は原理上つねに自分でも高周波を
> 発振していて、アンテナから**ごくわずかに電波が漏れ出す**。9-4 と同じく
> 電波法の**微弱無線局**の範囲 (322MHz 以下、距離 3m で電界強度 500µV/m
> 以下、電波法施行規則第 6 条) に収めるため、**アンテナは短く・結合は弱く
> (Cant は小さいまま)** にする。長いアンテナに張り替えたり、後段に高周波
> 増幅を足したりしない。

## 回路図

```circuit
title: 図1 コルピッツ発振+クエンチ回路のFM超再生受信機
parts:
  VCC: vcc a2
  L1: inductor a10 d10 100n
  Cb: capacitor a3 c3 0.1u
  GCb: ground c3
  Cant: capacitor d14 d15 2.2p
  ANT: antenna d16
  VC1: capacitor-var g13 i13 l=$\mathrm{VC}_1$
  GVC: ground j13
  Q1: npn f10
  C1: capacitor e12 g12 33p
  C2: capacitor h12 j12 33p
  GC2: ground j12
  Re: resistor h10 j10 470
  GRe: ground j10
  Rb1: resistor a5 d5 10k
  Rb2: resistor f5 h5 4.7k
  GRb2: ground h5
  Rq: resistor f6 f8 330k
  Cq: capacitor f8 h8 100p
  GCq: ground h8
  Raf: resistor b12 b15 4.7k
  Caf: capacitor b17 e17 0.01u
  GCaf: ground e17
  Cout: capacitor b18 b20 1u
  EAR: earphone c23 e23 l=$\mathrm{EAR}$
  GEAR: ground e23
wires:
  - a2 -- a10
  - d10 -- Q1.C
  - d10 -- d11
  - d11 -- d12
  - d12 -- d13
  - d13 -- d14
  - d12 -- e12
  - d15 -- d16
  - d13 -- g13
  - i13 -- j13
  - g12 -- h12
  - Q1.E -- h10
  - h10 -- h12
  - d5 -- f5
  - f5 -- f6
  - f8 -- Q1.B
  - d11 -- b11
  - b11 -- b12
  - b15 -- b18
  - b20 -- b21
  - b21 |- c23
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/06-superregen-fm.svg)

- **タンクと発振回路は 9-4 とほぼ同じ**: L1 (今回は 100nH) と C1・C2 (今回は
  33pF・33pF) のコルピッツ。合成容量 C<sub>s</sub> = 33p×33p/(33p+33p) **= 16.5pF**
- **同調は VC1 で合わせる**: 9-4 はコイルの巻きで周波数を合わせたが、ここでは
  L1 と並列に **VC1 (ポリバリコンの FM 側、4.5〜24.5pF)** を入れ、つまみを回して
  合わせる。タンクの容量は C<sub>s</sub> + VC1 = 21〜41pF で、
  f<sub>0</sub> = 1/(2π√(100nH×C)) **≈ 79〜110MHz** (計算値)。配線と
  Q1 の浮遊容量が数 pF 乗ると全体に数 MHz 下がり、およそ 75〜100MHz になる
  (実測はしていない)。日本の FM 放送帯 (76.1〜95.0MHz、ワイド FM 含む) の
  大半を回せる
- VC1 は AM/FM 2 連のポリバリコンの FM 側の 1 連だけを使う (AM 側の端子は使わない)。
  回転子 (E) を GND にしておくと、つまみに手を近づけたときの周波数のずれが小さい
- **クエンチ回路が 9-4 との違い**: Rb1・Rb2 (10kΩ・4.7kΩ) で作ったバイアスの
  中点から、**Rq (330kΩ) を通して**ベースへ電流を送り、ベースには
  **Cq (100pF)** だけを GND へ。Rq・Cq の時定数で、発振が育つとベースの
  直流電位がわずかに動いて発振が止まり (クエンチ)、Cq が Rq を通して
  放電しきるとまた発振が始まる、を繰り返す
- **クエンチ周波数** f<sub>q</sub> ≈ 1/(Rq×Cq) = 1/(330kΩ×100pF)
  **≈ 30.3kHz** (計算値)。可聴域のすぐ上なので、無信号時はザーッという
  クエンチ雑音がかすかに聞こえることがある
- **受信の仕組み**: 強い電波がアンテナ (Cant 経由) からタンクに飛び込むと、
  タンクの実効的な損失 (Q) が変わり、発振が立ち上がるまでの時間がわずかに
  変わる。この時間差の平均が信号の強さに応じて動くので、電波の強弱が
  音の大小に変わる。**FM は振幅が一定**なので、タンクを放送波の中心から
  少しだけずらして受信する (傾斜検波と同じ考え方) と、周波数のゆれが
  振幅のゆれに変わって拾える
- **音声の取り出し**: Raf (4.7kΩ) と Caf (0.01µF) の CR ローパス
  (カットオフ f<sub>c</sub> = 1/(2πRC) ≈ 3.4kHz) が、80MHz 前後の RF も
  30.3kHz のクエンチも落とし、残った可聴域の音声だけを Cout (1µF) 経由で
  EAR (クリスタルイヤホン) へ渡す
- **イヤホンのインピーダンス**: EAR は、いま売られているセラミック (圧電) 型の
  クリスタルイヤホンを想定する (容量 約 15nF、直流では 20MΩ 以上)。電気的には
  コンデンサなので、インピーダンスは周波数で変わり、**1kHz で約 10kΩ**
  (1/(2π×1kHz×15nF) ≈ 10.6kΩ)、100Hz で約 100kΩ。8Ω や 32Ω のダイナミック型の
  イヤホンでは、4.7kΩ の Raf を通した小さな電流では鳴らない
- イヤホンの容量は Cout (1µF、15nF よりずっと大きい) を通して Caf と並列に入る。
  合わせて約 25nF になり、ローパスの実際のカットオフは 1/(2π×4.7kΩ×25nF)
  **≈ 1.4kHz** に下がる。声は聞き取れるが、こもった音になる

## 実体配線図

**perfboard にした理由**: この回路は 75〜110MHz で発振する。ブレッドボードに
組む回路の目安は 3MHz 以下で、それを大きく超える。タンクの容量は 21〜41pF しかなく、
ブレッドボードの穴どうしの容量 (数 pF 規模) と、差し直すたびに変わる接触が、同調の位置を
ずらしてしまう。そこで、部品の足を短く切って半田付けで固定できる perfboard に組む。
perfboard の目安 (150MHz まで、VHF) の内側なので、この回路は 1 石の自励発振で部品を足で直に
結ぶだけの構成に合う。配線の長さと板の浮遊容量は周波数に効くので、
発振や同調範囲は実測して確かめる。電圧 (5V) と電流 (数 mA) は perfboard の範囲に十分収まる。

```perfboard
board: 7x5cm
title: 図2 perfboard に組む (部品面から見た図)
parts:
  PWR:
    type: device
    at: -e1
    label: 電源 5V
    pins: "- +"
  ANT:
    type: device
    at: -e13
    label: アンテナ 20cm
    pins: "1"
  VC1:
    type: device
    at: -e22
    label: ポリバリコン FM側
    pins: A E
  EAR:
    type: device
    at: s17
    label: クリスタルイヤホン
    pins: A B
  Rb1: resistor c4 g4 10k
  Rb2: resistor l4 p4 4.7k
  Cb: capacitor/ceramic e1 e3 0.1u
  Rq: resistor l5 l9 330k
  Cq: capacitor/ceramic m9 p9 100p
  Q1: transistor/to92 j9 j11 j13 2SC1815
  L1: inductor/axial c11 g11 100n
  Re: resistor l13 p13 470
  C2: capacitor/ceramic l15 p15 33p
  C1: capacitor/ceramic g15 k15 33p
  Cant: capacitor/ceramic d13 g13 2.2p
  Raf: resistor g19 l19 4.7k
  Caf: capacitor/ceramic l21 p21 0.01u
  Cout: capacitor/ceramic l17 o17 1u
wires:
  - PWR.- -- e1 black
  - e1 -- p1 black
  - p1 -- p4 black
  - p4 -- p9 black
  - p9 -- p13 black
  - p13 -- p15 black
  - p15 -- p18 black
  - p18 -- p21 black
  - p21 -- p23 black
  - PWR.+ -- c2 red
  - c2 -- c3 red
  - c3 -- c4 red
  - c4 -- c11 red
  - c3 -- e3 red
  - g4 -- l4 purple
  - l4 -- l5 purple
  - j9 -- l9 green
  - l9 -- m9 green
  - g11 -- j11 orange
  - g11 -- g13 orange
  - g13 -- g15 orange
  - g15 -- g19 orange
  - g19 -- g22 orange
  - j13 -- l13 blue
  - l13 -- l15 blue
  - k15 -- l15 blue
  - l19 -- l21 yellow
  - l19 -- l17 yellow
  - ANT.1 -- d13 white
  - VC1.A -- g22 orange
  - VC1.E -- p23 black
  - o17 -- EAR.A green
  - EAR.B -- p18 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/perfboard/06-superregen-fm.svg)

- 板は 5×7cm を横に置いた 24 列 × 18 行 (標準の板の先頭で、配置が収まる)。厚みと基材は
  既定の 1.6mm・FR-4。図は部品面から見た図で、足や被覆線は図の線どおりに半田面で通す
- 上の c 行が +5V の筋、下の p 行が GND の筋。左端の 1 列は電源の − から p 行へ下ろした GND
- Q1 (2SC1815) は j9・j11・j13 に足を広げて挿す。2SC1815 は平らな面を見て左から E・C・B なので、
  平らな面を板の上側に向けて挿すと左から B・C・E (ネットリストの 1・2・3 番)。組む前に実物の平らな面と足の並びを確かめる
- 9 列 (j9–l9–m9) がベースで、Rq の右、Cq の上、Q1 の B が集まる。
  4 列の縦線 (g4–l4) が Rb1・Rb2・Rq の中点
- g 行の橙の線がコレクタの母線。L1 の下端 (g11)、Cant・C1 の上、Raf の上、VC1 の A (g22) が
  ここにつながる。VC1 は板の外に置き、E (回転子) を GND の筋 (p23) へ
- 13 列 (l13) がエミッタ。Re・C2・C1 の下が集まる。C1 はコレクタの母線 (g15) とエミッタ (k15–l15) の間
- Raf の下端 (l19) が Caf と Cout に分かれる。Cout の下 (o17) からイヤホンの A へ、
  B は GND の筋 (p18) へ。A の線は GND の筋の上を跨ぐ被覆線にする
- L1 は市販の 100nH (0.1µH) のアキシャルのコイル。巻いて作る必要は無い。
  受信周波数は VC1 のつまみで合わせる
- 高周波の線 (L1・C1・C2・Q1・VC1 へ行く線) はなるべく短く。アンテナ線は 20cm ほどに
  とどめる (上の警告のとおり)

## 見るべき値

計算値。

| 確かめること | 期待する値 |
| --- | --- |
| 無信号時にイヤホンを聞く | ザーッというクエンチ雑音 (計算値 30.3kHz 付近の漏れ) |
| VC1 をゆっくり回して近くの FM 放送局に合わせる | 雑音が消えて放送が聞こえる |
| VC1 を端から端まで回す | 受信できる周波数が約 79〜110MHz (計算値。浮遊容量で数 MHz 下がる) の間で動く |
| Cant を大きくする (結合を強める) | 感度は上がるが、発振がタンクの外へ漏れやすくなる (微弱無線の範囲を超えやすい方向。既定の 2.2pF のままにする) |

## 出典

自作。電波法の微弱無線局の技術基準は総務省電波法施行規則第 6 条による。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
FM 側のポリバリコンの容量 (4.5〜24.5pF) は、市販の AM/FM 2 連ポリバリコンの仕様
([RPE パーツ](https://www.rpe-parts.co.jp/view/item/000000002194)) による。
