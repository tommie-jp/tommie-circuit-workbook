---
book: nanovna
chapter: 3
id: 3-2
title: 並列 (シャント) 治具
tier: 50
source: 自作
board: PF
device: H4
---

# 3-2 並列 (シャント) 治具

3-1 の直列治具は部品を CH0–CH1 の**間**に入れたが、この治具は CH0 と CH1
を直結したまま、部品を**その途中から GND へ**分岐させる。GND への漏れ電流
(ノイズ対策部品) や、GND との間の容量・インダクタンスを測るのに使う。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 並列 (シャント) 治具
parts:
  J1: sma 2,2 mirror
  J2: sma 8,2
  R1: resistor 4,2 4,4 100
  G1: ground 2,3
  G2: ground 8,3
  G3: ground 4,4
wires:
  - J1.1 -- 4,2 -- 6,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 8,3
notes:
  - text 2,1 center: CH0
  - text 8,1 center: CH1
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/02-shunt-fixture.svg)

- CH0–CH1 は**直結**のまま。R1 (DUT) がその途中から GND へ枝分かれする
- ここでは治具が正しく作れたかを確かめるため、100 Ω を仮に入れてある

## 実体配線図

```perfboard
# ユニバーサル基板の実体配線図 (tommie-fence の perfboard フェンス)
board:
  size: 7x5cm
  silk: board
  slots: on
title: 図2 perfboard の並列治具
points:
  GND: b7
parts:
  J1: sma/female-edge a10 011 09
  J2: sma/female-edge x10 y9
  R1: resistor h10 h7 100
wires:
  - a10 -- h10
  - h10 -- x10
  - h7 -- GND black
  - 09 -- b9 black
  - b9 -- GND black
  - y9 -- o9 black
  - o9 -- o7 black
  - o7 -- h7 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/perfboard/02-shunt-fixture.svg)

- 10 行を J1 (CH0) から J2 (CH1) まで一直線に通す。R1 は h10 から下 (h7) へ枝分かれし、
  7 行の GND のまとめ (b7〜o7) へつながる
- **中心導体の枝分かれの根元 (h10) から部品までを短く**する。3-1 と同じ理由で、
  長い枝はインダクタンスになり高い周波数でずれる (3-6)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz |
| 点数 | 101 |
| 校正 | SOLT。ケーブルの先 (治具の SMA に挿す手前) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag、S11 の Log Mag |

100 Ω を GND へ分岐させたときに**見えるはずの画面** (理想の模型)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図3 100 Ω をシャントに入れた治具の理想 (平ら)
dut:
  - shunt R 100
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
  - 300M
notes:
  - text 20M -40dB: S21 は −1.94 dB、S11 は −13.98 dB (直列の 3-1 と逆の出方)
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/02-shunt-fixture.svg)

## 見るべき値

50 Ω 系に並列 (GND へ) に Z を入れると、S21 = 2Z / (2Z + 50)、
S11 = −50 / (2Z + 50)。

| 入れる物 | S21 | S11 | 分かること |
| --- | --- | --- | --- |
| 100 Ω の抵抗 | −1.94 dB | −13.98 dB | 治具が正しく作れている |
| 太い銅線 (0 Ω、GND に短絡) | 小さいほど | 0 dB | GND への完全な短絡。3-1 の「開放」と対になる基準 |
| 何も入れない (開放のまま分岐) | 0 dB | 小さいほど | 分岐そのものの漏れ (3-1 の直列治具の開放と同じ考え方) |

**直列治具 (3-1) と数値の出方が逆になる**。直列は「小さい Z ほど通り抜ける
(S21 が 0 dB に近づく)」、シャントは「大きい Z ほど通り抜ける」。どちらの
治具で測るかで、部品の大小と S21 の増減の向きが逆になることを覚えておく。

## LTspice での確かめ

`sim/02-shunt-fixture.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。1 端子の `dut:` は最後を短絡か開放。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (シャント 100 Ω) | 10 MHz・300 MHz | S21 | −1.94 dB (平ら) | −1.94 dB | 合う |
| 同 | 同 | S11 | −13.98 dB | −13.98 dB (入口 33.3 Ω) | 合う |

## 出典

自作。
