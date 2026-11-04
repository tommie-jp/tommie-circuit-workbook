---
book: circuits
chapter: 10
id: 10-17
title: レベル変換 (3.3V ↔ 5V)
tier: 200
source: 自作 (回路の形は NXP の AN10441)
era: 今
---

# 10-17 レベル変換 (3.3V ↔ 5V)

Raspberry Pi Pico 2 (第 11 章) やセンサーの多くは 3.3 V で動き、10-1〜10-8 の 74HC や CD4000 系は 5 V で動かしてきた。
2 つをそのままつなぐと、向きによって別の困り方をする。

- **3.3 V → 5 V**: 5 V の 74HC が H と読むには入力が約 3.5 V 要る (TI の SN74HC04 のデータシートで V<sub>IH</sub> の最小は 4.5 V のとき 3.15 V、6 V のとき 4.2 V。5 V はその間)。
  3.3 V の H は届かず、H か L か決まらない
- **5 V → 3.3 V**: 3.3 V の IC の入力に 5 V を入れると、絶対最大定格を超える品が多い。入れてよいかは、その IC のデータシートで確かめる

この題では、N ch MOSFET 1 個と抵抗 2 本で両方向に変換する回路 (NXP の AN10441 が I2C のために示した形) を、
2N7000 と 78L33 (5 V から 3.3 V を作るレギュレータ) で組む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 78L33 で 3.3 V を作り 2N7000 1 個で 3.3 V 側と 5 V 側をつなぐ
parts:
  VCC: vcc 2,1 5V
  Cin: capacitor 2,2 2,4 330n
  GCin: ground 2,4
  U1: regulator 5,2 78L33
  GU1: ground 5,4
  Cout: capacitor 7,2 7,4 100n
  GCout: ground 7,4
  RL: resistor 9,3 9,6 10k
  Q1: nmos 11,6 r90 2N7000
  VCC: vcc 13,3 5V
  RH: resistor 13,3 13,6 10k
  LV: port 7,6 inout
  HV: port 15,6 inout
wires:
  - 2,1 -- 2,2
  - 2,2 -- U1.in
  - U1.gnd -- 5,4
  - U1.out -- 7,2
  - 7,2 -- 9,2
  - 9,2 -- 11,2
  - 9,2 -- 9,3
  - 11,2 -- Q1.G
  - 7,6 -- 9,6
  - 9,6 -- Q1.S
  - Q1.D -- 13,6
  - 13,6 -- 15,6
notes:
  - text 9.5,1.5 blue left: 3.3V
  - text 6,7 blue center: 3.3 V 側
  - text 15,7 blue center: 5 V 側
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/17-level-shift.svg)

- U1 (78L33) が AD3 の 5 V から 3.3 V を作る。Cin 0.33 µF・Cout 0.1 µF は 78L33 のデータシートの推奨の値
- Q1 のゲートは 3.3 V に固定。ソースが 3.3 V 側 (LV)、ドレインが 5 V 側 (HV)。RL・RH (10 kΩ) がそれぞれの電源へ引き上げる
- **3.3 V 側が L のとき**: V<sub>GS</sub> = 3.3 V で Q1 がオンし、5 V 側も L に引かれる
- **3.3 V 側が H (3.3 V) のとき**: V<sub>GS</sub> = 0 で Q1 は切れ、5 V 側は RH で 5 V
- **5 V 側が L に引かれたとき**: まず Q1 のボディダイオード (ソースからドレインへ向く) が 3.3 V 側を 0.6 V ほどまで引き下げ、
  V<sub>GS</sub> が 2.7 V に上がって Q1 がオンし、3.3 V 側も L
- **5 V 側が H のとき**: Q1 は切れ、3.3 V 側は RL で 3.3 V。5 V は 3.3 V 側に届かない
- どちらの側も「L に引くか、手を離すか」で動くので、10-16 のオープンドレインの線、特に 10-18 の I2C にそのまま使える。
  3.3 V 側を AD3 の Wavegen のようなプッシュプルで振ってもよい
- 2N7000 のしきい値は 0.8〜3 V (Vishay の 2N7000 のデータシート)。ゲートが 3.3 V なので、しきい値が 3 V に近い品は
  オンが弱い。L が上がるときは、しきい値の低い MOSFET (BSS138 など) を載せた市販の変換基板に替える

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 ブレッドボードに組む (下の赤レールが 5 V、上の赤レールが 78L33 の 3.3 V)
board: half
parts:
  AD:
    type: device
    at: bottom
    label: AD3 Supplies・Wavegen・Scope
    pins: [GND, V+, W1, 1+, 2+, 1-, 2-]
  U1: regulator h3 h4 h5 78L33
  Cin: capacitor/ceramic i5 i7 330n cap=right
  Cout: capacitor/ceramic b3 b1 100n
  Q1: transistor c10 c11 c12 2N7000
  RL: resistor d10 d7 10k
  RH: resistor h12 h15 10k
wires:
  - AD.GND -- -b1 black
  - AD.V+ -- +b2 red
  - -b30 -- -t30 black
  - j5 -- +b5 red
  - j4 -- -b4 black
  - j7 -- -b7 black
  - f3 -- e3 red
  - a3 -- +t3 red
  - a1 -- -t1 black
  - a11 -- +t11 red
  - a7 -- +t7 red
  - e10 -- f10 yellow
  - g10 -- g8 yellow
  - e12 -- f12 blue
  - j15 -- +b15 red
  - AD.W1 -- j8 yellow
  - AD.1+ -- j10 white
  - AD.2+ -- j12 blue
  - AD.1- -- -b20 black
  - AD.2- -- -b21 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/breadboard/17-level-shift.svg)

- この図では**下の赤レールが 5 V** (AD3 の V+)、**上の赤レールが 3.3 V** (78L33 の出力)。青レールは上下とも GND で、右端でつなぐ
- U1 (78L33、TO-92) は 3〜5 列で、平らな面を手前にして左から OUT・GND・IN。IN (5 列) を下の赤レール (5 V)、GND (4 列) を青レールへ。
  OUT (3 列) は溝をまたぐ赤の線で上へ渡し、上の赤レール (3.3 V) へ。Cin (334) は 5 列から 7 列 (GND)、Cout (104) は 3 列から 1 列 (GND)
- Q1 (2N7000) は 10〜12 列で、平らな面を手前にして S・G・D (資料が食い違うので、実物はテスタで確かめる)。G (11 列) を 3.3 V へ。
  S (10 列) が 3.3 V 側で、RL (7〜10 列) で 3.3 V へ。D (12 列) が 5 V 側で、溝をまたいだ下の 12 列から RH (12〜15 列) で 5 V へ
- 3.3 V 側は黄の線で下の 10 列へ渡し、8 列へも延ばす。AD3 の W1 を 8 列、1+ を 10 列、2+ を 12 列 (5 V 側) に挿す
- 電流は 78L33 の自己消費 (数 mA) と RL・RH の 0.5 mA ずつで、数 mA。78L33 の損失は (5 V − 3.3 V) × 数 mA で 10 mW ほど

## 計器の設定

計器は AD3 の Supplies (5 V)・Wavegen (W1)・Scope。まず W1 で 3.3 V 側を振り、5 V 側に 0〜5 V の方形波が出ることを見る (図3)。
次に W1 の線を 12 列 (5 V 側) へ挿し替え、W1 を 0〜5 V にして、3.3 V 側に 0〜3.3 V が出ることを見る (逆向き)。

| 項目 | 値 |
| --- | --- |
| Supplies | V+ を 5 V |
| W1 | Square、10 kHz、Amplitude 1.65 V、Offset 1.65 V (0〜3.3 V)。逆向きのときは 0〜5 V |
| CH1 (1+) | 3.3 V 側 (10 列)。2 V/div、0 V を下から 1 目盛 |
| CH2 (2+) | 5 V 側 (12 列)。CH1 と同じ尺度 |
| 時間 | 20 µs/div、トリガは CH1 の立ち上がり 1.65 V、トリガの点を左から 1 目盛 |
| Measurements | Max・Min・Frequency |
| カーソル | X1 = 25 µs (H の中)、X2 = 75 µs (L の中) |

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 3.3 V 側 (CH1) の 0〜3.3 V が 5 V 側 (CH2) で 0〜5 V になる (計算)
time: 20us/div
trigger: ch1 rising 1.65V at -4div
ch1: {wave: square 10kHz 1.65V offset 1.65V, range: 2V/div, position: -3div}
ch2: {wave: square 10kHz 2.495V offset 2.505V, range: 2V/div, position: -3div}
cursors: [25us, 75us]
measure: [vmax, vmin, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/scope/17-level-shift.svg)

- 図3 は計算で作った理想の波形。CH2 の L は LTspice の 10 mV ほどにした。5 V 側は L のとき Q1 で引かれ、H のとき RH で戻る
- 5 V 側の立ち上がりは RH と線の容量で決まる。プローブと配線を 20 pF とすると 0.44 µs (LTspice。目安) で、この時間軸では縦の線。
  I2C の 100 kHz (10-18) なら間に合うが、1 MHz を超える速い信号には向かない

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 3 端子レギュレータ (3.3 V、100 mA) | 78L33 (TO-92) |
| Cin・Cout | 積層セラミックコンデンサ | 0.33 µF (334)・0.1 µF (104) |
| Q1 | N ch MOSFET | 2N7000 (TO-92) |
| RL・RH | 抵抗 (1/4 W)、引き上げ | 10 kΩ × 2 本 |
| — | 電源・信号源・計器 | Analog Discovery 3 (V+ は 5 V。3.3 V は U1 で作る) |

## 見るべき値

| 入れる側 | 入れる値 | 3.3 V 側 | 5 V 側 |
| --- | --- | --- | --- |
| 3.3 V 側 | H (3.3 V) | 3.3 V | 5.0 V (RH で) |
| 3.3 V 側 | L (0 V) | 0 V | 10 mV 前後 (Q1 がオン) |
| 5 V 側 | H (5 V) | 3.3 V (RL で) | 5.0 V |
| 5 V 側 | L (0 V) | 10 mV 前後 (ボディダイオードのあと Q1 がオン) | 0 V |

- L を引いている側は、相手側の引き上げの電流 (5 V ÷ 10 kΩ = 0.5 mA) も吸い込む
- 抵抗 2 本で 5 V を分けて 3.3 V にする方法 (例: 10 kΩ と 20 kΩ) は 5 V → 3.3 V の片方向だけで、逆向きには使えない。
  分けた後の出力抵抗 (6.7 kΩ) と入力の容量で、立ち上がりも遅くなる

## LTspice での確かめ

`sim/17-level-shift.cir` で、2N7000 を LEVEL 1 の近似にボディダイオードを足した形 (仮定) にし、しきい値を .step で 2.1 V (典型) と 3.0 V (データシートの最大) にした。
3.3 V は理想の電源、線の容量は各 20 pF とした (目安)。

| 項目 | 本文の数字 | LTspice (しきい値 2.1 V / 3.0 V) | 判定 |
| --- | --- | --- | --- |
| 3.3 V 側 H → 5 V 側 | 5.0 V | 5.00 V / 5.00 V | 合う |
| 3.3 V 側 L → 5 V 側 | 10 mV 前後 | 4.2 mV / 17.1 mV | 合う |
| 5 V 側 H → 3.3 V 側 | 3.3 V | 3.30 V / 3.30 V | 合う |
| 5 V 側 L → 3.3 V 側 | 10 mV 前後 | 2.8 mV / 11.2 mV | 合う |
| L の間に RH を流れる電流 | 0.5 mA | 0.500 mA / 0.498 mA | 合う |
| 5 V 側の立ち上がり (10 → 90 %) | 0.44 µs (目安) | 0.445 µs / 0.441 µs | 合う |

しきい値 3.0 V の場合でも L は 20 mV 未満で、3.3 V・5 V のどちらの入力にも十分低い。ただし LEVEL 1 の近似は
しきい値の近くの電流を大きめに出すので、実物のしきい値が高い品では L がもっと上がることがある (実機で確かめる)。

## 出典

回路の形は NXP のアプリケーションノート AN10441 (Level shifting techniques in I2C-bus design) による。図と文は描き直した。

参考: [2N7000 データシート (Vishay)](https://www.vishay.com/docs/70226/70226.pdf)、[SN74HC04 データシート](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf)、[Level shifter (英語版 Wikipedia)](https://en.wikipedia.org/wiki/Level_shifter)
