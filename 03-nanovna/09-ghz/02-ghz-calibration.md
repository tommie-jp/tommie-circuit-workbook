---
book: nanovna
chapter: 9
id: 9-2
title: GHz の校正 — 付属キットの限界と基準面
tier: 100
source: 自作
board: —
device: V2
---

# 9-2 GHz の校正 — 付属キットの限界と基準面

NanoVNA の校正 (1-1) は、Open・Short・Load が**理想** (Open は位相 0°、Short は 180°、
Load は 50 Ω ちょうど) だと思い込んで誤差を割り出す。数百 MHz まではこの思い込みで困らないが、
**GHz では付属の SMA の標準器の「ずれ」が見えてくる**。

- Open は、中心導体の先が**基準面より数 mm 奥**で終わり、先の縁に小さな容量が付く。
  理想の Open より**位相が遅れる**
- Load は抵抗とピンのインダクタンスで、周波数を上げると**反射が増える**

校正は「標準器が示す所を 0 とする」作業なので (1-5)、標準器がずれていれば、
**そのずれがそのまま全部の測定に乗る**。ここでは V2 で 3 GHz まで、そのずれの大きさを見積もる。

## この実験で確かめる式

Open の模型 (**仮定**): 基準面から 4 mm 奥 (PTFE、速度係数 0.7) に、縁の容量 50 fF。

- 奥行きの遅れ (片道) = 4 mm / (0.7 × 3×10⁸ m/s) = **19 ps**。往復で 38 ps、
  位相にすると **−360° × f × 38 ps** (3 GHz で −41°)
- 縁の容量のぶん: −2 × atan(2π f C × 50 Ω) (3 GHz で −5.4°)

Load の模型 (**仮定**): 50 Ω に 0.3 nH が直列。|S11| ≈ 2π f L / 100 Ω (3 GHz で −25 dB)。

実際の値は標準器ごとに違い、付属のキットには値が書かれていないことが多い。
**値が分からないなら、何 GHz から校正を信じなくなるかを知っておく**のがこの題の目的。

## 回路図

```circuit
title: 図1 ケーブルの先に付属の Open をつなぐ (ここが基準面)
parts:
  M1:
    type: device
    at: 2,3.12
    label: NanoVNA V2
    pins: [CH0, CH1]
    turn: mirror
  J1: sma 8,3
  G1: ground 8,4
wires:
  - M1.CH0 -- J1.1
  - J1.2 -- 8,4
notes:
  - text 5,4 blue center: ケーブル (校正の前からつないでおく)
  - text 8,2 blue center: 基準面 (標準器をつなぐ所)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/circuit/02-ghz-calibration.svg)

- 基準面は、SMA の外導体どうしが突き当たる面。標準器の「理想の位置」はここにある
- CH1 は使わない (反射だけを見る)。S21 の校正の Thru も GHz では同じ問題を持つ
  (バレルアダプタの長さぶんの遅れ)

## 掃引の設定

計器は VNA。この題の図は NanoVNA V2 (歴史的な機種) で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 校正キットの標準器そのものを測る題で、基板に載せる回路が無い。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜3 GHz (V2) |
| 点数 | 301 |
| 校正 | 付属キットで SOLT。**1 回目は理想の値のまま**、2 回目は NanoVNA-Saver の校正の設定で Open の遅れ (19 ps) と縁の容量 (C0 = 50 fF) を入れる |
| 表示 | 図2 は S11 の位相と Smith、図3 は S11 の Log Mag と Smith |

**確かめ方**: 2 つの校正で、同じもの (SMA のバレルアダプタの先に付属の Open を付けたもの) を測り、
位相の読みの差を見る。読みが Open に近い (Smith の右端に近い) 周波数では、差は入れた定数のぶん
(下の図2 の Open のずれ) とほぼ同じになる。Short に近い周波数ではほとんど差が出ない
(2 つの校正で違うのは Open の扱いだけだから)。
**キットの定数を知らなければ、この大きさの誤差が残る**ということ。

付属の Open の**本当の姿** (仮定の模型) の見えるはずの画面。校正はこれを 0° だと
思い込む。

```vna
device: v2
sweep: 50k-3G 301
title: 図2 付属の Open (仮定の模型) — 1 GHz で −16°、3 GHz で −47° 遅れる
dut:
  - line 50 4mm vf 0.7
  - shunt C 50f
  - open
traces:
  - S11 phase
  - S11 smith
markers:
  - 100M
  - 1G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/vna/02-ghz-calibration-1.svg)

- 100 MHz では −1.6° で、理想 (0°) との差はほぼ無い。**数百 MHz までなら付属の
  キットを理想とみなしてよい**のはこのため
- 3 GHz では −47°。Smith の外周を右端から下へ 47° 回った所。校正はここを「右端」と
  思い込むので、校正の後の測定は、**Open に近い (Z の高い) ものほど、この角度ぶん
  位相が進んで読める**

付属の Load の見えるはずの画面。設定は図2 と同じ。

```vna
device: v2
sweep: 50k-3G 301
title: 図3 付属の Load (仮定の模型) — 3 GHz で −25 dB まで反射が増える
dut:
  - series R 50 esl 0.3n
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 100M
  - 1G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/09-ghz/vna/02-ghz-calibration-2.svg)

- Load を 50 Ω ちょうどと思い込むので、**この反射の大きさより小さい S11 は読めない**。
  3 GHz で −25 dB の Load で校正したら、アンテナやフィルタの S11 の −30 dB は信じられない
- Smith では中心のすぐ上 (誘導性) にわずかにずれる

## 見るべき値

計算値 (Open は 4 mm 奥・50 fF、Load は 0.3 nH の仮定)。

| 周波数 | Open の位相 (理想 0°) | Load の S11 (理想 −∞) |
| --- | --- | --- |
| 100 MHz | −1.55° | −54.5 dB |
| 1 GHz | −15.5° | −34.5 dB |
| 3 GHz | −46.6° | −25.0 dB |

- **位相の誤差は周波数に比例して増える**。GHz の測定で位相 (Smith の角度、TDR の距離) を
  使うなら、キットの定数を入れた校正にする
- 周波数ごとの定数を持った市販の校正キット (メーカーが定数を公表しているもの) なら、
  この題の誤差は小さくできる

## 出典

自作。標準器の模型 (遅れ + 容量・インダクタンス) は一般的な VNA の校正キットの定義の考え方による。
数値は仮定。
