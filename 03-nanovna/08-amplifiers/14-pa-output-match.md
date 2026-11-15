---
book: nanovna
chapter: 8
id: 8-14
title: 小電力パワーアンプの出力整合
tier: 200
source: 自作。2SC3355 の定格は NEC (現 Renesas) のデータシート
board: CB
device: H4
---

# 8-14 小電力パワーアンプの出力整合

> **値は式と LTspice (損失の無い理想の部品) で出したもので、実機では測っていない。**

送信機の終段のような**パワーアンプ**では、トランジスタのコレクタが「出したい電力を出せる抵抗」(負荷線の抵抗) を見るように、
50 Ω (オーム) のアンテナを**整合回路で変換**する。小信号のアンプ (8-1〜8-5) の整合は反射を減らすためだが、パワーアンプの出力の整合は
**電源の電圧で出せる電力を決めるため**で、目標の抵抗が 50 Ω ではない。
この題では、5 V で約 100 mW (+20 dBm) を 144 MHz で出す 2SC3355 の段を考え、コレクタに **100 Ω** を見せる L 形の整合回路を
銅張り基板に組む。**トランジスタの代わりに 100 Ω の抵抗を付けて**、出力の SMA から VNA で見て 50 Ω に合っているかを確かめる。

## この実験で確かめる式

**負荷線の抵抗**: コレクタの電圧は 0 V 近く (飽和の V<sub>CE(sat)</sub> 約 0.5 V) から 2 V<sub>CC</sub> 近くまで振れる (チョークで電源を入れるので、
中心が V<sub>CC</sub>)。振幅 V<sub>p</sub> = V<sub>CC</sub> − V<sub>CE(sat)</sub> = 4.5 V で電力 P を出すには

R<sub>L</sub> = V<sub>p</sub>² / (2 P) = 4.5² / (2 × 0.1 W) ≈ **100 Ω**

A 級で動かすなら、コレクタの電流は V<sub>p</sub> / R<sub>L</sub> = 45 mA 以上がいる。アイドル電流を 50 mA にすると、トランジスタの損失は
5 V × 50 mA = 250 mW で、2SC3355 の最大 (600 mW、I<sub>C</sub> 100 mA) に収まる。

**L 形の整合 (100 Ω → 50 Ω、144 MHz)**: Q = √(100 / 50 − 1) = 1。コレクタ側に並列のサセプタンス 1 / (Q × 100) = 0.01 S (ジーメンス)、
50 Ω 側に直列のリアクタンス Q × 50 = 50 Ω。

- 直列の L2: 50 Ω / (2π × 144 MHz) = 55 nH → **56 nH** (E12)
- 並列の C: 0.01 S / (2π × 144 MHz) = 11.1 pF。ここに**電源を入れるチョーク L1 (330 nH、144 MHz で 299 Ω)** が並列に入り、
  −0.0033 S を引くので、C2 は 0.0133 S 分の **14.8 pF → 15 pF** (E12)
- C3 (1 nF) は直流カット (144 MHz で 1.1 Ω)

この回路は低域通過形 (直列 L・並列 C) なので、コレクタの 2 倍・3 倍の高調波も少し落とす。ただし Q = 1 では足りず、本物の送信機は
この後ろに低域通過フィルタ (6-1) を置く。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 出力の整合回路 (Q1 の代わりに RD 100 Ω を付けて測る)
parts:
  RD: resistor 3,4 3,6 100
  C2: capacitor 5,4 5,6 15p
  L1: inductor 7,2 7,4 330n
  VCC: vcc 7,1 5V
  C4: capacitor 9,1 9,2 1n
  L2: inductor 8,4 10,4 56n
  C3: capacitor 11,4 12,4 1n
  J1: sma 14,4 CH0
  G1: ground 3,6
  G2: ground 5,6
  G3: ground 9,2
  G4: ground 14,5
wires:
  - 3,4 -- 5,4 -- 7,4 -- 8,4
  - 7,1 -- 7,2
  - 7,1 -- 9,1
  - 10,4 -- 11,4
  - 12,4 -- J1.1
  - J1.2 -- 14,5
notes:
  - text 3.2,3.6 small left: Q1 のコレクタの所
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/14-pa-output-match.svg)

- RD は**測るときだけ**付ける 100 Ω。実際の回路では、ここに 2SC3355 のコレクタ (エミッタは GND、ベースは前段から) が来る
- L1 はチョーク (コレクタに 5 V を入れる)、C4 はその 5 V の端を高周波で GND に落とす。測るときは 5 V をつながなくてよい
  (C4 が交流的に GND にするので、画面は同じ)
- 信号はふだん左 (コレクタ) から右 (出力) へ流れる。VNA は出力の J1 から逆向きに覗く

## 実体配線図

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
title: 図2 出力の整合回路を銅張り基板に Manhattan 式で組む
board:
  size: 50x30mm
  ground: front
style:
  back: off
copper:
  COL: pad 15,15 4x4mm
  M: pad 30,15 4x4mm
  S1: pad 47.5,15 5x2mm
  VCC: pad 15,5 4x4mm
parts:
  J1: sma right 15 CH0
  RD: resistor COL 15,24 100
  C2: capacitor COL 8,22 15p
  L1: inductor COL VCC 330n
  C4: capacitor VCC 24,5 1n
  L2: inductor COL M 56n
  C3: capacitor M S1 1n
notes:
  - text 6,13: Q1 の C
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/copper/14-pa-output-match.svg)

- 片面の銅張り基板 (50 mm × 30 mm) の表を GND にし、島 (4 mm 角) を貼る。COL がコレクタの島で、Q1 (2SC3355、TO-92) のコレクタのピンをここに
  半田付けする。**測るときは Q1 を付けず、RD (100 Ω) を COL の島から表の GND へ、リードを短くして付ける**
- C2 は COL から表の GND へ、リードを最短に。C2 のリードが長いと直列のインダクタンスで C2 が大きく見え、整合が下へずれる
- L2 (56 nH) と L1 (330 nH) は図ではリードの部品で描いたが、チップのインダクタ (2012) でも空芯の手巻きでもよい。チップの 330 nH は自己共振が
  数百 MHz にあるので、資料で 144 MHz より十分上か確かめる (目安)
- 144 MHz での波長は 2 m で、島の間 (15 mm) は電気長 3° ほど。この周波数なら Manhattan の島で組める (3-11)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN 高周波トランジスタ (TO-92) | 2SC3355 (V<sub>CEO</sub> 12 V、I<sub>C</sub> 100 mA、600 mW、f<sub>T</sub> 6.5 GHz)。測るときは付けない |
| RD | 抵抗 (1/4 W、リードを 3 mm ほどに切る) | 100 Ω (測るときだけ、Q1 の代わり) |
| C2 | セラミックコンデンサ (C0G) | 15 pF |
| C3, C4 | セラミックコンデンサ | 1 nF (102) |
| L1 | インダクタ (チョーク) | 330 nH |
| L2 | インダクタ | 56 nH |
| J1 | SMA コネクタ (端面実装) | — |
| — | 電源 | 5 V (Q1 を付けて動かすときだけ。約 50 mA) |

## 掃引の設定

計器は VNA (NanoVNA-H4。LiteVNA64 でも同じ)。1 ポート (S11) だけを使う。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50〜300 MHz |
| 点数 | 201 |
| 校正 | SOL を CH0 のケーブルの先で |
| 表示 | S11 の Log Mag と Smith |

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 50M-300M 201
title: 図3 出力から見た S11 (Q1 の代わりに 100 Ω) — 144 MHz で 50 Ω に合う
dut:
  - series C 1n
  - series L 56n
  - shunt C 15p
  - shunt L 330n
  - shunt R 100
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 100M
  - 144M
  - 160M
notes:
  - band 144M 146M: 2 m バンド
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/14-pa-output-match.svg)

- **144 MHz で S11 は約 −38 dB**、Smith の点は中心。−20 dB より下は約 128〜157 MHz
- 100 MHz では −12 dB、Smith では中心の右 (抵抗が大きい側)。周波数を上げると点は中心を通って左上 (誘導性) へ抜ける

## 見るべき値

計算値 (LTspice と図の読み値)。

| 周波数 | S11 (RD 100 Ω) | S11 (Q1 の C<sub>ob</sub> 1 pF を足したとき) |
| --- | --- | --- |
| 100 MHz | −12.1 dB | −12.8 dB |
| 130 MHz | −21.3 dB | −24.2 dB |
| 144 MHz | −38.9 dB (49.0 − j0.4 Ω。図3 は −38.5 dB) | −25.1 dB |
| 160 MHz | −18.3 dB | −15.4 dB |

- **谷が 144 MHz から下にずれていたら、並列の容量が多い** (C2 のリード、島の浮遊容量)。C2 を 12 pF に替えるか、島を小さくする
- Q1 を付けると、その出力容量 C<sub>ob</sub> (データシートの代表 0.65 pF・最大 1 pF、10 V のとき) が C2 に足され、谷は 138 MHz へ下がる
  (1 pF のとき、LTspice)。C2 を 1 pF 小さくして戻す。5 V では C<sub>ob</sub> は 10 V の値より少し大きい (接合の容量は電圧が下がると増える)
- RD を 100 Ω から 82 Ω や 120 Ω に替えて測ると、谷の深さが −20 dB ほどに浅くなる。**整合は抵抗の値で決まる** (負荷線の抵抗を変えると出せる電力も変わる)
- Q1 を付けて電力を出すときに S21 (利得) を測るなら、**出力と CH1 の間に 30 dB のアッテネータを挟む** (+20 dBm を CH1 に入れない。0-3)

## LTspice での確かめ

`sim/14-pa-output-match.cir` で図1 を出力の J1 から `.ac` にかけた (信号源 2 V・50 Ω で入射波を 1 にし、S11 = V(o) − 1。コイルは損失なし)。
Q1 の C<sub>ob</sub> を 0 と 1 pF の 2 通りで回した。実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| S11 (144 MHz) | 図3 の −38.47 dB (48.9 − j0.4 Ω) | −38.90 dB (48.95 − j0.43 Ω) | 合う (差は C4 の 1.1 Ω を図の模型に入れていないぶん) |
| S11 (100 MHz・160 MHz) | 図3 の −12.13 dB・−18.23 dB | −12.09 dB・−18.26 dB | 合う |
| C<sub>ob</sub> 1 pF のときの谷 | 下にずれる | 137.7 MHz で −30.0 dB | 合う |
| 負荷線の抵抗 | 100 Ω (式) | — | 式だけ (トランジスタは模型にしていない) |

## 出典

- [NEC, 2SC3355 データシート (P10355EJ3V1DS00)](https://static.chipdip.ru/lib/225/DOC000225164.pdf): V<sub>CEO</sub> 12 V、I<sub>C</sub> 100 mA、P<sub>T</sub> 600 mW、
  f<sub>T</sub> 6.5 GHz、C<sub>ob</sub> 0.65 pF (代表)、ピンの並び B・E・C

参考: [Impedance matching (Wikipedia)](https://en.wikipedia.org/wiki/Impedance_matching)、[Power amplifier classes (Wikipedia)](https://en.wikipedia.org/wiki/Power_amplifier_classes)
