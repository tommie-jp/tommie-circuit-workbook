---
book: circuits
chapter: 2
id: 2-21
title: エミッタ抵抗を分ける — バイアスと利得を別々に決める
tier: 100
source: 自作
board: BB
---

# 2-21 エミッタ抵抗を分ける — バイアスと利得を別々に決める

2-3 のエミッタ接地増幅は、エミッタ抵抗 `RE` を `CE` で全部バイパスすると利得が約 79 倍、`CE` を外すと約 2.2 倍だった。
79 倍は大きすぎて入力が数 mV しか入れられず、2.2 倍は小さすぎる。**その間の利得を、抵抗の比で決める**のがこの題。
エミッタ抵抗を 2 本に分け、`RE1` (100 Ω) はバイパスせずに残し、`RE2` (910 Ω) だけを `CE` でバイパスする。

- **直流**は `RE1 + RE2` = 1.01 kΩ で決まる。2-3 と同じ 1 kΩ なので、動作点 (約 0.93 mA) は 2-3 と変わらない
- **交流**は `RE1` だけが残る。利得は −RC / (RE1 + re) で、**re (約 28 Ω) を足した 128 Ω と RC 2.2 kΩ の比**、約 17 倍になる

つまり、バイアス (直流) を `RE2` で、利得 (交流) を `RE1` で、**別々に決められる**。無線の自作でもオーディオでも、
1 段増幅のエミッタはたいていこの形になっている。利得を抵抗の比で決めると、次の 3 つが得られる。

1. **利得が計算で読める**。`RC` と `RE1` は買った抵抗の値で、トランジスタの個体差 (hFE) と温度で動かない。
   残る re (= 26 mV / Ie) は温度と電流で動くが、`RE1` を re より大きくするほど効かなくなる
   (`RE1` 100 Ω では re が 2 割、220 Ω なら 1 割。LTspice で hFE を 120〜400 に振っても利得は 1 % しか動かない)
2. **歪みが減る**。`RE1` は負帰還 (出力の電流が入力に戻ってベース-エミッタ間の電圧を減らす) として働き、
   同じ出力の振幅で比べた歪みは、全バイパスの 3 分の 1 ほどになる (目安は 1 / (1 + gm × RE1) ≈ 1/4.6。LTspice では 1/3)
3. **入力インピーダンスが上がる**。ベースから見た抵抗は β × (re + RE1) ≈ 150 × 128 Ω ≈ 19 kΩ で、
   全バイパス (β × re ≈ 4.2 kΩ) の 4〜5 倍。前の段 (マイクなど) を重くしない

この題では、2-3 と同じ回路のエミッタだけを分けて、20 mVpp の正弦波が約 17 倍 (340 mVpp) で逆向きに出ることを
オシロで確かめる。出力 1 Vpp まで振っても歪まないことは、Analog Discovery 3 (AD3) のスペクトラムで 2 次の高調波を見ると分かる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 エミッタ抵抗を RE1 と RE2 に分ける (RE2 だけ CE でバイパス)
parts:
  VCC: vcc 6,2 5V
  R1: resistor 6,2 6,5 20k
  R2: resistor 6,5 6,7 10k
  G2: ground 6,7
  RC: resistor 8,2 8,4 2.2k
  Q1: npn 8,5
  CIN: capacitor 6,5 4,5 1u
  W1: sine 2,5 2,7 l=$\mathrm{W1}$
  M2: voltmeter 4,5 4,7 l=$\mathrm{CH2}$
  G4: ground 4,7
  RE1: resistor 8,7 8,9 100
  RE2: resistor 8,9 8,11 910
  G3: ground 8,11
  CE: ecap 10,9 10,11 100u
  COUT: capacitor 9,4 11,4 1u
  OUT: port 11,4
  M1: voltmeter 12,4 12,6 l=$\mathrm{CH1}$
  G5: ground 12,6
wires:
  - 6,2 -- 8,2
  - 2,5 -- 4,5
  - 2,7 -- 4,7
  - 11,4 -- 12,4
  - 6,5 -- Q1.B
  - 8,4 -- Q1.C
  - 8,4 -- 9,4
  - Q1.E -- 8,7
  - 8,9 -- 10,9
  - 8,11 -- 10,11
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/21-split-emitter.svg)

図1 は 2-3 の図1 と同じ回路で、エミッタの 1 kΩ を `RE1` (100 Ω) と `RE2` (910 Ω) に分け、`CE` を `RE2` にだけ
並列にした。電源は Analog Discovery の V+ (5 V)、入力は W1 から `CIN` へ、CH2 で入力を、CH1 で出力を見る。

- 直流: `R1`・`R2` の分圧でベースが約 1.63 V、エミッタが約 0.93 V。Ie = 0.93 V / 1.01 kΩ ≈ **0.92 mA**、
  コレクタは 5 − 0.92 mA × 2.2 kΩ ≈ **3.0 V** (2-3 と同じ。`CE` は直流を通さないので、直流には `RE1 + RE2` が見える)
- 交流: `CE` (100 µF) は 1 kHz で 1.6 Ω なので `RE2` は無いのと同じ。エミッタから GND までは `RE1` と、
  トランジスタの内部の re = 26 mV / 0.92 mA ≈ **28 Ω** の直列
- 電圧利得: Av = −RC / (RE1 + re) = −2200 / 128 ≈ **−17 倍** (反転)。入力 20 mVpp → 出力 約 340 mVpp
- `RE1` を 0 (全バイパス、2-3) にすると −2200 / 28 ≈ −79 倍、`CE` を外す (`RE1 + RE2` が残る) と −2200 / 1038 ≈ −2.1 倍。
  **`RE1` の値で、その間のどこにでも置ける**
- re の大きさは、ベース-エミッタ間の電圧と電流の関係 (2-2 で見た指数の曲線) の傾きから来るもので、
  絶対温度に比例する (27 °C → 57 °C で +10 %)。全バイパスなら利得がそのまま 10 % 動くが、
  この回路では 128 Ω のうちの 28 Ω だけが動くので約 2 % で済む (見積り)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 エミッタを RE1・RE2 に分ける (出力は下のブロックから CH1 へ)
# 5V は AD の V+ から上の + レールへ、上の − レール = GND。下の − レールは上の − レールとつないで CH1 の GND に使う
board: half
parts:
  R1: resistor b3 b9 20k
  R2: resistor c9 c13 10k
  RC: resistor b15 b20 2.2k
  Q1: transistor e19(B) e20(C) e21(E) 2SC1815 cap=below
  CIN: capacitor d5(-) d9(+) 1uF
  RE1: resistor b21 b24 100
  RE2: resistor a24 -t24 910 cap=left
  CE: capacitor/electrolytic c24(+) c27(-) 100uF v=16V
  COUT: capacitor g20(+) g27(-) 1uF
  AD:
    type: device
    at: top
    label: Analog Discovery (電源・W1・CH2)
    pins: [V+, GND, 2+, W1, 2-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery (CH1)
    pins: [1+, 1-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.2+ -- a4 blue
  - e4 -- e5 blue
  - AD.W1 -- a5 yellow
  - AD.2- -- -t7 black
  - +t3 -- a3 red
  - a13 -- -t13 black
  - e9 -- d19 orange [v10]
  - +t15 -- a15 red
  - a27 -- -t27 black
  - c20 -- f20 orange
  - AD1.1+ -- j27 orange
  - AD1.1- -- -b28 black
  - -t30 -- -b30 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/21-split-emitter.svg)

図2 は 2-3 の図2 と同じ並びで、エミッタ (列 21) から先と、出力の取り出し方を変えた。5 V は Analog Discovery の V+ (赤) から上の + レールへ
(WaveForms の Supplies で V+ を 5 V にする)。

- **エミッタ (列 21)**: 2-3 では `RE` を − レールへ縦に挿したが、ここでは `RE1` を横に (`b21`–`b24`) 挿して列 24 へ渡す
- **列 24 がエミッタ抵抗の分かれ目**: `RE2` を − レールへ縦に挿し、`CE` の + 側も同じ列に挿す。`CE` の − 側 (列 27) は − レールへ
- **出力は下のブロックで取り出す**: 上のブロックの列 21〜27 をエミッタの部品で使うので、コレクタ (列 20) から橙の線で
  下のブロックの列 20 へ渡し、`COUT` (`g20`–`g27`) を下に置く。CH1 の 1+ は `j27`、1− は下の − レールへ。
  **下の − レールは上の − レールと黒い線 (列 30) でつなぐ** (レールは上下で別々)
- それ以外 (ベースの列 9、入力の列 5) は 2-3 のまま

**2-3 を組んだ板があれば**、`RE` (1 kΩ) を抜いて `RE1`・`RE2` を挿し、`CE` を列 24 に挿し直し、`COUT` を下のブロックへ移すだけでこの題になる。

## オシロで見る

W1 を 1 kHz・20 mVpp の正弦波にする。CH2 (入力) は 5 mV/div、CH1 (出力) は 50 mV/div で並べる (尺度が 10 倍違う)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力 (CH2) と出力 (CH1) — 出力は約 17 倍で逆位相
time: 200us/div
trigger: ch2 rising 0V
ch1: {wave: sine 1kHz 340mVpp phase -180deg, range: 50mV/div}
ch2: {wave: sine 1kHz 20mVpp, range: 5mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/21-split-emitter.svg)

図3 の CH1 は約 340 mVpp で、CH2 (20 mVpp) の約 17 倍。CH2 の山で CH1 が谷になる (位相 180°)。
2-3 (10 mVpp → 790 mVpp) より入力を 2 倍にしても出力は半分以下で、利得が抵抗の比で抑えられている。

**歪みを比べる**: W1 を 59 mVpp まで上げると出力が約 1 Vpp になる。WaveForms の Spectrum で CH1 を見ると、
1 kHz の基本波の隣に 2 kHz の 2 次高調波が出る。この回路ではその高さが基本波の約 −36 dB (歪み率 1.7 %)。
2-3 の全バイパスの回路で同じ 1 Vpp (入力 12.7 mVpp) を出すと約 −25 dB (5.3 %) で、`RE1` の負帰還が歪みを 3 分の 1 にしているのが分かる
(どちらも LTspice の計算値。下の「LTspice での確かめ」)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 抵抗 (1/4 W) | 20 kΩ |
| R2 | 抵抗 (1/4 W) | 10 kΩ |
| RC | 抵抗 (1/4 W) | 2.2 kΩ |
| RE1 | 抵抗 (1/4 W) | 100 Ω (バイパスしない。利得を決める) |
| RE2 | 抵抗 (1/4 W) | 910 Ω (CE でバイパス。直流の動作点を決める) |
| CIN, COUT | フィルムコンデンサ | 1 µF |
| CE | 電解コンデンサ | 100 µF |
| Q1 | NPN トランジスタ | 2SC1815 |
| — | 電源 | Analog Discovery の V+ (5 V) |

## 見るべき値

直流の電圧は、W1 を止めてテスターの直流電圧レンジで GND を基準に測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| ベース電圧 | 約 1.6 〜 1.7 V | 分圧の計算どおり (2-3 と同じ) |
| エミッタ電圧 (RE1 の上) | 約 0.93 V | ベースより 0.6〜0.7 V 低い。直流は RE1 + RE2 で決まり、2-3 と同じ |
| RE1 の両端の電圧 | 約 0.09 V | 0.92 mA × 100 Ω。RE1 を流れる直流 |
| コレクタ電圧 | 約 3.0 V | 動作点は 2-3 と同じ |
| 入力 20 mVpp (1 kHz) のときの出力 (CH1) | 約 340 mVpp、入力と逆位相 | 利得 約 17 倍 = −RC / (RE1 + re) |
| 入力 59 mVpp のときの出力 | 約 1 Vpp、2 次高調波は基本波の約 −36 dB | 歪み率 約 1.7 %。全バイパスの 1 Vpp (約 5.3 %) の 3 分の 1 |

## LTspice での確かめ

`sim/21-split-emitter.cir` で図1 の交流の利得を、`sim/21-split-emitter-op.cir` で動作点を、
`sim/21-split-emitter-thd.cir` で出力 1 Vpp のときの歪み率を読んだ。Q1 は 2-3 と同じ 2SC1815 の代用モデル
(hFE 250・f<sub>T</sub> 45 MHz 前後の目安から作った仮定で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ベース電圧 | 約 1.63 V | 1.64 V | 合う |
| エミッタ電圧 | 約 0.93 V | 1.00 V | 近い (モデルの V<sub>BE</sub> が 0.64 V。本文は 0.7 V で見積もった。2-3 と同じずれ) |
| コレクタ電圧 | 約 3.0 V | 2.83 V | 近い (I<sub>C</sub> が 0.99 mA でやや多い) |
| 電圧利得 (1 kHz) | 約 −17 倍 | 17.0 倍 (24.6 dB)、位相 177.6° | 合う |
| hFE を 120・250・400 にしたときの利得 | 動かない | 16.9〜17.1 倍 (差 1.6 %) | 合う (利得は抵抗の比で決まる) |
| 歪み率 (出力 1 Vpp、RE1 100 Ω) | 約 1.7 % | 1.74 % | 本文の値は LTspice の読み (下の表) |

歪み率は `.tran` の最後の 8 周期 (52〜60 ms) を FFT にかけ、基本波 1 kHz に対する 2〜5 次の高調波の大きさから読んだ。

| 回路 | 入力 | 出力 | 歪み率 (THD) | 2 次高調波 |
| --- | --- | --- | --- | --- |
| この題 (RE1 100 Ω・RE2 910 Ω) | 59 mVpp | 0.98 Vpp | 1.74 % | −36.4 dB (3 次 −41.3 dB) |
| 2-3 の全バイパス (RE 1 kΩ、CE で全部バイパス) | 12.7 mVpp | 0.97 Vpp | 5.33 % | −25.5 dB (3 次 −46.1 dB) |

`RE1` の負帰還で歪みが 3 分の 1 (5.33 % / 1.74 % ≈ 3.1) になった。目安の係数 1 + gm × RE1 = 1 + 100 / 28 ≈ 4.6 より小さいのは、
模型のベースの抵抗 (r<sub>bb′</sub> 50 Ω) と信号源が直列に入って帰還の効きを少し弱めるため。

## 出典

自作。2-3 の回路のエミッタだけを分けたもの。

参考: [エミッタ接地回路 (Wikipedia)](https://ja.wikipedia.org/wiki/エミッタ接地回路)、[Common emitter (Wikipedia)](https://en.wikipedia.org/wiki/Common_emitter) (Emitter degeneration の節)
