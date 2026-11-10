---
book: circuits
chapter: 7
id: 7-8
title: ゲートドライバ IC
tier: 200
source: 自作
era: 今
---

# 7-8 ゲートドライバ IC

7-2 と 7-7 では、MOSFET のゲートを信号源 (5 V) から抵抗 1 本でじかに動かした。これで済むのは、
ゲートの電圧が信号の電圧と同じでよく、切り替えの速さを問わないときだけだ。パワー MOSFET を速く切り替えるには、次の 2 つが要る。

1. **ゲートを十分な電圧まで上げる**。IRF520 のような標準の MOSFET は、ON 抵抗 R<sub>DS(on)</sub> を V<sub>GS</sub> = 10 V で規定している。
   しきい値 V<sub>GS(th)</sub> は 2.0〜4.0 V なので、マイコンの 3.3 V では ON しきらない品がある
2. **ゲートの容量を短い時間で充放電する**。ゲートは数百 pF のコンデンサとして振る舞う。
   切り替えの間は MOSFET の中で電圧と電流が同時に大きく、熱が出る (スイッチング損失)。
   この時間は、ゲートに流し込める電流で決まる

この 2 つを 1 個でこなす IC が**ゲートドライバ**だ。この題では、2 回路入りの TC4427 (Microchip、DIP-8、非反転) を
12 V で動かし、Analog Discovery 3 (AD3) の 3.3 V のパルスを 12 V のゲートの振れに直して IRF520 を切り替える。
TC4427 の入力は 2.4 V 以上を H と読む (データシートの V<sub>IH</sub>) ので、3.3 V のロジックをそのまま入れられる。
出力は電源から GND まで振れ、出力抵抗は 7 Ω (典型)、ピークで 1.5 A を流せる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 TC4427 の B 側で IRF520 のゲートを 12 V で振る (CH1 は入力、CH2 はゲート)
parts:
  U1: dip8 6,5 r270 TC4427
  VCC: vcc 6.4,3 12V
  C2: capacitor 4.4,3 4.4,4.6 100n
  C1: ecap 2.2,3 2.2,4.6 10u
  G1: ground 4.4,4.6
  G2: ground 2.2,4.6
  G3: ground 6.4,6.6
  W1: square 2,7.4 2,9 l=$\mathrm{W1}$
  M1: voltmeter 3.4,7.4 3.4,9 l=$\mathrm{CH1}$
  RPD: resistor 4.8,7.4 4.8,9 10k
  G4: ground 2,9
  G5: ground 3.4,9
  G6: ground 4.8,9
  Rg: resistor 7.4,3.6 8.8,3.6 100
  M2: voltmeter 8.8,3.6 8.8,5.4 l=$\mathrm{CH2}$
  G7: ground 8.8,5.4
  RGS: resistor 10,3.6 10,5.4 10k
  G8: ground 10,5.4
  Q1: nmos-e 11.4,3.41 IRF520
  RL: resistor 11.4,1 11.4,2.4 220
  VCC: vcc 11.4,1 12V
  G9: ground 11.4,5.4
wires:
  - 6.4,3 -- U1.6
  - 6.4,3 -- 4.4,3 -- 2.2,3
  - U1.3 -- 6.4,6.2 -- 6.4,6.6
  - U1.2 |- 6.4,6.2
  - 2,7.4 -- 3.4,7.4 -- 4.8,7.4 -- 6.8,7.4
  - 6.8,7.4 -- U1.4
  - U1.5 |- 7.4,3.6
  - 8.8,3.6 -- 10,3.6
  - 10,3.6 -| Q1.G
  - 11.4,2.4 -- Q1.D
  - Q1.S -- 11.4,5.4
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/circuit/08-gate-driver.svg)

- U1 (TC4427) は B 側の 1 回路だけを使う。入力 IN B は 4 番、出力 OUT B は 5 番、電源 V<sub>DD</sub> は 6 番、GND は 3 番。
  使わない A 側の入力 IN A (2 番) は GND につなぎ、出力 OUT A (7 番) は開けておく。1・8 番は NC (どこにもつながらない)。
  CMOS の入力を開けておくと、しきい値の近くに浮いて A 側が勝手に切り替わり、電流を食う
- C1 (10 µF)・C2 (0.1 µF) は V<sub>DD</sub> のすぐそばのデカップリング。ゲートを充電する一瞬の大きな電流 (ピーク 0.1〜1.5 A) をここから出す。
  無いと 12 V の線のインダクタンスで V<sub>DD</sub> が揺れ、出力の縁が乱れる
- Rg (100 Ω) はゲートの直列抵抗。ゲートに流し込む電流のピークを 12 V ÷ (100 + 7) Ω ≈ 0.11 A に抑え、配線とゲートの容量が作る共振 (縁のリンギング) を抑える。
  **Rg を大きくすると切り替えが遅くなる** (下の表で 100 Ω と 1 kΩ を比べる)
- RGS (10 kΩ) はゲートとソースの間のプルダウン。12 V の電源を先に入れて W1 がまだ出ていないときも、Q1 を OFF に保つ
- RPD (10 kΩ) は入力のプルダウン。W1 を外したとき、IN B を L に保つ
- 負荷は RL (220 Ω、2 W 品)。Q1 が ON のとき 12 V ÷ 220 Ω ≈ 54.5 mA が流れる

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 TC4427 と IRF520 を組む (+ レールが 12 V)
board: half
parts:
  U1: dip8 @ e10 TC4427
  C1: capacitor/electrolytic b12(+) b6(-) 10uF cap=above v=25V
  C2: capacitor/ceramic d12 d6 100n cap=below:-2,0
  Rg: resistor c13 c16 100
  Q1: transistor/to220 h17 h18 h19 IRF520
  RGS: resistor b16 b21 10k
  RL: resistor j18 +b18 220
  RPD: resistor h13 h15 10k cap=above
  PSU:
    type: device
    at: top
    label: 電源 12V (AC アダプタ)
    pins: ["+", "-"]
  ADS:
    type: device
    at: top
    label: AD3 (Scope 2+)
    pins: [2+, 2-]
  ADW:
    type: device
    at: bottom
    label: AD3 (W1・Scope 1+)
    pins: [1+, W1, 1-, GND]
wires:
  - PSU.+ -- +t1 red
  - PSU.- -- -t2 black
  - a12 -- +t12 red
  - a6 -- -t6 black
  - e16 -- f16 orange
  - j16 -- j17 orange
  - j12 -- -b12 black
  - i11 -- i12 black
  - j15 -- -b15 black
  - j19 -- -b19 black
  - a21 -- -t21 black
  - -t29 -- -b29 black
  - +t30 -- +b30 red
  - ADS.2+ -- a16 green
  - ADS.2- -- -t24 black
  - ADW.W1 -- j13 yellow
  - ADW.1+ -- i13 blue
  - ADW.1- -- -b23 black
  - ADW.GND -- -b25 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/breadboard/08-gate-driver.svg)

- U1 は 10〜13 列に挿す。下の段が 1〜4 番 (f10 が 1 番の NC、f11 が IN A、f12 が GND、f13 が IN B)、
  上の段が右から 5〜8 番 (e13 が OUT B、e12 が V<sub>DD</sub>、e11 が OUT A、e10 が NC)
- 12 V の電源 (AC アダプタ) は上の + レールへ。上の − レールと下の − レールは 29 列でつなぐ。
  12 列の上の段が V<sub>DD</sub> で、C1・C2 を 12 列と 6 列 (GND) の間に挿す。C1 の + 側が 12 列
- 下の段の 12 列が GND (`j12` から − レールへ)。IN A (11 列) は黒の短い線で 12 列へつなぐ。IN B (13 列) には W1 (黄) と Scope の 1+ (青) と RPD
- OUT B (13 列の上の段) から Rg を 16 列へ渡す。16 列がゲートの点で、RGS (16 列 → 21 列、21 列は − レール) と Scope の 2+ (緑、`a16`) を挿す。
  16 列は橙の線で下のブロックへ下ろし、`j16` → `j17` の短い線で Q1 のゲートへ入る (Q1 の胴が f・g 行を覆うので、線は胴の外を通す)
- Q1 (IRF520、TO-220) は印字面を手前にして左から G・D・S で、下のブロックの 17・18・19 列に挿す。
  RL を D (18 列) と下の + レールの間に、S (19 列) を − レールへ。下の + レールは 30 列で上の + レールとつなぎ、12 V にする
- **AD3 の Supplies は使わない**。V<sub>DD</sub> と負荷の 12 V は AD3 の Supplies (±5 V) の外なので、12 V の AC アダプタから取る。
  AD3 の GND (1−・2−・GND) は − レールで 12 V の電源の − と共通にする
- RL を流れる 54.5 mA は、+ レール・18 列・19 列・− レールを通る。ブレッドボードの 1 穴 200 mA の内側

## 計器の設定

計器は Analog Discovery 3 の W1 (入力のパルス) と Scope。3.3 V のパルスが 12 V のゲートの振れに直るのは時間の波形で見る。
W1 は Simple の Square、Frequency 10 kHz、Amplitude 1.65 V、Offset 1.65 V (0〜3.3 V)、Symmetry 50 %。
Scope は 1+ を IN B (W1)、2+ を Q1 のゲートにして、2 ch とも 2 V/div、20 µs/div。AD3 の Scope の入力は ±25 V まで読めるので、12 V をそのまま入れてよい。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力 3.3 V (CH1) がゲートで 11.9 V (CH2) になる
time: 20us/div
trigger: ch1 rising 1.65V
ch1: {wave: pulse 10kHz 1.65V offset 1.65V duty 50%, range: 2V/div, position: -3div}
ch2: {wave: "ch1 | gain 3.6", range: 2V/div, position: -3div}
cursors: [25us, 75us]
measure: [vmax, vmin, freq, duty]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/07-power/scope/08-gate-driver.svg)

図3 は理想の形。カーソルの 25 µs は入力が H の真ん中、75 µs は L の真ん中。H の間、CH1 は 3.3 V、CH2 (ゲート) は約 11.9 V になる。
ゲートが 12 V に届かないのは、Rg (100 Ω) と RGS (10 kΩ) で分圧されるから (12 V × 10 kΩ ÷ 10.107 kΩ ≈ 11.87 V)。

**縁を見る**: 2+ を Q1 のドレイン (18 列) へ移し、時間軸を 200 ns/div にして、ドレインが落ちる縁と上がる縁を拡大する。
Rg を 100 Ω から 1 kΩ に替えると、縁がおよそ 3〜10 倍に延びる (下の表)。100 Ω のときの立ち下がり 13 ns は、AD3 の Scope の帯域では縦の線に見える。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | ゲートドライバ IC (2 回路、非反転、DIP-8) | TC4427 (V<sub>DD</sub> 4.5〜18 V、ピーク 1.5 A、V<sub>IH</sub> 2.4 V) |
| Q1 | N チャネル パワー MOSFET (TO-220) | IRF520 (100 V・9.2 A、R<sub>DS(on)</sub> 0.27 Ω 以下 @ V<sub>GS</sub> 10 V) |
| Rg | 抵抗 (ゲート直列) | 100 Ω (比べる用に 1 kΩ) |
| RGS | 抵抗 (ゲートのプルダウン) | 10 kΩ |
| RPD | 抵抗 (入力のプルダウン) | 10 kΩ |
| RL | 抵抗 (負荷、2 W) | 220 Ω (ON で 0.65 W。2 W の半分の 1 W より小さい) |
| C1 | 電解コンデンサ (25 V) | 10 µF |
| C2 | セラミックコンデンサ | 0.1 µF (104) |
| — | 電源 | 12 V の AC アダプタ (IRF520 は V<sub>GS</sub> 10 V で R<sub>DS(on)</sub> を規定しているので、ゲートを 10 V 以上で振るため) |
| — | 計器・信号源 | Analog Discovery 3 の W1 (0〜3.3 V の方形波、10 kHz) と Scope (1+ = IN B、2+ = ゲート、1−・2− = GND) |

## 見るべき値

表の値は計算値と LTspice の値で、実測ではない。直流の電圧は W1 を止め、W1 の代わりに IN B を 3.3 V (AD3 の V+ を 3.3 V にする) か GND につないでテスターで測る。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| IN B = 3.3 V のときのゲート電圧 | 約 11.9 V | 3.3 V のロジックが 12 V の振れに直る (レベル変換) |
| そのときのドレイン電圧 | 15 mV 以下 | 54.5 mA × 0.27 Ω。Q1 が ON しきっている |
| IN B = 0 V のときのドレイン電圧 | 12 V | Q1 が OFF、RL に電流が流れない |
| ドレインの立ち下がり (Rg 100 Ω → 1 kΩ) | 約 13 ns → 約 120 ns (10〜90 %) | 縁の時間はゲートに流せる電流でほぼ決まる |
| ドレインの立ち上がり (Rg 100 Ω → 1 kΩ) | 約 90 ns → 約 310 ns | 切るほうは RGS でも放電するが、ゲートの電圧が低いぶん電流が小さく遅い |
| TC4427 を通さず、W1 (3.3 V) を Rg でじかにゲートへ入れたとき | V<sub>GS(th)</sub> が 4 V に近い品は ON しない | V<sub>GS(th)</sub> の幅 (2.0〜4.0 V) の上の品では、ドライバ無しでは切り替わらない |

スイッチング損失は 1 回の縁で ½ × V × I × t ほど。この回路では ½ × 12 V × 54.5 mA × 0.1 µs × 2 回 × 10 kHz ≈ 0.7 mW と小さいが、
電流が 1 A を超える負荷や、周波数を 100 kHz に上げる降圧の回路 (5 章) では、縁の時間がそのまま熱になる。ゲートを動かすのに TC4427 が使う電力は、
多く見ても Q<sub>g</sub> × V<sub>DD</sub> × f = 16 nC × 12 V × 10 kHz ≈ 1.9 mW (Q<sub>g</sub> はデータシートの最大値)。

## LTspice での確かめ

`sim/08-gate-driver.cir` で図1 を回した。TC4427 は振る舞いの模型 (しきい値 1.6 V、出力抵抗 7 Ω)、IRF520 は VDMOS の模型
(V<sub>GS(th)</sub> 3.0 V、容量はデータシートの C<sub>iss</sub> 360 pF・C<sub>rss</sub> 34 pF に寄せた) で、どちらも仮定で実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| ON のゲート電圧 (Rg 100 Ω) | 約 11.9 V | 11.87 V | 合う |
| ON のゲート電圧 (Rg 1 kΩ) | 約 10.9 V (分圧) | 10.90 V | 合う |
| ON のドレイン電圧 | 15 mV 以下 | 11 mV | 合う |
| ON の負荷電流 | 54.5 mA | 54.5 mA | 合う |
| ドレインの立ち下がり (Rg 100 Ω / 1 kΩ) | 約 13 ns / 約 120 ns | 13 ns / 123 ns | 本文の値は LTspice の読み |
| ドレインの立ち上がり (Rg 100 Ω / 1 kΩ) | 約 90 ns / 約 310 ns | 94 ns / 313 ns | 本文の値は LTspice の読み |
| 直結 (3.3 V) で V<sub>GS(th)</sub> 2 / 3 / 4 V | 4 V の品は ON しない | ドレイン 0.02 V / 0.09 V / 12.0 V | 合う |

縁の時間は、模型の容量の置き方で 2 倍ほど動く (目安)。100 Ω と 1 kΩ の比 (3〜10 倍) は、ゲートの電流が Rg で決まることから来るので、模型に寄らない。

## 出典

自作。

参考: [Microchip TC4426/TC4427/TC4428 のデータシート](https://ww1.microchip.com/downloads/en/DeviceDoc/20001422G.pdf)、[Vishay IRF520 のデータシート](https://www.vishay.com/docs/91017/irf520.pdf)、[Power MOSFET (Wikipedia)](https://en.wikipedia.org/wiki/Power_MOSFET)
