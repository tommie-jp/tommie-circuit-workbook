---
book: nanovna
chapter: 6
id: 6-13
title: SAW フィルタ 433 / 915 MHz
tier: 200
source: 自作。フィルタの規格は RFM (Akoustis) のデータシート (SF2136E・SF2098E)
board: CB
device: H4
---

# 6-13 SAW フィルタ 433 / 915 MHz

**SAW フィルタ** (表面弾性波フィルタ) は、圧電基板の上を伝わる音の波で帯域を作る部品。
セラミックフィルタ (6-12) と同じく 1 個で急な裾のバンドパスになるが、数百 MHz〜GHz で働き、
多くは**入出力が 50 Ω (オーム) で作ってある**ので、抵抗で終端を合わせなくてよい。
433.92 MHz 用 (SF2136E) と 915 MHz 用 (SF2098E) を同じ治具に載せて測り、
規格の帯域・損失と、**H4 では裾の深さが読み切れない**ことを確かめる。

## この実験で確かめる式

どちらも 3.0 × 3.0 mm の 6 ピン (SM3030-6)。**2 番が入力・5 番が出力・ほかの 4 本が GND**、
信号源と負荷は 50 Ω。データシートの規格 (抜粋。典型値、括弧の中は保証値):

| 品 | 中心 | 帯域 | 挿入損失 | 帯域の外の減衰 |
| --- | --- | --- | --- | --- |
| SF2136E | 433.92 MHz | 3 dB 幅 5 MHz | 2.0 dB (3.3 dB 以下)。433.05〜434.79 MHz | 411〜414 MHz で 50 dB、454〜457 MHz で 51 dB |
| SF2098E | 915 MHz | 902〜928 MHz | 1.9 dB (4.0 dB 以下)。リップル 1.0 dB | 890〜894 MHz で 18 dB、940〜941 MHz で 47 dB、10〜800 MHz と 967〜1350 MHz で 37〜39 dB |

入れてよい電力は SF2136E が +10 dBm、SF2098E が +15 dBm まで。NanoVNA の出力は 0 dBm より小さい (0-3) ので、そのまま測れる。

測る側の限界も決まっている。H4 のダイナミックレンジ (S21 で読める床と 0 dB の差) は
**300 MHz まで 70 dB、900 MHz まで 60 dB、1.5 GHz まで 40 dB** (9-4)。
433.92 MHz の裾 (50 dB) は 60 dB の内側で読めるが、**915 MHz の帯域の外 (37〜49 dB) は 40 dB の床とほぼ重なる**。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 SAW フィルタを CH0 と CH1 の間に (50 Ω のまま)
parts:
  J1: sma 2,2 mirror CH0
  T1: tline 3,2 6,2 50 l=$\mathrm{L1}$
  U1: ceramic-filter 8,2 SF2136E
  T2: tline 10,2 13,2 50 l=$\mathrm{L2}$
  J2: sma 15,2 CH1
  G1: ground 2,3
  G2: ground 8,4
  G3: ground 15,3
wires:
  - J1.1 -- 3,2
  - 6,2 -- U1.IN
  - U1.OUT -- 10,2
  - 13,2 -- J2.1
  - U1.GND -- 8,4
  - J1.2 -- 2,3
  - J2.2 -- 15,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/13-saw-filter.svg)

- U1 は 3 ピンの箱の記号で代わりに描いた。実物の GND は 4 本 (1・3・4・6 番) で、図では 1 本にまとめた
- T1・T2 は図2 の線路 (L1 と L1n、L2n と L2)。915 MHz 用は U1 を SF2098E に替えるだけ

## 実体配線図

433 MHz と 915 MHz は perfboard の目安 (300 MHz) を超え、面実装の SAW を 50 Ω の線路で挟みたいので、銅張り基板にする。
両面の銅張り基板 (FR4、1.6 mm) に**コプレーナ線路 (CPWG)** を彫る。表の銅に溝を 2 本切って線を残し、
表の残りと裏の全面を GND にする。SAW の GND の 4 本のピンは、線の両脇の表の GND にそのまま乗る。
同じ基板を 2 枚作り、U1 だけ替える。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 60x24mm
  ground: both
  cut: 0.3mm
title: 図2 SAW の治具 (CPWG、表と裏が GND)
copper:
  L1: line 0,12 20.5,12 1.65mm
  L1n: line 20.5,12 28.5,12 1mm
  L2n: line 31.5,12 39.5,12 1mm
  L2: line 39.5,12 60,12 1.65mm
  V1: via 28.25,7
  V2: via 31.75,7
  V3: via 28.25,17
  V4: via 31.75,17
  V5: via 8,8
  V6: via 16,8
  V7: via 44,8
  V8: via 52,8
  V9: via 8,16
  V10: via 16,16
  V11: via 44,16
  V12: via 52,16
parts:
  J1: sma left 12 CH0
  J2: sma right 12 CH1
  U1: box 30,12 3x3mm 6 SF2136E
notes:
  - text 30,20.5: "U1 (3×3 mm): 2 番が入力・5 番が出力・ほかは GND"
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/copper/13-saw-filter.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、1.6 mm、比誘電率 4.4。5×7 cm から 60 mm × 24 mm を切り出す |
| 線 L1・L2 | 幅 1.65 mm、両脇に幅 0.3 mm の溝 (50 Ω、図の線路のラベルの計算値)。3 mm より細いのは、溝で GND を寄せたコプレーナ線路だから |
| 線 L1n・L2n | SAW の手前 8 mm を幅 1 mm に細くする (60 Ω)。SAW の 1 番・3 番のピン (2 番から 1.05 mm) が線に触れないため |
| via | 線から 4 mm 離して 8 mm おき、SAW の GND のピンの脇に 4 つ。表と裏の GND を φ0.8 mm の線で留める |
| 端面 SMA | 中心ピンを線の端へ、外皮の脚を表と裏の GND へ |

- 細くした 60 Ω の 8 mm は 915 MHz で約 15° (図の計算から)。50 Ω との段差の反射係数は 10/110 = 0.09 (−21 dB) で、2 か所が重なった最悪でも挿入損失への影響は 0.15 dB 以下 (算術)
- SAW は ESD に弱い (データシートの注意)。半田ごては接地し、ピンを指で触らない

## 掃引の設定

計器は VNA。この題の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | SF2136E | SF2098E |
| --- | --- | --- |
| 範囲 | 403.92〜463.92 MHz (中心 ±30 MHz) | 840〜990 MHz |
| 点数 | 241 (250 kHz おき) | 301 (500 kHz おき) |
| 校正 | SOLT。ケーブルの先で、範囲ごとに校正し直す (1-4) | 同じ |
| 表示 | S21 の Log Mag | S21 と S11 の Log Mag |

図の模型は、規格の帯域と損失に合わせた LC の**等価回路** (チェビシェフ 0.5 dB を 3 段と 5 段、
共振器の Q で損失を入れた。形の目安で、SAW の中身ではない)。SF2136E の**見えるはずの画面**。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 403.92M-463.92M 241
title: 図3 SF2136E (等価回路) — 433.92 MHz で −2.0 dB、3 dB 幅 5.0 MHz
dut:
  - shunt L 117.8p esr 0.000362
  - shunt C 1.142n
  - series L 1.961u esr 6.03
  - series C 68.6f
  - shunt L 117.8p esr 0.000362
  - shunt C 1.142n
traces:
  - S21 logmag
markers:
  - 431.44M
  - 433.92M
  - 436.43M
  - 454M
notes:
  - band 433.05M 434.79M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/13-saw-filter-1.svg)

SF2098E。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 840M-990M 301
title: 図4 SF2098E (等価回路) — 902〜928 MHz で −1.9〜−3.0 dB
dut:
  - shunt L 178.3p esr 0.0019
  - shunt C 169.7p
  - series L 305.8n esr 3.25
  - series C 98.94f
  - shunt L 119.7p esr 0.00127
  - shunt C 252.7p
  - series L 305.8n esr 3.25
  - series C 98.94f
  - shunt L 178.3p esr 0.0019
  - shunt C 169.7p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 892M
  - 915M
  - 928M
  - 940M
notes:
  - band 902M 928M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/13-saw-filter-2.svg)

## 見るべき値

計算値 (上の等価回路による)。塗った帯は規格の通過帯域。

| 図 | マーカー | 周波数 | S21 | S11 | 意味 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1 | 431.44 MHz | −5.02 dB | — | 3 dB 幅の下の端 |
| 図3 | 2 | 433.92 MHz | **−2.00 dB** | — | 中心。規格の挿入損失 2.0 dB |
| 図3 | 3 | 436.43 MHz | −5.00 dB | — | 3 dB 幅の上の端 (幅 5.0 MHz) |
| 図3 | 4 | 454 MHz | −59.57 dB | — | 中心から 20 MHz 上 (規格 51 dB) |
| 図4 | 1 | 892 MHz | −25.54 dB | −0.56 dB | 帯域の下 10 MHz (規格 18 dB) |
| 図4 | 2 | 915 MHz | **−1.90 dB** | −22.47 dB | 中心。規格の挿入損失 1.9 dB |
| 図4 | 3 | 928 MHz | −2.91 dB | −10.95 dB | 帯域の上の端 |
| 図4 | 4 | 940 MHz | −28.68 dB | −0.41 dB | 帯域の上 12 MHz (規格 47 dB) |

- 実物で読むのは**中心の損失と帯域の幅**。データシートの保証値 (SF2136E 3.3 dB 以下、
  SF2098E 4.0 dB 以下) に入れば合格
- 等価回路の裾は左右対称で、遠くほど深く落ちる。**実物の SAW は帯域の外が 37〜50 dB ほどで頭打ちになる**
  (入力から出力へ電波が素通りする分。目安)。裾の形の比べはデータシートの数で行う
- 図4 の S11 は 915 MHz で −22 dB。データシートの VSWR 1.8 (典型) は S11 にすると −10.9 dB で、
  実物は等価回路ほど整合していない

分かること:

- **H4 で 915 MHz の裾は読めない**。900 MHz を超えると H4 の床は −40 dB 付近で、SF2098E の帯域の外
  (37〜49 dB) はその床に埋もれる。画面が −40 dB で平らになったら、フィルタの限界ではなく計器の限界を疑う。
  V2 は高調波を使わないので床が深い (9-4 で確かめる)
- 433.92 MHz は H4 の 300〜900 MHz の帯 (床 −60 dB) にあり、規格の 50 dB は読める。ただし余裕は 10 dB しかない
- 1 個の部品で、LC (6-3) では作れない 1 % 幅 (5 MHz / 434 MHz) の急な帯域が得られる。
  帯域は工場で決まり、調整できない

## LTspice での確かめ

`sim/13-saw-filter.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。LTspice のコイルに付く既定の直列抵抗は 1 µΩ (マイクロオーム) に固定)。
理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 431.44 MHz | S21 | −5.02 dB | −5.03 dB | 合う |
| 図3 | 433.92 MHz | S21 | −2.00 dB | −2.00 dB | 合う |
| 図3 | 436.43 MHz | S21 | −5.00 dB | −5.00 dB | 合う |
| 図3 | 454 MHz | S21 | −59.57 dB | −59.57 dB | 合う |
| 図4 | 892 MHz | S21 / S11 | −25.54 dB / −0.56 dB | −25.54 dB / −0.56 dB | 合う |
| 図4 | 915 MHz | S21 / S11 | −1.90 dB / −22.47 dB | −1.90 dB / −22.46 dB | 合う |
| 図4 | 928 MHz | S21 / S11 | −2.91 dB / −10.95 dB | −2.92 dB / −10.95 dB | 合う |
| 図4 | 940 MHz | S21 / S11 | −28.68 dB / −0.41 dB | −28.68 dB / −0.41 dB | 合う |

8 点すべて図の読み値と合う。VSWR 1.8 → S11 −10.9 dB (Γ (ガンマ) = 0.8/2.8) と、60 Ω の段差の −21 dB は算術。

## 出典

自作。SAW フィルタの規格・ピン・外形は RFM (Akoustis) のデータシート
[SF2136E](https://rfmi.akoustis.com/wp-content/uploads/pdf-front/sf2136e-ds-rev07272022.pdf) と
[SF2098E](https://rfmi.akoustis.com/wp-content/uploads/pdf-front/sf2098e-ds-rev07262022.pdf) による。
H4 のダイナミックレンジは 9-4 の値。

参考: [Wikipedia「表面弾性波」](https://ja.wikipedia.org/wiki/%E8%A1%A8%E9%9D%A2%E5%BC%BE%E6%80%A7%E6%B3%A2)、[Wikipedia "Coplanar waveguide"](https://en.wikipedia.org/wiki/Coplanar_waveguide)
