---
name: workbook-writing
description: tommie-circuit-workbook の題 (1 題 1 ファイル) を新しく書く・直すときに使う。段 (必須 50 / 入門 100 / 中級 200) の選び方、入門までは低周波 (3 MHz 以下) に絞る流儀、front matter、本文の順、部品の値 (E24)、電源 (5 V)、実体配線図・Analog Discovery 3・オシロの図を全題に入れる決まり、書いたあとの検査 (npm run all) と図を PNG で点検する手順をまとめてある。Use when adding or editing a chapter (題) of the circuit / Analog Discovery / NanoVNA / denken workbook and deciding its tier, frequency range, parts, figures and checks.
---

# 教科書の題を書く

置き場・front matter・本文の順・部品の値・電源は、ルートの `README.md` の「書き方」が正本。
ここには、題を足すときの手順と、段と周波数の決まりをまとめる。

## 1. 段と周波数の範囲

必須 ⊂ 入門 ⊂ 中級 の入れ子。段ごとに、題で扱う周波数の上限を次のようにそろえる。

| 段 | 周波数 | 計器 | 基板 |
| --- | --- | --- | --- |
| 必須 | 3 MHz 以下 | AD3 のオシロ・波形発生器・スペクトラム | ブレッドボード |
| 入門 | 3 MHz 以下 (必須と同じ) | 同上 | ブレッドボードか perfboard |
| 中級 | 制限なし。ただし 01-circuits の README の基板ごとの範囲に従う (10 MHz 超は銅張り基板) | tinySA・VNA を足してよい | 範囲による |

- **入門までの題は、信号の周波数を 3 MHz 以下に絞る**。ブレッドボードの浮遊容量と AD3 のオシロの帯域 (9 MHz) の内側で、組んだとおりに測れるから。初めて組む人が「合わない」原因を配線ミスだけに絞れる
- 既に必須・入門に置いてある FM 帯の題 (9-4 FM 送信機・9-6 超再生 FM ラジオ) は、題材が FM 放送帯で、銅張り基板に組むので例外。書き足すときも同じ扱いにする
- 3 MHz を超える題 (FM・27 MHz・GHz 帯・DDS の 7 MHz など) は中級に置く。入門に置くなら、超える理由を題に 1 行書く
  (例: 「FM 放送帯の超再生は 3 MHz 以下では題が成り立たない」)
- 中波ラジオ (0.53〜1.6 MHz) と IF 455 kHz は 3 MHz 以下なので入門に置ける
- 例外: NanoVNA の冊は測る帯域そのものが題材なので、この冊は 3 MHz の絞りを課さない
  (入門では低い帯域の題から始め、GHz 帯は中級に寄せる)
- 掃引や FFT の表示範囲が 3 MHz を超えても、**回路が働く周波数**が 3 MHz 以下ならよい
  (高調波・像を見るために 10 MHz まで見る、など)。そのときは本文に見る範囲を書く

## 2. 題を足す手順

1. `<NN-冊>/plan.yaml` に 1 行足す (`id` `tier` `board` `title`)。既存の題と同じ型 (部品表・回路図・実体配線図・AD3・scope)
2. 同じ章の手本の題を 1 つ開き、本文の順をそろえる (説明 → 回路図 → 実体配線図 → 計器の設定 → 見るべき値 → 出典)
3. 部品の値は E24、電源は 5 V。外すときは部品表に理由を 1 行
4. **数式と数値は確かめる**。LTspice (または ngspice) で解析し、表の値と突き合わせる。確かめていない値は「見積り」と書く
5. 図は tommie-fence スキルと readable-schematic・breadboard-wiring・instrument-screen の点検表を通す。
   `npm run render` で出した SVG を PNG にして目で見る (check はつながりしか見ない)
6. 実体配線図・AD3・scope を入れない題は、理由を題に 1 行 (理由になることは README の「書き方」の表)
7. `npm run toc` で目次を直し、`npm run all` を通す。コミットは conventional commits (`docs:`)

## 3. 言葉

- 基板は「基板」か物の名前 (ブレッドボード・ユニバーサル基板・銅張り基板) で呼ぶ。単に「板」と書かない
- 部品のピンは「ピン」と書く。「足」と書かない
- 「ひずみ」は漢字 (歪み)・「センサー」は長音を付ける (README の用語の統一)
- 教科書の題を指すときは、題名だけでなく `tommie-circuit-workbook` からの相対パスを書く
- 借りた回路は `source` と本文の出典に出所を書き、図と文は写さず描き直す
