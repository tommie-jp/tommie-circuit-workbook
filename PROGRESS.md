# 進捗

`npm run progress` が計画 (`plan.yaml`) と題の front matter から書く。**箱以外は手で直さない。**

- **作成** — 題のファイルがあれば ✓ と link。まだの題は字だけ
- **目で確認** (箱) — 題の front matter の `seen: YYYY-MM-DD` (人が目で確認した日)。
  **目で確認したら箱を `[x]` にして** (括弧の中に x を打つ) `npm run progress` を回す。
  題の front matter に `seen: <今日>` が入り、日付がここに出る。`[ ]` に戻せば `seen` が消える
- **Fable で確認** — 題の front matter の `reviewed: YYYY-MM-DD` (Claude (Fable) で確認した日。— はまだ)

確認した日より後に題を書き換えていれば ✓ でなく △ で出し、箱を空にして数に入れない (確認し直して、また箱を付ける)。

| 冊 | 計画 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| [回路の教科書](01-circuits/README.md) | 219 | 120 | 0 | 0 |
| [Analog Discovery の教科書](02-analog-discovery/README.md) | 202 | 100 | 0 | 0 |
| [NanoVNA と tinySA の教科書](03-nanovna/README.md) | 223 | 114 | 0 | 0 |
| [電験三種の教科書](04-denken/README.md) | 200 | 100 | 0 | 0 |
| [番外の工作](05-etc/README.md) | 25 | 22 | 0 | 0 |
| [FPGA の教科書](06-fpga/README.md) | 206 | 124 | 0 | 0 |
| **計** | **1075** | **580** | **0** | **0** |

## 回路の教科書

### 第 0 章 測定と道具

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 0-1 | [テスターで電圧・電流・抵抗を測る — 分圧回路を相手に](01-circuits/00-measure/01-multimeter.md) | ✓ | [ ] | — |
| 0-2 | [ブレッドボードの導通と回路図の読み方 — 同じ列、レール、ネット](01-circuits/00-measure/02-continuity.md) | ✓ | [ ] | — |
| 0-3 | [オシロスコープで波形を見る — 555 の出力を PC オシロ / AD3 で](01-circuits/00-measure/03-oscilloscope.md) | ✓ | [ ] | — |
| 0-4 | [自作テスター — 分流器と倍率器](01-circuits/00-measure/04-shunt-multiplier.md) | ✓ | [ ] | — |
| 0-5 | [hFE チェッカー](01-circuits/00-measure/05-hfe-checker.md) | ✓ | [ ] | — |
| 0-6 | [安定化電源とファンクションジェネレータ — 電流制限を掛けて実験する](01-circuits/00-measure/06-bench-supply-limiting.md) | ✓ | [ ] | — |
| 0-7 | テブナン等価を測って確かめる | | | |
| 0-8 | コンデンサ容量計 — ブリッジで測る | | | |
| 0-9 | 周波数カウンタ (CMOS) | | | |
| 0-10 | ロジックプローブと音で聞く検出器 | | | |

### 第 1 章 基本 — 直流と受動部品

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 1-1 | [LED を点ける — 抵抗で電流を決める](01-circuits/01-basics/01-led.md) | ✓ | [ ] | — |
| 1-2 | [直列・並列と分圧](01-circuits/01-basics/02-series-parallel.md) | ✓ | [ ] | — |
| 1-3 | [コンデンサの充放電 — RC 時定数を LED で見る](01-circuits/01-basics/03-rc-charge.md) | ✓ | [ ] | — |
| 1-4 | [ダイオードの向きと順方向電圧 — LED の色で比べる](01-circuits/01-basics/04-diode-direction.md) | ✓ | [ ] | — |
| 1-5 | [RC ローパス・ハイパス](01-circuits/01-basics/05-rc-filter.md) | ✓ | [ ] | — |
| 1-6 | [ポテンショメータで分圧 (電位差計)](01-circuits/01-basics/06-potentiometer-divider.md) | ✓ | [ ] | — |
| 1-7 | [ホイートストンブリッジ](01-circuits/01-basics/07-wheatstone-bridge.md) | ✓ | [ ] | — |
| 1-8 | [コンデンサの直列・並列と時定数の比較](01-circuits/01-basics/08-cap-series-parallel.md) | ✓ | [ ] | — |
| 1-9 | [ダイオードのクリッパとクランパ](01-circuits/01-basics/09-diode-clipper-clamper.md) | ✓ | [ ] | — |
| 1-10 | 倍電圧 — ダイオードとコンデンサで (コッククロフト) | | | |
| 1-11 | LC 共振 — 直列と並列 | | | |
| 1-12 | 保護素子 — ヒューズ・PTC・バリスタ | | | |
| 1-13 | ツェナーで基準電圧 | | | |
| 1-14 | じゃがいも電池・レモン電池 | | | |
| 1-15 | 熱電対 — 2 種の金属で電圧 | | | |
| 1-16 | 電球の非線形 — 抵抗の温度係数 | | | |

### 第 2 章 トランジスタ — BJT と FET

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 2-1 | [トランジスタスイッチ (LED)](01-circuits/02-transistors/01-transistor-switch.md) | ✓ | [ ] | — |
| 2-2 | [エミッタフォロア](01-circuits/02-transistors/02-emitter-follower.md) | ✓ | [ ] | — |
| 2-3 | [エミッタ接地増幅 (自己バイアス)](01-circuits/02-transistors/03-common-emitter.md) | ✓ | [ ] | — |
| 2-4 | [ダーリントン — 指で触れて点く](01-circuits/02-transistors/04-darlington-touch.md) | ✓ | [ ] | — |
| 2-5 | [MOSFET スイッチ (2N7000、ロジックレベル)](01-circuits/02-transistors/05-mosfet-switch.md) | ✓ | [ ] | — |
| 2-6 | [差動増幅](01-circuits/02-transistors/06-differential-amp.md) | ✓ | [ ] | — |
| 2-7 | [カレントミラー](01-circuits/02-transistors/07-current-mirror.md) | ✓ | [ ] | — |
| 2-8 | [コレクタ帰還バイアスと分圧バイアスの比較](01-circuits/02-transistors/08-bias-comparison.md) | ✓ | [ ] | — |
| 2-9 | [JFET の定電流](01-circuits/02-transistors/09-jfet-current-source.md) | ✓ | [ ] | — |
| 2-10 | [プッシュプル (B 級) とクロスオーバー歪](01-circuits/02-transistors/10-push-pull.md) | ✓ | [ ] | — |
| 2-11 | [PNP のハイサイドスイッチ](01-circuits/02-transistors/11-pnp-high-side.md) | ✓ | [ ] | — |
| 2-12 | カスコード | | | |
| 2-13 | シュミットトリガ (Tr 2 石) | | | |
| 2-14 | 定電流源 — Tr + ツェナー / 2 石 | | | |
| 2-15 | 2 段増幅と負帰還 | | | |
| 2-16 | A 級パワーアンプ (スピーカーを鳴らす) | | | |
| 2-17 | MOSFET のゲート駆動 — ゲート抵抗・プルダウン・ミラー容量 | | | |
| 2-18 | IGBT スイッチ | | | |
| 2-19 | フォトカプラで絶縁 | | | |
| 2-20 | サイリスタ・トライアックの点弧 (低圧 AC) | | | |
| 2-21 | エミッタ抵抗を分ける — バイアスと利得を別々に決める | | | |

### 第 3 章 発振とタイマー

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 3-1 | [非安定マルチバイブレータ — LED 交互点滅](01-circuits/03-oscillators/01-astable-multivibrator.md) | ✓ | [ ] | — |
| 3-2 | [555 非安定 — LED 点滅](01-circuits/03-oscillators/02-555-astable.md) | ✓ | [ ] | — |
| 3-3 | [555 単安定 — タイマー](01-circuits/03-oscillators/03-555-monostable.md) | ✓ | [ ] | — |
| 3-4 | [弛張発振 — Tr 2 石でブザー](01-circuits/03-oscillators/04-relaxation-oscillator-buzzer.md) | ✓ | [ ] | — |
| 3-5 | [水晶発振 — CMOS インバータ + 水晶](01-circuits/03-oscillators/05-crystal-oscillator.md) | ✓ | [ ] | — |
| 3-6 | [555 の PWM — ボリュームで LED 調光](01-circuits/03-oscillators/06-555-pwm.md) | ✓ | [ ] | — |
| 3-7 | [ウィーンブリッジ — OP アンプで正弦波](01-circuits/03-oscillators/07-wien-bridge.md) | ✓ | [ ] | — |
| 3-8 | [シュミット CMOS (40106) の RC 発振](01-circuits/03-oscillators/08-schmitt-rc-oscillator.md) | ✓ | [ ] | — |
| 3-9 | 単安定 (Tr 2 石) | | | |
| 3-10 | コルピッツ | | | |
| 3-11 | 移相発振 (RC 3 段) | | | |
| 3-12 | 555 を 2 段 — サイレン | | | |
| 3-13 | VCO — 555 の 5 番ピン | | | |
| 3-14 | LM3909 (古典) と自動点滅 LED (現代) を並べる | | | |
| 3-15 | リングオシレータ (インバータ 3 段) | | | |

### 第 4 章 OP アンプ

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 4-1 | [ボルテージフォロア](01-circuits/04-opamps/01-voltage-follower.md) | ✓ | [ ] | — |
| 4-2 | [非反転増幅](01-circuits/04-opamps/02-non-inverting-amp.md) | ✓ | [ ] | — |
| 4-3 | [反転増幅](01-circuits/04-opamps/03-inverting-amp.md) | ✓ | [ ] | — |
| 4-4 | [比較器 — CdS でしきい値](01-circuits/04-opamps/04-comparator-cds.md) | ✓ | [ ] | — |
| 4-5 | [加算 (ミキサー)](01-circuits/04-opamps/05-summing-amp.md) | ✓ | [ ] | — |
| 4-6 | [積分器](01-circuits/04-opamps/06-integrator.md) | ✓ | [ ] | — |
| 4-7 | [差動増幅](01-circuits/04-opamps/07-differential-amp.md) | ✓ | [ ] | — |
| 4-8 | [シュミットトリガ (ヒステリシス)](01-circuits/04-opamps/08-schmitt-trigger.md) | ✓ | [ ] | — |
| 4-9 | [微分器](01-circuits/04-opamps/09-differentiator.md) | ✓ | [ ] | — |
| 4-10 | [アクティブ ローパス (サレンキー)](01-circuits/04-opamps/10-sallen-key-lowpass.md) | ✓ | [ ] | — |
| 4-11 | [単電源での使い方 — 仮想 GND、レール to レール](01-circuits/04-opamps/11-single-supply.md) | ✓ | [ ] | — |
| 4-12 | 精密整流とピークホールド | | | |
| 4-13 | 計装アンプ (OP アンプ 3 つ) | | | |
| 4-14 | 電流→電圧 (トランスインピーダンス、フォトダイオード) | | | |
| 4-15 | 電圧→電流 (定電流 LED ドライバ) | | | |
| 4-16 | ハイパス・バンドパス | | | |
| 4-17 | コンパレータ IC (LM393、オープンコレクタ) | | | |
| 4-18 | ウィンドウコンパレータ | | | |
| 4-19 | 三角波・方形波発生器 (積分 + シュミット) | | | |
| 4-20 | 帰還の安定性 — 容量負荷と位相補償 | | | |

### 第 5 章 電源

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 5-1 | [半波・全波・ブリッジ整流と平滑 (低圧 AC)](01-circuits/05-power-supplies/01-rectifier-filter.md) | ✓ | [ ] | — |
| 5-2 | [ツェナー + Tr のシリーズレギュレータ](01-circuits/05-power-supplies/02-zener-series-regulator.md) | ✓ | [ ] | — |
| 5-3 | [3 端子レギュレータ (7805)](01-circuits/05-power-supplies/03-three-terminal-regulator.md) | ✓ | [ ] | — |
| 5-4 | [LDO — USB 5 V → 3.3 V](01-circuits/05-power-supplies/04-ldo-usb.md) | ✓ | [ ] | — |
| 5-5 | [昇圧 — Joule thief](01-circuits/05-power-supplies/05-joule-thief.md) | ✓ | [ ] | — |
| 5-6 | [降圧スイッチング (MC34063 かモジュール)](01-circuits/05-power-supplies/06-buck-converter.md) | ✓ | [ ] | — |
| 5-7 | [チャージポンプ — 555 で負電圧](01-circuits/05-power-supplies/07-charge-pump-negative.md) | ✓ | [ ] | — |
| 5-8 | [Li-ion 充電 (TP4056 モジュール) と保護](01-circuits/05-power-supplies/08-liion-charging.md) | ✓ | [ ] | — |
| 5-9 | [逆接続保護 — ダイオード / P-MOSFET](01-circuits/05-power-supplies/09-reverse-polarity-protection.md) | ✓ | [ ] | — |
| 5-10 | 定電流 (LM317) | | | |
| 5-11 | 昇圧スイッチング (MT3608) | | | |
| 5-12 | 電池残量チェッカー | | | |
| 5-13 | ソーラー + スーパーキャパシタ | | | |
| 5-14 | リップルとデカップリングの実測 | | | |
| 5-15 | 電源の保護 — ヒューズ・PTC・TVS | | | |
| 5-16 | 負電源 (ICL7660) | | | |
| 5-17 | 電流制限 (フォールドバック) | | | |

### 第 6 章 トランスとコイル

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 6-1 | [トランスの基本 — 低圧 AC で昇圧・降圧・絶縁](01-circuits/06-transformers/01-transformer-basics.md) | ✓ | [ ] | — |
| 6-2 | [コイルの逆起電力 — 切った瞬間に LED が光る、フライバックダイオード](01-circuits/06-transformers/02-back-emf.md) | ✓ | [ ] | — |
| 6-3 | [自作トランス — 巻数比を測る](01-circuits/06-transformers/03-diy-transformer.md) | ✓ | [ ] | — |
| 6-4 | [センタータップと全波整流](01-circuits/06-transformers/04-center-tap-rectifier.md) | ✓ | [ ] | — |
| 6-5 | [磁界を聞く — コイル + 音](01-circuits/06-transformers/05-listen-to-magnetic-field.md) | ✓ | [ ] | — |
| 6-6 | フライバックコンバータ (小型) | | | |
| 6-7 | インダクタの飽和 | | | |
| 6-8 | 相互誘導と極性 (ドット) | | | |
| 6-9 | 電流トランス | | | |
| 6-10 | ワイヤレス給電 — 共振コイルで LED | | | |

### 第 7 章 パワー

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 7-1 | [リレー駆動 — Tr + フライバックダイオード](01-circuits/07-power/01-relay-driver.md) | ✓ | [ ] | — |
| 7-2 | [DC モータの PWM (MOSFET)](01-circuits/07-power/02-motor-pwm.md) | ✓ | [ ] | — |
| 7-3 | [H ブリッジ — 正転・逆転](01-circuits/07-power/03-h-bridge.md) | ✓ | [ ] | — |
| 7-4 | [ステッピングモータ (ULN2003)](01-circuits/07-power/04-stepper-motor.md) | ✓ | [ ] | — |
| 7-5 | [サーボ — パルス幅で角度](01-circuits/07-power/05-servo-pulse-angle.md) | ✓ | [ ] | — |
| 7-6 | [パワー LED の定電流](01-circuits/07-power/06-power-led-constant-current.md) | ✓ | [ ] | — |
| 7-7 | [ハイサイドとローサイド](01-circuits/07-power/07-high-side-low-side.md) | ✓ | [ ] | — |
| 7-8 | ゲートドライバ IC | | | |
| 7-9 | ブラシレスの原理 (3 相、簡略) | | | |
| 7-10 | ソレノイド | | | |
| 7-11 | 電子負荷 | | | |
| 7-12 | 熱設計 — 放熱と温度の実測 | | | |
| 7-13 | トライアックの位相制御 (低圧 AC) | | | |
| 7-14 | ソリッドステートリレー (フォトトライアック) | | | |

### 第 8 章 センサー

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 8-1 | [CdS で暗くなると点く](01-circuits/08-sensors/01-cds.md) | ✓ | [ ] | — |
| 8-2 | [サーミスタで温度アラーム](01-circuits/08-sensors/02-thermistor-alarm.md) | ✓ | [ ] | — |
| 8-3 | [タッチスイッチ (人体)](01-circuits/08-sensors/03-touch-switch.md) | ✓ | [ ] | — |
| 8-4 | [マイクで音に反応](01-circuits/08-sensors/04-mic.md) | ✓ | [ ] | — |
| 8-5 | [赤外線 LED とフォトトランジスタ — 遮光検出](01-circuits/08-sensors/05-photointerrupter.md) | ✓ | [ ] | — |
| 8-6 | [人感 (PIR モジュール)](01-circuits/08-sensors/06-pir.md) | ✓ | [ ] | — |
| 8-7 | [超音波 (HC-SR04)](01-circuits/08-sensors/07-ultrasonic.md) | ✓ | [ ] | — |
| 8-8 | [ホール素子 (磁石)](01-circuits/08-sensors/08-hall-sensor.md) | ✓ | [ ] | — |
| 8-9 | [水位・土壌湿度 (電極)](01-circuits/08-sensors/09-water-level-electrodes.md) | ✓ | [ ] | — |
| 8-10 | [温度センサー IC (LM35 / TMP36)](01-circuits/08-sensors/10-temperature-ic.md) | ✓ | [ ] | — |
| 8-11 | リードスイッチ | | | |
| 8-12 | 圧電 (ノック) | | | |
| 8-13 | 加速度 (モジュール) | | | |
| 8-14 | 静電容量タッチ — 発振周波数の変化 | | | |
| 8-15 | ロータリーエンコーダ | | | |
| 8-16 | 湿度 (DHT) | | | |
| 8-17 | 気圧 (I2C) | | | |
| 8-18 | 太陽電池を光センサーに | | | |
| 8-19 | フォトダイオードの短絡電流 | | | |
| 8-20 | LED を受光素子に | | | |

### 第 9 章 RF — ラジオと送信

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 9-1 | [LC 同調 — 共振を LED で見る](01-circuits/09-rf/01-lc-resonance.md) | ✓ | [ ] | — |
| 9-2 | [ゲルマラジオ](01-circuits/09-rf/02-crystal-radio.md) | ✓ | [ ] | — |
| 9-3 | [1 石ラジオ — トランジスタの高周波増幅とダイオード検波](01-circuits/09-rf/03-one-transistor-radio.md) | ✓ | [ ] | — |
| 9-4 | [FM 送信機 (1 石)](01-circuits/09-rf/04-fm-transmitter.md) | ✓ | [ ] | — |
| 9-5 | [1 石レフレックスラジオ](01-circuits/09-rf/05-reflex-radio.md) | ✓ | [ ] | — |
| 9-6 | [超再生 FM ラジオ](01-circuits/09-rf/06-superregen-fm.md) | ✓ | [ ] | — |
| 9-7 | [AM 変調 — 555 の搬送波を音声で振る](01-circuits/09-rf/07-am-modulation.md) | ✓ | [ ] | — |
| 9-8 | [ラジオ IC (LMF501T / TA7642)](01-circuits/09-rf/08-radio-ic.md) | ✓ | [ ] | — |
| 9-9 | [2 石ラジオ — 高周波増幅 + 低周波増幅](01-circuits/09-rf/09-two-transistor-radio.md) | ✓ | [ ] | — |
| 9-10 | [スーパーヘテロダイン (6 石、IF 455 kHz)](01-circuits/09-rf/10-superheterodyne.md) | ✓ | [ ] | — |
| 9-11 | [ダイオード検波とトランジスタ検波の比較](01-circuits/09-rf/11-detector-comparison.md) | ✓ | [ ] | — |
| 9-12 | [バランスドミキサー](01-circuits/09-rf/12-balanced-mixer.md) | ✓ | [ ] | — |
| 9-13 | [FM 復調 — スロープ検波](01-circuits/09-rf/13-fm-slope-detector.md) | ✓ | [ ] | — |
| 9-14 | [27 MHz の送受信 (トイラジコン)](01-circuits/09-rf/14-27mhz-rc-toy.md) | ✓ | [ ] | — |
| 9-15 | [アンテナ — ダイポールとループ、SWR](01-circuits/09-rf/15-antenna-dipole-loop.md) | ✓ | [ ] | — |
| 9-16 | [DDS モジュール — Pico 2 で 7 MHz を出して tinySA で見る](01-circuits/09-rf/16-dds-sdr-module.md) | ✓ | [ ] | — |
| 9-17 | [2.4 GHz モジュール (nRF24) と Pico 2](01-circuits/09-rf/17-nrf24-pico.md) | ✓ | [ ] | — |
| 9-25 | [AGC — 強い局で音量が跳ねないように利得を自動で下げる](01-circuits/09-rf/25-agc.md) | ✓ | [ ] | — |
| 9-26 | 送信のファイナルを並列にする — エミッタバラスト抵抗で電流をそろえる (2N3866) | | | |

### 第 10 章 ロジック

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 10-1 | [ゲートの基本 — スイッチと LED で AND / OR / NOT](01-circuits/10-logic/01-basic-gates.md) | ✓ | [ ] | — |
| 10-2 | [RS ラッチ (NAND)](01-circuits/10-logic/02-rs-latch.md) | ✓ | [ ] | — |
| 10-3 | [半加算器と全加算器 (XOR + AND)](01-circuits/10-logic/03-adders.md) | ✓ | [ ] | — |
| 10-4 | [バイナリカウンタ (4 bit、4040)](01-circuits/10-logic/04-binary-counter.md) | ✓ | [ ] | — |
| 10-5 | [D フリップフロップ (4013) と T フリップフロップ](01-circuits/10-logic/05-d-flip-flop.md) | ✓ | [ ] | — |
| 10-6 | [シフトレジスタ (74HC595)](01-circuits/10-logic/06-shift-register.md) | ✓ | [ ] | — |
| 10-7 | [7 セグメントとデコーダ (4511)](01-circuits/10-logic/07-seven-segment.md) | ✓ | [ ] | — |
| 10-8 | [4 bit 加算器 (74HC283)](01-circuits/10-logic/08-four-bit-adder.md) | ✓ | [ ] | — |
| 10-9 | チャタリング除去 — RC + シュミット | | | |
| 10-10 | ジョンソンカウンタ (4017) — LED 順送り | | | |
| 10-11 | 4 bit ALU もどき — 加算と減算 (2 の補数) (05-etc の 1-2 へ移した) | | | |
| 10-12 | CPU もどき — レジスタ + 加算器 + クロック (05-etc の 1-4 へ移した) | | | |
| 10-13 | メモリ — フリップフロップ 4 bit (05-etc の 1-3 へ移した) | | | |
| 10-14 | プログラムカウンタ (05-etc の 1-1 が担う) | | | |
| 10-15 | トランジスタで作るゲート (RTL / DTL) | | | |
| 10-16 | オープンドレインと配線 AND、プルアップ | | | |
| 10-17 | レベル変換 (3.3V ↔ 5V) | | | |
| 10-18 | I2C バスの電気 — プルアップと容量 | | | |
| 10-19 | 電子サイコロ (4017 + 555) | | | |
| 10-20 | 4 ビット CPU のようなもの — カウンタとメモリと命令 (05-etc の 1-1 へ移した) | | | |

### 第 11 章 マイコンと現代の定番

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 11-1 | [Pico 2 の L チカ](01-circuits/11-microcontrollers/01-pico-blink.md) | ✓ | [ ] | — |
| 11-2 | [ボタン入力とプルアップ](01-circuits/11-microcontrollers/02-button-pullup.md) | ✓ | [ ] | — |
| 11-3 | [ADC で CdS を読む](01-circuits/11-microcontrollers/03-adc-cds.md) | ✓ | [ ] | — |
| 11-4 | [PWM で LED 調光とサーボ](01-circuits/11-microcontrollers/04-pwm-led-servo.md) | ✓ | [ ] | — |
| 11-5 | [I2C センサー (温度)](01-circuits/11-microcontrollers/05-i2c-temperature.md) | ✓ | [ ] | — |
| 11-6 | SPI (シフトレジスタ / 表示) | | | |
| 11-7 | UART — Pico 2 台で通信 | | | |
| 11-8 | 割り込みとロータリーエンコーダ | | | |
| 11-9 | モータドライバ (DRV8833) | | | |
| 11-10 | Pico 2 W で しきい値を通知 | | | |
| 11-11 | USB 給電と電源設計 (VSYS / VBUS) | | | |
| 11-12 | デカップリングとグラウンド | | | |

### 第 12 章 実用回路 — 作品

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 12-1 | [おやすみタイマー — 555 単安定 + MOSFET](01-circuits/12-projects/01-goodnight-timer.md) | ✓ | [ ] | — |
| 12-2 | [人感ライト — PIR + CdS + MOSFET](01-circuits/12-projects/02-motion-light.md) | ✓ | [ ] | — |
| 12-3 | [水漏れ・水位アラーム](01-circuits/12-projects/03-water-alarm.md) | ✓ | [ ] | — |
| 12-4 | 電子ホタル — フェードイン・アウト | | | |
| 12-5 | ドアチャイム / メロディ IC | | | |
| 12-6 | インターホン (LM386) | | | |
| 12-7 | 電池チェッカー | | | |
| 12-8 | 植物の水やりアラーム | | | |
| 12-9 | LED イルミネーション (4017) | | | |
| 12-10 | ソーラーガーデンライト | | | |

### 第 13 章 電源装置 — 定電圧・定電流の使い方

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 13-1 | [定電圧 (CV) で使う — 電圧を決めて電流制限を掛ける](01-circuits/13-bench-supply/01-cv-mode.md) | ✓ | [ ] | — |
| 13-2 | [定電流 (CC) で使う — 抵抗なしで LED を光らせる](01-circuits/13-bench-supply/02-cc-mode.md) | ✓ | [ ] | — |
| 13-3 | [CV と CC の切り替わりを負荷で見る](01-circuits/13-bench-supply/03-cv-cc-crossover.md) | ✓ | [ ] | — |
| 13-4 | ±電源を作る — 2 ch の直列と GND の取り方 | | | |
| 13-5 | 並列と直列で電流・電圧を足す | | | |
| 13-6 | 出力の内部抵抗と負荷変動 | | | |
| 13-7 | 電流制限で回路を守る — 短絡・逆接続・起動時の突入電流 | | | |
| 13-8 | 定電流で充電する — NiMH と、やってはいけない Li-ion | | | |

### 第 14 章 I/Q と直接変換 — 90° の 2 本で受ける

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 14-1 | [RC-CR で 90° を作る — 1 本の正弦から I と Q](01-circuits/14-iq/01-rc-cr-quadrature.md) | ✓ | [ ] | — |
| 14-2 | [I/Q ミキサー — RF が LO の上か下かを知る](01-circuits/14-iq/02-iq-mixer.md) | ✓ | [ ] | — |
| 14-3 | [イメージ除去 — 位相法 (Hartley)](01-circuits/14-iq/03-image-reject-hartley.md) | ✓ | [ ] | — |
| 14-4 | [SSB を作る — 位相法の送信側](01-circuits/14-iq/04-ssb-phasing.md) | ✓ | [ ] | — |
| 14-5 | [Tayloe 検波器 — 74HC4052 で I/Q を音にする (直接変換)](01-circuits/14-iq/05-tayloe-detector.md) | ✓ | [ ] | — |
| 14-6 | [I/Q をマイコンで読む — Pico 2 の ADC で位相と大きさを計算する](01-circuits/14-iq/06-iq-pico2-adc.md) | ✓ | [ ] | — |
| 14-7 | [IQ 中波ラジオ — バーアンテナと 74HC4052 と Pico 2 で NHK を聞く](01-circuits/14-iq/07-iq-mw-radio.md) | ✓ | [ ] | — |

## Analog Discovery の教科書

### 第 0 章 道具と安全

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 0-1 | [接続と極性 — ワイヤの色、1+ / 1- の差動入力、GND を共通に](02-analog-discovery/00-tools/01-connections.md) | ✓ | [ ] | — |
| 0-2 | [入力範囲 ±25 V と電源の限界 — 電流は直列抵抗で決める](02-analog-discovery/00-tools/02-input-range-power-limits.md) | ✓ | [ ] | — |
| 0-3 | [ループバック — W1 を 1+ に直結して発生器とオシロを確かめる](02-analog-discovery/00-tools/03-loopback.md) | ✓ | [ ] | — |
| 0-4 | [ワークスペースの保存、CSV と画像の書き出し](02-analog-discovery/00-tools/04-workspace-save-export.md) | ✓ | [ ] | — |
| 0-5 | [BNC アダプタと 10:1 プローブ — 帯域 9 MHz と 30 MHz の違い](02-analog-discovery/00-tools/05-bnc-probe-bandwidth.md) | ✓ | [ ] | — |
| 0-6 | [付属ワイヤと同軸で同じ 5 MHz の方形波を見比べる](02-analog-discovery/00-tools/06-wire-vs-coax-square-wave.md) | ✓ | [ ] | — |
| 0-7 | 外部電源で電源ツールを 700 mA まで使う | | | |
| 0-8 | トリガ入出力 (T1 / T2) で 2 台を同期する | | | |
| 0-9 | AD3 の BNC アダプタ有りと無し (ヘッダ直結) を比べる (帯域・バッファ長) | | | |
| 0-10 | デバイスの校正 (WaveForms の Calibration) | | | |

### 第 1 章 WaveForms の基本

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 1-1 | [Supplies — +5 V と −5 V を出して電圧計で読む](02-analog-discovery/01-waveforms/01-supplies.md) | ✓ | [ ] | — |
| 1-2 | [1 kHz の正弦波を出してオシロで見る (最初の 1 本)](02-analog-discovery/01-waveforms/02-first-sine.md) | ✓ | [ ] | — |
| 1-3 | [電圧計とデータロガー — 分圧回路を 1 分記録する](02-analog-discovery/01-waveforms/03-voltmeter-logger.md) | ✓ | [ ] | — |
| 1-4 | [Static I/O — LED とボタンを DIO で](02-analog-discovery/01-waveforms/04-static-io.md) | ✓ | [ ] | — |
| 1-5 | [Script の最初の 1 行 — 波形を出し、測り、表にする](02-analog-discovery/01-waveforms/05-script-basics.md) | ✓ | [ ] | — |
| 1-6 | [画面の構成 — 計器の窓、Run / Stop / Single、Help](02-analog-discovery/01-waveforms/06-ui-layout.md) | ✓ | [ ] | — |
| 1-7 | [波形発生器 2 ch の同期と位相差](02-analog-discovery/01-waveforms/07-wavegen-2ch-phase.md) | ✓ | [ ] | — |
| 1-8 | [電源の電圧と直列抵抗で LED の電流を決める](02-analog-discovery/01-waveforms/08-current-limit-led.md) | ✓ | [ ] | — |
| 1-9 | [データロガーで温度 (LM35) を 10 分](02-analog-discovery/01-waveforms/09-logger-lm35.md) | ✓ | [ ] | — |
| 1-10 | [デバイスマネージャ — 計器ごとのバッファ長の配分を切り替える](02-analog-discovery/01-waveforms/10-device-manager-buffer.md) | ✓ | [ ] | — |
| 1-11 | Supplies のトラッキング (± 対称) | | | |
| 1-12 | 電圧計の AC / DC / True RMS | | | |
| 1-13 | ロガーを Script から回して CSV に追記する | | | |
| 1-14 | 計器を同時に走らせる (Scope + Spectrum + Logger) | | | |
| 1-15 | プロジェクトとプリセットで設定を使い回す | | | |
| 1-16 | Raspberry Pi で WaveForms を動かす (Linux 版) | | | |

### 第 2 章 オシロスコープ

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 2-1 | [トリガの基本 — エッジ・レベル・ホールドオフ](02-analog-discovery/02-oscilloscope/01-trigger-basics.md) | ✓ | [ ] | — |
| 2-2 | [測定 (Measurements) — Vpp・RMS・周波数・デューティ](02-analog-discovery/02-oscilloscope/02-measurements.md) | ✓ | [ ] | — |
| 2-3 | [カーソルで RC の時定数を読む](02-analog-discovery/02-oscilloscope/03-cursors-rc.md) | ✓ | [ ] | — |
| 2-4 | [差動入力で電流を測る — 1 Ω の両端](02-analog-discovery/02-oscilloscope/04-differential-current.md) | ✓ | [ ] | — |
| 2-5 | [XY 表示 — リサージュ図形](02-analog-discovery/02-oscilloscope/05-xy-lissajous.md) | ✓ | [ ] | — |
| 2-6 | [Math チャネル — 差・積 (瞬時電力)・積分](02-analog-discovery/02-oscilloscope/06-math-channel.md) | ✓ | [ ] | — |
| 2-7 | [Persistence でノイズとジッタを見る](02-analog-discovery/02-oscilloscope/07-persistence.md) | ✓ | [ ] | — |
| 2-8 | [デジタル ch を並べる (MSO) — 555 の出力と 4017 の分周](02-analog-discovery/02-oscilloscope/08-mso-555-4017.md) | ✓ | [ ] | — |
| 2-9 | [10:1 プローブの補正と入力容量の影響](02-analog-discovery/02-oscilloscope/09-probe-compensation.md) | ✓ | [ ] | — |
| 2-10 | [帯域の違いを方形波の立ち上がりで見る (9 / 30 MHz)](02-analog-discovery/02-oscilloscope/10-bandwidth-rise-time.md) | ✓ | [ ] | — |
| 2-11 | [Record モードで長時間 (ディスクへ)](02-analog-discovery/02-oscilloscope/11-record-mode.md) | ✓ | [ ] | — |
| 2-12 | [トリガ: パルス幅・ラント・タイムアウト](02-analog-discovery/02-oscilloscope/12-pulse-runt-timeout-trigger.md) | ✓ | [ ] | — |
| 2-13 | [ダイオードの順方向特性を XY で描く (Tracer の前段)](02-analog-discovery/02-oscilloscope/13-diode-xy-curve.md) | ✓ | [ ] | — |
| 2-14 | [平均化と 14 bit の分解能](02-analog-discovery/02-oscilloscope/14-averaging-resolution.md) | ✓ | [ ] | — |
| 2-15 | [参照波形と重ねて比べる](02-analog-discovery/02-oscilloscope/15-reference-waveform.md) | ✓ | [ ] | — |
| 2-16 | [サンプリングとエイリアス — 1 MHz を 1.2 MS/s で見る](02-analog-discovery/02-oscilloscope/16-sampling-alias.md) | ✓ | [ ] | — |
| 2-17 | シュミットトリガのヒステリシスを XY で | | | |
| 2-18 | 電源投入の突入電流 (Single トリガ) | | | |
| 2-19 | リレーの接点バウンス | | | |
| 2-20 | 充放電を Math の log で直線にする | | | |
| 2-21 | FIR フィルタ ch でノイズを除く | | | |
| 2-22 | ロックインアンプ ch で埋もれた信号を取り出す | | | |
| 2-23 | デジタル ch (バスの値) でトリガする | | | |
| 2-24 | 立ち上がり時間から帯域を逆算する (tr = 0.35 / BW) | | | |
| 2-25 | プローブの GND リードのリンギング | | | |
| 2-26 | 2 ch の時間差 — ゲートの伝搬遅延 | | | |
| 2-27 | 測定のヒストグラムと統計 | | | |
| 2-28 | 30 MHz の正弦を BNC で見る (perfboard) | | | |

### 第 3 章 波形発生器

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 3-1 | [正弦・方形・三角・ノコギリ・DC と振幅・オフセット](02-analog-discovery/03-wavegen/01-basic-waveforms.md) | ✓ | [ ] | — |
| 3-2 | [周波数掃引 (Sweep) をオシロで追う](02-analog-discovery/03-wavegen/02-sweep.md) | ✓ | [ ] | — |
| 3-3 | [AM / FM 変調](02-analog-discovery/03-wavegen/03-am-fm.md) | ✓ | [ ] | — |
| 3-4 | [カスタム波形 (CSV) と Play](02-analog-discovery/03-wavegen/04-custom-waveform.md) | ✓ | [ ] | — |
| 3-5 | [出力に 50 Ω を付けたときの落ち込み — 出力インピーダンス](02-analog-discovery/03-wavegen/05-output-impedance.md) | ✓ | [ ] | — |
| 3-6 | [バースト・トリガで単発パルス](02-analog-discovery/03-wavegen/06-burst-pulse.md) | ✓ | [ ] | — |
| 3-7 | [ノイズ波形と RC フィルタ](02-analog-discovery/03-wavegen/07-noise-rc-filter.md) | ✓ | [ ] | — |
| 3-8 | [2 ch で差動信号](02-analog-discovery/03-wavegen/08-differential-signal.md) | ✓ | [ ] | — |
| 3-9 | [音を出す (オーディオ出力)](02-analog-discovery/03-wavegen/09-audio-output.md) | ✓ | [ ] | — |
| 3-10 | [数式で波形 (sin x + sin 3x) を作って FFT へ](02-analog-discovery/03-wavegen/10-formula-waveform.md) | ✓ | [ ] | — |
| 3-11 | PWM 波形で MOSFET 経由のモータ | | | |
| 3-12 | 任意波形でステップ応答 (RC・RLC) | | | |
| 3-13 | 変調度と側波帯 (FFT と対) | | | |
| 3-14 | 位相変調と PSK | | | |
| 3-15 | 出力の帯域 (12 MHz) — 10 MHz の方形波はどう見えるか | | | |
| 3-16 | DC オフセットでバイアス点を振る (トランジスタの動作点) | | | |
| 3-17 | 波形発生器をシリアル信号源にする (Pattern の代替) | | | |
| 3-18 | 外部トリガ (T1) で同期する | | | |

### 第 4 章 FFT とスペクトラム

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 4-1 | [正弦波の FFT — 基本波と高調波](02-analog-discovery/04-spectrum/01-sine-fft.md) | ✓ | [ ] | — |
| 4-2 | [方形波の高調波 (奇数次)](02-analog-discovery/04-spectrum/02-square-harmonics.md) | ✓ | [ ] | — |
| 4-3 | [窓関数 (矩形・Hann・Flat-top) の違い](02-analog-discovery/04-spectrum/03-windows.md) | ✓ | [ ] | — |
| 4-4 | [THD と SNR — 波形発生器自身の歪](02-analog-discovery/04-spectrum/04-thd-snr.md) | ✓ | [ ] | — |
| 4-5 | [ノイズフロアと平均化](02-analog-discovery/04-spectrum/05-noise-floor-averaging.md) | ✓ | [ ] | — |
| 4-6 | [CZT (ズーム) で狭帯域を見る](02-analog-discovery/04-spectrum/06-czt-zoom.md) | ✓ | [ ] | — |
| 4-7 | [AM 波のスペクトル — 搬送波と側波帯](02-analog-discovery/04-spectrum/07-am-spectrum.md) | ✓ | [ ] | — |
| 4-8 | [FM 波のスペクトル](02-analog-discovery/04-spectrum/08-fm-spectrum.md) | ✓ | [ ] | — |
| 4-9 | [555 の出力スペクトル](02-analog-discovery/04-spectrum/09-555-spectrum.md) | ✓ | [ ] | — |
| 4-10 | [マイクの音のスペクトル](02-analog-discovery/04-spectrum/10-mic-spectrum.md) | ✓ | [ ] | — |
| 4-11 | 分解能帯域幅とサンプル数 | | | |
| 4-12 | SFDR | | | |
| 4-13 | 抵抗の熱雑音と 1/f ノイズ (増幅して) | | | |
| 4-14 | 2 トーンで相互変調 (IMD) の入口 | | | |
| 4-15 | PWM のスペクトルとローパス | | | |
| 4-16 | スイッチング電源のノイズのスペクトル | | | |
| 4-17 | ピークホールドとウォーターフォール | | | |
| 4-18 | 位相雑音のまね (裾の広がり) | | | |
| 4-19 | AM ラジオの IF 455 kHz を見る | | | |
| 4-20 | マイクの周波数特性 (ピンクノイズ) | | | |

### 第 5 章 ネットワークアナライザ

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 5-1 | [RC ローパスのボード線図](02-analog-discovery/05-network/01-rc-lowpass-bode.md) | ✓ | [ ] | — |
| 5-2 | [RC ハイパス](02-analog-discovery/05-network/02-rc-highpass.md) | ✓ | [ ] | — |
| 5-3 | [RL と LC の共振](02-analog-discovery/05-network/03-rl-lc-resonance.md) | ✓ | [ ] | — |
| 5-4 | [位相の読み方と −3 dB 点](02-analog-discovery/05-network/04-phase-and-3db.md) | ✓ | [ ] | — |
| 5-5 | [掃引の設定 — 開始・終了・ステップ・振幅・平均](02-analog-discovery/05-network/05-sweep-settings.md) | ✓ | [ ] | — |
| 5-6 | [オペアンプ非反転増幅の利得と帯域 (GBW)](02-analog-discovery/05-network/06-non-inverting-gbw.md) | ✓ | [ ] | — |
| 5-7 | [Nyquist / Nichols 表示](02-analog-discovery/05-network/07-nyquist-nichols.md) | ✓ | [ ] | — |
| 5-8 | [9 MHz の壁 — スルーで NA 自身の特性を取る](02-analog-discovery/05-network/08-9mhz-wall.md) | ✓ | [ ] | — |
| 5-9 | [2 段 RC と −40 dB/dec](02-analog-discovery/05-network/09-two-stage-rc-40db.md) | ✓ | [ ] | — |
| 5-10 | [CR 発振器の帰還路をループを切って測る](02-analog-discovery/05-network/10-cr-oscillator-loop.md) | ✓ | [ ] | — |
| 5-11 | [ツイン T ノッチ](02-analog-discovery/05-network/11-twin-t-notch.md) | ✓ | [ ] | — |
| 5-12 | [外部発振器モード (Wavegen を使わない)](02-analog-discovery/05-network/12-external-oscillator-mode.md) | ✓ | [ ] | — |
| 5-13 | 反転増幅の入力インピーダンスと周波数 | | | |
| 5-14 | ボルテージフォロアの容量負荷とピーキング | | | |
| 5-15 | サレンキー LPF の Q | | | |
| 5-16 | 状態変数フィルタ | | | |
| 5-17 | 位相余裕 (ループを切る) | | | |
| 5-18 | トランスの周波数特性 | | | |
| 5-19 | ケーブル 1 m の 10 MHz まで | | | |
| 5-20 | 10:1 プローブ込みの NA | | | |
| 5-21 | バーアンテナ + バリコンの同調曲線 | | | |
| 5-22 | 25 MHz まで (BNC、perfboard) | | | |

### 第 6 章 インピーダンス測定

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 6-1 | [抵抗の \|Z\| と位相 — 基準抵抗で測る仕組み](02-analog-discovery/06-impedance/01-resistor-z-phase.md) | ✓ | [ ] | — |
| 6-2 | [コンデンサの C と ESR](02-analog-discovery/06-impedance/02-capacitor-c-esr.md) | ✓ | [ ] | — |
| 6-3 | [コイルの L と Q](02-analog-discovery/06-impedance/03-inductor-l-q.md) | ✓ | [ ] | — |
| 6-4 | [自己共振 (SRF) — 100 µH のコイルが容量になる所](02-analog-discovery/06-impedance/04-self-resonance.md) | ✓ | [ ] | — |
| 6-5 | [インピーダンスアナライザアダプタ (自動レンジ)](02-analog-discovery/06-impedance/05-impedance-adapter-autorange.md) | ✓ | [ ] | — |
| 6-6 | [電解とセラミックの違い](02-analog-discovery/06-impedance/06-electrolytic-vs-ceramic.md) | ✓ | [ ] | — |
| 6-7 | [Open / Short 補償](02-analog-discovery/06-impedance/07-open-short-compensation.md) | ✓ | [ ] | — |
| 6-8 | [バーアンテナの L と Q](02-analog-discovery/06-impedance/08-bar-antenna-l-q.md) | ✓ | [ ] | — |
| 6-9 | セラミックの DC バイアス依存 (X7R) | | | |
| 6-10 | 25 MHz まで — 0.1 µF の SRF | | | |
| 6-11 | 水晶の fs / fp (10 MHz 以下) | | | |
| 6-12 | フェライトビーズ (10 MHz まで) | | | |
| 6-13 | スピーカーのインピーダンス曲線 | | | |
| 6-14 | 圧電ブザーの共振 | | | |
| 6-15 | 電池の内部抵抗 (AC) | | | |
| 6-16 | サーミスタ・CdS のインピーダンス vs 温度・光 | | | |

### 第 7 章 ロジックとプロトコル

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 7-1 | [ロジックアナライザで 555 と 4017 を見る](02-analog-discovery/07-logic/01-logic-555-4017.md) | ✓ | [ ] | — |
| 7-2 | [パターンジェネレータでカウンタを叩く](02-analog-discovery/07-logic/02-pattern-counter.md) | ✓ | [ ] | — |
| 7-3 | [UART を見る (Pico 2)](02-analog-discovery/07-logic/03-uart-pico.md) | ✓ | [ ] | — |
| 7-4 | [I2C を見る・叩く (温度センサー)](02-analog-discovery/07-logic/04-i2c-temperature.md) | ✓ | [ ] | — |
| 7-5 | [SPI](02-analog-discovery/07-logic/05-spi.md) | ✓ | [ ] | — |
| 7-6 | [プロトコルアナライザから送信する](02-analog-discovery/07-logic/06-uart-echo.md) | ✓ | [ ] | — |
| 7-7 | [バスの値でトリガする](02-analog-discovery/07-logic/07-bus-trigger.md) | ✓ | [ ] | — |
| 7-8 | [セットアップ・ホールド時間を測る](02-analog-discovery/07-logic/08-setup-hold.md) | ✓ | [ ] | — |
| 7-9 | [チャタリングを捕まえる](02-analog-discovery/07-logic/09-switch-bounce.md) | ✓ | [ ] | — |
| 7-10 | [PWM のデューティを測る](02-analog-discovery/07-logic/10-pwm-duty.md) | ✓ | [ ] | — |
| 7-11 | 74HC595 を叩いて 7 セグを点ける | | | |
| 7-12 | ゲートの伝搬遅延を Pattern + Scope で | | | |
| 7-13 | I2C のプルアップと立ち上がり (アナログ ch 併用) | | | |
| 7-14 | 1-Wire (DS18B20) | | | |
| 7-15 | ロジックのしきい値 (3.3 V / 5 V) と判定 | | | |
| 7-16 | パターンで状態機械 (ROM もどき) | | | |
| 7-17 | デバウンス回路の評価 (Static I/O + Scope) | | | |
| 7-18 | マイコンの起動ログ (UART) を長時間 Record | | | |
| 7-19 | 真理値表を当てる — Pattern で入力を全部出し、Logic で 74HC00 の出力と突き合わせる | | | |
| 7-20 | 静止電流で品種を見分ける — 74LS00 と 74HC00 の電源電流をシャントで測る | | | |
| 7-21 | Pico の ADC の特性 (直線性・雑音) | | | |
| 7-22 | PWM + RC で DAC | | | |
| 7-23 | クロックのオーバーシュートとリンギング | | | |
| 7-24 | ジッタ | | | |
| 7-25 | アイパターンのまね | | | |
| 7-26 | ADC のサンプリングとエイリアスを Pico で | | | |

### 第 8 章 ブレッドボードの限界と perfboard

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 8-1 | [ジャンパ 1 本のスルーの S21 を 100 kHz〜10 MHz](02-analog-discovery/08-breadboard-limits/01-jumper-s21.md) | ✓ | [ ] | — |
| 8-2 | [隣の列との容量 (数 pF) を測る](02-analog-discovery/08-breadboard-limits/02-row-capacitance.md) | ✓ | [ ] | — |
| 8-3 | [ジャンパ線のインダクタンス](02-analog-discovery/08-breadboard-limits/03-jumper-inductance.md) | ✓ | [ ] | — |
| 8-4 | [RC ローパスの理論と実測のずれ (1 MHz と 10 MHz)](02-analog-discovery/08-breadboard-limits/04-rc-lowpass-deviation.md) | ✓ | [ ] | — |
| 8-5 | [クロストーク — 隣の列に何が漏れるか](02-analog-discovery/08-breadboard-limits/05-crosstalk.md) | ✓ | [ ] | — |
| 8-6 | [レールの GND インピーダンス](02-analog-discovery/08-breadboard-limits/06-rail-impedance.md) | ✓ | [ ] | — |
| 8-7 | [同じ回路を perfboard で作って比べる](02-analog-discovery/08-breadboard-limits/07-perfboard-comparison.md) | ✓ | [ ] | — |
| 8-8 | [同じスルーを BNC で 25 MHz まで、LiteVNA64 で 1〜100 MHz](02-analog-discovery/08-breadboard-limits/08-bnc-vs-nanovna.md) | ✓ | [ ] | — |
| 8-9 | デカップリングの置き場所 (近い / 遠い) | | | |
| 8-10 | GND の取り回し — 1 点接地とループ | | | |
| 8-11 | 長いワイヤのアンテナ効果 (放送波の混入) | | | |
| 8-12 | 電源レールのノイズ (スイッチング電源を載せる) | | | |
| 8-13 | perfboard の GND 面 (銅テープ) の効果 | | | |
| 8-14 | 10 MHz の方形波が届くジャンパの長さ | | | |

### 第 9 章 アンプの特性

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 9-1 | [エミッタ接地の利得と帯域 (NA)](02-analog-discovery/09-amplifiers/01-common-emitter-bandwidth.md) | ✓ | [ ] | — |
| 9-2 | [オペアンプの GBW とスルーレート](02-analog-discovery/09-amplifiers/02-opamp-gbw-slew-rate.md) | ✓ | [ ] | — |
| 9-3 | [1 dB 圧縮点](02-analog-discovery/09-amplifiers/03-1db-compression.md) | ✓ | [ ] | — |
| 9-4 | [2 トーン IMD (Wavegen 2 ch + FFT)](02-analog-discovery/09-amplifiers/04-two-tone-imd.md) | ✓ | [ ] | — |
| 9-5 | [THD vs 出力](02-analog-discovery/09-amplifiers/05-thd-vs-output.md) | ✓ | [ ] | — |
| 9-6 | [Tracer でトランジスタの Ic–Vce 曲線](02-analog-discovery/09-amplifiers/06-tracer-ic-vce.md) | ✓ | [ ] | — |
| 9-7 | hFE の実測 | | | |
| 9-8 | MOSFET の Id–Vgs | | | |
| 9-9 | 位相余裕 (ループを切る) | | | |
| 9-10 | 入力インピーダンス (直列抵抗法) | | | |
| 9-11 | 出力インピーダンス (負荷法) | | | |
| 9-12 | PSRR | | | |
| 9-13 | CMRR (差動) | | | |
| 9-14 | LM386 の周波数特性と歪 | | | |
| 9-15 | プッシュプルのクロスオーバー歪を FFT で | | | |
| 9-16 | 入力換算雑音 | | | |

### 第 10 章 電源と雑音

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 10-1 | [リップルを FFT で](02-analog-discovery/10-power-noise/01-ripple-fft.md) | ✓ | [ ] | — |
| 10-2 | [負荷過渡応答](02-analog-discovery/10-power-noise/02-load-transient.md) | ✓ | [ ] | — |
| 10-3 | レギュレータの PSRR | | | |
| 10-4 | 出力インピーダンス vs 周波数 | | | |
| 10-5 | デカップリングの効果 | | | |
| 10-6 | スイッチングノイズ | | | |
| 10-7 | LDO vs スイッチング | | | |
| 10-8 | グラウンドループ | | | |

### 第 11 章 自動化

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 11-1 | [Script で掃引と測定を自動化 (1-5 の続き)](02-analog-discovery/11-automation/01-script-sweep.md) | ✓ | [ ] | — |
| 11-2 | [WaveForms SDK (Python) の最初](02-analog-discovery/11-automation/02-sdk-first-steps.md) | ✓ | [ ] | — |
| 11-3 | 部品 10 個のバッチ測定 | | | |
| 11-4 | CSV をグラフにする (matplotlib) | | | |
| 11-5 | SDK でオシロを取り込み、FFT を自分で書く | | | |
| 11-6 | Script で合否判定 (検査もどき) | | | |
| 11-7 | ロガーの長期記録 (1 日) | | | |
| 11-8 | 測った値を tommie-fence の図に注釈で載せる | | | |

## NanoVNA と tinySA の教科書

### 第 0 章 道具と安全

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 0-1 | [機種と範囲 — LiteVNA64 (標準、〜6.3 GHz) と H4・V2 (比較用)、どれで何が測れるか](03-nanovna/00-tools/01-device-range.md) | ✓ | [ ] | — |
| 0-2 | [SMA の締め方・トルク・ケーブルの扱い](03-nanovna/00-tools/02-sma-care.md) | ✓ | [ ] | — |
| 0-3 | [出力レベルと CH1 の最大入力 — アンプの出力にはアッテネータ](03-nanovna/00-tools/03-output-level.md) | ✓ | [ ] | — |
| 0-4 | [静電気とアンテナの帯電 — 放電してから繋ぐ](03-nanovna/00-tools/04-esd-antenna-discharge.md) | ✓ | [ ] | — |
| 0-5 | [電池・充電・ファームウェアの更新](03-nanovna/00-tools/05-battery-firmware.md) | ✓ | [ ] | — |
| 0-6 | ケーブルの種類 (RG316 / RG174 / セミリジッド) と GHz での差 | | | |
| 0-7 | コネクタの種類 (SMA / RP-SMA / U.FL / BNC / N) と変換 | | | |
| 0-8 | 測定の再現性 — 同じ物を 10 回測る | | | |

### 第 1 章 校正

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 1-1 | [SOLT の 9 手順と保存](03-nanovna/01-calibration/01-solt.md) | ✓ | [ ] | — |
| 1-2 | [校正の 3 点を Smith チャートで確かめる (Open / Short / Load)](03-nanovna/01-calibration/02-cal-standards-smith.md) | ✓ | [ ] | — |
| 1-3 | [Thru と S21 の 0 dB](03-nanovna/01-calibration/03-thru.md) | ✓ | [ ] | — |
| 1-4 | [範囲を変えたら再校正 — 変えずに測るとどう狂うか](03-nanovna/01-calibration/04-recalibrate-range.md) | ✓ | [ ] | — |
| 1-5 | [ケーブルの先端で校正する意味 (基準面)](03-nanovna/01-calibration/05-reference-plane.md) | ✓ | [ ] | — |
| 1-6 | [校正の保存スロットと呼び出し](03-nanovna/01-calibration/06-cal-slots.md) | ✓ | [ ] | — |
| 1-7 | [校正キットの質 — 付属 / 自作 / 市販](03-nanovna/01-calibration/07-cal-kit-quality.md) | ✓ | [ ] | — |
| 1-8 | [Load の 50 Ω を DC で測って確かめる](03-nanovna/01-calibration/08-load-dc-check.md) | ✓ | [ ] | — |
| 1-9 | [校正の有効期間 — 温度と時間](03-nanovna/01-calibration/09-cal-lifetime.md) | ✓ | [ ] | — |
| 1-10 | [ポート延長 (電気長)](03-nanovna/01-calibration/10-port-extension.md) | ✓ | [ ] | — |
| 1-11 | GHz での校正 — 付属キットの限界 | | | |
| 1-12 | 校正標準のオフセット (Open の容量・Short の誘導) と定義 | | | |
| 1-13 | 校正の点数 (101 vs 1001) と Saver の分割掃引 | | | |
| 1-14 | 校正なしで測るとどう見えるか | | | |
| 1-15 | Enhanced response / 12 項校正 | | | |
| 1-16 | 校正の検証 — 別の Load とアッテネータで | | | |

### 第 2 章 画面と PC ソフト

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 2-1 | [トレースの形式 — Log Mag / 位相 / Smith / SWR](03-nanovna/02-display/01-trace-formats.md) | ✓ | [ ] | — |
| 2-2 | [マーカー 4 つと読み方](03-nanovna/02-display/02-markers.md) | ✓ | [ ] | — |
| 2-3 | [掃引の設定 — 開始・終了・中心・スパン](03-nanovna/02-display/03-sweep-settings.md) | ✓ | [ ] | — |
| 2-4 | [NanoVNA-Saver に繋ぐ](03-nanovna/02-display/04-nanovna-saver.md) | ✓ | [ ] | — |
| 2-5 | [Touchstone (.s1p / .s2p) に保存する](03-nanovna/02-display/05-touchstone.md) | ✓ | [ ] | — |
| 2-6 | [R + jX と極表示](03-nanovna/02-display/06-rx-polar.md) | ✓ | [ ] | — |
| 2-7 | [TDR (時間領域) の設定](03-nanovna/02-display/07-tdr-settings.md) | ✓ | [ ] | — |
| 2-8 | [4 トレースの割り当て (S11 / S21 × 形式)](03-nanovna/02-display/08-four-traces.md) | ✓ | [ ] | — |
| 2-9 | [NanoVNA-Saver の校正と平均化](03-nanovna/02-display/09-saver-calibration-averaging.md) | ✓ | [ ] | — |
| 2-10 | [スクリーンショットと記録](03-nanovna/02-display/10-screenshot-records.md) | ✓ | [ ] | — |
| 2-11 | NanoVNA-QT | | | |
| 2-12 | NanoVNA-App | | | |
| 2-13 | Touchstone を Python (scikit-rf) で読む | | | |
| 2-14 | 群遅延の表示 | | | |
| 2-15 | マーカーの検索 — 最小 SWR、−3 dB 点 | | | |
| 2-16 | ファームウェアの違い (DiSlord 版など) | | | |

### 第 3 章 治具

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 3-1 | [直列治具 — 部品を CH0 と CH1 の間に入れる](03-nanovna/03-fixtures/01-series-fixture.md) | ✓ | [ ] | — |
| 3-2 | [並列 (シャント) 治具](03-nanovna/03-fixtures/02-shunt-fixture.md) | ✓ | [ ] | — |
| 3-3 | [スルー治具 — 治具だけの S21](03-nanovna/03-fixtures/03-thru-fixture.md) | ✓ | [ ] | — |
| 3-4 | [自作校正キット — Open / Short / Load (50 Ω) を perfboard で](03-nanovna/03-fixtures/04-diy-cal-kit.md) | ✓ | [ ] | — |
| 3-5 | [10 dB アッテネータの製作と S21 / S11](03-nanovna/03-fixtures/05-attenuator.md) | ✓ | [ ] | — |
| 3-6 | [治具の限界周波数 — どこまで信じるか](03-nanovna/03-fixtures/06-fixture-limit.md) | ✓ | [ ] | — |
| 3-7 | [ポート延長で治具の電気長を除く](03-nanovna/03-fixtures/07-port-extension-fixture.md) | ✓ | [ ] | — |
| 3-8 | [De-embedding — 治具の S2P を引く](03-nanovna/03-fixtures/08-de-embedding.md) | ✓ | [ ] | — |
| 3-9 | [SMA オス / メスとケーブルの再現性](03-nanovna/03-fixtures/09-sma-repeatability.md) | ✓ | [ ] | — |
| 3-10 | [市販のテストボードと自作の比較](03-nanovna/03-fixtures/10-commercial-test-board.md) | ✓ | [ ] | — |
| 3-11 | 銅張り基板に直付け (Manhattan 式) の治具 | | | |
| 3-12 | マイクロストリップの治具 — FR4 で 50 Ω の幅を計算して作る | | | |
| 3-13 | GHz の治具 — 端面 SMA + 短いマイクロストリップ | | | |
| 3-14 | 治具の S パラを Touchstone で保存して使い回す | | | |
| 3-15 | 3 端子部品の治具 (トランジスタ・SAW) | | | |
| 3-16 | バイアス T — 能動部品に DC を与える | | | |
| 3-17 | 平衡素子の治具 (バラン付き) | | | |
| 3-18 | 温度をかける治具 (ヒーター) | | | |

### 第 4 章 部品の周波数特性

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 4-1 | [抵抗 (カーボン・金属皮膜) の \|Z\|](03-nanovna/04-components/01-resistor.md) | ✓ | [ ] | — |
| 4-2 | [セラミックコンデンサの SRF と ESL](03-nanovna/04-components/02-ceramic-capacitor.md) | ✓ | [ ] | — |
| 4-3 | [電解コンデンサの ESR vs 周波数](03-nanovna/04-components/03-electrolytic-capacitor.md) | ✓ | [ ] | — |
| 4-4 | [コイルの SRF と Q](03-nanovna/04-components/04-inductor.md) | ✓ | [ ] | — |
| 4-5 | [フェライトビーズ — R と X の交差](03-nanovna/04-components/05-ferrite-bead.md) | ✓ | [ ] | — |
| 4-6 | [水晶 — fs / fp / Q / 等価回路](03-nanovna/04-components/06-crystal.md) | ✓ | [ ] | — |
| 4-7 | [リード線 1 cm のインダクタンス](03-nanovna/04-components/07-lead-inductance.md) | ✓ | [ ] | — |
| 4-8 | [デカップリングの並列 (0.1 µF + 10 µF)](03-nanovna/04-components/08-decoupling.md) | ✓ | [ ] | — |
| 4-9 | [バリキャップの C vs 電圧](03-nanovna/04-components/09-varicap.md) | ✓ | [ ] | — |
| 4-10 | [小型トランスの周波数特性](03-nanovna/04-components/10-small-transformer.md) | ✓ | [ ] | — |
| 4-11 | [コモンモードチョーク](03-nanovna/04-components/11-common-mode-choke.md) | ✓ | [ ] | — |
| 4-12 | [セラミックフィルタ / SAW (部品として)](03-nanovna/04-components/12-ceramic-filter.md) | ✓ | [ ] | — |
| 4-13 | [ダイオードの接合容量](03-nanovna/04-components/13-junction-capacitance.md) | ✓ | [ ] | — |
| 4-14 | [トロイダルコアの材質比較](03-nanovna/04-components/14-toroid-materials.md) | ✓ | [ ] | — |
| 4-15 | [リレー・スイッチの S21](03-nanovna/04-components/15-relay-switch.md) | ✓ | [ ] | — |
| 4-16 | [perfboard のパターンの容量](03-nanovna/04-components/16-perfboard-capacitance.md) | ✓ | [ ] | — |
| 4-17 | チップ部品 (0603 / 0805) の SRF を GHz で | | | |
| 4-18 | フェライトビーズの GHz 特性 | | | |
| 4-19 | 空芯コイルの Q を 1 GHz 手前まで | | | |
| 4-20 | 抵抗のリード品とチップ品 (GHz) | | | |
| 4-21 | コンデンサの Q と誘電体 (C0G vs X7R) | | | |
| 4-22 | 電解 vs OS-CON vs セラミック | | | |
| 4-23 | 巻線抵抗のインダクタンス | | | |
| 4-24 | ケーブルを部品として — 容量 / m とインダクタンス / m | | | |
| 4-25 | PIN ダイオード / RF スイッチ | | | |
| 4-26 | トランス型バランの S21 と平衡度 | | | |
| 4-27 | 温度で水晶の f が動く | | | |
| 4-28 | 部品 10 個のばらつき (バッチ) | | | |

### 第 5 章 伝送線路

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 5-1 | [ケーブルの S21 と長さ (TDR)](03-nanovna/05-transmission-lines/01-cable-length.md) | ✓ | [ ] | — |
| 5-2 | [速度係数](03-nanovna/05-transmission-lines/02-velocity-factor.md) | ✓ | [ ] | — |
| 5-3 | [ケーブルの損失 (1 m、30 / 144 / 430 MHz)](03-nanovna/05-transmission-lines/03-cable-loss.md) | ✓ | [ ] | — |
| 5-4 | [断線・短絡の位置 (TDR)](03-nanovna/05-transmission-lines/04-fault-location.md) | ✓ | [ ] | — |
| 5-5 | [SWR と反射 — 終端を変えて](03-nanovna/05-transmission-lines/05-swr-termination.md) | ✓ | [ ] | — |
| 5-6 | [50 Ω と 75 Ω の違い](03-nanovna/05-transmission-lines/06-fifty-vs-seventy-five.md) | ✓ | [ ] | — |
| 5-7 | [スタブ (開放・短絡)](03-nanovna/05-transmission-lines/07-stub.md) | ✓ | [ ] | — |
| 5-8 | [λ/4 変成器](03-nanovna/05-transmission-lines/08-quarter-wave-transformer.md) | ✓ | [ ] | — |
| 5-9 | [コネクタの不連続 (TDR)](03-nanovna/05-transmission-lines/09-connector-discontinuity.md) | ✓ | [ ] | — |
| 5-10 | [特性インピーダンスの測定 (Zoc と Zsc から)](03-nanovna/05-transmission-lines/10-z0-from-zoc-zsc.md) | ✓ | [ ] | — |
| 5-11 | [ケーブルの温度](03-nanovna/05-transmission-lines/11-cable-temperature.md) | ✓ | [ ] | — |
| 5-12 | [平行 2 線 (ラダーライン)](03-nanovna/05-transmission-lines/12-ladder-line.md) | ✓ | [ ] | — |
| 5-13 | GHz でのケーブル損失 (2.4 GHz) | | | |
| 5-14 | U.FL ピグテールの損失 | | | |
| 5-15 | マイクロストリップの Zo と FR4 の誘電率 | | | |
| 5-16 | コプレーナ線路 | | | |
| 5-17 | セミリジッドと柔らかいケーブルの位相安定性 | | | |
| 5-18 | ケーブルを曲げると何が変わるか | | | |
| 5-19 | コネクタの質 (真鍮 vs 金メッキ) を GHz で | | | |
| 5-20 | TDR の分解能と帯域 (H4 vs V2) | | | |
| 5-21 | スルーホール (via) の不連続 | | | |
| 5-22 | 遅延線を群遅延で | | | |

### 第 6 章 フィルタ

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 6-1 | [LC ローパス (7 次)](03-nanovna/06-filters/01-lc-lowpass.md) | ✓ | [ ] | — |
| 6-2 | [LC ハイパス](03-nanovna/06-filters/02-lc-highpass.md) | ✓ | [ ] | — |
| 6-3 | [LC バンドパス](03-nanovna/06-filters/03-lc-bandpass.md) | ✓ | [ ] | — |
| 6-4 | [挿入損失と反射損失 (S21 と S11)](03-nanovna/06-filters/04-insertion-return-loss.md) | ✓ | [ ] | — |
| 6-5 | [設計と実測 — バターワース vs チェビシェフ](03-nanovna/06-filters/05-design-vs-measured.md) | ✓ | [ ] | — |
| 6-6 | [ノッチ](03-nanovna/06-filters/06-notch.md) | ✓ | [ ] | — |
| 6-7 | [水晶ラダーフィルタ](03-nanovna/06-filters/07-crystal-ladder.md) | ✓ | [ ] | — |
| 6-8 | [群遅延](03-nanovna/06-filters/08-group-delay.md) | ✓ | [ ] | — |
| 6-9 | [ダイプレクサ](03-nanovna/06-filters/09-diplexer.md) | ✓ | [ ] | — |
| 6-10 | [π 型と T 型](03-nanovna/06-filters/10-pi-and-t.md) | ✓ | [ ] | — |
| 6-11 | [部品の許容差の影響](03-nanovna/06-filters/11-component-tolerance.md) | ✓ | [ ] | — |
| 6-12 | [セラミックフィルタ 455 kHz / 10.7 MHz](03-nanovna/06-filters/12-ceramic-filter.md) | ✓ | [ ] | — |
| 6-13 | SAW フィルタ 433 / 915 MHz | | | |
| 6-14 | マイクロストリップ LPF (ステップインピーダンス、1 GHz) | | | |
| 6-15 | 2.4 GHz バンドパス (インターディジタル / ヘアピン) | | | |
| 6-16 | 2.4 GHz ノッチ (スタブ) | | | |
| 6-17 | QRP 送信機の高調波フィルタ (7 MHz、2 倍・3 倍を見る) | | | |
| 6-18 | 同軸スタブのノッチ (144 / 430 MHz) | | | |
| 6-19 | 温度による変化 | | | |
| 6-20 | ヘリカルフィルタ | | | |
| 6-21 | 入出力の整合 (50 Ω 以外) がフィルタをどう歪めるか | | | |
| 6-22 | コムラインの模型 | | | |
| 6-23 | GPS 1.575 GHz の SAW | | | |
| 6-24 | Wi-Fi 2.4 GHz の帯域外減衰 | | | |

### 第 7 章 アンテナ

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 7-1 | [SWR とインピーダンスの読み方](03-nanovna/07-antennas/01-swr-impedance-reading.md) | ✓ | [ ] | — |
| 7-2 | [ダイポール (144 MHz) の調整](03-nanovna/07-antennas/02-dipole-144mhz.md) | ✓ | [ ] | — |
| 7-3 | [ホイップ (430 MHz) の共振](03-nanovna/07-antennas/03-whip-430mhz.md) | ✓ | [ ] | — |
| 7-4 | [L 型整合](03-nanovna/07-antennas/04-l-network-matching.md) | ✓ | [ ] | — |
| 7-5 | [バーアンテナ + バリコン (中波)](03-nanovna/07-antennas/05-loopstick-varicap.md) | ✓ | [ ] | — |
| 7-6 | [アンテナの帯域幅 (SWR 2 の幅)](03-nanovna/07-antennas/06-antenna-bandwidth.md) | ✓ | [ ] | — |
| 7-7 | [ループアンテナ](03-nanovna/07-antennas/07-loop-antenna.md) | ✓ | [ ] | — |
| 7-8 | [バランの有無](03-nanovna/07-antennas/08-balun.md) | ✓ | [ ] | — |
| 7-9 | [トラップ](03-nanovna/07-antennas/09-trap.md) | ✓ | [ ] | — |
| 7-10 | [λ/4 グラウンドプレーン](03-nanovna/07-antennas/10-ground-plane.md) | ✓ | [ ] | — |
| 7-11 | [手・近くの物の影響](03-nanovna/07-antennas/11-hand-effect.md) | ✓ | [ ] | — |
| 7-12 | [433 / 920 MHz のモジュール用アンテナ (LoRa)](03-nanovna/07-antennas/12-lora-module-antenna.md) | ✓ | [ ] | — |
| 7-13 | 2.4 GHz Wi-Fi / BLE ホイップ | | | |
| 7-14 | 基板の逆 F アンテナ (PIFA) | | | |
| 7-15 | パッチアンテナ 2.4 GHz | | | |
| 7-16 | GPS 1.575 GHz セラミックアンテナ | | | |
| 7-17 | Wi-Fi ルータの外部アンテナ (RP-SMA) | | | |
| 7-18 | 2.4 GHz の整合 (π ネットワーク、チップ部品) | | | |
| 7-19 | スロットアンテナ | | | |
| 7-20 | 八木の給電点 (430 MHz) | | | |
| 7-21 | アンテナ間の結合 — S21 で距離と偏波 | | | |
| 7-22 | 放射効率のまね (Wheeler cap) | | | |
| 7-23 | 1.2 GHz のコリニア | | | |
| 7-24 | 同軸込みの SWR と給電点の SWR (ケーブル損失で良く見える) | | | |
| 7-25 | RFID 13.56 MHz のループ | | | |
| 7-26 | NFC タグの共振 | | | |

### 第 8 章 アンプと能動回路の S パラメータ

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 8-1 | [アンプの S21 (利得 vs 周波数)](03-nanovna/08-amplifiers/01-amplifier-s21.md) | ✓ | [ ] | — |
| 8-2 | [入力・出力の S11 / S22](03-nanovna/08-amplifiers/02-input-output-return-loss.md) | ✓ | [ ] | — |
| 8-3 | [アッテネータの S パラメータ](03-nanovna/08-amplifiers/03-attenuator-s-parameters.md) | ✓ | [ ] | — |
| 8-4 | [バイアス T でトランジスタの S パラメータ](03-nanovna/08-amplifiers/04-bias-tee-transistor.md) | ✓ | [ ] | — |
| 8-5 | [安定性 (K 因子)](03-nanovna/08-amplifiers/05-stability-k-factor.md) | ✓ | [ ] | — |
| 8-6 | [LNA (MMIC) の S21 / S11](03-nanovna/08-amplifiers/06-mmic-lna.md) | ✓ | [ ] | — |
| 8-7 | [ミキサのポート間アイソレーション](03-nanovna/08-amplifiers/07-mixer-isolation.md) | ✓ | [ ] | — |
| 8-8 | [リレー / PIN スイッチのアイソレーション](03-nanovna/08-amplifiers/08-switch-isolation.md) | ✓ | [ ] | — |
| 8-9 | GHz の LNA モジュール (SPF5189Z など) | | | |
| 8-10 | 方向性結合器 | | | |
| 8-11 | ウィルキンソン分配器 (マイクロストリップ、2.4 GHz) | | | |
| 8-12 | サーキュレータ / アイソレータ (借り物) | | | |
| 8-13 | ダイオード検波器の S11 | | | |
| 8-14 | 小電力パワーアンプの出力整合 | | | |
| 8-15 | 整合回路の設計と実測 (Smith チャート上で) | | | |
| 8-16 | 入出力を同時に整合する | | | |
| 8-17 | S パラメータを Touchstone で回路シミュレータへ | | | |
| 8-18 | エミッタフォロアの出力インピーダンス | | | |
| 8-19 | 広帯域帰還アンプ — 帰還抵抗とエミッタ抵抗で入出力を 50 Ω にそろえる (2N5109・4:1 トランス) | | | |
| 8-20 | [コレクタ負荷を差し替える — 抵抗・チョーク・LC 同調・広帯域トランスで S21 の利得と帯域を比べる (1.9 MHz 帯)](03-nanovna/08-amplifiers/20-collector-loads.md) | ✓ | [ ] | — |
| 8-21 | [同調負荷のリンク巻線で 50 Ω に合わせる — 巻数比で選択度 (Q) が変わり、利得には最適の巻数がある (7 MHz)](03-nanovna/08-amplifiers/21-tuned-load-link.md) | ✓ | [ ] | — |

### 第 9 章 GHz 帯の作法

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 9-1 | [1.5 GHz より上へ — スルーで 3 GHz まで見る (ケーブルとコネクタで何 dB 落ちるか)](03-nanovna/09-ghz/01-past-1-5ghz.md) | ✓ | [ ] | — |
| 9-2 | [GHz の校正 — 付属キットの限界と基準面](03-nanovna/09-ghz/02-ghz-calibration.md) | ✓ | [ ] | — |
| 9-3 | [GND を面で取る — perfboard と銅張りの差を S21 で](03-nanovna/09-ghz/03-ground-plane.md) | ✓ | [ ] | — |
| 9-4 | [ダイナミックレンジの帯域依存 — H4 (70 / 60 / 40 dB) と V2 を測る](03-nanovna/09-ghz/04-dynamic-range.md) | ✓ | [ ] | — |
| 9-5 | [手・体・机の影響 — 放射する物を測るとき](03-nanovna/09-ghz/05-hand-body-desk.md) | ✓ | [ ] | — |
| 9-6 | コネクタの締め付け (トルク) と再現性 | | | |
| 9-7 | FR4 の誘電率 — 長さの違う 2 本の線路で | | | |
| 9-8 | ケーブルの曲げ・温度で位相が動く | | | |
| 9-9 | ノイズと平均化 — GHz で S21 −60 dB を読む | | | |
| 9-10 | 高調波方式のスプリアス応答 — H4 の 300 / 900 MHz の段 | | | |
| 9-11 | U.FL / IPEX の扱い (抜き差し回数) | | | |
| 9-12 | Wi-Fi の混入 — 2.4 GHz を測ると周りの電波が乗る | | | |
| 9-13 | 4.4 GHz の壁 — 5 GHz Wi-Fi は測れないことを確かめる | | | |
| 9-14 | GHz での TDR (分解能) | | | |
| 9-15 | マイクロストリップの放射 (開放端) | | | |
| 9-16 | 測った S パラを回路シミュレータ (QucsStudio) で使う — GHz LNA の整合 | | | |

### 第 10 章 自動化

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 10-1 | NanoVNA-Saver で掃引と保存を繰り返す | | | |
| 10-2 | Touchstone を scikit-rf で図にする | | | |
| 10-3 | 部品 10 個のバッチ測定 | | | |
| 10-4 | 温度掃引の記録 | | | |
| 10-5 | 校正データの管理 — キット・ケーブルごと | | | |
| 10-6 | シリアルコマンドで直接制御 (Python) | | | |
| 10-7 | AD 本の測定と突き合わせる (1〜10 MHz) | | | |
| 10-8 | 測った値を tommie-fence の図に注釈で載せる | | | |

### 第 11 章 スペクトラムアナライザ — tinySA と同じ種類の計器

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 11-1 | [スペアナの種類 — 掃引型・FFT 型・SDR と、壊さない使い方](03-nanovna/11-spectrum-analyzer/01-kinds-and-safety.md) | ✓ | [ ] | — |
| 11-2 | [中心・スパン・RBW・基準レベル](03-nanovna/11-spectrum-analyzer/02-center-span-rbw.md) | ✓ | [ ] | — |
| 11-3 | [ノイズフロアとアッテネータ — 小さい信号をどこまで見られるか](03-nanovna/11-spectrum-analyzer/03-noise-floor-attenuator.md) | ✓ | [ ] | — |
| 11-4 | [NanoVNA の出力を測る — 周波数と電力と高調波](03-nanovna/11-spectrum-analyzer/04-nanovna-output.md) | ✓ | [ ] | — |
| 11-5 | [方形波の高調波 — 555 と CMOS の発振器](03-nanovna/11-spectrum-analyzer/05-square-wave-harmonics.md) | ✓ | [ ] | — |
| 11-6 | FM 送信機の出力と高調波 | | | |
| 11-7 | AM 変調の側波帯 | | | |
| 11-8 | フィルタの通過特性を信号発生器 + スペアナで (スカラー) | | | |
| 11-9 | 信号発生器を兼ねる機種 — 出力の確かさ | | | |
| 11-10 | スプリアスとイメージ — 見えている山は本物か | | | |
| 11-11 | ゼロスパン — 時間の軸で見る | | | |
| 11-12 | アンテナで受ける — FM 放送帯と 430 MHz | | | |
| 11-13 | PC から操作して記録する | | | |
| 11-14 | [微弱電波の電界強度を見積もる — アンテナ係数とケーブルの損失](03-nanovna/11-spectrum-analyzer/14-field-strength.md) | ✓ | [ ] | — |

### 第 12 章 Smith チャート — 読み方から整合まで

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 12-1 | [Smith チャートの地図 — 外周・実軸・R の円・X の円](03-nanovna/12-smith-chart/01-map.md) | ✓ | [ ] | — |
| 12-2 | [周波数を掃くと点が回る — 直列の L は上半分、C は下半分を時計回りに](03-nanovna/12-smith-chart/02-sweep-rotation.md) | ✓ | [ ] | — |
| 12-3 | [Γ の円と SWR — 負荷の SWR は中心からの距離、線路を足すと円を回る](03-nanovna/12-smith-chart/03-swr-circle.md) | ✓ | [ ] | — |
| 12-4 | [Smith チャートデモボード — 8 つの負荷を差し替えて 1 点ずつ測る](03-nanovna/12-smith-chart/04-demo-board.md) | ✓ | [ ] | — |
| 12-5 | [直列と並列 — 直列は R の円の上を、並列は G の円の上を動く](03-nanovna/12-smith-chart/05-series-shunt.md) | ✓ | [ ] | — |
| 12-6 | [L 形の整合を Smith チャート上で作る — 24 Ω を 50 Ω にする](03-nanovna/12-smith-chart/06-l-match.md) | ✓ | [ ] | — |

## 電験三種の教科書

### 第 0 章 道具と安全

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 0-1 | [安全の約束 — 商用電源に触れない。低圧の交流の作り方と電流の上限](04-denken/00-tools/01-safety-promise.md) | ✓ | [ ] | — |
| 0-2 | [テスターの直流と交流 — 平均値形と真の実効値形で方形波の読みが違う](04-denken/00-tools/02-tester-ac-dc.md) | ✓ | [ ] | — |
| 0-3 | [電圧と電流を同時に見る — シャント抵抗で電流を電圧に、AD の 2 ch](04-denken/00-tools/03-shunt-2ch.md) | ✓ | [ ] | — |
| 0-4 | [低圧の交流電源を作る — AD の波形発生器を OP アンプとプッシュプルで受ける](04-denken/00-tools/04-opamp-push-pull-ac.md) | ✓ | [ ] | — |
| 0-5 | [AC 出力の AC アダプタ — 無負荷と負荷で二次電圧が変わる](04-denken/00-tools/05-ac-adapter-regulation.md) | ✓ | [ ] | — |
| 0-6 | [ヒューズと電流制限 — シャントの発熱も測る](04-denken/00-tools/06-fuse-current-limit.md) | ✓ | [ ] | — |
| 0-7 | 電験の図記号と tommie-fence の記号の対応 — 1 枚の図に並べる | | | |
| 0-8 | データロガー — 長い時間の変化を記録 (電池の放電・温度上昇) | | | |
| 0-9 | 人体の抵抗を 3 V で測る — 乾いた手と濡れた手 | | | |
| 0-10 | 測った値のまとめ方 — 有効数字、表とグラフ、式との突き合わせ | | | |

### 第 1 章 理論 — 直流回路

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 1-1 | [オームの法則 — 電圧・電流・抵抗を同時に測る](04-denken/01-dc-circuits/01-ohms-law.md) | ✓ | [ ] | — |
| 1-2 | [直列・並列の合成抵抗と分圧・分流](04-denken/01-dc-circuits/02-series-parallel.md) | ✓ | [ ] | — |
| 1-3 | [キルヒホッフの法則 — 2 電源の回路で節点の電流と閉路の電圧](04-denken/01-dc-circuits/03-kirchhoff.md) | ✓ | [ ] | — |
| 1-4 | [重ね合わせの理 — 電源を 1 つずつ残して足す](04-denken/01-dc-circuits/04-superposition.md) | ✓ | [ ] | — |
| 1-5 | [テブナンの定理 — 開放電圧と内部抵抗を測って等価回路を作る](04-denken/01-dc-circuits/05-thevenin.md) | ✓ | [ ] | — |
| 1-6 | [ホイートストンブリッジの平衡条件](04-denken/01-dc-circuits/06-wheatstone-bridge.md) | ✓ | [ ] | — |
| 1-7 | [電池の内部抵抗 — 負荷を変えて端子電圧の直線を引く](04-denken/01-dc-circuits/07-battery-internal-resistance.md) | ✓ | [ ] | — |
| 1-8 | [最大電力の伝達 — 負荷抵抗 = 内部抵抗](04-denken/01-dc-circuits/08-maximum-power-transfer.md) | ✓ | [ ] | — |
| 1-9 | [電線の電圧降下 — 細く長い電線で負荷の電圧が下がる](04-denken/01-dc-circuits/09-line-voltage-drop.md) | ✓ | [ ] | — |
| 1-10 | [Δ-Y 変換 — 端子間の抵抗が同じになることを測る](04-denken/01-dc-circuits/10-delta-y-conversion.md) | ✓ | [ ] | — |
| 1-11 | ミルマンの定理 — 並列の電源の電圧 | | | |
| 1-12 | ノートンの定理 — 電流源と電圧源の等価変換 | | | |
| 1-13 | はしご回路 — R-2R で電圧が半分ずつ | | | |
| 1-14 | 抵抗の温度係数 — 銅線と電球 | | | |
| 1-15 | ジュールの法則 — 抵抗の発熱と温度上昇 | | | |
| 1-16 | 補償の定理 — 抵抗を 1 本変えたときの電流の変化 | | | |
| 1-17 | 対称な回路 — 立方体に組んだ抵抗 12 本の合成抵抗 | | | |
| 1-18 | 非線形抵抗の動作点 — 電球と抵抗の直列を負荷線で | | | |

### 第 2 章 理論 — 静電気と電磁気

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 2-1 | [コンデンサの直列・並列 — 合成容量と分担電圧](04-denken/02-electromagnetism/01-capacitors-series-parallel.md) | ✓ | [ ] | — |
| 2-2 | [平行平板コンデンサ — アルミ箔の面積・間隔・誘電体で容量が変わる](04-denken/02-electromagnetism/02-parallel-plate-capacitor.md) | ✓ | [ ] | — |
| 2-3 | [電磁誘導 — 磁石をコイルに出し入れして起電力 (レンツの法則)](04-denken/02-electromagnetism/03-electromagnetic-induction.md) | ✓ | [ ] | — |
| 2-4 | [電流が作る磁界 — 電線の周りの方位磁針 (右ねじの法則)](04-denken/02-electromagnetism/04-magnetic-field-of-current.md) | ✓ | [ ] | — |
| 2-5 | [電磁力 — 磁石の間の電線が動く (フレミングの左手)](04-denken/02-electromagnetism/05-electromagnetic-force.md) | ✓ | [ ] | — |
| 2-6 | [自己インダクタンス — 巻数と鉄心でコイルの L が変わる](04-denken/02-electromagnetism/06-self-inductance.md) | ✓ | [ ] | — |
| 2-7 | [相互インダクタンスと結合係数 — 2 つのコイルの距離](04-denken/02-electromagnetism/07-mutual-inductance.md) | ✓ | [ ] | — |
| 2-8 | [和動接続と差動接続 — コイルの直列で極性を変える](04-denken/02-electromagnetism/08-series-aiding-opposing.md) | ✓ | [ ] | — |
| 2-9 | [電磁石の吸引力 — 電流と巻数で変わる](04-denken/02-electromagnetism/09-electromagnet-force.md) | ✓ | [ ] | — |
| 2-10 | [ホール効果 — ホール素子で磁束密度を測る](04-denken/02-electromagnetism/10-hall-effect.md) | ✓ | [ ] | — |
| 2-11 | 磁気回路 — 鉄心のすき間で磁束が減る | | | |
| 2-12 | ヒステリシス — 鉄心の B-H 曲線を XY 表示で | | | |
| 2-13 | うず電流 — 磁石がアルミ管の中をゆっくり落ちる | | | |
| 2-14 | 静電誘導と静電遮へい — 誘導電圧が金網で消える | | | |
| 2-15 | コンデンサの蓄えるエネルギー — 充電して LED を何秒光らせるか | | | |
| 2-16 | 比誘電率 — 同じ電極で空気・紙・プラスチック | | | |
| 2-17 | ファラデーの法則 — 磁石を落とす速さと起電力 | | | |
| 2-18 | コイルの蓄えるエネルギー — 切った瞬間の逆起電力 | | | |

### 第 3 章 理論 — 交流回路

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 3-1 | [正弦波の最大値・実効値・平均値 — √2 と 2/π を測る](04-denken/03-ac-circuits/01-sine-wave-values.md) | ✓ | [ ] | — |
| 3-2 | [R・L・C の電圧と電流の位相](04-denken/03-ac-circuits/02-rlc-phase.md) | ✓ | [ ] | — |
| 3-3 | [RL 直列 — インピーダンスとベクトル図](04-denken/03-ac-circuits/03-rl-series.md) | ✓ | [ ] | — |
| 3-4 | [RC 直列 — 電圧の和はベクトルの和](04-denken/03-ac-circuits/04-rc-series.md) | ✓ | [ ] | — |
| 3-5 | [RLC 直列共振 — 共振周波数で電流が最大](04-denken/03-ac-circuits/05-series-resonance.md) | ✓ | [ ] | — |
| 3-6 | [有効電力・無効電力・皮相電力と力率](04-denken/03-ac-circuits/06-power-triangle.md) | ✓ | [ ] | — |
| 3-7 | [力率改善 — コンデンサを並列にして線電流を減らす](04-denken/03-ac-circuits/07-power-factor.md) | ✓ | [ ] | — |
| 3-8 | [RLC 並列共振 — 共振で電流が最小](04-denken/03-ac-circuits/08-parallel-resonance.md) | ✓ | [ ] | — |
| 3-9 | [リアクタンスの周波数特性 — X_L は f に比例、X_C は反比例](04-denken/03-ac-circuits/09-reactance-frequency.md) | ✓ | [ ] | — |
| 3-10 | [記号法を測って確かめる — RL と C の並列の合成インピーダンス](04-denken/03-ac-circuits/10-symbolic-impedance.md) | ✓ | [ ] | — |
| 3-11 | [Q と帯域幅 — 共振の鋭さを R で変える](04-denken/03-ac-circuits/11-q-bandwidth.md) | ✓ | [ ] | — |
| 3-12 | [瞬時電力 — v × i の波形は 2 倍の周波数で脈打つ](04-denken/03-ac-circuits/12-instantaneous-power.md) | ✓ | [ ] | — |
| 3-13 | [歪み波 — 方形波を FFT で基本波と高調波に分ける](04-denken/03-ac-circuits/13-square-wave-fft.md) | ✓ | [ ] | — |
| 3-14 | 歪み波の実効値 — 各調波の実効値の二乗和の平方根 | | | |
| 3-15 | 高調波電流 — コンデンサ入力の整流の電流はひずむ | | | |
| 3-16 | 直列共振の電圧拡大 — L と C の電圧が電源より大きい | | | |
| 3-17 | 直流と交流の重ね合わせ — 実効値の合成 | | | |
| 3-18 | 相互誘導回路の等価回路 — T 形に置き換える | | | |
| 3-19 | 位相の進み遅れをリサジュー図形で | | | |
| 3-20 | 50 Hz と 60 Hz — 同じ負荷でリアクタンスと力率が変わる | | | |
| 3-21 | 移相回路 — RC で位相を 90° ずらす | | | |
| 3-22 | ベクトル軌跡 — R を変えたときの電流の先端は円を描く | | | |

### 第 4 章 理論 — 三相交流

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 4-1 | [三相の信号を作る — AD の 2 ch (位相 120°) と OP アンプで 3 相目](04-denken/04-three-phase/01-three-phase-source.md) | ✓ | [ ] | — |
| 4-2 | [Y 結線 — 線間電圧は相電圧の √3 倍、位相は 30° 進む](04-denken/04-three-phase/02-star-connection.md) | ✓ | [ ] | — |
| 4-3 | [Δ 負荷 — 線電流は相電流の √3 倍](04-denken/04-three-phase/03-delta-load.md) | ✓ | [ ] | — |
| 4-4 | [平衡負荷の中性線 — 平衡なら中性線の電流は 0](04-denken/04-three-phase/04-neutral-wire.md) | ✓ | [ ] | — |
| 4-5 | [三相電力 — P = √3 VI cos θ](04-denken/04-three-phase/05-three-phase-power.md) | ✓ | [ ] | — |
| 4-6 | [不平衡負荷 — 中性線の電流](04-denken/04-three-phase/06-unbalanced-load.md) | ✓ | [ ] | — |
| 4-7 | [負荷の Y-Δ 変換 — 同じ線電流になる抵抗](04-denken/04-three-phase/07-y-delta-conversion.md) | ✓ | [ ] | — |
| 4-8 | [二電力計法 — 2 つの読みの和が三相電力](04-denken/04-three-phase/08-two-wattmeter.md) | ✓ | [ ] | — |
| 4-9 | 相順 — コンデンサと 2 つのランプで相回転を見分ける | | | |
| 4-10 | V 結線 — 2 台で三相を作る、出力は Δ の 1/√3 | | | |
| 4-11 | 回転磁界 — 3 つのコイルと方位磁針 | | | |
| 4-12 | 三相交流を発電する — 小型 BLDC を回して 3 つの波形 | | | |
| 4-13 | 欠相 — 1 線が切れたときの各相の電圧 | | | |
| 4-14 | 中性点の移動 — 中性線を外した不平衡 Y | | | |
| 4-15 | 三相の瞬時電力は一定 — 3 つの v × i の和 | | | |
| 4-16 | 三相の力率改善 — Δ に入れたコンデンサ | | | |

### 第 5 章 理論 — 過渡現象

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 5-1 | [RC の充電 — 時定数 τ = CR で 63 %](04-denken/05-transients/01-rc-charging.md) | ✓ | [ ] | — |
| 5-2 | [RC の放電 — τ で 37 %](04-denken/05-transients/02-rc-discharging.md) | ✓ | [ ] | — |
| 5-3 | [RL の電流の立ち上がり — τ = L / R](04-denken/05-transients/03-rl-current-rise.md) | ✓ | [ ] | — |
| 5-4 | [方形波で繰り返し見る — 時定数と周期の比](04-denken/05-transients/04-square-wave-period.md) | ✓ | [ ] | — |
| 5-5 | [RLC の過渡 — R で減衰振動・臨界・過制動](04-denken/05-transients/05-rlc-transient.md) | ✓ | [ ] | — |
| 5-6 | [切り替えの瞬間 — C の電圧と L の電流は急に変わらない](04-denken/05-transients/06-continuity-at-switching.md) | ✓ | [ ] | — |
| 5-7 | 微分回路と積分回路 | | | |
| 5-8 | 充電したコンデンサ同士をつなぐ — エネルギーの半分が消える | | | |
| 5-9 | 突入電流 — コンデンサ入力の整流で電源を入れた瞬間 | | | |
| 5-10 | LC の自由振動 — 周波数と減衰 | | | |

### 第 6 章 理論 — 電子回路

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 6-1 | [ダイオードの電圧電流特性](04-denken/06-electronics/01-diode-characteristic.md) | ✓ | [ ] | — |
| 6-2 | [トランジスタの静特性 — I_C-V_CE と h_FE](04-denken/06-electronics/02-transistor-characteristics.md) | ✓ | [ ] | — |
| 6-3 | [エミッタ接地増幅 — 電圧増幅度とバイアス](04-denken/06-electronics/03-common-emitter-amp.md) | ✓ | [ ] | — |
| 6-4 | [OP アンプの反転・非反転増幅 — 仮想短絡](04-denken/06-electronics/04-opamp-amplifiers.md) | ✓ | [ ] | — |
| 6-5 | [FET の伝達特性 — V_GS と I_D](04-denken/06-electronics/05-fet-transfer.md) | ✓ | [ ] | — |
| 6-6 | [ツェナーダイオードの定電圧](04-denken/06-electronics/06-zener-regulator.md) | ✓ | [ ] | — |
| 6-7 | [トランジスタのスイッチ — 飽和と遮断](04-denken/06-electronics/07-transistor-switch.md) | ✓ | [ ] | — |
| 6-8 | [エミッタフォロア — 入出力インピーダンス](04-denken/06-electronics/08-emitter-follower.md) | ✓ | [ ] | — |
| 6-9 | [負帰還 — 増幅度と帯域の交換](04-denken/06-electronics/09-negative-feedback.md) | ✓ | [ ] | — |
| 6-10 | デシベル — 増幅度と減衰を dB で | | | |
| 6-11 | 差動増幅と同相除去 | | | |
| 6-12 | 発振の条件 — RC 3 段の移相発振 | | | |
| 6-13 | 光電効果 — フォトダイオードの電流は光の強さに比例 | | | |
| 6-14 | 熱電効果 — 熱電対の起電力 (ゼーベック効果) | | | |
| 6-15 | OP アンプの加算・積分・微分 | | | |
| 6-16 | 半導体の温度特性 — ダイオードの順電圧は約 −2 mV/℃ | | | |

### 第 7 章 理論 — 電気計測

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 7-1 | [分流器 — 電流計の測定範囲を広げる](04-denken/07-measurement/01-ammeter-shunt.md) | ✓ | [ ] | — |
| 7-2 | [倍率器 — 電圧計の測定範囲を広げる](04-denken/07-measurement/02-voltmeter-multiplier.md) | ✓ | [ ] | — |
| 7-3 | [電圧計と電流計のつなぎ方で誤差が変わる (電圧計が先 / 電流計が先)](04-denken/07-measurement/03-ammeter-voltmeter-position.md) | ✓ | [ ] | — |
| 7-4 | [誤差率と補正率 — 1 % の抵抗を測って計算する](04-denken/07-measurement/04-error-correction-rate.md) | ✓ | [ ] | — |
| 7-5 | [電力計の結線 — 単相の電力を測る](04-denken/07-measurement/05-wattmeter-connection.md) | ✓ | [ ] | — |
| 7-6 | [整流形の計器 — 平均値を測って実効値を表示する (波形率 1.11)](04-denken/07-measurement/06-rectifier-meter.md) | ✓ | [ ] | — |
| 7-7 | [計器用変流器 (CT) — 二次を開放しない理由](04-denken/07-measurement/07-current-transformer.md) | ✓ | [ ] | — |
| 7-8 | [交流ブリッジで C と L を測る](04-denken/07-measurement/08-ac-bridge.md) | ✓ | [ ] | — |
| 7-9 | 電位差計法 — 電流を流さずに電圧を測る | | | |
| 7-10 | 低い抵抗の測定 — 4 端子法 | | | |
| 7-11 | 位相差の測定 — 時間差とリサジュー | | | |
| 7-12 | 周波数の測定 — カウンタと周期 | | | |
| 7-13 | 電力量計の原理 — 電力を時間で積算する | | | |
| 7-14 | 零位法と偏位法 | | | |
| 7-15 | 高い抵抗の測定 — 絶縁抵抗計の原理 (µA を測る) | | | |
| 7-16 | ディジタル計器の分解能と確度 — 桁と ±digit | | | |

### 第 8 章 機械 — 変圧器

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 8-1 | [巻数比と電圧比・電流比](04-denken/08-transformers/01-turns-ratio.md) | ✓ | [ ] | — |
| 8-2 | [無負荷試験 — 励磁電流と鉄損](04-denken/08-transformers/02-no-load-test.md) | ✓ | [ ] | — |
| 8-3 | [短絡試験 — 銅損とインピーダンス電圧](04-denken/08-transformers/03-short-circuit-test.md) | ✓ | [ ] | — |
| 8-4 | [効率 — 負荷を変えて最大効率 (鉄損 = 銅損)](04-denken/08-transformers/04-efficiency.md) | ✓ | [ ] | — |
| 8-5 | [電圧変動率 — 負荷をつなぐと二次電圧が下がる](04-denken/08-transformers/05-voltage-regulation.md) | ✓ | [ ] | — |
| 8-6 | [極性試験 — 減極性と加極性](04-denken/08-transformers/06-polarity-test.md) | ✓ | [ ] | — |
| 8-7 | 単巻変圧器 — 分路巻線と直列巻線 | | | |
| 8-8 | 並行運転 — 巻数比がずれると循環電流 | | | |
| 8-9 | 三相の結線 — Y-Δ で位相が 30° ずれる | | | |
| 8-10 | 励磁突入電流と鉄心の飽和 | | | |
| 8-11 | 計器用変成器の比誤差 — 負担を変える | | | |
| 8-12 | 等価回路を組む — 8-2・8-3 の値から一次換算 | | | |

### 第 9 章 機械 — 回転機

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 9-1 | [直流モータの逆起電力 — 回転数に比例する](04-denken/09-rotating-machines/01-back-emf.md) | ✓ | [ ] | — |
| 9-2 | [直流モータを発電機に — 回す速さと起電力](04-denken/09-rotating-machines/02-motor-as-generator.md) | ✓ | [ ] | — |
| 9-3 | [アラゴの円板 — 回る磁石にアルミ円板がついて回る (誘導機の原理)](04-denken/09-rotating-machines/03-arago-disk.md) | ✓ | [ ] | — |
| 9-4 | [直流モータの速度制御 — 電圧 (PWM) で速さが変わる](04-denken/09-rotating-machines/04-pwm-speed-control.md) | ✓ | [ ] | — |
| 9-5 | [トルクと電流 — 負荷を掛けると電流が増える](04-denken/09-rotating-machines/05-torque-current.md) | ✓ | [ ] | — |
| 9-6 | [同期速度 — BLDC を三相で回して N = 120 f / p](04-denken/09-rotating-machines/06-synchronous-speed.md) | ✓ | [ ] | — |
| 9-7 | [ステッピングモータ — パルスの数と回転角](04-denken/09-rotating-machines/07-stepper-motor.md) | ✓ | [ ] | — |
| 9-8 | すべり — 回転磁界の中のアルミ缶は磁界より遅く回る | | | |
| 9-9 | 直流発電機の外部特性 — 負荷で端子電圧が下がる | | | |
| 9-10 | 発電ブレーキ — モータの端子を抵抗で閉じると早く止まる | | | |
| 9-11 | 同期発電機の周波数 — f = pN / 120 | | | |
| 9-12 | 同期発電機の負荷特性 — 同期インピーダンス | | | |
| 9-13 | ブラシレスモータの転流 — ホール素子で相を切り替える | | | |
| 9-14 | モータの効率 — 入力電力とおもりを持ち上げる仕事 | | | |
| 9-15 | サーボ機構 — 位置のフィードバック | | | |
| 9-16 | 始動電流 — モータを入れた瞬間の電流 | | | |

### 第 10 章 機械 — パワーエレクトロニクス

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 10-1 | [単相の半波整流と全波整流 — 平均値は 0.45 V と 0.9 V](04-denken/10-power-electronics/01-rectifiers.md) | ✓ | [ ] | — |
| 10-2 | [平滑コンデンサとリップル](04-denken/10-power-electronics/02-smoothing-ripple.md) | ✓ | [ ] | — |
| 10-3 | [降圧チョッパ — 出力電圧 = デューティ比 × 入力](04-denken/10-power-electronics/03-buck-chopper.md) | ✓ | [ ] | — |
| 10-4 | [昇圧チョッパ — 出力電圧 = 入力 / (1 − デューティ比)](04-denken/10-power-electronics/04-boost-chopper.md) | ✓ | [ ] | — |
| 10-5 | [サイリスタの位相制御 — 点弧角で平均電圧 (低圧 AC)](04-denken/10-power-electronics/05-thyristor-phase-control.md) | ✓ | [ ] | — |
| 10-6 | [単相インバータ — H ブリッジで直流から交流](04-denken/10-power-electronics/06-single-phase-inverter.md) | ✓ | [ ] | — |
| 10-7 | 三相全波整流 — 6 パルスとリップル | | | |
| 10-8 | PWM インバータ — 正弦波 PWM と LC フィルタ | | | |
| 10-9 | トライアックの交流電力制御 | | | |
| 10-10 | 還流ダイオード — 誘導負荷の電流が途切れない | | | |
| 10-11 | 昇降圧チョッパ — 出力の極性が反転する | | | |
| 10-12 | スイッチング損失 — MOSFET の発熱と周波数 | | | |
| 10-13 | VVVF — 周波数と電圧を一緒に変えて BLDC を回す | | | |
| 10-14 | 整流回路の力率 — 電流の歪みで力率が下がる | | | |

### 第 11 章 機械 — 照明・電熱・電気化学・制御・情報

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 11-1 | [照度の逆二乗則 — LED からの距離とフォトダイオードの電流](04-denken/11-applications/01-inverse-square-law.md) | ✓ | [ ] | — |
| 11-2 | [オン・オフ制御 — 温度を一定に保つ (サーミスタ + 比較器 + ヒータ)](04-denken/11-applications/02-on-off-control.md) | ✓ | [ ] | — |
| 11-3 | [一次遅れ系のステップ応答 — RC で模す](04-denken/11-applications/03-first-order-step.md) | ✓ | [ ] | — |
| 11-4 | [ボード線図 — 折れ点で −3 dB、−20 dB/dec](04-denken/11-applications/04-bode-plot.md) | ✓ | [ ] | — |
| 11-5 | [論理回路 — AND・OR・NOT と真理値表](04-denken/11-applications/05-logic-gates.md) | ✓ | [ ] | — |
| 11-6 | 電気分解 — 流した電荷と発生した気体の量 (ファラデーの法則) | | | |
| 11-7 | 電池の起電力と内部抵抗 — ボルタ電池・ダニエル電池 | | | |
| 11-8 | ペルチェ素子 — 電流の向きで冷える側が入れ替わる | | | |
| 11-9 | 電熱 — セメント抵抗でアルミ塊を温め、電力量と温度上昇 (比熱) | | | |
| 11-10 | PID 制御 — モータの速さを一定に (Pico) | | | |
| 11-11 | フリップフロップとカウンタ — 2 進数 | | | |
| 11-12 | シーケンス制御 — リレーの自己保持回路 | | | |
| 11-13 | 光源の効率 — 電球と LED を同じ照度にしたときの電力 | | | |
| 11-14 | A-D 変換 — 分解能と量子化誤差 | | | |

### 第 12 章 電力 — 発電・送配電・蓄電

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 12-1 | [太陽電池の I-V 特性と最大電力点](04-denken/12-power-systems/01-solar-iv-curve.md) | ✓ | [ ] | — |
| 12-2 | [送電線の模型 — R と L の線路で電圧降下と電力損失](04-denken/12-power-systems/02-transmission-line-model.md) | ✓ | [ ] | — |
| 12-3 | [力率と送電損失 — 同じ電力を運ぶ電流が力率で変わる](04-denken/12-power-systems/03-power-factor-line-loss.md) | ✓ | [ ] | — |
| 12-4 | [単相 3 線式 — 中性線が切れると電圧が偏る](04-denken/12-power-systems/04-single-phase-three-wire.md) | ✓ | [ ] | — |
| 12-5 | フェランチ効果 — 軽負荷で受電端の電圧が上がる (π 形の模型) | | | |
| 12-6 | 調相 — 受電端のコンデンサで電圧を保つ | | | |
| 12-7 | 短絡電流と % インピーダンス | | | |
| 12-8 | 過電流継電器 — 設定を超えると遮断する (比較器 + リレー) | | | |
| 12-9 | 地絡と零相電流 — 零相変流器で漏れを見つける | | | |
| 12-10 | 風力・水力の模型 — 小さな発電機の回転と出力 | | | |
| 12-11 | 蓄電池の充放電と効率 — 蓄電所の小さな模型 | | | |
| 12-12 | 電源の並列運転と負荷の分担 — 内部抵抗の違い | | | |

### 第 13 章 法規 — 保安と施設管理

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 13-1 | [接地の効果 — 漏電した機器に触れたときの電圧 (抵抗の模型、5 V)](04-denken/13-regulations/01-grounding-effect.md) | ✓ | [ ] | — |
| 13-2 | [漏電遮断器の原理 — 往きと帰りの電流の差](04-denken/13-regulations/02-earth-leakage-breaker.md) | ✓ | [ ] | — |
| 13-3 | 絶縁抵抗の測定の原理 — 高い抵抗を µA で | | | |
| 13-4 | 接地抵抗の測定の原理 — 電位降下法 (水槽の模型、AD の低い交流) | | | |
| 13-5 | 電線の太さ — 電圧降下と発熱 (許容電流の考え方) | | | |
| 13-6 | 需要率と負荷率 — 1 日の電力をロガーで記録する | | | |

## 番外の工作

### 第 1 章 CPU もどき

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 1-1 | [4 ビット CPU のようなもの — カウンタとメモリと命令](05-etc/01-cpu/01-cpu-like.md) | ✓ | [ ] | — |
| 1-2 | [4 ビット ALU もどき — 加算と減算 (2 の補数)](05-etc/01-cpu/02-alu-like.md) | ✓ | [ ] | — |
| 1-3 | [レジスタ — 4 ビットを D フリップフロップで覚える](05-etc/01-cpu/03-register.md) | ✓ | [ ] | — |
| 1-4 | [CPU もどき — PC と ROM に ACC と加算器を足して足し算する](05-etc/01-cpu/04-cpu-mimic.md) | ✓ | [ ] | — |
| 1-5 | [DRAM のセル — 2N7000 1 個とコンデンサ 1 個で 1 ビットを覚え、漏れて消えるのを見る](05-etc/01-cpu/05-dram-cell.md) | ✓ | [ ] | — |

### 第 2 章 中波ラジオの時報で動く時計

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 2-1 | [中波ラジオの時報を検出するブロック図](05-etc/02-radio-clock/01-block.md) | ✓ | [ ] | — |
| 2-2 | [中波ラジオの受信と AM 検波 — 2SC1815 の高周波増幅 2 段](05-etc/02-radio-clock/02-radio.md) | ✓ | [ ] | — |
| 2-3 | [時報音の検出 — 440 Hz と 880 Hz の帯域通過フィルタとしきい値比較](05-etc/02-radio-clock/03-detect.md) | ✓ | [ ] | — |
| 2-4 | [時報の状態遷移 — 440 Hz を 3 回数えて 880 Hz で正時パルス](05-etc/02-radio-clock/04-state-machine.md) | ✓ | [ ] | — |
| 2-5 | [発振と分周 — 32.768 kHz の水晶を 8 Hz のクロックと 1 秒の TICK にする](05-etc/02-radio-clock/05-oscillator.md) | ✓ | [ ] | — |
| 2-6 | [秒のカウンタ — 74HC163 を 2 個つないで 00〜59 を数え、分へ桁上げを出す](05-etc/02-radio-clock/06-seconds.md) | ✓ | [ ] | — |
| 2-7 | [時計 — 32.768 kHz を数えて時分秒を出し、正時パルスで合わせる](05-etc/02-radio-clock/07-clock.md) | ✓ | [ ] | — |
| 2-8 | [マイコン版 — ① 受信のあとを Raspberry Pi Pico 2 の FFT とプログラムで作る](05-etc/02-radio-clock/08-mcu.md) | ✓ | [ ] | — |
| 2-9 | [組み立て — 受信・検波・状態遷移のユニバーサル基板をつなぐ](05-etc/02-radio-clock/09-assembly.md) | ✓ | [ ] | — |

### 第 3 章 2SC1815 のミキサー

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 3-1 | [1 石ミキサー — 2SC1815 で中波を 455 kHz の IF に変える](05-etc/03-mixer-2sc1815/01-mixer.md) | ✓ | [ ] | — |
| 3-2 | [差動対のミキサー — 2SC1815 の差動対とカレントミラーで RF を打ち消す](05-etc/03-mixer-2sc1815/02-balanced.md) | ✓ | [ ] | — |
| 3-3 | [3 つのミキサーをシミュレーションで比べる — 変換利得・漏れ・P1dB](05-etc/03-mixer-2sc1815/03-compare.md) | ✓ | [ ] | — |

### 第 4 章 デュアルゲート FET ミキサー (参考)

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 4-1 | [デュアルゲート FET ミキサー — 3SK291 で中波を 455 kHz の IF に変える](05-etc/04-mixer-dual-gate-fet/01-mixer.md) | ✓ | [ ] | — |
| 4-2 | [ミキサーの特性をシミュレーションで見る — 変換利得・インピーダンス・FFT](05-etc/04-mixer-dual-gate-fet/02-simulation.md) | ✓ | [ ] | — |

### 第 5 章 10BASE-T のイーサネット

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 5-1 | [リンクパルスを見る — 使わなくなったルータの 10BASE-T の対をオシロで見る](05-etc/05-ethernet-10base-t/01-link-pulse.md) | ✓ | [ ] | — |
| 5-2 | [送信 — Raspberry Pi Pico 2 の PIO と抵抗だけでリンクパルスとフレームを送り、ルータにリンクさせる](05-etc/05-ethernet-10base-t/02-tx-link-pulse.md) | ✓ | [ ] | — |
| 5-3 | [受信回路 — 100 Ω 終端と 74HC14 で差動を 3.3 V の論理に戻し、ロジアナで読む](05-etc/05-ethernet-10base-t/03-rx-front-end.md) | ✓ | [ ] | — |
| 5-4 | フレームを読み下す — マンチェスターを PIO で復号し、MAC と IP のヘッダを USB シリアルに出す | | | |
| 5-5 | ARP と ping に答える — Pico 2 に IP アドレスを持たせ、応答までの時間をオシロで測る | | | |
| 5-6 | パルストランスを足す — トランス内蔵の RJ45 に差し替えて絶縁し、波形の違いを比べる | | | |

## FPGA の教科書

### 第 0 章 道具と準備

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 0-1 | [FPGA と Soft-FPGA の違い — 回路を並べる物と、回路を計算で真似る物](06-fpga/00-tools/01-fpga-vs-soft-fpga.md) | ✓ | [ ] | — |
| 0-2 | [道具を入れる — Verilator と Pico SDK を Docker で](06-fpga/00-tools/02-install-tools-docker.md) | ✓ | [ ] | — |
| 0-3 | [3.3 V の決まり — Pico 2 と FPGA のピンに 5 V を入れない](06-fpga/00-tools/03-voltage-rule-3v3.md) | ✓ | [ ] | — |
| 0-4 | [AD3 の Logic をつなぐ — DIO を 3.3 V にして GND を共通に](06-fpga/00-tools/04-ad3-logic-connect.md) | ✓ | [ ] | — |
| 0-5 | [最初の 1 本 — ブラウザの soft-fpga でカウンタの波形を見る](06-fpga/00-tools/05-first-counter-web.md) | ✓ | [ ] | — |
| 0-6 | [波形を見る道具 — VCD と波形ビューア](06-fpga/00-tools/06-waveform-viewer.md) | ✓ | [ ] | — |
| 0-7 | [Verilator の lint で書き間違いを見つける](06-fpga/00-tools/07-verilator-lint.md) | ✓ | [ ] | — |
| 0-8 | Windows (MSYS2) で道具を入れる | | | |
| 0-9 | Debug Probe で Pico 2 に書き込み、UART のログを見る | | | |
| 0-10 | 開いた道具で FPGA を合成する — Yosys と nextpnr | | | |
| 0-11 | CI で回帰を回す — GitHub Actions で Verilator の試験 | | | |

### 第 1 章 組み合わせ回路を Verilog で書く

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 1-1 | [assign で AND・OR・NOT — 論理図と Verilog を並べる](06-fpga/01-combinational/01-assign-gates.md) | ✓ | [ ] | — |
| 1-2 | [module と port — 回路を箱にして呼ぶ](06-fpga/01-combinational/02-module-port.md) | ✓ | [ ] | — |
| 1-3 | [ビットの束 — 幅のある信号と連結・切り出し](06-fpga/01-combinational/03-bit-vectors.md) | ✓ | [ ] | — |
| 1-4 | [マルチプレクサ — 条件演算子で 2 つから 1 つを選ぶ](06-fpga/01-combinational/04-multiplexer.md) | ✓ | [ ] | — |
| 1-5 | [always @(*) と case — デコーダ](06-fpga/01-combinational/05-case-decoder.md) | ✓ | [ ] | — |
| 1-6 | [半加算器と全加算器](06-fpga/01-combinational/06-adders.md) | ✓ | [ ] | — |
| 1-7 | [4 ビットの加算器 — 全加算器を 4 つ並べるのと + 演算子を比べる](06-fpga/01-combinational/07-adder4.md) | ✓ | [ ] | — |
| 1-8 | [7 セグメントのデコーダ](06-fpga/01-combinational/08-seg7-decoder.md) | ✓ | [ ] | — |
| 1-9 | [比較器 — 一致と大小](06-fpga/01-combinational/09-comparator.md) | ✓ | [ ] | — |
| 1-10 | [プライオリティエンコーダ](06-fpga/01-combinational/10-priority-encoder.md) | ✓ | [ ] | — |
| 1-11 | [符号付きの数 — 2 の補数と signed](06-fpga/01-combinational/11-signed.md) | ✓ | [ ] | — |
| 1-12 | [parameter と generate — 幅を変えられる部品](06-fpga/01-combinational/12-parameter-generate.md) | ✓ | [ ] | — |
| 1-13 | ラッチを作ってしまう書き方 — else の無い if | | | |
| 1-14 | バレルシフタ | | | |
| 1-15 | 桁上げ先見の加算器 — リップルと段数を比べる | | | |
| 1-16 | ALU — 加減算・論理・フラグ | | | |
| 1-17 | 3 ステートと双方向のピン (inout) | | | |
| 1-18 | function と localparam で書き直す | | | |

### 第 2 章 順序回路

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 2-1 | [D フリップフロップ — always @(posedge clk)](06-fpga/02-sequential/01-d-flip-flop.md) | ✓ | [ ] | — |
| 2-2 | [ノンブロッキング代入 — ブロッキング代入との違いを波形で見る](06-fpga/02-sequential/02-nonblocking.md) | ✓ | [ ] | — |
| 2-3 | [リセット — 同期と非同期](06-fpga/02-sequential/03-reset.md) | ✓ | [ ] | — |
| 2-4 | [2 進カウンタ](06-fpga/02-sequential/04-binary-counter.md) | ✓ | [ ] | — |
| 2-5 | [クロックイネーブル — クロックを分けずに遅く動かす](06-fpga/02-sequential/05-clock-enable.md) | ✓ | [ ] | — |
| 2-6 | [シフトレジスタ](06-fpga/02-sequential/06-shift-register.md) | ✓ | [ ] | — |
| 2-7 | [分周して LED を 1 Hz で点滅させる](06-fpga/02-sequential/07-blink-1hz.md) | ✓ | [ ] | — |
| 2-8 | [アップダウンカウンタとロード](06-fpga/02-sequential/08-updown-load.md) | ✓ | [ ] | — |
| 2-9 | [10 進カウンタと桁上げ — ストップウォッチの秒を 2 桁の 7 セグに](06-fpga/02-sequential/09-decimal-counter.md) | ✓ | [ ] | — |
| 2-10 | [立ち上がりの検出 — 1 クロックのパルスを作る](06-fpga/02-sequential/10-edge-detect.md) | ✓ | [ ] | — |
| 2-11 | [PWM — カウンタと比較器](06-fpga/02-sequential/11-pwm.md) | ✓ | [ ] | — |
| 2-12 | リングカウンタとジョンソンカウンタ | | | |
| 2-13 | LFSR — 擬似乱数 | | | |
| 2-14 | グレイコードのカウンタ | | | |
| 2-15 | [7 セグのダイナミック点灯](06-fpga/02-sequential/15-dynamic-7seg.md) | ✓ | [ ] | — |
| 2-16 | ロータリーエンコーダを読む | | | |
| 2-17 | 分周した信号をクロックに使わない理由 | | | |
| 2-18 | 初期値 — initial とリセットの違い | | | |
| 2-19 | パイプライン — 長い組み合わせをレジスタで切る | | | |

### 第 3 章 シミュレーションと検証

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 3-1 | [テストベンチ — クロックとリセットを C++ から与える](06-fpga/03-simulation/01-testbench.md) | ✓ | [ ] | — |
| 3-2 | [波形を書き出して読む](06-fpga/03-simulation/02-waveform.md) | ✓ | [ ] | — |
| 3-3 | [期待値と比べる — 自分で合否を言うテストベンチ](06-fpga/03-simulation/03-self-check.md) | ✓ | [ ] | — |
| 3-4 | [全部の入力を試す — 加算器の全数検査](06-fpga/03-simulation/04-exhaustive.md) | ✓ | [ ] | — |
| 3-5 | [$display でログを出す](06-fpga/03-simulation/05-display.md) | ✓ | [ ] | — |
| 3-6 | [Verilog で書くテストベンチと Icarus Verilog](06-fpga/03-simulation/06-icarus-testbench.md) | ✓ | [ ] | — |
| 3-7 | [cocotb — Python で試験を書く](06-fpga/03-simulation/07-cocotb.md) | ✓ | [ ] | — |
| 3-8 | [assert — 起きてはいけないことを書く](06-fpga/03-simulation/08-assert.md) | ✓ | [ ] | — |
| 3-9 | 乱数で試す | | | |
| 3-10 | カバレッジ — 試していない行を見つける | | | |
| 3-11 | X と Z — 2 値のシミュレータと 4 値のシミュレータ | | | |
| 3-12 | 同じ時刻の中の順番とレース | | | |
| 3-13 | 参照モデルと突き合わせる — C++ のモデルと RTL | | | |
| 3-14 | プロトコルの E2E 回帰 — UART の字を流して確かめる | | | |
| 3-15 | 形式検証の入口 — カウンタの性質を証明する | | | |
| 3-16 | シミュレーションの速さを測る — 1 秒に何クロックか | | | |

### 第 4 章 Soft-FPGA ブラウザ編

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 4-1 | [soft-fpga の仕組み — Verilog → Verilator → Emscripten → ブラウザ](06-fpga/04-soft-fpga-web/01-how-soft-fpga-works.md) | ✓ | [ ] | — |
| 4-2 | [カウンタの 8 ビットをロジックアナライザの画面で見る](06-fpga/04-soft-fpga-web/02-counter-logic-screen.md) | ✓ | [ ] | — |
| 4-3 | [自分の Verilog に差し替えてビルドする](06-fpga/04-soft-fpga-web/03-own-verilog-build.md) | ✓ | [ ] | — |
| 4-4 | [信号機の状態機械 — 今の状態が図で光る](06-fpga/04-soft-fpga-web/04-traffic-fsm.md) | ✓ | [ ] | — |
| 4-5 | [見たい信号を外へ引き出す — 最上位の薄いラッパ](06-fpga/04-soft-fpga-web/05-probe-wrapper.md) | ✓ | [ ] | — |
| 4-6 | [UART のループバックを波形で見る](06-fpga/04-soft-fpga-web/06-uart-loopback.md) | ✓ | [ ] | — |
| 4-7 | [ボタンとスイッチを画面に付ける — JS から入力を与える](06-fpga/04-soft-fpga-web/07-screen-switches.md) | ✓ | [ ] | — |
| 4-8 | [リングバッファと TypedArray — 毎クロック JS を呼ばない](06-fpga/04-soft-fpga-web/08-ring-buffer-typedarray.md) | ✓ | [ ] | — |
| 4-9 | [Web Worker で回す — 画面を止めない](06-fpga/04-soft-fpga-web/09-web-worker.md) | ✓ | [ ] | — |
| 4-10 | [メモリが伸びるとビューが切れる](06-fpga/04-soft-fpga-web/10-memory-growth-views.md) | ✓ | [ ] | — |
| 4-11 | [6502 の内部を見る — マイクロシーケンサとバス](06-fpga/04-soft-fpga-web/11-6502-microsequencer-bus.md) | ✓ | [ ] | — |
| 4-12 | [8080 と CP/M — I/O のバスを見る](06-fpga/04-soft-fpga-web/12-8080-cpm-io-bus.md) | ✓ | [ ] | — |
| 4-13 | [GitHub Pages に載せる](06-fpga/04-soft-fpga-web/13-github-pages.md) | ✓ | [ ] | — |
| 4-14 | [命令エミュレータに無い信号 — T ステートを数える](06-fpga/04-soft-fpga-web/14-count-t-states.md) | ✓ | [ ] | — |

### 第 5 章 Soft-FPGA Pico 2 編

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 5-1 | [Pico 2 で Verilog を動かす仕組み — Verilator の C++ を Pico SDK でビルドする](06-fpga/05-soft-fpga-pico/01-verilator-on-pico.md) | ✓ | [ ] | — |
| 5-2 | [カウンタを Pico 2 で回して LED を点ける](06-fpga/05-soft-fpga-pico/02-counter-led.md) | ✓ | [ ] | — |
| 5-3 | [Verilog の入出力を GPIO につなぐ — 入力を読み、eval し、出力を書く](06-fpga/05-soft-fpga-pico/03-gpio-io.md) | ✓ | [ ] | — |
| 5-4 | [DIP スイッチと LED で AND・OR を確かめる](06-fpga/05-soft-fpga-pico/04-dip-and-or.md) | ✓ | [ ] | — |
| 5-5 | [Soft-FPGA のクロックを測る — 1 クロックに何 µs かかるか](06-fpga/05-soft-fpga-pico/05-clock-measure.md) | ✓ | [ ] | — |
| 5-6 | [回路の規模でクロックは変わる — カウンタと TD4 で比べる](06-fpga/05-soft-fpga-pico/06-clock-vs-size.md) | ✓ | [ ] | — |
| 5-7 | [クロックを固定する — タイマ割り込みで一定の間隔で回す](06-fpga/05-soft-fpga-pico/07-clock-timer.md) | ✓ | [ ] | — |
| 5-8 | [4 ビット CPU の TD4 を動かす — DIP スイッチで入力、LED で出力](06-fpga/05-soft-fpga-pico/08-td4.md) | ✓ | [ ] | — |
| 5-9 | [固定できるクロックの上限 — いちばん重い 1 クロックより長い周期を選ぶ](06-fpga/05-soft-fpga-pico/09-clock-limit.md) | ✓ | [ ] | — |
| 5-10 | [クロックの周期のばらつき (ジッタ) を測る](06-fpga/05-soft-fpga-pico/10-clock-jitter.md) | ✓ | [ ] | — |
| 5-11 | [精密なクロック — PWM のハードウェアで刻み、その割り込みで回す](06-fpga/05-soft-fpga-pico/11-clock-pwm.md) | ✓ | [ ] | — |
| 5-12 | [水晶の精度を測る — 1 Hz を出して AD3 で ppm を見る](06-fpga/05-soft-fpga-pico/12-crystal-ppm.md) | ✓ | [ ] | — |
| 5-13 | [Verilator のランタイムを Pico で通す — 削る所と差し替える所](06-fpga/05-soft-fpga-pico/13-runtime-trim.md) | ✓ | [ ] | — |
| 5-14 | [USB シリアルで内部の信号を出す](06-fpga/05-soft-fpga-pico/14-usb-serial.md) | ✓ | [ ] | — |
| 5-15 | [7 セグと押しボタンを付ける](06-fpga/05-soft-fpga-pico/15-seg7-button.md) | ✓ | [ ] | — |
| 5-16 | [ブラウザと Pico 2 で同じ Verilog を動かして波形を比べる](06-fpga/05-soft-fpga-pico/16-browser-vs-pico.md) | ✓ | [ ] | — |
| 5-17 | 外の基準にクロックを合わせる — 32.768 kHz の発振器と GPS の 1PPS | | | |
| 5-18 | 外から来るクロックで 1 歩ずつ動かす | | | |
| 5-19 | 2 つのコアで回す — コア 1 を eval 専用にする | | | |
| 5-20 | 速い所を PIO に任せる — UART の送信 | | | |
| 5-21 | 最適化で何倍速くなるか | | | |
| 5-22 | 結線の表でゲートを真似る — Verilog を使わない方式 | | | |

### 第 6 章 状態機械

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 6-1 | [状態機械の書き方 — 状態のレジスタと、次の状態の case](06-fpga/06-state-machines/01-fsm-template.md) | ✓ | [ ] | — |
| 6-2 | [信号機 — 青・黄・赤と歩行者ボタン](06-fpga/06-state-machines/02-traffic-light-pico.md) | ✓ | [ ] | — |
| 6-3 | [押しボタンのチャタリングを取る](06-fpga/06-state-machines/03-debounce.md) | ✓ | [ ] | — |
| 6-4 | [系列検出 — 1011 を見つける (ムーアとミーリー)](06-fpga/06-state-machines/04-sequence-detector.md) | ✓ | [ ] | — |
| 6-5 | [状態の符号 — 2 進・ワンホット・グレイ](06-fpga/06-state-machines/05-state-encoding.md) | ✓ | [ ] | — |
| 6-6 | [時間を持つ状態機械 — 長押しと短押し](06-fpga/06-state-machines/06-long-short-press.md) | ✓ | [ ] | — |
| 6-7 | [99 秒タイマー — 設定・計数・鳴るの 3 状態、0 でブザー](06-fpga/06-state-machines/07-timer-99s.md) | ✓ | [ ] | — |
| 6-8 | [状態機械とデータパスを分ける — 掛け算を足し算の繰り返しで](06-fpga/06-state-machines/08-datapath-multiplier.md) | ✓ | [ ] | — |
| 6-9 | 自動販売機 | | | |
| 6-10 | valid と ready の受け渡し | | | |
| 6-11 | 定義していない状態から戻る | | | |
| 6-12 | ROM で状態機械を作る — マイクロプログラム | | | |
| 6-13 | 時報の状態遷移を Verilog に移す — 440 Hz を 3 回数えて 880 Hz | | | |
| 6-14 | キーパッドの走査 | | | |
| 6-15 | 文字の LCD を初期化する手順 | | | |
| 6-16 | 電子サイコロ | | | |

### 第 7 章 通信 (UART・SPI・I2C)

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 7-1 | [UART の送信 — ボーレートの分周とシフトレジスタ](06-fpga/07-serial/01-uart-tx.md) | ✓ | [ ] | — |
| 7-2 | [UART の受信 — 16 倍で刻んでビットの真ん中を読む](06-fpga/07-serial/02-uart-rx.md) | ✓ | [ ] | — |
| 7-3 | [AD3 の Protocol で UART の字を読む](06-fpga/07-serial/03-uart-protocol.md) | ✓ | [ ] | — |
| 7-4 | [SPI のマスタ](06-fpga/07-serial/04-spi-master.md) | ✓ | [ ] | — |
| 7-5 | [I2C のマスタ — 温度センサーを読む](06-fpga/07-serial/05-i2c-master-temperature.md) | ✓ | [ ] | — |
| 7-6 | [ボーレートのずれは何 % まで許されるか](06-fpga/07-serial/06-baud-tolerance.md) | ✓ | [ ] | — |
| 7-7 | [エコーバック — 受けた字を返す](06-fpga/07-serial/07-echo.md) | ✓ | [ ] | — |
| 7-8 | SPI のスレーブ — 74HC595 を真似る | | | |
| 7-9 | I2C のスレーブ | | | |
| 7-10 | FIFO を挟む — 受信の取りこぼしを防ぐ | | | |
| 7-11 | テキストのプロトコルを解く — RUP | | | |
| 7-12 | WS2812 — 800 kHz のタイミングを作る | | | |
| 7-13 | 赤外線リモコンの受信 | | | |
| 7-14 | PS/2 キーボード | | | |
| 7-15 | マンチェスタ符号 | | | |
| 7-16 | CRC を回路で計算する | | | |
| 7-17 | Soft-FPGA の UART は何 bps まで出るか | | | |

### 第 8 章 実物の FPGA

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 8-1 | [FPGA の中身 — LUT とフリップフロップと配線](06-fpga/08-fpga-board/01-lut-ff-routing.md) | ✓ | [ ] | — |
| 8-2 | [おすすめの FPGA ボード — 規模・出来ること・価格・情報の多さで比べる](06-fpga/08-fpga-board/02-recommended-boards.md) | ✓ | [ ] | — |
| 8-3 | [ボードと書き込みの道具をつなぐ](06-fpga/08-fpga-board/03-connect-board.md) | ✓ | [ ] | — |
| 8-4 | [LED の点滅 — 合成・配置配線・書き込みの一巡り](06-fpga/08-fpga-board/04-blink-flow.md) | ✓ | [ ] | — |
| 8-5 | [ピンの割り当て — 制約ファイル](06-fpga/08-fpga-board/05-constraints.md) | ✓ | [ ] | — |
| 8-6 | [Pico 2 で動かした同じ Verilog を FPGA で動かす](06-fpga/08-fpga-board/06-same-verilog-on-fpga.md) | ✓ | [ ] | — |
| 8-7 | [Soft-FPGA と FPGA の速さを AD3 で比べる](06-fpga/08-fpga-board/07-speed-soft-vs-fpga.md) | ✓ | [ ] | — |
| 8-8 | [合成の報告を読む — LUT とフリップフロップの数](06-fpga/08-fpga-board/08-synth-report.md) | ✓ | [ ] | — |
| 8-9 | [押しボタンと 7 セグをつなぐ](06-fpga/08-fpga-board/09-button-seg7.md) | ✓ | [ ] | — |
| 8-10 | [PLL でクロックを作る](06-fpga/08-fpga-board/10-pll.md) | ✓ | [ ] | — |
| 8-11 | [ブロック RAM](06-fpga/08-fpga-board/11-block-ram.md) | ✓ | [ ] | — |
| 8-12 | [電源を切ると消える書き込みと、残る書き込み](06-fpga/08-fpga-board/12-sram-vs-flash.md) | ✓ | [ ] | — |
| 8-13 | [ブレッドボードに出す信号は 3 MHz まで — 速いクロックは分周して出す](06-fpga/08-fpga-board/13-divide-for-breadboard.md) | ✓ | [ ] | — |
| 8-14 | LUT 1 個に何が入るか — 4 入力の関数 | | | |
| 8-15 | 桁上げの専用の回路 | | | |
| 8-16 | FPGA の中にロジックアナライザを入れる | | | |
| 8-17 | ピンの駆動の強さと立ち上がりを波形で見る | | | |
| 8-18 | 開いた道具とメーカーの道具で結果を比べる | | | |
| 8-19 | HDMI に絵を出す | | | |
| 8-20 | 5 V の回路とつなぐ — レベル変換 | | | |
| 8-21 | 配置を図で見る | | | |

### 第 9 章 タイミング

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 9-1 | [セットアップとホールド — クロックの前後で動かしてはいけない時間](06-fpga/09-timing/01-setup-hold.md) | ✓ | [ ] | — |
| 9-2 | [外から来る信号はフリップフロップ 2 段で受ける](06-fpga/09-timing/02-sync-two-ff.md) | ✓ | [ ] | — |
| 9-3 | [最高の動作周波数 — タイミングの報告を読む](06-fpga/09-timing/03-fmax-report.md) | ✓ | [ ] | — |
| 9-4 | [伝搬の遅れを測る — インバータを並べたリングオシレータ](06-fpga/09-timing/04-ring-oscillator.md) | ✓ | [ ] | — |
| 9-5 | [グリッチ — 組み合わせの出力に出る細いパルス](06-fpga/09-timing/05-glitch.md) | ✓ | [ ] | — |
| 9-6 | メタステーブルを見る | | | |
| 9-7 | クロックをまたぐ 1 ビット | | | |
| 9-8 | クロックをまたぐバス — グレイコードと非同期 FIFO | | | |
| 9-9 | タイミングの制約を書く | | | |
| 9-10 | パイプラインで最高の周波数を上げる | | | |
| 9-11 | リセットの解除をクロックに合わせる | | | |
| 9-12 | クロックのスキューとジッタ | | | |
| 9-13 | 外の IC とのセットアップ — 入出力の遅れ | | | |
| 9-14 | Soft-FPGA にタイミングはあるか — 計算の順と遅れ | | | |

### 第 10 章 メモリと演算

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 10-1 | [ROM — 配列と $readmemh](06-fpga/10-memory-arithmetic/01-rom-readmemh.md) | ✓ | [ ] | — |
| 10-2 | [RAM — クロックに合わせて読み書きする](06-fpga/10-memory-arithmetic/02-ram.md) | ✓ | [ ] | — |
| 10-3 | [FIFO](06-fpga/10-memory-arithmetic/03-fifo.md) | ✓ | [ ] | — |
| 10-4 | [掛け算 — 演算子と、シフトと加算の繰り返し](06-fpga/10-memory-arithmetic/04-multiplier.md) | ✓ | [ ] | — |
| 10-5 | 固定小数点 | | | |
| 10-6 | 割り算 | | | |
| 10-7 | FIR フィルタ | | | |
| 10-8 | DDS — 位相を足し続けて正弦波を作る | | | |
| 10-9 | 1 ビットの ΔΣ DAC — RC で均して AD3 のスペクトルで見る | | | |
| 10-10 | PWM の DAC とひずみ | | | |
| 10-11 | CORDIC | | | |
| 10-12 | 周波数カウンタ | | | |
| 10-13 | 読み口と書き口が別の RAM | | | |
| 10-14 | 64 ビットで盤面を持つ — ビットボードの演算 | | | |

### 第 11 章 CPU を作る

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 11-1 | [TD4 の構成 — 4 ビットのレジスタ・加算器・ROM](06-fpga/11-cpu/01-td4-architecture.md) | ✓ | [ ] | — |
| 11-2 | [TD4 の命令を 1 つずつ波形で追う](06-fpga/11-cpu/02-td4-trace.md) | ✓ | [ ] | — |
| 11-3 | [TD4 のプログラムを書く — タイマー](06-fpga/11-cpu/03-td4-timer.md) | ✓ | [ ] | — |
| 11-4 | [TD4 を 74 シリーズの IC で組んだ物と比べる](06-fpga/11-cpu/04-td4-vs-74hc.md) | ✓ | [ ] | — |
| 11-5 | [TD4 に命令を足す](06-fpga/11-cpu/05-td4-add-instructions.md) | ✓ | [ ] | — |
| 11-6 | [アセンブラを作る](06-fpga/11-cpu/06-assembler.md) | ✓ | [ ] | — |
| 11-7 | [6502 を読む — Apple-I の wozmon を動かす](06-fpga/11-cpu/07-wozmon.md) | ✓ | [ ] | — |
| 11-8 | [6502 で Integer BASIC を動かす](06-fpga/11-cpu/08-integer-basic.md) | ✓ | [ ] | — |
| 11-9 | [8080 で CP/M 2.2 を動かす](06-fpga/11-cpu/09-cpm22.md) | ✓ | [ ] | — |
| 11-10 | [割り込み](06-fpga/11-cpu/10-interrupt.md) | ✓ | [ ] | — |
| 11-11 | [自分の 8 ビット CPU を設計する](06-fpga/11-cpu/11-cpu8-design.md) | ✓ | [ ] | — |
| 11-12 | [6502 を実物の FPGA に載せる](06-fpga/11-cpu/12-6502-fpga.md) | ✓ | [ ] | — |
| 11-13 | C を RV32I の機械語にして PicoRV32 で Hello を出す — CPU を差し替えられる枠を作る | | | |
| 11-14 | 4 命令の RV32I を自作する — ADDI・LBU・SW・BEQ だけで Hello を出す | | | |
| 11-15 | 自作の RV32I を 8 命令に広げる — GCC の出した Hello を動かす | | | |
| 11-16 | PicoRV32 を Pico 2 の Soft-FPGA で動かす — 1 秒に何命令か測る | | | |
| 11-17 | PicoRV32 を実物の FPGA に載せる — 同じ機械語を Soft-FPGA と比べる | | | |
| 11-18 | Pico 2 の中の RISC-V (Hazard3) で同じ機械語を走らせる | | | |

### 第 12 章 作品

| # | 題 | 作成 | 目で確認 | Fable で確認 |
| --- | --- | --- | --- | --- |
| 12-1 | [リバーシのアクセラレータ — 合法手と裏返しを回路で](06-fpga/12-projects/01-reversi-accel.md) | ✓ | [ ] | — |
| 12-2 | [リバーシを UART で PC と対戦させる](06-fpga/12-projects/02-reversi-uart.md) | ✓ | [ ] | — |
| 12-3 | [Pong — ゲートだけで動くゲーム](06-fpga/12-projects/03-pong.md) | ✓ | [ ] | — |
| 12-4 | [時計 — 27 MHz を数えて時分秒を 4 桁の 7 セグに出し、時報で合わせる](06-fpga/12-projects/04-clock.md) | ✓ | [ ] | — |
| 12-5 | [DDS の信号発生器](06-fpga/12-projects/05-dds.md) | ✓ | [ ] | — |
| 12-6 | [小さいロジックアナライザを作る](06-fpga/12-projects/06-logic-analyzer.md) | ✓ | [ ] | — |
