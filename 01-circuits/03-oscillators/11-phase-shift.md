---
book: circuits
chapter: 3
id: 3-11
title: 移相発振 (RC 3 段)
tier: 200
source: 自作
era: 古
---

# 3-11 移相発振 (RC 3 段)

エミッタ接地の増幅 (2-3) は、入力と出力が逆の向き (位相が 180° ずれる) になる。その出力を、**1 つの周波数でちょうど 180° ずらす回路**に通して
入力へ戻すと、合わせて 360° で同じ向きに戻り、その周波数だけが輪を回り続ける。ずらす回路を C と R の 3 段の梯子 (はしご) で作るのが
移相発振回路 (phase-shift oscillator) で、コイルを使わずに正弦波に近い波を作る古典の回路である。

- **なぜ 3 段か**: C と R の 1 段がずらせるのは 90° 未満。2 段では 180° に届かず、3 段で初めて 180° になる周波数ができる
- **周波数**: 3 段が同じ R と C で、梯子の入口に Q1 のコレクタの抵抗 RC がつながるとき、f ≈ 1 / (2πRC√(6 + 4R<sub>C</sub>/R))。
  π (パイ) は円周率。この題は R = R<sub>C</sub> = 4.7 kΩ (Ω はオーム)、C = 10 nF なので f ≈ 1 / (2π × 4.7 kΩ × 10 nF × √10) ≈ **1.07 kHz**
- **利得の条件**: 180° ずれる周波数で、梯子は振幅も小さくする。R<sub>C</sub> = R のとき、トランジスタの電流増幅率 hFE が
  23 + 29 + 4 = **56 以上**でないと発振しない (梯子の弱め分を取り返せない)。2SC1815 の GR ランク (hFE 200〜400) なら十分にある

3 段目の R は、別の部品ではなく**ベースから見た抵抗** (R1・R2 と、トランジスタの入力の抵抗の並列。約 4.4 kΩ) が兼ねる。
この題では、組んだ回路が約 1.1 kHz で発振し、コレクタ (CH1) とベース (CH2) が逆の向きに動き、振幅が約 55 倍違うことを見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 移相発振回路 (RC 3 段で 180° 遅らせ、Q1 で反転して戻す)
parts:
  VCC: vcc 2,1 5V
  R1: resistor 2,1 2,4 33k
  R2: resistor 2,7 2,9 10k
  G1: ground 2,9
  RC: resistor 4,1 4,3 4.7k
  Q1: npn 4,5 2SC1815
  RE: resistor 4,6 4,8 1k
  G2: ground 4,8
  CE: ecap 6,6 6,8 100u
  G3: ground 6,8
  M1: voltmeter 5,3 5,5 l=$\mathrm{CH1}$
  G4: ground 5,5
  C1: capacitor 6,3 7,3 10n
  R3: resistor 8,3 8,5 4.7k
  G5: ground 8,5
  C2: capacitor 9,3 10,3 10n
  R4: resistor 11,3 11,5 4.7k
  G6: ground 11,5
  C3: capacitor 12,3 13,3 10n
  M2: voltmeter 8,10 8,12 l=$\mathrm{CH2}$
  G7: ground 8,12
wires:
  - 2,1 -- 4,1
  - 2,4 -- 2,5
  - 2,5 -- Q1.B
  - 2,5 -- 2,6
  - 2,6 -- 2,7
  - 4,3 |- Q1.C
  - 4,3 -- 5,3
  - 5,3 -- 6,3
  - Q1.E -- 4,6
  - 4,6 -- 6,6
  - 7,3 -- 8,3
  - 8,3 -- 9,3
  - 10,3 -- 11,3
  - 11,3 -- 12,3
  - 13,3 -- 14,3
  - 14,3 -- 14,10
  - 14,10 -- 8,10
  - 8,10 -- 1,10
  - 1,10 -- 1,6
  - 1,6 -- 2,6
style:
  grid: on
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/circuit/11-phase-shift.svg)

- 図1 の左がエミッタ接地の増幅 (2-3 と同じ形で、RE を CE でバイパス)。右へ伸びる C1・R3、C2・R4、C3 が梯子の 3 段
- C3 から先の線は下を回ってベースへ戻る。この輪が帰還で、梯子を右へ進むほど位相が遅れ、ベースへ戻る所で 180° になる
- CH1 はコレクタ、CH2 はベース (輪の戻り)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (Q1 と RE・R2 は下、RC・R1 と RC の 3 段は上)
board: half
parts:
  AD:
    type: device
    at: top
    label: AD3 (Supplies 5V と Scope)
    pins: [V+, GND, 1-, 2-, 1+, 2+]
  Q1: transistor h9 h10 h11 2SC1815 cap=right
  RE: resistor i9 i5 1k
  CE: capacitor/electrolytic f9(+) f5(-) 100uF
  R2: resistor j11 -b11 10k cap=right
  RC: resistor b6 b10 4.7k
  R1: resistor b11 b15 33k
  C1: capacitor d10 d16 10n
  R3: resistor a16 -t16 4.7k
  C2: capacitor e16 e20 10n
  R4: resistor a20 -t20 4.7k
  C3: capacitor d20 d24 10n
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - -t3 -- -b3 black
  - +t6 -- a6 red
  - +t15 -- a15 red
  - j5 -- -b5 black
  - e10 -- f10 orange
  - e11 -- f11 green
  - e24 -- f24 yellow
  - i24 -- i11 yellow
  - AD.1+ -- a10 orange
  - AD.2+ -- a11 green
  - AD.1- -- -t4 black
  - AD.2- -- -t5 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/breadboard/11-phase-shift.svg)

図2 は、Q1 と RE・CE・R2 を下のブロックに、RC・R1 と梯子を上のブロックに置いた。

- 電源は AD3 の Supplies (V+ を 5 V)。上の + レールと − レールへ入れ、3 列の黒い線で下の − レールへ渡す。回路が流す電流は約 0.6 mA
- **2SC1815 は平らな面を手前 (j 行側) にして h 行に、左から E・C・B (9・10・11 列)**
- エミッタ (9 列): RE (`i5`–`i9`) と CE (`f9`–`f5`、+ が 9 列) は 5 列に集め、5 列から下の − レールへ。ベース (11 列): R2 は下の − レールへ縦に
- コレクタ (10 列) は橙、ベース (11 列) は緑の線で上のブロックへ持ち上げる。RC (`b6`–`b10`) と R1 (`b11`–`b15`) は 6・15 列から + レールへ
- 梯子は上のブロックを右へ: C1 (`d10`–`d16`)、R3 (16 列から − レール)、C2 (`e16`–`e20`)、R4 (20 列から − レール)、C3 (`d20`–`d24`)。
  24 列から黄の線で下のブロックへ渡り、`i24`–`i11` の黄の線でベースへ戻る
- Scope の 1+ (橙) はコレクタ (`a10`)、2+ (緑) はベース (`a11`)。1− と 2− は上の − レールへ

## 計器の設定

オシロには AD3 の Scope を使う。1 kHz ほどの正弦波の周期と、コレクタとベースの振幅の比・向きを見る題で、10 MHz よりずっと低いから。

| 設定 | 値 |
| --- | --- |
| Scope CH1 (コレクタ、10 列) | DC、1 V/div |
| Scope CH2 (ベース、11 列) | DC、20 mV/div、オフセットで 1.13 V を中央に |
| Time | 200 µs/div (2 ms に約 2.2 周期) |
| Trigger | CH1、立ち上がり、2.5 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 コレクタ (CH1) とベース (CH2) — 逆の向きで約 1.1 kHz、振幅は約 55 倍違う
time: 200us/div
trigger: ch1 rising 2.5V
ch1: {wave: sine 1107Hz 3.78Vpp offset 2.5V, range: 1V/div, position: -2.5div}
ch2: {wave: sine 1107Hz 69mVpp offset 1.135V phase 180deg, range: 20mV/div, position: -56.75div}
cursors: [226us, 1129us]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/03-oscillators/scope/11-phase-shift.svg)

図3 は LTspice の値で描いた想定の波形で、実測ではない。基本波だけを正弦波で描いた。実際のコレクタは下の側 (0.6 V 付近) で少しつぶれ、
LTspice では高調波ひずみが約 6 % ある。ベースは振幅が小さく、波形にはひずみの成分がもっと目立つ (高調波を梯子が弱めきれない)。
CH2 は CH1 と尺度が 50 倍違う (形と向きを見るため)。カーソルの間隔 903 µs (µ はマイクロ) が 1 周期。CH1 が山のとき CH2 が谷になる (位相 180°)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| Q1 | NPN トランジスタ | 2SC1815 (GR ランク。hFE が 56 以上要る) |
| R1 | 抵抗 (ベースの分圧) | 33 kΩ |
| R2 | 抵抗 (ベースの分圧) | 10 kΩ |
| RC | 抵抗 (コレクタ) | 4.7 kΩ |
| RE | 抵抗 (エミッタ) | 1 kΩ |
| CE | 電解コンデンサ (エミッタのバイパス) | 100 µF |
| C1, C2, C3 | フィルムコンデンサ (梯子) | 10 nF (103) |
| R3, R4 | 抵抗 (梯子) | 4.7 kΩ |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+/2+ |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 発振の周波数 (CH1) | 約 1.1 kHz (式 1.07 kHz) | 梯子の R と C で決まる。式の √10 の 10 は、3 段の 6 と、RC が梯子に足す 4 |
| コレクタの振れ (CH1) | 約 3.8 Vpp (0.6〜4.4 V)、直流は約 2.6 V | トランジスタが振り切れる所で振幅が止まる |
| ベースの振れ (CH2) | 約 69 mVpp、CH1 と逆の向き | 梯子の弱め分。コレクタとの比 約 55 倍が、発振に要る利得 |
| 梯子の 1 段目・2 段目 (C1 と R3 の間、C2 と R4 の間) | 約 1.1 Vpp・約 0.24 Vpp | 段ごとに振幅が小さくなり、位相が遅れていく |
| hFE の違う個体に替えたときの周波数 | 1.08〜1.15 kHz (hFE 400〜120) | 3 段目の R がベースの入力の抵抗なので、hFE で数 % 動く |

C1〜C3 を 22 nF に替えると周波数は約半分 (0.5 kHz) になる。R3 か R4 を 2.2 kΩ に下げると、梯子の弱め分が増えて発振が止まることがある。
ウィーンブリッジ (3-7) は増幅を正の向き (同相) で使い、利得を 3 倍にそろえて正弦波を作るが、この回路は逆の向きで使い、
利得の余りはトランジスタが振り切れて吸収するので、波形のひずみは大きい。

## LTspice での確かめ

`sim/11-phase-shift.cir` で図1 を 0.2 秒の過渡解析で走らせ、終わりの 10 ms で周波数と振幅を読んだ。
Q1 は 3-1 と同じ 2SC1815 の模型で、BF を 120・250・400 に振った (仮定で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 発振の周波数 (hFE 250) | 約 1.1 kHz (式 1.07 kHz) | 1.107 kHz | 合う (式より 3 % 高い。3 段目の R が 4.7 kΩ でなく約 4.4 kΩ のため) |
| hFE 120 / 400 のときの周波数 | 1.08〜1.15 kHz | 1.151 / 1.081 kHz | 合う |
| コレクタの振れ | 約 3.8 Vpp (0.6〜4.4 V) | 3.78 Vpp (0.61〜4.39 V) | 合う |
| コレクタの直流 | 約 2.6 V | 2.58 V | 合う |
| ベースの振れ | 約 69 mVpp | 69.2 mVpp (直流 1.135 V) | 合う |
| 梯子の 1 段目・2 段目 | 約 1.1 Vpp・約 0.24 Vpp | 1.09 Vpp・0.242 Vpp | 合う |
| コレクタの高調波ひずみ | 約 6 % | 6.4 % | 本文の値は LTspice の読み |
| 電源の電流 | 約 0.6 mA | 0.63 mA | 合う |

## 出典

自作。

参考: [発振回路 (Wikipedia)](https://ja.wikipedia.org/wiki/発振回路)、[Phase-shift oscillator (Wikipedia)](https://en.wikipedia.org/wiki/Phase-shift_oscillator)
