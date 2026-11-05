---
book: analog-discovery
chapter: 1
id: 1-13
title: ロガーを Script から回して CSV に追記する
tier: 200
source: 自作 (計器の名前は Digilent の Analog Discovery 3 の公式資料)
board: BB
---

# 1-13 ロガーを Script から回して CSV に追記する

1-3 では Data Logger (Logger) の画面で 1 分を記録した。画面の記録は、止めて書き出すまでファイルに残らない。
何時間も回すときや、日をまたいで同じファイルに足していきたいときは、**Script** から Logger を動かし、
1 点読むごとに CSV ファイルの末尾へ 1 行ずつ**追記**する。途中で WaveForms が落ちても、それまでの行は残る。

この題では可変抵抗 (ポテンショメータ) の真ん中の電圧を 1 秒ごとに 60 点読み、ファイルに足していく。
つまみを回すと、行の値が変わっていく。1-5 の Script の続き (第 11 章の前の練習)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 5 V を VR1 (B10K) で分け、真ん中 (w) を CH1 で読む
parts:
  VCC: vcc 3,1 5V
  VR1: potentiometer 3,1 3,4 l=$\mathrm{VR1}$
  M1: voltmeter 6,2.5 6,4 l=$\mathrm{CH1}$
  G1: ground 3,4
  G2: ground 6,4
wires:
  - VR1.w -- 6,2.5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/13-logger-script-csv.svg)

- VR1 は B カーブ (回した角度に比例する) の 10 kΩ (キロオーム)。両端を +5 V と GND に、真ん中のピン (w) を CH1 へ
- VR1 に流れる電流は 5 V ÷ 10 kΩ = 0.5 mA

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 VR1 の 3 本のピンを 10・11・12 列に。真ん中 (11 列) を CH1 へ
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, GND, 1-, 1+]
  VR1: potentiometer/knob e10(1) e11(W) e12(3) 10k
wires:
  - AD.V+ -- +t2 red
  - AD.GND -- -t3 black
  - AD.1- -- -t5 black
  - a10 -- +t10 red
  - a12 -- -t12 black
  - AD.1+ -- b11 orange
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/13-logger-script-csv.svg)

## Script

**Script** の窓に書いて `Run` を押す。Logger を動かし、1 秒ごとに CH1 の平均を読んで、
`経過秒,電圧` の 1 行をファイルの末尾に足す。**このスクリプトは実機で動かしていない。**
Logger のプロパティの名前とファイルの関数の名前 (`FileAppendLine`) は WaveForms の版で違うことがあるので、
Script の窓の補完と Help で確かめてから使う (目安)。

```javascript
// 1 秒ごとに CH1 の平均を読み、CSV の末尾に 1 行ずつ足す (60 行)
var path = "logger-1-13.csv";   // 保存先。フルパスで書いてもよい
var points = 60;                // 読む回数
var writeHeader = false;        // 新しいファイルのときだけ true にして見出しを書く

if (writeHeader) {
  FileAppendLine(path, "elapsed_s,ch1_V");
}

Logger1.run();
var t0 = Date.now();

for (var i = 0; i < points; i++) {
  wait(1);                                       // 1 秒待つ
  var v = Logger1.Channel1.measure("Average");   // 最後の 1 点の平均 (名前は目安)
  var t = (Date.now() - t0) / 1000;
  FileAppendLine(path, t.toFixed(1) + "," + v.toFixed(4));
  print(i + 1 + " / " + points + " : " + v.toFixed(3) + " V");
}

Logger1.stop();
```

- `FileAppendLine` は、ファイルが無ければ作り、あれば末尾に 1 行足す。もう一度 Run すると、前の 60 行の後ろに続く
- 時刻は `Date.now()` の差で、`wait(1)` の待ちと読み出しの時間を含む。1 行の間隔は 1 秒より少し長くなる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V、Master Enable |
| Data Logger | CH1、DC。Rate は 1 秒に 1 点以上 (Logger の上限は 1 秒に 10 点) |
| Script | 上のコード。`path` は書き込めるフォルダに |

この題はオシロの図を付けない — 見るのは直流の電圧 (つまみで手で変える、1 秒ごとの値) だけで、波の形は無いため。

## 部品

| 記号 | 部品 | 値・型 | 備考 |
| --- | --- | --- | --- |
| VR1 | 可変抵抗 (つまみ付き) | B10K (10 kΩ、B カーブ) | 回転角 300° の品を想定 |

## 見るべき値

| 確かめる所 | 期待する値 | 分かること |
| --- | --- | --- |
| つまみを左に回し切る | CH1 ≈ 0 V | 真ん中のピンが GND 側の端 (どちらに回すと上がるかは品とピンのつなぎ方による) |
| 真ん中 (150°) | CH1 ≈ 2.5 V | B カーブは角度に比例 |
| 右に回し切る | CH1 ≈ 5.0 V | +5 V 側の端 |
| 1 回の Run の後のファイル | 60 行 (見出しを書いたら 61 行)。1 列目は 1.0, 2.0 … と 1 秒ほどずつ増える | 1 行ずつ足している |
| もう一度 Run | 120 行。2 回目の 1 列目は 1.0 から始め直す | 前の行が消えずに残る (上書きではない) |

2 回目の時刻を続きにしたいときは、`t0` の代わりに日時 (`new Date().toISOString()`) を 1 列目に書く。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 VR1 (B カーブ) の角度と CH1 — 150° で 2.5 V
x: つまみの角度 deg 0..300
y: CH1 の電圧 V 0..5
lines:
  計算 (5 V × 角度 ÷ 300°) V: 5*x/300
notes:
  - mark 0
  - mark 150
  - mark 300
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/graph/13-logger-script-csv.svg)

## LTspice での確かめ (対象外)

可変抵抗の分圧と行の数え方だけで、算術で確かめた。真ん中のピンの電圧は 5 V × 角度 / 300° で、0°・150°・300° で 0・2.5・5.0 V。
電流は 5 V / 10 kΩ = 0.5 mA。60 回読むと 60 行、2 回目で 120 行。本文の値と合う。

## 出典

自作。Logger が 1 秒に 10 点まで記録できることは Digilent の
[Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
(Data Logger の節)。Script の書き方は 1-5 と同じく WaveForms の Script の窓の Help による。

参考: [CSV (Wikipedia)](https://ja.wikipedia.org/wiki/CSV)
