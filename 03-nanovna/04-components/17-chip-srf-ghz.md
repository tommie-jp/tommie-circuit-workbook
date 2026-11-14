---
book: nanovna
chapter: 4
id: 4-17
title: チップ部品 (0603 / 0805) の SRF を GHz で
tier: 200
source: 自作
board: CB
device: V2
---

# 4-17 チップ部品 (0603 / 0805) の SRF を GHz で

4-2 ではリード付きの 0.1 µF (マイクロファラド) の自己共振周波数 (SRF) が 11 MHz にあった。
リードの無いチップのコンデンサは ESL (等価直列インダクタンス) がずっと小さく、10 pF なら SRF は GHz に来る。
ここでは同じ 10 pF の C0G を、**0603 (メートル表記で 1608、1.6 mm × 0.8 mm)** と
**0805 (2012、2.0 mm × 1.25 mm)** の 2 つの大きさで、銅張り基板のマイクロストリップに**シャント** (線路から GND へ) に載せ、
V2 で 3 GHz まで掃引して SRF を比べる。

GHz では部品そのものの ESL と同じくらい、**部品を GND へ落とす道 (パッドと via)** のインダクタンスが効く。
この題の結論は「大きさの違いより、実装の違いのほうが SRF を大きく動かす」ことになる。

## この実験で確かめる式

部品の枝 (C・ESR・ESL の直列) の Z (インピーダンス) を Z = ESR + j(ωL − 1/(ωC)) と書く。ω (オメガ) は 2πf。
50 Ω (オーム) の線路の途中から Z を GND へ落とすと

- S21 = 2Z / (2Z + 50)、S11 = −50 / (2Z + 50) (3-2 の並列治具と同じ式)
- SRF = 1 / (2π√(L·C))。SRF で Z = ESR になり、S21 は谷になる。谷の深さから ESR が読める
  (Z が 25 Ω より十分小さければ S21 ≈ Z / 25)

**シャントで測る理由**: SRF の近くの Z は 1 Ω より小さい。S11 の \|Z\| (4-2 の方法) では 1 Ω 以下が
反射 1 にほぼ重なって読めないが、シャントの S21 なら 0.2 Ω が −42 dB の谷になり、はっきり読める。

## 回路図

治具の等価回路。L は部品の ESL と、パッドと via のインダクタンスをまとめた値。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 マイクロストリップにチップのコンデンサをシャントに載せる (等価回路)
parts:
  J1: sma 2,2 mirror CH0
  T1: tline 3,2 6,2 50 l=$\mathrm{20mm}$
  T2: tline 6,2 9,2 50 l=$\mathrm{20mm}$
  J2: sma 10,2 CH1
  C1: capacitor 6,2.75 6,3.75 10p
  R1: resistor 6,3.75 6,4.75 0.2 l=$\mathrm{ESR}$
  L1: inductor 6,4.75 6,5.75 0.9n l=$\mathrm{L}$
  G1: ground 2,3
  G2: ground 10,3
  G3: ground 6,6
wires:
  - J1.1 -- 3,2
  - 9,2 -- J2.1
  - 6,2 -- 6,2.75
  - 6,5.75 -- 6,6
  - J1.2 -- 2,3
  - J2.2 -- 10,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/17-chip-srf-ghz.svg)

- T1・T2 は 50 Ω の線路で、S21 の大きさは変えない (損失は見ない)。位相だけが回る
- L1 は 1608 で 0.9 nH、2012 で 1.1 nH と置く (下の表。目安)

## 実体配線図

5×7 cm の両面の銅張り基板から 40 mm × 20 mm を切り出す。9-3 の図2 のスルーと同じ線路の中央に、パッドを 1 つ足す。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 40x20mm
  ground: back
title: 図2 シャントのチップの治具 (1608 と 2012 を付け替える)
f: 1.6G
copper:
  L1: line 0,8 40,8 3.06mm
  P1: pad 20,12 3x3mm
  V1: via 19,12.5
  V2: via 21,12.5
parts:
  J1: sma left 8 CH0
  J2: sma right 8 CH1
  C1: capacitor/1608 20,10 r90 10p
notes:
  - dim 0,17 20,17
  - text 23,15: P1 は via 2 本で裏の GND へ
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/copper/17-chip-srf-ghz.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、40 mm × 20 mm。裏は全面の銅 (GND) |
| 線 L1 | 表の中央に幅 3.06 mm・長さ 40 mm (計算値 50 Ω)。まわりの表の銅は剥がす |
| パッド P1 | 線の下の縁から 1.0 mm 空けて 3 mm × 3 mm を残す。直径 0.8 mm の穴を 2 つ開け、銅線を通して裏の GND に半田付けする (via) |
| C1 | 線の下の縁とパッドを跨いで、線と直角に載せる (線は切らない)。1608 を測ったら外して、同じ所に 2012 を載せる |
| 端面 SMA (J1・J2) | 左右の縁。中心ピンを線の端へ、外皮の脚は裏のベタへ |

- via の 1 本のインダクタンスは、厚さ h = 1.6 mm・穴の径 d = 0.8 mm で
  0.2·h·(ln(4h/d) + 1) ≈ 1.0 nH (近似式。目安)。2 本並べるとほぼ半分の 0.5 nH になる
- 銅張り基板にするのは、GHz で 50 Ω の線路と、面で取った GND が要るから (perfboard は 300 MHz くらいまで、3-6・9-3)。
  FR4 は 1 GHz を超えると損失と比誘電率がばらつくが、この題は谷の**位置**を読むので、線路の損失は校正の Thru の値と比べて見分ける (9-7)
- C1 を載せない状態で 1 度掃引し、治具だけでスルー (S21 ≈ 0 dB) になっていることを確かめておく (9-3 の図4)

## 部品

| 部品 | 値 | 備考 |
| --- | --- | --- |
| C1 (1 つめ) | 10 pF C0G、1608 (0603) | ESL は 0.4 nH (目安) |
| C1 (2 つめ) | 10 pF C0G、2012 (0805) | ESL は 0.6 nH (目安) |
| J1・J2 | 端面 SMA (メス) | 2 個 |
| 基板 | 両面 FR4 1.6 mm | 40 mm × 20 mm |

部品の ESL はメーカーの値ではなく、大きさから見積もった目安。L1 には via の 0.5 nH を足して
1608 で 0.9 nH・2012 で 1.1 nH とする。ESR は GHz で 0.2 Ω (目安) と置く。

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種、3 GHz まで) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる (LiteVNA64 なら 6 GHz まで延ばせる)。
AD3 とオシロは使わない (S パラメータを見る題)。H4 は 1.5 GHz で止まり、SRF に届かない。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で。基準面と治具の線の扱いは 9-2・3-13 |
| 表示 | S21 と S11 の Log Mag (1 つの枠に重ねる) |

1608 の 10 pF の見えるはずの画面 (理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-3G 301
title: 図3 1608 の 10 pF (L 0.9 nH) — 1.68 GHz で S21 が −42 dB の谷
dut:
  - shunt C 10p esr 0.2 esl 0.9n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 500M
  - 1678M
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/17-chip-srf-ghz-1.svg)

2012 の 10 pF (L 1.1 nH) に付け替えたときの画面。設定は図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-3G 301
title: 図4 2012 の 10 pF (L 1.1 nH) — 谷は 1.52 GHz へ下がる
dut:
  - shunt C 10p esr 0.2 esl 1.1n
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 500M
  - 1517M
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/17-chip-srf-ghz-2.svg)

- 谷より下では容量性で、周波数が上がるほど Z が小さくなり S21 が下がる。谷より上では誘導性で、
  Z が大きくなり S21 が 0 dB へ戻る
- S11 は谷で 0 dB に張り付く (ほぼ全部が GND で跳ね返る)。S21 の谷のほうが位置も深さも読みやすい

## 見るべき値

計算値 (模型: 10 pF + ESR 0.2 Ω + L)。

| 実装 | L | SRF | S21 @ 500 MHz | S21 @ SRF | S21 @ 3 GHz |
| --- | --- | --- | --- | --- | --- |
| 1608、via 2 本 (図3) | 0.9 nH | 1.678 GHz | −2.44 dB | −42.0 dB | −7.54 dB |
| 2012、via 2 本 (図4) | 1.1 nH | 1.517 GHz | −2.53 dB | −42.0 dB | −5.64 dB |
| 1608、via 1 本 (図なし) | 1.4 nH | 1.345 GHz | −2.66 dB | −42.0 dB | −3.85 dB |

S11 は図3 で 500 MHz −3.73 dB・1.678 GHz −0.07 dB・3 GHz −0.91 dB、図4 で −3.63 dB・−0.07 dB・−1.45 dB (計算値)。

分かること:

- **大きさを 1608 から 2012 にすると SRF は約 10 % 下がる** (L が 0.9 → 1.1 nH)。
  **via を 2 本から 1 本にすると約 20 % 下がる** (0.9 → 1.4 nH)。実装のほうが効く
- **谷の深さ (−42 dB) は L によらない**。SRF の Z は ESR だけで、S21 ≈ 2·0.2 / 50.4 から ESR が逆算できる。
  測った谷が浅ければ ESR (と、GHz では基板の損失) が大きい
- SRF より上ではこのコンデンサは**コイル**。2.4 GHz のバイパスに 10 pF を選ぶなら、
  1608 を via 2 本で落とせば SRF の近く (Z が小さい所) に来る。100 pF に替えると SRF は √10 分の 1 の 0.53 GHz に下がり、2.4 GHz では Z が大きくなる (計算値)
- 測った SRF から L を逆算する: L = 1 / ((2π·SRF)²·C)。C は低い周波数 (100〜300 MHz) の S21 から 1/(ωC) を読んで確かめる

## LTspice での確かめ

`sim/17-chip-srf-ghz.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。
LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 500 MHz | S21 | −2.44 dB | −2.44 dB | 合う |
| 図3 | 1.678 GHz | S21 | −42.0 dB | −42.01 dB | 合う |
| 図3 | 3 GHz | S21 | −7.54 dB | −7.54 dB | 合う |
| 図4 | 500 MHz | S21 | −2.53 dB | −2.53 dB | 合う |
| 図4 | 1.517 GHz | S21 | −42.0 dB | −42.01 dB | 合う |
| 図4 | 3 GHz | S21 | −5.64 dB | −5.64 dB | 合う |
| via 1 本 | 1.345 GHz | S21 | −42.0 dB | −42.01 dB | 合う |

7 点すべて合う。via のインダクタンスの近似式 (1.0 nH) は算術で確かめた (LTspice では見ていない)。

## 出典

自作。via のインダクタンスは広く使われる近似式 0.2·h·(ln(4h/d) + 1) nH による。

参考: [Wikipedia "Equivalent series inductance"](https://en.wikipedia.org/wiki/Equivalent_series_inductance)、[Wikipedia "Via (electronics)"](https://en.wikipedia.org/wiki/Via_(electronics))、[Wikipedia "Microstrip"](https://en.wikipedia.org/wiki/Microstrip)
