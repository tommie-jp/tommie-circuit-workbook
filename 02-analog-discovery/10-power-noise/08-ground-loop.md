---
book: analog-discovery
chapter: 10
id: 10-8
title: グラウンドループ
tier: 200
source: 自作 (計器の操作は Digilent の Using the Oscilloscope)
board: BB
---

# 10-8 グラウンドループ

GND は「電圧 0 の点」として描くが、実物の GND の線には抵抗がある。大きな電流 (モータ・LED・スイッチング電源) の帰りと、小さな信号 (センサー) の帰りが
同じ GND の線を通ると、電流 × 線の抵抗の電圧がセンサーの信号に足される。これを**共通インピーダンス結合**という。
GND の線を 2 本に増やしてループにしても、電流が 2 本に分かれるだけで、足される電圧は半分にしかならない。
直すには、大きな電流の帰りをセンサーの GND の線から外す (**一点接地**)。

この題では、GND の線の抵抗を 1 Ω (オーム) の抵抗 RG1・RG2 で大げさに作り (実物のジャンパ線は 0.05 Ω ほどの目安)、
2N7000 で 1 kHz に開け閉めする 22 mA の負荷の帰りを通す。センサーは 104 mV を出す分圧 (R2・R3) で代わりにし、
AD3 の **Scope** で、AD3 の GND から測る (CH1) のと、センサーの GND から差動で測る (CH2) のを比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 負荷の帰りの電流が、センサーの GND の線 (RG1・RG2) を通る
parts:
  VP: vsource 2,3 2,7 5
  G1: ground 2,9
  W1: square 4,4 4,9 l=$\mathrm{W1}$
  R1: resistor 6,1 6,3 220
  Q1: nmos 6,4 2N7000
  R2: resistor 9,1 9,4 47k
  R3: resistor 9,4 9,6 1k
  RG1: resistor 8,6 8,9 1
  RG2: resistor 10,6 10,9 1
  M2: voltmeter 11,4 11,6 l=$\mathrm{CH2}$
  M1: voltmeter 13,4 13,9 l=$\mathrm{CH1}$
wires:
  - 2,1 -- 2,3
  - 2,7 -- 2,9
  - 2,1 -- 6,1 -- 9,1
  - 6,3 -- Q1.D
  - Q1.G -- 4,4
  - Q1.S -- 6,6
  - 6,6 -- 8,6 -- 9,6 -- 10,6 -- 11,6
  - 9,4 -- 11,4 -- 13,4
  - 2,9 -- 4,9 -- 8,9 -- 10,9 -- 13,9
notes:
  - text 7,5.6: B
  - text 6,9.4: A
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/circuit/08-ground-loop.svg)

- A は AD3 の GND (計器と電源の基準)、B はセンサーの GND。A と B の間の RG1・RG2 (1 Ω) が GND の線
- V<sub>P</sub> は AD3 の V+ (5 V)。R1 (220 Ω) が負荷で、Q1 (2N7000) を W1 (0〜5 V の方形波、1 kHz) で開け閉めする。入ると 22 mA が流れ、Q1 の S から B を通って A へ帰る
- R2 (47 kΩ) と R3 (1 kΩ) がセンサーの代わり。出力は B から見て 5 V × 1 / 48 ≒ 104 mV
- CH1 は A から見たセンサーの出力 (1− を A)、CH2 は B から見た出力 (2− を B)。AD3 の Scope は差動入力なので、2− をどこに当ててもよい
- 比べる組: (1) RG2 を抜く (GND の線が 1 本)、(2) 図1 のまま (2 本のループ)、(3) Q1 の S の線を B から外して A へ直に戻し、RG1 を抜く (一点接地。Q1 の帰りは RG2 を通らない)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上の青レールが A (AD3 の GND)、下の青レールが B (センサーの GND)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・W1・1−)
    pins: [V+, GND, W1, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (1+・2+・2−)
    pins: [2+, 1+, 2-]
  Q1: transistor c10 c11 c12 2N7000
  R1: resistor b12 b15 220
  R2: resistor g14 g18 47k
  R3: resistor h18 h21 1k
  RG1: resistor c23 h23 1
  RG2: resistor c27 h27 1
wires:
  - AD.V+ -- +t3 red
  - AD.W1 -- a11 green
  - AD.GND -- -t6 black
  - AD.1- -- -t20 black
  - +t15 -- a15 red
  - e10 -- f10 blue
  - j10 -- -b10 blue
  - +t2 -- +b2 red
  - j14 -- +b14 red
  - j21 -- -b21 blue
  - a23 -- -t23 black
  - j23 -- -b23 blue
  - a27 -- -t27 black
  - j27 -- -b27 blue
  - AD1.1+ -- j18 orange
  - AD1.2+ -- i18 yellow
  - AD1.2- -- -b25 blue
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/breadboard/08-ground-loop.svg)

- 上の青レールが A (AD3 の GND と 1−)、下の青レールが B。B への線は青、A への線は黒にして取り違えないようにする
- RG1 (23 列) と RG2 (27 列) は溝をまたいで縦に挿し、上の端を上の青レール、下の端を下の青レールへ
- Q1 (2N7000) は平らな面を手前にして左から S・G・D (10・11・12 列)。D に R1 (12〜15 列、15 列から上の赤レール)、G に W1、S は溝を渡って下の青レール (B) へ
- センサーの R2 は下の赤レール (2 列で上の赤レールとつないだ V+) から 14 列を経て 18 列へ、R3 は 18 列から 21 列を経て下の青レール (B) へ。18 列が出力で、1+ と 2+ を当てる
- (3) の組では、`j10 -- -b10` の線を抜いて Q1 の S (10 列の下のブロック) から上の青レールへ黒の線を引き、RG1 を抜く
- 電流は最大 22 mA で、ブレッドボードの範囲に収まる。R1 の損失は入っている間 0.11 W (平均 0.06 W)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V |
| Wavegen | W1: Square、1 kHz、Offset 2.5 V、Amplitude 2.5 V (0〜5 V) |
| Scope | CH1・CH2 とも 10 mV/div、Offset −100 mV (目安)、200 µs/div (µs はマイクロ秒)。トリガは CH1 の立ち上がり 115 mV |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 GND の線が 1 本の組 — CH1 は負荷が入るたびに 22 mV 浮き、CH2 は平ら
time: 200us/div
trigger: ch1 rising 115mV
ch1: {wave: square 1kHz 11mV offset 115mV, range: 10mV/div, position: -10div}
ch2: {wave: dc 104mV, range: 10mV/div, position: -10div}
measure: [vpp, avg]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/10-power-noise/scope/08-ground-loop.svg)

図3 は (1) の組の画面 (計算)。CH1 は 104 mV と 126 mV の間を跳ぶ方形波になる。足された 22 mV は RG1 × 22 mA で、
センサーの出力の 2 割に当たる。CH2 はセンサーと同じ GND から測るので、跳びは 0.5 mV しか残らない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 220 Ω (負荷。入っている間 22 mA・0.11 W) |
| R2 | 抵抗 (1/4 W) | 47 kΩ |
| R3 | 抵抗 (1/4 W) | 1 kΩ |
| RG1・RG2 | 抵抗 (1/4 W) | 1 Ω (GND の線の代わり。損失 0.5 mW) |
| Q1 | N チャネル MOSFET | 2N7000 |
| — | 電源 | AD3 の Supplies の V+ (5 V) |
| — | 計器 | AD3 の Wavegen (W1 = Q1 のゲート) と Scope (CH1 = A から、CH2 = B から) |

## 見るべき値

計算値 (下の LTspice の値)。負荷が入ったときの CH1 の跳び (Vpp) が、GND の線から足された電圧。

| 組 | CH1 (A から) | CH1 の跳び | CH2 (B から) | 分かること |
| --- | --- | --- | --- | --- |
| (1) GND の線が 1 本 | 104 → 126 mV | **22 mV** | 104 mV (跳び 0.5 mV) | 22 mA × 1 Ω がそのまま足される |
| (2) 2 本のループ | 104 → 115 mV | 11 mV | 104 mV | 電流が 2 本に分かれ、半分になるだけ |
| (3) 一点接地 | 104 mV | 0 mV | 104 mV | 負荷の帰りが B を通らないので消える |

- **ループで線を増やしても、共通の部分が残る限り消えない。** 消えるのは、大きな電流の帰りと信号の帰りを分けたとき
- AD3 の Scope の入力は差動で、1− と 2− には電流がほとんど流れない (入力は 1 MΩ)。だから CH2 の 2− を B に当てても、新しいループはできない
- **汎用のオシロスコープ** (BNC の外皮が AC 100 V のコンセントのアース (保護接地) につながる物) で同じ所を測ると、プローブの GND のクリップが
  2 本めの GND の線になる。PC (AD3 の USB) とオシロの両方がアースにつながっていれば、コンセントのアースを通るループができ、
  負荷の電流の一部と商用電源の 50 / 60 Hz の誘導がそこに流れる (読みに 50 Hz か 60 Hz の揺れが乗る)。この題の回路はコンセントに直につながないが、
  計器のアースのつなぎ方でループができることは覚えておく
- 実物のジャンパ線 (20 cm で 0.05 Ω ほどの目安) なら跳びは 1 mV ほど。14 ビットの ADC やマイクのアンプでは、この 1 mV が効く

## LTspice での確かめ

`sim/08-ground-loop.cir` で図1 を 5 ms 動かし、3〜5 ms を読んだ。パラメータ `k` で 3 つの組に替えた。2N7000 は 02-transistors の題と同じ仮定の模型。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 負荷の電流 | 22 mA | 22.3 mA | 合う |
| CH1 の跳び (1)・(2)・(3) | 22・11・0 mV | 22.1・11.1・0 mV | 合う |
| CH1 の低い側 | 104 mV | 104.0 mV | 合う |
| CH2 の跳び (1) | 0.5 mV | 22.1 mV ÷ 48 = 0.46 mV (V(s) と V(b) の差) | 合う |

## 出典

自作。計器の名前と操作は Digilent の [Using the Oscilloscope](https://digilent.com/reference/test-and-measurement/guides/waveforms-oscilloscope)。
参考: [Ground loop (electricity) (Wikipedia)](https://en.wikipedia.org/wiki/Ground_loop_(electricity))
