---
book: circuits
chapter: 2
id: 2-16
title: A 級パワーアンプ (スピーカーを鳴らす)
tier: 200
source: 自作
---

# 2-16 A 級パワーアンプ (スピーカーを鳴らす)

スピーカーは 8 Ω (オーム) ほどの低い抵抗で、1 V を掛けるだけで 125 mA が要る。AD3 の Wavegen は 10 mA ほどしか出せないので、
直接つなぐと波形がつぶれる。電圧はそのままに**電流を増やす段** (パワーアンプ) が要る。

**A 級**は、信号が無いときにも十分な電流 (**アイドル電流** I<sub>Q</sub>) を流しておき、信号でその電流を上下に振る方式。
トランジスタは一度も切れないので、2-10 の B 級のようなクロスオーバー歪みが無い。代わりに、音を出していないときも電源から
I<sub>Q</sub> を取り続け、その大部分を熱にする。この題では、2-2 のエミッタフォロアに 8 Ω のスピーカーをつなぎ、

- 出せる電圧の上限が I<sub>Q</sub> で決まる (下側が先に頭打ちになる)
- 電源から取る電力に比べて、スピーカーに届く電力がとても小さい (効率が数 %)

ことを、オシロと計算で確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 A 級のエミッタフォロアで 8 Ω のスピーカーを鳴らす
parts:
  VCC: vcc 5,2 5V
  W1: sine 1,5 1,8 l=$\mathrm{W1}$
  M1: voltmeter 3,5 3,8 l=$\mathrm{CH1}$
  G1: ground 1,8
  CIN: ecap 5,5 3,5 10u
  R1: resistor 5,2 5,5 1.2k
  R2: resistor 5,5 5,8 1.8k
  G2: ground 5,8
  Q1: npn 7,5
  RE: resistor 7,7 7,10 56
  G3: ground 7,10
  COUT: ecap 7,7 10,7 470u
  SP: speaker 10,7 10,10 l=$\mathrm{SP}$
  M2: voltmeter 12,7 12,10 l=$\mathrm{CH2}$
  G4: ground 10,10
wires:
  - 1,5 -- 3,5
  - 1,8 -- 3,8
  - 5,2 -- 7,2
  - 7,2 -- Q1.C
  - 5,5 -- Q1.B
  - Q1.E -- 7,7
  - 10,7 -- 12,7
  - 10,10 -- 12,10
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/16-class-a-amp.svg)

図1 の電源は AD3 の V+ (5 V)。CH1 で入力 (W1)、CH2 でスピーカーの両端を見る。

- **動作点**: `R1`・`R2` の分圧でベースは 5 × 1.8 / 3.0 = 3.0 V、ベース電流 (約 0.15 mA) が分圧の抵抗 (720 Ω) で落とす分を引いて約 2.86 V。
  エミッタは約 2.1 V で、I<sub>Q</sub> ≈ 2.1 V / 56 Ω ≈ **37 mA**
- **電源から取る電力**: 5 V × 39 mA ≈ **0.19 W** (分圧の 1.7 mA を含む)。Q1 で約 0.1 W、`RE` で約 0.08 W が熱になる
- **出せる電圧の上限**: エミッタの電流が増える向き (上) は Q1 が流せば済むが、減る向き (下) は 0 mA より下げられない。
  スピーカーの電流を `COUT` から引くとき、その電流は `RE` を通るしかなく、スピーカーの電圧の下の限界は
  −I<sub>Q</sub> × (`RE` ∥ 8 Ω) = −37 mA × 7.0 Ω ≈ **−0.26 V**
- **スピーカーの電力**: 頭打ちしない最大は振幅 0.26 V で、0.26² / (2 × 8) ≈ **4 mW**。電源の 0.19 W の **約 2 %**
- **電流の増幅**: 電圧の利得は 1 倍弱 (エミッタフォロア) だが、W1 が出す電流は 1 mA 以下で、スピーカーには 30 mA 前後が流れる

A 級の効率の上限は、負荷を抵抗で直に受ける形で 25 %、定電流源 (2-14) かトランスで受ける形で 50 %。この回路は 8 Ω と並んで `RE` も電力を取るので、さらに低い。
今のオーディオの IC (LM386 など) が B 級や AB 級を使うのはこのため。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 A 級のエミッタフォロアとスピーカー
board: half
parts:
  CIN: capacitor/electrolytic c9(+) c5(-) 10uF
  R1: resistor a9 +t9 1.2k
  R2: resistor b9 b13 1.8k
  Q1: transistor e16(B) e17(C) e18(E) 2SC1815 cap=below
  RE: resistor a18 -t18 56
  COUT: capacitor/electrolytic c18(+) c23(-) 470uF
  SP: speaker b23 b27
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
  - e9 -- d16 orange [v10]
  - +t17 -- a17 red
  - a27 -- -t27 black
  - AD.2+ -- a23 green
  - AD.2- -- -t29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/16-class-a-amp.svg)

図2 は 2-21 と同じ並び方で、入力を左、Q1 を中央、スピーカーを右に置いた。5 V は AD3 の V+ (赤) から上の + レールへ。

- **ベース (列 9)**: `CIN` (+ が列 9)、+ レールへの `R1`、右へ寝かせた `R2` (列 13 から − レールへ)。橙の線で Q1 の B (列 16) へ
- **Q1**: 平らな面を奥に挿し、手前から見て左から B・C・E (列 16〜18)。C (列 17) は赤い線で + レールへ
- **エミッタ (列 18)**: − レールへ縦に `RE`、右へ `COUT` (+ が列 18)
- **スピーカー**: `COUT` の − 側 (列 23) と列 27 の間。列 27 を − レールへ。CH2 の 2+ (緑) は `a23`
- スピーカーのリード線は細いので、ピンヘッダか太い単線をはんだ付けしてから挿す

## 計器の設定

計器は AD3 のオシロ (スピーカーの電圧の波形のつぶれを見るため)。W1 を 1 kHz の正弦波にし、0.5 Vpp から 0.8 Vpp へ上げる。
CH1・CH2 とも 200 mV/div、時間軸 200 µs/div、CH1 の立ち上がりでトリガ。Supplies の V+ は 5 V (電流は約 39 mA)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 W1 0.8 Vpp — スピーカーの電圧 (CH2) は下が −0.26 V で平らになる
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 0.8Vpp, range: 200mV/div}
ch2: {wave: ch1 | gain 0.75 | clip -0.26V 1V, range: 200mV/div}
measure: [vpp, vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/16-class-a-amp.svg)

図3 は W1 を 0.8 Vpp にしたとき。CH2 の上は 0.30 V まで出るが、下は −0.26 V で平らになる。W1 を 0.5 Vpp に下げると CH2 は約 0.38 Vpp で、
上下とも丸い (歪み率 1.7 %)。図の CH2 は、LTspice の利得 0.75 と −0.26 V の頭打ちで描いた形 (下の節)。

音で聞き比べると、0.8 Vpp では 1 kHz の音が少しにごる (高調波)。Supplies の電流表示は、音を出しても出さなくてもほとんど変わらない (約 39 mA)。
A 級は、音の大きさに関係なく電源の電流が一定である。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 1.2 kΩ |
| R2 | 抵抗 (1/4 W) | 1.8 kΩ |
| RE | 抵抗 (1/4 W) | 56 Ω (約 78 mW。1/4 W の半分の 125 mW 以下) |
| CIN | 電解コンデンサ (16 V) | 10 µF (+ をベース側に) |
| COUT | 電解コンデンサ (16 V) | 470 µF (+ をエミッタ側に) |
| Q1 | NPN トランジスタ | 2SC1815 (I<sub>C</sub> 37 mA・損失 約 0.1 W。最大 150 mA・400 mW の内) |
| SP | スピーカー | 8 Ω・0.5 W (φ 50 mm ほど) |
| — | 電源 | AD3 の V+ (5 V、約 39 mA = 0.19 W。Supplies の上限 250 mW の内) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース / エミッタの直流 | 約 2.86 V / 約 2.1 V | 動作点 |
| 電源の電流 (Supplies の表示) | 約 39 mA (音の有無で変わらない) | A 級はアイドル電流を流し続ける |
| W1 0.5 Vpp のときのスピーカーの電圧 (CH2) | 約 0.38 Vpp (2.2 mW) | 電圧の利得は 1 倍弱 |
| W1 0.8 Vpp のときの CH2 の下の端 | 約 −0.26 V で平ら | 下の限界 = −I<sub>Q</sub> × (`RE` ∥ 8 Ω) |
| 効率 (W1 0.8 Vpp) | 約 3 % (5.2 mW / 0.19 W) | A 級は電力の大部分を熱にする |

## LTspice での確かめ

`sim/16-class-a-amp.cir` で W1 の振幅を 0.25・0.4・0.6 V (0.5・0.8・1.2 Vpp) に振って過渡解析し、最後の 10〜20 ms でスピーカーの電圧・電源の電流・
電力・歪み率 (FFT、5 次まで) を読んだ。Q1 は 2-3 と同じ 2SC1815 の代用モデル、スピーカーは 8 Ω の抵抗とした (どちらも仮定で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ベース / エミッタ | 約 2.86 V / 約 2.1 V | 2.86 V / 2.09 V | 合う |
| 電源の電流 | 約 39 mA | 38.8 mA (0.5 Vpp)・39.7 mA (1.2 Vpp) | 合う |
| CH2 (W1 0.5 Vpp) | 約 0.38 Vpp | 0.376 Vpp、歪み率 1.7 % | 合う |
| CH2 (W1 0.8 Vpp) の上 / 下 | 0.30 V / −0.26 V | 0.299 V / −0.257 V、歪み率 6.6 % | 合う |
| CH2 の下の限界 | −0.26 V (= −37 mA × 7.0 Ω) | −0.268 V (W1 1.2 Vpp) | 合う |
| スピーカーの電力 (0.5 / 0.8 Vpp) | 2.2 mW / 5.2 mW | 2.23 mW / 5.18 mW | 合う |
| Q1 の損失 | 約 0.1 W | 0.105 W | 合う |
| W1 の電流の山 | 1 mA 以下 | 0.49 mA (0.5 Vpp)・0.76 mA (0.8 Vpp) | 合う |

電圧の利得が 0.75 倍とエミッタフォロアの目安 (0.9 倍) より低いのは、37 mA で模型のエミッタの抵抗 (1 Ω) と re (0.7 Ω) に加え、
電流の振れが I<sub>Q</sub> の半分を越えて大信号になっているため。

## 出典

自作。2-2 のエミッタフォロアにスピーカーをつないだもの。

参考: [増幅回路 (Wikipedia)](https://ja.wikipedia.org/wiki/増幅回路)、[Power amplifier classes (Wikipedia)](https://en.wikipedia.org/wiki/Power_amplifier_classes)
