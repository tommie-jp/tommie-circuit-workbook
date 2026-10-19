---
book: nanovna
chapter: 1
id: 1-5
title: ケーブルの先端で校正する意味 (基準面)
tier: 50
source: 自作
board: —
device: H4
---

# 1-5 ケーブルの先端で校正する意味 (基準面)

校正を終えた場所を**基準面**と呼ぶ。校正した場所より先にケーブルを足すと、
そのケーブルの分だけ位相が回り、**DUT の本当の値が読めなくなる**。
基準面は「NanoVNA のコネクタ」ではなく「標準器をつないだ場所」になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 30 cm のケーブルの先の Open
parts:
  M1:
    type: device
    at: 2,3.12
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  J1: sma 9,3
  G1: ground 9,4
wires:
  - M1.CH0 -- J1.1
  - J1.2 -- 9,4
notes:
  - text 5,2 blue center: 30 cm (vf 0.66) のケーブル
  - text 9,2 blue center: Open (先端)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/circuit/05-reference-plane.svg)

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

この題は実体配線図を付けない — 校正の手順の題で、組む回路が無い (ケーブルの先に標準器を付ける)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 MHz〜150 MHz、101 点 (読むのは 100 MHz のマーカー) |
| 校正 | NanoVNA のコネクタ (ケーブルの手前) で SOLT |
| 表示 | S11 の位相、S11 の Smith チャート |

**基準面を NanoVNA のコネクタに置いた場合** (ケーブルを足す前に校正)、
Open は理想どおり位相 0°。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 50M-150M 101
title: 図2 基準面がコネクタのときの Open は位相 0° (右端)
dut: open
traces:
  - S11 phase
  - S11 smith
markers:
  - 100M
notes:
  - text 55M 60deg: 基準面がコネクタなら 0° のまま
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/05-reference-plane-1.svg)

**同じ Open を、30 cm のケーブルの先に置いた場合** (基準面を動かさずに測ると)。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 50M-150M 101
title: 図3 30 cm 先の Open — 基準面を動かさないと −109° 回る
dut:
  - line 50 30cm vf 0.66
  - open
traces:
  - S11 phase
  - S11 smith
markers:
  - 100M
notes:
  - text 55M -20deg: ケーブルのぶん回り、周波数が高いほど大きく回る
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/01-calibration/vna/05-reference-plane-2.svg)

- 図2 は位相 0°、Smith の右端ちょうど
- 図3 は 100 MHz で位相が **−109.17°** も回り、Smith 上では右端から
  離れた点 (0.0 Ω − j35.6 Ω) に見える。回る量は周波数に比例し、
  50 MHz では約 −55°、150 MHz では約 −164° になる (位相の線が右下がり)。**Open という同じ標準器なのに、
  ケーブルを足しただけで別の値に化ける**
- ケーブルの先まで基準面を移したいなら、**その 30 cm のケーブルを
  つないだ状態で校正をやり直す** (ポート延長という道もある。1-10)

## 見るべき値

| 基準面 | 100 MHz での Open の位相 | Smith 上の位置 |
| --- | --- | --- |
| NanoVNA のコネクタ (ケーブル無し) | 0.00° | 右端 (理想) |
| 30 cm 先 (ケーブルぶん動いた) | −109.17° | 右端から回った点 |

**校正は「どこを 0 とするか」を決める作業。** 治具や DUT をつなぐ場所と
校正した場所が違えば、その差分がそのまま測定誤差になる。

## LTspice での確かめ

`sim/05-reference-plane.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。1 端子の `dut:` は最後を短絡か開放。LTspice のコイルに付く既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図2 (Open) | 100 MHz | S11 の位相 | 0.00° | 0.0° | 合う |
| 図3 (30 cm・VF 0.66 の先の Open) | 100 MHz | S11 の位相 | −109.17° | −109.2° | 合う |
| 同 | 100 MHz | Z | 0.0 Ω − j35.6 Ω | 0.0 Ω − j35.56 Ω | 合う |
| 同 | 50 MHz / 150 MHz | S11 の位相 | 約 −55° / 約 −164° | −54.6° / −163.7° | 合う |

## 出典

自作。

参考: [Electrical length (Wikipedia)](https://en.wikipedia.org/wiki/Electrical_length)、[Network analyzer (electrical) (Wikipedia)](https://en.wikipedia.org/wiki/Network_analyzer_(electrical))
