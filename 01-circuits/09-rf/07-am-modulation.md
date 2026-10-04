---
book: circuits
chapter: 9
id: 9-7
title: AM 変調 — 555 の搬送波を音声で振る
tier: 100
source: 自作
board: BB
---

# 9-7 AM 変調 — 555 の搬送波を音声で振る

**AM (振幅変調)** は、一定の周波数の搬送波を、音声の大きさに合わせて
**振幅だけ**上下させる方式。555 の出力の H レベルは電源電圧そのものなので、
**555 の電源に音声を混ぜてやる**と、出力の振幅が音声にあわせて揺れる —
乱暴だが仕組みの分かりやすい AM 変調器になる。
9-2〜9-5 のラジオが受けていた AM の電波を、ここでは自分で作り、オシロとスペアナで中身を見る。

> [!WARNING]
> 出力をごく小さな結合コンデンサ (Cant) と短いループ線で近くの AM ラジオへ
> 渡すだけの実験にする。9-4 と同じく**電波法の微弱無線局**の範囲 (322MHz
> 以下、距離 3m で電界強度 500µV/m 以下、電波法施行規則第 6 条) に収める
> ため、**ループ線を伸ばしたり、後段を増幅したりしない**。

この題の流れ:

1. 回路図 (図1): 555 の搬送波、電源に音声を混ぜる変調、音声源の条件と PIN 8 に届く振れの計算
2. 実体配線図 (図2) と部品
3. 計器の設定: オシロのつなぎ方 (図3) とスペアナのつなぎ方 (図4)
4. 見るべき値: ラジオで聞く → オシロで時間の波形を見る (図5〜7) → スペアナで周波数の線を見る (図8・図9)

## 回路図

```circuit
title: 図1 555の電源に音声を混ぜてAM変調する
parts:
  V1: sine c2 e2 0.5
  GV1: ground e2
  Cmod: capacitor c2 c4 1u
  VCC: vcc a8 5V
  Rmod: resistor a8 c8 220
  U555: ic g10 TLC555
  GU555: ground j10f0
  R1: resistor c6 e6 1k
  R2: resistor f6f0 h6f0 10k
  C1: capacitor h8f0 j8f0 100p
  GC1: ground j8f0
  Cant: capacitor g14 g16 100p
  ANT: port g17
wires:
  - c4 -- c10a5
  - U555.VDD |- c10
  - U555.RESET |- c10a5
  - e6 -- f6f0
  - U555.DISCH -| f6f0
  - U555.THRES -| g8
  - U555.TRIG -| g8f0
  - g8 -- h8f0
  - h6f0 -- h8f0
  - U555.GND |- j10f0
  - U555.OUT -| g14
  - g16 -- g17
notes:
  # 計測点。オシロは橙、スペアナは緑 (計器の設定の表と同じ名前)
  - arrow b1 c2 orange
  - text a1h0 small orange left: 音声
  - arrow b9f5 c9a5 orange
  - text b9c5 small orange center: PIN 8
  - arrow e12f0 g12 orange
  - text e12c0 small orange center: PIN 3
  - arrow h17f0 g17 orange
  - text h17h0 small orange right: ANT
  - arrow i12 i10 orange
  - text i12 small orange left: オシロ GND
  - arrow e13f5 g13a5 green
  - text e13c5 small green center: スペアナ入力
  - arrow i12h0 i10h0 green
  - text i12h0 small green left: スペアナ GND
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/07-am-modulation.svg)

- **搬送波**: R1 (1kΩ)・R2 (10kΩ)・C1 (100pF) の 555 非安定。
  f = 1.44/((R1+2R2)C) = 1.44/((1k+20k)×100p) **≈ 686kHz** — 日本の
  AM 放送帯 (531kHz〜1602kHz) の中
- **変調**: V1 (信号発生器、1 kHz の正弦波) を Rmod (220Ω) と Cmod (1µF) を介して
  555 の電源ピン (PIN 8) へ混ぜる。555 の出力 H は「そのときの電源電圧」なので、
  電源が音声で揺れれば**出力の振幅も一緒に揺れる** — これが AM
- **CMOS 版 (TLC555) を使う理由**: バイポーラの NE555 は動作下限が
  4.5V ほどだが、TLC555 は 2V まで動く。電源に深く音声を混ぜて振幅変調を
  深くしても (瞬間的に電源電圧が下がっても)、発振が止まりにくい
- Rmod は音声源からみた直流の道筋を分け、Cmod は音声の交流分だけを
  PIN 8 へ渡す結合コンデンサ。**変調度**は音声の振幅 ÷ PIN 8 の直流の電圧
  (約 4.4 V、下の項目) で決まり、深くしすぎる (音声振幅が電源電圧に迫る) と
  波形がつぶれて歪む
- **音声源 (V1) の想定**: 0-6 のファンクションジェネレータを **1 kHz の正弦波・
  振幅 0.5 V** (発生器の表示値) にしたものを想定する。1 kHz は試験音の定番で、
  AM ラジオが通す音声の帯域 (数 kHz まで) の中にあり、スペアナで側波 (9-4 で見た、搬送波の両側に立つ線) を搬送波と
  分けて見られる (中心 686 kHz・スパン 10 kHz)。声や音楽を入れたければ、
  スマホのイヤホン出力やマイクアンプの出力でもよい (次の項目の負荷の条件つき)
- **音声源のインピーダンス**: 多くのファンクションジェネレータは出力に 50 Ω の
  抵抗を持つ (9-1 と同じ)。計算はその **50 Ω** で行い、出力抵抗がほぼ 0 Ω の
  発生器 (Analog Discovery の W1 など) では PIN 8 の振れが 15 % ほど大きく出る。
  V1 から見た負荷は Cmod (1 kHz で約 159 Ω) と Rmod (220 Ω。VCC は交流では
  GND と同じ) の直列で、**1 kHz で約 270 Ω** (555 自身が流す電流の分は無視)。PIN 8 に届く振れは V1 の 220/√((50+220)² + 159²) ≈ **0.70 倍** (0.5 V → 約 0.35 V)。
  約 270 Ω は、10 kΩ 以上の負荷を前提にしたライン出力には重いが、32 Ω のイヤホンを
  鳴らせるスマホのイヤホン出力 (振幅は最大でも 1 V 前後なので、変調度は 20 % ほどまで) や、
  OP アンプのマイクアンプの出力 (LM358 でも 10 mA ほど流せる) なら、振幅 2 V くらいまで駆動できる
- **音声の周波数で分圧が変わる**: Cmod と (50 + 220) Ω はハイパスで、−3 dB は
  約 590 Hz (1/(2π×270Ω×1µF))。1 kHz で 0.70 倍のものが 300 Hz で 0.37 倍、
  100 Hz で 0.14 倍になり、声を入れると低音が細い電話のような音になる。低い音まで
  通したいなら Cmod を 10 µF (電解) にする。−3 dB が約 59 Hz へ下がり、1 kHz の分圧は
  0.81 倍に上がるので、下の表の PIN 8 の振れは 1.16 倍で読み替える
- **Rmod の直流の降下**: R1 (1kΩ) は PIN 7 が L の間 (周期の約 47 %)、PIN 8 の電圧を
  GND へ流す。PIN 8 の電流はパルスで約 4 mA、平均 3 mA 前後になり、Rmod (220Ω) で
  約 0.6 V 落ちて **PIN 8 の直流は約 4.4 V**。これが搬送波の H の高さで、変調度の分母
- **ANT はループ線** (Cant 経由の弱い結合)。近くの中波 AM ラジオを 686kHz
  付近に合わせると、方形波なので歪みつつも音声が聞こえる

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  GEN:
    type: device
    at: top
    label: 信号発生器 1kHz 0.5V
    pins: [GND, OUT]
  ANT:
    type: device
    at: bottom
    label: ループ線
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - ANT.1 -- j27 yellow
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/07-am-modulation-1.svg)

- 上の赤レール = +5V (USB や電池)、青レール = GND。30 列で上下の − レールを渡している
- U555 は 20〜23 列で溝をまたぐ (切り欠きを左、1 番は左下の f20)
- 16 列が 555 の電源のネット (PIN 8 から a 行の線、PIN 4 から g 行の線)。Rmod で +5V から、
  Cmod で発生器 (GEN) から入る
- PIN 7 (21 列) と 16 列の間に R1、PIN 7 と 25 列の間に R2。PIN 6 (c 行の線) と PIN 2
  (h 行の線) を 25 列にまとめ、C1 で GND へ
- ループ線は PIN 3 (22 列) から Cant を通した 27 列 (下、j27)
- PIN 1 (20 列) は h 行の線で 13 列へ出し、そこから下の − レールへ落とす (j 行を計器のために空けておく)
- 計器のつなぎ方は「計器の設定」の図3 (オシロ) と図4 (スペアナ)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U555 | CMOS タイマ IC | TLC555 (バイポーラの NE555 は動作下限 4.5 V なので不可) |
| R1 | 抵抗 | 1 kΩ |
| R2 | 抵抗 | 10 kΩ |
| C1 | セラミックコンデンサ (時定数) | 100 pF |
| Rmod | 抵抗 (555 の電源の給電) | 220 Ω |
| Cmod | セラミックコンデンサ (音声の結合) | 1 µF |
| Cant | セラミックコンデンサ (アンテナ結合) | 100 pF |
| Rsa | 抵抗 (スペアナの入力を絞る。測るときだけ) | 10 kΩ |
| Csa | セラミックコンデンサ (スペアナの入力の直流を切る。測るときだけ) | 0.01 µF |
| — | ループ線 | 短い線 (伸ばさない) |
| — | 信号源 (V1) | 信号発生器 (0-6 のファンクションジェネレータ)。1 kHz 正弦波、振幅 0.5 V (表示値)、出力 50 Ω |
| — | 電源 | 5 V (USB や電池) |

## 計器の設定

オシロスコープ (2 チャンネル) と、スペクトラムアナライザ (tinySA など) で調べる。
どちらのグランドも − レールに取る。

| 項目 | 設定 |
| --- | --- |
| プローブ | 2 本とも 10:1。測る点は下の 4 つで、図ごとに付け替える |
| PIN 3 (搬送波) | 22 列の空き穴 (j22)。DC 結合 |
| ANT (Cant の先) | 27 列の空き穴 (j27。ループ線は g 行の短い線で 28 列へ延ばした j28 に挿し替える)。DC 結合 |
| 音声 (発生器の端子) | Cmod の発生器側、10 列の空き穴 (c10)。DC 結合 |
| PIN 8 (555 の電源) | 16 列の空き穴 (j16)。AC 結合で音声の揺れだけを見る |
| 搬送波を見るとき (図5) | CH1 PIN 3 (2 V/div)、CH2 ANT (1 V/div)。0.5 µs/div、トリガは CH1 の立ち上がり |
| 包絡線の山と谷を比べるとき (図7) | PIN 3 を 1 V/div・位置 −2.5 目盛 (0 V が下から 1.5 目盛)、0.5 µs/div。山の波を Reference に残し、谷の波と重ねる |
| 音声を見るとき (図6) | CH1 音声、CH2 PIN 8。どちらも 200 mV/div、200 µs/div、トリガは CH1 の立ち上がり |
| 変調の包絡線を見るとき | CH1 PIN 3 (1 V/div)、CH2 PIN 8。200 µs/div、トリガは CH2 (音声) の立ち上がり |
| スペアナのつなぎ方 | PIN 3 の空き穴 (j22) から **10 kΩ (Rsa) と 0.01 µF (Csa) を直列に**通して入力 (50 Ω) へ (図4。j22 → j19 の線 → Rsa → Csa → h10)。入力に届くのは搬送波で約 −27 dBm (計算値) で、入力の上限に十分収まる。**PIN 3 を直に入力へつながない** (4〜5 V の方形波は入力の上限を超える) |
| スペアナの掃引 | 無変調の高調波を見るとき: 開始 100 kHz・終了 4 MHz。側波を見るとき: 中心 686 kHz・スパン 10 kHz、RBW 300 Hz 以下 (tinySA Ultra は 200 Hz まで絞れる) |

- PIN 2・6 (25 列) にはプローブを当てない。プローブの容量 (10〜15 pF) が C1 (100 pF) に
  足されて、搬送波の周波数が 1 割ほど下がる
- RBW を 1 kHz より十分細くできないスペアナでは、V1 を 10 kHz にすると、
  側波が搬送波から 10 kHz 離れて見分けやすい (Cmod の分圧が緩むので、PIN 8 の振れは
  0.5 V × 0.81 ≈ 0.41 V に増える)

### オシロスコープのつなぎ方

```breadboard
title: 図3 オシロスコープをつなぐ (PIN 3 と ANT を見るとき)
board: half
parts:
  GEN:
    type: device
    at: top
    label: 信号発生器 1kHz 0.5V
    pins: [GND, OUT]
  SCOPE:
    type: device
    at: bottom
    label: オシロスコープ
    pins: [GND, CH1, CH2]
  ANT:
    type: device
    at: bottom
    label: ループ線
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - g27 -- g28 yellow
  - ANT.1 -- j28 yellow
  - -t30 -- -b30 black
  - SCOPE.CH1 -- j22 purple
  - SCOPE.CH2 -- j27 pink
  - SCOPE.GND -- -b17 black
notes:
  - circle j22
  - circle j27
  - circle -b17
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/07-am-modulation-2.svg)

- 赤い丸はプローブを当てる穴と GND のクリップの所。図は PIN 3 (CH1) と ANT (CH2) を見るとき (図5)。GND のクリップは下の − レールへ
- ループ線は g27〜g28 の短い線 (黄) で 28 列へ延ばして j28 に挿し替え、空いた j27 に CH2 を当てる。
  プローブの線とループ線が同じ列に並んで触れないようにするため
- 音声と PIN 8 を見るとき (図6) は、CH1 を c10、CH2 を j16 に付け替える

### スペアナのつなぎ方

```breadboard
title: 図4 スペアナをつなぐ (10 kΩ と 0.01 µF を通す)
board: half
parts:
  GEN:
    type: device
    at: top
    label: 信号発生器 1kHz 0.5V
    pins: [GND, OUT]
  SA:
    type: device
    at: bottom
    label: スペアナ (tinySA)
    pins: [IN, GND]
  ANT:
    type: device
    at: bottom
    label: ループ線
    pins: ["1"]
  U555: dip8 @ e20 TLC555
  Rmod: resistor b16 b12 220
  Cmod: capacitor/ceramic d10 d16 1u
  R1: resistor c16 c21 1k
  R2: resistor a21 a25 10k
  C1: capacitor/ceramic d25 d29 100p
  Cant: capacitor/ceramic i22 i27 100p
  Rsa: resistor i19 i14 10k
  Csa: capacitor/ceramic f14 f10 0.01u
wires:
  - GEN.OUT -- a10 green
  - GEN.GND -- -t8 black
  - +t12 -- a12 red
  - a20 -- a16 orange
  - e16 -- f16 orange
  - g23 -- g16 orange
  - c22 -- c25 blue
  - e25 -- f25 blue
  - h21 -- h25 blue
  - a29 -- -t29 black
  - h20 -- h13 black
  - j13 -- -b13 black
  - ANT.1 -- j27 yellow
  - -t30 -- -b30 black
  - j22 -- j19 purple
  - SA.IN -- h10 purple
  - SA.GND -- -b12 black
notes:
  - circle j22
  - circle h10
  - circle -b12
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/07-am-modulation-3.svg)

- 図2 から足したのは Rsa (i14〜i19)・Csa (f10〜f14)・紫の線 (j19〜j22) と、スペアナの 2 本。赤い丸は線をつなぐ穴
  (PIN 3 の取り出し口 j22、入力の h10、GND の − レール)。Rsa (10 kΩ) と Csa (0.01 µF) で PIN 3 の方形波を小さくし、直流を切ってから入力へ渡す。
  **PIN 3 を直に入力へつながない**
- オシロのプローブ (図3) を外してからつなぐ。どちらも PIN 3 の j22 を使う

## 見るべき値

計算値。VCC = 5V (USB や電池)、V1 は出力 50 Ω の発生器とする。PIN 8 の直流は Rmod の降下で約 4.4 V (回路図の項目)。

| 確かめること | 期待する値 |
| --- | --- |
| 搬送波の周波数 (無変調時) | f ≈ 686kHz (計算値) |
| V1 を 1 kHz 正弦波・振幅 0.5 V にする | 近くの AM ラジオ (686kHz 付近) から 1kHz の音が聞こえる |
| V1 の振幅を 2 V にする | 変調度 約 32% (PIN 8 の揺れ 約 1.4 V ÷ 4.4 V、計算値)。音は 0.5 V のときの 4 倍 (+12dB) になり、歪みはまだ目立たない |
| V1 の振幅を 3.4 V より大きくする | PIN 8 の谷 (4.4 V − 2.4 V) が TLC555 の動作下限 (2V) を割り、谷ごとに発振が途切れて音がひどく歪む (変調が深すぎる目安。変調度 約 55% 以上、計算値)。出力 0 Ω の発生器なら 3.0 V から (このとき V1 の電流は約 11 mA。Analog Discovery 3 の Wavegen は 30 mA まで流せる) |
| V1 を外す | 無変調の搬送波だけになり、ラジオからは「サー」という単調な音 (方形波の高調波混じり) |

### オシロスコープで見る

計算値。t<sub>H</sub> = 0.693(R1+R2)C ≈ 0.76 µs、t<sub>L</sub> = 0.693·R2·C ≈ 0.69 µs。
破線の図は計算で描いた「見えるはずの画面」。

信号は **音声 → PIN 8 → PIN 3 (搬送波) → ANT** の順に流れる。まず V1 を外し、搬送波と ANT を見る。

```scope
title: 図5 無変調の搬送波 — PIN 3 (CH1) と ANT (CH2)
time: 0.5us/div
trigger: ch1 rising 2.2V
ch1: {wave: square 686kHz 2.2V offset 2.2V duty 52%, range: 2V/div, position: 0.5div}
ch2: {wave: ch1 | gain 0.87 | offset -1.99V, range: 1V/div, position: -2div}
measure: [vpp, vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/07-am-modulation-1.svg)

- PIN 3 (CH1) は 0〜4.4 V の方形波。H の高さは PIN 8 の電圧そのもの
- ANT (CH2) は Cant で直流が切れ、**0 V を中心に振れる** (+1.84〜−1.99 V)。平均が 0 V に
  なるので、デューティ 52 % のぶん H のほうが低い。振幅は PIN 3 の 0.87 倍 (4.4 → 3.83 V<sub>pp</sub>)。
  Cant (100 pF) とプローブの容量 (約 15 pF) の分圧で、100/(100+15) ≈ 0.87
- 電波として出ていくのは、この ANT の方形波 (と、その高調波)

次に V1 を 1 kHz・0.5 V にして、音声が PIN 8 に届くまでを見る。

```scope
title: 図6 音声の通り道 — 発生器の端子 (CH1) と PIN 8 (CH2、AC結合)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.43V, range: 200mV/div}
ch2: {wave: sine 1kHz 0.35V phase 36deg, range: 200mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/07-am-modulation-2.svg)

- 発生器の端子 (CH1) は 0.5 V ではなく **約 0.43 V** (0.86 V<sub>pp</sub>)。負荷 (約 270 Ω) に
  電流を流すぶん、発生器の中の 50 Ω で落ちる
- PIN 8 (CH2) は端子の 0.81 倍 (0.35 V) で、**位相が 36° 進む**。Cmod (159 Ω) と Rmod (220 Ω) の
  分圧で、コンデンサを通った電流は電圧より進むため (tan⁻¹(159/220) ≈ 36°)
- 実機の CH2 には、686 kHz の細かい揺れ (0.2 V ほど) が太く乗る (下の表)。図は音声の成分だけ

最後に、変調された PIN 3 を見る。200 µs/div では、搬送波の 1 周期 (1.46 µs) は細かすぎて
1 本ずつは見えず、**H の頂が作る包絡線**が PIN 8 と同じ 1 kHz で揺れる帯に見える
(この画面は scope の図では描けないので、下の表の値で確かめる)。
包絡線の山と谷で 0.5 µs/div に広げて見比べると、AM の要点が分かる。

```scope
title: 図7 PIN 3 の搬送波 — 包絡線の山 (CH1) と谷 (CH2) を重ねる
time: 0.5us/div
trigger: ch1 rising 2V
ch1: {wave: square 686kHz 2.375V offset 2.375V duty 52%, range: 1V/div, position: -2.5div}
ch2: {wave: square 686kHz 2.025V offset 2.025V duty 52%, range: 1V/div, position: -2.5div}
measure: [vmax, freq, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/07-am-modulation-3.svg)

- 実機では 1 本のプローブ (PIN 3) で、山で取り込んだ波を基準の波形 (Reference) に残し、
  谷の波と重ねる。図の CH2 はその 2 回目の取り込み
- **高さ (4.75 V と 4.05 V) だけが違い、周期は同じ 1.458 µs**。電源が揺れても
  周波数は動かず、振幅だけが動く — これが AM

| 確かめること | 期待する値 |
| --- | --- |
| 無変調の PIN 3 (CH1、0.5 µs/div) | 方形波。周期 ≈ 1.46 µs (686 kHz)、H ≈ 4.4 V (PIN 8 の電圧。Rmod の降下ぶん 5 V より低い)、デューティ ≈ 52 % |
| 無変調の ANT (CH2) | 0 V を中心とする方形波、+1.84〜−1.99 V (3.83 V<sub>pp</sub>、図5) |
| V1 を 1 kHz・0.5 V にしたときの発生器の端子 | 1 kHz の正弦波、振幅 約 0.43 V (発生器の 50 Ω で落ちる。図6) |
| V1 を 1 kHz・0.5 V にしたときの PIN 8 (CH2) | 1 kHz の正弦波、振幅 約 0.35 V (0.5 V × 0.70。Cmod の 159 Ω と、発生器の 50 Ω + Rmod の 220 Ω の分圧)。端子より位相が 36° 進む (図6)。その上に 686 kHz の細かい揺れが 0.2 V ほど乗る (R1 の約 4 mA の脈動が Cmod を通して発生器の 50 Ω に落ちるため。出力 0 Ω の発生器ではほとんど乗らない) |
| そのときの PIN 3 (CH1、200 µs/div) | 方形波の H の頂が 1 kHz で 約 4.05〜4.75 V に揺れる (包絡線)。L は 0 V のまま。変調度 m = (4.75 − 4.05)/(4.75 + 4.05) ≈ 8 % |
| 包絡線の山と谷で、搬送波の周期をカーソルで測る | どちらも ≈ 1.46 µs。555 のしきい値は電源電圧に比例するので、電源が揺れても周波数は動かず、振幅だけが動く (AM) |

### スペクトラムアナライザで見る

計算値。レベルは 10 kΩ + 0.01 µF で取り出したときの入力 (50 Ω) での値。
入力に届くのは、PIN 3 の方形波 (±2.2 V) の約 1/200 (50 Ω ÷ 10 kΩ)、peak 約 10.9 mV の方形波。

```spectrum
title: 図8 無変調の高調波 (100 kHz〜4 MHz)
device: tinysa-ultra
sweep: 100k-4M 450
rbw: 10kHz
ref: -20dBm
signal: square 686kHz 10.9mV duty 52%
markers: [686k, 1372k, 2058k, 3430k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/07-am-modulation-1.svg)

- マーカーは 1 = 基本波 (686 kHz)、2 = 2 次、3 = 3 次、4 = 5 次 (3430 kHz)。4 次 (2744 kHz) には置いていない
- 方形波なので奇数次 (3 次・5 次) が大きく、1/n で並ぶ。デューティが 50 % から少し
  ずれているぶん、偶数次 (2 次 1372 kHz、4 次 2744 kHz) も小さく出る
- 2 次 (1372 kHz) は AM 放送帯の中。ラジオでも弱く受かる

```spectrum
title: 図9 1 kHz・0.5 V で変調した側波 (中心 686 kHz・スパン 10 kHz)
device: tinysa-ultra
center: 686kHz
span: 10kHz
rbw: 200Hz
points: 450
ref: -20dBm
signal:
  - sine 686kHz -27.1dBm
  - sine 685kHz -55.1dBm
  - sine 687kHz -55.1dBm
markers: [peak, 685k, 687k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/spectrum/07-am-modulation-2.svg)

- 搬送波の両側 ±1 kHz (音声の周波数) に側波が立つ。側波の大きさは搬送波の m/2 = 0.04 倍 (−28 dB)
- 図6 で見た音声が、周波数の軸ではこの 2 本の側波になる。音声の周波数を変えると側波の間隔が、
  振幅を変えると側波の高さが変わる

| 確かめること | 期待する値 |
| --- | --- |
| 無変調の搬送波 | 686 kHz に線、約 −27 dBm |
| 無変調の高調波 (100 kHz〜4 MHz) | 3 次 (2058 kHz) が搬送波より約 −10 dB、5 次 (3430 kHz) が約 −14 dB。デューティが 50 % に近いので、偶数次 (2 次の 1372 kHz、4 次の 2744 kHz) は約 −24 dB と小さい (図8) |
| 2 次の高調波の周波数 | 1372 kHz は AM 放送帯の中。ラジオを 1372 kHz 付近に合わせても、弱く聞こえる |
| V1 を 1 kHz・0.5 V (スパン 10 kHz) | 685 kHz と 687 kHz に側波、約 −55 dBm。搬送波より約 −28 dB (側波の大きさは m/2 = 0.04。図9) |
| V1 の振幅を 2 倍にする | 側波が約 6 dB 上がる。搬送波の大きさは変わらない |

## 出典

自作。電波法の微弱無線局の技術基準は総務省電波法施行規則第 6 条による。
TLC555 の電源電圧の範囲 (2〜15 V) は Texas Instruments のデータシート、
ファンクションジェネレータの出力抵抗 50 Ω は 9-1 と同じ前提、Analog Discovery 3 の
Wavegen の出力インピーダンス (0 Ω) と出力電流 (30 mA) は Digilent の仕様書による。
