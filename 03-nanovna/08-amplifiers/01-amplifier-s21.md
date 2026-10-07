---
book: nanovna
chapter: 8
id: 8-1
title: アンプの S21 (利得 vs 周波数)
tier: 50
source: 自作
board: PF
device: H4
---

# 8-1 アンプの S21 (利得 vs 周波数)

小信号アンプ (2SC1815 の 1 段増幅) の利得を S21 で測る。**アンプは電力を生む
(受動素子ではない) ので、この本のフェンスの `dut:` (R・L・C・
伝送線路の縦続だけ) では利得のある画面を描けない。** ここでは描ける範囲
(アッテネータだけの基準画面) を示し、利得を足した実際の読みは計算で示す。

**CH1 の最大入力に注意**: 0-3 で扱ったとおり、NanoVNA の CH1 に入れてよい電力には
上限があり、超えると壊れる。アンプの出力をそのまま CH1 に入れると、利得の分だけ
NanoVNA 自身の出力レベルより高くなって上限に届くおそれがある。**アンプの出力と
CH1 の間に必ずアッテネータを挟む** (ここでは 3-5 と同じ考え方の 10 dB パッドを使う)。

## この実験で確かめる式

**Av = (Rc ∥ R_L) / re′**、**re′ = 26 mV / Ic** (共通エミッタ、エミッタを大きな
コンデンサでバイパスした場合の中域利得)。R_L はコレクタの先につながる負荷で、
ここでは 50 Ω 系 (出力のアッテネータの入口、50.3 Ω)。**Rc だけでなく
50 Ω の負荷と並列になった値で利得が決まる**。

バイアス: Vcc = 5 V、R1 = 8.2 kΩ、R2 = 3.9 kΩ、Re = 200 Ω、Rc = 270 Ω
(h<sub>FE</sub> = 200 として計算)。

Vb ≈ 1.56 V (分圧の 1.61 V からベース電流の分だけ下がる)、Ve = Vb − 0.7 = 0.86 V、
Ic ≈ Ve / Re = 4.3 mA、re′ = 26 mV / 4.3 mA ≈ 6.1 Ω。
コレクタの直流は Vc = 5 − 4.3 mA × 270 Ω ≈ 3.85 V (Vce ≈ 3.0 V)。

Rc ∥ R_L = 270 ∥ 50.3 ≈ 42.4 Ω なので、**Av = 42.4 / 6.1 ≈ 7.0 倍 ≈ 16.9 dB**
(ベース → コレクタの電圧利得、計算値、中域)。

S21 はこれより大きく出る。アンプの入力の Z (R1 ∥ R2 ∥ h<sub>FE</sub>re′ ≈ 830 Ω) が
50 Ω よりずっと高いので、ベースには入ってくる波のほぼ 2 倍
(2 × 830 / (830 + 50) = 1.89 倍、+5.5 dB) の電圧がかかる。
**低い周波数の S21 の目安 ≈ 16.9 + 5.5 ≈ 22.4 dB**。

**周波数を上げると利得は落ちる**。8-2・8-4 と同じハイブリッド π の**等価回路**
(g<sub>m</sub> = Ic / 26 mV = 0.165 S、r<sub>π</sub> 1.2 kΩ、C<sub>π</sub> = g<sub>m</sub> / (2π f<sub>T</sub>) ≈ 330 pF
(f<sub>T</sub> 80 MHz)、C<sub>μ</sub> 2 pF、r<sub>bb′</sub> 50 Ω、r<sub>o</sub> 23 kΩ) で計算すると、
C<sub>π</sub> (とミラー効果で C<sub>μ</sub> が増えた分) がベースを交流的に短絡していき、
**S21 は低い所の 22.0 dB から 5 MHz で 3 dB 落ち、30 MHz では 6.4 dB** になる (計算値)。
低い所の 22.0 dB が上の目安より 0.4 dB 小さいのは、r<sub>bb′</sub> と r<sub>o</sub> のぶん。
f<sub>T</sub> 80 MHz はデータシートの最小値なので、実物はもっと高い周波数まで伸びることが多い
(f<sub>T</sub> 200 MHz なら 3 dB 落ちるのは 12 MHz、30 MHz で 13.3 dB)。

**出力の振れの上限**: コレクタの電流は 0 より下がれないので、頭打ちせずに振れるのは
Ic × (Rc ∥ R_L) = 4.3 mA × 42.4 Ω ≈ **0.18 V (片側の振幅)**。50 Ω に出せる電力は
**約 −5 dBm** が上限で、アッテネータ (10 dB) の先の CH1 では **約 −15 dBm**。
0-3 の目安 (CH1 に 0 dBm を大きく超える信号を入れない) より十分小さい。
入力で言うと、ベースで 26 mV (CH0 から入る波で約 −27 dBm) を超えると頭打ちが始まる。
CH0 の出力がこれより大きいと利得が小さく読めるので、そのときは入力側にも
アッテネータ (20 dB など) を足し、校正に含める。

## 回路図

```circuit
title: 図1 2SC1815 1 段増幅 + 出力アッテネータ
parts:
  J1: sma 2,3 mirror CH0
  C1: capacitor 4,3 6,3 0.1u
  R1: resistor 6,1 6,3 8k2
  R2: resistor 6,3 6,5 3k9
  BAT: battery 1,1 1,5 5
  Q1: npn 8,3
  Rc: resistor 8,1 8,2 270
  Re: resistor 8,4 8,6 200
  Ce: capacitor 9,4 9,6 10u
  C2: capacitor 8,2 10,2 0.1u
  PR1: resistor 10,2 10,5 100
  PR2: resistor 10,2 12,2 68
  PR3: resistor 12,2 12,5 100
  J2: sma 14,2 CH1
  GJ1: ground 2,4
  GBAT: ground 1,5
  GR2: ground 6,5
  GRE: ground 8,6
  GCE: ground 9,6
  GPR1: ground 10,5
  GPR3: ground 12,5
  GJ2: ground 14,3
wires:
  - J1.1 -- 4,3
  - J1.2 -- 2,4
  - 1,1 -- 6,1 -- 8,1
  - 6,3 -- Q1.B
  - Q1.C |- 8,2
  - Q1.E |- 8,4
  - 8,4 -- 9,4
  - 8,6 -- 9,6
  - 12,2 -- 14,2 -- J2.1
  - J2.2 -- 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/01-amplifier-s21.svg)

- Q1 のコレクタ抵抗 Rc (270 Ω) と先の 50 Ω が並列で利得を決める。エミッタの Re (200 Ω) は
  Ce (10 µF) でバイパスして交流的には短絡し、直流の動作点だけを安定させる
- 出力の PR1・PR2・PR3 が 10 dB (計算値 9.6 dB) の π 型アッテネータ
  (100 Ω・68 Ω・100 Ω、8-3 と同じ設計)。ここを通してから CH1 へ

## 実体配線図

```perfboard
board:
  size: 27x9
  slots: on
title: 図2 perfboard に組む (アンプ + アッテネータ)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 e5 100n
  R1: resistor c6 e6 8k2
  R2: resistor e8 h8 3k9
  BAT: battery c4 c1 5
  Q1: transistor f12 f11 f10
  Rc: resistor c11 e11 270
  Re: resistor g12 i12 200
  Ce: capacitor g13 h13 10u
  C2: capacitor e15 e17 100n
  PR1: resistor e19 h19 100
  PR2: resistor e20 e22 68
  PR3: resistor e23 h23 100
  J2: sma/female-edge e26 f27
wires:
  - e1 -- e3
  - e5 -- e6
  - e6 -- e8
  - e8 -- e10
  - e10 -- f10
  - c4 -- c6 red
  - c6 -- c11 red
  - e11 -- f11
  - e11 -- e15
  - f12 -- g12
  - g12 -- g13
  - i12 -- h12
  - h13 -- h12
  - e17 -- e19
  - e19 -- e20
  - e22 -- e23
  - e23 -- e25
  - e25 -- e26
  - c1 -- d1 black
  - d1 -- d0 black
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h8 black
  - h8 -- h12 black
  - h12 -- h19 black
  - h19 -- h23 black
  - f27 -- f25 black
  - f25 -- h25 black
  - h25 -- h23 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/01-amplifier-s21.svg)

- Q1 は変換基板に載せた TO-92 (`transistor` は 3 ピン)。ピンの並びは 2SC1815 の
  実物 (1 = E、2 = C、3 = B) に合わせて配線する
- Vcc は 5 V (USB の 5 V か、単 3 電池 3 本の 4.5 V)。4.5 V なら Ic ≈ 3.5 mA で、
  S21 は 1 MHz で 1.6 dB ほど小さくなる (計算値。30 MHz ではほとんど変わらない)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz (利得が平らな所から、f<sub>T</sub> で落ちていく所まで) |
| 点数 | 61 |
| 校正 | SOLT (アッテネータの手前で) |
| 表示 | S21 の Log Mag |

**アンプを挟む前に、出力アッテネータ単体の S21 を確かめる**画面
(利得は描けないので、この基準を先に見る)。

```vna
device: h4
sweep: 1M-30M 61
title: 図3 出力アッテネータ単体の S21 (アンプを挟む前の基準)
dut:
  - shunt R 100
  - series R 68
  - shunt R 100
traces:
  - S21 logmag
markers:
  - 1M
  - 5M
  - 10M
  - 30M
notes:
  - text 3M -30dB: 基準 −9.63 dB。アンプを挟むと 1 MHz で +12.3 dB (計算)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/01-amplifier-s21.svg)

- アッテネータだけなら周波数によらず一定 (−9.63 dB、計算値)。**この基準を
  確かめてから**アンプをアッテネータの前に足す
- マーカーは下の表の 4 つの周波数。アンプを足した後も同じマーカーで読む
- アンプを足すと、実際の CH1 の読みは「アンプの利得 − アッテネータの減衰」に
  なるはずだが、**利得のある画面はこのフェンスでは描けない** (見るべき値の
  表に計算値を示す)

## 見るべき値

計算値 (ハイブリッド π の等価回路、f<sub>T</sub> 80 MHz。CH1 の側はアッテネータ + 50 Ω)。

| 周波数 | アッテネータ単体 | アンプ単体の S21 | アンプ + アッテネータ (CH1 の読み) |
| --- | --- | --- | --- |
| 1 MHz | −9.63 dB | +21.9 dB | **+12.3 dB** |
| 5 MHz | −9.63 dB | +19.1 dB | +9.4 dB |
| 10 MHz | −9.63 dB | +15.1 dB | +5.5 dB |
| 30 MHz | −9.63 dB | +6.4 dB | −3.2 dB |

| 項目 | 値 | 分かること |
| --- | --- | --- |
| 低い周波数の S21 の目安 | +22.4 dB | (Rc ∥ 50 Ω) / re′ の 16.9 dB と、入力の Z が高いぶんの +5.5 dB |
| 3 dB 落ちる周波数 | 約 5 MHz | C<sub>π</sub> がベースを短絡し始める所 (f<sub>T</sub> 80 MHz の場合) |
| CH1 に届く電力の上限 | 約 −15 dBm | 出力が頭打ちする所 (−5 dBm) からアッテネータの 10 dB を引いた値 |

- +12.3 dB は NanoVNA の出力レベルより信号が**強く**なって CH1 に入ることを
  意味する。この 5 V の 1 段アンプは頭打ちで −5 dBm ほどしか出せないが、
  もっと大きいアンプでも同じ手順で測れるように、**測定中はアッテネータを外さない**
- 利得は数 MHz から落ち始め、30 MHz ではアッテネータの 10 dB に負けて S21 が 0 dB を割る
  (この模型で)。**実物の f<sub>T</sub> が高ければ、落ち始めは表より高い周波数へずれる**。
  測った 3 dB の周波数から f<sub>T</sub> の見当が付く
- もっと上の周波数 (8-9 の GHz LNA モジュールなど) では、f<sub>T</sub> の高い別の部品が要る

## 出典

自作。2SC1815 の f<sub>T</sub> (最小値 80 MHz)・C<sub>ob</sub> はデータシートの値。ハイブリッド π の模型は
8-4 と同じ (標準的な電子回路の教科書による)。
