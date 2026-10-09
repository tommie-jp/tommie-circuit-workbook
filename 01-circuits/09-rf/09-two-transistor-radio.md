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
増幅段を足す**。高周波で約 7 倍、低周波で約 100 倍、合わせて約 700 倍の
電圧利得になる。さらに検波ダイオードは小さい振幅では 2 乗検波に近く、入力が大きいほど効率が上がるので、
バーアンテナだけで中波 (531〜1602kHz) の局が聞こえるのは、電波の強い所に限られる。

9-3 との違いはもう 1 つある。**アンテナから Q1 のベースへは、バーアンテナの
2 次巻線 (リンクコイル) で渡す**。Q1 の入力 (数 kΩ) を同調タンクに直に
つなぐと、タンクの Q が 1 近くまで落ちて局が分離できない。巻数比 10:1 なら
インピーダンスは 1/100 に見えるので、タンクの Q を保ったまま低いインピーダンスで
ベースを駆動できる。

## 回路図

```circuit
title: 図1 2 石ラジオ (W1 で AM を入れ、CH2 で RF 入力・CH1 で音声出力を見る)
parts:
  W1: sine 2,4 2,6 l=$\mathrm{W1}$
  GW: ground 2,6
  CT: capacitor 2,4 3,4 10p
  VC1: capacitor-var 4,4 4,6 l=$\mathrm{VC}_1$
  GVC: ground 4,6
  T1: transformer 7,5
  GT2: ground 9,6
  C1: capacitor 9,5 10,5 0.01u
  M2: voltmeter 10,5 10,7 l=$\mathrm{CH2}$
  GM2: ground 10,7
  Q1: npn 13,5
  GE1: ground 13,6
  Rb1: resistor 11,3 13,3 220k
  Rc1: resistor 14,3 14,1 1.5k
  VCC1: vcc 14,1 5V
  D1: diode 14,3 16,3 1N60
  C3: capacitor 17,3 17,5 2200p
  GC3: ground 17,5
  R3: resistor 19,3 19,5 4.7k
  GR3: ground 19,5
  C4: capacitor 19,3 21,3 1u
  Q2: npn 23,5
  GE2: ground 23,6
  Rb2: resistor 21,3 23,3 470k
  Rc2: resistor 24,3 24,1 4.7k
  VCC2: vcc 24,1 5V
  EAR: earphone 26,3 26,5 l=$\mathrm{EAR}$
  GEAR: ground 26,5
  M1: voltmeter 28,3 28,5 l=$\mathrm{CH1}$
  GM1: ground 28,5
wires:
  - 3,4 -- 4,4
  - T1.A1 -| 4,4
  - T1.A2 -| 4,6
  - T1.B1 -| 9,5
  - T1.B2 -| 9,6
  - 10,5 -- 11,5
  - 11,3 -- 11,5
  - 11,5 -- Q1.B
  - 13,3 -- Q1.C
  - 13,3 -- 14,3
  - Q1.E -- 13,6
  - 16,3 -- 17,3 -- 19,3
  - 21,3 -- 21,5
  - 21,5 -- Q2.B
  - 23,3 -- Q2.C
  - 23,3 -- 24,3
  - Q2.E -- 23,6
  - 24,3 -- 26,3 -- 28,3
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
  f = 1/(2π√(LC)) が **531kHz (C ≈ 170pF) 〜 1602kHz (C ≈ 18.6pF)** を覆う。
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

LTspice の動作点 (hFE = 250、V<sub>BE</sub> = 0.65V の代用モデル) は、V<sub>C1</sub> = 2.04V、I<sub>C1</sub> = 1.59mA、I<sub>D1</sub> = 0.38mA、
V<sub>C2</sub> = 1.86V、I<sub>C2</sub> = 0.67mA。上の計算値 (hFE = 200) と 1 割ほどの差で、hFE の仮定の違い。

**利得の目安** (計算値):

- Q1 (1MHz): g<sub>m1</sub> = 1.45mA / 26mV ≈ 56mS。コレクタの交流の負荷は R<sub>c1</sub> (1.5kΩ) と、
  D1 を通って C3 へ抜ける道の並列になる。D1 はバイアスの電流が流れていて小さな抵抗に見え
  (r<sub>d</sub> = N·V<sub>T</sub> / I<sub>D</sub> ≈ 90Ω、直列抵抗を足して約 110Ω)、C3 (2200pF) は 1MHz で 72Ω なので、
  この道は約 130Ω しかない。負荷は約 120Ω になり、A<sub>v1</sub> ≈ 56mS × 0.12kΩ ≈ **7 倍 (17dB)**。
  検波の入力を R3/2 (約 2.35kΩ) と見ても利得は 50 倍に届かない (これは負荷を R3 だけで考えた誤り)。
  C3 を小さくすれば利得は上がるが、1MHz を落とす力が弱まる
- ミラー効果: コレクタ-ベース間の容量は、ベースから見ると (1 + 利得) 倍に大きく見える。
  この段の利得は小さく、ベースは 2 次巻線の低いインピーダンスで駆動するので、利得はほとんど削れない
- 検波: コレクタの搬送波が数十 mVpp のうちは、バイアスを流していてもダイオードは 2 乗検波に近く、
  音声は搬送波の振幅の 2 乗に比例する。LTspice の 1kHz 成分は、CH2 の搬送波が 3mVpp で検波の出力 約 0.3mVpp (CH1 約 50mVpp)、
  6mVpp で 8mVpp (CH1 0.27Vpp)、10mVpp で 15.5mVpp (CH1 0.89Vpp)、12mVpp で 22mVpp (CH1 1.6Vpp)。
  振幅が上がるほど検波効率が上がる。2 乗検波は 2 次のひずみも出し、CH1 の 2 倍の周波数の成分は
  基本波の 7% (6mVpp)〜18% (12mVpp)
- Q2 (1kHz): g<sub>m2</sub> = 0.62mA / 26mV ≈ 24mS。負荷は R<sub>c2</sub> (4.7kΩ) と
  EAR (1kHz で約 10.6kΩ の容量性) の並列で |Z| ≈ 4.3kΩ。A<sub>v2</sub> ≈ **100 倍 (40dB)**、反転 (LTspice の小信号で 105 倍)。
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
  CT: capacitor/ceramic c15 c19 10p
  C1: capacitor/ceramic d22 d25 0.01u
  Rb1: resistor b25 b29 220k
  Q1: transistor e25(B) e29(C) e33(E) 2SC1815 cap=below
  Rc1: resistor a29 +t29 1.5k
  D1: diode c29(A) c41(K) 1N60
  R3: resistor a41 -t41 4.7k
  C3: capacitor/ceramic b41 b45 2200p
  C4: capacitor/film d41 d47 1u
  Q2: transistor e47(B) e48(C) e49(E) 2SC1815 cap=below
  Rb2: resistor c47 c53 470k cap=below:1.5,0
  Rc2: resistor a48 +t48 4.7k cap=left
wires:
  - AD.V+ -- +t3 red
  - AD.GND -- -t1 black
  - AD.W1 -- a15 yellow
  - VC1.E -- -t17 black
  - VC1.A -- a19 yellow
  - BAR.P1 -- a20 yellow
  - b19 -- b20 yellow
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
  - h53 -- h52 green
  - ADM.1+ -- j52 orange
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

- **同調 (15〜22 列)**: W1 (黄) を `a15` に挿し、C<sub>T</sub> (c15–c19) を通して 19 列へ。
  19 列にポリバリコンの A 端子 (`a19`) が入る。バーアンテナの 1 次 P1 は `a20` に挿し、b 行の黄色の短い線 (b19–b20) で 19 列へつなぐ
  (2 本の線が同じ列の穴の上を通らないようにするため)。
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
  - 53 列の e–f を緑の線で下のブロックへ渡し、クリスタルイヤホンの A を `j53`、イヤホンの B を下の − レールへ。
    CH1 の 1+ (橙) は、h 行の緑の短い線 (h53–h52) で 52 列へ分けた `j52` に挿す (イヤホンの線と交わらないようにするため)
- AD の 2−・1− (黒) は下の − レールへ。放送を聞くときは W1・CH1・CH2 の線と C<sub>T</sub> を抜く
- 高周波の部分 (16〜41 列) の線はできるだけ短く。長いと Q1 の出力が入力側へ回り込んで発振しやすい

## 計器の設定

放送の代わりに、W1 から**振幅変調 (AM) した 1MHz** を入れる。W1 は C<sub>T</sub> (10pF) を
通して同調タンクの上へ弱く注ぐ。C<sub>T</sub> はタンクに並ぶので、VC1 は 1MHz に合う所
(タンクの合計 約 48pF) より C<sub>T</sub> の分だけ少なめに回して合わせる。

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5V (オン) |
| Wavegen W1 | Sine 1MHz、Modulation: AM、1kHz の Sine、変調度 30%。振幅は CH2 の搬送波が 10mVpp になるよう絞る (目安 100mVpp — 2 次巻線で 1/10 になる) |
| Scope | CH2 = 2 次巻線の出力 (C1 の手前、RF 入力)、5mV/div。CH1 = Q2 のコレクタ (音声出力)、0.5V/div。CH1 は約 1.9V の直流に音声が乗るので、Offset で直流を打ち消す。トリガは CH1 の立ち上がり 1.9V |

VC1 を回して CH1 の振幅が最大になる所が 1MHz の同調点。外れると CH2 も CH1 も小さくなる
(タンクの Q が選択度そのもの)。

## 計器の画面

```scope
title: 図3 RF 入力 (CH2、1MHz を 1kHz・30% で AM) と音声出力 (CH1)
time: 200us/div
trigger: ch1 rising 1.9V
ch1: {wave: sine 1kHz 0.9Vpp phase 180deg offset 1.9V, range: 0.5V/div, position: -1.8div}
ch2: {wave: = 5mV * (1 + 0.3 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 5mV/div, position: -2.0div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/09-two-transistor-radio-1.svg)

- CH2 は 1MHz の搬送波が塗りつぶしの帯に見え、その**包絡線が 1kHz でふくらむ**。
  Vpp は包絡線の山で 13mVpp (= 10mVpp × 1.3)、谷で 7mVpp
- CH1 は包絡線を取り出して増幅した 1kHz の波、約 **0.9Vpp** (LTspice の 1kHz 成分 0.89Vpp。2 次のひずみが 1 割ほど乗り、図は正弦波で描いた)。Q2 で反転するので、
  **包絡線の山で CH1 が谷**になる (位相 180°)。検波で 1MHz は消えている

```scope
title: 図4 RF 入力 (CH2) の搬送波を拡大 — 無変調で 1MHz・10mVpp
time: 0.5us/div
trigger: ch2 rising 0V
ch2: {wave: sine 1MHz 10mVpp, range: 2mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/09-two-transistor-radio-2.svg)

W1 の変調を切って (無変調の搬送波) 横軸を 0.5µs/div にすると、帯の中身が 1MHz の正弦波だと分かる。
AD3 のアナログ入力は、BNC アダプタ付きで帯域 30MHz 以上 (−3dB)、6MHz まで −0.1dB に収まるので、1MHz は形のまま見える。2×15 ピンのヘッダに直接つないでも 9MHz (−3dB)、2.9MHz (−0.5dB) あり、1MHz は読める。

### 同調回路だけを VNA で見る (補足)

W1 の代わりに LiteVNA64 を使うと、バーアンテナの 1 次 (約 530 µH) と同調の容量 (VC1 と C<sub>T</sub> を合わせた約 48 pF) の
並列だけを、放送の電波なしで測れる。この並列を回路から外し、CH0 と CH1 の間に**直列**に挿して、S21 の Log Mag を 0.8〜1.2 MHz で掃引する。
並列共振ではインピーダンスが非常に大きくなって信号が通らないので、f<sub>0</sub> だけ深い谷になる。
03-nanovna/03-fixtures/01-series-fixture.md (3-1) の直列治具が使える。

見えるはずの画面 (理想の模型。コイルの損失を並列の 333 kΩ (Q = 100) とした目安で、実測ではない)。

```vna
device: litevna64
sweep: 0.8M-1.2M 401
title: 図5 同調回路 (T1 の 1 次 530 µH ∥ 48 pF) の S21 — f0 で深い谷
dut:
  - series L 530u cp 48p rp 333k
traces:
  - S21 logmag
markers:
  - 0.998M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/vna/09-two-transistor-radio.svg)

- 谷の位置は f<sub>0</sub> = 1 / (2π√(530 µH × 48 pF)) ≈ 0.998 MHz で、図の読み値は 0.998 MHz で約 −70 dB。VC1 を回すと動く
- 実物は図ほど深くならない。コイルの Q、バーアンテナの置き方、治具の漏れで浅くなり、手や金属を近づけても動く

## 見るべき値

計算値と LTspice の値 (下の「LTspice での確かめ」)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Q1 のコレクタ電圧 | 約 2.0〜2.2V | D1 のバイアス電流 (約 0.4mA) も R<sub>c1</sub> を流れる |
| Q2 のコレクタ電圧 | 約 1.9〜2.1V | 動作点が電源のほぼ半分 |
| CH2 (2 次巻線の出力、無変調) | 10.0mVpp、1.000MHz | 2 次巻線で 1 次の 1/10 |
| CH2 (30% の AM) | 包絡線の山で 13.0mVpp、谷で 7.0mVpp | 変調度 = (13 − 7)/(13 + 7) = 0.3 |
| Q1 のコレクタの搬送波 | 包絡線の山で約 110mVpp | 高周波の利得 約 7〜9 倍 (小信号で 6.8 倍) |
| 検波の出力 (R3) | 約 15mVpp、1kHz | 2 乗検波に近く、搬送波が大きいほど効率が上がる |
| CH1 (Q2 のコレクタ) | 約 0.9Vpp、1.000kHz、包絡線と逆位相 | 低周波の利得 約 100 倍 (40dB)。搬送波を 12mVpp にすると約 1.6Vpp |

- 全体では、ベースの搬送波 10mVpp から 0.9Vpp の音声が出る。1 石 (9-3) の検波出力を
  そのままイヤホンに入れたときと比べ、音は 40dB (100 倍) 大きい
- CH2 の搬送波を 30mVpp 近くまで上げると、Q2 のコレクタが 0V と 5V の側で頭打ちになる。
  変調度を 50% 以上にすると、先に検波の負ピーククリッピング (上限 0.39) で CH1 の谷がつぶれる
- R3 を 100kΩ に戻すと、30% の変調でも CH1 の波形の片側が平らになる。検波の交流と直流の
  負荷の比を確かめられる

## LTspice での確かめ

デッキは `sim/09-two-transistor-radio.cir` (過渡解析。2 次巻線の出力に AM した 1MHz を入れ、`hf` で振幅を振る) と
`sim/09-two-transistor-radio-ac.cir` (小信号の利得)。モデルは 9-25 と同じ 2SC1815 の代用
(IS = 2 × 10<sup>−14</sup>・BF = 250・VAF = 100・RB = 30 Ω・CJE = 8 pF・CJC = 2 pF・TF = 2 ns) と、
1N60 の代用 (IS = 250 nA・N = 1.3・RS = 20 Ω・CJO = 1 pF。順方向 0.25V で 0.4mA になるよう置いた目安)。
目安から作った仮定で、実測の値ではない。

| 項目 | 本文の計算値 | LTspice | 判定 |
| --- | --- | --- | --- |
| V<sub>C1</sub>、I<sub>C1</sub>、I<sub>D1</sub> | 2.2V、1.45mA、0.42mA | 2.04V、1.59mA、0.38mA | ほぼ合う (hFE 250 の仮定の差) |
| V<sub>C2</sub>、I<sub>C2</sub> | 2.1V、0.62mA | 1.86V、0.67mA | ほぼ合う (同上) |
| 高周波の利得 (1MHz、小信号) | 51 倍 (旧) | 6.8 倍 | 直した (約 7 倍。D1 の r<sub>d</sub> と C3 が負荷になる) |
| 低周波の利得 (1kHz、小信号) | 約 100 倍 | 105 倍 | 合う |
| 検波の出力 (CH2 の搬送波 10mVpp) | 23mVpp (旧、3mVpp で) | 15.5mVpp (3mVpp では約 0.3mVpp) | 直した (2 乗検波で振幅に強く依る) |
| CH1 の音声 | 2.3Vpp (旧、3mVpp で) | 0.89Vpp (10mVpp で)、50mVpp (3mVpp で) | 直した (W1 の目安を 10mVpp に) |
| 同調の範囲 (L = 530µH) | 531kHz〜1602kHz | 170pF で 530.2kHz、18.6pF で 1602kHz | 合う (19pF は 1586kHz なので 18.6pF に直した) |
| 図5 の谷 | 0.998MHz、約 −70dB | 1/(2π√(LC)) = 0.998MHz、2Z<sub>0</sub>/(R<sub>p</sub> + 2Z<sub>0</sub>) = −70.5dB | 合う (式による確認) |

放送の受信そのものとバーアンテナの感度は、電波とアンテナで決まるのでシミュレーションの対象外。

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
