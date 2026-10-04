---
book: fpga
chapter: 4
id: 4-2
title: カウンタの 8 ビットをロジックアナライザの画面で見る
tier: 50
source: 自作
board: —
device: WEB
---

# 4-2 カウンタの 8 ビットをロジックアナライザの画面で見る

この題は実体配線図と Analog Discovery 3 の図を付けない。ブラウザの中で動く題で、組む物が無いから。

0-5 で開いた 01-counter の画面は、ロジックアナライザの画面と同じ形をしている。
横が時間、縦が信号の並び (レーン)、各レーンが 0 と 1 の高低で描かれる。
この題では、その画面の読み方を覚える。AD3 の Logic も同じ読み方で読める。

## 画面の約束

[https://tommie-jp.github.io/soft-fpga/01-counter/](https://tommie-jp.github.io/soft-fpga/01-counter/) を開いて確かめる。

- レーンは 8 本。上から `b7`、`b6`、…、`b0`。**一番上が最上位のビット**
- 横の 1 ピクセルが 1 クロック。左が古く、右が最新
- 一番左の見えているサンプルから右へ、時間が進む
- 見える長さは、画面の幅 800 から左の名前の欄 32 を引いた 768 サンプルまで。リングバッファは 1024 個なので、それより古い分は消える

soft-fpga の 01-counter の画面に、カーソルは無い。ライブラリ (`js/rtlscope-la.js`) にはマーカー (A・B・C) があるが、01 は使っていない。
カーソルで読む練習は、この題の `logic` の図と、0-4 で行う。

## 読み方の練習

次の図は、リセットの直後から 20 クロックぶんを `logic` のフェンスで描いたもの。ブラウザの画面には時間の単位が無いので、1 クロックを 1 ms と置いた仮の目盛。
レーンの名前は Q0〜Q7 (soft-fpga の画面では `b0`〜`b7`)。

```logic
title: 図1 count が 8 になる所は Q0・Q1・Q2 が一斉に下がり Q3 が上がる
device: generic
window: 20ms
signals:
  CLK: dio0 clock 1kHz
  Q: dio1..dio8 counter on CLK rising start 1 wrap 256
buses:
  Count: Q7..Q0 hex
cursors: [7.25ms, 15.25ms]
trigger: CLK rising at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/06-fpga/04-soft-fpga-web/logic/02-counter-logic-screen.svg)

- バスの欄は、8 本のレーンを 16 進の 1 つの数にまとめたもの。soft-fpga の画面にバスの欄は無いので、`b7` を上位にして自分で読む
- X1 (7.25 ms) では Count = 0x08、2 進で `00001000`。Q3 だけが 1
- X2 (15.25 ms) では Count = 0x10、2 進で `00010000`。Q4 だけが 1
- 2 つのカーソルの間は 8 ms で、8 クロックぶん。count が 8 増えている

### 繰り上がりを見る

7 から 8 に変わる 1 回の立ち上がりで、`Q0`・`Q1`・`Q2` が 1 から 0 に、`Q3` が 0 から 1 に変わる。
2 進数で 0111 に 1 を加えて 1000 になる、あの繰り上がりが、4 本のレーンの同時の変化として見える。

| クロック | count | Q3 | Q2 | Q1 | Q0 |
| --- | --- | --- | --- | --- | --- |
| 7 回目の立ち上がりの後 | 7 | 0 | 1 | 1 | 1 |
| 8 回目の立ち上がりの後 | 8 | 1 | 0 | 0 | 0 |

実機では、4 本が全く同時に変わるとは限らない (第 9 章)。Soft-FPGA の画面では、クロックの区切りでそろって変わる。

## 見るべき値

図の読み値は `logic-fence` の check で出したもの。

| 見る所 | 値 | 種類 |
| --- | --- | --- |
| X1 (7.25 ms) の Count | 0x08 | 計算値 (図の読み値) |
| X2 (15.25 ms) の Count | 0x10 | 計算値 (図の読み値) |
| X2 − X1 | 8 ms (1/ΔX = 125 Hz) | 計算値 |
| 画面に見える最大のサンプル数 | 768 | 画面の幅 800 − 名前の欄 32 (`index.html` から) |
| `b7` が 768 サンプルの間に反転する回数 | 約 6 回 (128 クロックごと) | 計算値 |

ブラウザでは、Run を押して止めたあと、`b0` の細かさと `b7` の遅さを見比べる。
`b7` は 128 クロックごとに反転するので、止めた画面には 3 周期ほどが入る。

## 出典

自作。画面の仕様は [tommie-jp/soft-fpga](https://github.com/tommie-jp/soft-fpga) の `examples/01-counter/web/index.html`。
計器の画面の読み方は、AD3 の Logic について Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
