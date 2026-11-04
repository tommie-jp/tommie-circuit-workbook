---
book: circuits
chapter: 2
id: 2-13
title: シュミットトリガ (Tr 2 石)
tier: 200
source: 自作
era: 古
---

# 2-13 シュミットトリガ (Tr 2 石)

ゆっくり変わる電圧や雑音の乗った電圧を、きれいな 2 値に直す回路が**シュミットトリガ**。
上がるときと下がるときで切り替わる電圧 (しきい値) が違い、その差 (**ヒステリシス**) より小さい揺れでは出力が動かない。
今は 74HC14 や 40106 (3-8) の 1 ゲートで済むが、中身の考え方は、トランジスタ 2 石のこの回路と同じ。

この回路は Q1 と Q2 が**エミッタの抵抗 `RE` を共有**し、どちらか一方だけが電流を流す。

- 入力が低いとき: Q1 は切れ、Q2 は `R1`・`R2` の分圧でオン。`RE` には Q2 の電流が流れ、エミッタは約 2.5 V に持ち上がる。
  Q1 がオンになるには、入力がこのエミッタより V<sub>BE</sub> だけ高い所 (約 3.1 V) まで上がらなければならない
- 入力が約 3.1 V を越えると Q1 が流し始め、Q1 のコレクタが下がって Q2 のベースを引き下げる。Q2 の電流が減ると `RE` の電圧が下がり、
  Q1 の V<sub>BE</sub> がさらに増える。この**正帰還**で、一瞬で Q1 がオン・Q2 がオフに入れ替わる
- 戻るときは、Q2 のベースが Q1 のコレクタで決まるので、入力を約 1.8 V まで下げないと Q2 が戻らない

この題では、AD3 の W1 から 0〜5 V の三角波を入れ、出力 (Q2 のコレクタ) が 3.0 V で上がり 1.8 V で下がることを、オシロのカーソルで読む。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 エミッタ結合のシュミットトリガ (RE を Q1・Q2 で共有)
parts:
  VCC: vcc 7,2 5V
  RC1: resistor 7,2 7,5 2.2k
  Q1: npn 7,7
  R1: resistor 7,5 10,5 10k
  R2: resistor 10,7 10,9 22k
  G2: ground 10,9
  Q2: npn 14,7
  RC2: resistor 14,2 14,5 470
  RE: resistor 12,11 12,13 1k
  G3: ground 12,13
  W1: triangle 1,7 1,10 l=$\mathrm{W1}$
  M1: voltmeter 3,7 3,10 l=$\mathrm{CH1}$
  G1: ground 1,10
  RB: resistor 3,7 5,7 10k
  OUT: port 16,5
  M2: voltmeter 17,5 17,7 l=$\mathrm{CH2}$
  G4: ground 17,7
wires:
  - 7,2 -- 14,2
  - 7,5 -- Q1.C
  - 10,5 -- 10,7
  - 10,7 -- Q2.B
  - 14,5 -- Q2.C
  - Q1.E -- 7,11
  - Q2.E -- 14,11
  - 7,11 -- 12,11
  - 12,11 -- 14,11
  - 1,7 -- 3,7
  - 1,10 -- 3,10
  - 5,7 -- Q1.B
  - 14,5 -- 16,5
  - 16,5 -- 17,5
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/circuit/13-schmitt-2tr.svg)

図1 の電源は AD3 の V+ (5 V)。W1 は `RB` (10 kΩ) を通して Q1 のベースへ入れる。`RB` は、入力が高く Q1 が飽和したときのベース電流を抑える。
CH1 で W1、CH2 で出力 (Q2 のコレクタ) を見る。

- **Q1 がオフのとき**: Q2 のベースは、`RC1` + `R1` (12.2 kΩ) と `R2` (22 kΩ) の分圧でテブナン等価が 5 × 22 / 34.2 ≈ 3.22 V・7.9 kΩ。
  Q2 のベース電流の分を引いて V<sub>B2</sub> ≈ **3.14 V**、エミッタは約 2.49 V、I<sub>E</sub> ≈ **2.5 mA**。
  出力は 5 − 0.47 kΩ × 2.5 mA ≈ **3.83 V** (Low)
- **上のしきい値 V<sub>T+</sub>**: Q1 のベースが Q2 のベースに追いつく所、約 **3.1 V** (`RB` の電圧降下はベース電流が µA なので小さい)
- **Q2 がオフのとき**: 出力は `RC2` で 5 V に上がる (High)。Q1 のコレクタは `RC1` と `R1` + `R2` (32 kΩ) のテブナン等価 4.68 V・2.06 kΩ で決まる
- **下のしきい値 V<sub>T−</sub>**: 入力が V<sub>in</sub> のとき、エミッタは V<sub>in</sub> − 0.65 V、Q1 の電流は (V<sub>in</sub> − 0.65) / 1 kΩ。
  Q2 のベース 0.6875 × (4.68 − 2.06 × (V<sub>in</sub> − 0.65)) が V<sub>in</sub> に等しくなる所を解くと V<sub>in</sub> ≈ **1.7 V**
- ヒステリシスは約 1.2〜1.4 V。入力の雑音がこれより小さければ、出力は 1 回しか切り替わらない

出力の Low が 3.8 V と高いのは、Q2 のエミッタが `RE` で持ち上がっているから。この形は「出力が 0 V まで下がらない」のが欠点で、
ロジックにつなぐなら、もう 1 石のスイッチ (2-1) で受けるか、74HC14 を使う。

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 シュミットトリガ (エミッタは h 行の橙の線で共通)
board: half
parts:
  RB: resistor d5 d10 10k
  RC1: resistor a9 +t9 2.2k
  R1: resistor b9 b14 10k
  R2: resistor a14 -t14 22k
  Q1: transistor g8 g9 g10 2SC1815
  Q2: transistor g12 g13 g14 2SC1815
  RE: resistor j8 -b8 1k
  RC2: resistor j13 +b13 470
  AD:
    type: device
    at: top
    label: Analog Discovery 3 (電源・W1・CH1)
    pins: [V+, GND, 1+, W1, 1-]
  AD1:
    type: device
    at: bottom
    label: Analog Discovery 3 (CH2)
    pins: [2+, 2-]
wires:
  - AD.V+ -- +t1 red
  - AD.GND -- -t2 black
  - AD.1+ -- a4 blue
  - e4 -- e5 blue
  - AD.W1 -- a5 yellow
  - AD.1- -- -t7 black
  - e10 -- f10 white
  - e9 -- f9 green
  - e14 -- f14 white
  - h8 -- h12 orange [v-10]
  - AD1.2+ -- i13 blue
  - AD1.2- -- -b17 black
  - +t30 -- +b30 red
  - -t29 -- -b29 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/breadboard/13-schmitt-2tr.svg)

図2 は、上のブロックに抵抗、下のブロックに 2 つのトランジスタを置いた。5 V は AD3 の V+ (赤) から上の + レールへ。
**下のレールは列 29・30 の線で上のレールとつなぐ**。

- **入力**: W1 (黄) は `a5`、CH1 の 1+ (青) は `a4` から `e4`–`e5` で同じ列へ。`RB` (`d5`–`d10`) の右端を白い線で下の列 10 (Q1 の B) へ渡す
- **Q1・Q2**: どちらも平らな面を手前に E・C・B。Q1 は列 8〜10、Q2 は列 12〜14
- **Q1 のコレクタ (列 9)**: 上のブロックの列 9 に、+ レールからの `RC1` と、右へ寝かせた `R1` (`b9`–`b14`)。緑の線で上下をつなぐ
- **Q2 のベース (列 14)**: `R1` の右端と − レールへの `R2`。白い線で下の列 14 へ
- **共通のエミッタ**: Q1 の E (列 8) と Q2 の E (列 12) を橙の線 `h8`–`h12` でつなぎ、`RE` を列 8 から下の − レールへ
- **出力 (列 13)**: `RC2` を下の + レールへ、CH2 の 2+ を `i13` に挿す

## 計器の設定

計器は AD3 のオシロ (切り替わる時の入力の電圧を、波形とカーソルで読むため)。W1 を Triangle、100 Hz、Amplitude 2.5 V、Offset 2.5 V (0〜5 V) にする。
CH1・CH2 とも 1 V/div・Offset −3 V、時間軸 1 ms/div、CH1 の立ち上がり 2.5 V でトリガし、トリガ点を画面の左端に寄せる。
カーソル X1・X2 を CH2 の段の直後に置き、CH1 の値を読む。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 入力 (CH1) が 3.0 V を越えると上がり、1.8 V を下回ると下がる
time: 1ms/div
trigger: ch1 rising 2.5V at -5div
ch1: {wave: triangle 100Hz 2.5V offset 2.5V, range: 1V/div, position: -3div}
ch2: {wave: "= 3.83V + 1.17V * step(t - 2.99ms) * step(8.19ms - t)", range: 1V/div, position: -3div}
cursors: [0.5ms, 5.7ms]
measure: [vmax, vmin]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/02-transistors/scope/13-schmitt-2tr.svg)

図3 の X1 は CH2 が上がった直後で、CH1 は 3.00 V。X2 は CH2 が下がった直後で、CH1 は 1.80 V。上りと下りで 1.2 V 違う所で切り替わる。
CH2 は 3.83 V と 5.00 V の 2 値で、その間の値を取らない。WaveForms の XY 表示 (横 CH1・縦 CH2) にすると、ヒステリシスが四角い輪になって見える。
雑音への強さを確かめるには、W1 を Custom にして三角波に 0.5 Vpp の正弦波 (数 kHz) を足す。CH2 は 1 周期に 1 回ずつしか切り替わらない。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RB | 抵抗 (1/4 W) | 10 kΩ |
| RC1 | 抵抗 (1/4 W) | 2.2 kΩ |
| R1 | 抵抗 (1/4 W) | 10 kΩ |
| R2 | 抵抗 (1/4 W) | 22 kΩ |
| RC2 | 抵抗 (1/4 W) | 470 Ω (2.5 mA で 2.9 mW) |
| RE | 抵抗 (1/4 W) | 1 kΩ (2.5 mA で 6.3 mW) |
| Q1, Q2 | NPN トランジスタ | 2SC1815 |
| — | 電源 | AD3 の V+ (5 V、約 2 mA) |

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 入力 0 V のときのエミッタ (列 8) | 約 2.5 V | Q2 の電流が `RE` を持ち上げる |
| 出力の Low / High (CH2) | 約 3.8 V / 5.0 V | Low は 0 V まで下がらない |
| 上りで切り替わる入力 (X1 の CH1) | 約 3.0 V | V<sub>T+</sub> ≈ Q2 のベースの電圧 |
| 下りで切り替わる入力 (X2 の CH1) | 約 1.8 V | V<sub>T−</sub> は Q1 のコレクタで決まる |
| ヒステリシス | 約 1.2 V | この幅より小さい雑音では出力が揺れない |

## LTspice での確かめ

`sim/13-schmitt-2tr.cir` で、0〜5 V・100 Hz の三角波を入れて過渡解析し、出力が高と低の中点を横切る瞬間の入力の電圧を読んだ。
Q1・Q2 は 2-3 と同じ 2SC1815 の代用モデル (仮定で、実測ではない)。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 上のしきい値 V<sub>T+</sub> | 約 3.1 V (見積り) | 2.99 V | 近い (Q1 が流し始めた所で正帰還が始まる) |
| 下のしきい値 V<sub>T−</sub> | 約 1.7 V (見積り) | 1.81 V | 近い |
| 出力の Low / High | 約 3.83 V / 5.0 V | 3.83 V / 5.00 V | 合う |
| 入力が低いときのエミッタ | 約 2.49 V | 2.47 V | 合う |
| 入力 5 V で `RB` を流れる電流 | 小さい | 0.26 mA | 合う (W1 の 10 mA の内) |

図3 のカーソルとしきい値の見出しは LTspice の値 (3.0 V・1.8 V) に合わせた。

## 出典

自作。シュミットトリガは O. H. Schmitt が 1938 年に発表した回路で、エミッタ結合の 2 石の形はその古典の形。

参考: [シュミットトリガ (Wikipedia)](https://ja.wikipedia.org/wiki/シュミットトリガ)、[Schmitt trigger (Wikipedia)](https://en.wikipedia.org/wiki/Schmitt_trigger)
