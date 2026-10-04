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
| C<sub>μ</sub> | データシートの C<sub>ob</sub> | 2 pF |
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
title: 図1 バイアス T 2 つで 2SC1815 に直流を与える
parts:
  BAT: battery a1 g1 5 l=$\mathrm{BAT}$
  Cd: capacitor a2 c2 10u
  J1: sma e3 mirror CH0
  C1: capacitor e4 e5 0.1u
  RB: resistor a6 c6 200k
  L1: inductor c6 e6 100u
  Q1: npn e8
  Rs: resistor a10 b10 100
  L2: inductor b10 d10 100u
  C2: capacitor d11 d12 0.1u
  J2: sma d14 CH1
  GBAT: ground g1
  GCd: ground c2
  GJ1: ground f3
  GQ1: ground g8
  GJ2: ground e14
wires:
  - a1 -- a2 -- a6 -- a10
  - J1.1 -- e4
  - J1.2 -- f3
  - e5 -- e6 -- Q1.B
  - Q1.E |- g8
  - Q1.C |- d10
  - d10 -- d11
  - d12 -- d14 -- J2.1
  - J2.2 -- e14
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/04-bias-tee-transistor.svg)

- C1・L1 が入力側のバイアス T、C2・L2 が出力側のバイアス T。コンデンサ (0.1 µF) は
  直流を止めて交流を通し、コイル (100 µH) は直流を通して交流を止める
- **エミッタは GND に直結** (8-1 の Re・Ce が無い)。測りたいのはトランジスタだけ
  だから。そのぶん動作点は RB だけで決まり、h<sub>FE</sub> のばらつきがそのまま Ic に出る
- Cd (10 µF) は 5 V の線を交流的に GND へ落とす。RB と Rs の上の端は交流では GND

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard に組む (バイアス T 2 つ + 2SC1815)
parts:
  J1: sma/female-edge i1 j0
  BAT: battery c4 c1 5
  Cd: capacitor d5 e5 10u
  C1: capacitor i3 i5 100n
  RB: resistor c7 f7 200k
  L1: inductor f8 i8 100u
  Q1: transistor j12 j11 j10
  Rs: resistor c14 f14 100
  L2: inductor f13 i13 100u
  C2: capacitor i15 i17 100n
  J2: sma/female-edge i24 j25
wires:
  - c4 -- c5 red
  - c5 -- c7 red
  - c7 -- c14 red
  - d5 -- c5 red
  - c1 -- e1 black
  - e1 -- h1 black
  - h1 -- h0 black
  - e5 -- e1 black
  - i1 -- i3
  - i5 -- i8
  - i8 -- i10
  - i10 -- j10
  - f7 -- f8
  - i11 -- j11
  - i11 -- i13
  - f13 -- f14
  - i13 -- i15
  - i17 -- i24
  - j0 -- j2 black
  - j2 -- m2 black
  - m2 -- m12 black
  - m12 -- m21 black
  - j12 -- m12 black
  - j25 -- j21 black
  - j21 -- m21 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/04-bias-tee-transistor.svg)

- Q1 は 8-1 と同じく変換基板に載せた TO-92。足は実物 (1 = E、2 = C、3 = B) に
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
device: h4
sweep: 1M-150M 150
title: 図3 バイアス T 2 つだけ — S21 は 0 dB (上端)、S11 は 100 MHz まで −20 dB 以下
dut:
  - series C 100n
  - shunt L 100u cp 3p
  - shunt L 100u cp 3p
  - series C 100n
traces:
  - S21 logmag
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
(r<sub>bb′</sub>・r<sub>π</sub>・C<sub>π</sub> と、C<sub>μ</sub> のミラー効果の 18 pF) を並べた**等価回路**の
見えるはずの画面。

```vna
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

計算値 (ハイブリッド π の模型、h<sub>FE</sub> 200・f<sub>T</sub> 80 MHz・C<sub>μ</sub> 2 pF・r<sub>bb′</sub> 50 Ω・r<sub>o</sub> 23 kΩ、
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
- S12 と S22 は、**板を裏返して** J2 を CH0、J1 を CH1 に挿し直して測る
  (NanoVNA は CH0 → CH1 の 1 方向だけ。8-2 と同じ)。S12 は C<sub>μ</sub> を通って
  逆向きに漏れる量、S22 はコレクタの高い Z (ほぼ全反射) を見る。**4 つそろうと
  8-5 で安定性 (K 因子) が計算できる**
- 測ったら Touchstone に保存して隣に置く。2 回 (表と裏) の `.s2p` を
  組み合わせると 4 つの S パラメータになる

## 出典

自作。2SC1815 の f<sub>T</sub> (最小値)・C<sub>ob</sub>・r<sub>bb′</sub> はデータシートの値。
ハイブリッド π の模型は標準的な電子回路の教科書による。
