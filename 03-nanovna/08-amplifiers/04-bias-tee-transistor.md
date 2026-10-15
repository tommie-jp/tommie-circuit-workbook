---
book: nanovna
chapter: 8
id: 8-4
title: バイアス T でトランジスタの S パラメータ
tier: 100
source: 自作
board: PF
device: H4
---

# 8-4 バイアス T でトランジスタの S パラメータ

8-1 のアンプは Rc・Re・バイアス抵抗まで含めた「回路」の S21 だった。ここでは
**トランジスタ (2SC1815) そのもの**の S パラメータを測る。エミッタを GND に直結し、
ベースとコレクタには**バイアス T** (直流だけを通すコイルと、交流だけを通す
コンデンサの組) で直流を与える。バイアス T は、NanoVNA のポートに直流を入れずに
能動部品へ電源を与えるための道具 (3-16 で詳しく作る)。

測る順は 2 段。**先にバイアス T だけ** (トランジスタの代わりに線でつなぐ) を測り、
掃引の範囲でバイアス T が信号を邪魔しないことを確かめる。それからトランジスタを
挿して S11 と S21 を測る。

## この実験で確かめる式

トランジスタの小信号の模型 (ハイブリッド π、**等価回路**):

| 要素 | 式 | 値 (Ic = 4.3 mA、計算値) |
| --- | --- | --- |
| g<sub>m</sub> | Ic / 26 mV | 0.165 S |
| r<sub>π</sub> | h<sub>FE</sub> / g<sub>m</sub> | 1.2 kΩ (h<sub>FE</sub> = 200) |
| C<sub>π</sub> | g<sub>m</sub> / (2π f<sub>T</sub>) | 330 pF (f<sub>T</sub> = 80 MHz) |
| C<sub>µ</sub> | データシートの C<sub>ob</sub> | 2 pF |
| r<sub>bb′</sub> | データシートの代表値 | 50 Ω |
| r<sub>o</sub> | V<sub>A</sub> / Ic | 約 23 kΩ (アーリー電圧 V<sub>A</sub> 100 V と仮定) |

- **低い周波数の S21 ≈ 2 g<sub>m</sub> × 50 Ω = 16.5 倍 = 24.3 dB** (ベースの入口が
  50 Ω よりずっと高いので、ベースには入ってくる波の約 2 倍がかかる)。r<sub>bb′</sub> で
  少し削れて、1 MHz では 23.5 dB (計算値)
- 周波数を上げると C<sub>π</sub> がベースを短絡していき、**S21 は 10 MHz あたりから
  1 けたごとに 20 dB ずつ落ちる**。f<sub>T</sub> (80 MHz) を過ぎると 0 dB を割る
- 入力の Z は、低い周波数では r<sub>π</sub> ∥ C<sub>π</sub> が見え、高い周波数では
  C<sub>π</sub> が短絡して **r<sub>bb′</sub> (50 Ω) だけ**が残る。だから S11 は周波数を上げるほど
  小さくなる (整合したように見える)

f<sub>T</sub> はデータシートの最小値 (80 MHz)、r<sub>bb′</sub> と C<sub>ob</sub> は代表値。実物の f<sub>T</sub> は
これより高いことが多く、そのぶん S21 の落ち始めが高い周波数へずれる。

**バイアス**: ベースへ RB = 200 kΩ で Ib = (5 − 0.7) V / 200 kΩ = 21.5 µA、
Ic = h<sub>FE</sub> × Ib = 4.3 mA (8-1 と同じ動作点)。h<sub>FE</sub> はばらつくので、
コレクタ側の Rs (100 Ω) の両端の電圧 (4.3 mA なら 0.43 V) をテスターで読んで確かめる。
外れていたら RB を E24 で替える (Ic が大きすぎれば 240 kΩ・300 kΩ)。
Vce = 5 − 0.43 ≈ 4.6 V。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 バイアス T 2 つで 2SC1815 に直流を与える
parts:
  BAT: battery 1,1 1,7 5 l=$\mathrm{BAT}$
  Cd: capacitor 2,1 2,3 10u
  J1: sma 3,5 mirror CH0
  C1: capacitor 4,5 5,5 0.1u
  RB: resistor 6,1 6,3 200k
  L1: inductor 6,3 6,5 100u
  Q1: npn 8,5
  Rs: resistor 10,1 10,2 100
  L2: inductor 10,2 10,4 100u
  C2: capacitor 11,4 12,4 0.1u
  J2: sma 14,4 CH1
  GBAT: ground 1,7
  GCd: ground 2,3
  GJ1: ground 3,6
  GQ1: ground 8,7
  GJ2: ground 14,5
wires:
  - 1,1 -- 2,1 -- 6,1 -- 10,1
  - J1.1 -- 4,5
  - J1.2 -- 3,6
  - 5,5 -- 6,5 -- Q1.B
  - Q1.E |- 8,7
  - Q1.C |- 10,4
  - 10,4 -- 11,4
  - 12,4 -- 14,4 -- J2.1
  - J2.2 -- 14,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/04-bias-tee-transistor.svg)

- C1・L1 が入力側のバイアス T、C2・L2 が出力側のバイアス T。コンデンサ (0.1 µF) は
  直流を止めて交流を通し、コイル (100 µH) は直流を通して交流を止める
- **エミッタは GND に直結** (8-1 の Re・Ce が無い)。測りたいのはトランジスタだけ
  だから。そのぶん動作点は RB だけで決まり、h<sub>FE</sub> のばらつきがそのまま Ic に出る
- Cd (10 µF) は 5 V の線を交流的に GND へ落とす。RB と Rs の上の端は交流では GND

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard に組む (バイアス T 2 つ + 2SC1815)
parts:
  J1: sma/female-edge a10 09
  BAT: battery d16 a16 5
  Cd: capacitor e15 e14 10u
  C1: capacitor c10 e10 100n
  RB: resistor g16 g13 200k
  L1: inductor h13 h10 100u
  Q1: transistor l9 k9 j9
  Rs: resistor n16 n13 100
  L2: inductor m13 m10 100u
  C2: capacitor o10 q10 100n
  J2: sma/female-edge x10 y9
wires:
  - d16 -- e16 red
  - e16 -- g16 red
  - g16 -- n16 red
  - e15 -- e16 red
  - a16 -- a14 black
  - a14 -- a11 black
  - a11 -- 011 black
  - e14 -- a14 black
  - a10 -- c10
  - e10 -- h10
  - h10 -- j10
  - j10 -- j9
  - g13 -- h13
  - k10 -- k9
  - k10 -- m10
  - m13 -- n13
  - m10 -- o10
  - q10 -- x10
  - 09 -- b9 black
  - b9 -- b6 black
  - b6 -- l6 black
  - l6 -- u6 black
  - l9 -- l6 black
  - y9 -- u9 black
  - u9 -- u6 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/04-bias-tee-transistor.svg)

- Q1 は 8-1 と同じく変換基板に載せた TO-92。ピンは実物 (1 = E、2 = C、3 = B) に
  合わせる。**エミッタ (j12) から GND の線 (m 行) までは短く太く**。ここの
  インダクタンスはそのまま利得を下げる
- L1・L2 は軸物の 100 µH。**1 MHz で 630 Ω** あり、50 Ω の信号線にほとんど
  負担をかけない
- 5 V は上の c 行 (赤)、GND は下の m 行 (黒)。電池の − は J1 の外皮 (h0) に落とし、
  外皮の下の腕 (j0) から m 行へつなぐ (J1 の 2 本の腕は同じ金物)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜150 MHz |
| 点数 | 150 |
| 校正 | SOLT。CH0 のケーブルの先に **20 dB のパッド** (0-3 の図と同じ) を付け、パッドの先で校正する |
| 表示 | 図3 は S21 と S11 の Log Mag、図4 は S11 の Log Mag と Smith |

**入力にパッドを入れる理由**: 1 MHz でこのトランジスタは 23.5 dB 増幅する。
小信号として測るには、ベースの振れを数 mV に抑えたい (26 mV に近づくと波形が歪み、
S21 が小さく読める)。CH0 の出力を 20 dB 下げておけば、CH1 に届く信号も
NanoVNA 自身の出力と同じくらいに収まる。**パッドを 10 dB 増やしても S21 の読みが
変わらなければ、小信号で測れている**。

**バイアス T だけ** (Q1 を外し、i10 と i11 を線でつないだ) の**見えるはずの画面**。
コイルには巻線の容量 (3 pF と仮定) が並列に付く。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-150M 150
title: 図3 バイアス T 2 つだけ — S21 は 0 dB (上端)、S11 は 100 MHz まで −20 dB 以下
dut:
  - series C 100n
  - shunt L 100u cp 3p
  - shunt L 100u cp 3p
  - series C 100n
traces:
  - S21 logmag 10dB
  - S11 logmag
markers:
  - 1M
  - 9.2M
  - 150M
notes:
  - text 60M -60dB: S21 は 0 dB で枠の上端に乗る
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/04-bias-tee-transistor-1.svg)

- 1 MHz では 2 つのコイル (並列で 50 µH、314 Ω) が信号を少し GND へ逃がす。
  150 MHz では巻線の容量 (2 つで 6 pF) が同じことをする。S11 は 1〜100 MHz で
  −20 dB 以下、150 MHz で −17 dB。S21 はどこでも 0.1 dB も落ちない (図3 の S21 が
  上端から動かないのは意図どおりで、動かないことを見る線) ので、
  **この範囲ならバイアス T は測定をほとんど邪魔しない** (S11 が −20 dB を超える
  100 MHz より上は、3-6 と同じく「治具の限界の手前」と見て読む)
- 9.2 MHz はコイルの自己共振 (100 µH と 3 pF)。ここではコイルの Z が一番高く、
  S11 は一番小さい

**トランジスタを挿した後の入力側** (S11)。ハイブリッド π のうち入力に効く部分
(r<sub>bb′</sub>・r<sub>π</sub>・C<sub>π</sub> と、C<sub>µ</sub> のミラー効果の 18 pF) を並べた**等価回路**の
見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-150M 150
title: 図4 ベースの入口の S11 — 周波数を上げると 50 Ω に近づく (等価回路)
dut:
  - series R 50
  - shunt R 1k2
  - shunt C 348p
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 5M
  - 30M
  - 100M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/04-bias-tee-transistor-2.svg)

- 5 MHz では C<sub>π</sub> と r<sub>π</sub> がまだ見えて 57 Ω − j91 Ω (S11 −3.8 dB)。100 MHz では
  C<sub>π</sub> がほぼ短絡し、r<sub>bb′</sub> の 50 Ω だけが残って S11 は −27 dB
- Smith では、**容量性の下半分を右から中心へ向かう弧**になる。中心に寄るのは
  整合を取ったからではなく、r<sub>bb′</sub> がたまたま 50 Ω に近いから
- S21 (増幅) の画面は、このフェンスの模型に利得の素子が無いので
  描けない。下の表に計算値を示す

## 見るべき値

計算値 (ハイブリッド π の模型、h<sub>FE</sub> 200・f<sub>T</sub> 80 MHz・C<sub>µ</sub> 2 pF・r<sub>bb′</sub> 50 Ω・r<sub>o</sub> 23 kΩ、
入出力とも 50 Ω で終端)。

| 周波数 | S11 | S21 | S12 (裏返して) | S22 (裏返して) |
| --- | --- | --- | --- | --- |
| 1 MHz | −0.87 dB | +23.5 dB | −58.9 dB | −0.07 dB |
| 5 MHz | −3.75 dB | +20.6 dB | −47.8 dB | −0.45 dB |
| 30 MHz | −16.5 dB | +7.95 dB | −44.9 dB | −0.89 dB |
| 100 MHz | −26.8 dB | −2.41 dB | −44.8 dB | −0.91 dB |

| バイアス T だけ | 1 MHz | 9.2 MHz | 150 MHz |
| --- | --- | --- | --- |
| S21 | −0.01 dB | 0.00 dB | −0.09 dB |
| S11 | −26.6 dB | −49.2 dB (自己共振) | −17.1 dB |

- **S21 は 1 けたごとに 20 dB 落ちる** (5 MHz → 30 MHz で 12.7 dB)。周波数と S21 の
  倍率の積がほぼ一定 (f<sub>T</sub> の考え方)。実物の f<sub>T</sub> が高ければ、表より上に出る
- S12 と S22 は、**ユニバーサル基板を裏返して** J2 を CH0、J1 を CH1 に挿し直して測る
  (NanoVNA は CH0 → CH1 の 1 方向だけ。8-2 と同じ)。S12 は C<sub>µ</sub> を通って
  逆向きに漏れる量、S22 はコレクタの高い Z (ほぼ全反射) を見る。**4 つそろうと
  8-5 で安定性 (K 因子) が計算できる**
- 測ったら Touchstone に保存して隣に置く。2 回 (表と裏) の `.s2p` を
  組み合わせると 4 つの S パラメータになる

## LTspice での確かめ

`sim/04-bias-tee-transistor.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。
理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1 MHz | S21 / S11 | −0.01 dB / −26.59 dB | −0.01 dB / −26.59 dB | 合う |
| 図3 | 9.2 MHz | S21 / S11 | 0.00 dB / −49.17 dB | 0.00 dB / −49.17 dB | 合う |
| 図3 | 150 MHz | S21 / S11 | −0.09 dB / −17.10 dB | −0.09 dB / −17.10 dB | 合う |
| 図4 | 5 MHz | S11 / Z | −3.75 dB / 56.9 Ω − j90.9 Ω | −3.75 dB / 56.9 Ω − j90.9 Ω | 合う |
| 図4 | 30 MHz | S11 / Z | −16.45 dB / 50.2 Ω − j15.2 Ω | −16.45 dB / 50.2 Ω − j15.2 Ω | 合う |
| 図4 | 100 MHz | S11 / Z | −26.81 dB / 50.0 Ω − j4.6 Ω | −26.81 dB / 50.0 Ω − j4.6 Ω | 合う |

6 点すべて図の読み値と合う。

図3・図4 の `dut:` は部分の等価回路で、トランジスタを含む S パラメータの表は `sim/04-bias-tee-transistor-hybrid-pi.cir` のハイブリッド π (C<sub>π</sub> = g<sub>m</sub> / (2π f<sub>T</sub>) − C<sub>µ</sub> = 327 pF、バイアス T は理想の結合) で確かめた。実測ではない。

| 周波数 | S11 (本文) | S11 (LTspice) | S21 (本文) | S21 (LTspice) | S12 (本文) | S12 (LTspice) | S22 (本文) | S22 (LTspice) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 MHz | −0.87 dB | −0.86 dB | +23.5 dB | +23.5 dB | −58.9 dB | −58.9 dB | −0.07 dB | −0.07 dB |
| 5 MHz | −3.75 dB | −3.70 dB | +20.6 dB | +20.6 dB | −47.8 dB | −47.8 dB | −0.45 dB | −0.45 dB |
| 30 MHz | −16.5 dB | −16.4 dB | +7.95 dB | +7.95 dB | −44.9 dB | −44.9 dB | −0.89 dB | −0.88 dB |
| 100 MHz | −26.8 dB | −26.7 dB | −2.41 dB | −2.41 dB | −44.8 dB | −44.8 dB | −0.91 dB | −0.91 dB |

S11 だけ 0.05〜0.1 dB 本文より小さく出る (本文の S11 は図4 の簡略の等価回路の値)。他は合う。バイアス T の RFC (100 µH) を実物の値で入れると、1 MHz の S22 が −0.28 dB、S21 が +23.4 dB に動く (5 MHz より上は変わらない)。

## 出典

自作。2SC1815 の f<sub>T</sub> (最小値)・C<sub>ob</sub>・r<sub>bb′</sub> はデータシートの値。
ハイブリッド π の模型は標準的な電子回路の教科書による。
