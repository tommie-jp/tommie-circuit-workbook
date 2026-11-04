---
book: circuits
chapter: 4
id: 4-15
title: 電圧→電流 (定電流 LED ドライバ)
tier: 200
source: 自作
---

# 4-15 電圧→電流 (定電流 LED ドライバ)

1-1 では LED の電流を直列の抵抗で決めた。電流は (電源 − V<sub>F</sub>) / R なので、LED の色 (V<sub>F</sub>) や電源電圧が変わると電流も変わる。
**OP アンプで「抵抗の両端の電圧」を入力の電圧に合わせ続ける**と、電流は I = V<sub>in</sub> / Rs だけで決まり、
LED の V<sub>F</sub> にも電源にも依らなくなる。電圧を電流に変える回路 (V-I 変換) で、定電流の LED ドライバ・
センサーの励振・4-20 mA の電流ループの送り側に使う。

この題では、LM358 と 2SC1815 で、W1 の三角波 (0 V〜1 V) をそのまま LED の電流 (0 mA〜10 mA) に変える。
電流検出の抵抗 Rs の電圧が W1 と同じ形になること、LED を 2 本に増やすと電圧が足りずに電流が頭打ちになることを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 V-I 変換 (Rs の電圧を入力に合わせて I は Vin / Rs)
parts:
  VCC: vcc 10,1 5V
  W1: triangle 2,4 2,6 1 l=$\mathrm{W1}$
  GW: ground 2,6
  U1: opamp 5,4.4 +up
  Rb: resistor 7,4.4 9,4.4 1k
  Q1: npn 10,4.4 2SC1815
  D1: led 10,1 10,3 red
  Rs: resistor 10,6 10,8 100
  GRs: ground 10,8
  VE: port 12,6 out
wires:
  - 2,4 -- 4,4
  - 4,4 |- U1.+
  - U1.out -- 7,4.4
  - 9,4.4 -- Q1.B
  - 10,3 -- Q1.C
  - Q1.E -- 10,6
  - 10,6 -- 4,6
  - 4,6 |- U1.-
  - 10,6 -- 12,6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/15-led-current-driver.svg)

- U1 の電源は 5 V の単電源 (V+ = 5 V、V− = GND)。LM358 は入力も出力も GND の近くまで使える (4-11)
- **U1 の − 入力を Q1 のエミッタ (VE) から取る**のが要点。U1 は − 入力を + 入力 (W1) に合わせようとして出力を動かし、
  Q1 のベースを通してエミッタの電圧を V<sub>in</sub> にそろえる。Rs (100 Ω) には I = V<sub>in</sub> / Rs が流れる
- Q1 のコレクタの電流はエミッタの電流とほぼ同じ (ベースの電流は 1/250 ほど)。LED の電流は **V<sub>in</sub> / 100 Ω**。
  W1 が 0 V〜1 V なら 0 mA〜10 mA。4-1 のフォロアの帰還の中に Q1 を入れた形で、Q1 の V<sub>BE</sub> (約 0.7 V) も帰還が打ち消す
- LED の V<sub>F</sub> が変わっても、Q1 のコレクタ-エミッタ間の電圧が変わって吸収する。吸収できる範囲は
  **5 V − V<sub>F</sub> − V<sub>in</sub> − V<sub>CE(sat)</sub> (約 0.1 V) > 0** の間。赤 LED 1 本 (V<sub>F</sub> 約 2.0 V) なら 10 mA で約 1.9 V の余裕がある
- Rb (1 kΩ) は U1 の出力からベースへ流す電流を制限する。出力は V<sub>in</sub> + V<sub>BE</sub> ≈ 1.75 V までしか上がらず、
  LM358 の出力の上限 (約 3.5 V) の内にいる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Rs と LED は下ブロック)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies 5V・W1・Scope)
    pins: [V+, GND, W1, 1+, 2+, 1-, 2-]
  U1: dip8 @ e10 LM358
  Rb: resistor b11 b17 1k
  Q1: transistor d15 d16 d17 2SC1815
  Rs: resistor j15 -b15 100 cap=left
  D1: led +b18 j18 red cap=right
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.W1 -- a13 yellow
  - AD3.1+ -- a15 orange
  - AD3.2+ -- a16 green
  - AD3.1- -- -t26 black
  - AD3.2- -- -t27 black
  - +t1 -- +b1 red
  - -t4 -- -b4 black
  - a10 -- +t10 red
  - j13 -- -b13 black
  - c15 -- c12 orange
  - e15 -- f15 orange
  - e16 -- f16 green
  - h16 -- h18 green
  - g10 -- g11 white
  - j12 -- -b12 black
notes:
  - text below: 上下とも 赤レール = +5V、青レール = GND (単電源)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/15-led-current-driver.svg)

- 5 V の単電源。AD3 の V+ は上の赤レール、GND は上の青レールへ入れ、下のレールには 1 列の赤と 4 列の黒で渡す (4-11 と同じ)。
  電流は LED の最大 10 mA と LM358 の約 1 mA で、AD3 の 5 V の約 50 mA の範囲に収まる
- LM358 は 10 列〜13 列。**上ブロック側の回路 (PIN 5〜7) を使う**。+ 入力 (PIN 5、13 列) に W1 (黄)、PIN 8 (10 列) は `a10 → +t10` で +5 V、PIN 4 (13 列) は `j13 → -b13` で GND
- 出力 (PIN 7、11 列) から Rb (b 段、11 列〜17 列) で Q1 のベース (17 列) へ。Q1 (2SC1815) は印字面を手前にして 15 列 (E)・16 列 (C)・17 列 (B)
- **エミッタ (15 列) から橙 `c15 → c12` で − 入力 (PIN 6、12 列) に戻す** (帰還)。エミッタは橙 `e15 → f15` で下ブロックへ下ろし、Rs (100 Ω) を 15 列から下の青レール (GND) へ
- コレクタ (16 列) は緑 `e16 → f16` で下ブロックへ下ろし、`h16 → h18` で 18 列へ。D1 (赤 LED) は下の赤レール (+5 V、アノード) から 18 列 (カソード) へ挿す
- 下ブロック側の回路 (PIN 1〜3) は使わないので、出力と − 入力を白 `g10 → g11` でつなぎ、+ 入力 (12 列) を `j12 → -b12` で GND に落とす
- Scope の 1+ (橙) はエミッタの 15 列 (`a15`)、2+ (緑) はコレクタの 16 列 (`a16`)。1− と 2− は上の青レール (GND) へ

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。100 Hz の三角波の形を比べる題で、10 MHz よりずっと低いから。
W1 は 100 Hz・0 V〜1 V の三角波。CH1 でエミッタ (Rs の電圧 = 電流 × 100 Ω)、CH2 でコレクタを見る。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Triangle、100 Hz、振幅 0.5 V、オフセット 0.5 V (0 V〜1 V) |
| Scope CH1 (エミッタ、15 列) | DC、200 mV/div。0 V を中心より 2.5 目盛下に置く |
| Scope CH2 (コレクタ、16 列) | DC、500 mV/div。0 V を中心より 4 目盛下に置く |
| Time | 2 ms/div (100 Hz が 2 周期) |
| Trigger | CH1、立ち上がり、0.5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Rs の電圧 (CH1) は W1 の三角波のまま、コレクタ (CH2) はほぼ一定
time: 2ms/div
trigger: ch1 rising 0.5V
ch1: {wave: triangle 100Hz 0.5V offset 0.5V, range: 200mV/div, position: -2.5div}
ch2: {wave: = 3.12V - 0.12 * ch1, range: 500mV/div, position: -4div}
cursors: [-2.5ms, 2.5ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/15-led-current-driver.svg)

図3 の CH1 は 0 V から 1 V (5 目盛) の三角波で、W1 と同じ形。Rs が 100 Ω なので、1 目盛 (200 mV) が 2 mA に当たる。
カーソル X1 (−2.5 ms) は谷 (0 mA)、X2 (2.5 ms) は山 (10 mA)。CH2 (コレクタ) は 5 V から LED の V<sub>F</sub> を引いた電圧で、
電流が 10 mA のとき約 3.0 V、電流が小さいほど V<sub>F</sub> が下がって少し上がる (図の傾きは LED の模型からの目安)。
LED の明るさが変わっても、電流の形は W1 のまま崩れない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方。もう片方は使わない) | LM358 |
| Q1 | NPN トランジスタ | 2SC1815 (I<sub>C</sub> は最大 10 mA で、定格 150 mA の内) |
| Rs | 抵抗 (電流の検出。I = V<sub>in</sub> / Rs) | 100 Ω (10 mA で 10 mW) |
| Rb | 抵抗 (ベースの電流の制限) | 1 kΩ |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 2.0 V @ 10 mA |
| — | 信号源 | 100 Hz・0 V〜1 V の三角波 (電流の指令) |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (エミッタとコレクタ)、テスター |

## 見るべき値

W1 を三角波にしてオシロで、W1 を直流 (オフセットだけ) にしてテスターで測る。表の値は計算値。I = V<sub>in</sub> / 100 Ω。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| エミッタ (Rs の電圧) | W1 と同じ (0 V〜1 V) | 帰還がエミッタを V<sub>in</sub> にそろえる。V<sub>BE</sub> は残らない |
| LED の電流 (W1 を直流 0.5 V に) | 5.0 mA | 0.5 V / 100 Ω。テスターの電流レンジを LED と直列に入れて確かめる |
| U1 の出力 (11 列、0.5 V のとき) | 約 1.2 V | V<sub>in</sub> + V<sub>BE</sub> + Rb の降下。ここだけが V<sub>BE</sub> の分だけずれる |
| コレクタ (10 mA のとき) | 約 3.0 V | 5 V − V<sub>F</sub>。Q1 が残りの 2 V ほどを受け持つ |
| LED を緑・青に替えたときの電流 | 変わらない (10 mA で同じ) | V<sub>F</sub> の違いはコレクタの電圧が吸収する。青 (V<sub>F</sub> 約 3 V) でも余裕は約 0.9 V |
| 赤 LED を 2 本直列にしたとき | 電流の山が約 9.2 mA で頭打ち | 5 V − 2 × 2.0 V = 1 V しか残らず、Rs の 1 V と V<sub>CE(sat)</sub> が入らない。このとき U1 の出力は上限 (約 3.5 V) に張り付く |

定電流の回路には「出せる電圧の範囲」(コンプライアンス電圧) がある。範囲を超えた負荷は、電流を決める側から外れてしまう。
電源を 9 V にすると LED 2 本でも 10 mA が流れるが、Q1 の電力 (V<sub>CE</sub> × I) が増える。

## LTspice での確かめ

`sim/15-led-current-driver.cir` で図1 を過渡解析で走らせた。LED が 1 本の場合と 2 本直列の場合を並べた。Q1 は 2-3 と同じ 2SC1815 の代用モデル、
D1 は赤 LED の代用モデル (どちらも**仮定**で、実測ではない)。オペアンプは 1 極の簡易模型 (出力は V+ − 1.5 V で頭打ち。LM358 相当の**仮定**)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 電流の山 (LED 1 本、W1 = 1 V) | 10 mA | 9.99 mA | 合う |
| W1 = 0.5 V のときの電流 | 5.0 mA | 5.00 mA | 合う |
| エミッタの山 | 1 V | 0.999 V | 合う |
| LED の V<sub>F</sub> (10 mA) | 約 2.0 V | 2.01 V | 合う |
| コレクタの電圧 (LED 1 本) | 約 3.0 V〜3.1 V | 2.99 V (10 mA)〜3.40 V (電流ほぼ 0) | 合う (電流がほぼ 0 の瞬間だけ V<sub>F</sub> が下がって上がる) |
| 赤 LED 2 本で頭打ちの電流 | 約 9.2 mA | 9.18 mA (U1 の出力 3.5 V) | 合う |

## 出典

自作。
参考: [Current source (Wikipedia)](https://en.wikipedia.org/wiki/Current_source)、[TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)
