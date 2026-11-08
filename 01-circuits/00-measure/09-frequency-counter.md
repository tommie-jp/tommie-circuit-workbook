---
book: circuits
chapter: 0
id: 0-9
title: 周波数カウンタ (CMOS)
tier: 200
source: 自作
board: BB
---

# 0-9 周波数カウンタ (CMOS)

周波数は「1 秒の間に何回くり返すか」。だから、**ちょうど 1 秒だけ門 (ゲート) を開け、その間に来たパルスを数える**と、数がそのまま周波数 (Hz) になる。
これが周波数カウンタの原理で、テスターの周波数のレンジや、AD3 の Scope の Measurements の Freq も、やり方の違いはあれ同じ考えで測っている。

周波数カウンタに要るのは 3 つ。

1. **正確な 1 秒** — 時計と同じ 32.768 kHz の水晶 (2 の 15 乗 Hz) を発振させ、2 で割り続けて作る
2. **門** — 1 秒の間だけ、測るパルスを通す AND ゲート
3. **数える部分** — 10 進で数えるカウンタ (BCD)。門が開く瞬間に 0 に戻す

この題では 74HC の IC 4 個で、2 けた (0〜99 Hz) を数える周波数カウンタを組む。数は AD3 の Logic (ロジックアナライザ) で 2 けたの BCD (2 進化 10 進) として読む。
測るパルスは AD3 の Wavegen の W1 で作るので、表示が W1 の設定と合うかで確かめられる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CMOS の周波数カウンタ。水晶の 2 Hz から 1 s のゲートを作り、その間のパルスを数える
parts:
  U1: ic 8,12 74HC4060
  VCC: vcc 8,8.6 5V
  G1: ground 8,16.6
  RF: resistor 4,3 11,3 10M
  X1: crystal 4,5 6,5 32.768k
  RS: resistor 6,5 11,5 220k
  C1: capacitor 2,9 2,11 22p
  C2: capacitor 6,6 6,7.5 22p
  G2: ground 2,11
  G3: ground 6,7.5
  U2: ic 15,15 74HC393
  VCC: vcc 15,11.6 5V
  G4: ground 15,19.6
  U3A: and 20,13.8 74HC08
  IN: port 18,10 in
  U4: dip16 26,15 74HC390
  VCC: vcc 28,13 5V
  G5: ground 24.4,17.2
  C3: capacitor 18.5,15 18.5,17 1n
  R3: resistor 18.5,17 18.5,19 10k
  G6: ground 18.5,19
  D1: diode 20.5,19 20.5,17
  G7: ground 20.5,19
wires:
  - U1.VCC |- 8,8.6
  - U1.GND |- 8,16.6
  - U1.CLR |- 8,16.6
  - 4,3 -- 4,5
  - 4,5 -- 4,9
  - 4,9 -- 2,9
  - 4,9 |- U1.CLKI
  - 6,5 -- 6,6
  - 11,3 -- 11,5
  - 11,5 |- U1./CLKO
  - U1.QN -- U2.1CLK
  - U2.VCC |- 15,11.6
  - U2.GND |- 15,19.6
  - U2.1CLR |- 15,19.6
  - U2.2CLR |- 15,19.6
  - U2.2CLK -| 13,19.6
  - 13,19.6 -- 15,19.6
  - U2.1QB -| 18.5,15
  - U3A.b -| 18.5,15
  - 18,10 |- U3A.a
  - U3A.out -- U4.1CLKA
  - 18.5,17 -- 20.5,17
  - 20.5,17 -- 23,17
  - 23,17 |- U4.1CLR
  - 23,17 -- 23,18.6
  - 23,18.6 -- 28.4,18.6
  - 28.4,18.6 |- U4.2CLR
  - U4.1QA -| 24.2,15
  - 24.2,15 -- U4.1CLKB
  - U4.2QA -| 27.8,15.4
  - 27.8,15.4 -- U4.2CLKB
  - U4.1QD -| 23.8,18
  - 23.8,18 -- 29,18
  - 29,18 |- U4.2CLKA
  - U4.GND -| 24.4,17.2
  - U4.VCC -| 28,13
notes:
  - text 29.5,16 left: 1QA-1QD・2QA-2QD は AD3 の DIO へ
  - text 16.9,13.6: G
  - text 22.5,17.4: RST
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/circuit/09-frequency-counter.svg)

- **水晶の発振 (`U1` 74HC4060 の中のインバータ、`X1`・`RF`・`RS`・`C1`・`C2`)**: `RF` (10 MΩ) でインバータを増幅の状態にし、水晶 `X1` と `C1`・`C2` (22 pF) で 32.768 kHz だけを返して発振させる (ピアス形)。
  `RS` (220 kΩ) は水晶に加わる電力を絞る。部品の値は 32.768 kHz の水晶の発振によく使われる目安
- **分周**: 74HC4060 の 14 段の 2 分周で、QN (14 段目) が 32768 / 2<sup>14</sup> = **2 Hz**。`U2` (74HC393) の 1QA で 1 Hz、1QB で **0.5 Hz** になる。
  0.5 Hz の方形波は **1 s が H、1 s が L** で、これをゲート G にする
- **門** (`U3A`、74HC08 の 1 回路): G が H の 1 s の間だけ、IN (測るパルス) を `U4` へ通す。L の 1 s の間は止まり、数が保たれて読める
- **数える部分** (`U4`、74HC390): 2 つの 10 進カウンタを縦につないだ 2 けた。1CLKA が立ち下がりで数え、1QA を 1CLKB へつなぐと 1 けた目が 0〜9 の BCD (1QA〜1QD) になる。
  9 → 0 のときに 1QD が立ち下がるので、それを 2 けた目 (2CLKA) へ送る
- **0 に戻す** (`C3`・`R3`・`D1`): G が立ち上がる瞬間に、`C3` (1 nF) と `R3` (10 kΩ) の微分で 3 µs ほどの山 (RST) を作り、74HC390 の CLR (H で 0 に戻す) に入れる。
  G の立ち下がりで RST は負に振れるので、`D1` (ショットキー 1N5819) で −0.3 V に押さえる
- **電源**: どの IC も 5 V (AD3 の V+)。74HC08 (`U3A`) の 14 番 (VCC) と 7 番 (GND)、使わない 3 回路の入力 (GND へ) は図に描いていない。74HC4060 の CLR、74HC393 の 1CLR・2CLR・2CLK は GND へ

**読み方**: G が H の 1 s の間に数え終わった数が、IN の周波数 (Hz)。W1 を 37 Hz にすれば、L の 1 s の間 37 が読める。
2 けたなので 99 Hz まで (100 Hz では 00 に戻る)。けたを増やすなら 74HC390 をもう 1 個つなぐ。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 full のブレッドボードに 74HC4060・74HC393・74HC08・74HC390 を左から
board: full
parts-list: symbols
parts:
  U1: dip16 @ e5 74HC4060
  U2: dip14 @ e18 74HC393
  U3: dip14 @ e30 74HC08
  U4: dip16 @ e46 74HC390
  C1: capacitor/ceramic a10 -t10 22p
  RF: resistor b10 b13 10M
  RS: resistor c13 c15 220k
  X1: crystal/cylinder d15 d10 32.768k cap=below:2,0
  C2: capacitor/ceramic a15 -t15 22p
  C3: capacitor/ceramic i38 i41 1n
  R3: resistor j41 -b41 10k
  D1: schottky -b43 j43 1N5819
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (電源・DIO4-7)
    pins: [V+, GND, DIO4, DIO5, DIO6, DIO7]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (DIO8・W1・Scope・DIO0-3)
    pins: [DIO8, W1, 1+, 1-, 2+, 2-, DIO0, DIO1, DIO2, DIO3]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t4 -- -b4 black
  - a5 -- +t5 red
  - j12 -- -b12 black
  - a9 -- -t9 black
  - a11 -- a13 orange
  - h7 -- h18 green
  - a18 -- +t18 red
  - j24 -- -b24 black
  - j19 -- -b19 black
  - a19 -- -t19 black
  - a20 -- -t20 black
  - i21 -- i31 white
  - AD1.DIO8 -- j21 white
  - a30 -- +t30 red
  - j36 -- -b36 black
  - j33 -- -b33 black
  - j34 -- -b34 black
  - a31 -- -t31 black
  - a32 -- -t32 black
  - a34 -- -t34 black
  - a35 -- -t35 black
  - AD1.W1 -- j27 yellow
  - g27 -- g28 yellow
  - h28 -- h30 yellow
  - AD1.1+ -- j28 yellow
  - AD1.1- -- -b30 black
  - h32 -- h46 orange
  - g31 -- g38 white
  - AD1.2+ -- j38 white
  - AD1.2- -- -b39 black
  - g41 -- g43 purple
  - i43 -- i47 purple
  - e43 -- f43 purple
  - c43 -- c48 purple
  - a46 -- +t46 red
  - j53 -- -b53 black
  - g48 -- g49 blue
  - AD1.DIO0 -- j48 blue
  - AD1.DIO1 -- j50 blue
  - AD1.DIO2 -- j51 blue
  - g52 -- g55 green
  - e55 -- f55 green
  - b47 -- b55 green
  - AD1.DIO3 -- j52 blue
  - c49 -- c50 blue
  - AD.DIO4 -- a49 blue
  - AD.DIO5 -- a51 blue
  - AD.DIO6 -- a52 blue
  - AD.DIO7 -- a53 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/breadboard/09-frequency-counter.svg)

左から `U1` 74HC4060 (列 5〜12)・`U2` 74HC393 (列 18〜24)・`U3` 74HC08 (列 30〜36)・`U4` 74HC390 (列 46〜53)。どれも切り欠きを左に、1 番が左下。

- **電源**: V+ (5 V) を上の + レールへ、GND を上の − レールへ。上下の − レールは列 4 でつなぐ (下の + レールは使わない)。各 IC の VCC を + レールへ、GND を − レールへ。
  full のブレッドボードでレールが真ん中 (列 31〜32 のあたり) で切れている品は、そこを線でつないでおく
- **水晶 (列 10〜15 の上)**: 列 10 が CLKI (11 番)、列 11 と列 13 が /CLKO (10 番。橙の線でつなぐ)、列 15 が水晶と `RS` の間 (図1 の C2 の点)。`C1`・`C2` は − レールへ縦に挿す
- **分周**: QN (3 番、列 7 の下) を緑の線で 74HC393 の 1CLK (列 18 の下) へ。1QB (列 21 の下) が G で、白の線で 74HC08 の 1B (列 31 の下) へ、さらに列 38 へ延ばす
- **門**: W1 (黄) を列 27 から列 28・列 30 へ渡し、74HC08 の 1A (列 30 の下) へ。1Y (列 32 の下) を橙の線で 74HC390 の 1CLKA (列 46 の下) へ
- **リセット (列 38〜43 の下)**: `C3` で G (列 38) から列 41 (RST)、`R3` と `D1` を列 41・列 43 から下の − レールへ。RST を紫の線で 1CLR (列 47 の下) と、上のブロックへ渡して 2CLR (列 48 の上) へ
- **数える部分**: 1QA (列 48 の下) と 1CLKB (列 49 の下)、2QA (列 49 の上) と 2CLKB (列 50 の上) を短い線で。1QD (列 52 の下) は緑の線で列 55 を回って 2CLKA (列 47 の上) へ
- **読む線**: DIO0〜3 (下の AD3) が 1QA・1QB・1QC・1QD、DIO4〜7 (上の AD3) が 2QA・2QB・2QC・2QD、DIO8 が G。CH1 は IN (W1)、CH2 は G

電流は 4 個の IC を合わせても数 mA で、AD3 の V+ の範囲に収まる。回路が働く周波数は 32.768 kHz と IN (100 Hz まで) で、ブレッドボードの範囲の内側。

**動かないとき**は、上流から 1 か所ずつ確かめる: CH2 を QN (列 7) に当てて 2 Hz が出るか (出なければ水晶の部分)、次に G (列 21) で 0.5 Hz か、
最後に 1CLKA (列 46) に G が H の間だけ IN が来ているか。

## 計器の設定

計器は AD3 の Supplies (V+ = 5 V)・Wavegen (測るパルス)・Scope (ゲートの長さ)・Logic (数の読み)。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5.0 V |
| Wavegen W1 | 方形波、振幅 2.5 V・オフセット 2.5 V (0〜5 V)、周波数 6 Hz (図4)。読めたら 37 Hz・99 Hz・100 Hz と変える |
| Scope | CH1 が IN、CH2 が G。DC、2 V/div。時間 200 ms/div、トリガ CH2 の立ち上がり |
| Logic | DIO0〜3 をバス「1 けた目」(10 進)、DIO4〜7 を「2 けた目」、DIO8 を G。標本化 5 kHz、時間 400 ms/div |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ゲート G (CH2) が H の 1 s の間だけ IN (CH1、6 Hz) を数える
time: 200ms/div
trigger: ch2 rising 2.5V at -2div
ch1: {wave: square 6Hz 2.5V offset 2.5V, range: 2V/div, position: -3div}
ch2: {wave: square 0.5Hz 2.5V offset 2.5V, range: 2V/div, position: 1div}
cursors: [0, 1s]
measure: [freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/scope/09-frequency-counter.svg)

図3 の X1 から X2 までの 1 s (ΔX) がゲートの時間。その間に CH1 の立ち下がりが 6 回あり、6 が数えられる。ゲートの長さは水晶で決まるので、
32.768 kHz の誤差 (普通の水晶で ±20 ppm ほど、目安) がそのまま読みの誤差になる。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 IN が 6 Hz のとき、G が H の間に 1 けた目が 0 から 6 まで進み、L の間は 6 のまま
device: ad3
time: 400ms/div
sample: 5kHz
signals:
  G: dio8 edges 0s=0 600ms=1 1600ms=0 2600ms=1 3600ms=0
  QA: dio0 edges 0s=0 750ms=1 916.7ms=0 1083.3ms=1 1250ms=0 1416.7ms=1 1583.3ms=0 2750ms=1 2916.7ms=0 3083.3ms=1 3250ms=0 3416.7ms=1 3583.3ms=0
  QB: dio1 edges 0s=1 600ms=0 916.7ms=1 1250ms=0 1583.3ms=1 2600ms=0 2916.7ms=1 3250ms=0 3583.3ms=1
  QC: dio2 edges 0s=1 600ms=0 1250ms=1 2600ms=0 3250ms=1
  QD: dio3 low
buses:
  Count: QD QC QB QA dec
cursors: [1200ms, 2200ms]
trigger: G rising at 600ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/00-measure/logic/09-frequency-counter.svg)

図4 は IN を 6 Hz にしたとき (QA〜QD は 74HC390 の 1QA〜1QD)。G が立ち上がる 0.6 s で数が 0 に戻り、IN の立ち下がりごとに 1・2・… と進んで、1.58 s に 6 になる。
G が L の 1.6〜2.6 s は 6 のまま (X2)。2 けた目 (DIO4〜7) は 0 のままなので図から省いた。数えている間 (X1 では 3) は読まない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 14 段 2 進カウンタ・発振回路 | 74HC4060 |
| U2 | 4 ビット 2 進カウンタ 2 回路 | 74HC393 |
| U3 | AND ゲート 4 回路 | 74HC08 |
| U4 | 10 進カウンタ 2 回路 | 74HC390 |
| X1 | 水晶振動子 (円筒形) | 32.768 kHz (時計用) |
| RF | 抵抗 (1/4 W) | 10 MΩ |
| RS | 抵抗 (1/4 W) | 220 kΩ |
| C1, C2 | セラミックコンデンサ (C0G) | 22 pF (220) |
| C3 | セラミックコンデンサ | 1 nF (102) |
| R3 | 抵抗 (1/4 W) | 10 kΩ |
| D1 | ショットキーダイオード | 1N5819 |
| — | 電源・信号・表示 | AD3 の V+ (5 V)・W1・Scope・Logic (DIO0〜8) |

## 見るべき値

| W1 の周波数 | 期待する読み (G が L の間、2 けた目・1 けた目) | 分かること |
| --- | --- | --- |
| 6 Hz | 0・6 | 図4。1 s の数がそのまま Hz |
| 37 Hz | 3・7 (36 か 38 のこともある) | 門の開け閉めの瞬間とパルスの位相で ±1 ずれる (±1 カウントの誤差) |
| 99 Hz | 9・9 | 2 けたの上限 |
| 100 Hz | 0・0 (かそれに近い数) | けたあふれ。けたを足すか、ゲートを短くして単位を替える |
| CH2 の G の周波数・デューティ | 0.500 Hz・50 % | ゲートの長さ 1.000 s を水晶が決める |
| QN (列 7) の周波数 | 2.000 Hz | 32768 / 16384 |

**±1 カウント**: 門が開く・閉じる瞬間と IN の立ち下がりの位置は毎回ずれるので、1 s に 37.4 回でも 37 と 38 が出る。
数えるカウンタはこの「1 つぶん」より細かくは読めない。0.1 Hz まで読むなら門を 10 s にする (74HC393 の 1QD で 1/16 Hz … 2 のべき乗なので 10 s にはならない。
水晶を 2 のべき乗以外の周波数にするか、10 進のカウンタで分周するのが本式)。

## LTspice での確かめ

数える部分は論理回路なので、真理値と数の算術で確かめた。

| 項目 | 本文の数字 | 確かめ | 判定 |
| --- | --- | --- | --- |
| QN の周波数 | 2 Hz | 32768 Hz / 2<sup>14</sup> = 2.000 Hz | 合う |
| G | 0.5 Hz、H が 1 s | 74HC393 の 1QA で ÷2 (1 Hz)、1QB で ÷4 (0.5 Hz、デューティ 50 %) | 合う |
| 6 Hz の読み | 6 | 1 s の間の立ち下がり (図4 の時刻の計算): 0.75・0.92・1.08・1.25・1.42・1.58 s の 6 回 | 合う |
| BCD のつなぎ | 0〜9 → 0 で上のけたへ | 74HC390 は 1QA を 1CLKB へつなぐと BCD、9 → 0 で 1QD が立ち下がる (データシートの説明) | 合う |

リセットの山だけは `sim/09-frequency-counter-reset.cir` で、G の立ち上がりを `C3`・`R3` で微分し、`D1` (1N5819、LTspice の標準ライブラリの値) で押さえる .tran を回した
(G は 50 Ω の出力の 0〜5 V の方形波と仮定)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| RST が 3.5 V (74HC の H の下限) を超えている時間 | 3 µs ほど | 2.9 µs | 合う。74HC390 の CLR に要る幅 (4.5 V で 15 ns 以下、データシート) の 100 倍以上 |
| G の立ち下がりでの RST の下の振れ | −0.3 V | −0.29 V | 合う (入力の保護ダイオードが働く −0.5 V より浅い) |
| RST の山の高さ | 5 V 前後 | 5.4 V (2 回目の立ち上がり) | 近い (VCC を少し超える分は、入力の保護ダイオードが数 µs だけ受ける程度) |

## 出典

自作。

参考: [周波数カウンタ (Wikipedia)](https://ja.wikipedia.org/wiki/周波数カウンタ)、[SN74HC4060 データシート (TI)](https://www.ti.com/lit/ds/symlink/sn74hc4060.pdf)、[CD74HC390 データシート (TI)](https://www.ti.com/lit/ds/symlink/cd74hc390.pdf)
