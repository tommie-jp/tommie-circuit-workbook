---
book: denken
chapter: 4
id: 4-2
title: Y 結線 — 線間電圧は相電圧の √3 倍、位相は 30° 進む
tier: 50
source: 自作
board: BB
---

# 4-2 Y 結線 — 線間電圧は相電圧の √3 倍、位相は 30° 進む

4-1 で作った三相電源 (1 相目・2 相目・3 相目) に、同じ値の抵抗 3 本を星形に
つないだ **Y 結線**の負荷を加える。3 本が集まる点 (中性点 N) は電源の GND に
つながない。相電圧 (相と中性点の間) と線間電圧 (相と相の間) を測って比べる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| V_AB = V_A − V_B | 線間電圧 (A 相と B 相の差) |
| \|V_AB\| = √3 × \|V_A\| | 線間電圧の大きさは相電圧の √3 倍 |
| ∠V_AB = ∠V_A + 30° | 線間電圧の位相は、その相電圧より 30° 進む |
| V_N = (V_A + V_B + V_C) / 3 | 中性点の電圧。平衡なら分子が 0 になるので V_N = 0 |

## 回路図

```circuit
title: 図1 三相電源に Y 結線の負荷
parts:
  V1: sine c1 e1 1 l=$\mathrm{W1}$
  G1: ground e1
  V2: sine i1 k1 1 l=$\mathrm{W2}$
  G2: ground k1
  R1: resistor c3 e3 10k
  R2: resistor i4 g4 10k
  U1: opamp f8 +down TL071
  G3: ground g6
  Rf: resistor d7 d10 10k
  R3: resistor c16 c18 1k
  R5: resistor f16 f18 1k
  R4: resistor i16 i18 1k
wires:
  - e3 -- e4 -- e7
  - e4 -- g4
  - d7 -- e7
  - e7 |- U1.-
  - g6 |- U1.+
  - d10 -- f10
  - c1 -- c3 -- c16
  - i1 -- i4 -- i16
  - U1.out -- f10 -- f16
  - c18 -- c20 -- f20
  - f18 -- f20
  - i18 -- i20
  - f20 -- i20
notes:
  - text b12: 1 相目
  - text g12: 3 相目
  - text h12: 2 相目
  - text d20a3: N
style:
  standard: jis
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/02-star-connection-1.svg)

- R3・R4・R5 (各 1 kΩ) が Y 結線の負荷。3 本が集まる点 (N) はどこにもつながず、
  浮かせたまま (**中性線なし**。中性線ありは 4-4)
- 電源側 (V1・V2・U1 の出力) は電流を流しても電圧が下がらない理想の電源として
  計算する。1 相あたりの電流は 1 V ÷ 1 kΩ = 1 mA で、オペアンプの出力にも
  AD の Wavegen にも十分小さい (Wavegen 側は R1・R2 の 0.1 mA と合わせても
  1.1 mA)

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
# 上のブロック (a〜e) に TL071 の入力側と R1・R2、下のブロック (f〜j) に出力側と Rf
board: full
parts:
  R1: resistor b17 b21 10k
  R2: resistor c25 c21 10k
  Rf: resistor i21 i14 10k
  U1: dip8 @ f13 r180 TL071
  R3: resistor b35 b39 1k
  R4: resistor b42 b46 1k
  R5: resistor b49 b53 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [V+, GND, V-, W1, 2+, W2, 2-, 1+, 1-]
wires:
  - AD.V+ -- +t4 red [v11, h-162]
  - AD.GND -- -t6 black [v19, h-152]
  - AD.V- -- a13 purple [v27, h-52, v79, h-10]
  - AD.W1 -- c17 yellow [v11, h-32]
  - AD.2+ -- a17 yellow
  - AD.W2 -- b25 orange [v27, h48]
  - AD.2- -- a25 orange
  - AD.1+ -- a35 yellow
  - AD.1- -- a39 green
  - a14 -- -t14 black
  - d15 -- d21 green
  - e21 -- f21 green
  - +t2 -- +b2 red
  - j15 -- +b15 red
  - e17 -- f17 yellow
  - g17 -- g35 yellow
  - f35 -- e35 yellow
  - e25 -- f25 orange
  - j25 -- j42 orange
  - f42 -- e42 orange
  - h14 -- h49 blue
  - f49 -- e49 blue
  - d39 -- d46 green
  - a46 -- a53 green
notes:
  - text small: R3・R4・R5 (各 1k) が Y 結線。b53 (R5 の右) が中性点 N (浮かせたまま)
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/breadboard/02-star-connection.svg)

- 1 相目 (R3) を b35 の列、2 相目 (R4) を b42 の列、3 相目 (R5) を b49 の列から
  取り出し、d 行と a 行の緑の線で 39・46・53 列を束ねて中性点 N (53 列) にする。
  3 つの相は下の段の g 行 (1 相目)・j 行 (2 相目)・h 行 (3 相目) で右へ運び、
  短い線で溝を渡って e35・e42・e49 から上の段へ戻す
- AD の 1+・1− は R3 の両端 (a35・a39) に挿し、相電圧 (1 相目 − N) を差動で測る。
  2+・2− は 1 相目 (a17) と 2 相目 (a25) に挿し、線間電圧 (1 相目 − 2 相目) を
  差動で測る。1− も 2− も GND のレールには挿さない
- N は GND のレールにはつながない。1− を N (a39) に挿すときは、GND とは別の場所だと
  確かめてから挿す

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、1 kHz、Amplitude 1 V、Phase 0°。W2: 同じく Phase −120° |
| Supplies | V+ = 5 V、V− = −5 V |
| Scope (1 回目) | CH1 = 1 相目 − N (差動。1+ を a35、1− を a39)、CH2 = 1 相目 − 2 相目 (差動。2+ を a17、2− を a25) |
| Scope (2 回目) | CH1 は同じ。CH2 は 2+ を N (c53)、2− を GND のレールに挿し替え、N の電圧 (GND 基準) を読む |
| Measure | CH1・CH2 の Amplitude と、CH1 に対する CH2 の Phase |

1 回目の画面。CH1 が相電圧、CH2 が線間電圧で、2 つは同じ V/div にしてある。

```scope
title: 図3 線間電圧 (CH2) は相電圧 (CH1) の √3 倍で 30° 進む
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: sine 1kHz 1.732V phase 30deg, range: 500mV/div}
measure: [vmax, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/scope/02-star-connection.svg)

### オシロスコープと発振器

発振器・電源・プローブの読み替えは 4-1 と同じ ([回路の本の 0-3](../../01-circuits/00-measure/03-oscilloscope.md)・
[0-6](../../01-circuits/00-measure/06-bench-supply-limiting.md))。違うのは測り方だ。
AD 版は CH1 を 1 相目と N の間、CH2 を 1 相目と 2 相目の間に差動で当てる。
汎用オシロではグランドクリップを N にも 2 相目にも当てられない。N に当てれば
N が GND に落ちて中性線ありの 4-4 に変わり、2 相目に当てれば FG の CH2 の出力を
GND と短絡する。

**回路はそのまま、先端を当てる点を GND 基準で測り、Math の CH1 − CH2 で引く** (図4)。
引いた結果 (相電圧・線間電圧) は元の 2 つの波と同じくらいの大きさなので、8 bit のオシロでも埋もれない。
測る点は 1 相目・2 相目・N の 3 つで、2 ch では 2 回に分ける。

```circuit
title: 図4 汎用オシロでの測り方
parts:
  U1: port a1
  V1: sine e1 g1 1 l=$\mathrm{FG}_1$
  G1: ground g1
  V2: sine i1 k1 1 l=$\mathrm{FG}_2$
  G2: ground k1
  M1: voltmeter e4 g4 l=$\mathrm{CH1}$
  G3: ground g4
  M2: voltmeter i4 k4 l=$\mathrm{CH2}$
  G4: ground k4
  R5: resistor a6 a9 1k
  R3: resistor e6 e9 1k
  R4: resistor i6 i9 1k
  M3: voltmeter i12 k12 l=$\mathrm{CH2}$
  G5: ground k12
wires:
  - a1 -- a6
  - e1 -- e4 -- e6
  - i1 -- i4 -- i6
  - a9 -- e9 -- i9 -- i12
notes:
  - text a2f5 blue: 3 相目
  - text e2f5 blue: 1 相目
  - text i2f5 blue: 2 相目
  - text e9d4 blue: N
  - text j5 small: 1 回目
  - text j13 small: 2 回目
style:
  standard: jis
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/04-denken/04-three-phase/circuit/02-star-connection-2.svg)

- U1 は図1 の OP アンプの出力 (3 相目)。FG₁・FG₂ は FG の CH1・CH2。
  グランドクリップは 2 本とも GND のレールに挟む
- 1 回目は CH1 を 1 相目 (17 列)、CH2 を 2 相目 (25 列) に当てる。Math の CH1 − CH2 が線間電圧
- 2 回目は CH2 を N (53 列) へ移す。CH2 そのものが N の電圧 (GND 基準)、
  Math の CH1 − CH2 が相電圧。ブレッドボードの部品は動かさない

| 回 | CH1 | CH2 | Math CH1 − CH2 |
| --- | --- | --- | --- |
| 1 回目 | 1 相目 | 2 相目 | 線間電圧 (1 相目 − 2 相目) |
| 2 回目 | 1 相目 | N | 相電圧 (1 相目 − N) |

- 線間電圧の位相は、Math と CH1 のゼロ交差の時間差 Δt をカーソルで読み、
  θ = 360° × 1 kHz × Δt で求める (30° は 83 µs)。Math を位相の Measure に
  使えない機種が多いため。N はほぼ 0 V なので、CH1 の位相が相電圧の位相の代わりになる
- 測る前に 2 本の先端を同じ点 (1 相目) に当て、Math が 0 V 近くになるかを見る。
  ch どうしの利得の差が、そのまま差の誤差になる

**FG の 50 Ω で値が変わる** (計算値)。1 相あたりの負荷は 1 kΩ で、FG の 50 Ω が
直列に入る。相電圧の振幅は 0.95 V、線間電圧は 1.65 V になる。√3 倍と 30° は
変わらない。3 相目の OP アンプは 1・2 相目の端子の電圧 (50 Ω で下がったあと) を
足すので、3 相目も同じだけ下がり、負荷は平衡のままで N は 0 V のまま。

## 見るべき値

計算値。V_A・V_B・V_C は 4-1 で確かめた振幅 1.00 V の三相 (0°、−120°、+120°)。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 相電圧 (1 相目 − N) の振幅 | 1.00 V | R3・R4・R5 が等しいので、相電圧は電源の振幅のまま |
| 線間電圧 (1 相目 − 2 相目) の振幅 | 1.73 V (= √3 × 1.00 V) | 線間電圧は相電圧の √3 倍 |
| 線間電圧の位相 (相電圧に対して) | +30° | 線間電圧は相電圧より 30° 進む |
| N の電圧 (GND 基準) | 0 V (計算値) | 平衡負荷なので中性点は浮いていても GND と同じ電圧になる |

分かること:

- **線間電圧は相電圧より大きく、位相もずれる。** カタログの三相機器の定格が
  「200 V」のように 1 つの数字でも、それは線間電圧で、相電圧は 200/√3 ≒ 115 V
- 中性点 N を浮かせても電圧が暴れないのは、**この負荷が平衡している (3 本とも
  同じ値) から**。1 本だけ値を変えると N が動く (4-14 の中性点の移動で確かめる)

## AD3 を 2 台使う — 3 つの相電圧と線間電圧を同時に

AD3 を 2 台使うと、オシロの入力が 4 ch になる。2 台の配線・GND の共通化・T2 での同期は
[4-1 の「AD3 を 2 台使う」](01-three-phase-source.md) と同じ。W1・W2 と Supplies は AD-A だけが出し、
AD-B は測るだけ (Wavegen も Supplies も使わない)。
この題では、3 つの相電圧 (各相 − N) と線間電圧を、1 回で同時に見られる。

| 台 | CH1 | CH2 |
| --- | --- | --- |
| AD-A | 1 相目 − N (R3 の両端、差動) | 線間電圧 1 相目 − 2 相目 (差動) |
| AD-B | 2 相目 − N (R4 の両端、差動) | 3 相目 − N (R5 の両端、差動) |

計算値 (どれも 1 kHz)。

| 台 | 測る所 | 期待する値 |
| --- | --- | --- |
| AD-A | CH1 の振幅、CH2 の振幅 | 1.00 V、1.73 V |
| AD-A | CH1 に対する CH2 の位相 | +30° |
| AD-B | CH1・CH2 の振幅 | どちらも 1.00 V (3 つの相電圧が等しい) |
| AD-B | CH1 (2 相目) に対する CH2 (3 相目) の位相 | −120° (= +240°) |

- 2 台の 1−・2− はすべて N か 2 相目の点に挿し、**GND のレールには挿さない** (どれかが GND に落ちる)。
  2 台の GND 端子だけを、電源の GND のレールにつなぐ。差動の入力は ±25 V の範囲に収まっていれば読める
- 3 つの相電圧の和が 0 になることは、2 台のあいだで Math が組めないので、画面の値から計算する
  (瞬時値を 1 つの時刻で読み、足す。カーソルで 1 つの時刻に合わせる)
- 実機では確かめていない (計算値)

## 出典

自作。
