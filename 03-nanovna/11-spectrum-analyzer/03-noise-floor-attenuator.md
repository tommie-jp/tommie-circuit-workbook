---
book: nanovna
chapter: 11
id: 11-3
title: ノイズフロアとアッテネータ — 小さい信号をどこまで見られるか
tier: 100
source: 自作
board: —
device: SA
---

# 11-3 ノイズフロアとアッテネータ — 小さい信号をどこまで見られるか

11-2 の 1 MHz の信号を、今度は思い切り小さくして測る。**スペアナが見せられる
一番小さい信号は、計器自身が持つノイズ (ノイズフロア) に埋もれない範囲まで**。
アッテネータを入力の手前に足すと、信号だけでなくノイズフロアも動くことを
確かめる。

## 回路図

11-2 と同じ Wavegen の 1 MHz・1 V (peak) の信号に、パッド (アッテネータ) を
継ぎ足して弱くする。パッドの作り方は 0-3 と同じ 50 Ω の T 型で、値だけ 30 dB 用に置き換える。
30 dB の T 型パッドの計算値は `series` 46.9 Ω・`shunt` 3.17 Ω・`series` 46.9 Ω。
E24 に丸めると 47 Ω・3.3 Ω・47 Ω になる (0-3 の 20 dB パッドと同じ丸め方)。

```circuit
title: 図1 30 dB パッドで信号をさらに落として tinySA へ
parts:
  X1:
    type: device
    at: b1
    label: Analog Discovery
    pins: [W1, GND]
    turn: mirror
  R1: resistor b5 b7 1k
  P1: resistor b7 b9 47
  P2: resistor b9 d9 3.3
  P3: resistor b9 b11 47
  X2:
    type: device
    at: b13
    label: tinySA
    pins: [RF, GND]
  GA: ground d4
  GP: ground d9
  GM: ground d12
wires:
  - X1.W1 -| b5
  - b11 -| X2.RF
  - X1.GND -| d4
  - X2.GND -| d12
```

## 計器の設定

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 中心周波数 | 1 MHz | `FREQUENCY` → `CENTER` |
| スパン | 200 kHz | `FREQUENCY` → `SPAN` |
| RBW | 100 kHz → 3 kHz (2 通りで比べる) | `FREQUENCY` → `RBW` |
| 入力アッテネータ | 0 dB → 20 dB (2 通りで比べる) | `LEVEL` → `ATTENUATE` |
| LNA | 切 → 入 (tinySA Ultra のみ) | `LEVEL` → `LNA` |

## 見るべき値

計算値。11-2 の 1 MHz・約 −16.4 dBm に 30 dB パッドを足すと届く電力は
約 **−46.4 dBm**。

| 操作 | 見え方 (計算値・理論) | 分かること |
| --- | --- | --- |
| 30 dB パッドを入れる | 信号が −16.4 dBm → −46.4 dBm に下がる (計算値) | 減衰量ぶんそのまま下がる。11-1 の「必要な減衰量」と同じ引き算 |
| ノイズフロア (実測。自分の tinySA の値を読む) | 目安として 30〜100 kHz の RBW で −90〜−110 dBm 台に収まることが多い (機種・RBW依存、**要実測**) | −46.4 dBm の信号はこの目安の範囲なら十分に見えるはず |
| `LEVEL` → `ATTENUATE` を 0 dB → 20 dB へ (回路のパッドとは別、計器の内部減衰) | ノイズフロアが**ほぼそのまま 20 dB 分**上がって見える。信号もほぼ 20 dB 分下がる (差し引きは変わらない) | **内部アッテネータは、外の強い信号から入力回路を守るためのもの。弱い信号を見たいときに増やしても得はなく、むしろノイズに埋もれやすくなる** |
| RBW 100 kHz → 3 kHz (1/約33) | ノイズフロアが 10 log₁₀(100/3) ≈ **15 dB** 下がる (計算値) | 小さい信号を見たいときは、アッテネータを足すのではなく **RBW を狭める** (または平均化する) のが筋 |
| `LEVEL` → `LNA` を入にする | ノイズフロアが最大 16 dB 下がる (仕様書の値、tinySA Ultra) | 内蔵の低雑音アンプでノイズフロアを下げる、別の手段。ただし強い信号が同時に来ているとアンプが飽和しやすくなる |

**まとめ**: アッテネータは「壊れないための道具」(11-1・0-3)。**小さい信号を
見るための道具は RBW・平均化・LNA** で、この 2 つの役割を混同しない。

## 出典

自作。tinySA Ultra の `ATTENUATE` `RBW` `LNA` の意味は公式 wiki の
[Level メニュー](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.LEVEL)と
[Frequency メニュー](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.FREQ) (2026-09-27 に確認)。
RBW とノイズフロアの関係 (10 log₁₀ の式) は掃引型スペアナの一般的な理論。
