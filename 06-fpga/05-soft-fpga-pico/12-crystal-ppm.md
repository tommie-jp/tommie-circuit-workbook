---
book: fpga
chapter: 5
id: 5-12
title: 水晶の精度を測る — 1 Hz を出して AD3 で ppm を見る
tier: 100
source: 自作
board: BB
device: PICO
---

# 5-12 水晶の精度を測る — 1 Hz を出して AD3 で ppm を見る

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは 5-11 と同じ `.uf2` で、ビルドは確かめたが、書き込んで動かしてはいない。
> Pico 2 の水晶のずれ (ppm) は**測っていない**。表の ppm と秒の対応は計算値。「見るべき値」の空欄は、測って書き込む。

5-11 の PWM は、Pico 2 の水晶から作ったシステムクロックを数えている。だから Soft-FPGA のクロックの**平均の周波数は、水晶の精度そのもの**になる。
水晶が 20 ppm 速ければ、クロックも 20 ppm 速い。ppm は百万分の 1 のことで、20 ppm は 1 秒に 20 µs (マイクロ秒) のずれ。

この題では、5-11 のプログラムで 1 Hz の信号を作り、AD3 の Logic で長く測って、水晶のずれを ppm で出す。
時計にしたとき 1 日に何秒ずれるかも、そこから計算する (12-4 の時計で、FPGA と比べる)。

## 1 Hz の作り方

PWM だけでは 1 Hz は出せない (5-11 の最低は約 8.98 Hz)。そこで、**1 kHz のクロックで 2-7 の `blink` を回す**。
`blink` は `CLK_HZ = 1000` で作ってあり、500 クロックごとに `led` が反転するので、`led` の周期はちょうど 1000 クロック。

```text
PWM:  150 MHz ÷ (3 × 50 000) = 1 kHz  (割り切れる。誤差 0)
blink: 1000 クロック ÷ 1 kHz = 1 s     (led の周期)
```

割り込みは PWM のカウンタが 1 周するたびに入る。入る時刻に遅れがあっても、**カウンタは遅れを積み上げない**
(次の周期はカウンタが決める)。1000 回数えた平均は、水晶と PLL だけで決まる。

| 決め | 内容 |
| --- | --- |
| クロック | 1 kHz。PWM のハードウェアが GP16 に出す |
| 回路 | 2-7 の `blink` (`CLK_HZ = 1000`)。`led` が 1 Hz |
| 測る信号 | `led` の写し (GP18、AD3 の DIO2)。LED (GP5) も同じ値で、1 秒に 1 回、0.5 s ずつ点滅する |
| 参照の信号 | CLK (GP16、DIO0)。1 kHz のまま。窓が長いと塗りつぶしになるので、見ない |

スイッチは 5-11 と同じプログラム。**SW1 ON・SW2 ON・SW3 OFF・SW4 ON** (1 kHz と `blink`) で起動する。

## 水晶のずれを出す式

測る量は、`led` の立ち上がりから N 回後の立ち上がりまでの時間 T (秒)。設計値は N 秒。

```text
ずれ [ppm] = (T − N) ÷ N × 1 000 000
1 日のずれ [s] = ずれ [ppm] × 86 400 ÷ 1 000 000 = ずれ [ppm] × 0.0864
```

ppm と 1 日のずれ (計算値):

| ずれ | 1 日のずれ | 1 時間のずれ |
| --- | --- | --- |
| 1 ppm | 0.0864 s | 3.6 ms |
| 5 ppm | 0.432 s | 18 ms |
| 10 ppm | 0.864 s | 36 ms |
| 20 ppm | 1.73 s | 72 ms |
| 50 ppm | 4.32 s | 180 ms |
| 100 ppm | 8.64 s | 360 ms |
| 200 ppm | 17.3 s | 720 ms |

## 測る側の限界

**測っているのは、AD3 の時間軸に対するずれ**である。AD3 にも自分の時間の基準 (発振器) があり、その精度は Pico 2 と同じ桁かもしれない。
この方法で分かるのは、2 つの水晶の**差**。AD3 の時間の基準の精度は、Digilent の資料で確かめてから「Pico 2 のずれ」と読むこと
(この題では確かめていない)。ずれの符号が正なら、Pico 2 の 1 秒のほうが AD3 の 1 秒より長い。

もう 1 つの限界は、**取り込みの長さで決まる分解能**である。時間は標本の刻み 1 つぶんの粒でしか読めない。

```text
分解能 [ppm] = 刻み ÷ 測る時間 × 1 000 000
```

| 取り込み | 刻み | 測る時間 (N 周期) | 分解能 (計算値) |
| --- | --- | --- | --- |
| 32 768 標本の 1 回 | 1 ms (1 kHz で標本化) | 32 s (N = 32) | 約 31 ppm |
| 32 768 標本の 1 回 | 10 ms (100 Hz) | 327 s (N = 327) | 約 31 ppm |
| Record で長く | 1 ms | 100 s (N = 100) | 10 ppm |
| Record で長く | 1 ms | 1000 s (N = 1000) | 1 ppm |
| Record で長く | 0.1 ms (10 kHz) | 1000 s (N = 1000) | 0.1 ppm |

- 1 回の取り込み (32 768 標本) では、どの標本化でも約 31 ppm (= 1 ÷ 32 768) より細かくは読めない。
  水晶のずれがそれより小さければ、「±31 ppm の内」としか言えない
- それより細かく見るには、**長く記録する**。AD3 の Scope には Record がある (02-analog-discovery/02-oscilloscope/11-record-mode.md)。
  Logic にも Record があるか、WaveForms の取り込みモードの一覧で確かめる (この題では確かめていない)。
  なければ Scope の CH1 に `led` の写し (GP18) をつないで測ってもよい
- 長く測るほど、室温の変化も水晶のずれに入る。水晶は温度で周波数が変わるので、測るあいだは基板を動かさない

## 回路図

図1・図2 は 5-5 と同じ。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Pico 2 に LED 4 個・DIP スイッチ・AD3 の Logic をつなぐ
parts:
  U1: pico2 8,8 mirror
  R1: resistor 13,2 15,2 330
  D1: led 15,2 17,2
  R2: resistor 13,3.2 15,3.2 330
  D2: led 15,3.2 17,3.2
  R3: resistor 13,4.4 15,4.4 330
  D3: led 15,4.4 17,4.4
  R4: resistor 13,5.6 15,5.6 330
  D4: led 15,5.6 17,5.6
  G1: ground 17.6,6.4
  G3: ground 10.2,7.6
  SW1: dip-switch4 13,10
  G2: ground 15.4,11.2
  AD:
    type: device
    at: 2,10.8
    label: AD3
    pins: [DIO5, DIO4, DIO3, DIO2, GND, DIO1, DIO0]
    turn: mirror
wires:
  - U1.GP2 -| 10,2
  - 10,2 -- 13,2
  - U1.GP3 -| 10.5,3.2
  - 10.5,3.2 -- 13,3.2
  - U1.GP4 -| 11,4.4
  - 11,4.4 -- 13,4.4
  - U1.GP5 -| 11.5,5.6
  - 11.5,5.6 -- 13,5.6
  - 17,2 -- 17.6,2 -- 17.6,3.2
  - 17,3.2 -- 17.6,3.2 -- 17.6,4.4
  - 17,4.4 -- 17.6,4.4 -- 17.6,5.6
  - 17,5.6 -- 17.6,5.6 -- 17.6,6.4
  - U1.GND8 -| 10.2,7.6
  - U1.GP10 -| 9.8,9.4
  - 9.8,9.4 |- SW1.A1
  - U1.GP11 -| 10,9.8
  - 10,9.8 |- SW1.A2
  - U1.GP12 -| 10.2,10.2
  - 10.2,10.2 |- SW1.A3
  - U1.GP13 -| 10.4,10.6
  - 10.4,10.6 |- SW1.A4
  - SW1.B1 -| 15.4,9.4
  - SW1.B2 -| 15.4,9.8
  - SW1.B3 -| 15.4,10.2
  - SW1.B4 -| 15.4,10.6
  - 15.4,9.4 -- 15.4,9.8 -- 15.4,10.2 -- 15.4,10.6 -- 15.4,11.2
  - AD.DIO5 -- U1.GP21
  - AD.DIO4 -- U1.GP20
  - AD.DIO3 -- U1.GP19
  - AD.DIO2 -- U1.GP18
  - AD.GND -- U1.GND23
  - AD.DIO1 -- U1.GP17
  - AD.DIO0 -- U1.GP16
notes:
  - text 9,12.6: GP10-GP13 は Pico 2 の内蔵プルアップ (ON で L)
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/circuit/12-crystal-ppm.svg)

- 配線は 5-5 と同じ。AD3 は GP18 (`led` の写し) を DIO2 で読む。GND は共通

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 Pico 2 の左に LED、右に DIP スイッチ、上に AD3 の Logic
board: full
parts:
  U1: pico2 @ g15
  R4: resistor g3 c3 330
  D4: led b3(A) b4(K) red
  R3: resistor g6 c6 330
  D3: led b6(A) b7(K) red
  R2: resistor g9 c9 330
  D2: led b9(A) b10(K) red
  R1: resistor g12 c12 330
  D1: led b12(A) b13(K) red
  SW1: dip-switch4 @ e37 r180
  AD:
    type: device
    at: top
    label: AD3 Logic
    pins: [DIO5, DIO4, DIO3, DIO2, GND, DIO1, DIO0]
wires:
  - j22 -- -b22 black
  - -t1 -- -b1 black
  - a4 -- -t4 black
  - a7 -- -t7 black
  - a10 -- -t10 black
  - a13 -- -t13 black
  - h18 -- h12 yellow
  - i19 -- i9 yellow
  - j20 -- j6 yellow
  - j21 -- j3 yellow [v15]
  - a37 -- -t37 black
  - a38 -- -t38 black
  - a39 -- -t39 black
  - a40 -- -t40 black
  - h31 -- h37 blue
  - i30 -- i38 blue
  - j29 -- j39 blue
  - j28 -- j40 blue [v15]
  - AD.DIO5 -- a28 green
  - AD.DIO4 -- a29 green
  - AD.DIO3 -- a30 green
  - AD.DIO2 -- a31 green
  - AD.GND -- -t32 black
  - AD.DIO1 -- a33 orange
  - AD.DIO0 -- a34 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/breadboard/12-crystal-ppm.svg)

- 配線は 5-5 と同じ。AD3 は DIO2 (緑、`led` の写し) と DIO0 (白、CLK) を読む
- DIP スイッチは下の列の左から 4・3・2・1。**右端が SW1**。SW1・SW2・SW4 を ON、SW3 を OFF にする

## 部品表

5-5 と同じ。電源は 3.3 V (Pico 2 の GPIO)。5 V を入れないのは 0-3 と同じ理由。

## Pico 2 のプログラム

5-11 の `clock511.cpp` をそのまま使う (SW1 ON・SW2 ON・SW3 OFF・SW4 ON)。作業用のフォルダ・ビルドの打ち方は 5-11 と同じ。
`build/clock511.uf2` は 96 256 バイト (Verilator 5.048、Pico SDK 2.2.0)。**実機では動かしていない。**

## 計器の設定

計器は AD3 の Logic。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO2 (`led`) を Enable。標本化 1 kHz (窓は 32.768 s、刻みは 1 ms) |
| Logic のトリガ | DIO2 の立ち上がり。トリガのあとに N 周期入る窓にする |
| カーソル | X1 をトリガの立ち上がり、X2 を N 周期後の立ち上がりに置く。ΔX が T |
| 長く測る | Record (分解能の表の下 3 行)。記録を CSV に書き出し、立ち上がりの時刻の差を計算する |

CSV からは、5-10 の `jitter.py` が、立ち上がりの間隔の最小・最大・平均を出す。
**平均の周期**の、1 秒からのずれが ppm になる (上の式)。

## Logic に見えるはずの画面

図3 は、`led` の 1 Hz。0.5 s ずつ H と L が続く。ΔX は 4 周期 (4 s)。ずれは 0 と置いて描いた (設計値)。実機では、ΔX が 4.000 s からわずかにずれる。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 blink の led は 1 Hz。4 周期 (4 s) を X1 と X2 で挟む
device: ad3
time: 500ms/div
start: -500ms
sample: 1kHz
signals:
  MON0: dio2 edges -500ms=0 0s=1 500ms=0 1s=1 1500ms=0 2s=1 2500ms=0 3s=1 3500ms=0 4s=1 4500ms=0
cursors: [0s, 4s]
trigger: MON0 rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/05-soft-fpga-pico/logic/12-crystal-ppm.svg)

- X1 は、トリガの立ち上がり (0 s)。X2 は 4 周期後の立ち上がり (4 s)
- 4 s が 4.000 s より 1 ms 長く読めたら、(4.001 − 4) ÷ 4 × 10⁶ = 250 ppm。1 回の取り込みの刻みは 1 ms なので、**この読み方は 250 ppm より細かくは読めない**。
  図の窓 (5 s) より長く取り込み、周期を増やす

## 見るべき値

**測っていない。測って空欄を埋める。** 数を決め打たないのは、この冊の決め (水晶の精度は実測してから書く)。

| 測る所 | 見るべき値 | 分かること |
| --- | --- | --- |
| `led` の周期 (平均) | 1.000 s (設計値) からの差を (測って書く) | クロックが水晶で決まっていること |
| 2 つの水晶の差 | (測って書く) ppm | Pico 2 と AD3 の相対のずれ |
| 測る時間と分解能 | (測って書く) s、(測って書く) ppm | 上の表の分解能。ずれより細かいか |
| 1 日のずれ | (測って書く) s (= ppm × 0.0864) | 時計にしたら、1 日にこれだけずれる |
| 取り込みごとのばらつき | (測って書く) ppm | 3 回測って、結果が揃うか (室温の影響も) |

この ppm は、7-6 で「ボーレートのずれは何 % まで許されるか」を考えるときの土台になる。
FPGA の水晶 (Tang Nano 9K の 27 MHz の発振器) との比べは 12-4。

## シミュレーションでの確かめ (対象外を含む)

この題に新しい Verilog や `.cpp` は無い (5-11 の `clock511.cpp` を使う)。表の数と、`blink` の 1 Hz の作り方を計算と PC のシミュレーションで確かめた。

| 項目 | 本文の数字 | 実行結果 | 判定 |
| --- | --- | --- | --- |
| ppm と 1 日・1 時間のずれ (7 行) | 1 ppm = 0.0864 s・3.6 ms … 200 ppm = 17.3 s・720 ms | ppm × 0.0864 s、ppm × 3.6 ms と同じ | 計算値として合った |
| 分解能の表 (5 行) | 約 31・約 31・10・1・0.1 ppm | 1 ms ÷ 32 s = 31.25、10 ms ÷ 327 s = 30.6、1 ms ÷ 100 s = 10、1 ms ÷ 1000 s = 1、0.1 ms ÷ 1000 s = 0.1 ppm | 計算値として合った |
| 1 回の取り込みの限界 | 1 ÷ 32 768 = 約 31 ppm | 30.5 ppm | 合った |
| 250 ppm の例 | 4.001 s を読むと 250 ppm | (4.001 − 4) ÷ 4 = 250 ppm | 合った |
| `blink` の周期 | 1 kHz で 1000 クロック = 1 s | 5-7 の PC 試験で LED が 500 クロックごとに反転 (周期 1000 クロック) | 合った |
| 1 kHz の PWM | 150 MHz ÷ (3 × 50 000) = 1 kHz | 5-11 の表のとおり (`div` = 3、`wrap` = 49 999) | 合った |

確かめられなかったもの。

- 水晶のずれの実測値と、AD3 の時間の基準との差 (実機)。Logic の Record の有無も確かめていない (本文も確かめていないと書いてある)

## 出典

自作。水晶のずれと時計の関係 (ppm と秒) は計算による。PWM の設定は 5-11。AD3 の Logic と Record は 0-4・02-analog-discovery/02-oscilloscope/11-record-mode.md。

参考: [水晶振動子 (Wikipedia)](https://ja.wikipedia.org/wiki/水晶振動子)、[ppm (Wikipedia)](https://ja.wikipedia.org/wiki/ppm)
