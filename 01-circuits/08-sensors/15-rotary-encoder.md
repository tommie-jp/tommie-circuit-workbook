---
book: circuits
chapter: 8
id: 8-15
title: ロータリーエンコーダ
tier: 200
source: 自作
board: BB
---

# 8-15 ロータリーエンコーダ

ロータリーエンコーダは、軸を回した**向き**と**量**を 2 本の方形波で出す部品である。可変抵抗 (ボリューム) と違って端が無く、
何回でも回せる。音量のつまみ、マウスのホイール、測定器のダイヤルに使われる。

中には 2 組の接点 (A 相と B 相) があり、軸を回すと GND へ閉じたり開いたりする。2 組は**1/4 周期 (90°) ずらして**
置いてあるので、どちらが先に変わるかで向きが分かる。この 2 本の関係を**直交 (クアドラチャ)** という。

- 時計回り: A が先に L になり、1/4 周期遅れて B が L になる
- 反時計回り: B が先に L になり、A が遅れる

この題では、モジュールの KY-040 (CLK = A 相、DT = B 相) を使い、Analog Discovery 3 (AD3) のオシロで 2 本の 90° のずれを見る。
向きは、**A が L に変わった瞬間の B の値**で決まる。これを D フリップフロップ (74HC74) で覚えさせ、
時計回りなら緑、反時計回りなら赤の LED を点ける。接点は機械なので 8-11 のリードスイッチと同じく跳ねる。跳ねで
フリップフロップが誤って動かないよう、RC と 74HC14 (シュミット) で整えてから入れる。マイコンで向きと回数を数える方法は 11-8 で扱う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 KY-040 の 2 相を整え、74HC74 で回す向きを覚える
parts:
  M1:
    type: device
    model: KY-040
    at: 2,4
    pins: [VCC, DT, CLK, GND]
    turn: mirror
  VCC: vcc 4,2 5V
  G0: ground 3.3,6
  M2: voltmeter 5,4 5,6 l=$\mathrm{CH2}$
  G1: ground 5,6
  R2: resistor 6.5,4 8,4 10k
  C2: capacitor 8,4 8,6 10n
  G2: ground 8,6
  U1B: not 10,4 74HC14
  M3: voltmeter 5,8 5,10 l=$\mathrm{CH1}$
  G3: ground 5,10
  R1: resistor 6.5,8 8,8 10k
  C1: capacitor 8,8 8,10 10n
  G4: ground 8,10
  U1A: not 10,8 74HC14
  U2: ic 15,6 74HC74
  VCC: vcc 15,3 5V
  G5: ground 15,8.5
  R3: resistor 19,5.5 21,5.5 1k
  D1: led 21,5.5 21,7.5 red
  G6: ground 21,7.5
  R4: resistor 18,9.5 20,9.5 1k
  D2: led 20,9.5 20,11.5 green
  G7: ground 20,11.5
  VCC: vcc 23,2 5V
  C3: capacitor 23,2 23,4 100n
  G8: ground 23,4
  VCC: vcc 26,2 5V
  C4: capacitor 26,2 26,4 100n
  G9: ground 26,4
wires:
  - M1.VCC -| 4,2
  - M1.GND -| 3.3,6
  - M1.DT -- 5,4 -- 6.5,4
  - 8,4 -- U1B.in
  - U1B.out -| U2.1D
  - M1.CLK -| 3.8,8
  - 3.8,8 -- 5,8 -- 6.5,8
  - 8,8 -- U1A.in
  - U1A.out -- 12,8
  - 12,8 |- U2.1CLK
  - U2.VCC |- 14,3.5
  - U2.1PRE |- 14.5,3.5
  - U2.1CLR |- 15,3.5
  - 14,3.5 -- 14.5,3.5 -- 15,3.5 -- 15,3
  - U2.GND |- 15,8.5
  - U2.1Q -| 19,5.5
  - U2./1Q -| 18,9.5
notes:
  - text 17,12.5 blue left: "C3・C4 は U1・U2 の 14 番と 7 番の間"
  - text 17,13.5 blue left: "U2 の 2 回路目の入力 (10 から 13 番) は 5V へ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/15-rotary-encoder.svg)

- **KY-040** は、エンコーダの接点と、CLK・DT を 5 V へ引き上げる 10 kΩ のプルアップの抵抗を載せた基板 (プルアップは図1 では箱の中にあって描いていない。
  載っているかは買った基板の表面の抵抗で確かめる)。接点が閉じると L (0 V)、開くと H (5 V)。押しボタンの SW は使わない
- **R1・C1 と R2・C2** は 8-11 と同じ跳ね止め。接点が閉じると C は R (10 kΩ) を通して放電し (τ = 10 kΩ × 10 nF = 0.1 ms)、
  開くとプルアップと R の 20 kΩ を通して充電される (τ = 0.2 ms)。跳ね (1 ms 以下が多い) の間の細かい開きでは C の電圧はしきい値まで戻らない。
  手で回すとき、1 クリックの間隔は速くても 10 ms ほどなので、0.2 ms の遅れは問題にならない
- **U1A・U1B (74HC14)** は C の鈍った電圧を切れのよい方形波に戻す。インバータなので向きが逆になり、A 相が L に変わる瞬間が U1A の出力の立ち上がりになる
- **U2 (74HC74)** は、CLK の入力の立ち上がりで D の入力の値を取り込み、次の立ち上がりまで Q に出し続ける。CLK に U1A (A 相の反転)、
  D に U1B (B 相の反転) を入れたので、**A 相が L になった瞬間の B 相の反転**が Q に残る
  - 時計回り: A 相が先に L になる。その瞬間 B 相はまだ H なので、D は L。Q = L、/Q = H で **D2 (緑) が点く**
  - 反時計回り: B 相が先に L になっている。A 相が L になる瞬間、D は H。Q = H で **D1 (赤) が点く**
- PRE と CLR (1 番・4 番) は L で働く入力なので、使わないときは 5 V へつなぐ。2 回路目の入力も 5 V へ (浮かせない)
- LED の電流は (5 − 2.0) V ÷ 1 kΩ ≈ 3 mA (74HC74 の出力は 4 mA で 4.5 V 電源でも 3.84 V 以上を保証するので、ほぼ 5 V が出る)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 KY-040・RC・74HC14・74HC74 を組む (KY-040 は下、AD3 は上から線でつなぐ)
board: full
parts:
  R1: resistor h2 h6 10k
  C1: capacitor/ceramic j6 -b6 10n
  R2: resistor h8 h12 10k
  C2: capacitor/ceramic j12 -b12 10n
  U1: dip14 @ e14 74HC14
  C3: capacitor/ceramic c11 c14 100n
  U2: dip14 @ e26 74HC74
  C4: capacitor/ceramic c23 c26 100n
  R3: resistor h30 h35 1k
  D1: led i35(A) i37(K) red i=3mA
  R4: resistor g31 g40 1k
  D2: led h40(A) h42(K) green i=3mA
  M1:
    type: device
    at: bottom
    model: KY-040
    pins: [CLK, VCC, GND, DT]
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (Supplies・Scope)
    pins: [V+, 1+, GND, 2+, 1-, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t7 black
  - +b63 -- +t63 red
  - -b62 -- -t62 black
  - M1.VCC -- +b4 red
  - M1.GND -- -b5 black
  - M1.CLK -- j2 yellow
  - M1.DT -- j8 blue
  - g6 -- g14 yellow
  - i12 -- i16 blue
  - +t14 -- a14 red
  - a11 -- -t11 black
  - a15 -- -t15 black
  - a17 -- -t17 black
  - a19 -- -t19 black
  - j18 -- -b18 black
  - j20 -- -b20 black
  - g15 -- g28 orange
  - h17 -- h27 green
  - +t26 -- a26 red
  - a23 -- -t23 black
  - a27 -- +t27 red
  - a28 -- +t28 red
  - a29 -- +t29 red
  - a30 -- +t30 red
  - j26 -- +b26 red
  - j29 -- +b29 red
  - j32 -- -b32 black
  - j37 -- -b37 black
  - j42 -- -b42 black
  - e2 -- f2 yellow
  - e8 -- f8 blue
  - AD.1+ -- a2 yellow
  - AD.1- -- -t13 black
  - AD.2+ -- a8 blue
  - AD.2- -- -t16 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/15-rotary-encoder.svg)

- 電源は AD3 の Supplies の V+ (5 V) を上の + レールへ、GND を上の − レールへ。右端 (列 63・62) で下のレールへ渡す
- **KY-040** はブレッドボードに挿さず、メス-オスのジャンパ線で下からつなぐ。`+` (VCC) を + レール、GND を − レール、CLK (黄) を `j2`、DT (青) を `j8` へ。SW は使わない
- **跳ね止め**: CLK は R1 (列 2〜6) と C1 (列 6 と − レール)、DT は R2 (列 8〜12) と C2 (列 12 と − レール)
- **74HC14 (U1)** は列 14〜20。列 6 を黄の線で 1 番 (1A、`f14`) へ、列 12 を青の線で 3 番 (2A、`f16`) へ。2 番 (1Y、列 15) が A 相の反転、4 番 (2Y、列 17) が B 相の反転
- **74HC74 (U2)** は列 26〜32。下の列が 1〜7 番で、1 番 1CLR (列 26)・2 番 1D (列 27)・3 番 1CLK (列 28)・4 番 1PRE (列 29)・5 番 1Q (列 30)・6 番 /1Q (列 31)・7 番 GND (列 32)。
  1Y (列 15) を橙の線で 1CLK (列 28) へ、2Y (列 17) を緑の線で 1D (列 27) へ。1CLR と 1PRE は下の + レールへ
- **使わない入力**: 74HC14 の 5・9・11・13 番は − レールへ。74HC74 の 2 回路目の 10〜13 番 (上の列 27〜30) は + レールへ
- **LED**: 1Q (列 30) → R3 → D1 (赤、反時計回り)、/1Q (列 31) → R4 → D2 (緑、時計回り)。カソードは − レールへ
- オシロは上から当てる。列 2 と列 8 を黄・青の短い線で上のブロックへ渡し、1+ (黄) を CLK の生の電圧 (`a2`)、2+ (青) を DT の生の電圧 (`a8`) に挿す
- 電流は LED 1 個の 3 mA、プルアップの 0.5 mA × 2、IC 2 個の 1 mA 以下で、合わせて 5 mA ほど。AD3 の Supplies とブレッドボードの範囲に収まる

## 計器の設定

計器は AD3。Supplies の V+ を 5 V。Scope は CH1 を CLK (A 相)、CH2 を DT (B 相) にして、横 10 ms/div、縦はどちらも 2 V/div
(CH1 を上、CH2 を下に分けて置く)。手で回す速さは一定にならないので、**Single** にして CH1 の立ち下がり 2.5 V でトリガを掛ける。
軸を時計回りに、1 秒に 1/4 回転ほどの速さで回す。

見えるはずの画面 (時計回りに 1 クリックあたり 40 ms (25 Hz) で一定に回したと**仮定**した理想の形。跳ねは描いていない。実測ではない)。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 時計回り — A 相 (CH1) が B 相 (CH2) より 1/4 周期先に L になる
time: 10ms/div
trigger: ch1 falling 2.5V at -4div
ch1: {wave: square 25Hz 2.5V offset 2.5V phase 180deg, range: 2V/div, position: 1div}
ch2: {wave: square 25Hz 2.5V offset 2.5V phase 90deg, range: 2V/div, position: -3.5div}
cursors: [0, 10ms]
measure: [freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/scope/15-rotary-encoder.svg)

- CH1 が L に落ちてから、1/4 周期 (図3 では 10 ms) 遅れて CH2 が L に落ちる。カーソル X1・X2 の差がそのずれ
- Measurements の Phase は CH1 に対する CH2 の遅れで −90°。反時計回りに回すと CH2 が先に落ち、+90° (進み) に変わる
- 跳ねは落ちる所と上がる所に細い針として出る。横を 200 µs/div に広げると、1 回の落ちる所に数本の針が見えることがある。
  CH2 を U1 の 2 番 (列 15) に挿し替えると、跳ねが消えて約 0.1 ms 遅れた 1 本の立ち上がりになる
- 回す向きを変えると、最初の 1 クリックで LED の色が切り替わる

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| M1 | ロータリーエンコーダのモジュール | KY-040 (CLK・DT・SW・+・GND の 5 ピン。CLK・DT に 10 kΩ のプルアップ) |
| R1, R2 | 抵抗 (1/4 W) | 10 kΩ |
| R3, R4 | 抵抗 (1/4 W) | 1 kΩ |
| C1, C2 | 積層セラミックコンデンサ | 0.01 µF (103) |
| C3, C4 | 積層セラミックコンデンサ | 0.1 µF (104) |
| U1 | シュミットトリガのインバータ | 74HC14 (2 回路を使う) |
| U2 | D フリップフロップ | 74HC74 (1 回路を使う) |
| D1 | LED (赤、反時計回り) | V<sub>F</sub> ≈ 2.0 V |
| D2 | LED (緑、時計回り) | V<sub>F</sub> ≈ 2.0 V |
| — | 電源 | 5 V (AD3 の Supplies の V+。合わせて約 5 mA) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CLK・DT (止めたとき) | 5 V か 0 V (クリックの位置で決まる) | 接点が開けばプルアップで H、閉じれば L |
| CH1 と CH2 のずれ (時計回り) | CH2 が 1/4 周期 (90°) 遅れる | 直交の 2 相。向きはどちらが先かで決まる |
| CH1 と CH2 のずれ (反時計回り) | CH2 が 1/4 周期 (90°) 進む | 同上 |
| 接点が閉じてから U1 の出力が H になるまで | 約 0.1 ms | τ = R1 × C1 = 0.1 ms の放電が V<sub>T−</sub> まで下がる時間 |
| 時計回りに回したあとの LED | D2 (緑) が点き、D1 は消える | A 相が落ちた瞬間の B 相 (H) の反転 (L) が Q に残る |
| 反時計回りに回したあとの LED | D1 (赤) が点く | 同じ瞬間の B 相が L なので Q = H |
| LED の電流 | 約 3 mA | (5 − 2.0) V ÷ 1 kΩ |

時計回りで緑が点かず赤が点くときは、モジュールの A 相と B 相の割り当てが逆の品なので、CLK と DT の線を入れ替える。

## LTspice での確かめ

`sim/15-rotary-encoder.cir` で図1 を解いた。接点は GND へのスイッチとプルアップ 10 kΩ で置き、
時計回り (A 相が 10 ms 先) と反時計回り (B 相が 10 ms 先) の 2 通りを `.step` で回した (跳ねは入れていない)。
74HC14 は SCHMITT (8-11 と同じしきい値)、74HC74 は LTspice の DFLOP で置いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 接点が閉じてから U1A の出力が H になるまで | 約 0.1 ms | 0.108 ms | 合う |
| 時計回りのあとの Q・/Q | L・H (緑が点く) | 0 V・5.0 V | 合う |
| 反時計回りのあとの Q・/Q | H・L (赤が点く) | 5.0 V・0 V | 合う |
| LED の電流 | 約 3 mA | 3.05 mA | 合う |

跳ねを含めた動き (RC が跳ねを吸う) は 8-11 の LTspice で確かめた形と同じで、ここでは解いていない。
KY-040 の中の接点の跳ねの長さは品と回し方で変わる。

## 出典

自作。74HC74 と 74HC14 の動作は Texas Instruments の [SN74HC74 データシート](https://www.ti.com/lit/ds/symlink/sn74hc74.pdf)
(Function Table) と [SN74HC14 データシート](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf)。

参考: [ロータリエンコーダ (Wikipedia)](https://ja.wikipedia.org/wiki/ロータリエンコーダ)、[Rotary encoder (Wikipedia)](https://en.wikipedia.org/wiki/Rotary_encoder)
