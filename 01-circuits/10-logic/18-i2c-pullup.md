---
book: circuits
chapter: 10
id: 10-18
title: I2C バスの電気 — プルアップと容量
tier: 200
source: 自作 (数の決まりは NXP の I2C-bus specification UM10204)
era: 今
---

# 10-18 I2C バスの電気 — プルアップと容量

I2C は、SDA (データ) と SCL (クロック) の 2 本の線に、マイコンとセンサーを何個もぶら下げるバスである。
どの IC も 10-16 のオープンドレインで、線を L に引くか手を離すかしかしない。H に戻すのはプルアップの抵抗 Rp だけ。
11-5 で Pico 2 と温度センサーを I2C でつないだときは、プルアップを 4.7 kΩ にした。この題では、その値をどう決めるかを、線の電気だけで確かめる。

線には配線と、ぶら下がった IC の入力の容量 C<sub>b</sub> (バスの容量) がある。手を離した線は Rp で C<sub>b</sub> を充電して戻るので、
Rp が大きすぎると H に戻りきらないうちに次のビットが来る。小さすぎると、L に引く IC が電流を吸い込みきれない。

## この実験で確かめる式

I2C の規格 (UM10204) は、立ち上がり t<sub>r</sub> を V<sub>DD</sub> の 30 % から 70 % までの時間で決め、標準モード (100 kHz) で 1000 ns 以下、
ファストモード (400 kHz) で 300 ns 以下とする。L は 3 mA を吸い込んで 0.4 V 以下。バスの容量は 400 pF まで。

- 30 % → 70 % の時間: t<sub>r</sub> = R<sub>p</sub> C<sub>b</sub> × ln(0.7 ÷ 0.3) ≈ 0.8473 R<sub>p</sub> C<sub>b</sub>
- R<sub>p</sub> の上限: R<sub>p</sub> ≤ t<sub>r</sub> ÷ (0.8473 C<sub>b</sub>)
- R<sub>p</sub> の下限: R<sub>p</sub> ≥ (V<sub>DD</sub> − 0.4 V) ÷ 3 mA。5 V なら 1.53 kΩ、3.3 V なら 0.97 kΩ

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 I2C の SCL の線の電気 (2N7000 が引き Rp が戻す。Cb はバスの容量)
parts:
  VCC: vcc 8,1 5V
  Rp: resistor 8,1 8,3 4.7k
  Q1: nmos 5,5 2N7000
  GQ1: ground 5,6
  Cb: capacitor 10,3 10,5 330p
  GCb: ground 10,5
  SCL: port 12,3 inout
  W1: port 2,5 in
wires:
  - Q1.D -- 5,3 -- 8,3
  - 8,3 -- 10,3
  - 10,3 -- 12,3
  - Q1.S -- 5,6
  - 2,5 -| Q1.G
notes:
  - text 1,8 small left: "Cb は 100 pF と 330 pF、Rp は 2.2k・4.7k・10k に替えて比べる"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/18-i2c-pullup.svg)

- Q1 (2N7000) が SCL を L に引く IC の出力の代わり。ゲートに W1 (100 kHz、0〜5 V) を入れ、5 V の間だけ SCL を引く
- Rp が SCL を 5 V へ引き上げる。Cb (330 pF または 100 pF) はバスの容量の代わりで、実物のバスなら配線 (1 m で数十 pF が目安) と、
  ぶら下がった IC の入力 (1 個 10 pF が目安) の和になる
- この題のバスは 5 V。Pico 2 につなぐときは 3.3 V で、上の式の V<sub>DD</sub> と、30 %・70 % の電圧が変わる (0.99 V・2.31 V)。5 V と 3.3 V の IC を
  同じバスに載せるときは、10-17 の変換回路を挟む
- SDA も同じ形の線で、同じ式に従う (この題では SCL の 1 本だけを組む)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Rp と Cb を差し替えて比べる)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 Supplies・Wavegen・Scope
    pins: [GND, V+, 1+, W1, 2+, 1-, 2-]
  Q1: transistor e5 e6 e7 2N7000
  Rp: resistor c7 c11 4.7k cap=right
  Cb: capacitor/ceramic b7 b9 330p cap=right
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t1 black
  - a5 -- -t5 black
  - a9 -- -t9 black
  - a11 -- +t11 red
  - b6 -- b3 yellow
  - AD.1+ -- a3 white
  - AD.W1 -- a6 yellow
  - AD.1- -- -t8 black
  - AD.2+ -- a7 blue
  - AD.2- -- -t13 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/18-i2c-pullup.svg)

- 電源は AD3 の Supplies の V+ (5 V) を上の赤レールへ、GND を上の青レールへ
- Q1 (2N7000) は 5〜7 列で、平らな面を手前にして S・G・D (資料が食い違うので、実物はテスタで確かめる)。S (5 列) を青レールへ
- D (7 列) が SCL。Rp (7〜11 列) と赤の線で +5 V へ、Cb (記号 331、7〜9 列) と黒の線で GND へ
- W1 を G (6 列) に挿し、黄の線で 3 列へ渡して 1+ を挿す。2+ は SCL (7 列)
- Rp を 2.2 kΩ・4.7 kΩ・10 kΩ、Cb を 330 pF (331)・100 pF (101) に差し替え、6 通りの立ち上がりを測る。
  AD3 のオシロのプローブと配線にも容量があるので、Cb を外したときの立ち上がりも測っておくと、その分が分かる
- 電流は SCL が L の間に Rp を流れる 5 V ÷ Rp で、2.2 kΩ でも 2.3 mA。ブレッドボードの範囲にも AD3 の Supplies にも収まる

## 計器の設定

計器は AD3 の Supplies・Wavegen (W1)・Scope。SCL の立ち上がりを 1 目盛 1 µs で拡大し、30 % (1.5 V) と 70 % (3.5 V) にカーソルを置いて時間を読む。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V |
| W1 | Square、100 kHz、0〜5 V (Amplitude 2.5 V、Offset 2.5 V) |
| CH1 (1+) | ゲート (W1)。2 V/div、0 V を下から 1 目盛 |
| CH2 (2+) | SCL。CH1 と同じ尺度 |
| 時間 | 1 µs/div、トリガは CH1 の立ち上がり 2.5 V、トリガの点を左端 |
| カーソル | X1 = 5.55 µs (SCL が 1.5 V)、X2 = 6.87 µs (SCL が 3.5 V) — Rp 4.7 kΩ・Cb 330 pF のとき |
| Measurements | Frequency (W1 の 100 kHz を確かめる) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 Rp 4.7 kΩ・Cb 330 pF の SCL の立ち上がり (30 → 70 % に 1.3 µs、計算)
time: 1us/div
trigger: ch1 rising 2.5V at -5div
ch1: {wave: square 100kHz 2.5V offset 2.5V, range: 2V/div, position: -3div}
ch2: {wave: = step(t-5us)*5V*(1-exp(-(t-5us)/1.551us)), range: 2V/div, position: -3div}
cursors: [5.553us, 6.868us]
measure: [freq]
notes:
  - text ch2 5.553us 1.5V: 30 %
  - text ch2 6.868us 3.5V: 70 %
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/18-i2c-pullup.svg)

- 図3 は計算で作った理想の波形 (τ = 4.7 kΩ × 330 pF = 1.55 µs)。0〜5 µs は Q1 が SCL を 0 V に引く。5 µs で手を離すと、
  SCL は τ で 5 V へ向かい、30 % から 70 % まで 1.31 µs (LTspice では Q1 の容量の分で 1.33 µs)
- この線では標準モードの決まり (1000 ns) を守れない。Rp を 2.2 kΩ に下げると 0.62 µs で収まる
- 立ち下がりは Q1 が直接引くので 10 ns ほどで、この時間軸では縦の線 (10-16)

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | N ch MOSFET | 2N7000 (TO-92) |
| Rp | 抵抗 (1/4 W)、プルアップ | 2.2 kΩ・4.7 kΩ・10 kΩ (差し替える) |
| Cb | セラミックコンデンサ (C0G)、バスの容量の代わり | 330 pF (331)・100 pF (101) |
| — | 電源・信号源・計器 | Analog Discovery 3 |

Rp が 2.2 kΩ のとき、L の間の電力は 5 V × 2.3 mA = 11 mW で、1/4 W の半分より小さい。

## 見るべき値

30 % → 70 % の立ち上がり t<sub>r</sub> (計算 0.8473 R<sub>p</sub> C<sub>b</sub>。括弧は LTspice)。標準モードは 1000 ns 以下、ファストモードは 300 ns 以下。

| C<sub>b</sub> \ R<sub>p</sub> | 2.2 kΩ | 4.7 kΩ | 10 kΩ |
| --- | --- | --- | --- |
| 100 pF | 186 ns (195 ns): ファストも可 | 398 ns (418 ns): 標準だけ | 847 ns (889 ns): 標準だけ |
| 330 pF | 615 ns (624 ns): 標準だけ | 1314 ns (1334 ns): どちらも不可 | 2796 ns (2837 ns): どちらも不可 |

| 項目 | 値 (5 V のバス) |
| --- | --- |
| R<sub>p</sub> の下限 (3 mA で 0.4 V) | (5 V − 0.4 V) ÷ 3 mA = 1.53 kΩ → E24 で 1.6 kΩ 以上 |
| R<sub>p</sub> の上限 (標準モード、C<sub>b</sub> 100 pF / 330 pF) | 11.8 kΩ / 3.58 kΩ |
| R<sub>p</sub> の上限 (ファストモード、C<sub>b</sub> 100 pF / 330 pF) | 3.54 kΩ / 1.07 kΩ (下限より小さく、330 pF では作れない) |
| L の間に Rp を流れる電流 (2.2 kΩ / 10 kΩ) | 2.3 mA / 0.5 mA |

- 4.7 kΩ がよく使われるのは、3.3 V か 5 V のバスで、容量の小さい (100 pF 前後) 短い配線なら標準モードに余裕で収まり、電流も 1 mA 前後で済むから
- センサーの基板 (モジュール) にはプルアップが載っていることが多い。何枚もつなぐと並列で小さくなり、下限を割ることがある (11-5)

## LTspice での確かめ

`sim/18-i2c-pullup.cir` で、2N7000 を他の題と同じ LEVEL 1 の近似 (ドレインの容量 10 pF を含む。仮定) にし、(R<sub>p</sub>, C<sub>b</sub>) の 6 通りを同じ回路 6 組で並べて解いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| t<sub>r</sub> (2.2 kΩ・100 pF / 4.7 kΩ・100 pF / 10 kΩ・100 pF) | 186 / 398 / 847 ns | 195 / 418 / 889 ns | 合う (5 % 長い。Q1 の容量の分) |
| t<sub>r</sub> (2.2 kΩ・330 pF / 4.7 kΩ・330 pF / 10 kΩ・330 pF) | 615 / 1314 / 2796 ns | 624 / 1334 / 2837 ns | 合う |
| L の間の電流 (2.2 kΩ / 10 kΩ) | 2.3 mA / 0.5 mA | 2.27 mA / 0.500 mA | 合う |
| L の電圧 (2.2 kΩ / 10 kΩ) | 数 mV | 7.8 mV / 1.7 mV | 合う |

## 出典

自作。数の決まり (30 %・70 %、1000 ns・300 ns、3 mA で 0.4 V、400 pF) は NXP の I2C-bus specification and user manual (UM10204) による。

参考: [I2C (Wikipedia)](https://ja.wikipedia.org/wiki/I2C)、[2N7000 データシート (Vishay)](https://www.vishay.com/docs/70226/70226.pdf)
