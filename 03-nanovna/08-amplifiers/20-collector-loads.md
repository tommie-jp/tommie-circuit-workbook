---
book: nanovna
chapter: 8
id: 8-20
title: コレクタ負荷を差し替える — 抵抗・チョーク・LC 同調・広帯域トランスで S21 の利得と帯域を比べる (1.9 MHz 帯)
tier: 100
source: 自作
board: BB
device: LV64
---

# 8-20 コレクタ負荷を差し替える — 抵抗・チョーク・LC 同調・広帯域トランスで S21 の利得と帯域を比べる (1.9 MHz 帯)

8-1 のエミッタ接地の段 (2SC1815、Ic ≈ 4.3 mA) をそのまま使い、**コレクタの負荷だけを 4 通りに差し替えて** S21 を比べる。
無線の自作で出てくるコレクタ負荷は、ほぼこの 4 つに収まる: **抵抗**、**RF チョーク (RFC)**、**LC 同調回路**、**広帯域トランス**。
どれを選ぶかで利得・帯域・出力の上限が決まる。

- 出力は 50 Ω (オーム) の VNA に直結する。**抵抗とチョークでは、コレクタから見た負荷がどちらもほぼ 50 Ω** になり、利得は 22〜23 dB で変わらない。違いは直流の電圧降下 (振幅の上限) と帯域の下限
- **利得を上げるにはコレクタから見た抵抗を上げるしかない。それがトランスと同調回路の役目** — 巻数比の 2 乗で 50 Ω を高い抵抗に見せる (インピーダンス変換)。同調回路は帯域を狭めた分だけ利得が高い
- 周波数は 1.9 MHz 帯 (1.8〜1.9 MHz、160 m バンド)。3 MHz 以下なのでブレッドボードに組める

> **この題の図は理想の模型 (8-1 と同じハイブリッド π (パイ) の等価回路) から計算した値で、実機では測っていない。** トロイダルコアの A<sub>L</sub> は ±25 % ばらつくので、同調回路は組む前に図7 の方法で f<sub>0</sub> を測って合わせる。

## この実験で確かめる式

共通の段は 8-1 と同じ: Vcc = 5 V、R1 = 8.2 kΩ、R2 = 3.9 kΩ、Re = 200 Ω、Ic ≈ 4.3 mA、
**re′ = 26 mV / Ic ≈ 6.05 Ω**。ベースの入口 (R1 ∥ R2 ∥ h<sub>FE</sub>re′ ≈ 830 Ω) は 50 Ω よりずっと高いので、
CH0 から来る波のほぼ 2 倍 (1.89 倍、+5.5 dB) がベースにかかる。

コレクタから見た交流の負荷を R<sub>L</sub>′ とすると、**コレクタの電圧利得 Av = R<sub>L</sub>′ / re′**。トランスや同調回路の
2 次 (50 Ω 側) に出る電圧は巻数比 n で割った Av / n。だから **S21 の目安 = 20 log (1.89 × Av / n)**。

| 負荷 | コレクタから見た R<sub>L</sub>′ | Av | n | S21 の目安 | 直流の電圧降下 | 帯域 (計算) |
| --- | --- | --- | --- | --- | --- | --- |
| A 抵抗 Rc 270 Ω | 270 ∥ 50 = 42 Ω | 7.0 | 1 | 22.4 dB | 1.2 V (Rc × Ic) | 広い。上は f<sub>T</sub> で落ちる (8-1) |
| B チョーク RFC 100 µH | 1.2 kΩ ∥ 50 = 48 Ω (1.9 MHz で X<sub>L</sub> = 1.2 kΩ) | 7.9 | 1 | 23.5 dB | 0 V | 下は X<sub>L</sub> = 50 Ω になる 80 kHz から。上は f<sub>T</sub> と自己共振 (約 9 MHz) |
| C LC 同調 (FT37-61 に 14 回 + 680 pF、リンク 3 回) | 50 × 4.67² = 1.09 kΩ、コイルの損失 12.9 kΩ と r<sub>o</sub> 23 kΩ が並列で **963 Ω** | 159 | 4.67 | 36.2 dB | 0 V | 狭い。Q<sub>L</sub> = 963 / 126 = 7.6 → 3 dB 幅 約 250 kHz |
| D 広帯域トランス (FT37-43 に 12 回:6 回) | 50 × 2² = 200 Ω (∥ 23 kΩ) | 32.8 | 2 | 29.8 dB | 0 V | 下は 1 次 (60 µH) の X<sub>L</sub> = 200 Ω になる 530 kHz から。上は f<sub>T</sub> |

- A は 8-1 そのもの。**B は Rc をコイルに替えただけ**で、1.9 MHz では X<sub>L</sub> = 2π × 1.9 MHz × 100 µH ≈ 1.2 kΩ が 50 Ω と並列になるから、利得は A とほぼ同じ。
  違いは直流 — コイルは電圧を落とさないので、コレクタは 5 V に座り、振幅の余裕が大きい
- C は **同調回路 (FT37-61 に 14 回 = 約 10.8 µH、680 pF) の f<sub>0</sub> = 1 / (2π√(LC)) ≈ 1.857 MHz**。
  1 次 14 回・リンク 3 回で n = 4.67 なので、50 Ω がコレクタからは 50 × 4.67² ≈ 1.09 kΩ に見える。
  コイル自身の損失は Q<sub>u</sub> ≈ 100 と仮定して R<sub>p</sub> = Q<sub>u</sub> × X<sub>L</sub> ≈ 12.9 kΩ (実物は 4-14 の方法で測る)。
  **負荷の Q<sub>L</sub> = R<sub>L</sub>′ / X<sub>L</sub> ≈ 7.6** で、3 dB 幅は f<sub>0</sub> / Q<sub>L</sub> ≈ 250 kHz
- D は巻数比 2:1 の広帯域トランス (FT37-43 に 12 回:6 回、1 次 約 60 µH)。**50 Ω がコレクタからは 200 Ω に見える**。
  同調しないので周波数によらず 4 倍で、下は 1 次のリアクタンスが 200 Ω を割る 530 kHz あたりから落ちる

**出力の上限**: コレクタの電流は 0 より下がれず (Ic × R<sub>L</sub>′ まで)、電圧は Vce の余裕 (5 − 0.86 − 0.2 ≈ 3.9 V) までしか振れない。小さいほうが上限になる (計算値)。

| 負荷 | コレクタの振幅の上限 | 50 Ω での振幅 | 電力 |
| --- | --- | --- | --- |
| A 抵抗 | Ic × 42 Ω = 0.18 V (電流で決まる) | 0.18 V<sub>p</sub> | 約 −5 dBm |
| B チョーク | Ic × 50 Ω = 0.22 V (電流で決まる。電圧の余裕 3.9 V は使えない) | 0.22 V<sub>p</sub> | 約 −3 dBm |
| D 広帯域トランス | Ic × 200 Ω = 0.86 V | 0.43 V<sub>p</sub> | 約 +2.7 dBm |
| C LC 同調 | Ic × 963 Ω = 4.1 V と Vce の余裕 3.9 V がほぼ同じ → 3.9 V | 0.84 V<sub>p</sub> | 約 +8.5 dBm |

電流の上限と電圧の上限が同時に効く R<sub>L</sub>′ = 3.9 V / 4.3 mA ≈ 900 Ω のとき、取り出せる電力が最大
(½ × 4.3 mA × 3.9 V ≈ 8.4 mW、+9.2 dBm) になる。**C の 963 Ω はほぼその値** — 同調負荷の巻数比は、利得だけでなく出力の上限も決めている
(8-21 で巻数比を振る)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 抵抗負荷 (Rc 270 Ω、8-1 と同じ段)
parts:
  J1: sma 2,3 mirror CH0
  C1: capacitor 3,3 5,3 0.1u
  R1: resistor 5,1 5,3 8k2
  R2: resistor 5,3 5,5 3k9
  Q1: npn 7,3
  Rc: resistor 7,1 7,2 270
  C2: capacitor 7,2 9,2 0.1u
  Re: resistor 7,4 7,6 200
  Ce: capacitor 9,4 9,6 1u
  J2: sma 11,2 CH1
  V1: vcc 5,1 5V
  G1: ground 2,4
  G2: ground 5,5
  G3: ground 7,6
  G4: ground 9,6
  G5: ground 11,3
wires:
  - J1.1 -- 3,3
  - J1.2 -- 2,4
  - 5,1 -- 7,1
  - 5,3 -- Q1.B
  - Q1.C |- 7,2
  - Q1.E |- 7,4
  - 7,4 -- 9,4
  - 7,6 -- 9,6
  - 9,2 -- 11,2 -- J2.1
  - J2.2 -- 11,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/20-collector-loads-1.svg)

- 8-1 の段 (R1・R2・Re・Rc) と同じ。違いはエミッタのバイパス Ce を 10 µF の電解から **1 µF の積層セラミック** に替えたこと
  (電解は MHz で ESL が効いてバイパスにならない。1 µF は 1.9 MHz で 0.08 Ω)
- 8-1 で基板に載せていた出力のアッテネータは、この題では**ケーブルの先の SMA のパッド**にして校正に含める (「掃引の設定」)。
  だから S21 の読みがそのままアンプの利得になる
- J1・J2 の外皮は GND。電源は +5 V の記号で描き、ブレッドボードでは上のレールに入れる

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図3 チョーク負荷 (RFC 100 µH)
parts:
  J1: sma 2,3 mirror CH0
  C1: capacitor 3,3 5,3 0.1u
  R1: resistor 5,1 5,3 8k2
  R2: resistor 5,3 5,5 3k9
  Q1: npn 7,3
  RFC: inductor 7,1 7,2 100u l=$\mathrm{RFC}$
  C2: capacitor 7,2 9,2 0.1u
  Re: resistor 7,4 7,6 200
  Ce: capacitor 9,4 9,6 1u
  J2: sma 11,2 CH1
  V1: vcc 5,1 5V
  G1: ground 2,4
  G2: ground 5,5
  G3: ground 7,6
  G4: ground 9,6
  G5: ground 11,3
wires:
  - J1.1 -- 3,3
  - J1.2 -- 2,4
  - 5,1 -- 7,1
  - 5,3 -- Q1.B
  - Q1.C |- 7,2
  - Q1.E |- 7,4
  - 7,4 -- 9,4
  - 7,6 -- 9,6
  - 9,2 -- 11,2 -- J2.1
  - J2.2 -- 11,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/20-collector-loads-2.svg)

- Rc を軸物のコイル 100 µH (8-4 のバイアス T と同じ物) に替えただけ。**直流は通し (コレクタは 5 V)、交流では 1.2 kΩ の高い Z** で、50 Ω の負荷に電流を渡す
- 100 µH の軸物は 9 MHz あたりに自己共振がある (8-4 の図3)。それより上ではコイルでなくコンデンサ (約 3 pF) に見えるが、
  30 MHz でも 1.8 kΩ あるので、この題の範囲では負荷の邪魔をしない。**チョークの上限は、自己共振よりトランジスタの f<sub>T</sub> が先に効く**

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図4 同調負荷 (FT37-61 に 14 回 + 680 pF、リンク 3 回で 50 Ω へ)
parts:
  J1: sma 2,4 mirror CH0
  C1: capacitor 3,4 5,4 0.1u
  R1: resistor 5,1 5,4 8k2
  R2: resistor 5,4 5,6 3k9
  Q1: npn 7,4
  Ct: capacitor 8,1 8,3 680p
  T1: transformer 10,2
  J2: sma 13,2 CH1
  Re: resistor 7,5 7,7 200
  Ce: capacitor 9,5 9,7 1u
  V1: vcc 5,1 5V
  G1: ground 2,5
  G2: ground 5,6
  G3: ground 7,7
  G4: ground 9,7
  G5: ground 11,4
  G6: ground 13,3
wires:
  - J1.1 -- 3,4
  - J1.2 -- 2,5
  - 5,1 -- 8,1
  - 5,4 -- Q1.B
  - Q1.C |- 8,3
  - Q1.E |- 7,5
  - 7,5 -- 9,5
  - 7,7 -- 9,7
  - 8,1 -| T1.A1
  - 8,3 -| T1.A2
  - T1.B1 |- 13,2 -- J2.1
  - T1.B2 -| 11,4
  - J2.2 -- 13,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/20-collector-loads-3.svg)

- T1 の 1 次 (A1-A2、14 回、約 10.8 µH) と Ct (680 pF) が同調回路。1 次の片端が +5 V、もう片端がコレクタ。
  **+5 V の線は交流では GND** (電源のコンデンサで落ちている) なので、同調回路はコレクタと GND の間に入っているのと同じ
- 2 次 (B1-B2、リンク 3 回) が 50 Ω の CH1 へ。巻数比 14:3 で、CH1 の 50 Ω はコレクタからは 1.09 kΩ に見える。
  **リンクの巻数を減らすほどコレクタから見た抵抗が上がり、利得が上がって帯域が狭くなる** (8-21)
- 結合コンデンサ C2 は要らない (トランスが直流を切る)

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図6 広帯域トランス負荷 (FT37-43 に 12 回:6 回、4:1 で 50 Ω を 200 Ω に)
parts:
  J1: sma 2,4 mirror CH0
  C1: capacitor 3,4 5,4 0.1u
  R1: resistor 5,1 5,4 8k2
  R2: resistor 5,4 5,6 3k9
  Q1: npn 7,4
  T1: transformer 10,2
  J2: sma 13,2 CH1
  Re: resistor 7,5 7,7 200
  Ce: capacitor 9,5 9,7 1u
  V1: vcc 5,1 5V
  G1: ground 2,5
  G2: ground 5,6
  G3: ground 7,7
  G4: ground 9,7
  G5: ground 11,4
  G6: ground 13,3
wires:
  - J1.1 -- 3,4
  - J1.2 -- 2,5
  - 5,1 -- 8,1
  - 5,4 -- Q1.B
  - Q1.C |- 8,3
  - Q1.E |- 7,5
  - 7,5 -- 9,5
  - 7,7 -- 9,7
  - 8,1 -| T1.A1
  - 8,3 -| T1.A2
  - T1.B1 |- 13,2 -- J2.1
  - T1.B2 -| 11,4
  - J2.2 -- 13,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/circuit/20-collector-loads-4.svg)

- 図4 から Ct を外し、T1 を **FT37-43 (透磁率の高いフェライト) に 12 回:6 回** に替えた。1 次は約 60 µH で、
  1.9 MHz の X<sub>L</sub> ≈ 720 Ω。反射した 200 Ω より十分大きいので、変換比はほぼ巻数比の 2 乗 (4:1) になる
- 同調しないので、100 kHz 台から 10 MHz 台まで同じ 200 Ω に見える (下は 1 次の X<sub>L</sub>、上は巻線の容量と f<sub>T</sub> で決まる)。
  **帯域を広く取りつつ利得を上げる、無線の自作の定番** (BITX の双方向アンプ、QRP の送信機のドライバ段など)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 抵抗負荷 (Rc を RFC に替えるとチョーク負荷)
board: half
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  VNA:
    type: device
    at: top
    label: VNA (20 dB パッド付きケーブルの先)
    pins: [CH0, GND, CH1]
  C1: capacitor/ceramic c2 c7 100n
  R1: resistor b7 b11 8k2
  Q1: transistor g7(B) g8(C) g9(E) 2SC1815 cap=left
  R2: resistor i7 i3 3k9
  Re: resistor i9 i13 200
  Ce: capacitor/ceramic h9 h13 1u cap=above:1,0
  Rc: resistor b15 b19 270 cap=below:1,0
  C2: capacitor/ceramic e15 e21 100n
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - VNA.GND -- -t3 black
  - VNA.CH0 -- a2 orange
  - VNA.CH1 -- a21 blue
  - +t11 -- a11 red
  - +t19 -- a19 red
  - -t30 -- -b30 black
  - j3 -- -b3 black
  - j13 -- -b13 black
  - e7 -- f7 orange
  - e8 -- f8 gray
  - d8 -- d15 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/breadboard/20-collector-loads-1.svg)

- 左が共通の段 (C1・R1・R2・Q1・Re・Ce)、**15 列目から右が負荷**。灰色の線 (8 → 15 列目) がコレクタを負荷まで運ぶ。
  1.9 MHz なら 7 穴ぶん (18 mm) の線は問題にならない
- **図3 のチョーク負荷は、Rc (15〜19 列目) を 100 µH の軸物のコイルに挿し替えるだけ**。C2 と線はそのまま
- Q1 は 2SC1815 (平らな面を手前にして左から E・C・B)。図は B・C・E の順に 7・8・9 列目なので、**平らな面を奥に向けて挿す**
- 電源は左上の 5 V (USB か電池 3 本の 4.5 V)。上の + レールに入れ、R1 と Rc へは 11・19 列目から縦に赤い線で下ろす。
  GND は上下の − レール (30 列目でつなぐ)
- VNA の CH0 (橙) は 2 列目 (C1 の左)、CH1 (青) は 21 列目 (C2 の右)。**どちらもケーブルの先に 20 dB のパッドを付けた状態**
  (「掃引の設定」)。CH0 の GND (黒) を − レールへ。ケーブルの外皮と電源の GND は、この 1 本でつながる
- 上の − レールと下の − レールをまたぐ黒い線 (30 列目) と、R2・Re の GND (3・13 列目) は下の − レールへ

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図5 同調負荷 (Ct を外し T1 を替えるとトランス負荷)
board: half
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  VNA:
    type: device
    at: top
    label: VNA (20 dB パッド付きケーブルの先)
    pins: [CH0, GND, CH1]
  C1: capacitor/ceramic c2 c7 100n
  R1: resistor b7 b11 8k2
  Q1: transistor g7(B) g8(C) g9(E) 2SC1815 cap=left
  R2: resistor i7 i3 3k9
  Re: resistor i9 i13 200
  Ce: capacitor/ceramic h9 h13 1u cap=above:1,0
  T1: transformer/toroid e15(A2) e18(A1) e21(B1) e24(B2) FT37-61 14t:3t
  Ct: capacitor/ceramic b15 b18 680p
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - VNA.GND -- -t3 black
  - VNA.CH0 -- a2 orange
  - VNA.CH1 -- a21 blue
  - +t11 -- a11 red
  - +t18 -- a18 red
  - -t24 -- a24 black
  - -t30 -- -b30 black
  - j3 -- -b3 black
  - j13 -- -b13 black
  - e7 -- f7 orange
  - e8 -- f8 gray
  - d8 -- d15 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/breadboard/20-collector-loads-2.svg)

- 共通の段は図2 と同じ。負荷が **T1 (FT37-61 のトロイダル) と Ct (680 pF)** に替わる。T1 の 4 本のリードは
  1 次の A2 (コレクタ、15 列目)・A1 (+5 V、18 列目)、2 次の B1 (CH1、21 列目)・B2 (GND、24 列目)
- **T1 の巻き方**: FT37-61 (灰色のフェライト、外径 9.5 mm) に 0.32 mm のポリウレタン線 (UEW) を 14 回。
  コアの内側を線が通った回数が巻数。リンク 3 回は 1 次の上に重ねて**同じ向き**に巻き、巻き始め (A1・B1) をそろえる。
  リードは被覆を削って錫めっきし、細くて抜けやすければ 0.5 mm の錫めっき線を継いでから挿す
- **図6 のトランス負荷は、Ct を抜き、T1 を FT37-43 (同じ外径、灰色) に 12 回:6 回 巻いた物に挿し替える**。
  リードの並びは同じ (A2 コレクタ・A1 +5 V・B1 CH1・B2 GND)
- 挿す前に、**T1 と Ct だけを図7 の方法で測って f<sub>0</sub> を合わせる**。A<sub>L</sub> のばらつき (±25 %) で f<sub>0</sub> は ±12 % 動く。
  低ければ Ct を 560 pF、高ければ 820 pF (どちらも E12) に替えるか、1 次を 1 回増減する
- ブレッドボードの浮遊容量 (列どうしで数 pF) は 680 pF に比べて小さく、f<sub>0</sub> をほとんど動かさない。回路が働く周波数は 1.9 MHz で、3 MHz 以下

## 掃引の設定

計器は VNA (LiteVNA64)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜30 MHz、201 点 (4 つの負荷を同じ範囲で)。同調負荷の山は 1.5〜2.2 MHz、351 点で見直す |
| 校正 | SOLT と THRU。**CH0 側に 20 dB、CH1 側に 20 dB の SMA のパッドを付け、パッドの先で校正する** (THRU は 2 つのパッドを直結して取る)。同調負荷は CH0 側を 30 dB にする |
| 表示 | S21 の Log Mag |

**パッドを 2 つ入れる理由**: CH0 側の 20 dB は、ベースの振れを数 mV に抑えて小信号で測るため (8-4 と同じ。
パッドを 10 dB 増やして S21 の読みが変わらなければ小信号で測れている)。CH1 側の 20 dB は、アンプの出力が
VNA 自身の出力より強くなって CH1 の上限 (0-3) に届かないようにするため。同調負荷は利得が 34 dB あるので、CH0 側を 30 dB にして
ベースを 10 mV 以下に抑える。**パッドは校正に含めるので、S21 の読みはそのままアンプの利得**。

**負荷を挿す前に、同調回路 (T1 の 1 次 + Ct) だけを測る**。CH0 と CH1 の間に**直列**に入れると、f<sub>0</sub> で並列共振の Z が最大になって深い谷ができる。
谷の底から 3 dB 上がる幅が f<sub>0</sub> / Q<sub>u</sub> で、コイルの Q<sub>u</sub> も読める。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: litevna64
sweep: 1.5M-2.2M 351
title: 図7 同調回路だけを直列に入れて測る (f0 で深い谷、幅から Qu)
dut:
  - series L 10.8u cp 680p rp 12.9k
traces:
  - S21 logmag
markers:
  - 1.857M
  - 1.848M
  - 1.866M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/vna/20-collector-loads.svg)

- 谷の底が f<sub>0</sub> = 1.857 MHz (計算)。深さ −42 dB は R<sub>p</sub> ≈ 12.9 kΩ (Q<sub>u</sub> 100 の仮定) と 100 Ω (両側の 50 Ω) の比
- 底から 3 dB 上がる所が ±9 kHz (1.848・1.866 MHz)。**幅 18.6 kHz = f<sub>0</sub> / Q<sub>u</sub>** → Q<sub>u</sub> ≈ 100。実物の 61 材は 1.9 MHz で 100〜150 ほど
- 谷が 1.8〜1.9 MHz から外れていたら、Ct か巻数を直してから負荷として挿す。**ここで f<sub>0</sub> を合わせておけば、アンプに入れた後の山の位置は
  トランジスタの容量 (C<sub>ob</sub> 2 pF と、ミラー効果で見える分) で 1〜2 % 下がるだけ**

## 見るべき値

計算値 (ハイブリッド π の等価回路、f<sub>T</sub> 80 MHz、h<sub>FE</sub> 200。パッドは校正に含めた後の S21)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図8 4 つの負荷の S21 (計算) — 同調負荷は山が高くて狭く、トランス負荷は広い
x: 周波数 Hz log 100k..30M
y: S21 dB -25..40
lines:
  A 抵抗 dB:
    - 100k 21.7
    - 133.4k 21.9
    - 177.8k 21.9
    - 237.1k 22.0
    - 316.2k 22.0
    - 421.7k 22.0
    - 562.3k 22.0
    - 749.9k 21.9
    - 1M 21.9
    - 1.334M 21.8
    - 1.778M 21.5
    - 1.857M 21.5
    - 2.371M 21.2
    - 3.162M 20.6
    - 4.217M 19.8
    - 5.623M 18.6
    - 7.499M 17.0
    - 10M 15.1
    - 13.34M 13.0
    - 17.78M 10.8
    - 23.71M 8.4
    - 30M 6.5
  B チョーク dB:
    - 100k 22.4
    - 133.4k 22.9
    - 177.8k 23.2
    - 237.1k 23.3
    - 316.2k 23.4
    - 421.7k 23.4
    - 562.3k 23.4
    - 749.9k 23.4
    - 1M 23.3
    - 1.334M 23.2
    - 1.778M 23.0
    - 1.857M 23.0
    - 2.371M 22.6
    - 3.162M 22.1
    - 4.217M 21.2
    - 5.623M 20.0
    - 7.499M 18.4
    - 10M 16.6
    - 13.34M 14.5
    - 17.78M 12.2
    - 23.71M 9.8
    - 30M 7.9
  C 同調 dB:
    - 100k -7.5
    - 133.4k -4.8
    - 177.8k -2.2
    - 237.1k 0.4
    - 316.2k 3.0
    - 421.7k 5.7
    - 562.3k 8.6
    - 749.9k 11.8
    - 1M 15.7
    - 1.334M 21.6
    - 1.445M 24.0
    - 1.514M 25.8
    - 1.585M 27.9
    - 1.66M 30.4
    - 1.738M 33.1
    - 1.82M 34.5
    - 1.857M 34.1
    - 1.905M 32.9
    - 1.995M 30.0
    - 2.089M 27.5
    - 2.188M 25.3
    - 2.291M 23.5
    - 2.399M 22.0
    - 3.162M 15.3
    - 4.217M 10.4
    - 5.623M 6.0
    - 7.499M 1.6
    - 10M -2.9
    - 13.34M -7.5
    - 17.78M -12.3
    - 23.71M -17.2
    - 30M -21.2
  D トランス dB:
    - 100k 14.6
    - 133.4k 17.1
    - 177.8k 19.5
    - 237.1k 21.7
    - 316.2k 23.7
    - 421.7k 25.4
    - 562.3k 26.7
    - 749.9k 27.6
    - 1M 28.2
    - 1.334M 28.5
    - 1.778M 28.5
    - 1.857M 28.4
    - 2.371M 28.2
    - 3.162M 27.5
    - 4.217M 26.5
    - 5.623M 25.2
    - 7.499M 23.4
    - 10M 21.4
    - 13.34M 19.3
    - 17.78M 16.9
    - 23.71M 14.5
    - 30M 12.5
notes:
  - mark 1.857M
  - mark 10M
  - band 1.8M 1.9M: 1.9 MHz 帯
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/graph/20-collector-loads.svg)

| 負荷 | 1 MHz | 1.857 MHz | 5 MHz | 10 MHz | 30 MHz | 山・3 dB 幅 |
| --- | --- | --- | --- | --- | --- | --- |
| A 抵抗 270 Ω | 21.9 dB | 21.5 dB | 19.1 dB | 15.1 dB | 6.5 dB | 平ら (上は f<sub>T</sub> で落ちる。8-1 と同じ) |
| B チョーク 100 µH | 23.3 dB | 23.0 dB | 20.5 dB | 16.6 dB | 7.9 dB | 平ら。A より 1.5 dB 高い (270 Ω が並列に無い分) |
| C LC 同調 | 15.7 dB | 34.1 dB | 7.8 dB | −2.9 dB | −21.2 dB | **34.5 dB、1.82 MHz**。3 dB 幅 1.69〜1.95 MHz (257 kHz、Q<sub>L</sub> ≈ 7.1) |
| D 広帯域トランス | 28.2 dB | 28.4 dB | 25.8 dB | 21.4 dB | 12.5 dB | 28.5 dB、1.5 MHz。3 dB 幅 0.43〜5.3 MHz |

- **A と B はほぼ同じ曲線**。50 Ω に直結する限り、負荷の種類で利得は変わらない。B の値打ちは直流の電圧降下が無いこと (出力の上限が 2 dB 上がる) と、消費電力
- **D は A より 6.5 dB 高い**。巻数比 2:1 で 50 Ω を 200 Ω に見せた分 (200 / 42 = 4.7 倍 = 6.8 dB の見積りと合う)。形は A と同じで、下が 430 kHz で落ちる
- **C は山で 34.5 dB、A より 13 dB 高いが、10 MHz では A より 18 dB 低い**。同調回路は「利得」と「選択度」を同時に買っている。
  山が 1.857 MHz でなく 1.82 MHz なのは、トランジスタの C<sub>ob</sub> とミラー効果で見える容量が 680 pF に足されるから (2 %)。
  目安の 36.2 dB より 1.7 dB 低いのは、ミラー効果でベースの入口が重くなり、ベースにかかる電圧が 1.89 倍から 1.6 倍に減るため
- 実物の f<sub>T</sub> が 80 MHz より高ければ、どの負荷も 5 MHz より上の落ち方がゆるくなる (8-1)。1.9 MHz の値はほとんど変わらない
- 測ったら Touchstone を題のファイルの隣に置き、`data:` で図7 に重ねる (アンプ本体は `dut:` では描けないので、S21 は表と図8 で比べる)

## LTspice での確かめ

`sim/20-collector-loads-tank.cir` で、図7 の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。
理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図7 | 1.857 MHz | S21 | −42.28 dB | −42.28 dB | 合う |
| 図7 | 1.848 MHz | S21 | −39.21 dB | −39.21 dB | 合う |
| 図7 | 1.866 MHz | S21 | −39.40 dB | −39.40 dB | 合う |

3 点すべて図の読み値と合う。

アンプの S21 は `dut:` では表せない (トランジスタを含む) ので、`sim/20-collector-loads-resistor.cir`・`-choke.cir`・`-tuned.cir`・`-transformer.cir` に
8-1 と同じハイブリッド π の模型 (g<sub>m</sub> 0.165 S、r<sub>π</sub> 1.2 kΩ、C<sub>π</sub> 327 pF、C<sub>µ</sub> 2 pF、r<sub>bb′</sub> 50 Ω、r<sub>o</sub> 23 kΩ) を置いて解いた。
図8 と「見るべき値」の表はその値。トロイダルは結合係数 1 の理想のトランスに、コイルの損失 (R<sub>p</sub>) を並列で足した。実測ではない。

| 負荷 | S21 の目安 (本文の式) | LTspice (1.857 MHz) | 判定 |
| --- | --- | --- | --- |
| A 抵抗 | 22.4 dB | 21.5 dB | 合う (r<sub>bb′</sub>・r<sub>o</sub> と、1.9 MHz で f<sub>T</sub> の落ちが始まる分) |
| B チョーク | 23.5 dB | 23.0 dB | 合う |
| C LC 同調 | 36.2 dB (山) | 34.5 dB (山、1.82 MHz) | 1.7 dB 低い。ミラー効果で入力が重くなる分 (本文) |
| D 広帯域トランス | 29.8 dB | 28.4 dB | 合う (1.4 dB 低い。r<sub>o</sub> と f<sub>T</sub> の分) |

f<sub>T</sub> を 200 MHz (C<sub>π</sub> 129 pF) にしても 1.857 MHz の値は 1 dB 以内しか変わらない (A・B・D で +0.4〜0.5 dB、C で +0.8 dB。5 MHz より上の落ち方は大きく変わる)。

## 出典

自作。共通の段と等価回路は 8-1、チョーク (100 µH の軸物) の自己共振は 8-4、トロイダルコアの A<sub>L</sub> は 4-14 と同じ値 (FT37-61 55 nH/回²、FT37-43 420 nH/回²、いずれも ±25 %)。

参考: [エミッタ接地回路 (Wikipedia)](https://ja.wikipedia.org/wiki/エミッタ接地回路)、[インピーダンス整合 (Wikipedia)](https://ja.wikipedia.org/wiki/インピーダンス整合)、[Choke (electronics) (Wikipedia)](https://en.wikipedia.org/wiki/Choke_(electronics))、[Toroidal inductors and transformers (Wikipedia)](https://en.wikipedia.org/wiki/Toroidal_inductors_and_transformers)
