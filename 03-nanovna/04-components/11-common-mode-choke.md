---
book: nanovna
chapter: 4
id: 4-11
title: コモンモードチョーク
tier: 100
source: 自作
board: PF
device: H4
---

# 4-11 コモンモードチョーク

コモンモードチョークは、1 つのコアに 2 本の巻線を**同じ向き**に巻いた部品。行きと帰りの
電流 (ディファレンシャルモード、信号そのもの) は磁束が打ち消し合って素通りし、2 本の線に
同じ向きに乗ったノイズ (コモンモード) だけが大きなインダクタンスに当たる。3-1 の直列治具に
**2 通りのつなぎ方**で挿し、この差を S21 で見る。

## 回路図

**コモンモードのつなぎ方** — 2 本の巻線を並列にして直列の位置に入れる。2 本に同じ向きの
電流が流れ、磁束が足し合う。

```circuit
title: 図1 コモンモード (2 本の巻線を並列に)
parts:
  J1: sma d2 mirror CH0
  L1: transformer d6
  J2: sma d10 CH1
  G1: ground e2
  G2: ground e10
wires:
  - J1.1 -| L1.A1
  - L1.A1 |- c6
  - c6 -| L1.B1
  - L1.A2 |- e6
  - e6 -| L1.B2
  - L1.B2 -| J2.1
  - J1.2 -- e2
  - J2.2 -- e10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/11-common-mode-choke-1.svg)

**ディファレンシャルモードのつなぎ方** — 巻線 A を通った電流が巻線 B を**逆向き**に
戻る。行きと帰りの電流と同じで、磁束が打ち消し合う。

```circuit
title: 図2 ディファレンシャルモード (A2 と B2 を結んで直列に)
parts:
  J1: sma d2 mirror CH0
  L1: transformer d6
  J2: sma d10 CH1
  G1: ground e2
  G2: ground e10
wires:
  - J1.1 -| L1.A1
  - L1.A2 |- e6
  - e6 -| L1.B2
  - L1.B1 -| J2.1
  - J1.2 -- e2
  - J2.2 -- e10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/circuit/11-common-mode-choke-2.svg)

- L1 は巻線 2 本の部品をトランスの記号で描いた。A1・B1 が巻き始め (データシートの ● のピン)
- 1 本の巻線のインダクタンスを 1 mH (コモンモード)、2 本を逆向きに通したときに残る
  漏れを 2 µH (ディファレンシャルモード) とする。巻線の間の容量は 10 pF と 5 pF
  (どれも見積もり。部品のデータシートの値に替える)

## 実体配線図

ピンの並びは、左の列が巻線 A (上が A1)、右の列が巻線 B (上が B1) とする。
実物のピンの並びは品ごとに違うので、データシートのピンの図で確かめる。

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図3 コモンモードのつなぎ方
points:
  GND: m2
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  L1: transformer i6 k6 i9 k9 CMC
wires:
  - i1 -- i6
  - i6 -- h6
  - h6 -- h9
  - h9 -- i9
  - k6 -- l6
  - l6 -- l9
  - l9 -- k9
  - l9 -- l13
  - l13 -- i13
  - i13 -- i24
  - j0 -- j2 black
  - j2 -- GND black
  - GND -- m15 black
  - j25 -- j15 black
  - j15 -- m15 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/11-common-mode-choke-1.svg)

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図4 ディファレンシャルモードのつなぎ方
points:
  GND: m2
parts:
  J1: sma/female-edge i1 h0 j0
  J2: sma/female-edge i24 j25
  L1: transformer i6 k6 i9 k9 CMC
wires:
  - i1 -- i6
  - k6 -- l6
  - l6 -- l9
  - l9 -- k9
  - i9 -- i24
  - j0 -- j2 black
  - j2 -- GND black
  - GND -- m15 black
  - j25 -- j15 black
  - j15 -- m15 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/perfboard/11-common-mode-choke-2.svg)

- 違いは**上の 2 本のピン (i6・i9) を h 行で結ぶか**と、**CH1 へ出すピン**だけ。コモンモードは
  下の結び (l 行) から、ディファレンシャルモードは B1 (i9) から出す。GND は m 行
- 図4 の l 行の線は A2 と B2 を結ぶだけで、ほかへはつながない。検査 (ERC) が
  「L1 の 2 本のピンがどこにもつながっていない」と言うが、これは意図どおり

## 掃引の設定

| 項目 | 値 |
| --- | --- |
| 範囲 | 50 kHz〜10 MHz |
| 点数 | 201 |
| 校正 | SOLT。ケーブルの先 (治具の SMA) で Open / Short / Load / Thru |
| 表示 | S21 の Log Mag と位相 |

**1. コモンモード** — 見えるはずの画面。1 mH と 10 pF の並列共振 (1.59 MHz) で
いちばん通らない。理想の谷は枠の下へ抜ける (印 3 は −94 dB) が、実物はコアの損失で丸まる。

```vna
device: h4
sweep: 50k-10M 201
title: 図5 コモンモード — 1 MHz で −40.3 dB、1.59 MHz で谷
dut:
  - series L 1m esr 0.5 cp 10p
traces:
  - S21 logmag
  - S21 phase
markers:
  - 100k
  - 1M
  - 1.59M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/11-common-mode-choke-1.svg)

**2. ディファレンシャルモード** — 同じ設定で。漏れの 2 µH しか残らず、ほとんど素通り。

```vna
device: h4
sweep: 50k-10M 201
title: 図6 ディファレンシャルモード — 1 MHz で −0.15 dB
dut:
  - series L 2u esr 1 cp 5p
traces:
  - S21 logmag
  - S21 phase
markers:
  - 100k
  - 1M
  - 1.59M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/04-components/vna/11-common-mode-choke-2.svg)

## 見るべき値

計算値 (模型から)。直列治具なので S21 = 100 / (100 + Z)。

| 周波数 | コモンモードの S21 | ディファレンシャルモードの S21 |
| --- | --- | --- |
| 100 kHz | −16.1 dB | −0.09 dB |
| 1 MHz | −40.3 dB | −0.15 dB |
| 1.59 MHz | −94.2 dB (理想の谷。実物はもっと浅い) | −0.25 dB |

分かること:

- **同じ部品なのに、つなぎ方で 40 dB 近く違う。** コモンモードのノイズだけを止め、
  信号 (ディファレンシャルモード) は通す — これがコモンモードチョークの働き。図6 の S21 が
  上端の 0 dB 近くからほとんど動かない (10 MHz までで 4 dB ほど) のは意図どおりで、
  素通りを見る線
- コモンモードの谷は巻線の容量との並列共振。それより上では容量が効いて Z が下がり、
  チョークが効かなくなる。**効く帯域は谷のまわり**で、データシートのインピーダンスの
  曲線 (コモンモード) と同じ形になる
- この模型は損失を巻線の抵抗 (0.5 Ω) だけにしているので、谷が鋭く深すぎる。
  実物はコアの損失で谷が丸まり、深さは数十 dB に留まる。実測との差がコアの損失
- ディファレンシャルモードでも、2 µH の漏れは周波数が上がると効いてくる。
  USB などの速い信号の線に使うチョークは、この漏れが小さい物を選ぶ

## 出典

自作。
