---
book: nanovna
chapter: 6
id: 6-16
title: 2.4 GHz ノッチ (スタブ)
tier: 200
source: 自作
board: CB
device: V2
---

# 6-16 2.4 GHz ノッチ (スタブ)

5-7 では同軸ケーブルの先を開いた**スタブ**が、長さが λ (ラムダ)/4 になる周波数で信号を地へ逃がすのを見た。
同じことを銅張り基板のマイクロストリップでやると、**部品なしで 2.45 GHz だけを落とすノッチ**ができる。
1.575 GHz の GPS や 900 MHz 帯の受信機に、近くの Wi-Fi (2.4 GHz) が入ってくるのを落とす使い方を考え、
スタブの太さ (Z0) で**落ちる幅と、残したい周波数の損失**がどう変わるかを NanoVNA V2 で見る。

## この実験で確かめる式

先を開いた長さ l のスタブを入口から見ると Z = −jZ<sub>s</sub> cot βl (Z<sub>s</sub> はスタブの Z0、β (ベータ) は位相定数)。
βl = 90° (l = λ<sub>g</sub>/4) で Z = 0 になり、主線を GND へ短絡するので S21 が深く落ちる。
λ<sub>g</sub> = v<sub>f</sub> × c / f で、厚さ 1.6 mm・比誘電率 4.4 の FR4 では (Hammerstad の式。計算値):

| スタブ | 幅 | v<sub>f</sub> | λ<sub>g</sub>/4 at 2.45 GHz | 開放端の延び | 彫る長さ (主線の中心から) |
| --- | --- | --- | --- | --- | --- |
| 50 Ω (オーム) | 3.06 mm | 0.548 | 16.76 mm | 0.62 mm | 16.14 mm (主線の縁から 14.61 mm) |
| 100 Ω | 0.71 mm | 0.574 | 17.56 mm | 0.45 mm | 17.11 mm (主線の縁から 15.58 mm) |

開いた端の先には電界が少しはみ出し、線が実際より長く見える (開放端の延び)。その分を短く彫る。

**落ちる幅は Z<sub>s</sub> で決まる**。共振の近くで Z = −jZ<sub>s</sub> cot βl ≈ jZ<sub>s</sub> (π (パイ)/2)(Δ (デルタ)f / f<sub>0</sub>) なので、
Z<sub>s</sub> が小さい (太い) スタブほど、中心から外れても Z が小さいまま (広く落ちる)。その代わり、遠い周波数でも
Z が小さく、残したい信号まで少し削る。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 50 Ω の線の途中に開放スタブ (2.45 GHz で 1/4 波長)
parts:
  J1: sma 2,2 mirror CH0
  TA: tline 3,2 6,2 50 l=$\mathrm{T1}$
  TS: tline 7,2 7,5 50 l=$\mathrm{S1}$
  TB: tline 8,2 11,2 50 l=$\mathrm{T1}$
  J2: sma 12,2 CH1
  G1: ground 2,3
  G2: ground 12,3
wires:
  - J1.1 -- 3,2
  - 6,2 -- 7,2 -- 8,2
  - 11,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 12,3
notes:
  - text 7,5.3 center: 開放
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/circuit/16-stub-notch-2g4.svg)

- 図1 の T1 は主線を 2 つに分けて描いた (図2 の T1 の左右の半分)。S1 は図2 の S1 (100 Ω の版は S2)
- S1 の先は意図して開放のままにしてある (check が「どこにもつながっていない」と言うのはこのため)

## 実体配線図

2.4 GHz は perfboard の目安 (300 MHz) を超え、スタブそのものが Z0 と長さの決まった線路なので、銅張り基板に彫る。
FR4 は 1 GHz を超えると損失が増えるが、ノッチの周波数は長さで決まり、損失は深さを浅くするだけなので FR4 で作る。
両面の FR4 (1.6 mm、比誘電率 4.4) で、裏は全面の銅 (GND)。5×7 cm から 40 mm × 30 mm を 2 枚切り出す。

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
title: 図2 開放スタブのノッチ (2.45 GHz)
f: 2.45G
board:
  size: 40x30mm
  ground: back
sheets:
  - name: 50Ωのスタブ
    copper:
      T1: line 0,24 40,24 3.06mm
      S1: line 20,24 20,7.86 3.06mm
    parts:
      J1: sma left 24 CH0
      J2: sma right 24 CH1
    notes:
      - dim 10,7.86 10,22.47
  - name: 100Ωのスタブ
    copper:
      T2: line 0,24 40,24 3.06mm
      S2: line 20,24 20,6.89 0.71mm
    parts:
      J3: sma left 24 CH0
      J4: sma right 24 CH1
    notes:
      - dim 10,6.89 10,22.47
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/copper/16-stub-notch-2g4.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 主線 T1・T2 | 幅 3.06 mm (50 Ω)、40 mm |
| スタブ S1 | 幅 3.06 mm、主線の上の縁から 14.61 mm (寸法線)。主線の中央から真上へ |
| スタブ S2 | 幅 0.71 mm (100 Ω)、主線の上の縁から 15.58 mm。3 mm より細いのは、高い Z0 で落ちる幅を狭めるため |
| 端面 SMA | 左右の縁に 1 つずつ。外皮の脚は縁で裏のベタへ |

- **ノッチが低い周波数に出たら、スタブの先を削る**。0.5 mm 削ると約 3 % 上がる (16.8 mm に対して。目安)。伸ばすのは難しいので、
  少し長めに彫って削り合わせる
- T 字の分かれ目は模型に入っていない。実物のノッチは数 % ずれることがある (目安)

## 掃引の設定

計器は VNA。2.4 GHz は H4 の範囲 (1.5 GHz まで) の外なので、この題の図は NanoVNA V2 (3 GHz まで) で書いてある。
標準の LiteVNA64 でも同じ手順で測れる。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1〜3 GHz |
| 点数 | 401 (5 MHz おき) |
| 校正 | SOLT。ケーブルの先で (9-2) |
| 表示 | S21 の Log Mag |

模型は損失の無い線路 (主線の左右 12 mm ずつと、開放スタブ)。スタブの長さは開放端の延びを足した電気的な長さ。
50 Ω のスタブの**見えるはずの画面**。塗った帯は 2.4 GHz 帯 (2.4〜2.4835 GHz)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 1G-3G 401
title: 図3 50 Ω のスタブ — 2.45 GHz で深く落ち、GPS (1.575 GHz) も −2.1 dB
dut:
  - line 50 12mm vf 0.548
  - shunt line 50 16.76mm vf 0.548 open
  - line 50 12mm vf 0.548
traces:
  - S21 logmag
markers:
  - 1.575G
  - 2.4G
  - 2.45G
  - 2.4835G
notes:
  - band 2.4G 2.4835G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/16-stub-notch-2g4-1.svg)

100 Ω のスタブ。掃引もマーカーも図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 1G-3G 401
title: 図4 100 Ω のスタブ — 落ちる幅が半分、GPS は −0.6 dB
dut:
  - line 50 12mm vf 0.548
  - shunt line 99.7 17.56mm vf 0.574 open
  - line 50 12mm vf 0.548
traces:
  - S21 logmag
markers:
  - 1.575G
  - 2.4G
  - 2.45G
  - 2.4835G
notes:
  - band 2.4G 2.4835G
expect:
  - match: に集まっています
    why: 図3 と同じ掃引で幅を比べる図
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/06-filters/vna/16-stub-notch-2g4-2.svg)

## 見るべき値

計算値 (損失の無い線路の模型)。

| マーカー | 周波数 | 50 Ω のスタブ (図3) | 100 Ω のスタブ (図4) | 意味 |
| --- | --- | --- | --- | --- |
| 1 | 1.575 GHz | −2.13 dB | −0.64 dB | GPS。残したい信号の損失 |
| 2 | 2.400 GHz | −23.78 dB | −17.95 dB | 2.4 GHz 帯の下の端 |
| 3 | 2.450 GHz | −62.71 dB | −71.72 dB | ノッチの中心 (λ<sub>g</sub>/4) |
| 4 | 2.4835 GHz | −27.50 dB | −21.35 dB | 2.4 GHz 帯の上の端 |

- −10 dB より深く落ちる幅は、50 Ω のスタブで 2.19〜2.71 GHz (515 MHz)、100 Ω で 2.32〜2.58 GHz (260 MHz) (計算値)
- 中心の深さ (−60〜−70 dB) は損失の無い模型の値。実物は FR4 の損失で浅くなり、読むのは**ノッチの周波数と幅**
- 開放スタブは 3 倍 (7.35 GHz) でもまた落ちる (5-7 と同じ)。V2 の範囲の外

分かること:

- **太いスタブは広く深く落とすが、遠い周波数も削る** (GPS で −2.1 dB)。細いスタブは帯域の端で −18〜−21 dB と浅いが、
  GPS の損失は −0.6 dB で済む。何を残したいかで太さを選ぶ
- 2.4 GHz 帯の幅 (83.5 MHz) を 20 dB 以上落とすには 50 Ω のスタブで足りる。もっと深く・急にしたいなら、
  λ<sub>g</sub>/4 離して 2 本並べる (落ちる所が 2 つ重なる)
- 同軸ケーブルで作るスタブ (5-7・6-18) と同じ式で、長さだけが短い (v<sub>f</sub> 0.55 と 0.66 の違い)

## LTspice での確かめ

`sim/16-stub-notch-2g4.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。線路は損失の無い T 素子、スタブの先の開放は 1 TΩ)。
理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 | 1.575 GHz | S21 | −2.13 dB | −2.13 dB | 合う |
| 図3 | 2.400 GHz | S21 | −23.78 dB | −23.78 dB | 合う |
| 図3 | 2.450 GHz | S21 | −62.71 dB | −62.71 dB | 合う |
| 図3 | 2.4835 GHz | S21 | −27.50 dB | −27.50 dB | 合う |
| 図4 | 1.575 GHz | S21 | −0.64 dB | −0.64 dB | 合う |
| 図4 | 2.400 GHz | S21 | −17.95 dB | −17.95 dB | 合う |
| 図4 | 2.450 GHz | S21 | −71.72 dB | −71.72 dB | 合う |
| 図4 | 2.4835 GHz | S21 | −21.35 dB | −21.35 dB | 合う |

8 点すべて図の読み値と合う。スタブの幅と Z0 は図2 のラベル (copper フェンスの計算) と合い、電気長は 87°・88° (図2 のラベル。開放端の延びを足して 90°) と合う。

## 出典

自作。[マイクロストリップ](https://en.wikipedia.org/wiki/Microstrip)の Z0・実効比誘電率・開放端の延びは Hammerstad の近似式で計算した。

参考: [Wikipedia "Stub (electronics)"](https://en.wikipedia.org/wiki/Stub_(electronics))、[Wikipedia "Distributed-element filter"](https://en.wikipedia.org/wiki/Distributed-element_filter)
