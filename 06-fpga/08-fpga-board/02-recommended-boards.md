---
book: fpga
chapter: 8
id: 8-2
title: おすすめの FPGA ボード — 規模・出来ること・価格・情報の多さで比べる
tier: 50
source: 自作 (値は各社・各店・Sipeed・Digilent・Lattice の公開ページ。調べた日は 2026-10-05)
board: —
device: FPGA
---

# 8-2 おすすめの FPGA ボード — 規模・出来ること・価格・情報の多さで比べる

第 8 章で使うボードを比べる。この本の図と手順は **Sipeed Tang Nano 9K** で書く。
ほかのボードでも、ピンの割り当て (8-5) とクロックの周波数を変えれば進める。

実体配線図・Analog Discovery 3・`logic` の図は入れない (**組まない題**。信号も測らない)。

値はすべて **2026-10-05** に調べた。価格は動くので「Pico 2 の何倍か」を見る。
Pico 2 は秋月で 990 円 (税込、商品コード 129604)。

## 規模と載っている物

LUT の数は**メーカーで数え方が違う**: Gowin と Lattice は 4 入力の LUT4、
AMD (Xilinx) の Artix-7 は 6 入力の LUT6 で、LUT6 のほうが 1 個で多くの論理を持つ。

| ボード | FPGA と規模 | 載っている物 |
| --- | --- | --- |
| Sipeed Tang Nano 9K (この本の標準) | Gowin GW1NR-9。LUT4 8,640・FF 6,480・ブロック RAM 468 kbit・PLL 2 | 27 MHz の発振器、LED 6、ボタン 2、HDMI、SPI フラッシュ 32 Mbit、PSRAM 64 Mbit、TF カード、USB-JTAG と UART を内蔵 |
| Sipeed Tang Nano 20K | Gowin GW2AR-18。LUT4 20,736・FF 15,552・ブロック RAM 828 kbit | SDRAM 64 Mbit、HDMI、LED 6 と RGB LED 1、ボタン 2、TF カード、フラッシュ 64 Mbit |
| Sipeed Tang Primer 25K (キット) | Gowin GW5A-25。LUT4 23,040・ブロック RAM 1,008 kbit・PLL 6 | コアボードとドックのキット。PMOD 3、USB-A、SDRAM 用の 2×20 ピン、ボタン 2 |
| Gowin RUNBER | Gowin GW1N-UV4。LUT の数は未確認 | 12 MHz の発振器、7 セグ、LED、RGB LED、DIP スイッチ、押しボタン |
| Fomu (Lattice iCE40UP5K) | iCE40UP5K。LUT 5,280 (iCEBreaker のページの値。同じチップ) | 48 MHz の発振器、フラッシュ 2 MB、USB に直に挿す形、タッチパッド 4、RGB LED 1。ピンが少なく、配線の実験には向かない |
| iCEBreaker (Lattice iCE40UP5K) | 同上。ブロック RAM 120 kbit + 1 Mbit | 書き込み器と USB-UART を内蔵 |
| Terasic DE10-Lite | Intel (Altera) MAX 10 10M50DAF484C7G。約 50 k LE | USB-Blaster 内蔵、SDRAM、加速度センサー、VGA、2×20 の GPIO、Arduino 用ヘッダ。スイッチと 7 セグの数は未確認 |
| Digilent Basys 3 | AMD Artix-7 XC7A35T。LUT6 20,800 (5,200 スライス × 4)・ロジックセル 33,280・ブロック RAM 1,800 kbit | スイッチ 16、LED 16、ボタン 5、7 セグ 4 桁、VGA、Pmod 4、USB HID、USB-UART |
| Digilent Arty A7 (秋月の品) | AMD Artix-7 XC7A100T。LUT の数は未確認 | Pmod・Arduino・chipKIT 用のヘッダ。DDR3 とイーサネットの有無は未確認 |

## 価格

商品ページの税込みの値 (DigiKey はページ表示の税抜 24,954 円 + 10 % = 27,449 円)。

| ボード | 店 (商品コード) | 税込み | Pico 2 の何倍 |
| --- | --- | --- | --- |
| Tang Nano 9K | 秋月電子通商 (117448) | 3,780 円 | 3.8 倍 |
| Gowin RUNBER | 秋月電子通商 (116723) | 4,280 円 | 4.3 倍 |
| Fomu PVT1 | スイッチサイエンス (6380) | 5,692 円 | 5.7 倍 |
| Tang Nano 20K | 秋月電子通商 (130974) | 6,280 円 | 6.3 倍 |
| Tang Primer 25K キット | 秋月電子通商 (129610) | 6,280 円 | 6.3 倍 |
| DE10-Lite | DigiKey (P0466) | 27,449 円 | 27.7 倍 |
| Basys 3 | 秋月電子通商 (108634) | 35,100 円 | 35.5 倍 |
| Arty A7 (XC7A100T) | 秋月電子通商 (113488) | 53,710 円 | 54.3 倍 |
| iCEBreaker | 国内の店は未確認 (海外は Crowd Supply で 69 ドル、SparkFun の 84.95 ドルは販売終了) | 未確認 | 未確認 |

秋月の在庫は Tang Nano 9K が 128 個、20K が 71 個、Primer 25K が 41 個。スイッチサイエンスの Tang Primer (旧型) は売り切れ。
**Tang 系の 3 機種 (3,780 円〜6,280 円) は、AMD と Intel の大学向けボードの 1/4 〜 1/14 の値段**。

## 情報の多さ

どれも 1 回だけ数えた**目安**。

- **日本語の記事**: Qiita の API (`/api/v2/items?query="ボード名"`) の `Total-Count`。Zenn (語を絞れない) とブログは数えていない
- **GitHub のリポジトリ**: 検索 API (`search/repositories`、`ボード名 in:name,description`) の `total_count`。別の物も混じる
- **道具**: 開いた道具は nextpnr と Apicula の README の一覧、メーカーの道具 (無料か) は各社のページ

| ボード | Qiita の記事 | GitHub のリポジトリ | Yosys / nextpnr | メーカーの道具 |
| --- | --- | --- | --- | --- |
| Tang Nano 9K | 29 | 399 | 対応 (Apicula の一覧) | Gowin EDA (Standard 版と Education 版)。無償の条件は登録後にしか見えず未確認 |
| Tang Nano 20K | 4 | 227 | 対応 (同上) | 同上 |
| Tang Primer 25K | 8 | 46 | nextpnr は GW5A 系 (Arora V) を挙げる。Apicula のボードの一覧には無い (未確認) | 同上 (Gowin EDA v1.9.9Beta-4 以降が要る) |
| iCEBreaker | 5 (iCEstick は 0) | 2,658 (iCEstick は 148。多すぎて目安にならない) | 対応 (nextpnr の iCE40 は安定版) | iCEcube2。趣味や教育者には Lattice に頼むと無償の許可が出る |
| DE10-Lite | 10 | 739 | nextpnr の一覧に無い | Quartus の無償版かは未確認 |
| Basys 3 | 15 | 1,930 (Basys3 は 1,582) | nextpnr は Xilinx 7 系を**実験段階**として載せる | Vivado WebPACK は無償 (Digilent の資料) |
| Arty A7 | 29 | 301 | 同上 | 未確認 (Vivado は同じ系列) |

- **開いた道具をそのまま使えるのは Gowin (9K・20K) と Lattice iCE40**
- Tang Nano 9K の Qiita の記事は Tang 系で最多だが、「日本語で調べれば出る」程度
- GitHub の数が多いのは AMD と Intel の大学向けボード。ただし 1 台 3〜5 万円

## この本が Tang Nano 9K を選ぶ理由

1. **価格**: Pico 2 の 3.8 倍。第 4〜7 章の Pico 2 に足す出費が小さい
2. **規模**: カウンタ・UART・TD4 のような小さな CPU は載る (8-8 で実測)
3. **開いた道具**: Yosys と nextpnr (Apicula) で合成から書き込みまで通せる
4. **TD4 の元との縁**: Soft-FPGA-TD4 の元の [simpleTD4](https://github.com/asfdrwe/simpleTD4) は
   初代の Tang Nano (GW1N-1) で動かす手順を README に書いている。同じ Gowin なので Verilog はそのまま載る (8-22)

欠点: **BANK3 (右の列の IO79〜IO86) は 1.8 V** で、ほかのピンは 3.3 V。5 V は不可 (0-3・8-5)。

## 見るべき値

買う前に確かめる。

| 確かめること | どこを見るか | 目安 |
| --- | --- | --- |
| ピンの電圧 | 販売店・メーカーの仕様。BANK ごとの電圧 | 3.3 V (1.8 V のバンクがあれば印を付ける) |
| 書き込みの道具 | 開いた道具 (Yosys・nextpnr) が対応するか | 一覧に載るチップ |
| ピンの割り当て | ボードの回路図とピン配置図 | 8-5 の制約ファイルに写せる |
| 国内で買えるか | 店の在庫と税込みの値 | 在庫が 1 個以上 |

## シミュレーションでの確かめ (対象外)

Verilog が無い。LUT・FF の数・値段・付属品はメーカーと店の資料の値で、シミュレーションでは確かめられない。

## 出典

自作。値は次のページで読んだ。

- 価格・在庫: [秋月電子通商](https://akizukidenshi.com/) の商品ページ
  ([Tang Nano 9K](https://akizukidenshi.com/catalog/g/g117448/)・
  [Tang Nano 20K](https://akizukidenshi.com/catalog/g/g130974/)・
  [Tang Primer 25K キット](https://akizukidenshi.com/catalog/g/g129610/)・
  [RUNBER](https://akizukidenshi.com/catalog/g/g116723/)・
  [Basys 3](https://akizukidenshi.com/catalog/g/g108634/)・
  [Arty A7](https://akizukidenshi.com/catalog/g/g113488/))、
  [スイッチサイエンスの Fomu](https://www.switch-science.com/products/6380)、
  [DigiKey の DE10-Lite (P0466)](https://www.digikey.jp/en/products/detail/terasic-inc/P0466/6230089)
- 仕様: [Sipeed Tang Nano 9K](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html)・
  [Tang Nano 20K](https://wiki.sipeed.com/hardware/en/tang/tang-nano-20k/nano-20k.html)・
  [Tang Primer 25K](https://wiki.sipeed.com/hardware/en/tang/tang-primer-25k/primer-25k.html) の wiki、
  [Digilent の Basys 3 の資料](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Basys-3_Datasheet_0525.pdf)
- 開いた道具: [nextpnr](https://github.com/YosysHQ/nextpnr) と
  [Apicula](https://github.com/YosysHQ/apicula) の README
- メーカーの道具: [Lattice iCEcube2](https://www.latticesemi.com/icecube2)、
  [Gowin のダウンロードページ](https://www.gowinsemi.com/en/support/download_eda/)
- 記事数: [Qiita API v2](https://qiita.com/api/v2/docs)、リポジトリ数: [GitHub の検索 API](https://docs.github.com/ja/rest/search/search)
