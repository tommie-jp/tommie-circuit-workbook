---
book: circuits
chapter: 9
id: 9-14
title: 27MHz の送受信 (トイラジコン)
tier: 200
source: 自作
era: 古
board: BB
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

```breadboard
title: 図3 送信機をブレッドボードに組む
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 2-, 2+, W1]
  ANT:
    type: device
    at: top
    label: アンテナ 20cm
    pins: ["1"]
  Rb1: resistor c10 c14 22k
  Rb2: resistor i14 i10 10k
  X1: crystal/hc49 g14 g10 27.145M
  Q1: transistor j14(B) j18(C) j22(E) 2SC1815
  L1: inductor/axial c18 c15 1u
  CT: capacitor/ceramic a18 +t18 30p
  Cant: capacitor/ceramic d18 d22 2.2p
  C1: capacitor/ceramic g18 g22 22p
  Re: resistor f22 f26 1k
  C2: capacitor/ceramic h22 h26 100p
  Cb: capacitor/ceramic b26 b28 0.1u
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.2- -- -t6 black
  - AD.2+ -- a8 blue
  - b8 -- b10 blue
  - AD.W1 -- a10 yellow
  - j10 -- -b10 black
  - e14 -- f14 orange
  - +t15 -- a15 red
  - e18 -- f18 green
  - ANT.1 -- a22 yellow
  - j26 -- -b26 black
  - +t26 -- a26 red
  - a28 -- -t28 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/14-27mhz-rc-toy-1.svg)

- 上の赤レール = +5V (AD の V+)、青レール = GND。30 列で上下の − レールを渡している
- Q1 は下のブロックの j 行 (14 列 B・18 列 C・22 列 E)。ベースとコレクタは e–f の短い線で上のブロックへも出す
- **10 列 (上) がキー**: W1 (黄) を a10 に挿し、CH2 の 2+ (青) は a8 から b8–b10 で渡す。Rb1 でベース (14 列) へ
- ベース (14 列) の上に Rb1、下に X1 と Rb2。X1 と Rb2 の GND 側は 10 列 (下) から − レールへ。上の 10 列 (キー) とは溝で分かれている
- コレクタ (18 列) に L1 (15 列の +5V から)・CT (+ レールへ縦に挿す)・Cant・C1。
  CT は 30pF のセラミックトリマ (図の値は最大値)
- エミッタ (22 列、下) に C1・Re・C2。Re と C2 の GND 側は 26 列から下の − レールへ。上の 22 列はアンテナ
- Cb は 26〜28 列で +5V と GND の間

```breadboard
title: 図4 受信機をブレッドボードに組む
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, 1-, 1+]
  ANT:
    type: device
    at: bottom
    label: アンテナ 20cm
    pins: ["1"]
  Cc: capacitor/ceramic h3 h6 10p
  L2: inductor/axial j6 -b6 1u
  CT2: capacitor/ceramic i6 i9 30p
  C3: capacitor/ceramic f6 f2 22p
  D1: schottky g6 g14 1SS108
  Cd: capacitor/ceramic h14 h17 1n
  Rd: resistor j14 -b14 100k
  U1: dip8 @ e20 LM358
  Rt1: resistor a22 +t22 100k
  Rt2: resistor b22 b27 1k
  Rled: resistor b21 b17 470
  LED: led a17 -t17 red
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1- -- -t12 black
  - AD.1+ -- a14 orange
  - ANT.1 -- j3 yellow
  - j9 -- -b9 black
  - j2 -- -b2 black
  - f14 -- e14 blue
  - d14 -- d23 blue
  - j17 -- -b17 black
  - +t20 -- a20 red
  - a27 -- -t27 black
  - j21 -- -b21 black
  - j22 -- -b22 black
  - j23 -- -b23 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/14-27mhz-rc-toy-2.svg)

- 上の赤レール = +5V (AD の V+)、青レール = GND。30 列で上下の − レールを渡している
- 同調と検波は下のブロック: アンテナ (j3) → Cc → **6 列がタンク** (L2 は − レールへ縦に、CT2 は 9 列・C3 は 2 列から − レールへ)
- D1 (1SS108) の陰極側の **14 列が検波の出力**。Cd (17 列から GND)・Rd (− レールへ縦) が並び、
  f14–e14 の線で上のブロックへ出す。CH1 の 1+ (橙) は a14 に挿す
- U1 (LM358) は 20〜23 列で溝をまたぐ。上の行が PIN 8〜5、下の行が PIN 1〜4。
  検波の出力は d14–d23 の青い線で **PIN 5 (IN2+)** へ
- PIN 6 (22 列、上) に Rt1 (+ レールから縦) と Rt2 (27 列から GND)。ここが 49.5mV のしきい値
- PIN 7 (21 列) から Rled で 17 列の LED の陽極へ。LED は陰極を − レールへ縦に挿す
- PIN 8 は + レール (a20)、PIN 4 は j23 から − レール。使わない 1 回路目の入力 PIN 2・PIN 3 も j21・j22 から − レールへ

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
