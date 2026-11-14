---
book: nanovna
chapter: 11
id: 11-10
title: スプリアスとイメージ — 見えている山は本物か
tier: 200
source: 自作
board: —
device: SA
---

# 11-10 スプリアスとイメージ — 見えている山は本物か

スペアナの画面の山は、入力に本当にある信号だけではない。**スペアナの中で作られた山**が混じる。

- **歪み**: 入力が強いと、入口のミキサーが歪んで高調波や相互変調の山を作る
- **スプリアス**: 中の発振器 (マイコンのクロックなど) が漏れて、入力が無くても立つ山
- **イメージ (像)**: ミキサーで周波数を変える受信機は、狙った周波数のほかに「中間周波数を挟んだ反対側」も
  受けてしまう。入口のローパスで消せない帯域で出る

この題では 1 MHz の強い正弦波をわざと減衰 0 dB で入れて歪みの山を作り、
**減衰を 10 dB 増やすと本物の山は動かず、中で作られた山だけが下がる**ことを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 の 1 MHz を 220 Ω で落として -4.7 dBm を tinySA へ
parts:
  X1:
    type: device
    at: 1,2
    label: Analog Discovery
    pins: [W1, GND]
    turn: mirror
  R1: resistor 5,2 7,2 220
  X2:
    type: device
    at: 9,2
    label: tinySA
    pins: [RF, GND]
  GA: ground 4,4
  GM: ground 8,4
wires:
  - X1.W1 -| 5,2
  - 7,2 -| X2.RF
  - X1.GND -| 4,4
  - X2.GND -| 8,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/10-spurs-and-images.svg)

- W1 を 1 MHz・振幅 1 V の正弦波にする。tinySA に届くのは 1 V × 50/(220 + 50) = 0.185 V<sub>p</sub>、
  **約 −4.7 dBm** (計算値)。W1 の電流は約 3.7 mA
- tinySA Ultra の入力の絶対最大は +6 dBm (減衰 0 dB)、1 dB 圧縮点は −1 dBm (公式の仕様)。
  −4.7 dBm はどちらより下だが、仕様の「よい測定は −25 dBm より下」よりずっと強い。**歪みを見るために
  わざと強くしている**。終わったら減衰を自動に戻す
- 減衰 0 dB では tinySA の入力は 50 Ω (オーム) ちょうどではない (50 Ω になるのは 10 dB 以上、公式の仕様)。
  0 dB の読みが 10 dB のときと少し違っても、それだけでは歪みと決めない。3 MHz が 20 dB 動くかで見る
- この題は新しい実体配線図を付けない。11-2 の図2 のブレッドボードで R1 (1 kΩ) を 220 Ω に替えるだけ

## 計器の設定

計器は tinySA Ultra、信号は AD3 の W1。オシロは使わない (周波数を見る題)。

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 開始・終了 | 0〜4.49 MHz、450 点 (1 点 = 10 kHz) | `FREQUENCY` → `START` / `STOP` |
| RBW | 10 kHz | `FREQUENCY` → `RBW` |
| 基準レベル | 0 dBm | `LEVEL` → `REF LEVEL` |
| 入力アッテネータ | **0 dB → 10 dB → 20 dB (手動)** | `LEVEL` → `ATTENUATE` |

読みは減衰を補正して出る。減衰を増やすとノイズフロアは同じだけ上がる
(RBW 10 kHz で 0 / 10 / 20 dB のとき約 −106.8 / −96.8 / −86.8 dBm。11-3)。

## 計器の画面

内部の歪みを、仕様の IIP3 (3 次の入力インターセプト点) +15 dBm から見積もった**見えるはずの画面**
(下の「見るべき値」の模型。W1 自身の高調波は描いていない)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 減衰 0 dB — 3 MHz に中で作られた山 (−53.5 dBm)
device: tinysa-ultra
sweep: 0-4.49M 450
rbw: 10kHz
atten: 0dB
ref: 0dBm
signal:
  - sine 1MHz -4.74dBm
  - sine 3MHz -53.48dBm
markers: [1M, 3M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/10-spurs-and-images-1.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 減衰 10 dB — 1 MHz は動かず、3 MHz だけ 20 dB 下がる
device: tinysa-ultra
sweep: 0-4.49M 450
rbw: 10kHz
atten: 10dB
ref: 0dBm
signal:
  - sine 1MHz -4.66dBm
  - sine 3MHz -73.48dBm
markers: [1M, 3M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/10-spurs-and-images-2.svg)

## 見るべき値

計算値 (入口を 3 次の歪みだけを持つ増幅とみなした模型。tinySA の中の本当の歪みの形は公開されていないので、
IIP3 から出した**目安**)。

| 減衰 | 1 MHz の読み | 3 MHz の読み | 3 MHz − 1 MHz | フロア |
| --- | --- | --- | --- | --- |
| 0 dB | −4.7 dBm | −53.5 dBm | −48.7 dBc | −106.8 dBm |
| 10 dB | −4.7 dBm | −73.5 dBm | −68.8 dBc | −96.8 dBm |
| 20 dB | −4.7 dBm | (−93.5 dBm、フロアの下) | 見えない | −86.8 dBm |

分かること:

- **見分け方**: 減衰を 10 dB 増やしたとき、**本物の山は読みが変わらず**、中の 2 次の歪みは 10 dB、
  3 次は 20 dB 下がる (3 次の歪みは入力の 3 乗に比例するので、入力が 1/10 (−10 dB) なら 1/1000 (−30 dB)、
  読みの補正 +10 dB を引いて −20 dB)。下がらなくなるまで減衰を増やし、その減衰で測る (公式の Harmonic 測定の頁の手順。11-6 でも使う)
- **減衰を増やしすぎるとフロアが上がる**。20 dB では 3 MHz の歪みは消えるが、本物の小さな山もフロアに沈む。
  「歪みが消え、フロアがまだ十分に低い」所を選ぶ
- 外付けのアッテネータでも同じ見分け方ができる。そのときは読みも 10 dB 下がるので、
  `EXT GAIN` に −10 を入れて補正するか、本物も 10 dB 下がることを基準にする

### 入力が無いのに立つ山・場所が動く山

| 疑うもの | 確かめ方 |
| --- | --- |
| 中のクロックのスプリアス (マイコンの 48 MHz とその倍) | 入力を 50 Ω で終わらせても残れば、中で作られた山。付属のアンテナや狭い RBW で目立つ (公式の注意。新しいファームウェアでは抑えてある) |
| イメージ (Ultra モード、800 MHz より上) | 800 MHz より上は入口のローパスを外して高調波でミキシングするので、像とスプリアスが出る。`CONFIG` → `SPUR REMOVAL` を自動 (既定) にしておくと、周波数をずらして 2 回測り、動く山を消す。消し方が効かないのは、短い信号・広い信号 (1 MHz 超)・掃引する信号 |
| 外の強い電波 (FM 放送・携帯電話) | 入力を終わらせても残るのは、シールドを抜けて入った電波。アンテナを外して消えれば本物の電波 |
| 前置フィルタで確かめる | 見たい帯だけを通すフィルタ (6-1 のローパス、帯域のアンテナ) を前に入れる。帯の外の山が消えずに残れば、それは中で作られた像 |

- Ultra モードでは、局部発振 (LO) が RF 端子から最大 −10 dBm ほど漏れ出る (公式の説明)。
  弱い信号を扱う回路 (受信機の入口など) を直につなぐときは、この漏れが回路に入ることを覚えておく

## LTspice での確かめ

`sim/10-spurs-attenuator.cir` で、tinySA の入口を y = x − a<sub>3</sub>x³ (IIP3 = +15 dBm から a<sub>3</sub> = 0.4217) の
増幅とみなし、W1 の 1 MHz・1 V を 220 Ω 越しに入れて、減衰 0・10・20 dB の 3 通りで `.four` を読んだ。
読みは減衰を補正した値。模型は仮定 (実測ではない)。

| 減衰 | 本文の数字 (1 MHz / 3 MHz) | LTspice | 判定 |
| --- | --- | --- | --- |
| 0 dB | −4.7 / −53.5 dBm | −4.74 / −53.48 dBm | 合う |
| 10 dB | −4.7 / −73.5 dBm | −4.66 / −73.48 dBm | 合う |
| 20 dB | −4.7 / −93.5 dBm | −4.65 / −93.48 dBm | 合う |

3 MHz が 10 dB ごとに 20.00 dB 下がり、1 MHz は 0.09 dB しか動かない (減衰 0 dB でわずかに圧縮される分)。
3 次の高調波の式 a<sub>3</sub>A³/4 (A = 0.1852 V) = 0.670 mV<sub>p</sub> も算術で合う。ノイズフロアは算術。
スプリアス・イメージ・LO の漏れは計器の性質で、SPICE の対象外。

## 出典

自作。tinySA Ultra の IIP3・1 dB 圧縮点・入力の上限は
[公式の仕様](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification)、減衰を変えて確かめる手順は
[Harmonic 測定の頁](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.IMD)、Ultra モードの像と消し方・LO の漏れは
[Ultra モードの頁](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Ultra)、48 MHz のスプリアスと外の電波は
[FAQ](https://tinysa.org/wiki/pmwiki.php?n=Main.FAQ)・[制限の頁](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Limitations)
(いずれも 2026-11-14 に確認)。
