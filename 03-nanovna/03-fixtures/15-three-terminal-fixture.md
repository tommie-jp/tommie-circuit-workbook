---
book: nanovna
chapter: 3
id: 3-15
title: 3 端子部品の治具 (トランジスタ・SAW)
tier: 200
source: 自作
board: PF
device: H4
---

# 3-15 3 端子部品の治具 (トランジスタ・SAW)

トランジスタ (B・C・E)、SAW フィルタやセラミックフィルタ (IN・GND・OUT) のように、
**ピンが 3 本で、1 本を入力と出力が共通に使う**部品がある。治具では、その共通のピン
(エミッタや GND のピン) を GND へ落とす。この線のインダクタンス Lg は、入力の電流と出力の電流が
**両方とも通る**。Lg の両端の電圧は入力から出力へそのまま漏れ、部品の帯域外の減衰や、
トランジスタの逆向きの漏れ (S12) を、部品の値ではなく治具の値にしてしまう。

この題では、共通のピンから GND までを短くした治具を作り、長い場合と比べる。部品は
帯域外の SAW フィルタを模型にする: 入力と出力の電極が、それぞれ 2 pF (静電容量。仮定) で
共通のピンにつながるだけで、**Lg が 0 なら入力から出力へは何も漏れない**。だから見える
漏れはすべて治具のせい。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 3 端子部品の治具 (共通のピンの線 Lg)
parts:
  J1: sma 1,2 mirror CH0
  U1:
    type: ic3
    at: 5,2
    label: DUT
    pins: [IN, COM, OUT]
  J2: sma 9,2 CH1
  G1: ground 1,3
  G2: ground 5,4
  G3: ground 9,3
wires:
  - J1.1 -- U1.IN
  - U1.OUT -- J2.1
  - U1.COM -- 5,4
  - J1.2 -- 1,3
  - J2.2 -- 9,3
notes:
  - text 5.2,3.4 blue left: Lg
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/15-three-terminal-fixture.svg)

- U1 が測る 3 端子の部品。SAW なら IN・GND・OUT、トランジスタ (エミッタ接地) なら B・E・C
- 青い字の Lg は、共通のピンから GND の線までの線のインダクタンス (図には線だけを描いた)。図2 の作りで 2 nH、
  4-12 の図2 のように 3 穴下ろしてから GND のまとめへ回すと 10 nH (どちらも目安)

**帯域外の SAW の模型** (図3・図4 の `dut:`): 入力の電極の 2 pF (直列) → Lg (並列に GND へ) →
出力の電極の 2 pF (直列)。Lg に流れる入力の電流が作る電圧を、出力の 2 pF が拾う。

## 部品

| 部品 | 値・型 | 注意 |
| --- | --- | --- |
| ユニバーサル基板 | 5×7 cm、厚さ 1.6 mm、FR-4 | 3-1 と同じ基板 |
| J1・J2 | 端面 SMA (メス) | 左が CH0 (入力)、右が CH1 (出力) |
| U1 | 測る 3 端子の部品 | 共通のピンを真ん中 (l10) に |
| GND の線 | すずめっき線 0.6 mm | 11 行を 0 列から Y 列まで通し、両方の SMA の外皮をつなぐ |

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  h: 1.6mm
  material: FR-4
  silk: board
  slots: on
title: 図2 3 端子部品の治具 (共通のピンは 1 穴で GND へ)
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  U1: ic3 k10 l10 m10 DUT
wires:
  - a10 -- k10
  - m10 -- x10
  - l10 -- l11 black
  - 011 -- l11 black
  - l11 -- y11 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/15-three-terminal-fixture.svg)

- **共通のピン (l10) は真上の l11 で GND の線に落とす**。ピンは基板から 3 mm で切る。
  ここが Lg のほとんどで、2.54 mm の線とピン 3 mm で約 1.6 nH (8-3 の経験式、目安)
- GND の線は 11 行を左右の SMA の外皮まで 1 本で通す。入力の帰り道と出力の帰り道が
  l11 で分かれ、共通の道を作らない
- 入力の線 (a10〜k10) と出力の線 (m10〜x10) は 10 行に一直線。長さは 3-1 と同じ考えで、
  この治具の上限 (300 MHz、3-6) を決める
- トランジスタを測るときは、U1 の並びを B・E・C にして 8-4 のバイアス T を前後に足す
  (8-4 の図2 と同じ。エミッタの線を短く太くするのは同じ理由)
- SAW フィルタは数百 MHz〜GHz の部品が多い。通過帯を測るなら、同じ並び (共通のピンを
  GND の面へ直に) で銅張り基板 (3-11 の Manhattan 式) に組む。ここで測るのは 300 MHz までの帯域外

## 掃引の設定

計器は VNA。この題の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag |
| 測れる下限 | NanoVNA-H4 のダイナミックレンジは 300 MHz まで 70 dB。−70 dB より下は雑音に埋もれる |

**共通のピンの線が長い (Lg 10 nH)** ときの見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図3 Lg 10 nH — 300 MHz で S21 −30.5 dB まで漏れる (治具のせい)
dut:
  - series C 2p
  - shunt L 10n
  - series C 2p
traces:
  - S21 logmag
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/15-three-terminal-fixture-1.svg)

**図2 の作り (Lg 2 nH)** の見えるはずの画面。設定は図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図4 Lg 2 nH — 300 MHz で S21 −45.5 dB (15 dB 下がる)
dut:
  - series C 2p
  - shunt L 2n
  - series C 2p
traces:
  - S21 logmag
markers:
  - 100M
  - 300M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/15-three-terminal-fixture-2.svg)

- 漏れは**周波数の 3 乗**で増える (1 けたで 60 dB)。2 つの 2 pF のリアクタンスが周波数に反比例し、
  Lg のリアクタンスが比例するため
- 図3 と図4 の差は 20 log (10 / 2) = 14 dB。Lg が 5 分の 1 になると漏れは 5 分の 1
- 100 MHz の −74 dB (図4) は NanoVNA-H4 の下限より低く、雑音しか見えない。**見えた漏れが
  下限より上なら、まず共通のピンの線を疑う**

## 見るべき値

計算値 (図3・図4 の模型、CH1 は 50 Ω (オーム) で終端)。

| 周波数 | Lg 10 nH の S21 | Lg 2 nH の S21 | 差 |
| --- | --- | --- | --- |
| 30 MHz | −91.4 dB | −105.4 dB | 14.0 dB |
| 100 MHz | −60.0 dB | −74.1 dB | 14.1 dB |
| 300 MHz | −30.5 dB | −45.5 dB | 15.0 dB |

- 漏れが小さいうちは S21 ≈ (2π (パイ) f)³ × Lg × C² × 100 Ω (100 Ω は 50 Ω の 2 倍。S21 は出力の電圧の 2 倍で数える。2 pF・10 nH・100 MHz で 0.00099 = −60.1 dB。算術)
- 300 MHz で差が 15 dB に広がるのは、漏れが大きくなって近似が外れ始めたため
- 実物の SAW には電極どうしの直の容量もあり、Lg が 0 でも漏れは 0 にならない。それでも
  **Lg を変えて漏れが動くなら、その分は治具のせい**。図2 の作りで共通のピンを長く浮かせて
  (3 穴下ろす) 測り比べると分かる
- トランジスタでは、エミッタの Lg は入力の Z に g<sub>m</sub> × Lg / C<sub>π</sub> = 2π f<sub>T</sub> × Lg の抵抗を足す
  (f<sub>T</sub> 80 MHz・Lg 10 nH で 5.0 Ω。計算値)。8-4 の r<sub>bb′</sub> 50 Ω に比べて小さいが、
  GHz のトランジスタ (f<sub>T</sub> 数 GHz) では効く

## LTspice での確かめ

`sim/15-three-terminal-fixture.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ (マイクロオーム) に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (Lg 10 nH) | 30 MHz / 100 MHz / 300 MHz | S21 | −91.4 / −60.0 / −30.5 dB | −91.43 / −59.97 / −30.47 dB | 合う |
| 図4 (Lg 2 nH) | 30 MHz / 100 MHz / 300 MHz | S21 | −105.4 / −74.1 / −45.5 dB | −105.42 / −74.05 / −45.48 dB | 合う |

近似式は算術で確かめた: (2π × 100 MHz)³ × 10 nH × (2 pF)² × 100 Ω = 0.00099 (−60.1 dB)。
Lg の見積り: 0.2 × 2.54 × {ln(2 × 2.54 / 0.64) − 0.75} = 0.67 nH と 0.2 × 3 × {ln(6 / 0.64) − 0.75} = 0.89 nH の和で 1.6 nH。
エミッタの抵抗 2π × 80 MHz × 10 nH = 5.03 Ω。

## 出典

自作。

参考: [Surface acoustic wave (Wikipedia)](https://en.wikipedia.org/wiki/Surface_acoustic_wave)、[Common emitter (Wikipedia)](https://en.wikipedia.org/wiki/Common_emitter)
