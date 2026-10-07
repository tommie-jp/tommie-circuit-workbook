---
book: nanovna
chapter: 7
id: 7-9
title: トラップ
tier: 100
source: 自作
board: PF
device: H4
---

# 7-9 トラップ

1 本のダイポールを 2 つのバンドで使うための**トラップ** (エレメントの途中に入れる
並列 LC) を作って測る。トラップは自分の共振周波数では**ほぼ開放**になってエレメントを
そこで切り離し、それより低い周波数では**コイル**として働いてエレメントを電気的に
延ばす。ここでは 7 MHz に共振するトラップを作り、3.5 MHz と 7 MHz の 2 バンドの
ダイポール (W3DZZ 型) の要の部品として確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| **f<sub>0</sub> = 1 / (2π√(LC))** | トラップの共振周波数。L 10 µH・C 50.3 pF で 7.10 MHz |
| **X = ωL / (1 − (f / f<sub>0</sub>)²)** | 損失を無視したトラップのリアクタンス。f < f<sub>0</sub> で正 (誘導性)、f > f<sub>0</sub> で負 (容量性) |
| **R<sub>p</sub> = Q × ωL** | 共振点のインピーダンス (純抵抗)。コイルの Q が 50 なら 7.1 MHz で 22.3 kΩ |
| **S21 = 2Z<sub>0</sub> / (2Z<sub>0</sub> + Z)** | 3-1 の直列治具で CH0 と CH1 の間に Z を入れたときの通過 |

**2 バンドの働き**:

- 7 MHz では、トラップが開放になり、給電点からトラップまでの内側だけが半波長のダイポールとして働く
- 3.5 MHz では、トラップが +j290 Ω (13.2 µH 相当) のコイルになり、外側のエレメントと合わせて
  3.5 MHz の半波長になる (コイルの分だけエレメントは短くて済む)

## 回路図

3-1 の直列治具の形で、CH0 と CH1 の間にトラップを入れる。C は 47 pF と 3.3 pF の並列
(50.3 pF。7.1 MHz に要る 50.2 pF が E12 に無いため)。

```circuit
title: 図1 トラップ (L と C の並列) を直列治具で測る
parts:
  J1: sma 2,2 mirror CH0
  L1: inductor 4,2 8,2 10u
  C1: capacitor 4,3 8,3 47p
  C2: capacitor 4,4 8,4 3.3p
  J2: sma 10,2 CH1
  G1: ground 2,3
  G2: ground 10,3
wires:
  - J1.1 -- 4,2
  - 4,2 -- 4,3 -- 4,4
  - 8,2 -- 8,3 -- 8,4
  - 8,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 10,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/circuit/09-trap.svg)

- L1 は軸物の 10 µH (7 MHz で Q 50 前後のもの)。Q は計算で**仮定**した値で、
  実物の Q は共振の谷の深さから逆算できる (見るべき値)
- 測るだけならこの小さな部品でよい。**送信に使うトラップ**は電圧が高くなるので、
  耐圧の高いコンデンサと太い線の空芯コイルで作り直す (測り方は同じ)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard に組む (部品面)
parts:
  J1: sma/female-edge a10 09
  J2: sma/female-edge x10 y9
  L1: inductor e10 k10 10u
  C1: capacitor e8 k8 47p
  C2: capacitor e6 k6 3.3p
wires:
  - a10 -- e10
  - k10 -- x10
  - e10 -- e8
  - e8 -- e6
  - k10 -- k8
  - k8 -- k6
  - 09 -- b9 black
  - b9 -- b5 black
  - b5 -- o5 black
  - o5 -- o9 black
  - o9 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/perfboard/09-trap.svg)

- L1・C1・C2 の 3 つを 5 列と 11 列の縦の線で並列にする
- J1 と J2 の外皮は n 行の GND の線でつなぐ (トラップの外側を回す)

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 2 MHz〜12 MHz (3.5 MHz と 7 MHz の両方が入る) |
| 点数 | 201 |
| 校正 | SOLT (CH0・CH1 の両方。Thru を含む) |
| 表示 | S21 の Log Mag、S11 の X (CH1 の 50 Ω は純抵抗なので、X はトラップの X) |

```vna
device: h4
sweep: 2M-12M 201
title: 図3 7.1 MHz で S21 が −47 dB の谷、X の符号が + から − へ
dut:
  - series L 10u esr 8.9 cp 50.3p
traces:
  - S21 logmag
  - S11 x
markers:
  - 3.5M
  - 7.1M
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/07-antennas/vna/09-trap.svg)

- S21 は 7.1 MHz で深い谷 (−47 dB)。**谷の周波数がトラップの共振**
- S11 の X は 3.5 MHz で +290 Ω (コイル)、7.1 MHz を境に符号が反転し、10 MHz で −637 Ω (コンデンサ)

## 見るべき値

計算値 (L 10 µH・C 50.3 pF・コイルの Q 50 を仮定。損失の抵抗 8.9 Ω を L に直列)。

| 周波数 | トラップの Z | S21 | 働き |
| --- | --- | --- | --- |
| 3.5 MHz | 15.5 + j290 Ω | −9.9 dB | 13.2 µH のコイル (エレメントを延ばす) |
| 7.1 MHz | 22.3 k − j1.6 k Ω | −47.0 dB | ほぼ開放 (外側を切り離す) |
| 10 MHz | 9.2 − j637 Ω | −16.2 dB | コンデンサ |

- **共振の周波数は谷の底で読む**。7.0〜7.2 MHz のアマチュア無線のバンドの中にあれば合格。
  ずれていたら C2 を替えて合わせる (C2 を 2.2 pF にすると約 7.18 MHz)
- 谷の深さから R<sub>p</sub> = 100 Ω × (1 / \|S21\| − 1) で共振点の抵抗を出し、Q = R<sub>p</sub> / ωL で
  コイルの Q を逆算できる (−47 dB なら R<sub>p</sub> ≈ 22 kΩ、Q ≈ 50)
- 3.5 MHz でトラップがどれだけのコイルに見えるか (13.2 µH) で、外側のエレメントの長さが決まる。
  7.1 MHz 用に切った内側に、このコイルとで 3.5 MHz に合う長さの外側を足す

## 出典

自作。2 バンドのトラップ・ダイポール (W3DZZ 型) の考え方はアマチュア無線のアンテナの
解説書に広く載っている。値はこの題で選んだもの。
