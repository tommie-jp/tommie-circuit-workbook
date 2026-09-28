---
book: denken
chapter: 12
id: 12-2
title: 送電線の模型 — R と L の線路で電圧降下と電力損失
tier: 50
source: 自作
board: BB
---

# 12-2 送電線の模型 — R と L の線路で電圧降下と電力損失

送電線は抵抗 R とリアクタンス X (コイルの L) を持つ。電源電圧・線路の
インピーダンス・受電端の電圧はベクトルで足し合わさるので、単純な引き算には
ならない。線路のコイルを短絡できるスイッチを付け、R だけの線路と比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| Vs = Vr + I × (R + jX) | 送電端電圧はベクトル和 (3-4 の RC 直列と同じ考え方) |
| P_loss = I² × R | 線路の損失。線電流の 2 乗に比例する |
| X = ωL | 線路のリアクタンス。周波数に比例して増える |

## 回路図

```circuit
title: 図1 送電線の模型 (R + L、S1 で L を短絡)
style:
  standard: jis
parts:
  W1: sine c1 g1 l=$\mathrm{W1}$
  Rline: resistor c1 c3 10 i=I
  M2: voltmeter a1 a3 l=$\mathrm{CH2}$
  Lline: inductor c3 e3 10m
  S1: switch c5 e5
  Rload: resistor e3 g3 100
  M1: voltmeter a7 a9 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - a1 -- c1
  - a3 -- c3
  - c3 -- c5
  - e3 -- e5
  - a7 |- e3
  - a9 |- g3
  - g1 -- g3
```

- W1 は AD の波形発生器。1 kHz、振幅 1 V。Rline (10 Ω) が線路の抵抗を兼ねる
  電流検出用シャント、Lline (10 mH) が線路のリアクタンス
- S1 を閉じると Lline が短絡され、R だけの線路になる (開けば R + L の線路)
- CH1 (M1) が受電端電圧 Vr (Rload の両端)、CH2 (M2) が Rline の両端 (線電流 I)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rline: resistor c12 c16 10
  Lline: inductor/axial g16 g8 10m
  S1: switch i16 i8
  Rload: resistor c8 c4 100
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
wires:
  - AD.W1 -- a3 yellow
  - AD.GND -- -t6 black
  - a4 -- -t4 black
  - AD.1+ -- a8 orange
  - AD.1- -- -t10 black
  - b3 -- b12 yellow
  - AD.2+ -- a12 yellow
  - AD.2- -- a16 green
  - e8 -- f8 orange
  - e16 -- f16 green
```

- W1 (3 列) は黄の線で 12 列へ延ばし、Rline (12・16 列) の入口にする。16 列と
  8 列は溝をまたぐ短い線で下のブロックへ降ろしてある
- Lline (10 mH、下のブロックの 8・16 列) と S1 (同じ 8・16 列、別の穴) は同じ
  2 つの列を共有する。S1 を挿すと L が短絡され、抜くと L だけを通る
- 8 列 (受電端) から Rload (100 Ω、4〜8 列) を通って 4 列から青レール (GND) へ戻る
- CH1 (1+/1−) が Rload の両端 (受電端電圧)、CH2 (2+/2−) が Rline の両端 (線電流)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V |
| Scope | CH1 = 受電端電圧。CH2 = Rline の両端 (I = 読み ÷ 10 Ω)。Measure で振幅と位相 |

CH2 は CH1 のちょうど 1/10 なので、CH2 を 50 mV/div にすると 2 本が重なる。CH1 を上、CH2 を下へ
2 div ずつずらして並べた。CH1 と CH2 はどちらも抵抗の両端で同じ電流を見ているので、位相はそろう。
線路の L による遅れは W1 に対するもので、この 2 ch の間には出ない。

```scope
title: 図3 S1 を開く (R + L の線路) — CH1 は 500 mV/div、CH2 は 50 mV/div
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.789V, range: 500mV/div, position: 2div}
ch2: {wave: sine 1kHz 78.9mV, range: 50mV/div, position: -2div}
measure: [vmax, freq, phase]
```

```scope
title: 図4 S1 を閉じる (R だけの線路) — 同じ V/div で CH1・CH2 とも大きくなる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.909V, range: 500mV/div, position: 2div}
ch2: {wave: sine 1kHz 90.9mV, range: 50mV/div, position: -2div}
measure: [vmax, freq, phase]
```

### オシロスコープと発振器

W1 は FG の OUT (High-Z、1 kHz、振幅 1 V。Vpp で入れる機種なら 2 Vpp) に読み替える
([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)、
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。AD の CH2 は Rline の両端
(12 列と 16 列) を差動で挟む。汎用オシロのグランドクリップは大地につながっていて、FG の GND も
同じ大地につながっているので、16 列に当てると Lline と Rload が GND に落ち、12 列に当てると FG の
出力を GND へ短絡する。Rline の電圧は 80〜90 mV で、振れ (1 V) の 1 割に満たず、CH1 − CH2 では
8 bit の分解能に埋もれる。そこで **Rline を戻りの線 (Rload と GND の間) へ移す** (図5)。
線路の抵抗は行きと帰りのどちらにあっても、直列なので電流と損失は変わらない。試験の図とは位置が変わる。

```circuit
title: 図5 汎用オシロでの測り方
style:
  standard: jis
  pitch: 1.2
parts:
  V1: sine c1 g1 l=$\mathrm{FG}$
  S1: switch a3 a6
  Lline: inductor c3 c6 10m
  Rload: resistor c8 e8 100
  Rline: resistor e8 g8 10 i=I
  M2: voltmeter e11 g11 l=$\mathrm{CH2}$
  M1: voltmeter c14 g14 l=$\mathrm{CH1}$
  G1: ground g1
wires:
  - c1 -- c3
  - a3 -- c3
  - a6 -- c6
  - c6 -- c8 -- c14
  - e8 -- e11
  - g1 -- g8 -- g11 -- g14
```

- 板の変え方: Rline を 12〜16 列から抜き、3 列からの黄の線を 12 列でなく 16 列へ挿す。
  4 列から青レールへの黒い線を抜き、代わりに Rline を 4 列と青レールの間に挿す
- CH1 の先端は 8 列 (Rload の上)、CH2 の先端は 4 列 (Rline の上)。グランドクリップは 2 本とも青レール
- I は CH2 ÷ 10 Ω (図1 と同じ)。受電端電圧 Vr は Math の CH1 − CH2。Rload も Rline も抵抗なので、
  Vr と I は同じ位相になる
- FG の 50 Ω が線路の R に足される。負荷は 110〜127 Ω と小さく、振幅 1 V のままだと I の振幅は
  5.82 mA (S1 を開く) / 6.25 mA (閉じる) に下がる (計算値)。**FG の出力端 (3 列) の振幅が 1.00 V に
  なるよう、FG の振幅を上げる**: 先に CH1 の先端を 3 列に当てて合わせ、8 列へ戻す。設定は S1 を
  開いて約 1.36 V、閉じて約 1.45 V (Vpp の機種なら 2.71 / 2.91 Vpp)。S1 を切り替えるたびに合わせ直せば、
  見るべき値の表がそのまま使える

## 見るべき値

計算値。Rline = 10 Ω、Lline = 10 mH (X_L = 62.8 Ω、1 kHz)、Rload = 100 Ω とした。

| 状態 | I (振幅) | Vr = I×Rload | 線路の損失 (I_rms²×Rline) | 分かること |
| --- | --- | --- | --- | --- |
| S1 を開く (R + L の線路) | 7.89 mA | 0.789 V | 0.312 mW | X_L が効いて電流が減る |
| S1 を閉じる (R だけの線路) | 9.09 mA | 0.909 V | 0.413 mW | 電流・受電端電圧とも大きくなる |

**Vs (1 V) は Vr (0.789 V) と線路の電圧降下の単純な足し算にならない。**
線路の電圧降下 (I×√(R²+X_L²) ≒ 0.502 V) を Vr に足すと 1.29 V になり、
Vs の 1 V を超えてしまう — 両者の位相がずれているため、ベクトル和でしか
一致しない (3-4 の RC 直列と同じ性質)。リアクタンスが線路の電圧降下を
余分に大きくすることが、S1 の開閉で数値として確かめられる。

## 出典

自作。
