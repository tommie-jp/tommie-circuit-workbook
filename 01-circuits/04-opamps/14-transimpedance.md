---
book: circuits
chapter: 4
id: 4-14
title: 電流→電圧 (トランスインピーダンス、フォトダイオード)
tier: 200
source: 自作
---

# 4-14 電流→電圧 (トランスインピーダンス、フォトダイオード)

フォトダイオードは、受けた光にほぼ比例した**電流** (光電流 I<sub>ph</sub>) を流す部品で、電圧を出す部品ではない。
抵抗をつないで電圧に変えると、抵抗の電圧がフォトダイオードの両端にもかかり、光電流の一部がダイオードの中を
戻ってしまう (順方向に約 0.4 V かかると、電流はほとんど抵抗へ流れなくなる)。両端の容量 C<sub>D</sub> も、そのたびに充放電される。
**OP アンプの − 入力 (仮想接地) で光電流を受け、帰還抵抗 Rf に流させる**と、フォトダイオードの両端は 0 V のまま、
出力に V<sub>out</sub> = I<sub>ph</sub> × Rf が出る。電流を電圧に変えるこの回路を**トランスインピーダンス増幅** (TIA) と呼ぶ。
光センサー・光通信の受信・電流計の入口の基本形。

この題では、W1 で点滅させた赤 LED の光を BPW34 で受け、光電流が Rf (10 kΩ) で電圧になることと、
Rf に並列の Cf が無いと出力の角が跳ねる (帰還が不安定に近づく) ことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 フォトダイオードの光電流を Rf で電圧に変える (Cf で安定に)
parts:
  VP: vsource vp mid 5
  VN: vsource mid vm 5
  G1: ground 3,8.5
  W1: square 2,3 2,5 4 l=$\mathrm{W1}$
  GW: ground 2,5
  R1: resistor 3,3 5,3 330
  D1: led 5,3 5,5 red
  GD1: ground 5,5
  D2: photodiode 8,6 8,4 BPW34
  GD2: ground 8,6
  U1: opamp 12,5 +down
  GU1: ground 10,6
  Rf: resistor 10,2.8 14,2.8 10k
  Cf: capacitor 10,1 14,1 100p
  OUT: port 16,5 out
points:
  vp: 2,7
  vm: 2,10
  mid: 2,8.5
wires:
  - mid -- 3,8.5
  - 2,3 -- 3,3
  - 8,4 -- 10,4
  - 10,4 |- U1.-
  - 10,6 |- U1.+
  - 10,4 -- 10,2.8
  - 10,2.8 -- 10,1
  - 14,1 -- 14,2.8
  - 14,2.8 -- 14,5
  - U1.out -- 14,5 -- 16,5
notes:
  - text 6.5,4.3 orange: 光
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/circuit/14-transimpedance.svg)

- 左下の VP・VN は ±5 V 電源。AD3 の Supplies の V+・V− で作る (4-1 と同じ)
- **左は光を出す側**: W1 (0 V と 4 V の方形波、1 kHz) で赤 LED の D1 を点滅させる。R1 (330 Ω) で電流は (4 − 1.9) / 330 ≈ 6.4 mA
- **D2 (BPW34) は陽極を GND、陰極を − 入力へ**。光電流は陰極から陽極へ流れるので、− 入力の節点から電流を引き抜く。
  OP アンプは Rf を通して同じ電流を出力から送り込み、− 入力を 0 V (仮想接地) に保つ。出力は **V<sub>out</sub> = I<sub>ph</sub> × Rf** (正)
- D2 の両端は 0 V のまま動かない (ゼロバイアス)。C<sub>D</sub> (BPW34 で約 70 pF) は充放電されず、光電流の全部が Rf を流れる。
  抵抗だけで受けるとき (下の表の比べ) と違い、出力は光電流に比例し続ける
- **Cf (100 pF) は安定のため**。C<sub>D</sub> と Rf は − 入力に遅れを作り、OP アンプの帰還の遅れと重なって、
  階段の入力で出力が跳ねる (Cf が無いと約 45 % の行き過ぎ。4-20 で見る帰還の安定性の話)。Cf はその遅れを打ち消す。
  帯域は f = 1 / (2π × Rf × Cf) ≈ 159 kHz に下がるが、1 kHz の点滅には十分
- Rf を大きくすると感度 (V/A) が上がる。ただし部屋の明かり (BPW34 で 1 klx に約 75 µA) でも出力が振れ切らない値に止める

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (LED と BPW34 は向かい合わせ)
board: half
parts:
  AD3:
    type: device
    at: top
    label: AD3 (Supplies ±5V・W1・Scope)
    pins: [V-, V+, GND, 2+, 1+, W1, 1-, 2-]
  U1: dip8 @ e14 LM358
  Rf: resistor b16 b10 10k cap=left
  Cf: capacitor d16 d10 100p cap=left
  D2: photodiode c19(A) c16(K) BPW34
  D1: led c21(A) c23(K) red cap=above
  R1: resistor d21 d25 330
wires:
  - AD3.V- -- -b1 blue
  - AD3.V+ -- +t3 red
  - AD3.GND -- -t4 black
  - AD3.2+ -- a10 green
  - AD3.1+ -- a24 yellow
  - AD3.W1 -- a25 yellow
  - c24 -- c25 yellow
  - AD3.1- -- -t28 black
  - AD3.2- -- -t29 black
  - a14 -- +t14 red
  - j17 -- -b17 blue
  - a17 -- -t17 black
  - c15 -- c10 green
  - a19 -- -t19 black
  - a23 -- -t23 black
  - g14 -- g15 white
  - j16 -- -b16 blue
notes:
  - text below: 上の赤レール = +5V、上の青レール = GND、下の青レール = −5V (V−)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/breadboard/14-transimpedance.svg)

- AD3 の V+ は上の赤レール、GND は上の青レール、V− は左端を回して下の青レールへ。電流は LED の 6.4 mA (W1 から) と数 mA で、各レール約 50 mA の範囲に収まる
- LM358 は 14 列〜17 列。**上ブロック側の回路 (PIN 5〜7) を使う**。+ 入力 (PIN 5、17 列) は `a17 → -t17` で GND、PIN 8 (14 列) は `a14 → +t14` で +5 V、PIN 4 (17 列) は `j17 → -b17` で −5 V
- **16 列が − 入力 (PIN 6)**。D2 (BPW34) の陰極 (K) を 16 列、陽極 (A) を 19 列に挿し、19 列は `a19 → -t19` で GND。出力 (PIN 7、15 列) は緑 `c15 → c10` で 10 列へ出す。
  Rf (b 段) と Cf (d 段) は 16 列と 10 列の間に並べる
- **D1 (赤 LED) は D2 の隣 (21 列〜23 列)** に挿し、LED の頭を D2 の受光面へ向けて曲げる。距離は 5 mm〜1 cm。R1 (330 Ω、d 段) は 21 列と 25 列の間、W1 (黄) は 25 列。
  部屋の明かりが入ると出力に直流が乗るので、LED と D2 を黒い紙の筒で一緒に覆う
- 下ブロック側の回路 (PIN 1〜3) は使わないので、出力と − 入力を白 `g14 → g15` でつなぎ、+ 入力 (16 列) を `j16 → -b16` で V− に落とす (LM358 の入力の範囲は V− を含む)
- Scope の 1+ (黄) は 24 列に挿し、黄の短い線 `c24 → c25` で W1 を見る。2+ (緑) は出力の 10 列 (`a10`)

## 計器の設定

オシロには Analog Discovery 3 (AD3) の Scope を使う。1 kHz の方形波の形と高さを読む題で、10 MHz よりずっと低いから。
W1 は 1 kHz の方形波 (Low 0 V・High 4 V)。CH1 で W1、CH2 で TIA の出力を見る。

| 設定 | 値 |
| --- | --- |
| Wavegen W1 | Square、1 kHz、振幅 2 V、オフセット 2 V (0 V〜4 V) |
| Scope CH1 (W1、24 列) | DC、2 V/div。0 V を中心より 1 目盛上に置く |
| Scope CH2 (出力、10 列) | DC、50 mV/div。0 V を画面の下端 (中心より 4 目盛下) に置く |
| Time | 200 µs/div (1 kHz が 2 周期) |
| Trigger | CH1、立ち上がり、2 V |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 LED の点滅 (CH1) とフォトダイオードの出力 (CH2、Iph 20 µA × 10 kΩ)
time: 200us/div
trigger: ch1 rising 2V
ch1: {wave: square 1kHz 2V offset 2V, range: 2V/div, position: 1div}
ch2: {wave: square 1kHz 0.1V offset 0.1V | rc 1us, range: 50mV/div, position: -4div}
cursors: [250us, 750us]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/04-opamps/scope/14-transimpedance.svg)

図3 は光電流を 20 µA と**仮定した**想定図 (LED と D2 の距離と向きで大きく変わる)。CH2 は LED が点いている間 0.2 V、消えている間 0 V で、
カーソル X1 (250 µs) と X2 (750 µs) が点灯と消灯のそれぞれの真ん中を読む。読んだ高さを 10 kΩ で割ると、光電流が分かる (0.2 V なら 20 µA)。
CH2 の角は 時定数 τ (タウ) = Rf × Cf = 1 µs で丸まる。1 目盛 200 µs の画面では見えないので、Time を 2 µs/div にして立ち上がりを拡大する。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | オペアンプ (2 回路入りの片方。もう片方は使わない) | LM358 |
| D2 | フォトダイオード | BPW34 (C<sub>D</sub> 70 pF @ 0 V、1 klx で約 75 µA。データシートの代表値) |
| Rf | 抵抗 (光電流を電圧に変える) | 10 kΩ |
| Cf | セラミックコンデンサ (帰還の安定) | 100 pF |
| D1 | LED (赤、5 mm) | V<sub>F</sub> ≈ 1.9 V |
| R1 | 抵抗 (LED の電流) | 330 Ω |
| — | 信号源 | 1 kHz の方形波 (0 V〜4 V)。LED の電流 6.4 mA は W1 の出せる電流 (約 10 mA) の内 |
| — | 電源 | ±5 V (AD3 の Supplies。V+ = +5 V、V− = −5 V) |
| — | 計器 | AD3 の W1 (信号源)・Scope 1+/2+ (W1 と出力)、テスター |

## 見るべき値

LED と D2 を黒い筒で覆ってから測る。表の光電流は 20 µA の仮定 (目安) で、実際の高さは距離で変わる。比例して読めばよい。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 出力 (LED が点いている間) | 0.2 V (I<sub>ph</sub> 20 µA のとき) | V<sub>out</sub> = I<sub>ph</sub> × Rf。高さを 10 kΩ で割ると光電流 |
| 出力 (LED が消えている間) | ほぼ 0 V | 覆いが十分なら暗電流 (nA) × 10 kΩ と、LM358 の入力オフセット (数 mV) だけ |
| − 入力 (16 列) の電圧 | ほぼ 0 V (光で動かない) | D2 はゼロバイアスのまま |
| 出力の立ち上がり (10 %→90 %) | 約 2.2 µs | 2.2 × Rf × Cf。Time を 2 µs/div にして読む |
| Cf を抜いた立ち上がり | 約 0.5 µs で、行き過ぎ 約 45 % | 速くなるが、跳ねて揺れる。Cf は帰還の安定のため |
| 覆いを外したとき | 直流が乗る (100 lx で約 75 mV) | 部屋の明かり (BPW34 で 1 klx に約 75 µA)。照明の 100 Hz / 120 Hz のちらつきも乗る |
| 比べ: Rf の代わりに 10 kΩ だけで受けた D2 の電圧 | 約 −0.2 V (D2 が順方向に 0.2 V かかる) | 光電流が増えると順方向の電流が増えて比例しなくなる |

## LTspice での確かめ

`sim/14-transimpedance.cir` で図1 を過渡解析で走らせた。D2 は、光電流の電流源 (0 と 20 µA の 1 kHz の方形波、**仮定**) と
C<sub>D</sub> 70 pF (データシートの代表値) で表した。Cf を 100 pF と 0 の 2 通り、比べの「抵抗だけで受ける」も同じファイルで解いた。
オペアンプは 1 極の簡易模型 (GBW 1 MHz。LM358 相当の**仮定**で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 出力 (点灯) | 0.2 V | 0.200 V | 合う |
| 出力 (消灯) | ほぼ 0 V | 0 V | 合う |
| − 入力の電圧 | ほぼ 0 V | 2 µV 以下 | 合う |
| 立ち上がり (Cf 100 pF) | 約 2.2 µs | 2.05 µs | 合う |
| Cf を抜いたとき | 約 0.5 µs、行き過ぎ 約 45 % | 0.54 µs、最大 0.290 V (行き過ぎ 45 %) | 合う |
| 抵抗だけで受けた D2 の電圧 | 約 −0.2 V | −0.200 V | 合う (ダイオードの順方向の電流は模型に入れていない) |

## 出典

自作。
参考: [Transimpedance amplifier (Wikipedia)](https://en.wikipedia.org/wiki/Transimpedance_amplifier)、[フォトダイオード (Wikipedia)](https://ja.wikipedia.org/wiki/フォトダイオード)、[Vishay BPW34 のデータシート](https://www.vishay.com/docs/81521/bpw34.pdf)、[TI LM358 のデータシート](https://www.ti.com/lit/ds/symlink/lm358.pdf)
