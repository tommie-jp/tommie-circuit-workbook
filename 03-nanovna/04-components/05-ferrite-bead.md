---
book: nanovna
chapter: 4
id: 4-5
title: フェライトビーズ — R と X の交差
tier: 50
source: 自作
board: PF
device: H4
---

# 4-5 フェライトビーズ — R と X の交差

フェライトビーズはノイズを**熱として吸収する**部品で、そのために低い周波数では
コイルらしく (X が大きく)、高い周波数では抵抗らしく (R が大きく) 振る舞う。
3-1 の直列治具にリード付きのフェライトビーズを挿して、R と X が入れ替わる様子を見る。

## 回路図

```circuit
title: 図1 直列治具にフェライトビーズを挿す
parts:
  J1: sma 2,2 mirror CH0
  FB1: ferrite-bead 4,2 6,2 l=$\mathrm{FB}_1$
  J2: sma 8,2 CH1
  G1: ground 2,3
  G2: ground 8,3
wires:
  - J1.1 -- 4,2
  - 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
notes:
  - text 4,2.7 center: フェライトビーズ
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/05-ferrite-bead.svg)

フェライトビーズは塗りつぶした箱の記号で描く。

## 実体配線図

```perfboard
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の直列治具にフェライトビーズ
points:
  GND: 09
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  FB1: ferrite-bead f10 i10 200R@164M
wires:
  - a10 -- f10
  - i10 -- x10
  - 09 -- y9 black
notes:
  - text v10: J2 に SMA の短絡プラグ
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/05-ferrite-bead.svg)

- ビーズは**リード付き (アキシャル) のフェライトビーズ**を使う。面実装 (SMD) の
  ビーズはユニバーサル基板の穴に挿せない。ピンは 4 穴分 (i6〜i9) に曲げて挿す
- J2 には **SMA の短絡プラグ**を付ける。ビーズの先を GND へ落とし、CH0 から見た
  1 端子 (S11) で部品の Z を読むため。CH1 へはつながない

## 模型

フェライトビーズのデータシートによく載る等価回路で考える。直流抵抗 Rdc に、
L・R・C の並列をつないだ形。

- **L (470 nH)**: 低い周波数でのコイルとしての働き
- **R (200 Ω)**: 芯材の損失。ノイズを熱にする分。L と並列なので、周波数が上がって
  L のリアクタンスが大きくなるほど、電流は R の側を通り、損失が表に出る
- **C (2 pF)**: 巻線と電極の間の容量。L と共振し (164 MHz)、その上では容量性になる
- **Rdc (0.3 Ω)**: 直流抵抗

値は 100 MHz で約 180 Ω の、リード付きビーズを想定した目安。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜900 MHz |
| 点数 | 401 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S11 の R と X (Ω)。最後を短絡にして 1 端子の Z 測定にする |

見えるはずの画面 (理想の模型)。

```vna
device: h4
sweep: 1M-900M 401
title: 図3 フェライトビーズ (Rdc + L∥R∥C) — 164 MHz で R が山、X は正から負へ
dut:
  - series L 470n esr 0.3 rp 200 cp 2p
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 59M
  - 164M
  - 457M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/05-ferrite-bead-1.svg)

R が X を抜く 59 MHz と、R の山の 164 MHz を広げて見る。

```vna
device: h4
sweep: 20M-200M 401
title: 図4 20〜200 MHz に広げる — 59 MHz で R が X を抜く
dut:
  - series L 470n esr 0.3 rp 200 cp 2p
  - short
traces:
  - S11 r
  - S11 x
markers:
  - 59M
  - 100M
  - 164M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/05-ferrite-bead-2.svg)

## 見るべき値

計算値 (模型: Rdc 0.3 Ω + (470 nH ∥ 200 Ω ∥ 2 pF))。

| 周波数 | R | X | どちらが優勢か |
| --- | --- | --- | --- |
| 10 MHz | 4.6 Ω | 28.9 Ω | X (誘導性) |
| 59 MHz (1 回目の交差) | 100 Ω | 99.8 Ω | 同じ大きさ |
| 100 MHz | 169 Ω | 72.0 Ω | R (抵抗性) |
| 164 MHz (共振、R の山) | 200 Ω | 0.2 Ω | R (抵抗性) |
| 300 MHz | 156 Ω | −82.6 Ω | R (抵抗性) |
| 457 MHz (2 回目の交差) | 100 Ω | −100 Ω | 同じ大きさ |
| 900 MHz | 34.6 Ω | −75.6 Ω | \|X\| (容量性) |

分かること:

- **低い周波数ではコイル、59 MHz から上は抵抗**として働く。ノイズを止めたい帯域
  (数十〜数百 MHz) で R が大きいのは、並列の R (芯材の損失) が効くから。
  ノイズは反射されずに熱になる
- **164 MHz で X が 0 を横切り、R が山 (200 Ω) になる。** L と C の共振で、
  ここでは Z がほぼ R だけになる。データシートの「インピーダンス @ 100 MHz」は、
  この山の裾の値であることが多い
- **457 MHz で |X| が R をもう一度上回る** (2 回目の交差)。X は負、つまり容量性で、
  ここから上はビーズの効きが落ちる。図 3 では X が負の側にあるので、2 本の線は
  交わらずに見える。|X| と R を比べて読む
- 実物は芯材の損失が周波数とともに変わるので、山の高さと位置は模型からずれる。
  測った Touchstone を `data:` で重ね、ずれを見る

## 出典

自作。
