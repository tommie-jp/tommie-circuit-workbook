---
book: fpga
chapter: 8
id: 8-3
title: ボードと書き込みの道具をつなぐ
tier: 50
source: 自作
board: BB
device: FPGA
---

# 8-3 ボードと書き込みの道具をつなぐ

> [!WARNING]
> **この題は実機で組んでいない。** 道具 (OSS CAD Suite) を入れて版を表示するところまでは手元の PC で確かめたが、
> Tang Nano 9K を USB でつないで見つけるところ (`--detect`) は実行していない。

第 8 章から実物の FPGA を使う。最初に、Tang Nano 9K を PC とブレッドボードにつなぎ、
書き込みの道具がボードを見つけるところまでを確かめる。
回路を書き込むのは次の 8-4 で、この題では何も書き込まない。

用意する物は 3 つ。

| 物 | 役 |
| --- | --- |
| Tang Nano 9K | FPGA ボード。USB-C の口と、USB から書き込む回路 (USB-JTAG) が載っている (8-2) |
| USB-C のケーブル | PC とボードをつなぐ。給電と書き込みを 1 本で兼ねる。充電専用のケーブルは使えない |
| OSS CAD Suite | 開いた道具の詰め合わせ。合成 (yosys)・配置配線 (nextpnr)・ビットストリーム作り (Apicula の `gowin_pack`)・書き込み (openFPGALoader) が入っている |

Gowin の道具 (Gowin EDA) でも同じことができる。この本は、第 0〜7 章の Verilator と同じく
コマンドで動かせる開いた道具で進める (8-2 の「開いた道具」の欄)。

## 道具を入れる

OSS CAD Suite は、YosysHQ が日付ごとに出している tgz をほどくだけで使える。
手元では Linux (x64) 用の 2026-10-10 の版を入れた。

```bash
# https://github.com/YosysHQ/oss-cad-suite-build/releases から自分の OS 用の tgz を取る
tar xzf oss-cad-suite-linux-x64-20261010.tgz
source oss-cad-suite/environment      # この端末の PATH に道具を足す
```

入ったかどうかは、版を出して確かめる。手元の結果を並べる。

```bash
yosys -V
nextpnr-himbaechel --version
openFPGALoader --Version
```

```text
Yosys 0.69+274 (git sha1 7513f8df8, Release, Clang /usr/bin/clang++ 21.1.8)
"nextpnr-himbaechel" -- Next Generation Place and Route (Version nextpnr-0.11.1-54-g861c57be)
openFPGALoader v1.1.1
```

openFPGALoader が Tang Nano 9K を知っているかは、ボードの一覧で確かめる。

```bash
openFPGALoader --list-boards | grep tangnano9k
openFPGALoader --list-fpga | grep GW1N
```

```text
tangnano9k                 ft2232             Undefined
0x0100481b  Gowin         GW1N            GW1N(R)-9C
```

ボードの名前は `tangnano9k`。ボードの上の書き込みの回路は、openFPGALoader からは `ft2232` (FTDI の USB の石) として扱われる。
Tang Nano 9K の FPGA (GW1NR-9C) は、一覧の `GW1N(R)-9C` の行に当たる。

- Linux では、一般のユーザーが USB の書き込み器を開けるように udev の規則を入れる。
  openFPGALoader の配布物にある `99-openfpgaloader.rules` を `/etc/udev/rules.d/` に写す (手順は openFPGALoader の文書)
- Windows の WSL2 から使うときは、USB の機器を WSL2 に渡す設定 (usbipd-win) が要る。この題では確かめていない

## ボードを見つける

USB-C のケーブルでボードを PC につなぎ、次の 2 つを打つ。

```bash
openFPGALoader --scan-usb
openFPGALoader -b tangnano9k --detect
```

- `--scan-usb` は、PC につながっている書き込み器を並べる。ボードをつないでいないと `No USB devices found` と出る (手元の PC で確かめた)
- `--detect` は、書き込み器を通して FPGA の型番 (IDCODE) を読む。`GW1N(R)-9C` の名前が出れば、ボードと道具がつながっている

**`--detect` は実行していない。** 出る行の形は、つないだときに書き加える。
見つからないときは、ケーブル (充電専用でないか)、udev の規則、WSL2 なら usbipd の設定を順に疑う。

## 回路図

この題ではボードに何も書き込まないので、回路は AD3 との接続だけになる。
8-4・8-5・8-7 は、この接続のまま測る。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 Tang Nano 9K の IO38・IO37 を AD3 の DIO0・DIO1 で読む。GND は共通
parts:
  AD:
    type: device
    at: 1,3.8
    label: AD3
    pins: [DIO0, DIO1, GND]
    turn: mirror
  U1: tang-nano-9k 8,6
  G1: ground 3.5,4.8
  G2: ground 10.5,9
wires:
  - AD.DIO0 -| 5,3.24
  - U1.IO38 |- 5,3.24
  - AD.DIO1 -| 5.5,3.48
  - U1.IO37 |- 5.5,3.48
  - AD.GND -| 3.5,4.8
  - U1.GND -| 10.5,9
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/08-fpga-board/circuit/03-connect-board.svg)

- U1 のピンの名前は、Sipeed のピン配置図の FPGA のピン番号に `IO` を付けたもの (`IO38` は FPGA の 38 番ピン)。
  左の数 (`01`〜`48`) はヘッダのピンの番号で、FPGA のピン番号とは別である
- IO38 と IO37 は 3.3 V のピン。右の列の `IO79`〜`IO86` は 1.8 V なので、この本の測る線には使わない (0-3)
- `5V` (31 番) と `3V3` (25 番) は電源のピン。この題では何もつながない

## 部品表

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Sipeed Tang Nano 9K (GW1NR-9) | 1 | FPGA ボード。USB-C から給電 |
| — | ブレッドボード (half、30 列) | 1 | |
| — | ジャンパ線 | 5 本 | GND の 3 本と DIO の 2 本 |
| — | USB-C のケーブル (データの通る物) | 1 | PC とボード |
| AD | Analog Discovery 3 | 1 | Logic で IO38・IO37 を読む (8-4 から) |

電源は教科書の既定の 5 V ではなく **3.3 V** (FPGA のピン)。FPGA のピンに 5 V を入れると壊れるため (0-3)。
ブレッドボードには電源を配らない。ボードは USB-C の 5 V で動き、ボードの上で 3.3 V を作る。

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図2 Tang Nano 9K を溝をまたいで挿し、AD3 をつなぐ
board: half
parts:
  U1: tang-nano-9k @ b1
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO0, DIO1, GND]
wires:
  - a23 -- -t23 black
  - -t29 -- -b29 black
  - AD.GND -- -b27 black
  - AD.DIO0 -- j1 green
  - AD.DIO1 -- j2 yellow
notes:
  - text: 給電は Tang Nano 9K の USB-C (5 V)。電源レールは GND (−) だけ使う
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/08-fpga-board/breadboard/03-connect-board.svg)

- Tang Nano 9K は 2 列のヘッダの間が 9 ピッチ (22.8 mm) ある。ブレッドボードの溝をまたいで、b 行と i 行に挿す (`@ b1`)。
  向かいに挿せる組は a↔h・b↔i・c↔j の 3 つで、b↔i なら外側に 1 穴 (a 行・j 行) が残る
- 1〜24 番のピンが下の列 (i 行)、25〜48 番が上の列 (b 行)。USB-C は 1 番ピンの側 (左) にある
- 線は外側の 1 穴から取る。c〜h 行の穴はボードの基板の下になるので使わない
- GND (26 番) は上の列の 23 列。a23 から上の − レールへ下ろし、右端 (29 列) で上と下の − レールをつなぐ
- 線の色: 黒は GND だけ。緑と黄は AD3 の DIO。赤は使わない (+ の電源をブレッドボードに配らないため)
- ピンヘッダの付いていない品は、先にヘッダを半田付けする。ヘッダが曲がっていると 2 列が同時に入らない

## 計器の設定

この題では何も書き込まないので、ピンの出力は決まっていない。Logic の図は 8-4 から載せる。
ここでは配線を確かめるだけにする。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0・DIO1 を Enable。DIO は 3.3 V。GND を共通にする (0-4) |

## 見るべき値

| 確かめること | 見るべき値 | 分かること |
| --- | --- | --- |
| `openFPGALoader --scan-usb` | 書き込み器が 1 つ出る (目安) | USB のケーブルと PC の設定が通っている |
| `openFPGALoader -b tangnano9k --detect` | `GW1N(R)-9C` の名前 (目安。未実行) | 書き込み器の先に FPGA がいる |
| GND の線 | テスタで AD3 の GND と a23 の間が導通 (目安) | 8-4 からの測定の基準が共通になっている |

実機でつないだら、`--detect` の出力をこの表に書き加える。

## 出典

自作。

- Tang Nano 9K のピン配置・列の間隔・1.8 V のピン: Sipeed の [Tang Nano 9K のページ](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html) のピン配置図と寸法図
- OSS CAD Suite: [YosysHQ/oss-cad-suite-build](https://github.com/YosysHQ/oss-cad-suite-build) の Releases
- openFPGALoader のボード名と udev の規則: [openFPGALoader](https://github.com/trabucayre/openFPGALoader) のリポジトリ (`99-openfpgaloader.rules`) と `--list-boards` の出力
- 開いた道具が Tang Nano 9K に対応していること: [Apicula](https://github.com/YosysHQ/apicula) の README
