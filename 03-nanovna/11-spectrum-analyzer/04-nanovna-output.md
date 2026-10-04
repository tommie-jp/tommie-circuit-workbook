---
book: nanovna
chapter: 11
id: 11-4
title: NanoVNA の出力を測る — 周波数と電力と高調波
tier: 100
source: 自作
board: —
device: SA
---

# 11-4 NanoVNA の出力を測る — 周波数と電力と高調波

いつも「測るための道具」として使っている NanoVNA の **CH0 (ポート 1)** の
出力そのものを、今度はスペアナで**見られる側**として測る。0-3 で「CH0 の
出力は 0 dBm より小さい」とだけ書いた値を、ここで具体的に確かめる。

## 回路図

CH0 の出力を 0-3 と同じ 20 dB パッド (43 Ω・11 Ω・43 Ω) で落として tinySA へ入れる。パッドを
通す理由は 0-3 と同じ — **CH0 の出力自体は小さいが、パッドを通すと反射も
一緒に減衰するので、tinySA 側の入力インピーダンスの乱れが CH0 に戻る影響も
減らせる**。

```circuit
title: 図1 CH0 の出力を 20 dB パッドで tinySA へ
parts:
  X1:
    type: device
    at: b1
    label: NanoVNA
    pins: [CH0, GND]
    turn: mirror
  P1: resistor b5 b7 43
  P2: resistor b7 d7 11
  P3: resistor b7 b9 43
  X2:
    type: device
    at: b11
    label: tinySA
    pins: [RF, GND]
  GV: ground d4
  GP: ground d7
  GM: ground d10
wires:
  - X1.CH0 -| b5
  - b9 -| X2.RF
  - X1.GND -| d4
  - X2.GND -| d10
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/circuit/04-nanovna-output.svg)

## 実体配線図

パッドは 10 MHz 以上を測るので、ブレッドボードではなく perfboard に端面 SMA で組む (0-3 の図2 と同じ基板、3-5)。
J1 に NanoVNA の CH0 のケーブルを、J2 に tinySA の RF のケーブルを付ける。

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の 20 dB パッド (CH0 から tinySA へ)
points:
  GND: l2
parts:
  J1: sma/female-edge i1 h0 j0
  P1: resistor i3 i6 43
  P2: resistor i8 k8 11
  P3: resistor i10 i13 43
  J2: sma/female-edge i24 j25
wires:
  - i1 -- i3
  - i6 -- i8
  - i8 -- i10
  - i13 -- i24
  - k8 -- l8 black
  - l8 -- GND black
  - j0 -- j2 black
  - j2 -- GND black
  - j25 -- j15 black
  - j15 -- l15 black
  - l15 -- l8 black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/perfboard/04-nanovna-output.svg)

CH0 の出力は 0 dBm 以下 (1 mW、約 6.3 mA 相当) なので、ユニバーサル基板に流れる電流は数 mA 以下で、1 穴 200 mA の範囲に収まる。
抵抗は 0.25 W 品でよい。

## 計器の設定

計器は tinySA Ultra。信号源は NanoVNA の CH0 で、AD3 とオシロは使わない (10 MHz 以上を見る題)。

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 開始・終了 | 1 MHz〜60 MHz (基本波 10 MHz から 5 次高調波の 50 MHz まで入る) | `FREQUENCY` → `START` / `STOP` |
| RBW | 100 kHz | `FREQUENCY` → `RBW` |
| 基準レベル | −20 dBm (パッド込みで信号が −20 dBm 前後に収まる想定) | `LEVEL` → `REF LEVEL` |

NanoVNA 側は CH0 の周波数を 10 MHz 固定 (CW) にする (機種のファームウェアで
「単一周波数を出し続ける」設定がなければ、掃引の Start = Stop = 10 MHz にする)。

## 見るべき値

**CH0 の出力は正弦波ではない。** NanoVNA の多くは Si5351 のようなクロック
生成 IC で作った方形波に近い信号を出しており、方形波は奇数次の高調波を
持つ (Analog Discovery の教科書の 4-2 と同じ理屈)。理想の方形波 (デューティ 50%) を
**仮定**した場合の、基本波との差の計算値:

| 次数 n | 周波数 (10 MHz 基準) | 基本波との差 (計算値、Analog Discovery の教科書の 4-2 と同じ式) |
| --- | --- | --- |
| 1 (基本波) | 10 MHz | 0 dB (基準) |
| 2 | 20 MHz | 理想の 50% デューティでは現れない (見えたらデューティが 50% からずれている証拠、11-3 と同じ考え方) |
| 3 | 30 MHz | −9.5 dB |
| 4 | 40 MHz | 理想では現れない |
| 5 | 50 MHz | −14.0 dB |

**この表はあくまで「方形波ならこうなる」という仮定の目安。** 実際の
NanoVNA の CH0 は、内部のローパスフィルタや、機種によっては帯域ごとに
出し方を変える回路 (1.5 GHz まで伸ばす H4 は、高い周波数では低い周波数の
高調波を使って作っている、と言われている — 詳しくは 9-10 で扱う) が入って
いるので、この計算どおりにはならないことが多い。

| 測る所 | 記録の仕方 |
| --- | --- |
| 基本波 (10 MHz) のレベル | 実測値を記録する (パッド込みで −20 dBm 前後になれば、パッド無しの CH0 は 0-3 の目安どおり 0 dBm 未満) |
| 2 次・3 次・4 次・5 次のレベル (基本波との差) | 実測して、上の理想表とどれだけ違うかを記録する。**理想よりずっと高調波が少なければ、内部フィルタが効いている**ということ |
| 掃引周波数を変えたとき (例えば 100 MHz、900 MHz) | 高調波の出方が変わるかを記録する。1.5 GHz に近い設定では、9-10 で扱う「高調波方式」の影響が出ることがある |

## 出典

自作。パッドの値と考え方は 0-3 と同じ。方形波の高調波の式は Analog Discovery の教科書の 4-2。
