---
book: nanovna
chapter: 8
id: 8-2
title: 入力・出力の S11 / S22
tier: 50
source: 自作
board: PF
device: H4
---

# 8-2 入力・出力の S11 / S22

8-1 と同じアンプの**入力側の反射 (S11)** と**出力側の反射 (S22)** を測る。
**NanoVNA は S22・S12 を測らない** (CH0 → CH1 の 1 方向だけ)。S22 を測るには
**基板を裏返して**、出力を CH0 に挿し直して S11 として測る。

## この実験で確かめる式

トランジスタは 8-4 と同じハイブリッド π の**等価回路**で見る (Ic 4.3 mA:
g<sub>m</sub> 0.165 S、r<sub>π</sub> 1.2 kΩ、C<sub>π</sub> = g<sub>m</sub> / (2π f<sub>T</sub>) ≈ 330 pF (f<sub>T</sub> 80 MHz)、
C<sub>μ</sub> (C<sub>ob</sub>) 2 pF、r<sub>bb′</sub> 50 Ω)。Re は Ce (10 µF) で交流的に GND に落ちている。

**入力側**: ベースの内側には r<sub>π</sub> と、C<sub>π</sub> に C<sub>μ</sub> のミラー効果
(2 pF × (1 + g<sub>m</sub> × 42 Ω) ≈ 16 pF。42 Ω は Rc 270 Ω と出口の 50 Ω の並列) を足した
**約 346 pF** が並列に付く。その手前に r<sub>bb′</sub> (50 Ω)、さらにバイアス抵抗
(8.2 kΩ ∥ 3.9 kΩ = 2.64 kΩ) が並列に付く。

- 直流に近い所では 2.64 kΩ ∥ (50 Ω + 1.2 kΩ) ≈ **850 Ω** で、50 Ω よりずっと大きい
- ところが 346 pF のリアクタンスは 1 MHz で 460 Ω と、もう r<sub>π</sub> より小さい。
  周波数を上げると C<sub>π</sub> がベースの内側を短絡し、**r<sub>bb′</sub> の 50 Ω だけが残る**
  (2.64 kΩ と並列で 49 Ω)。だから入力の反射は**周波数とともに小さくなる** (8-4 の図4 と同じ)

**出力側**: コレクタから見ると Rc (270 Ω) に、C<sub>μ</sub> を通る帰還が並列に付く。
数 MHz より上ではベースの内側が C<sub>π</sub> でほぼ短絡されるので、コレクタの電圧が
C<sub>μ</sub> と C<sub>π</sub> で分けられてベースに戻り、g<sub>m</sub> で電流になる。これが
C<sub>π</sub> / (g<sub>m</sub> C<sub>μ</sub>) = 330 pF / (0.165 S × 2 pF) ≈ **1 kΩ** の抵抗に見え、270 Ω と
並列で約 **213 Ω**。そこに C<sub>μ</sub> (2 pF) も並列に付く (トランジスタ自身の出力抵抗は
数十 kΩ あって無視できる)。

50 Ω 系との不整合を Γ = (Z − 50)/(Z + 50) で見ると、入力側は低い周波数で大きく反射し、
上では 50 Ω に近づく。出力側は 213〜270 Ω 対 50 Ω で、どの周波数でもそこそこ反射する。

## 回路図

8-1 の図1 と同じ回路 (2SC1815 1 段増幅)。入力側は J1 (CH0) から見た
ベースの見かけのインピーダンス、出力側は J2 (裏返して CH0 に挿す) から見た
Rc の見かけのインピーダンスを測る。

```circuit
title: 図1 8-1 と同じ回路 (S11 は J1、S22 は裏返して J2 で測る)
parts:
  J1: sma c2 mirror CH0
  C1: capacitor c4 c6 0.1u
  R1: resistor a6 c6 8k2
  R2: resistor c6 e6 3k9
  BAT: battery a1 e1 5
  Q1: npn c8
  Rc: resistor a8 b8 270
  Re: resistor d8 f8 200
  Ce: capacitor d9 f9 10u
  C2: capacitor b8 b10 0.1u
  J2: sma b12 Load
  GJ1: ground d2
  GBAT: ground e1
  GR2: ground e6
  GRE: ground f8
  GCE: ground f9
  GJ2: ground c12
wires:
  - J1.1 -- c4
  - J1.2 -- d2
  - a1 -- a6 -- a8
  - c6 -- Q1.B
  - Q1.C |- b8
  - Q1.E |- d8
  - d8 -- d9
  - f8 -- f9
  - b10 -- b12 -- J2.1
  - J2.2 -- c12
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/02-input-output-return-loss.svg)

- 8-1 との違いは出力にアッテネータを挟まず、**測らない側の口を校正キットの
  Load (50 Ω) で終える**こと。ここでは反射だけを見るので CH1 は使わない。
  増幅された信号は Load が受けるので、CH1 に大きな信号が入る心配も無い。
  S22 を測るときは J2 を CH0 に、J1 を Load につなぎ替える
- C2 (出力結合コンデンサ、0.1 µF) は測る周波数 (1〜300 MHz) では
  リアクタンスが 1.6 Ω 以下と小さく、出力側の見え方 (Rc 270 Ω) はほとんど
  変えない。一方で**直流は止める**: コレクタには約 3.9 V の直流がかかって
  いるので、C2 を外すとその電圧が NanoVNA のポートにそのままかかる。
  **C2 は必ず入れる**

## 実体配線図

8-1 と同じ考え方の perfboard (アッテネータは付けない。直流カットの C2 は残す)。

```perfboard
board:
  size: 7x5cm
title: 図2 perfboard に組む (アンプ、アッテネータなし)
parts:
  J1: sma/female-edge i1 j0
  C1: capacitor i3 i5 100n
  R1: resistor g6 i6 8k2
  R2: resistor i8 l8 3k9
  BAT: battery g4 g1 5
  Q1: transistor j12 j11 j10
  Rc: resistor g11 i11 270
  Re: resistor k12 n12 200
  Ce: capacitor k14 n14 10u
  C2: capacitor i15 i17 100n
  J2: sma/female-edge i24 j25
wires:
  - i1 -- i3
  - i5 -- i6
  - i6 -- i8
  - i8 -- i10
  - i10 -- j10
  - g4 -- g6 red
  - g6 -- g11 red
  - i11 -- j11
  - i11 -- i15
  - i17 -- i24
  - j12 -- k12
  - k12 -- k14
  - n12 -- n14 black
  - g1 -- h1 black
  - h1 -- h0 black
  - j0 -- j2 black
  - j2 -- n2 black
  - n2 -- n8 black
  - l8 -- n8 black
  - n8 -- n12 black
  - j25 -- j19 black
  - j19 -- n19 black
  - n19 -- n14 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/perfboard/02-input-output-return-loss.svg)

- C2 (出力結合コンデンサ) は 8-1 と同じ所に残す。測る周波数では C2 の
  リアクタンスは小さく、J2 からはほぼコレクタ (Rc) がそのまま見える。
  C2 を外すとコレクタの約 3.9 V の直流が NanoVNA のポートにかかるので外さない

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S11 の Log Mag |

**入力側** (J1 = CH0、J2 は Load) の**見えるはずの画面**。上の等価回路を並べた模型
(バイアス抵抗 2.64 kΩ、r<sub>bb′</sub>、r<sub>π</sub>、346 pF)。

```vna
device: h4
sweep: 1M-300M 201
title: 図3 入力側の S11 — 周波数を上げると 50 Ω に近づく (等価回路)
dut:
  - shunt R 2k64
  - series R 50
  - shunt R 1k2
  - shunt C 346p
  - open
traces:
  - S11 logmag
  - S11 smith
markers:
  - 30M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/02-input-output-return-loss-1.svg)

**出力側** (基板を裏返して J2 を CH0 に挿し、J1 は Load) の**見えるはずの画面**。
Rc 270 Ω、帰還の 1 kΩ、C<sub>μ</sub> 2 pF の並列 (**30 MHz より上で合う等価回路**)。
掃引とマーカーは図3 と同じ。

```vna
device: h4
sweep: 1M-300M 201
title: 図4 出力側の Z (裏返して) — R は 211 Ω から 129 Ω へ、X は容量性
dut:
  - shunt R 270
  - shunt R 1k
  - shunt C 2p
  - open
traces:
  - S11 r
  - S11 x
  - S11 smith
markers:
  - 30M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/02-input-output-return-loss-2.svg)

- 入力側は 1 MHz で −1.2 dB (大きく反射) だが、10 MHz で −8 dB、100 MHz で −27 dB と
  下がっていく。Smith では容量性の下半分を右から中心へ寄る弧になる。
  中心に寄るのは整合したからではなく、r<sub>bb′</sub> がたまたま 50 Ω に近いから
- 出力側は 30 MHz より上で S11 −4.1 dB 前後とほぼ平ら。S11 の Log Mag では枠の上端近くに
  張り付いて変化が読めないので、図4 は R と X (Ω) で描いた。R は 30 MHz の 211 Ω から
  ゆっくり下がり、300 MHz では C<sub>μ</sub> の容量で 129 − j104 Ω と容量性に寄る
- 図4 の等価回路は、帰還の 1 kΩ がまだ効ききらない 10 MHz より下では合わない
  (1 MHz では完全な模型で 267 Ω、S11 −3.3 dB。下の表)

## 見るべき値

計算値 (ハイブリッド π の模型。出口・入口の反対側は 50 Ω で終端)。30・100・300 MHz の
入力の S11 と Z は図3、出力の Z は図4 のマーカーの読み値 (出力の S11 はその Z から計算)、1・10 MHz は完全な模型 (帰還の g<sub>m</sub> まで含む) の値。

| 周波数 | S11 (入力、J1) | 入力の Z | S11 (出力、裏返して J2) | 出力の Z |
| --- | --- | --- | --- | --- |
| 1 MHz | −1.19 dB | 237 − j339 Ω | −3.29 dB | 267 − j14 Ω |
| 10 MHz | −7.98 dB | 52 − j44 Ω | −3.96 dB | 220 − j26 Ω |
| 30 MHz | −16.65 dB | 49.3 − j14.8 Ω | −4.16 dB | 211 − j17 Ω |
| 100 MHz | −26.82 dB | 49.1 − j4.4 Ω | −4.15 dB | 198 − j53 Ω |
| 300 MHz | −35.09 dB | 49.1 − j1.5 Ω | −4.01 dB | 129 − j104 Ω |

- 入力の反射が上で小さくなるのは、C<sub>π</sub> (f<sub>T</sub> から決まる) がベースの内側を
  短絡するから。**f<sub>T</sub> が大きい実物 (データシートの 80 MHz は最小値) では C<sub>π</sub> が
  小さく、反射の減り方は表より高い周波数へずれる**
- **入力は低い周波数で、出力はどの周波数でも 50 Ω に整合していない** (ミスマッチ)。これは 1 段の
  共通エミッタ増幅回路の典型で、8-15・8-16 の整合回路でこれを 50 Ω に近づける
- NanoVNA で S22 を直接読むメニューは無い。**基板を物理的に裏返して S11 として
  測り直す**のが唯一の方法 (3-1 のようなリバーシブルな治具だとやりやすい)

## 出典

自作。2SC1815 の f<sub>T</sub> (最小値)・C<sub>ob</sub> はデータシートの値。ハイブリッド π の模型は
8-4 と同じ (標準的な電子回路の教科書による)。
