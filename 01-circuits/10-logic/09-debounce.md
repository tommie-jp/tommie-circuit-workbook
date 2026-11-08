---
book: circuits
chapter: 10
id: 10-9
title: チャタリング除去 — RC + シュミット
tier: 200
source: 自作
---

# 10-9 チャタリング除去 — RC + シュミット

押しボタンの接点は、押した瞬間と離した瞬間に数 ms のあいだ跳ねて、オンとオフを何度も繰り返す (チャタリング)。
人の目には 1 回の押下でも、10-5 の T-FF や 10-6 の 74HC595 のような速いロジックは跳ねを 1 回ずつ数え、
1 回押しただけで 2 つ以上進む。

この題では、跳ねを RC (抵抗とコンデンサ) でならし、なまった電圧をシュミットトリガのインバータ 74HC14 で
きれいな 0 / 1 に戻す。比べるために、RC を通さない接点の電圧も同じ 74HC14 の別のインバータに入れ、
跳ねの数だけパルスが出ることを Analog Discovery 3 (AD3) のロジックアナライザで見る。

## この実験で確かめる式

ボタンを押すと、コンデンサ C1 の電圧 V<sub>B</sub> は R2 を通して τ<sub>押</sub> = R2 · C1 で 0 V へ下がる。
離すと R1 + R2 を通して τ<sub>離</sub> = (R1 + R2) · C1 で 5 V へ戻る。出力が切り替わるまでの遅れは

- 押したとき: t = τ<sub>押</sub> · ln(5 V ÷ V<sub>T−</sub>)
- 離したとき: t = τ<sub>離</sub> · ln(5 V ÷ (5 V − V<sub>T+</sub>))

V<sub>T+</sub> と V<sub>T−</sub> は 74HC14 の入力のしきい値 (上がるとき・下がるときに出力が切り替わる電圧)。
2 つの間が開いている (ヒステリシス) ので、なまった電圧がしきい値の近くでふらついても、出力は 1 回しか切り替わらない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 RC で跳ねをならし 74HC14 で 0 と 1 に戻す
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,1 2,3 10k
  SW: button 2,3 2,5 l=$\mathrm{SW}$
  GSW: ground 2,5
  R2: resistor 3,3 5,3 10k
  C1: capacitor 5,4 5,6 1u
  GC1: ground 5,6
  U1A: not 8,3 74HC14
  R3: resistor 10,3 12,3 330
  D1: led 12,3 12,5 red
  GD1: ground 12,5
  U1B: not 8,8 74HC14
  YRAW: port 11,8 out
wires:
  - 2,3 -- 3,3
  - 5,3 -- 5,4
  - 5,3 -- U1A.in
  - U1A.out -- 10,3
  - 3,3 -- 3,8 -- U1B.in
  - U1B.out -- 11,8
notes:
  - text 2.5,2.5 blue center: A
  - text 5.5,2.5 blue center: B
  - text 9,2.5 blue center: Y1
  - text 1,10 small left: "U1 は 74HC14 (14 番 VCC を +5V・7 番 GND)。使わない入力 5・9・11・13 番は GND"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/09-debounce.svg)

- 押していないとき、A は R1 (10 kΩ) で +5 V に引き上げられ、C1 (1 µF) は R1 と R2 を通して 5 V に充電されている。
  U1A (1 番入力・2 番出力) の入力 B は H なので、出力 Y1 は L で D1 は消えている
- SW を押すと A は 0 V。C1 は R2 を通して τ<sub>押</sub> = 10 kΩ × 1 µF = 10 ms で放電する。
  跳ねで接点が 0.3 ms 開いても、その間に B が戻るのは 20 kΩ × 1 µF = 20 ms の時定数でわずかで (LTspice で 4.6 V から 4.9 V ほど)、しきい値に届かない
- B が V<sub>T−</sub> を下回ると Y1 が H になり D1 が点く。離すと C1 は R1 + R2 で τ<sub>離</sub> = 20 ms で充電し、
  B が V<sub>T+</sub> を越えた所で Y1 が L に戻る
- U1B (3 番入力・4 番出力) は A をそのまま入れた比べ。跳ねのたびに A が 0 V と 5 V を行き来するので、
  出力 Yraw には跳ねの数だけパルスが出る
- R2 は、押した瞬間に C1 を接点で直接短絡しないための抵抗も兼ねる (R2 が無いと、5 V の C1 が接点を通して一気に放電する)
- しきい値は TI の SN74HC14 のデータシートで、電源 4.5 V の典型が V<sub>T+</sub> 2.5 V・V<sub>T−</sub> 1.6 V、
  6 V の典型が 3.3 V・2.0 V。5 V はその間を直線で読み、V<sub>T+</sub> ≈ 2.8 V・V<sub>T−</sub> ≈ 1.7 V とした (目安)。
  最小のヒステリシスは 4.5 V で 0.4 V なので、品によって遅れは下の表から数 ms ずれる
- 図1 の U1A・U1B は同じ 74HC14 (1 個に 6 回路) の中のインバータ。記号はふつうのインバータで描いた

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Scope で A と B、Logic で Yraw と Y1)
board: half
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies・Scope
    pins: [V+, GND, 1+, 1-, 2+, 2-]
  LA:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO1, DIO0]
  R1: resistor b1 b3 10k
  SW: button @ e3
  R2: resistor b5 b8 10k
  C1: capacitor/ceramic i8 i10 1u
  U1: dip14 @ e14 74HC14
  R3: resistor i15 i22 330
  D1: led g22(A) g25(K) red i=9mA
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t30 -- -b30 black
  - a1 -- +t1 red
  - j3 -- -b3 black
  - j10 -- -b10 black
  - e8 -- f8 orange
  - h8 -- h14 orange
  - d5 -- d12 yellow
  - e12 -- f12 yellow
  - g12 -- g16 yellow
  - a14 -- +t14 red
  - a15 -- -t15 black
  - a17 -- -t17 black
  - a19 -- -t19 black
  - j18 -- -b18 black
  - j20 -- -b20 black
  - j25 -- -b25 black
  - PS.1+ -- a5 blue
  - PS.1- -- -t6 black
  - PS.2+ -- a8 green
  - PS.2- -- -t9 black
  - LA.DIO0 -- j17 white
  - LA.DIO1 -- j15 purple
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/09-debounce.svg)

- 電源は AD3 の Supplies の V+ (5 V) を上の赤レールへ、GND を上の青レールへ。下の青レールは 30 列 (右端) で上とつなぐ
- SW (タクトスイッチ) は 3〜5 列で溝をまたぐ。上の 3 列と 5 列が A (中でつながっている)、下の 3 列が GND。
  R1 は 1 列 (+5 V) から 3 列へ、R2 は 5 列から 8 列 (B) へ。C1 は下のブロックで 8 列から 10 列 (GND) へ
- B は溝をまたぐオレンジの線 (8 列) と h 行の線で U1 の 1 番 (14 列の下) へ。
  A は黄の線で d 行を 12 列へ運び、溝をまたいで g 行の線で U1 の 3 番 (16 列の下) へ
- U1 (74HC14) は 14〜20 列、切り欠きが左で 1 番が左下 (f14)。14 番 (14 列の上) を +5 V、7 番 (20 列の下) を GND へ。
  使わない入力の 13 番 (15 列の上)・11 番 (17 列の上)・9 番 (19 列の上)・5 番 (18 列の下) は GND へ
- 2 番 (Y1、15 列の下) から R3 (330 Ω) と D1 を通して GND へ。4 番 (Yraw、17 列の下) は Logic の DIO0 だけにつなぐ
- AD3 の 1+ を A (5 列)、2+ を B (8 列) に挿す。Logic の DIO0 を Yraw (17 列)、DIO1 を Y1 (15 列) に挿す。
  AD3 の DIO は 3.3 V の入力で 5 V まで耐える (Analog Discovery の教科書の 7-1)

## 計器の設定

計器は AD3 の Supplies (+5 V)・Scope (A と B の電圧)・Logic (Yraw と Y1 の 0 / 1)。跳ねは 1 回ごとに形が違い、
繰り返さないので、Scope も Logic も Single (1 回だけ取り込む) にして、ボタンを押した瞬間を捕まえる。
図3・図4 は跳ねを仮定した計算の画面で、実測ではない (押した直後に 0.3〜0.6 ms と 1.0〜1.3 ms の 2 回開くとした)。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V、Master Enable を入れる |
| Scope CH1 (1+) | A。1 V/div、0 V を下から 1 目盛 |
| Scope CH2 (2+) | B。CH1 と同じ尺度 |
| Scope の時間 | 10 ms/div。トリガは CH1 の立ち下がり 2.5 V、Single。トリガの点を左から 1 目盛 |
| Scope のカーソル | X1 = 10.8 ms (B が V<sub>T−</sub> を下回る)、X2 = 66.4 ms (B が V<sub>T+</sub> を越える。離したのは 50 ms) |
| Logic | DIO0 (Yraw)・DIO1 (Y1)。標本化 1 MHz、2 ms/div、トリガは DIO0 の立ち上がり、Single |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 A (CH1) は押すと 0 V、B (CH2) は 10 ms と 20 ms の時定数でなまる (計算)
time: 10ms/div
trigger: ch1 falling 2.5V at -4div
ch1: {wave: = 5V*(1-step(t)) + 5V*(step(t-0.3ms)-step(t-0.6ms)+step(t-1ms)-step(t-1.3ms)) + step(t-50ms)*(5V-2.48V*exp(-(t-50ms)/20ms)), range: 1V/div, position: -3div}
ch2: {wave: = 5V*(1-step(t)) + step(t)*(1-step(t-50ms))*5V*exp(-t/10ms) + step(t-50ms)*(5V-4.97V*exp(-(t-50ms)/20ms)), range: 1V/div, position: -3div}
cursors: [10.8ms, 66.4ms]
measure: [vmax, vmin]
notes:
  - text ch2 10.8ms 1.7V: VT− 1.7 V
  - text ch2 66.4ms 2.8V: VT+ 2.8 V
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/09-debounce.svg)

- CH1 (A) は押した 0 ms で 0 V に落ち、跳ねの 2 回だけ 5 V に戻る (この時間軸では細い針)。
  50 ms で離すと 2.5 V まで跳ね上がり、そこから B の半分を足した値で 5 V へ戻る (A は R1 と R2 の真ん中なので)
- CH2 (B) は押すと 10 ms の時定数で下がり、カーソル X1 (10.8 ms) で V<sub>T−</sub> を切る。
  離すと 20 ms の時定数で上がり、X2 (66.4 ms、離してから 16.4 ms) で V<sub>T+</sub> を切る。跳ねは B にはほとんど出ない。
  図3 は跳ねで B が少し戻る分を入れていない。入れた LTspice では 11.4 ms と 16.9 ms (下の表)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 RC なしの Yraw は跳ねの数だけ立ち上がり、RC ありの Y1 は 1 回だけ (計算)
device: ad3
time: 2ms/div
start: -2ms
sample: 1MHz
signals:
  YRAW: dio0 edges -2ms=0 0s=1 300us=0 600us=1 1ms=0 1.3ms=1
  Y1:   dio1 edges -2ms=0 10.8ms=1
cursors: [1.3ms, 10.8ms]
trigger: YRAW rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/logic/09-debounce.svg)

- YRAW は 0・0.6・1.3 ms の 3 回立ち上がる。これをカウンタのクロックに入れると、1 回押しただけで 3 つ進む
- Y1 は 10.8 ms (跳ねを入れた LTspice では 11.4 ms) に 1 回だけ立ち上がる。押してから出力が変わるまで 11 ms ほど遅れるのが、RC で跳ねを消す代わりに払う値

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | シュミットトリガのインバータ (6 回路) | 74HC14 (DIP-14) |
| R1・R2 | 抵抗 (1/4 W)、プルアップと RC | 10 kΩ × 2 本 |
| C1 | 積層セラミックコンデンサ | 1 µF (105)、16 V 以上 |
| R3 | 抵抗 (1/4 W)、LED の電流制限 | 330 Ω |
| D1 | LED (赤) | 5 mm、V<sub>F</sub> 約 2.0 V |
| SW | タクトスイッチ | 1 個 |
| — | 電源・計器 | Analog Discovery 3 |

電流は、押している間の R1 が 5 V ÷ 10 kΩ = 0.5 mA、D1 が (5 V − 2.0 V) ÷ 330 Ω ≈ 9 mA (計算値)、74HC14 は数 µA。
合わせて 10 mA ほどで、ブレッドボードの範囲にも AD3 の Supplies にも収まる。R3 の電力は 9 mA² × 330 Ω ≈ 27 mW で 1/4 W の半分より小さい。

## 見るべき値

| 項目 | 計算 | 見る所 |
| --- | --- | --- |
| 押したときの時定数 τ<sub>押</sub> | R2 · C1 = 10 ms | B (CH2) の下がり方 |
| 離したときの時定数 τ<sub>離</sub> | (R1 + R2) · C1 = 20 ms | B (CH2) の上がり方 |
| 押してから Y1 が H になるまで | 10 ms × ln(5 ÷ 1.7) = 10.8 ms (跳ねの分で LTspice は 11.4 ms) | カーソル X1 |
| 離してから Y1 が L に戻るまで | 20 ms × ln(5 ÷ 2.2) = 16.4 ms (同 16.9 ms) | カーソル X2 − 50 ms |
| 1 回押したときの Yraw の立ち上がり | 跳ねの数 + 1 (図4 は 3 回) | Logic の DIO0 |
| 1 回押したときの Y1 の立ち上がり | 1 回 | Logic の DIO1 |

- 実物の跳ねの長さは、ボタンの種類で 1 ms 弱から 10 ms ほどまで違う。τ<sub>押</sub> は跳ねの長さより十分長く取る。
  Yraw が何度押しても 1 回しか立ち上がらないボタンなら、跳ねがほとんど無い品
- 10-5 の T-FF の CLK2 に Y1 をつなぐと、1 回押すごとにちょうど 1 回反転する。Yraw をつなぐと、反転の回数がばらつく
- 74HC04 (シュミットでないインバータ) に替えると、B がしきい値の近くをゆっくり通る間に出力が細かく振れることがある。
  ゆっくり変わる入力はシュミットで受ける、が 74HC14 を使う理由

## LTspice での確かめ

`sim/09-debounce.cir` で、ボタンを電圧で開閉するスイッチ (跳ねは上の仮定) に、74HC14 を LTspice の SCHMITT 素子
(しきい値 2.8 V / 1.7 V) に置き換えて流した。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 押してから Y1 が H | 計算 10.8 ms、跳ね込みで約 11 ms | 11.4 ms | 合う |
| 離してから Y1 が L | 計算 16.4 ms、跳ね込みで約 17 ms | 16.9 ms (66.9 ms − 50 ms) | 合う |
| 跳ねの間の B の最小 | しきい値 1.7 V より十分上 | 4.62 V | 合う |
| 離した直後 (接点が開いた) の A | 約 2.5 V | 2.54 V | 合う |
| Y1 の立ち上がりの数 | 1 回 | 1 回 (2 回目は無い) | 合う |
| Yraw の立ち上がりの数 (押したとき) | 3 回 | 3 回 (3 回目が 1.30 ms) | 合う |

離したときの跳ねは Yraw にも出ない。接点が開いた瞬間の A は約 2.5 V で、V<sub>T+</sub> と V<sub>T−</sub> の間に入るので、
シュミットの出力は B が 0.6 V を越えて A が 2.8 V に届くまで変わらない (LTspice では 53.0 ms に 1 回だけ下がる)。
これは R1 と R2 で A を半分に分ける、この回路の形のせいで、どのボタンでも離す側の跳ねが消えるとは限らない。

## 出典

自作。

参考: [SN74HC14 データシート](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf)、[チャタリング (Wikipedia)](https://ja.wikipedia.org/wiki/チャタリング)、[シュミットトリガ (Wikipedia)](https://ja.wikipedia.org/wiki/シュミットトリガ)
