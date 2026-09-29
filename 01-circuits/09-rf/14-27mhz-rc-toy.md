---
book: circuits
chapter: 9
id: 9-14
title: 27MHz の送受信 (トイラジコン)
tier: 200
source: 自作
era: 古
board: PF
---

# 9-14 27MHz の送受信 (トイラジコン)

昔のおもちゃのラジコン (トイラジコン) は、27MHz 帯の電波を**出す・止める**だけで
「進め」を伝えていた。これを OOK (On-Off Keying、断続の変調) という。送信機は
水晶で周波数を決めた 1 石の発振器、受信機は同じ周波数に合わせた同調回路と
検波だけ。ここでは 27.145MHz (トイラジコンでよく使われたチャンネル) で両方を組み、
W1 の方形波で送信機を断続させて、受信機の LED が同じ調子で点滅するのを見る。

> [!WARNING]
> 日本の電波法では、免許の要らない**微弱無線局**の電界強度に上限がある
> (電波法施行規則第 6 条)。322MHz 以下の一般の上限は**距離 3m で 500µV/m 以下**。
> ラジコン用には 26.9〜27.2MHz などに別枠があり、**距離 500m で 200µV/m 以下**・
> 用途は無線操縦に限られる。この題の送信機は発振器 1 段だけで、アンテナは
> **20cm の線**、結合は 2.2pF に留めてある。**増幅段を足したりアンテナを
> 伸ばしたりしない**。実験は机の上 (送受信のアンテナの間 10cm ほど) で行い、
> 電波を出したまま放置しない。tinySA につなぐときはアンテナを外す。

## 回路図

### 送信機

```circuit
title: 図1 送信機 (水晶で決める 27.145MHz の発振器、W1 で断続)
parts:
  W1: square c3 e3 l=$\mathrm{W1}$
  GW1: ground e3
  M2: voltmeter c5 e5 l=$\mathrm{CH2}$
  GM2: ground e5
  Rb1: resistor c9 f9 22k
  X1: crystal f7 i7 27.145M
  GX1: ground i7
  Rb2: resistor f9 i9 10k
  GRb2: ground i9
  Q1: npn f12
  VCC: vcc a12 5V
  L1: inductor a12 d12 1u
  CT: capacitor-var a14 d14 l=$\mathrm{C_T}$
  C1: capacitor d16 g16 22p
  C2: capacitor g18 j18 100p
  GC2: ground j18
  Re: resistor h12 j12 1k
  GRe: ground j12
  Cant: capacitor d17 d19 2.2p
  ANT: antenna d20
  Cb: capacitor a22 c22 0.1u
  GCb: ground c22
wires:
  - c3 -- c9
  - f7 -- f9
  - f9 -- Q1.B
  - d12 -- Q1.C
  - Q1.E -- g12
  - g12 -- h12
  - g12 -- g16
  - a12 -- a22
  - d12 -- d17
  - g16 -- g18
  - d19 -- d20
notes:
  - text k15 blue: "L1とCTのタンク (約27MHz)"
  - text k7 blue: "水晶 (直列共振で Bを接地)"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/14-27mhz-rc-toy-1.svg)

`+5V` は Analog Discovery の V+ (Supplies で 5V)。W1 は 50Hz・0〜5V の方形波で、
**Rb1 の上端 (バイアスの電源) を入れたり切ったりする**。W1 が 0V の間は Q1 に
ベース電流が流れず発振しない。W1 の代わりに、押しボタンで +5V を Rb1 へ
つないでもよい (これが本物のトイラジコンの「進め」ボタン)。

- **動作点** (W1 = 5V のとき): 分圧の開放電圧 5V×10k/32k **≈ 1.56V**、
  テブナン抵抗 6.9kΩ。hFE = 200・V<sub>BE</sub> = 0.65V で
  I<sub>E</sub> ≈ (1.56−0.65)/(1k+6.9k/201) **≈ 0.88mA** (計算値)。
  W1 が流す電流は分圧の 5V/32kΩ **≈ 0.16mA** で、W1 の上限 (約 10mA) より十分小さい
- **帰還**: 9-4 と同じコルピッツ。C1 (22pF、コレクタ−エミッタ) と C2 (100pF、エミッタ−GND)
  の分圧でエミッタへ戻す。直列合成は 22p×100p/122p **≈ 18.0pF**
- **水晶**: X1 はベースと GND の間。**直列共振の 27.145MHz でだけ**ほぼ短絡になり、
  ベースを高周波で接地する (ベース接地の増幅になって帰還が利く)。それ以外の
  周波数ではベースが浮いて利得が出ないので、**周波数は水晶が決める**
- **タンク**: L1 (1µH) と C<sub>T</sub> (セラミックトリマ 5〜30pF) に C1・C2 の 18.0pF が並ぶ。
  合計 23〜48pF で、タンクの共振は **23.0〜33.2MHz** (計算値)。27.145MHz に合う
  C<sub>T</sub> は 1/((2π×27.145MHz)²×1µH) − 18.0pF **≈ 16.3pF**。27MHz 帯の水晶は
  3 倍オーバートーン (基本波は約 9MHz) の品が多いが、タンクを 27MHz に合わせて
  おけば 9MHz では利得が足りず、27.145MHz だけで発振する
- **出力**: コレクタから Cant (2.2pF) でアンテナへ。27.145MHz での Cant の
  リアクタンスは 1/(2π×27.145MHz×2.2pF) **≈ 2.67kΩ** と大きく、発振器を軽く
  しか引っ張らない (微弱無線の条件そのもの)
- Cb (0.1µF) は +5V のパスコン。L1 の上端を高周波で GND に落とす

### 受信機

```circuit
title: 図2 受信機 (同調・検波・LM358 のコンパレータで LED)
parts:
  ANT: antenna c2
  Cc: capacitor c4 c6 10p
  L2: inductor c8 f8 1u
  GL2: ground f8
  CT2: capacitor-var c10 f10 l=$\mathrm{C_{T2}}$
  GCT2: ground f10
  C3: capacitor c12 f12 22p
  GC3: ground f12
  D1: diode c14 c16 1SS108
  Cd: capacitor c17 f17 1n
  GCd: ground f17
  Rd: resistor c19 f19 100k
  GRd: ground f19
  M1: voltmeter c21 f21 l=$\mathrm{CH1}$
  GM1: ground f21
  U1: opamp d25 +up
  VCC: vcc g20 5V
  Rt1: resistor g20 i20 100k
  Rt2: resistor i22 k22 1k
  GRt2: ground k22
  Rled: resistor d28 d30 470
  LED: led d32 g32 l=$\mathrm{LED}$
  GLED: ground g32
wires:
  - c2 -- c4
  - c6 -- c12
  - c12 -- c14
  - c16 -- c21
  - c21 -| U1.+
  - i20 -- i22
  - i22 -- i24
  - i24 -| U1.-
  - U1.out -- d28
  - d30 -- d32
notes:
  - text b26 blue: "LM358 PIN 5:+ PIN 6:- PIN 7:出力"
  - text k26 blue: "PIN 8:+5V PIN 4:GND"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/14-27mhz-rc-toy-2.svg)

- **同調**: L2 (1µH) と C3 (22pF)・CT2 (5〜30pF) の並列で 27〜52pF、
  **22.1〜30.6MHz** (計算値) を回せる。27.145MHz には CT2 ≈ 34.4pF − 22pF **≈ 12.4pF**。
  共振のとき L2 のリアクタンスは 2π×27.145MHz×1µH **≈ 171Ω**、Q が 50 なら
  タンクは約 8.5kΩ の抵抗に見える。アンテナは Cc (10pF) で弱く結合する
- **検波**: D1 (1SS108、ショットキー) で包絡線を取り出す。Cd (1nF) と Rd (100kΩ)
  の時定数は **100µs** — 27MHz の周期 (37ns) よりずっと長く、断続の周期 (20ms)
  よりずっと短いので、**電波がある間だけ直流が立ち、止まると 0.1ms ほどで落ちる**
- **判定**: LM358 の 2 回路目をコンパレータに使う。PIN 6 (−) には 5V を Rt1・Rt2
  (100kΩ・1kΩ) で分けた **49.5mV** (計算値) を入れる。検波の電圧がこれを超えると
  PIN 7 が H (5V 電源の LM358 で約 3.5V) になり、LED が点く。LED の電流は
  (3.5−2.0)/470 **≈ 3.2mA** (目安)
- LM358 は入力の同相範囲が GND を含むので、数十 mV の比較ができる (単電源の OP アンプを選ぶ理由)
- 図の `opamp` 記号は LM358 (DIP8) の 2 回路目 (PIN 5〜7)。電源は PIN 8 = +5V、PIN 4 = GND。
  使わない 1 回路目は入力 PIN 2・PIN 3 を GND へつなぐ (図4)

## 実体配線図

**perfboard にした理由**: この題の回路は **27.145MHz** で、ブレッドボードの
上限 (板の上に組む回路は 3MHz 以下) を超える。理由は 2 つ。

- **浮遊容量**: ブレッドボードは隣り合う列の間に数 pF の容量がある。
  CT・CT2 のトリマは 5〜30pF、Cant は 2.2pF、Cc は 10pF と、数 pF が
  そのまま効く大きさなので、板の容量で同調が動く。たとえば送信機のタンクは
  合計 34.3pF で 27.145MHz に合う (計算値)。ここへ 3pF が足されるだけで、
  共振は約 **1.1MHz** (26.0MHz へ) 下がる
- **足と配線のインダクタンス**: ブレッドボードの穴と長い足・引き回しは、
  1 本で数十 nH になる (目安)。30nH のリアクタンスは 27MHz で
  2π×27.145MHz×30nH **≈ 5.1Ω**。C2 (100pF) のリアクタンス **≈ 58.6Ω**
  の約 1 割で、小さい容量と直列に入ると効きが変わる

ユニバーサル基板 (perfboard) なら、部品の足を短く切って穴に半田付けし、
GND の筋を部品のすぐそばに通せるので、浮遊容量と足の長さを小さく抑えられる。
使える範囲は 150MHz 以下・12V 以下・電流も 1 本の線あたり数 mA なので、範囲に収まる。
板は 5×7cm (18×24 穴、1.6mm の FR-4・両面スルーホール) の 1 枚目で、
送信機・受信機とも部品と線の外周に 1 穴の余白を残して収まる。
送信機と受信機は別々の板に組み、どちらも AD の V+ と GND (Supplies の 5V) から給電する。
図は部品面から見た図で、部品の足はその穴を通して裏の半田面で半田付けする。

```perfboard
board:
  size: 5x7cm
  h: 1.6mm
  material: FR-4
title: 図3 送信機 (perfboard 5×7cm、部品面)
parts:
  AD:
    type: device
    at: -c2
    label: Analog Discovery
    pins: GND 2- W1 2+ V+
  ANT:
    type: device
    at: -c17
    label: アンテナ
    pins: "1"
  Rb1: resistor d4 i4 22k
  X1: crystal/hc49 i5 o5 27.145M
  Rb2: resistor i8 o8 10k
  Q1: transistor i11 j11 k11 2SC1815
  L1: inductor/axial b13 f13 1u
  CT: capacitor/ceramic b15 f15 5-30p
  C1: capacitor/ceramic f16 k16 22p
  Cant: capacitor/ceramic b17 f17 2.2p
  Re: resistor k13 o13 1k
  C2: capacitor/ceramic k15 o15 100p
  Cb: capacitor/ceramic b7 g7 0.1u
wires:
  - AD.V+ -- b6 red
  - b6 -- b7 red
  - b7 -- b13 red
  - b13 -- b15 red
  - AD.GND -- o2 black
  - AD.2- -- o3 black
  - o2 -- o3 black
  - o3 -- o5 black
  - o5 -- o7 black
  - o7 -- o8 black
  - o8 -- o13 black
  - o13 -- o15 black
  - AD.W1 -- d4 yellow
  - AD.2+ -- d5 blue
  - d4 -- d5 blue
  - i4 -- i5 green
  - i5 -- i8 green
  - i8 -- i11 green
  - f13 -- j13 orange
  - j13 -- j11 orange
  - f13 -- f15 orange
  - f15 -- f16 orange
  - f16 -- f17 orange
  - k11 -- k13 white
  - k13 -- k15 white
  - k15 -- k16 white
  - g7 -- o7 black
  - b17 -- ANT.1 yellow
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/perfboard/14-27mhz-rc-toy-1.svg)

- 上の b 行の赤い筋が +5V (AD の V+)、下の o 行の黒い筋が GND。
  AD の GND と CH2 の 2− は 2・3 列を縦に降りて、GND の筋の左端 (o2・o3) へ
- **Q1 (2SC1815) は 11 列に縦**、平らな面を右にして上から B (i11)・C (j11)・E (k11)
- **B の筋 (緑、i 行)**: Rb1 の下端 (i4)・X1 の上端 (i5)・Rb2 の上端 (i8)・Q1 の B。
  X1 と Rb2 の下端は、足のまま o 行の GND の筋へ
- **キー (W1)**: 黄の線を Rb1 の上端 d4 へ。CH2 の 2+ (青) は d5 に挿して d4 と短い線で結ぶ
- **コレクタの筋 (橙、f 行)**: L1 (13 列)・CT (15 列) の下端と C1 (16 列)・Cant (17 列) の上端を集め、
  13 列を j13 まで下ろして j11 (Q1 の C) へ。L1 と CT の上端は b 行の +5V の筋
- **エミッタの筋 (白、k 行)**: Q1 の E (k11) から Re (13 列)・C2 (15 列) の上端と C1 の下端 (k16) へ。
  Re と C2 の下端は o 行の GND の筋
- Cb (0.1µF) は 7 列で b7 と g7 の間、g7 から o7 まで線で GND の筋へ (B の筋を跨ぐ)。CT は 30pF のセラミックトリマ (図の値は最大値)
- アンテナの線 (20cm) は Cant の上端 b17 へ

```perfboard
board:
  size: 5x7cm
  h: 1.6mm
  material: FR-4
title: 図4 受信機 (perfboard 5×7cm、部品面)
points:
  NC_PIN1: m10
parts:
  AD:
    type: device
    at: -c17
    label: Analog Discovery
    pins: V+ GND
  ANT:
    type: device
    at: -c3
    label: アンテナ
    pins: "1"
  Cc: capacitor/ceramic b3 f3 10p
  L2: inductor/axial f5 k5 1u
  CT2: capacitor/ceramic f7 k7 5-30p
  C3: capacitor/ceramic f9 k9 22p
  D1: schottky n4 r4 1SS108
  Cd: capacitor/ceramic r6 w6 1n
  Rd: resistor r8 w8 100k
  U1: dip8 m13 r90 LM358
  Rt1: resistor k16 o16 100k
  Rt2: resistor q16 w16 1k
  Rled: resistor p14 t14 470
  LED: led u14 w14 red
wires:
  - AD.V+ -- k17 red
  - k17 -- k16 red
  - k16 -- k13 red
  - k13 -- m13 red
  - AD.GND -- w18 black
  - k5 -- k7 black
  - k7 -- k9 black
  - k5 -- k2 black
  - k2 -- s2 black
  - s2 -- w2 black
  - w2 -- w6 black
  - w6 -- w8 black
  - w8 -- w10 black
  - w10 -- w14 black
  - w14 -- w16 black
  - w16 -- w18 black
  - n10 -- o10 black
  - o10 -- p10 black
  - p10 -- w10 black
  - ANT.1 -- b3 yellow
  - f3 -- f4 yellow
  - f4 -- f5 yellow
  - f5 -- f7 yellow
  - f7 -- f9 yellow
  - f4 -- n4 yellow
  - r4 -- r6 green
  - r6 -- r8 green
  - r8 -- r13 green
  - r13 -- p13 green
  - o13 -- o16 orange
  - o16 -- p16 orange
  - p16 -- q16 orange
  - n13 -- n14 white
  - n14 -- p14 white
  - t14 -- u14 white
notes:
  - mark r7 blue
  - text q7 white: CH1 1+
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/perfboard/14-27mhz-rc-toy-2.svg)

- b〜f 行は同調。アンテナ (b3) → Cc (3 列) → f 行の**同調の筋 (黄)** に L2 (5 列)・CT2 (7 列)・C3 (9 列) の上端。
  3 つの下端は k 行の GND の筋へ (CT2 は 30pF のセラミックトリマ、図の値は最大値)
- 同調の筋から D1 (1SS108) の陽極 (n4) へ 4 列を降ろす (k 行の GND の筋を跨ぐ)。
  陰極は帯の側 (r4)
- **r 行 (緑) が検波の出力**: D1 の陰極 (r4)・Cd (6 列)・Rd (8 列) の上端をつなぎ、
  r13 から p13 (LM358 の **PIN 5**) へ上げる (10 列の GND の線を跨ぐ)。
  CH1 の 1+ は青丸の r7 に当てる (D1 の陰極 r4 に近い穴でよい)。1− は w 行の GND の筋の穴
- U1 (LM358、DIP8) は **90 度回して**立て、右の列が上から PIN 8・7・6・5、
  左の列が上から PIN 1・2・3・4。右下の PIN 5 (IN2+) に検波の出力が入る。足の名前は胴に刷ってある
- **PIN 6 (o13)** に Rt1 (16 列、+5V の筋 k 行から) と Rt2 (16 列、GND の筋へ)。
  PIN 6 から橙の線を o16 へ (14 列の白い線を跨ぐ)。ここが 49.5mV のしきい値
- PIN 7 (n13) から白の線を降ろして Rled (14 列) → LED (14 列)。LED の陰極 (w14) は GND の筋
- PIN 8 (m13) は k13 の +5V の筋へ。PIN 4 (p10) は 10 列を降ろして GND の筋へ。
  使わない 1 回路目の入力 PIN 2・PIN 3 (n10・o10) も PIN 4 と線で結んで GND へ。PIN 1 (OUT1) は何もつながない
- AD の V+ は 17 列で k17 へ、GND は 18 列を降ろして w18 へ

`perfboard-fence check` のネットリストは、回路図 (図1・図2) と同じつながりになる。
違いは電圧計だけで、図3 の CH2 は AD の 2+・2− の線で描き、図4 の CH1 は
1+・1− を描かずに (上のとおり r7 と GND の筋に) 当てる。

## 計器の設定

### Analog Discovery (断続と受信の波形)

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5V (送信機と受信機の両方の +5V) |
| Wavegen W1 | Square・50Hz・Amplitude 2.5V・Offset 2.5V (0〜5V) |
| Scope CH2 | W1 (送信機のキー)。2V/div |
| Scope CH1 | 受信機の検波の出力 (Rd の上端)。100mV/div |
| Scope 時間軸 | 5ms/div、トリガ CH2 の立ち上がり 2.5V |

送受信のアンテナ (どちらも 20cm の線) を平行に 10cm 離して置く。

### tinySA Ultra (送信機の搬送波)

W1 を DC 5V (Offset 5V・Amplitude 0V) にして送信機を発振させたままにし、
**アンテナを外して** Cant の出口を tinySA の RF 入力 (50Ω) へ短い同軸でつなぐ。

| 設定 | 値 |
| --- | --- |
| 中心 / スパン | 27.145MHz / 1MHz |
| RBW | 10kHz |
| REF | −10dBm |
| マーカー | peak |

## 計器の画面

```spectrum
title: 図5 送信機の搬送波 (Cant の出口を 50Ω で受ける)
device: tinysa-ultra
center: 27.145MHz
span: 1MHz
rbw: 10kHz
points: 450
ref: -10dBm
signal: sine 27.145MHz -18.5dBm
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/14-27mhz-rc-toy.svg)

コレクタの振幅を 2V peak (目安) とすると、Cant (2.67kΩ) と 50Ω の分圧で 50Ω の両端は
2V×50/2.67k **≈ 37.5mV peak**、電力は (37.5mV)²/(2×50Ω) **≈ 14µW = −18.5dBm**
(計算値)。水晶の発振なので線は細く、C<sub>T</sub> を回しても**周波数は動かず高さだけ変わる**
(タンクが 27.145MHz に合った所で一番高い)。

```scope
title: 図6 キー (CH2) と受信機の検波出力 (CH1)
time: 5ms/div
trigger: ch2 rising 2.5V
ch1: {wave: square 50Hz 0.15V offset 0.15V | rc 0.1ms, range: 100mV/div, position: -3div}
ch2: {wave: square 50Hz 2.5V offset 2.5V, range: 2V/div, position: -2div}
measure: [vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/14-27mhz-rc-toy.svg)

CH1 は CH2 と同じ 50Hz・デューティ 50% で上がり下がりする。高さの 0.3V は
アンテナの間 10cm での目安で、**距離を離すとすぐ小さくなる** (近くの電界は距離の
2〜3 乗で弱まる)。0.3V は判定の 49.5mV の約 6 倍あるので LED は確実に点滅する。

## 見るべき値

計算値 (「目安」と書いたものは距離や部品のばらつきで変わる)。

| 測る所 | 期待する値 |
| --- | --- |
| Q1 のエミッタ電流 (W1 = 5V) | 約0.88mA (Re の両端 約0.88V) |
| tinySA のピーク | 27.145MHz、約 −18.5dBm (目安) |
| C<sub>T</sub> を回す | 周波数は動かず、約 16.3pF で高さが最大 |
| 検波の出力 CH1 | 50Hz・デューティ 50%、最大 約0.3V (目安、10cm)・最小 0V |
| LM358 PIN 6 の電圧 | 49.5mV |
| LED | W1 の 50Hz で点滅 (目では速いので W1 を 2Hz にすると分かる) |
| 受信機の CT2 を回す | 約 12.4pF で CH1 が最大 |
| アンテナの間を 1m にする | CH1 がほぼ 0 になり LED が点かない (微弱の範囲の目安) |

## 部品

| 部品 | 値・型番 | メモ |
| --- | --- | --- |
| Q1 | 2SC1815 | f<sub>T</sub> 80MHz 以上 (typ)。27MHz なら足りる |
| X1 | 水晶振動子 27.145MHz (HC-49/U) | トイラジコン・CB 用。3 倍オーバートーン品でよい |
| L1, L2 | 1µH (アキシャルのマイクロインダクタ) | |
| C<sub>T</sub>, C<sub>T2</sub> | セラミックトリマ 5〜30pF | |
| C1 / C2 / C3 / Cant / Cc | 22pF / 100pF / 22pF / 2.2pF / 10pF | セラミック (C0G) |
| Cd / Cb | 1nF / 0.1µF | |
| Rb1 / Rb2 / Re | 22kΩ / 10kΩ / 1kΩ | |
| D1 | 1SS108 (ショットキー) | 1N60 (ゲルマニウム) でも可 |
| Rd / Rt1 / Rt2 / Rled | 100kΩ / 100kΩ / 1kΩ / 470Ω | |
| U1 | LM358 | 2 回路目だけ使う。1 回路目の入力は GND へ |
| LED | 赤 LED (V<sub>F</sub> 約 2V) | |
| アンテナ | 線 20cm × 2 本 | 伸ばさない |

## 出典

自作。微弱無線局の電界強度の上限 (一般: 322MHz 以下で距離 3m・500µV/m、
ラジコン用: 26.9〜27.2MHz などで距離 500m・200µV/m) は電波法施行規則第 6 条と
[総務省 電波利用ホームページ「微弱無線局の規定」](https://www.tele.soumu.go.jp/j/ref/material/rule/) による。
LM358 の足の並びは TI のデータシート (LM358、DIP8: PIN 1 = OUT1、PIN 2 = IN1−、
PIN 3 = IN1+、PIN 4 = GND、PIN 5 = IN2+、PIN 6 = IN2−、PIN 7 = OUT2、PIN 8 = V+) による。
