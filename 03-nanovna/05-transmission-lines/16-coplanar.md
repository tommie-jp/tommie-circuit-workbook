---
book: nanovna
chapter: 5
id: 5-16
title: コプレーナ線路
tier: 200
source: 自作
board: CB
device: V2
---

# 5-16 コプレーナ線路

マイクロストリップ (5-15) は線のまわりの表の銅を広く剥がす。手で作るときは、線の両脇に
**細い溝だけを切って**、残りの表の銅を GND として残すほうが楽だ。こうした線を
**コプレーナ線路** (CPW) と呼び、裏も GND なら**裏付きのコプレーナ線路** (CPWG) になる。
同じ面の GND が近いぶん線と GND の間の容量が増え、**Z₀ は溝の幅で下がる**。

マイクロストリップの 50 Ω (オーム) の幅 (3.06 mm) のまま 0.3 mm の溝を切った線と、溝を 0.5 mm にして
線を 2.0 mm に細くした線を作り、V2 で 3 GHz まで比べる。銅張り基板にするのは、溝の幅と
GND の面で Z₀ を決める線路の題だから (perfboard では作れない)。

## この実験で確かめる式

CPWG の Z₀ と実効比誘電率 ε<sub>eff</sub> (イプシロン) は等角写像の式 (Wadell の本の形) で決まる。線の幅 S、溝の幅 W、
基材の厚さ h として k = S / (S + 2W)、k₃ = tanh(πS/4h) / tanh(π(S + 2W)/4h) (π (パイ) は円周率) を作り、
完全楕円積分 K の比で表す。ここでは結果だけを使う (厚さ 1.6 mm・比誘電率 4.4 の FR4 と仮定)。

| 線の幅 S | 溝 0.3 mm | 溝 0.5 mm | 溝 1.0 mm | 溝 2.0 mm |
| --- | --- | --- | --- | --- |
| 3.06 mm | **38.2 Ω** | 41.6 Ω | 45.9 Ω | 49.2 Ω |
| 2.5 mm | 42.0 Ω | 46.0 Ω | 51.3 Ω | 55.3 Ω |
| 2.0 mm | 46.3 Ω | **51.1 Ω** | 57.5 Ω | 62.3 Ω |

- 溝を広げるほど、マイクロストリップの値 (3.06 mm で 50 Ω) に近づく
- 50 Ω からずれた長さ l の線を 50 Ω の間に挟むと、線が λ (ラムダ)/4 になる周波数で S11 が一番大きくなる。
  そのときの |S11| = |Z₀² − 50²| / (Z₀² + 50²)。**この山の高さから Z₀ が逆算できる**

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 CH0-CH1 間に 40 mm のコプレーナ線路 (2 枚を順に測る)
parts:
  J1: sma 2,2 mirror CH0
  TL1: tline 4,2 7,2 Z0 l=$\mathrm{TL}_1$
  J2: sma 9,2 CH1
  G1: ground 2,3
  G2: ground 9,3
wires:
  - J1.1 -- 4,2
  - 7,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 9,3
notes:
  - text 5.5,2.7 center: 40 mm・38.2 Ω か 51.1 Ω
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/circuit/16-coplanar.svg)

## 実体配線図

5×7 cm の両面基板から 40 mm × 20 mm を 2 枚切り出す。表の銅は溝のほかは全部残し、via
(0.8 mm の穴に線を通して表と裏を半田付け) で表と裏の GND を 6 mm おきに留める。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
title: 図2 40 mm のコプレーナ線路 (表も裏も GND)
f: 1.09G
sheets:
  - name: 狭い溝
    board:
      size: 40x20mm
      ground: both
      cut: 0.3mm
    copper:
      L1: line 0,10 40,10 3.06mm gap 0.3mm
      V1: via 5,6
      V2: via 11,6
      V3: via 17,6
      V4: via 23,6
      V5: via 29,6
      V6: via 35,6
      V7: via 5,14
      V8: via 11,14
      V9: via 17,14
      V10: via 23,14
      V11: via 29,14
      V12: via 35,14
    parts:
      J1: sma left 10 CH0
      J2: sma right 10 CH1
  - name: 50Ω
    board:
      size: 40x20mm
      ground: both
      cut: 0.5mm
    copper:
      L2: line 0,10 40,10 2mm gap 0.5mm
      V21: via 5,6
      V22: via 11,6
      V23: via 17,6
      V24: via 23,6
      V25: via 29,6
      V26: via 35,6
      V27: via 5,14
      V28: via 11,14
      V29: via 17,14
      V30: via 23,14
      V31: via 29,14
      V32: via 35,14
    parts:
      J3: sma left 10 CH0
      J4: sma right 10 CH1
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/copper/16-coplanar.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 基板 | 両面の FR4、厚さ 1.6 mm、40 mm × 20 mm を 2 枚。裏は全面の銅 (GND) |
| 1 枚め (狭い溝) | 線の幅 3.06 mm、両脇に 0.3 mm の溝 (計算値 38.2 Ω) |
| 2 枚め (50Ω) | 線の幅 2.0 mm、両脇に 0.5 mm の溝 (計算値 51.1 Ω) |
| via | 両脇に 6 mm おきに 6 個ずつ。溝の縁から 1.5 mm ほど離す |
| 端面 SMA | 左右の縁。中心ピンを線へ、外皮の脚を表の GND と裏のベタへ半田付け |

- 溝はカッターで 2 本の切れ目を入れ、間の銅を剥がす。溝に銅の切り残しがあると線が GND に
  短絡する。**切ったらテスターで線と GND の間が開いているか確かめる**
- 1 枚めは溝が狭く、SMA の外皮の脚が溝の上まで来る (図2 の 1 枚め)。脚が線に触れていないかをルーペで見て、触れていれば脚を外へ少し開く
- via の間隔 6 mm は、3 GHz の線の中の波長 (59 mm) の 1/10。間が広いと、表と裏の GND の間に
  別の波 (平行平板の波) が立って、ある周波数で S21 に谷が出る (目安)

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる (3 GHz は H4 の範囲の外)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 MHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOLT。CH0・CH1 のケーブルの先 (基板の SMA を挿す所) で |
| 表示 | S21 と S11 の Log Mag |

1 枚め (狭い溝、38.2 Ω・40 mm) の見えるはずの画面 (理想の模型、損失は見ない)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50M-3G 301
title: 図3 狭い溝 (38.2 Ω) — λ/4 の 1.09 GHz で S11 が −11.6 dB
dut:
  - line 38.2 40mm vf 0.581
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1.09G
  - 2.18G
  - 3G
expect:
  - match: しか動きません
    why: S11 の山を見る図で、S21 の 0.3 dB の落ち込みは読み値の表で読む
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/16-coplanar-1.svg)

2 枚め (50Ω、51.1 Ω・40 mm)。掃引とマーカーは図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 50M-3G 301
title: 図4 溝 0.5 mm・幅 2.0 mm (51.1 Ω) — S11 は −33 dB より下
dut:
  - line 51.1 40mm vf 0.586
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 1.09G
  - 2.18G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/05-transmission-lines/vna/16-coplanar-2.svg)

## 見るべき値

計算値 (損失の無い線、比誘電率 4.4 の仮定)。

| 周波数 | 1 枚めの S11 | 1 枚めの S21 | 2 枚めの S11 | 2 枚めの S21 |
| --- | --- | --- | --- | --- |
| 1.09 GHz (1 枚めの λ/4) | **−11.61 dB** | −0.31 dB | −33.25 dB | 0.00 dB |
| 2.18 GHz (λ/2) | −59.30 dB (谷) | 0.00 dB | −66.06 dB | 0.00 dB |
| 3 GHz | −12.22 dB | −0.27 dB | −34.04 dB | 0.00 dB |

- 1 枚めは、線が λ/4 になる 1.09 GHz で S11 が山になり、λ/2 の 2.18 GHz で谷に落ちる
  (λ/2 の線は両端の Z が同じになり、50 Ω に見える)。**山の高さ −11.6 dB から |S11| = 0.263、
  Z₀ = 50 × √((1 − 0.263) / (1 + 0.263)) = 38.2 Ω** と逆算できる
- 山の周波数から速度係数が出る: vf = 4 × 0.04 m × 1.09 GHz / c = 0.581 (ε<sub>eff</sub> = 2.96)。
  同じ幅のマイクロストリップ (5-15 の 0.548) より速い。**電界の一部が溝の上の空気を通るから**
- 2 枚めは山が −33 dB より下で、50 Ω の線として使える。**溝を狭くしたら線も細くする**
- 実物では FR4 の損失で 3 GHz の S21 が 0.4 dB ほど下がる (目安)。測った山の高さと周波数を
  上の表と突き合わせ、ずれたら比誘電率を 5-15 の方法で測り直して計算し直す

## LTspice での確かめ

`sim/16-coplanar.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端、損失の無い T 素子)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (38.2 Ω) | 1.09 GHz | S11 / S21 | −11.61 dB / −0.31 dB | −11.61 dB / −0.31 dB | 合う |
| 図3 | 2.18 GHz | S11 | −59.30 dB | −59.30 dB | 合う |
| 図3 | 3 GHz | S11 / S21 | −12.22 dB / −0.27 dB | −12.22 dB / −0.27 dB | 合う |
| 図4 (51.1 Ω) | 1.09 GHz | S11 | −33.25 dB | −33.25 dB | 合う |
| 図4 | 2.18 GHz | S11 | −66.06 dB | −66.06 dB | 合う |
| 図4 | 3 GHz | S11 | −34.04 dB | −34.04 dB | 合う |

.meas は大きさを線形で出すので、20 log₁₀ で dB に直した。Z₀ の表は等角写像の式を Python (SciPy の楕円積分) で解いた算術で、
図2 の線路の札 (38.2 Ω・51.1 Ω) と合う。

## 出典

自作。CPWG の Z₀ は B. C. Wadell, *Transmission Line Design Handbook* (Artech House, 1991) の裏付きコプレーナ線路の式で計算した。

参考: [Wikipedia "Coplanar waveguide"](https://en.wikipedia.org/wiki/Coplanar_waveguide)
