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
  ANT: antenna e1
  L1: inductor e2 g2 250u
  GL: ground g2
  VC1: capacitor-var e4 g4 l=$\mathrm{VC}_1$
  GVC: ground g4
  C1: capacitor e6 e7 0.01u
  Q1: npn e10
  VCC: vcc a10 5V
  Rc: resistor c10 a10 1.5k
  Rb: resistor c8 c10 220k
  GE: ground f10
  D1: diode c11 c13 1N60
  C3: capacitor c14 e14 0.001u
  GC3: ground e14
  R3: resistor c16 e16 100k
  GR3: ground e16
  EAR: earphone c19 e19 l=$\mathrm{EAR}$
  GEAR: ground e19
wires:
  - e1 -- e6
  - e7 -- e8
  - e8 -- Q1.B
  - c8 -- e8
  - c10 -- Q1.C
  - Q1.E -- f10
  - c10 -- c11
  - c13 -- c17
  - c17 -- c19
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
  PWR:
    type: device
    at: top
    label: 電源 5V
    pins: [+5V, GND]
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
  EAR:
    type: device
    at: bottom
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b12 b16 250u
  C1: capacitor/ceramic d12 d18 0.01u
  Rb: resistor b18 b22 220k
  Rc: resistor c22 c26 1.5k
  Q1: transistor h18(B) h19(C) h20(E) 2SC1815
  D1: diode e22(A) f22(K) 1N60
  C3: capacitor/ceramic g22 g26 0.001u
  R3: resistor i22 i26 100k
wires:
  - PWR.+5V -- +t1 red
  - PWR.GND -- -t2 black
  - VC1.E -- -t14 black
  - VC1.A -- a12 yellow
  - ANT.1 -- c12 yellow
  - a16 -- -t16 black
  - e18 -- f18 orange
  - f19 -- e19 blue
  - a19 -- a22 blue
  - +t26 -- a26 red
  - j20 -- -b20 black
  - j26 -- -b26 black
  - EAR.A -- j22 green
  - EAR.B -- -b28 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/03-one-transistor-radio.svg)

- 電源 (5V。USB の 5V や電池) は左上から上のレールへ入れる。上の赤レール = +5V、青レール = GND。
  30 列で上下の − レールを渡している
- 前段は 12 列にアンテナ・VC1・L1・C1 をまとめる。L1 の右足 (16 列) は上の − レールへ
- Q1 は下のブロックの h 行に、隣り合う 3 列 (18 列 B・19 列 C・20 列 E) へ挿す。足を大きく
  曲げずに挿せる間隔。2SC1815 は平らな面を手前にすると左から E・C・B なので、
  平らな面を上のブロック側へ向けて挿すと左から B・C・E になる。エミッタ (20 列) は下の − レールへ
- ベース (18 列) は e–f の短い線で上のブロックの 18 列へ出し、C1 と Rb の左足をそこに挿す。
  コレクタ (19 列) も e–f の線で上の 19 列へ出し、a 行の青い線で 22 列へ渡す。
  22 列に Rb の右足・Rc・D1 が集まる。B と C が隣り合うので、Rb をじかに渡さずに 22 列を使う
- Rc の右足 (26 列) は上の + レールへ。D1 は 22 列で溝をまたぎ、アノードが上 (コレクタ)、
  カソードが下 (検波出力)。下の 22 列に C3・R3 の左足と EAR の A 端子が並ぶ。
  C3・R3 の右足 (26 列) と EAR の B 端子は下の − レールへ
- 1 つの穴には足か線を 1 本だけ挿す

## 見るべき値

計算値。

| 測る所 | 期待する値 |
| --- | --- |
| Q1 のコレクタ電圧 (テスターの DC 電圧、GND 基準) | 約2.5V (電源の半分) |
| Q1 のコレクタ電流 (Rc の両端の電圧をテスターで測り ÷ 1.5kΩ) | 約1.7mA (Rc の両端で約 2.5V) |
| 電圧利得 (g<sub>m</sub>·R<sub>c</sub>) | 約98倍 (40dB)。R3 とイヤホンの負荷を数えない上限 |

- タンクだけのゲルマラジオ (9-2) より弱い局まで聞こえるようになる。
  高周波を増幅してから検波するぶん、検波に必要な振幅を作りやすい
- Rb のコレクタ側の足を +5V へつなぎ替えると、固定バイアスになる。ベース電流は
  (5V − 0.6V) ÷ 220kΩ ≈ 20µA に決まり、I<sub>C</sub> = hFE × 20µA は hFE のばらつきをそのまま受ける。
  hFE 100 なら 2mA で Vc ≈ 2V、hFE 200 なら 4mA になるはずが Rc で 6V も落とせないので、
  Q1 は飽和して Vc が 0V 近くに張り付く。コレクタ帰還の効果を確かめられる

## 出典

自作。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
