---
book: circuits
chapter: 10
id: 10-16
title: オープンドレインと配線 AND、プルアップ
tier: 200
source: 自作
---

# 10-16 オープンドレインと配線 AND、プルアップ

10-1 の 74HC の出力は、H のときは 5 V へ、L のときは GND へ、トランジスタで能動的に引く (プッシュプル)。
2 つのプッシュプルの出力を 1 本の線につなぐと、片方が H・片方が L のとき、5 V から GND へ 2 つの出力を通って
大きな電流が流れ、どちらかが壊れる。

**オープンドレイン** (バイポーラならオープンコレクタ) の出力は、L に引くトランジスタだけを持ち、H の側が無い。
H にするのは外の 1 本の抵抗 (プルアップ) である。こうすると何個の出力を 1 本の線につないでも喧嘩しない。
線が H になるのは「全員が手を離したとき」だけで、誰か 1 人が引けば L。これを**配線 AND** (wired AND) と呼ぶ。
10-18 の I2C バスと、LM393 (コンパレータ) の出力・割り込みの線がこの形。

この題では 2N7000 (N ch MOSFET) 2 個をオープンドレインの出力に見立てて 1 本の線にまとめ、
プルアップの抵抗 Rp を 10 kΩ と 1 kΩ で比べる。線の容量 (配線と相手の入力) は C1 (1 nF) で代わりにする。

## この実験で確かめる式

- 線が L から H へ戻るのは Rp が C を充電する速さで決まる。時定数 τ = Rp · C、立ち上がり (10 % → 90 %) は t<sub>r</sub> = τ · ln 9 ≈ 2.2 τ
- H から L へはトランジスタが直接引くので、ずっと速い (2N7000 のオン抵抗は数 Ω)
- 線が L の間、Rp には I = 5 V ÷ Rp が流れ続ける (Rp が小さいほど速いが、電流が増える)

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2N7000 2 個のオープンドレインを 1 本の線にまとめる
parts:
  VCC: vcc 8,1 5V
  Rp: resistor 8,1 8,3 10k
  Q1: nmos 5,5 2N7000
  GQ1: ground 5,6
  Q2: nmos 11,5 2N7000
  GQ2: ground 11,6
  C1: capacitor 13,3 13,5 1n
  GC1: ground 13,5
  LINE: port 15,3 out
  W1: port 2,5 in
  W2: port 2,7.5 in
wires:
  - Q1.D -- 5,3 -- 8,3
  - 8,3 -- 11,3
  - Q2.D -- 11,3
  - 11,3 -- 13,3
  - 13,3 -- 15,3
  - Q1.S -- 5,6
  - Q2.S -- 11,6
  - 2,5 -| Q1.G
  - 2,7.5 -- 9.5,7.5
  - 9.5,7.5 |- Q2.G
notes:
  - text 1,9 small left: "C1 は線の容量の代わり (配線と相手の入力)。Rp は 1 kΩ にも替えて比べる"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/16-open-drain.svg)

- Q1・Q2 のドレインが 1 本の線 LINE で、Rp が 5 V へ引き上げる。ソースは GND。ゲートには AD3 の W1・W2 (0 V か 5 V) を入れる
- W1・W2 がともに 0 V なら Q1・Q2 は切れ、LINE は Rp で 5 V。どちらかが 5 V ならそのトランジスタがオンし、LINE は数 mV になる
- 「ゲートが H なら引く」ので、ゲートで見ると LINE は NOR。「線を L に引きたい人」を 1 として見ると、
  線の H は「全員 0」の AND。オープンドレインの線の L は、たいてい「誰かが用がある」という意味 (負論理、10-2) に使う
- 2N7000 のしきい値は 0.8〜3 V (Vishay の 2N7000 のデータシート)。ゲートを 5 V で振れば確実にオンする。
  3.3 V で振るときは、品によってしきい値の 3 V に近く、オン抵抗が大きくなる (10-17)
- ゲートが浮くとオン・オフが決まらないので、W1・W2 を抜くときはゲートを 100 kΩ で GND に落とす (図では省いた)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (2N7000 は平らな面が手前で S・G・D)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 Supplies・Wavegen・Scope
    pins: [GND, V+, 1+, W1, 1-, W2, 2+, 2-]
  Q1: transistor e5 e6 e7 2N7000
  Q2: transistor e11 e12 e13 2N7000
  Rp: resistor b13 b17 10k
  C1: capacitor/ceramic b7 b9 1n
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t1 black
  - a5 -- -t5 black
  - a11 -- -t11 black
  - a9 -- -t9 black
  - c7 -- c13 orange
  - a17 -- +t17 red
  - AD.W1 -- a6 yellow
  - b6 -- b3 yellow
  - AD.1+ -- a3 white
  - AD.1- -- -t8 black
  - AD.W2 -- a12 green
  - AD.2+ -- a13 blue
  - AD.2- -- -t15 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/16-open-drain.svg)

- 電源は AD3 の Supplies の V+ (5 V) を上の赤レールへ、GND を上の青レールへ
- 2N7000 は平らな面を手前にして左から S・G・D (資料が食い違うので、実物はテスタで確かめる。breadboard フェンスの表の注意書き)。
  Q1 は 5〜7 列、Q2 は 11〜13 列。ソース (5・11 列) を青レールへ
- ドレイン (7・13 列) をオレンジの線でつなぐ。この線が LINE。Rp (10 kΩ) は 13 列から 17 列、赤の線で +5 V へ。
  C1 (1 nF、記号 102) は 7 列から 9 列、黒の線で GND へ
- W1 を Q1 のゲート (6 列) に挿し、黄の線で 3 列へも渡して、そこに 1+ (CH1) を挿す。W2 は Q2 のゲート (12 列)、2+ (CH2) は LINE (13 列)
- Rp を 1 kΩ に差し替えて同じ測り方をする。電流は Rp が 1 kΩ でも 5 mA で、ブレッドボードの範囲にも AD3 の Supplies にも収まる

## 計器の設定

計器は AD3 の Supplies・Wavegen (ゲート)・Scope (ゲートと LINE)・Logic。
Scope では W2 を 0 V にして、Q1 が手を離したあと LINE が Rp と C1 でゆっくり戻る形を見る。Logic で配線 AND の真理値を見る。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V |
| W1 | Square、10 kHz、0〜5 V (Amplitude 2.5 V、Offset 2.5 V) |
| W2 | DC 0 V (Scope のとき)。Logic のときは W1 を 1 kHz、W2 を 500 Hz の 0〜5 V の方形波 (同期) |
| CH1 (1+) | Q1 のゲート (W1)。2 V/div、0 V を下から 1 目盛 |
| CH2 (2+) | LINE。CH1 と同じ尺度 |
| 時間 | 10 µs/div、トリガは CH1 の立ち上がり 2.5 V、トリガの点を左端 |
| Measurements | CH2 の Rise Time・Max・Min |
| カーソル | X1 = 51.1 µs、X2 = 73.0 µs (LINE の 10 % と 90 %) |
| Logic | DIO0 (W1)・DIO1 (W2)・DIO2 (LINE)。標本化 1 MHz、250 µs/div |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Q1 が手を離すと LINE は Rp 10 kΩ と C1 1 nF で戻る (立ち上がり 22 µs、計算)
time: 10us/div
trigger: ch1 rising 2.5V at -5div
ch1: {wave: square 10kHz 2.5V offset 2.5V, range: 2V/div, position: -3div}
ch2: {wave: = step(t-50us)*5V*(1-exp(-(t-50us)/10us)), range: 2V/div, position: -3div}
cursors: [51.1us, 73us]
measure: [rise, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/16-open-drain.svg)

- 図3 は計算で作った理想の波形。0〜50 µs は W1 が 5 V で Q1 がオンし、LINE は 0 V。50 µs で W1 が 0 V になると、
  LINE は τ = 10 kΩ × 1 nF = 10 µs で 5 V へ向かい、10 % から 90 % まで 22 µs かかる (カーソル X1・X2)
- 100 µs で Q1 がまたオンすると、LINE は 12 ns ほどで落ちる (LTspice の値。この時間軸では縦の線)
- Rp を 1 kΩ にすると τ = 1 µs、立ち上がりは 2.2 µs に縮む。代わりに、LINE が L の間に Rp を流れる電流は 0.5 mA から 5 mA に増える

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 LINE は W1 と W2 の両方が 0 のときだけ H (配線 AND、計算)
device: ad3
time: 250us/div
sample: 1MHz
signals:
  W1:   dio0 clock 1kHz
  W2:   dio1 clock 500Hz
  LINE: dio2 edges 0s=0 1.5ms=1 2ms=0
cursors: [250us, 1.75ms]
trigger: W2 rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/logic/16-open-drain.svg)

- 図4 の 1 kHz では LINE の立ち上がりの 22 µs は見えない (1 目盛 250 µs)。Logic の標本化の 1 µs で H と読まれるのは、LINE が AD3 の DIO の H のしきい値 (3.3 V 系の入力) を越えた時刻

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1・Q2 | N ch MOSFET | 2N7000 (TO-92) × 2 |
| Rp | 抵抗 (1/4 W)、プルアップ | 10 kΩ と 1 kΩ (差し替えて比べる) |
| C1 | セラミックコンデンサ、線の容量の代わり | 1 nF (102) |
| — | 電源・信号源・計器 | Analog Discovery 3 |

Rp が 1 kΩ のとき、LINE が L の間の電力は 5 V × 5 mA = 25 mW で、1/4 W の半分より小さい。

## 見るべき値

| W1 | W2 | LINE |
| --- | --- | --- |
| 0 | 0 | H (5 V) |
| 0 | 1 | L |
| 1 | 0 | L |
| 1 | 1 | L |

| 項目 | Rp = 10 kΩ | Rp = 1 kΩ |
| --- | --- | --- |
| 時定数 τ = Rp · C1 | 10 µs | 1 µs |
| 立ち上がり (10 → 90 %) 2.2 τ | 22 µs | 2.2 µs |
| LINE が L の間に Rp を流れる電流 | 0.5 mA | 5 mA |
| LINE の L の電圧 (オン抵抗 × 電流) | 2 mV ほど | 17 mV ほど |
| 立ち下がり (90 → 10 %) | 12 ns ほど | 12 ns ほど |

- Rp の選び方は「速さ」と「電流」の取り合い。速い線ほど Rp を小さくするが、L に引く側が吸い込める電流 (I2C は 3 mA、10-18) が上限
- C1 を外すと、線の容量は配線とプローブの十数 pF になり、10 kΩ でも立ち上がりは 1 µs 未満になる (プローブの容量で値が変わる。目安)

## LTspice での確かめ

`sim/16-open-drain.cir` で、2N7000 を他の題と同じ LEVEL 1 の近似 (しきい値 2.1 V、仮定) にし、W1 = 10 kHz、W2 = 0 V で Rp を .step で 10 kΩ と 1 kΩ にした。
真理値は同じ回路を 4 組並べて入力を直流で入れた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 真理値 (W1, W2) = (0,0) / (0,1) / (1,0) / (1,1) | H / L / L / L | 5.00 V / 1.7 mV / 1.7 mV / 0.9 mV | 合う |
| 立ち上がり (Rp 10 kΩ) | 22 µs | 22.18 µs | 合う |
| 立ち上がり (Rp 1 kΩ) | 2.2 µs | 2.218 µs | 合う |
| 立ち下がり | 12 ns ほど | 12.4 ns・12.7 ns | 合う |
| L の間の Rp の電流 (10 kΩ / 1 kΩ) | 0.5 mA / 5 mA | 0.500 mA / 4.98 mA | 合う |
| L の電圧 (10 kΩ / 1 kΩ) | 2 mV / 17 mV ほど | 1.7 mV / 17.2 mV | 合う (モデルのオン抵抗 3.4 Ω による。実物は品で違う) |

## 出典

自作。

参考: [2N7000 データシート (Vishay)](https://www.vishay.com/docs/70226/70226.pdf)、[オープンコレクタ (Wikipedia)](https://ja.wikipedia.org/wiki/オープンコレクタ)
