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
title: 図1 30 cm のケーブルの先の Open
parts:
  M1:
    type: device
    at: b2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  J1: sma f8 mirror
  G1: ground g8
wires:
  - M1.CH0 -| J1.1
  - J1.2 -- g8
notes:
  - text d5 blue: 30 cm (vf 0.66) のケーブル
  - text f8f0 blue center: Open (先端)
```

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 99 MHz〜101 MHz、3 点 (100 MHz 付近だけ見る) |
| 校正 | NanoVNA のコネクタ (ケーブルの手前) で SOLT |
| 表示 | S11 の位相、S11 の Smith チャート |

**基準面を NanoVNA のコネクタに置いた場合** (ケーブルを足す前に校正)、
Open は理想どおり位相 0°。

```vna
device: h4
sweep: 99M-101M 3
title: 図2 基準面がコネクタのときの Open (理想)
dut: open
traces:
  - S11 phase
  - S11 smith
markers:
  - 100M
```

**同じ Open を、30 cm のケーブルの先に置いた場合** (基準面を動かさずに測ると)。

```vna
device: h4
sweep: 99M-101M 3
title: 図3 30 cm 先の Open (基準面を動かさないと)
dut:
  - line 50 30cm vf 0.66
  - open
traces:
  - S11 phase
  - S11 smith
markers:
  - 100M
```

- 図2 は位相 0°、Smith の右端ちょうど
- 図3 は 100 MHz で位相が **−109.17°** も回り、Smith 上では右端から
  離れた点 (0.0 Ω − j35.6 Ω) に見える。**Open という同じ標準器なのに、
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

## 出典

自作。
