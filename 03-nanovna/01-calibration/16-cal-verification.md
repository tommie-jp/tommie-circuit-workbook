---
book: nanovna
chapter: 1
id: 1-16
title: 校正の検証 — 別の Load とアッテネータで
tier: 200
source: 自作
board: PF
device: H4
---

# 1-16 校正の検証 — 別の Load とアッテネータで

校正の直後に、校正に使った Load をつなぎ直して「−60 dB、よし」と見ても、何も確かめていない。
校正はその Load を「反射 0」と決めたので、同じ物は必ず 0 近くに読める (1-7)。
**校正が正しいかは、校正に使っていない、値の分かった物を測って確かめる**。これを校正の検証という。
この題では、DC の抵抗から反射を前もって計算できる 2 つの検証用の標準を perfboard に作る。

## 検証用の標準の決め

| 決め | 理由 |
| --- | --- |
| 校正に使った標準器と**別の物** | 同じ物では校正の自己満足になる |
| **値を VNA 以外の方法で知っている** | テスターの DC の抵抗 (1-8) から反射を計算する。計算と読みが合えば、校正と計器の両方が正しい |
| 反射の大きさが**違う 2 つ** | 小さい反射 (−40 dB) は方向性の誤差、中くらいの反射 (−20 dB) は反射の伝達の誤差を見る |
| 低い周波数で比べる | 抵抗器のピンの寄生分が小さい所 (この題では 10 MHz 前後) で比べる。周波数を上げた先は、寄生分と校正の誤差が混ざる |

## 2 つの標準

- **標準 A (51 Ω の Load)**: 51 Ω (E24) 1 本。反射は (51 − 50) ÷ (51 + 50) = 0.0099 で **−40.1 dB**。
  校正の Load (付属か 3-4 の自作) とは別の物。50 Ω から 1 Ω だけずらしてあるので、読みが −40 dB の近くに
  出れば「−40 dB の反射が読める」ことの確かめになる
- **標準 B (アッテネータ + Short)**: 27・36・27 Ω の T 型の 10 dB アッテネータ (3-5 と同じ値) の先を
  基板の上で短絡した物。入口から見ると 27 + (36 ∥ 27) = 42.43 Ω の抵抗で、反射は **−21.73 dB**、位相 180°
- **S21 の検証**は 3-5 の 10 dB アッテネータ (−10.07 dB) を CH0–CH1 の間に入れて見る (新しく作らない)

DC の抵抗は、組んだ後にテスターで J1・J2 の中心と外の間を測る。読んだ値 R から、反射の予想
|Γ| = |R − 50| ÷ (R + 50) を計算し直す (抵抗の誤差 ±5 % があるので、表の値は E24 の値どおりのとき)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 検証用の標準 A (51 Ω) と B (10 dB アッテネータの先を短絡)
parts:
  J1: sma 2,2 mirror
  R1: resistor 4,2 4,4 51
  G1: ground 2,3
  G2: ground 4,4
  J2: sma 2,6 mirror
  R2: resistor 4,6 6,6 27
  R3: resistor 6,6 6,8 36
  R4: resistor 6,6 8,6 27
  G3: ground 2,7
  G4: ground 6,8
  G5: ground 9,7
wires:
  - J1.1 -- 4,2
  - J1.2 -- 2,3
  - J2.1 -- 4,6
  - J2.2 -- 2,7
  - 8,6 -- 9,6 -- 9,7
notes:
  - text 4.6,3 blue left: 標準 A (-40.1 dB)
  - text 9.2,6.5 blue left: 短絡
  - text 7,9 blue center: 標準 B (42.43 Ω、-21.73 dB)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/circuit/16-cal-verification.svg)

J1・J2 は CH0 のケーブルの先につなぐ (どちらも 1 ポートの標準)。

## 実体配線図

5×7 cm のユニバーサル基板 (横置き、1.6 mm の FR-4) の左の縁に、端面 SMA を 2 つ並べる。
基板の上の 2 つの組 (行 6 と行 13) の真ん中が基板の高さの中央になる。GND の筋は 9 行目。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 検証用の標準の基板 (部品面)
points:
  GND: b9
parts:
  J2: sma/female-edge a6 07 05
  R2: resistor c6 f6 27
  R3: resistor h6 h9 36
  R4: resistor j6 m6 27
  J1: sma/female-edge a13 014 012
  R1: resistor c13 c10 51
wires:
  - a6 -- c6
  - f6 -- h6
  - h6 -- j6
  - m6 -- m9 black
  - a13 -- c13
  - c10 -- c9 black
  - 07 -- b7 black
  - b7 -- b9 black
  - 012 -- b12 black
  - b12 -- b9 black
  - b9 -- c9 black
  - c9 -- h9 black
  - h9 -- m9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/perfboard/16-cal-verification.svg)

- 上の組 (J2) が標準 B。R2・R4 (27 Ω) は 6 行目の本線、R3 (36 Ω) は GND の筋へ落ちる枝。
  R4 の先 (m6) から GND の筋 (m9) へ下ろす黒い線が「先の短絡」。**この線をできるだけ短く**
  (長いとインダクタンスが乗り、Short が周波数とともに回る、3-4)
- 下の組 (J1) が標準 A。R1 (51 Ω) の下のピンから GND の筋へ 1 行
- SMA の外 (シェル) は 1 本ずつ GND の筋へ。使わない側のシェル (05・014) は半田付けで固定するだけ

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz (perfboard の治具の目安の上限) |
| 点数 | 101 |
| 校正 | CH0・CH1 のケーブルの先で SOLT (付属のキット)。この基板は校正に使わない |
| 測る物 | J1 (標準 A)、J2 (標準 B) を CH0 に。3-5 のアッテネータを CH0–CH1 に |
| 表示 | S11 の Log Mag と Smith |

標準 B の**見えるはずの画面** (理想の模型。抵抗の寄生分は入れていない)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図3 標準 B (アッテネータ + Short) — 平らな −21.73 dB、42.43 Ω
dut:
  - series R 27
  - shunt R 36
  - series R 27
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/16-cal-verification-1.svg)

標準 A。R1 のピンと基板の線のインダクタンスを 2 nH と**仮定**した (3-9 の自作 Load と同じ見積もり)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図4 標準 A (51 Ω + 2 nH の仮定) — 10 MHz で −40.0 dB
dut:
  - series L 2n
  - series R 51
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 10M
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/16-cal-verification-2.svg)

- 標準 A は 10 MHz では −40.0 dB (51 Ω の抵抗のぶん)。周波数を上げると 2 nH のぶん反射が増え、
  300 MHz で −28.3 dB。**比べるのは 10 MHz の値**。上の周波数は校正ではなく標準 A の寄生分を見ている

## 合格の目安

| 標準 | 予想 (10 MHz) | 合格 (この教科書の目安) | 外れたら疑う物 |
| --- | --- | --- | --- |
| A (51 Ω) | −40.0 dB | −37 dB より小さい | 校正の Load の質 (1-7)・Load の付け外し (0-8) |
| B (42.43 Ω) | −21.73 dB、180° | 予想の ±0.3 dB、±2° | Open・Short の定義 (1-12)・範囲の変更 (1-4) |
| 3-5 のアッテネータの S21 | −10.07 dB | 予想の ±0.1 dB | Thru の校正 (1-3)・Enhanced response (1-15) |

±0.3 dB は、0-8 の表で読みに −50 dB の小さな誤差が乗ったときの、−20 dB の読みの揺れ
(+0.27 / −0.28 dB) から決めた。A の −37 dB は、−40 dB の読みに同じ誤差が乗ったとき
(+2.4 dB) の上の端。

## 見るべき値

計算値 (理想の模型)。

| 測る物 | 10 MHz | 100 MHz | 300 MHz |
| --- | --- | --- | --- |
| 標準 A の S11 (図4) | −40.02 dB (51.0 + j0.13 Ω) | −35.97 dB (51.0 + j1.26 Ω) | −28.27 dB (51.0 + j3.77 Ω) |
| 標準 B の S11 (図3) | −21.73 dB (42.43 Ω) | −21.73 dB | −21.73 dB |
| 3-5 のアッテネータの S21 | −10.07 dB | −10.07 dB | −10.07 dB |

## LTspice での確かめ

`sim/16-cal-verification.cir` で、図3・図4 と 3-5 のアッテネータの模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端、最後を短絡。コイルの直列抵抗は 1 µΩ)。理想の模型どうしの比べで、実測ではない。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 標準 A の S11 (10 / 100 / 300 MHz) | −40.02 / −35.97 / −28.27 dB | −40.02 / −35.97 / −28.27 dB (51.00 + j0.13 / j1.26 / j3.77 Ω) | 合う |
| 標準 B の S11 (同) | −21.73 dB、180°、42.43 Ω | −21.73 dB、180.00°、42.43 Ω | 合う |
| 3-5 のアッテネータの S21 (同) | −10.07 dB | −10.067 dB | 合う |

DC の値の式 (51 − 50) ÷ (51 + 50) → −40.09 dB と、27 + 36 × 27 ÷ (36 + 27) = 42.43 Ω → −21.73 dB は算術でも合う。

## 出典

自作。

参考: [Network analyzer (electrical) (Wikipedia)](https://en.wikipedia.org/wiki/Network_analyzer_(electrical))、[アッテネータ (Wikipedia)](https://ja.wikipedia.org/wiki/アッテネータ)
