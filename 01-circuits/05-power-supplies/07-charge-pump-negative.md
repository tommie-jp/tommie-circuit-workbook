---
book: circuits
chapter: 5
id: 5-7
title: チャージポンプ — 555 で負電圧
tier: 100
board: BB
source: 自作
---

# 5-7 チャージポンプ — 555 で負電圧

+9 V の電源 1 つから、GND より低い**負電圧** (約 −7 V) を作る。
コイルを使わず、コンデンサとダイオードだけで電圧を作り替える回路を**チャージポンプ**という。
555 の方形波でコンデンサの電荷を汲み移し、電源には無いマイナス側の電圧を作る。
OP アンプの負電源 (4 章の ± 電源) や、基準電圧を少しだけマイナス側にずらしたいときに使う、軽い負荷向けの回路だ。

## 回路図

```circuit
title: 図1 555 チャージポンプ (負電圧)
parts:
  V1: vsource b3 gnd 9
  vcc: vcc b3 9V
  G1: ground gnd
  U1: ic g10 NE555
  vcc: vcc c6 9V
  Ra: resistor c6 e6 1k
  Rb: resistor f6f0 h6f0 4k7
  C1: capacitor h8f0 j8f0 10n
  GC1: ground j8f0
  vcc: vcc c10 9V
  GU1: ground j10f0
  Cc: capacitor i11 j11f0 10n
  GCc: ground j11f0
  Cp: capacitor g12 g14 1u
  D1: diode g14 j14f0 1N4148
  GD1: ground j14f0
  D2: diode g16 g14 1N4148
  Co: ecap j16f0 g16 10u
  GCo: ground j16f0
  RL: resistor g18 j18f0 1k
  GRL: ground j18f0
points:
  gnd: e3
wires:
  - U1.VCC |- c10
  - c10 -- c10a5
  - U1.RESET |- c10a5
  - e6 -- f6f0
  - U1.DISCH -| f6f0
  - U1.THRES -| g8
  - U1.TRIG -| g8f0
  - g8 -- h8f0
  - h6f0 -- h8f0
  - U1.GND |- j10f0
  - U1.CONT |- i10a5
  - i10a5 -- i11
  - U1.OUT -| g12
  - g16 -- g18
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/07-charge-pump-negative.svg)

- 555 は 3-2 と同じ非安定接続。PIN 3 (OUT) の方形波 (0〜9 V) が、
  ポンプ用のコンデンサ Cp (1 µF) を押したり引いたりする
- OUT が High の間は、D1 が Cp の右側 (D1・D2 の中点) を +0.6 V あたりに留め、
  Cp を約 (9 − 0.6) V に充電する。OUT が Low に落ちると、Cp の電圧はそのままなので中点は約 −8.4 V まで
  引き下げられる。このとき D2 が導通し、Co (出力の電荷をためるコンデンサ) から電荷を吸い出す。
  これを繰り返すたびに、Co の電圧がだんだん負に深くなる
- 無負荷の出力電圧は、理論上 −(V<sub>CC</sub> − 2 × ダイオードの順方向電圧) ≈ −(9 − 2 × 0.6) = −7.8 V。
  ダイオード 2 個ぶん (約 1.2 V) だけ、V<sub>CC</sub> より浅くなるのは避けられない
- RL (負荷) をつなぐと、Cp が 1 周期に運べる電荷には限りがあるので、出力はさらに浅くなる。
  大きな電流は取り出せない、軽い負荷向けの方式だ

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
# 上の赤レール = +9V、青レール = GND。下の青レール = GND (左端の線で渡す)、下の赤レール = +9V (RESET 用)
board: half
parts:
  BAT:
    type: device
    at: top
    label: 9 V 電源 (006P 電池かアダプタ)
    pins: [+9V, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope + BNC アダプタ (CH2 は AC 結合)
    pins: [1+, 2+, 1-, 2-]
  U1: dip8 @ e10 NE555
  Ra: resistor a11 +t11 1k
  Rb: resistor b11 b17 4.7k
  C1: capacitor d17 d20 10n
  Cc: capacitor a13 -t13 10n
  Cp: capacitor h18 h22 1u
  D1: diode i22(A) -b22(K) 1N4148
  D2: diode g26(A) g22(K) 1N4148
  Co: capacitor/electrolytic -b26(+) i26(-) 10u
  RL: resistor i30 -b30 1k
wires:
  - BAT.+9V -- +t1 red
  - BAT.GND -- -t2 black
  - +t1 -- +b1 red
  - -t2 -- -b2 black
  - +t10 -- a10 red
  - j10 -- -b10 black
  - j13 -- +b13 red
  - c12 -- c17 orange
  - g11 -- d12 orange
  - g12 -- g18 yellow
  - h26 -- h30 blue
  - a20 -- -t20 black
  - SC.1+ -- h12 orange
  - SC.2+ -- j26 green
  - SC.1- -- -b15 black
  - SC.2- -- -b16 black
notes:
  - text below: 上の赤レール = +9V、青レール = GND。下の赤レール = +9V (PIN 4 用)、青レール = GND
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/07-charge-pump-negative.svg)

- 電源は 9 V の電池 (006P) かアダプタ。**AD3 の Supplies は ±5 V までで 9 V は出せない**ので、9 V は別の電源にし、AD3 は Scope だけに使う。9 V はブレッドボードの範囲 (定常 12 V 以下) に収まる。ブレッドボードを通る電流は 555 の約 10 mA と負荷の約 7 mA で、200 mA の範囲に収まる
- 555 (U1) の PIN 8 (10 列) は `+t10 → a10` で +9V へ、PIN 1 (10 列) は `j10 → -b10` で GND へ、PIN 4 (RESET、13 列) は `j13 → +b13` で下の赤レール (+9V、左端の線で上の赤レールから渡す) へ
- 非安定の接続: Ra (1 kΩ) は +9V から PIN 7 (11 列) へ立てて挿す。Rb (4.7 kΩ) は PIN 7 の 11 列から 17 列へ渡し、橙の線 `c12 → c17` で PIN 6 (12 列) とつなぐ。PIN 2 (11 列) と PIN 6 (12 列) は橙の線 `g11 → d12` でつなぐ。C1 (10 nF) は 17 列〜20 列で、黒の線 `a20 → -t20` で GND へ。Cc (10 nF) は PIN 5 (13 列) から GND へ立てて挿す
- ポンプ部: PIN 3 (OUT、12 列) を黄の線 `g12 → g18` で 18 列へ広げ、Cp (1 µF、18 列〜22 列) を挿す。22 列が図1 の D1・D2 の中点。D1 は 22 列 (アノード) から下の青レール (GND、カソード)、D2 は出力の 26 列 (アノード) から 22 列 (カソード) へ。**D1・D2 は帯 (カソード) の向きに注意**
- Co (10 µF) は + を GND (下の青レール) に、− を出力の 26 列 (`i26`) に挿す (電解コンデンサの向き)。RL (1 kΩ) は 30 列から GND へ立てて挿し、青の線 `h26 → h30` で出力につなぐ
- Scope の 1+ (橙) は PIN 3 (`h12`)、2+ (緑) は出力 (`j26`)、1− と 2− (黒) は下の青レール (GND) へ。
  この題は AD3 に BNC アダプタを付けて測る (理由は「計器の設定」)。BNC ケーブル (先がクリップのもの) の芯が 1+・2+、
  外皮 (GND) が 1−・2− に当たる

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。13.8 kHz の方形波とリップルを見る題で、10 MHz よりずっと低いから。
CH1 は 555 の出力 (0〜9 V) を DC 結合で見る。CH2 は出力の −7.3 V に乗った小さなリップルを見るので、直流を切る **AC 結合** にする。
AD3 本体のピン (2×15 のヘッダー) の入力は DC 結合だけで、直流を打ち消す Offset も 0.5 V/div 以下の細かい目盛では ±2.5 V までしか動かせない。
そこで AD3 に **BNC アダプタ** を付け、CH1 のジャンパは DC、CH2 のジャンパは AC にする (AC 結合は約 1.6 Hz より低い成分を切る)。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (PIN 3、12 列) | BNC アダプタのジャンパで DC 結合、2 V/div |
| Scope CH2 (出力、26 列) | BNC アダプタのジャンパで AC 結合、20 mV/div |
| Time | 20 µs/div (13.8 kHz が約 3 周期) |
| Trigger | CH1、立ち上がり、4.5 V |

```scope
title: 図3 PIN 3 の方形波 (CH1) と出力のリップル (CH2、AC 結合) — 目安
time: 20us/div
trigger: ch1 rising 4.5V
ch1: {wave: square 13.8kHz 4.5V offset 4.5V, range: 2V/div}
ch2: {wave: triangle 13.8kHz 53mVpp, range: 20mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/07-charge-pump-negative.svg)

図3 の CH1 は 0〜9 V (9 Vpp、2 V/div で 4.5 目盛)、周波数は約 13.8 kHz。画面下の Measurements も Vpp 9.00 V・13.80 kHz (CH1)、53.0 mV (CH2) と表の値に合う。CH2 は 53 mVpp の揺れで、「見るべき値」の表の計算値 (約 53 mV) を三角波で**目安として**描いた
(実際の形は Cp が電荷を運ぶ瞬間の跳びを含むのこぎり状になり、大きさは使うダイオードと 555 の出力の High の電圧で変わる)。
DC 結合のままだと CH2 は約 −7.3 V の直線に見えて揺れは読めない。AC 結合にすると、図3 のように 0 V のまわりの揺れになる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | タイマー IC | NE555 |
| Ra | 抵抗 | 1 kΩ |
| Rb | 抵抗 | 4.7 kΩ |
| C1 | セラミックコンデンサ (タイミング) | 10 nF |
| Cc | セラミックコンデンサ (CONT のノイズ対策) | 10 nF |
| Cp | セラミックコンデンサ (ポンプ用) | 1 µF |
| D1, D2 | ダイオード | 1N4148 |
| Co | 電解コンデンサ (出力の平滑) | 10 µF |
| RL | 抵抗 (負荷) | 1 kΩ |
| — | 計器 | AD3 の Scope 1+ / 2+ (PIN 3 と出力)。直流の電圧はテスター |
| — | AD3 の BNC アダプタと BNC ケーブル 2 本 (先がクリップのもの) | CH2 の AC 結合に使う |
| — | 電源 | 9 V (006P 電池かアダプタ)。チャージポンプは出力がダイオード 2 個ぶん (約 1.2 V) 浅くなる。既定の 5 V では負電圧が浅すぎて OP アンプの負電源に使いにくいので、9 V にして実用的な深さの負電圧を取り出す |

## 見るべき値

表の値は計算値で、OUT の High を 9 V とした。式は次の 2 つ。

- 周波数 f = 1.44 / ((Ra + 2Rb) × C1) (3-2 の 555 非安定と同じ式)
- 出力インピーダンス (出力の電圧が負荷でどれだけ下がるかを表す、等価な直列抵抗) の目安 R<sub>out</sub> ≈ 1 / (f × Cp)

実物の NE555 は、OUT の High が電源より 1.5 V ほど低いことが多い。その分、出力電圧は表よりさらに浅くなる。
電圧はテスターの DC 電圧レンジで、+ 側の棒を出力 (Co の −)、− 側の棒を GND に当てて測る (マイナスの値が出る)。
周波数とリップルは Analog Discovery のオシロ (1+ を PIN 3 または出力、1− を GND) で見る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| PIN 3 (OUT) の周波数 | 約 13.8 kHz | 1.44 / ((1 k + 9.4 k) × 10 nF) |
| 出力電圧 (無負荷) | 約 −7.8 V (計算値) | −(9V − 2×0.6V)。実測はダイオードの特性でもう少し浅くなることがある |
| 出力電圧 (RL = 1 kΩ) | 約 −7.3 V (計算値) | −7.8 V × 1 k / (1 k + 72) 。出力インピーダンス (約 72 Ω = 1 / (13.8 kHz × 1 µF)) と RL の分圧ぶん浅くなる |
| RL を流れる電流 | 約 7.3 mA | 7.3 V ÷ 1 kΩ |
| 出力のリップル | 約 53 mV (計算値) | RL の電流 × 周期 ÷ Co = 7.3 mA × 72 µs ÷ 10 µF |

Cp や周波数を大きくするほど取り出せる電流は増えるが、555 自体の出力電流
(最大 200 mA 程度) と発熱が上限になる。数十 mA を超える負電圧が要るなら
専用 IC (ICL7660。5-16 で扱う予定) を使うほうが安定する。

## 出典

自作。
