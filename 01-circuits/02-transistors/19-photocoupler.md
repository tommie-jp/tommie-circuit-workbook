---
book: circuits
chapter: 2
id: 2-19
title: フォトカプラで絶縁
tier: 200
source: 自作
era: 今
---

# 2-19 フォトカプラで絶縁

**フォトカプラ** (光結合素子) は、LED と光トランジスタを 1 つの包みに入れ、間を光だけでつないだ部品。
入力 (1 次側) と出力 (2 次側) の間には電線が無く、GND も共通にしなくてよい。PC817 は 1 次と 2 次の間に 5 kV (実効値) まで耐える (シャープの資料)。

使い道は、GND の違う 2 つの回路の間で信号だけを渡すこと。マイコンからリレーやモータの電源の側へ、USB の機器から別の電源の機器へ、
雑音の多い回路から計測の回路へ、などで、片方で事故や雑音が起きても、もう片方へ電流が回り込まない。

この題では、1 次側を AD3 の W1 で、2 次側を単 3 電池 3 本 (4.5 V) で動かし、**2 つの側の GND をつながずに**信号が渡ることを確かめる。
あわせて、光トランジスタは切れるのが遅い (数十 µs) ことを、出力の立ち上がりで見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フォトカプラ PC817 で絶縁 (2 次側は電池 4.5 V で別に)
parts:
  W1: square 1,4 1,7 l=$\mathrm{W1}$
  G1: ground 1,7
  M1: voltmeter 3,4 3,7 l=$\mathrm{CH1}$
  RIN: resistor 3,4 5,4 680
  U1: photocoupler 7,5 PC817
  RL: resistor 10,2 10,4 4.7k
  BT1: battery 13,2 13,8 4.5V
  M2: voltmeter 11,4 11,8 l=$\mathrm{CH2}$
wires:
  - 1,4 -- 3,4
  - 1,7 -- 3,7
  - 5,4 -| U1.A
  - U1.K |- 5,7
  - 5,7 -- 3,7
  - 10,2 -- 13,2
  - 10,4 |- U1.C
  - 10,4 -- 11,4
  - U1.E -| 10,8
  - 10,8 -- 11,8
  - 11,8 -- 13,8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/19-photocoupler.svg)

図1 の左が 1 次側 (W1 と AD3 の GND)、右が 2 次側 (電池 `BT1` と `RL`)。2 つの側は `U1` の中の光でしかつながっていない。
CH1 は W1 (GND 基準)、CH2 は 2 次側の出力 (`U1` の C-E 間、差動) を見る。

- **LED の電流**: W1 が 5 V のとき、I<sub>F</sub> = (5 − 1.17) / 680 Ω ≈ **5.6 mA** (V<sub>F</sub> は 5 mA で約 1.17 V、目安)。W1 の目安 (10 mA) の内
- **電流伝達率 (CTR)**: 光トランジスタのコレクタ電流 ÷ LED の電流。PC817 は I<sub>F</sub> = 5 mA で **50〜400 %** (ランクで違う)。
  最小の 50 % でも 2.8 mA を流せる
- **出力が Low になる条件**: `RL` (4.7 kΩ) で 4.5 V を 0.12 V まで下げるのに要る電流は (4.5 − 0.12) / 4.7 kΩ ≈ 0.93 mA。
  CTR が最小でも 3 倍の余裕があるので、光トランジスタは飽和し、出力は約 **0.12 V** (資料の V<sub>CE(sat)</sub> は 0.1 V 代表)
- **向き**: W1 が High (LED が点く) で出力は Low。論理が反転する。反転させたくなければ `RL` をエミッタ側 (E と電池の − の間) に置き、エミッタから出力を取る
- **速さ**: 光トランジスタはベースを光の小さな電流 (µA) だけで充電・放電するので遅い。資料の応答時間は R<sub>L</sub> = 100 Ω で 4 µs (立ち上がり)・3 µs (立ち下がり)。
  `RL` が大きく、飽和させて使うこの回路では、切れて出力が上がるのに **約 80 µs** かかる (LTspice の模型での値)。1 kHz なら十分で、数十 kHz を越えると波形がつぶれる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 フォトカプラで絶縁 (下が 1 次側 = AD3 の GND、上が 2 次側 = 電池)
# 上のレールは電池の 4.5 V だけ (2 次側)。下の − レールは AD3 の GND (1 次側)。上下のレールはつながない
board: half
parts:
  U1: photocoupler @ e10 PC817
  RIN: resistor h5 h10 680
  RL: resistor a10 +t10 4.7k
  BT1: battery +t4 -t4 4.5V
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (CH2)
    pins: [2+, 2-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (GND・W1・CH1)
    pins: [1-, GND, 1+, W1]
wires:
  - a11 -- -t11 black
  - AD.2+ -- b10 green
  - AD.2- -- -t15 green
  - j11 -- -b11 black
  - AD1.GND -- -b2 black
  - AD1.1- -- -b1 black
  - AD1.W1 -- j5 yellow
  - AD1.1+ -- j3 blue
  - g3 -- g5 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/19-photocoupler.svg)

図2 は `U1` を溝にまたがせ、**1 次側を下のブロック、2 次側を上のブロック**に分けた。上下のレールは**つながない** (これが絶縁)。

- **U1 (PC817)**: 丸い印 (1 番) を左下にして `e10` から挿す。1 番 A (`f10`)・2 番 K (`f11`) が下、3 番 E (`e11`)・4 番 C (`e10`) が上
- **1 次側 (下)**: W1 (黄) は `j5`、CH1 の 1+ (青) は `j3` から `g3`–`g5` で同じ列へ。`RIN` (`h5`–`h10`) が A へ。K (列 11) は黒い線で下の − レール (AD3 の GND) へ
- **2 次側 (上)**: 電池 `BT1` (単 3 × 3 本の電池ケース) の + を上の + レール、− を上の − レールへ。`RL` は + レールから C (列 10)、E (列 11) は上の − レールへ。
  CH2 の 2+ (緑) は `b10`、2− (緑) は上の − レール (電池の −)。CH2 は差動なので、電池の側の電位が AD3 の GND と違っても測れる
- **絶縁を確かめる**: AD3 をつなぐ前に、テスターの抵抗レンジで下の − レールと上の − レールの間を測る。OL (∞) になる (資料の絶縁抵抗は 5 × 10<sup>10</sup> Ω 以上)

## 計器の設定

計器は AD3 のオシロ (1 次の入力と 2 次の出力を同じ時間軸で比べるため)。W1 を Square、1 kHz、Amplitude 2.5 V、Offset 2.5 V (0/5 V) にする。
CH1・CH2 とも 1 V/div・Offset −3 V、時間軸 20 µs/div、CH1 の立ち下がり 2.5 V でトリガして画面の左に寄せる。Measure で CH2 の Rise Time を出す。Supplies は使わない。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力 (CH1) が切れると 2 次側の出力 (CH2) は約 80 µs かけて上がる
time: 20us/div
trigger: ch1 falling 2.5V at -4div
ch1: {wave: square 1kHz 2.5V offset 2.5V phase 180deg, range: 1V/div, position: -3div}
ch2: {wave: "= 0.12V + 4.37V * step(t) * (1 - exp(-t / 36us))", range: 1V/div, position: -3div}
measure: [vmax, vmin, rise]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/19-photocoupler.svg)

図3 は W1 が 5 V から 0 V に落ちた瞬間。CH2 は 0.12 V から 4.5 V へ、指数のような形で約 80 µs (10〜90 %) かけて上がる。
逆の向き (W1 が上がって出力が下がる) は約 6 µs で速い。時間軸を 200 µs/div にすると、CH2 は CH1 を反転した方形波に見える。
図の CH2 は LTspice の模型の立ち上がり (下の節) を指数で描いた形。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | フォトカプラ (DIP-4) | PC817 (CTR 50〜400 %、絶縁 5 kV 実効値) |
| RIN | 抵抗 (1/4 W) | 680 Ω (LED に 5.6 mA) |
| RL | 抵抗 (1/4 W) | 4.7 kΩ |
| BT1 | 電池ケース + 単 3 電池 3 本 | 4.5 V — 2 次側を AD3 と別の電源にして、GND をつながないため |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 1 次と 2 次の間の抵抗 (テスター) | OL (∞) | 2 つの側は電気的につながっていない |
| LED の電流 (W1 5 V、`RIN` の電圧 / 680 Ω) | 約 5.6 mA | I<sub>F</sub> |
| 出力の Low / High (CH2) | 約 0.12 V / 4.5 V | 光トランジスタが飽和する。論理は反転 |
| 出力の立ち上がり (10〜90 %) | 約 80 µs | 光トランジスタは切れるのが遅い |
| 出力の立ち下がり | 約 6 µs | 入るのは速い |

## LTspice での確かめ

`sim/19-photocoupler.cir` で 1 kHz の方形波を入れて過渡解析し、LED の電流・出力の Low と High・立ち上がりと立ち下がりの時間を、`RL` を 100 Ω と 4.7 kΩ に振って読んだ。
LTspice に PC817 の部品は無いので、LED・電流で動く電流源 (受光の電流 = 0.2 % × I<sub>F</sub>)・光トランジスタ (hFE 500、CTR 約 100 %) で模型を作った (仮定)。
光トランジスタの容量は、`RL` 100 Ω の応答が資料 (立ち上がり 4 µs・立ち下がり 3 µs) と同じ桁になるよう置いた。どれも実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| LED の電流 | 約 5.6 mA | 5.6 mA | 合う |
| 出力の Low / High (`RL` 4.7 kΩ) | 約 0.12 V / 4.5 V | 0.120 V / 4.49 V | 合う |
| 出力の立ち上がり 10〜90 % (`RL` 4.7 kΩ) | 約 80 µs | 80 µs | 本文の値は LTspice の読み |
| 出力の立ち下がり 90〜10 % (`RL` 4.7 kΩ) | 約 6 µs | 5.5 µs | 本文の値は LTspice の読み |
| 入力から出力の 50 % まで (切る / 入る) | — | 29 µs / 3.5 µs | 切るほうが 8 倍遅い |
| `RL` 100 Ω の立ち下がり / 立ち上がり | 資料 3 µs / 4 µs | 2.7 µs / 0.5 µs | 立ち下がりは合う。立ち上がりは模型が速い (目安) |

`RL` 100 Ω では光トランジスタが飽和せず、出力は 4.5 V から 3.9 V までしか振れない (0.6 V)。速さと振れの大きさは `RL` で引き換えになる。
実物の応答は CTR のランクと温度で大きく動くので、80 µs は目安で、測って書き直す値である。

## 出典

自作。PC817 の値とピンの並びは [シャープ PC817XxNSZ1B のデータシート](https://global.sharp/products/device/lineup/data/pdf/datasheet/PC817XxNSZ1B_e.pdf) (CTR・V<sub>F</sub>・V<sub>CE(sat)</sub>・応答時間・絶縁)。

参考: [フォトカプラ (Wikipedia)](https://ja.wikipedia.org/wiki/フォトカプラ)
