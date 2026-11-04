---
book: nanovna
chapter: 8
id: 8-20
title: コレクタ負荷を差し替える — 抵抗とチョークで S21 の利得と帯域を比べる (1.9 MHz 帯)
tier: 100
source: 自作
board: BB
device: LV64
---

# 8-20 コレクタ負荷を差し替える — 抵抗とチョークで S21 の利得と帯域を比べる (1.9 MHz 帯)

8-1 のエミッタ接地の段 (2SC1815、Ic ≈ 4.3 mA) をそのまま使い、**コレクタの負荷だけを差し替えて** S21 を比べる。
無線の自作で出てくるコレクタ負荷は、ほぼ 4 つに収まる: **抵抗**、**RF チョーク (RFC)**、**LC 同調回路**、**広帯域トランス**。
どれを選ぶかで利得・帯域・出力の上限が決まる。この題は 50 Ω (オーム) に直結する抵抗とチョークを比べる。
50 Ω を高い抵抗に見せて利得を上げる LC 同調と広帯域トランスは 8-22 に分けた。

- 出力は 50 Ω の VNA に直結する。**抵抗とチョークでは、コレクタから見た負荷がどちらもほぼ 50 Ω** になり、利得は 22〜23 dB で変わらない。違いは直流の電圧降下 (振幅の上限) と帯域の下限
- 周波数は 1.9 MHz 帯 (1.8〜1.9 MHz、160 m バンド)。3 MHz 以下なのでブレッドボードに組める

> **この題の図は理想の模型 (8-1 と同じハイブリッド π (パイ) の等価回路) から計算した値で、実機では測っていない。**

## この実験で確かめる式

共通の段は 8-1 と同じ: Vcc = 5 V、R1 = 8.2 kΩ、R2 = 3.9 kΩ、Re = 200 Ω、Ic ≈ 4.3 mA、
**re′ = 26 mV / Ic ≈ 6.05 Ω**。ベースの入口 (R1 ∥ R2 ∥ h<sub>FE</sub>re′ ≈ 830 Ω) は 50 Ω よりずっと高いので、
CH0 から来る波のほぼ 2 倍 (1.89 倍、+5.5 dB) がベースにかかる。

コレクタから見た交流の負荷を R<sub>L</sub>′ とすると、**コレクタの電圧利得 Av = R<sub>L</sub>′ / re′**。50 Ω に直結するので
**S21 の目安 = 20 log (1.89 × Av)**。

| 負荷 | コレクタから見た R<sub>L</sub>′ | Av | S21 の目安 | 直流の電圧降下 | 帯域 (計算) |
| --- | --- | --- | --- | --- | --- |
| A 抵抗 Rc 270 Ω | 270 ∥ 50 = 42 Ω | 7.0 | 22.4 dB | 1.2 V (Rc × Ic) | 広い。上は f<sub>T</sub> で落ちる (8-1) |
| B チョーク RFC 100 µH | 1.2 kΩ ∥ 50 = 48 Ω (1.9 MHz で X<sub>L</sub> = 1.2 kΩ) | 7.9 | 23.5 dB | 0 V | 下は X<sub>L</sub> = 50 Ω になる 80 kHz から。上は f<sub>T</sub> と自己共振 (約 9 MHz) |

- A は 8-1 そのもの。**B は Rc をコイルに替えただけ**で、1.9 MHz では X<sub>L</sub> = 2π × 1.9 MHz × 100 µH ≈ 1.2 kΩ が 50 Ω と並列になるから、利得は A とほぼ同じ。
  違いは直流 — コイルは電圧を落とさないので、コレクタは 5 V に座り、振幅の余裕が大きい

**出力の上限**: コレクタの電流は 0 より下がれず (Ic × R<sub>L</sub>′ まで)、電圧は Vce の余裕 (5 − 0.86 − 0.2 ≈ 3.9 V) までしか振れない。小さいほうが上限になる (計算値)。

| 負荷 | コレクタの振幅の上限 | 50 Ω での振幅 | 電力 |
| --- | --- | --- | --- |
| A 抵抗 | Ic × 42 Ω = 0.18 V (電流で決まる) | 0.18 V<sub>p</sub> | 約 −5 dBm |
| B チョーク | Ic × 50 Ω = 0.22 V (電流で決まる。電圧の余裕 3.9 V は使えない) | 0.22 V<sub>p</sub> | 約 −3 dBm |

A・B は電流で上限が決まり、電圧の余裕を使い切れない。余裕を使い切る負荷 (約 900 Ω) は 8-22 の同調負荷。

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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/08-amplifiers/breadboard/20-collector-loads.svg)

- 左が共通の段 (C1・R1・R2・Q1・Re・Ce)、**15 列目から右が負荷**。灰色の線 (8 → 15 列目) がコレクタを負荷まで運ぶ。
  1.9 MHz なら 7 穴ぶん (18 mm) の線は問題にならない
- **図3 のチョーク負荷は、Rc (15〜19 列目) を 100 µH の軸物のコイルに挿し替えるだけ**。C2 と線はそのまま
- Q1 は 2SC1815 (平らな面を手前にして左から E・C・B)。図は B・C・E の順に 7・8・9 列目なので、**平らな面を奥に向けて挿す**
- 電源は左上の 5 V (USB か電池 3 本の 4.5 V)。上の + レールに入れ、R1 と Rc へは 11・19 列目から縦に赤い線で下ろす。
  GND は上下の − レール (30 列目でつなぐ)
- VNA の CH0 (橙) は 2 列目 (C1 の左)、CH1 (青) は 21 列目 (C2 の右)。**どちらもケーブルの先に 20 dB のパッドを付けた状態**
  (「掃引の設定」)。CH0 の GND (黒) を − レールへ。ケーブルの外皮と電源の GND は、この 1 本でつながる
- 上の − レールと下の − レールをまたぐ黒い線 (30 列目) と、R2・Re の GND (3・13 列目) は下の − レールへ

## 掃引の設定

計器は VNA (LiteVNA64)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 kHz〜30 MHz、201 点 (8-22 の負荷とも同じ範囲) |
| 校正 | SOLT と THRU。**CH0 側に 20 dB、CH1 側に 20 dB の SMA のパッドを付け、パッドの先で校正する** (THRU は 2 つのパッドを直結して取る) |
| 表示 | S21 の Log Mag |

**パッドを 2 つ入れる理由**: CH0 側の 20 dB は、ベースの振れを数 mV に抑えて小信号で測るため (8-4 と同じ。
パッドを 10 dB 増やして S21 の読みが変わらなければ小信号で測れている)。CH1 側の 20 dB は、アンプの出力が
VNA 自身の出力より強くなって CH1 の上限 (0-3) に届かないようにするため。**パッドは校正に含めるので、S21 の読みはそのままアンプの利得**。

アンプの S21 は vna フェンスの `dut:` では描けない (トランジスタを含む) ので、見えるはずの S21 は「見るべき値」の図4 に計算で示す。

## 見るべき値

計算値 (ハイブリッド π の等価回路、f<sub>T</sub> 80 MHz、h<sub>FE</sub> 200。パッドは校正に含めた後の S21)。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 抵抗負荷とチョーク負荷の S21 (計算) — ほぼ同じ曲線で、チョークが 1.5 dB 高い
x: 周波数 Hz log 100k..30M
y: S21 dB 0..30
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

- **A と B はほぼ同じ曲線**。50 Ω に直結する限り、負荷の種類で利得は変わらない。B の値打ちは直流の電圧降下が無いこと (出力の上限が 2 dB 上がる) と、消費電力
- 実物の f<sub>T</sub> が 80 MHz より高ければ、どの負荷も 5 MHz より上の落ち方がゆるくなる (8-1)。1.9 MHz の値はほとんど変わらない
- 測ったら Touchstone を題のファイルの隣に置き、S21 を表と図4 で比べる

## LTspice での確かめ

アンプの S21 は `dut:` では表せない (トランジスタを含む) ので、`sim/20-collector-loads-resistor.cir`・`-choke.cir` に
8-1 と同じハイブリッド π の模型 (g<sub>m</sub> 0.165 S、r<sub>π</sub> 1.2 kΩ、C<sub>π</sub> 327 pF、C<sub>µ</sub> 2 pF、r<sub>bb′</sub> 50 Ω、r<sub>o</sub> 23 kΩ) を置いて解いた。
図4 と「見るべき値」の表はその値。実測ではない。

| 負荷 | S21 の目安 (本文の式) | LTspice (1.857 MHz) | 判定 |
| --- | --- | --- | --- |
| A 抵抗 | 22.4 dB | 21.5 dB | 合う (r<sub>bb′</sub>・r<sub>o</sub> と、1.9 MHz で f<sub>T</sub> の落ちが始まる分) |
| B チョーク | 23.5 dB | 23.0 dB | 合う |

f<sub>T</sub> を 200 MHz (C<sub>π</sub> 129 pF) にしても 1.857 MHz の値は A・B とも +0.5 dB 以内しか変わらない (5 MHz より上の落ち方は大きく変わる)。

## 出典

自作。共通の段と等価回路は 8-1、チョーク (100 µH の軸物) の自己共振は 8-4。

参考: [エミッタ接地回路 (Wikipedia)](https://ja.wikipedia.org/wiki/エミッタ接地回路)、[Choke (electronics) (Wikipedia)](https://en.wikipedia.org/wiki/Choke_(electronics))
