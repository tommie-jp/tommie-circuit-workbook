---
book: analog-discovery
chapter: 1
id: 1-10
title: デバイスマネージャ — バッファ長と ch 数の構成を切り替える
tier: 100
source: 自作 (数値は Digilent の Analog Discovery 2 / 3 の公式仕様)
board: —
device: AD3
---

# 1-10 デバイスマネージャ — バッファ長と ch 数の構成を切り替える

Analog Discovery の中の FPGA には、Scope・Wavegen・Logic Analyzer・Pattern
Generator が使う記録メモリが 1 つのプールとして載っている。**Device Manager**
（`Settings > Device Manager`）は、このメモリをどの計器にどれだけ割り振るかを
選ぶ画面。ここでは AD3 でチャネル数とバッファ長（1 チャネルあたりの記録点数）
がどう入れ替わるかを確かめる。

## 回路図

```circuit
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: sine a1 c1 1
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

配線は 0-3 のループバックのまま。ここで変えるのは配線ではなく、Device Manager
の設定。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅 1 V |
| Scope (CH1・CH2) | 既定の構成（2 ch）でまず Record Length（Scope の記録点数の設定欄）を確認する |
| Device Manager | 既定の構成 → 「Scope を 1 ch にしてバッファを増やす」構成に切り替える |

## 見るべき値（AD3）

AD3 の仕様では、Scope のバッファは**既定で 2 ch とも 32,768 点/ch**。
**片方の ch だけを使う設定にすると、1 ch の記録が 65,536 点まで増える**
（2 ch 分のメモリを 1 ch に集める）。

| 構成 | CH1 のバッファ長 | CH2 は使えるか |
| --- | --- | --- |
| 既定（2 ch） | 32,768 点 | 使える |
| CH1 のみ（Device Manager で切り替え） | 65,536 点（2 倍） | 使えない |

Device Manager にはこのほかにも、Scope・Wavegen・Logic Analyzer・Pattern
Generator の間でメモリの配分を変えるプリセットがあるが、正確な組み合わせは
バージョンによって増えることがあるので、実際の画面で確かめる。設定を切り替えると
デバイスの再構成（FPGA の書き直し）が入り、一瞬デバイスが切断されたように
見えることがある——実験中の波形は失われるので、切り替えは測定の合間に行う。

## AD2 ではどうするか

AD2 にも同じ Device Manager があるが、初期値と上限が違う。仕様
（Analog Discovery 2 リファレンスマニュアル 9.1〜9.4 節）によれば：

| 計器 | 既定のバッファ | 切り替え後の上限 | 引き換えに失うもの |
| --- | --- | --- | --- |
| Scope | 8k 点/ch | 16k 点/ch | Digital I/O のメモリを 0 にし、Wavegen のバッファも減らす |
| Wavegen | 4k 点/ch | 16k 点/ch | Digital I/O のメモリを 0 にし、Scope のバッファも減らす |
| Logic Analyzer | 4k 点/ch | 16k 点/ch | Scope・Wavegen のメモリを 0 にする |

AD2 は「ch 数を減らして 2 倍」という AD3 のような軽い切り替えではなく、**別の
計器（主に Digital I/O）を丸ごと諦める**ことでバッファを伸ばす。上限も
16k 点/ch と AD3（65,536 点）の 1/4。それでも「今の実験に要らない計器を削って、
使う計器に長い記録を回す」という考え方自体は AD2 でも AD3 でも同じ。

## 出典

自作。バッファ長の数値は Digilent の Analog Discovery 2 / 3 の公式仕様
（Horizontal System の節）による。
