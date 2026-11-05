---
book: analog-discovery
chapter: 7
id: 7-12
title: ゲートの伝搬遅延を Pattern + Scope で
tier: 200
source: 自作 (計器の操作は WaveForms のヘルプの Patterns と Scope)
board: BB
---

# 7-12 ゲートの伝搬遅延を Pattern + Scope で

ゲートの入力が変わってから出力が変わるまでには、少しの遅れ (**伝搬遅延** t<sub>pd</sub>) がある。74HC04 では 1 段 10 ns ほどで、
Logic (125 MS/s、1 標本 8 ns) では 1 標本と区別がつかない。そこで **Pattern で 1 MHz の方形波を作って 6 段のインバータに通し**、
入口と出口を Scope の 2 本で同時に見る。6 段ぶんなら 70 ns ほどになり、カーソルで読める。

もう 1 つの要点は、Scope の帯域 (付属のワイヤで 9 MHz) が作る縁のなまり (立ち上がり約 39 ns) が、**読みたい遅れより長い**こと。
それでも 2 本が同じ帯域を通るので、**50 % の点どうしの時間差**はなまりに左右されにくい。この題ではそれを LTspice でも確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 74HC04 の 6 段を Pattern の方形波で叩き、入口と出口を Scope で見る
parts:
  AD:
    type: device
    at: 2,5
    label: Analog Discovery 3
    pins: [V+, DIO0, 1+, 2+, GND, 1-, 2-]
    turn: mirror
  VCC: vcc 5,2 3.3V
  G1: ground 5,7
  C1: capacitor 6.5,2 6.5,3 100n
  G2: ground 6.5,3
  U1A: not 7,4 74HC04
  U1B: not 9,4 74HC04
  U1C: not 11,4 74HC04
  U1D: not 13,4 74HC04
  U1E: not 15,4 74HC04
  U1F: not 17,4 74HC04
wires:
  - AD.V+ -| 5,2
  - 5,2 -- 6.5,2
  - AD.GND -| 5,7
  - AD.DIO0 -| 6,4
  - 6,4 -- U1A.in
  - U1A.out -- U1B.in
  - U1B.out -- U1C.in
  - U1C.out -- U1D.in
  - U1D.out -- U1E.in
  - U1E.out -- U1F.in
  - U1F.out -- 19,4
  - AD.1+ -| 6,4
  - AD.2+ -| 19,4
  - AD.1- -| 5,7
  - AD.2- -| 5,7
notes:
  - text 8,6.5 small left: "U1 は 74HC04 (14 番 VCC を +3.3V・7 番 GND)"
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/12-gate-delay.svg)

- 74HC04 の 6 個のインバータを数珠つなぎにする (1 番 → 2 番 → 3 番 → … → 13 番 → 12 番)。6 回反転するので、出口 (12 番) は入口 (1 番) と同じ向きの波になる
- 入口は Pattern の DIO0。同じ点を Scope の 1+ で、出口を 2+ で見る。1−・2− は GND
- 電源は Supplies の V+ を 3.3 V。DIO の H (3.3 V) を確実に H と読ませるため (7-15)。C1 (0.1 µF (マイクロファラド)) は電源のデカップリング

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (U1 は 74HC04)
board: half
parts:
  U1: dip14 @ e10 74HC04
  C1: capacitor c8 -t8 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1-, 2-, DIO0, 1+, 2+]
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - AD.1- -- -t4 black
  - AD.2- -- -t5 black
  - AD.DIO0 -- a6 yellow
  - AD.1+ -- a7 blue
  - AD.2+ -- a12 green
  - f6 -- e6 yellow
  - d6 -- d7 yellow
  - j6 -- j10 yellow
  - a10 -- +t10 red
  - d8 -- d10 red
  - j16 -- -b16 black
  - -t28 -- -b28 black
  - g11 -- g12 white
  - g13 -- g14 white
  - i15 -- i18 orange
  - f18 -- e18 orange
  - a18 -- a15 orange
  - b16 -- b13 white
  - c14 -- c11 white
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/12-gate-delay.svg)

- U1 (74HC04) は 10〜16 列、切り欠きが左で 1 番が左下 (f10)。14 番 (VCC、10 列の上) を + レールへ、7 番 (GND、16 列の下) を下の − レールへ。C1 は 8 列と − レールの間で、d 行の赤い線で VCC の列へつなぐ
- 下の列の 1Y→2A・2Y→3A は g 行の白い短い線。3Y (15 列の下) は橙の線で 18 列へ出し、溝を渡って上の 4A (15 列の上) へ戻す。
  上の列の 4Y→5A・5Y→6A は b 行・c 行の白い線。出口の 6Y は 12 列の上
- AD3 は上に置く。DIO0 (黄) を 6 列へ入れ、黄の線で 1A (10 列の下) へ運ぶ。1+ (青) は同じ入口の点 (6 列と線でつないだ 7 列)、2+ (緑) は 6Y の 12 列。
  1−・2− と GND は上の − レール。上下の − レールは 28 列でつなぐ
- 入口と出口の線の長さは、どちらもワイヤ 1 本ぶんにそろえる (長さの差は 1 cm で 0.05 ns ほどなので、この題では効かない)

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Pattern | DIO0 = Clock、1 MHz、Duty 50 %、Output PP (プッシュプル) |
| Scope CH1 (1+) | 入口 (1 番)。1 V/div、0 V を中央の 2 目盛下 |
| Scope CH2 (2+) | 出口 (12 番)。CH1 と同じ尺度で重ねる |
| Scope の時間 | 20 ns/div、Sample Rate は最速の 125 MS/s。トリガは CH1 の立ち上がり 1.65 V、トリガの点を左から 2 目盛 |
| カーソル | X1 = CH1 が 1.65 V を切る点 (0)、X2 = CH2 が 1.65 V を切る点 |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入口 (CH1) と 6 段の出口 (CH2) — 50 % の点の差が 6 段ぶんの遅れ
time: 20ns/div
trigger: ch1 rising 1.65V at -3div
ch1: {wave: square 1MHz 1.65V offset 1.65V | rc 17.7ns, range: 1V/div, position: -2div}
ch2: {wave: ch1 | delay 72ns, range: 1V/div, position: -2div}
cursors: [0, 72ns]
measure: [rise, vmax]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/scope/12-gate-delay.svg)

図3 は計算で作った理想の画面で、実測ではない。1 段の遅れを 12 ns と仮定し (下の「見るべき値」)、6 段で 72 ns。Scope の帯域は
9 MHz の 1 次の低域 (時定数 17.7 ns) と仮定した。どちらの縁も 10〜90 % で約 39 ns なまるが、形が同じなので、1.65 V を切る時刻の差 ΔX は
6 段の遅れそのもの (72 ns) になる。立ち下がりでも同じように読み、2 つを平均する (74HC の t<sub>PLH</sub> と t<sub>PHL</sub> は少し違う)。

1 標本は 8 ns なので、カーソルは標本の間を読む。**1 回の取り込みでは ±8 ns ほどぶれる**。Repeated で何回か取り込み、
ΔX の真ん中を読む。Pattern の DIO0 と Scope は同じ AD3 の中の時計で動くので、毎回同じ縁が画面に来る。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | インバータ (6 回路) | 74HC04 (DIP-14、3.3 V で使う) |
| C1 | セラミックコンデンサ | 0.1 µF (104) |
| — | 電源・信号源・計器 | Analog Discovery 3 (Supplies 3.3 V、Pattern、Scope) |

電流は 1 MHz で切り替えても 1 mA に届かない (入力と配線の容量を数 pF とした見積り)。Supplies の範囲に十分収まる。

## 見るべき値

1 段の遅れは目安。TI の SN74HC04 のデータシートは、負荷 50 pF で t<sub>pd</sub> の典型が 4.5 V で 9 ns、2 V で 45 ns。
3.3 V の値は載っていないので、その間で 12 ns と置いた (この題の負荷は次の段の入力と配線の数 pF で、50 pF より軽いので速めに出る)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 と CH2 の 1.65 V の点の差 (立ち上がり) | 約 70 ns (目安。6 段 × 12 ns) | 6 段ぶんの伝搬遅延 |
| 同じく立ち下がり | 約 70 ns (立ち上がりと数 ns 違ってよい) | t<sub>PLH</sub> と t<sub>PHL</sub> |
| 1 段あたり | ΔX ÷ 6 ≈ 12 ns (目安) | データシートの 4.5 V の 9 ns と 2 V の 45 ns の間に入る |
| CH1・CH2 の立ち上がり (Rise、10〜90 %) | どちらも約 39 ns | Scope の帯域 (0.35 ÷ 9 MHz) が決めるなまり。ゲートの縁はこれより速く見えない |
| V+ を 2.5 V に下げる | ΔX が延びる | CMOS は電源電圧が低いほど遅い |
| 2+ を 2 番 (1 段目の出口) に替える | 反転した波で、差は 12 ns ほど | 1 標本 8 ns と同じ程度で読みにくい。6 段にした理由 |

## LTspice での確かめ

`sim/12-gate-delay.cir` で、1 段を 12 ns 遅れる理想のインバータ (仮定) として 6 段つなぎ、入口と出口を 9 MHz の 1 次の低域 (Scope の帯域の仮定) に通して
1.65 V の点の差を読んだ。インバータの遅れも Scope の帯域も仮定で、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 1 段の遅れ (1 番 → 2 番) | 12 ns (仮定) | 12.0 ns | 合う (仮定どおりに組めている) |
| 6 段の遅れ (帯域を通す前) | 約 72 ns | 72.2 ns | 合う |
| 6 段の遅れ (Scope の 2 本で読む、立ち上がり) | 約 72 ns | 73.6 ns | 合う (差 1.4 ns。出口の縁が少し遅いぶん) |
| 同じく立ち下がり | 約 72 ns | 73.7 ns | 合う |
| CH1・CH2 の立ち上がり (10〜90 %) | 約 39 ns | 38.8 ns・40.2 ns | 合う |

なまり (39 ns) が遅れの 1 段ぶん (12 ns) より長くても、2 本の 50 % の点の差は 2 % ほどしか変わらなかった。

## 出典

自作。計器の名前と操作は WaveForms のヘルプ (Patterns の Clock、Scope) と Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer) (Pattern Generator の節)。

参考: [Texas Instruments SN74HC04 データシート](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf)、[伝搬遅延 (Wikipedia)](https://ja.wikipedia.org/wiki/伝搬遅延)
