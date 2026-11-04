---
book: circuits
chapter: 13
id: 13-4
title: ±電源を作る — 2 ch の直列と GND の取り方
tier: 200
source: 自作
---

# 13-4 ±電源を作る — 2 ch の直列と GND の取り方

両電源のオペアンプ (TL072 など) は +5 V と −5 V の 2 本の電源と、その真ん中の GND を要る。2 出力の電源装置なら、
**出力 A の − と出力 B の + をつなぎ、そのつなぎ目を GND にする**だけで作れる。A の + が +5 V、B の − が −5 V になる。

電源装置の出力は、ふつうは接地 (コンセントのアース) からも、出力どうしからも浮いている (13-1〜13-3 の題でも、CH の − を GND と呼んで使った)。
浮いているから、2 つを直列に積めて、どこを GND と呼ぶかを自分で決められる。決めた GND は回路の中で 1 か所だけにする。

- **正しい取り方**: A の − = B の + = GND。回路から見ると +5 V・0 V・−5 V の 3 本
- **まちがえやすい取り方**: B の − を GND と思ってつなぐ。すると回路から見た電源は 0 V・+5 V・+10 V になり、反転増幅の + (GND につないだつもり) が
  オペアンプの V− と同じ電圧になる。TL072 の入力が働く範囲は V− より 1.5〜3 V 上から (データシートの値。品種で違う) なので、出力は正しく出ない
- 電源装置によっては、2 つの出力の − が中でつながっている (共通の − の機種)。その機種は直列にできない。取扱説明書で「独立出力」か「直列 (シリーズ) 運転」の欄を確かめる

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 電源装置の出力 A と B を直列にして +5 V と -5 V (つなぎ目が GND)
parts:
  V1: vsource 2,2 2,5 5 l=$\mathrm{A}$
  V2: vsource 2,5 2,8 5 l=$\mathrm{B}$
  C1: capacitor 4,2 4,5 0.1u
  C2: capacitor 4,5 4,8 0.1u
  VP: port 5,2 out
  VN: port 5,8 out
  G1: ground 4,5
  W1: sine 7,4 7,7 l=$\mathrm{W1}$
  G2: ground 7,7
  RIN: resistor 9,4 11,4 10k
  U1A: opamp 13,4.35 +down TL072
  RF: resistor 11,2.5 15,2.5 20k
  G3: ground 11.5,5.5
  M1: voltmeter 8.5,4 8.5,7 l=$\mathrm{CH1}$
  M2: voltmeter 16,4.35 16,7 l=$\mathrm{CH2}$
  G4: ground 8.5,7
  G5: ground 16,7
wires:
  - 2,2 -- 4,2 -- 5,2
  - 2,8 -- 4,8 -- 5,8
  - 2,5 -- 4,5
  - 11,4 -| U1A.-
  - 11,2.5 -- 11,4
  - U1A.out -- 15,4.35 -- 16,4.35
  - 15,2.5 -- 15,4.35
  - 11.5,5.5 |- U1A.+
  - 7,4 -- 8.5,4 -- 9,4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/circuit/04-dual-supply-series.svg)

- A・B は電源装置の 2 つの出力 (どちらも 5.0 V、電流制限 50 mA)。VP (+5 V) を TL072 の 8 番 (VCC+)、VN (−5 V) を 4 番 (VCC−) へ
- C1・C2 (0.1 µF (マイクロファラド)) は TL072 のすぐそばのデカップリング。+5 V と GND、GND と −5 V の間に 1 個ずつ
- U1A は TL072 の 1 番目の回路で、RIN (10 kΩ (オーム))・RF (20 kΩ) の反転増幅 (利得 −2)。入力は AD3 の W1 (1 kHz・1 Vpp)
- CH1 が入力、CH2 が出力

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 上の赤レール = +5 V、上の青レール = GND、下の青レール = -5 V
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源装置 (出力 A・B とも 5.0 V、電流制限 50 mA)
    pins: [B-, A+, A-, B+]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (W1 と Scope)
    pins: [1+, W1, 2+, 1-, GND, 2-]
  U1: dip8 @ e10 TL072
  C1: capacitor +t7 -t7 0.1uF
  C2: capacitor i23 -b24 0.1uF
  RIN: resistor g2 g11 10k
  RF: resistor i3 i11 20k
wires:
  - PSU.A+ -- +t2 red
  - PSU.A- -- -t3 black
  - PSU.B+ -- -t5 black
  - PSU.B- -- -b1 blue
  - a10 -- +t10 red
  - j13 -- -b13 blue
  - -t20 -- a20 black
  - e20 -- f20 black
  - g12 -- g20 black
  - h10 -- h3 orange
  - a13 -- -t13 black
  - c11 -- c12 white
  - AD.W1 -- j2 yellow
  - AD.1+ -- i2 yellow
  - AD.2+ -- j10 green
  - AD.1- -- i20 black
  - h20 -- h23 black
  - AD.2- -- j23 black
  - AD.GND -- j20 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/breadboard/04-dual-supply-series.svg)

- 電源装置の A+ (赤) を上の赤いレール、A− と B+ (黒) を上の青いレールへ。この 2 本の黒い線が「つなぎ目 = GND」。B− (青) は下の青いレール (−5 V)
- −5 V の線と下のレールは青、GND は黒、+5 V は赤で分ける。下の青いレールは GND ではなく −5 V なので、取り違えない
- TL072 (10〜13 列) の 8 番 (`e10`) を +5 V へ、4 番 (`f13`) を −5 V (`j13`) へ。C1 は上のレールの間、C2 は GND の 23 列と −5 V のレールの間
- GND は上の青いレールから 20 列を下りて下のブロックへ (`a20`、`e20`–`f20`)、`g20`–`g12` で 1IN+ (3 番) へ、`h20`–`h23` で 23 列へ
- 2 番目の回路は使わない: 2IN+ (5 番) を GND へ、2IN− と 2OUT (6・7 番) を白の短い線でつなぐ
- RIN (`g2`–`g11`) は入力の 2 列から 1IN− (11 列) へ、RF (`i3`–`i11`) は 1IN− から 3 列へ、橙の線 (`h3`–`h10`) で 1OUT (10 列) へ戻す
- AD3 の W1 と 1+ は 2 列、2+ は 1OUT (`j10`)。1−・2− と AD3 の GND は GND の 20・23 列

ブレッドボードを流れる電流は数 mA で、ブレッドボードの範囲に収まる。

## 計器の設定

電源は電源装置の 2 つの出力 (この題の主役)。AD3 の Supplies も ±5 V を出せるが、ここでは電源装置で ±電源の作り方を覚える。AD3 は Wavegen と Scope だけを使う。

1. 電源装置を出力オフのまま、A・B とも 5.0 V・電流制限 50 mA にする。直列の線 (A− と B+) をつないでから回路をつなぐ
2. 出力を入れ、テスターで GND から見た +5 V と −5 V を確かめる (A+ が +5.0 V、B− が −5.0 V)。逆に出たら A と B を取り違えている
3. W1 を正弦波・1 kHz・振幅 0.5 V (1 Vpp)、Scope は CH1・CH2 とも 500 mV/div、時間軸 200 µs/div、トリガは CH1 の立ち上がり 0 V

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 ±5 V で動く TL072 — 入力 1 Vpp (CH1) が 2 Vpp で反転して出る (CH2)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1Vpp, range: 500mV/div}
ch2: {wave: ch1 | gain -2, range: 500mV/div}
measure: [vpp, avg, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/scope/04-dual-supply-series.svg)

図3 は理想 (計算) の画面。CH2 は CH1 の 2 倍の 2 Vpp で、山と谷が逆。平均は 0 V で、出力が GND の上下に同じだけ振れている。
これが単電源では出せない「0 V を中心に振れる出力」で、両電源を作った意味。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 2 回路のオペアンプ (DIP-8) | TL072 (新しい TL072H は ±2.25 V から動く。旧来品の表は ±15 V の値) |
| RIN | 抵抗 (1/4 W) | 10 kΩ |
| RF | 抵抗 (1/4 W) | 20 kΩ |
| C1, C2 | セラミックコンデンサ (104) | 0.1 µF |
| — | 電源 | 電源装置の 2 出力 (A・B とも 5.0 V、電流制限 50 mA) を直列。この章の題なので電源装置で作る |
| — | 計器 | AD3 の Wavegen (W1) と Scope (CH1 = 入力、CH2 = 出力) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| A+ と GND の間・B− と GND の間 (テスター) | +5.0 V・−5.0 V | つなぎ目が GND になる |
| A+ と B− の間 | 10.0 V | 2 つの出力の和 |
| 出力 (CH2) | 2.00 Vpp、平均 0 V、入力と逆の向き | ±5 V で TL072 が正しく動く |
| 電源装置の電流の表示 (A・B) | どちらも約 2.8 mA (TL072 の 2 回路ぶん、1 回路 1.4 mA がデータシートの典型) | 両方の出力に同じ電流が流れる。片方だけ大きければ配線を疑う |
| B− を GND につないだ (まちがえた) とき | 出力が 2 Vpp の正弦波にならない | + の入力が V− と同じで、入力が働く範囲を外れる |

- 電流制限 (50 mA) は、配線をまちがえたときの保険。±電源の回路は、+5 V と −5 V の線が触れると 10 V の短絡になる
- オペアンプの出力に重い負荷をつなぐと、A と B の電流は等しくなくなる (出力が正のときは A から、負のときは B から流れる)

## LTspice での確かめ

`sim/04-dual-supply-series.cir` で図1 を 10 ms 動かした。A・B は理想の 5 V の電源を直列にし、TL072 は 04-opamps の題と同じ汎用の模型
(仮定: GBW 3 MHz、出力は電源から 1.5 V 内側まで)。TL072 自身の電流は 2.8 mA (1 回路 1.4 mA の 2 回路ぶん、データシートの典型の仮定) の電流源で入れた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| A+ と B− の間 | 10.0 V | 10.0 V | 合う |
| 出力の振れ | 2.00 Vpp | 1.998 Vpp | 合う |
| 出力の平均 | 0 V | 0.02 mV | 合う |
| 入力と出力の向き | 逆 | 入力の 0 V の上りと出力の 0 V の下りが同じ時刻 (5.000 ms) | 合う |
| A・B の電流 | 約 2.8 mA | 2.80 mA・2.80 mA (模型に入れた値) | 模型の仮定どおり |

まちがえた GND (B− を GND) は、模型のオペアンプが入力の範囲を持たないので確かめていない。データシートの入力の範囲から言える事として書いた。

## 出典

自作。

参考: [TI TL072 のデータシート](https://www.ti.com/lit/ds/symlink/tl072.pdf)、[安定化電源 (Wikipedia)](https://ja.wikipedia.org/wiki/安定化電源)、[オペアンプ (Wikipedia)](https://ja.wikipedia.org/wiki/オペアンプ)
