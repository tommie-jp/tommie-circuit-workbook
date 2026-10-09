---
book: circuits
chapter: 9
id: 9-22
title: Tayloe 検波器 — 74HC4052 で I/Q を音にする (直接変換)
tier: 200
source: 自作
board: BB
era: 今
---

# 9-22 Tayloe 検波器 — 74HC4052 で I/Q を音にする (直接変換)

9-19 では SA612 を 2 個使い、LO を 90° ずらした 2 つのミキサーで I と Q を作った。
この題では、同じ I と Q を **アナログスイッチ 1 個とコンデンサ 4 個**で作る。
**Tayloe 検波器** (Dan Tayloe の特許、2001 年) と呼ばれる回路で、SoftRock など初期の SDR の入口に使われた。

ここでは LO と RF の差を 0 近くにして、I と Q を**そのまま音の周波数**で取り出す。
中間周波数 (IF) を通らないので**直接変換** (ダイレクトコンバージョン、ゼロ IF) と呼ぶ。

**働き。** 4 チャネルのアナログスイッチ 74HC4052 の共通端 AN に、抵抗 R1 を通して RF を入れる。
LO の 1 周期を 4 つに分け、各 1/4 周期だけ 4 つのコンデンサ (C1〜C4) の 1 つを AN につなぐ。

- つながっている間、コンデンサは R1 を通して、その 1/4 周期の RF の**平均**に向かって充電される。
  離れている間は電圧を保つ
- RF が LO と同じ周波数なら、各コンデンサは毎回 RF の同じ位相の所を拾う。
  4 つのコンデンサは 0°・90°・180°・270° の所の値で止まり、直流になる
- RF が LO から Δf ずれると、拾う位相が 1 秒に Δf 回の速さで回る。コンデンサの電圧は
  **Δf の正弦波**で動く。これが差の周波数で、**スイッチが掛け算 (ミキサー)、コンデンサが低域フィルタ**を兼ねる
- 0° と 180° のコンデンサの差が **I**、90° と 270° の差が **Q** になる。
  差を取ると、2.5 V の偏りと、4 つに同じだけ乗る揺れが消え、振幅は 2 倍になる

**4 相の LO を 74HC74 で作る。** スイッチを 4 つ順に回すには、90° ずつずれた方形波が要る。
9-18 の RC-CR 網は正弦の 90° しか作れないので、ここではデジタルで作る。
AD3 の W1 から **1.992 MHz** の方形波 (0〜5 V) を出し、74HC74 の D フリップフロップ 2 個を
**ジョンソンカウンタ** (FF1 の D ← FF2 の /Q、FF2 の D ← FF1 の Q、クロックは共通) にして 4 分の 1 にする。

- 74HC74 は CLK の立ち上がりで D を Q に写す。Q1・Q2 = 0・0 から始めると、
  クロックごとに (Q1, Q2) は **00 → 10 → 11 → 01 → 00** と回る (FF1 は /Q2 を、FF2 は Q1 を写すため)
- Q1 と Q2 は、どちらも **498 kHz・デューティ 50 %** の方形波で、Q2 は Q1 より 1 クロック (502 ns、LO の 1/4 周期 = 90°) 遅れる
- **S0 ← Q1、S1 ← Q2** とつなぐ。(S1, S0) は 00 → 01 → 11 → 10 と回り、
  チャネルの番号 (2·S1 + S0) は **0 → 1 → 3 → 2**。つながるコンデンサは **A0 → A1 → A3 → A2** の順で、
  これが 0°・90°・180°・270° になる
- だから **I = A0 − A3、Q = A1 − A2**。番号の順に A0 − A2、A1 − A3 と組むと、
  0° と 270°、90° と 180° の差になり、I と Q にならない
- この順は 1 ステップに選択線が 1 本しか変わらない (グレイ符号の順)。2 本が同時に変わる所が無いので、
  切り替えの瞬間に別のチャネルが一瞬つながることが無い

**周波数。** LO = 1.992 MHz ÷ 4 = **498 kHz**。RF は W2 の **499 kHz** (LO より 1 kHz 上)。
I と Q は **1 kHz の音**になる。W1 と W2 は AD3 の中の同じクロックから作るので、差はぴったり 1.000 kHz だ。

- **W2 = 499 kHz なら Q が I より 90° 進み、497 kHz なら 90° 遅れる** (1 kHz の 90° は 250 µs)。
  I だけ (ミキサー 1 個) では、どちらも同じ 1 kHz で区別できない。これは 9-19 と同じ話で、
  9-19 の IF (49.8 kHz) がここでは音になった
- W2 = 498.000 kHz ちょうどなら差は 0 で、I と Q は**直流**になる (ゼロ IF)。値は W2 と LO の位相の関係で決まり、
  W2 の位相を変えると、I と Q の組が円の上を動く。74HC74 が電源を入れたときどの状態から始まるかで、
  位相の基準は 90° 単位でずれる

**利得と低域の角。** 計算値と LTspice (スイッチの模型、オン抵抗 R<sub>on</sub> 80 Ω)。

- 各コンデンサは 1/4 周期 (90°) の平均を拾うので、正弦の振幅は sin(π/4) ÷ (π/4) = **0.900 倍**。
  差を取って 2 倍、合わせて **1.80 倍**
- 各コンデンサが R1 につながるのは時間の 1/4 だけなので、時定数は 4 倍に伸びる。
  低域の角は f<sub>c</sub> = 1 ÷ (2π · 4 · (R1 + R<sub>on</sub>) · C) = 1 ÷ (2π · 4 · 1080 Ω · 10 nF) **≈ 3.7 kHz**
- W2 を振幅 0.25 V (0.5 V<sub>pp</sub>) にすると、1 kHz での I と Q は**それぞれ 0.434 V peak (0.87 V<sub>pp</sub>)**。
  入力の **1.74 倍 (+4.8 dB)** で、1.80 倍から低域の角の分 (1 kHz で 0.965 倍) だけ下がった値だ (LTspice)
- Δf を 4 kHz (W2 = 502 kHz) にすると 0.305 V peak (−3.1 dB)、10 kHz (508 kHz) では 0.156 V peak (LTspice)。
  受けたい音の帯域より上は、このコンデンサだけで落ちる

**RF の偏り。** 74HC4052 は 5 V の単電源 (VEE と GND を 0 V) で使うので、AN の電圧は 0〜5 V に収める。
W2 に**オフセット 2.5 V** を足して 2.25〜2.75 V で振らせれば、偏りの部品が要らない。4 つのコンデンサも 2.5 V まで充電され、
I と Q は差を取るので 2.5 V は消える。

- **B 側は使わない。** BN (PIN 3) を GND に結び、B0〜B3 (PIN 1・2・4・5) は開けておく。
  B 側のスイッチは A 側と同じ S0・S1 で動き、開いた 1 本のピンを GND につなぐだけなので何も起きない。
  論理の入力ではないので、浮かせても入力が揺れる心配は無い。E (PIN 6、L で動く) と VEE (PIN 7) も GND へ
- 74HC74 の 1CLR・1PRE・2CLR・2PRE (L で効く) は 5 V に結び、使わない /1Q は開けておく
- ブレッドボードに通るいちばん高い周波数は W1 の 1.992 MHz で、この本のブレッドボードの範囲 (3 MHz 以下) に収まる。
  W1 の線と 74HC74 の CLK の線は短くする

## 回路図

```circuit
title: 図1 Tayloe 検波器 (74HC74 で 4 相を作り、74HC4052 で 4 つの C に振り分ける)
parts:
  VCC: vcc 6,5 5V
  U1: ic 8,8 74HC74
  G2: ground 8,10
  W1: square 3.5,10 3.5,12 l=$\mathrm{W1}$
  G1: ground 3.5,12
  U2: ic 32,8 74HC4052
  VCC: vcc 32,4 5V
  G3: ground 31,12
  G11: ground 35.5,10
  C2: capacitor 17,12 17,14 10n
  G4: ground 17,14
  C3: capacitor 20,12 20,14 10n
  G5: ground 20,14
  C4: capacitor 23,12 23,14 10n
  G6: ground 23,14
  C1: capacitor 26,12 26,14 10n
  G7: ground 26,14
  M2: voltmeter 20,10 23,10 l=$\mathrm{CH2}$
  M1: voltmeter 20,16 23,16 l=$\mathrm{CH1}$
  R1: resistor 36,8 38,8 1k
  W2: sine 39,8 39,10 l=$\mathrm{W2}$
  G8: ground 39,10
  VCC: vcc 3,18 5V
  C5: capacitor 3,18 3,20 100n
  G9: ground 3,20
  VCC: vcc 7,18 5V
  C6: capacitor 7,18 7,20 100n
  G10: ground 7,20
wires:
  - 6,5 -- 9,5
  - 7,5 |- U1.VCC
  - 7.5,5 |- U1.1PRE
  - 8,5 |- U1.1CLR
  - 8.5,5 |- U1.2PRE
  - 9,5 |- U1.2CLR
  - U1.GND |- 8,10
  - U1.1CLK -| 3.5,8
  - 3.5,8 -- 3.5,9
  - U1.2CLK -| 3.5,9
  - 3.5,9 -- 3.5,10
  - U1./2Q -| 11,9
  - 11,9 -- 11,14 -- 1,14 -- 1,7.5
  - 1,7.5 -| U1.1D
  - U1.1Q -| 11.5,7.5
  - 11.5,7.5 -- 13,7.5
  - 13,7.5 -- 13,20
  - 11.5,7.5 -- 11.5,2 -- 2,2 -- 2,8.5
  - 2,8.5 -| U1.2D
  - U1.2Q -| 12,8.5
  - 12,8.5 -- 12,21
  - 13,20 -| U2.S0
  - 12,21 -| U2.S1
  - U2.VCC |- 32,4
  - 31,12 |- U2.GND
  - U2.VEE |- 31.5,12
  - U2.E |- 32,12
  - 31,12 -- 32,12
  - U2.BN -| 35.5,10
  - U2.A0 -| 17,6.5
  - 17,6.5 -- 17,11
  - 17,11 -- 17,12
  - U2.A1 -| 20,7
  - 20,7 -- 20,10
  - 20,10 -- 20,12
  - U2.A2 -| 23,7.5
  - 23,7.5 -- 23,10
  - 23,10 -- 23,12
  - U2.A3 -| 26,8
  - 26,8 -- 26,11
  - 26,11 -- 26,12
  - 17,11 -- 15.5,11 -- 15.5,16 -- 20,16
  - 23,16 -- 28,16 -- 28,11 -- 26,11
  - U2.AN -| 36,8
  - 38,8 -- 39,8
notes:
  - text 4,11 small left: 1.992 MHz
  - text 40,9 small left: 499 kHz
  - text 5,21 small center: パスコン (C5 は U1、C6 は U2)
  - text 22,19.5 small center: LO 0° (S0)
  - text 22,22 small center: LO 90° (S1)
  - text 21.5,18 small center: CH1 は I (A0 - A3)、CH2 は Q (A1 - A2)
style:
  pitch: 1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/22-tayloe-detector.svg)

図1 の `+5V` は AD3 の電源出力 V+ (Supplies で 5 V)。74HC74 と 74HC4052 を合わせても流す電流は 1 mA に届かない。

- **左が LO の 4 相**。W1 (1.992 MHz) を U1 (74HC74) の 1CLK と 2CLK へ。1Q (PIN 5) が S0 と 2D へ、
  2Q (PIN 9) が S1 へ、/2Q (PIN 8) が 1D へ戻る。2 本の帰還は箱の上と下を回るので、
  線の交差が 2 か所ある (黒丸の無い交差はつながっていない)
- **右が Tayloe 検波器**。U2 (74HC4052) はピンを働きで並べた箱で描いた (左にチャネル A0〜A3・B0〜B3、
  右に共通の AN・BN、下に GND・VEE・E・S0・S1)。この箱は左右を裏返せず、共通の AN が右にあるので、
  **RF は右から入り、左のコンデンサへ流れる**。W2 (499 kHz) が R1 (1 kΩ) を通って AN (PIN 13) へ。
  A0 (PIN 12)・A1 (PIN 14)・A2 (PIN 15)・A3 (PIN 11) に C2・C3・C4・C1 (10 nF) を GND へ。
  GND・VEE・E・BN は GND へ
- LO の 2 本は下から S0・S1 へ入る
- **CH1 は差動**で 1+ を A0、1− を A3 (I)。**CH2 も差動**で 2+ を A1、2− を A2 (Q)。
  AD3 の Scope の入力はもともと差動なので (9-12 と同じ)、差を取る回路が要らない
- C5・C6 は U1・U2 の電源のパスコン。それぞれの IC の VCC と GND のそばに挿す

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (左が 74HC4052、右が 74HC74)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W2, 2-, 2+, 1+, 1-, DIO1, W1, DIO2, DIO0]
  U2: dip16 @ e13 74HC4052
  U1: dip14 @ e22 74HC74
  R1: resistor c8 c12 1k
  C4: capacitor/ceramic a14 -t14 10n
  C3: capacitor/ceramic a15 -t15 10n
  C2: capacitor/ceramic a17 -t17 10n
  C1: capacitor/ceramic a18 -t18 10n
  C6: capacitor/ceramic +t11 -t11 100n
  C5: capacitor/ceramic +b29 -b29 100n
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - +t4 -- +b4 red
  - -t5 -- -b5 black
  - a13 -- +t13 red
  - j15 -- -b15 black
  - j18 -- -b18 black
  - j19 -- -b19 black
  - j20 -- -b20 black
  - a22 -- +t22 red
  - a23 -- +t23 red
  - a26 -- +t26 red
  - j22 -- +b22 red
  - j25 -- +b25 red
  - j28 -- -b28 black
  - AD.W2 -- b8 yellow
  - d12 -- d16 yellow
  - AD.2- -- c14 blue [h3]
  - AD.2+ -- c15 purple [h35]
  - AD.1+ -- c17 orange [v24, h59]
  - AD.1- -- d18 white [h29]
  - AD.W1 -- a25 green
  - AD.DIO0 -- a30 gray
  - AD.DIO1 -- a21 gray
  - AD.DIO2 -- a27 gray
  - b25 -- b30 green
  - d30 -- g30 green
  - i30 -- i24 green
  - g26 -- g21 brown
  - f21 -- e21 brown
  - b21 -- b24 brown
  - d21 -- d19 brown
  - c27 -- c20 pink
  - c28 -- c29 yellow
  - d29 -- g29 yellow
  - h29 -- h23 yellow
style:
  text-size: 8
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/22-tayloe-detector.svg)

- U2 (74HC4052) は 13〜20 列、U1 (74HC74) は 22〜28 列で溝をまたぐ (切り欠きを左、PIN 1 は左下)。
  U2 の上の列は左から VCC・A2・A1・AN・A0・A3・S0・S1、下の列は B0・B2・BN・B3・B1・E・VEE・GND
- **電源**: AD3 の V+ (赤) を上の + レール、GND (黒) を上の − レールへ。上下のレールは 4・5 列で赤と黒の線で渡す。
  U2 の VCC (a13)、U1 の VCC・2CLR・2PRE (a22・a23・a26) は上の + レールへ、U1 の 1CLR・1PRE (j22・j25) は下の + レールへ。
  U2 の BN・E・VEE・GND (j15・j18・j19・j20) と U1 の GND (j28) は下の − レールへ
- **C1〜C4** (10 nF) は A3・A0・A1・A2 の列の a 行から上の − レールへ直に挿す (a18・a17・a15・a14)。
  C6 は上のレールの間 (11 列)、C5 は下のレールの間 (29 列) に挿す
- **RF (W2、黄)**: b8 に挿し、R1 (c8〜c12) を通して、d12〜d16 の黄の線で AN の列 (16 列) へ
- **LO**: W1 (緑) を a25 (2CLK の列) に挿す。b25〜b30 → d30〜g30 → i30〜i24 の緑の線で 1CLK の列 (24 列) へ下ろす。
  1Q (g26) から茶の線で 21 列へ渡り、溝を越えて上の 21 列から 2D (b21〜b24) と S0 (d21〜d19) へ。
  2Q (c27) から桃の線で S1 (c20) へ。/2Q は c28〜c29 → d29〜g29 → h29〜h23 の黄の線で 1D (23 列) へ
- **Scope**: 1+ (橙) を c17 (A0)、1− (白) を d18 (A3)、2+ (紫) を c15 (A1)、2− (青) を c14 (A2) に挿す。
  コンデンサの上を通らないよう、線は列の間を降りて横から入れた
- **Logic**: DIO0 (灰) を a30 (CLK)、DIO1 を a21 (S0)、DIO2 を a27 (S1) に挿す。
  AD3 の DIO は 3.3 V の論理で、5 V の入力に耐える (仕様) ので、74HC の 5 V の出力をそのまま見られる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | D フリップフロップ ×2 | 74HC74、DIP14 |
| U2 | 4 チャネルのアナログマルチプレクサ ×2 | 74HC4052、DIP16 |
| R1 | 抵抗 | 1 kΩ |
| C1〜C4 | セラミックコンデンサ (標本を保つ) | 10 nF (103)。4 個の容量がそろうほど I と Q の振幅がそろう。C0G (NP0) の品か、同じ袋の 4 個を選ぶ |
| C5・C6 | セラミックコンデンサ (電源のパスコン) | 100 nF (104) |
| — | 信号源・計器・電源 | Analog Discovery 3 (W1・W2、Scope、Logic、V+ 5 V) |

- 74HC4052 のオン抵抗は 5 V で数十 Ω (データシートの代表値)。計算では 80 Ω と見た。R1 の 1 kΩ に比べて小さいので、
  個体の差は低域の角を数 % 動かすだけだ

## 計器の設定

Analog Discovery 3 だけを使う。LO の 4 倍のクロック (1.992 MHz) も RF (499 kHz) も Wavegen で作れ、
I と Q は 1 kHz の音なので Scope でそのまま見える。4 相の順は Logic で見る。

| 項目 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V (V− は使わない) |
| Wavegen W1 (LO の 4 倍) | Square、1.992 MHz、振幅 2.5 V、オフセット 2.5 V (0〜5 V)、デューティ 50 % |
| Wavegen W2 (RF) | Sine、499 kHz、振幅 0.25 V (0.5 V<sub>pp</sub>)、オフセット 2.5 V |
| Scope | CH1 = 1+ を A0、1− を A3 (I)。CH2 = 2+ を A1、2− を A2 (Q)。どちらも 200 mV/div、DC 結合。時間軸 200 µs/div、トリガは CH1 の立ち上がり 0 V |
| Scope (XY) | 表示を XY に。X = CH1 (I)、Y = CH2 (Q) |
| Logic | DIO0 = CLK、DIO1 = S0、DIO2 = S1。標本化 100 MHz、時間軸 400 ns/div、トリガは DIO0 の立ち上がり。DIO2・DIO1 を束ねたバスを 10 進で表示 |

- 74HC は 5 V で入力の H が 3.15 V 以上 (データシート)。W1 を 0〜5 V の方形波にするのはこのため
- Scope の入力は 1 MΩ ほどで GND へつながる。コンデンサを充電する R1 (1 kΩ) より 1000 倍大きいので、I と Q はほとんど変わらない
- 2.5 V の偏りは差動の 2 本に同じだけ乗るので、DC 結合のままで画面には出ない

## 計器の画面

計算値 (振幅は LTspice の 0.434 V peak)。I と Q の線には 498 kHz の切り替えの段が数 mV 乗るが、この尺度では見えない (計算値で約 5 mV<sub>pp</sub>)。

```scope
title: 図3 W2 = 499 kHz (LO より 1 kHz 上) — Q が I より 250 µs 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 434mV, range: 200mV/div}
ch2: {wave: sine 1kHz 434mV phase 90deg, range: 200mV/div}
cursors: [-250us, 0]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/22-tayloe-detector-1.svg)

- 図3 は CH1 = I、CH2 = Q。Q は I より 1/4 周期 (250 µs) 早く 0 V を上に横切る (カーソル X1)。Phase は +90.0° (進み)
- 振幅はどちらも 0.868 V<sub>pp</sub> (0.434 V peak)。W2 の 0.5 V<sub>pp</sub> の 1.74 倍

```scope
title: 図4 XY 表示 (W2 = 499 kHz) — 半径 0.434 V の円
view: xy
ch1: {wave: sine 1kHz 434mV, range: 200mV/div}
ch2: {wave: sine 1kHz 434mV phase 90deg, range: 200mV/div}
xy: ch1 ch2
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/22-tayloe-detector-2.svg)

- I を横、Q を縦にすると、振幅が等しく 90° ずれているので**円**になる (2-5 のリサージュ図形と同じ)。
  点は 1 秒に 1000 回、円を回る
- 499 kHz と 497 kHz では回る向きが逆だが、静止した画面では同じ円に見える。向きは図3 と図5 の時間の画面で確かめる
- 円がつぶれて楕円になったら、C1〜C4 の容量か、配線の長さが 4 つでそろっていない

```scope
title: 図5 W2 = 497 kHz (LO より 1 kHz 下) — Q が I より 250 µs 遅れる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 434mV, range: 200mV/div}
ch2: {wave: sine 1kHz 434mV phase -90deg, range: 200mV/div}
cursors: [0, 250us]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/22-tayloe-detector-3.svg)

- 図5 は図3 と同じ設定で、W2 だけを 497 kHz にした。音は同じ 1 kHz で、振幅も同じ。
  違うのは Q の位置だけで、I より 250 µs 遅れる (カーソル X2)。Phase は −90.0°
- この符号の違いで、RF が LO の上 (499 kHz) か下 (497 kHz) かが分かる。I だけを見ていたら分からない

```logic
title: 図6 74HC74 の 4 相 — CH (S1 S0) が 1 3 2 0 と回る
device: ad3
time: 400ns/div
sample: 100MHz
signals:
  CLK: dio0 clock 1.992MHz
  S: dio1..dio2 counter on CLK rising sequence 1 3 2 0 repeat
buses:
  CH: S1 S0 dec
cursors: [125ns, 2133ns]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/logic/22-tayloe-detector.svg)

- CLK (1.992 MHz) の立ち上がりごとに、S1 S0 を束ねたバス CH (= つながるチャネルの番号) が **1 → 3 → 2 → 0** と回る。
  A1 → A3 → A2 → A0 の順で、図の左端の立ち上がりから 4 状態で LO の 1 周期だ
- S0 と S1 はどちらも 498 kHz・デューティ 50 % で、S1 が S0 より 1 クロック (502 ns) 遅れる
- カーソルは同じ状態 (CH = 1) の真ん中に 1 周期あけて置いた。ΔX = **2.008 µs**、1/ΔX = **498.0 kHz** が LO の周波数
- 図は CLK の立ち上がりを t = 0 に置き、状態の変わり目を 74HC74 の遅れ (数十 ns) を除いて描いた。
  電源を入れたときにどの状態から始まるかは決まっていない。4 状態を同じ順に回ることだけが大事だ

## 見るべき値

計算値と LTspice (スイッチの模型で R<sub>on</sub> 80 Ω、W2 は振幅 0.25 V)。

| 確かめること | 期待する値 |
| --- | --- |
| LO の周波数 (Logic の 1/ΔX) | 498.0 kHz (1.992 MHz ÷ 4)。S0・S1 はデューティ 50 %、S1 が 502 ns 遅れる |
| 4 相の順 (Logic の CH) | 0 → 1 → 3 → 2 → 0 … (A0 → A1 → A3 → A2) |
| I と Q の周波数 (W2 = 499 kHz) | 1.000 kHz |
| I と Q の振幅 (1 kHz) | それぞれ 0.434 V peak (0.868 V<sub>pp</sub>)。入力の 1.74 倍 (+4.8 dB)。LTspice |
| Q と I の時間差 (W2 = 499 kHz) | Q が 250 µs 進む (+90°) |
| Q と I の時間差 (W2 = 497 kHz) | Q が 250 µs 遅れる (−90°)。振幅は同じ |
| XY 表示 | 半径 0.434 V の円 |
| W2 = 502 kHz (Δf 4 kHz) | 4 kHz、0.305 V peak (1 kHz より −3.1 dB)。LTspice |
| W2 = 508 kHz (Δf 10 kHz) | 10 kHz、0.156 V peak。LTspice |
| 低域の角 | 1 ÷ (2π · 4 · 1080 Ω · 10 nF) ≈ 3.7 kHz (計算値) |
| W2 = 498.000 kHz | I と Q が直流になる (ゼロ IF)。W2 の位相を変えると、XY の点が半径 0.45 V の円の上を動く (計算値) |
| W2 を止める (オフセット 2.5 V だけ) | I と Q が 0 V |
| A0 − A2 と A1 − A3 で組んだとき (誤り) | 2 本の位相差が 90° にならない (0° と 270° の差、90° と 180° の差を見ているため) |

## LTspice で確かめた値

デッキは `sim/22-tayloe-detector.cir` (過渡解析)。**74HC4052 は電圧制御スイッチの模型 (オン抵抗 80 Ω、切り替えの隙間 0.2 ns) で、実測ではない仮定**。
(S1, S0) の順 00 → 01 → 11 → 10 を、A0 → A1 → A3 → A2 の順に 1/4 周期ずつ開く制御で置き、I = A0 − A3、Q = A1 − A2 を読んだ。W2 は 2.5 V に 0.25 V peak、R1 1 kΩ、C1〜C4 は 10 nF。

| 確かめること | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| I・Q の振幅 (W2 = 499 kHz) | 0.434 V peak (1.74 倍) | 0.432 V peak (1.73 倍)、I と Q は同じ | 合う (0.4 % 差) |
| Q と I の先後 (499 kHz) | Q が 90° 進む | Q − I = +90.0° | 合う |
| Q と I の先後 (497 kHz) | Q が 90° 遅れる | Q − I = −90.0°、振幅は同じ | 合う |
| W2 = 502 kHz (Δf 4 kHz) | 0.305 V peak | 0.303 V peak | 合う |
| W2 = 508 kHz (Δf 10 kHz) | 0.156 V peak | 0.155 V peak | 合う |
| 切り替えの段 (I の 498 kHz 成分) | 約 5 mV<sub>pp</sub> | 3〜5 mV<sub>pp</sub> | 合う |
| 利得 1.80 倍と低域の角 3.7 kHz | 1.80 × 0.965 = 1.74 倍 | 1.73 倍 | 合う |

- 74HC74 の 4 相 (00 → 10 → 11 → 01) と、(S1, S0) = 00 → 01 → 11 → 10、チャネル 0 → 1 → 3 → 2 は、D フリップフロップの式 (D1 = /Q2、D2 = Q1) から手で追って確かめた。論理の動きは LTspice に入れていない (制御は理想のパルス)
- 4 つのコンデンサの容量が 1 つでも違うと円が崩れるのは、LTspice では回していない (本文の説明のまま)

## 出典

自作。Tayloe 検波器は Dan Tayloe の米国特許 6,230,000 (2001 年) の形を、AD3 で動く周波数に置き直した。
74HC4052 のピンの並び (PIN 13 = AN、PIN 12・14・15・11 = A0〜A3、PIN 10・9 = S0・S1、PIN 6 = E) とオン抵抗、
74HC74 の真理値表 (CLK の立ち上がりで D を Q へ、CLR・PRE は L で効く)、入力の H の電圧 (5 V で 3.15 V 以上) は
各社の 74HC4052・74HC74 のデータシートによる。振幅と低域の角は、4 個のスイッチと 1 kΩ・10 nF の模型の LTspice と、
1/4 周期の平均 (sin(π/4) ÷ (π/4)) からの計算値。
