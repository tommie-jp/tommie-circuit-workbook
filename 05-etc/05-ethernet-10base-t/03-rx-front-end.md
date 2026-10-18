---
book: etc
chapter: 5
id: 5-3
title: 受信回路 — 100 Ω 終端と 74HC14 で差動を 3.3 V の論理に戻し、ロジアナで読む
tier: 200
source: 自作
board: PF
---

# 5-3 受信回路 — 100 Ω 終端と 74HC14 で差動を 3.3 V の論理に戻し、ロジアナで読む

> [!WARNING]
> **この工作 (5 章 ethernet-10base-t) は、まだ実機で測っていない。** 74HC14 の閾値とバイアスの余裕は
> データシートの代表値からの計算で、ルータの信号を取りこぼさずに読めるかは組んで確かめてほしい。

ブレッドボードでなくユニバーサル基板に組むのは 5-2 と同じ理由 (線の上の信号が 10 MHz)。
5-2 の送信回路と同じ基板に受信回路を足し、Pico 2 には 5-2 のプログラムをそのまま載せる。

## ねらい

ルータから来る 10BASE-T の信号 (差動 ±2.5 V、浮いている) を、Pico 2 が読める **0〜3.3 V の論理**に
戻す。やることは 3 つ。

1. **終端**: 対の両端に 100 Ω (オーム) を付け、線路のインピーダンスに合わせる (反射を無くす)。51 Ω × 2 = 102 Ω で代える
2. **バイアス**: 対は相手のトランスで浮いているので、終端の**中点**を 1.65 V に固定する
   (51 Ω を 2 本直列にして中点を出す)。すると RX+ は 1.65 V を中心に +1.25 V、RX− は −1.25 V 振れる
3. **しきい値で切る**: RX+ を 74HC14 (シュミットトリガの NOT) に入れる。ヒステリシスがあるので、
   雑音と小さな振れを無視して、差動が正なら H、負なら L を出す。2 段通して向きを戻す

74HC14 の出力 RXD は 3.3 V の論理なので、Analog Discovery 3 のロジアナにそのまま入り (`logic` の図)、
Pico 2 の GP18 にもつなぐ (読むのは 5-4)。5-2 の送信を同じ Pico 2 で動かしておくと、ルータが
リンクし、リンクパルス (NLP) とブロードキャストのフレームが流れてくる。送信を止めていても、
ルータは FLP バースト (5-1) を出し続けるので、それだけでも受信回路は確かめられる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 受信回路の終端とバイアスと 74HC14 (送信の R1・R2 は 5-2 と同じ)
parts:
  MCU: pico2 2,7
  R2: resistor 5,9.25 7,9.25 47
  R1: resistor 5,10.5 7,10.5 47
  J1:
    type: device
    at: 13,10
    label: RJ45
    pins: [P3, P6, P1, P2]
  R3a: resistor 11,3.5 11,4.5 51
  R3b: resistor 11,4.5 11,5.5 51
  R6: resistor 10,3.5 8.5,3.5 470
  U1A: not 7,3.5 mirror 74HC14
  U1B: not 5,3.5 mirror 74HC14
  R5: resistor 10.5,4.5 10.5,6.5 1k
  C2: capacitor 9,4.5 9,6.5 100n
  R4: resistor 7.5,4.5 7.5,6.5 1k
  G1: ground 10.5,6.5
  G2: ground 9,6.5
  V1: vcc 6.5,6.5 3.3V
  LA:
    type: device
    at: 2.5,1
    label: AD3 Logic
    pins: [DIO0, GND]
    turn: mirror
  G3: ground 3.6,2.25
wires:
  - MCU.GP17 -- 4,9.25 -- 5,9.25
  - MCU.GP16 -| 4.5,10.5 -- 5,10.5
  - 7,9.25 -- 11,9.25 |- J1.P1
  - 7,10.5 -- 10.5,10.5 |- J1.P2
  - J1.P3 |- 11,3.5 -- 10,3.5
  - J1.P6 -| 12.25,5.5 -- 11,5.5
  - 11,4.5 -- 10.5,4.5 -- 9,4.5 -- 7.5,4.5
  - 7.5,6.5 -- 6.5,6.5
  - 8.5,3.5 -- U1A.in
  - U1A.out -- U1B.in
  - U1B.out -- 4.5,3.5 -- 4.5,8.75 -- MCU.GP18
  - LA.DIO0 -| 4.5,3.5
  - LA.GND -| 3.6,2.25
notes:
  - text 11.5,2.75 small: RX+ (ピン 3)
  - text 12.5,6 small: RX- (ピン 6)
  - text 12.5,4.5 small left: 中点 1.65 V
  - text 1,12 small left: U1 の 14 番 (VCC) は 3.3 V、7 番 (GND) は GND。間に C3 100 nF
  - text 1,12.5 small left: 使わない入力 (3A から 6A) は GND へ
  - text 8,12 small left: R1・R2 と J1 のピン 1・2 は 5-2 の送信回路
  - text 8,12.5 small left: AD3 Scope は 1+ を RX+、1- を RX-、2+ を RXD、2- を GND に
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/circuit/03-rx-front-end.svg)

| 部品 | 値 | 備考 |
| --- | --- | --- |
| R3a・R3b | 51 Ω × 2 | 終端 (直列で 102 Ω)。線路の特性インピーダンス (100 Ω) に合わせ、中点をバイアスに使う |
| R4・R5 | 1 kΩ | 3.3 V を 2 分して 1.65 V を終端の中点に与える。1.65 mA 流れる |
| C2 | 100 nF | 中点を交流的に GND へ。対の信号は中点に対して対称なので、ここにはほとんど電流が流れない |
| R6 | 470 Ω | 74HC14 の入力の保護。ケーブルを抜き挿ししたときの跳ねを抑える。入力容量 (5 pF) との時定数は 2.4 ns |
| U1 | 74HC14 (3.3 V) | 6 回路のシュミットトリガ NOT。1A→1Y→2A→2Y の 2 段。C3 100 nF を 14・7 番の間に。使わない入力は GND |
| R1・R2・J1 | 5-2 と同じ | 送信。J1 のピン 3・6 を受信に使う |
| 電源 | Pico 2 の 3.3 V | 74HC14 とバイアスの 1.65 mA だけ |

- **バイアスの余裕**: 74HC14 の 3.3 V でのしきい値は、データシートの 2.0 V と 4.5 V の値から
  内挿して V<sub>T+</sub> ≈ 1.9 V、V<sub>T−</sub> ≈ 1.2 V (代表値。品種で違う)。RX+ は 1.65 ± 1.25 V =
  0.4〜2.9 V で振れるので、上に 1.0 V、下に 0.8 V の余裕がある。ケーブルが長くて振幅が 2 V まで落ちても
  (±1.0 V → 0.65〜2.65 V) 切れる
- **スケルチ**: 実物の受信機は 300〜585 mV 以下の信号を無視する。74HC14 のヒステリシス (0.7 V ほど) が
  同じ役をする。リンクパルス (正の 100 ns) は 1 発で H になる
- **74HC14 の速さ**: 伝搬遅延は 3.3 V で 20 ns 程度 (4.5 V で代表 13 ns)。シンボル 50 ns に対して 2 段で 40 ns
  遅れるが、遅れは一定なので波形の形は保たれる。速い品種 (74AHC14・74LVC14) に替えれば数 ns になる
- **なぜ 2 段か**: 1 段では RX+ が正のとき L になり、ロジアナの波形が送信側と逆になる。2 段で元の向き
  (HIGH = H) に戻し、本文の図と 5-2 の図を同じ向きで見比べる
- 終端の中点を 1.65 V に固定しているので、**受信の対にはこの基板の電位 (1.65 V) が乗る**。相手 (ルータ) は
  トランスで浮いているので支障ない。中点でなく RX− を固定すると、RX+ が 1.65 ± 2.5 V で振れて 74HC14 の
  電源の外に出る (入力の保護ダイオードに流れる)。パルストランスで切る方法は 5-6

## 実体配線図

```perf
# ユニバーサル基板の実体配線図 (tommie-fence の perf フェンス)
title: 図2 送受信のユニバーサル基板 (5-2 の送信に受信回路を足す。7×5 cm 横置き、部品面)
board:
  size: 7x5cm
  silk: board
  h: 1.6mm
  material: FR-4
  slots: on
style:
  check: off
parts:
  MCU: pico2 c9
  J1:
    type: device
    at: h21
    label: RJ45 (DIP 化)
    pins: P6 P3 P1 P2
  R2: resistor u13 u10 47
  R1: resistor v13 v10 47
  R3b: resistor h17 e17 51
  R3a: resistor i14 f14 51
  R6: resistor j14 j11 470
  U1: dip14 l15 74HC14
  R4: resistor g16 g13 1k
  R5: resistor e14 e11 1k
  C2: capacitor/ceramic d16 d13 100n
  C3: capacitor/ceramic k16 m16 100n
wires:
  # 送信 (5-2 と同じ)
  - J1.P1 -- j17 white
  - j17 -- u17 white
  - u17 -- u13 white
  - u10 -- u9 white
  - J1.P2 -- k18 green
  - k18 -- v18 green
  - v18 -- v13 green
  - v10 -- v9 green
  # 受信の対: RX+ (ピン 3) → R3a、RX- (ピン 6) → R3b。中点 (E 列) がバイアス
  - J1.P6 -- h17 blue
  - J1.P3 -- i14 yellow
  - f14 -- e14 blue
  - e14 -- e16 blue
  - e16 -- e17 blue
  # 中点 1.65 V: R4 (3.3 V から)・R5 (GND へ)・C2
  - g16 -- e16 blue
  - e16 -- d16 blue
  - g13 -- g10 red
  - e11 -- e9 black
  - d13 -- d11 black
  - d11 -- e11 black
  # RX+ → R6 → U1 の 1A (12 行)
  - i14 -- j14 yellow
  - j11 -- l11 yellow
  - l11 -- l12 yellow
  # 3.3 V: 36 番から 10 行を K 列へ、K 列を上げて U1 の 14 番と C3 へ (K 列 11 行で RX+ の線を跨ぐ: 被覆線)
  - g9 -- g10 red
  - g10 -- k10 red
  - k10 -- k15 red
  - k15 -- l15 red
  - k15 -- k16 red
  # U1 の 7 番 (GND) と使わない入力 (3A・4A・5A・6A) を 23 番の GND へ。C3 の GND
  - r12 -- r11 black
  - r11 -- t11 black
  - t11 -- t10 black
  - t10 -- t9 black
  - p12 -- p11 black
  - p11 -- r11 black
  - m15 -- m16 black
  - o15 -- o16 black
  - q15 -- q16 black
  - m16 -- o16 black
  - o16 -- q16 black
  - q16 -- t16 black
  - t16 -- t11 black
  # 1Y → 2A、2Y (RXD) → GP18
  - m12 -- n12 white
  - o12 -- o10 orange
  - o10 -- s10 orange
  - s10 -- s9 orange
notes:
  - mark j14 yellow
  - mark h17 blue
  - mark o10 orange
  - mark t10 black
  - text l-1 yellow: 黄の丸 (J14) はオシロの 1+ (RX+)
  - text l-2 blue: 青の丸 (H17) はオシロの 1- (RX-)
  - text l-3 orange: 橙の丸 (O10) はロジアナの DIO0 (RXD)、黒の丸 (T10) は GND
unused: [U1.3Y, U1.4Y, U1.5Y, U1.6Y]
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/perfboard/03-rx-front-end.svg)

- 基板・Pico 2・RJ45・R1・R2 の置き場は 5-2 の図2 と同じ。受信回路は Pico 2 の上の 10〜18 行に足す。
  RJ45 のピンの並びはピン 6 を H 列、ピン 3 を I 列にした (5-2 の図2 とは 3・6 が逆)
- **受信の対**: RJ45 のピン 6 (RX−) を H 列から `h17` へ、ピン 3 (RX+) を I 列から `i14` へ下ろす。
  R3a (51 Ω) は 14 行の I→F 列、R3b (51 Ω) は 17 行の H→E 列で、E 列の 14〜17 行が**中点** (青)
- **バイアス**: 中点から R4 (G 列 13〜16 行) で 3.3 V へ (`g13` から `g10` へ)、R5 (E 列 11〜14 行) で GND へ
  (`e11` から 38 番 `e9` へ)、C2 (D 列 13〜16 行) で GND へ (`d13` から `d11` 経由で `e11` へ)
- **RX+ → 74HC14**: `i14` から `j14` へ渡し、R6 (J 列 11〜14 行) を通って 11 行を L 列へ、`l12` (1 番 1A) へ
- **3.3 V**: 36 番 (`g9`) から `g10`、10 行を K 列へ、K 列を `k15` まで上げて U1 の 14 番 (`l15`) と C3 (`k16`) へ。
  **K 列の線は 11 行で RX+ の線 (`j11`〜`l11`) を跨ぐ**ので被覆線にする (図では半円の跨ぎ)
- **U1 (74HC14)**: L〜R 列、12 行 (1〜7 番) と 15 行 (8〜14 番)。2 番 (1Y) → 3 番 (2A) を `m12`〜`n12` の短い線でつなぎ、
  4 番 (2Y、`o12`) が RXD。7 番 (GND、`r12`) は 11 行を通って T 列から 23 番 (`t9`) へ。使わない入力は 5 番 (3A) を
  11 行の GND へ、9・11・13 番 (4A・5A・6A) を 16 行の GND へ落とし、16 行の GND は T 列で 11 行の GND と合わせる。
  C3 (100 nF) は `k16`〜`m16` で VCC と GND の間
- **RXD**: `o12` から 10 行を S 列へ、`s9` (GP18、24 番) へ。橙の丸がロジアナの DIO0、黒の丸 (`t10`) が GND。
  黄の丸 (`j14`) がオシロの 1+ (RX+)、青の丸 (`h17`) が 1− (RX−)
- 線の色: 赤は 3.3 V、黒は GND だけ。黄は RX+、青は RX− と中点、橙は RXD、白と緑は 5-2 の送信
- Pico 2 の使わないピンは `style: check: off` で ERC を外し、U1 の使わない出力 (3Y〜6Y) は `unused:` に書いた。
  つなぐ所は check のネットリストで確かめた (回路図と parity で一致)

## 計器の設定

計器は Analog Discovery 3。対の差動は Scope (BNC アダプタ基板、差動入力)、74HC14 の出力は Logic (3.3 V、125 MS/s)。
Scope の ch2 で 74HC14 の出力も見て、差動波形との遅れを読む。

| 項目 | 設定 |
| --- | --- |
| Scope ch1 | 1+ を `j14` (RX+)、1− を `h17` (RX−)。GND はつながない。1 V/div |
| Scope ch2 | 2+ を `o10` (RXD)、2− を `t10` (GND)。1 V/div、0 V を下から 1 目盛 |
| Scope のトリガ | Normal、ch1 立ち上がり 0 V (差動がゼロを横切る所) |
| Scope の時間軸 | 50 ns/div (図4、2.5 周期)。リンクパルスは 5-1 の図4 と同じ 100 ns/div |
| Logic | DIO0 = RXD (`o10`)、GND = `t10`。125 MS/s。トリガ DIO0 立ち上がり |

### ロジアナで見る RXD

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図3 RXD — リンクパルスは 100 ns の H、プリアンブルは 5 MHz
device: ad3
time: 100ns/div
sample: 125MHz
signals:
  RXD: dio0 edges 0s=0 100ns=1 200ns=0 500ns=0 550ns=1 650ns=0 750ns=1 850ns=0 950ns=1
cursors: [150ns, 250ns]
trigger: RXD rising at 100ns
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/logic/03-rx-front-end.svg)

図3 の左はリンクパルス (100〜200 ns の H)、右はプリアンブルの始まり (550 ns から 100 ns 周期)。実物では
両者は 16 ms 離れているので 1 画面には入らない。説明のために並べた (トリガを掛け直して 2 回撮る)。
X1・X2 はパルスの中と後で、ΔX = 100 ns が幅。

### オシロで見る差動と 74HC14 の出力

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図4 プリアンブル — ch1 の差動 ±2.5 V を ch2 の 0/3.3 V に戻す。遅れ 40 ns
time: 50ns/div
trigger: ch1 rising 0V
ch1: {wave: square 5MHz 2.5V, range: 1V/div, position: 0div}
ch2: {wave: square 5MHz 1.65V offset 1.65V phase -72deg, range: 1V/div, position: -3div}
cursors: [0, 40ns]
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/05-ethernet-10base-t/scope/03-rx-front-end.svg)

ch2 の立ち上がりは ch1 のゼロ交差から 74HC14 2 段ぶん (40 ns = 200 ns の周期の 72°) 遅れる。
X1 (0 ns) が ch1 のゼロ交差、X2 (40 ns) が ch2 の立ち上がり。ch1 と ch2 は同じ 1 V/div で、ch2 は 0 V を下から 1 目盛に置いた。

## 見るべき値

| 何を | 値 | 根拠 |
| --- | --- | --- |
| 中点の電圧 (テスター。青の丸) | 1.65 V | R4・R5 の分圧 |
| RX+ の振れ (74HC14 の入力) | 1.65 ± 1.25 V = 0.4〜2.9 V。対の差動は Vpp 5 V (図4 の ch1) | 5-1 の振幅 2.5 V<sub>p</sub> を中点で 2 分 |
| RXD の H と L (図4 の ch2) | 3.3 V / 0 V、Vpp 3.3 V | 74HC14 の出力 |
| 遅れ (図4 の ΔX、Phase) | 40 ns (−72°) | 74HC14 2 段 × 20 ns (3.3 V の代表値) |
| リンクパルスの RXD (図3) | 幅 100 ns の H、16 ms ごと | 5-1 |
| リンク無しのとき | FLP バースト: 100 ns の H が 125 µs/62.5 µs 間隔で 17〜33 発、16 ms ごと | 5-1 の図3 |
| プリアンブルの周波数 | 5 MHz | 5-1 |

RXD が全く動かないときは、対が逆 (ルータの Auto-MDIX) の可能性がある。5-1 と同じく、RJ45 のピン 1・2 側に
信号が来ていないかオシロで見る。逆なら、ケーブルをクロスにするか、J1 のピン 1・2 と 3・6 を入れ替えて組み直す。

## LTspice での確かめ

`sim/03-rx-front-end.cir` で、図1 の終端 (51 Ω × 2) とバイアスを解いた。相手の信号は浮いた差動電圧源 (±2.5 V の 5 MHz の
方形波。規格は 100 Ω の負荷での値なので内部抵抗 0) とし、74HC14 は入力容量 5 pF だけを置いた (しきい値の判定は本文の数で行う)。
LTspice で解いた。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 中点の直流 | 1.65 V | 1.650 V | 合う |
| RX+ の最大・最小 | 2.9 V / 0.4 V | 2.900 V / 0.400 V | 合う (V<sub>T+</sub> 1.9 V を 1.0 V 超え、V<sub>T−</sub> 1.2 V を 0.8 V 下回る) |
| R6 と 5 pF の時定数 | 2.4 ns | 10〜90 % の立ち上がり 5.6 ns (2.2 τ = 5.3 ns に、信号源の 2 ns の立ち上がりが加わる) | 合う |

## 出典

- 自作。74HC14 の数値 (しきい値・伝搬遅延) は Nexperia / TI の 74HC14 データシートの 2.0 V・4.5 V の代表値から
  3.3 V を内挿した (データシートに 3.3 V の値は無い。**実物で確かめる**)
- IEEE 802.3-2022 Clause 14 — 14.3.1.3.1 (受信の振幅とスケルチ)、14.4 (MDI のピン配置)
- 5-1・5-2 の本文
