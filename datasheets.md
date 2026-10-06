# 部品のデータシート (リンク集)

> [!WARNING]
> この本は AI (Claude) が書いたもので、人間の専門家の校正を受けていない。
> 型番の取り違え・リンク切れがありうる。部品を買う前に、売り場の型番とデータシートを自分で見比べてほしい。

教科書の部品表に出る型番のデータシートへのリンク。**確認済**のものは、2026-10-06 に PDF を取得して先頭の型番が合うことを確かめた。**未確認**のものは、メーカーのサイトが機械からの取得を断る、または公式の PDF が見つからないもので、ブラウザで開いて確かめる。

同じ型番に作り手が何社もある部品 (74HC、2N7000、1N4148 など) は、1 社の資料を代表に置いた。電気的な値は作り手で少し違うので、買った部品の資料で読み直す。

## 確認済

### トランジスタ・FET・サイリスタ

| 型番 | 内容 | データシート |
| --- | --- | --- |
| 2N7000 / BS170 | N ch MOSFET (TO-92) | [PDF](https://www.vishay.com/docs/70226/70226.pdf)。2N7000 のピンの並びは実物で確かめる: onsemi の 2007 年版の図は S G D、2022 年版の表は D G S で食い違い、表は 2007 年版 (S G D) に従う。実物はテスタで確かめる |
| 2SC3355 / 2SC3355L | 高周波 NPN (fT 7 GHz) | [PDF](https://static.chipdip.ru/lib/225/DOC000225164.pdf) |
| IRF9540 | P ch パワー MOSFET | [PDF](https://www.vishay.com/docs/91078/91078.pdf) |

### ダイオード

| 型番 | 内容 | データシート |
| --- | --- | --- |
| 1N4148 | 小信号スイッチング | [PDF](https://www.vishay.com/docs/81857/1n4148.pdf) |
| 1N5817 / 1N5818 / 1N5819 | ショットキー | [PDF](https://www.vishay.com/docs/88525/1n5817.pdf) |
| 1N4001〜1N4007 | 整流 | [PDF](https://www.vishay.com/docs/88503/1n4001.pdf) |

### オペアンプ・コンパレータ・アナログ IC

| 型番 | 内容 | データシート |
| --- | --- | --- |
| LM358 | 2 回路オペアンプ (LM158 / LM258 と共通) | [PDF](https://www.ti.com/lit/ds/symlink/lm358.pdf) |
| TL071 / TL072 | JFET 入力オペアンプ | [PDF](https://www.ti.com/lit/ds/symlink/tl071.pdf) |
| MCP6002 | レール to レール オペアンプ | [PDF](https://ww1.microchip.com/downloads/en/DeviceDoc/MCP6001-1R-1U-2-4-1-MHz-Low-Power-Op-Amp-DS20001733L.pdf) |
| LM393 | 2 回路コンパレータ | [PDF](https://www.ti.com/lit/ds/symlink/lm393.pdf) |
| LM386 | 低電圧のオーディオ電力増幅 | [PDF](https://www.ti.com/lit/ds/symlink/lm386.pdf) |
| NE555 | タイマー IC | [PDF](https://www.ti.com/lit/ds/symlink/ne555.pdf) |

### 電源 IC

| 型番 | 内容 | データシート |
| --- | --- | --- |
| 7805 (LM340 系) | 5 V 三端子レギュレータ | [PDF](https://www.ti.com/lit/ds/symlink/lm340.pdf) |
| LM317 | 可変の三端子レギュレータ | [PDF](https://www.ti.com/lit/ds/symlink/lm317.pdf) |
| LM1117 | LDO | [PDF](https://www.ti.com/lit/ds/symlink/lm1117.pdf) |
| AMS1117 | LDO (3.3 V) | [PDF](http://www.advanced-monolithic.com/pdf/ds1117.pdf) |
| MC34063 | スイッチングレギュレータ IC | [PDF](https://www.ti.com/lit/ds/symlink/mc34063a.pdf) |
| LM2596 | 降圧スイッチングレギュレータ | [PDF](https://www.ti.com/lit/ds/symlink/lm2596.pdf) |
| TP4056 | リチウムイオン充電 IC | [PDF](https://dlnmh9ip6v2uc.cloudfront.net/datasheets/Prototyping/TP4056.pdf) |

### ロジック IC

| 型番 | 内容 | データシート |
| --- | --- | --- |
| 74HC00 | NAND | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc00.pdf) |
| 74HC02 | NOR | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc02.pdf) |
| 74HC04 | インバータ | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc04.pdf) |
| 74HC08 | AND | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc08.pdf) |
| 74HC32 | OR | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc32.pdf) |
| 74HC86 | XOR | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc86.pdf) |
| 74HC14 | シュミットトリガのインバータ | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc14.pdf) |
| 74HC74 | D フリップフロップ | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc74.pdf) |
| 74HC161 | 4 ビットカウンタ (同期、非同期クリア) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc161.pdf) |
| 74HC163 | 4 ビットカウンタ (同期クリア) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc163.pdf) |
| 74HC154 | 4 線→16 線デコーダ | [PDF](https://assets.nexperia.com/documents/data-sheet/74HC_HCT154.pdf) |
| 74HC194 | 4 ビットシフトレジスタ | [PDF](https://www.ti.com/lit/ds/symlink/cd74hc194.pdf) |
| 74HC245 | バスバッファ | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc245.pdf) |
| 74HC283 | 4 ビット全加算器 | [PDF](https://www.ti.com/lit/ds/symlink/cd74hc283.pdf) |
| 74HC595 | シフトレジスタ (ラッチ付き) | [PDF](https://www.ti.com/lit/ds/symlink/sn74hc595.pdf) |
| CD4011 | NAND (CMOS 4000 系) | [PDF](https://www.ti.com/lit/ds/symlink/cd4011b.pdf) |
| CD4013 | D フリップフロップ | [PDF](https://www.ti.com/lit/ds/symlink/cd4013b.pdf) |
| CD4017 | ジョンソンカウンタ | [PDF](https://www.ti.com/lit/ds/symlink/cd4017b.pdf) |
| CD4040 | 12 段バイナリカウンタ | [PDF](https://www.ti.com/lit/ds/symlink/cd4040b.pdf) |
| CD4069UB | インバータ | [PDF](https://www.ti.com/lit/ds/symlink/cd4069ub.pdf) |
| CD4070B | XOR | [PDF](https://www.ti.com/lit/ds/symlink/cd4070b.pdf) |
| CD4071B | OR | [PDF](https://www.ti.com/lit/ds/symlink/cd4071b.pdf) |
| CD4081B | AND | [PDF](https://www.ti.com/lit/ds/symlink/cd4081b.pdf) |

### ドライバ・変換

| 型番 | 内容 | データシート |
| --- | --- | --- |
| ULN2003A | 7 回路のダーリントンドライバ | [PDF](https://www.ti.com/lit/ds/symlink/uln2003a.pdf) |
| L293D | モータドライバ (H ブリッジ) | [PDF](https://www.ti.com/lit/ds/symlink/l293d.pdf) |
| MCP3008 | 10 ビット 8 ch ADC (SPI) | [PDF](https://cdn-shop.adafruit.com/datasheets/MCP3008.pdf) |
| Si5351 | I2C のクロック発生器 | [PDF](https://www.skyworksinc.com/-/media/Skyworks/SL/documents/public/data-sheets/Si5351-B.pdf) |

### センサー・モジュール・マイコン

| 型番 | 内容 | データシート |
| --- | --- | --- |
| LM35 | アナログ温度センサー | [PDF](https://www.ti.com/lit/ds/symlink/lm35.pdf) |
| TMP36 | アナログ温度センサー | [PDF](https://cdn-learn.adafruit.com/assets/assets/000/010/131/original/TMP35_36_37.pdf) |
| MCP9808 | I2C 温度センサー | [PDF](https://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf) |
| LM75 | I2C 温度センサー | [PDF](https://www.ti.com/lit/ds/symlink/lm75b.pdf) |
| DS18B20 | 1-Wire 温度センサー | [PDF](https://cdn-shop.adafruit.com/datasheets/DS18B20.pdf) |
| HC-SR04 | 超音波距離モジュール | [PDF](https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf) |
| SG90 | マイクロサーボ | [PDF](https://www.friendlywire.com/projects/ne555-servo-safe/SG90-datasheet.pdf) |
| nRF24L01+ | 2.4 GHz トランシーバ | [PDF](https://www.sparkfun.com/datasheets/Components/SMD/nRF24L01Pluss_Preliminary_Product_Specification_v1_0.pdf) |
| RP2350 | マイコン (Raspberry Pi Pico 2 の石) | [PDF](https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf) |
| Raspberry Pi Pico 2 | ボード | [PDF](https://datasheets.raspberrypi.com/pico/pico-2-datasheet.pdf) |
| HC-49 系の水晶 | 水晶振動子 (例: Abracon ABL) | [PDF](https://www.abracon.com/Resonators/ABL.pdf) |

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

| 計器 | 資料 |
| --- | --- |
| Analog Discovery 3 の仕様 | [Specifications (PDF、TestEquity のミラー)](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf) |
| Analog Discovery 3 のリファレンスマニュアル | [Reference Manual (PDF、同ミラー)](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf) |
| WaveForms | [Reference Manual](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual) (digilent.com は機械からは 403。ブラウザで開く) |
| tinySA | [Specification](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification) |

## 保守

- 題に新しい部品を足したら、ここへ 1 行足す。リンクは PDF を取得して先頭の型番を見てから書く
- digilent.com・analog.com・onsemi・alldatasheet は機械からの取得を断ることがある。ミラーの PDF を使うか、未確認の表に回す
