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

**入力側**: ベースの見かけの抵抗は hFE × re′ (hFE ≈ 200、re′ ≈ 25.4 Ω、8-1 参照)
とバイアス抵抗 (27 kΩ・4.7 kΩ) の並列。計算値 ≈ **2.2 kΩ** (トランジスタの
Cib ≈ 25 pF も並列に付く)。

**出力側**: コレクタから見た抵抗は Rc (270 Ω) が支配的 (トランジスタ自身の
出力抵抗は数十 kΩ あって無視できる)。**Rc = 270 Ω**、トランジスタの
Cob ≈ 2 pF が並列に付く。

50 Ω 系との不整合を Γ = (Z − 50)/(Z + 50) で見ると、入力側はほぼ全反射
(2.2 kΩ ≫ 50 Ω)、出力側は 270 Ω 対 50 Ω でそこそこの反射になる。

## 回路図

8-1 の図1 と同じ回路 (2SC1815 1 段増幅)。入力側は J1 (CH0) から見た
ベースの見かけのインピーダンス、出力側は J2 (裏返して CH0 に挿す) から見た
Rc の見かけのインピーダンスを測る。

```circuit
title: 図1 8-1 と同じ回路 (S11 は J1、S22 は J2 を裏返して測る)
parts:
  J1: sma c2 mirror CH0
  C1: capacitor c4 c6 0.1u
  R1: resistor a6 c6 27k
  R2: resistor c6 e6 4k7
  BAT: battery a1 e1 9
  Q1: npn c8
  Rc: resistor a8 b8 270
  Re: resistor d8 f8 620
  Ce: capacitor d9 f9 10u
  C2: capacitor b8 b10 0.1u
  J2: sma b12 CH1
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

- 8-1 との違いは出力にアッテネータを挟んでいないこと。ここでは電力を送り込む
  測定ではなく**反射だけ**を見るので、アンプの利得が悪さをしない
  (CH1 からの信号レベルは低く保ったまま、S11 だけを読む)
- C2 (出力結合コンデンサ、0.1 µF) は測る周波数 (1〜300 MHz) では
  リアクタンスが 1.6 Ω 以下と小さく、出力側の見え方 (Rc 270 Ω) はほとんど
  変えない。一方で**直流は止める**: コレクタには約 8 V の直流がかかって
  いるので、C2 を外すとその電圧が NanoVNA のポートにそのままかかる。
  **C2 は必ず入れる**

## 実体配線図

8-1 と同じ考え方の perfboard (アッテネータは付けない。直流カットの C2 は残す)。

```perfboard
board:
  size: 20x9
title: 図2 perfboard に組む (アンプ、アッテネータなし)
parts:
  J1: sma/female-edge e1 f0
  C1: capacitor e3 e5 100n
  R1: resistor c6 e6 27k
  R2: resistor e8 h8 4k7
  BAT: battery c2 h2 9
  Q1: transistor f12 f11 f10
  Rc: resistor c11 e11 270
  Re: resistor g12 i12 620
  Ce: capacitor g13 h13 10u
  C2: capacitor e15 e17 100n
  J2: sma/female-edge e20 f21
wires:
  - e1 -- e3
  - e5 -- e6
  - e6 -- e8
  - e8 -- e10
  - e10 -- f10
  - c6 -- c2
  - c11 -- c2
  - e11 -- f11
  - e11 -- e15
  - e17 -- e20
  - f12 -- g12
  - g12 -- g13
  - i12 -- h12
  - h13 -- h12
  - f0 -- f2 black
  - f2 -- h2 black
  - h2 -- h8 black
  - h8 -- h12 black
  - f21 -- f19 black
  - f19 -- h19 black
  - h19 -- h12 black
```

- C2 (出力結合コンデンサ) は 8-1 と同じ所に残す。測る周波数では C2 の
  リアクタンスは小さく、J2 からはほぼコレクタ (Rc) がそのまま見える。
  C2 を外すとコレクタの約 8 V の直流が NanoVNA のポートにかかるので外さない

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 201 |
| 校正 | SOLT |
| 表示 | S11 の Log Mag |

**入力側** (J1 = CH0) の**見えるはずの画面**。

```vna
device: h4
sweep: 1M-300M 201
title: 図3 入力側の S11 (ベースの見かけの Z)
dut:
  - shunt R 2.2k
  - shunt C 25p
  - open
traces:
  - S11 logmag
markers:
  - 1M
  - 100M
  - 300M
```

**出力側** (基板を裏返して J2 を CH0 に挿す) の**見えるはずの画面**。

```vna
device: h4
sweep: 1M-300M 201
title: 図4 出力側の S11 (Rc の見かけの Z、基板を裏返して測る)
dut:
  - shunt R 270
  - shunt C 2p
  - open
traces:
  - S11 logmag
markers:
  - 1M
  - 100M
  - 300M
```

- 入力側は 1 MHz でほぼ 0 dB (ほぼ全反射)。2.2 kΩ が 50 Ω よりずっと大きいため
- 出力側は 1 MHz で −3.25 dB とそこそこ反射する (270 Ω と 50 Ω の中間的な不整合)
- どちらも周波数を上げると Cib・Cob の容量で見かけの Z が下がり、反射がやや減る

## 見るべき値

計算値。

| 周波数 | S11 (入力、J1) | S11 (出力、裏返して J2) |
| --- | --- | --- |
| 1 MHz | −0.39 dB | −3.25 dB |
| 100 MHz | −0.24 dB | −3.24 dB |
| 300 MHz | −0.06 dB | −3.14 dB |

- **入力・出力とも 50 Ω に整合していない** (ミスマッチ)。これは 1 段の
  共通エミッタ増幅回路の典型で、8-15・8-16 の整合回路でこれを 50 Ω に近づける
- NanoVNA で S22 を直接読むメニューは無い。**基板を物理的に裏返して S11 として
  測り直す**のが唯一の方法 (3-1 のようなリバーシブルな治具だとやりやすい)

## 出典

自作。
