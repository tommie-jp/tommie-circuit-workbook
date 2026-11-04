---
book: circuits
chapter: 2
id: 2-15
title: 2 段増幅と負帰還
tier: 200
source: 自作
---

# 2-15 2 段増幅と負帰還

エミッタ接地を 2 段つなぐと利得は掛け算になり、約 1000 倍になる。ただしその 1000 倍は hFE や温度で 2 割も動き、
入力が 1 mV を越えれば歪む。そこで、大きすぎる利得の一部を**負帰還**に回して、利得を抵抗の比で決め直す。

この回路では、出力 (Q2 のコレクタ) を `RF` (2.2 kΩ) で Q1 のエミッタへ戻す。エミッタ接地は 1 段で反転するので、
2 段では入力と同じ向きの出力になる。それを Q1 のエミッタ (入力と同じ向きに動くと利得が減る所) へ返すので、帰還は負になる。

- 帰還の割合 β (ベータ) は `RE1A` / (`RE1A` + `RF`) = 100 / 2300 ≈ 0.043
- 帰還のない利得 (**開ループ利得**) A が大きければ、全体の利得は 1 / β = 1 + `RF` / `RE1A` = **23 倍** に近づく。
  正しくは A / (1 + Aβ) で、Aβ (**ループ利得**) が大きいほど 1 / β に近い
- ループ利得の分だけ、hFE の影響・歪み・帯域の狭さが小さくなる。2-21 で 1 段の中で行った負帰還を、2 段をまたいで行う形

この題では、帰還のある回路の利得が 22 倍で入力と同じ向きに出ることをオシロで確かめ、帰還を切った (J1 を抜いた) ときと利得・歪みを比べる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2 段増幅と負帰還 (出力から RF で Q1 のエミッタへ戻す)
parts:
  VCC: vcc 5,2 5V
  W1: sine 1,6 1,9 l=$\mathrm{W1}$
  M1: voltmeter 3,6 3,9 l=$\mathrm{CH1}$
  G1: ground 1,9
  CIN: capacitor 3,6 5,6 1u
  R1: resistor 5,2 5,6 33k
  R2: resistor 5,6 5,10 10k
  G2: ground 5,10
  RC1: resistor 8,2 8,4 4.7k
  Q1: npn 8,6
  RE1A: resistor 8,8 8,10 100
  RE1B: resistor 8,10 8,12 910
  G3: ground 8,12
  CE1: ecap 10,10 10,12 100u
  C12: capacitor 8,4 11,4 1u
  R3: resistor 12,2 12,5 20k
  R4: resistor 12,5 12,9 10k
  G4: ground 12,9
  RC2: resistor 14,2 14,4 2.2k
  Q2: npn 14,5
  RE2: resistor 14,7 14,9 1k
  G5: ground 14,9
  CE2: ecap 16,7 16,9 100u
  OUT: port 17,4
  M2: voltmeter 20,4 20,6 l=$\mathrm{CH2}$
  G6: ground 20,6
  CF: ecap 18,6 18,8 10u
  RF: resistor 13,14 10,14 2.2k
wires:
  - 1,6 -- 3,6
  - 1,9 -- 3,9
  - 5,2 -- 8,2
  - 8,2 -- 12,2
  - 12,2 -- 14,2
  - 5,6 -- Q1.B
  - 8,4 -- Q1.C
  - Q1.E -- 8,8
  - 8,10 -- 10,10
  - 8,12 -- 10,12
  - 11,4 |- 12,5
  - 12,5 -- Q2.B
  - 14,4 -- Q2.C
  - Q2.E -- 14,7
  - 14,7 -- 16,7
  - 14,9 -- 16,9
  - 14,4 -- 17,4
  - 17,4 -- 18,4
  - 18,4 -- 20,4
  - 18,4 -- 18,6
  - 18,8 -- 18,14
  - 18,14 -- 13,14
  - 10,14 -- 7,14
  - 7,14 -- 7,8
  - 7,8 -- 8,8
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/15-two-stage-feedback.svg)

図1 の電源は AD3 の V+ (5 V)。CH1 で入力 (W1)、CH2 で出力 (Q2 のコレクタ) を見る。

- **1 段目 (Q1)**: `R1`・`R2` の分圧でベースが約 1.15 V、エミッタは約 0.5 V、I<sub>E1</sub> ≈ 0.5 V / 1.01 kΩ ≈ **0.5 mA**。
  コレクタは 5 − 0.5 mA × 4.7 kΩ ≈ **2.6 V**。エミッタの抵抗は 2-21 と同じく 2 本に分け、`RE1B` だけを `CE1` でバイパスする。
  帰還は、バイパスしない `RE1A` (100 Ω) の上に返す
- **2 段目 (Q2)**: 2-3 と同じ回路で、I<sub>E2</sub> ≈ 0.93 mA、コレクタは約 **2.8〜3.0 V**。1 段目とは `C12` でつなぐので、2 段の動作点は別々に決まる
- **帰還の直流を止める**: `CF` (10 µF) は、出力の直流 (約 2.8 V) が Q1 のエミッタ (0.5 V) に流れ込まないようにする。1 kHz では 16 Ω で無いのと同じ
- **開ループ利得**: 1 段目は `RC1` ∥ (2 段目の入力 3.4 kΩ) ≈ 1.97 kΩ を (re1 50 Ω + `RE1A` 100 Ω) で割って約 13 倍、
  2 段目は 2.2 kΩ / re2 28 Ω ≈ 79 倍。掛けて **約 1000 倍**
- **帰還あり**: ループ利得 Aβ ≈ 1000 × 0.043 ≈ 44。全体の利得は 23 / (1 + 1/44) ≈ **22.5 倍** (計算値)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 2 段増幅と負帰還 (帰還の CF・RF とエミッタの RE2・CE2 は下のブロック)
board: full
parts:
  CIN: capacitor c5 c9 1uF
  R1: resistor a9 +t9 33k
  R2: resistor b9 b13 10k
  Q1: transistor d16(B) d17(C) d18(E) 2SC1815 cap=below
  RC1: resistor a17 +t17 4.7k
  RE1A: resistor c18 c21 100
  RE1B: resistor a21 -t21 910
  CE1: capacitor/electrolytic d21(+) d24(-) 100uF
  C12: capacitor c26 c30 1uF
  R3: resistor a30 +t30 20k
  R4: resistor b30 b34 10k
  Q2: transistor d38(B) d39(C) d40(E) 2SC1815 cap=below
  RC2: resistor a39 +t39 2.2k
  RE2: resistor j40 -b40 1k
  CE2: capacitor/electrolytic h40(+) h44(-) 100uF
  CF: capacitor/electrolytic g39(+) g35(-) 10uF
  RF: resistor h35 h30 2.2k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1+, W1, 1-, 2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a4 blue
  - e4 -- e5 blue
  - AD.W1 -- a5 yellow
  - AD.1- -- -t7 black
  - a13 -- -t13 black
  - e9 -- e16 orange
  - a24 -- -t24 black
  - b17 -- b26 orange
  - a34 -- -t34 black
  - e30 -- e38 orange
  - e39 -- f39 green
  - e40 -- f40 white
  - j44 -- -b44 black
  - i30 -- i18 white
  - e18 -- f18 white
  - -t62 -- -b62 black
  - AD.2+ -- b39 green
  - AD.2- -- -t45 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/15-two-stage-feedback.svg)

図2 は full のブレッドボード。上のブロックに 2 つの増幅段を並べ、帰還の `CF`・`RF` と 2 段目のエミッタの `RE2`・`CE2` を下のブロックに置いた。
5 V は AD3 の V+ (赤) から上の + レールへ。**下の − レールは列 62 の黒い線で上の − レールとつなぐ**。

- Q1・Q2 は d 行に、平らな面を奥にして挿す (手前から見て左から B・C・E)。e 行を空けて、溝をまたぐ線をそこから出すため
- **1 段目 (列 5〜24)**: `CIN` (`c5`–`c9`) の先の列 9 がベースの分圧の点。橙の線 `e9`–`e16` で Q1 の B へ。`RE1A` を E (列 18) から列 21 へ、
  `RE1B` と `CE1` を列 21 から GND へ
- **段の間**: Q1 の C (列 17) から橙の線 `b17`–`b26`、`C12` (`c26`–`c30`) で 2 段目のベースの分圧の点 (列 30) へ。橙の線 `e30`–`e38` で Q2 の B へ
- **2 段目 (列 30〜44)**: `RC2` は Q2 の C (列 39) から + レールへ、CH2 の 2+ は `b39`。Q2 の E (列 40) を白い線で下へ下ろし、`RE2`・`CE2` を下の − レールへ
- **帰還**: Q2 の C を緑の線 `e39`–`f39` で下へ下ろし、`CF` (+ が列 39)、`RF` (`h35`–`h30`)、白い線 `i30`–`i18` で Q1 の E の列 18 へ戻す (列 18 は `e18`–`f18` で上下をつないである)

**帰還を切る (J1)**: 白い線 `i30`–`i18` を抜く。Q1 のエミッタには `RE1A` だけが残り、開ループ利得の回路になる。

## 計器の設定

計器は AD3 のオシロ (入力と出力の大きさと向きを波形で比べるため)。W1 を 1 kHz・44 mVpp の正弦波にする。CH1 は 20 mV/div、CH2 は 200 mV/div で、
CH2 の Offset を −2.8 V にして直流を消す。時間軸 200 µs/div、CH1 の立ち上がりでトリガする。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 帰還あり — 入力 44 mVpp (CH1) が約 22 倍の 0.97 Vpp (CH2) で同じ向きに出る
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 44mVpp, range: 20mV/div, position: 2.5div}
ch2: {wave: ch1 | gain 22, range: 200mV/div, position: -1.5div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/15-two-stage-feedback.svg)

図3 の CH2 は約 0.97 Vpp で、CH1 の約 22 倍。山と谷が CH1 とそろい、位相は 0°。

**帰還を切って比べる**: 白い線 `i30`–`i18` を抜き、W1 を 1 mVpp に下げる (44 mVpp のままだと出力が電源の幅を越えて頭と底がつぶれる)。
CH2 は約 1 Vpp で、利得は約 1000 倍。同じ約 1 Vpp の出力で WaveForms の Spectrum を CH2 に当てると、2 kHz・3 kHz の高調波が帰還ありより
約 20 dB 高い (歪み率 0.35 % → 3.7 %。LTspice の値)。1 mVpp は AD3 の Wavegen の小さい側の端なので、雑音が目立つ。
W1 と `CIN` の間に 10 kΩ と 100 Ω の分圧器 (1/101) を入れ、W1 を 100 mVpp にして約 1 mVpp を作ってもよい。

AD3 の Network Analyzer で 10 Hz〜1 MHz を掃引すると、帰還ありの利得は 1 MHz まで平らで (−3 dB は模型で 10 MHz)、帰還なしは約 200 kHz で落ちる。
ループ利得の分だけ、帯域が広がる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 33 kΩ |
| R2, R4 | 抵抗 (1/4 W) | 10 kΩ |
| R3 | 抵抗 (1/4 W) | 20 kΩ |
| RC1 | 抵抗 (1/4 W) | 4.7 kΩ |
| RE1A | 抵抗 (1/4 W) | 100 Ω (帰還を受ける。バイパスしない) |
| RE1B | 抵抗 (1/4 W) | 910 Ω |
| RC2, RF | 抵抗 (1/4 W) | 2.2 kΩ |
| RE2 | 抵抗 (1/4 W) | 1 kΩ |
| CIN, C12 | フィルムコンデンサ | 1 µF |
| CE1, CE2 | 電解コンデンサ | 100 µF |
| CF | 電解コンデンサ | 10 µF (+ を Q2 のコレクタ側に) |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| — | 電源 | AD3 の V+ (5 V、約 2 mA) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| Q1 のベース / エミッタ / コレクタ | 約 1.15 V / 0.53 V / 2.6 V | 1 段目の動作点 |
| Q2 のベース / コレクタ | 約 1.64 V / 2.8 V | 2 段目の動作点 (2-3 と同じ) |
| 帰還ありの利得 (44 mVpp → CH2) | 約 22 倍 (0.97 Vpp)、同じ向き | 1 + `RF` / `RE1A` = 23 に近い |
| 帰還なしの利得 (1 mVpp → CH2) | 約 1000 倍 | 開ループ利得 |
| 出力 1 Vpp の歪み率 (帰還あり / なし) | 約 0.35 % / 約 3.7 % | 負帰還で歪みが約 1/10 |
| hFE が違う個体での利得 (帰還あり) | ほぼ同じ (差 2 % 以内) | 利得が抵抗の比で決まる |

## LTspice での確かめ

`sim/15-two-stage-feedback.cir` で 1 kHz の利得と −3 dB の帯域を .ac で読み、J1 の有無 (`rj` を 1 mΩ と 1 GΩ) と hFE (`bf` を 120・250・400) を振った。
`sim/15-two-stage-feedback-tran.cir` で出力が約 1 Vpp になる入力を入れ、動作点と歪み率 (最後の 10 周期の FFT、5 次まで) を読んだ。
Q1・Q2 は 2-3 と同じ 2SC1815 の代用モデルで、hFE などは仮定 (実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| Q1 のベース / エミッタ / コレクタ | 約 1.15 V / 0.5 V / 2.6 V | 1.15 V / 0.53 V / 2.56 V | 合う |
| Q2 のベース / コレクタ | 約 1.64 V / 2.8〜3.0 V | 1.64 V / 2.80 V | 合う |
| 帰還ありの利得 (hFE 120 / 250 / 400) | 約 22.5 倍 | 21.7 / 22.1 / 22.2 倍 (差 2 %) | 合う |
| 帰還なしの利得 (hFE 120 / 250 / 400) | 約 1000 倍 | 749 / 1016 / 1157 倍 (差 ±21 %) | 合う (hFE で大きく動く) |
| 帰還ありの −3 dB (高い側 / 低い側) | 1 MHz より上 | 10.7 MHz / 34 Hz | 合う |
| 帰還なしの −3 dB (高い側、hFE 250) | 約 200 kHz | 212 kHz | 本文の値は LTspice の読み |
| 出力 0.97 Vpp の歪み率 (帰還あり) | 約 0.35 % | 0.35 % | 本文の値は LTspice の読み |
| 出力 1.01 Vpp の歪み率 (帰還なし) | 約 3.7 % | 3.73 % | 本文の値は LTspice の読み |

帰還ありの 10.7 MHz は、トランジスタの模型とオシロの容量だけで計算した値で、ブレッドボードの浮遊容量と AD3 の帯域では見えない (目安)。
利得 × 帯域は帰還あり 22 × 10.7 MHz ≈ 240 MHz、なし 1016 × 212 kHz ≈ 220 MHz でほぼ同じで、帰還は利得を帯域に替えている。

## 出典

自作。1 段目は 2-21、2 段目は 2-3 の回路。

参考: [負帰還 (Wikipedia)](https://ja.wikipedia.org/wiki/負帰還)、[Negative-feedback amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Negative-feedback_amplifier)
