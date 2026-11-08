---
book: circuits
chapter: 4
id: 4-18
title: ウィンドウコンパレータ
tier: 200
source: 自作
---

# 4-18 ウィンドウコンパレータ

4-17 の比較器は「しきい値より上か下か」の 2 つしか言わない。電池の電圧や温度のように
**「決めた範囲 (窓) の中か外か」** を知りたいときは、比較器を 2 つ使う。1 つは下のしきい値 V<sub>L</sub> より上か、
もう 1 つは上のしきい値 V<sub>H</sub> より下かを見て、**両方が成り立つときだけ出力を High** にする。
LM393 の出力はオープンコレクタなので、2 つの出力を直結するだけで「どちらかが Low なら Low」(ワイヤード AND) になる (4-17)。

この題では V<sub>L</sub> = 1.25 V、V<sub>H</sub> = 2.5 V の窓を作り、W1 の三角波 (0.5 V〜3.0 V) が窓に入っている間だけ出力が High に、
外に出ると Low になって LED が点くことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ウィンドウコンパレータ (U1B は VH より下、U1A は VL より上で手を離す)
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,1 2,3 20k
  R2: resistor 2,3 2,7.8 10k
  R3: resistor 2,7.8 2,10 10k
  GR3: ground 2,10
  W1: triangle 5,4.6 5,6.6 1.25 l=$\mathrm{W1}$
  GW: ground 5,6.6
  U1B: opamp 10,3.38 +up
  U1A: opamp 10,7.38 +up
  Rpu: resistor 14,1 14,5.4 10k
  D1: led 16,1 16,3 red
  R4: resistor 16,3 16,5.4 1k
  OUT: port 18,5.4 out
wires:
  - 2,1 -- 14,1 -- 16,1
  - 2,3 -| U1B.+
  - 2,7.8 -| U1A.-
  - 5,4.6 -- 7,4.6
  - 7,4.6 |- U1B.-
  - 7,4.6 |- U1A.+
  - U1B.out -- 12,3.38
  - U1A.out -- 12,7.38
  - 12,3.38 -- 12,5.4 -- 12,7.38
  - 12,5.4 -- 14,5.4 -- 16,5.4 -- 18,5.4
notes:
  - text 3,2.7 blue: VH
  - text 3,7.5 blue: VL
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/18-window-comparator.svg)

- U1A・U1B は 1 個の LM393 の 2 回路 (記号は OP アンプと同じ三角)。電源は 5 V の単電源 (4-17 と同じ)
- **しきい値は左の 3 本の抵抗で作る**。5 V − R1 (20 kΩ) − R2 (10 kΩ) − R3 (10 kΩ) − GND の分圧で、
  V<sub>H</sub> = 5 × 20/40 = **2.5 V**、V<sub>L</sub> = 5 × 10/40 = **1.25 V**。1 本の分圧の上下から取るので、窓の幅も電源に比例する
- **U1B** は + 入力が V<sub>H</sub>、− 入力が W1。W1 が 2.5 V より下なら出力のトランジスタは切れる (手を離す)、上なら Low に引く
- **U1A** は + 入力が W1、− 入力が V<sub>L</sub>。W1 が 1.25 V より上なら手を離す、下なら Low に引く
- 2 つの出力を直結して Rpu (10 kΩ) で 5 V へ。**両方が手を離したとき (1.25 V < W1 < 2.5 V) だけ High**、どちらかが引けば Low
- D1 (赤 LED) と R4 (1 kΩ) は 5 V から出力へ。出力が Low (窓の外) のとき (5 − 2.0 − 0.1) / 1 kΩ ≈ 3 mA で点く。窓の中では両端の電圧が無くなって消える
- W1 の上限を 3.0 V にしたのは、LM393 の入力が正しく働く範囲 (5 V − 1.5 V = 3.5 V まで) に収めるため

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (2 つの出力を 11 列でまとめる)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies 5V・W1・Scope)
    pins: [V+, GND, 2+, W1, 1+, 1-, 2-]
  U1: dip8 @ e14 LM393
  R1: resistor b22 b27 20k cap=right
  R2: resistor c22 c25 10k
  R3: resistor a25 -t25 10k
  Rpu: resistor c11 c7 10k cap=above
  R4: resistor d11 d5 1k
  D1: led +t4 a4 red i=3mA
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.2+ -- a15 green
  - AD3.W1 -- a16 yellow
  - AD3.1+ -- a19 yellow
  - AD3.1- -- -t29 black
  - AD3.2- -- -t30 black
  - a14 -- +t14 red
  - -t1 -- -b1 black
  - j17 -- -b17 black
  - a27 -- +t27 red
  - a7 -- +t7 red
  - b4 -- b5 white
  - d17 -- d22 orange
  - c16 -- c19 yellow
  - e19 -- f19 yellow
  - g19 -- g16 yellow
  - e25 -- f25 blue
  - h25 -- h15 blue
  - g14 -- g11 green
  - f11 -- e11 green
  - b11 -- b15 green
notes:
  - text below: 上の赤レール = +5V、青レール = GND (上下とも)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/18-window-comparator.svg)

- 5 V の単電源。AD3 の V+ は上の赤レール、GND は上の青レールへ。下の青レールは 1 列の黒で GND をもらう。電流は LED の 3 mA と数 mA で、AD3 の 5 V の約 50 mA の範囲に収まる
- LM393 は 14 列〜17 列。**下ブロック側の回路 (PIN 1〜3) が U1A、上ブロック側 (PIN 5〜7) が U1B**。PIN 8 (14 列) は `a14 → +t14` で +5 V、PIN 4 (17 列) は `j17 → -b17` で GND
- **しきい値 (右上)**: R1 (b 段、20 kΩ) は 27 列 (`a27 → +t27` で +5 V) と 22 列 (V<sub>H</sub>) の間、R2 (c 段、10 kΩ) は 22 列と 25 列 (V<sub>L</sub>) の間、R3 は 25 列から GND へ。
  V<sub>H</sub> は橙 `d17 → d22` で U1B の + 入力 (PIN 5、17 列) へ。V<sub>L</sub> は青 `e25 → f25` で下ブロックへ下ろし、`h25 → h15` で U1A の − 入力 (PIN 2、15 列) へ
- **W1 (黄) は 16 列** (U1B の − 入力、PIN 6)。黄 `c16 → c19` と `e19 → f19`、`g19 → g16` で、下ブロックの 16 列 (U1A の + 入力、PIN 3) へも配る
- **2 つの出力をまとめる**: U1A の出力 (PIN 1、14 列) は緑 `g14 → g11` と `f11 → e11` で上ブロックの 11 列へ上げ、緑 `b11 → b15` で U1B の出力 (PIN 7、15 列) とつなぐ
- 11 列から Rpu (c 段) で 7 列 (`a7 → +t7` で +5 V) へ、R4 (d 段) で 5 列へ。D1 は上の赤レール (+5 V、アノード) から 4 列 (カソード) へ挿し、白 `b4 → b5` で R4 につなぐ
- Scope の 1+ (黄) は W1 の 19 列 (`a19`)、2+ (緑) は出力の 15 列 (`a15`)

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。100 Hz の三角波としきい値の関係を見る題で、10 MHz よりずっと遅いから。
W1 は 100 Hz・0.5 V〜3.0 V の三角波。CH1 で W1、CH2 で出力を見る。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Triangle、100 Hz、振幅 1.25 V、オフセット 1.75 V (0.5 V〜3.0 V) |
| Scope CH1 (W1、19 列) | DC、1 V/div。0 V を中心より 4 目盛下に置く |
| Scope CH2 (出力、15 列) | DC、2 V/div。0 V を中心より 4 目盛下に置く |
| Time | 1 ms/div (100 Hz が 1 周期) |
| Trigger | CH1、立ち上がり、1.25 V。トリガの点を左から 1.5 目盛に置く |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 (CH1) が 1.25 V〜2.5 V の間だけ、出力 (CH2) が High
time: 1ms/div
trigger: ch1 rising 1.25V at -3.5div
ch1: {wave: triangle 100Hz 1.25V offset 1.75V, range: 1V/div, position: -4div}
ch2: {wave: "= 0.1V + 4.9V * step(ch1 - 1.25V) * step(2.5V - ch1)", range: 2V/div, position: -4div}
cursors: [1.25ms, 3.5ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/18-window-comparator.svg)

図3 は 1 周期 (10 ms) を描いた。t = 0 (トリガ) は CH1 が 1.25 V を上へ横切る所で、CH2 はここで 0.1 V から 5 V へ上がり、2.5 ms 後に CH1 が 2.5 V を超えると落ちる。
下りでも 2.5 V から 1.25 V までの 2.5 ms だけ High になる。カーソル X1 (1.25 ms) は窓の中 (CH1 1.88 V、CH2 5 V)、X2 (3.5 ms) は三角波の山 (CH1 3.0 V、CH2 0.1 V)。
High の間 (窓の中) は LED が消え、Low の間 (窓の外) は点く。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1A, U1B | コンパレータ (1 個の LM393 の 2 回路) | LM393 |
| R1 | 抵抗 (上のしきい値を作る) | 20 kΩ |
| R2, R3 | 抵抗 (窓の幅と下のしきい値を作る) | 各 10 kΩ |
| Rpu | 抵抗 (2 つの出力の共通のプルアップ) | 10 kΩ |
| D1 | LED (赤、5 mm。窓の外で点く) | V<sub>F</sub> ≈ 2.0 V |
| R4 | 抵抗 (LED の電流) | 1 kΩ |
| — | 信号源 | 100 Hz の三角波 (0.5 V〜3.0 V) |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (W1 と出力)、テスター |

## 見るべき値

テスターで V<sub>H</sub>・V<sub>L</sub> を、オシロで切り替わりの電圧と時刻を読む。表の値は計算値と LTspice の読み。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| V<sub>H</sub> (22 列) | 2.50 V | 5 × 20 / 40 |
| V<sub>L</sub> (25 列) | 1.25 V | 5 × 10 / 40 |
| 出力が High に上がる W1 | 1.25 V | U1A が手を離す (U1B はもう離している) |
| 出力が Low に落ちる W1 | 2.50 V | U1B が引き始める |
| 1 周期の中で High の時間 | 2.5 ms × 2 = 5.0 ms (50 %) | 窓の幅 1.25 V / 三角波の振れ 2.5 V。上りと下りで 1 回ずつ |
| 出力の Low | 約 0.1 V | Rpu の 0.5 mA と LED の 3 mA を吸う |
| LED の電流 (窓の外) | 約 3.0 mA | (5 − 2.0 − 0.1) / 1 kΩ |

W1 の代わりに半固定抵抗の分圧をつなぎ、ゆっくり回すと、1.25 V と 2.5 V で LED が切り替わる。しきい値ちょうどで
LED がちらつくのは 4-8 と同じ理由で、ヒステリシスを足すとなくなる (出力から + 入力へ大きな抵抗を戻す)。

## LTspice での確かめ

`sim/18-window-comparator.cir` で図1 を過渡解析で走らせた。LM393 は 4-17 と同じ振る舞いの模型 (応答時間 約 1.3 µs、
出力は 27 Ω で GND へ落とすオープンコレクタ。**仮定**で、実測ではない)、D1 は赤 LED の代用モデル。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| V<sub>H</sub>・V<sub>L</sub> | 2.50 V・1.25 V | 2.500 V・1.250 V | 合う |
| High に上がる W1 | 1.25 V | 1.251 V | 合う |
| Low に落ちる W1 | 2.50 V | 2.501 V | 合う |
| 切り替わりの時刻 (三角波の底から) | 1.5・4.0・6.0・8.5 ms | 1.50・4.00・6.00・8.50 ms | 合う |
| 出力の Low | 約 0.1 V | 0.093 V | 合う |
| LED の電流 (窓の外) | 約 3.0 mA | 2.96 mA | 合う |

## 出典

自作。
参考: [TI LM393 のデータシート](https://www.ti.com/lit/ds/symlink/lm393.pdf)、[Comparator (Wikipedia)](https://en.wikipedia.org/wiki/Comparator) (Window detector の節)
