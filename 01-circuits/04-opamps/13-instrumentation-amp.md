---
book: circuits
chapter: 4
id: 4-13
title: 計装アンプ (OP アンプ 3 つ)
tier: 200
source: 自作
---

# 4-13 計装アンプ (OP アンプ 3 つ)

4-7 の差動増幅は 2 つの入力の差を増幅するが、入力抵抗が 10 kΩ と 110 kΩ で、**左右で違い、しかも小さい**。
ひずみゲージや圧力センサーのブリッジ (抵抗 4 本の橋。片側の抵抗が変わると、2 つの中点の間に小さな差が出る) は
数 kΩ の出力抵抗を持つので、4-7 をそのままつなぐとブリッジが引っ張られ、差が正しく読めない。
**差動増幅の前に、ボルテージフォロアを 2 つ置いて入力を受ける**と、入力抵抗はほぼ無限大になる。
2 つのフォロアの − 入力の間に抵抗 Rg を 1 本渡すと、その 1 本で利得が決まる。これが OP アンプ 3 つの**計装アンプ**
(インスツルメンテーションアンプ) で、計測の入口の定番。

この題では LM324 (4 回路入り) の 3 回路で計装アンプを組み、W1 で励振したブリッジの差 (振幅 47.6 mV) が約 10 倍の
0.48 V になること、同じブリッジに 4-7 の差動増幅をつなぐと 0.30 V しか出ないことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 計装アンプ (前段 U1・U2 と Rg、差動段 U3) でブリッジの差を読む
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 3,9
  W1: sine 2,2 2,4 2 l=$\mathrm{W1}$
  GW: ground 2,4
  R7: resistor 6,1 6,3 10k
  R8: resistor 6,3 6,5 10k
  G8: ground 6,5
  R5: resistor 4,3 4,6 10k
  R6: resistor 4,6 4,9 11k
  G6: ground 4,9
  U1: opamp 10,3.36 +up
  Rf1: resistor 9,5 12,5 10k
  Rg: resistor 9,5 9,8 2.2k
  Rf2: resistor 9,8 12,8 10k
  U2: opamp 10,10 +down
  R11: resistor 13,3.36 15,3.36 10k
  R12: resistor 15,2 19,2 10k
  R13: resistor 13,10 15,10 10k
  R14: resistor 15,10 15,12 10k
  G14: ground 15,12
  U3: opamp 17,6.4 +down
  OUT: port 21,6.4 out
points:
  vp: 2,7.5
  vm: 2,10.5
  mid: 2,9
wires:
  - mid -- 3,9
  - 2,2 -- 2,1 -- 4,1 -- 6,1
  - 4,1 -- 4,3
  - 6,3 -- 8,3
  - 8,3 |- U1.+
  - 4,6 -- 7,6
  - 7,6 |- U2.+
  - 9,5 |- U1.-
  - 9,8 |- U2.-
  - U1.out -- 12,3.36
  - 12,5 -- 12,3.36 -- 13,3.36
  - U2.out -- 12,10
  - 12,8 -- 12,10 -- 13,10
  - 15,3.36 -- 15,2
  - 15,3.36 |- U3.-
  - 15,10 |- U3.+
  - 19,2 -- 19,6.4
  - U3.out -- 19,6.4 -- 21,6.4
notes:
  - text 7,2.7 blue: A
  - text 5,5.7 blue: B
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/13-instrumentation-amp.svg)

- 左下の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- **左のブリッジ**: W1 (1 kHz・振幅 2 V) で励振する。右の腕 (R7・R8、10 kΩ と 10 kΩ) の中点 A は W1 のちょうど半分、
  左の腕 (R5・R6、10 kΩ と 11 kΩ) の中点 B は 11/21 = 0.524 倍。差 V<sub>B</sub> − V<sub>A</sub> は W1 の 0.0238 倍 (振幅 47.6 mV) で、
  A・B はどちらも約 1 V 振れる (同相の成分)。R6 を 11 kΩ にしたのは、センサーの抵抗が 10 % 変わった所を作るため
- **前段 (U1・U2)**: A と B を + 入力で受ける。+ 入力には電流が流れないので、ブリッジは引っ張られない。
  Rg の両端は仮想短絡で A と B になり、Rg に (V<sub>B</sub> − V<sub>A</sub>) / Rg の電流が流れる。同じ電流が Rf1・Rf2 も流れるので、
  2 つの出力の差は **(1 + 2 × Rf / Rg) 倍 = 1 + 20 k / 2.2 k = 10.1 倍**に広がる。同相の成分は 1 倍のまま通る
- **差動段 (U3)**: 4-7 の差動増幅を、4 本とも 10 kΩ にした利得 1 倍の形。前段の出力の差だけを取り出し、同相の成分を消す。
  利得は全体で 10.1 倍、出力は **10.1 × 47.6 mV = 0.48 V** (振幅)
- 利得を変えるときは **Rg の 1 本だけを替える** (1 kΩ で 21 倍、10 kΩ で 3 倍)。差動段の 4 本はそろえたまま触らない

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (LM324 は 180° 回して挿す)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1・Scope)
    pins: [1+, W1, V+, GND, 2+, 1-, 2-, V-]
  U1: dip14 @ e12 r180 LM324
  R7: resistor b3 b7 10k
  R8: resistor a7 -t7 10k cap=right
  R5: resistor d3 d11 10k cap=below:2,0
  R6: resistor a11 -t11 11k cap=right
  Rg: resistor i13 i17 2.2k cap=right
  Rf1: resistor j13 j10 10k cap=left
  Rf2: resistor h17 h21 10k cap=right
  R11: resistor c10 c17 10k
  R12: resistor b17 b23 10k cap=above
  R13: resistor d21 d16 10k cap=right
  R14: resistor a16 -t16 10k cap=right
wires:
  - AD3.1+ -- a2 yellow
  - AD3.W1 -- a3 yellow
  - c2 -- c3 yellow
  - AD3.V+ -- +t5 red
  - AD3.GND -- -t13 black
  - AD3.2+ -- a18 green
  - AD3.1- -- -t26 black
  - AD3.2- -- -t27 black
  - AD3.V- -- -b30 blue
  - a15 -- +t15 red
  - j15 -- -b15 blue
  - e7 -- f7 orange
  - g7 -- g14 orange
  - e11 -- f11 white
  - h11 -- h16 white
  - i12 -- i10 green
  - f10 -- e10 green
  - g18 -- g21 orange
  - e21 -- f21 orange
  - c18 -- c23 green
  - b12 -- b13 white
  - a14 -- -t14 black
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/13-instrumentation-amp.svg)

- **LM324 は 180° 回して挿す** (切り欠きが右、1 番ピンが右上)。+5 V の PIN 4 が上ブロックの 15 列、−5 V の PIN 11 が下ブロックの 15 列に来て、
  `a15 → +t15` と `j15 → -b15` の短い線で電源がとれる。**下ブロックの 2 回路 (PIN 8〜10・12〜14) が前段、上ブロックの 1 回路 (PIN 1〜3) が差動段**。
  上ブロックの残りの 1 回路 (PIN 5〜7) は使わないが、入力を浮かせると発振して電源を揺らすことがあるので、
  フォロアにして + 入力を GND に落とす (白 `d12 → d13`、黒 `a14 → -t14`)
- AD3 は 1 つの箱にまとめた。V+ は上の赤レール、GND は上の青レール、V− は右端を回して下の青レールへ。電流は数 mA で、各レール約 50 mA の範囲に収まる
- **ブリッジは左上**: W1 (黄) は 3 列。R7 (b 段) と R5 (d 段) が 3 列から出て、A (7 列) と B (11 列) を作る。R8 (10 kΩ) と R6 (11 kΩ) は 7 列・11 列から上の青レール (GND) へ。
  Scope の 1+ は 2 列に挿し、黄の短い線 `c2 → c3` で W1 を見る
- **A・B を前段へ**: A は橙 `e7 → f7` で下ブロックへ下ろし、`g7 → g14` で U1 の + 入力 (PIN 10、14 列) へ。B は白 `e11 → f11` と `h11 → h16` で U2 の + 入力 (PIN 12、16 列) へ。
  2 本は g 段と h 段に分けたので交わらない
- **前段**: Rg (i 段) は 2 つの − 入力 (PIN 9 の 13 列と PIN 13 の 17 列) の間。U1 の出力 (PIN 8、12 列) は緑 `i12 → i10` で 10 列へ出し、Rf1 (j 段) で 13 列へ戻す。
  U2 の出力 (PIN 14、18 列) は橙 `g18 → g21` で 21 列へ出し、Rf2 (h 段) で 17 列へ戻す
- **差動段**: U1 の出力 (10 列) は緑 `f10 → e10` で上ブロックへ上げ、R11 (c 段) で U3 の − 入力 (PIN 2、17 列) へ。U2 の出力 (21 列) は橙 `e21 → f21` で上げ、
  R13 (d 段) で U3 の + 入力 (PIN 3、16 列) へ。R14 は 16 列から GND、R12 は 17 列と 23 列の間で、23 列は緑 `c18 → c23` で出力 (PIN 1、18 列) に戻る。
  Scope の 2+ (緑) は出力の 18 列 (`a18`) に挿す

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の正弦波の振幅を 2 本比べる題で、10 MHz よりずっと低いから。
CH1 で W1 (ブリッジの励振)、CH2 で出力を見る。出力が励振と同じ向きに振れること (B の側が大きいので正の差) も確かめる。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Sine、1 kHz、振幅 2 V、オフセット 0 V |
| Scope CH1 (W1、2 列) | DC、1 V/div |
| Scope CH2 (出力、18 列) | DC、200 mV/div |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH1、立ち上がり、0 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ブリッジの励振 (CH1、振幅 2 V) と計装アンプの出力 (CH2、振幅 0.48 V)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 2V, range: 1V/div}
ch2: {wave: sine 1kHz 0.481V, range: 200mV/div}
cursors: [250us, 750us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/13-instrumentation-amp.svg)

図3 の CH1 は 4 Vpp (4 目盛)、CH2 は 0.96 Vpp (約 4.8 目盛)。カーソル X1 (250 µs) と X2 (750 µs) を山と谷に置くと、CH2 は +0.48 V と −0.48 V。
CH1 と同じ向きに振れる。A・B の同相の成分 (約 1 V の振幅) は、出力にはほとんど残らない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1, U2, U3 | オペアンプ (1 個の LM324 の 4 回路のうち 3 つ) | LM324 |
| R5, R7, R8 | 抵抗 (ブリッジ) | 各 10 kΩ |
| R6 | 抵抗 (ブリッジの、センサーが 10 % 変わった腕) | 11 kΩ |
| Rg | 抵抗 (利得を決める 1 本) | 2.2 kΩ |
| Rf1, Rf2 | 抵抗 (前段の帰還) | 各 10 kΩ |
| R11〜R14 | 抵抗 (差動段。そろえるほど同相が消える。±1 % の金属皮膜) | 各 10 kΩ |
| — | 信号源 | 1 kHz・振幅 2 V の正弦波 (ブリッジの励振) |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (励振と出力)、テスター |

## 見るべき値

W1 を入れてオシロで振幅を読む。A・B や前段の出力は Scope の 1+ を挿し替えて見る。表の値は計算値。
利得 G = (1 + 2 × 10 kΩ / 2.2 kΩ) × 1 = 10.1。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| A (7 列) | 振幅 1.00 V | W1 × 10/20 |
| B (11 列) | 振幅 1.05 V | W1 × 11/21。差は 47.6 mV、同相は約 1 V |
| U1 の出力 (10 列) | 振幅 0.78 V | A − (10 k / 2.2 k) × 47.6 mV。差が前段で広がる |
| U2 の出力 (21 列) | 振幅 1.26 V | B + 4.55 × 47.6 mV |
| 出力 (18 列) | 振幅 0.48 V (W1 と同じ向き) | 10.1 × 47.6 mV。同相の 1 V は消える |
| Rg を 1 kΩ に替えた出力 | 振幅 1.0 V | 利得 21 倍。Rg の 1 本で利得が決まる |
| 比べ: 同じブリッジに 4-7 の差動増幅 (10 kΩ / 100 kΩ、利得 10) | 振幅 約 0.30 V (計算の 0.48 V の 6 割) | 4-7 の入力抵抗 (10 kΩ と 110 kΩ) がブリッジ (出力抵抗 約 5 kΩ) を引っ張る |
| 比べ: 差動段の R14 を 1 % 大きくし、ブリッジを釣り合わせた (R6 = 10 kΩ) ときの出力 | 約 10 mVpp | 同相 (2 Vpp) の 0.5 % が漏れる。差動段の抵抗のずれが同相除去を決める |

同相の漏れは差動段の抵抗のずれで決まり、前段の利得には依らない。**前段で差だけを広げてから差動段に渡す**ので、
Rg を小さくして利得を上げるほど、信号に比べた漏れの割合 (同相除去比、CMRR) がよくなる。市販の計装アンプ IC (INA128 など) は、
この 3 つの OP アンプと、そろえた抵抗を 1 つのチップに入れたもの。

## LTspice での確かめ

`sim/13-instrumentation-amp.cir` で図1 を過渡解析で走らせた。同じファイルに、比べの 2 つ (4-7 の差動増幅を同じブリッジにつないだもの、
釣り合わせたブリッジで同相だけを入れたもの) も入れ、差動段の抵抗を 1 % ずらす場合と並べた。
オペアンプは 1 極の簡易模型 (GBW 1 MHz。LM324 相当の**仮定**で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| A・B の振幅 | 1.00 V・1.05 V | 1.000 V・1.047 V | 合う |
| U1・U2 の出力の振幅 | 0.78 V・1.26 V | 0.783 V・1.264 V | 合う |
| 出力の振幅 | 0.48 V | 0.480 V | 合う |
| 4-7 の差動増幅をつないだ出力 | 約 0.30 V | 0.303 V | 合う |
| 同相だけ (抵抗のずれ 0) | 0 V | 0 V | 合う |
| 同相だけ (R14 を 1 % ずらす) | 約 10 mVpp | 9.9 mVpp | 合う |

## 出典

自作。
参考: [Instrumentation amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Instrumentation_amplifier)、[ホイートストンブリッジ (Wikipedia)](https://ja.wikipedia.org/wiki/ホイートストンブリッジ)、[TI LM324 のデータシート](https://www.ti.com/lit/ds/symlink/lm324.pdf)
