---
book: circuits
chapter: 9
id: 9-10
title: スーパーヘテロダイン (6 石、IF 455kHz)
tier: 200
source: 自作
board: BB
era: 古
---

# 9-10 スーパーヘテロダイン (6 石、IF 455kHz)

9-3 や 9-9 のラジオは、受けたい局の周波数のまま増幅して検波する (ストレート方式)。
同調を鋭くしようとタンクを増やすと、全部を同時に動かすのが難しい。
**スーパーヘテロダイン**は、受けた電波をいったん**決まった周波数 (中間周波、IF = 455kHz) に変換**してから増幅する。
IF は局によらず同じなので、455kHz に固定した同調 (IFT、中間周波トランス) を何段も重ねて、利得と選択度を稼げる。
昭和のトランジスタラジオの定番、6 石スーパーを 5 V で組む (「石」はトランジスタの数)。

6 石の内訳は、周波数変換 (Q1)・中間周波増幅 2 段 (Q2・Q3)・低周波のドライブ (Q4)・
プッシュプル出力 (Q5・Q6)。検波はダイオード (D1) で、石には数えない。

この題の流れは次のとおり。

- 回路図は信号の順に 3 枚 (図1 周波数変換、図2 中間周波増幅と検波、図3 低周波増幅)
- 図1 のあとに、2 連バリコンで局発を追従させる「トラッキング」と、スーパー特有の混信「イメージ周波数」を説明する
- 実体配線図も同じ 3 枚のブレッドボードに分ける (図4〜図6)
- Analog Discovery の W1 で作った AM 信号を入れ、同じ Analog Discovery の Spectrum で Q1 のコレクタのスペクトル (図7)、オシロで検波の前後 (図8) を見る

## 回路図

1 枚では詰まるので、信号の順に 3 枚に分けた。図1 の端子 IF・IFB は図2 の同じ名前の端子へ、図2 の AF は図3 の AF へつながる。

```circuit
title: 図1 周波数変換 局発とミキサーを1石で
parts:
  W1: sine 2,5 2,7 l=$\mathrm{W1}$
  GW1: ground 2,7
  Cw: capacitor 2,3 4,3 10p
  VC1a: capacitor-var 5,3 5,7 l=$\mathrm{VC}_{1a}$
  GVa: ground 5,7
  T1: transformer 7,5
  VCC: vcc 9,6 5V
  R1: resistor 9,6 9,8 33k
  R2: resistor 8,8 8,10 10k
  GR2: ground 8,10
  Cb: capacitor 6,8 6,10 0.01u
  GCb: ground 6,10
  Q1: npn 11,5
  Re: resistor 11,8 11,10 1k
  GRe: ground 11,10
  Cc2: capacitor 12,8 13,8 0.01u
  T2: transformer 15,5
  VCC: vcc 15,3 5V
  Cp: capacitor 17,7 17,9 270p
  VC1b: capacitor-var 17,9 17,11 l=$\mathrm{VC}_{1b}$
  GVb: ground 17,11
  T3: transformer 20,5
  Ci1: capacitor 18,4 18,7 180p l=$\mathrm{C}$
  IF: port 22,4
  IFB: port 22,7
wires:
  - 2,5 -- 2,3
  - 4,3 -- 5,3
  - 5,3 -| T1.A1
  - T1.A2 |- 5,7
  - T1.B1 -| 10,5
  - 10,5 -- Q1.B
  - T1.B2 -| 8,8
  - 6,8 -- 8,8
  - 8,8 -- 9,8
  - Q1.E -- 11,8
  - 11,8 -- 12,8
  - 13,8 -| T2.A2
  - T2.A1 -| 14,3
  - 14,3 -- 15,3
  - 15,3 -- 16,3
  - T2.B1 -| 16,3
  - T2.B2 -| 17,7
  - 17,7 -- 18,7
  - 18,7 -- 19,7
  - 19,7 -| T3.A2
  - Q1.C -- 11,1
  - 11,1 -- 19,1
  - 19,1 -- 19,4
  - 19,4 |- T3.A1
  - 18,4 -- 19,4
  - T3.B1 -| 22,4
  - T3.B2 -| 22,7
notes:
  - text 7,2 small center: バーアンテナ
  - text 15.5,2 small center: 局発コイル (赤)
  - text 20,8 small center: IFT1 (黄)
  - box 17,3 20,7 blue
  - text 19.5,2 small blue left: IFT に内蔵 180pF
  - arrow 13,2.5 13,1 green
  - text 13,2.5 small green right: スペアナ
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/10-superheterodyne-1.svg)

- **局発の周波数は受信周波数 + 455kHz**: 局発は局部発振器 (LO) の略で、ラジオの中で作る発振。f<sub>LO</sub> = f<sub>RF</sub> + f<sub>IF</sub>。
  1000kHz の局なら f<sub>LO</sub> = 1455kHz。Q1 は局発 (発振) とミキサーを 1 石で兼ねる (自励式コンバータ)
- **発振**: T2 (局発コイル、赤) の 1 次 (図の左の巻線) は Q1 のエミッタへ Cc2 で帰還し、2 次 (右の巻線) は Cp と VC1b とでタンクを作る。
  コレクタ電流が T2 の 2 次を通るので、コレクタとエミッタが巻線でつながり、発振が続く。
  発振しないときは T2 の片方の巻線の向きを入れ替える (帰還の向きが逆)。
  実物の局発コイルはタップ付きの 3 端子 + 2 端子で、図は巻線 2 つに略した
- **ミキサー**: ベースには T1 (バーアンテナ) からの RF、エミッタには LO が入る。
  トランジスタの V<sub>BE</sub>–I<sub>C</sub> は曲がっている (指数) ので、コレクタ電流には
  f<sub>RF</sub>・f<sub>LO</sub> のほか、**差 f<sub>LO</sub> − f<sub>RF</sub> = 455kHz** と和 (2455kHz) が出る。
  T3 (IFT1、黄) が 455kHz にだけ同調しているので、差だけが次の段へ渡る
- **バイアス**: R1 (33kΩ)・R2 (10kΩ) でベースは 5 × 10/43 ≈ 1.16V。
  I<sub>E</sub> = (1.16 − 0.6)/1kΩ ≈ 0.56mA (V<sub>BE</sub> = 0.6V と置いた計算値)。
  コンバータは電流を絞るほうが雑音が少なく、発振も穏やか
- **W1 と Cw (10pF)**: 放送の代わりに、Analog Discovery の W1 で作った AM 信号を小さな容量でタンクへ入れる (設定は「計器の設定」の表)。
  放送を聞くときは Cw ごと外す
- **IFT の同調**: IFT は同調コンデンサ (180pF 前後) を内蔵する。
  455kHz に合うコイルは L = 1/((2π × 455kHz)² × 180pF) ≈ 680µH。コアを回して 455kHz に合わせる。
  図の破線の枠が IFT の缶の中で、内蔵の 180pF を 1 次巻線 (A1・A2) に並べて描いた。
  2 次 (B1・B2) は同調させない前提で、コンデンサは描かない (7mm 角の 455kHz 用 IFT の多くは 1 次だけに内蔵)

### 2 連バリコンとトラッキング

VC1a (アンテナ) と VC1b (局発) は 1 本の軸で一緒に回る 2 連バリコン。
中波 531〜1602kHz に対し、局発は 986〜2057kHz を動く必要がある。

- **周波数の比が違う**: アンテナ側は 1602/531 = 3.02 倍 (容量は 9.1 倍)、局発側は 2057/986 = 2.09 倍 (容量は 4.4 倍) で足りる。
  同じ容量の 2 連をそのまま使うと、局発が回りすぎて差が 455kHz に保てない
- **パディングで縮める**: 局発側に Cp (パディングコンデンサ、270pF) を直列に入れると、容量の変わり方が縮む。
  トリマ (VC1b に並列) で上の端を、コイルのコアで下の端を合わせる。これを**トラッキング**という
- 次の表は計算値。条件は、T1 の 1 次 330µH、VC1a 側は浮遊容量とトリマで 20pF、同容量の 2 連、
  局発コイル 187µH・VC1b のトリマ 27pF・Cp 270pF。600・1000・1400kHz の 3 点で差がちょうど 0 になる Cp は 271.5pF で、
  表はこの値で計算した (270pF でも各行の差は 0.5kHz 以内しか変わらない)。
  VC1 の容量は 1/((2πf<sub>RF</sub>)² × 330µH) − 20pF、f<sub>LO</sub> は 187µH と「(VC1 + 27pF) と Cp の直列」の共振周波数:

| 受信 f<sub>RF</sub> | VC1 の容量 | 局発 f<sub>LO</sub> | 差 − 455kHz |
| --- | --- | --- | --- |
| 531kHz | 252pF | 991.5kHz | +5.5kHz |
| 600kHz | 193pF | 1055.0kHz | 0 |
| 800kHz | 100pF | 1251.2kHz | −3.8kHz |
| 1000kHz | 57pF | 1455.0kHz | 0 |
| 1200kHz | 33pF | 1657.9kHz | +2.9kHz |
| 1400kHz | 19pF | 1855.0kHz | 0 |
| 1602kHz | 10pF | 2045.2kHz | −11.8kHz |

- 帯の中ほどのずれは ±4kHz ほどで、IF の通過帯域 (IFT 3 段で ±4〜5kHz、目安) に収まる。
  帯の端はずれが大きく、そこでは感度が落ちる。ずれても IFT を通るのは f<sub>LO</sub> − 455kHz の局なので、
  **選局 (聞こえる周波数) は局発で決まり、アンテナのタンクは感度だけを決める**

### イメージ周波数

差が 455kHz になるのは f<sub>RF</sub> = f<sub>LO</sub> − 455kHz だけではない。
**f<sub>LO</sub> + 455kHz = f<sub>RF</sub> + 910kHz** の電波も、局発との差が 455kHz になる (イメージ)。
1000kHz を受けているとき、イメージは **1910kHz**。これを止めるのはアンテナのタンク (T1・VC1a) だけで、
IFT では止められない。タンクの Q が 50 (目安) なら、1910kHz の減衰は
Q × (1910/1000 − 1000/1910) ≈ 69 倍 (約 37dB) の計算値。

```circuit
title: 図2 中間周波増幅 2段と検波
parts:
  IF: port 1,3
  IFB: port 1,7
  VCC: vcc 2,5 5V
  R3: resistor 2,5 2,7 33k
  R4: resistor 2,7 2,9 10k
  GR4: ground 2,9
  Cb2: capacitor 4,7 4,9 0.01u
  GCb2: ground 4,9
  Q2: npn 6,3
  Re2: resistor 6,6 6,8 1k
  GRe2: ground 6,8
  Ce2: capacitor 8,6 8,8 0.01u
  GCe2: ground 8,8
  T4: transformer 10,3
  Ci2: capacitor 8,2 8,4 180p l=$\mathrm{C}$
  VCC: vcc 9,1 5V
  R6: resistor 11,7 11,9 10k
  GR6: ground 11,9
  Cb3: capacitor 13,7 13,9 0.01u
  GCb3: ground 13,9
  VCC: vcc 15,5 5V
  R5: resistor 15,5 15,7 22k
  Q3: npn 17,3
  Re3: resistor 17,6 17,8 1k
  GRe3: ground 17,8
  Ce3: capacitor 19,6 19,8 0.01u
  GCe3: ground 19,8
  T5: transformer 21,3
  Ci3: capacitor 19,2 19,4 180p l=$\mathrm{C}$
  VCC: vcc 20,1 5V
  GT5: ground 22,6
  CH2: voltmeter 24,4 24,6 l=$\mathrm{CH2}$
  GCH2: ground 24,6
  D1: diode 25,3 27,3 1N60
  Cd: capacitor 28,3 28,5 0.01u
  GCd: ground 28,5
  CH1: voltmeter 31,3 31,5 l=$\mathrm{CH1}$
  GCH1: ground 31,5
  VR: potentiometer 34,3 34,5 l=$\mathrm{VR}$
  GVR: ground 34,5
  AF: port 36,4
wires:
  - 1,3 -- Q2.B
  - 1,7 -- 2,7
  - 2,7 -- 4,7
  - Q2.E -- 6,6
  - 6,6 -- 8,6
  - Q2.C -- 6,2
  - 6,2 -- 7,2
  - 7,2 |- 8,4
  - 8,4 |- T4.A2
  - T4.A1 -| 8,2
  - T4.A1 -| 9,1
  - T4.B1 -| 16,3
  - 16,3 -- Q3.B
  - T4.B2 -| 11,7
  - 11,7 -- 13,7
  - 13,7 -- 15,7
  - Q3.E -- 17,6
  - 17,6 -- 19,6
  - Q3.C -- 17,2
  - 17,2 -- 18,2
  - 18,2 |- 19,4
  - 19,4 |- T5.A2
  - T5.A1 -| 19,2
  - T5.A1 -| 20,1
  - T5.B1 -| 23,3
  - 23,3 -- 24,3
  - 24,3 -- 25,3
  - 24,3 -- 24,4
  - T5.B2 -| 22,6
  - 27,3 -- 28,3
  - 28,3 -- 31,3
  - 31,3 -- 34,3
  - VR.w -| 36,4
notes:
  - text 34,6 small center: 10kΩ (A)
  - text 9,5 small center: IFT2 (白)
  - box 8,2 10,4 blue
  - text 10.5,1 small blue left: IFT に内蔵 180pF
  - text 20,5 small center: IFT3 (黒)
  - box 19,2 21,4 blue
  - text 21.5,1 small blue left: IFT に内蔵 180pF
style:
  pitch: 1.1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/10-superheterodyne-2.svg)

- **中間周波増幅**: Q2・Q3 は 455kHz だけを増幅するエミッタ接地。
  バイアスは Q2 が R3 (33kΩ)・R4 (10kΩ)・Re2 (1kΩ) で Q1 と同じ I<sub>E</sub> ≈ 0.56mA。
  Q3 は R5 (22kΩ)・R6 (10kΩ) でベースが 5 × 10/32 ≈ 1.56V、I<sub>E</sub> = (1.56 − 0.6)/1kΩ ≈ 0.96mA (計算値)。
  Ce2・Ce3 (0.01µF) は 455kHz で 35Ω で、エミッタを交流で GND にする
- ベースの直流は IFT の 2 次を通って入る。2 次の下の端 (IFB) は Cb2・Cb3 で交流の GND に落とす
- **IFT の色**: 局発コイル 赤、IFT1 黄、IFT2 白、IFT3 黒。
  段ごとに入出力のインピーダンスが違うので巻数比が違う。色の順に差し替えない
- **検波**: D1 (1N60、ゲルマニウム) が IFT3 の 2 次の包絡線を取り出す。Cd (0.01µF) は 455kHz で 35Ω で IF を落とし、
  VR (10kΩ) との時定数は 100µs。1kHz・変調度 30% なら追従の条件
  (τ < √(1 − m²)/(m·2πf) ≈ 506µs) を満たし、包絡線をなぞれる
- 昔のラジオは検波の直流を Q2 のベースへ戻して利得を下げる AGC を持つ。
  この図では省いた (強い局では VR を絞る)

```circuit
title: 図3 低周波増幅 ドライブ1石とプッシュプル2石
parts:
  AF: port 1,8
  C1: ecap 3,8 2,8 10u
  Rb2: resistor 4,8 4,11 22k
  GRb2: ground 4,11
  Q4: npn 7,8
  Re4: resistor 7,10 7,12 100
  GRe4: ground 7,12
  VCC: vcc 9,1 5V
  R7: resistor 9,1 9,3 680
  D2: diode 9,3 9,5 1N4148
  D3: diode 9,5 9,7 1N4148
  Q5: npn 11,3
  VCC: vcc 11,1 5V
  Q6: pnp 11,7
  GQ6: ground 11,10
  Rf: resistor 8,13 10,13 30k
  C2: ecap 13,5 15,5 220u
  SP: speaker 17,5 17,7 l=$\mathrm{SP}$
  GSP: ground 17,7
wires:
  - 1,8 -- 2,8
  - 3,8 -- 4,8
  - 4,8 -- 6,8
  - 6,8 -- Q4.B
  - Q4.E -- 7,10
  - Q4.C -- 7,7
  - 7,7 -- 9,7
  - 9,7 -- Q6.B
  - 9,3 -- Q5.B
  - Q5.C -- 11,1
  - Q6.C -- 11,10
  - Q5.E -- 11,5
  - 11,5 -- Q6.E
  - 11,5 -- 12,5
  - 12,5 -- 13,5
  - 12,5 -- 12,13
  - 12,13 -- 10,13
  - 8,13 -- 6,13
  - 6,13 -- 6,8
  - 15,5 -- 17,5
notes:
  - text 18,6 small left: 8Ω
  - text 11.5,3.7 small left: 2SC2120
  - text 10.9,7.7 small right: 2SA950
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/10-superheterodyne-3.svg)

- **ドライブ段 (Q4)**: R7 (680Ω) → D2・D3 → Q4 のコレクタへ電流を流す。
  出力の中点 (Q5・Q6 のエミッタ) を 2.5V に置くと、D2 の上は 2.5 + 0.65 = 3.15V、
  I = (5 − 3.15)/680 ≈ 2.7mA。Q4 のエミッタは 0.27V、ベースは 0.87V
- **中点の帰還**: Rf (30kΩ) が中点からベースへ直流を戻す。中点が上がると Q4 の電流が増えて中点を引き下げ、2.5V 前後に落ち着く
  (Rb2 の 40µA とベース電流 14µA の和 54µA を Rf が流す。(2.5 − 0.87)/54µA ≈ 30kΩ、hFE = 200 の計算値)
- **プッシュプル (Q5・Q6)**: 上半分を NPN の Q5、下半分を PNP の Q6 が受け持つ。D2・D3 の 1.3V が 2 つの V<sub>BE</sub> を
  あらかじめ持ち上げ、0 付近のすき間 (クロスオーバー歪、2-10 で見た) を減らす
- **出力**: 中点が ±1.5V 振れると、8Ω に最大 1.5/8 ≈ 190mA が流れ、出力は約 1.5²/(2 × 8) ≈ 0.14W (計算値)。
  2SC1815 (150mA) では足りないので、Q5・Q6 は 2SC2120・2SA950 (800mA) にする。
  C2 (220µF) と 8Ω の低域のカットオフは 1/(2π × 8Ω × 220µF) ≈ 90Hz
- 最大音量で電流が 100mA を超えるので、**電源は Analog Discovery の V+ ではなく、USB の 5V か電池**にする
  (V+ は USB 給電で 1 レール 250mW = 50mA まで)。Analog Discovery とラジオの GND はつなぐ

## 実体配線図

回路図の破線の枠の 180pF (IFT に内蔵) は IFT の缶の中にあり、外にピンが出ない。
実体配線図には描かず、IFT (T3・T4・T5) を 1 つの部品として挿す (ピンは 1 次の A1・A2 と 2 次の B1・B2 の 4 本だけ)。
そのため、check で出るネットリストは、回路図のほうが 180pF の 3 個 (Ci1〜Ci3) だけ部品が多い。IFT の 1 次の 2 端子の間に並ぶだけなので、つながりは実体配線図と同じ。
3 枚のブレッドボードに分けて組む。ブレッドボードどうしは IF・IFB・AF の 3 本と、+5V・GND を線でつなぐ
(箱「図5 の基板へ」などが相手のブレッドボード)。電源は 3 枚とも同じ 5V (USB や電池) で、上下の − レールと + レールは右端 (29・30 列、図5 は 62・63 列) で渡す。
1 つの穴にはピンか線を 1 本だけ挿す。赤は +5V、黒は GND、橙はブレッドボードの中のつなぎ、緑は信号の出入り。

```breadboard
title: 図4 周波数変換のブレッドボード Q1
board: half
parts:
  PWR:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, W1]
  BAR:
    type: device
    at: top
    label: バーアンテナ T1
    pins: [A1, A2, B2, B1]
  VC1:
    type: device
    at: top
    label: 2連バリコン VC1
    pins: [A, E, B]
  NEXT:
    type: device
    at: bottom
    label: 図5 の基板へ
    pins: [IF, IFB]
  Cw: capacitor/ceramic d1 d4 10p
  R1: resistor b7 b9 33k
  Q1: transistor c11(B) c12(C) c13(E) 2SC1815
  R2: resistor g7 g5 10k
  Cb: capacitor/ceramic i7 i5 0.01u
  Re: resistor g13 g15 1k
  Cc2: capacitor/ceramic i13 i17 0.01u
  T2: transformer h17(A2) h18(A1) h19(B1) h20(B2)
  Cp: capacitor/ceramic b20 b22 270p
  T3: transformer h23(A2) h24(A1) h25(B1) h26(B2)
wires:
  - PWR.+5V -- +t1 red
  - PWR.GND -- -t2 black
  - AD.GND -- -t3 black
  - AD.W1 -- a1 green
  - BAR.A1 -- b4 yellow
  - BAR.A2 -- -t5 black
  - BAR.B2 -- a7 yellow
  - BAR.B1 -- a11 yellow
  - VC1.A -- a4 yellow
  - VC1.E -- -t6 black
  - VC1.B -- a22 yellow
  - +t9 -- a9 red
  - e7 -- f7 orange
  - -b5 -- j5 black
  - e13 -- f13 orange
  - -b15 -- j15 black
  - +b18 -- j18 red
  - +b19 -- j19 red
  - e20 -- f20 orange
  - i20 -- i23 blue
  - d19 -- d24 orange
  - b12 -- b19 orange
  - e24 -- f24 orange
  - NEXT.IF -- j25 green
  - NEXT.IFB -- j26 green
  - +t29 -- +b29 red
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/10-superheterodyne-1.svg)

- 上のブロックが Q1 のベース側、下のブロックがエミッタと局発。Q1 は c 行 (11 列 B・12 列 C・13 列 E)
- 4 列にアンテナの同調 (Cw の右端 d4・VC1 の A・バーアンテナの A1)。W1 は 1 列 (a1) から Cw (10pF) を通して入る
- 7 列がベースのバイアス (R1 は 9 列の +5V へ、R2・Cb は e7–f7 の線で下の 7 列へ渡して 5 列の GND へ)
- エミッタ (13 列) は e13–f13 で下へ。Re は 15 列の GND へ、Cc2 は 17 列の T2 の A2 (局発コイルの帰還の巻線) へ
- T2 は h17〜h20 (A2・A1・B1・B2)。A1・B1 (18・19 列) を +5V へ。B2 (20 列) は e20–f20 で上へ渡して Cp (b20〜b22) から VC1 の B へ、
  i20–i23 の青い線で T3 の A2 へ
- コレクタ (12 列) は b12–b19・d19–d24・e24–f24 の橙の線で T3 の A1 (24 列) へ
- T3 の 2 次 (25・26 列) を次のブレッドボードの IF・IFB へ。スペアナで見るときは、コレクタの空き穴 (a12) から 10kΩ と 0.01µF を通す

```breadboard
title: 図5 中間周波増幅と検波のブレッドボード Q2 Q3 D1
board: full
parts:
  PWR:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, 1-, 2-, 2+, 1+]
  PREV:
    type: device
    at: top
    label: 図4 の基板から
    pins: [IFB, IF]
  NEXT:
    type: device
    at: bottom
    label: 図6 の基板へ
    pins: [AF]
  R3: resistor b2 b5 33k
  R4: resistor g2 g4 10k
  Cb2: capacitor/ceramic i2 i4 0.01u
  Q2: transistor c7(B) c8(C) c9(E) 2SC1815
  Re2: resistor g9 g11 1k
  Ce2: capacitor/ceramic i9 i11 0.01u
  T4: transformer h13(A2) h14(A1) h15(B1) h16(B2)
  R5: resistor c16 c18 22k
  R6: resistor g16 g19 10k
  Cb3: capacitor/ceramic i16 i19 0.01u
  Q3: transistor c20(B) c21(C) c22(E) 2SC1815
  Re3: resistor g22 g24 1k
  Ce3: capacitor/ceramic i22 i24 0.01u
  T5: transformer h26(A2) h27(A1) h28(B1) h29(B2)
  D1: diode b28(A) b31(K) 1N60
  Cd: capacitor/ceramic g31 g33 0.01u
  VR: potentiometer d35(1) d36(W) d37(3) 10k
wires:
  - PWR.+5V -- +t1 red
  - PWR.GND -- -t2 black
  - AD.GND -- -t3 black
  - AD.1- -- -t4 black
  - AD.2- -- -t6 black
  - PREV.IFB -- a2 green
  - PREV.IF -- a7 green
  - +t5 -- a5 red
  - e2 -- f2 orange
  - -b4 -- j4 black
  - e9 -- f9 orange
  - -b11 -- j11 black
  - b8 -- b13 orange
  - e13 -- f13 orange
  - +b14 -- j14 red
  - f15 -- e15 orange
  - b15 -- b20 orange
  - e16 -- f16 orange
  - +t18 -- a18 red
  - -b19 -- j19 black
  - e22 -- f22 orange
  - -b24 -- j24 black
  - b21 -- b26 orange
  - e26 -- f26 orange
  - +b27 -- j27 red
  - -b29 -- j29 black
  - f28 -- e28 orange
  - AD.2+ -- a28 pink
  - AD.1+ -- d31 purple
  - e31 -- f31 orange
  - -b33 -- j33 black
  - a31 -- a35 orange
  - e36 -- f36 orange
  - NEXT.AF -- j36 green
  - -t37 -- a37 black
  - +t62 -- +b62 red
  - -t63 -- -b63 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/10-superheterodyne-2.svg)

- 2 段とも図4 と同じ形。Q2 は c7〜c9、Q3 は c20〜c22 (B・C・E)。エミッタは e–f の線で下へ渡し、Re と Ce で GND へ
- ベースの直流は前のブレッドボードの IFB (2 列) と T4 の B2 (16 列) から入る。R3・R5 は上の +5V へ、R4・Cb2・R6・Cb3 は下の GND へ
- コレクタは b 行の橙の線で IFT (T4 は h13〜h16、T5 は h26〜h29) の A2 へ。A1 (14・27 列) を +5V へ
- T5 の B1 (28 列) を f28–e28 で上へ渡し、D1 (b28〜b31) で検波。Cd は e31–f31 で下へ渡して 33 列の GND へ。
  a31–a35 で VR の端子 1 へ、端子 3 (37 列) を GND へ、中点 W (36 列) を次のブレッドボードの AF へ
- Analog Discovery の 2+ (CH2) を a28 (検波の前)、1+ (CH1) を d31 (検波の後) に挿す。1−・2−・GND は上の − レールへ

```breadboard
title: 図6 低周波増幅のブレッドボード Q4 Q5 Q6
board: half
parts:
  PWR:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
  PREV:
    type: device
    at: top
    label: 図5 の基板から
    pins: [AF]
  SP:
    type: device
    at: top
    label: スピーカー 8Ω
    pins: ["1", "2"]
  C1: capacitor/electrolytic d4 d1 10u
  Rb2: resistor b4 b2 22k
  D3: diode a9(A) a5(K) 1N4148
  D2: diode c13(A) c9(K) 1N4148
  R7: resistor b13 b17 680
  Q4: transistor g4(B) g5(C) g6(E) 2SC1815
  Re4: resistor j6 j9 100
  Q5: transistor g13(B) g14(C) g15(E) 2SC2120
  Q6: transistor g21(B) g22(C) g23(E) 2SA950
  Rf: resistor a19 a23 30k
  C2: capacitor/electrolytic b23 b27 220u
wires:
  - PWR.+5V -- +t1 red
  - PWR.GND -- -t4 black
  - PREV.AF -- a1 green
  - -t2 -- a2 black
  - e4 -- f4 orange
  - e5 -- f5 orange
  - -b9 -- i9 black
  - e13 -- f13 orange
  - +b14 -- j14 red
  - +t17 -- a17 red
  - d5 -- d21 orange [v10]
  - e21 -- f21 orange
  - -b22 -- j22 black
  - j15 -- j23 orange
  - e23 -- f23 orange
  - c19 -- a4 orange
  - SP.1 -- a27 green
  - SP.2 -- -t28 black
  - +t29 -- +b29 red
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/10-superheterodyne-3.svg)

- Q4 (g4〜g6)・Q5 (g13〜g15)・Q6 (g21〜g23) は下のブロック、バイアスとダイオードは上のブロック
- 4 列がベース (C1 の +・Rb2・e4–f4)。Rf (a19〜a23) は c19–a4 の線でベースへ戻る
- Q4 のコレクタ (5 列) は e5–f5 で上へ渡して D3 のカソード (a5) へ、d5–d21 で Q6 のベース (21 列) へ
- D3 のアノードと D2 のカソードが 9 列、D2 のアノードが 13 列で、e13–f13 で Q5 のベースへ。R7 (b13〜b17。17 列は a17 から上の + レールへ) がここへ電流を流す
- Q5 のエミッタ (15 列) と Q6 のエミッタ (23 列) を j15–j23 でつなぎ、e23–f23 で上の 23 列 (中点) へ。C2 (b23〜b27) からスピーカーへ

## 計器の設定

Analog Discovery (W1・CH1・CH2) だけを使う。
W1 は放送の代わりの AM 信号、オシロは検波の前後の波形 (図8)、Spectrum (WaveForms のスペクトル表示) は Q1 のコレクタに並ぶ RF・LO・IF・和のスペクトル (図7) に使う。
見る周波数は 3MHz までなので、この本の決め (10MHz 以下は Analog Discovery、それより上は tinySA) どおり Analog Discovery で足りる。

| 項目 | 設定 |
| --- | --- |
| W1 (Wavegen) | Sine 1MHz、振幅 100mV、Modulation を AM (1kHz の Sine、30%) |
| W1 のつなぎ方 | Cw (10pF) を通して T1 の 1 次の上 (VC1a) へ (図1) |
| 選局 | VC1 を回して、CH1 に 1kHz が最も大きく出る所 (f<sub>LO</sub> = 1455kHz) |
| CH2 (Scope) | IFT3 の 2 次 (D1 の手前)。500mV/div、DC 結合 |
| CH1 (Scope) | 検波出力 (VR の上)。100mV/div、DC 結合 |
| 時間軸・トリガ | 200µs/div、CH1 の立ち上がり 0.4V |
| Spectrum のつなぎ方 | CH2 を Q1 のコレクタへ移す。10kΩ と 0.01µF を直列に通し、CH2 の入力 (2+ と 2−) の間に 51Ω を入れる。入力に届くのはコレクタの約 1/200 |
| Spectrum の設定 | 0〜3MHz、8192 標本 (分解能 約 0.9kHz)、窓 Flat Top、縦軸 dBm (50Ω)、Top −30dBm |

- CH2 をコレクタへ直につながない。入力 (1MΩ) と線の容量 (数十 pF) が IFT1 の同調容量に足され、同調がずれる。
  10kΩ で切り離し、51Ω で入力の容量を効かなくする (tinySA なら入力の 50Ω が同じ役をする)。
  プローブを局発のタンク (T2・VC1b) に当てると、その容量で局発の周波数がずれる

## 計器の画面

### Analog Discovery の Spectrum で見る

レベルは目安。Q1 のコレクタで IF 50mV、LO 300mV、RF 2.3mV、和 2mV (いずれも peak) と置き、
10kΩ + 51Ω の分圧 (約 1/197) をかけた値。IF と LO の周波数は計算で決まる。

```spectrum
title: 図7 Q1 のコレクタ 受信 1000kHz のとき
device: ad3
sweep: 0-3MHz
samples: 8192
window: flattop
unit: dBm
ref: -30dBm
signal:
  - sine 455kHz -61.9dBm
  - sine 1000kHz -88.7dBm
  - sine 1455kHz -46.4dBm
  - sine 2455kHz -89.9dBm
markers: [455k, 1000k, 1455k, 2455k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/10-superheterodyne.svg)

- 1 本目 (455kHz) が IF、2 本目 (1000kHz) が受けている RF、3 本目 (1455kHz) が LO、4 本目 (2455kHz) が和
- **LO が一番大きい**。局発はコレクタにも巻線で強く乗る。RF と和は IFT1 の同調から外れて、コレクタでは小さい
- W1 の周波数を変えて VC1 で合わせ直すと、RF (2 本目)・LO (3 本目)・和 (4 本目) は一緒に動くが、455kHz の IF は動かない。これが「どの局も IF に揃える」ということ
- W1 を 1910kHz (イメージ) に変えても、VC1 を触らなければ 455kHz に IF が出る。大きさは 1000kHz のときより 37dB ほど下 (計算値)

### オシロスコープで見る

レベルは目安 (IFT3 の 2 次で peak 0.5V、D1 の順方向電圧を 0.1V と置いた)。

```scope
title: 図8 検波の前後 CH2 は IFT3 の2次 CH1 は検波出力
time: 200us/div
trigger: ch1 rising 0.4V
ch1: {wave: sine 1kHz 0.15V offset 0.4V, range: 100mV/div, position: -6div}
ch2: {wave: = 0.5V * (1 + 0.3 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 455kHz * t), range: 500mV/div, position: 2.5div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/10-superheterodyne.svg)

- CH2 は 455kHz の IF。200µs/div では 1 周期 (2.2µs) は見えず、**包絡線が 1kHz でふくらむ帯**に見える。
  山は 0.5 × 1.3 = 0.65V、谷は 0.5 × 0.7 = 0.35V (変調度 30%)
- CH1 は検波出力。包絡線をなぞった 1kHz の正弦波が直流の上に乗る (0.25〜0.55V)
- 変調を 30% のまま、周波数を変えても、CH2 の包絡線の周期が変わるだけで、IF の 455kHz は変わらない

## 見るべき値

直流の電圧は、テスターの直流電圧レンジで GND との間を測る。

| 確かめること | 期待する値 |
| --- | --- |
| Q1・Q2 のエミッタの電圧 | 約 0.56V (I<sub>E</sub> ≈ 0.56mA、計算値) |
| Q3 のエミッタの電圧 | 約 0.96V (I<sub>E</sub> ≈ 0.96mA、計算値) |
| 出力の中点 (Q5・Q6 のエミッタ) | 約 2.5V (計算値) |
| 1000kHz を受けたときの LO | 1455kHz (図7 のマーカー 3) |
| IF | 455kHz (図7 のマーカー 1、図8 の CH2 の Freq)。VC1 を回しても動かない |
| イメージ周波数 (1000kHz 受信時) | 1910kHz。1000kHz より約 37dB 弱く聞こえる (Q = 50 の計算値) |
| 帯の中ほど (600〜1400kHz) のトラッキングのずれ | ±4kHz 以内 (計算値) |
| IFT3 の 2 次の包絡線 (CH2) | 山 0.65V・谷 0.35V、変調度 30% (目安、図8) |
| 検波出力 (CH1) | 1kHz、0.25〜0.55V (目安、図8) |
| W1 を外して放送を受ける | 9-3 より大きく、隣の局と混ざりにくい (IFT 3 段の選択度) |

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1〜Q4 | NPN トランジスタ | 2SC1815 |
| Q5 | NPN トランジスタ (出力) | 2SC2120 |
| Q6 | PNP トランジスタ (出力) | 2SA950 |
| T1 | バーアンテナ (1 次 約 330µH + 結合巻線) | 中波用 |
| T2 | 局発コイル (赤) | 455kHz スーパー用 |
| T3・T4・T5 | IFT (黄・白・黒) | 455kHz、コンデンサ内蔵 (1 次に 180pF 前後。買うのは IFT だけで、コンデンサは別に要らない) |
| VC1a・VC1b | 2 連ポリバリコン (トリマ付き) | 同容量 約 260pF × 2 |
| Cp | パディングコンデンサ | 270pF |
| Cw | セラミックコンデンサ (W1 の注入) | 10pF |
| D1 | ゲルマニウムダイオード | 1N60 |
| D2・D3 | シリコンダイオード | 1N4148 |
| R1・R3 | 抵抗 | 33kΩ |
| R2・R4・R6 | 抵抗 | 10kΩ |
| R5・Rb2 | 抵抗 | 22kΩ |
| Re・Re2・Re3 | 抵抗 | 1kΩ |
| Re4 | 抵抗 | 100Ω |
| R7 | 抵抗 | 680Ω |
| Rf | 抵抗 | 30kΩ |
| VR | 可変抵抗 (音量) | 10kΩ (A カーブ) |
| Cb・Cb2・Cb3・Cc2・Ce2・Ce3・Cd | セラミックコンデンサ | 0.01µF |
| C1 | 電解コンデンサ | 10µF |
| C2 | 電解コンデンサ | 220µF |
| SP | スピーカー | 8Ω、0.2W 以上 |
| — | 電源 | 5V (USB や電池)。Analog Discovery の V+ は使わない |

VC1 は同容量の 2 連で計算した。アンテナ側と局発側の容量が違う「親子」の 2 連 (スーパー用) なら、
局発側の羽根の形でトラッキングを取るので Cp は要らない (そのときは Cp を短絡する)。

## 出典

自作。中間周波数 455kHz と IFT・局発コイルの色分けは、日本の中波スーパーの慣習による。
2SC2120・2SA950 の最大コレクタ電流 (800mA) は東芝のデータシート、
Analog Discovery の Wavegen の AM 変調と電源の上限は Digilent の資料による。
