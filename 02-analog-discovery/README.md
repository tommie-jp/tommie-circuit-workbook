# Analog Discovery の教科書

> [!WARNING]
> この教科書は AI (Claude) が書いたもので、人間の専門家の校正を受けていない。
> 回路・数値・手順が間違っている可能性がある。組む前に自分で確かめてほしい。

Analog Discovery 2 / 3 と付属ソフトウェア WaveForms で、DC〜10 MHz を測る。
第 1〜7 章は WaveForms の計器ごと (Digilent の計器ガイドと同じ順) で、公式の
ガイドを隣に開いて進められる。第 8 章でブレッドボードの限界を測り、第 9 章から
応用 (アンプ・電源・自動化・混合信号)。

- **板の印**: BB = ブレッドボード (10 MHz まで)、PF = perfboard (それより上)、
  — = 板を使わない
- **機種の印**: AD3 = Analog Discovery 3 でしかできない題 (Tracer・CZT・25 MHz の
  インピーダンスなど)。本文に AD2 での代わりのやり方を書く。印の無い題は AD2 でも AD3 でも同じ
- **安全**: 入力は ±25 V まで。電源は USB 給電で 1 系統 250 mW まで。
  商用電源は扱わない
- 10 MHz より上 (数 GHz まで) は [NanoVNA の教科書](../03-nanovna/README.md) で測る

<!-- toc:start -->

必須・入門・中級は計画の数で、入れ子で数える (入門は必須を含み、中級は全部)。
済 は書き終えた題の数。書き終えた題は link になっている。

| 章 | 題名 | 必須 | 入門 | 中級 | 済 |
| --- | --- | --- | --- | --- | --- |
| 0 | 道具と安全 | 4 | 6 | 10 | 6 |
| 1 | WaveForms の基本 | 6 | 10 | 16 | 10 |
| 2 | オシロスコープ | 8 | 16 | 28 | 16 |
| 3 | 波形発生器 | 5 | 10 | 18 | 10 |
| 4 | FFT とスペクトラム | 5 | 10 | 20 | 10 |
| 5 | ネットワークアナライザ | 6 | 12 | 22 | 12 |
| 6 | インピーダンス測定 | 4 | 8 | 16 | 8 |
| 7 | ロジックとプロトコル | 4 | 10 | 18 | 5 |
| 8 | ブレッドボードの限界と perfboard | 4 | 8 | 14 | 8 |
| 9 | アンプの特性 | 2 | 6 | 16 | 6 |
| 10 | 電源と雑音 | 1 | 2 | 8 | 2 |
| 11 | 自動化 | 1 | 2 | 8 | 2 |
| 12 | デジタルと混合信号 | 0 | 0 | 6 | 0 |
| **計** | | **50** | **100** | **200** | **95** |

## 第 0 章 道具と安全

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 0-1 | [接続と極性 — ワイヤの色、1+ / 1- の差動入力、GND を共通に](00-tools/01-connections.md) | 必須 | BB | |
| 0-2 | [入力範囲 ±25 V と電源の限界 — 電源ツールで電流を制限する](00-tools/02-input-range-power-limits.md) | 必須 | — | |
| 0-3 | [ループバック — W1 を 1+ に直結して発生器とオシロを確かめる](00-tools/03-loopback.md) | 必須 | — | |
| 0-4 | [ワークスペースの保存、CSV と画像の書き出し](00-tools/04-workspace-save-export.md) | 必須 | — | |
| 0-5 | [BNC アダプタと 10:1 プローブ — 帯域 9 MHz と 30 MHz の違い](00-tools/05-bnc-probe-bandwidth.md) | 入門 | — | |
| 0-6 | [付属ワイヤと同軸で同じ 5 MHz の方形波を見比べる](00-tools/06-wire-vs-coax-square-wave.md) | 入門 | BB | |
| 0-7 | 外部電源で電源ツールを 700 mA まで使う | 中級 | BB | |
| 0-8 | トリガ入出力 (T1 / T2) で 2 台を同期する | 中級 | — | |
| 0-9 | AD2 と AD3 を同じ実験で比べる (帯域・バッファ長) | 中級 | BB | |
| 0-10 | デバイスの校正 (WaveForms の Calibration) | 中級 | — | |

## 第 1 章 WaveForms の基本

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 1-1 | [Supplies — +5 V と −5 V を出して電圧計で読む](01-waveforms/01-supplies.md) | 必須 | BB | |
| 1-2 | [1 kHz の正弦波を出してオシロで見る (最初の 1 本)](01-waveforms/02-first-sine.md) | 必須 | BB | |
| 1-3 | [電圧計とデータロガー — 分圧回路を 1 分記録する](01-waveforms/03-voltmeter-logger.md) | 必須 | BB | |
| 1-4 | [Static I/O — LED とボタンを DIO で](01-waveforms/04-static-io.md) | 必須 | BB | |
| 1-5 | [Script の最初の 1 行 — 波形を出し、測り、表にする](01-waveforms/05-script-basics.md) | 必須 | BB | |
| 1-6 | [画面の構成 — 計器の窓、Run / Stop / Single、Help](01-waveforms/06-ui-layout.md) | 必須 | — | |
| 1-7 | [波形発生器 2 ch の同期と位相差](01-waveforms/07-wavegen-2ch-phase.md) | 入門 | — | |
| 1-8 | [電源の電流制限で LED を守る](01-waveforms/08-current-limit-led.md) | 入門 | BB | |
| 1-9 | [データロガーで温度 (LM35) を 10 分](01-waveforms/09-logger-lm35.md) | 入門 | BB | |
| 1-10 | [デバイスマネージャ — バッファ長と ch 数の構成を切り替える](01-waveforms/10-device-manager-buffer.md) | 入門 | — | AD3 |
| 1-11 | Supplies のトラッキング (± 対称) | 中級 | BB | AD3 |
| 1-12 | 電圧計の AC / DC / True RMS | 中級 | BB | |
| 1-13 | ロガーを Script から回して CSV に追記する | 中級 | BB | |
| 1-14 | 計器を同時に走らせる (Scope + Spectrum + Logger) | 中級 | BB | |
| 1-15 | プロジェクトとプリセットで設定を使い回す | 中級 | — | |
| 1-16 | Raspberry Pi で WaveForms を動かす (Linux 版) | 中級 | — | |

## 第 2 章 オシロスコープ

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 2-1 | [トリガの基本 — エッジ・レベル・ホールドオフ](02-oscilloscope/01-trigger-basics.md) | 必須 | BB | |
| 2-2 | [測定 (Measurements) — Vpp・RMS・周波数・デューティ](02-oscilloscope/02-measurements.md) | 必須 | BB | |
| 2-3 | [カーソルで RC の時定数を読む](02-oscilloscope/03-cursors-rc.md) | 必須 | BB | |
| 2-4 | [差動入力で電流を測る — 1 Ω の両端](02-oscilloscope/04-differential-current.md) | 必須 | BB | |
| 2-5 | [XY 表示 — リサージュ図形](02-oscilloscope/05-xy-lissajous.md) | 必須 | — | |
| 2-6 | [Math チャネル — 差・積 (瞬時電力)・積分](02-oscilloscope/06-math-channel.md) | 必須 | BB | |
| 2-7 | [Persistence でノイズとジッタを見る](02-oscilloscope/07-persistence.md) | 必須 | BB | |
| 2-8 | [デジタル ch を並べる (MSO) — 555 の出力と 4017 の分周](02-oscilloscope/08-mso-555-4017.md) | 必須 | BB | |
| 2-9 | [10:1 プローブの補正と入力容量の影響](02-oscilloscope/09-probe-compensation.md) | 入門 | BB | |
| 2-10 | [帯域の違いを方形波の立ち上がりで見る (9 / 30 MHz)](02-oscilloscope/10-bandwidth-rise-time.md) | 入門 | — | |
| 2-11 | [Record モードで長時間 (ディスクへ)](02-oscilloscope/11-record-mode.md) | 入門 | BB | |
| 2-12 | [トリガ: パルス幅・ラント・タイムアウト](02-oscilloscope/12-pulse-runt-timeout-trigger.md) | 入門 | BB | |
| 2-13 | [ダイオードの順方向特性を XY で描く (Tracer の前段)](02-oscilloscope/13-diode-xy-curve.md) | 入門 | BB | |
| 2-14 | [平均化と 14 bit の分解能](02-oscilloscope/14-averaging-resolution.md) | 入門 | BB | |
| 2-15 | [参照波形と重ねて比べる](02-oscilloscope/15-reference-waveform.md) | 入門 | — | |
| 2-16 | [サンプリングとエイリアス — 1 MHz を 1.2 MS/s で見る](02-oscilloscope/16-sampling-alias.md) | 入門 | — | |
| 2-17 | シュミットトリガのヒステリシスを XY で | 中級 | BB | |
| 2-18 | 電源投入の突入電流 (Single トリガ) | 中級 | BB | |
| 2-19 | リレーの接点バウンス | 中級 | BB | |
| 2-20 | 充放電を Math の log で直線にする | 中級 | BB | |
| 2-21 | FIR フィルタ ch でノイズを除く | 中級 | BB | AD3 |
| 2-22 | ロックインアンプ ch で埋もれた信号を取り出す | 中級 | BB | AD3 |
| 2-23 | デジタル ch (バスの値) でトリガする | 中級 | BB | |
| 2-24 | 立ち上がり時間から帯域を逆算する (tr = 0.35 / BW) | 中級 | — | |
| 2-25 | プローブの GND リードのリンギング | 中級 | BB | |
| 2-26 | 2 ch の時間差 — ゲートの伝搬遅延 | 中級 | BB | |
| 2-27 | 測定のヒストグラムと統計 | 中級 | BB | |
| 2-28 | 30 MHz の正弦を BNC で見る (perfboard) | 中級 | PF | |

## 第 3 章 波形発生器

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 3-1 | [正弦・方形・三角・ノコギリ・DC と振幅・オフセット](03-wavegen/01-basic-waveforms.md) | 必須 | — | |
| 3-2 | [周波数掃引 (Sweep) をオシロで追う](03-wavegen/02-sweep.md) | 必須 | BB | |
| 3-3 | [AM / FM 変調](03-wavegen/03-am-fm.md) | 必須 | — | |
| 3-4 | [カスタム波形 (CSV) と Play](03-wavegen/04-custom-waveform.md) | 必須 | — | |
| 3-5 | [出力に 50 Ω を付けたときの落ち込み — 出力インピーダンス](03-wavegen/05-output-impedance.md) | 必須 | BB | |
| 3-6 | [バースト・トリガで単発パルス](03-wavegen/06-burst-pulse.md) | 入門 | BB | |
| 3-7 | [ノイズ波形と RC フィルタ](03-wavegen/07-noise-rc-filter.md) | 入門 | BB | |
| 3-8 | [2 ch で差動信号](03-wavegen/08-differential-signal.md) | 入門 | BB | |
| 3-9 | [音を出す (オーディオ出力)](03-wavegen/09-audio-output.md) | 入門 | — | |
| 3-10 | [数式で波形 (sin x + sin 3x) を作って FFT へ](03-wavegen/10-formula-waveform.md) | 入門 | — | |
| 3-11 | PWM 波形で MOSFET 経由のモータ | 中級 | BB | |
| 3-12 | 任意波形でステップ応答 (RC・RLC) | 中級 | BB | |
| 3-13 | 変調度と側波帯 (FFT と対) | 中級 | — | |
| 3-14 | 位相変調と PSK | 中級 | — | |
| 3-15 | 出力の帯域 (12 MHz) — 10 MHz の方形波はどう見えるか | 中級 | — | |
| 3-16 | DC オフセットでバイアス点を振る (トランジスタの動作点) | 中級 | BB | |
| 3-17 | 波形発生器をシリアル信号源にする (Pattern の代替) | 中級 | BB | |
| 3-18 | 外部トリガ (T1) で同期する | 中級 | — | |

## 第 4 章 FFT とスペクトラム

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 4-1 | [正弦波の FFT — 基本波と高調波](04-spectrum/01-sine-fft.md) | 必須 | — | |
| 4-2 | [方形波の高調波 (奇数次)](04-spectrum/02-square-harmonics.md) | 必須 | — | |
| 4-3 | [窓関数 (矩形・Hann・Flat-top) の違い](04-spectrum/03-windows.md) | 必須 | — | |
| 4-4 | [THD と SNR — 波形発生器自身の歪](04-spectrum/04-thd-snr.md) | 必須 | — | |
| 4-5 | [ノイズフロアと平均化](04-spectrum/05-noise-floor-averaging.md) | 必須 | — | |
| 4-6 | [CZT (ズーム) で狭帯域を見る](04-spectrum/06-czt-zoom.md) | 入門 | — | AD3 |
| 4-7 | [AM 波のスペクトル — 搬送波と側波帯](04-spectrum/07-am-spectrum.md) | 入門 | — | |
| 4-8 | [FM 波のスペクトル](04-spectrum/08-fm-spectrum.md) | 入門 | — | |
| 4-9 | [555 の出力スペクトル](04-spectrum/09-555-spectrum.md) | 入門 | BB | |
| 4-10 | [マイクの音のスペクトル](04-spectrum/10-mic-spectrum.md) | 入門 | BB | |
| 4-11 | 分解能帯域幅とサンプル数 | 中級 | — | |
| 4-12 | SFDR | 中級 | — | |
| 4-13 | 抵抗の熱雑音と 1/f ノイズ (増幅して) | 中級 | BB | |
| 4-14 | 2 トーンで相互変調 (IMD) の入口 | 中級 | BB | |
| 4-15 | PWM のスペクトルとローパス | 中級 | BB | |
| 4-16 | スイッチング電源のノイズのスペクトル | 中級 | BB | |
| 4-17 | ピークホールドとウォーターフォール | 中級 | — | |
| 4-18 | 位相雑音のまね (裾の広がり) | 中級 | BB | |
| 4-19 | AM ラジオの IF 455 kHz を見る | 中級 | BB | |
| 4-20 | マイクの周波数特性 (ピンクノイズ) | 中級 | BB | |

## 第 5 章 ネットワークアナライザ

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 5-1 | [RC ローパスのボード線図](05-network/01-rc-lowpass-bode.md) | 必須 | BB | |
| 5-2 | [RC ハイパス](05-network/02-rc-highpass.md) | 必須 | BB | |
| 5-3 | [RL と LC の共振](05-network/03-rl-lc-resonance.md) | 必須 | BB | |
| 5-4 | [位相の読み方と −3 dB 点](05-network/04-phase-and-3db.md) | 必須 | BB | |
| 5-5 | [掃引の設定 — 開始・終了・ステップ・振幅・平均](05-network/05-sweep-settings.md) | 必須 | — | |
| 5-6 | [オペアンプ非反転増幅の利得と帯域 (GBW)](05-network/06-non-inverting-gbw.md) | 必須 | BB | |
| 5-7 | [Nyquist / Nichols 表示](05-network/07-nyquist-nichols.md) | 入門 | BB | |
| 5-8 | [9 MHz の壁 — スルーで NA 自身の特性を取る](05-network/08-9mhz-wall.md) | 入門 | — | |
| 5-9 | [2 段 RC と −40 dB/dec](05-network/09-two-stage-rc-40db.md) | 入門 | BB | |
| 5-10 | [CR 発振器の帰還路をループを切って測る](05-network/10-cr-oscillator-loop.md) | 入門 | BB | |
| 5-11 | [ツイン T ノッチ](05-network/11-twin-t-notch.md) | 入門 | BB | |
| 5-12 | [外部発振器モード (Wavegen を使わない)](05-network/12-external-oscillator-mode.md) | 入門 | — | |
| 5-13 | 反転増幅の入力インピーダンスと周波数 | 中級 | BB | |
| 5-14 | ボルテージフォロアの容量負荷とピーキング | 中級 | BB | |
| 5-15 | サレンキー LPF の Q | 中級 | BB | |
| 5-16 | 状態変数フィルタ | 中級 | BB | |
| 5-17 | 位相余裕 (ループを切る) | 中級 | BB | |
| 5-18 | トランスの周波数特性 | 中級 | BB | |
| 5-19 | ケーブル 1 m の 10 MHz まで | 中級 | — | |
| 5-20 | 10:1 プローブ込みの NA | 中級 | BB | |
| 5-21 | バーアンテナ + バリコンの同調曲線 | 中級 | BB | |
| 5-22 | 25 MHz まで (BNC、perfboard) | 中級 | PF | |

## 第 6 章 インピーダンス測定

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 6-1 | [抵抗の \|Z\| と位相 — 基準抵抗で測る仕組み](06-impedance/01-resistor-z-phase.md) | 必須 | BB | |
| 6-2 | [コンデンサの C と ESR](06-impedance/02-capacitor-c-esr.md) | 必須 | BB | |
| 6-3 | [コイルの L と Q](06-impedance/03-inductor-l-q.md) | 必須 | BB | |
| 6-4 | [自己共振 (SRF) — 100 µH のコイルが容量になる所](06-impedance/04-self-resonance.md) | 必須 | BB | |
| 6-5 | [インピーダンスアナライザアダプタ (自動レンジ)](06-impedance/05-impedance-adapter-autorange.md) | 入門 | — | |
| 6-6 | [電解とセラミックの違い](06-impedance/06-electrolytic-vs-ceramic.md) | 入門 | BB | |
| 6-7 | [Open / Short 補償](06-impedance/07-open-short-compensation.md) | 入門 | BB | |
| 6-8 | [バーアンテナの L と Q](06-impedance/08-bar-antenna-l-q.md) | 入門 | BB | |
| 6-9 | セラミックの DC バイアス依存 (X7R) | 中級 | BB | |
| 6-10 | 25 MHz まで — 0.1 µF の SRF | 中級 | PF | AD3 |
| 6-11 | 水晶の fs / fp (10 MHz 以下) | 中級 | BB | |
| 6-12 | フェライトビーズ (10 MHz まで) | 中級 | BB | |
| 6-13 | スピーカーのインピーダンス曲線 | 中級 | — | |
| 6-14 | 圧電ブザーの共振 | 中級 | BB | |
| 6-15 | 電池の内部抵抗 (AC) | 中級 | — | |
| 6-16 | サーミスタ・CdS のインピーダンス vs 温度・光 | 中級 | BB | |

## 第 7 章 ロジックとプロトコル

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 7-1 | [ロジックアナライザで 555 と 4017 を見る](07-logic/01-logic-555-4017.md) | 必須 | BB | |
| 7-2 | [パターンジェネレータでカウンタを叩く](07-logic/02-pattern-counter.md) | 必須 | BB | |
| 7-3 | [UART を見る (Pico)](07-logic/03-uart-pico.md) | 必須 | BB | |
| 7-4 | [I2C を見る・叩く (温度センサ)](07-logic/04-i2c-temperature.md) | 必須 | BB | |
| 7-5 | [SPI](07-logic/05-spi.md) | 入門 | BB | |
| 7-6 | プロトコルアナライザから送信する | 入門 | BB | |
| 7-7 | バスの値でトリガする | 入門 | BB | |
| 7-8 | セットアップ・ホールド時間を測る | 入門 | BB | |
| 7-9 | チャタリングを捕まえる | 入門 | BB | |
| 7-10 | PWM のデューティを測る | 入門 | BB | |
| 7-11 | 74HC595 を叩いて 7 セグを点ける | 中級 | BB | |
| 7-12 | ゲートの伝搬遅延を Pattern + Scope で | 中級 | BB | |
| 7-13 | I2C のプルアップと立ち上がり (アナログ ch 併用) | 中級 | BB | |
| 7-14 | 1-Wire (DS18B20) | 中級 | BB | |
| 7-15 | ロジックのしきい値 (3.3 V / 5 V) と判定 | 中級 | BB | |
| 7-16 | パターンで状態機械 (ROM もどき) | 中級 | BB | |
| 7-17 | デバウンス回路の評価 (Static I/O + Scope) | 中級 | BB | |
| 7-18 | マイコンの起動ログ (UART) を長時間 Record | 中級 | BB | |

## 第 8 章 ブレッドボードの限界と perfboard

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 8-1 | [ジャンパ 1 本のスルーの S21 を 100 kHz〜10 MHz](08-breadboard-limits/01-jumper-s21.md) | 必須 | BB | |
| 8-2 | [隣の列との容量 (数 pF) を測る](08-breadboard-limits/02-row-capacitance.md) | 必須 | BB | |
| 8-3 | [ジャンパ線のインダクタンス](08-breadboard-limits/03-jumper-inductance.md) | 必須 | BB | |
| 8-4 | [RC ローパスの理論と実測のずれ (1 MHz と 10 MHz)](08-breadboard-limits/04-rc-lowpass-deviation.md) | 必須 | BB | |
| 8-5 | [クロストーク — 隣の列に何が漏れるか](08-breadboard-limits/05-crosstalk.md) | 入門 | BB | |
| 8-6 | [レールの GND インピーダンス](08-breadboard-limits/06-rail-impedance.md) | 入門 | BB | |
| 8-7 | [同じ回路を perfboard で作って比べる](08-breadboard-limits/07-perfboard-comparison.md) | 入門 | BB / PF | |
| 8-8 | [同じスルーを BNC で 25 MHz まで、NanoVNA で 1〜100 MHz](08-breadboard-limits/08-bnc-vs-nanovna.md) | 入門 | PF | |
| 8-9 | デカップリングの置き場所 (近い / 遠い) | 中級 | BB | |
| 8-10 | GND の取り回し — 1 点接地とループ | 中級 | BB | |
| 8-11 | 長いワイヤのアンテナ効果 (放送波の混入) | 中級 | BB | |
| 8-12 | 電源レールのノイズ (スイッチング電源を載せる) | 中級 | BB | |
| 8-13 | perfboard の GND 面 (銅テープ) の効果 | 中級 | PF | |
| 8-14 | 10 MHz の方形波が届くジャンパの長さ | 中級 | BB | |

## 第 9 章 アンプの特性

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 9-1 | [エミッタ接地の利得と帯域 (NA)](09-amplifiers/01-common-emitter-bandwidth.md) | 必須 | BB | |
| 9-2 | [オペアンプの GBW とスルーレート](09-amplifiers/02-opamp-gbw-slew-rate.md) | 必須 | BB | |
| 9-3 | [1 dB 圧縮点](09-amplifiers/03-1db-compression.md) | 入門 | BB | |
| 9-4 | [2 トーン IMD (Wavegen 2 ch + FFT)](09-amplifiers/04-two-tone-imd.md) | 入門 | BB | |
| 9-5 | [THD vs 出力](09-amplifiers/05-thd-vs-output.md) | 入門 | BB | |
| 9-6 | [Tracer でトランジスタの Ic–Vce 曲線](09-amplifiers/06-tracer-ic-vce.md) | 入門 | BB | AD3 |
| 9-7 | hFE の実測 | 中級 | BB | |
| 9-8 | MOSFET の Id–Vgs | 中級 | BB | |
| 9-9 | 位相余裕 (ループを切る) | 中級 | BB | |
| 9-10 | 入力インピーダンス (直列抵抗法) | 中級 | BB | |
| 9-11 | 出力インピーダンス (負荷法) | 中級 | BB | |
| 9-12 | PSRR | 中級 | BB | |
| 9-13 | CMRR (差動) | 中級 | BB | |
| 9-14 | LM386 の周波数特性と歪 | 中級 | BB | |
| 9-15 | プッシュプルのクロスオーバー歪を FFT で | 中級 | BB | |
| 9-16 | 入力換算雑音 | 中級 | BB | |

## 第 10 章 電源と雑音

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 10-1 | [リップルを FFT で](10-power-noise/01-ripple-fft.md) | 必須 | BB | |
| 10-2 | [負荷過渡応答](10-power-noise/02-load-transient.md) | 入門 | BB | |
| 10-3 | レギュレータの PSRR | 中級 | BB | |
| 10-4 | 出力インピーダンス vs 周波数 | 中級 | BB | |
| 10-5 | デカップリングの効果 | 中級 | BB | |
| 10-6 | スイッチングノイズ | 中級 | BB | |
| 10-7 | LDO vs スイッチング | 中級 | BB | |
| 10-8 | グラウンドループ | 中級 | BB | |

## 第 11 章 自動化

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 11-1 | [Script で掃引と測定を自動化 (1-5 の続き)](11-automation/01-script-sweep.md) | 必須 | — | |
| 11-2 | [WaveForms SDK (Python) の最初](11-automation/02-sdk-first-steps.md) | 入門 | — | |
| 11-3 | 部品 10 個のバッチ測定 | 中級 | BB | |
| 11-4 | CSV をグラフにする (matplotlib) | 中級 | — | |
| 11-5 | SDK でオシロを取り込み、FFT を自分で書く | 中級 | — | |
| 11-6 | Script で合否判定 (検査もどき) | 中級 | BB | |
| 11-7 | ロガーの長期記録 (1 日) | 中級 | BB | |
| 11-8 | 測った値を tommie-fence の図に注釈で載せる | 中級 | — | |

## 第 12 章 デジタルと混合信号

| # | 題 | 段 | 板 | 機種 |
| --- | --- | --- | --- | --- |
| 12-1 | Pico の ADC の特性 (直線性・雑音) | 中級 | BB | |
| 12-2 | PWM + RC で DAC | 中級 | BB | |
| 12-3 | クロックのオーバーシュートとリンギング | 中級 | BB | |
| 12-4 | ジッタ | 中級 | BB | |
| 12-5 | アイパターンのまね | 中級 | BB | |
| 12-6 | ADC のサンプリングとエイリアスを Pico で | 中級 | BB | |

<!-- toc:end -->
