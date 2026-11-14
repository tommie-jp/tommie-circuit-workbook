---
book: nanovna
chapter: 11
id: 11-12
title: アンテナで受ける — FM 放送帯と 430 MHz
tier: 200
source: 自作
board: —
device: SA
---

# 11-12 アンテナで受ける — FM 放送帯と 430 MHz

第 7 章では NanoVNA でアンテナの SWR と共振を測った。この題では、そのアンテナを tinySA につないで
**実際に飛んでいる電波**を見る。FM 放送 (76〜95 MHz) は一日中同じ強さで出ているので、読んだ dBm から
電界強度を見積もる練習になる。430 MHz のアマチュア無線帯は、出たり止んだりする電波なので、
`MAX HOLD` で「いつ・どこに出たか」を貯めて見る。

## つなぎ方

| 帯 | アンテナ | 作り方 |
| --- | --- | --- |
| FM 放送帯 | 半波長ダイポール、全長 1.68 m (85.2 MHz に合わせる、全長 ≈ 143 / f[MHz] m) | 7-2 (144 MHz のダイポール) と同じ作り方で長さだけ変える。NanoVNA で SWR の底が帯の中にあるのを確かめてから使う |
| 430 MHz 帯 | λ (ラムダ、波長) の 1/4 のホイップ (7-3) | 7-3 のまま |

- アンテナは**放電してから**つなぐ (0-4)。屋外に張った線は、乾いた日や雷の近い日に大きく帯電する
- 同軸は短くする (損失は 11-14 の「ケーブルの損失を測る」。この題では 0 dB とみなす)
- この題は回路図と実体配線図を付けない。アンテナの同軸を tinySA の RF に直につなぐだけで、組む回路が無い
- SDR (RTL-SDR など、11-1) でも同じことはできる。ただし dBm の絶対値の確かさは tinySA より低い

## 計器の設定

計器は tinySA Ultra。AD3 とオシロは使わない (受けるだけで、10 MHz を超える)。

| 一般の名前 | FM 放送帯 (図1) | 430 MHz 帯 (図2) | tinySA Ultra のメニュー |
| --- | --- | --- | --- |
| 開始・終了 | 76〜98.45 MHz (450 点、1 点 = 50 kHz) | 430〜438.98 MHz (450 点、1 点 = 20 kHz) | `FREQUENCY` → `START` / `STOP` |
| RBW | 100 kHz | 10 kHz | `FREQUENCY` → `RBW` |
| 基準レベル・目盛 | −30 dBm・10 dB/div | −70 dBm・5 dB/div | `LEVEL` → `REF LEVEL`・`SCALE/DIV` |
| 入力アッテネータ | 自動 | 自動 | `LEVEL` → `ATTENUATE` |
| 保持 | 無し | MAX HOLD (数分〜数時間貯める) | `TRACE` → `CALC` → `MAX HOLD` |

- FM 放送の 1 局は ±75 kHz ほど周波数が振れるので、RBW 100 kHz では幅 200 kHz ほどの山に見える。
  RBW を 10 kHz に狭めると山が崩れて見えるが、局の高さは RBW を広くした読みで読む
- 430 MHz は弱い。RBW 10 kHz でフロアは約 −106.8 dBm (11-2 の換算)。もっと下を見たいときは
  `LEVEL` → `LNA` を入れる (フロアが最大 16 dB 下がる。代わりに内部の減衰が切れ、強い電波で飽和しやすい)
- **強い電波で tinySA の中が歪んでいないか**を一度確かめる。減衰を手動で 10 dB 増やして、山が動かず
  フロアだけが上がれば本物 (11-10)。FM 放送の局が近いと、局どうしの相互変調の山が帯の中に立つことがある

## 計器の画面

**FM 放送帯の例** (見えるはずの画面の例。局の周波数と電界強度は仮の値で、自分の地域の局に置き換える)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図1 FM 放送帯の例 — 70・60・50 dBµV/m の 3 局をダイポールで受ける
device: tinysa-ultra
sweep: 76M-98.45M 450
rbw: 100kHz
ref: -30dBm
signal:
  - sine 80MHz -43.1dBm
  - sine 82.5MHz -53.4dBm
  - sine 85.2MHz -63.7dBm
markers: [80M, 82.5M, 85.2M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/12-antenna-receive-1.svg)

- 図は局を 1 本の線で描いた。実物は FM の振れで RBW より少し太い山になる
- 帯の外 (95 MHz より上) にも、ほかの業務の電波が見えることがある。局と見分けるには周波数の割当を調べる

**430 MHz 帯の例** (MAX HOLD。2 回の送信を貯めた画面。周波数と強さは仮の値)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図2 430 MHz 帯の例 — 出たり止んだりする電波を MAX HOLD で貯める
device: tinysa-ultra
sweep: 430M-438.98M 450
rbw: 10kHz
ref: -70dBm
scale: 5dB
hold:
  - sine 433MHz -80dBm
  - sine 435.5MHz -90dBm
markers: [433M, 435.5M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/12-antenna-receive-2.svg)

- マーカー 2 の −89.9 dBm は、−90 dBm の電波にフロア (−106.8 dBm) の電力がわずかに足された読み
- `MAX HOLD` は点ごとに一番大きかった値を残す。見ている間に 1 度でも出た電波が残り、どの周波数が
  使われたかが分かる。今出ているかは、もう 1 本のトレースを `CALC` なしにして重ねて見る
- `DISPLAY` → `WATERFALL` にすると、時間とともに上から下へ流れる図になり、いつ出たかも分かる

## 見るべき値

アンテナ係数 AF (11-14 の半波長ダイポールの式 AF = 9.73 / (λ √1.64)) で、tinySA の読み P [dBm] を電界強度 E に直す:
**E [dBµV/m] = P + 107 + AF + L** (µ はマイクロ) (L はケーブルの損失、ここでは 0 dB)。

| 周波数 | 波長 λ | AF (計算値) | 電界強度 (例) | tinySA の読み (計算値) |
| --- | --- | --- | --- | --- |
| 80.0 MHz | 3.75 m | 6.1 dB/m | 70 dBµV/m | −43.1 dBm |
| 82.5 MHz | 3.64 m | 6.4 dB/m | 60 dBµV/m | −53.4 dBm |
| 85.2 MHz | 3.52 m | 6.7 dB/m | 50 dBµV/m | −63.7 dBm |
| 433 MHz (ホイップ) | 0.69 m | 20.8 dB/m (ダイポールの値で代用、目安) | 47.8 dBµV/m | −80 dBm (例) |

分かること:

- 読みから電界強度を出すと、局ごとの強さを比べられる。**ダイポールの向き** (水平・垂直) を変えると
  読みが変わる (局の偏波に合う向きで一番大きく読む)
- 一番強い局が −43 dBm なら、tinySA の入力の推奨の上限 (0 dBm) より十分に低い。ただし近くに放送の
  送信所があると −10 dBm を超えることもあり、そのときは減衰を入れる (11-1)
- 430 MHz のホイップは λ/4 で、ダイポールと利得も給電の形も違う。表の AF は目安で、絶対値の比べには
  使わない。ここでは「出ていたか・どの周波数か」を見る
- 受けた電波の中身 (音声) は、`LEVEL` → `LISTEN` でイヤホンから聞ける (AM だけ。公式の仕様)

## LTspice での確かめ (対象外)

アンテナで電波を受ける題で、SPICE で模型にできる回路が無い (アンテナの利得と飛んでくる電波は回路ではない)。
数は算術で確かめた: λ = 300 / f[MHz]、AF = 20 log₁₀ (9.73 / (λ √1.64)) は 80.0 MHz で 6.13 dB/m、
82.5 MHz で 6.40 dB/m、85.2 MHz で 6.68 dB/m、433 MHz で 20.80 dB/m。P = E − 107 − AF は 70 dBµV/m で
−43.1 dBm、60 で −53.4 dBm、50 で −63.7 dBm、−80 dBm の読みは 47.8 dBµV/m。11-14 の表 (80 MHz で 6.1 dB/m、
430 MHz で 20.7 dB/m) とも合う。フロア −106.8 dBm (RBW 10 kHz) は 11-2 の換算と同じ。

## 出典

自作。アンテナ係数の式は 11-14。アンテナは 7-2・7-3、放電は 0-4。
tinySA の `MAX HOLD`・`WATERFALL`・`LISTEN`・LNA は
[メニューの一覧](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.MenuTree)と
[仕様](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification) (2026-11-14 に確認)。
日本の FM 放送の周波数 (76〜95 MHz) は総務省の周波数割当計画による。
