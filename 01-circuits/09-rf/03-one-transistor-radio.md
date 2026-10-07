---
book: circuits
chapter: 9
id: 9-3
title: 1 石ラジオ — トランジスタの高周波増幅とダイオード検波
tier: 50
source: 自作
board: BB
era: 古
---

# 9-3 1 石ラジオ — トランジスタの高周波増幅とダイオード検波

ゲルマラジオ (9-2) の同調タンクはそのままに、**検波の前にトランジスタ 1 石で高周波を
増幅**する。検波はダイオード D1 が受け持ち、D1 には直流のバイアス電流をあらかじめ流しておく。
この 2 つで、弱い電波でも音が大きくなる。電池が要る代わりに、アンテナが短くても聞こえる。

## 回路図

```circuit
title: 図1 1石ラジオ
parts:
  ANT: antenna 1,5
  L1: inductor 2,5 2,7 250u
  GL: ground 2,7
  VC1: capacitor-var 4,5 4,7 l=$\mathrm{VC}_1$
  GVC: ground 4,7
  C1: capacitor 6,5 7,5 0.01u
  Q1: npn 10,5
  VCC: vcc 10,1 5V
  Rc: resistor 10,3 10,1 1.5k
  Rb: resistor 8,3 10,3 220k
  GE: ground 10,6
  D1: diode 11,3 13,3 1N60
  C3: capacitor 14,3 14,5 0.001u
  GC3: ground 14,5
  R3: resistor 16,3 16,5 100k
  GR3: ground 16,5
  EAR: earphone 19,3 19,5 l=$\mathrm{EAR}$
  GEAR: ground 19,5
wires:
  - 1,5 -- 6,5
  - 7,5 -- 8,5
  - 8,5 -- Q1.B
  - 8,3 -- 8,5
  - 10,3 -- Q1.C
  - Q1.E -- 10,6
  - 10,3 -- 11,3
  - 13,3 -- 17,3
  - 17,3 -- 19,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/03-one-transistor-radio.svg)

- **タンク → C1 → ベース**: L1・VC1 の並列タンクで選んだ電波を、結合コンデンサ
  C1 で Q1 のベースへ渡す
- **コレクタ帰還バイアス**: Rb (220kΩ) がコレクタからベースへ戻る。hFE が
  100〜300 に散っても動作点が安定する (2-8 と同じ考え方)
- **検波**: D1 は Q1 のコレクタに直結。Rc → コレクタ → D1 → R3 → GND の道が
  常に電流を流しているので、ダイオードはあらかじめゲルマニウムの立ち上がりに
  乗っている。弱い電波でも検波が始まる
- C3 が残った高周波を GND へ落とし、R3 が検波の負荷。EAR (クリスタルイヤホン)
  は R3 と並列 (A 端子を検波出力、B 端子を GND) につないで音を出す
- **イヤホンのインピーダンス**: EAR は、いま売られているセラミック (圧電) 型の
  クリスタルイヤホンを想定する (容量 約 15nF、直流では 20MΩ 以上)。電気的には
  コンデンサなので、インピーダンスは周波数で変わり、**1kHz で約 10kΩ**
  (1/(2π×1kHz×15nF) ≈ 10.6kΩ)、100Hz で約 100kΩ。8Ω や 32Ω の
  ダイナミック型のイヤホンでは、この小さな電流では鳴らない
- 1kHz ではイヤホン (約 10kΩ) が R3 (100kΩ) よりずっと低いので、音声の負荷はほぼイヤホン。
  イヤホンは直流を通さないので、D1 にバイアス電流を流す直流の道は R3 が作る。
  イヤホンの容量 (15nF) は C3 (1nF) と並列に入り、高周波のバイパスも助ける

**動作点の計算値** (V<sub>CC</sub> = 5V、hFE = 200、V<sub>BE</sub> = 0.6V と仮定):

- I<sub>C</sub> = (V<sub>CC</sub> − V<sub>BE</sub>) / (R<sub>b</sub>/hFE + R<sub>c</sub>)
  = (5V − 0.6V) / (220kΩ/200 + 1.5kΩ) = 4.4V / 2.6kΩ ≈ 1.7mA
- V<sub>C</sub> = V<sub>CC</sub> − I<sub>C</sub> × R<sub>c</sub> = 5V − 1.7mA × 1.5kΩ ≈ 2.5V。
  電源のほぼ半分なので、信号で上下どちらにも振れる余地がある
- 電圧利得 = g<sub>m</sub> × R<sub>c</sub>。g<sub>m</sub> = I<sub>C</sub> / 26mV (2-3 で見た) なので、
  1.7mA / 26mV × 1.5kΩ ≈ 98 倍 (20 log 98 ≈ 40dB)

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [A, E]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [W1, V+, GND, 2+, 1+, 1-, 2-]
  EAR:
    type: device
    at: bottom
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b12 b16 250u
  C1: capacitor/ceramic d12 d18 0.01u
  RS: resistor e12 i12 1k
  Rb: resistor b18 b22 220k
  Rc: resistor c22 c26 1.5k
  Q1: transistor h18(B) h19(C) h20(E) 2SC1815
  D1: diode e22(A) f22(K) 1N60
  C3: capacitor/ceramic g22 g26 0.001u
  R3: resistor i22 i26 100k
wires:
  - ANT.1 -- c12 yellow
  - VC1.A -- a12 yellow
  - VC1.E -- -t14 black
  - AD.W1 -- j12 orange
  - AD.2+ -- j19 blue
  - AD.1+ -- h22 blue
  - AD.V+ -- +b17 red
  - AD.GND -- -b19 black
  - AD.1- -- -b22 black
  - AD.2- -- -b23 black
  - +t30 -- +b30 red
  - a16 -- -t16 black
  - e18 -- f18 orange
  - f19 -- e19 blue
  - a19 -- a22 blue
  - +t26 -- a26 red
  - j20 -- -b21 black
  - j26 -- -b25 black
  - EAR.A -- j24 green
  - j24 -- j22 green
  - EAR.B -- -b28 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/03-one-transistor-radio.svg)

- **AD3 は下に置く** (検波出力とコレクタを測る 22 列・19 列が下のブロックにあるため、線が基板の上を長く渡らない)。
  V+ (Supplies の 5V) を下の赤レール (17 列)、GND を下の青レール (19 列) へ入れる。赤レール = +5V、青レール = GND。
  30 列で上下の + レールどうし、− レールどうしを渡している (上の + レールから Rc へ、上の − レールから L1・VC1 へ)
- 前段は 12 列にアンテナ・VC1・L1・C1 をまとめる。L1 の右リード (16 列) は上の − レールへ
- Q1 は下のブロックの h 行に、隣り合う 3 列 (18 列 B・19 列 C・20 列 E) へ挿す。ピンを大きく
  曲げずに挿せる間隔。2SC1815 は平らな面を手前にすると左から E・C・B なので、
  平らな面を上のブロック側へ向けて挿すと左から B・C・E になる。エミッタ (20 列) は下の − レールへ
- ベース (18 列) は e–f の短い線で上のブロックの 18 列へ出し、C1 と Rb の左リードをそこに挿す。
  コレクタ (19 列) も e–f の線で上の 19 列へ出し、a 行の青い線で 22 列へ渡す。
  22 列に Rb の右リード・Rc・D1 が集まる。B と C が隣り合うので、Rb をじかに渡さずに 22 列を使う
- Rc の右リード (26 列) は上の + レールへ。D1 は 22 列で溝をまたぎ、アノードが上 (コレクタ)、
  カソードが下 (検波出力)。下の 22 列に C3・R3 の左リードが並び、EAR の A 端子は 24 列 (`j24`) を通って 22 列 (`j22`) へつなぐ (AD3 の 1−・2− の線との交差を減らすため)。
  C3・R3 の右リード (26 列) と EAR の B 端子は下の − レールへ
- AD3 (Analog Discovery 3) の W1 を RS (1 kΩ) 経由で同調回路の 12 列へ入れる。放送の電波の代わりの試験用で、
  使うときは ANT の線を外してよい。RS は溝をまたいで縦に挿し (`e12` と `i12`)、W1 は下の 12 列 (`j12`) へ入れる。1+ は検波出力 (下の 22 列、`h22`)、2+ は Q1 のコレクタ (下の 19 列、`j19`)、1−・2−・GND は下の − レール (22・23・19 列) へ入れる
- 1 つの穴にはピンか線を 1 本だけ挿す

## 計器の設定

計器は Analog Discovery 3。電源 (Supplies の V+ = 5 V)、信号源 (Wavegen の W1)、オシロ (Scope) が 1 台で足り、
搬送波 1 MHz は Scope の範囲 (10 MHz 以下) に入る。消費電流は I<sub>C</sub> ≈ 1.7 mA ほどで、電源 1 系統の約 50 mA に収まり、
ブレッドボードの 1 穴 200 mA の範囲にも入る。VC1 は約 100 pF に回しておく (f<sub>0</sub> ≈ 1.007 MHz)。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ = 5 V、出力 ON |
| Wavegen W1 | 搬送波 Sine 1 MHz、振幅 20 mV (peak)、Modulation: AM、変調波 Sine 1 kHz、変調度 50 % |
| Scope CH1 (1+ = 検波出力) | Coupling DC、200 mV/div |
| Scope CH2 (2+ = コレクタ) | Coupling DC、1 V/div |
| Scope 時間軸・トリガ | 200 µs/div、CH1 の立ち上がり |

```scope
title: 図3 AM 信号の試験 — コレクタ (CH2) は増幅され、検波出力 (CH1) は 1 kHz
time: 200us/div
trigger: ch1 rising 2.98V
ch1: {wave: = 2.98V + 0.31V * sin(2 * pi * 1kHz * t), range: 200mV/div, position: -14.9div}
ch2: {wave: = 2.45V + 0.78V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 1V/div, position: -2.45div}
measure: [vpp, avg, freq]
cursors: [250us, 750us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/03-one-transistor-radio.svg)

- 図3 は LTspice の計算 (2SC1815 は BF = 200 の汎用モデル、1N60 は IS = 0.2 µA・RS = 25 Ω と仮定) をもとにした画面。実測ではない
- CH2 (コレクタ) は直流 約 2.45 V (上の動作点の 2.5 V とほぼ一致) に、1 MHz の搬送波が乗る。振幅は 1 kHz で太り細りして、
  最大 約 1.2 V (peak)。入力の同調回路の振幅は最大でも約 19 mV (peak) なので、実効の利得は約 60 倍。
  上の 98 倍より小さいのは、タンクと Rc に D1・R3・イヤホンの負荷が付くため
- CH1 は平均 約 3.0 V、1 kHz の振れ 約 0.6 Vpp (2.66〜3.28 V)。D1 がコレクタの山を拾い、C3・R3・イヤホンでならした出力

### 同調回路だけを VNA で見る (補足)

L1 と VC1 の同調回路は 9-2 と同じで、VC1 を約 100 pF に回したときの f<sub>0</sub> は約 1.007 MHz。
放送の電波や W1 の信号がなくても、L1 と VC1 の並列だけを回路から外して LiteVNA64 の CH0 と CH1 の間に直列に挿せば、
S21 の谷として f<sub>0</sub> と谷の鋭さを測れる。つなぎ方、見えるはずの画面 (図)、読み方は
01-circuits/09-rf/02-crystal-radio.md (9-2) の「同調回路だけを VNA で見る」と同じ。VC1 を回すと谷が動く。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| L1 | インダクタ (アキシャル) | 250 µH |
| VC1 | ポリバリコン | 20〜260 pF |
| C1 | セラミックコンデンサ | 0.01 µF |
| Rb | 抵抗 | 220 kΩ |
| Rc | 抵抗 | 1.5 kΩ |
| Q1 | NPN トランジスタ | 2SC1815 |
| D1 | ゲルマニウムダイオード | 1N60 |
| C3 | セラミックコンデンサ | 1 nF |
| R3 | 抵抗 | 100 kΩ |
| EAR | クリスタルイヤホン | 容量 約 15 nF |
| RS | 抵抗 (試験用。W1 から同調回路へ入れる) | 1 kΩ |
| — | 電源・試験用の信号源・オシロ | Analog Discovery 3 (V+ = 5 V、W1、Scope の 1・2) |

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| Q1 のコレクタ電圧 (テスターの DC 電圧、GND 基準) | 約2.5V (電源の半分) |
| Q1 のコレクタ電流 (Rc の両端の電圧をテスターで測り ÷ 1.5kΩ) | 約1.7mA (Rc の両端で約 2.5V) |
| 電圧利得 (g<sub>m</sub>·R<sub>c</sub>) | 約98倍 (40dB)。R3 とイヤホンの負荷を数えない上限 |

- タンクだけのゲルマラジオ (9-2) より弱い局まで聞こえるようになる。
  高周波を増幅してから検波するぶん、検波に必要な振幅を作りやすい
- Rb のコレクタ側のピンを +5V へつなぎ替えると、固定バイアスになる。ベース電流は
  (5V − 0.6V) ÷ 220kΩ ≈ 20µA に決まり、I<sub>C</sub> = hFE × 20µA は hFE のばらつきをそのまま受ける。
  hFE 100 なら 2mA で Vc ≈ 2V、hFE 200 なら 4mA になるはずが Rc で 6V も落とせないので、
  Q1 は飽和して Vc が 0V 近くに張り付く。コレクタ帰還の効果を確かめられる

## 出典

自作。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
