---
book: analog-discovery
chapter: 7
id: 7-17
title: デバウンス回路の評価 (Static I/O + Scope)
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Static I/O と Scope)
board: BB
---

# 7-17 デバウンス回路の評価 (Static I/O + Scope)

7-9 で跳ね (チャタリング) を Logic で捕まえ、回路の教科書の 10-9 で RC + シュミットトリガ (74HC14) で消す回路を組んだ。
この題はその回路を**評価する**。1 回の波形を見るだけでは、たまたまうまくいった押し方かもしれない。そこで 4 ビットのカウンタ 74HC393 を 2 つ
(1 個に 2 回路) 足し、**RC を通した出力 Y1 と、通さない出力 Yraw のそれぞれが数えたパルスの数**を Static I/O の LED で読む。
何回も押して「押した回数 = Y1 の数」が崩れないか、C1 を小さくするとどこで崩れるかを確かめ、押してからの遅れを Scope で測る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 10-9 の RC + 74HC14 の 2 本の出力を 74HC393 で数える
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,1 2,3 10k
  SW: button 2,3 2,5 l=$\mathrm{SW}$
  GSW: ground 2,5
  R2: resistor 3,3 5,3 10k
  C1: capacitor 5,4 5,6 1u
  GC1: ground 5,6
  U1A: not 8,3 74HC14
  U1B: not 8,8 74HC14
  U2: ic 14,6 74HC393
  VCC: vcc 14,3.25 5V
  G9: ground 14,9
  LA:
    type: device
    at: 20,6
    label: AD3 Logic (Static I/O)
    pins: [DIO0, DIO1, DIO2, DIO3, DIO4, DIO5, DIO6, DIO7]
wires:
  - 2,3 -- 3,3
  - 5,3 -- 5,4
  - 5,3 -- U1A.in
  - 3,3 -- 3,8 -- U1B.in
  - U1A.out -- 10,3
  - U2.1CLK -| 10,3
  - U1B.out -- 10,8
  - U2.2CLK -| 10,8
  - U2.VCC |- 14,3.25
  - U2.GND |- 13.5,9
  - U2.1CLR |- 14,9
  - U2.2CLR |- 14.5,9
  - 13.5,9 -- 14,9
  - 14,9 -- 14.5,9
  - U2.1QA -- 18.5,4.5
  - 18.5,4.5 -- 18.5,5.25
  - 18.5,5.25 -- LA.DIO0
  - U2.1QB -- 18,5
  - 18,5 -- 18,5.5
  - 18,5.5 -- LA.DIO1
  - U2.1QC -- 17.5,5.5
  - 17.5,5.5 -- 17.5,5.75
  - 17.5,5.75 -- LA.DIO2
  - U2.1QD -- LA.DIO3
  - U2.2QA -- 17,6.5
  - 17,6.5 -- 17,6.25
  - 17,6.25 -- LA.DIO4
  - U2.2QB -- 17.5,7
  - 17.5,7 -- 17.5,6.5
  - 17.5,6.5 -- LA.DIO5
  - U2.2QC -- 18,7.5
  - 18,7.5 -- 18,6.75
  - 18,6.75 -- LA.DIO6
  - U2.2QD -- 18.5,8
  - 18.5,8 -- 18.5,7
  - 18.5,7 -- LA.DIO7
notes:
  - text 1,10 small left: "Scope の 1+ を A・2+ を B (10-9 と同じ)。U1・U2 の電源は V+ の 5 V"
  - text 1,10.5 small left: "U1 (74HC14) の使わない入力 5・9・11・13 番は GND"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/17-debounce-evaluation.svg)

- 左半分は 10-9 と同じ。押していないとき A と B は 5 V、押すと A は 0 V に落ち、B は R2・C1 で τ (タウ) = 10 kΩ (オーム) × 1 µF (マイクロファラド) = 10 ms でなまって下がる
- U1A (1 番入力・2 番出力) は B を受けて Y1、U1B (3 番・4 番) は A をそのまま受けて Yraw。どちらも押すと H になる
- U2 (74HC393) は CLK の**立ち下がり**で 1 つ数える 4 ビットのカウンタ。1CLK に Y1、2CLK に Yraw。1CLR・2CLR (H で 0 に戻す) は GND に固定し、
  数え続ける。Y1 は離したときに 1 回下がるので、押して離すたびに 1 つ進む。Yraw は跳ねで A が戻るたびにも下がる
- 1QA〜1QD を DIO0〜DIO3、2QA〜2QD を DIO4〜DIO7 へ。5 V の出力が DIO に入るが、AD3 の DIO は 5 V まで耐える (7-9)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (左は 10-9 の RC と 74HC14、右が 74HC393)
board: half
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies・Scope
    pins: [V+, GND, 1+, 1-, 2+, 2-]
  LB:
    type: device
    at: top
    label: AD3 DIO4-7
    pins: [DIO4, DIO5, DIO6, DIO7]
  LA:
    type: device
    at: bottom
    label: AD3 DIO0-3
    pins: [DIO0, DIO1, DIO2, DIO3]
  R1: resistor b1 b3 10k
  SW: button @ e3
  R2: resistor b5 b8 10k
  C1: capacitor/ceramic i8 i10 1u
  U1: dip14 @ e14 74HC14
  U2: dip14 @ e24 74HC393
wires:
  - PS.V+ -- +t2 red
  - PS.GND -- -t4 black
  - -t21 -- -b21 black
  - a1 -- +t1 red
  - j3 -- -b3 black
  - j10 -- -b10 black
  - e8 -- f8 orange
  - h8 -- h14 orange
  - d5 -- d12 yellow
  - e12 -- f12 yellow
  - g12 -- g16 yellow
  - a14 -- +t14 red
  - a15 -- -t15 black
  - a17 -- -t17 black
  - a19 -- -t19 black
  - j18 -- -b18 black
  - j20 -- -b20 black
  - PS.1+ -- a5 blue
  - PS.1- -- -t6 black
  - PS.2+ -- a8 green
  - PS.2- -- -t9 black
  - i15 -- i24 white
  - j17 -- j22 purple
  - f22 -- e22 purple
  - b22 -- b25 purple
  - a24 -- +t24 red
  - j25 -- -b25 black
  - a26 -- -t26 black
  - j30 -- -b30 black
  - LA.DIO0 -- j26 yellow
  - LA.DIO1 -- j27 green
  - LA.DIO2 -- i28 blue
  - LA.DIO3 -- j29 orange
  - LB.DIO4 -- a27 yellow
  - LB.DIO5 -- a28 green
  - LB.DIO6 -- a29 blue
  - LB.DIO7 -- a30 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/17-debounce-evaluation.svg)

- 1〜20 列は 10-9 の図2 と同じ (R3 と LED は外し、Logic の線も外す)。U1 は 14〜20 列
- U2 (74HC393) は 24〜30 列、1 番 (1CLK) が左下の f24。14 番 VCC (24 列の上) を + レール、7 番 GND (30 列の下)・2 番 1CLR (25 列の下)・12 番 2CLR (26 列の上) を − レールへ
- Y1 (U1 の 2 番、15 列の下) は白い線で 1CLK (24 列の下) へ。Yraw (U1 の 4 番、17 列の下) は紫の線で 22 列へ出し、溝を渡って上の 2CLK (25 列) へ
- 1QA〜1QD (26〜29 列の下) を下の AD3 の DIO0〜DIO3 へ、2QA〜2QD (27〜30 列の上) を上の AD3 の DIO4〜DIO7 へ。AD3 は 1 台で、図では端子ごとに 3 つの箱に分けて描いた
- 上下の − レールは 21 列でつなぐ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable を入れる |
| Static I/O | 7-0 の組を Bit I/O にし、DIO0〜DIO7 を LED (入力の表示) にする。DIO3〜DIO0 が Y1 の数、DIO7〜DIO4 が Yraw の数 (2 進、右が下位) |
| Scope CH1 (1+)・CH2 (2+) | A と B。1 V/div、0 V を下から 1 目盛。250 µs/div で跳ねを、10 ms/div で遅れを見る。トリガは CH1 の立ち下がり 2.5 V、Single |

**評価の手順**: (1) 電源を入れた直後の 2 つの数を書き留める (0 とは限らない)。(2) ボタンを 5 回、間を 1 s ほど空けて押して離す。
(3) 2 つの数がいくつ進んだかを読む。4 ビットなので 16 で 0 に戻る。1 回に読むのは 5 回までにすると、一周して取り違えない。
(4) これを 3 回くり返し、15 回ぶんの合計で見る。(5) C1 を 0.1 µF、0.01 µF に替えて同じことをする。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 押した直後 — A (CH1) は跳ねるが、B (CH2) はゆっくり下がるだけ
time: 250us/div
trigger: ch1 falling 2.5V at -4div
ch1: {wave: = 5V * (step(-t) + step(t - 0.3ms) * step(0.6ms - t) + step(t - 1ms) * step(1.3ms - t)), range: 1V/div, position: -3div}
ch2: {wave: = 5V * (step(-t) + step(t) * exp(-t / 10ms)), range: 1V/div, position: -3div}
cursors: [0.45ms, 1.15ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/17-debounce-evaluation.svg)

図3 は跳ねを仮定して計算した理想の画面で、実測ではない (押した直後の 0.3〜0.6 ms と 1.0〜1.3 ms に接点が開くとした。10-9 と同じ仮定)。
X1・X2 は跳ねで A が 5 V に戻った所で、B は 4.78 V・4.46 V。74HC14 の V<sub>T−</sub> (約 1.7 V、5 V での目安) よりずっと上なので、Y1 は動かない。
図の B は跳ねの間に少し充電し直す分を入れていない (入れた 10-9 の LTspice では最小 4.62 V)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | シュミットトリガのインバータ (6 回路) | 74HC14 (DIP-14) |
| U2 | 4 ビットの 2 進カウンタ (2 回路) | 74HC393 (DIP-14) |
| R1・R2 | 抵抗 (1/4 W) | 10 kΩ × 2 |
| C1 | 積層セラミックコンデンサ | 1 µF (105)。評価で 0.1 µF (104)・0.01 µF (103) に替える |
| SW | タクトスイッチ | 1 個 |
| — | 電源・計器 | Analog Discovery 3 (Supplies 5 V、Static I/O、Scope) |

## 見るべき値

数は LTspice (下) の仮定の跳ねで、3 回押したときの値。実物の跳ねは押し方と個体で変わるので、Yraw の数はこれと違ってよい。

| C1 | Y1 の数 (3 回押す) | Yraw の数 | 押してから Y1 が H | 離してから Y1 が L | 判定 |
| --- | --- | --- | --- | --- | --- |
| 1 µF | 3 (1 回に 1) | 9 (1 回に 3) | 約 11 ms | 約 17 ms | よい |
| 0.1 µF | 3 | 15 (1 回に 5) | 約 1.9 ms | 約 2.5 ms | よい (跳ねの続く時間しだい) |
| 0.01 µF | 15 (1 回に 5) | 15 | 0.1 ms ほど | — (跳ねのたびに切り替わる) | **だめ** (跳ねが Y1 に通る) |

- **Y1 の数 = 押した回数** が 15 回押しても崩れなければ、その C1 は手元のボタンに足りている。1 つでも多ければ足りない
- Yraw の数 − 押した回数 が、跳ねで余分に数えた回数。7-9 で見た跳ねの数と比べる
- 遅れは Scope の 10 ms/div で、A の立ち下がり (押した瞬間) から、Y1 の代わりに B が V<sub>T−</sub> を切る所までをカーソルで読む。
  C1 を大きくすれば確実になるが、押してから反応するまでが延びる。評価は「余分に数えない」と「遅すぎない」の両方で決める
- C1 0.1 µF で Yraw が増えるのは、離したときの A の戻りが速くなり、離す側の跳ねも通るから (1 µF では 10-9 の説明のとおり A が 2.5 V で止まり、離す側の跳ねが出ない)

## LTspice での確かめ

`sim/17-debounce-count.cir` で、10-9 と同じ回路と跳ねの仮定 (押す・離すの直後に 2 回ずつ 0.3 ms 跳ねる) で 3 回押し、C1 を 1 µF・0.1 µF・0.01 µF に振って、
Y1 と Yraw の立ち下がり (74HC393 が数える向き) を数えた。74HC14 は LTspice の SCHMITT 素子 (しきい値 2.8 V・1.7 V、目安) で置き換えた。跳ねもしきい値も仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Y1 の立ち下がり (1 µF・0.1 µF・0.01 µF) | 3・3・15 | 3・3・15 | 合う |
| Yraw の立ち下がり (同) | 9・15・15 | 9・15・15 | 合う |
| 押してから Y1 が H (1 µF・0.1 µF・0.01 µF) | 約 11 ms・約 1.9 ms・0.1 ms ほど | 11.4 ms・1.85 ms・0.11 ms | 合う (1 µF は 10-9 と同じ) |
| 離してから Y1 が L (1 µF・0.1 µF) | 約 17 ms・約 2.5 ms | 16.9 ms・2.5 ms | 合う |

図3 の CH2 は 5 V × e<sup>−t/10 ms</sup> の算術で、0.45 ms で 4.78 V、1.15 ms で 4.46 V。

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Static I/O の Bit I/O、Scope)。

参考: [Texas Instruments SN74HC14 データシート](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf)、[Texas Instruments SN74HC393 データシート](https://www.ti.com/lit/ds/symlink/sn74hc393.pdf)、[チャタリング (Wikipedia)](https://ja.wikipedia.org/wiki/チャタリング)
