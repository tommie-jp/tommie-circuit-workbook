---
book: nanovna
chapter: 11
id: 11-7
title: AM 変調の側波帯
tier: 200
source: 自作
board: BB
device: SA
---

# 11-7 AM 変調の側波帯

回路の教科書の 9-29 は、9-7 の AM 変調器 (555 の電源に 1 kHz の音声を混ぜる、搬送波 686 kHz) を
tinySA で見て、搬送波の両側 ±1 kHz に側波が立つのを確かめた。この題はその先で、
**側波の高さから変調度 m を読む**。m を 0.08 から 0.3 へ深くして側波が上がるのを見て、
3 倍の高調波 (2058 kHz) の両側にも**同じ dBc の側波**が立つことを確かめる。
Analog Discovery の教科書の 4-7 (FFT 型で見た AM のスペクトル) と同じ式を、掃引型で使う。

この題は回路図と実体配線図を載せない。回路は 9-7 の図1、tinySA のつなぎ方 (Rsa 10 kΩ (キロオーム) と
Csa 0.01 µF (マイクロファラド) を通す) は 9-29 の図1 のまま、ブレッドボードもそのまま使う。

## この実験で確かめる式

搬送波 A cos ω<sub>c</sub>t (ω はオメガ、角周波数) の振幅を音声 cos ω<sub>m</sub>t で m だけ振ると

A (1 + m cos ω<sub>m</sub>t) cos ω<sub>c</sub>t = A cos ω<sub>c</sub>t + (mA/2) cos (ω<sub>c</sub> − ω<sub>m</sub>)t + (mA/2) cos (ω<sub>c</sub> + ω<sub>m</sub>)t

なので、側波 1 本の振幅は搬送波の **m/2 倍**。dB にすると
**側波 − 搬送波 = 20 log₁₀ (m/2)** で、逆に読めば **m = 2 × 10<sup>(差/20)</sup>**。

| m | 側波 − 搬送波 (dBc) | 側波 2 本の電力 ÷ 搬送波の電力 |
| --- | --- | --- |
| 0.05 | −32.0 | 0.1 % |
| 0.08 (9-29) | −28.0 | 0.3 % |
| 0.1 | −26.0 | 0.5 % |
| 0.3 (この題) | −16.5 | 4.5 % |
| 0.5 | −12.0 | 12.5 % |
| 1.0 | −6.0 | 50 % |

- 側波の電力は 2 本で m²/2。m = 1 でも全体の 1/3 しか音声を運ばない (AM の効率が悪い理由)
- 555 の出力は方形波なので、3 倍・5 倍の高調波にも同じ包絡線 (1 + m cos ω<sub>m</sub>t) が掛かる。
  **どの次数の高調波の両側にも、同じ dBc の側波**が ±1 kHz に立つ

## 変調を深くする

9-7 の m は PIN 8 の振れ ÷ PIN 8 の直流 (約 4.4 V)。9-29 の音声の通り道では、発生器 (出力 50 Ω) の
設定の振幅の 0.702 倍が PIN 8 に届く (1 kHz)。

| 発生器の振幅 (1 kHz) | PIN 8 の振れ | m |
| --- | --- | --- |
| 0.5 V (9-29) | 0.35 V | 0.08 |
| 1.88 V | 1.32 V | 0.30 |

- m = 0.3 で PIN 8 は 3.1〜5.7 V を往復する。TLC555 の電源の下限 (2 V) より上で、
  発生器の電流は約 6 mA (計算値)
- m を 0.5 より深くすると、PIN 8 の電圧が下がった所で 555 の H が電源ほど上がらなくなり、
  包絡線が歪む (目安)。側波 ±2 kHz (2 次の歪み) が立ち始めたら深すぎる

## 計器の設定

計器は tinySA Ultra。音声は 9-29 の発生器 (Analog Discovery 3 の W1 でもよい。出力が 0 Ω なので
PIN 8 の振れが 15 % ほど大きく出る、9-29)。オシロは 9-29 の図2 の音声の通り道を見るときだけ使う。

| 一般の名前 | 値 | tinySA Ultra のメニュー |
| --- | --- | --- |
| 中心・スパン | 686 kHz・10 kHz (図1)、2058 kHz・10 kHz (図2) | `FREQUENCY` → `CENTER` / `SPAN` |
| 点数 | 101 (1 点 = 100 Hz。±1 kHz の側波が点の真上に載る) | `DISPLAY` → `SWEEP POINTS` |
| RBW | 200 Hz (側波の間隔 1 kHz より十分狭い) | `FREQUENCY` → `RBW` |
| 入力アッテネータ | **20 dB (手動)** | `LEVEL` → `ATTENUATE` |
| 基準レベル | −20 dBm (図1)、−30 dBm (図2) | `LEVEL` → `REF LEVEL` |
| AM の測定 | 搬送波 686 kHz・変調 1 kHz を入れる (設定をまとめて変えるので、後で上の値に戻す) | `MEASURE` → `AM` |

- **アッテネータを 20 dB にする理由**: tinySA は内部の AGC (検波の幅を広げる自動の利得) が
  AM の速い振れについていけず、本物でない線がたくさん出ることがある。公式の説明は
  「搬送波 − 内部の減衰 を −45 dBm より下にせよ」とする。搬送波は約 −27.1 dBm なので、
  18 dB 以上、きりのよい 20 dB を入れる。読みは減衰を補正して出るので変わらない
- RBW 200 Hz・減衰 20 dB のノイズフロアは約 −103.8 dBm (−102 dBm @ 30 kHz からの換算、11-2)
- 狭い RBW では掃引が遅い (1 回に数秒)。側波が揺れて見えるときは `TRACE` → `CALC` の平均を使う

## 計器の画面

m = 0.3 のときの**見えるはずの画面** (計算値)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図1 m = 0.3 の側波は搬送波の 16.5 dB 下 (686 kHz ± 1 kHz)
device: tinysa-ultra
center: 686kHz
span: 10kHz
points: 101
rbw: 200Hz
atten: 20dB
ref: -20dBm
signal:
  - sine 686kHz -27.1dBm
  - sine 685kHz -43.6dBm
  - sine 687kHz -43.6dBm
markers: [686k, 685k, 687k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/07-am-sidebands-1.svg)

- マーカー 1 が搬送波、2・3 が下と上の側波。2 本は同じ高さ (振幅だけを振った AM の印。
  高さが違えば周波数も振れている = FM が混ざっている)
- 9-29 の図4 (m = 0.08、側波 −55.1 dBm) と比べて、側波だけが 11.5 dB 上がり、搬送波は変わらない

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 3 倍の高調波 2058 kHz の両側にも同じ −16.5 dBc の側波
device: tinysa-ultra
center: 2058kHz
span: 10kHz
points: 101
rbw: 200Hz
atten: 20dB
ref: -30dBm
signal:
  - sine 2058kHz -36.8dBm
  - sine 2057kHz -53.3dBm
  - sine 2059kHz -53.3dBm
markers: [2058k, 2057k, 2059k]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/07-am-sidebands-2.svg)

- 側波の間隔は 3 倍にならず ±1 kHz のまま (音声の周波数で決まる)。dBc も同じ
- 側波の間隔が 3 倍になる FM (Analog Discovery の教科書の 4-8) との見分けにも使える

## 見るべき値

計算値 (LTspice。搬送波の高さは 9-29 と同じ、10 kΩ + 0.01 µF 越しに 50 Ω で受けたとき)。

| 確かめること | m = 0.08 (発生器 0.5 V) | m = 0.3 (発生器 1.88 V) |
| --- | --- | --- |
| 搬送波 686 kHz | −27.1 dBm | −27.1 dBm (変わらない) |
| 側波 685・687 kHz | −55.1 dBm (−28.0 dBc) | −43.6 dBm (−16.5 dBc) |
| 3 倍の高調波 2058 kHz | −36.8 dBm | −36.8 dBm |
| その側波 2057・2059 kHz | −64.8 dBm (−28.0 dBc) | −53.3 dBm (−16.5 dBc) |
| 側波の差から逆算した m | 2 × 10<sup>(−28.0/20)</sup> = 0.080 | 2 × 10<sup>(−16.5/20)</sup> = 0.30 |

分かること:

- **側波の dBc から m が読める**。実測の差から逆算した m と、オシロで読んだ PIN 8 の振れ ÷ 直流
  (9-29 の図2) を突き合わせる。合わなければ、PIN 8 の直流 (4.4 V の仮定) をテスターで測り直す
- 搬送波の高さはどちらの m でも同じ。音声の情報は側波だけが運ぶ
- Analog Discovery の Spectrum (FFT 型、4-7) でも 686 kHz は見られる。掃引型との違いは、FFT 型は
  1 回の取り込みで全部の線を同時に見るので変調の揺れに強く、掃引型は RBW を狭めると 1 回の掃引が
  遅い代わりに 800 MHz まで同じ手順で見られること (11-1)

## LTspice での確かめ

`sim/07-am-sidebands.cir` で、PIN 3 の方形波 (686 kHz・デューティ 52 %、High = 4.4 V × (1 + m sin 2π·1 kHz·t)、π はパイ) を
Rsa・Csa 越しに 50 Ω で受け、`.four` (基本 1 kHz、2060 次まで) で 685〜687 次と 2057〜2059 次を読んだ。
555 の出力の High を PIN 8 の電圧と置いたのは仮定 (TLC555 の CMOS の出力)。m は 0.08 と 0.3 の 2 通り。

| 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- |
| 搬送波 686 kHz | −27.1 dBm | −27.13 dBm (両方の m で同じ) | 合う |
| 側波 (m = 0.08) | −55.1 dBm | −55.09 dBm | 合う |
| 側波 (m = 0.3) | −43.6 dBm | −43.61 dBm | 合う |
| 3 倍の高調波 2058 kHz | −36.8 dBm | −36.81 dBm | 合う |
| その側波 (m = 0.08 / 0.3) | −64.8 / −53.3 dBm | −64.77 / −53.29 dBm | 合う |
| ±2 kHz の線 (684・688 kHz) | 立たない | −168 dBm 以下 (数値の誤差の水準) | 合う |

発生器の振幅と m の関係 (0.702 倍、1.88 V で m = 0.30)、ノイズフロア (−103.8 dBm) は算術で合う。
tinySA の AGC が AM で乱れること (公式の説明) は計器の性質で、SPICE の対象外。

## 出典

自作。回路は回路の教科書の 9-7、tinySA のつなぎ方と音声の通り道の分圧は 9-29。AM の式は
Analog Discovery の教科書の 4-7・3-13 と同じ。tinySA で AM を見るときの減衰の決め (搬送波 − 減衰 < −45 dBm) は
[公式の AM の頁](https://tinysa.org/wiki/pmwiki.php?n=Main.AMModulation)、`MEASURE` → `AM` は
[公式の Measure メニューの頁](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.MEASURE) (2026-11-14 に確認)。
TLC555 の電源の範囲は [TI のデータシート](https://www.ti.com/lit/ds/symlink/tlc555.pdf)。
