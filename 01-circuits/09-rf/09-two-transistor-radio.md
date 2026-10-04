---
book: circuits
chapter: 9
id: 9-9
title: 2 石ラジオ — 高周波増幅 + 低周波増幅
tier: 200
source: 自作
board: BB
era: 古
---

# 9-9 2 石ラジオ — 高周波増幅 + 低周波増幅

9-3 の 1 石ラジオは、高周波を 1 石で増幅してからダイオードで検波し、そのまま
クリスタルイヤホンを鳴らした。ここでは**検波の後ろにもう 1 石、低周波 (音声) の
増幅段を足す**。高周波で約 50 倍、低周波で約 100 倍、合わせて数千倍の
電圧利得になり、バーアンテナだけで中波 (531〜1602kHz) の局が大きく聞こえる。

9-3 との違いはもう 1 つある。**アンテナから Q1 のベースへは、バーアンテナの
2 次巻線 (リンクコイル) で渡す**。Q1 の入力 (数 kΩ) を同調タンクに直に
つなぐと、タンクの Q が 1 近くまで落ちて局が分離できない。巻数比 10:1 なら
インピーダンスは 1/100 に見えるので、タンクの Q を保ったまま低いインピーダンスで
ベースを駆動できる。

## 回路図

```circuit
title: 図1 2 石ラジオ (W1 で AM を入れ、CH2 で RF 入力・CH1 で音声出力を見る)
parts:
  W1: sine d2 f2 l=$\mathrm{W1}$
  GW: ground f2
  CT: capacitor d2 d3 10p
  VC1: capacitor-var d4 f4 l=$\mathrm{VC}_1$
  GVC: ground f4
  T1: transformer e7
  GT2: ground f9
  C1: capacitor e9 e10 0.01u
  M2: voltmeter e10 g10 l=$\mathrm{CH2}$
  GM2: ground g10
  Q1: npn e13
  GE1: ground f13
  Rb1: resistor c11 c13 220k
  Rc1: resistor c14 a14 1.5k
  VCC1: vcc a14 5V
  D1: diode c14 c16 1N60
  C3: capacitor c17 e17 2200p
  GC3: ground e17
  R3: resistor c19 e19 4.7k
  GR3: ground e19
  C4: capacitor c19 c21 1u
  Q2: npn e23
  GE2: ground f23
  Rb2: resistor c21 c23 470k
  Rc2: resistor c24 a24 4.7k
  VCC2: vcc a24 5V
  EAR: earphone c26 e26 l=$\mathrm{EAR}$
  GEAR: ground e26
  M1: voltmeter c28 e28 l=$\mathrm{CH1}$
  GM1: ground e28
wires:
  - d3 -- d4
  - T1.A1 -| d4
  - T1.A2 -| f4
  - T1.B1 -| e9
  - T1.B2 -| f9
  - e10 -- e11
  - c11 -- e11
  - e11 -- Q1.B
  - c13 -- Q1.C
  - c13 -- c14
  - Q1.E -- f13
  - c16 -- c17 -- c19
  - c21 -- e21
  - e21 -- Q2.B
  - c23 -- Q2.C
  - c23 -- c24
  - Q2.E -- f23
  - c24 -- c26 -- c28
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/09-two-transistor-radio.svg)

`+5V` は Analog Discovery の電源出力 V+ (WaveForms の Supplies で 5 V)。放送を聞くときは
W1・C<sub>T</sub>・CH1・CH2 を外し、単 3 電池 3 本 (4.5V) でもよい。

- **同調 (T1 の 1 次 + VC1)**: T1 はバーアンテナ (フェライトの棒にコイルを巻いたアンテナ。
  棒が電波の磁界を集める)。1 次のインダクタンスを約 530µH とすると、
  VC1 (160pF 級のポリバリコン) と配線の浮遊容量 (約 10pF) で
  f = 1/(2π√(LC)) が **531kHz (C ≈ 170pF) 〜 1602kHz (C ≈ 19pF)** を覆う。
  コアの上でコイルを滑らせて下の端を合わせる
- **高周波増幅 (Q1)**: 2 次巻線 → C1 → Q1 のベース。バイアスは 9-3 と同じコレクタ帰還
  (R<sub>b1</sub> 220kΩ・R<sub>c1</sub> 1.5kΩ)。C1 は、2 次巻線がベースの直流を
  GND へ落とさないための結合コンデンサ
- **検波 (D1)**: 9-3 と同じく、ダイオードをコレクタに直結して直流のバイアス電流を流しておく。
  ただし検波の負荷 R3 を 100kΩ から **4.7kΩ** に下げた。次段 Q2 の入力 (約 3.0kΩ) が
  C4 を通して交流の負荷に並ぶので、直流の負荷との比 (4.7k‖3.0k) / 4.7k ≈ 0.39 が、
  音がひずまずに検波できる変調度の上限になる (負ピーククリッピング)。R3 が 100kΩ のままだと
  この比は 0.03 まで落ち、ふつうの放送 (変調度 30% 前後) でも音がつぶれる。
  負ピーククリッピングは、交流の負荷が直流の負荷より重いせいで、検波した波の谷が平らに切れること
- **低周波増幅 (Q2)**: C4 で直流を切り、Q2 (コレクタ帰還、R<sub>b2</sub> 470kΩ・
  R<sub>c2</sub> 4.7kΩ) で増幅して、コレクタからクリスタルイヤホン (EAR) を鳴らす。
  EAR は直流を通さない (容量 約 15nF のコンデンサ) ので、コレクタに直につないでよい
- C3 (2200pF) は検波後に残った 1MHz を GND へ落とす。1MHz で 72Ω、1kHz で 72kΩ

**動作点の計算値** (V<sub>CC</sub> = 5V、hFE = 200、V<sub>BE</sub> = 0.6V、D1 の順方向電圧 0.25V):

| 段 | 式 | 結果 |
| --- | --- | --- |
| Q1 | R<sub>c1</sub> に I<sub>C1</sub> と D1 の電流 (V<sub>C1</sub> − 0.25V)/R3 が流れる | V<sub>C1</sub> ≈ 2.2V、I<sub>C1</sub> ≈ 1.45mA、D1 ≈ 0.42mA |
| Q2 | I<sub>C2</sub> = (5 − 0.6)/(R<sub>b2</sub>/hFE + R<sub>c2</sub>) | I<sub>C2</sub> ≈ 0.62mA、V<sub>C2</sub> ≈ 2.1V |

**利得の目安** (計算値):

- Q1 (1MHz): g<sub>m1</sub> = 1.45mA / 26mV ≈ 56mS。コレクタの交流の負荷は R<sub>c1</sub> と
  検波の入力 (約 R3/2 = 2.35kΩ) の並列で約 0.92kΩ。A<sub>v1</sub> ≈ 56mS × 0.92kΩ ≈ **51 倍 (34dB)**。
  2SC1815 の f<sub>T</sub> (80MHz 級) から見て 1MHz ではまだ |h<sub>fe</sub>| (9-4 で見た) が 80 以上残る。
  コレクタ-ベース間の容量は、ベースから見ると (1 + 利得) 倍に大きく見える (ミラー効果)。
  ベースは 2 次巻線の低いインピーダンスで駆動するので、この容量は利得をあまり削らない
- 検波: 小さい振幅 (コレクタで 0.1V 程度) では、バイアスを流していてもダイオードの
  検波効率 η は 0.5 程度 (仮定)。音声の振幅 ≈ η × 変調度 × 搬送波の振幅
- Q2 (1kHz): g<sub>m2</sub> = 0.62mA / 26mV ≈ 24mS。負荷は R<sub>c2</sub> (4.7kΩ) と
  EAR (1kHz で約 10.6kΩ の容量性) の並列で |Z| ≈ 4.3kΩ。A<sub>v2</sub> ≈ **100 倍 (40dB)**、反転。
  入力インピーダンスは r<sub>π</sub> (= hFE / g<sub>m2</sub>、約 8.3kΩ) と、R<sub>b2</sub> のミラー分の並列で約 3.0kΩ。
  コレクタからベースへ戻る R<sub>b2</sub> も、ミラー効果でベースからは 1/(1 + 利得) に小さく見え、
  470kΩ/101 ≈ 4.7kΩ になる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む — 左が同調と高周波増幅、右が検波と低周波増幅
board: full
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery (電源・W1)
    pins: [GND, V+, W1]
  VC1:
    type: device
    at: top
    label: ポリバリコン 160pF
    pins: [E, A]
  BAR:
    type: device
    at: top
    label: バーアンテナ (1 次 P・2 次 S)
    pins: [P1, S1, P2, S2]
  ADM:
    type: device
    at: bottom
    label: Analog Discovery (CH2・CH1)
    pins: [2+, 2-, 1-, 1+]
  EAR:
    type: device
    at: bottom
    label: クリスタルイヤホン
    pins: [A, B]
  CT: capacitor/ceramic b16 b19 10p
  C1: capacitor/ceramic d22 d25 0.01u
  Rb1: resistor b25 b29 220k
  Q1: transistor e25(B) e29(C) e33(E) 2SC1815
  Rc1: resistor a29 +t29 1.5k
  D1: diode c29(A) c41(K) 1N60
  R3: resistor a41 -t41 4.7k
  C3: capacitor/ceramic b41 b45 2200p
  C4: capacitor/film d41 d47 1u
  Q2: transistor e47(B) e48(C) e49(E) 2SC1815
  Rb2: resistor c47 c53 470k
  Rc2: resistor a48 +t48 4.7k
wires:
  - AD.V+ -- +t3 red
  - AD.GND -- -t1 black
  - AD.W1 -- a16 yellow
  - VC1.E -- -t17 black
  - VC1.A -- a19 yellow
  - BAR.P1 -- c19 yellow
  - BAR.P2 -- -t37 black
  - BAR.S1 -- a22 yellow
  - BAR.S2 -- -t39 black
  - e22 -- f22 blue
  - ADM.2+ -- j22 blue
  - ADM.2- -- -b24 black
  - a33 -- -t33 black
  - a45 -- -t45 black
  - a49 -- -t49 black
  - b48 -- b53 orange
  - e53 -- f53 green
  - ADM.1+ -- i53 orange
  - ADM.1- -- -b40 black
  - EAR.A -- j53 green
  - EAR.B -- -b55 black
  - +t30 -- +t32 red
  - -t30 -- -t32 black
  - -b30 -- -b32 black
  - -t61 -- -b61 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/09-two-transistor-radio.svg)

フルサイズ (63 列) のブレッドボードに、左から同調 → 高周波増幅 → 検波 → 低周波増幅の順に並べる。
Analog Discovery は 1 台だが、線が交わらないよう図では箱を 2 つに分けた。上の箱が電源と W1、下の箱がオシロの CH2・CH1。
上の赤レール = +5V (AD の V+、赤)、上の青レール = GND (AD の GND、黒)。61 列の黒い線で下の − レールへ渡す。
フルサイズのブレッドボードには、電源レールが中央 (31 列と 32 列の間) で左右に切れている品がある。
30〜32 列の短い線 (+ は赤、− は黒) で、上の + と −、下の − の切れ目を渡しておく (切れていないブレッドボードでも害は無い)。

- **同調 (16〜22 列)**: W1 (黄) を `a16` に挿し、C<sub>T</sub> (b16–b19) を通して 19 列へ。
  19 列にポリバリコンの A 端子 (`a19`) とバーアンテナの 1 次 P1 (`c19`) が並ぶ。
  E 端子と P2・S2 は上の − レールへ。2 次の S1 は `a22`。黄はアンテナ側の高周波の線
- **CH2**: 22 列 (2 次巻線の出力、C1 の手前) を e–f の青い線で下のブロックへ渡し、`j22` に 2+ を挿す。回路図の CH2 と同じ所
- **Q1 (上のブロックの e 行)**: 25 列 B・29 列 C・33 列 E。
  - ベース (25 列): C1 (d22–d25) の右リードと Rb1 (b25–b29) の左リード
  - コレクタ (29 列): Rc1 を `a29` から上の + レールへ縦に、Rb1 の右リード、D1 のアノード (`c29`)
  - エミッタ (33 列): `a33` から − レールへ黒の線
- **検波 (41 列)**: D1 のカソード (`c41`)、R3 (`a41` から − レールへ縦に)、C3 (b41–b45、45 列を − レールへ)、C4 の左リード (`d41`)
- **Q2 (e 行、47 列 B・48 列 C・49 列 E)**: ピンを詰めて挿すので、コレクタは橙の線 (b48–b53) で 53 列へ引き出す。
  - ベース (47 列): C4 の右リード (`d47`) と Rb2 (c47–c53) の左リード
  - コレクタ (48 列): Rc2 を `a48` から + レールへ。53 列に Rb2 の右リード
  - エミッタ (49 列): `a49` から − レールへ
  - 53 列の e–f を緑の線で下のブロックへ渡し、クリスタルイヤホンの A を `j53`、CH1 の 1+ (橙) を `i53`、イヤホンの B を下の − レールへ
- AD の 2−・1− (黒) は下の − レールへ。放送を聞くときは W1・CH1・CH2 の線と C<sub>T</sub> を抜く
- 高周波の部分 (16〜41 列) の線はできるだけ短く。長いと Q1 の出力が入力側へ回り込んで発振しやすい

## 計器の設定

放送の代わりに、W1 から**振幅変調 (AM) した 1MHz** を入れる。W1 は C<sub>T</sub> (10pF) を
通して同調タンクの上へ弱く注ぐ。C<sub>T</sub> はタンクに並ぶので、VC1 は 1MHz に合う所
(タンクの合計 約 48pF) より C<sub>T</sub> の分だけ少なめに回して合わせる。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5V (オン) |
| Wavegen W1 | Sine 1MHz、Modulation: AM、1kHz の Sine、変調度 30%。振幅は CH2 の搬送波が 3mVpp になるよう絞る (目安 30mVpp — 2 次巻線で 1/10 になる) |
| Scope | CH2 = 2 次巻線の出力 (C1 の手前、RF 入力)、1mV/div。CH1 = Q2 のコレクタ (音声出力)、1V/div。CH1 は約 2.1V の直流に音声が乗るので、Offset で直流を打ち消す (図3 は CH2 と重ならないよう 2.5 目盛上へずらした Offset +0.4V)。トリガは CH1 の立ち上がり 2.1V |

VC1 を回して CH1 の振幅が最大になる所が 1MHz の同調点。外れると CH2 も CH1 も小さくなる
(タンクの Q が選択度そのもの)。

## 計器の画面

```scope
title: 図3 RF 入力 (CH2、1MHz を 1kHz・30% で AM) と音声出力 (CH1)
time: 200us/div
trigger: ch1 rising 2.1V
ch1: {wave: sine 1kHz 2.3Vpp phase 180deg offset 2.1V, range: 1V/div, position: 0.4div}
ch2: {wave: = 1.5mV * (1 + 0.3 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 1mV/div, position: -1.8div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/09-two-transistor-radio-1.svg)

- CH2 は 1MHz の搬送波が塗りつぶしの帯に見え、その**包絡線が 1kHz でふくらむ**。
  Vpp は包絡線の山で 3.9mVpp (= 3mVpp × 1.3)、谷で 2.1mVpp
- CH1 は包絡線を取り出して 100 倍した 1kHz の正弦波、約 **2.3Vpp**。Q2 で反転するので、
  **包絡線の山で CH1 が谷**になる (位相 180°)。検波で 1MHz は消えている

```scope
title: 図4 RF 入力 (CH2) の搬送波を拡大 — 無変調で 1MHz・3mVpp
time: 0.5us/div
trigger: ch2 rising 0V
ch2: {wave: sine 1MHz 3mVpp, range: 1mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/09-two-transistor-radio-2.svg)

W1 の変調を切って (無変調の搬送波) 横軸を 0.5µs/div にすると、帯の中身が 1MHz の正弦波だと分かる。
AD3 のアナログ入力は、BNC アダプタ付きで帯域 30MHz 以上 (−3dB)、6MHz まで −0.1dB に収まるので、1MHz は形のまま見える。2×15 ピンのヘッダに直接つないでも 9MHz (−3dB)、2.9MHz (−0.5dB) あり、1MHz は読める。

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Q1 のコレクタ電圧 | 約 2.2V | D1 のバイアス電流 (約 0.42mA) も R<sub>c1</sub> を流れる |
| Q2 のコレクタ電圧 | 約 2.1V | 動作点が電源のほぼ半分 |
| CH2 (2 次巻線の出力、無変調) | 3.00mVpp、1.000MHz | 2 次巻線で 1 次の 1/10 |
| CH2 (30% の AM) | 包絡線の山で 3.90mVpp | 変調度 = (3.9 − 2.1)/(3.9 + 2.1) = 0.3 |
| Q1 のコレクタの搬送波 | 約 150mVpp | 高周波の利得 約 51 倍 (34dB) |
| 検波の出力 (R3) | 約 23mVpp、1kHz | η 0.5 × 0.3 × 76mV (仮定) |
| CH1 (Q2 のコレクタ) | 約 2.30Vpp、1.000kHz、包絡線と逆位相 | 低周波の利得 約 100 倍 (40dB) |

- 全体では、ベースの搬送波 3mVpp から 2.3Vpp の音声で約 770 倍。1 石 (9-3) の検波出力を
  そのままイヤホンに入れたときと比べ、音は 40dB (100 倍) 大きい
- W1 を大きくして CH1 が 4Vpp を越えると、Q2 のコレクタが 0V と 5V の側で頭打ちになる。
  変調度を 50% 以上にすると、先に検波の負ピーククリッピング (上限 0.39) で CH1 の谷がつぶれる
- R3 を 100kΩ に戻すと、30% の変調でも CH1 の波形の片側が平らになる。検波の交流と直流の
  負荷の比を確かめられる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| T1 | バーアンテナ (2 次巻線つき、フェライト) | 1 次 約 530µH、巻数比 約 10:1 |
| VC1 | ポリバリコン (AM 用、160pF 級) | 最大 約 160pF |
| Q1, Q2 | NPN トランジスタ | 2SC1815 (GR) |
| D1 | ゲルマニウムダイオード | 1N60 |
| C1 | セラミックコンデンサ | 0.01µF |
| C3 | セラミックコンデンサ | 2200pF |
| C4 | フィルムコンデンサ | 1µF |
| R<sub>b1</sub>, R<sub>c1</sub> | 抵抗 (1/4W) | 220kΩ, 1.5kΩ |
| R3 | 抵抗 (1/4W) | 4.7kΩ |
| R<sub>b2</sub>, R<sub>c2</sub> | 抵抗 (1/4W) | 470kΩ, 4.7kΩ |
| EAR | クリスタルイヤホン (セラミック型) | 約 15nF |
| C<sub>T</sub> | セラミックコンデンサ (試験用) | 10pF |
| — | 電源 | Analog Discovery の V+ (5V)、または単 3 電池 3 本 |

- 1 次のインダクタンスは製品で違う (330µH 前後は 260pF のバリコン向け)。
  使うバリコンに合うバーアンテナを選ぶか、コアの上でコイルを滑らせて合わせる
- 2SC1815 のピンは平らな面を手前にして左から E・C・B

## 出典

自作。
クリスタルイヤホンの容量は 9-3 と同じ前提 (市販のセラミックイヤホン 15000pF)。
WaveForms の Wavegen の AM 変調は
[WaveForms Reference Manual](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual) による。
