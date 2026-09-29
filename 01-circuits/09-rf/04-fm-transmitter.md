---
book: circuits
chapter: 9
id: 9-4
title: FM 送信機 (1 石)
tier: 50
source: 自作
board: PF
era: 古
---

# 9-4 FM 送信機 (1 石)

トランジスタ 1 石だけの**コルピッツ発振回路**を FM 放送帯 (80MHz 前後、日本の
FM 放送は 76〜95MHz) で組み、
マイクの音声で発振周波数をわずかに揺らす (直接 FM)。近くの FM ラジオで受かる
ほど電波は届くが、**電波法の微弱無線局の範囲に収めるため、アンテナは短く・
結合は弱いまま・増幅段を足さない**。

> [!WARNING]
> 日本の電波法では、322MHz 以下の微弱無線局は**距離 3m での電界強度が
> 500µV/m 以下**なら免許が要らない (電波法施行規則第 6 条)。この題の
> 定数 (短いアンテナ・小さな結合コンデンサ・弱いバイアス電流) はその範囲に収める
> ための設計で、**アンテナを伸ばしたり石を足して増幅したりすると免許なしでは
> 違法**になる。実験は屋内で短時間、電波を出したまま放置しない。

## 回路図

```circuit
title: 図1 コルピッツ発振 + マイク直接FM
parts:
  VCC: vcc a2
  L1: inductor c10 a10 260n
  Cb: capacitor a4 c4 0.1u
  GCb: ground c4
  Cant: capacitor c13 c15 2.2p
  ANT: antenna c16
  Q1: npn e10
  C1: capacitor d12 f12 22p
  C2: capacitor g12 i12 47p
  GC2: ground i12
  Re: resistor g10 i10 470
  GRe: ground i10
  Rb1: resistor a8 c8 10k
  Rb2: resistor g7 e7 2.4k
  GRb2: ground g7
  C3: capacitor e8 g8 0.001u
  GC3: ground g8
  MIC: mic e2 g2
  GMIC: ground g2
  Rmic: resistor a2 c2 2.2k
  Cmic: capacitor e3 e5 0.1u
wires:
  - a2 -- a10
  - c10 -- Q1.C
  - c10 -- c12
  - c12 -- c13
  - c12 -- d12
  - c15 -- c16
  - f12 -- g12
  - Q1.E -- g10
  - g10 -- g12
  - c2 -- e2
  - e2 -- e3
  - e5 -- e7
  - e7 -- e8
  - e8 -- Q1.B
  - c8 -- e8
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/04-fm-transmitter.svg)

- **タンク**: L1 (260nH、実測でずれる。手巻きコイル) と C1・C2 (コルピッツの
  分圧) で並列共振回路を作る。コレクタは L1 を介して Vcc につながるので、
  L1 は「タンクの一部」と「コレクタの負荷 (RFC 代わり)」を兼ねる
- **帰還**: C1 と C2 の分圧点がエミッタ。C1・C2 の直列合成 C<sub>s</sub> と L1 で
  発振周波数が決まる: f<sub>0</sub> = 1 / (2π√(L1·C<sub>s</sub>))
- **ベース接地**: C3 (0.001µF) がベースを高周波で GND に落とす (80MHz で約 2Ω)。
  これでベース接地のコルピッツになり、C1・C2 の分圧でエミッタへ戻した帰還が
  利く。音声の周波数 (1kHz で約 160kΩ) ではほとんど効かないので、マイクの音声は
  ベースに残る。Cb (0.1µF) は電源のパスコンで、L1 の電源側を高周波で GND に落とす
- **直接 FM**: MIC (エレクトレットマイク) の音声を Cmic でベースへ結合する。
  ベースの直流電位がわずかに揺れると、Q1 のベース-エミッタ間容量 (C<sub>be</sub>) も
  わずかに変わり、C2 と一緒にタンクの容量を揺らして周波数が動く
- **アンテナ**: Cant (2.2pF) の小さな結合でコレクタから取り出す。結合を弱くする
  ほど発振回路への負荷が軽く保たれ、輻射も弱くなる (微弱無線の条件そのもの)

**発振周波数の計算値**: C<sub>s</sub> = C1·C2/(C1+C2) = 22p·47p/69p ≈ 15pF。

f<sub>0</sub> = 1 / (2π√(260nH × 15pF)) **≈ 80.6MHz (約80MHz)**。共振周波数は
L1・C1・C2 だけで決まり電源電圧には依らないので、Rb1・Rb2 を電源電圧に
合わせて選び直しても周波数はそのまま。

**動作点の計算値** (V<sub>CC</sub> = 5V、hFE = 200、V<sub>BE</sub> = 0.6V、
Rb1 = 10kΩ、Rb2 = 2.4kΩ、Re = 470Ω): I<sub>C</sub> ≈ 0.76mA、
V<sub>CE</sub> ≈ 4.6V。3V (単3 電池 2 本) のときの Rb2 = 4.7kΩ のままだと
I<sub>C</sub> が約 2.0mA まで増え、電流は多めでも発振は保てるが、
Rb2 を 2.4kΩ に下げて I<sub>C</sub> を元とほぼ同じ (3V 時 ≈0.74mA) に
合わせている。

コイルの巻きを少し広げる (実効インダクタンスが下がる) と周波数は上がり、
詰めると下がる。実測ではコイル 1 巻きぶんの調整で数 MHz 動くので、
**近くの FM ラジオで一番静かな (放送局の無い) 周波数に合わせる**。

## 実体配線図

FM 放送帯 (80MHz 前後) の発振回路なので、ブレッドボードではなく **perfboard (ユニバーサル基板)** に半田付けする。

```perfboard
title: 図2 perfboard に組む (部品面から見た図)
board: 5x7cm
style:
  back: on
points:
  VCC: c17
  GND: q17
  ANT: g16
parts:
  MIC:
    type: device
    at: -d4
    label: マイク
    pins: GND OUT
  Rmic: resistor c6 g6 2.2k
  Cmic: capacitor/ceramic i6 i8 0.1u
  Rb1: resistor c10 g10 10k
  Rb2: resistor m10 q10 2.4k
  C3: capacitor/ceramic m8 q8 0.001u
  Q1: transistor i10 i12 i14 2SC1815
  L1: inductor/axial c12 g12 260n
  Cant: capacitor/ceramic g14 g16 2.2p
  C1: capacitor/ceramic k12 k14 22p
  Re: resistor m14 q14 470
  C2: capacitor/ceramic m12 q12 47p
  Cb: capacitor/ceramic c17 e17 0.1u
wires:
  # 電源 (上の c 行、赤) と GND (下の q 行、黒) の筋
  - c6 -- c10 red
  - c10 -- c12 red
  - c12 -- c17 red
  - q4 -- q8 black
  - q8 -- q10 black
  - q10 -- q12 black
  - q12 -- q14 black
  - q14 -- q17 black
  # Cb の GND 側は右端の縁を下りて GND の筋へ
  - e17 -- q17 black
  # マイク
  - MIC.GND -- q4 black
  - MIC.OUT -- i5 green
  - i5 -- i6 green
  - g6 -- i6 green
  # ベース (Rb1 の下、Cmic の右、Rb2 と C3 の上)
  - g10 -- i10 yellow
  - i8 -- i10 yellow
  - i10 -- m10 yellow
  - m8 -- m10 yellow
  # コレクタ (L1 の下、Cant、C1)
  - g12 -- i12 blue
  - g12 -- g14 blue
  - i12 -- k12 blue
  # エミッタ (C1、Re、C2)
  - i14 -- k14 orange
  - k14 -- m14 orange
  - m14 -- m12 orange
notes:
  - text f16: ANT
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/perfboard/04-fm-transmitter.svg)

### perfboard にした理由

- この回路は 80MHz 前後で発振する。この教科書はブレッドボードの上に組む回路を
  3MHz 以下としている。VHF ではブレッドボードの浮遊容量 (数 pF) と足の長さによる
  インダクタンスが、タンクの 15pF・260nH に対して無視できない。発振周波数が
  ずれ、発振しなくなることもある。**ブレッドボードでは組まない**
- perfboard は足を短く切って半田付けでき、GND の筋も近くに引ける。80MHz は perfboard の
  目安 (150MHz、VHF まで) の内側。それでも**配線の長さと板の浮遊容量が周波数に効く**ので、
  周波数は最後にコイルの巻きの広げ具合で合わせる。部品は 1 石だけで数が少なく、
  この題では perfboard で足りる
- 電圧は 5V、電流は I<sub>C</sub> ≈ 0.76mA と、perfboard の電圧・電流の範囲の
  ずっと内側。板は 5×7cm の順位の先頭で収まる (18 列 × 24 行のうち、使うのは
  C〜Q 行・4〜17 列)

### 図の読み方

- 部品面から見た図で、下に半田面 (左右が逆) も出している。上の C 行の赤が +5V、
  下の Q 行の黒が GND の筋。部品の足で筋につなぎ、届かないところだけ被覆線で足す
- Cb (0.1µF) は +5V と GND の間なので、右端の 17 列に GND の線を通し、
  Cb の下の足をそこから Q 行へ落とす。アンテナ線は G16 に半田付けする
  (図の点 ANT。**アンテナ線は 20cm ほど**にとどめる。伸ばすと電波法の範囲を超えやすい。
  結合コンデンサ Cant (2.2pF) も指定どおりの小さい値で)
- 回路図とのつながりは、`perfboard-fence check` のネットリストが回路図と同じ。
  Q1 は書いた順に B (i10)・C (i12)・E (i14)。2SC1815 は平らな面を見て左から E・C・B なので、
  平らな面を板の上側 (L1 側) に向けて挿すと左から B・C・E になる
- L1 は太さ 0.6mm のエナメル線を直径 8mm の丸棒に 8 回巻き、両端を穴に合わせて
  曲げたもの (インダクタンスは目安。実測でずれる)
- ベース (10 列) に Rb1 (上、+5V から)・Cmic (左)・Rb2 と C3 (下、GND へ) が集まる。
  マイクの音声は 5 列のマイクの OUT から、Rmic の下の足 (6 列) と Cmic (i6〜i8) へ入る
- コレクタ (12 列) に L1・Cant・C1、エミッタ (14 列) に C1・Re・C2 が集まる
- 1 つの穴には部品の足を 1 本だけ挿す

## 見るべき値

計算値・実測を併用。

| 確かめること | 期待する値 |
| --- | --- |
| 近くの FM ラジオで受信 | 80MHz 付近 (計算値) の**静かな周波数**でノイズが変わる |
| マイクに向かって話す | ラジオから声が (小さく歪みつつ) 聞こえる |
| コイルの巻きを少し広げる | 受かる周波数が上がる方向へ動く |
| アンテナを外す | 数十cm 以内でしか受からなくなる (電波法の範囲内であることの目安) |

## 出典

自作。電波法の微弱無線局の技術基準 (322MHz 以下、距離 3m で 500µV/m 以下) は
総務省電波法施行規則第 6 条による。
