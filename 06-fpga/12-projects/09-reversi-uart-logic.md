---
book: fpga
chapter: 12
id: 12-9
title: リバーシの UART を Logic で読む — 読み下しの足し方と状態の 3 本
tier: 300
source: 自作。プロトコルは tommie-jp/reversi-uart-protocol v0.2 (CC BY 4.0)
board: BB
device: PICO
---

# 12-9 リバーシの UART を Logic で読む — 読み下しの足し方と状態の 3 本

> [!WARNING]
> **この題は実機で組んでいない。** 図の字の並びは決まり (115200 bps、8N1) から、答えの行は PC 版の主ループから描いた。
> AD3 での測定はしていない。考える時間 (BUSY-GP2 の H の幅) と LED を書き直すまでの時間は仮の値で、測って書く。

12-2 では、Pico 2 の Soft-FPGA に 12-1 のリバーシの回路を載せ、PC とリバーシ UART プロトコルの行で話させた。
12-2 の図4 は、`SB` を受けて `MOd3` を返す 1 行を AD3 の Logic で見た。
この題は同じ基板を同じ AD3 の線のまま読み、WaveForms で UART の読み下しを足す手順と、
5 行のやり取りで状態の LED の 3 本が変わる所 (図1)、その 1 行を拡大した所 (図2) を描く。

この題は回路図・実体配線図・Analog Discovery 3 のつなぎ方の図を載せない。基板と AD3 の線は 12-2 と同じで、前の題の図 (12-2 の図2・図3) は再掲しない。
Enable する DIO・標本化・トリガは 12-2 の「計器の設定」の表のとおり。

## 計器の設定

UART の読み下し (12-2 の図4 と、この題の図2 の RX・COPY・PICO の行) は、WaveForms の Logic で次のように足す。

1. 信号の一覧の上の緑の **+** の ▼ を押し、出た一覧から **UART** を選ぶ。「Add UART」の窓が開く
2. **Name** を `COPY`、**Data** を **DIO 0** にする
3. **Polarity** は Standard、**Bits** は 8、**Parity** は None、**Stop** は 1 のまま (8N1)
4. **Baud** を **Manual** に替え、**Rate** に **115200** を入れる。既定の Auto Arbitrary のままだと Rate は灰色で入れられない (速さを波形から推し量る)
5. **Format** を **ASCII** にする (既定も ASCII)。Hexadecimal にすると 16 進で出る。`S` = 0x53、`B` = 0x42
6. **Add** で閉じる。同じ手順を Name `PICO`・Data **DIO 1** で繰り返す。Debug Probe でつないでいるときは、Name `RX`・Data **DIO 6** も足す

- 窓の項目の名前と並び、既定の値は、WaveForms 3.24.4 に付いているヘルプ (`doc/logic.html` の「4.6. UART」と、その「Add UART」の窓の画像) で確かめた。Format の選択肢 (ASCII・Decimal・Hexadecimal・Binary) と Baud の選択肢 (Manual・Auto Standard・Auto Arbitrary) は、同じ版の本体に入っている名前で確かめた。AD3 をつないだ画面では確かめていない
- **Bit labels** に印を付けると、ビットの境目に赤の破線と番号 (スタートが S、ストップが P) が出る。ビットの長さを数えるときに使う
- CR (0x0D) と LF (0x0A) は字の形が無いので、12-2 の図4 では 16 進で描いた。WaveForms の ASCII の表示でどう出るかは、ヘルプに書かれていない
- 12-2 の図4 とこの題の図のフェンスでは、`decode:` の行の最後の `ascii` が同じ設定 (`hex` と書けば 16 進で描く)

12-2 の図4 とこの題の図1・図2 のレーンの名前は「信号の名前-Pico 2 のピン」(LED は「LED の番号-状態-ピン」。状態は 12-2 の図2・図3 の GAME・WHITE・ERR と同じ)(logic フェンスの名前に括弧は使えないので `-` でつなぐ)。AD3 の DIO との対応は次のとおり。

| レーン | AD3 | Pico 2 のピン | 中身 | 図 |
| --- | --- | --- | --- | --- |
| COPY-GP4 | DIO0 | GP4 (UART1 の TX) | PC から受けた行の写し。読み下しの行は COPY | 12-2 の図4・図2 |
| TX-GP0 | DIO1 | GP0 (UART0 の TX) | Pico 2 の答え。読み下しの行は PICO | 12-2 の図4・図2 |
| BUSY-GP2 | DIO2 | GP2 | 行を受けてから答えを送り始めるまで H (時間の印) | 12-2 の図4・図2 |
| D1-GAME-GP16 | DIO3 | GP16 | 対局中 (LED の D1、緑) | 12-2 の図4・図1・図2 |
| D2-WHITE-GP17 | DIO4 | GP17 | 対局中で自分が白 (LED の D2、黄) | 12-2 の図4・図1・図2 |
| D3-ERR-GP18 | DIO5 | GP18 | 直前の行に誤りを返した (LED の D3、赤) | 12-2 の図4・図1・図2 |
| RX-GP1 | DIO6 | GP1 (UART0 の RX) | PC が送った字そのもの。**Debug Probe でつないだときだけ**見える (USB のときは線に何も来ない)。読み下しの行は RX | 12-2 の図4・図2 |

Debug Probe でつないでいるときは、DIO6 を GP1 (Probe → Pico 2 の線そのもの) に足すと、PC が送った字が届いた時刻も読める。
写し (DIO0) は Pico 2 が受け終えてから出すので、届いた時刻は読めない。USB でつないでいるときは、届いた時刻は Logic では測れない。

## Logic に見えるはずの画面

### 状態の 3 本を長い窓で見る

PC から 4 ms おきに `SW` `MOd3` `MOz9` `PI` `EW` の 5 行を送ったところ (送る間隔は例として決めた。play.py は答えを待ってすぐ送るので、もっと詰まる)。
変わり目の時刻は、各行の LF を受けた所 (行の最後の字のストップビットの終わり) に置いた。行を調べる時間 (数十 µs、見積り) はこの尺度では見えない。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図1 SW で対局が始まり、MOz9 で誤り、PI で消え、EW で終わる
device: ad3
time: 2ms/div
start: 0s
sample: 100kHz
signals:
  D1-GAME-GP16: dio3 edges 0s=0 1ms=1 17ms=0
  D2-WHITE-GP17: dio4 edges 0s=0 1ms=1 17ms=0
  D3-ERR-GP18: dio5 edges 0s=0 9ms=1 13ms=0
cursors: [1ms, 5ms, 9ms, 13ms, 17ms]
trigger: D1-GAME-GP16 rising at 1ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/12-projects/logic/09-reversi-uart-logic-1.svg)

- レーンの名前とピンの対応は、上の「計器の設定」の表のとおり
- 行き来した行は図に描かず、次の表に書いた。2 ms/div では 1 字が約 3 px で、UART の線 (`RX-GP1`・`COPY-GP4`・`TX-GP0`) は塗りつぶしになり、読み下しの箱にも字が入らないため。字の中身は図2 のように 100 µs/div に拡大して読む

| カーソル | 時刻 (LF を受けた所) | RX (PC が送った行、Debug Probe のとき) | COPY (写し) | PICO (Pico 2 の答え) | D1 GAME | D2 WHITE | D3 ERR |
| --- | --- | --- | --- | --- | --- | --- | --- |
| X1 | 1 ms | `SW` | `SW` | (答えない) | 🟢 点く | 🟡 点く | ⚫ |
| X2 | 5 ms | `MOd3` | `MOd3` | `MOc3` | 🟢 | 🟡 | ⚫ |
| X3 | 9 ms | `MOz9` | `MOz9` | `-04 bad coord` | 🟢 | 🟡 | 🔴 点く |
| X4 | 13 ms | `PI` | `PI` | `+PI` | 🟢 | 🟡 | ⚫ 消える |
| X5 | 17 ms | `EW` | `EW` | (答えない) | ⚫ 消える | ⚫ 消える | ⚫ |

カーソルは図1 の縦線の名前 (X1〜X5)。🟢 🟡 🔴 は点いている、⚫ は消えている。その行を受けた後の LED の様子で、字の付いた所がその行で変わった所

- RX は LF を受けた時刻に送り終わり、COPY と PICO はその直後から出る (12-2 の図4 と同じ順)。PICO の答えは、PC 版の主ループ (`sim/02-reversi-uart-pcstub`) に同じ 5 行を流して得た
- 1 ms の `SW` で D1 (緑) と D2 (黄) が点く。自分が白なので答えは返さない
- 5 ms の `MOd3` は合法な手なので、Pico 2 は自分の手 `MOc3` を返し、状態は変わらない
- 9 ms の `MOz9` は座標の書き違いで `-04 bad coord` を返し、D3 (赤) が点く。13 ms の `PI` は `+PI` を返すので D3 が消える
- 17 ms の `EW` で対局が終わり、D1 と D2 が消える
- カーソルは X1〜X5 が 1・5・9・13・17 ms (どれも LF を受けた所)。図の下の表に、各行でその時刻の D1〜D3 の値と、X1 (対局の始まり) からの差が出る (X5 の差 16 ms がこの例の対局の長さ)
- GP2 (BUSY) はこの図に入れていない。山の幅は数十 µs (仮の値) で、2 ms/div では塗りつぶしになって読めない。幅は 12-2 の図4 の尺度で測る

### 1 行を拡大する

図1 の 13 ms (`PI`) のあたりを 100 µs/div に拡大した。図1 が上の段 (全体)、図2 が下の段 (1 行の字のタイミング) の 2 段で読む。
時刻の置き方は 12-2 の図4 と同じ (行を調べる時間 0.035 ms と、LED を書き直すまでの 0.002 ms は仮の値)。

```logic
# ロジックアナライザの画面 (tommie-fence の logic フェンス)
title: 図2 図1 の 13 ms を拡大。PI を受け終えて +PI を返し、D3-ERR が消える
device: ad3
time: 100us/div
start: 12.6ms
axis: ms
sample: 1MHz
signals:
  RX-GP1: dio6 pattern 11000001010101001001010101100001001010000111 bit 8.681us from 12.635398ms
  COPY-GP4: dio0 pattern 11000001010101001001010101100001001010000111 bit 8.681us from 12.989638ms
  TX-GP0: dio1 pattern 110110101001000001010101001001010101100001001010000111 bit 8.681us from 13.017638ms
  BUSY-GP2: dio2 edges 0s=0 13ms=1 13.035ms=0
  D1-GAME-GP16: dio3 high
  D2-WHITE-GP17: dio4 high
  D3-ERR-GP18: dio5 edges 0s=1 13.037ms=0
decode:
  RX: uart RX-GP1 baud 115200 8N1 ascii
  COPY: uart COPY-GP4 baud 115200 8N1 ascii
  PICO: uart TX-GP0 baud 115200 8N1 ascii
cursors: [13ms, 13.035ms]
trigger: BUSY-GP2 rising at 13ms
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/12-projects/logic/09-reversi-uart-logic-2.svg)

- `RX-GP1` で `PI` の LF を受け終えた所 (13.000 ms) で BUSY-GP2 が H になる。受け始めは 12.653 ms (4 字で 0.347 ms)
- `COPY-GP4` は受け終えた後の 13.007 ms から写しを出す。`TX-GP0` は BUSY-GP2 が L に戻る 13.035 ms から `+PI` を返す
- D3-ERR は、9 ms の `MOz9` の誤りから点いていた。`PI` は誤りでない行なので、答えを送り始めた後 (13.037 ms、仮の位置) に消える
- D1-GAME と D2-WHITE は対局中で自分が白なので、H のまま
- ΔX (0.035 ms = 35 µs) が、`PI` を受けてから答え始めるまでの時間 (仮)。12-2 の図4 と同じ測り方
- 時間軸の字は `axis: ms` で ms にそろえた (logic-fence 0.3.0 から。書かなければ、100 µs/div は 1 目盛が 1 を下回るので µs の字になる)。読み値の表は有効 4 桁なので X2 は 13.04 ms と丸められ、ΔX は 35 µs と出る

## 見るべき値

| 項目 | 値 | どこで得たか |
| --- | --- | --- |
| 5 行への答え (`SW` `MOd3` `MOz9` `PI` `EW`) | (答えない)・`MOc3`・`-04 bad coord`・`+PI`・(答えない) | PC 版の主ループ (`sim/02-reversi-uart-pcstub`) |
| 状態の 3 本の変わり目 | `SW` で D1・D2 が点く。`MOz9` で D3 が点き、`PI` で消える。`EW` で D1・D2 が消える | 同上。並びは 12-2 の層 A と同じ決まり |
| 図1 の X1 から X5 までの差 | 16 ms (この例の対局の長さ。送る間隔 4 ms は例として決めた) | 図1 |
| `PI\r\n` の 4 字の長さ | 0.347 ms (1 字 86.8 µs) | 計算値 |
| `PI` を受けてから `+PI` を返し始めるまで | (測って書く) µs。図2 の ΔX の 35 µs は仮の値 | 図2 の ΔX |

確かめていないもの: AD3 での読み下し (WaveForms の窓の項目は、ヘルプと本体の名前で確かめただけ)、実機での BUSY-GP2 の幅と LED の変わる時刻。

## 出典

自作。

- 行の決まり: [tommie-jp/reversi-uart-protocol](https://github.com/tommie-jp/reversi-uart-protocol) の README (ドラフト v0.2、CC BY 4.0)。§7 行の書式と答えのコード
- AD3 の Logic の読み下しの種類と UART の設定 (Data・Polarity・Bits・Parity・Stop・Baud・Rate・Start・Format): WaveForms 3.24.4 に付いているヘルプ (`doc/logic.html` の「3. Signal Grid」と「4.6. UART」)。読み下しの一覧は Bus・SPI・SPI MOSI/MISO・I2C・UART・1-Wire・CAN・GPIB・HDMI CEC・I2S・JTAG・LIN・Manchester・PWM・QuadDec・SAE J1850・SWD・USART PS/2・Custom で、USB は無い
