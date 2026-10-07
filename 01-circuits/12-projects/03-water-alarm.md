---
book: circuits
chapter: 12
id: 12-3
title: 水漏れ・水位アラーム
tier: 100
source: 自作
board: PF
---

# 12-3 水漏れ・水位アラーム

2-4 のダーリントン (トランジスタ 2 個を重ねて電流の増幅を掛け算にする接続。指で触れると点く) は、
指の皮膚を通るわずかな電流をベース電流にしていた。同じ仕組みを、指の代わりに水に使うと、
水漏れや水位のアラームになる。8-9 の水位センサーと同じく、2 本の電極の間を水がつなぐと
電流が流れる。水は指よりも電気を通しやすいことが多く (水道水で目安 数kΩ〜数十kΩ)、
ダーリントンなら十分な電流を作れる。

> [!NOTE]
> 電極に直流を流し続けると、電気分解で電極が少しずつ傷む (腐食)。
> この題は仕組みを確かめる実験用の割り切りとして直流のままにするが、
> 長期間つけっぱなしにする実用品では、555 などで電極を交流的に駆動する
> (時々しか電流を流さない) 設計にするとよい。

## 回路図

```circuit
title: 図1 水で橋渡しされるとダーリントンが導通しブザーが鳴る
parts:
  VCC: vcc 2,1 5V
  Rprobe: resistor 2,1 2,4 10k
  P1: port 2,4
  Rwater: resistor-var 2,4 2,7
  P2: port 2,7
  Rb: resistor 4,7 4,9 1M
  GRb: ground 4,9
  Q1: npn 7,7
  Q2: npn 9,9
  GQ2: ground 9,10
  Buzzer: buzzer 11,1 11,3 l=$\mathrm{Buzzer}$
  RLED: resistor 13,1 13,3 330 l=$R_\mathrm{LED}$
  DLED: led 13,3 13,5 red l=$D_\mathrm{LED}$
wires:
  - 2,1 -- 13,1
  - 2,7 -- 4,7
  - 4,7 -- Q1.B
  - Q1.E |- Q2.B
  - Q1.C -- 7,5
  - Q2.C -- 9,5
  - 7,5 -- 9,5
  - 9,5 -- 11,5
  - 11,5 -- 13,5
  - 11,3 -- 11,5
  - Q2.E -- 9,10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/circuit/03-water-alarm.svg)

- P1・P2 が電極 (むき出しの導線の先や、金属のねじ)。乾いている間は
  抵抗が無限大 (未接続) で、Q1 のベースは Rb (1MΩ) で GND に引かれて
  OFF。水が P1・P2 を橋渡しすると、水の抵抗 (図1 では Rwater と表す。
  水道水で目安 数kΩ〜数十kΩ、蒸留水はもっと高い) を通して +5V からベースへ
  電流が流れ込む
- Q1・Q2 のダーリントン (2-4 と同じ考え方) で電流を 2 段増幅する。
  全体の電流増幅率 hFE は 2 石の掛け算 (目安 hFE = 200 なら 200 × 200 = 40000) になるので、
  水の高い抵抗を通した弱い電流でもコレクタには十分な電流が流れる
- Rprobe (10kΩ) は電極を流れる電流の上限を決め、電極の腐食と回路の
  過電流を防ぐ。Rprobe は +5V から Q1 のベースへの道に直列に入っているので、
  ベースを守る直列抵抗も兼ねる (電極どうしが金属で直接触れても、
  ベース電流は 5V / 10kΩ = 0.5mA 以下)。ベースに別の直列抵抗は要らない
- Rb (1MΩ) はベースと GND の間のプルダウン。乾いている間、電極の先は
  どこにもつながらず、ベースが浮く。合成 hFE が数万のダーリントンでは、
  浮いたベースに電極の長い線が拾う雑音や漏れ電流が入るだけで導通して
  しまうので、Rb で 0V に引いておく。1MΩ と大きいので、濡れたときの
  ベース電流はほとんど横取りしない。乾いた状態と濡れた状態の計算値:

| 状態 | ベース電圧 (目安) | ダーリントン |
| --- | --- | --- |
| 乾いている (Rwater = ∞) | 0V (Rb で GND) | OFF |
| 水道水で橋渡し (Rwater ≈ 20kΩ と仮定) | 約 **1.2V** (VBE 2 段分で頭打ち)。ベース電流 ≈ (5V−1.2V)/(10kΩ+20kΩ) ≈ **0.13mA** (Rb へ逃げるのは 1.2µA ほど) | ON (ダーリントンは飽和しきらず、V<sub>CE</sub> は 0.8V 前後で止まる) |

- Q1 と Q2 のコレクタはつないである。この点と +5V の間に、Buzzer (自励式、電圧を
  かけるだけで鳴るアクティブブザー) と、RLED・DLED (目印の LED) を並べてつなぐ。
  ダーリントンが ON になると両方が同時に働く

## ユニバーサル基板に組む

水回りに置いたままにする作品なので、ブレッドボードではなくユニバーサル基板に組む。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboardに組む (部品面から見た図。黄色の丸は AD3 を挟む所)
points:
  PWR: u17
  GND: a5
parts:
  P2:
    type: device
    at: b22
    label: Probe2
    pins: [W]
  P1:
    type: device
    at: f22
    label: Probe1
    pins: [W]
  Rprobe: resistor j17 f17 10k
  Rb: resistor b10 b5 1M
  Q1: transistor e10 d10 c10 2SC1815
  Q2: transistor i10 h10 g10 2SC1815
  Buzzer: buzzer n15 n12
  RLED: resistor r17 r15 330
  DLED: led r14 r12 red
wires:
  - P1.W -- f17
  - j17 -- n17 red
  - n17 -- r17 red
  - r17 -- PWR red
  - P2.W -- b10
  - b10 -- c10
  - e10 -- g10
  - d10 -- d12
  - h10 -- h12
  - d12 -- h12
  - h12 -- n12
  - n12 -- r12
  - n17 -- n15 red
  - r15 -- r14
  - i10 -- i5 black
  - GND -- b5 black
  - b5 -- i5 black
notes:
  - mark u17 yellow
  - mark a5 yellow
  - mark c10 yellow
  - mark n12 yellow
  - mark i5 yellow
  - text u17 red large bold right: V+
  - text b4 red large bold center: GND
  - text c11 red large bold center: 1+
  - text n11 red large bold center: 2+
  - text i4 red large bold center: 1-/2-
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/perfboard/03-water-alarm.svg)

- 2SC1815 は E-C-B の順 (東芝の実物の並び)。Q1 (e10=E, d10=C, c10=B)・
  Q2 (i10=E, h10=C, g10=B) と、どちらも左右を返して (左から B・C・E) 10 行に揃えて置く。
  こうするとベースが左 (電極の側)、エミッタが右 (次の段の側) に来る
- 配線は縦と横だけで、交差は無い。上の 17 行が PWR、下の 5 行が GND、
  その間の 12 行が Q1・Q2 のコレクタをまとめた線
- 5V と計器は Analog Discovery 3 (AD3) から取る。**AD3 は測るときだけ挟む一時的な接続で、基板には配線しない**。
  図では AD3 の箱と線を描かず、AD3 を挟む穴を黄色の丸で囲み、赤の大きな太字で名前を書いた。
  V+ (Supplies の +5V) は PWR の u17、GND は GND の a5、Scope の 1+ は Q1 のベース (c10)、2+ は Q1・Q2 のコレクタをまとめた
  12 行 (n12、Buzzer の下のピンと同じ穴)、1−・2− は GND の i5 を挟む。
  電流は、Buzzer (自励式のアクティブブザー。目安 30mA 前後) と DLED の約 6.7mA を合わせて約 37mA で、AD3 の各レール約 50mA
  (USB 給電で 250mW) の内側に収まる。使うブザーの電流がもっと大きいときは、別の 5V 電源 (USB アダプタ) に替える
- ユニバーサル基板を流れる電流は約 37mA で、perfboard の範囲 (1 本の線・ランドごとに定常 500mA、ユニバーサル基板全体 2A) に収まる
- 水に触れる電極 (P1・P2) に Scope をつながない。Scope の入力は GND とつながっているので、つなぐ先は電極の先ではなく、
  基板上のベース (c10) とコレクタ (h12) にする。電極に GND を引き込むと、水を通した直流の電流が増え、腐食が早まる
- ユニバーサル基板の外の電極 P1 (`-f16`) は Rprobe の左端 (f17) へ下ろし、Rprobe の右端 (j17) から
  17 行を PWR へ。もう一方の電極 P2 (`-b16`) は B 列をまっすぐ下りて Rb の上端 (b10) へ、
  そこから隣の Q1 のベース (c10) へ。Rb の下端 (b5) は GND (図1 と同じプルダウン)。
  電極 2 本は水に浸すまでつながっていないのが正しい状態
- Q1 のエミッタ (e10) を Q2 のベース (g10) へ。Q1・Q2 のコレクタ (d10・h10) は
  12 行へ上げて共通ネットにし、その先に Buzzer の下のピン (n12) と DLED の K (r12) を
  つなぐ。Buzzer の上のピン (n15) と RLED の上端 (r17) は PWR の 17 行へ
  (ダーリントンは GND 側のスイッチとして働く)。Q2 のエミッタ (i10) は I 列を下りて GND の 5 行へ

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1・Q2 | NPN トランジスタ | 2SC1815 |
| Rprobe | 抵抗 (電極の電流制限) | 10kΩ |
| Rb | 抵抗 (ベースのプルダウン) | 1MΩ |
| RLED | 抵抗 (LED の電流制限) | 330Ω |
| DLED | LED | 赤色 5mm |
| Buzzer | アクティブブザー | 5V (目安 30mA 前後) |
| P1・P2 | 電極 | むき出しの導線の先か金属のねじ |
| — | 電源・計器 | Analog Discovery 3 の Supplies の V+ (5V) と Scope (1+ = Q1 のベース、2+ = コレクタ、1−・2− = GND) |

## 計器の設定

計器は AD3 の Scope。**電極が水につかった瞬間に、Q1 のベースが 0V から約 1.2V に上がり、Q2 のコレクタが 5V から約 0.8V に落ちる**
(ブザーが鳴り始める) のを、1 回きりの変化として捕まえる。水につける・拭くは 1 回きりなので、トリガを Single にする。

| 項目 | 値 |
| --- | --- |
| 電源 | AD3 の Supplies の V+ (5V) |
| CH1 (1+) | Q1 のベース (i3)。1V/div、0V を下から 3 目盛 |
| CH2 (2+) | コレクタの 12 行 (n12)。CH1 と同じ 1V/div・同じ 0V の位置 |
| 1−・2− | GND |
| 時間レンジ | 100ms/div (1 画面 1 秒) |
| トリガ | CH2 の立ち下がり、2.5V (5V の中央)、Single。トリガの点を左から 2 目盛に置く |
| Measurements | Maximum・Minimum |
| カーソル | X1 を水につかる前 (−200ms)、X2 をつかったあと (500ms) に置く |

```scope
title: 図3 電極が水につかると、ベース (CH1) が上がりコレクタ (CH2) が落ちる
time: 100ms/div
trigger: ch2 falling 2.5V at -3div
ch1: {wave: = 1.2V * step(t) | rc 20ms, range: 1V/div, position: -3div}
ch2: {wave: = 5V - 4.2V * step(t) | rc 20ms, range: 1V/div, position: -3div}
cursors: [-200ms, 500ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/12-projects/scope/03-water-alarm.svg)

- 図3 の X1 (水につかる前) は CH1 が 0V、CH2 が 5V。X2 (つかったあと) は CH1 が約 1.2V (V<sub>BE</sub> 2 段分)、CH2 が約 0.8V (ダーリントンの V<sub>CE</sub>)。
  上の表 (ベース電圧・V<sub>CE</sub>) の計算値と同じ値で、実測ではない
- 図は理想の形。水がつかる速さは実際にはまちまちで、立ち上がりは図より遅いことが多い (時定数 20ms でなめらかにした)。
  水の抵抗が大きい (蒸留水など) と、ベースは 1.2V まで上がらず、コレクタも落ちきらない
- AD3 の Scope の入力は 1MΩ。ベースの Rb (1MΩ) と並列になるが、水を通す電流 (約 0.13mA) の経路にはほとんど影響しない

## 見るべき値

計算値。VCC = 5V (AD3 の V+)。電圧はテスターの直流電圧レンジで GND との間を測る。

| 確かめること | 期待する値 |
| --- | --- |
| 乾いた状態 | ブザー鳴らず、LED 消灯 |
| 電極を水道水に浸す (両方同時に) | ブザーが鳴り、LED 点灯 |
| 鳴っている間のコレクタ (Q2 の C) | 約 0.8V (ダーリントンの V<sub>CE</sub>)。ブザーには約 4.2V (5V − 0.8V) がかかる |
| 鳴っている間の DLED の電流 | 約 6.7mA ((5V − 0.8V − 2.0V) / 330Ω、計算値)。RLED の両端の電圧 ÷ 330Ω で確かめる |
| 電極を布で拭いて乾かす | 数秒以内に鳴りやむ (水の抵抗が無限大に戻る) |
| 電極の間隔を広げる | 水の抵抗が増え、鳴るまでの反応がやや鈍くなる |

水位アラームとして使うときは、タンクの決めた高さに P1・P2 を固定する。
水漏れ検知として使うときは、床に平らな電極 (金属テープなど) を敷く。

## 出典

自作。2-4 のダーリントン (指で触れて点く) と同じ考え方を水に応用した。
