---
book: nanovna
chapter: 4
id: 4-25
title: PIN ダイオード / RF スイッチ
tier: 200
source: 自作
board: PF
device: H4
---

# 4-25 PIN ダイオード / RF スイッチ

**PIN ダイオード**は、P 型と N 型の間に不純物の少ない I (真性) 層を挟んだダイオードである。
直流を流すと I 層に電荷がたまり、高い周波数では**直流の量で決まる小さな抵抗**に見える。逆向きに電圧を
かけると I 層が空になり、**小さなコンデンサ**に見える。整流はしないので、信号の通り道を直流で開け閉めする
**RF スイッチ**や、直流で減衰を変えるアッテネータに使う。送受信の切り替え・アンテナの切り替え・
VNA の中の S11 と S21 の切り替えも同じ仕組み (今は IC の RF スイッチが多い)。

この題では、整流用の **1N4007** を PIN ダイオードとして使う。1N4007 は高い電圧に耐えるため I 層に近い
厚い層を持ち、数 MHz より上では PIN ダイオードのように振る舞う (アマチュア無線の短波の送受信切り替えで
よく使われる手。品と周波数で効き方が違うので、この題で確かめる)。順に 10 mA 流した**オン**と、
逆に 5 V かけた**オフ**で、短波帯 (1〜30 MHz) の S21 を測り比べる。

この題で使う模型 (等価回路) は次のとおり (目安)。

| 状態 | D1 の模型 | 根拠 |
| --- | --- | --- |
| オン (順 10 mA) | 抵抗 1 Ω + ピンの 7 nH | 順方向の電流で決まる RF の抵抗。1 Ω は見積もりで、実物で読む値 |
| オフ (逆 5 V) | 容量 15 pF + ピンの 7 nH | 4-13 で測った 1N4007 の接合容量 (4 V で 15 pF。データシートの代表値) |

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 1N4007 を PIN ダイオードとして使う直列の RF スイッチ
parts:
  J1: sma 2,6 mirror CH0
  C1: capacitor 3,6 5,6 100n
  D1: diode 6,6 9,6 1N4007
  C2: capacitor 10,6 12,6 100n
  J2: sma 13,6 CH1
  L1: inductor 6,3 6,5 100u
  L2: inductor 9,7 9,9 100u
  R1: resistor 4,3 6,3 430
  S1: spdt 3,3 mirror
  VCC: vcc 2,1 5V
  VEE: vee 2,4 5V
  G1: ground 2,7
  G2: ground 13,7
  G4: ground 9,9
wires:
  - J1.1 -- 3,6
  - 5,6 -- 6,6
  - 9,6 -- 10,6
  - 12,6 -- J2.1
  - J1.2 -- 2,7
  - J2.2 -- 13,7
  - 6,5 -- 6,6
  - 9,6 -- 9,7
  - S1.in -- 4,3
  - S1.1 -| 2,1
  - S1.2 -| 2,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/25-pin-diode-switch.svg)

- **D1 はアノードが CH0 側 (左)**。S1 を +5 V に倒すと、R1 → L1 → D1 → L2 → GND と
  (5 − 0.75) / 430 ≈ 9.9 mA が流れてオン。−5 V に倒すと、D1 のアノードが −5 V・カソードが 0 V で、
  逆向きに 5 V かかってオフ (電流は流れない)
- L1・L2 (100 µH) は**チョーク**: 直流は通し、RF は通さない。1 MHz で X = 628 Ω、上は巻線の容量
  (3 pF とする) と 9.2 MHz で共振し、その上でも 30 MHz で 1.8 kΩ ある
- C1・C2 (100 nF) は直流を止める。**VNA のポートに ±5 V を入れない**ための物で、外さない
- 電源は AD3 の Supplies (V+ = +5 V・V− = −5 V)。AD3 の GND を基板の GND に繋ぐ

## 実体配線図

3-1 の直列治具に、D1 とチョーク 2 本、バイアスの R1 と S1 を足す。GND の筋は L2 を落とすため
5 行目を回す。

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 直列治具に PIN スイッチ (1N4007) とバイアスのチョーク
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  C1: capacitor/ceramic b10 d10 100n
  D1: diode/do41 f10 i10 1N4007
  C2: capacitor/ceramic k10 m10 100n
  L1: inductor/axial f14 f11 100u
  L2: inductor/axial i9 i6 100u
  R1: resistor b14 e14 430
  S1: slide-switch a16 b16 c16
  AD3:
    type: device
    at: "022"
    label: AD3
    pins: GND V+ V-
wires:
  - a10 -- b10
  - d10 -- f10
  - i10 -- k10
  - m10 -- x10
  - f10 -- f11
  - f14 -- e14
  - i10 -- i9
  - b16 -- b14
  - AD3.V+ -- a16 red
  - AD3.V- -- b18 blue
  - b18 -- d18 blue
  - d18 -- d16 blue
  - d16 -- c16 blue
  - AD3.GND -- 011 black
  - 09 -- 05 black
  - 05 -- i5 black
  - i5 -- i6 black
  - i5 -- y5 black
  - y5 -- y9 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/25-pin-diode-switch.svg)

- D1 は帯 (カソード) を右 (i10) に向ける。ピンは f10–i10 の幅に曲げて短く
- L1 と L2 はアキシアルのマイクロインダクタ (カラーコード付き)。RF の線 (10 行目) から縦に離して立てる
- S1 の真ん中のピン (b16) が R1 へ行く。a16 が V+、c16 が V−

## 部品

| 部品 | 値 | 理由・注意 |
| --- | --- | --- |
| D1 | 1N4007 | PIN ダイオードの代わり。逆耐圧 1000 V の整流用 |
| L1・L2 | 100 µH (アキシアル) | チョーク。自己共振は品で違う (3 pF・9.2 MHz は目安) |
| R1 | 430 Ω | オンの電流 (5 − 0.75) / 430 ≈ 9.9 mA |
| C1・C2 | 100 nF (積層セラミック) | 直流を止める |
| S1 | スライドスイッチ (1 回路 2 接点) | +5 V (オン) と −5 V (オフ) を切り替える |
| 電源 | ±5 V (AD3 の Supplies) | オフで逆電圧をかけるため両電源にする |

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。
AD3 は電源だけに使う。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz (短波帯) |
| 点数 | 291 (0.1 MHz おき) |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag。オンは 0.1 dB/目盛、オフは 10 dB/目盛 |

**オン** — 見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-30M 291
title: 図3 オン (順 10 mA) — 通過の損失は 0.1 dB (0.1 dB/目盛)
dut:
  - series C 100n
  - shunt L 100u esr 430 cp 3p
  - series R 1 esl 7n
  - shunt L 100u cp 3p
  - series C 100n
traces:
  - S21 logmag 0.1dB
markers:
  - 1M
  - 3.5M
  - 14M
  - 28M
expect:
  - match: に集まっています
    why: 低い端でチョークの X が下がって落ちるのを見せる図
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/25-pin-diode-switch-1.svg)

**オフ** — 同じ掃引。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-30M 291
title: 図4 オフ (逆 5 V、15 pF) — 3.5 MHz で −29.7 dB、28 MHz で −11.9 dB
dut:
  - series C 100n
  - shunt L 100u esr 430 cp 3p
  - series C 15p esl 7n
  - shunt L 100u cp 3p
  - series C 100n
traces:
  - S21 logmag
markers:
  - 1M
  - 3.5M
  - 14M
  - 28M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/25-pin-diode-switch-2.svg)

## 見るべき値

計算値 (上の模型から)。

| 周波数 | オンの S21 | オフの S21 | オンとオフの差 (アイソレーション) |
| --- | --- | --- | --- |
| 1 MHz | −0.25 dB | −40.83 dB | 40.6 dB |
| 3.5 MHz | −0.11 dB | −29.67 dB | 29.6 dB |
| 14 MHz | −0.09 dB | −17.67 dB | 17.6 dB |
| 28 MHz | −0.09 dB | −11.90 dB | 11.8 dB |

分かること:

- **オンの損失は 0.1 dB。** 1 Ω が 100 Ω (CH0 と CH1 の 50 Ω ずつ) の輪に直列に入るだけなので
  20 log(100 / 101) = −0.09 dB。1 MHz で −0.25 dB に下がるのは、チョークの X (628 Ω) が下がって
  信号を GND へ逃がすから。低い周波数で使うならチョークを大きくする
- **オフの効きは周波数とともに悪くなる。** 15 pF の X は 3.5 MHz で 3.0 kΩ、28 MHz で 379 Ω と、
  周波数に反比例して下がる。差は 1 オクターブで約 6 dB ずつ縮む (3.5 → 14 MHz の 2 オクターブで 12 dB)。
  直列のスイッチの限界は**オフの容量**で決まる
- 効きを上げる手は 2 つ: 容量の小さい本物の PIN ダイオードに替える (1 pF の桁の品がある)、
  直列の D1 の後ろに **GND へ落とすもう 1 本**を足し、オフのときだけそちらをオンにする (直列・並列の組)。
  並列の 1 本が漏れを GND へ逃がすので、アイソレーションが大きく伸びる
- 1N4007 が PIN として働くのは、I 層にたまった電荷が RF の 1 周期で抜けきらない周波数から上。
  ずっと低い周波数 (数百 kHz) では普通のダイオードとして RF を整流し、ひずみが出る。
  模型はこれを入れていないので、測った S21 が 1 MHz 付近で模型より悪ければ、それがこの効き方の下限

## LTspice での確かめ

`sim/25-pin-diode-switch.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端、
S21 = 2·V(out) / Vs)。D1 は上の表の線形の模型で、ダイオードの非線形 (整流) は入れていない。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1 MHz | S21 | −0.25 dB | −0.25 dB | 合う |
| 図3 | 3.5 MHz | S21 | −0.11 dB | −0.11 dB | 合う |
| 図3 | 14 MHz | S21 | −0.09 dB | −0.09 dB | 合う |
| 図3 | 28 MHz | S21 | −0.09 dB | −0.09 dB | 合う |
| 図4 | 1 MHz | S21 | −40.83 dB | −40.83 dB | 合う |
| 図4 | 3.5 MHz | S21 | −29.67 dB | −29.67 dB | 合う |
| 図4 | 14 MHz | S21 | −17.67 dB | −17.67 dB | 合う |
| 図4 | 28 MHz | S21 | −11.90 dB | −11.90 dB | 合う |

8 点すべて図の読み値と合う。

## 出典

自作。1N4007 の接合容量は [Vishay の 1N4001〜1N4007 のデータシート](https://www.vishay.com/docs/88503/1n4001.pdf) (4.0 V・1 MHz で 15 pF) による。

参考: [Wikipedia「PIN ダイオード」](https://ja.wikipedia.org/wiki/PINダイオード)、[Wikipedia "PIN diode"](https://en.wikipedia.org/wiki/PIN_diode)
