---
book: circuits
chapter: 4
id: 4-17
title: コンパレータ IC (LM393、オープンコレクタ)
tier: 200
source: 自作
era: 今
---

# 4-17 コンパレータ IC (LM393、オープンコレクタ)

4-4 と 4-8 は OP アンプ (LM358) を比較器として使った。OP アンプは負帰還で使う前提の部品なので、
出力が飽和から抜けるのが遅く、LM358 では出力が 0 V から 3.5 V まで動くのに 10 µs ほどかかる (スルーレート 0.3 V/µs)。
**比較器専用の IC (コンパレータ)** は帰還を掛けずに使う前提で作られていて、LM393 の応答時間は約 1.3 µs (データシートの代表値)。
もう 1 つの違いが出力の形で、LM393 の出力は **オープンコレクタ** (出力のトランジスタのコレクタだけが出ていて、
GND へ引くことはできるが、+ へ持ち上げることはできない)。High にするのは外付けの**プルアップ抵抗**の役目になる。

プルアップを使う出力には次の性質がある。

- **High の電圧をプルアップの先で選べる**。電源が 5 V でも、プルアップを 3.3 V へつなげば 3.3 V のロジックに渡せる (レベル変換)
- 出力どうしを直結できる (**ワイヤード AND**。どれか 1 つが Low なら Low)。4-18 のウィンドウコンパレータで使う
- 立ち下がりはトランジスタが引くので速いが、**立ち上がりはプルアップ抵抗が配線の容量を充電する速さで決まる**

この題では LM393 の片方で 2.5 V と比べ、出力の立ち上がりが プルアップ抵抗 × 容量 の時定数で遅れ、立ち下がりは速いことをオシロで確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 LM393 で 2.5 V と比べる (出力はオープンコレクタ + プルアップ)
parts:
  VCC: vcc 4,1 5V
  R1: resistor 4,1 4,4 10k
  R2: resistor 4,4 4,6 10k
  GR2: ground 4,6
  W1: square 2,7 2,9 0.5 l=$\mathrm{W1}$
  GW: ground 2,9
  U1: opamp 9,4.38 +up
  Rpu: resistor 12,1 12,4.38 10k
  CL: capacitor 14,4.38 14,6.4 1n
  GCL: ground 14,6.4
  OUT: port 16,4.38 out
wires:
  - 4,1 -- 12,1
  - 4,4 -| U1.+
  - 2,7 -- 6,7
  - 6,7 |- U1.-
  - U1.out -- 12,4.38 -- 14,4.38 -- 16,4.38
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/17-lm393-open-collector.svg)

- U1 は LM393 の片方 (記号は OP アンプと同じ三角で描いた)。電源は 5 V の単電源で、LM393 の入力は GND から 5 V − 1.5 V = 3.5 V までが働く範囲 (25 °C)
- **+ 入力は基準の 2.5 V** (R1・R2、10 kΩ と 10 kΩ の分圧)。− 入力に W1 (2.5 V を中心に ±0.5 V の方形波、1 kHz) を入れる。
  − 入力が 2.5 V を超えると出力のトランジスタが導通して Low、下回ると切れて High
- **Rpu (10 kΩ) が High を作る**。Low のときは Rpu に 5 V / 10 kΩ = 0.5 mA が流れ、LM393 はそれを吸い込む (吸い込める電流は代表値 21 mA)
- **CL (1 nF) は、配線と次につなぐ回路の入力の容量の代わり**に置いた。立ち上がりは τ = Rpu × CL = 10 µs で 5 V へ近づく。
  立ち下がりは LM393 の出力のトランジスタが数 mA 以上で CL を放電するので、1 µs もかからない
- 図の三角は OP アンプと同じだが、出力は「GND へ引くか、手を離すか」の 2 つしか無い。だから**プルアップ抵抗が無いと High にならない**

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (使わない片方は入力を固定する)
board: half
parts:
  AD3:
    type: device
    at: bottom
    label: AD3 (Supplies 5V・W1・Scope)
    pins: [V+, GND, 2+, W1, 1+, 1-, 2-]
  U1: dip8 @ e12 LM393
  R1: resistor g14 g19 10k cap=right
  R2: resistor h14 h9 10k cap=right
  Rpu: resistor g12 g6 10k cap=above
  CL: capacitor i12 i8 1n
wires:
  - AD3.V+ -- +b2 red
  - AD3.GND -- -b3 black
  - AD3.2+ -- j12 green
  - AD3.W1 -- j13 yellow
  - AD3.1+ -- j16 yellow
  - AD3.1- -- -b22 black
  - AD3.2- -- -b23 black
  - +b1 -- +t1 red
  - -b4 -- -t4 black
  - j15 -- -b15 black
  - a12 -- +t12 red
  - a14 -- +t14 red
  - a15 -- -t15 black
  - j19 -- +b19 red
  - j9 -- -b9 black
  - j6 -- +b6 red
  - j8 -- -b8 black
  - i13 -- i16 yellow
notes:
  - text below: 上下とも 赤レール = +5V、青レール = GND (単電源)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/17-lm393-open-collector.svg)

- 5 V の単電源。AD3 は下に置き、V+ は下の赤レール、GND は下の青レールへ。上のレールには 1 列の赤と 4 列の黒で渡す。電流は 1 mA ほどで、AD3 の 5 V の約 50 mA の範囲に収まる
- LM393 は 12 列〜15 列。**下ブロック側の回路 (PIN 1〜3) を使う**。PIN 8 (12 列) は `a12 → +t12` で +5 V、PIN 4 (15 列) は `j15 → -b15` で GND
- **使わない上ブロック側の回路 (PIN 5〜7)** は、+ 入力 (PIN 5、15 列) を GND、− 入力 (PIN 6、14 列) を +5 V に固定する。出力は Low に落ち着き、
  入力が浮いて出力が勝手に動く (発振して電源を揺らす) ことがない。出力 (PIN 7) は何にもつながないので電流は流れない
- **基準の 2.5 V**: R1 (g 段) は + 入力 (PIN 3、14 列) から 19 列へ、19 列は `j19 → +b19` で +5 V。R2 (h 段) は 14 列から 9 列へ、9 列は `j9 → -b9` で GND
- W1 (黄) は − 入力 (PIN 2、13 列) の `j13`。黄の線 `i13 → i16` で 16 列へ出し、Scope の 1+ を挿す
- **出力 (PIN 1、12 列)**: Rpu (g 段) で 6 列へ、6 列は `j6 → +b6` で +5 V。CL (i 段) は 12 列と 8 列の間で、8 列は `j8 → -b8` で GND。Scope の 2+ (緑) は `j12`

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。数 µs〜数十 µs の立ち上がりと立ち下がりを読む題で、10 MHz よりずっと遅いから。
W1 は 1 kHz の方形波 (2.0 V〜3.0 V)。CH1 で − 入力、CH2 で出力を見る。入力が下がる瞬間 (出力が上がる瞬間) にトリガを掛けて拡大する。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Square、1 kHz、振幅 0.5 V、オフセット 2.5 V (2.0 V〜3.0 V) |
| Scope CH1 (− 入力、16 列) | DC、1 V/div |
| Scope CH2 (出力、12 列) | DC、1 V/div |
| Time | 5 µs/div。トリガの点を左から 1 目盛に置く |
| Trigger | CH1、立ち下がり、2.5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力が 2.5 V を下回ると、出力 (CH2) は Rpu × CL = 10 µs でゆっくり上がる
time: 5us/div
trigger: ch1 falling 2.5V at -4div
ch1: {wave: = 3V - 1V * step(t), range: 1V/div, position: -3div}
ch2: {wave: = 5V * step(t - 1.3us) * (1 - exp(-(t - 1.3us) / 10us)), range: 1V/div, position: -3div}
cursors: [2.35us, 24.3us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/17-lm393-open-collector.svg)

図3 は t = 0 で入力が 3.0 V から 2.0 V へ下がった所。出力は LM393 の応答時間 (約 1.3 µs) の後に上がり始め、時定数 10 µs の指数の曲線で 5 V に近づく。
カーソル X1 (2.35 µs) と X2 (24.3 µs) は出力が 0.5 V (10 %) と 4.5 V (90 %) を通る所で、間が立ち上がり時間 2.2 × τ = 22 µs。
同じ設定で立ち上がり (入力の立ち上がり) にトリガを掛け直すと、出力は 1 目盛の中で 5 V から 0 V へ落ち、立ち下がりがずっと速いことが分かる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | コンパレータ (2 回路入りの片方。もう片方は入力を固定) | LM393 |
| R1, R2 | 抵抗 (基準の 2.5 V) | 各 10 kΩ |
| Rpu | 抵抗 (プルアップ) | 10 kΩ (1 kΩ に替えて比べる) |
| CL | セラミックコンデンサ (配線と次の入力の容量の代わり) | 1 nF |
| — | 信号源 | 1 kHz の方形波 (2.0 V〜3.0 V) |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (− 入力と出力)、テスター |

## 見るべき値

表の値は計算値と LTspice の読み (応答時間はデータシートの代表値 1.3 µs と**仮定**)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| + 入力 (基準) | 2.50 V | 10 kΩ と 10 kΩ の分圧 |
| 出力の Low | 約 0.01 V (Rpu 10 kΩ) | 0.5 mA しか吸わないので、トランジスタの電圧はごく小さい |
| 出力の High | 5.0 V | プルアップの先の電圧そのもの |
| 立ち上がり (10 %→90 %、Rpu 10 kΩ) | 約 22 µs | 2.2 × Rpu × CL |
| 立ち下がり (90 %→10 %) | 1 µs 以下 | トランジスタが CL を直に放電する |
| 入力が下がってから出力が 2.5 V に届くまで | 約 8 µs | 応答時間 1.3 µs + 0.69 × τ |
| Rpu を 1 kΩ にした立ち上がり | 約 2.2 µs | 10 倍速くなるが、Low の間 5 mA を吸い、Low の電圧も 0.13 V に上がる |
| プルアップの先を 3.3 V に替えた High | 3.3 V | 5 V の回路から 3.3 V のマイコンへ渡せる (レベル変換) |

プルアップ抵抗は、速さ (小さい抵抗) と消費電流 (大きい抵抗) の兼ね合いで決める。マイコンの入力 1 つなら 4.7 kΩ〜10 kΩ がよく使われる。

## LTspice での確かめ

`sim/17-lm393-open-collector.cir` で図1 を過渡解析で走らせ、Rpu を 10 kΩ と 1 kΩ の 2 通りにした。
LM393 は振る舞いの模型 (入力の差で 0 / 1 を決め、応答時間 約 1.3 µs、出力は 27 Ω で GND へ落とすオープンコレクタ。データシートの代表値から作った**仮定**で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力の Low (Rpu 10 kΩ / 1 kΩ) | 約 0.01 V / 0.13 V | 0.013 V / 0.131 V | 合う |
| 出力の High | 5.0 V | 5.000 V | 合う |
| 立ち上がり (Rpu 10 kΩ / 1 kΩ) | 約 22 µs / 2.2 µs | 22.0 µs / 2.20 µs | 合う |
| 立ち下がり | 1 µs 以下 | 0.07 µs | 合う (模型の 27 Ω で決まる。実物は吸い込める電流で決まり、もう少し遅い) |
| 出力が 2.5 V に届くまで (Rpu 10 kΩ) | 約 8 µs | 8.25 µs | 合う |
| Low の間に吸う電流 (Rpu 10 kΩ / 1 kΩ) | 0.5 mA / 5 mA | 0.50 mA / 4.87 mA | 合う |

## 出典

自作。
参考: [TI LM393 のデータシート](https://www.ti.com/lit/ds/symlink/lm393.pdf)、[Open collector (Wikipedia)](https://en.wikipedia.org/wiki/Open_collector)、[コンパレータ (Wikipedia)](https://ja.wikipedia.org/wiki/コンパレータ)
