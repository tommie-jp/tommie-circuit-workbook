---
book: etc
chapter: 2
id: 2-2
title: 中波ラジオの受信と AM 検波 — 2SC1815 の高周波増幅 2 段
tier: 200
source: 自作
board: [BB, PF]
---

# 2-2 中波ラジオの受信と AM 検波 — 2SC1815 の高周波増幅 2 段

全体の中の位置は [01-block.md](01-block.md) の ① 受信。NHK ラジオ第 1 放送 (東京は 594 kHz) を
トランジスタ回路で受け、AM 検波して音声信号にするまでを扱う。

## ブロック図

```plantuml
@startuml
top to bottom direction
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
skinparam rectangle {
  RoundCorner 6
}

rectangle "フェライトバー\nアンテナ + 同調回路\n(594 kHz を選ぶ)" as ANT
rectangle "高周波増幅 1 段目\n2SC1815" as RF1
rectangle "高周波増幅 2 段目\n2SC1815" as RF2
rectangle "AM 検波\n(ダイオード + 平滑)" as DET
rectangle "音声信号\n(次の ② へ)" as OUT #FDECEA

ANT --> RF1 : 微弱な高周波
RF1 --> RF2 : 増幅した AM 波
RF2 --> DET : AM 波
DET --> OUT
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/plantuml/02-radio.svg)

## 回路図

```circuit
title: 図1 中波 AM 受信機 (同調、高周波増幅 2 段、AM 検波)
parts:
  VC1: capacitor-var e3 g3 l=$\mathrm{VC}_1$
  La: inductor e5 g5 l=$L_{1a}$
  Lb: inductor g5 i5 l=$L_{1b}$
  GL: ground i5
  C1: capacitor e7 e9 0.01u
  R1: resistor a11 c11 82k
  VCC1: vcc a11 5V
  R2: resistor g11 i11 22k
  GR2: ground i11
  Q1: npn f14
  Rc1: resistor a14 c14 2.2k l=$R_{C1}$ i=$I_C$
  VCC2: vcc a14 5V
  RE1: resistor h14 j14 470 l=$R_{E1}$ i=$I_E$
  CE1: ecap h16 j16 100u l=$C_{E1}$
  GE1: ground j15
  C2: capacitor d16 d18 0.01u
  R3: resistor a21 c21 82k
  VCC3: vcc a21 5V
  R4: resistor g21 i21 22k
  GR4: ground i21
  Q2: npn f24
  Rc2: resistor a24 c24 2.2k l=$R_{C2}$ i=$I_C$
  VCC4: vcc a24 5V
  RE2: resistor h24 j24 470 l=$R_{E2}$ i=$I_E$
  CE2: ecap h26 j26 100u l=$C_{E2}$
  GE2: ground j25
  D1: diode d26 d28 1N60
  C4: capacitor d30 f30 0.01u
  GC4: ground f30
  R5: resistor d32 f32 100k i=$I$
  GR5: ground f32
  OUT: port d34
wires:
  - e3 -- e5
  - g3 -- i3 -- i5
  - g5 -| e7
  - e9 -- e11
  - c11 -- g11
  - f11 -- Q1.B
  - c14 -- d14
  - d14 -- Q1.C
  - Q1.E -- h14
  - j14 -- j15 -- j16
  - h14 -- h16
  - d14 -- d16
  - d18 -- d21
  - c21 -- g21
  - f21 -- Q2.B
  - c24 -- d24
  - d24 -- Q2.C
  - Q2.E -- h24
  - j24 -- j25 -- j26
  - h24 -- h26
  - d24 -- d26
  - d28 -- d34
notes:
  - text c5 small center: フェライトバー
  - text e11a8 small blue left: 約 1.0 V
  - arrow e11a7 e11a1 blue
  - text e14a8 small blue left: 約 3.4 V
  - arrow e14a7 e14a1 blue
  - text g13a2 small blue right: 約 0.34 V
  - arrow g13a3 g14 blue
  - text h14d6 small blue left: 0.73 mA
  - text a14f6 small blue left: 0.73 mA
  - text e21a8 small blue left: 約 1.0 V
  - arrow e21a7 e21a1 blue
  - text e24a8 small blue left: 約 3.4 V
  - arrow e24a7 e24a1 blue
  - text g23a2 small blue right: 約 0.34 V
  - arrow g23a3 g24 blue
  - text h24d6 small blue left: 0.73 mA
  - text a24f6 small blue left: 0.73 mA
  - text c30 small blue center: 約 3 V (直流)
  - arrow c30f0 d30 blue
  - text d32d6 small blue left: 30 µA
  - text j26f0 small blue left: 青い数字は計算値 (hFE 200、無信号のとき)。電圧は GND から
style:
  grid: off
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/circuit/02-radio.svg)

左から、同調回路、高周波増幅 1 段目 (Q1)、2 段目 (Q2)、AM 検波 (D1) の順に並べた。
電源は 5 V の単電源で、電源の記号は 4 か所に分けて置いた。

## 実体配線図

```bread
title: 図2 中波 AM 受信機のブレッドボード
board: half
parts:
  PS:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  BAR:
    type: device
    at: top
    label: フェライトバー
    pins: [TOP, TAP, GND]
  VC1:
    type: device
    at: top
    label: バリコン 365pF
    pins: [A, B]
  OUT:
    type: device
    at: top
    label: 検波出力 OUT
    pins: [OUT, GND]
  C1: capacitor/ceramic d4 d7 0.01u
  R2: resistor a6 -t6 22k
  R1: resistor a7 +t7 82k
  Q1: transistor e7(B) e10(C) e13(E) 2SC1815
  Rc1: resistor a10 +t10 2.2k
  RE1: resistor a13 -t13 470
  CE1: capacitor/electrolytic a14 -t14 100u
  C2: capacitor/ceramic d10 d19 0.01u
  R4: resistor a17 -t17 22k
  R3: resistor a19 +t19 82k
  Q2: transistor e19(B) e21(C) e23(E) 2SC1815
  Rc2: resistor a21 +t21 2.2k
  RE2: resistor a23 -t23 470
  CE2: capacitor/electrolytic a24 -t24 100u
  D1: diode d21(A) d27(K) 1N60
  C4: capacitor/ceramic a27 -t27 0.01u
  R5: resistor a29 -t29 100k
wires:
  - PS.+5V -- +t1 red
  - PS.GND -- -t1 black
  - BAR.TOP -- a5 yellow
  - VC1.A -- c5 yellow
  - VC1.B -- -t2 black
  - BAR.GND -- -t3 black
  - BAR.TAP -- a4 purple
  - c6 -- c7 blue
  - b13 -- b14 green
  - c17 -- c19 blue
  - c23 -- c24 green
  - c27 -- c28 white
  - d28 -- d29 white
  - OUT.OUT -- b28 white
  - OUT.GND -- -t30 black
notes:
  - arrow f7 e7 blue
  - text f7 tiny blue bold right: 約 1.0 V
  - arrow f10 e10 blue
  - text f10 tiny blue bold right: 約 3.4 V
  - arrow f13 e13 blue
  - text f13 tiny blue bold right: 約 0.34 V
  - arrow f19 e19 blue
  - text f19 tiny blue bold right: 約 1.0 V
  - arrow f21 e21 blue
  - text f21 tiny blue bold right: 約 3.4 V
  - arrow f23 e23 blue
  - text f23 tiny blue bold left: 約 0.34 V
  - arrow f27 e27 blue
  - text f27 tiny blue bold right: 約 3 V
  - circle c10 green
  - text c11 small green left: CH2
  - circle e27 orange
  - text e28 small orange left: CH1
  - circle -t15 ink
  - text tiny blue: "青い数字は計算値 (hFE 200、無信号のとき)。電圧は GND から"
  - text tiny ink: "オシロ (AD3): 橙の丸は CH1 (検波出力)、緑の丸は CH2 (Q1 のコレクタ)、黒い丸は GND"
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/breadboard/02-radio.svg)

```perf
title: 図2b 中波 AM 受信機のユニバーサル基板
board: 7x5cm
parts:
  BAR:
    type: device
    at: s1
    label: フェライトバー
    pins: TAP GND TOP
  VC1:
    type: device
    at: s6
    label: バリコン 365pF
    pins: A B
  PS:
    type: device
    at: s23
    label: 電源 5V
    pins: GND +5V
  OUT:
    type: device
    at: s19
    label: 検波出力 OUT
    pins: GND OUT
  C1: capacitor/ceramic h1 h4 0.01u
  R1: resistor b5 g5 82k
  R2: resistor h5 q5 22k
  Q1: transistor i7 h7 g7 2SC1815
  Rc1: resistor b7 f7 2.2k
  RE1: resistor j7 q7 470
  CE1: capacitor/electrolytic j9 q9 100u
  C2: capacitor/ceramic g9 g12 0.01u
  R3: resistor b13 f13 82k
  R4: resistor g13 q13 22k
  Q2: transistor h15 g15 f15 2SC1815
  Rc2: resistor b15 e15 2.2k
  RE2: resistor i15 q15 470
  CE2: capacitor/electrolytic i17 q17 100u
  D1: diode f19 j19 1N60
  C4: capacitor/ceramic j21 q21 0.01u
  R5: resistor j23 q23 100k
wires:
  - BAR.TAP -- h1
  - BAR.GND -- q2
  - VC1.B -- q7
  - PS.+5V -- b24 red
  - b24 -- b15 red
  - PS.GND -- q23 black
  - OUT.GND -- q19 black
  - OUT.OUT -- j20
  - BAR.TOP -- VC1.A
  - h4 -- h5
  - g5 -- h5
  - h5 -- h7
  - f7 -- g7
  - i7 -- j7
  - j7 -- j9
  - g7 -- g9
  - b5 -- b7 red
  - b7 -- b13 red
  - b13 -- b15 red
  - q2 -- q5 black
  - q5 -- q7 black
  - q7 -- q9 black
  - q9 -- q11 black
  - q11 -- q13 black
  - q13 -- q15 black
  - q15 -- q17 black
  - q17 -- q19 black
  - q19 -- q21 black
  - q21 -- q23 black
  - g12 -- g13
  - f13 -- g13
  - g13 -- g15
  - e15 -- f15
  - h15 -- i15
  - i15 -- i17
  - f15 -- f19
  - j19 -- j20
  - j20 -- j21
  - j21 -- j23
notes:
  - mark j20 orange
  - text k22 orange: CH1
  - mark g7 green
  - text f9 green: CH2
  - mark q11 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/perfboard/02-radio.svg)

図2 はブレッドボード、図2b は同じ回路をユニバーサル基板に組む図。次の説明は図2 のもので、図2b は「ユニバーサル基板に組むとき」に書く。

半分の大きさ (30 列) のブレッドボード 1 枚に収まる。電源の 5 V は左上から、上の赤いレール (+) と青いレール (−) の
左端へ入れる。部品の電源側と GND 側のピンは、それぞれのレールまで縦に 1 本で届く。

| 場所 | 挿すもの |
| --- | --- |
| 1 列 (上のレール) | 電源の + (赤) と GND (黒) |
| 2・3 列 (上のレール) | VC1 の B 端子とフェライトバーの GND (黒)。どちらも − レール |
| 4 列 | フェライトバーのタップ (紫) を `a4` に、C1 の左リードを `d4` に |
| 5 列 | フェライトバーの TOP (黄) を `a5` に、バリコンの A (黄) を `c5` に。同じ 5 列の別の穴に挿す |
| 6・7 列 | R2 (`a6` から − レール)、R1 (`a7` から + レール)、C1 の右リード (`d7`)、Q1 のベース (`e7`)。6 列と 7 列は青い線 (`c6`〜`c7`) でつなぐ |
| 10 列 | Q1 のコレクタ (`e10`)、Rc1 (`a10` から + レール)、C2 の左リード (`d10`) |
| 13・14 列 | Q1 のエミッタ (`e13`)、RE1 (`a13` から − レール)、CE1 (`a14` から − レール)。緑の線 (`b13`〜`b14`) でつなぐ |
| 17〜19 列 | R4 (`a17` から − レール)、R3 (`a19` から + レール)、C2 の右リード (`d19`)、Q2 のベース (`e19`)。17 列と 19 列は青い線 (`c17`〜`c19`) |
| 21 列 | Q2 のコレクタ (`e21`)、Rc2 (`a21` から + レール)、D1 のアノード (`d21`) |
| 23・24 列 | Q2 のエミッタ (`e23`)、RE2 (`a23` から − レール)、CE2 (`a24` から − レール)。緑の線 (`c23`〜`c24`) |
| 27〜30 列 | D1 のカソード (`d27`)、C4 (`a27` から − レール)。27 列から 28 列へ白い線 (`c27`〜`c28`)、28 列から 29 列へ白い線 (`d28`〜`d29`) で渡し、R5 (`a29` から − レール) をつなぐ。**検波出力は 28 列の `b28` から、ユニバーサル基板の外の OUT へ白い線で出す。OUT の GND は黒い線で `-t30` へ** |

- 線の色は、赤が + の電源、黒が GND だけ。黄は同調回路の上端 (バリコンの A とフェライトバーの TOP)、紫はフェライトバーのタップ、青はベース、緑はエミッタ、白は検波出力
- 青い矢印と数字は、各節点の電圧の計算値 (回路図の値と同じ)。トランジスタのピン (B・C・E) と、検波の出力 (27 列) を指す。組んだら、テスターで GND との間を測って見比べる
- 電解コンデンサ (CE1、CE2) は + をエミッタ側 (`a` 行側) に、− をレール側にする
- 2SC1815 のピンは、平らな面を手前にして左から E・C・B。図の B・C・E の並びは、平らな面を向こう側にしたときの順
- フェライトバーのタップは、接地側から巻数の 6 分の 1 ほどの所から出す。コイルの両端 (TOP と GND) は、バリコンの A と B に並べてつなぐ。バリコンの A とフェライトバーの TOP は、同じ列の別の穴に挿して線を重ねない
- ユニバーサル基板に載せる回路の周波数は 540 kHz〜1.6 MHz で、ユニバーサル基板の目安の 3 MHz 以下に収まる。電源から出る電流は、計算で 2 つの Q の電流とバイアスの電流を合わせて約 1.6 mA (見積り)
- 高周波の部分 (4〜29 列) の線は、できるだけ短く。長いと出力が入力へ回り込んで発振しやすい

### ユニバーサル基板に組むとき

図2b は図2 と同じ回路で、ネットリストも同じ (check で突き合わせて、全部の節点が一致した)。ブレッドボードは接触が揺れやすく、
高周波の 2 段は回り込みで発振しやすいので、組み上げて残したいときは半田付けで固定する。

- ユニバーサル基板は 5×7 cm (24 列 × 18 行を横に置く)。部品と線が収まる一番小さい在庫のユニバーサル基板で、外周の 1 穴と電源の筋の行が残る。
  厚みと基材は書いていないので 1.6 mm の FR-4 (両面スルーホール)
- 図は部品面から見たもの。部品は表に挿し、線は裏で半田付けする。部品のピンを線のつもりで曲げて届かせ、ピンで届かない所は被覆線で渡す
- 電源の + は上の行 (`b`、赤) に 5 列から 24 列まで 1 本の筋で通し、GND は下の行 (`q`、黒) に 2 列から 23 列まで通す。各部品は、電源側のピンを上、GND 側のピンを下にして縦に立てる
- ユニバーサル基板の外の電源は右下。+5 V は右端の 24 列を真上へ上げて筋につなぎ、GND は 23 列で下の筋につなぐ
- フェライトバーの TAP は 1 列を上へ上げて C1 の左リード (`h1`) に、GND は下の筋の左端 (`q2`) につなぐ。バリコンの B は `q7`。バリコンの A とフェライトバーの TOP はユニバーサル基板に載せず、ユニバーサル基板の外で直接つなぐ (図2 と同じ)
- 検波出力は 20 列を上へ上げて `j20` につなぐ。この線は下の GND の筋 (`q` 行) を渡るので、被覆線にする。OUT の GND は `q19` につなぐ
- 線の交差は、このほかに無い。ベースの 4 つのピン (C1・R1・R2・Q) は `h5` に集め、短い線で隣の穴へつなぐ
- 2SC1815 はピンを曲げて、上から C・B・E の順に 3 つの穴 (`g`・`h`・`i` 行) へ挿す。向きは図2 の 2SC1815 と同じ (平らな面を手前にして左から E・C・B)
- 電解コンデンサ (CE1、CE2) の + は上側 (エミッタ側)、− は下の GND の筋の側
- 橙の丸 (`j20`) はオシロの CH1、緑の丸 (`g7`) は CH2、黒い丸 (`q11`) は GND のクリップ

| 場所 | 挿すもの |
| --- | --- |
| `b` 行 | + の筋。R1 (`b5`)、Rc1 (`b7`)、R3 (`b13`)、Rc2 (`b15`) の上のピン。電源は `b24` |
| `q` 行 | GND の筋。R2 (`q5`)、RE1 (`q7`)、CE1 (`q9`)、R4 (`q13`)、RE2 (`q15`)、CE2 (`q17`)、C4 (`q21`)、R5 (`q23`) の下のピン |
| 1〜4 列 | C1 (`h1`〜`h4`)。左の `h1` に TAP の線が来る |
| 5 列 | R1 (`b5`〜`g5`)、R2 (`h5`〜`q5`)。`g5` と `h5` を短い線でつなぐ |
| 7 列 | Rc1 (`b7`〜`f7`)、Q1 (`g7` が C、`h7` が B、`i7` が E)、RE1 (`j7`〜`q7`) |
| 9〜12 列 | CE1 (`j9`〜`q9`)、C2 (`g9`〜`g12`) |
| 13 列 | R3 (`b13`〜`f13`)、R4 (`g13`〜`q13`) |
| 15 列 | Rc2 (`b15`〜`e15`)、Q2 (`f15` が C、`g15` が B、`h15` が E)、RE2 (`i15`〜`q15`) |
| 17 列 | CE2 (`i17`〜`q17`) |
| 19〜23 列 | D1 (`f19` が A、`j19` が K)、C4 (`j21`〜`q21`)、R5 (`j23`〜`q23`)。`j19`〜`j23` を線でつなぎ、検波出力を `j20` から出す |

この図は、組んで確かめていない。電圧 5 V、電流は約 1.6 mA、周波数は 540 kHz〜1.6 MHz なので、ユニバーサル基板の範囲 (12 V 以下、500 mA 以下、10 MHz 以下) に収まる。

### オシロスコープで調べる場所

**計器は Analog Discovery 3 (AD3) に決める。** 見たいのは 440 Hz の音声と 594 kHz の搬送波で、どちらも AD3 の範囲 (30 MHz まで) に入る。入力は 1 MΩ で、Q1 のコレクタ (2.2 kΩ) に当てても負荷がほとんど増えず、FFT の分解能 (最小 23 Hz) で 440 Hz 離れた側波も分けられる。tinySA Ultra は使わない。入力が 50 Ω で、高インピーダンスの節点に直接つなげない。通常モードが 100 kHz からなので、440 Hz の音声が見えない。分解能 (RBW) の最小も 200 Hz で、側波を分けにくい。

Analog Discovery 3 のオシロスコープを使う。プローブの先を次の場所に当て、GND のクリップを黒い丸の − レール (15 列) につなぐ。

| チャンネル | 場所 (図の丸) | 見えるもの |
| --- | --- | --- |
| CH1 (橙) | 27 列の `e27` (検波出力) | 約 3 V の直流に、放送の音声 (包絡線) が乗る |
| CH2 (緑) | 10 列の `c10` (Q1 のコレクタ) | 約 3.4 V の直流に、594 kHz の AM 波が乗る。同調を合わせると振幅が大きくなる |
| GND クリップ | 15 列の − レール | 基準 (0 V) |

- 値は計算値の動作点 (図の青い数字) で、**波の大きさは受信した電波の強さで変わる** (測っていない)
- CH2 のプローブは、高周波の部分に容量 (数 pF〜十数 pF) を足すので、同調が少しずれる。測るときだけ当て、離したら合わせ直す
- 音声の周波数 (数 100 Hz〜数 kHz) と搬送波 (594 kHz) は大きく違うので、時間軸を変えて見る。CH1 は 1 ms/div、CH2 は 2 µs/div

見えるはずの画面 (推測) を、scope フェンスで描いた。**波の大きさは仮の値で、実測ではない**。直流分 (CH1 は約 3 V、CH2 は約 3.4 V) は、画面の中央を波の中心にして描き、図の下の読み値 (Avg) に出る。AD3 では、波を見やすくするため、CH を AC 結合にするか、オフセットを合わせる。

```scope
title: 図3 CH1 検波出力 (時報の 440 Hz が出ているとき、推測)
time: 1ms/div
trigger: ch1 rising 3V
ch1: sine 440Hz 50mV offset 3V
measure: [vpp, freq, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/scope/02-radio-1.svg)

- 時報の 440 Hz が出ているあいだ、検波出力に 440 Hz の正弦波 (周期 約 2.3 ms) が乗る。振幅は仮に 50 mV (100 mVpp)
- 放送の音声は一定の高さではないので、普段の番組では、この形にはならない

```scope
title: 図4 CH2 Q1 のコレクタ (594 kHz の搬送波、推測)
time: 2us/div
trigger: ch2 rising 3.4V
ch2: sine 594kHz 100mV offset 3.4V
measure: [vpp, freq, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/scope/02-radio-2.svg)

- 搬送波の周期は 約 1.68 µs なので、画面 (20 µs) に約 12 周期が入る。振幅は仮に 100 mV (200 mVpp)
- 振幅は、音声の強さに合わせて、ゆっくり (数 ms の周期で) 大きくなったり小さくなったりする (AM 変調)。2 µs/div の画面では、この変化は見えない。時間軸を 1 ms/div にすると、搬送波が密に並んだ帯になり、帯の太さが音声に合わせて変わる

### Analog Discovery 3 の FFT (スペクトル) で見る

同じ 2 つの場所を、WaveForms の Spectrum (FFT) でも見られる。波形では見えない**搬送波と側波の高さ**が分かる。見えるはずの画面 (推測) を、spectrum フェンスで描いた。**振幅は仮の値 (CH1 は 50 mV、CH2 は 100 mV、変調度は 0.3) で、実測ではない。** 実測したら WaveForms の CSV を題のファイルの隣に置き、`data:` で重ねる。

```spectrum
title: 図5 CH1 検波出力のスペクトル (440 Hz の音声、推測)
device: ad3
sweep: 0-1kHz
samples: 8192
window: hann
unit: dBV
ref: -10dBV
signal: sine 440Hz 50mV
markers: [440Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/spectrum/02-radio-1.svg)

- 440 Hz に山が 1 本立つ。50 mV (peak) の正弦波は −29.03 dBV (読み値)。1 V (peak) の正弦波が −3.01 dBV にあたる
- 検波出力の直流分 (約 3 V) は 0 Hz に大きな線として出る。見やすくするため、CH1 を AC 結合にして測る

```spectrum
title: 図6 CH2 Q1 のコレクタのスペクトル (搬送波と AM の側波、推測)
device: ad3
center: 594kHz
span: 4kHz
samples: 65536
window: hann
unit: dBV
ref: -10dBV
signal:
  - sine 594kHz 100mV
  - sine 593.56kHz 15mV
  - sine 594.44kHz 15mV
markers: [594kHz, 593.56kHz, 594.44kHz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/spectrum/02-radio-2.svg)

| マーカー | 周波数 | レベル (読み値) | 意味 |
| --- | --- | --- | --- |
| 1 | 約 594 kHz | −23.06 dBV | 搬送波 (100 mV) |
| 2 | 約 593.56 kHz | −39.70 dBV | 下側の側波 (594 kHz − 440 Hz) |
| 3 | 約 594.44 kHz | −39.49 dBV | 上側の側波 (594 kHz + 440 Hz) |

- 側波は、搬送波から**音声の周波数 (440 Hz) だけ離れて**両側に出る。高さは、変調度 m = 0.3 のとき搬送波の m ÷ 2 = 0.15 倍で、**搬送波より約 16.5 dB 低い**
- 音声が強いほど (変調度が大きいほど) 側波が高くなる。同調が合っていると、側波も同じように増幅される
- FFT の分解能は、掃引の幅と標本数で決まる (図 5 は 0.3125 Hz、図 6 は 23.28 Hz)。440 Hz 離れた側波を分けるには、分解能が側波の間隔より十分細かいことが要る

## 動作

1. **同調**: フェライトバーに巻いたコイル L1 (La + Lb) と可変コンデンサ VC1 が並列共振する。
   VC1 を回して NHK 第 1 (東京は 594 kHz) の周波数に合わせる。信号はコイルのタップ (La と Lb の境) から取り出す。
   タップにすると、次段の入力抵抗が共振回路に与える負荷が軽くなり、同調がなまりにくい。
2. **高周波増幅**: Q1、Q2 は共通エミッタの増幅で、ベースは R1 と R2 (R3 と R4) の分圧でバイアスする。
   RE と CE (100 µF) でエミッタを高周波的に接地して利得を稼ぐ。段間は C2 (0.01 µF) で結ぶ。
3. **AM 検波**: Q2 のコレクタの信号を D1 (1N60) で半波整流し、C4 と R5 で平滑して包絡線 (音声) を取り出す。
   出力には直流の約 3 V が乗るので、次の ([03-detect.md](03-detect.md)) では AC 結合で受ける。

## 部品表

| 部品 | 値 | 備考 |
| --- | --- | --- |
| Q1, Q2 | 2SC1815 (GR) | NPN。ピンは平らな面を手前にして左から E・C・B |
| D1 | 1N60 | ゲルマニウムの検波ダイオード。順方向の電圧降下が小さく、小さな信号に向く |
| R1, R3 | 82 kΩ | ベースの上側の抵抗 |
| R2, R4 | 22 kΩ | ベースの下側の抵抗 |
| RC1, RC2 | 2.2 kΩ | コレクタの負荷 |
| RE1, RE2 | 470 Ω | エミッタの抵抗 |
| R5 | 100 kΩ | 検波の負荷 |
| C1, C2 | 0.01 µF | 結合 (セラミック) |
| C4 | 0.01 µF | 検波の平滑 (セラミック) |
| CE1, CE2 | 100 µF 16 V | 電解。+ をエミッタ側にする |
| VC1 | 365 pF のバリコン (AM 用) | 同調 |
| L1 (La + Lb) | 手巻きのコイル | フェライトバーに巻く。全体で約 260 µH を目安に巻数で合わせる。タップは接地側から巻数の 6 分の 1 ほど |

参考にした回路図 (R1 22 kΩ、RC 4.7 kΩ、RE 1 kΩ) は、5 V で動かすとトランジスタが飽和するので、
バイアスを計算し直して上の値にした。

## 動作点の見積り (計算値)

hFE を 200、ベースとエミッタの間を 0.65 V と仮定した計算値で、実機では測っていない。

| 項目 | 値 |
| --- | --- |
| ベースの分圧 (無負荷) | 5 V × 22 / (82 + 22) = 約 1.06 V |
| コレクタ電流 | 約 0.73 mA |
| エミッタの電圧 | 約 0.34 V |
| コレクタの電圧 | 5 V − 0.73 mA × 2.2 kΩ = 約 3.4 V |
| コレクタとエミッタの間 | 約 3.1 V (飽和していない) |
| 検波の出力の直流 | 約 3 V (コレクタの電圧から 1N60 の降下を引いた値) |

同調の計算値 (L1 を 260 µH としたとき): 540 kHz で VC1 約 330 pF、594 kHz で約 270 pF、
1600 kHz で約 38 pF。実際は配線とトランジスタの容量が加わるので、巻数で合わせる。

## 調整と注意

- 2 段で利得が大きいので、発振して笛のような音がするときは、電源に 100 µF と 0.1 µF を
  並べて足し、2 段を離して組む。
- 近くの強い局に引かれるときは、タップの位置を接地側へ寄せる。
- 巻数とバリコンの値は、手元のフェライトバーで合わせる (見積りは目安)。
