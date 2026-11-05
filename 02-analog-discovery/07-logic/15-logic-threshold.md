---
book: analog-discovery
chapter: 7
id: 7-15
title: ロジックのしきい値 (3.3 V / 5 V) と判定
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Wavegen・Scope・Logic)
board: BB
---

# 7-15 ロジックのしきい値 (3.3 V / 5 V) と判定

ディジタルの入力は、電圧が**しきい値**より上なら 1、下なら 0 と判定する。しきい値は IC の種類と電源電圧で違い、
3.3 V の IC の出力を 5 V の IC に入れたときなどに「たまたま動く」が起きる。この題では Wavegen の 0〜5 V のゆっくりした三角波を、
**5 V で動かした 74HC04** と **AD3 の DIO0 (Logic)** の両方に入れ、それぞれが何 V で判定を切り替えるかを Scope と Logic で読む。
読んだ値を、データシートの保証値 (V<sub>IH</sub>・V<sub>IL</sub>) と並べて、つないでよいかを判定する。

- V<sub>IH</sub>: これ以上なら必ず 1 と読む入力の電圧 (保証の下限)。V<sub>IL</sub>: これ以下なら必ず 0 と読む電圧 (保証の上限)
- 実物が切り替わる電圧 (しきい値) は V<sub>IL</sub> と V<sub>IH</sub> の間のどこか。保証の外の「間」に入れてはいけない

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 0-5 V の三角波を 74HC04 (5 V) と AD3 の DIO0 に入れる
parts:
  AD:
    type: device
    at: 2,4
    label: Analog Discovery 3
    pins: [V+, W1, 1+, 2+, DIO1, DIO0, GND, 1-, 2-]
    turn: mirror
  VCC: vcc 5.5,1.5 5V
  C1: capacitor 7,1.5 7,2.5 100n
  G2: ground 7,2.5
  U1A: not 9.5,3.25 74HC04
  R1: resistor 8,4.5 8,5.5 1k
  G1: ground 5.5,7
wires:
  - AD.V+ -| 5.5,1.5
  - 5.5,1.5 -- 7,1.5
  - AD.W1 -- 6,3.25
  - AD.1+ -- 6,3.5
  - 6,3.5 -- 6,3.25
  - 6,3.25 -- 8,3.25
  - 8,3.25 -- U1A.in
  - 8,3.25 -- 8,4.5
  - AD.DIO0 -- 6.5,4.25
  - 6.5,4.25 -- 6.5,6
  - 6.5,6 -- 8,6
  - 8,6 -- 8,5.5
  - U1A.out -- 11.5,3.25
  - 11.5,3.25 -- 11.5,3.75
  - AD.2+ -- 11.5,3.75
  - AD.DIO1 -- 11.5,4
  - 11.5,4 -- 11.5,3.75
  - AD.GND -| 5.5,7
  - AD.1- -| 5.5,7
  - AD.2- -| 5.5,7
notes:
  - text 7,8 small left: "U1 は 74HC04 (14 番を +5V・7 番を GND)"
  - text 7,8.5 small left: "使わない入力 3・5・9・11・13 番は GND"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/15-logic-threshold.svg)

- Wavegen の W1 を 74HC04 の 1 番 (1A) と Scope の 1+ に。同じ点から R1 (1 kΩ (オーム)) を通して DIO0 へ。
  R1 は、W1 を誤って ±5 V の範囲いっぱいに振ったときに DIO0 へ流れる電流を絞るため
- 74HC04 の出力 (2 番) を Scope の 2+ と DIO1 へ。5 V の H が DIO1 に入るが、AD3 の DIO は 5 V まで耐える (7-9)
- 74HC04 は Supplies の V+ で 5 V。C1 (0.1 µF (マイクロファラド)) は電源のデカップリング。使わない入力は GND に固定する (浮かせると中途の電圧になり、電流が流れる)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (U1 は 74HC04 を 5 V で)
board: half
parts:
  U1: dip14 @ e10 74HC04
  C1: capacitor c8 -t8 100n
  R1: resistor h10 h6 1k
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3
    pins: [GND, 1-, 2-, DIO0, 1+, W1, DIO1, 2+, V+]
wires:
  - AD.GND -- -b2 black
  - AD.1- -- -b3 black
  - AD.2- -- -b4 black
  - AD.DIO0 -- j6 yellow
  - AD.W1 -- j10 orange
  - AD.1+ -- i10 blue
  - AD.DIO1 -- j11 white
  - AD.2+ -- i11 green
  - AD.V+ -- +b22 red
  - a10 -- +t10 red
  - d8 -- d10 red
  - a11 -- -t11 black
  - a13 -- -t13 black
  - a15 -- -t15 black
  - j12 -- -b12 black
  - j14 -- -b14 black
  - j16 -- -b16 black
  - +t27 -- +b27 red
  - -t28 -- -b28 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/15-logic-threshold.svg)

- U1 (74HC04) は 10〜16 列、1 番が左下 (f10)。14 番 (10 列の上) を + レール、7 番 (16 列の下) を − レールへ。
  使わない入力 6A・5A・4A (11・13・15 列の上) と 2A・3A (12・14 列の下) は − レールへ。C1 は 8 列から − レール、d 行の赤い線で VCC の列へ
- 入口の 10 列の下に W1 (橙) と 1+ (青)、R1 (h10〜h6) を挿し、R1 の 6 列に DIO0 (黄)。出口の 11 列の下に DIO1 (白) と 2+ (緑)
- 上下のレールは 27・28 列でつなぐ。AD3 のピンの並びは線が交わらない順 (実物とは違う)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Wavegen W1 | Triangle、10 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V)。**先に Offset を入れてから Amplitude を上げる** (負の電圧を入れないため) |
| Scope CH1 (1+)・CH2 (2+) | 入口と出口。どちらも 1 V/div、0 V を中央の 2.5 目盛下に重ねる。10 ms/div、トリガは CH1 の立ち上がり 2.5 V |
| Logic | DIO0 と DIO1。Rate 100 kHz、10 ms/div。トリガは DIO1 の立ち下がり |
| (ほかに) | Scope の View で XY にすると、横が入口・縦が出口の**伝達特性**になる。しきい値は縦が 2.5 V を切る横の値 |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 三角波 (CH1) が約 2.5 V を切る所で 74HC04 の出力 (CH2) が反転する
time: 10ms/div
trigger: ch1 rising 2.5V
ch1: {wave: triangle 10Hz 2.5V offset 2.5V, range: 1V/div, position: -2.5div}
ch2: {wave: = 5V / (1 + exp((ch1 - 2.5V) / 50mV)), range: 1V/div, position: -2.5div}
cursors: [-10ms, 0]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/15-logic-threshold.svg)

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 同じ三角波を AD3 の DIO0 は約 1.5 V で H と判定する (DIO1 は 74HC04 の出力)
device: ad3
time: 10ms/div
start: -50ms
sample: 100kHz
signals:
  DIO0: dio0 edges -50ms=1 -40ms=0 -10ms=1
  DIO1: dio1 edges -50ms=1 0s=0
cursors: [-10ms, 0s]
trigger: DIO1 falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/15-logic-threshold.svg)

図3・図4 は計算で作った理想の画面で、実測ではない。74HC04 のしきい値を電源の半分 (2.5 V)、AD3 の DIO0 のしきい値を 1.5 V と置いた (どちらも目安。
AD3 の DIO の値は手元の資料に無いので、測って書き直す)。X2 (0 s) で三角波が 2.5 V を切り、74HC04 の出口が H→L になる (図3 の CH2・図4 の DIO1)。
その 10 ms 前の X1 (1.5 V) で、DIO0 はもう 1 と読んでいる (図4)。**同じ電圧でも、読む側によって 0 か 1 かが違う**。

三角波はデータシートの入力の変化の速さの上限 (4.5 V で 500 ns/V) よりずっと遅いので、74HC04 の出口は切り替わりの所で細かく発振することがある。
しきい値を読むための入れ方で、ふだんの回路ではしない (遅い入力にはシュミットトリガの 74HC14 を使う。7-17)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | インバータ (6 回路) | 74HC04 (DIP-14、5 V で使う) |
| R1 | 抵抗 (1/4 W)、DIO0 の保護 | 1 kΩ |
| C1 | セラミックコンデンサ | 0.1 µF (104) |
| — | 電源・信号源・計器 | Analog Discovery 3 (Supplies 5 V、Wavegen、Scope、Logic) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 74HC04 (5 V) が切り替わる入力 | 約 2.5 V (目安。電源の半分) | CMOS のしきい値は電源電圧に比例する |
| V+ を 3.3 V にしたとき | 約 1.65 V (目安) | 同じ IC でも電源でしきい値が動く |
| AD3 の DIO0 が 1 と読む入力 | 1.5 V 前後 (目安。測って書く) | Logic の判定は 3.3 V の CMOS の値 |
| 上がるときと下がるときの差 | 74HC04 はほぼ 0 | ヒステリシスが無い (74HC14 は 0.4 V 以上ある。7-17) |
| 入口 3.3 V のときの 74HC04 の電源の電流 | 数十 µA ほど (目安。下の LTspice) | 中途の電圧の入力で P と N が両方少し導通する |

この値を保証値と並べて、つないでよいかを判定する (V<sub>IH</sub> は TI の SN74HC04 で 4.5 V のとき 3.15 V、6 V のとき 4.2 V。5 V は 0.7 × 5 V = 3.5 V と置く)。

| 出す側 → 受ける側 | 出す H | 受ける V<sub>IH</sub> | 判定 |
| --- | --- | --- | --- |
| 74HC04 (5 V) → AD3 の DIO | 約 5 V | 2 V 前後 (3.3 V の CMOS の目安)、5 V まで耐える | よい |
| AD3 の DIO (3.3 V) → 74HC04 (5 V) | 3.3 V | 3.5 V | **だめ** (たまたま 2.5 V で読めるが保証の外。電流も増える) |
| AD3 の DIO (3.3 V) → 74HC04 (3.3 V) | 3.3 V | 2.31 V (0.7 × 3.3 V) | よい (7-11・7-12 はこの組) |
| AD3 の DIO (3.3 V) → 74HCT04 (5 V) | 3.3 V | 2.0 V (TTL と同じ入力) | よい (3.3 V から 5 V へ渡す定番) |
| 74HC04 (5 V) → 5 V に耐えない 3.3 V の入力 | 5 V | — | **だめ** (入力の上限を超える。抵抗の分圧かレベル変換が要る) |

## LTspice での確かめ

`sim/15-logic-threshold.cir` で、CMOS のインバータを NMOS と PMOS の 1 次の模型 (しきい値 ±0.8 V、大きさをそろえた仮定) で表し、入力を 0〜5 V で掃引した。
74HC04 の中身は公開されていないので、形を確かめるための模型で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| しきい値 (電源 5 V) | 約 2.5 V | 2.50 V | 合う |
| しきい値 (電源 3.3 V) | 約 1.65 V | 1.65 V | 合う |
| 入口 3.3 V のときの出口 (5 V) | L (0 V 近く) | 0.18 V | 合う (L とは読める) |
| 入口 3.3 V のときの電源の電流 (5 V) | 数十 µA | 42 µA | 合う (入口 0 V では 0 に近い) |

図3・図4 の数は算術で確かめた。10 Hz・0〜5 V の三角波は 1 V を 10 ms で上る (5 V ÷ 50 ms) ので、1.5 V と 2.5 V の点は 10 ms 離れる。図3 の X1・X2 の CH1 の読み (1.50 V・2.50 V) と合う。

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Wavegen、Scope の XY、Logic)。V<sub>IH</sub>・V<sub>IL</sub> と入力の変化の速さは
[Texas Instruments SN74HC04 データシート](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf)。

参考: [Logic level (Wikipedia 英語版)](https://en.wikipedia.org/wiki/Logic_level)
