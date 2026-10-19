---
book: nanovna
chapter: 6
id: 6-1
title: LC ローパス (7 次)
tier: 50
source: 自作
board: PF
device: H4
---

# 6-1 LC ローパス (7 次)

コイルとコンデンサだけで作るローパスフィルタ。次数を上げるほど遮断は急になるが、
部品も増える。ここでは 7 次のバターワース (最平坦) 特性を、E12/E24 系列の実在の
値で作り、カットオフ周波数 30 MHz を狙う。

## この実験で確かめる式

7 次バターワースの LC はしご形回路 (π 型、両端が並列コンデンサ) の値は、
正規化定数 g (g1 = g7 = 0.445、g2 = g6 = 1.247、g3 = g5 = 1.802、g4 = 2.000) から

**C = g / (2π f_c R)**、**L = g R / (2π f_c)** (R = 50 Ω)

で決まる。計算値 (丸める前): C1 = C7 = 47.2 pF、L2 = L6 = 330.8 nH、
C3 = C5 = 191.2 pF、L4 = 530.5 nH。E12/E24 系列に丸めると
C1 = C7 = 47 pF、L2 = L6 = 330 nH、C3 = C5 = 200 pF、L4 = 560 nH になる。
200 pF は E12 に無いので、**100 pF を 2 個並列**にして作る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 7 次 LC ローパス (C-L-C-L-C-L-C)
parts:
  J1: sma 2,2 mirror CH0
  C1: capacitor 4,2 4,4 47p
  L1: inductor 5,2 7,2 330n
  C2: capacitor 8,2 8,4 200p
  L2: inductor 9,2 11,2 560n
  C3: capacitor 12,2 12,4 200p
  L3: inductor 13,2 15,2 330n
  C4: capacitor 16,2 16,4 47p
  J2: sma 18,2 CH1
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 8,4
  G4: ground 12,4
  G5: ground 16,4
  G6: ground 18,3
wires:
  - J1.1 -- 4,2 -- 5,2
  - 7,2 -- 8,2 -- 9,2
  - 11,2 -- 12,2 -- 13,2
  - 15,2 -- 16,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 18,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/01-lc-lowpass.svg)

- 両端が並列コンデンサ (shunt C) の π 型。直列側はコイル
- 式の添字は g の番号 (C1・L2・…・C7) で、図の部品番号とは違う。図では 47 pF の
  C1・C4 が両端、200 pF (100 pF を 2 個並列) の C2・C3 が内側、330 nH の L1・L3 と
  560 nH の L2 が直列側。次数が奇数なので両端の素子は同じ種類 (コンデンサ) になる

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 34x10
  slots: on
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 f3 47p
  L1: inductor e5 e9 330n
  C2a: capacitor e10 f10 100p
  C2b: capacitor e12 f12 100p
  L2: inductor e13 e18 560n
  C3a: capacitor e19 f19 100p
  C3b: capacitor e21 f21 100p
  L3: inductor e22 e26 330n
  C4: capacitor e28 f28 47p
  J2: sma/female-edge e34 f35
wires:
  - e1 -- e3
  - e3 -- e5
  - e9 -- e10
  - e10 -- e12
  - e12 -- e13
  - e18 -- e19
  - e19 -- e21
  - e21 -- e22
  - e26 -- e28
  - e28 -- e34
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h3 black
  - h3 -- f3 black
  - h3 -- h10 black
  - h10 -- f10 black
  - h10 -- h12 black
  - h12 -- f12 black
  - h12 -- h19 black
  - h19 -- f19 black
  - h19 -- h21 black
  - h21 -- f21 black
  - h21 -- h28 black
  - h28 -- f28 black
  - h28 -- h33 black
  - f35 -- f33 black
  - f33 -- h33 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/01-lc-lowpass.svg)

- e 行が信号の通り道。6 つのコンデンサの下側のピン (f 行) を h 行の GND バスへ落とす
- 回路図の C2・C3 (200 pF) は、それぞれ 100 pF 2 個 (C2a・C2b、C3a・C3b) の並列
- コイルは軸物 (`inductor`)。330 nH と 560 nH は市販のカラーコード付きインダクタで買える。
  この値のアキシアル (例: Bourns 78FR33K・78FR56K) は Q の試験周波数が 25 MHz、SRF が最小 335 MHz・245 MHz で、
  30 MHz のフィルタに合う部品。使う周波数が SRF の 1/8 以下なので、値の持ち上がりは 2 % 以下。SMD にする利点は無い
  (チップの 330 nH は SRF が高い代わりに Q は同等以下で、ユニバーサル基板に載らない)。帯域ごとの部品の形は
  [回路の教科書の「基板ごとの使える範囲」](../../01-circuits/README.md#基板ごとの使える範囲-この教科書の制限基準)の「部品の形と周波数の範囲」の表
- Q を上げたいなら T37-2 (鉄粉 #2、A<sub>L</sub> 4.0 nH/回²。4-14) に手巻きする: 9 回で 324 nH、12 回で 576 nH。
  フェンスは `inductor/toroid` に `T37-2 9t` と書く。通過帯域の損失が 1/3 ほどになる (下の「寄生成分を入れた比べ」)
- リード付きセラミック 47 pF・100 pF は、リードと本体で ESL ≈ 5.6 nH (4-2 の 2 nH + 4-7 の穴 2 つぶん 3.6 nH) と見ても
  SRF は約 310 MHz・210 MHz で、通過帯域には効かない

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜100 MHz |
| 点数 | 201 |
| 校正 | SOLT (Thru はケーブル 2 本を直結) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

丸めた値 (47p/330n/200p/560n) で計算した**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-100M 201
title: 図3 7 次ローパス (E12/E24 丸め後) — −3 dB は 28.4 MHz
dut:
  - shunt C 47p
  - series L 330n
  - shunt C 200p
  - series L 560n
  - shunt C 200p
  - series L 330n
  - shunt C 47p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 20M
  - 28.4M
  - 40M
  - 100M
notes:
  - band 1M 28.4M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/01-lc-lowpass.svg)

- 部品を E12/E24 系列に丸めたので、実際のカットオフ (−3 dB) は設計の 30 MHz より
  やや低い**約 28.4 MHz**になる (計算値)
- マーカー 4 (100 MHz) では −74 dB まで落ちる。急峻さは次数の証

## 見るべき値

計算値 (理想の集中定数、コイルは無損失として)。

| 周波数 | S21 (計算値) | 分かること |
| --- | --- | --- |
| 1 MHz | 約 0 dB | 通過帯域 |
| 20 MHz | −0.06 dB | まだほぼ平ら |
| 28.4 MHz | −3.0 dB | 実際のカットオフ (丸めた値のため 30 MHz より低い) |
| 40 MHz | −19.6 dB | 急な下がり (7 次) |
| 100 MHz | −74.4 dB | 阻止帯域。実測ではコイルどうしの結合・基板の浮遊容量と部品の SRF (4-2・4-4) で頭打ちになる (ユニバーサル基板では −50〜−60 dB が目安) |

実測では、コイルの Q が有限なので通過帯域の S21 は 0 dB ちょうどにはならない
(小さな挿入損失が出る。6-4 で確かめる)。Q 40〜50 のアキシアルで約 0.5 dB、カットオフは 1〜1.5 MHz 下がる
(下の「寄生成分を入れた比べ」の計算値)。

## LTspice での確かめ

`sim/01-lc-lowpass.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。
理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 20 MHz | S21 / S11 | −0.06 dB / −18.76 dB | −0.06 dB / −18.76 dB | 合う |
| 図3 | 28.4 MHz | S21 / S11 | −2.98 dB / −3.04 dB | −2.98 dB / −3.04 dB | 合う |
| 図3 | 40 MHz | S21 / S11 | −19.55 dB / −0.05 dB | −19.55 dB / −0.05 dB | 合う |
| 図3 | 100 MHz | S21 / S11 | −74.43 dB / 0.00 dB | −74.43 dB / 0.00 dB | 合う |

4 点すべて図の読み値と合う。

### 寄生成分を入れた比べ

`sim/01-lc-lowpass-parasitic.cir` で、図2 の配線どおりに寄生成分を足して比べた (計算値。実測ではない):
コイルの直列抵抗 (30 MHz での Q から)、コイルの巻線間の容量 0.5 pF、コンデンサのリードと本体の ESL 5.6 nH、
h 行の GND バス (4-7 の 7 nH/cm)。

| 条件 | 20 MHz | 28.4 MHz | 40 MHz | −3 dB |
| --- | --- | --- | --- | --- |
| 理想 (図3 の読み値) | −0.06 dB | −2.98 dB | −19.55 dB | 28.4 MHz |
| アキシアル Q = 50、図2 の基板 | −0.54 dB | −4.6 dB | −22.3 dB | 27.0 MHz |
| 同じ部品、GND をベタに | −0.57 dB | −3.9 dB | −20.6 dB | 27.4 MHz |
| T37-2 手巻き Q = 150 (目安)、図2 の基板 | −0.20 dB | −4.1 dB | −22.1 dB | 27.4 MHz |
| チップ 2012 (Q = 40)、銅張り基板 | −0.70 dB | −4.0 dB | −20.5 dB | 27.3 MHz |

- 実測で効くのは**コイルの Q と部品の許容差** (6-11) で、SRF ではない。通過帯域に 0.5 dB ほどの挿入損失が出て、
  カットオフは 1〜1.5 MHz 下がる
- チップ部品にしても良くならない。手巻きで Q を上げると損失が 1/3 になる
- 阻止帯域はこの模型では評価できない。実物の底はコイルどうしの結合と基板の浮遊容量で決まる

## 出典

自作。7 次バターワースの g 値は標準的なフィルタ設計表による。
