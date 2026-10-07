---
book: circuits
chapter: 7
id: 7-1
title: リレー駆動 — Tr + フライバックダイオード
tier: 50
source: 自作
board: BB
---

# 7-1 リレー駆動 — Tr + フライバックダイオード

リレーは、コイルに電流を流すと電磁石が接点を引き寄せて、別の回路を入り切りする部品だ。
小さな信号で、モータや大きな電流の機器を動かすのに使う。
ただしリレーのコイルは、マイコンの GPIO (信号の出入りに使うピン。数 mA しか出せない) では直接動かせないほど電流を食う。
そこでトランジスタ (2-1 で見たスイッチ) で駆動し、コイルを切った瞬間の逆起電力 (6-2 で見た) から
トランジスタを守る**フライバックダイオード**を、コイルと並列に入れる。
6-2 では逆起電力で LED を光らせたが、今度はダイオードで逃がして打ち消す側に使う。

## 回路図

```circuit
title: 図1 トランジスタでリレーを駆動する (IN は AD の W1、CH1 は IN、CH2 はコレクタ)
parts:
  VCC: vcc 5,2 5V
  D1:  diode 3,6 3,3 1N4148
  K1:  relay 5.88,5 r180 mirror G5V-2
  Q1:  npn 5,8
  R1:  resistor 2,8 4,8 1k
  IN:  port 2,8
  G1:  ground 5,9
  R2:  resistor 7,7 9,7 330
  D2:  led 9,7 11,7
  G2:  ground 11,8
  M1:  voltmeter 2,9 2,11 l=$\mathrm{CH1}$
  G3:  ground 2,11
  M2:  voltmeter 1,6 1,9 l=$\mathrm{CH2}$
  G4:  ground 1,9
wires:
  - 5,2 -- 5,3 -- 3,3
  - K1.A2 |- 5,3
  - K1.A1 |- 5,6
  - 3,6 -- 5,6 -- Q1.C
  - 4,8 -- Q1.B
  - Q1.E -- 5,9
  - K1.COM1 |- 5,3
  - K1.NO1 |- 7,7
  - 11,7 -- 11,8
  - 2,8 -- 2,9
  - 3,6 -- 1,6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/01-relay-driver.svg)

- IN (GPIO など) が H (High、ここでは 5 V) になると、R1 (1 kΩ) を通してベース電流が流れる。
  Q1 が飽和して (2-1 で見た、完全に ON の状態) コイル (K1 の A1-A2) に電流が流れ、リレーが接点を引き寄せる
- D1 はコイルと並列に、電源側がカソードになる向きに入れる。コイルに電流が流れている間は
  逆向きの電圧しか掛からず、電流は流れない。Q1 が切れた瞬間だけコイルの
  逆起電力を吸い取って、Q1 のコレクタに高い電圧が掛かるのを防ぐ (6-2 と同じ理屈)
- 接点 (COM1・NO1) はコイルとは別の回路。COM は共通の端子、NO (Normally Open) はふだん開いていて
  リレーが引くと COM とつながる端子をいう。ここでは COM1 を同じ 5 V につなぎ、
  NO1 から R2 を通して LED (D2) を点けている。
  実際は、接点側にもっと高い電圧・電流の負荷 (モータ、AC 100 V の機器など) を
  つなぐためにリレーを使う (この教科書では AC 100 V はつながない)

## 実体配線図

```breadboard
title: 図2 トランジスタでリレーを動かす (W1 が IN、1+ が IN、2+ がコレクタ)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源 5V (AC アダプタ等)
    pins: ["+", "-"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery (W1 と Scope)
    pins: [W1, 1+, 1-, 2+, 2-, GND]
  K1: relay @ f10
  Q1: transistor i4(E) i5(C) i6(B) 2SC1815
  R1: resistor f1 f6 1k
  D1: diode i10(A) i13(K) 1N4148
  R2: resistor g17 g21 330
  D2: led h21(A) h22(K) red
wires:
  - PSU.+ -- +t2 red
  - PSU.- -- -t3 black
  - +t10 -- a10 red
  - g5 -- g10 yellow
  - j4 -- -b4 black
  - AD.W1 -- j1 orange
  - AD.1+ -- i1 blue
  - AD.2+ -- j5 green
  - AD.1- -- -b7 black
  - AD.2- -- -b9 black
  - AD.GND -- -b11 black
  - g13 -- +b13 red
  - j22 -- -b22 black
  - +t30 -- +b30 red
  - -t29 -- -b29 black
notes:
  - text: オレンジの線 (1 列) が IN。W1 が 5V のとき Q1 が入り、リレーが引いて LED が点く
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/01-relay-driver.svg)

- リレーは胴の左端を 10 列に置き、中央の溝をまたいで挿す。ピンの並びは、切り欠きを左にした実物を上から見た
  並び (1 番の `A1` が左下の f10)
- Q1 (2SC1815) は平らな面を見て左から E・C・B。平らな面を手前 (j 行側) に向けて
  i 行の 4・5・6 列に挿す。コレクタ (5 列) は g5 から黄色の線で 10 列 (コイルの `A1`) へつなぐ
- D1 (フライバックダイオード) は、アノードをコイルの `A1` と同じ 10 列 (Q1 のコレクタ側)、
  カソードを 13 列 (`COM1` と同じ列で、g13 から + レールへつながる) に挿す。
  これでコイルと並列・逆向きに入る (コイルの `A2` は 10 列の上のブロックから + レールへ)
- 5 V の電源は別の電源 (5 V の AC アダプタや電源装置) を使う。コイルが約 100 mA、LED が約 9 mA で、
  Analog Discovery の Supplies の各レール 50 mA (USB 給電で 250 mW) を超えるため、AD3 は信号 (W1) とオシロ (Scope) だけに使う
- IN (1 列) には AD の W1 (オレンジ) を入れる。1+ (青) は同じ 1 列 (`i1`) で IN を、2+ (緑) は Q1 のコレクタの 5 列 (`j5`) を見る。
  1−・2−・GND (黒) は下の − レールへ。W1 の出力は約 0 Ω・30 mA までで、ベース電流 約 4.3 mA は余裕で出せる
- 使わない 2 回路目 (`COM2` `NC2` `NO2`) は空けたまま

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| K1 | リレー (Omron G5V-2、5 V) | コイル抵抗 50 Ω、定格コイル電流 100 mA |
| Q1 | NPN トランジスタ | 2SC1815 |
| R1 | 抵抗 | 1 kΩ |
| D1 | 小信号ダイオード (フライバック用) | 1N4148 |
| R2 | 抵抗 | 330 Ω |
| D2 | LED (赤) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V の AC アダプタか電源装置 (負荷が 約 110 mA で AD3 の Supplies の 50 mA を超えるため) |
| — | 計器・入力 | Analog Discovery 3 の W1 (IN。0 V / 5 V の方形波) と Scope (1+ = IN、2+ = コレクタ、1−・2− = GND) |

## 計器の設定

計器は Analog Discovery 3 の W1 (IN に入れる 0 V / 5 V の方形波) と Scope。リレーの入り切りは波形の変わり目で見るので、W1 を 10 Hz にして、
CH1 (IN) と CH2 (コレクタ) を同じ 1 V/div で重ねる。WaveForms の W1 は Simple の Square、Amplitude 2.5 V、Offset 2.5 V。

```scope
title: 図3 IN (CH1) とコレクタ (CH2) — 逆向きに動く
time: 20ms/div
trigger: ch1 rising 2.5V
ch1: {wave: square 10Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: square 10Hz 2.4V offset 2.6V phase 180deg, range: 1V/div, position: -3div}
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/01-relay-driver.svg)

図3 は理想の形で、CH2 は 5 V (Q1 が切れてコイルの先が 5 V) と 0.2 V (飽和) の間を、CH1 と逆向きに動く。
実物は Q1 が切れる瞬間、コイルの逆起電力で D1 が導通し、コレクタが一瞬だけ約 5.7 V (= 5 V + D1 の順方向電圧 0.7 V) になる。
D1 が無いとこの山が数十 V に達しうる (この教科書では外して試さない)。山の幅はコイルのインダクタンスで決まり、
このリレーの値を確かめていないので図3 には描かない。LED とリレーの「カチッ」は、CH1 が 5 V の間だけ続く。

## 見るべき値

表の値は計算値。2SC1815 は hFE ≥ 70 (O ランクの下限)、G5V-2 の 5 V 品はコイル抵抗 50 Ω・
定格コイル電流 100 mA (Omron のデータシート値) とした。
電圧はテスターの DC 電圧レンジで、− 側の棒を GND に当てて測る。コイルの電流は、
テスターの電流 (mA) レンジを + レールとコイルの `A2` の間に直列に入れて測る。
リレーが引くと「カチッ」と音がして、LED (D2) が点く。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電流 (IN = 5 V のとき) | 約 4.3 mA (= (5 − 0.7) / 1 kΩ) | R1 で決まる |
| 飽和に要る最小ベース電流 | 約 1.4 mA (= 100 mA / 70) | 4.3 mA はこれより十分大きく、Q1 は確実に飽和する |
| コイルの電流 (リレーが引いているとき) | 約 100 mA (= 5 V / 50 Ω) | データシートの定格どおり |
| Q1 の C-E 間電圧 (飽和時) | 0.2 V 以下 | ほぼ電源電圧がそのままコイルに掛かる |
| D1 に電流が流れる瞬間 | Q1 を OFF にした直後だけ | それ以外は逆向きの電圧を受けているだけで電流は流れない |
| D1 を外したとき | Q1 の C-E 間に瞬間的に高い電圧が掛かる (壊れることがある) | フライバックダイオードが要る理由。**この教科書では外して試さない** |

## 出典

自作。
