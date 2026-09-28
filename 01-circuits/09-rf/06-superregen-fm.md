---
book: circuits
chapter: 9
id: 9-6
title: 超再生 FM ラジオ
tier: 100
source: 自作
board: BB
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
  Cant: capacitor d14 d15 2p
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

- **タンクと発振回路は 9-4 とほぼ同じ**: L1 (今回は 100nH) と C1・C2 (今回は
  33pF・33pF) のコルピッツ。合成容量 C<sub>s</sub> = 33p×33p/(33p+33p) **= 16.5pF**
- **同調は VC1 で合わせる**: 9-4 はコイルの巻きで周波数を合わせたが、ここでは
  L1 と並列に **VC1 (ポリバリコンの FM 側、4.5〜24.5pF)** を入れ、つまみを回して
  合わせる。タンクの容量は C<sub>s</sub> + VC1 = 21〜41pF で、
  f<sub>0</sub> = 1/(2π√(100nH×C)) **≈ 79〜110MHz** (計算値)。ブレッドボードと
  Q1 の浮遊容量が数 pF 乗ると全体に数 MHz 下がり、およそ 75〜100MHz になる。
  どちらでも日本の FM 放送帯 (76.1〜95.0MHz、ワイド FM 含む) の大半を回せる
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

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  ANT:
    type: device
    at: top
    label: アンテナ 20cm
    pins: ["1"]
  VC1:
    type: device
    at: top
    label: ポリバリコン FM 側
    pins: [E, A]
  EAR:
    type: device
    at: top
    label: クリスタルイヤホン
    pins: [B, A]
  Cb: capacitor/ceramic b6 b3 0.1u
  Rb1: resistor c6 c10 10k
  Rq: resistor b10 b14 330k
  Rb2: resistor g10 g6 4.7k
  Cq: capacitor/ceramic g14 g11 100p
  Q1: transistor j14(B) j18(C) j22(E) 2SC1815
  L1: inductor/axial c18 c15 100n
  Cant: capacitor/ceramic b18 b22 2p
  Raf: resistor d18 d24 4.7k
  C1: capacitor/ceramic g18 g22 33p
  Re: resistor f22 f26 470
  C2: capacitor/ceramic h22 h26 33p
  Caf: capacitor/ceramic c24 c28 0.01u
  Cout: capacitor/ceramic e24 e30 1u
wires:
  - +t6 -- a6 red
  - a3 -- -t3 black
  - e10 -- f10 purple
  - j6 -- -b6 black
  - j11 -- -b11 black
  - e14 -- f14 orange
  - +t15 -- a15 red
  - e18 -- f18 blue
  - VC1.E -- -t17 black
  - VC1.A -- a18 blue
  - ANT.1 -- a22 yellow
  - j26 -- -b26 black
  - a28 -- -t28 black
  - EAR.A -- a30 green
  - EAR.B -- -t29 black
  - -t1 -- -b1 black
```

- 上の赤レール = +5V (USB や電池)、青レール = GND。1 列で上下の − レールを渡している
- Q1 は下のブロックの j 行 (14 列 B・18 列 C・22 列 E)。ベースとコレクタは e–f の短い線で
  上のブロックへも出す
- 10 列が Rb1・Rb2・Rq の中点 (上下を e–f でつなぐ)。ベース (14 列) に Rq と Cq が集まる
- コレクタ (18 列) に L1・Cant・Raf・C1、エミッタ (22 列) に C1・C2・Re が集まる
- L1 は市販の 100nH (0.1µH) のアキシャルのコイル。巻いて作る必要は無い。
  受信周波数は VC1 のつまみで合わせる
- VC1 は板の外に置き、FM 側の 1 連の A をコレクタ (a18)、E (回転子) を上の − レールへ
- アンテナ線は 20cm ほどにとどめる (上の警告のとおり)

## 見るべき値

計算値。

| 確かめること | 期待する値 |
| --- | --- |
| 無信号時にイヤホンを聞く | ザーッというクエンチ雑音 (計算値 30.3kHz 付近の漏れ) |
| VC1 をゆっくり回して近くの FM 放送局に合わせる | 雑音が消えて放送が聞こえる |
| VC1 を端から端まで回す | 受信できる周波数が約 79〜110MHz (計算値。浮遊容量で数 MHz 下がる) の間で動く |
| Cant を大きくする (結合を強める) | 感度は上がるが、発振がタンクの外へ漏れやすくなる (微弱無線の範囲を超えやすい方向。既定の 2pF のままにする) |

## 出典

自作。電波法の微弱無線局の技術基準は総務省電波法施行規則第 6 条による。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
FM 側のポリバリコンの容量 (4.5〜24.5pF) は、市販の AM/FM 2 連ポリバリコンの仕様
([RPE パーツ](https://www.rpe-parts.co.jp/view/item/000000002194)) による。
