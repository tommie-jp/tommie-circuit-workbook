---
book: nanovna
chapter: 6
id: 6-7
title: 水晶ラダーフィルタ
tier: 100
source: 自作
board: PF
device: H4
---

# 6-7 水晶ラダーフィルタ

4-6 で測った水晶は、fs のすぐ近くだけをよく通す、Q が数万の共振器だった。
同じ周波数の水晶を**直列に 3 個**並べ、間を**並列のコンデンサ**でつなぐと、
幅 1 kHz ほどの狭いバンドパスになる。はしご (ラダー) の形なので
**水晶ラダーフィルタ**と呼ぶ。無線機の CW (モールス) 用フィルタに使われる形を、
10 MHz の HC-49 水晶 3 個と 220 pF 2 個で作り、50 Ω の NanoVNA に直につないで測る。

## この実験で確かめる式

水晶の等価回路は 4-6 と同じ代表値 (Cm = 12 fF、Lm = 21.1 mH、Rm = 25 Ω、
Co = 4 pF、fs = 10.002 MHz) とする (**仮定**。実物の値は 4-6 の方法で測る)。

- 並列のコンデンサ C は、隣り合う 2 つの水晶の**結合**の強さを決める。C が
  小さいほど結合が強く帯域が広いが、50 Ω の終端では 3 つの共振が 1 つの
  通過帯域にまとまらず、上に**離れた小山**が残る。C が大きいほど帯域は狭く、
  損失が増える
- 50 Ω で終端したとき、小山が出ずに 1 つの山にまとまる最小の C が
  **220 pF** (E12)。計算で −3 dB の幅 **約 740 Hz**、損失 **約 5.7 dB**
- 損失の大半は水晶の Rm (25 Ω × 3 個) で、50 Ω の終端と同じくらいの大きさ
  だから

| C (両方同じ) | −3 dB の幅 | 通過帯域の損失 | 通過帯域の外の小山 |
| --- | --- | --- | --- |
| 100 pF | 0.84 kHz | 4.1 dB | 10.0036 MHz に山の 5.1 dB 下 |
| 150 pF | 0.64 kHz | 4.5 dB | 10.0031 MHz に山の 4.3 dB 下 |
| **220 pF** | **0.74 kHz** | **5.7 dB** | **なし** (上側に肩が残る) |
| 330 pF | 0.53 kHz | 7.8 dB | なし |
| 470 pF | 0.37 kHz | 9.8 dB | なし |

220 pF の −3 dB の幅が 150 pF より広いのは、上側の肩 (下の見るべき値) が
山から 3 dB 以内に入って幅に数えられるから。肩を除いた山だけの幅は C とともに
狭くなる。

## 回路図

```circuit
title: 図1 水晶 3 個のラダーフィルタ (10 MHz、CW 用の幅)
parts:
  J1: sma b2 mirror CH0
  X1: crystal b3 b5 10M
  C1: capacitor b6 d6 220p
  X2: crystal b7 b9 10M
  C2: capacitor b10 d10 220p
  X3: crystal b11 b13 10M
  J2: sma b15 CH1
  G1: ground c2
  G2: ground d6
  G3: ground d10
  G4: ground c15
wires:
  - J1.1 -- b3
  - b5 -- b6 -- b7
  - b9 -- b10 -- b11
  - b13 -- J2.1
  - J1.2 -- c2
  - J2.2 -- c15
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/07-crystal-ladder.svg)

| 部品 | 値 | メモ |
| --- | --- | --- |
| X1〜X3 | 10 MHz 水晶 (HC-49) | **同じ品番・同じ袋**の物。4-6 の方法で fs を測り、差が 50 Hz 以内の 3 個を選ぶ |
| C1・C2 | 220 pF | セラミック (CH 特性か C0G)。温度で値が動かない物 |

## 実体配線図

部品面から見た図。水晶は i 行に直列に並べ、C1・C2 は下の l 行 (GND) へ落とす。

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard に組む (端面 SMA 2 つ)
parts:
  J1: sma/female-edge a10 09
  X1: crystal/hc49 c10 e10 10M
  C1: capacitor g10 g8 220p
  X2: crystal/hc49 i10 k10 10M
  C2: capacitor m10 m8 220p
  X3: crystal/hc49 o10 q10 10M
  J2: sma/female-edge x10 y9
wires:
  - a10 -- c10
  - e10 -- g10
  - g10 -- i10
  - k10 -- m10
  - m10 -- o10
  - q10 -- x10
  - 09 -- b9 black
  - b9 -- b7 black
  - b7 -- g7 black
  - g7 -- g8 black
  - g7 -- m7 black
  - m7 -- m8 black
  - m7 -- t7 black
  - y9 -- t9 black
  - t9 -- t7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/perfboard/07-crystal-ladder.svg)

- 水晶のケース (金属の缶) は、つなげるなら GND へ。入口と出口の水晶のケースが
  近いと、容量で信号が水晶を飛び越え、阻止帯域が浅くなる

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 10.000 MHz〜10.005 MHz (幅 5 kHz。−3 dB の幅の約 7 倍) |
| 点数 | 201 (25 Hz おき) |
| 校正 | SOLT。**この範囲・この点数で**校正する (1-4) |
| 表示 | S21 の Log Mag |

水晶の実験は狭い掃引が要る (4-6)。見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 10.000M-10.005M 201
title: 図3 3 個の水晶ラダー — −3 dB の幅は 740 Hz、損失 5.7 dB
dut:
  - series C 12f esl 21.1m esr 25 cp 4p
  - shunt C 220p
  - series C 12f esl 21.1m esr 25 cp 4p
  - shunt C 220p
  - series C 12f esl 21.1m esr 25 cp 4p
traces:
  - S21 logmag
markers:
  - 10.00201M
  - 10.00224M
  - 10.00275M
  - 10.0035M
notes:
  - band 10.00201M 10.00275M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/07-crystal-ladder.svg)

## 見るべき値

計算値 (上の等価回路の仮定による)。読み値の表の周波数は 1 kHz の桁に丸めて
出るので、周波数はこの表で読む。図の横軸の中央の目盛 (10.003 MHz) も 10.0025 MHz を丸めたもの。

| マーカー | 周波数 | S21 | 意味 |
| --- | --- | --- | --- |
| 1 | 10.00201 MHz | −8.80 dB | 通過帯域の下の端 (山から −3 dB) |
| 2 | 10.00224 MHz | **−5.74 dB** | 山 |
| 3 | 10.00275 MHz | −8.72 dB | 通過帯域の上の端 |
| 4 | 10.0035 MHz | −36.58 dB | 上の阻止帯域 (山から約 1.3 kHz) |

| 項目 | 値 |
| --- | --- |
| −3 dB の幅 | 約 740 Hz (10.00201〜10.00275 MHz) |
| −20 dB の幅 | 約 1.6 kHz (10.00154〜10.00316 MHz) |
| 下の裾 (10.000 MHz、山から 2.2 kHz 下) | −50.9 dB |
| 上の裾 (10.005 MHz、山から 2.8 kHz 上) | −62.4 dB |

- 通過帯域の中心は水晶 1 個の fs (10.002 MHz) より少し上。並列の C が水晶と
  組んで共振をずらすため
- 山の上側 (10.0027 MHz 付近) に、山より 2.7 dB 低い**肩**が残る。3 つの共振の
  うち 1 つが、50 Ω の終端では十分に広がらないため

分かること:

- **3 個の水晶と 2 個のコンデンサだけで、幅 1 kHz 以下のフィルタ**が作れる。
  LC (6-3) で同じ幅を作るのは、コイルの Q が足りず無理
- 帯域幅と形は並列の C と**終端のインピーダンス**で決まる。50 Ω のままでは
  1 kHz より広くすると小山が離れ、平らな山にもならない。SSB 用の 2.4 kHz で平らに
  するには終端を数百 Ω に上げる (整合の話は 6-21)
- 水晶の fs がそろっていないと、通過帯域が波打つ。**部品を選んでから組む**のが
  水晶フィルタのいちばん大事な手順

## 出典

自作。水晶の等価回路は 4-6 の代表値による。
