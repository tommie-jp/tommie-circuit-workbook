---
book: circuits
chapter: 9
id: 9-14
title: 27MHz の送受信 (トイラジコン)
tier: 200
source: 自作
era: 古
board: [CB, PF]
---

# 9-14 27MHz の送受信 (トイラジコン)

昔のおもちゃのラジコン (トイラジコン) は、27MHz 帯の電波を**出す・止める**だけで
「進め」を伝えていた。これを OOK (On-Off Keying、断続の変調) という。送信機は
水晶で周波数を決めた 1 石の発振器、受信機は同じ周波数に合わせた同調回路と
検波だけ。ここでは 27.145MHz (トイラジコンでよく使われたチャンネル) で両方を組み、
W1 の方形波で送信機を断続させて、受信機の LED が同じ調子で点滅するのを見る。
W1 を 50 Hz にすると LED は 1 秒に 50 回点滅するが、目には連続した光 (やや暗め) に見え、ちらつきはほぼ分からない。
点滅を目で見るときは W1 を 2 Hz に下げる。50 Hz のままの断続は、オシロの波形 (図7) で確かめる。

この題の流れは次のとおり。

- 回路図は送信機 (図1) と受信機 (図2)。送信機は水晶で周波数を決める発振器、受信機は同調・検波・コンパレータ
- 27MHz はブレッドボードの範囲を超えるので、送信機 (図3) と受信機の高周波部 (図4) は銅張り基板、受信機の低周波部 (図5) は perfboard に組む。基板を選んだ理由は「実体配線図」の頭に書いた
- tinySA で送信機の搬送波 (図6)、オシロで断続のキーと受信機の検波出力 (図7) を見る

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
  W1: square 3,3 3,5 l=$\mathrm{W1}$
  GW1: ground 3,5
  M2: voltmeter 5,3 5,5 l=$\mathrm{CH2}$
  GM2: ground 5,5
  Rb1: resistor 9,3 9,6 22k
  X1: crystal 7,6 7,9 27.145M
  GX1: ground 7,9
  Rb2: resistor 9,6 9,9 10k
  GRb2: ground 9,9
  Q1: npn 12,6
  VCC: vcc 12,1 5V
  L1: inductor 12,1 12,4 1u
  CT: capacitor-var 14,1 14,4 l=$\mathrm{C_T}$
  C1: capacitor 16,4 16,7 22p
  C2: capacitor 18,7 18,10 100p
  GC2: ground 18,10
  Re: resistor 12,8 12,10 1k
  GRe: ground 12,10
  Cant: capacitor 17,4 19,4 2.2p
  ANT: antenna 20,4
  Cb: capacitor 22,1 22,3 0.1u
  GCb: ground 22,3
wires:
  - 3,3 -- 9,3
  - 7,6 -- 9,6
  - 9,6 -- Q1.B
  - 12,4 -- Q1.C
  - Q1.E -- 12,7
  - 12,7 -- 12,8
  - 12,7 -- 16,7
  - 12,1 -- 22,1
  - 12,4 -- 17,4
  - 16,7 -- 18,7
  - 19,4 -- 20,4
notes:
  - text 15,11 blue: "L1とCTのタンク (約27MHz)"
  - text 7,11 blue: "水晶 (直列共振で Bを接地)"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/14-27mhz-rc-toy-1.svg)

`+5V` は Analog Discovery の V+ (Supplies で 5V)。W1 は 50Hz・0〜5V の方形波で、
**Rb1 の上端 (バイアスの電源) を入れたり切ったりする**。W1 が 0V の間は Q1 に
ベース電流が流れず発振しない。W1 の代わりに、押しボタンで +5V を Rb1 へ
つないでもよい (これが本物のトイラジコンの「進め」ボタン)。

- **動作点** (W1 = 5V のとき): 分圧の開放電圧 5V×10k/32k **≈ 1.56V**、
  テブナン抵抗 6.9kΩ。hFE = 200・V<sub>BE</sub> = 0.65V で
  I<sub>E</sub> ≈ (1.56−0.65)/(1k+6.9k/201) **≈ 0.88mA** (計算値)。
  W1 が流す電流は分圧の 5V/32kΩ **≈ 0.16mA** で、W1 が歪みなく出せる電流 (AD3 で 30mA) より十分小さい
- **帰還**: 9-4 と同じコルピッツ。C1 (22pF、コレクタ−エミッタ) と C2 (100pF、エミッタ−GND)
  の分圧でエミッタへ戻す。直列合成は 22p×100p/122p **≈ 18.0pF**
- **水晶**: X1 はベース (B) と GND の間。**直列共振の 27.145MHz でだけ**ほぼ短絡になり、
  ベースを高周波で接地する (ベース接地の増幅になって帰還が利く)。それ以外の
  周波数ではベースが浮いて利得が出ないので、**周波数は水晶が決める**
- **タンク**: L1 (1µH) と C<sub>T</sub> (セラミックトリマ 5〜30pF) に C1・C2 の 18.0pF が並ぶ。
  合計 23〜48pF で、タンクの共振は **23.0〜33.2MHz** (計算値)。27.145MHz に合う
  C<sub>T</sub> は 1/((2π×27.145MHz)²×1µH) − 18.0pF **≈ 16.3pF** (トランジスタの容量や島の浮遊容量を無視した値。
  LTspice では並ぶ容量のぶん小さくなり、10pF 前後で振幅が最大だった)。27MHz 帯の水晶は
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
  ANT: antenna 2,3
  Cc: capacitor 4,3 6,3 10p
  L2: inductor 8,3 8,6 1u
  GL2: ground 8,6
  CT2: capacitor-var 10,3 10,6 l=$\mathrm{C_{T2}}$
  GCT2: ground 10,6
  C3: capacitor 12,3 12,6 22p
  GC3: ground 12,6
  D1: diode 14,3 16,3 1SS108
  Cd: capacitor 17,3 17,6 1n
  GCd: ground 17,6
  Rd: resistor 19,3 19,6 100k
  GRd: ground 19,6
  M1: voltmeter 21,3 21,6 l=$\mathrm{CH1}$
  GM1: ground 21,6
  U1: opamp 25,4 +up
  VCC: vcc 20,7 5V
  Rt1: resistor 20,7 20,9 100k
  Rt2: resistor 22,9 22,11 1k
  GRt2: ground 22,11
  Rled: resistor 28,4 30,4 470
  LED: led 32,4 32,7 l=$\mathrm{LED}$
  GLED: ground 32,7
wires:
  - 2,3 -- 4,3
  - 6,3 -- 12,3
  - 12,3 -- 14,3
  - 16,3 -- 21,3
  - 21,3 -| U1.+
  - 20,9 -- 22,9
  - 22,9 -- 24,9
  - 24,9 -| U1.-
  - U1.out -- 28,4
  - 30,4 -- 32,4
notes:
  - text 26,2 blue: "LM358 PIN 5:+ PIN 6:- PIN 7:出力"
  - text 26,11 blue: "PIN 8:+5V PIN 4:GND"
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
  使わない 1 回路目は入力 PIN 2・PIN 3 を GND へつなぐ (図5)

## 実体配線図

**銅張り基板にした理由**: この題の回路は **27.145MHz** で、ブレッドボードの上限
(基板の上に組む回路は 3MHz 以下) も perfboard の目安 (10MHz 以下) も超える。
送信機のタンクと受信機の同調回路は、容量が 5〜50pF ほどと小さく、穴どうしの容量、
差し直すたびに変わる接触、穴ピッチに合わせて長くなるピンが、同調の位置を動かしてしまう。
そこで、裏を切れ目の無い GND の面にした銅張り基板に、部品を短いピンで島から島へ渡す
Manhattan 方式で組む。島は回路図の節点ごとに 1 つで、GND の節点は島にせず、via で裏の GND の面へ
直に落とす。見積もりは次のとおり (どちらも目安で、実測はしていない)。

- **島の浮遊容量**: 送信機で一番大きい島はコレクタの節点 COL (14×4mm)。裏の GND の面との間の容量は、
  平行板の式 C = ε<sub>0</sub>ε<sub>r</sub>A/h (ε<sub>r</sub> = 4.4、h = 1.6mm、A = 56mm²) で
  **約 1.4pF**。タンクの合計 34.4pF (27.145MHz に合う値) の約 4%、共振は約 2% (0.5MHz) 下がる。
  受信機で一番大きい同調の島 TANK (22×4mm、88mm²) は **約 2.1pF**。合計 34.4pF の約 6%、
  共振は約 3% (0.8MHz) 下がる。どちらもトリマ (C<sub>T</sub>・C<sub>T2</sub>) の 5〜30pF の範囲で追える。
  送信機は水晶が周波数を決めるので、C<sub>T</sub> で高さを合わせるだけでよい
- **ピンのインダクタンス**: 直径 0.5mm のピンは 1mm あたり **0.7nH 前後**。C1 と C2 のピンを合わせて
  10mm 分で約 7nH、27.145MHz では 2π×27.145MHz×7nH **≈ 1.2Ω**。C2 (100pF) の
  リアクタンス **≈ 58.6Ω** の約 2% で、ピンを切り詰めれば効きは小さい。ブレッドボードの穴と
  長いピン・引き回し (1 本で数十 nH、30nH で約 5.1Ω) より一桁小さい
- **なぜ perfboard でないか**: 穴ピッチ (2.54mm) に合わせて部品を渡すので、島から島へ渡す
  今の図よりピンが長くなりやすく、裏の連続した GND の面も無い。10MHz 以下の回路には十分でも、
  27MHz で同調の容量が 30〜50pF の回路には向かない

**範囲の確認**: 電圧 5V、電流は送信機が 1mA 弱・受信機の高周波部は 0 (電源が要らない)、
電力は数 mW (100mW 以下)、周波数 27.145MHz は、銅張り基板の範囲 (10MHz 超〜1GHz) に収まる。
島の幅は最小 4mm (3mm 以上)。島どうしの溝は最小 2mm (0.3mm 以上)。商用電源は使わない。
基板は 5×7cm を横に置いた 70×50mm (標準の基板の先頭で、配置が収まる)。FR-4・1.6mm・両面 1oz で、
表の銅は図の島だけを残して剥がし (または別の銅板の小片を貼って島にする)、**裏の銅は全面を GND** にする。
島は基板の端から 8mm 以上離してある。各図の下の段が裏から見た図で、丸い印は via
(裏の GND へ落とす穴と、その島)。図の値は設計値で、切り出したら島どうしと GND の面の導通を
テスターで確かめる (削り残しの銅で短絡していないか)。

**低周波の部分を perfboard に分けた理由**: 受信機のうち、LM358 のコンパレータと LED の部分
(図5) は、増幅段 (LM358) と電源の電流の道を持つ低周波の回路で、扱う信号は検波後の 50Hz の
断続と DC だけ。10MHz 以下の範囲なので perfboard で足りる。これを高周波の島と同じ銅張り基板に
載せると、切り出しと面積が高くつくうえ、LM358 の電源と LED の電流の道が同調の島の近くを通り、
同調が乱れる。そこで受信機を**図4 (高周波部、銅張り基板) と図5 (低周波部、perfboard) の
2 枚に分ける**。基板どうしのつなぎは 2 本 — 検波の出力 (DET) と GND。GND は図4 の裏の銅から
短い線で図5 の GND の筋 (w 行) の 1 か所へ渡す。送信機 (図3) は発振だけの 1 枚なので分けない。
図3・図4・図5 のどれにも、基板の外の機器 (AD やアンテナの線、基板どうしのつなぎ) を箱で描き、ピンから島や穴へ線を引いてある。
送信機と図5 は AD の V+ と GND (Supplies の 5V) から給電し、受信機の高周波部 (図4) は電源が要らない。
図5 の入口に電源のデカップリング (0.1µF) は置かない。電流は LED の約 3mA だけで、信号は 50Hz の断続なので、電源の揺れが問題にならない (デカップリングは、電流が大きい・速い信号を扱う段で置く)。

### 送信機 (銅張り基板)

```copper
board:
  size: 70x50mm
  ground: back
title: 図3 送信機 (銅張り基板、Manhattan)
f: 27.145M
copper:
  KEY: pad 10,14 4x4mm
  VCC: pad 30,14 28x4mm
  BASE: pad 20,28 20x4mm
  COL: pad 38,20 14x4mm
  EMI: pad 45,30 14x4mm
  ANT: pad 56,20 4x4mm
  GCb: pad 19,22 4x4mm
  VCb: via 19,22
  GX: pad 12,40 4x4mm
  VX: via 12,40
  GB2: pad 27,40 4x4mm
  VB2: via 27,40
  GC2: pad 42,40 4x4mm
  VC2: via 42,40
  GRe: pad 50,40 4x4mm
  VRe: via 50,40
  GAD: pad 60,10 4x4mm
  VAD: via 60,10
parts:
  Rb1: resistor 10,14 10,28 22k
  X1: crystal 12,28 12,40 27.145M
  Rb2: resistor 27,28 27,40 10k
  Cb: capacitor 19,14 19,22 0.1u
  Q1: transistor/to92 29,28 36,20 41,30 2SC1815
  L1: inductor 32,14 32,20 1u
  CT: capacitor 38,14 38,20 5-30p
  C1: capacitor 42,20 42,30 22p
  C2: capacitor 42,30 42,40 100p
  Re: resistor 50,30 50,40 1k
  Cant: capacitor 45,20 56,20 2.2p
  AD:
    type: device
    at: 32,-14
    label: Analog Discovery
    pins: W1 2+ V+ 2- GND
    face: bottom
  WIRE:
    type: device
    at: 92,20
    label: アンテナ線 20cm
    pins: ANT
    face: left
wires:
  - AD.W1 -- 9,13 blue
  - AD.2+ -- 11,13 orange
  - AD.V+ -- 30,14 red
  - AD.2- -- 59,9 black
  - AD.GND -- 61,9 black
  - WIRE.ANT -- ANT green
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/copper/14-27mhz-rc-toy-1.svg)

- 銅張り基板は 5×7cm を横に置いた 70×50mm。銅張り基板の外の箱は Analog Discovery (AD、上) とアンテナの線 (右)。
  箱のピンから島へ引いた線は、銅を作らない配線 (半田付けする線) で、線が指す島とピンの対応が
  **図の島と回路図 (図1) の節点の対応**の表 (`copper-fence check` のネットリストと図1 の接続は一致する)

  | 図の島 | 回路図の節点 (つながるピン) |
  | --- | --- |
  | KEY | Rb1 の上。**AD の W1 (青) と 2+ (橙、CH2) の線**をここへ。左上 |
  | BASE | Rb1 の下・X1 の上・Rb2 の上・Q1 のベース |
  | VCC | +5V (Cb の上・L1 の上・C<sub>T</sub> の上)。上の帯。**AD の V+ (赤)** |
  | COL | Q1 のコレクタ・L1 の下・C<sub>T</sub> の下・C1 の上・Cant の左 |
  | EMI | Q1 のエミッタ・Re の上・C1 の下・C2 の上 |
  | ANT | Cant の右。**アンテナの線 (20cm、緑)** をここへ半田付けする |
  | GND (via の島 5 つ) | X1・Rb2・Cb・C2・Re の下。**すべて via で裏の GND の面** |
  | GAD (via の島、右上) | 裏の GND の面。**AD の GND と 2− (黒) の線**をここへ (銅張り基板の上の空きの島で、回路の部品はつながない) |

- Q1 (2SC1815) は 3 本のピンを 3 つの島 (BASE・COL・EMI) へ広げて半田付けする。図の黒い丸は
  Q1 の胴の置き場で、ピンは B が左の BASE、C が上の COL、E が右下の EMI へ向かう。
  2SC1815 は平らな面を見て左から E・C・B なので、組む前に実物のピンの並びを確かめてから折り曲げる
- 電源 (5V) の + は AD の V+ から上の VCC の帯へ、− は AD の GND から右上の GAD の島 (裏の GND の面) へ。
  W1 の線は左の KEY の島へ、CH2 の 2+ も同じ島へ (2− は GND へ)。
  tinySA をつなぐときはアンテナの線を外し、ANT の島から短い同軸へ
- 高周波の線 (L1・C<sub>T</sub>・C1・C2・Q1) はなるべく短く、特に C1・C2 のピンは 5〜10mm にとどめる。
  C<sub>T</sub> は 30pF のセラミックトリマ (図の値は範囲の 5〜30pF)

### 受信機の高周波部 (銅張り基板)

```copper
board:
  size: 70x50mm
  ground: back
title: 図4 受信機の高周波部 (銅張り基板、Manhattan)
f: 27.145M
copper:
  ANT: pad 8,20 4x4mm
  TANK: pad 27,20 22x4mm
  DET: pad 50,20 12x4mm
  GL2: pad 19,32 4x4mm
  VL2: via 19,32
  GCT: pad 27,32 4x4mm
  VCT: via 27,32
  GC3: pad 35,32 4x4mm
  VC3: via 35,32
  GCd: pad 46,32 4x4mm
  VCd: via 46,32
  GRd: pad 52,32 4x4mm
  VRd: via 52,32
  GAD: pad 60,10 4x4mm
  VAD: via 60,10
parts:
  Cc: capacitor 8,20 17,20 10p
  L2: inductor 19,20 19,32 1u
  CT2: capacitor 27,20 27,32 5-30p
  C3: capacitor 35,20 35,32 22p
  D1: schottky 37,20 45,20 1SS108
  Cd: capacitor 46,20 46,32 1n
  Rd: resistor 52,20 52,32 100k
  AD:
    type: device
    at: 52,-14
    label: Analog Discovery
    pins: 1+ 1- GND
    face: bottom
  WIRE:
    type: device
    at: -22,20
    label: アンテナ線 20cm
    pins: ANT
    face: right
  NEXT:
    type: device
    at: 92,26
    label: 図5 の基板へ
    pins: DET GND
    face: left
wires:
  - AD.1+ -- 50,18 green
  - AD.1- -- 59,9 black
  - AD.GND -- 61,9 black
  - WIRE.ANT -- ANT green
  - 55,20 -- NEXT.DET green
  - NEXT.GND -- GRd black
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/copper/14-27mhz-rc-toy-2.svg)

- 銅張り基板は送信機と同じ 5×7cm の横置き (70×50mm)。銅張り基板の外の箱は AD (上)・アンテナの線 (左)・図5 の基板 (右)。
  **図の島と回路図 (図2) の節点の対応**

  | 図の島 | 回路図の節点 (つながるピン) |
  | --- | --- |
  | ANT | Cc の左。**アンテナの線 (20cm、緑)** をここへ |
  | TANK | Cc の右・L2 の上・C<sub>T2</sub> の上・C3 の上・D1 のアノード |
  | DET | D1 のカソード・Cd の上・Rd の上。**検波の出力**。AD の CH1 の 1+ (緑) と、図5 の基板への線 (緑、図5 の PIN 5 へ) をここへ |
  | GND (via の島 5 つ) | L2・C<sub>T2</sub>・C3・Cd・Rd の下。すべて via で裏の GND の面。図5 の基板への GND の線 (黒) は右端の Rd の下の島から |
  | GAD (via の島、右上) | 裏の GND の面。AD の CH1 の 1− と GND (黒) の線をここへ |

- 同調の島 TANK に L2 (19mm)・C<sub>T2</sub> (27mm)・C3 (35mm) の上端を立て、下端は via の島へ落とす。
  D1 (1SS108) は TANK の右端から DET へ渡す。カソードは帯の側
- 右の箱「図5 の基板へ」の DET と GND のピンは、図5 の**下の枠「図4 の基板から」の DET・GND のピン**へ
  そのままつなぐ 2 本の線 (DET は島 DET から、GND は裏の GND の面から)
- 受信機の高周波部は電源が要らないので、AD の V+ はつながない。CH1 の 1+ を DET へ、1− を GND へ当てる
- C<sub>T2</sub> は 30pF のセラミックトリマ (図の値は範囲の 5〜30pF)

### 受信機の低周波部 (perfboard)

**perfboard に組む範囲**: 電圧 5V、電流は LED の約 3.2mA と数百 µA のしきい値の分圧だけ
(1 本の線あたり 500mA 以下)、信号は 50Hz の断続と DC (10MHz 以下)。銅張り基板は 5×7cm (18×24 穴、
1.6mm の FR-4・両面スルーホール) の 1 枚目で、部品と線の外周に 1 穴の余白を残して収まる。
図は部品面から見た図で、部品のピンはその穴を通して裏の半田面で半田付けする。

```perfboard
board:
  size: 5x7cm
  h: 1.6mm
  material: FR-4
  slots: on
title: 図5 受信機の低周波部 (perfboard 5×7cm、部品面)
points:
  NC_PIN1: i6
parts:
  PREV:
    type: device
    at: y2
    label: 図4 の基板から
    pins: DET GND
  AD:
    type: device
    at: -c4
    label: Analog Discovery
    pins: V+ GND
  SC:
    type: device
    at: y9
    label: AD CH1
    pins: 1+ 1-
  U1: dip8 i9 r90 LM358
  Rt1: resistor e12 i12 100k
  Rt2: resistor k12 q12 1k
  Rled: resistor j15 n15 470
  LED: led o15 s15 red
wires:
  - AD.V+ -- c4 red
  - c4 -- c9 red
  - c9 -- c12 red
  - c12 -- e12 red
  - c9 -- i9 red
  - AD.GND -- a5 black
  - a5 -- a18 black
  - a18 -- w18 black
  - w18 -- w15 black
  - w15 -- w12 black
  - w12 -- w6 black
  - w6 -- w5 black
  - w5 -- w3 black
  - PREV.GND -- w3 black
  - l6 -- w6 black
  - j6 -- k6 black
  - k6 -- l6 black
  - q12 -- w12 black
  - s15 -- w15 black
  - PREV.DET -- n2 green
  - n2 -- n4 green
  - n4 -- n9 green
  - SC.1+ -- n9 blue
  - SC.1- -- w10 black
  - w10 -- w12 black
  - n9 -- l9 green
  - i12 -- k12 orange
  - k9 -- k12 orange
  - j9 -- j15 white
  - n15 -- o15 white
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/perfboard/14-27mhz-rc-toy.svg)

- 上の c 行の赤い筋が +5V (AD の V+)、下の w 行の黒い筋が GND。AD の GND は上の a 行を右へ回して 18 列を降ろし、w18 へ。
  計器の箱は 2 つで、左上が電源 (V+・GND)、下の中ほどが CH1 の 1+・1− (AD CH1。1+ は 9 列で n9、1− は w10 へ。
  1+ の線は w 行の GND の筋を 1 か所だけ渡る)。
  図4 の基板からの GND はユニバーサル基板の下から w3 へ (2 枚のユニバーサル基板の GND を 1 か所でつなぐ)
- U1 (LM358、DIP8) は 6 列と 9 列をまたいで立て、左の列が上から PIN 1・2・3・4、
  右の列が上から PIN 8・7・6・5 (ピンの名前は胴に刷ってある)。PIN 8 (i9) は c9 から降ろした +5V へ。
  PIN 4 (l6) は 6 列を w6 へ降ろして GND の筋へ。使わない 1 回路目の入力 PIN 2・PIN 3 (j6・k6) も
  PIN 4 と線で結んで GND へ。PIN 1 (OUT1) は何もつながない
- **検波の出力 (緑)**: 図4 の基板から来る DET を n2 に受け、n 行を右へ走らせて n9、そこから l9
  (LM358 の **PIN 5**) へ上げる。途中で 6 列の GND の線を跨ぐ (図の半円)。
  CH1 の 1+ (青) は 4 列から降ろして n4 に当てる (図4 の DET の島と同じ電位)。1− (黒) は 5 列を降ろし、
  n 行の緑の線を跨いで w5 の GND の筋へ
- **PIN 6 (k9)** に Rt1 (12 列、上端は c12 から降ろした +5V) と Rt2 (12 列、下端は w12 の GND の筋へ)。
  PIN 6 から橙の線を k12 へ、Rt1 の下端 i12 からも橙の線を k12 へ (j12 で白い線を跨ぐ)。
  ここが 49.5mV のしきい値
- PIN 7 (j9) から白の線を j15 へ、15 列を降ろして Rled → LED。LED のカソード (s15) は w15 で GND の筋へ

`copper-fence check` と `perfboard-fence check` のネットリストを合わせると、回路図 (図1・図2) と
同じつながりになる。図3 は図1 のとおり (AD の V+ は VCC、W1 と 2+ は KEY、2− と GND は GND、
アンテナの線は ANT)。受信機は図2 の D1・Cd・Rd の節点 (図4 の DET) と GND が、図4 の箱
「図5 の基板へ」・図5 の「図4 の基板から」の DET と GND を通ってつながる。図4 の AD は 1+ が DET、
1− と GND が GND、図5 の AD は V+ が +5V、GND と CH1 の 1− が GND、1+ が DET (図2 の電圧計 CH1 の 1+・1− と同じ)。

## 計器の設定

50Hz の断続のキーと検波の出力は、Analog Discovery のオシロで波形を見る。27.145MHz の搬送波は
オシロの範囲 (10MHz 以下) を超えるので、tinySA のスペクトルで確かめる。

### Analog Discovery (断続と受信の波形)

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5V (送信機と受信機の両方の +5V) |
| Wavegen W1 | Square・50Hz・Amplitude 2.5V・Offset 2.5V (0〜5V) |
| Scope CH2 | W1 (送信機のキー)。2V/div |
| Scope CH1 | 受信機の検波の出力 (図5 の PIN 5、Rd の上端と同じ電位)。100mV/div |
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
title: 図6 送信機の搬送波 (Cant の出口を 50Ω で受ける)
device: tinysa-ultra
center: 27.145MHz
span: 1MHz
rbw: 10kHz
points: 450
ref: 0dBm
signal: sine 27.145MHz -9.7dBm
markers: [peak]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/14-27mhz-rc-toy.svg)

コレクタの振幅は、LTspice の発振のシミュレーションで約 10Vpp (5V peak。L1 から給電するので電源の 2 倍まで振れる)。
Cant (2.67kΩ) と 50Ω の分圧のほか、コレクタの波形のひずみがあり、50Ω の両端は LTspice で 0.104V peak。
電力は (0.104V)²/(2×50Ω) **≈ 108µW = −9.7dBm**。
最初の目安 (コレクタ 2V peak、37.5mV peak、−18.5dBm) は実際より 8 dB 小さい見積りだった。水晶の発振なので線は細く、C<sub>T</sub> を回しても**周波数は動かず高さだけ変わる**
(タンクが 27.145MHz に合った所で一番高い)。

```scope
title: 図7 キー (CH2) と受信機の検波出力 (CH1)
time: 5ms/div
trigger: ch2 rising 2.5V
ch1: {wave: square 50Hz 0.15V offset 0.15V | rc 0.1ms, range: 100mV/div, position: -3div}
ch2: {wave: square 50Hz 2.5V offset 2.5V, range: 2V/div, position: -2div}
measure: [vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/14-27mhz-rc-toy.svg)

CH1 は CH2 と同じ 50Hz・デューティ 50% で上がり下がりする。高さの 0.3V は
アンテナの間 10cm での目安で、**距離を離すとすぐ小さくなる** (近くの電界は距離の
2〜3 乗で弱まる)。0.3V は判定の 49.5mV の約 6 倍あるので LED は確実に点く (W1 が 50 Hz のときは明るさで確かめ、点滅は W1 を 2 Hz にして見る)。

## 見るべき値

計算値 (「目安」と書いたものは距離や部品のばらつきで変わる)。

| 測る所 | 期待する値 |
| --- | --- |
| Q1 のエミッタ電流 (W1 = 5V) | 約0.88mA (テスターの直流電圧レンジで Re の両端を測り、約0.88V) |
| tinySA のピーク | 27.145MHz、約 −10dBm (LTspice で −9.7dBm。部品のばらつきで数 dB 動く) |
| C<sub>T</sub> を回す | 周波数は動かず、高さが最大になる所がある (計算 16.3pF、LTspice は 10pF 前後。トリマの範囲 5〜30pF に収まる) |
| 検波の出力 CH1 | 50Hz・デューティ 50%、最大 約0.3V (目安、10cm)・最小 0V |
| LM358 PIN 6 の電圧 | 49.5mV |
| LED | W1 が 50Hz のとき、点きっぱなしの光に見える (平均の明るさは W1 が DC 5V のときより暗い)。W1 を 2Hz に下げると 1 秒に 2 回の点滅が目で分かり、W1 を止めて 0V にすると消える |
| 受信機の CT2 を回す | 計算 12.4pF (アンテナとダイオードの容量を入れると 9pF 前後) で CH1 が最大 |
| アンテナの間を 1m にする | CH1 がほぼ 0 になり LED が点かない (微弱の範囲の目安) |

## LTspice での確かめ

デッキは `sim/14-27mhz-rc-toy-tx.cir` (送信機の発振)、`sim/14-27mhz-rc-toy-rx.cir` (受信機の同調)。
2SC1815 は 9-25 と同じ代用モデル。水晶は直列共振 27.145MHz の等価回路 (C<sub>s</sub> = 0.02pF・R<sub>s</sub> = 40Ω・C<sub>p</sub> = 4pF)、
L1 は Q = 50 (直列 3.4Ω)、1SS108 は I<sub>S</sub> = 20nA・n = 1.05・R<sub>S</sub> = 5Ω・C<sub>J0</sub> = 1pF、アンテナの容量は 3pF。
どれも目安から作った仮定で、実測の値ではない。送信機は、30µs だけ 27.145MHz の小さな電流をベースへ注いで水晶を揺らし、
発振が続くか見た (呼び水なしでは、シミュレーションの雑音が無く起動しない)。

| 項目 | 本文の計算値 | LTspice | 判定 |
| --- | --- | --- | --- |
| Q1 のエミッタ電流 (W1 = 5V、発振の前) | 0.88mA | 0.90mA (V<sub>E</sub> 0.90V) | 合う |
| 発振の周波数 | 27.145MHz (水晶が決める) | C<sub>T</sub> = 8pF で 27.1417MHz、10pF で 27.134MHz、13pF で 27.077MHz | 合う (水晶に引かれる。外れるほど少しずれる) |
| 発振の有無と C<sub>T</sub> | 約 16.3pF に合わせる | 8〜13pF で発振、14pF 以上では起動しなかった | 直した (16.3pF は容量を無視した値。実際は 10pF 前後が良い) |
| コレクタの振幅 | 2V peak (目安) | 約 10Vpp (5V peak) | 直した (8dB 大きい) |
| 50Ω の振幅・電力 (tinySA) | 37.5mV peak・−18.5dBm | 0.104V peak・−9.7dBm (C<sub>T</sub> = 10pF) | 直した (−10dBm 前後に) |
| 受信機の同調、CT2 = 12.4pF | 27.145MHz | アンテナの容量とダイオードで 26.1MHz。27.145MHz には約 9pF | 直した (注記を足した。トリマの範囲に収まる) |
| 計算だけで確かめた値 | 次の行 | 式による | 合う |

計算だけの値 (式を Python で解いた): 分圧の開放電圧 1.5625V・テブナン抵抗 6.875kΩ・I<sub>E</sub> 0.882mA、C1 と C2 の直列 18.03pF、
タンクの共振 33.19〜22.97MHz、C<sub>T</sub> 16.35pF、Cant のリアクタンス 2.665kΩ、受信機の同調 30.6〜22.1MHz・CT2 12.38pF・ωL 170.6Ω・Q = 50 で 8.5kΩ、
Cd × Rd = 100µs、コンパレータのしきい値 49.5mV、LED の電流 3.19mA (出力 3.5V と置いた目安)、C2 のリアクタンス 58.6Ω、ピン 7nH で 1.19Ω。

検波の出力 0.3V (アンテナの間 10cm)・LM358 の出力 3.5V・LED の電流は、距離や素子で決まる目安で、シミュレーションの対象外。
電波の到達と微弱無線の電界強度、島の浮遊容量の実測も対象外 (見積りは本文のとおり)。

## 部品

| 部品 | 値・型番 | メモ |
| --- | --- | --- |
| Q1 | 2SC1815 | f<sub>T</sub> は最小 80MHz。27MHz なら足りる |
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
LM358 のピンの並びは TI のデータシート (LM358、DIP8: PIN 1 = OUT1、PIN 2 = IN1−、
PIN 3 = IN1+、PIN 4 = GND、PIN 5 = IN2+、PIN 6 = IN2−、PIN 7 = OUT2、PIN 8 = V+) による。
