---
book: analog-discovery
chapter: 8
id: 8-9
title: デカップリングの置き場所 (近い / 遠い)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Network Analyzer)
board: BB
---

# 8-9 デカップリングの置き場所 (近い / 遠い)

デカップリングのコンデンサ (パスコン) は「IC の電源ピンのすぐ近くに置く」と言われる。
同じ 100 nF でも、置き場所が IC から離れると、間のレールとジャンパのインダクタンス
(8-3・8-6) がコンデンサと直列に入り、高い周波数で効かなくなるからだ。
ここでは IC の電源ピンが来る列 (VCC の点) から見た**電源のインピーダンス**を、
コンデンサを近くに置いたときと遠くに置いたときで比べる。

IC の消費電流の変化は、この点に電流を出し入れすることと同じ。そこで IC の代わりに
W1 から 100 Ω (オーム) を通して小さな交流の電流を入れ、VCC の点に出る電圧を CH2 で読む。
電圧が小さいほど、電源のインピーダンスが低い (よく効いている) ことになる。
測るあいだは Supplies を切り、V+ の線は抜いておく (電源の出力のインピーダンスを混ぜないため)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 VCC の点に電流を入れ、近い C2 と遠い C1 で電圧を比べる
parts:
  W1: sine 2,3 2,6 l=$\mathrm{W1}$
  M1: voltmeter 4,3 4,6 l=$\mathrm{CH1}$
  Rinj: resistor 5,3 8,3 100 l=$\mathrm{R_{inj}}$
  C2: capacitor 9,3 9,6 100n
  M2: voltmeter 12,3 12,6 l=$\mathrm{CH2}$
  Lpath: inductor 13,3 16,3 100n l=$\mathrm{L_{path}}$
  C1: capacitor 16,3 16,6 100n
  G1: ground 9,6
wires:
  - 2,3 -- 4,3
  - 4,3 -- 5,3
  - 8,3 -- 9,3
  - 9,3 -- 12,3
  - 12,3 -- 13,3
  - 2,6 -- 4,6
  - 4,6 -- 9,6
  - 9,6 -- 12,6
  - 12,6 -- 16,6
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/circuit/09-decoupling-placement.svg)

- W1 は AD3 の Wavegen、CH1・CH2 は Scope の 2 つの入力 (CH1 は 1+/1−、CH2 は 2+/2−)
- C2 の上の節点が IC の VCC の点 (電源ピンの列)、下が IC の GND の点。CH2 はこの 2 点を挟む
- C2 は**近い**置き場所 (VCC と GND の列に直に挿す)、C1 は**遠い**置き場所 (電源の入口のレールの端)。
  **測るときはどちらか 1 個だけを挿す**
- L<sub>path</sub> は部品ではない。C1 から VCC の点までのレール (+ と − の往復) とジャンパの
  等価インダクタンスで、8-3 の経験式で約 100 nH と見積もった (仮定。下の「見るべき値」)
- コンデンサ自身のリードと接点のインダクタンス (ESL) 約 5 nH と抵抗分 (ESR) 50 mΩ は図に描かず、計算に入れる (仮定)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 近い C2 (20・22 列) と遠い C1 (2・4 列)。どちらか 1 個だけ挿す
board: half
parts:
  C1: capacitor/ceramic c2 c4 100n
  Rinj: resistor c15 c20 100
  C2: capacitor/ceramic e20 e22 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (V+ は測るあいだ抜く)
    pins: [1-, W1, 1+, 2+, 2-, GND]
wires:
  - a2 -- +t2 red
  - a4 -- -t4 black
  - a20 -- +t20 red
  - a22 -- -t22 black
  - AD.1- -- -t10 black
  - AD.W1 -- a15 yellow [h-10]
  - AD.1+ -- b15 orange [h10]
  - AD.2+ -- b20 white
  - AD.2- -- b22 gray [h-10]
  - AD.GND -- c22 black [h10]
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/breadboard/09-decoupling-placement.svg)

- 20 列が VCC の点、22 列が GND の点。実際の回路なら、ここに IC の電源ピン (74HC04 なら PIN 14) と GND のピン (PIN 7) が来る。
  この題では IC は挿さない
- 2 列と 4 列は電源の入口 (レールの左端)。C1 をここに挿すと、C1 から VCC の点まで、正のレール 18 穴・GND のレール 18 穴と、
  レールへ下りるジャンパ 4 本を通る
- AD.GND と 2− はどちらも 22 列 (GND の点) に挿す。W1 の電流はこの点から AD に戻るので、
  CH2 には VCC の点と GND の点の間の電圧だけが出る (8-6 で見たレールの電位差を混ぜない)

## 計器の設定

計器は Analog Discovery 3 の Network (Wavegen と Scope の組)。CH1 を基準にした比で読むので、W1 の振幅の誤差は消える。

| 計器 | 設定 |
| --- | --- |
| Supplies | **切る** (V+ の線を抜く) |
| Network | 掃引 100 kHz〜10 MHz、点数 101、W1 の振幅 1 V、Reference = CH1、CH2 の Range は 50 mV/div (小さい電圧を読むため) |
| Scope | 5 MHz の 1 点を、CH1 = W1、CH2 = VCC の点で見る |
| 手順 | C2 だけ挿して掃引 → C2 を抜いて C1 を挿し、もう一度掃引 |

10 MHz は AD3 の 2×15 ヘッダ直の帯域 (9 MHz @ −3 dB) を超えるので、**BNC アダプタ**を付ける
(8-5・8-7 と同じ)。CH1 と CH2 の比を読むので、2 つのチャンネルの帯域がそろう限り影響は小さい (目安)。
W1 の電流は 1 V / 100 Ω = 10 mA が上限 (低い周波数でコンデンサのインピーダンスが大きいときでもこれより小さい)。

読んだ比 H = V<sub>CH2</sub> / V<sub>CH1</sub> から、VCC の点のインピーダンスは |Z| ≒ 100 Ω × |H / (1 − H)|。
H が小さいうちは |Z| ≒ 100 Ω × |H| で、−40 dB が 1 Ω、−60 dB が 0.1 Ω にあたる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 遠い C1 の 5 MHz — VCC の点に 29.8 mV、CH1 より 87° 進む
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: sine 5MHz 1V, range: 500mV/div}
ch2: {wave: sine 5MHz 29.8mV phase 87.3deg, range: 10mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/scope/09-decoupling-placement.svg)

CH2 は CH1 の 1/30 ほどしか振れないので、V/div を別にした。近い C2 なら同じ 5 MHz で 1.69 mV (図3 の 1/18) しか出ない。

## 部品

| 部品 | 値・型 | メモ |
| --- | --- | --- |
| C1・C2 | 100 nF (104)・50 V、X7R、リード付き積層セラミック | 同じ品を 2 個。測るときはどちらか 1 個だけ挿す |
| R<sub>inj</sub> | 100 Ω、1/4 W | 電流を決める抵抗。電流は 10 mA まで、電力は 5 mW まで |
| ジャンパ | 4 本 (レールへ下りる線) | 長さは 1 cm ほど |
| 電源 | 使わない (Supplies は切る) | インピーダンスの測定に電源の出力を混ぜない |

## 見るべき値

計算値。コンデンサは 100 nF に ESR 50 mΩ・ESL 5 nH (リードと接点、仮定) を直列にした模型。
遠い置き場所の L<sub>path</sub> は 8-3 の式 L (nH) = 0.2 × l × (ln(2l / 0.64) − 0.75) (l は mm) で、
レール 18 穴 (45.7 mm) が 38.5 nH、これが + と − の 2 本で 77 nH、レールへ下りる 1 cm のジャンパ 4 本が 21.5 nH、合わせて約 100 nH
(**仮定**。往きと戻りが並んで打ち消し合う分を無視した上限の目安)。

| 周波数 | 近い C2 の \|Z\| | 近い C2 の H | 遠い C1 の \|Z\| | 遠い C1 の H |
| --- | --- | --- | --- | --- |
| 100 kHz | 15.9 Ω | −16.1 dB | 15.9 Ω | −16.1 dB |
| 1 MHz | 1.56 Ω | −36.1 dB | 0.93 Ω | −40.6 dB |
| 5 MHz | 0.169 Ω | −55.5 dB | 2.98 Ω | −30.5 dB |
| 10 MHz | 0.163 Ω | −55.8 dB | **6.44 Ω** | **−23.8 dB** |

- 自己共振 (直列の L と C が打ち消し合う周波数) は、近い C2 が 1/(2π (パイ) √(5 nH × 100 nF)) = 7.12 MHz、
  遠い C1 が 1/(2π√(105 nH × 100 nF)) = 1.55 MHz。**遠いと自己共振が 1/4.6 の周波数に下がる**。
  自己共振の所の \|Z\| は ESR の 50 mΩ だけになる (図4 の谷)
- 自己共振より上では、コンデンサは**コイルとして振る舞う** (図3 の CH2 が 90° 近く進むのはそのため)。
  10 MHz で遠い C1 の 6.44 Ω は、近い C2 の 0.163 Ω の約 40 倍
- 1 MHz だけを見ると遠い C1 のほうが低い (0.93 Ω)。自己共振の近くで L が C を打ち消すためで、
  「遠いほうが常に悪い」のではなく、**効く周波数の範囲が狭くなる**

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図4 遠い C1 は 1.55 MHz で底を打ち、10 MHz では近い C2 の約 40 倍
x: 周波数 Hz log 100k..10M
y: インピーダンス Ω log 0.01..100
lines:
  近い C2 Ω: sqrt(0.05^2+(2*pi*x*5n-1/(2*pi*x*100n))^2)
  遠い C1 Ω: sqrt(0.05^2+(2*pi*x*105n-1/(2*pi*x*100n))^2)
notes:
  - mark 1.55M
  - mark 7.12M
  - mark 10M
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/08-breadboard-limits/graph/09-decoupling-placement.svg)

IC が実際に電流を切り替えると、この差がそのまま電源の揺れになる。74HC の出力が
20 mA を 5 ns で切り替えるとすると (目安)、電流の傾きは 4 × 10⁶ A/s で、
遠い C1 では 105 nH × 4 × 10⁶ A/s ≒ 0.42 V、近い C2 では 5 nH × 4 × 10⁶ A/s = 20 mV だけ VCC が瞬間に沈む (算術)。
5 V の 74HC にとって 0.42 V の沈みは、隣のゲートの入力のしきい値を揺らすのに十分な大きさだ。

**パスコンは IC の電源ピンと GND のピンの列に直に挿す。** 1 個で足りないときは、
近い所に 100 nF、電源の入口に 10 µF (マイクロファラド) の電解というように、効く周波数の違う物を
置き場所で分ける (5-10 MHz 帯は近い 100 nF、低い周波数は入口の大きな容量)。

## LTspice での確かめ

`sim/09-decoupling-placement.cir` で、W1 → R<sub>inj</sub> 100 Ω → VCC の点に、近い C2 (100 nF・ESR 50 mΩ・ESL 5 nH) か
遠い C1 (同じ物 + L<sub>path</sub> 100 nH) の片方をつないで交流解析した (寄生は本文の仮定)。

| 条件 | 本文の数字 (H) | LTspice | 判定 |
| --- | --- | --- | --- |
| 近い、100 kHz / 1 MHz | 0.157 / 0.0156 | 0.1571 / 0.01560 | 合う |
| 近い、5 MHz / 10 MHz | 0.00169 / 0.00163 | 0.001693 / 0.001634 | 合う |
| 遠い、1 MHz | 0.00933 | 0.009328 | 合う |
| 遠い、5 MHz | 0.0298、+87.3° | 0.02978、+87.27° | 合う |
| 遠い、10 MHz | 0.0642 | 0.06422 | 合う |

0.42 V と 20 mV の沈みは L × di/dt の算術で、LTspice では解いていない。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Network Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-network-analyzer)。
ジャンパとレールのインダクタンスの経験式は 8-3 と同じもの。
