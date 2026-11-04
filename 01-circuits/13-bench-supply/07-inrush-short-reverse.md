---
book: circuits
chapter: 13
id: 13-7
title: 電流制限で回路を守る — 短絡・逆接続・起動時の突入電流
tier: 200
source: 自作
---

# 13-7 電流制限で回路を守る — 短絡・逆接続・起動時の突入電流

13-1〜13-3 で使った電源装置の電流制限は、故障のときの保険になる。この題では 3 つの「事故」で、電流制限が何を守り、何は守らないかを確かめる。

1. **起動時の突入電流** — 空のコンデンサは、電源を入れた瞬間は短絡と同じ。470 µF (マイクロファラド) の電源のコンデンサを 5 V の電源に直結すると、
   電流は配線の抵抗だけで決まり、数 A 流れることがある。電流制限 100 mA の電源装置なら、電源装置が CC に入り、100 mA でコンデンサを**一定の速さで**充電する。
   5 V まで t = C × V ÷ I = 470 µF × 5 V ÷ 0.1 A ≈ 24 ms
2. **短絡** — 出力の + と − が触れても、電流は 100 mA で止まる。電源装置の出力の電圧が 0 V 近くまで下がり、熱は電源装置の中で出る
3. **逆接続** — 回路の電源の線を + と − を逆に挿すと、電解コンデンサに逆の電圧が掛かる。回路に D1 (ショットキー) を逆向きに入れておくと、
   逆につないだときだけ D1 が流れて、コンデンサの逆電圧を 0.3 V ほどに抑える。電流は電源装置の電流制限 (100 mA) で止まるので D1 も焼けない。
   5-9 の逆接続保護 (直列のダイオード) と違い、ふだんは電流が流れず電圧を損しない。そのかわり電流制限が無い電源 (電池など) では D1 が大電流を流す

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 470 µF の回路を電流制限 100 mA の電源装置で入れる (D1 は逆接続の保護)
parts:
  U1:
    type: device
    at: 2,3
    label: PSU
    pins: ["+", "-"]
    turn: mirror
  D1: schottky 6,7 6,3 1N5819
  C1: ecap 9,3 9,7 470u
  RL: resistor 12,3 12,7 1k
  M1: voltmeter 14,3 14,7 l=$\mathrm{CH1}$
  RS: resistor 6,7 6,9 1
  M2: voltmeter 4,7 4,9 l=$\mathrm{CH2}$
  G1: ground 6,9
wires:
  - U1.+ -- 6,3
  - 6,3 -- 9,3 -- 12,3 -- 14,3
  - 6,7 -- 9,7 -- 12,7 -- 14,7
  - 4,7 -- 6,7
  - 4,9 -- 6,9
  - U1.- -| 3,9
  - 3,9 -- 4,9
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/circuit/07-inrush-short-reverse.svg)

- PSU は電源装置 (5.00 V、電流制限 100 mA)。C1 (470 µF・16 V) は回路の電源のコンデンサ、RL (1 kΩ (オーム)) は回路の消費電流の代わり (5 mA)
- D1 (1N5819) はカソードを + 側に向けた逆接続の保護。正しくつないだときは逆向きなので流れない
- RS (1 Ω) は戻りの電流を見るシャント。CH2 が RS の両端 (1 mA で 1 mV)、CH1 が C1 の両端

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 赤レール = VO、上の青レール = C1 の -、下の青レール = GND
board: half
parts:
  PSU:
    type: device
    at: top
    label: 電源装置 (5.00 V、電流制限 100 mA)
    pins: ["-", "+"]
  AD:
    type: device
    at: bottom
    label: Analog Discovery 3 (Scope)
    pins: [GND, 2+, 2-]
  AD1:
    type: device
    at: top
    label: Analog Discovery 3 (CH1)
    pins: [1+, 1-]
  D1: schottky c5(A) c9(K) 1N5819
  C1: capacitor/electrolytic +t12(+) -t12(-) 470uF
  RL: resistor +t16 -t16 1k
  RS: resistor c20 c24 1
wires:
  - PSU.+ -- +t3 red
  - PSU.- -- -b1 black
  - a5 -- -t5 black
  - a9 -- +t9 red
  - a20 -- -t20 black
  - e24 -- f24 black
  - j24 -- -b24 black
  - AD1.1+ -- +t18 orange
  - AD1.1- -- -t22 blue
  - AD.GND -- -b4 black
  - AD.2+ -- j20 green
  - e20 -- f20 green
  - AD.2- -- i24 yellow
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/breadboard/07-inrush-short-reverse.svg)

- 電源装置の + (赤) を上の赤いレール (VO)、− (黒) を下の青いレール (GND) へ。上の青いレールは C1 の − の側で、RS を通って GND へ戻る
- C1 は + を上の赤いレール、− を上の青いレールに挿す (12 列)。RL も同じレールの間 (16 列)
- D1 は帯 (カソード) のある側を 9 列 (赤いレールへ)、アノードを 5 列 (上の青いレールへ) に挿す
- RS (`c20`–`c24`) は上の青いレールから 20 列、24 列から下のブロックを通って下の青いレール (GND) へ
- CH1 (1+ を赤いレール、1− を上の青いレール) で C1 の電圧、CH2 (2+ を RS の上の 20 列、2− を 24 列) で電流を見る。AD3 の GND は下の青いレール
- 流れる電流は最大 100 mA で、ブレッドボードの範囲 (1 穴 200 mA) の内側

## 計器の設定

電源は電源装置 (この題の主役)。AD3 は Scope だけを使う。

1. 電源装置を出力オフで 5.00 V・電流制限 100 mA にして回路をつなぐ
2. Scope は CH1 1 V/div、CH2 20 mV/div、どちらも 0 V を下から 1 目盛 (−4 div)、時間軸 5 ms/div。トリガは単発で CH2 の立ち上がり 50 mV
3. 出力を入れる (t = 0)。表示の CC が点き、24 ms ほどで CV に戻ることも見る
4. 短絡: 出力を入れたまま、上の赤いレールと上の青いレールを線で一瞬つなぐ。電源装置の表示が CC・約 0 V・100 mA になる。数秒で外す
5. 逆接続: 出力を切り、電源装置の + と − の線をブレッドボードの側で入れ替えて出力を入れる。CH1 が約 −0.3 V、電源装置の表示が CC・100 mA になる。すぐに切って戻す

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 100 mA (CH2) で 470 µF を一定の速さで充電し、24 ms で 5 V (CH1)
time: 5ms/div
trigger: ch2 rising 50mV at -4div
ch1: {wave: "= min(100V * (1 - exp(-max(t, 0s) / 470ms)), 4.995V)", range: 1V/div, position: -4div}
ch2: {wave: "= 100mV * step(t) - 95mV * step(t - 24.1ms)", range: 20mV/div, position: -4div}
cursors: [11.9ms, 30ms]
measure: [vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/13-bench-supply/scope/07-inrush-short-reverse.svg)

図3 は理想 (計算) の画面。CH2 は 100 mV (= 100 mA) で平らで、その間 CH1 は直線で上がる。X1 (11.9 ms) で 2.5 V、24.1 ms で 5 V に届くと
電源装置は CV に戻り、電流は RL の 5 mA (CH2 5 mV) に落ちる。直線で上がるのが定電流で充電している印で、RC の充電 (指数の形) とは違う。

実物の電源装置は、出力の中にもコンデンサがあり、出力を入れた瞬間や線をつないだ瞬間に、そのコンデンサから電流制限を超える電流が一瞬出ることがある (13-2)。
CH2 の立ち上がりに細い山が見えたらそれで、電流制限は「落ち着いた後の電流」を決めるもの、と覚えておく。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| C1 | 電解コンデンサ (16 V) | 470 µF |
| RL | 抵抗 (1/4 W) | 1 kΩ (25 mW) |
| D1 | ショットキーダイオード | 1N5819 (逆接続のとき 100 mA × 0.3 V ≈ 30 mW) |
| RS | 抵抗 (1/4 W) | 1 Ω (100 mA のとき 10 mW) |
| — | 電源 | 電源装置 (5.00 V、電流制限 100 mA)。この章の題なので電源装置を使う |
| — | 計器 | AD3 の Scope (CH1 = C1 の両端、CH2 = RS の両端) |

## 見るべき値

| 事故 | 測る所 | 期待する値 | 分かること |
| --- | --- | --- | --- |
| 起動 | 充電の間の電流 (CH2) | 100 mA で一定 | 電流制限が突入電流を抑える |
| 起動 | 2.5 V・5 V に届く時刻 (CH1) | 11.9 ms・24.1 ms | 定電流なので時間 = C × V ÷ I の直線 |
| 起動 | 落ち着いた後 | 4.995 V・5.0 mA | RS の 5 mV だけ C1 の電圧は 5 V より低い |
| 短絡 | 電源装置の表示 | CC、約 0 V、100 mA | 電流は制限で止まる。熱は電源装置の中で出る |
| 逆接続 | C1 の電圧 (CH1) | 約 −0.3 V | D1 が逆電圧を抑える。電解コンデンサの逆電圧は 1 V より十分小さく |
| 逆接続 | 電源装置の表示 | CC、約 0.4 V、100 mA | D1 の 0.3 V と RS の 0.1 V |

- 電流制限を 3 A などの最大のままにしておくと、どの事故でも保険にならない。「回路がふだん使う電流の 2〜3 倍」に決めてから出力を入れる (13-1 の手順)
- 起動の時間は電流制限で変えられる。50 mA にすれば 48 ms で、突入電流は半分

## LTspice での確かめ

`sim/07-inrush-short-reverse.cir` で、図1 の電源を t = 0 で入れたときと、電源を逆につないだときを解いた。電源装置は CV/CC の模型
(5-15 と同じ。出力のコンデンサは入れていない)、C1 は 470 µF + ESR 0.1 Ω (仮定)、D1 は 1N5819 の模型。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 充電の間の電流 | 100 mA | 100.0 mA | 合う |
| 2.5 V・4.9 V に届く時刻 | 11.9 ms・約 23.5 ms | 11.87 ms・23.58 ms | 合う |
| 落ち着いた後の C1 の電圧・電流 | 4.995 V・5.0 mA | 4.995 V・5.03 mA | 合う |
| 逆接続の電流・C1 の電圧 | 100 mA・約 −0.3 V | 100.0 mA・−0.29 V | 合う |
| 逆接続の電源装置の電圧 | 約 0.4 V | 0.39 V | 合う |

5 V に届く時刻 24.1 ms は、式 t = −RC × ln(1 − V ÷ (I × R)) (R = 1 kΩ、I = 100 mA) の値で、LTspice の 4.9 V の時刻と同じ曲線の上にある。短絡は算術 (電流 = 電流制限) だけで、LTspice には掛けていない。

## 出典

自作。

参考: [突入電流 (Wikipedia)](https://ja.wikipedia.org/wiki/突入電流)、[ショットキーバリアダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/ショットキーバリアダイオード)、[安定化電源 (Wikipedia)](https://ja.wikipedia.org/wiki/安定化電源)
