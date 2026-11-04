---
book: circuits
chapter: 4
id: 4-19
title: 三角波・方形波発生器 (積分 + シュミット)
tier: 200
source: 自作
---

# 4-19 三角波・方形波発生器 (積分 + シュミット)

4-6 の積分回路は、方形波を入れると三角波を出した。4-8 のシュミットトリガは、入力が上のしきい値を超えると出力が跳び、
下のしきい値を下回ると戻った。**積分の出力をシュミットに入れ、シュミットの出力を積分に戻す**と、外から信号を入れなくても
2 つが互いを動かし続ける。シュミットが High の間は積分が下がり、下のしきい値で Low に跳ぶと、こんどは積分が上がる。
積分の出力が**三角波**、シュミットの出力が**方形波**になる発振回路で、関数発生器 (ファンクションジェネレータ) の原形。

この題では MCP6002 の 2 回路で組み、約 1 kHz の三角波 (±1.25 V) と方形波 (±2.5 V) が同時に出ることを確かめる。
周波数は f = R2 / (4 × R1 × R × C) で、R・C・R1・R2 の比だけで決まり、電源の電圧には依らない。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 積分 (U1) とシュミット (U2) を輪にした三角波・方形波の発振回路
parts:
  VP: vsource vp mid 2.5
  VN: vsource mid vm 2.5
  G1: ground 22,2.5
  R: resistor 2,4 5,4 10k
  C: capacitor 5,2 9,2 47n
  U1: opamp 7,4.38 +down
  GU1: ground 6,6
  R1: resistor 10,4.38 12,4.38 10k
  R2: resistor 12,2 17,2 20k
  U2: opamp 15,4.76 +up
  GU2: ground 14,6.5
  TRI: port 10,6.5 out
  SQ: port 19,4.76 out
points:
  vp: 21,1
  mid: 21,2.5
  vm: 21,4
wires:
  - mid -- 22,2.5
  - 5,4 -| U1.-
  - 5,4 -- 5,2
  - 9,2 -- 9,4.38
  - 6,6 |- U1.+
  - U1.out -- 9,4.38 -- 10,4.38
  - 10,4.38 -- 10,6.5
  - 12,4.38 -| U2.+
  - 12,4.38 -- 12,2
  - 17,2 -- 17,4.76
  - 14,6.5 |- U2.-
  - U2.out -- 17,4.76 -- 19,4.76
  - 17,4.76 -- 17,8 -- 2,8 -- 2,4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/19-triangle-square-generator.svg)

- 右上の VP・VN は ±2.5 V 電源。AD3 の Supplies の V+ を 2.5 V、V− を −2.5 V にして作る (理由は部品の表)
- **U1 は 4-6 の積分回路** (R = 10 kΩ、C = 47 nF)。入力 (SQ) が +2.5 V の間は TRI が 2.5 V / (R × C) = 5.3 V/ms の傾きで下がり、−2.5 V の間は同じ傾きで上がる
- **U2 は + 入力側から入れるシュミット** (4-8 は − 入力に入れたので向きが逆)。+ 入力は TRI と SQ を R1 (10 kΩ) と R2 (20 kΩ) で分圧した電圧で、
  これが 0 V (− 入力) を横切ると SQ が跳ぶ。しきい値は **TRI = ∓2.5 V × R1 / R2 = ∓1.25 V**
- 輪の動き: SQ が +2.5 V → TRI が下がる → TRI が −1.25 V に届くと SQ が −2.5 V に跳ぶ → TRI が上がる → +1.25 V で SQ が +2.5 V に戻る
- 三角波が 2.5 Vpp を 5.3 V/ms で上り下りするので、半周期は 0.47 ms、**f = R2 / (4 × R1 × R × C) = 20 k / (4 × 10 k × 10 kΩ × 47 nF) ≈ 1.06 kHz**。
  SQ の振れ (電源) は傾きとしきい値の両方に同じだけ効くので、式から消える
- 周波数を変えるには R か C を替える。三角波の振幅を変えるには R1 / R2 の比を替える (周波数も一緒に変わる)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (上が積分、下がシュミット)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies +2.5V・Scope)
    pins: [V+, GND, 2+, 1+, 1-, 2-]
  SV:
    type: device
    at: bottom
    label: AD3 (Supplies −2.5V)
    pins: [V-]
  U1: dip8 @ e12 MCP6002
  C: capacitor c14 c9 47n
  R: resistor d14 d19 10k
  R1: resistor g9 g14 10k cap=left
  R2: resistor i14 i19 20k
wires:
  - AD3.V+ -- +t2 red
  - AD3.GND -- -t3 black
  - AD3.1+ -- a19 white
  - AD3.2+ -- a13 orange
  - AD3.1- -- -t29 black
  - AD3.2- -- -t30 black
  - SV.V- -- j15 blue
  - -t1 -- -b1 black
  - a12 -- +t12 red
  - a15 -- -t15 black
  - b13 -- b9 orange
  - e9 -- f9 orange
  - e19 -- f19 white
  - h12 -- h19 white
  - j13 -- -b13 black
notes:
  - text below: 赤レール = +2.5V、青レール = GND (上下とも)。−2.5V は V− から PIN 4 へ直に
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/19-triangle-square-generator.svg)

- AD3 の V+ (+2.5 V) は上の赤レール、GND は上の青レール、下の青レールは 1 列の黒で GND をもらう。**−2.5 V はレールに置かず、AD3 の V− (青) から PIN 4 (15 列) へ直に入れる** (4-16 と同じ)。
  電流は 1 mA ほど
- MCP6002 は 12 列〜15 列。**上ブロック側の回路 (PIN 5〜7) が U1 (積分)、下ブロック側 (PIN 1〜3) が U2 (シュミット)**。PIN 8 (12 列) は `a12 → +t12` で +2.5 V
- **積分 (上)**: + 入力 (PIN 5、15 列) は `a15 → -t15` で GND。− 入力 (PIN 6、14 列) から C (c 段) を 9 列へ、R (d 段) を 19 列へ。
  出力 TRI (PIN 7、13 列) は橙 `b13 → b9` で 9 列 (C の他端) へつなぐ
- **TRI を下へ**: 橙 `e9 → f9` で下ブロックの 9 列へ下ろし、R1 (g 段) で U2 の + 入力 (PIN 3、14 列) へ
- **シュミット (下)**: − 入力 (PIN 2、13 列) は `j13 → -b13` で GND。R2 (i 段) は 14 列と 19 列の間、出力 SQ (PIN 1、12 列) は白 `h12 → h19` で 19 列へ。
  19 列は白 `e19 → f19` で上ブロックへ上がり、R の他端 (積分の入力) になる
- Scope の 1+ (白) は SQ の 19 列 (`a19`)、2+ (橙) は TRI の 13 列 (`a13`)

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。約 1 kHz の三角波と方形波を並べる題で、10 MHz よりずっと低いから。
入力の信号は要らない (W1 は使わない)。電源を入れると発振が始まる。

| 設定 | 値 |
| --- | --- |
| Supplies | V+ 2.5 V、V− −2.5 V |
| Scope CH1 (SQ、19 列) | DC、1 V/div |
| Scope CH2 (TRI、13 列) | DC、500 mV/div |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 方形波 (CH1) が High の間は三角波 (CH2) が下がり、Low の間は上がる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 1.04kHz 2.475V, range: 1V/div}
ch2: {wave: ch1 | integrate 470us | invert, range: 500mV/div}
cursors: [0, 481us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/19-triangle-square-generator.svg)

図3 の CH1 (SQ) は ±2.5 V (5 目盛) の方形波、CH2 (TRI) は ±1.25 V (5 目盛) の三角波。カーソル X1 (0 µs) は SQ が立ち上がる瞬間で、TRI はちょうど上のしきい値 +1.25 V にいる。
X2 (481 µs) は SQ が立ち下がる瞬間で、TRI は下のしきい値 −1.25 V。ΔX が半周期 (481 µs) で、周波数は 1.04 kHz (LTspice の値で描いた)。
SQ が High の間 TRI は下がり、Low の間は上がる (積分は反転するため)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1, U2 | オペアンプ (1 個の MCP6002 の 2 回路。レール to レール) | MCP6002 |
| R | 抵抗 (積分) | 10 kΩ |
| C | フィルムコンデンサ (積分) | 47 nF |
| R1 | 抵抗 (シュミットの入力側) | 10 kΩ |
| R2 | 抵抗 (シュミットの帰還。R1 / R2 が三角波の振幅を決める) | 20 kΩ |
| — | 電源 | ±2.5 V (AD3 の Supplies。V+ = +2.5 V、V− = −2.5 V)。**±5 V にしないのは、MCP6002 の電源電圧が 6 V までのため**。出力が電源から電源まで振れる (レール to レール) ので、方形波の高さが ±2.5 V にそろい、三角波も 0 V を中心にそろう |
| — | 計器 | AD3 の Scope 1+/2+ (SQ と TRI)、テスター |

LM358 で組むと、出力の上は V+ − 1.5 V までしか振れず、下は V− の近くまで振れるので、方形波の上下の高さがそろわない。
しきい値と傾きが上下で違い、三角波が 0 V からずれ、方形波のデューティが 50 % から外れる。

## 見るべき値

表の値は計算値と LTspice の読み。周波数は Scope の Measurements の Frequency で読む。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| SQ の高さ | ±2.5 V (4.95 Vpp) | レール to レールの出力。電源から約 25 mV 内側 |
| TRI の山と谷 | ±1.25 V (2.5 Vpp) | しきい値 = ±2.5 V × R1 / R2 |
| TRI の傾き | 約 5.3 V/ms | 2.5 V / (R × C) |
| 周波数 | 約 1.06 kHz (計算)、1.04 kHz (LTspice) | f = R2 / (4 R1 R C)。MCP6002 のスルーレート (0.6 V/µs) で SQ が跳ぶのに約 8 µs かかる分、少し下がる |
| SQ のデューティ | 50 % | 上下の高さがそろっているから |
| C を 100 nF に替えた周波数 | 約 0.5 kHz | f は C に反比例 |
| R2 を 39 kΩ に替えた TRI | ±0.64 V、周波数 約 2.1 kHz | 振幅は R1 / R2 に比例、周波数は R2 / R1 に比例 |

三角波をダイオードで山を丸める回路に通すと、正弦波に近い波ができる。市販の関数発生器 IC (ICL8038 など) も、コンデンサの充放電としきい値の切り替えで三角波と方形波を作り、正弦波に整えて出す。

## LTspice での確かめ

`sim/19-triangle-square-generator.cir` で図1 を過渡解析で 20 ms 走らせ、後半の 10 ms を読んだ (起動のため TRI の初期値を 1 V にした)。
オペアンプは 1 極の簡易模型 (GBW 1 MHz・スルーレート 0.6 V/µs・出力は電源から 25 mV まで。MCP6002 相当の**仮定**で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| SQ の高さ | ±2.5 V | ±2.475 V | 合う |
| TRI の山と谷 | ±1.25 V | +1.256 V・−1.256 V | 合う |
| 周期 | 約 0.94 ms (計算) | 0.963 ms (1.04 kHz) | 近い (スルーレートで 2 % 長い) |
| 半周期 | 約 0.47 ms | 0.481 ms (デューティ 50 %) | 近い (同じ理由) |
| SQ の立ち上がり (−2 V→+2 V) | 約 7 µs | 6.7 µs | 合う (4 V / 0.6 V/µs) |

## 出典

自作。
参考: [Function generator (Wikipedia)](https://en.wikipedia.org/wiki/Function_generator)、[Microchip MCP6002 のデータシート](https://ww1.microchip.com/downloads/en/DeviceDoc/MCP6001-1R-1U-2-4-1-MHz-Low-Power-Op-Amp-DS20001733L.pdf)
