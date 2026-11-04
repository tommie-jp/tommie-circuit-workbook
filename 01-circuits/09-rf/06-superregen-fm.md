---
book: circuits
chapter: 9
id: 9-6
title: 超再生 FM ラジオ
tier: 100
source: 自作
board: CB
era: 古
---

# 9-6 超再生 FM ラジオ

**超再生検波**は、9-4 と同じコルピッツ発振回路を、**わざと間欠的に発振・停止させながら**受信に使う古くからの方式で、1 石で高い感度を得る。
FM 放送を受けてイヤホンで聞く。受信機が出す発振を tinySA で見る手順は 9-30 に分けた。
FM 放送帯の超再生は 3 MHz 以下では題が成り立たないので、入門に置いて銅張り基板に組む。
Analog Discovery 3 とオシロの図は入れない (75〜110 MHz は 10 MHz を超えてオシロで見えない。9-30 で spectrum の図にする)。

> [!WARNING]
> この回路は**受信専用**だが、超再生検波はつねに自分でも発振していて、アンテナから**ごくわずかに電波が漏れ出す**。
> 9-4 と同じく**微弱無線局**の範囲 (322 MHz 以下、距離 3m で 500 µV/m 以下、電波法施行規則第 6 条) に収めるため、
> **アンテナは短く・結合は弱く (Cant は小さいまま)** する。長いアンテナや高周波増幅を足さない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 コルピッツ発振+クエンチ回路のFM超再生受信機
parts:
  VCC: vcc 2,1 5V
  L1: inductor 10,1 10,4 100n
  Cb: capacitor 3,1 3,3 0.1u
  GCb: ground 3,3
  Cant: capacitor 14,4 15,4 2.2p
  ANT: antenna 16,4
  VC1: capacitor-var 13,7 13,9 l=$\mathrm{VC}_1$
  GVC: ground 13,10
  Q1: npn 10,6 2SC3355L
  C1: capacitor 12,5 12,7 33p
  C2: capacitor 12,8 12,10 33p
  GC2: ground 12,10
  Re: resistor 10,8 10,10 470
  GRe: ground 10,10
  Rb1: resistor 5,1 5,4 10k
  Rb2: resistor 5,6 5,8 4.7k
  GRb2: ground 5,8
  Rq: resistor 6,6 8,6 330k
  Cq: capacitor 8,6 8,8 100p
  GCq: ground 8,8
  Raf: resistor 12,2 15,2 4.7k
  Caf: capacitor 17,2 17,5 0.01u
  GCaf: ground 17,5
  Cout: capacitor 18,2 20,2 1u
  EAR: earphone 23,3 23,5 l=$\mathrm{EAR}$
  GEAR: ground 23,5
wires:
  - 2,1 -- 10,1
  - 10,4 -- Q1.C
  - 10,4 -- 11,4
  - 11,4 -- 12,4
  - 12,4 -- 13,4
  - 13,4 -- 14,4
  - 12,4 -- 12,5
  - 15,4 -- 16,4
  - 13,4 -- 13,7
  - 13,9 -- 13,10
  - 12,7 -- 12,8
  - Q1.E -- 10,8
  - 10,8 -- 12,8
  - 5,4 -- 5,6
  - 5,6 -- 6,6
  - 8,6 -- Q1.B
  - 11,4 -- 11,2
  - 11,2 -- 12,2
  - 15,2 -- 18,2
  - 20,2 -- 21,2
  - 21,2 |- 23,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/06-superregen-fm.svg)

- **タンクと発振回路は 9-4 とほぼ同じ**: L1 (100 nH) と C1・C2 (33 pF・33 pF) のコルピッツ。合成容量 C<sub>s</sub> = 33p×33p/(33p+33p) **= 16.5 pF**
- **同調**: L1 と並列の **VC1 (ポリバリコンの FM 側、4.5〜24.5 pF)** のつまみで合わせる。タンクの容量は C<sub>s</sub> + VC1 = 21〜41 pF で、
  f<sub>0</sub> = 1/(2π√(100 nH×C)) **≈ 79〜110 MHz** (計算値)。浮遊容量と Q1 の帰還容量 C<sub>re</sub>
  (最大 1.0 pF、VCB=10 V・1 MHz) とピンのインダクタンスで、およそ 74〜102 MHz に下がる (見積もりは 9-30、実測はしていない)。
  FM 放送帯 (76.1〜95.0 MHz、ワイド FM 含む) を回せる
- **Q1 を 2SC3355L (UTC、TO-92、秋月電子で 1 本 20 円) にした理由**: 100 MHz 前後で発振と感度を出すには、
  電流増幅率が 1 より十分大きい石が要る。2SC1815 (fT 最小 80 MHz) では |h<sub>fe</sub>| ≈ f<sub>T</sub>/f が
  75〜110 MHz で **約 0.7〜1.1** しかない。2SC3355 は fT **典型 7 GHz** で、100 MHz で約 70。この回路の 1 mA 以下で fT が下がっても
  桁で余裕がある。定格 (VCEO 12 V など) と h<sub>FE</sub> 50〜300 は 9-27 と同じ
- **バイアスの電流**: Rb1・Rb2 の中点は 5 V×4.7k/14.7k ≈ 1.6 V (内部抵抗 10k∥4.7k ≈ 3.2 kΩ)。
  Rq (330 kΩ) 越しにベースへ入り、V<sub>BE</sub> = 0.7 V で I<sub>C</sub> ≈ (1.6 V−0.7 V) / (Re×(1+1/h<sub>FE</sub>) + (Rq+3.2 kΩ)/h<sub>FE</sub>)。
  h<sub>FE</sub> = 50・100・300 で **I<sub>C</sub> ≈ 0.13 mA・0.24 mA・0.57 mA** (計算値)。
  V<sub>CE</sub> は 4.7 V 以上で、飽和も破損もしない。クエンチを決める Rq は替えず、感度が足りなければ
  h<sub>FE</sub> の大きい個体を選ぶ (テスターの hFE 端子で測る)
  VC1 は AM/FM 2 連の FM 側の 1 連だけを使い、回転子 (E) を GND にする (手を近づけたときのずれが小さい)
- **クエンチ回路が 9-4 との違い**: バイアスの中点から **Rq (330 kΩ) を通して**ベースへ電流を送り、
  ベースから **Cq (100 pF)** だけを GND へ。発振が育つとベースの直流電位が動いて止まり (クエンチ)、
  Cq が Rq を通して放電しきるとまた始まる
- **クエンチ周波数** f<sub>q</sub> ≈ 1/(Rq×Cq) = 1/(330 kΩ×100 pF)
  **≈ 30.3 kHz** (時定数だけの概算。hFE と発振の強さで変わる。LTspice の節)。
  可聴域のすぐ上で、無信号時はザーッというクエンチ雑音がかすかに聞こえることがある
- **受信の仕組み**: 発振は止まるたびに、タンクに残った小さな電圧 (ふだんは雑音) を種にして育ち直す。
  電波が Cant 経由で入っていると種が大きく、発振が早く立ち上がる。その平均が信号の強さで動き、音の大小になる。**FM は振幅が一定**なので、同調を放送波の中心から少しずらし、
  共振の山の斜面で周波数のゆれを振幅のゆれに変える (傾斜検波 = スロープ検波。9-13)
- **音声の取り出し**: Raf (4.7 kΩ) と Caf (0.01 µF) の CR ローパス
  (f<sub>c</sub> = 1/(2πRC) ≈ 3.4 kHz) が RF とクエンチを落とし、音声だけを Cout (1 µF) 経由で EAR へ渡す
- **イヤホン**: EAR はセラミック (圧電) 型 (容量 約 15 nF、直流では 20 MΩ 以上)。
  インピーダンスは **1 kHz で約 10 kΩ** (1/(2π×1 kHz×15 nF) ≈ 10.6 kΩ)、100 Hz で約 100 kΩ。
  8 Ω や 32 Ω のダイナミック型は、Raf を通した小さな電流では鳴らない。
  イヤホンの容量が Cout を通して Caf と並列に入り (約 25 nF)、カットオフは
  1/(2π×4.7 kΩ×25 nF) **≈ 1.4 kHz** に下がる。声は聞き取れるが、こもる

### LTspice での確かめ

`sim/06-superregen-fm.cir` で図1 の回路 (Cant は 50 Ω の負荷へ) を、電源の立ち上げから 60 µs の過渡解析で走らせた。
Q1 は 2SC3355 の代用モデル (`sim/04-fm-transmitter.cir` と同じ。目安から作った仮定)。島の浮遊容量とピンのインダクタンスは入れていない。
動作点は `.op` で、周波数とクエンチは過渡解析の波形から読んだ。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Re の両端の直流 (hFE 50・100・300) | 0.06〜0.27 V (I<sub>C</sub> 0.13・0.24・0.57 mA) | 0.07・0.13・0.30 V (I<sub>C</sub> 0.15・0.27・0.63 mA) | 合う (V<sub>BE</sub> の仮定 0.7 V と約 0.6 V の差で 1 割ほど) |
| 発振の周波数 (VC1 = 4.5 pF / 24.5 pF) | 計算 110 / 79 MHz、浮遊容量とピン込みで 102 / 74 MHz | 102.2 / 75.8 MHz (Cant と Q1 の容量だけを入れた値) | 合う |
| 発振の中央 (VC1 = 14.5 pF) | 計算 約 90 MHz (21〜41 pF の中ほど) | 86.5 MHz | 合う |
| クエンチ周波数 | f<sub>q</sub> ≈ 30.3 kHz (= 1/(Rq×Cq)) | hFE = 300 で約 68 kHz (周期 14.6 µs、発振している時間は 3.3 µs)。hFE = 50・100 では**クエンチせず**、小さな振幅 (0.3〜0.7 Vpp) で連続して発振する | 直した (注意を足した) |

hFE が小さいとクエンチしない理由と、実物の f<sub>q</sub> を tinySA の側波の間隔から読む手順は 9-30。
この結果はモデルの仮定に強く依存し、実測の値ではない。受信感度と音は、アンテナと放送の強さに依るので対象外。

## 実体配線図

**銅張り基板にした理由**: 75〜110 MHz はブレッドボード (3 MHz 以下) も perfboard (10 MHz 以下) も超える。
タンクの容量は 21〜41 pF しかなく、穴の容量や接触、長くなるピンが同調と発振の条件をずらす。
そこで、裏を全面 GND にした銅張り基板に、部品を短いピンで島から島へ渡す Manhattan 方式で組む。
島は回路図の節点ごとに 1 つで、GND の節点は via で裏の GND の面へ直に落とす。
島の浮遊容量とピンのインダクタンスで同調範囲が 74〜102 MHz ほどに下がる見積もりは 9-30。ピンは切り詰める。

**範囲の確認**: 5 V・1 mA 以下 (分圧の約 0.34 mA と Q1 の 0.13〜0.57 mA)・75〜110 MHz で、
銅張り基板の範囲 (10 MHz 超〜1 GHz) に収まる。島の幅は最小 4mm (3mm 以上)、溝は最小 1.5mm (0.3mm 以上)。商用電源は使わない。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 70x50mm
  ground: back
title: 図2 銅張り基板に組む (Manhattan)
f: 90M
copper:
  VCC: pad 21,8 26x4mm
  BIAS: pad 22,20 4x4mm
  BASE: pad 32,20 4x6mm
  COL: pad 40.5,12.75 5x13.5mm
  EMI: pad 44,24 12x5mm
  ANT: pad 55,7 4x4mm
  AF: pad 57,18 14x4mm
  OUT: pad 55,33 4x4mm
  GCb: pad 10,18 4x4mm
  VCb: via 10,18
  GB2: pad 22,32 4x4mm
  VB2: via 22,32
  GCq: pad 32,32 4x4mm
  VCq: via 32,32
  GC2: pad 42,31 4x4mm
  VC2: via 42,31
  GRe: pad 47,35 4x4mm
  VRe: via 47,35
  GVC: pad 66,12.5 4x4mm
  VVC: via 66,12.5
  GCaf: pad 63,30 4x4mm
  VCaf: via 63,30
  GEAR: pad 63,43 4x4mm
  VEAR: via 63,43
parts:
  Q1: transistor/to92 31.5,18 38.5,14 38.5,24.5 2SC3355L
  Cb: capacitor 10,8 10,18 0.1u
  Rb1: resistor 22,8 22,19 10k
  Rb2: resistor 22,21 22,32 4.7k
  Rq: resistor 23,20 31,20 330k
  Cq: capacitor 32,22 32,32 100p
  L1: inductor 33,8 39,8 100n
  C1: capacitor 40,19 40,23 33p
  C2: capacitor 42,25 42,31 33p
  Re: resistor 47,25 47,35 470
  Cant: capacitor 42,7 54,7 2.2p
  Raf: resistor 42.5,18 51,18 4.7k
  Caf: capacitor 63,19 63,30 0.01u
  Cout: capacitor 55,19 55,33 1u
  PWR:
    type: device
    at: -14,12
    label: 電源 5V
    pins: + -
  VC1:
    type: device
    at: 86,11
    label: VC1
    pins: A E
    face: left
  ANTW:
    type: device
    at: 55,-10
    label: アンテナ線 20cm
    pins: W
    face: bottom
  EAR:
    type: device
    at: 56,60
    label: イヤホン
    pins: A B
    face: top
wires:
  - PWR.+ -- 8.5,8 red
  - PWR.- -- GCb black
  - VC1.A -- COL
  - VC1.E -- GVC black
  - ANTW.W -- ANT
  - EAR.A -- OUT
  - EAR.B -- GEAR black
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/copper/06-superregen-fm.svg)

- 5×7cm を横に置いた 70×50mm、FR-4・1.6mm・両面 1oz。表は島だけを残して剥がし (または銅板の小片を貼り)、
  **裏の銅は全面を GND** にする。下の段が裏から見た図で、丸い印が via。島は端から 5mm 以上 (1cm の余白は取れなかった)
- **図の島と回路図の節点の対応** (`copper-fence check` のネットリストと回路図の接続は一致する)

  | 図の島 | 回路図の節点 (つながるピン) |
  | --- | --- |
  | VCC | +5 V (Cb の上・Rb1 の上・L1 の上・電源の +)。上の帯 |
  | COL | Q1 のコレクタ・L1 の下・C1 の上・Cant の左・VC1 の A・Raf の上 |
  | EMI | Q1 のエミッタ・Re の上・C1 の下・C2 の上 |
  | BIAS | Rb1 の下・Rb2 の上・Rq の上 |
  | BASE | Q1 のベース・Rq の下・Cq の上 |
  | ANT | Cant の右・アンテナ線 (ここへ半田付けする) |
  | AF | Raf の下・Caf の上・Cout の左 |
  | OUT | Cout の右・イヤホンの A |
  | GND (via の島) | Cb・Rb2・Cq・C2・Re・Caf の下、電源の −、VC1 の E、イヤホンの B。**すべて via で裏の GND の面** (線はどの GND の島へ付けてもよい) |

- Q1 (2SC3355L-T92) は平らな面を見て左から B・E・C (UTC のデータシート。2SC1815 の E・C・B とは違う)。メーカーで違うことがあるので、
  組む前にテスターの hFE 端子で確かめる
- 黒い箱 (基板の外の物) から引いた直線は、島へ半田付けする線
- 高周波の線 (L1・C1・C2・Q1・VC1) は短く。C1・C2 のピンは 5mm 前後に
- L1 は市販の 100 nH のアキシャルのコイル (巻かなくてよい)
- 島は紙で配置を決めてから切り出し、島どうしと GND の面の導通をテスターで確かめる

## 見るべき値

計算値。

| 確かめること | 期待する値 |
| --- | --- |
| 無信号時にイヤホンを聞く | ザーッというクエンチ雑音 (30.3 kHz は時定数の概算。LTspice では 68 kHz。クエンチしない個体もありうる) |
| Re (470 Ω) の両端の直流電圧 | 約 0.06〜0.27 V (hFE 50〜300 で I<sub>C</sub> 0.13〜0.57 mA の計算値。発振で少し動く) |
| VC1 を回して近くの FM 放送局に合わせる | 雑音が消えて放送が聞こえる |
| VC1 を端から端まで回す | 受信できる周波数が約 74〜102 MHz (計算値 79〜110 MHz から浮遊容量とピンで下がった見積もり) の間で動く |
| Cant を大きくする (結合を強める) | 感度は上がるが、発振が外へ漏れやすい (微弱無線の範囲を超えやすい。2.2 pF のままにする) |

## 出典

自作。微弱無線局の技術基準は電波法施行規則第 6 条。
クリスタルイヤホンの容量とインピーダンスは市販品の仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、15000 pF・20 MΩ 以上) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100 Hz で 80〜90 kΩ)。
Q1 (2SC3355L) の定格・fT・Cre・端子の順は UTC のデータシート
([秋月電子の 2SC3355 資料](https://akizukidenshi.com/goodsaffix/2sc3355_utc.pdf))。
FM 側のポリバリコンの容量 (4.5〜24.5 pF) は AM/FM 2 連ポリバリコンの仕様
([RPE パーツ](https://www.rpe-parts.co.jp/view/item/000000002194))。
