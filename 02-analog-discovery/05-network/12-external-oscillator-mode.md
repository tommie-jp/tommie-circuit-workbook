---
book: analog-discovery
chapter: 5
id: 5-12
title: 外部発振器モード (Wavegen を使わない)
tier: 100
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 5-12 外部発振器モード (Wavegen を使わない)

Network の **Source** 設定には、いつも使ってきた「Wavegen C1」のほかに
**External** がある。External を選ぶと Network 自身は周波数を掃引せず、
**Start〜Stop の範囲でいちばん強い成分を探して**、その周波数での利得と位相を
測る。Network が信号を出さなくても測れることを、W1 を「外部発振器の代わり」
にして確かめる。

## 回路図

```circuit
title: 図1 スルー (基準) の結線
parts:
  V1: sine a1 c1 l=$\mathrm{W1}$
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  M2: voltmeter a5 c5 l=$\mathrm{CH2}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

板は使わない。5-5・5-8 と同じスルー (W1 を CH1・CH2 の両方に直結)。ここでは
W1 を**「外部の信号源」に見立て**、Network からは操作しない (周波数を Network
の掃引ではなく Wavegen 側で直接決める)。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen | W1: Sine、**2.5 kHz 固定**、Amplitude 1 V (Network からは触らない) |
| Network | **Source: External**。Start・Stop を下表のとおり変える |

## 見るべき値

計算値というより「窓に入っているか」の確認。スルーなので DUT による減衰は
なく、周波数さえ捉えられれば利得 0 dB・位相 0° になるはず。

| Start〜Stop | W1 の 2.5 kHz は範囲内か | 見える結果 |
| --- | --- | --- |
| 1 kHz〜4 kHz | 入っている | 利得 ≈ 0 dB、位相 ≈ 0° (2.5 kHz を検出) |
| 1 kHz〜1.5 kHz | **入っていない** | ピークが見つからず、結果が不安定・読み取り不能 |
| 2 kHz〜3 kHz (範囲を狭める) | 入っている | 1 kHz〜4 kHz のときと同じ結果だが、**分解能が上がる** |

分かること:

- **External では Network が周波数を作らない代わり、実際に鳴っている周波数を
  Start〜Stop の中から探す。** 5-1〜5-11 の「Wavegen C1」モードは Network
  自身が周波数を指定するので、この「探す」失敗は原理上起こらない — External
  ならではの制約
- **探す範囲を狭めるほど、周波数の読み取り精度が上がる。** 何 Hz か分かって
  いる信号を測るときは、その近くまで Start・Stop を絞るとよい
- **使いどころ**: 自励発振回路 (5-10 の CR 発振器のような、こちらが周波数を
  決められない回路) をいじらずに、実際に動いている周波数での特性をそのまま
  読みたいとき。Wavegen で無理に同じ周波数を作って注入する必要がない

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Network の節。Source に External を選べること、Start〜Stop の中でいちばん
強い成分を検出することは同マニュアルの記載による)。
