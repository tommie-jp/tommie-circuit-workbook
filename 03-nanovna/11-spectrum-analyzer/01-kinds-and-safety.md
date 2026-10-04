---
book: nanovna
chapter: 11
id: 11-1
title: スペアナの種類 — 掃引型・FFT 型・SDR と、壊さない使い方
tier: 100
source: 自作
board: —
device: SA
---

# 11-1 スペアナの種類 — 掃引型・FFT 型・SDR と、壊さない使い方

**スペクトラムアナライザ (スペアナ) は、受信だけをする計器。** NanoVNA (VNA)
は自分で信号を送り出して、跳ね返り (S11) と通り抜け (S21) を複素数
(振幅と位相) で測るが、スペアナは**外から来た信号の振幅 (パワー) だけ**を
周波数ごとに見る。位相は分からない。0-1 で見た H4 / V2 の使い分けと同じ形で、
スペアナにも数種類の作りがあり、それぞれ得意な範囲と弱点が違う。

## 同じ種類の計器

範囲は 2026-09-27 時点でメーカーの仕様頁を確かめた値 (tinySA は公式 wiki)。
モデルが多い種類は目安として書く。

| 種類 | 例 | 範囲 (目安) | 何が違うか |
| --- | --- | --- | --- |
| 掃引型ハンディ | **tinySA Basic** | LOW 入力 100 kHz〜350 MHz、HIGH 入力 240〜960 MHz。RBW 3〜600 kHz (手動。自動選択はもっと細かい) | 安い。入力端子が LOW / HIGH の 2 つに分かれる。信号発生器も兼ねる |
| 〃 | **tinySA Ultra (ZS-405、この章の例の機種)** | 通常モード 100 kHz〜800 MHz (Ultra+ は 900 MHz)、Ultra モードで 6 GHz まで (ZS407 は 7.3 GHz)。RBW 0.2〜850 kHz (9 段) | 入力端子 1 つで広い範囲。800 MHz より上は Ultra モード (高調波ミキシング) になり、イメージ・スプリアスに注意が要る (11-10) |
| 〃 | RF Explorer | モデルにより 15 MHz〜3.3 GHz、50 kHz〜6.1 GHz など。ライセンスで 7.5 GHz まで拡張できる機種もある | 同じ種類のハンディ。モデル・ライセンスで範囲を選ぶ |
| SDR + ソフト | RTL-SDR (R820T2 系) | 目安 24 MHz〜1.7 GHz (直接サンプリング改造で下も伸ばせる) | 受信機を掃引してスペアナに見せる。**絶対値 (dBm) の確かさは低い**。ダイナミックレンジは ADC の bit 数で決まる |
| 〃 | HackRF One + `hackrf_sweep` | 1 MHz〜6 GHz | 掃引ソフトで全帯域を走査。SDR 共通の弱点 (絶対値の較正が弱い) はそのまま |
| 据え置き | Siglent SSA3000X 系 | モデルにより 9 kHz〜2.1 / 3.2 GHz など | 絶対値が校正されている。RBW が 1 Hz 台まで細かく、ノイズフロアが低い。トラッキングジェネレータ付きの型もある |
| 〃 | Rigol DSA800 系 (DSA815 / DSA832) | DSA815: 9 kHz〜1.5 GHz、DSA832: 9 kHz〜3.2 GHz | 同上。据え置きは絶対値を信じてよい代わりに持ち歩けない |
| FFT 型 | Analog Discovery の **Spectrum** | 0 Hz〜10 MHz 程度 (サンプル周波数の設定による) | **掃引しない。** 取り込んだ時間波形を丸ごと FFT にかける。低い周波数 (kHz 帯) で得意 (Analog Discovery の教科書の第 4 章) |
| 〃 | オシロスコープの FFT 機能 | オシロの帯域による (機種ごとに違う、目安) | 考え方は Spectrum と同じ。専用機ではなく汎用オシロのおまけ機能 |

分かること:

- **掃引型は 1 点ずつ周波数を変えて受信レベルを測る** (時間がかかるが範囲を
  広く取れる)。**FFT 型は取り込んだ時間波形を一度に周波数へ変換する**
  (速いが、範囲はサンプル周波数の半分まで)。SDR はハードは受信機、ソフトが
  掃引かFFTかを選ぶ (`hackrf_sweep` は掃引式)
- 据え置きは絶対値 (dBm) を信じてよいように工場で校正されている。ハンディと
  SDR は個体差があるので、**同じ信号を 2 台で測って dB 単位の差を比べる**のは
  よいが、**dBm の絶対値を他の測定と厳密に突き合わせる**のは向かない
- 部品やフィルタをスペアナで測るときも、NanoVNA の 3-1 と同じ考え方で
  **50 Ω の環境をできるだけ保つ小さな治具**を使う (11-8 で信号発生器と
  組み合わせて使う)

## 壊さない使い方 — 入力の上限とアッテネータ

**スペアナの入力回路 (LNA・ミキサ) は、NanoVNA の CH1 (0-3) と同じように
壊れる上限を持つ。** 表に挙げた機種の目安 (0 dB 減衰のとき):

| 機種 | 入力の上限の目安 |
| --- | --- |
| tinySA Basic | +10 dBm (LOW / HIGH とも) |
| tinySA Ultra | 推奨は +0 dBm 以下 (内部減衰を自動にしたとき)。**絶対最大は +6 dBm** (内部減衰 0 dB) で、これを超えると壊れる。短時間のピークは内部減衰 30 dB で +20 dBm まで。DC は ±5 V まで (tinySA の wiki の仕様) |
| 据え置き機 (Siglent / Rigol など) | 機種の説明書に明記 (だいたい +20〜+30 dBm 前後のことが多い。**必ず自分の機種の値で確かめる**) |

**0-3 と同じ決まり**: 送信機やアンプの出力を直接入れない。**必要な減衰量
[dB] = 送りたい信号のレベル [dBm] − 入力の上限 [dBm]** を計算して、それ以上の
アッテネータを先に挟む。tinySA は `LEVEL` メニューに `ATTENUATE` (0〜31 dB、
自動もあり) を持つが、**これは内部の減衰であって、外部の強い信号から回路を
守るものではない**。外の信号が大きいときは、外付けのアッテネータで先に
落としてから入れる。

アンテナを直接つなぐとき (11-12) は、静電気の放電も 0-4 と同じように先に
済ませておく。

## 出典

自作。範囲・入力上限は各社の仕様頁 (2026-09-27 に確認):
[tinySA Ultra の仕様](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification)、
[tinySA Basic の仕様](https://tinysa.org/wiki/pmwiki.php?n=Main.Specification)、
[RF Explorer のモデル一覧](https://rfexplorer.com/models/)、
[Siglent SSA3000X](https://siglentna.com/spectrum-analyzers/ssa3000x-series-spectrum-analyzers/)、
[Rigol DSA800](https://www.rigol.com/intl/products/spectrum-analyzer/DSA800.html)、
[RTL-SDR (R820T2) の受信範囲](https://www.rtl-sdr.com/tag/r820t2/)、
[HackRF One の仕様](https://hackrf.readthedocs.io/en/latest/hackrf_one.html)。
