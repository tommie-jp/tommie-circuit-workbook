---
book: circuits
chapter: 9
id: 9-8
title: ラジオ IC (LMF501T / TA7642)
tier: 100
source: 自作
board: BB
---

# 9-8 ラジオ IC (LMF501T / TA7642)

高周波増幅・検波・AGC (自動利得調整) を 1 個の 3 ピン IC にまとめた、
「1 チップ AM ラジオ」の定番が TA7642 (東芝、ZN414/MK484 と同じ系列) と
LMF501T (三ツ美電機)。**どちらも今は製造が終わっているが、ラジオ工作
キット向けに今でも通販や部品店 (秋月・マルツ・aitendo など) で手に入る**。
9-3 で石と部品で組んだ増幅と検波を、IC 1 個に置き換える。

> [!NOTE]
> 2 つはピンの並びが同じとは限らない。ここでは TA7642 のデータシートで確かめた
> 並びで描く (ZN414 系は同じ 3 ピンでもピンの並びが違う品種があるので注意)。
> LMF501T を使うときは、
> 必ず入手した個体のデータシートでピンを確認する (ピン配置は記憶で決め打たない)。

## 回路図

```circuit
title: 図1 TA7642系ラジオICの標準回路
parts:
  ANT: antenna d1
  L1: inductor d2 f2 250u
  GL: ground f2
  VC1: capacitor-var d4 f4 l=$\mathrm{VC}_1$
  GVC: ground f4
  IC1:
    type: ic3
    at: c9
    label: TA7642
    pins: [GND, IN, OUT]
  GIC1: ground c7
  Rload: resistor c12 a12 15k
  VCC: vcc a12 5V
  Cout: capacitor e13 e15 0.1u
  EAR: earphone e18 g18 l=$\mathrm{EAR}$
  Csup: capacitor a15 c15 10u
  GCsup: ground c15
  GEAR: ground g18
wires:
  - d1 -- d8
  - d8 -| IC1.2
  - IC1.1 -- c7
  - IC1.3 -- c12
  - c12 -- e12
  - e12 -- e13
  - a12 -- a15
  - e15 -- e16
  - e16 -- e18
notes:
  - text b8h0 small blue center: "PIN 1"
  - text c8h8 small blue right: "PIN 2"
  - text b10h0 small blue center: "PIN 3"
  - text d13 small blue left: "PIN 3 (OUT) は出力と電源の入口"
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/circuit/08-radio-ic.svg)

- **タンク**: L1 (250µH) と VC1 (ポリバリコン、20〜260pF) は 9-2 と同じ
  中波帯の同調回路。タンクの上端 (アンテナ側) を IC1 の**PIN 2 (RF 入力)**へ
  直接つなぐ — IC の入力インピーダンスが高く、結合コンデンサを挟まなくても
  タンクを大きく乱さない
- **PIN 1 = GND**、**PIN 3 = 出力であり電源の入り口でもある**。チップ内部の
  電圧リミッタが、PIN 3 の電圧 (VCC) を 1.2〜1.6V (typ 1.3V) に抑える。データシートの静止電流は 0.14〜0.30mA (typ 0.20mA) しかなく、
  絶対最大定格も VCC = 6V までなので、5V をそのまま PIN 3 に入れると
  チップの内部リミッタに定格を超えた電流が流れてしまう。そこで **Rload
  を直列の降圧抵抗として** VCC と PIN 3 の間に入れ、データシートの静止電流
  に収まる値まで電流を絞る。Rload = 15kΩ なら電流は
  (5V−1.3V)/15kΩ **≈ 0.25mA** (データシートの範囲 0.14〜0.30mA に収まる)
  で、PIN 3 の電圧はチップが自分で 1.3V 付近に調整する
- **検波した音声も同じ PIN 3 に出る**。Cout (0.1µF) で直流を切って EAR
  (クリスタルイヤホン) へ渡す。スピーカーを鳴らすには、この後に
  4-3 の反転増幅や LM386 (12-6 で扱う) のような低周波増幅を足すとよい
- **イヤホンのインピーダンス**: EAR は、いま売られているセラミック (圧電) 型の
  クリスタルイヤホンを想定する (容量 約 15nF、直流では 20MΩ 以上)。電気的には
  コンデンサなので、インピーダンスは周波数で変わり、**1kHz で約 10kΩ**
  (1/(2π×1kHz×15nF) ≈ 10.6kΩ)、100Hz で約 100kΩ。8Ω や 32Ω の
  ダイナミック型のイヤホンは、この IC の小さな出力では鳴らない
- 1kHz のイヤホン (約 10kΩ) は Rload (15kΩ) と同じくらいなので、PIN 3 の出力を
  はっきり引き下げる。PIN 3 の出力インピーダンスを Rload とみなすと、Cout とイヤホンの
  直列 (約 13nF) との高域のカットオフは 1/(2π×15kΩ×13nF) ≈ 800Hz (目安)。
  声は聞き取れるが、こもった音になる
- Csup (10µF) は電源のバイパス。無いと、検波した低い周波数の変動が
  電源経由でチップへ回り込み、「ボー」という発振 (モーターボーティング)
  を起こしやすい
- チップ内部の AGC (自動利得調整) が、強い局を受けたときに利得を自動で
  下げるので、9-3 のような外付けの検波バイアス調整が要らない

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, W1, 2+, 1+, 1-, 2-]
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [E, A]
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  EAR:
    type: device
    at: bottom
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b11 b7 250u
  IC1: ic3 d10 d11 d12 TA7642
  Cout: capacitor/ceramic a12 a15 0.1u
  Rload: resistor c12 c16 15k
  Csup: capacitor/electrolytic b16 b20 10u
  RS: resistor e11 e9 1k
wires:
  - VC1.E -- -t5 black
  - VC1.A -- a11 yellow
  - ANT.1 -- c11 yellow
  - a7 -- -t7 black
  - a10 -- -t10 black
  - +t16 -- a16 red
  - a20 -- -t20 black
  - e15 -- f18 green [h60]
  - EAR.A -- j18 green
  - EAR.B -- -b20 black
  - -t28 -- -b28 black
  - AD.V+ -- +t2 red
  - AD.GND -- -t2 black
  - AD.W1 -- a9 orange
  - AD.2+ -- b9 blue
  - AD.1+ -- b15 blue
  - AD.1- -- -t24 black
  - AD.2- -- -t26 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/breadboard/08-radio-ic.svg)

- 上の赤レール = +5V (AD の V+)、青レール = GND (AD の GND)。28 列で上下の − レールを渡している
- IC1 は 10・11・12 列 (PIN 1 = GND、PIN 2 = RF 入力、PIN 3 = 出力+電源)。上の注意のとおり、
  挿す前に入手した個体のデータシートでピンの並びを確かめる
- 11 列がタンクの上端 (VC1・アンテナ・L1) で、そのまま PIN 2 へ入る
- PIN 3 (12 列) から Rload で +5V (16 列) へ、Cout で 15 列へ。15 列から緑の線で 18 列へ回って溝を越え
  (溝に刷った IC の字をよけるため)、j18 から EAR の A 端子へ。Csup は + のピンを 16 列に挿す

- AD3 を足した。V+ (Supplies、5 V) が上の赤レール、GND が青レールにつながる。この回路の電流は 0.25 mA ほどで、
  AD3 の V+ の上限 (約 50 mA) に十分収まる。放送の電波が弱くて確かめにくいときは、W1 (Wavegen) の AM 信号を
  RS (1 kΩ) を通して同調回路 (11 列) へ入れる試験ができる (そのときは ANT の線を外す)。
  W1 の線は 9 列 (RS の左端) へ、2+ も同じ 9 列へ当てて、入れた信号を見る。1+ は Cout の出口の列 (15 列。直流を切ったあとの音声を見る)、1−・2− は上の青レールへ
- ブレッドボードの電流は 0.25 mA で、ブレッドボードの範囲 (1 穴 200 mA・ブレッドボード全体 500 mA) に十分収まる。周波数は 1 MHz 前後で 3 MHz 以下

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| IC1 | ラジオ IC | TA7642 |
| L1 | インダクタ (アキシャル) | 250 µH |
| VC1 | ポリバリコン | 20〜260 pF |
| Rload | 抵抗 | 15 kΩ |
| Cout | セラミックコンデンサ | 0.1 µF |
| Csup | 電解コンデンサ | 10 µF (16 V 以上) |
| EAR | クリスタルイヤホン | 容量 約 15 nF |
| RS | 抵抗 (試験用。W1 から同調回路へ入れる) | 1 kΩ |
| — | 電源・試験用の信号源・オシロ | Analog Discovery 3 (V+ と GND、W1、Scope の 1・2) |

## 計器の設定

計器は Analog Discovery 3 (AD3)。電源 (Supplies) と試験の信号 (W1) とオシロ (Scope) を 1 台でまかなう。
搬送波 1 MHz は Scope の範囲 (10 MHz 以下) に入る。波形で見たいのは PIN 3 に出る検波後の音声なので、オシロを選ぶ。
VC1 は約 100 pF に回しておく (f<sub>0</sub> = 1 / (2π√(250 µH × 100 pF)) ≈ 1.007 MHz)。

| 項目 | 値 |
| --- | --- |
| Supplies V+ | +5 V (Rload を通して PIN 3 へ) |
| Wavegen W1 | 搬送波 Sine 1 MHz、振幅 10 mV (peak)、Modulation: AM、変調波 Sine 1 kHz、変調度 50 % |
| Scope CH1 (1+ = Cout の出口) | Coupling DC (Cout が直流を切っている)、5 mV/div |
| Scope CH2 (2+ = W1 の出力側) | Coupling DC、10 mV/div |
| Scope 時間軸・トリガ | 200 µs/div、CH1 の立ち上がり |

```scope
title: 図3 AM 試験信号 (CH2) と Cout の出口の検波出力 (CH1) — 出力の大きさは仮定
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: = 0.01V * sin(2 * pi * 1kHz * t), range: 5mV/div, position: 2div}
ch2: {wave: = 0.01V * (1 + 0.5 * sin(2 * pi * 1kHz * t)) * sin(2 * pi * 1MHz * t), range: 10mV/div, position: -1.5div}
measure: [vpp, freq]
cursors: [250us, 750us]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/08-radio-ic.svg)

- 図3 は目安の画面で、実測ではない。CH2 は W1 に設定した AM 信号 (1 MHz は 200 µs/div では塗りつぶされた帯に見え、
  帯の太さが 1 kHz で太り細りする)。CH1 は PIN 3 から Cout を通った検波後の 1 kHz で、振幅 10 mV (20 mV<sub>pp</sub>) は**仮定した値**。
  TA7642 の出力の大きさは入力の強さと個体で変わるので、実物の値で読み替える
- 見る点は、CH2 の帯が太い所で CH1 が上がる (同じ 1 kHz で動く) ことと、W1 を止める (振幅 0) と CH1 の 1 kHz が消えること

### 同調回路だけを VNA で見る (補足)

L1 と VC1 の同調回路は 9-2 と同じで、VC1 を約 100 pF に回したときの f<sub>0</sub> は約 1.007 MHz。
放送の電波や W1 の信号がなくても、L1 と VC1 の並列だけを回路から外して LiteVNA64 の CH0 と CH1 の間に直列に挿せば、
S21 の谷として f<sub>0</sub> と谷の鋭さを測れる。つなぎ方、見えるはずの画面 (図)、読み方は
01-circuits/09-rf/02-crystal-radio.md (9-2) の「同調回路だけを VNA で見る」と同じ。VC1 を回すと谷が動く。

## 見るべき値

計算値。VCC = 5V (USB や電池)。

| 測る所 | 期待する値 |
| --- | --- |
| PIN 3 (出力+電源) の直流電圧 (テスターで GND 基準) | 約1.3V (データシートの VCC typ、チップ内部のリミッタで自己調整) |
| Rload に流れる電流 (Rload の両端の電圧をテスターで測り ÷ 15kΩ) | 約0.25mA (両端で約 3.7V。データシートの静止電流 0.14〜0.30mA の範囲内) |
| VC1 を回す | 受かる局が変わる (9-2・9-3 と同じ同調の効き方) |
| 弱い局と強い局を切り替える | 音量差が 9-3 (AGC 無し) より小さい (AGC の効果) |

## 出典

自作。TA7642 (ZN414/MK484 系) の標準アプリケーション回路による。
クリスタルイヤホンの容量とインピーダンスは、市販のセラミックイヤホンの仕様
([共立電子産業 CH905](https://eleshop.jp/shop/g/gE7P361/)、容量 15000pF・インピーダンス 20MΩ 以上・周波数範囲 200〜8000Hz) と
実測の例 ([セラミックイヤホンの特性](https://www.crystal-set.com/report/s100.htm)、100Hz で 80〜90kΩ) による。
