---
book: analog-discovery
chapter: 0
id: 0-4
title: ワークスペースの保存、CSV と画像の書き出し
tier: 50
source: 自作
board: BB
---

# 0-4 ワークスペースの保存、CSV と画像の書き出し

0-3 のループバックをそのまま使い、WaveForms の**保存**と**書き出し**を
一通り試す。設定を毎回組み直さずに済ませる保存と、測った波形を
外の道具 (表計算・レポート) に持ち出す書き出しは、以後どの計器でも使う。

## 回路図

```circuit
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: triangle a1 c1 1
  M1: voltmeter a3 c3 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3
  - c1 -- c3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/04-workspace-save-export.svg)

0-3 と同じ配線。ここでは正弦波の代わりに**三角波**にして、CSV に
書き出したときに値の変化が読み取りやすくしてある。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (W1 を 1+ に直結)
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange
  - AD.GND -- -t3 black
  - AD.1- -- -t8 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/breadboard/04-workspace-save-export.svg)

配線は 0-3 と同じ。W1 と 1+ を 5 列に挿し、GND と 1− を上の − レールにまとめる。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 三角波、1 kHz、振幅 1 V、オフセット 0 V |
| Scope (CH1) | DC、**Sample Rate を 1 MS/s に固定**、Record Length 1000 (1 ms ぶん) |

Sample Rate を固定 (Base Frequency ではなく数値を直接指定) しておくと、
書き出した CSV の行数と時間刻みが計算どおりになる。

記録の 1 ms は、100 μs/div の画面のちょうど横 10 目盛にあたる。t = 0 (トリガ) を
左端に寄せると、CSV の 1 行目から最後の行までが画面の端から端に並ぶ。

```scope
title: 図3 記録の 1 ms (1000 点) が三角波のちょうど 1 周期
time: 100us/div
trigger: ch1 rising 0V at -5div
ch1: {wave: triangle 1kHz 1V, range: 500mV/div}
cursors: [0, 1ms]
measure: [vpp, period]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/scope/04-workspace-save-export.svg)

## 手順

1. **ワークスペースの保存**: `File > Save` (または `Save As`) で
   `.dwf3work` として保存する。計器の窓の配置・チャネルの設定
   (レンジ・カップリング)・Wavegen の波形がまとめて入る。次に開くときは
   `File > Open` でこのファイルを選ぶだけで、同じ画面に戻れる
2. **CSV の書き出し**: Scope のグラフを右クリック → `Export` →
   `CSV (Discrete)` を選ぶ。1 列目が時刻 (s)、2 列目が CH1 (V) になる
3. **画像の書き出し**: Scope の右上のカメラの印 (または `File > Export`
   の `Image`) で PNG に書き出す。レポートに貼るときはこちらを使う

## 見るべき値

| 確かめる所 | 期待する値 | 分かること |
| --- | --- | --- |
| CSV の行数 | 1000 行 (= Record Length) | Sample Rate 1 MS/s で 1 ms ぶん記録すると 1000 点になる |
| CSV の 1 行目の時刻 | 0.000000 s | 記録の起点 |
| CSV の 1 周期ぶんの行数 | 1000 行 (= 1 ms ÷ 1 μs) | 1 kHz の 1 周期がちょうど記録の全長と一致する (計算値) |
| 保存したワークスペースを開き直す | 計器の窓・設定が保存前と同じに戻る | `.dwf3work` に画面ごと入っていることの確認 |

## 出典

自作。
