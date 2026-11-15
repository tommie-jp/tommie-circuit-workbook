---
book: nanovna
chapter: 2
id: 2-12
title: NanoVNA-App
tier: 200
source: 自作 (画面の欄の名前は NanoVNA-App のソース)
board: —
device: H4
---

# 2-12 NanoVNA-App

**NanoVNA-App** は Windows の PC ソフトで、NanoVNA-H / H4 のほか V2 などもつなげる。
NanoVNA-Saver (2-4) と同じく掃引・校正・保存ができ、加えて**トレースを記憶して重ねる**・
**基準で割る (正規化)**・**時間の平均とメディアンで雑音を抑える**といった、測った線を
比べるための道具が多い。6-3 の LC バンドパスを 801 点で掃引し、記憶したトレースと比べる。

元の作者 (OneOfEleven) の配布場所は今は開けない。ソース (C++Builder) は他の人が
引き継いで公開している ([owenduffy/NanoVNA-App](https://github.com/owenduffy/NanoVNA-App) など)。
版によって画面の並びが違うので、ここでは**欄の名前** (ソースの綴り) で書く。

## App の欄と働き

| 欄 (ソースの綴り) | 働き |
| --- | --- |
| Start / Stop / Center / Span (MHz) | 掃引の範囲 (2-3) |
| Number of points | 点数。H4 には 51〜25601 の候補が出る。本体の 1 回の上限 (DiSlord 版の H4 で 401 点。2-16) を超えると、App が範囲を区切って何回かに分けて掃引する (セグメント) |
| Point RBW (Hz) | 1 点を測る帯域。本体の IF BANDWIDTH と同じ。狭いほど雑音が減り、遅くなる (2-9) |
| Time averaging | 掃引を何回か平均する (2-9 の平均と同じ考え方) |
| Median filter | 前後の点の中央値で、飛び出した 1 点を消す |
| Trace smoothing | 前後の点で線をならす。狭い山や谷も丸めるので、効かせすぎない |
| Set memory / Clear memory | 今のトレースを記憶して、後の掃引と重ねる |
| Set Norm / Enable Norm | 今のトレースを基準にして、後の掃引をそれで割る (正規化) |
| e-delay (ps) | 電気長を足し引きする (ポート延長、1-10) |
| S1P / S2P / CSV | Touchstone (2-5) と表の書き出し |
| Save image / Copy image | 画面の画像 (2-10) |

グラフの形式は S11 の Return Loss・VSWR・Smith・Series R / X / L / C・Parallel R / X / L / C・
Quality Factor・Group Delay、S21 の Gain・Phase・Group Delay などから選び、最大 4 枚を並べる。

校正の窓には Open・Short・Load/Isoln・Through のボタンと、Average・Median・Smoothing の欄がある。
校正の測定を何回か平均してから補正に使える (校正の値の雑音も補正に乗るため)。

## 記憶と正規化の使い分け

| | Set memory (記憶) | Set Norm (正規化) |
| --- | --- | --- |
| 何をする | 前の線を残して、今の線と**重ねる** | 前の線で今の線を**割る** (dB なら引き算) |
| 使う所 | 部品を替える前と後、温度を変える前と後を比べる | 治具やケーブルの損失を除いた差だけを見る |
| 注意 | 掃引の範囲と点数を同じにする | 割る相手が SOLT の代わりになるわけではない。反射 (S11) のずれは直らない |

正規化は「Thru で割る」応答の校正 (1-3) と同じことをする。SOLT で校正した上で、
**変化だけ**を拡大して見たいときに使う (例: コイルの巻きを広げる前と後の差を 0 dB の線からの
ずれとして読む)。

## 回路図

6-3 と同じ DUT。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 3 共振器バンドパス (6-3 と同じ)
parts:
  J1: sma 2,2 mirror CH0
  L1: inductor 4,2 4,4 39n
  C1: capacitor 7,2 7,4 1500p
  L2: inductor 9,2 11,2 6.8u
  C2: capacitor 11,2 13,2 8.2p
  L3: inductor 16,2 16,4 39n
  C3: capacitor 19,2 19,4 1500p
  J2: sma 21,2 CH1
  G1: ground 2,3
  G2: ground 4,4
  G3: ground 7,4
  G4: ground 16,4
  G5: ground 19,4
  G6: ground 21,3
wires:
  - J1.1 -- 4,2 -- 7,2 -- 9,2
  - 13,2 -- 16,2 -- 19,2 -- 21,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 21,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/circuit/12-nanovna-app.svg)

この題は実体配線図を付けない — 6-3 のユニバーサル基板をそのまま使い、PC ソフトの使い方だけを足す題 (図は 6-3 の図2)。

## 掃引の設定

計器は VNA。この本の図は NanoVNA-H4 で書いてあり、標準の LiteVNA64 でも同じ手順で測れる
(App は LiteVNA にも対応する。版による)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 16 MHz〜26 MHz (6-3 の図4 と同じ) |
| 点数 | 801 (App の Number of points。本体 401 点なら区切って掃引する) |
| Point RBW | 1000 Hz (目安。狭くすると遅くなる) |
| 校正 | App の校正の窓で SOLT。Average は 4 (目安) |
| 表示 | S21 Gain、S11 Return Loss |

**見えるはずの画面**。マーカーは 6-3 の図4 と同じ 4 点で、塗った所が S21 の −3 dB の帯域。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 16M-26M 801
title: 図2 801 点で見た 6-3 のバンドパス — 通過の山で S11 は −45.4 dB
dut:
  - shunt L 39n
  - shunt C 1500p
  - series L 6.8u
  - series C 8.2p
  - shunt L 39n
  - shunt C 1500p
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 20.04M
  - 21.22M
  - 21.91M
  - 22.3M
notes:
  - band 20.04M 22.3M
expect:
  - match: S11 LOGMAG の変化は
    why: S11 の深い谷は狭い。6-3 の図4 と同じ範囲で S21 を見せるのが主
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/02-display/vna/12-nanovna-app.svg)

- 801 点なら隣の点の間は 10 MHz ÷ 800 = 12.5 kHz。それでも S11 の谷 (21.91 MHz) は鋭く、
  点を結んだ線は −40 dB くらいまでしか下りない。読み値の −45.4 dB は模型をマーカーの周波数で
  計算した値で、実機のマーカーは一番近い点 (21.9125 MHz) の −40.3 dB (計算値) を出す
- 帯域の端 (20.04 MHz と 22.3 MHz) では S21 と S11 がどちらも約 −3 dB で交わる。損失の無い
  模型では、通らなかった電力はすべて CH0 へ戻るから (|S11|² + |S21|² = 1)

## 記憶して比べる手順

| # | 操作 | 見ること |
| --- | --- | --- |
| 1 | 図2 の掃引をして Set memory | 記憶した線が別の色で残る |
| 2 | 基板の L2 (6.8 µH (マイクロヘンリー)) の巻きを指で少し広げる (アキシアルなら、隣の部品に指を近づけるだけでもよい) | 今の線が記憶の線から横にずれる |
| 3 | 2 本の山の位置と −3 dB の幅をマーカーで読む | 部品の値と置き方のばらつき (6-11) が見える |
| 4 | 記憶の線を Set Norm にして、今の線を Enable Norm | 差だけが 0 dB の線からのずれとして出る |
| 5 | S2P で両方を保存する | 後から scikit-rf で比べられる (2-13) |

## 見るべき値

計算値 (無損失として)。

| マーカー | S21 | S11 | 分かること |
| --- | --- | --- | --- |
| 20.04 MHz | −3.00 dB | −3.02 dB | 通過帯域の下端 |
| 21.22 MHz | −0.89 dB | −7.33 dB | E12 に丸めたためにできた帯域の中の谷 (6-3) |
| 21.91 MHz | 0.00 dB | −45.4 dB | 通過の山。整合がいちばんよい |
| 22.3 MHz | −2.95 dB | −3.07 dB | 通過帯域の上端 |

分かること:

- App の道具 (平均・メディアン・ならし) は、どれも**測った線を変える**。図の読み値と比べるときは、
  どれを効かせたかを記録に書く (2-10)
- ならし (Trace smoothing) を強くすると、21.91 MHz の S11 の谷 (−45 dB) は浅くなる。谷の深さを
  読む題では切る

## LTspice での確かめ

`sim/12-nanovna-app.cir` で、図2 の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω (オーム) の電源と
50 Ω の終端。コイルの既定の直列抵抗は 1 µΩ に固定)。理想の模型どうしの比べで、実測ではない。

| 周波数 | 項目 | 図の読み値 | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 20.04 MHz | S21 / S11 | −3.00 dB / −3.02 dB | −3.00 dB / −3.02 dB | 合う |
| 21.22 MHz | S21 / S11 | −0.89 dB / −7.33 dB | −0.89 dB / −7.33 dB | 合う |
| 21.91 MHz | S21 / S11 | 0.00 dB / −45.4 dB | 0.00 dB / −45.40 dB | 合う |
| 22.3 MHz | S21 / S11 | −2.95 dB / −3.07 dB | −2.95 dB / −3.07 dB | 合う |

8 点すべて図の読み値と合う。点の間隔 12.5 kHz は (26 − 16) MHz ÷ 800、一番近い点 (21.9125 MHz) の S11 −40.3 dB は同じ模型を Python で計算した値 (算術)。

## 出典

自作。欄の名前と点数の候補は [NanoVNA-App](https://github.com/owenduffy/NanoVNA-App) のソース
(`Unit1.dfm`・`Unit1.cpp`・`CalibrationUnit.dfm`)。元の作者は OneOfEleven。
