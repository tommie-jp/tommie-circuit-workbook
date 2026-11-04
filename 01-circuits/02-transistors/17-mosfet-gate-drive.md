---
book: circuits
chapter: 2
id: 2-17
title: MOSFET のゲート駆動 — ゲート抵抗・プルダウン・ミラー容量
tier: 200
source: 自作
era: 今
---

# 2-17 MOSFET のゲート駆動 — ゲート抵抗・プルダウン・ミラー容量

2-5 では、MOSFET のゲートには電流がほとんど流れないと書いた。直流ではそのとおりだが、ゲートは**コンデンサ**で、
オン・オフを切り替える瞬間には、そのコンデンサを充電・放電する電流が流れる。だから切り替えにかかる時間は、
ゲートへ電流を送る抵抗 (**ゲート抵抗** `RG`) と、ゲートの容量で決まる。

ゲートの容量のうち、切り替えの時間を一番長くするのは、ゲートとドレインの間の容量 (**ミラー容量** C<sub>GD</sub>) である。
ドレインが 5 V から 0 V へ落ちる間、ゲート側から見ると C<sub>GD</sub> の両端の電圧が 5 V 変わる。その間、`RG` から来る電流は全部
C<sub>GD</sub> の充電に使われ、ゲートの電圧は一定の値 (**ミラーの平坦部**) で止まる。

2N7000 の C<sub>GD</sub> は 2〜5 pF と小さく (Vishay の資料の C<sub>rss</sub>)、AD3 のオシロでは平坦部がほとんど見えない。
この題では、ゲートとドレインの間に 100 pF の `CM` を足して、パワー MOSFET (C<sub>rss</sub> が数十〜数百 pF) と同じ形を、見える時間に引き延ばす。
加えて、ゲートを GND へ落としておく**プルダウン** `RPD` の役目も見る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 2N7000 のゲート駆動 (RG・RPD と、ゲート-ドレインの CM)
parts:
  W1: square 1,6 1,9 l=$\mathrm{W1}$
  G1: ground 1,9
  RG: resistor 2,6 4,6 10k
  M1: voltmeter 4,6 4,9 l=$\mathrm{CH1}$
  G2: ground 4,9
  RPD: resistor 6,6 6,9 100k
  G3: ground 6,9
  CM: capacitor 6,4 8,4 100p
  VCC: vcc 8,2 5V
  RD: resistor 8,2 8,4 330
  Q1: nmos-e 8,5.8
  G4: ground 8,9
  M2: voltmeter 10,4 10,7 l=$\mathrm{CH2}$
  G5: ground 10,7
wires:
  - 1,6 -- 2,6
  - 4,6 -- 6,6
  - 6,4 -- 6,6
  - 6,6 |- Q1.G
  - 8,4 -- Q1.D
  - Q1.S -- 8,9
  - 8,4 -- 10,4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/17-mosfet-gate-drive.svg)

図1 の電源は AD3 の V+ (5 V)。W1 は 0/5 V・10 kHz の方形波で、`RG` を通してゲートへ。CH1 でゲート、CH2 でドレインを見る。

- **オンのとき**: `RG` と `RPD` の分圧でゲートは 5 × 100 / 110 ≈ **4.55 V**。ドレインの電流は (5 − 0.06) / 330 Ω ≈ **15 mA**
- **ミラーの平坦部の電圧**: 15 mA を流すのに要る V<sub>GS</sub>。しきい値 2.1 V (代表) より少し上の約 **2.5 V** (LTspice の模型で 2.49 V。個体で 1.3〜3.3 V と動く)
- **平坦部の長さ**: その間のゲートの電流は (5 − 2.5) V / 10 kΩ = 0.25 mA。`CM` + C<sub>GD</sub> (105 pF) の両端を 4.9 V 変えるのに
  105 pF × 4.9 V / 0.25 mA ≈ **2.1 µs**。ドレインはこの間に 5 V から 0.06 V へ落ちる
- **`RG` を 1 kΩ に**: 電流が 10 倍 (2.5 mA) になり、平坦部は約 **0.2 µs**。W1 が出す電流の山も 5 mA になる (Wavegen の 10 mA の内)
- **切り替えの損失**: 平坦部の間、Q1 には電圧と電流が同時にかかる。1 回の切り替えで約 ½ × 5 V × 15 mA × 2.1 µs ≈ 80 nJ、
  10 kHz の上り下りで約 1.6 mW (見積り)。電流の大きいパワー MOSFET では、これが熱の主な元になる
- **`RPD` の役目**: W1 の線を抜いたときや、マイコンが起動するまでの出力が開いている間、ゲートは宙に浮く。
  ゲートは数十 pF のコンデンサなので、指を近づけたりドレインからの漏れで電荷がたまると、半端にオンになる。`RPD` がその電荷を逃がす

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 2N7000 のゲート駆動 (CM はゲートとドレインの間)
board: half
parts:
  Q1: transistor e13(D) e14(G) e15(S) 2N7000 cap=below
  RD: resistor a13 +t13 330 cap=left
  CM: capacitor/ceramic c13 c14 100p cap=left
  RPD: resistor a18 -t18 100k
  RG: resistor c18 c24 10k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 2+, 1+, 1-, W1, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.2+ -- b13 green
  - AD.1+ -- a14 blue
  - b14 -- b18 orange
  - a15 -- -t15 black
  - AD.1- -- -t17 black
  - AD.W1 -- a24 yellow
  - AD.2- -- -t27 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/17-mosfet-gate-drive.svg)

図2 は 2-5 と同じ向きに Q1 を挿す。5 V は AD3 の V+ (赤) から上の + レールへ。

- **Q1 (列 13〜15)**: 2N7000 を**平らな面を奥に**して挿し、手前から見て左から D・G・S。S (列 15) は − レールへ
  ※ **実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる**
- **ドレイン (列 13)**: `RD` を + レールへ縦に、CH2 の 2+ (緑) を `b13` に。`CM` (101 の積層セラミック) を `c13`–`c14` でゲートの列へ
- **ゲート (列 14)**: CH1 の 1+ (青) は `a14`。橙の線 `b14`–`b18` で列 18 へ延ばし、`RPD` を − レールへ、`RG` (`c18`–`c24`) を W1 (列 24) へ
- `CM` を抜けば 2N7000 そのものの容量に戻る。`RG` は 10 kΩ と 1 kΩ を挿し替えて比べる

## 計器の設定

計器は AD3 のオシロ (µs の切り替えの波形を見るため)。W1 を Square、10 kHz、Amplitude 2.5 V、Offset 2.5 V (0/5 V) にする。
CH1・CH2 とも 1 V/div・Offset −3 V、時間軸 1 µs/div、CH1 の立ち上がり 1 V でトリガ (Normal)。カーソル X1・X2 を CH1 の平らな所の両端に置く。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 RG 10 kΩ・CM 100 pF — ゲート (CH1) は 2.5 V で約 2.3 µs 止まる
time: 1us/div
trigger: ch1 rising 1V at -4div
ch1: {wave: "= step(t) * min(4.55V * (1 - exp(-t / 1.31us)), 2.49V) + 2.06V * step(t - 3.3us) * (1 - exp(-(t - 3.3us) / 1.32us))", range: 1V/div, position: -3div}
ch2: {wave: "= clip(5V - (t - 1.04us) * 4.94V / 2.26us, 0.06V, 5V)", range: 1V/div, position: -3div}
cursors: [0.72us, 2.98us]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/17-mosfet-gate-drive.svg)

図3 の CH1 は 2.5 V まで上がると止まり (X1)、CH2 が 5 V から 0.06 V まで落ち切る (X2) と、また 4.55 V へ向けて上がる。
X1 から X2 まで約 2.3 µs。図は LTspice の波形 (下の節) を、指数と直線でつないだ形。
`RG` を 1 kΩ にすると、平坦部が 0.2 µs ほどに縮み、時間軸を 100 ns/div にしないと見えない。`CM` を抜くと 10 kΩ でも 0.16 µs になる。
立ち下がり (W1 が 0 V に戻るとき) も、ゲートが 2.5 V で止まる間にドレインが上がる。

**プルダウンを確かめる**: W1 の線を `a24` から抜き、`RPD` も抜いて、ゲートの列に指を近づける。CH2 が 5 V と 0 V の間をふらつく。
`RPD` を挿し直すと 5 V (オフ) で止まる。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RG | 抵抗 (1/4 W) | 10 kΩ と 1 kΩ (挿し替えて比べる) |
| RPD | 抵抗 (1/4 W) | 100 kΩ |
| RD | 抵抗 (1/4 W) | 330 Ω (15 mA。オンの間 75 mW、10 kHz の 50 % で平均 37 mW) |
| CM | 積層セラミックコンデンサ (C0G / NP0) | 100 pF (101)。ミラー容量を見やすくする |
| Q1 | ロジックレベル N-MOSFET | 2N7000 |
| — | 電源 | AD3 の V+ (5 V) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| オンのときのゲート (CH1) | 約 4.55 V | `RG` と `RPD` の分圧 |
| オンのときのドレイン (CH2) | 約 0.06 V (15 mA) | R<sub>DS(on)</sub> が小さい |
| ミラーの平坦部の電圧 (X1・X2 の CH1) | 約 2.5 V | 15 mA を流す V<sub>GS</sub> |
| 平坦部の長さ (RG 10 kΩ・CM あり) | 約 2.3 µs (ドレインの 90→10 % は 2.1 µs) | (C<sub>GD</sub> + `CM`) × ΔV / I<sub>G</sub> |
| ドレインの 90→10 % (RG 1 kΩ・CM あり) | 約 0.19 µs | `RG` に比例して短くなる |
| ドレインの 90→10 % (RG 10 kΩ・CM なし) | 約 0.16 µs | 2N7000 そのものの C<sub>GD</sub> は小さい |

## LTspice での確かめ

`sim/17-mosfet-gate-drive.cir` で、W1 の 0→5 V の段を `RG` に入れる過渡解析を回し、`RG` (1 kΩ・10 kΩ) と `CM` (0・100 pF) を振った。
2N7000 は 2-5 と同じ LEVEL=1 の代用モデル (しきい値 2.1 V) に、内部の容量として C<sub>GS</sub> 20 pF・C<sub>GD</sub> 5 pF を外に置いた仮定。
AD3 のオシロの入力容量を両方の点に 20 pF ずつ置いた (仮定)。どれも実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| オンのときのゲート (RG 10 kΩ / 1 kΩ) | 4.55 V / 4.95 V | 4.55 V / 4.95 V | 合う |
| オンのときのドレイン・電流 | 約 0.06 V・15 mA | 0.062 V・15.0 mA | 合う |
| 平坦部の電圧 (RG 10 kΩ・CM あり) | 約 2.5 V | 2.49 V (ドレイン 50 % の時) | 合う |
| ドレインの 90→10 % (RG 10 kΩ・CM あり) | 約 2.1 µs (計算) | 2.07 µs | 合う |
| ドレインの 90→10 % (RG 1 kΩ・CM あり) | 約 0.2 µs | 0.19 µs | 合う |
| ドレインの 90→10 % (RG 10 kΩ・CM なし) | 約 0.16 µs | 0.16 µs | 本文の値は LTspice の読み |
| ドレインの 10→90 % (切るとき、RG 10 kΩ・CM あり) | 約 1.8 µs | 1.75 µs | 本文の値は LTspice の読み |

切るときが入れるときより少し速いのは、平坦部の間のゲートの電流が 2.5 V / 10 kΩ に `RPD` の 2.5 V / 100 kΩ が加わって、0.275 mA になるため。
2N7000 の実物のしきい値は 0.8〜3 V と個体差が大きいので (2-5)、平坦部の電圧と長さは個体で動く。

## 出典

自作。2N7000 の容量は [Vishay 2N7000 / BS170 のデータシート](https://www.vishay.com/docs/70226/70226.pdf) (70226、C<sub>iss</sub> 22 pF・C<sub>rss</sub> 2 pF の代表値)。

参考: [MOSFET (Wikipedia)](https://ja.wikipedia.org/wiki/MOSFET)、[Miller effect (Wikipedia)](https://en.wikipedia.org/wiki/Miller_effect)
