---
book: fpga
chapter: 8
id: 8-5
title: ピンの割り当て — 制約ファイル
tier: 50
source: 自作
board: BB
device: FPGA
---

# 8-5 ピンの割り当て — 制約ファイル

> [!WARNING]
> **この題は実機で組んでいない。** 制約ファイルを書き換えて配置配線 (nextpnr) とビットストリーム作り (gowin_pack) を
> 通すところ、間違えたときに道具が何と言うかは手元の PC で確かめた。書き込みと AD3 での測定は実行していない。

Verilog のモジュールの入出力 (`clk` `led_n` など) は、名前だけで、FPGA のどのピンにつながるかを言わない。
それを決めるのが**制約ファイル**で、Gowin の FPGA では拡張子 `.cst` の文字のファイルに書く。
役は 5-3 で作る「ピンの対応の表」と同じ。Pico 2 では C の主ループが GPIO を読み書きして Verilog の入出力に渡すが、
FPGA では制約ファイルの 1 行がその配線になる。

この題では、8-4 の `top.cst` を読み、`blink_out` を IO38 から IO37 に移す。
Verilog は変えず、制約ファイルの 1 行だけを書き換える。

## 書き方

8-4 の `top.cst` をもう一度並べる。

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=UP;
IO_LOC "rst_n" 4;
IO_PORT "rst_n" PULL_MODE=UP;
IO_LOC "led_n" 10;
IO_PORT "led_n" PULL_MODE=UP DRIVE=8;
IO_LOC "blink_out" 38;
IO_PORT "blink_out" IO_TYPE=LVCMOS33 DRIVE=8;
```

| 行 | 意味 |
| --- | --- |
| `IO_LOC "名前" 番号;` | 最上位のモジュールの入出力 `名前` を、FPGA の `番号` のピンにつなぐ |
| `IO_PORT "名前" 設定…;` | そのピンの電気の設定 |
| `IO_TYPE=LVCMOS33` | 3.3 V の CMOS の信号として扱う |
| `PULL_MODE=UP` | FPGA の中でプルアップする。`DOWN` でプルダウン、`NONE` で無し |
| `DRIVE=8` | 出力が流せる電流を 8 mA にする |

- 名前は Verilog の入出力の名前そのまま。幅のある入出力はビットごとに書く (`"led[0]"`)
- `IO_TYPE` `PULL_MODE` `DRIVE` の 3 つは、Sipeed の例 (TangNano-9K-example) の制約ファイルに出てくる設定。
  例の中では `LVCMOS33` だけ、`PULL_MODE` は `UP` と `NONE`、`DRIVE` は `8` と `24` が使われていた。ほかの値は Gowin の資料で確かめてから使う
- Sipeed の例の制約ファイルの頭には `Part Number: GW1NR-LV9QN88PC6/I5`・`Device: GW1NR-9C` とある。8-4 の nextpnr に渡した型番と同じ

## 番号は FPGA のピンの番号

`IO_LOC` に書く番号は、**FPGA のチップ (QN88 という 88 ピンの形) のピンの番号**である。
ボードのヘッダの番号 (`01`〜`48`) ではない。この本のフェンスがピンを `IO38` と呼ぶのは、この FPGA のピンの番号を名前にしたから (8-3)。

| ヘッダの番号 | 名前 (FPGA のピンの番号) | ブレッドボードの穴 (`@ b1` のとき) | 電圧 | この本での使い道 |
| --- | --- | --- | --- | --- |
| 1 | IO38 | j1 | 3.3 V | 8-4 の `blink_out` |
| 2 | IO37 | j2 | 3.3 V | この題で `blink_out` を移す先 |
| 26 | GND | a23 | — | GND |
| 40〜47 | IO79〜IO86 | a2〜a9 | **1.8 V** | 使わない (下の節) |
| — | 52 (クロック)・3 と 4 (押しボタン)・10・11・13〜16 (LED) | ボードの上 | — | ヘッダには出ていない |

ヘッダに出ていないピンの番号 (52・3・4・10〜16) は Sipeed の例の制約ファイルから取った。
ボードに載っている LED は 6 個で、例の `led[0]`〜`led[5]` が 10・11・13・14・15・16 番。

## IO38 から IO37 に移す

`top.cst` の `blink_out` の 1 行だけを 37 に書き換えた `a37.cst` を作り、8-4 の 2 から 4 の手順をやり直す。合成 (1) はやり直さなくてよい。
制約ファイルは配置配線から先にしか使わないからである。

```bash
sed 's/"blink_out" 38/"blink_out" 37/' top.cst > a37.cst
nextpnr-himbaechel --json top.json --write pnr37.json \
    --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C \
    --vopt cst=a37.cst --freq 27
gowin_pack -d GW1N-9C -o top37.fs pnr37.json
openFPGALoader -b tangnano9k top37.fs
```

配置配線とビットストリーム作りは通った (書き込みは未実行)。
nextpnr が `blink_out` の出力のバッファを置いた場所を `pnr37.json` で読むと、
8-4 では `X30Y28/IOBB`、この題では `X30Y28/IOBA` だった。38 番と 37 番は FPGA の中で隣り合う入出力の組で、制約ファイルの 1 行で置き場所が変わったことが分かる。

書き込んだら、点滅は DIO0 (IO38) から消えて DIO1 (IO37) に移る。配線は 8-3 のまま、1 本も挿し直さない。

## 間違えたときに道具が言うこと

制約ファイルを書き間違えたときに nextpnr (0.11.1-54) が何と言うかを、わざと間違えて確かめた。

| 間違い | nextpnr の言うこと | 止まるか |
| --- | --- | --- |
| `blink_out` の行を消した | `ERROR: Unconstrained IO:blink_out_OBUF_O` | 止まる |
| 無い番号 (200) を書いた | `ERROR: Pin 200 not found (pin# style)` | 止まる |
| 2 つの出力を同じピン (10) にした | `ERROR: Can't place blink_out_OBUF_O at X0Y14/IOBA because it's already taken by led_n_OBUF_O` | 止まる |
| Verilog に無い名前 (`nosuch`) の行を足した | `Info: Cell nosuch not found` (エラーでも警告でもない) | **止まらない** |
| `blink_out` を 1.8 V の 79 番に `LVCMOS33` で置いた | 何も言わない。gowin_pack も `.fs` を作った | **止まらない** |

- 名前の綴りを間違えると、その行は黙って無視され、本当の入出力は「割り当てが無い」のエラーになる。エラーの名前と制約ファイルの名前を見比べる
- **1.8 V のピンに 3.3 V の設定を書いても、道具は止めない。** IO79〜IO86 に 3.3 V の回路をつなぐと壊すおそれがある (0-3)。
  ピンを選ぶときは、上の表と 0-3 の表を自分で見る

## 回路図

接続は 8-3 と同じ。この題で読むのは DIO1 (IO37)。

```circuit
title: 図1 制約ファイルを書き換えると点滅は IO37 (DIO1) に移る。接続は 8-3 と同じ
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

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/08-fpga-board/circuit/05-constraints.svg)

## 部品表

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| U1 | Sipeed Tang Nano 9K (GW1NR-9) | 1 | FPGA ボード。USB-C から給電と書き込み |
| — | ブレッドボード (half、30 列) | 1 | |
| — | ジャンパ線 | 5 本 | |
| AD | Analog Discovery 3 | 1 | Logic で IO37 を測る |

電源は教科書の既定の 5 V ではなく **3.3 V** (FPGA のピン)。FPGA のピンに 5 V を入れると壊れるため (0-3)。

## 実体配線図

```bread
title: 図2 配線は 8-3 のまま。IO37 (j2) を DIO1 で読む
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

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/08-fpga-board/breadboard/05-constraints.svg)

- IO37 は 2 番ピンで、下の列の 2 列 (j2)。8-3 で黄の線を挿してある
- 信号は 1 Hz で、ブレッドボードの範囲 (3 MHz 以下) に収まる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO1 を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 | 250 ms/div (窓 2.5 s)。8-4 と同じ |
| 標本化 | 1 kS/s |
| トリガ | DIO1 の立ち上がり |

8-4 の図4 と同じ設定で、レーンだけを DIO0 から DIO1 に替えた。

## Logic に見えるはずの画面

```logic
title: 図3 点滅は DIO1 (IO37) に移る。周期は 8-4 と同じ 1 s
device: ad3
time: 250ms/div
start: -250ms
sample: 1kHz
signals:
  blink_out: dio1 clock 1Hz
cursors: [250ms, 1250ms]
trigger: blink_out rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/08-fpga-board/logic/05-constraints.svg)

IO38 (DIO0) は、書き換えたあとは回路から外れる。外れたピンの電圧は FPGA の既定で決まり、この本では確かめていないので図に載せない。

## 見るべき値

計算値と道具の結果。実機で測っていない。

| 項目 | 見るべき値 | どこで得たか |
| --- | --- | --- |
| 点滅が出るピン | DIO1 (IO37) | `a37.cst` の 1 行 |
| 点滅の周期 (ΔX) | 1.000 s (計算値) | 8-4 と同じ。制約ファイルは周期を変えない |
| `blink_out` のバッファの置き場所 | `X30Y28/IOBB` (38 番) → `X30Y28/IOBA` (37 番) | nextpnr の出力の `pnr.json` |
| 合成のやり直し | 要らない | 制約ファイルは配置配線から使う |

実機で書き込んだら、DIO0 と DIO1 を両方 Enable にして、点滅が DIO1 だけに出ることを確かめる。

## 出典

自作。

- 制約ファイルの書き方 (`IO_LOC` `IO_PORT` と設定の値)、ボードの上のピンの番号: Sipeed の [TangNano-9K-example](https://github.com/sipeed/TangNano-9K-example) の制約ファイル (`led/src/9K_LED_project.cst`・`uart/src/top.cst` ほか)
- 1.8 V のピン (BANK3 の IO79〜IO86): Sipeed の [Tang Nano 9K のページ](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html) のピン配置図
- 道具の言うこと: 手元の nextpnr-himbaechel (nextpnr-0.11.1-54) と gowin_pack (OSS CAD Suite 2026-10-10) で実行した
