---
book: circuits
chapter: 10
id: 10-5
title: D フリップフロップ (4013) と T フリップフロップ
tier: 100
board: BB
source: 自作
---

# 10-5 D フリップフロップ (4013) と T フリップフロップ

10-2 の RS ラッチは、ボタンを押している間ずっと出力が入力に従った。フリップフロップ (FF) は
クロックの立ち上がり (L から H に変わる瞬間) にだけ入力を取り込み、それ以外の時間は
入力が変わっても出力を保つ。決まった瞬間にだけ値を写すので、カウンタやレジスタ (10-6) の
部品になる。

ここでは D フリップフロップの IC (CD4013、2 回路入り) を使う。1 回路はそのまま
D-FF (クロックの立ち上がりで D の値を Q に写す) として、もう 1 回路は Q̄ を D に戻す
配線で T-FF (クロックが来るたびに Q が反転する) に仕立てる。

## 回路図

```circuit
title: 図1 D-FFとQバー帰還のT-FF (CD4013)
parts:
  U1: ic 15,8 CD4013B
  VCC: vcc 6,1 5V
  SWD: switch 6,1 6,3 l=$\mathrm{SW}_\mathrm{D}$
  RpdD: resistor 6,3 6,5 10k l=$R_\mathrm{pdD}$
  GD: ground 6,5
  VCC: vcc 3,1 5V
  SWC1: button 3,1 3,3 l=$\mathrm{SW_{C1}}$
  RpdC1: resistor 3,3 3,5 10k l=$R_\mathrm{pdC1}$
  GC1: ground 3,5
  VCC: vcc 3,11 5V
  SWC2: button 3,11 3,13 l=$\mathrm{SW_{C2}}$
  RpdC2: resistor 3,13 3,15 10k l=$R_\mathrm{pdC2}$
  GC2: ground 3,15
  VCC: vcc 15,3 5V
  GU1: ground 15,12
  GS1: ground 10,8
  GS2: ground 12.5,10
  RQ1: resistor 25,10 25,11 1k l=$R_\mathrm{Q1}$
  DQ1: led 25,11 25,12 red l=$D_\mathrm{Q1}$
  GQ1: ground 25,12
  RQ2: resistor 22,10 22,11 1k l=$R_\mathrm{Q2}$
  DQ2: led 22,11 22,12 red l=$D_\mathrm{Q2}$
  GQ2: ground 22,12
wires:
  # FF1 (D-FF): D1 と CLOCK1 を左から入れる
  - U1.D1 -| 8,3
  - 8,3 -- 6,3
  - U1.CLOCK1 -| 4,3
  - 4,3 -- 3,3
  # FF2 (T-FF): Qバー2 を D2 へ戻し、CLOCK2 は左のボタンから
  - U1./Q2 -| 17,14
  - 17,14 -- 11,14 -- 11,8.5
  - U1.D2 -| 11,8.5
  - U1.CLOCK2 -| 4,13
  - 4,13 -- 3,13
  # 使わない SET・RESET は GND
  - U1.SET1 -| 10,7.5
  - U1.RESET1 -| 10,8
  - 10,8 -- 10,7.5
  - U1.SET2 -| 12.5,10
  - U1.RESET2 -| 12.5,10
  # 電源
  - 15,3 |- U1.VDD
  - U1.VSS |- 15,12
  # 出力
  - U1.Q1 -| 25,10
  - U1.Q2 -| 22,10
notes:
  - text 25,13 blue center: Q1
  - text 22,13 blue center: Q2
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/05-d-flip-flop.svg)

- FF1 (D-FF): SWD が D1 (PIN 5) を決める。SWC1 (CLK1、PIN 3) を押すと CLK1 が
  0V から +5V へ立ち上がり、その瞬間の D1 の値を Q1 (PIN 1) に写す。押している
  間や離したあとは D1 を変えても Q1 は動かない (次の立ち上がりまで保持)
- FF2 (T-FF): Q̄2 (PIN 12) を D2 (PIN 9) へ配線で戻してある。CLK2 (PIN 11) が
  立ち上がるたびに、Q2 (PIN 13) は今と反対の値を取り込むので反転する。SWC2 を
  1 回押すごとに DQ2 が点く・消えるを繰り返す。クロック 2 回で Q2 が 1 往復するので、
  周波数が半分になる (1/2 分周)。10-4 の 4040 の中では、この T-FF が 12 段つながっている
- 図1 の CD4013 (U1) は、ピンを働きで並べた箱で描いた。左に入力 (D・CLOCK・SET・RESET)、
  右に出力 (Q・Q̄)、上が VDD (PIN 14)、下が VSS (PIN 7)。PIN の番号は箱の中に添えてある。
  FF1 の入力 (D1・CLOCK1) と FF2 の入力 (D2・CLOCK2) は、ともに左から入る。
  Q̄2 から D2 への帰還の線だけが、箱の下を回って CLOCK2 の線と 1 か所で交わる
- LED の直列抵抗 RQ1・RQ2 は 1kΩ。10-1 と同じく、5V の CD4000 系の出力は数 mA しか
  流し出せない (TI の CD4013B のデータシートで I<sub>OH</sub> は出力 2.5V のとき最小 1.6mA)。
  1kΩ なら LED の電流は 1.5〜2.2mA (10-1 で求めた目安)。暗いときは高輝度 LED にする
- RESET (PIN 4・10)・SET (PIN 6・8) は CD4013 では H で働く (Q を強制的に 0・1 にする)。
  ここでは使わないので、両方 GND に落として無効にする
- ボタンの接点は、押した瞬間に細かく何度も跳ねて、オン・オフを繰り返す
  (チャタリング)。CLK にボタンをそのままつなぐと、1 回の押下で Q が 2 回以上
  反転して見えることがある。きれいな 1 パルスにするには 10-9 のチャタリング除去を足す

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む (CD4013 の D-FF と T-FF)
board: half
parts:
  PS:
    type: device
    at: top
    label: AD3
    pins: [V+, GND, 2+, W1, 1+, 1-, 2-]
  U1: dip14 @ e8 CD4013B
  RQ2: resistor b9 b6 1k
  DQ2: led d6(A) d3(K) red
  RQ1: resistor i8 i5 1k
  DQ1: led g5(A) g2(K) red
  SWC1: button @ e17
  RpdC1: resistor i17 i20 10k
  SWC2: button @ e21
  RpdC2: resistor b21 b25 10k
  SWD: switch g25 g29
  RpdD: resistor i25 i28 10k
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - -t1 -- -b1 black
  - +t30 -- +b30 red
  - a8 -- +t8 red
  - a12 -- -t12 black
  - a14 -- -t14 black
  - a3 -- -t3 black
  - d10 -- d13 orange
  - c11 -- c21 yellow
  - a17 -- +t17 red
  - j23 -- +b23 red
  - a25 -- -t25 black
  - j11 -- -b11 black
  - j13 -- -b13 black
  - j14 -- -b14 black
  - j2 -- -b2 black
  - g17 -- g10 yellow
  - j20 -- -b20 black
  - h12 -- h25 blue
  - j29 -- +b29 red
  - j28 -- -b28 black
  - PS.2+ -- a9 blue
  - PS.W1 -- a11 yellow
  - PS.1+ -- a21 yellow
  - PS.1- -- -t28 black
  - PS.2- -- -t29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/05-d-flip-flop.svg)

- 電源は Analog Discovery 3 (AD3、0-3 で使った USB 計測器) の Supplies で、V+ を 5V にする。
  AD3 の V+ を上の赤レール (1 列)、GND を上の青レール (2 列) へ。
  下のレールは青を 1 列、赤を 30 列 (右端) で上のレールとつなぐ
- U1 (CD4013) は 8〜14 列。切り欠きが左で、PIN 1 が左下 (f 行の 8 列)、PIN 14 (VDD) が左上 (e 行の 8 列)。
  下の列が PIN 1〜7 (FF1 のピンと VSS)、上の列が PIN 14〜8 (VDD と FF2 のピン)
- 電源: PIN 14 (8 列の上) を +5V へ、PIN 7 (14 列の下) を GND へ。使わない RESET・SET の
  PIN 4 (11 列の下)・PIN 6 (13 列の下)・PIN 10 (12 列の上)・PIN 8 (14 列の上) は GND へ
- FF1 (D-FF): SWD (g23 〜 g26) の 26 列を +5V に、23 列を青の線で PIN 5 (D1、12 列の下) へ。
  RpdD (10kΩ) が 23 列を GND に落とす。SWC1 (ボタン、17 列) は上の列を +5V に、
  下の列を黄の線で PIN 3 (CLK1、10 列の下) へ。RpdC1 (10kΩ) が下の列を GND に落とす。
  Q1 (PIN 1、8 列の下) は RQ1 (1kΩ) と DQ1 を通して GND へ
- FF2 (T-FF): オレンジの線で PIN 12 (Q̄2、10 列の上) を PIN 9 (D2、13 列の上) へ戻す。
  CLK2 (PIN 11、11 列の上) は黄の線で SWC2 (ボタン、22 列) の上の列へ渡す。SWC2 の下の列は +5V、
  RpdC2 (10kΩ) が上の列を GND に落とす。Q2 (PIN 13、9 列の上) は RQ2 (1kΩ) と DQ2 を通して GND へ
- 図2 では、CLK2 の列 (11 列と、黄の線でつながった 22 列) に AD3 の W1 と 1+ を、Q2 の列 (9 列) に 2+ を挿す。
  1− と 2− (黒) は上の青レール (GND) へ。W1 を挿すときは SWC2 を押さない (押すと W1 の出力が +5V につながる)
- ブレッドボードを流れる電流は、LED 2 個で約 2mA × 2、プルダウン抵抗 3 本で 5V ÷ 10kΩ = 0.5mA × 3 (ボタンやスイッチが閉じたとき)、
  CD4013 自身は数 µA で、全部で 6mA ほど。ブレッドボードの範囲 (1 穴 200mA・ブレッドボード全体 500mA) にも、AD3 の V+ を USB 給電で使うときの
  目安 (5V で 50mA) にも収まる

## 計器の設定

計器は AD3 の Supplies (電源)・Wavegen (クロックの信号源)・Scope (オシロ)。ボタンを押す間隔は人の手で決まり、
オシロで止めて見られないので、波形を見るときは SWC2 の代わりに W1 のクロックを CLK2 に入れる。
**Q2 がクロックの立ち上がりごとに反転し、周期がクロックの 2 倍になる** (2 分周) ことを見る。

| 項目 | 値 |
| --- | --- |
| 電源 | Supplies の V+ を 5V、V− は使わない |
| W1 | Square、100Hz、Amplitude 2.5V、Offset 2.5V (0〜5V)。SWC2 は押さない |
| CH1 (1+) | CLK2 (W1 と同じ点、PIN 11)。1V/div、0V を下から 1 目盛 |
| CH2 (2+) | Q2 (PIN 13)。CH1 と同じ 1V/div・同じ 0V の位置 |
| 1−・2− | GND |
| 時間レンジ | 5ms/div |
| トリガ | CH1 の立ち上がり、1.8V。トリガの点を左から 1 目盛に置く |
| Measurements | Frequency・Vmax・Vmin |
| カーソル | X1 をクロックの High の中 (2.5ms)、X2 をその 2 周期あと (22.5ms) に置く。ΔX = 20ms の逆数が Q2 の周波数 |

```scope
title: 図3 クロック (CH1) と Q2 (CH2) — Q2 はクロックの立ち上がりで反転し、周波数は半分
time: 5ms/div
trigger: ch1 rising 1.8V at -4div
ch1: {wave: square 100Hz 2.5V offset 2.5V duty 50%, range: 1V/div, position: -3div}
ch2: {wave: square 50Hz 2V offset 2V, range: 1V/div, position: -3div}
cursors: [2.5ms, 22.5ms]
measure: [freq, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/05-d-flip-flop.svg)

- 図3 の CH1 (クロック) は 0V と 5V を行き来し、周波数は 100Hz (周期 10ms)。
  CH2 (Q2) はクロックの立ち上がりのたびに (0・10ms・20ms…) 0V と約 4V が入れ替わる。立ち下がりでは動かない
- カーソルの ΔX = 20ms から、1/ΔX = 50Hz。クロックの半分で、Q2 の周期はクロックの 2 周期
- Q2 の High は LED に 2mA ほど流しながら約 4V (10-1 の目安。標準の品)。D-FF の側 (Q1) は、
  W1 を CLK1 に挿し替え、D1 を SWD で切り替えれば同じ形で見られる

## 見るべき値

| 操作 | Q1 (DQ1) | Q2 (DQ2) |
| --- | --- | --- |
| SWD を閉じて (D1 = 1) SWC1 を押す | 点灯 (1) に変わる | — |
| SWD を開けて (D1 = 0) SWC1 を押す | 消灯 (0) に変わる | — |
| SWD を変えずに SWC1 をもう一度押す | 変わらない (直前の値を保持) | — |
| SWD を切り替えるだけ (SWC1 は押さない) | 変わらない | — |
| SWC2 を 1 回押す | — | 反転 (消灯→点灯 か 点灯→消灯) |
| SWC2 をもう 1 回押す | — | また反転 (元に戻る) |

T-FF の Q2 は、CLK2 を 2 回押してようやく 1 周する。CLK2 に一定間隔のパルス
(例えば 3-2 の 555 の出力) を入れれば、Q2 はその半分の周波数で振れる。

## 出典

自作。
