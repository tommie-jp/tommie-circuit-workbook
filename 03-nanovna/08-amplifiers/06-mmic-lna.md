---
book: nanovna
chapter: 8
id: 8-6
title: LNA (MMIC) の S21 / S11
tier: 100
source: 自作。ERA-3SM+ の特性と推奨回路は Mini-Circuits のデータシート
board: CB
device: H4
---

# 8-6 LNA (MMIC) の S21 / S11

**MMIC** (モノリシックのマイクロ波 IC) の増幅器を測る。例は Mini-Circuits の
**ERA-3SM+** (DC〜3 GHz、ダーリントン接続、**入出力とも 50 Ω に整合済み**)。
8-4 のトランジスタは入出力が 50 Ω から大きく外れていたが、MMIC は中に整合と
帰還が入っていて、**そのまま 50 Ω の線の途中に挿せる**のが違い。H4 の範囲
(100 MHz〜1.5 GHz) で利得 (S21) と入力の反射 (S11) を測る。

周波数が GHz に近いので、治具は perfboard ではなく**銅張り基板の 50 Ω の
マイクロストリップ**にする (perfboard の治具は 300 MHz くらいまでが目安、3-6)。

**CH1 の最大入力に注意** (0-3): ERA-3SM+ の出力は飽和で +13.6 dBm (データシートの
代表値) まで出る。**出力に 20 dB の SMA 固定アッテネータを必ず挟む**
(CH1 には最大でも約 −6 dBm)。

## この実験で確かめる式

データシートの代表値 (Id = 35〜40 mA) を読む。

| 周波数 | 利得 (S21) | 入力反射損失 (−S11) | 出力反射損失 (−S22) |
| --- | --- | --- | --- |
| 100 MHz | 23.4 dB | 30 dB | 21 dB |
| 1 GHz | 21 dB | 19 dB | 17 dB |

**バイアス**: MMIC の出力のピン (3 番) は信号の出口であり、同時に電源の入口でもある。
5 V から抵抗 Rbias で電流を決めて、RFC (高周波を止めるコイル) を通して 3 番へ入れる。

**Rbias = (Vcc − Vd) / Id = (5 − 3.2) / 35 mA = 51.4 Ω → E24 の 51 Ω**
(Id = 35.3 mA、Rbias の消費 64 mW で 1/4 W の半分に収まる)。
データシートの推奨表は Vcc 7 V からで、5 V では Rbias が小さく、
**Rbias だけでは出力の 50 Ω を食う** (51 Ω が出力に並列に入り、利得が大きく減る)。
だから **RFC が要る**。RFC は 1 µH と 100 nH の直列。1 µH が低い周波数
(100 MHz で 630 Ω) を、100 nH が 1 µH の自己共振より上を受け持つ (100 nH を MMIC の側に置く)。

## 回路図

```circuit
title: 図1 ERA-3SM+ の 1 段 (5 V、Rbias 51 Ω + RFC)
parts:
  BAT: battery a1 g1 5 l=$\mathrm{BAT}$
  J1: sma e3 mirror CH0
  C1: capacitor e4 e5 1n
  U1:
    type: ic3
    at: e7
    label: ERA-3SM+
    pins: [IN, GND, OUT]
  Rb: resistor a10 b10 51
  L2: inductor b10 c10 1u
  L1: inductor c10 d10 100n
  Cbp: capacitor b12 c12 10n
  C2: capacitor e11 e12 1n
  J2: sma e14 CH1
  GBAT: ground g1
  GJ1: ground f3
  GU1: ground f7
  GCbp: ground c12
  GJ2: ground f14
wires:
  - a1 -- a10
  - J1.1 -- e4
  - J1.2 -- f3
  - e5 |- U1.IN
  - U1.GND |- f7
  - U1.OUT -| e10
  - e10 -- d10
  - e10 -- e11
  - b10 -- b12
  - e12 -- e14 -- J2.1
  - J2.2 -- f14
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/06-mmic-lna.svg)

- U1 のピンは 1 = IN、2・4 = GND (図では 1 本にまとめた)、3 = OUT と電源。
  **GND のピンはビアで裏のベタへ最短で**落とす。ここのインダクタンスは MMIC の帰還を
  狂わせ、利得の平坦さを崩す
- C1・C2 (1 nF) は直流カット。100 MHz で 1.6 Ω と小さい
- Cbp (10 nF) は Rbias と RFC の間を交流的に GND へ落とす
- J2 の先に **20 dB の SMA 固定アッテネータ**を付け、その先に CH1 のケーブルをつなぐ

## 実体配線図

基板は FR4 (厚さ 1.6 mm、比誘電率 4.4 と仮定) の両面銅張りで、5×7 cm の銅張り基板に収まる。裏は全面 GND。
J1 に CH0 のケーブルを、J2 に 20 dB アッテネータ経由で CH1 のケーブルをつなぐ。電源の 5 V は USB アダプタなどから取る。

```copper
title: 図2 ERA-3SM+ を銅張り基板に組む
f: 1G
sheets:
  - name: 治具
    board:
      size: 70x50mm
      ground: back
    copper:
      Lin: line 0,36 27,36 3.06mm
      Lout: line 41,36 70,36 3.06mm
      G1: pad 34,28 4x4mm
      VG1a: via 33,28
      VG1b: via 35,28
      G2: pad 34,44 4x4mm
      VG2a: via 33,44
      VG2b: via 35,44
      N1: pad 46,26 4x4mm
      N2: pad 56,26 4x4mm
      VCC: pad 66,26 4x4mm
      GCb: pad 56,14 4x4mm
      VCb: via 56,14
    parts:
      J1: sma left 36 CH0
      J2: sma right 36 CH1
      C1: capacitor/1608 12,36 1n
      C2: capacitor/1608 60,36 1n
      U1: mmic 27,36 G1 41,36 G2 ERA-3SM+
      L1: inductor 46,36 N1 100n
      L2: inductor N1 N2 1u
      Cbp: capacitor N2 GCb 10n
      Rb: resistor N2 VCC 51
      BAT:
        type: device
        at: 62,-9
        label: 5 V
        pins: ["-", "+"]
    wires:
      - BAT.+ -- VCC red
      - BAT.- -- GCb black
  - name: スルー
    board:
      size: 56x20mm
      ground: back
    copper:
      L3: line 0,10 56,10 3.06mm
    parts:
      J3: sma left 10 CH0
      J4: sma right 10 CH1
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/copper/06-mmic-lna.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 50 Ω の線 | **幅 3.06 mm** (計算値 50.0 Ω、実効比誘電率 3.3。図の線路のラベルの値)。銅張り基板の中央を左右に通す |
| 端面 SMA (J1・J2) | 左右の縁に 1 つずつ。中心ピンを線の端に、外皮の脚を表の GND の縁と裏のベタへ半田付け |
| U1 (ERA-3SM+) | 線の中央。線を 1 番 (IN) と 3 番 (OUT) のピンの間で切る |
| U1 の GND (2・4 番) | 線の上下に GND の島 (4 mm × 4 mm)。**島ごとに 2 か所、0.8 mm の穴に線を通して裏のベタへ** (ビアの代わり) |
| C1・C2 (1 nF、1608) | 線を 1 mm 切り、その隙間を跨いで載せる |
| L1 (100 nH)・L2 (1 µH) | OUT 側の線から直角に上へ。100 nH を線に近い側に |
| Cbp・Rbias | L2 の先の島 (N2) に。Cbp は GND の島 (穴で裏のベタへ)、Rbias (1/4 W の軸物) は 5 V の島へ |
| スルー (図2 (2枚め)) | 治具と同じ両面の FR4 から **56 mm × 20 mm** を切り出し、幅 3.06 mm の線を 1 本通す。長さ 56 mm は治具の Lin (27 mm) と Lout (29 mm) の和。端面 SMA (J3・J4) の付け方は J1・J2 と同じ |

- 銅張り基板を流れる電流は Id = 35 mA で、幅 3 mm の線に対して十分小さい (C 値の目安 500 mA 以下)
- 50 Ω の幅は Hammerstad の近似式で計算した値。基板の厚さや比誘電率が違えば幅も変わる
  (測って確かめるのは 3-13・9-7)
- **治具だけで先に確かめる**: U1 と C1・C2 を載せる前に、切る前の線 (スルー) の S21 と
  S11 を測っておく。1.5 GHz で S11 が −20 dB 以下なら治具は使える (3-6 と同じ考え方)
- **治具とスルーを 1 つの図に並べたのは、同じ基材・同じ線路幅で切り出すため**。U1 の両側の
  線を足すとスルーの線と同じ長さになるので、スルーの S21 を基準にすれば、治具の線の損失と遅延を
  差し引いて U1 だけの S21 が読める。U1 を載せた後も、スルーは治具の確かめに使い続けられる

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題。電源の 5 V は USB アダプタ)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜1.5 GHz |
| 点数 | 141 |
| 校正 | SOLT。CH0 のケーブルの先と、**20 dB アッテネータを付けた CH1 側の先**で (アッテネータを校正に含める) |
| 表示 | 図3 は S21 の Log Mag、図4 は S11 の Log Mag と Smith |

アッテネータを校正に**含める**と、画面の S21 は MMIC の利得そのもの (+21 dB など) になる。
**含めない** (ケーブルの先で校正してから付ける) と、画面は利得 − 20 dB。
どちらで校正したかを表に書いておく。

利得のある画面はこのフェンスの模型では描けないので、
**先にアッテネータ単体の基準** (校正に含めない場合の −20 dB) を示す (8-1 と同じやり方)。

```vna
device: h4
sweep: 100M-1.5G 141
title: 図3 20 dB アッテネータ単体の S21 (MMIC を挟む前の基準)
dut:
  - series R 40.9
  - shunt R 10.1
  - series R 40.9
traces:
  - S21 logmag
markers:
  - 100M
  - 1G
  - 1.5G
notes:
  - text 150M -40dB: MMIC を挟むと +3.4 dB (100 MHz)・+1.0 dB (1 GHz) (計算)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/06-mmic-lna-1.svg)

入力の反射 (S11) は受け身の画面なので描ける。データシートの入力反射損失
(100 MHz で 30 dB、1 GHz で 19 dB) に**大きさだけ合わせた等価回路**
(50 Ω に 3 Ω と 1.8 nH が直列) で描く。位相は合わせていない。

```vna
device: h4
sweep: 100M-1.5G 141
title: 図4 MMIC の入力の S11 — 周波数とともに −30 dB から −16 dB へ (等価回路)
dut:
  - series R 3 esl 1.8n
  - shunt R 50
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 100M
  - 1G
  - 1.5G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/06-mmic-lna-2.svg)

- どの周波数でも S11 は −15 dB より下 (SWR 1.4 以下)。Smith では**中心のすぐ近く**に
  留まる。8-2・8-4 のトランジスタ (外周の近く) と比べると、整合済みの意味が分かる
- 周波数を上げると、ピンと中の配線のインダクタンスで少しずつ上 (誘導性) へずれる

## 見るべき値

アッテネータを**校正に含めない**場合の画面の S21 (= 利得 − 20 dB) も並べる。
利得と S11 はデータシートの代表値、アッテネータは理想の 20.0 dB (計算値)。

| 周波数 | MMIC の S21 | 画面の S21 (校正に含めない) | S11 (等価回路) |
| --- | --- | --- | --- |
| 100 MHz | +23.4 dB | +3.4 dB | −30.1 dB |
| 1 GHz | +21 dB | +1.0 dB | −18.9 dB |
| 1.5 GHz | 約 +19.9 dB (1 GHz と 2 GHz の 21・18.7 dB から直線で) | 約 −0.1 dB | −15.7 dB |

| バイアス | 値 |
| --- | --- |
| Vd (U1 の 3 番の電圧) | 3.2 V (代表値、3.0〜3.4 V) |
| Id | 35 mA (Rbias の両端 1.8 V をテスターで読む) |

- **S21 は 1.5 GHz まで 3 dB ほどしか落ちない**。8-4 のトランジスタ (1 けたで 20 dB 落ちる)
  と比べ、広い帯域で平らなのが MMIC の特徴
- 利得が 100 MHz より下で落ちるなら C1・C2 か RFC が足りない。上で波打つなら GND のピンの
  ビアか RFC の自己共振を疑う
- H4 は 300 MHz より上で高調波を使うので、900 MHz〜1.5 GHz では読みのばらつきが増える
  (9-4)。掃引を何回か重ねて平均する

## 出典

- Mini-Circuits, ERA-3SM+ データシート (Rev. R): 利得・反射損失・Vd・推奨電流・最大定格・推奨回路
- マイクロストリップの幅は Hammerstad の近似式で計算した
