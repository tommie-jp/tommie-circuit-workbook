---
book: denken
chapter: 4
id: 4-1
title: 三相の信号を作る — AD の 2 ch (位相 120°) と OP アンプで 3 相目
tier: 50
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: BB
---

# 4-1 三相の信号を作る — AD の 2 ch (位相 120°) と OP アンプで 3 相目

三相交流は 120° ずつずれた 3 つの正弦波。Analog Discovery (AD) の波形発生器
(Wavegen) は W1・W2 の 2 ch しか無いので、1 相目・2 相目は AD からそのまま出し、
3 相目はオペアンプの反転加算回路で作る。**平衡三相は 3 つの和が常に 0** という
性質を使うと、3 相目 = −(1 相目 + 2 相目) で作れる。この回路を 4-2〜4-4 でも
そのまま使う。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| v₁ = Vm sin θ、v₂ = Vm sin(θ − 120°) | AD の W1・W2 (振幅 Vm、位相差 120°) |
| v₃ = −(v₁ + v₂) | 3 相目。オペアンプの反転加算 (ゲイン −1 を 2 つ足す) |
| v₁ + v₂ + v₃ = 0 | 平衡三相の性質。3 つの瞬時値の和は常に 0 |
| v₃ = Vm sin(θ + 120°) | 上の式を展開すると、3 相目も同じ振幅で 120° 進んだ正弦波になる |

## 回路図

```circuit
title: 図1 三相の信号を作る
parts:
  V1: sine a1 c1 1 l=$\mathrm{W1}$
  G1: ground c1
  R1: resistor a1 a4 10k
  V2: sine e1 g1 1 l=$\mathrm{W2}$
  G2: ground g1
  R2: resistor e1 e5 10k
  U1: opamp c9 +up TL071
  G3: ground c6
  Rf: resistor d11 d14 10k
  OUT: port c16
wires:
  - a4 |- U1.-
  - e5 |- U1.-
  - c6 |- U1.+
  - d11 |- U1.-
  - U1.out -- c14 -- c16
  - d14 -- c14
notes:
  - text c16 blue: 3 相目
style:
  standard: jis
  grid: on
  pitch: 1.4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/01-three-phase-source.svg)

- V1 (W1) が 1 相目 (0°)、V2 (W2) が 2 相目 (−120°)。どちらも AD の Wavegen が
  そのまま出す — AD の Wavegen 出力インピーダンスは低いので、バッファなしで
  1 相目・2 相目として使ってよい
- U1 (TL071) は R1・R2・Rf が全部 10 kΩ の**反転加算回路**。出力 = −(1 相目 + 2 相目)。
  非反転入力は GND (G3) に落として仮想接地を作る
- R1・R2 (各 10 kΩ) が AD の Wavegen から引く電流は 1 V ÷ 10 kΩ = 0.1 mA だけ。
  Wavegen の上限 30 mA (AD3 の仕様) に対して十分小さい

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery (1 回目)
# 上のブロック (a〜e) に TL071 の入力側と R1・R2、下のブロック (f〜j) に出力側と Rf
board: half
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 2-, V-, W1, 1+, W2, 2+]
wires:
  - AD.V+ -- +t4 red
  - AD.GND -- -t6 black
  - AD.1- -- -t8 black
  - AD.2- -- -t10 black
  - AD.V- -- a13 purple
  - AD.W1 -- c17 yellow [h-10]
  - AD.1+ -- a17 yellow
  - AD.W2 -- b25 orange [h-10]
  - AD.2+ -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
notes:
  - text small: 2 番 (IN-) に R1・R2・Rf が集まる。2 回目は AD.2+ を U1.6 に挿し替える
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/01-three-phase-source-1.svg)

- TL071 (dip8) は `r180` で置き、1 番が e16 に来る。上の段 (e13〜e16) が 4・3・2・1 番、
  下の段 (f13〜f16) が 5・6・7・8 番。ピン: 1 = NC、2 = IN−、3 = IN+、4 = V−、
  5 = NC、6 = OUT、7 = V+、8 = NC。**1・5・8 番はオフセット調整用**
  (データシートどおり未使用。空けたままでよい)
- IN− (15 列) は d 行の緑の線で 21 列へ延ばし、R1・R2 と、溝を渡って下の段の Rf が集まる。
  IN+ (14 列) は GND レール (−t)、V+ (7 番、下の段 15 列) は下の + レールから取る
  (左端の赤い線で上の + レールとつなぐ)
- V+ (7 番) と V− (4 番) は AD の Supplies の ±5 V。オペアンプの出力は最大でも
  1 V 程度なので、±5 V の電源に対して十分な余裕がある

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: Sine、1 kHz、Amplitude 1 V、Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V。Master Enable を入れてから波形を出す |
| Scope (1 回目) | CH1 = W1 (1 相目)、CH2 = W2 (2 相目)。どちらも DC 結合 |
| Scope (2 回目) | CH2 を U1 の 6 番 (3 相目) に挿し替える。CH1 は 1 相目のまま |
| Measure | CH1 に対する CH2 の Phase (位相差) と、CH1・CH2 の振幅 (Amplitude) |

1 回目は 2 相目が 120° 遅れ、2 回目は 3 相目が 120° 進む。振幅はどれも 1 V のままだ。

```scope
title: 図3 1 回目 — 2 相目 (CH2) は 1 相目 (CH1) より 120° 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V phase -120deg, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/01-three-phase-source-1.svg)

```scope
title: 図4 2 回目 — 3 相目 (CH2) は 1 相目 (CH1) より 120° 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V phase 120deg, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/01-three-phase-source-2.svg)

### オシロスコープと発振器

1− と 2− は GND のレールなので、測り方は GND 基準のままでよい。端子の読み替えは
[回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md) と
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md)。
違うのは、発振器に **2 ch で、ch どうしの位相を決められる機種** が要ることだ。

| AD | 汎用の計器 |
| --- | --- |
| W1 / W2 | 2 ch のファンクションジェネレータ (FG) の CH1 / CH2。どちらも Sine、1 kHz、**2 Vpp** (AD の Amplitude 1 V は山の高さで、FG の多くは Vpp で決める)、出力は High-Z |
| W2 の Phase −120° | FG の CH2 の Phase。符号の約束は機種で違うので、1 回目の Measure で CH2 が −120° (遅れ) と出るほうに決める |
| V+ / V− | 2 出力の安定化電源で ±5 V。電流制限は各 10 mA (TL071 の消費電流 約 1.4 mA と出力の 0.1 mA に余裕を見た値) |
| 1+ / 2+ | CH1・CH2 のプローブの先端 (1 回目は 17 列と 25 列、2 回目は CH2 を U1 の 6 番へ)。グランドクリップは 2 本とも GND のレール |

- 2 ch の FG でも、2 つの ch の周波数を別々に決める設定のままだと、位相を決めた
  つもりでもずれることがある。周波数を結合する設定 (Coupling・Track など) にするか、
  同じ周波数にしたあと「位相を揃える」(Align Phase・同相化) を実行する
- **1 ch の FG を 2 台並べても 120° は保てない。** 内部の時計が別なので周波数が
  わずかに違い、位相差が流れていく。10 MHz の基準クロックを 1 台からもう 1 台へ
  渡せる機種どうしなら使える
- 1 ch の FG しか無いなら、2 相目を OP アンプの**全域通過 (オールパス) 回路**で作る。
  FG の出力を R = 27 kΩ と C = 10 nF の RC で遅らせて + 入力へ、− 入力は 10 kΩ の
  入力抵抗と 10 kΩ の帰還抵抗。振幅はそのままで、位相は −2 arctan(ωRC) ≒ −119°
  (1 kHz での計算値)。周波数を変えると位相も変わるので 1 kHz 専用。OP アンプを
  もう 1 回路 (TL072 など) 使う
- FG の出力の 50 Ω は、R1・R2 (10 kΩ) の負荷では振幅を 0.5 % 下げるだけで無視できる

## 見るべき値

計算値。オペアンプは理想 (仮想短絡) として計算している。

| 測る所 | 1 回目 (CH1=1 相目, CH2=2 相目) | 2 回目 (CH1=1 相目, CH2=3 相目) |
| --- | --- | --- |
| CH1 の振幅 | 1.00 V | 1.00 V |
| CH2 の振幅 | 1.00 V | 1.00 V |
| CH1 に対する CH2 の位相 | −120° | +120° |

分かること:

- **3 相目も 1・2 相目と同じ振幅 1.00 V になる。** −(v₁+v₂) を計算すると、
  自動的に「同じ振幅・120° 進み」の正弦波が出てくる
- 3 つの位相差はどの組も 120°(絶対値)。1 相目を基準にすると 2 相目は −120°、
  3 相目は +120°(= −240°) で、これが**相順**(4-9 で扱う)を決める
- オシロの 2 ch では 3 つを同時に見られないので、上の表は 2 回に分けて測っている。
  **3 つを同時に見るには、AD3 を 2 台使う** (次の節)。1 台のままなら、3-19 のリサジュー図形の
  要領で、1 相目と 3 相目を X-Y 表示にしてもよい

## AD3 を 2 台使う — 3 相を同時に見る

Analog Discovery 3 (AD3) 1 台のオシロスコープは 2 ch なので、3 相を同時には見られない。
**AD3 を 2 台使うと 4 ch になり、3 つの相電圧と、位相を読むための基準を 1 画面群に並べられる。**
三相の電源は上の回路のまま (最大 1 V の低い電圧。商用電源には触れない、0-1) で、増えるのは測る側の
AD3 だけだ。

| 台 | 役 | CH1 (1+) | CH2 (2+) |
| --- | --- | --- | --- |
| AD-A | 電源 (W1・W2・Supplies) と測定 | 1 相目 (W1) | 2 相目 (W2) |
| AD-B | 測定だけ (電源は出さない) | 1 相目 (基準) | 3 相目 (U1 の 6 番) |

AD-B の CH1 に **1 相目をもう一度入れる** のがこの方法の要点。位相は 1 台の中の 2 ch どうしで
読むので、2 台の時計のずれに左右されない。AD-A では「CH1 に対する CH2」が 2 相目、
AD-B では「CH1 (基準の 1 相目) に対する CH2 (3 相目)」が読める。

```breadboard
title: 図5 AD3 を 2 台 (上が AD-A、下が AD-B)
board: half
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  ADA:
    type: device
    at: top
    label: AD-A (Wavegen・電源)
    pins: [V+, GND, 1-, 2-, V-, W1, 1+, W2, 2+, T2]
  ADB:
    type: device
    at: bottom
    label: AD-B (測るだけ)
    pins: [GND, 1-, 2-, 2+, 1+, T2]
wires:
  - ADA.V+ -- +t4 red
  - ADA.GND -- -t6 black
  - ADA.1- -- -t8 black
  - ADA.2- -- -t10 black
  - ADA.V- -- a13 purple
  - ADA.W1 -- c17 yellow [h-10]
  - ADA.1+ -- a17 yellow
  - ADA.W2 -- b25 orange [h-10]
  - ADA.2+ -- a25 orange
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - -t28 -- -b28 black
  - ADB.GND -- -b6 black
  - ADB.1- -- -b8 black
  - ADB.2- -- -b10 black
  - ADB.2+ -- h14 pink
  - e17 -- f17 yellow
  - ADB.1+ -- j17 yellow
  - ADA.T2 -- f29 white
  - ADB.T2 -- j29 white
notes:
  - text small: T2 どうしを 1 本でつなぐ (f29 と j29 は同じ 5 穴の列)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/01-three-phase-source-2.svg)

- 上の AD-A は 図2 と同じ配線。下の AD-B は、1+ を 1 相目 (j17。e17 と f17 を黄の線でつないで
  下の段へ渡す)、2+ を U1 の 6 番の列 (h14、3 相目)、1−・2−・GND を GND のレールにつなぐ
- **2 台の GND は必ず共通にする。** AD3 のオシロの入力は、回路と GND を共有していないと安定して読めない
  (リファレンスマニュアルの注意)。図では上下の − レールを 28 列の黒い線でつないでいる
- AD-B の入力は 1 MΩ ‖ 24 pF (AD3 の仕様)。1 kHz では 24 pF は約 6.6 MΩ に当たり、
  10 kΩ の回路には影響しない
- AD-B に Supplies の配線は要らない (USB から給電される)。2 台とも、それぞれの USB につなぐ

### 2 台を同期する

- AD3 の Trigger I/O (T1・T2) は、初期値では外からの信号を受ける側で、内部の計器 (オシロなど) が作った
  トリガを外へ出すこともできる (Digilent のリファレンスマニュアル)。オシロのトリガ源には外部トリガ
  (T1・T2) を選べる (同じくスペック)
- AD-A の T2 を出力、AD-B の T2 を入力にして、**T2 どうしを 1 本の線でつなぐ** (図の白い線)。
  信号は 3.3 V の論理レベルなので、線は短く、GND を共通にしてあるのが前提
- AD-A のオシロは CH1 の立ち上がり 0 V でトリガし、そのトリガを T2 へ出す。AD-B のオシロは
  トリガ源を外部トリガ (T2) にする。これで 2 台の画面がほぼ同じ瞬間から始まる
- T1 は使わない。T1 は 10 MHz などの基準クロックを 1 台からもう 1 台へ渡す入り口
  (仕様書に「装置の同期のための基準クロックの入出力」とある) と兼ねているためで、
  2 台の時計を完全にそろえたいときにだけ使う
- 2 台の Trigger I/O の詳しい使い方 (T2 を使った 2 台同期の手順) は、AD3 の本の 0-8
  「トリガ入出力 (T1 / T2) で 2 台を同期する」で扱う
- WaveForms で 2 台を開く操作 (1 つの画面で 2 台を扱えるか、WaveForms を 2 つ起動して
  それぞれで別の機を選ぶか) と、トリガ出力・外部トリガ入力の設定の項目名は、手元のマニュアルでは
  読み取れなかったので **未確認**。実際の画面で確かめること。上の「基準を 2 台目にも入れる」方法は、
  同期がずれても位相を読めるので、確かめる前でも使える

### 2 台で見る画面

3 つの相を、それぞれの画面に基準つきで並べる。カーソルは 1 相目の立ち上がり (0°) と、
その相が 1 相目に遅れる時間に合わせる (1 kHz は周期 1 ms なので、120° = 333.3 µs、240° = 666.7 µs)。

```scope
title: 図6 AD-A の画面 — CH2 (2 相目) は CH1 (1 相目) より 120° 遅れる
time: 200us/div
trigger: ch1 rising 0V
cursors: [0, 333.3us]
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V phase -120deg, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/01-three-phase-source-3.svg)

```scope
title: 図7 AD-B の画面 — CH1 は 1 相目 (基準)、CH2 は 3 相目 (120° 進み = 240° 遅れ)
time: 200us/div
trigger: ch1 rising 0V
cursors: [0, 666.7us]
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1V phase 120deg, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/01-three-phase-source-4.svg)

計算値 (どちらも 1 kHz)。

| 画面 | 測る所 | 読み | 意味 |
| --- | --- | --- | --- |
| AD-A | CH1 の振幅、CH2 の振幅 | 1.00 V、1.00 V | 1・2 相目 |
| AD-A | CH1 に対する CH2 の位相 | −120° | 2 相目は 120° 遅れ |
| AD-A | カーソル ΔX (0 と 333.3 µs) | 333.3 µs = 120° | 遅れの時間 |
| AD-B | CH1 (基準の 1 相目) の振幅、CH2 (3 相目) の振幅 | 1.00 V、1.00 V | 1・3 相目 |
| AD-B | CH1 に対する CH2 の位相 | +120° | 3 相目は 120° 進み |
| AD-B | カーソル ΔX (0 と 666.7 µs) | 666.7 µs = 240° | 3 相目を遅れで数えたとき |

- 3 つの相の時間の差は、1 相目を 0° として 0°・120°・240° (遅れで数える)。**どの 2 つの間も 120° になる**
- 実測では 2 台の T2 の遅れ (数 ns から 20 ns 程度、仕様書の「トリガの分解能」8〜20 ns) だけ
  画面の始まりがずれることがある。1 kHz の 10 ns は 0.004° で、読みには出ない (計算値)。実機は 未確認
- 画面の図は理想の波形から作った計算値で、実測ではない

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Supplies・Scope の節)。
