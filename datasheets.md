# 部品のデータシート (リンク集)

> [!WARNING]
> この本は AI (Claude) が書いたもので、人間の専門家の校正を受けていない。
> 型番の取り違え・リンク切れがありうる。部品を買う前に、売り場の型番とデータシートを自分で見比べてほしい。

教科書の部品表に出る型番のデータシートへのリンク。**確認済**のものは、2026-10-06 に PDF を取得して先頭の型番が合うことを確かめた。**未確認**のものは、メーカーのサイトが機械からの取得を断る、または公式の PDF が見つからないもので、ブラウザで開いて確かめる。

**版**は資料の文書番号と改訂 (TI なら SCLS181H のような番号と改訂の年月)。リンクが切れても、この番号でメーカーのサイトを探し直せる。**控え**は Internet Archive の [Wayback Machine](https://web.archive.org/) に保存した写しで、元のリンクが消えたときに使う。PDF そのものは、著作権がメーカーにあるのでこのリポジトリには置かない。

同じ型番に作り手が何社もある部品 (74HC、2N7000、1N4148 など) は、1 社の資料を代表に置いた。電気的な値は作り手で少し違うので、買った部品の資料で読み直す。

## 確認済

### トランジスタ・FET・サイリスタ

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| 2N7000 / BS170 | N ch MOSFET (TO-92) | Vishay 70226 Rev. F (2001-07) | [PDF](https://www.vishay.com/docs/70226/70226.pdf)。2N7000 のピンの並びは実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる | [Wayback](https://web.archive.org/web/20260326171844/https://www.vishay.com/docs/70226/70226.pdf) |
| 2SC3355 / 2SC3355L | 高周波 NPN (fT 7 GHz) | NEC P10355EJ3V1DS00 (第 3 版) | [PDF](https://static.chipdip.ru/lib/225/DOC000225164.pdf) | [Wayback](https://web.archive.org/web/20261006192755/https://static.chipdip.ru/lib/225/DOC000225164.pdf) |
| IRF9540 | P ch パワー MOSFET | Vishay 91078 Rev. C (2021-08) | [PDF](https://www.vishay.com/docs/91078/91078.pdf) | [Wayback](https://web.archive.org/web/20260430150732/https://www.vishay.com/docs/91078/91078.pdf) |

### ダイオード

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| 1N4148 | 小信号スイッチング | Vishay 81857 Rev. 1.6 (2024-11) | [PDF](https://www.vishay.com/docs/81857/1n4148.pdf) | [Wayback](https://web.archive.org/web/20260910063119/https://www.vishay.com/docs/81857/1n4148.pdf) |
| 1N5817 / 1N5818 / 1N5819 | ショットキー | Vishay 88525 (2020-07) | [PDF](https://www.vishay.com/docs/88525/1n5817.pdf) | [Wayback](https://web.archive.org/web/20260926233424/https://www.vishay.com/docs/88525/1n5817.pdf) |
| 1N4001〜1N4007 | 整流 | Vishay 88503 (2020-04) | [PDF](https://www.vishay.com/docs/88503/1n4001.pdf) | [Wayback](https://web.archive.org/web/20260926191906/https://www.vishay.com/docs/88503/1n4001.pdf) |

### オペアンプ・コンパレータ・アナログ IC

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| LM358 | 2 回路オペアンプ (LM158 / LM258 と共通) | SLOS068AB (2024-10) | [PDF](https://www.ti.com/lit/ds/symlink/lm358.pdf) | [Wayback](https://web.archive.org/web/20261004161810/https://www.ti.com/lit/ds/symlink/lm358.pdf) |
| TL071 / TL072 | JFET 入力オペアンプ | SLOS080W (2025-07) | [PDF](https://www.ti.com/lit/ds/symlink/tl071.pdf) | [Wayback](https://web.archive.org/web/20261004150708/https://www.ti.com/lit/ds/symlink/tl071.pdf) |
| MCP6002 | レール to レール オペアンプ | DS20001733L | [PDF](https://ww1.microchip.com/downloads/en/DeviceDoc/MCP6001-1R-1U-2-4-1-MHz-Low-Power-Op-Amp-DS20001733L.pdf) | [Wayback](https://web.archive.org/web/20261004005311/https://ww1.microchip.com/downloads/en/DeviceDoc/MCP6001-1R-1U-2-4-1-MHz-Low-Power-Op-Amp-DS20001733L.pdf) |
| LM393 | 2 回路コンパレータ | SLCS005AH (2025-04) | [PDF](https://www.ti.com/lit/ds/symlink/lm393.pdf) | [Wayback](https://web.archive.org/web/20261006194001/https://www.ti.com/lit/ds/symlink/lm393.pdf) |
| LM386 | 低電圧のオーディオ電力増幅 | SNAS545D (2023-08) | [PDF](https://www.ti.com/lit/ds/symlink/lm386.pdf) | [Wayback](https://web.archive.org/web/20261001143649/https://www.ti.com/lit/ds/symlink/lm386.pdf) |
| NE555 | タイマー IC | SLFS022K (2026-03) | [PDF](https://www.ti.com/lit/ds/symlink/ne555.pdf) | [Wayback](https://web.archive.org/web/20261006194200/https://www.ti.com/lit/ds/symlink/ne555.pdf) |

### 電源 IC

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| 7805 (LM340 系) | 5 V 三端子レギュレータ | SNOSBT0L (2016-09) | [PDF](https://www.ti.com/lit/ds/symlink/lm340.pdf) | [Wayback](https://web.archive.org/web/20261006194223/https://www.ti.com/lit/ds/symlink/lm340.pdf) |
| LM317 | 可変の三端子レギュレータ | SLVS044Z (2025-04) | [PDF](https://www.ti.com/lit/ds/symlink/lm317.pdf) | [Wayback](https://web.archive.org/web/20261004184150/https://www.ti.com/lit/ds/symlink/lm317.pdf) |
| LM1117 | LDO | SNOS412Q (2023-01) | [PDF](https://www.ti.com/lit/ds/symlink/lm1117.pdf) | [Wayback](https://web.archive.org/web/20261006194346/https://www.ti.com/lit/ds/symlink/lm1117.pdf) |
| AMS1117 | LDO (3.3 V) | 記載なし | [PDF](http://www.advanced-monolithic.com/pdf/ds1117.pdf) | [Wayback](https://web.archive.org/web/20261004164730/http://www.advanced-monolithic.com/pdf/ds1117.pdf) |
| MC34063 | スイッチングレギュレータ IC | SLLS636N (2015-01) | [PDF](https://www.ti.com/lit/ds/symlink/mc34063a.pdf) | [Wayback](https://web.archive.org/web/20261006194433/https://www.ti.com/lit/ds/symlink/mc34063a.pdf) |
| LM2596 | 降圧スイッチングレギュレータ | SNVS124G (2023-03) | [PDF](https://www.ti.com/lit/ds/symlink/lm2596.pdf) | [Wayback](https://web.archive.org/web/20261004013103/https://www.ti.com/lit/ds/symlink/lm2596.pdf) |
| TP4056 | リチウムイオン充電 IC | 記載なし | [PDF](https://dlnmh9ip6v2uc.cloudfront.net/datasheets/Prototyping/TP4056.pdf) | — |

### ロジック IC

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| 74HC00 | NAND | SCLS181H (2021-08) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc00.pdf) | [Wayback](https://web.archive.org/web/20261006195112/https://www.ti.com/lit/ds/symlink/sn74hc00.pdf) |
| 74HC02 | NOR | SCLS076G (2020-12) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc02.pdf) | — |
| 74HC04 | インバータ | SCLS078H (2021-04) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf) | [Wayback](https://web.archive.org/web/20261006195353/https://www.ti.com/lit/ds/symlink/sn74hc04.pdf) |
| 74HC08 | AND | SCLS081J (2025-02) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc08.pdf) | [Wayback](https://web.archive.org/web/20261006195600/https://www.ti.com/lit/ds/symlink/sn74hc08.pdf) |
| 74HC32 | OR | SCLS200F (2021-04) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc32.pdf) | [Wayback](https://web.archive.org/web/20261006195703/https://www.ti.com/lit/ds/symlink/sn74hc32.pdf) |
| 74HC86 | XOR | SCLS100F (2021-04) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc86.pdf) | [Wayback](https://web.archive.org/web/20261006195735/https://www.ti.com/lit/ds/symlink/sn74hc86.pdf) |
| 74HC14 | シュミットトリガのインバータ | SCLS085L (2025-02) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf) | — |
| 74HC74 | D フリップフロップ | SCLS094F (2021-06) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc74.pdf) | [Wayback](https://web.archive.org/web/20261006200013/https://www.ti.com/lit/ds/symlink/sn74hc74.pdf) |
| 74HC161 | 4 ビットカウンタ (同期、非同期クリア) | SCLS297D (2003-09) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc161.pdf) | [Wayback](https://web.archive.org/web/20261006200055/https://www.ti.com/lit/ds/symlink/sn74hc161.pdf) |
| 74HC163 | 4 ビットカウンタ (同期クリア) | SCLS298D (2003-10) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc163.pdf) | [Wayback](https://web.archive.org/web/20261006200156/https://www.ti.com/lit/ds/symlink/sn74hc163.pdf) |
| 74HC154 | 4 線→16 線デコーダ | Nexperia Rev. 10 (2024-08) | [PDF](https://assets.nexperia.com/documents/data-sheet/74HC_HCT154.pdf) | [Wayback](https://web.archive.org/web/20261006200256/https://assets.nexperia.com/documents/data-sheet/74HC_HCT154.pdf) |
| 74HC194 | 4 ビットシフトレジスタ | SCHS164G (2006-05) | [PDF](https://www.ti.com/lit/ds/symlink/cd74hc194.pdf) | [Wayback](https://web.archive.org/web/20260923170717/https://www.ti.com/lit/ds/symlink/cd74hc194.pdf) |
| 74HC245 | バスバッファ | SCLS131F (2022-08) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc245.pdf) | [Wayback](https://web.archive.org/web/20260923015019/https://www.ti.com/lit/ds/symlink/sn74hc245.pdf) |
| 74HC283 | 4 ビット全加算器 | SCHS176E (2022-07) | [PDF](https://www.ti.com/lit/ds/symlink/cd74hc283.pdf) | [Wayback](https://web.archive.org/web/20261006200944/https://www.ti.com/lit/ds/symlink/cd74hc283.pdf) |
| 74HC595 | シフトレジスタ (ラッチ付き) | SCLS041J (2021-10) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf) | — |
| CD4011 | NAND (CMOS 4000 系) | SCHS021D (2003-09) | [PDF](https://www.ti.com/lit/ds/symlink/cd4011b.pdf) | [Wayback](https://web.archive.org/web/20260828011251/https://www.ti.com/lit/ds/symlink/cd4011b.pdf) |
| CD4013 | D フリップフロップ | SCHS023E (2016-09) | [PDF](https://www.ti.com/lit/ds/symlink/cd4013b.pdf) | [Wayback](https://web.archive.org/web/20261006201449/https://www.ti.com/lit/ds/symlink/cd4013b.pdf) |
| CD4017 | ジョンソンカウンタ | SCHS027C (2004-02) | [PDF](https://www.ti.com/lit/ds/symlink/cd4017b.pdf) | [Wayback](https://web.archive.org/web/20260924161200/https://www.ti.com/lit/ds/symlink/cd4017b.pdf) |
| CD4040 | 12 段バイナリカウンタ | SCHS030D (2003-12) | [PDF](https://www.ti.com/lit/ds/symlink/cd4040b.pdf) | [Wayback](https://web.archive.org/web/20261006222955/https://www.ti.com/lit/ds/symlink/cd4040b.pdf) |
| CD4069UB | インバータ | SCHS054E (2019-01) | [PDF](https://www.ti.com/lit/ds/symlink/cd4069ub.pdf) | — |
| CD4070B | XOR | SCHS055E (2003-09) | [PDF](https://www.ti.com/lit/ds/symlink/cd4070b.pdf) | — |
| CD4071B | OR | SCHS056D (2003-08) | [PDF](https://www.ti.com/lit/ds/symlink/cd4071b.pdf) | — |
| CD4081B | AND | SCHS057C (2003-09) | [PDF](https://www.ti.com/lit/ds/symlink/cd4081b.pdf) | — |

### ドライバ・変換

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| ULN2003A | 7 回路のダーリントンドライバ | SLRS027T (2025-03) | [PDF](https://www.ti.com/lit/ds/symlink/uln2003a.pdf) | — |
| L293D | モータドライバ (H ブリッジ) | SLRS008D (2016-01) | [PDF](https://www.ti.com/lit/ds/symlink/l293d.pdf) | — |
| MCP3008 | 10 ビット 8 ch ADC (SPI) | DS21295D (2008-12) | [PDF](https://cdn-shop.adafruit.com/datasheets/MCP3008.pdf) | — |
| Si5351 | I2C のクロック発生器 | Rev. 1.3 | [PDF](https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/data-sheets/Si5351-B.pdf) | — |

### センサー・モジュール・マイコン

| 型番 | 内容 | 版 | データシート | 控え |
| --- | --- | --- | --- | --- |
| LM35 | アナログ温度センサー | SNIS159H (2017-12) | [PDF](https://www.ti.com/lit/ds/symlink/lm35.pdf) | — |
| TMP36 | アナログ温度センサー | Rev. E | [PDF](https://cdn-learn.adafruit.com/assets/assets/000/010/131/original/TMP35_36_37.pdf) | — |
| MCP9808 | I2C 温度センサー | DS25095A (2011-10) | [PDF](https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf) | [Wayback](https://web.archive.org/web/20260829185052/http://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf) |
| LM75 | I2C 温度センサー | SNIS153D (2015-10) | [PDF](https://www.ti.com/lit/ds/symlink/lm75b.pdf) | — |
| DS18B20 | 1-Wire 温度センサー | REV 042208 | [PDF](https://cdn-shop.adafruit.com/datasheets/DS18B20.pdf) | — |
| HC-SR04 | 超音波距離モジュール | 記載なし | [PDF](https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf) | — |
| SG90 | マイクロサーボ | 記載なし | [PDF](https://www.friendlywire.com/projects/ne555-servo-safe/SG90-datasheet.pdf) | — |
| nRF24L01+ | 2.4 GHz トランシーバ | Rev. 1.0 | [PDF](https://www.sparkfun.com/datasheets/Components/SMD/nRF24L01Pluss_Preliminary_Product_Specification_v1_0.pdf) | — |
| RP2350 | マイコン (Raspberry Pi Pico 2 の石) | build 80d627281ed5 | [PDF](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) | — |
| Raspberry Pi Pico 2 | ボード | build d4e0f1799616 | [PDF](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf) | — |
| HC-49 系の水晶 | 水晶振動子 (例: Abracon ABL) | REVISED 03-31-23 | [PDF](https://www.abracon.com/Resonators/ABL.pdf) | — |

## 未確認 (ブラウザで開いて確かめる)

| 型番 | 内容 | 探し方 |
| --- | --- | --- |
| 2SC1815 / 2SA1015 | NPN / PNP の小信号トランジスタ (東芝。製造中止で、互換品を使う) | 東芝 (toshiba-semicon-storage.com) の製品ページ。互換品は各社の 2SC1815 相当品の資料 |
| 2SC2120 / 2SA950 | NPN / PNP の小信号トランジスタ | 東芝の旧品。[alldatasheet.com](https://www.alldatasheet.com/) で型番検索 |
| 2N3904 | NPN の小信号トランジスタ | onsemi・Diodes・Nexperia の各社の資料 (型番で検索) |
| 2N5064 | サイリスタ (SCR) | onsemi の 2N5060 系の資料 (型番で検索) |
| 3SK291 | デュアルゲート MOSFET (東芝) | [electronicsdatasheets.com の資料](https://www.electronicsdatasheets.com/download/101912.pdf?format=pdf)。東芝の製品ページ (toshiba-semicon-storage.com の 3SK291) でも見られる |
| 1SS108 / 1SV149 / 1N5231B ほか | 検波・可変容量・ツェナー | 型番で [alldatasheet.com](https://www.alldatasheet.com/) を検索 |
| SA612A | 平衡ミキサ + 局発 IC | NXP の資料 (公式の URL は移動した。型番で検索) |
| LMF501T / TA7642 | AM ラジオ IC | 型番で [alldatasheet.com](https://www.alldatasheet.com/) を検索 |
| SFU455B | セラミックフィルタ 455 kHz (村田) | 村田製作所 (murata.com) の SFU 系の資料 |
| 7905 | −5 V 三端子レギュレータ | TI の LM79xx・onsemi の MC7900 の資料 (型番で検索) |
| AD9833 / ADF4350 | DDS / PLL シンセサイザ | Analog Devices (analog.com) の製品ページ |
| DS3231 | RTC (I2C) | Analog Devices (analog.com) の製品ページ |
| GL5528 | CdS 光センサー | メーカーの資料 (型番で検索) |
| DHT11 / MT3608 | 温湿度センサー / 昇圧モジュール | 型番で検索 |

## 計器

| 計器 | 版 | 資料 | 控え |
| --- | --- | --- | --- |
| Analog Discovery 3 の仕様 | 記載なし | [Specifications (PDF、TestEquity のミラー)](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf) | — |
| Analog Discovery 3 のリファレンスマニュアル | 記載なし | [Reference Manual (PDF、同ミラー)](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf) | — |
| WaveForms | — | [Reference Manual](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual) (digilent.com は機械からは 403。ブラウザで開く) | — |
| tinySA | — | [Specification](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification) | — |

## 保守

- 題に新しい部品を足したら、ここへ 1 行足す。リンクは PDF を取得して先頭の型番を見てから書く
- 行を足したら、版 (表紙かページの下の文書番号と改訂) を書き、`https://web.archive.org/save/<元の URL>` を開いて Wayback に保存し、保存先を控えの列に書く。版の記載がない資料は「記載なし」と書く
- digilent.com・analog.com・onsemi・alldatasheet は機械からの取得を断ることがある。ミラーの PDF を使うか、未確認の表に回す
