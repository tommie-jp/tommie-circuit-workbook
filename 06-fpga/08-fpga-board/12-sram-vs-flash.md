---
book: fpga
chapter: 8
id: 8-12
title: 電源を切ると消える書き込みと、残る書き込み
tier: 100
source: 自作
board: —
device: FPGA
---

# 8-12 電源を切ると消える書き込みと、残る書き込み

> [!WARNING]
> **この題は実機で組んでいない。** 書き込みのコマンドの形は openFPGALoader の `--help` と文書で読み、
> ビットストリームの大きさは gowin_pack で作って数えた。**ボードへの書き込みと、電源を入れ直す確かめは実行していない。**
> 「見るべき値」の電源投入から動き出すまでの時間は「測って書く」で、数を決め打ちしていない。

8-4 の `openFPGALoader -b tangnano9k top.fs` は、回路を FPGA に載せるが、**電源を切ると消える**。
USB を抜いて挿し直すと、ボードは書く前の状態に戻る。
この題では、消える書き込みと残る書き込みの違いと、コマンドの形、実機で確かめる手順を並べる。

**組まない題である。** 実体配線図・Analog Discovery 3・`logic` の図は入れない。
コマンドの違いを読む題で、ブレッドボードの配線は 8-3 のまま変えないため。

## なぜ消えるか

FPGA の中の LUT の表・FF の使い方・配線のスイッチ (8-1) は、**SRAM** という電源を切ると中身を失うメモリに入っている。
`top.fs` を SRAM に書くと、すぐ動く。電源を切ると中身が消えるので、入れ直したときには空に戻る。

残すには、電源を切っても残るメモリ (**フラッシュ**) にも同じ中身を書いておく。電源を入れたとき、FPGA は
フラッシュから中身を読み出して SRAM に入れる。

| 書く所 | 書く速さ | 電源を切ると | 使う場面 |
| --- | --- | --- | --- |
| SRAM | 速い (目安。書く数は「測って書く」) | **消える** | 試しながら直すとき |
| フラッシュ | 遅い (消して書く。目安) | **残る**。電源を入れると自動で動く | 回路が決まったとき |

Sipeed の例の頁は、書き込みの道具の説明で「We'll use download to SRAM as an example」と SRAM を例にして、
「If you need to store firmware with no power, just change Access mode and choose your target .fs file」と、
電源が無いあいだ残すにはアクセスの方式を替える、と書いている。

## コマンド

8-4 で使った書き込みの道具は openFPGALoader。`--help` (v1.1.1) の説明を並べる。

| 指定 | `--help` の説明 | 書き込み先 |
| --- | --- | --- |
| `-m` (`--write-sram`) | write bitstream in SRAM (default: true) | FPGA の SRAM。何も指定しないとこれ |
| `-f` (`--write-flash`) | write bitstream in flash (default: false) | フラッシュ |
| `--external-flash` | select ext flash for device with internal and external storage | 内蔵と外付けの両方のある FPGA で、外付けを選ぶ |
| `--verify` | Verify write operation (SPI Flash only) | 書いたあと読み戻して確かめる (SPI フラッシュだけ) |
| `--detect` | detect FPGA, add -f to show connected flash | FPGA の型番を読む。`-f` を足すとつながったフラッシュも出る |

`-m` `-f` `--dump-flash` は同時に指定できない (`Error: --write-flash, --write-sram and --dump-flash are mutually exclusive`)。

### Tang Nano 9K での書き方 — 資料で確かめられた所と確かめられない所

openFPGALoader の Gowin の頁 (`doc/vendors/gowin.rst`) を読んで、次のとおりだった。

| 言っていること | 内容 |
| --- | --- |
| SRAM (`-m`) | `-b` に書けるボードの名前に `tangnano9k` が入っている (`openFPGALoader -m -b BOARD_NAME *.fs`) |
| フラッシュ (`-f`) | 「Only with Trenz TEC0117, runber, brs-100-gw1nr9 and epm11」。**この一覧に Tang Nano 9K は無い** |
| 外付け SPI フラッシュ | 「`-f` の代わりに `--external-flash` を使うと、MSPI につながった外付けの SPI フラッシュに書ける」 |

- **この題では、Tang Nano 9K に `-f` で書いて残る、とは書けない。** 8-4 の書き込みの節に書いた `-f` が Tang Nano 9K でフラッシュに書くかは、
  上の頁からは確かめられなかった (**未確認**)。実機で `--detect -f` やフラッシュへの書き込みを試して、結果をこの表に書き加える
- 外付けのフラッシュに書く `--external-flash` は、頁にある。Tang Nano 9K の外付け SPI フラッシュは 32 Mbit (8-2)
- 「内蔵のフラッシュ」が Tang Nano 9K の FPGA に載っているかは、この題では確かめていない (**未確認**)

```bash
# 試しながら直すとき (SRAM。電源を切ると消える)
openFPGALoader -b tangnano9k top.fs

# 外付けの SPI フラッシュに書く (頁にある書き方。残るかは実機で確かめる)
openFPGALoader -b tangnano9k --external-flash --verify top.fs
```

どちらも **未実行**。

## ビットストリームの大きさ

フラッシュに入るかを、gowin_pack で作ったビットストリームの大きさで確かめた。
8-4・8-8・8-9・8-10 の 4 つの回路 (LUT の数も FF の数も違う) を、`-d GW1N-9C` で作った。

| 回路 | `.fs` の大きさ (文字) |
| --- | --- |
| 8-4 の点滅 (`top`) | 2,069,320 |
| 8-8 の TD4 に ROM を足した物 | 2,069,320 |
| 8-9 の押しボタンと 7 セグ | 2,069,320 |
| 8-10 の PLL | 2,069,320 |

- **回路が小さくても大きくても、同じ大きさになる。** 8-4 の 24 ビットのカウンタ 1 つと、8-8 の TD4 とで違いが無い。
  `.fs` は FPGA 全体の設定を並べるので、使わない所の設定 (0 か 1) も入る
- `.fs` は `0` と `1` の文字だけのファイルで、728 行。**改行を除くと 2,068,592 文字 (ビット)** で、バイトにすると約 258 キロバイト (計算値)
- 外付けの SPI フラッシュは 32 Mbit なので、1 つの回路は約 6 % を使う (計算値。8-2 の値と上の数から)
- gowin_pack の `-c` (`--compress`) を付けると、同じ回路で 349,472〜362,784 文字になった (回路で違う)。
  圧縮した `.fs` を openFPGALoader が受けるかは、この題では確かめていない

## 実機で確かめる手順

8-4 の `blink` (1 Hz の点滅) を使う。**未実行**。

| 手順 | すること | 見るもの |
| --- | --- | --- |
| 1 | 8-3 の配線に、Tang Nano 9K の `3V3` (25 番。上の列の 24 列) と AD3 の DIO1 を 1 本足す。Logic は DIO0 (IO38) と DIO1 を Enable | DIO1 が 3.3 V の H |
| 2 | SRAM に書く (`openFPGALoader -b tangnano9k top.fs`) | ボードの LED と DIO0 が 1 Hz で点滅する |
| 3 | USB を抜いて挿し直す | **LED は点滅しない**。DIO0 は動かない (書く前の状態に戻る) |
| 4 | フラッシュに書く (`--external-flash`。残るかを確かめるのがこの手順) | 書き込みが終わり、LED が点滅する |
| 5 | USB を抜いて挿し直す | 点滅するなら残った。動かなければ、この書き方では残らない |
| 6 | 5 で動いたら、DIO1 の立ち上がりでトリガをかけ、DIO0 の最初の変化までの時間を測る | 下の表 |

手順 5 で動かなかったときは、この題の `--external-flash` の書き方が Tang Nano 9K の中の設定と合っていない。
結果を、書き込みのコマンドの形と一緒にこの題に書き加える。

## 計器の設定

実機で確かめるときの設定。

| 計器 | 設定 |
| --- | --- |
| Logic | DIO0・DIO1 を Enable。DIO は 3.3 V。GND を共通にする (0-4) |
| 時間軸 | 100 ms/div (窓 1 s) から始め、動き出す時刻が窓の外なら 500 ms/div (窓 5 s) |
| 標本化 | 1 kS/s (1 ms 刻み。動き出しの時間を ms で読めればよい) |
| トリガ | DIO1 (3V3) の立ち上がり。単発 (Single) で待ってから、USB を挿す |

## 見るべき値

| 項目 | 見るべき値 | どこで得たか |
| --- | --- | --- |
| SRAM に書いたあと USB を挿し直したときの点滅 | **無い** (SRAM は消える。目安) | 手順 3 で確かめる |
| フラッシュに書いたあと USB を挿し直したときの点滅 | 測って書く | 手順 5 で確かめる |
| 電源を入れてから最初の変化までの時間 | 測って書く (blink の最初の反転は、リセットが解けてから 0.5 s あと。測った値から 0.5 s を引くと動き出すまでの時間) | 手順 6 |
| `.fs` の大きさ | 2,069,320 文字 (回路によらない) | gowin_pack の出力 |
| `.fs` の中身のビット数 | 2,068,592 (改行を除く) | 同上 |
| 外付けフラッシュの使用率 | 約 6 % (計算値) | 上の数と 8-2 の 32 Mbit |

## シミュレーションでの確かめ (対象外)

openFPGALoader の書き込み先 (SRAM とフラッシュ) と `.fs` の大きさの題で、Verilog が無い。確かめには openFPGALoader・gowin_pack
と実機の Tang Nano 9K が要る。この環境には無いので、`--help` の文言と `.fs` の大きさは確かめていない。

## 出典

自作。

- コマンドの形と説明 (`-m` `-f` `--external-flash` `--verify` `--detect`): openFPGALoader v1.1.1 (OSS CAD Suite 2026-10-10 に入っている) の `--help`
- Gowin の書き込みの説明 (`-m` の対応ボード、`-f` が Trenz TEC0117・runber・brs-100-gw1nr9・epm11 だけ、`--external-flash`):
  [openFPGALoader](https://github.com/trabucayre/openFPGALoader) の `doc/vendors/gowin.rst`
- SRAM への書き込みを例にしていることと、電源が無いあいだ残すにはアクセスの方式を替えること:
  Sipeed の [Tang Nano 9K の LED の例](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/examples/led.html)
- 外付けの SPI フラッシュ 32 Mbit: 8-2 の表 (Sipeed の [Tang Nano 9K のページ](https://wiki.sipeed.com/hardware/en/tang/Tang-Nano-9K/Nano-9K.html))
