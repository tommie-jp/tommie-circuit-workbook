---
book: circuits
chapter: 5
id: 5-17
title: 電流制限 (フォールドバック)
tier: 200
source: 自作
---

# 5-17 電流制限 (フォールドバック)

5-2 のシリーズレギュレータは、出力を短絡すると制御のトランジスタに入力の電圧がまるごと掛かり、大きな電流が流れて壊れる。
電流制限は、検出抵抗 R<sub>SC</sub> の電圧で電流の上限を決める仕組みで、さらに**フォールドバック** (折り返し) は、出力の電圧が下がるほど上限そのものも下げる。
短絡したときの電流が、ふだんの上限の 1/3 ほどになるので、トランジスタの熱がずっと小さくて済む。V-I の線が「⊃」の形に折れ返ることからこの名がある。

この題の回路は、LM358 のフォロアで 5.1 V の基準 (ツェナー) を出力に写し、2SC1815 (Q1) で電流を足す 5 V 電源に、Q2 と抵抗 3 本のフォールドバックを付けたもの。
Q2 のベースには、Q1 のエミッタの電圧 V<sub>E</sub> = V<sub>OUT</sub> + I × R<sub>SC</sub> を R1・R2 で分けた電圧 k × V<sub>E</sub> (k = R2 ÷ (R1 + R2) = 0.636) が掛かる。
Q2 のエミッタは出力なので、Q2 が入って Q1 のベースの電流を奪い始めるのは

k × (V<sub>OUT</sub> + I × R<sub>SC</sub>) − V<sub>OUT</sub> = V<sub>BE</sub> (約 0.75 V) → I = [V<sub>BE</sub> + V<sub>OUT</sub> × (1 − k)] ÷ (k × R<sub>SC</sub>)

のとき。V<sub>OUT</sub> = 4.9 V なら約 33 mA、短絡 (V<sub>OUT</sub> = 0) なら約 10 mA (計算値。下の LTspice で 31 mA と 11 mA)。
出力の電圧が式に入っているので、出力が下がるほど上限も下がる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フォールドバックの電流制限つきの 5 V 電源 (入力 12 V)
parts:
  VIN: vcc 2,1 12V
  RZ: resistor 2,1 2,3.5 680
  DZ: zener 2,6 2,3.5 5.1V
  G1: ground 2,6
  U1B: opamp 5,3.5 +up LM358
  RB: resistor 6.5,3.5 7.8,3.5 4.7k
  Q1: npn 9,3.5 2SC1815
  RSC: resistor 10,5 13,5 120
  M2: voltmeter 10,3 13,3 l=$\mathrm{CH2}$
  R1: resistor 9,5 9,7.5 3.9k
  R2: resistor 9,7.5 9,9.5 6.8k
  G2: ground 9,9.5
  Q2: npn 7,7.5 mirror 2SC1815
  RL: resistor-var 15,5 15,9.5 1k
  G3: ground 15,9.5
  M1: voltmeter 17,5 17,9.5 l=$\mathrm{CH1}$
  G4: ground 17,9.5
wires:
  - 2,1 -- 9,1
  - 9,1 -| Q1.C
  - 2,3.5 |- U1B.+
  - U1B.out -- 6.5,3.5
  - 7.8,3.5 -- 8,3.5 -| Q1.B
  - Q1.E -| 9,5
  - 9,5 -- 10,5
  - 10,5 -- 10,3
  - 13,3 -- 13,5
  - 13,5 -- 15,5 -- 17,5
  - 9,7.5 -| Q2.B
  - Q2.C |- 8,4.5
  - 8,4.5 -- 8,3.5
  - Q2.E -| 7,10.5
  - 13,5 -- 13,10.5
  - 13,10.5 -- 7,10.5 -- 4,10.5
  - 4,10.5 |- U1B.-
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/circuit/17-foldback-current-limit.svg)

- 入力は 12 V (電源装置)。LM358 の出力は電源より約 1.5 V 低い所までしか上がらず、Q1 のベースは出力 + R<sub>SC</sub> の電圧 + 0.7 V (最大 9.6 V ほど) まで要るので、5 V や 9 V では足りない
- DZ (5.1 V) と RZ (680 Ω (オーム)、約 10 mA) が基準。U1B (LM358 の 2 番目の回路) は − に出力をつないだフォロアで、出力を基準と同じ電圧に保つ。
  R<sub>SC</sub> は帰還の内側にあるので、電流が増えても出力は下がらない
- RB (4.7 kΩ) は U1B の出力から Q1 のベースへの抵抗。Q2 が入ると RB の電流を横取りし、Q1 を絞る。RB が大きいほど Q2 の仕事が楽になる
- R<sub>SC</sub> (120 Ω) が電流を見る抵抗、R1 (3.9 kΩ)・R2 (6.8 kΩ) がフォールドバックの分圧
- RL (1 kΩ の半固定抵抗をレオスタット接続) が負荷。CH1 が出力、CH2 が R<sub>SC</sub> の両端 (120 Ω で 1 mA = 0.12 V)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (U1 は 2 番目の回路を使う。赤レール = 12 V)
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源装置 (12 V、電流制限 100 mA)
    pins: ["-", "+"]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (CH1・2-)
    pins: [1+, 2-, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (2+)
    pins: [2+]
  U1: dip8 @ e5 LM358
  RZ: resistor b1 b8 680
  DZ: zener c8(K) c3(A) 5.1V
  RB: resistor d6 d9 4.7k
  Q1: transistor f12 f13 f14 2SC1815
  RSC: resistor h12 h16 120
  R1: resistor i12 i22 3.9k
  R2: resistor j22 -b23 6.8k
  Q2: transistor f20 f21 f22 2SC1815
  RL: potentiometer i25(1) i26(W) i27(2) 1k
wires:
  - PSU.- -- -t2 black
  - PSU.+ -- +t4 red
  - +t1 -- a1 red
  - a3 -- -t3 black
  - a5 -- +t5 red
  - +t30 -- +b30 red
  - -t29 -- -b29 black
  - a7 -- a16 blue
  - e9 -- f9 orange
  - e16 -- f16 blue
  - g9 -- g14 orange
  - j13 -- +b13 red
  - j21 -- j14 orange
  - g20 -- g16 blue
  - h20 -- h25 blue
  - g25 -- g26 white
  - j27 -- -b27 black
  - g5 -- g6 white
  - g7 -- g8 white
  - j8 -- -b8 black
  - AD.1+ -- d16 yellow
  - AD.2- -- c16 purple
  - AD.1- -- -t20 black
  - AD1.2+ -- j12 green
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/breadboard/17-foldback-current-limit.svg)

- LM358 は 5〜8 列。使うのは上の e 行の 2 番目の回路 (5 番 IN2+ = 8 列、6 番 IN2− = 7 列、7 番 OUT2 = 6 列、8 番 V+ = 5 列)。
  使わない 1 番目の回路は、下の f 行で OUT1 と IN1− (5・6 列)、IN1+ と V− (7・8 列) を白の短い線でつなぎ、V− (8 列) を GND へ
- 基準: 赤いレール (12 V) から 1 列、RZ (`b1`–`b8`) で 8 列 (IN2+) へ。DZ はカソード (帯) を 8 列、アノードを 3 列に挿し、3 列を GND へ
- RB (`d6`–`d9`) で OUT2 から 9 列へ、橙の線で下のブロックの 9 列へ渡し、`g9`–`g14` で Q1 の B (14 列) へ
- Q1 (2SC1815) は平らな面を手前に左から E・C・B (12・13・14 列)。C は下の赤いレール (12 V) へ (`j13`)
- E (12 列) から R<sub>SC</sub> (`h12`–`h16`) で 16 列 (出力) へ、R1 (`i12`–`i22`) で 22 列 (Q2 の B) へ。R2 (`j22`) で GND へ
- Q2 (20〜22 列、E・C・B) の C (21 列) は橙の線 `j21`–`j14` で Q1 の B へ、E (20 列) は青の線で出力の 16 列と負荷 RL (25〜27 列) へ
- 出力の 16 列から上のブロックへ青の線で渡し、`a16`–`a7` で IN2− (7 列) に戻す。CH1 (1+) と 2− は上の 16 列、2+ は Q1 の E (`j12`)
- 上下の赤・青のレールは 29・30 列でつなぐ

ブレッドボードを流れる電流は最大 31 mA と基準・分圧の 15 mA で、ブレッドボードの範囲 (1 穴 200 mA) に収まる。

## 計器の設定

電源は電源装置 (12 V、電流制限 100 mA。この題の回路の電流制限が働かなかったときの保険)。12 V は AD3 の Supplies (±5 V) では作れない。
AD3 は Scope だけを使う。CH1・CH2 とも 1 V/div、0 V を下から 1 目盛 (−4 div)、時間軸 1 s/div、トリガは単発で CH2 の立ち上がり 0.592 V。
RL を 1 kΩ にしてから待たせ、8 秒ほどかけて 0 Ω まで一定の速さで回す。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 負荷を 8 秒で 1 kΩ から 0 Ω へ回す — 電流は 31 mA で折れ返り、短絡で 11 mA
time: 1s/div
trigger: ch2 rising 0.592V at -5div
ch1: {wave: "= 1000 * max(1 - max(t, 0s) / 8s, 0) * min(4.93V / (1000 * max(1 - max(t, 0s) / 8s, 0) + 0.001), 10.66mV / max(1 - 4.159 * max(1 - max(t, 0s) / 8s, 0), 0.001))", range: 1V/div, position: -4div}
ch2: {wave: "= 120 * min(4.93V / (1000 * max(1 - max(t, 0s) / 8s, 0) + 0.001), 10.66mV / max(1 - 4.159 * max(1 - max(t, 0s) / 8s, 0), 0.001))", range: 1V/div, position: -4div}
cursors: [6.73s, 8.2s]
measure: [vmax, vmin]
notes:
  - text ch2 6.73s 3.73V: 31 mA で折れ返る
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/05-power-supplies/scope/17-foldback-current-limit.svg)

図3 は理想 (計算) の画面で、下の LTspice の結果を式で近似して描いた。読み方は次のとおり。

- 0〜6.7 s (RL が 1 kΩ から 160 Ω): CH1 は 4.93 V で平ら。CH2 (= 電流 × 120 Ω) は負荷が軽くなるにつれ上がる
- X1 (6.73 s、RL ≈ 158 Ω): 電流が 31 mA (CH2 3.73 V) に届いて Q2 が入る。ここが V-I の線の折れ返りの角
- X1 から右: 電流は**下がりながら**、出力の電圧も下がる。ふつうの電流制限 (13-2 の電源装置の CC) なら電流は 31 mA のまま平らだが、フォールドバックでは下がる
- X2 (8.2 s、短絡): CH1 は 0 V、CH2 は 1.28 V (= 10.7 mA)。短絡の電流はふだんの上限の約 1/3

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (DIP-8) | LM358 (2 番目の回路を使う) |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| DZ | ツェナーダイオード (0.5 W) | 5.1 V (約 10 mA、損失 約 50 mW) |
| RZ | 抵抗 (1/4 W) | 680 Ω (損失 約 70 mW) |
| RB | 抵抗 (1/4 W) | 4.7 kΩ |
| R<sub>SC</sub> | 抵抗 (**1/2 W**) | 120 Ω (31 mA で 0.12 W。1/4 W の半分を超えるので 1/2 W) |
| R1 | 抵抗 (1/4 W) | 3.9 kΩ |
| R2 | 抵抗 (1/4 W) | 6.8 kΩ |
| RL | 半固定抵抗 (レオスタット接続、0.5 W 前後) | 1 kΩ (最大の損失は 158 Ω のとき 約 0.15 W) |
| — | 電源 | 電源装置 12 V (電流制限 100 mA)。LM358 の出力の上限と Q1 のベースの電圧のため、5 V では動かない |
| — | 計器 | AD3 の Scope (1+ = 出力、2+・2− = R<sub>SC</sub> の両端) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力 (軽い負荷) | 4.93 V | 基準 (ツェナーの 10 mA での電圧) をフォロアが写す |
| 折れ返りの電流 (X1) | 31 mA (RL ≈ 158 Ω) | 上限。出力が保たれる最後の点 |
| 短絡の電流 (X2) | 10.7 mA | 上限の約 1/3 に折れ返る |
| 短絡のときの Q1 の損失 | 約 0.10 W (12 V − 1.06 V) × 10.7 mA | 2SC1815 の最大定格 400 mW に十分の余裕 |
| ふつうの電流制限だったら (31 mA のまま短絡) | 約 0.26 W ((12 V − 3.7 V) × 31 mA、計算値) | フォールドバックで Q1 の熱が 1/2.6 に減る |
| Q1 の損失の最大 | 約 0.15 W (折れ返りの少し手前) | 放熱器は要らない |

- フォールドバックには弱点もある。電球やモータのように、電源を入れた瞬間に大きな電流を取る負荷では、出力が下がったまま上がってこないことがある
  (上限が下がった所で釣り合う)。この回路で RL を 100 Ω にしたまま電源を入れると、出力は 1.9 V ほどで止まる (下の LTspice の V-I の点から)
- R2 を外す (k = 1) と、ふつうの電流制限になる (上限は V<sub>BE</sub> ÷ R<sub>SC</sub> ≈ 6 mA)。k で折れ返りの強さが決まる

## LTspice での確かめ

`sim/17-foldback-limit.cir` で、図1 の負荷を 8 秒で 1 kΩ から 0 Ω へ動かした (負荷は抵抗の値が時間で変わる挙動の電流源)。Q1・Q2 は 5-2 と同じ 2SC1815 の仮定の模型、
DZ も 5-2 と同じ仮定の模型、LM358 は 04-opamps の題と同じ汎用の模型 (出力 High は電源 − 1.5 V の仮定)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力 (軽い負荷) | 4.93 V | 4.929 V | 合う |
| 折れ返りの電流と、そのときの RL | 31 mA・158 Ω | 31.1 mA・158 Ω (6.73 s) | 本文の値は LTspice の読み |
| 式の見積り (V<sub>BE</sub> 0.75 V) | 33 mA・10 mA | 31.1 mA・10.7 mA | 近い (Q2 の V<sub>BE</sub> が電流で 0.75〜0.8 V に動く) |
| 短絡の電流 | 10.7 mA | 10.66 mA | 合う |
| 短絡のときの Q1 の損失 | 約 0.10 W | 97 mW | 合う |
| Q1 の損失の最大 | 約 0.15 W | 147 mW | 合う |
| R<sub>SC</sub> の損失の最大 | 0.12 W | 116 mW | 合う |
| RL 100 Ω のときの出力・電流 | 約 1.9 V | 1.88 V・18.7 mA | 合う |

## 出典

自作。

参考: [Foldback (power supply design) (Wikipedia)](https://en.wikipedia.org/wiki/Foldback_(power_supply_design))、[LM358 のデータシート (TI)](https://www.ti.com/lit/ds/symlink/lm358.pdf)
