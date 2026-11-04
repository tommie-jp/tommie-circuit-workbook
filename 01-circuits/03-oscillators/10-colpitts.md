---
book: circuits
chapter: 3
id: 3-10
title: コルピッツ
tier: 200
source: 自作
era: 古
---

# 3-10 コルピッツ

コイル 1 個とコンデンサ 2 個の LC 共振回路で周波数を決める発振回路。考えた人の名前 (E. H. Colpitts) で呼ぶ。
3-7 のウィーンブリッジは RC で周波数を決めたが、ラジオの局部発振や送信機の発振 (第 9 章) は、ほとんどが LC の発振回路である。
LC は共振の周波数のところだけで大きく振れる (共振の Q が高い) ので、RC より周波数が定まり、波形も正弦波に近い。

- **周波数**: L1 と、C1・C2 の直列 (C<sub>s</sub> = C1·C2 / (C1 + C2)) の共振 f = 1 / (2π√(L1 C<sub>s</sub>))。
  π (パイ) は円周率。L1 47 µH (マイクロヘンリー)、C1 820 pF、C2 2.2 nF で C<sub>s</sub> ≈ 597 pF、f ≈ 949 kHz
- **帰還**: コレクタの振れを C1 と C2 で分圧し、その一部をエミッタへ戻す。C2 が大きいほど戻す割合は小さい
  (C1 / (C1 + C2) ≈ 0.27)
- **増幅**: この題はベースを CB で交流的に GND に落とした**ベース接地**の形。エミッタに入れた電圧がコレクタに同じ向きで大きく出るので、
  C1・C2 で戻した電圧と向きがそろい、輪が回り続ける

電源を入れると、雑音のうち共振の周波数の成分だけが輪を回るたびに大きくなり、トランジスタが振り切れる所 (コレクタが 0 V 近くまで下がる所) で振幅が止まる。
コレクタは L1 の働きで電源の 5 V を中心に上下するので、**電源より高い約 10.5 V まで上がる**。
周波数は 1 MHz 弱で、ブレッドボードの範囲 (3 MHz 以下) に収めた。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 コルピッツ発振回路 (ベース接地、L1 と C1・C2 で約 0.93 MHz)
parts:
  VCC: vcc 3,1 5V
  R1: resistor 3,1 3,3 22k
  R2: resistor 3,5 3,7 10k
  G1: ground 3,7
  CB: capacitor 4.5,5 4.5,7 100n
  G2: ground 4.5,7
  L1: inductor 6,1 6,3 47u
  Q1: npn 6,5 2SC1815
  C1: capacitor 8,3 8,5 820p
  RE: resistor 6,6 6,8 1k
  G3: ground 6,8
  C2: capacitor 10,6 10,8 2.2n
  G4: ground 10,8
  M1: voltmeter 12,6 12,8 l=$\mathrm{CH1}$
  G5: ground 12,8
  M2: voltmeter 14,3 14,5 l=$\mathrm{CH2}$
  G6: ground 14,5
wires:
  - 3,1 -- 6,1
  - 3,3 -- 3,5
  - 3,5 -- 4.5,5
  - 4.5,5 -- Q1.B
  - 6,3 |- Q1.C
  - 6,3 -- 8,3
  - 8,3 -- 14,3
  - Q1.E -- 6,6
  - 6,6 -- 8,6
  - 8,5 -- 8,6
  - 8,6 -- 10,6
  - 10,6 -- 12,6
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/10-colpitts.svg)

- 図1 の左がベースの直流の分圧 (R1・R2) と、ベースを交流的に GND へ落とす CB。真ん中が Q1、右が LC の共振回路 (L1・C1・C2)
- **L1 は電源からコレクタへ** 直流を通す。コレクタの直流は 5 V で、交流はその上下に振れる
- **C1 はコレクタとエミッタの間、C2 はエミッタと GND の間**。この 2 つの直列が L1 と共振し、2 つの比で帰還の量が決まる
- RE (1 kΩ。Ω はオーム) はエミッタの直流の通り道。CH1 はエミッタ、CH2 はコレクタ

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (エミッタと L1 は上、ベースは下のブロック)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  AD1:
    type: device
    at: bottom
    label: AD3 Scope
    pins: [1-, 2-, 1+, 2+]
  Q1: transistor h14 h15 h16 2SC1815
  RE: resistor a14 -t14 1k
  C2: capacitor c11 c14 2.2n
  C1: capacitor b14 b15 820p cap=right
  L1: inductor c15 c20 47u
  R2: resistor j16 -b16 10k cap=right
  CB: capacitor g16 g19 100n
  R1: resistor f16 f22 22k cap=above
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t3 black
  - +t2 -- +b2 red
  - -t4 -- -b4 black
  - a11 -- -t11 black
  - +t20 -- a20 red
  - e14 -- f14 blue
  - e15 -- f15 orange
  - j19 -- -b19 black
  - j22 -- +b22 red
  - AD1.1+ -- j14 blue
  - AD1.2+ -- j15 green
  - AD1.1- -- -b9 black
  - AD1.2- -- -b10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/10-colpitts.svg)

図2 は、Q1 を下のブロックの h 行に置き、エミッタ (14 列) とコレクタ (15 列) を溝をまたぐ線で上のブロックへ持ち上げた。
上のブロックがエミッタと LC の部品、下のブロックがベースの部品になる。

- 電源は AD3 の Supplies (V+ を 5 V)。上の + レールと − レールへ入れ、2・4 列の線で下のレールへも渡す。回路が流す電流は約 1 mA
- **2SC1815 は平らな面を手前 (j 行側) にして h 行に、左から E・C・B (14・15・16 列)**
- エミッタ (上の 14 列): RE は − レールへ縦に、C2 (`c11`–`c14`) は 11 列から − レールへ。C1 (`b14`–`b15`) は隣の 15 列 (コレクタ) へ 1 穴の幅で挿す
- コレクタ (上の 15 列): L1 (`c15`–`c20`) を通して 20 列から上の + レールへ
- ベース (下の 16 列): R2 は下の − レールへ縦に、CB (`g16`–`g19`) は 19 列から下の − レールへ、R1 (`f16`–`f22`) は 22 列から下の + レールへ (赤の線は − レールをまたぐ)
- Scope の 1+ (青) はエミッタ (`j14`)、2+ (緑) はコレクタ (`j15`)。1− と 2− は下の − レールへ
- 1 MHz の回路なので、L1・C1・C2 のリードは短くし、ブレッドボードの上で輪を小さくする。プローブとブレッドボードの容量 (数十 pF の目安) が
  C2 に並列に入っても C2 (2.2 nF) に比べて小さいので、周波数は 1〜2 % しか動かない (下の LTspice の表)

## 計器の設定

オシロには AD3 の Scope を使う。1 MHz 弱の正弦波の振幅と周期を見る題で、10 MHz より低いから。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (エミッタ、10 列) | DC、1 V/div |
| Scope CH2 (コレクタ、11 列) | DC、2 V/div |
| Time | 500 ns/div (5 µs に約 4.7 周期) |
| Trigger | CH2、立ち上がり、5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 エミッタ (CH1) とコレクタ (CH2) — 同じ位相で約 0.93 MHz
time: 500ns/div
trigger: ch2 rising 5V
ch1: {wave: sine 934kHz 2.9Vpp offset 0.89V, range: 1V/div, position: -1div}
ch2: {wave: sine 934kHz 11Vpp offset 4.95V, range: 2V/div, position: -2.5div}
cursors: [268ns, 1.339us]
measure: [vpp, vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/10-colpitts.svg)

図3 は LTspice の値 (下の表) で描いた想定の波形で、実測ではない。実際の波形はトランジスタが振り切れる所で少しだけ平らになる
(LTspice ではコレクタの高調波ひずみが 2.4 %、エミッタが 1.0 %)。カーソルの間隔 1.07 µs が 1 周期 (山から次の山)。
エミッタとコレクタは同じ向きに動き、エミッタの振れはコレクタの約 0.26 倍 (C1 と C2 の分圧) になる。

AD3 の Spectrum (FFT) で CH2 を見ると、934 kHz の基本波の隣に 2 倍・3 倍の高調波が小さく立つ。振れが大きい分の高調波で、
発振回路の出力を次の回路へ渡すときにフィルタを入れる理由になる (第 9 章)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 (発振の範囲は 27 MHz 以下。1 MHz は十分に内側) |
| L1 | アキシアルのコイル (カラーコード) | 47 µH |
| C1 | セラミックコンデンサ (C0G / CH) | 820 pF (821) |
| C2 | セラミックコンデンサ (C0G / CH) | 2.2 nF (222) |
| CB | 積層セラミックコンデンサ | 0.1 µF (104) |
| R1 | 抵抗 | 22 kΩ |
| R2 | 抵抗 | 10 kΩ |
| RE | 抵抗 | 1 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+/2+ |

C1・C2 は温度で容量の動きにくい C0G (CH) にする。X7R などの高誘電率のセラミックは温度と電圧で容量が 1 割以上動き、周波数がふらつく。

## 見るべき値

周波数の計算 (理想): C<sub>s</sub> = 820 × 2200 / (820 + 2200) ≈ 597 pF、f = 1 / (2π √(47 µH × 597 pF)) ≈ **949 kHz**。
実際は C1・C2 にトランジスタの容量とプローブの容量が足されて、少し下がる。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 発振の周波数 (CH2) | 約 0.93 MHz (計算 949 kHz) | L1 と C1・C2 の直列で決まる。プローブとトランジスタの容量で 2 % ほど下がる |
| コレクタの振れ (CH2) | 約 11 Vpp (−0.55〜10.45 V) | L1 があるので 5 V を中心に上下し、電源より高くまで上がる |
| エミッタの振れ (CH1) | 約 2.9 Vpp | コレクタの約 0.26 倍。C1 / (C1 + C2) の分圧 |
| ベースの直流 (テスター) | 約 0.2 V (発振を止めると 1.56 V) | 振れの大きい間はベース-エミッタが整流して CB を下向きに充電し、動作点が自分で下がる |
| 電源の電流 | 約 1 mA | |

C2 を 3.3 nF・4.7 nF に替えると、周波数は 0.89 MHz・0.86 MHz に下がり、エミッタの振れは 2.1 Vpp・1.6 Vpp に小さくなる (戻す割合が減る。LTspice の値)。
C1 を外すと帰還が無くなり、発振は止まる。

## LTspice での確かめ

`sim/10-colpitts.cir` で図1 を 2 ms の過渡解析で走らせ、終わりの 0.1 ms で周波数・振幅・電流を読んだ。
Q1 は 3-1 と同じ 2SC1815 の模型 (BF を 120・250・400 に振る)。L1 の巻線の抵抗 6 Ω (1 MHz で Q 約 50) と、
Scope の入力 (1 MΩ と 20 pF) を CH1・CH2 に置いたのは仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 発振の周波数 (hFE 250) | 約 0.93 MHz (計算 949 kHz) | 934 kHz | 合う (計算より 1.6 % 低い。プローブとトランジスタの容量の分) |
| hFE 120 / 400 のときの周波数 | 変わらない | 934.08 / 934.05 kHz | 合う |
| コレクタの振れ | 約 11 Vpp (−0.55〜10.45 V) | 11.0 Vpp (−0.55〜10.45 V) | 合う |
| エミッタの振れ | 約 2.9 Vpp | 2.91 Vpp (−0.57〜2.34 V) | 合う |
| ベースの直流 (発振中) | 約 0.2 V | 0.23 V | 合う |
| 電源の電流 | 約 1 mA | 0.97 mA | 合う |
| 高調波ひずみ (コレクタ / エミッタ) | 2.4 % / 1.0 % | 2.36 % / 1.02 % | 本文の値は LTspice の読み |
| C2 を 3.3 nF / 4.7 nF にしたとき (同じデッキの C2 だけを替えた) | 0.89 / 0.86 MHz、エミッタ 2.1 / 1.6 Vpp | 891 / 864 kHz、2.12 / 1.56 Vpp | 本文の値は LTspice の読み |

## 出典

自作。

参考: [コルピッツ発振回路 (Wikipedia)](https://ja.wikipedia.org/wiki/コルピッツ発振回路)、[Colpitts oscillator (Wikipedia)](https://en.wikipedia.org/wiki/Colpitts_oscillator)
