---
book: fpga
chapter: 12
id: 12-2
title: リバーシを UART で PC と対戦させる
tier: 300
source: 自作。プロトコルは tommie-jp/reversi-uart-protocol v0.2 (CC BY 4.0)。Pico SDK でのビルドは tommie-jp/Soft-FPGA-Reversi (MIT) に倣った
board: BB
device: PICO
---

# 12-2 リバーシを UART で PC と対戦させる

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までビルドし、RP2350 のエミュレータ (picoemu) に載せて
> UART0 越しに 200 局を打たせた。PC では同じプログラムを替え玉の stdio で動かし、PC の側のプログラムと 200 局を打たせた。
> 実物の Pico 2 への書き込み、USB と Debug Probe での PC との対局、AD3 での測定はしていない。
> picoemu は USB を外に出さないので、USB の道は picoemu でも確かめていない。
> 「見るべき値」の時間の欄は、測って書く。

12-1 で作ったリバーシのアクセラレータを Pico 2 の Soft-FPGA に載せ、**PC と対戦させる**。
PC とは Pico 2 の **USB** (仮想のシリアルポート) でつなぐ。USB ケーブル 1 本で給電と書き込みと対局ができ、ほかの機器は要らない。
Raspberry Pi Debug Probe を持っていれば、Pico 2 の UART0 (GP0・GP1) にもつなげる。同じ `.uf2` のまま、どちらからでも同じに話せる。
PC からは「黒で始めて」「相手は d3 に打った」と 1 行ずつ送り、Pico 2 は自分の手を 1 行で返す。
行の決まりは、自作の CPU を PC と対戦させるために決められた [リバーシ UART プロトコル](https://github.com/tommie-jp/reversi-uart-protocol) (v0.2) に従う。
同じ決まりを話す物どうしなら、相手が PC のソフトでも、別の人が FPGA で作った CPU でも対戦できる。

仕事は 3 つに分けた。

| 仕事 | 誰がするか | 理由 |
| --- | --- | --- |
| USB・UART のビットを字にする | Pico 2 の USB と UART の部品 (ハードウェア) と、SDK の stdio | 7-1・7-2 では UART を Verilog で書いた。この題では盤の計算に絞るため、Pico 2 に元からある部品に任せる |
| 行を読み、決まりどおりに答える | C の主ループ | 字の並びを比べて分かれる仕事。分かれ道の多い仕事は CPU が得意 |
| 合法手・裏返す石・最善手 | 12-1 の回路 (Verilator の C++) | 64 マスを同時に調べる仕事。回路が得意 |

Soft-FPGA-Reversi は行を読む所まで Verilog で書いている (`rtl/proto.v`) が、この題は回路の仕事を盤の計算に絞った。
UART を 115200 bps のビットのまま Verilog で読まないのは、Soft-FPGA の 1 クロックが 1 bit の 8.7 µs より遅くなりうるため (5-6)。

PC の側のプログラム (play.py) と対局の手順、PC と picoemu で 200 局を回して回路の版と C の版を突き合わせた確かめは、12-8 に分けた。

## 決めたこと

| 項目 | 決め | 理由 |
| --- | --- | --- |
| PC とのつなぎ | 既定は Pico 2 の USB (CDC。PC からはシリアルポートに見える)。Debug Probe があれば、その UART の端子 (3.3 V) を GP0・GP1 につないでもよい | Probe が無くても組めるようにする。Probe は書き込みに使え、PC が送った線そのものを AD3 で読めるので残す |
| stdio | `pico_enable_stdio_usb` と `pico_enable_stdio_uart` を両方有効にする。出す字は USB と UART0 の両方に出て、受ける字はどちらからでも受ける | 1 つの `.uf2` で 2 つのつなぎ方に応じる。UART0 は GP0 が TX、GP1 が RX、115200 bps、8N1 (プロトコルの §4 の例の速さ。SDK の既定) |
| 改行 | `stdio_put_string(…, false, false)` で送り、stdio の改行の変換 (LF を CR LF にする) を通さない | プロトコルは CR LF だけを許す (§5)。`printf("…\r\n")` だと変換で `\r\r\n` になる |
| 受けた行の写し | 受けた行を、そのまま UART1 の TX (GP4、115200 bps 8N1) に出す | **AD3 では USB の中身を読めない** (USB は D+・D− の差動 12 Mbps で、線を取り出すにはケーブルを割くか変換の基板が要る。WaveForms 3.24.4 の Logic の読み下しの一覧 (UART・SPI・I2C・CAN・I2S など 19 種) にも USB は無い)。PC → Pico 2 の行を AD3 で読むため、受けた字を UART で出し直す |
| 時間の印 | 行の LF を受けてから答えを送り始めるまで GP2 を H にする | USB には 1 ms ごとの区切りがあり、PC での受け取りの時刻が揺れる。Pico 2 が考えた時間は、この印の幅で測る |
| GP1 | プルアップする | Debug Probe をつながないと GP1 (UART0 の RX) が浮き、雑音を字として読むおそれがある |
| 状態の LED | GP16 = 対局中 (緑)、GP17 = 対局中で自分が白 (黄)、GP18 = 直前の行に誤り (`-0x`) を返した (赤)。どれも 330 Ω を通して LED を光らせ、AD3 でも読む | 主ループの状態を、PC の画面を見なくても分かるようにする。上の列のピンを使うと、AD3 の線と交わらずに右の空いた所へ LED を置ける |
| 状態を出す時 | 行を 1 つ調べ終えるたびに 3 本を書き直す | 状態が変わるのは行を受けた時だけ。誤りの LED は、次に誤りでない行 (答えない行も含む) を受けると消える |
| 話す行 | 必須の `SB` `SW` `MO` `PA` `EB` `EW` `ED` `VE` `PI` と、`CA` `XB`。`BO` (盤を丸ごと送る) は受けない | プロトコルで任意とされた行を減らし、主ループを短くした |
| 打つ手 | 12-1 の `reversi_accel` の最善手 (角を先に、次に裏返る数の多い手) | 12-1 で C の参照実装と突き合わせ済み |
| 回路を使わないビルド | `SOFT_FPGA` を定義しないと、同じ答えを C の関数で出す | 回路の版と C の版で同じ棋譜になることを確かめる。速さを比べる |
| 起きたとき | `RE` を 1 行送る | プロトコルの §11。PC は `RE` を見たら直前の指示を送り直せる |
| 誤った行 | `-01`〜`-06` で答える | プロトコルの §7.3。FPGA の最小の作りなら `-00` だけでもよい、とされている |

この題で使わない決め: 字と字の間が 100 ms 空いたら行を捨てる決め (プロトコルの §6) は入れていない。人が端末で打つと字の間が 100 ms は空き、手で試せなくなるため。

## 話す行

PC → Pico 2 (左) と Pico 2 → PC (右)。行の終わりはどれも CR LF (`\r\n`)。

| PC が送る | 意味 | Pico 2 が返す |
| --- | --- | --- |
| `PI` | 生きているか | `+PI` |
| `VE` | 版 | `+VE02wb-reversi-12-2` (`02` がプロトコルの版) |
| `CA` | 話せる行の一覧 | `+CA PI VE CA SB SW MO PA EB EW ED XB` |
| `SB` | あなたは黒 (先手) | 自分の手 `MOd3` など |
| `SW` | あなたは白 (後手) | 返さない (相手の手を待つ) |
| `MOe3` | 相手は e3 に打った | 自分の手 `MOf3` など。打てなければ `PA` |
| `PA` | 相手はパス | 自分の手か `PA` |
| `EB` `EW` `ED` | 終わり (黒の勝ち・白の勝ち・引き分け) | 返さない |
| `XB` | 拡張: 考えた量 | `+XB moves=手の数 clocks=回路のクロックの合計 us=考えた時間の合計` |

誤った行への答え: 小文字のコマンド `-02`、CR の無い行 `-03`、座標の書き違い `-04`、打てない手 `-05`、対局していないのに `MO`・`PA` `-06`、知らないコマンド `-01`、80 字を超える行 `-00`。
空の行 (CR LF だけ) は黙って捨てる。`X` で始まる知らない行 (ほかの人の拡張) も黙って捨てる。

始めの数行のやり取り (左の `>` が PC から、`<` が Pico 2 から):

```text
< RE              Pico 2 が起きた
> PI
< +PI
> SB              あなたは黒
< MOd3            始めの局面の合法手 d3・c4・f5・e6 は同じ点数。番号の小さい d3
> MOe3            PC (白) は e3
< MOf3            Pico 2 は f3
```

盤の座標は a1 が左上、行は上から 1〜8 (プロトコルの §8)。12-1 の番号 (行 × 8 + 列) と同じ並びで、`d3` は 2 × 8 + 3 = 19 番になる。

## ブロック図

```plantuml
@startuml
left to right direction
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
skinparam rectangle {
  RoundCorner 6
}
title 図1 PC の play.py と Pico 2 が USB か UART で 1 行ずつ話し、盤の計算は 12-1 の回路が受け持つ

rectangle "PC\nplay.py\n(盤を数え直して確かめる)" as PC #E8F0FE
rectangle "Debug Probe\n(あれば)\nUSB ⇔ UART 3.3 V" as DP
rectangle "USB (CDC)\n既定のつなぎ" as USB #E6F4EA
rectangle "UART0\nGP1 (RX)・GP0 (TX)\n115200 bps" as UART #E6F4EA
rectangle "stdio\nUSB と UART0 の\n両方に出し、両方から受ける" as STDIO #E6F4EA
rectangle "主ループ (C)\n行を読む・盤を持つ" as MAIN #FFF8E1
rectangle "AD3 Logic\nGP0・GP4 (写し)・GP2 (印)\nGP16〜GP18 (状態)" as AD #F3E5F5
rectangle "LED 3 つ\n対局中・白・誤り\n(GP16〜GP18)" as LED #FFEBEE
rectangle "accel.cpp\naccel_legal / flip / pick" as ACC #FFF8E1
rectangle "reversi_accel\n(12-1 の Verilog を\nVerilator の C++ に)" as RTL #E6F4EA

PC --> USB : USB ケーブル
PC --> DP : USB
DP --> UART : TX → GP1
UART --> DP : GP0 → RX
USB --> STDIO
UART --> STDIO
STDIO --> MAIN : 1 字ずつ
MAIN --> AD : 写し (UART1)・印・状態
MAIN --> LED : 状態
MAIN --> ACC : own・opp
ACC --> RTL : eval()・クロック
RTL --> ACC : legal・flip・best
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/12-projects/plantuml/02-reversi-uart.svg)

- 主ループは stdio から字を 1 つずつ受け、LF が来たら 1 行として調べる。字が USB から来たか UART0 から来たかは区別しない。盤 (`black` と `white` の 64 ビット 2 つ) は主ループが持つ
- 盤の計算は `accel_legal` `accel_flip` `accel_pick` の 3 つの関数だけを呼ぶ。中身が回路か C かを主ループは知らない
- 最善手を探す `accel_pick` だけクロックを回す (合法手の数 + 1 クロック、12-1)。`accel_legal` と `accel_flip` は組み合わせ回路なので `eval()` 1 回で答えが出る

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図2 AD3 は 6 本を読む。状態は LED 3 つ。Debug Probe はあれば
parts:
  MCU: pico2 4,6 mirror
  TX0: port 6.4,2.4
  RX0: port 6.4,2.8
  G1: ground 6.4,3.2 r270
  BUSY: port 6.4,3.6
  COPY: port 6.4,4.4
  GAME: port 6.4,10.8
  WHITE: port 6.4,11.2
  ERR: port 6.4,11.6
  DP:
    type: device
    at: 14,2.8
    label: Debug Probe
    pins: [RX, TX, GND]
  TX0: port 11.6,2.4
  RX0: port 11.6,2.8
  G2: ground 11.6,3.2 r90
  AD:
    type: device
    at: 14,6
    label: AD3
    pins: [DIO1, DIO0, DIO2, DIO3, DIO4, DIO5, GND]
  TX0: port 11.6,4.8
  COPY: port 11.6,5.2
  BUSY: port 11.6,5.6
  GAME: port 11.6,6
  WHITE: port 11.6,6.4
  ERR: port 11.6,6.8
  G3: ground 11.6,7.2 r90
  GAME: port 9.6,8.4
  D1: led 9.6,8.4 11.1,8.4
  R1: resistor 11.1,8.4 12.6,8.4 330
  G4: ground 13.2,8.4 r270
  WHITE: port 9.6,9.8
  D2: led 9.6,9.8 11.1,9.8
  R2: resistor 11.1,9.8 12.6,9.8 330
  G5: ground 13.2,9.8 r270
  ERR: port 9.6,11.2
  D3: led 9.6,11.2 11.1,11.2
  R3: resistor 11.1,11.2 12.6,11.2 330
  G6: ground 13.2,11.2 r270
wires:
  - MCU.GP0 -- 6.4,2.4
  - MCU.GP1 -- 6.4,2.8
  - MCU.GND3 -- 6.4,3.2
  - MCU.GP2 -- 6.4,3.6
  - MCU.GP4 -- 6.4,4.4
  - MCU.GP16 -- 2.3,10 -- 2.3,10.8 -- 6.4,10.8
  - MCU.GP17 -- 2,9.6 -- 2,11.2 -- 6.4,11.2
  - MCU.GP18 -- 1.6,8.8 -- 1.6,11.6 -- 6.4,11.6
  - 11.6,2.4 -- DP.RX
  - 11.6,2.8 -- DP.TX
  - 11.6,3.2 -- DP.GND
  - 11.6,4.8 -- AD.DIO1
  - 11.6,5.2 -- AD.DIO0
  - 11.6,5.6 -- AD.DIO2
  - 11.6,6 -- AD.DIO3
  - 11.6,6.4 -- AD.DIO4
  - 11.6,6.8 -- AD.DIO5
  - 11.6,7.2 -- AD.GND
  - 12.6,8.4 -- 13.2,8.4
  - 12.6,9.8 -- 13.2,9.8
  - 12.6,11.2 -- 13.2,11.2
style:
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/12-projects/circuit/02-reversi-uart.svg)

- 線で結ぶ代わりに、**同じ名前の端子 (白丸と名前) どうしがつながっている** (12-4 と同じ書き方)。`TX0` は GP0、`RX0` は GP1、`BUSY` は GP2、`COPY` は GP4
- 回路図に PC は出てこない (USB でつなぎ、Pico 2 の電源も USB から取る)
- AD3 は 6 本を読むだけ。DIO1 が Pico 2 → PC (GP0)、DIO0 が PC → Pico 2 の行の写し (GP4)、DIO2 が時間の印 (GP2)、DIO3〜DIO5 が状態 (GP16〜GP18)
- 状態の 3 本は、それぞれ LED と 330 Ω を通して GND へ。赤・黄・緑の LED の V<sub>F</sub> (順方向電圧) を 2.0 V ほどとすると、(3.3 V − 2.0 V) ÷ 330 Ω ≈ 3.9 mA (見積り)。Pico 2 のピンの既定の駆動 (4 mA) の内に収まる
- Debug Probe は**あれば**つなぐ。Probe の TX (Probe が送る) を Pico 2 の GP1 (受ける) へ、Pico 2 の GP0 (送る) を Probe の RX へ。**送ると受けるを交差させる**
- GND はどれも共通にする。どれも 3.3 V の信号で、レベル変換は要らない

## 部品

| 部品 | 値・型番 | 数 | 役 |
| --- | --- | --- | --- |
| MCU | Raspberry Pi Pico 2 | 1 | Soft-FPGA (12-1 の回路) と主ループ |
| DP | Raspberry Pi Debug Probe (**あれば**。無くても組める) | 1 | PC の USB と Pico 2 の UART (3.3 V) をつなぐ。書き込みにも使える |
| — | ブレッドボード (full、63 列) | 1 | LED を Pico 2 の右に 4 列おきに置くため、half (30 列) から替えた |
| — | ジャンパ線 | 4 本 + 機器の線 | Pico 2 の GND (3 番) から − のレールへ 1 本、GP16〜GP18 から LED へ 3 本。AD3 の線 7 本と、Probe の UART の端子の線 3 本 (あれば) は、先をブレッドボードに挿す |
| D1・D2・D3 | LED 5 mm (緑・黄・赤) | 3 | 状態を見せる。D1 が対局中、D2 が自分が白、D3 が誤り |
| R1・R2・R3 | 330 Ω (E24)、1/4 W | 3 | LED の電流を決める (約 3.9 mA、見積り) |
| AD | Analog Discovery 3 | 1 | Logic で Pico 2 が送った字・受けた字の写し・時間の印・状態の 3 本を読む |
| — | USB ケーブル | 1 本 (Probe があれば 2 本) | Pico 2 と PC (給電・書き込み・対局)。Debug Probe と PC |

電源は教科書の既定の 5 V ではなく **3.3 V** (Pico 2 のピン)。Pico 2 のピンに 5 V を入れると壊れるため (0-3)。
3.3 V でない USB-UART の変換器 (5 V のもの) をつながない。

## 実体配線図

```bread
# ブレッドボードの実体配線図 (tommie-fence の bread フェンス)
title: 図3 GND は − のレールに。状態の LED は右の 27〜36 列。Probe はあれば i5・j6
board: full
parts:
  MCU: pico2 @ h5
  D1: led g27(A) g28(K) green cap=below:0,1 i=3.9mA
  R1: resistor j28 -b28 330
  D2: led g31(A) g32(K) yellow cap=below:0,1 i=3.9mA
  R2: resistor j32 -b32 330
  D3: led g35(A) g36(K) red cap=below:0,1 i=3.9mA
  R3: resistor j36 -b36 330
  DP:
    type: device
    at: bottom
    label: Debug Probe (あれば)
    pins: [RX, GND, TX]
  AD:
    type: device
    at: bottom
    label: AD3 Logic
    pins: [DIO2, DIO0, DIO1, GND, DIO3, DIO4, DIO5]
wires:
  - j7 -- -b7 black
  - DP.RX -- i5 green [h0]
  - DP.GND -- -b3 black
  - DP.TX -- j6 yellow
  - AD.DIO1 -- j5 white [h10, v-130, h-240]
  - AD.DIO2 -- j8 purple
  - AD.DIO0 -- j10 orange
  - AD.GND -- -b19 black
  - b24 -- f27 pink [h50]
  - a23 -- f31 gray [v-10, h150]
  - a21 -- f35 brown [v-20, h290]
  - AD.DIO3 -- j27 blue
  - AD.DIO4 -- j31 blue
  - AD.DIO5 -- j35 blue
notes:
  - text h27 green bold: GAME
  - text h31 orange bold: WHITE
  - text h35 red bold: ERR
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/12-projects/breadboard/02-reversi-uart.svg)

- `pico2 @ h5` は 7-3 と同じ向き。下の列は GP0 (1 番) が 5 列、GP1 (2 番) が 6 列、GND (3 番) が 7 列、GP2 (4 番) が 8 列、GP4 (6 番) が 10 列。上の列は GP16 (21 番) が 24 列、GP17 (22 番) が 23 列、GP18 (24 番) が 21 列
- 状態の 3 本は、上の列のピンの a・b 行から、基板の上の縁を通して右の 27・31・35 列へ渡し、溝を越えて f 行に挿す。遠くへ行く線ほど外を回したので、3 本は交わらない
- LED のすぐ下の太字が、その LED が示す状態 (図2 の端子の名前と同じ)
- LED は g 行に横に挿す (左がアノード)。カソードの列の j 行から 330 Ω で − のレールへ落とす。AD3 の DIO3〜DIO5 は、LED のアノードの列 (27・31・35 列) の j 行に下から挿す
- Pico 2 のピンは h 行に挿さり、同じ列の i・j 行の穴とつながる
- **GND は − のレール (下) にまとめる。** Pico 2 の GND (j7) から − のレールへ 1 本渡し、AD3 と Debug Probe の GND はレールに挿す
- AD3 の DIO1 (白) は、i 行と j 行の間を通して j5 へ入れる。ほかの線の端 (j 行) より上を通るので、線どうしが交差しない
- Debug Probe が無ければ、緑・黄と Probe の黒の 3 本を挿さないだけでよい。ほかの線は変わらない
- 線の色: 緑が Pico 2 → Probe (GP0)、黄が Probe → Pico 2 (GP1)、黒が GND。AD3 の線は白 (DIO1、GP0)、橙 (DIO0、写し)、紫 (DIO2、印)、青 (DIO3〜DIO5、状態)。LED への線は桃・灰・茶。赤は使わない (電源を配らない)
- 流れる電流は LED の 3 つで 12 mA ほど (見積り)。ほかは信号のごく小さな電流。信号は 115200 bps (1 bit 8.7 µs) で、ブレッドボードの範囲 (3 MHz 以下) に収まる

## Pico 2 のプログラム

作業用のフォルダは 5-1 と同じに作る (`stub_mutex.h` `cxx_minimal.cpp` `verilated.cpp` `pico_tls.cpp` と `add_soft_fpga` の `CMakeLists.txt`)。
12-1 の `reversi_accel.v` `legal_bb.v` `flip_calc.v` を写し、下の 2 つのファイルを足す。

この題は C と C++ だけで書く。MicroPython からは Verilator の C++ を呼べない (5-1)。

### reversi.c — 主ループ

```c
// 12-2 リバーシを UART で PC と対戦させる — Pico 2 の主ループ
// PC とは stdio で話す。stdio は USB (CDC) と UART0 (GP0 が TX、GP1 が RX、115200 bps 8N1) の両方に出し、両方から受ける。
// Debug Probe が無ければ USB だけ、あれば Probe の UART でも同じに話せる。リバーシ UART プロトコル v0.2 の一部を話す。
// AD3 で見るために、受けた行の写しを UART1 (GP4) に出し、行を受け終えてから答えを送り始めるまで GP2 を H にする。
// 内部の状態を GP16〜GP18 に出し、LED で見せる (対局中・自分が白・直前の行に誤りを返した)。AD3 でも読む。
// 盤面の計算 (合法手・裏返す石・最善手) は accel_* の 3 つの関数に任せる。
// SOFT_FPGA を定義したビルドでは accel.cpp が 12-1 の回路 (Verilator の C++) で答え、
// 定義しないビルドでは下の C の関数が同じ答えを出す (比べるためと、PC の試験のため)。
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"

#define BAUD      115200
#define PIN_RX0   1                     // UART0 の RX (stdio が使う)。Probe をつながないときに浮かせない
#define COPY_UART uart1
#define PIN_COPY  4                     // UART1 の TX: 受けた行の写し (AD3 用)
#define PIN_BUSY  2                     // 行を受け終えてから答えを送り始めるまで H (AD3 用)
#define PIN_GAME  16                    // 対局中 (緑の LED)
#define PIN_WHITE 17                    // 対局中で、自分が白 (黄の LED)
#define PIN_ERR   18                    // 直前の行に誤り (-0x) を返した (赤の LED)
#define LINE_MAX  80                    // 受ける 1 行の最大 (CR LF を除く)

uint64_t accel_legal(uint64_t own, uint64_t opp);
uint64_t accel_flip(uint64_t own, uint64_t opp, unsigned move);
int      accel_pick(uint64_t own, uint64_t opp, unsigned *clocks);

#ifndef SOFT_FPGA
// ---- 回路を使わないビルドの代わり: 12-1 と同じ答えを C で出す ----
static const int DR[8] = {-1, -1, -1, 0, 0, 1, 1, 1};
static const int DC[8] = {-1, 0, 1, -1, 1, -1, 0, 1};

uint64_t accel_flip(uint64_t own, uint64_t opp, unsigned move) {
    if (((own | opp) >> move) & 1u) return 0;
    uint64_t all = 0;
    for (int d = 0; d < 8; d++) {
        uint64_t line = 0;
        int r = (int)move / 8 + DR[d], c = (int)move % 8 + DC[d];
        while (r >= 0 && r < 8 && c >= 0 && c < 8 && ((opp >> (r * 8 + c)) & 1u)) {
            line |= 1ull << (r * 8 + c);
            r += DR[d]; c += DC[d];
        }
        if (line && r >= 0 && r < 8 && c >= 0 && c < 8 && ((own >> (r * 8 + c)) & 1u)) all |= line;
    }
    return all;
}

uint64_t accel_legal(uint64_t own, uint64_t opp) {
    uint64_t l = 0;
    for (unsigned i = 0; i < 64; i++)
        if (accel_flip(own, opp, i)) l |= 1ull << i;
    return l;
}

int accel_pick(uint64_t own, uint64_t opp, unsigned *clocks) {   // 角を先に、次に裏返る数の多い手
    int best = -1, best_score = -1;
    unsigned n = 0;
    for (unsigned i = 0; i < 64; i++) {
        uint64_t f = accel_flip(own, opp, i);
        if (!f) continue;
        n++;
        int score = __builtin_popcountll(f) + ((i == 0 || i == 7 || i == 56 || i == 63) ? 32 : 0);
        if (score > best_score) { best_score = score; best = (int)i; }
    }
    *clocks = n + 1;                    // 回路なら合法手の数 + 1 クロック (12-1)
    return best;
}
#endif

// ---- 対局の状態 ----
enum { IDLE, WAIT_OPP };
static int      state = IDLE;
static uint64_t black, white;
static int      me;                     // 0 = 黒、1 = 白
static unsigned moves;                  // 自分が考えた回数
static unsigned long total_clocks;      // 回路が探すのに使ったクロックの合計
static uint64_t total_us;               // 考えるのに使った時間の合計
static bool     last_err;               // この行に誤りを返したか

static void send(const char *s) {       // 1 行送る。行の終わりは CR LF
    char buf[LINE_MAX + 3];
    int n = snprintf(buf, sizeof buf, "%s\r\n", s);
    gpio_put(PIN_BUSY, 0);              // 答えを送り始める
    last_err = (s[0] == '-');
    stdio_put_string(buf, n, false, false);  // 改行の変換をしない (CR LF をそのまま送る)
}

static void show_state(void) {          // 状態を LED に出す
    gpio_put(PIN_GAME, state == WAIT_OPP);
    gpio_put(PIN_WHITE, state == WAIT_OPP && me == 1);
    gpio_put(PIN_ERR, last_err);
}

static void copy_line(const char *line, unsigned len, bool had_cr) {  // 受けた行を UART1 に写す
    for (unsigned i = 0; i < len; i++) uart_putc_raw(COPY_UART, line[i]);
    if (had_cr) uart_putc_raw(COPY_UART, '\r');
    uart_putc_raw(COPY_UART, '\n');
}

static void new_game(int side) {
    black = (1ull << 28) | (1ull << 35);    // e4 d5
    white = (1ull << 27) | (1ull << 36);    // d4 e5
    me = side;
}

static void put_stone(uint64_t *own, uint64_t *opp, unsigned m, uint64_t f) {
    *own |= f | (1ull << m);
    *opp &= ~f;
}

static void think_and_move(void) {
    uint64_t *mine = me ? &white : &black, *theirs = me ? &black : &white;
    unsigned clocks = 0;
    uint64_t t0 = time_us_64();
    int m = accel_pick(*mine, *theirs, &clocks);
    if (m >= 0) put_stone(mine, theirs, (unsigned)m, accel_flip(*mine, *theirs, (unsigned)m));
    total_us += time_us_64() - t0;
    total_clocks += clocks;
    moves++;
    if (m < 0) {
        send("PA");                     // 打てる所が無い
    } else {
        char s[5] = {'M', 'O', (char)('a' + m % 8), (char)('1' + m / 8), 0};
        send(s);
    }
    state = WAIT_OPP;
}

static void opponent_move(const char *line, unsigned len) {
    if (len != 4 || line[2] < 'a' || line[2] > 'h' || line[3] < '1' || line[3] > '8') { send("-04 bad coord"); return; }
    unsigned m = (unsigned)(line[3] - '1') * 8u + (unsigned)(line[2] - 'a');
    uint64_t *mine = me ? &white : &black, *theirs = me ? &black : &white;
    uint64_t f = accel_flip(*theirs, *mine, m);
    if (!f) { send("-05 illegal move"); return; }
    put_stone(theirs, mine, m, f);
    think_and_move();
}

static void handle_line(const char *line, unsigned len, bool had_cr) {
    if (!had_cr) { send("-03 need CR LF"); return; }
    if (len == 0) return;                                   // 空行は黙って捨てる
    if (len < 2) { send("-01 unknown"); return; }
    if (line[0] >= 'a' && line[0] <= 'z') { send("-02 lowercase"); return; }
    char c0 = line[0], c1 = line[1];
    if      (c0 == 'P' && c1 == 'I') send("+PI");
    else if (c0 == 'V' && c1 == 'E') send("+VE02wb-reversi-12-2");
    else if (c0 == 'C' && c1 == 'A') send("+CA PI VE CA SB SW MO PA EB EW ED XB");
    else if (c0 == 'X' && c1 == 'B') {
        char s[64];
        snprintf(s, sizeof s, "+XB moves=%u clocks=%lu us=%lu", moves, total_clocks, (unsigned long)total_us);
        send(s);
    }
    else if (c0 == 'S' && (c1 == 'B' || c1 == 'W')) {
        new_game(c1 == 'W');
        if (c1 == 'B') think_and_move();                     // 黒が先に打つ
        else           state = WAIT_OPP;
    }
    else if (c0 == 'M' && c1 == 'O') { if (state == WAIT_OPP) opponent_move(line, len); else send("-06 not my game"); }
    else if (c0 == 'P' && c1 == 'A') { if (state == WAIT_OPP) think_and_move();         else send("-06 not my game"); }
    else if (c0 == 'E' && (c1 == 'B' || c1 == 'W' || c1 == 'D')) state = IDLE;
    else if (c0 == 'X') { }                                   // ほかの拡張は黙って捨てる
    else send("-01 unknown");
}

int main(void) {
    stdio_init_all();                                         // USB と UART0 (GP0・GP1、115200 8N1)
    gpio_pull_up(PIN_RX0);
    uart_init(COPY_UART, BAUD);
    uart_set_format(COPY_UART, 8, 1, UART_PARITY_NONE);
    gpio_set_function(PIN_COPY, GPIO_FUNC_UART);
    static const uint OUT_PINS[] = {PIN_BUSY, PIN_GAME, PIN_WHITE, PIN_ERR};
    for (unsigned i = 0; i < sizeof OUT_PINS / sizeof OUT_PINS[0]; i++) {
        gpio_init(OUT_PINS[i]);
        gpio_set_dir(OUT_PINS[i], GPIO_OUT);
    }
    send("RE");                                               // 起きたことを知らせる

    char line[LINE_MAX];
    unsigned len = 0;
    bool cr = false, too_long = false;
    while (true) {
        int c = getchar_timeout_us(1000000);                  // USB か UART0 から 1 字
        if (c == PICO_ERROR_TIMEOUT) continue;
        if (c == '\n') {                                     // 行の終わり
            gpio_put(PIN_BUSY, 1);
            last_err = false;
            copy_line(line, len, cr);
            if (too_long) send("-00 too long");
            else          handle_line(line, len, cr);
            gpio_put(PIN_BUSY, 0);                            // 答えない行 (SW・EB など) もここで L
            show_state();
            len = 0; cr = false; too_long = false;
        } else if (c == '\r') {
            cr = true;
        } else {
            if (len < LINE_MAX) line[len++] = (char)c;
            else                too_long = true;
            cr = false;
        }
    }
}
```

- 盤は主ループの `black` と `white` が持つ。`accel_*` には「打つ側」と「相手」の順に渡す。相手の手を確かめるときは、相手の石を `own` にして渡す (`opponent_move`)
- `stdio_init_all` が USB と UART0 を用意し、`getchar_timeout_us` はどちらに来た字も返す
- 主ループは字を 1 つずつ見て CR を覚え、LF で 1 行を調べる。LF の前に CR が無ければ `-03`
- 送るのは `send` だけ。`stdio_put_string` の 4 つめの引数 `false` が改行の変換を止める (「決めたこと」の改行)
- LF を受けたら GP2 を H にし、受けた行を UART1 に写す (`copy_line`)。`send` が送り始める前に GP2 を L にする。答えない行 (`SW` `EB` など) は、行を調べ終えた所で L にする
- `send` は送る行が `-` で始まれば `last_err` を立てる。行を調べ終えたら `show_state` が GP16〜GP18 を書き直す。対局中は `state == WAIT_OPP` (Pico 2 は考えるのも答えるのも行を受けた中で済ませるので、対局の間はいつも相手を待っている)
- PC がポートを開くまで、USB への出力は捨てられる (SDK の stdio_usb は、PC が DTR を立てたのを見て送り始める)。起きたときの `RE` は、PC が後から開くと届かない。play.py は `PI` から始めるので困らない
- `XB` の `us` は、`accel_pick` と `accel_flip` を呼んでいた時間の合計 (`time_us_64` の µs)。行を送る時間は含まない
- `#ifndef SOFT_FPGA` の中は 12-1 の参照実装と同じ考え方 (8 方向を 1 マスずつ辿る)。`clocks` は、回路なら何クロックかかったかを同じ数え方で出す

### accel.cpp — 12-1 の回路を呼ぶ

```cpp
// accel.cpp — 12-1 の reversi_accel (Verilator で C++ にした物) を、C の主ループから呼ぶ
#include <stdint.h>
#include "Vreversi_accel.h"

static VerilatedContext ctx;
static Vreversi_accel   top{&ctx};
static bool             ready = false;

static void tick() {
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
}

static void set_board(uint64_t own, uint64_t opp) {
    if (!ready) {                       // 初めて呼ばれたときにリセットを 1 クロック掛ける
        top.start = 0; top.rst = 1; tick(); top.rst = 0;
        ready = true;
    }
    top.own = own;
    top.opp = opp;
}

extern "C" uint64_t accel_legal(uint64_t own, uint64_t opp) {
    set_board(own, opp);
    top.eval();                         // 組み合わせ回路: クロックを待たない
    return top.legal;
}

extern "C" uint64_t accel_flip(uint64_t own, uint64_t opp, unsigned move) {
    set_board(own, opp);
    top.move = move;
    top.eval();
    return top.flip;
}

extern "C" int accel_pick(uint64_t own, uint64_t opp, unsigned *clocks) {
    set_board(own, opp);
    top.start = 1; tick(); top.start = 0;
    unsigned n = 0;
    do { tick(); n++; } while (!top.done);     // 合法手の数 + 1 クロックで done
    *clocks = n;
    return top.found ? (int)top.best : -1;
}
```

- `extern "C"` で、C の主ループから呼べる名前にする (C++ は関数の名前に引数の型を混ぜるので、そのままでは C から見えない)
- `accel_legal` と `accel_flip` は、入力を置いて `eval()` を 1 回するだけ (組み合わせ回路。図1 の下)
- `accel_pick` は 12-1 の試験台の `hw_pick` と同じ回し方。`start` を 1 クロック入れ、`done` が 1 になるまでクロックを回す

### verilate.sh と CMakeLists.txt

`verilate.sh` (`sfa-dev:local` の中で打つ):

```bash
#!/bin/sh
set -e
rm -rf vlinc && cp -r /usr/local/share/verilator/include vlinc
verilator --cc --no-timing --no-trace -Wall --prefix Vreversi_accel --Mdir v_reversi_accel reversi_accel.v legal_bb.v flip_calc.v
```

`CMakeLists.txt` の「ここから下が題ごとに替わる」の下 (5-1):

```cmake
add_soft_fpga(reversi122 reversi.c reversi_accel)
target_sources(reversi122 PRIVATE accel.cpp)
target_compile_definitions(reversi122 PRIVATE SOFT_FPGA)
target_link_libraries(reversi122 hardware_uart)
pico_enable_stdio_usb(reversi122 1)          # stdio を USB (CDC) にも出す
pico_enable_stdio_uart(reversi122 1)         # stdio を UART0 (GP0・GP1) にも出す (Debug Probe・AD3 用)

# 比べるための C だけの版
add_executable(reversi122_c reversi.c)
target_link_libraries(reversi122_c pico_stdlib hardware_uart)
pico_enable_stdio_usb(reversi122_c 1)
pico_enable_stdio_uart(reversi122_c 1)
pico_add_extra_outputs(reversi122_c)
```

- `add_soft_fpga` の主ループは `.c` でもよい。`stub_mutex.h` を先に読ませる指定は C++ のファイルにだけ掛かる (5-1 の `$<COMPILE_LANGUAGE:CXX>`)
- `target_compile_definitions` で `SOFT_FPGA` を定義すると、`reversi.c` の C の関数が消え、`accel.cpp` の関数がつながる
- `pico_enable_stdio_usb` と `pico_enable_stdio_uart` を両方 1 にする。片方だけにすると、もう片方のつなぎ方では話せない

ビルドの打ち方は [5-1 の「ビルドする」](../05-soft-fpga-pico/01-verilator-on-pico.md#ビルドする) と同じ 2 行。
ただし **USB を使うので、TinyUSB 入りの Pico SDK でビルドする** (5-14)。5-1 の `wb-pico-sdk` の Pico SDK には TinyUSB が入っておらず、
CMake が「TinyUSB submodule has not been initialized」と警告して、黙って USB の無い `.uf2` ができる。
手元の Pico SDK 2.2.0 (`git clone --recurse-submodules`) を `-v "$HOME/pico-sdk":/psdk:ro -e PICO_SDK_PATH=/psdk` で差し込む打ち方は 5-14 と同じ。

| できた物 | 大きさ | text | bss |
| --- | --- | --- | --- |
| `build/reversi122.uf2` (回路の版) | 158 720 バイト | 83 032 バイト | 5 532 バイト |
| `build/reversi122_c.uf2` (C だけの版) | 67 072 バイト | 37 312 バイト | 3 848 バイト |

回路の版は、5-1 の `blink` (`.uf2` 92 160 バイト) より 65 KB ほど大きい。Verilator のランタイムに、回路の C++ と USB (TinyUSB)・UART の部品が足された分。
USB を入れる前 (UART0 だけ) は回路の版が 126 976 バイト、C の版が 36 352 バイトだったので、USB の部品で約 30 KB 増えた。
`arm-none-eabi-readelf -S` で `.tdata` が 0 バイト、`.tbss` が 0x44 バイトなので、5-1 の `pico_tls.cpp` の配列のままでよい。**実機では動かしていない。**

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0 (GP4、PC → Pico 2 の行の写し)・DIO1 (GP0、Pico 2 → PC)・DIO2 (GP2、時間の印)・DIO3〜DIO5 (GP16〜GP18、状態) を Enable。Debug Probe でつなぐときは DIO6 (GP1、PC → Pico 2 の線そのもの) も。DIO は 3.3 V。GND を共通にする (0-4) |
| 標本化 | 1 MHz (1 bit 8.68 µs に 8 標本ほど)、窓 1 ms (100 µs/div) |
| トリガ | DIO2 の立ち上がり (Pico 2 が行の LF を受けた所) |
| 読み下し | Logic に UART を足す。DIO0 (名前 COPY) と DIO1 (名前 PICO)、Debug Probe のときは DIO6 (名前 RX) も。115200 bps、8N1、書式は ASCII (手順は 12-9) |
| 測る値 | DIO2 の H の幅 (行を受けてから答えを送り始めるまで = Pico 2 が考えた時間 + 行を調べる時間)。状態の 3 本は窓を 20 ms (2 ms/div) に広げ、どの行で変わったかを見る (12-9 の図1) |

標本化は、一番短い変化 (1 bit) の 4 倍より速くした (instrument-screen の流儀)。

UART の読み下しを足す手順、レーンの一覧、状態の 3 本の図と 1 行を拡大した図は 12-9 に分けた。

## Logic に見えるはずの画面

PC が `SB` を送り、Pico 2 が `MOd3` を返すところ。**考える時間 (図では BUSY-GP2 の H の 35 µs) は仮の値**で、測って書き直す。
字の並びとビットの長さ (8.68 µs) は決まりから決まる。いちばん上の `RX-GP1` (PC が送った線そのもの) は Debug Probe でつないだときだけ見え、USB のときは H のまま。ほかの行は、どちらでつないでも同じに見える。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図4 SB を受け終えてから考え、MOd3 を返す。BUSY-GP2 の H が考える時間 (仮)
device: ad3
time: 100us/div
start: -400us
sample: 1MHz
signals:
  RX-GP1: dio6 pattern 110110010101001000010101011000010010100001 bit 8.681us from -354.6us
  COPY-GP4: dio0 pattern 110110010101001000010101011000010010100001 bit 8.681us from 0s
  TX-GP0: dio1 pattern 1010110010101111001010001001101011001100101011000010010100001 bit 8.681us from 36.319us
  BUSY-GP2: dio2 edges 0s=0 10us=1 45us=0
  D1-GAME-GP16: dio3 edges 0s=0 47us=1
  D2-WHITE-GP17: dio4 low
  D3-ERR-GP18: dio5 low
decode:
  RX: uart RX-GP1 baud 115200 8N1 ascii
  COPY: uart COPY-GP4 baud 115200 8N1 ascii
  PICO: uart TX-GP0 baud 115200 8N1 ascii
cursors: [10us, 45us]
trigger: BUSY-GP2 rising at 10us
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/12-projects/logic/02-reversi-uart.svg)

- 1 字は 10 bit (スタート 1・データ 8・ストップ 1) で 86.8 µs。`SB\r\n` の 4 字は 347 µs、`MOd3\r\n` の 6 字は 521 µs で送り終わる
- レーンの名前は「信号の名前-Pico 2 のピン」。DIO との対応は上の表の Logic の行
- 順番は **`RX-GP1` で `SB` を受け終える (10 µs) → BUSY-GP2 が H → 考える → 45 µs から `TX-GP0` に `MOd3`**。`COPY-GP4` の `SB` は受け終えた後に出し直した写しで、PC が送った時刻ではない
- X1 (10 µs) と X2 (45 µs、仮の位置) は BUSY-GP2 の H の両端。**ΔX が Pico 2 の考える時間**を含む
- D1 (対局中) は `SB` で点く。主ループは行を調べ終えてから LED を書き直すので、点くのは答えを送り始めた後 (図では 47 µs、仮の位置)。黒番で誤りでもないので、D2 (白) と D3 は消えたまま
- 写し (`COPY-GP4`) と答え (`TX-GP0`) は別の UART で、写しを送っている間に答えが出始めてよい。`copy_line` は写しを UART1 の送信 FIFO (32 字) に積むだけで、送り終わりを待たない。待つと BUSY-GP2 の幅に写しの時間 (4 字で 347 µs) が入り、考える時間が測れなくなる。写しの字の並びが PC の送った行と同じなら、Pico 2 は行を正しく受けている
- 読み下しの行に、上の「話す行」の表の字が出れば、プロトコルの行の形は合っている

## 見るべき値

| 項目 | 値 | どこで得たか |
| --- | --- | --- |
| `PI` への答え | `+PI` | PC の試験・picoemu (12-8) |
| `SB` への答え | `MOd3` | PC の試験・picoemu (12-8)・層 A |
| `SB` → `MOe3` の後の答え | `MOf3` | 同上 |
| 1 字の時間 | 86.8 µs (115200 bps、10 bit) | 計算値 |
| UART1 (GP4) の写し | 受けた字と 1 字も違わない (200 局で 35 602 字) | 層 A・picoemu (12-8) |
| GP2 の印 | 行ごとに 1 回 H になり、答えを送り始める前に L に戻る | 層 A |
| 状態の 3 本 (GP16〜GP18、LED の D1〜D3) | `SB` で D1 が点き、`EB` で消える。`SW` では D2 も点く。誤りの答え (`-0x`) で D3 が点き、次の誤りでない行で消える。15 行で 12 回の変わり目が期待どおりの並び | 層 A |
| LED の電流 | 約 3.9 mA (1 本) | 計算 ((3.3 V − 2.0 V) ÷ 330 Ω、V<sub>F</sub> は見積り) |
| BUSY (GP2) の H の幅 (`SB` を受けてから `MOd3` を送り始めるまで) | (測って書く) µs | 図4の ΔX |
| 1 回考える時間 (回路の版) | (測って書く) µs | `XB` の `us` ÷ `moves` |
| 1 回考える時間 (C の版) | (測って書く) µs | 同上 |

- PC で回したときの 1 回考える時間は、回路の版 (Verilator の C++) が約 2.3〜2.4 µs、C の版が約 0.7〜0.85 µs だった (手元の PC。参考の値)。
  **PC の上では、回路を Verilator で真似るほうが C より遅い。** 回路は 64 マスを同時に計算するが、Verilator はその全部を順に計算するからである。
  実物の FPGA なら `legal` は 1 クロック (27 MHz なら 37 ns) で出る。Pico 2 の上で何倍になるかを、`XB` で測って書く

## プログラムでの確かめ

ここでは層 A (SDK のモック) で本文のプログラムを動かした。PC で 200 局を回した確かめと、`.uf2` を picoemu で丸ごと動かした確かめは 12-8 に置いた。

### 層 A — SDK のモック

`npm run pico:test` の層 A (`tests/pico/host/cases/12-02-reversi-uart.c`)。本文の `reversi.c` を SDK のモックにつなぎ、
`SOFT_FPGA` なし (C の計算) で動かす。stdio に決まった行を流し、返した字・UART1 の写し・GP2 と GP16〜GP18 の変化を比べた。
流す行は、黒番の局 (`SB`〜`EB`) と誤りの行のあとに、白番の局 (`SW` `EW`) を足した 15 行。
モックは USB と UART0 を分けない (どちらも stdio の 1 本の入口と出口)。

| 確かめること | 期待値 | 結果 |
| --- | --- | --- |
| `PI` `VE` `SB` `MOe3` `XB` への答え | `RE` `+PI` `+VE02wb-reversi-12-2` `MOd3` `MOf3` `+XB moves=2 clocks=11 us=0` | 合った (考える間はモックの時刻が進まないので `us=0`) |
| 誤った行 (`pi`、CR の無い `PI`、`MOz9`、`MOa1`、終局後の `PA`、`ZZ`) | `-02` `-03` `-04` `-05` `-06` `-01`。空の行には答えない | 合った |
| 改行 | 答えの行の終わりが CR LF のまま (CR が増えない) | 合った |
| UART1 | 115200 bps、8N1、GP4 を UART に。写しが受けた字 (15 行) と同じ。UART0 には直に書かない | 合った |
| GP1 | プルアップ | 合った |
| GP2 | 出力。15 行で 15 回 H になり、最後は L | 合った |
| GP16〜GP18 | 出力。変わり目が `SB` で D1↑、`pi` で D3↑、`EB` で D1↓・D3↓、`PA` で D3↑、空の行で D3↓、`ZZ` で D3↑、`SW` で D1↑・D2↑・D3↓、`EW` で D1↓・D2↓ の 12 回 | 合った |

確かめていないもの: 実物の Pico 2 での動き、USB と Debug Probe のそれぞれで PC の端末から読めること、`XB` の実機の時間、図4の GP2 の H の幅、AD3 での読み下し、LED の明るさと実際の電流。

## 出典

自作。

- 行の決まり: [tommie-jp/reversi-uart-protocol](https://github.com/tommie-jp/reversi-uart-protocol) の README (ドラフト v0.2、CC BY 4.0)。§4 リンク層、§5 文字と改行、§7 行の書式と答えのコード、§8 座標、§11 CPU の状態、§12 状態遷移表
- Pico SDK で Verilator の C++ をビルドする手 (`stub_mutex.h`・`cxx_minimal.cpp`・`verilated.cpp`): [tommie-jp/Soft-FPGA-Reversi](https://github.com/tommie-jp/Soft-FPGA-Reversi) (MIT、コミット `5be3b16`)。5-1 と同じ
- 行を読む所まで Verilog で書いた例: 同じリポジトリの `rtl/proto.v` (この題では C に置いた)
- UART の部品の使い方 (`uart_init` `uart_putc_raw` `gpio_set_function`): Raspberry Pi の Pico SDK 2.2.0 の `hardware_uart`
- stdio を USB と UART の両方に出す設定 (`pico_enable_stdio_usb` `pico_enable_stdio_uart`)、改行の変換 (`PICO_STDIO_DEFAULT_CRLF`)、`stdio_put_string`・`getchar_timeout_us`: Pico SDK 2.2.0 の `pico_stdio` と `pico_stdio_usb` (`stdio.h`・`stdio_usb.h`)
- AD3 の Logic の読み下しの種類 (19 種で、USB は無い): WaveForms 3.24.4 に付いているヘルプ (`doc/logic.html` の「3. Signal Grid」)。UART の設定の出典は 12-9
