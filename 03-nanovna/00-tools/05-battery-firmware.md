---
book: nanovna
chapter: 0
id: 0-5
title: 電池・充電・ファームウェアの更新
tier: 100
source: 自作 (ファームウェアの書き込みは NanoVNA-D (DiSlord 版) の README)
board: —
device: H4
---

# 0-5 電池・充電・ファームウェアの更新

NanoVNA-H4 は**リチウムポリマー電池 1 セル** (1950 mAh) を内蔵していて、
USB につなぐと充電される。ファームウェアは USB から書き換えられる。
どちらも測る前の準備で、**更新の後は校正が消えることがある**ので、最後に
検査片 (100 Ω) を測って元どおり測れることを確かめる。

## 電池と充電

| 項目 | 値 | 注意 |
| --- | --- | --- |
| 電池 | リチウムポリマー 1 セル、1950 mAh | 満充電 4.2 V、公称 3.7 V |
| 充電 | USB Type-C に 5 V (PC か USB の AC アダプタ) | 充電しながら測ってもよい |
| 電圧の見方 | 画面の電池の印。数字は CONFIG → VERSION の画面の `Batt:` | 表示は目安。VBAT OFFSET で補正できる |
| 充電の電流 | 最大 1 A (販売店の仕様) | 空からの充電には 2〜3 時間かかる (目安) |
| 使える時間 | 1950 mAh ÷ 電池から流れる電流 | 動作電流は USB 電流計で測る |

販売店の仕様では、動作の電力は USB 5 V で 200 mA (1 W)。電池 3.7 V から
同じ 1 W を取ると 1 W / 3.7 V ≈ 0.27 A で、使える時間は
1950 mAh / 270 mA ≈ **7 時間** (目安。画面の明るさや掃引の速さで変わるので、
自分の機体で測った電流で計算し直す)。

- 電池が切れかけた状態で校正しない。**充電してから校正し、校正と測定を
  続けて行う** (校正は測ったときの状態でしか正しくない。温度と時間の話は 1-9)
- 長くしまうときは満充電でも空でもなく、半分くらい残してしまう。
  空のまま何か月も置くと、リチウムポリマー電池は傷む
- 膨らんだ電池は使わない。ケースが浮いてきたら交換する

## ファームウェアの更新

H4 の中のマイコン (STM32) は、**DFU** (Device Firmware Update) という書き込みの
モードを持つ。DFU はマイコンの ROM にあるので、書き込みに失敗しても
もう一度 DFU に入れば書き直せる。

| # | 手順 | 操作 |
| --- | --- | --- |
| 1 | 今の版を控える | CONFIG → VERSION。版と日付をメモする (2-10 の記録にも書く) |
| 2 | 校正を控える | 使っているスロットの範囲と点数をメモする (1-6)。SD カードがあれば SD CARD → SAVE CALIBRATION |
| 3 | 充電しておく | 途中で電池が切れないように |
| 4 | DFU に入る | CONFIG → DFU → RESET AND ENTER DFU。または**ジョグスイッチを押しながら電源を入れる**。画面は DFU の表示になる |
| 5 | PC から書き込む | `dfu-util -d 0483:df11 -a 0 -s 0x08000000:leave -D H4.bin` (H4.bin は配布されている H4 用のファイル) |
| 6 | 起動を確かめる | CONFIG → VERSION で新しい版になったこと |
| 7 | 校正し直す | 1-1 の 9 手順。スロットに保存 (1-6) |
| 8 | 検査片を測る | 下の 100 Ω。値が「見るべき値」どおりなら更新は終わり |

- 書き込みの途中に `Device's firmware is corrupt` という行が出ることがある。
  DFU の状態を消す前の決まった表示で、その後に `No error condition is present`
  が出れば問題ない
- **H4 用のファイルを使う。** NanoVNA-H (2.8 インチ) 用の `H.bin` を H4 に
  書かない (画面の大きさも中身も違う)
- 版によってメニューの名前や場所が変わる。この教科書のメニューの名前は
  DiSlord 版 (NanoVNA-D) のもの (版の違いは 2-16)

## 回路図

検査片は SMA オスの先に 100 Ω (1/4 W の金属皮膜、E24) を 1 本、中心導体と
外皮の間に付けたもの。足は短く切る。

```circuit
title: 図1 CH0 に 100 Ω の検査片をつなぐ
parts:
  M1:
    type: device
    at: b2
    label: NanoVNA
    pins: [CH0, CH1]
    turn: mirror
  R1: resistor a5i0i0 c5i0i0 100
  G1: ground c5i0i0
wires:
  - M1.CH0 -| a5i0i0
notes:
  - text c5f5 blue: 検査片 (SMA の先)
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/circuit/05-battery-firmware.svg)

## 実体配線図

```perfboard
board:
  size: 7x5cm
  slots: on
title: 図2 perfboard の検査片 (100 Ω を端面 SMA の先に付ける)
points:
  GND: l2
parts:
  J1: sma/female-edge i1 h0 j0
  R1: resistor i5 l5 100
wires:
  - i1 -- i5
  - l5 -- GND black
  - j0 -- j2 black
  - j2 -- GND black
```

![ユニバーサル基板の実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/perfboard/05-battery-firmware.svg)

J1 のねじ (SMA) に NanoVNA の CH0 のケーブルをつなぐ。R1 (100 Ω、E24 にある 1 本) は中心導体から GND へ立てて付ける。
板に流れる電流は、NanoVNA の出力が 0 dBm 以下なので数 mA 以下で、板の範囲 (1 穴 200 mA) に収まる。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜30 MHz (抵抗の足のインダクタンスが効かない低い範囲) |
| 点数 | 101 |
| 校正 | 更新の後に CH0 で SOLT し直す (1-1) |
| 表示 | S11 の Log Mag、S11 の Smith チャート |

```vna
device: h4
sweep: 1M-30M 101
title: 図3 更新の後の検査片 100 Ω は −9.54 dB (SWR 2.00)
dut:
  - series R 100
  - short
traces:
  - S11 logmag
  - S11 smith
markers:
  - 10M
notes:
  - text 15M -25dB: 全域で −9.54 dB のまま平ら
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/00-tools/vna/05-battery-firmware.svg)

- 100 Ω の反射係数は Γ = (100 − 50) / (100 + 50) = 1/3。20 log₁₀(1/3) = **−9.54 dB**、
  SWR = (1 + 1/3) / (1 − 1/3) = **2.00**
- Smith では真ん中と右端の間、実軸の上の 1 点 (100 Ω) に留まる
- 更新の前にも同じ検査片を測って控えておくと、前後の比較になる

## 見るべき値

| 見る所 | 値 | 分かること |
| --- | --- | --- |
| 10 MHz の S11 Log Mag | −9.54 dB (計算値) | 更新と再校正の後も正しく測れている |
| 10 MHz の SWR | 2.00 (計算値) | Log Mag と同じことを SWR で言った値 |
| 10 MHz の Z (Smith の読み値) | 100.0 Ω + j0.0 Ω (計算値) | 抵抗の値そのものが読める |
| 1〜30 MHz の S11 の変化 | 平ら (計算値) | 足の短い抵抗は 30 MHz まで抵抗のまま |
| VERSION の版 | 書き込んだ版 | 更新できた |

**SWR が 2.00 から大きくずれるなら、まず校正を疑う** (更新でスロットが消えて
いないか、校正の範囲が合っているか)。100 Ω の値そのものはテスターで確かめられる
(Load の 50 Ω と同じやり方、1-8)。

## 出典

自作。DFU の入り方と `dfu-util` の書き方は
[NanoVNA-D (DiSlord 版) の README](https://github.com/DiSlord/NanoVNA-D)。
電池の容量と動作の電力 (USB 5 V 200 mA、充電は最大 1 A) は販売店の仕様
([R&L Electronics の NanoVNA-H4 の頁](https://www.randl.com/index.php?main_page=product_info&products_id=75145))。
