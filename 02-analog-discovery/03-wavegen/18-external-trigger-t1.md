---
book: analog-discovery
chapter: 3
id: 3-18
title: 外部トリガ (T1) で同期する
tier: 200
source: 自作 (計器の操作は Digilent の WaveForms リファレンスマニュアル)
board: —
---

# 3-18 外部トリガ (T1) で同期する

AD3 のヘッダには、計器のほかに **T1・T2** (外部トリガの入出力) の 2 本のピンがある。AD3 の中のトリガの仕組みは、
どの計器のトリガも、T1・T2 から入った信号も、どの計器の起動にも使える (仕様)。
ここでは T1 を**入力**にし、外の機械が出す「今始めよ」のパルスで Wavegen を起動し、同じ T1 で Scope も捕まえる。
外の機械の代わりに、AD3 自身の Patterns の DIO0 から 100 Hz のパルスを出して T1 に入れる。
試験の対象 (被測定物) の動作の合図に合わせて刺激を入れる、という使い方の練習になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 DIO0 の合図を T1 に入れ、W1 を T1 で起動する
parts:
  V2: square 1,1 1,3 l=$\mathrm{DIO0}$
  M2: voltmeter 3,1 3,3 l=$\mathrm{CH2}$
  T1: port 5,1 in
  V1: sine 1,4 1,6 l=$\mathrm{W1}$
  M1: voltmeter 3,4 3,6 l=$\mathrm{CH1}$
  G1: ground 1,6
  G2: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,4 -- 3,4
  - 1,3 -- 3,3
  - 1,6 -- 3,6
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/circuit/18-external-trigger-t1.svg)

- V2 (DIO0) は Patterns の Clock 100 Hz (0 V / 3.3 V)。これを T1 と CH2 (2+) に配る。外の機械を使うときは、その合図の出力をここに置き換える
- T1 の入力の電圧は DIO と同じ 3.3 V の LVCMOS で、5 V までは耐える (仕様)。5 V の論理の合図はそのまま入れてよいが、それより高い電圧は分圧してから入れる
- W1 は CH1 (1+) へ直結。GND・1−・2− は共通

実体配線図は載せない。部品が無く、AD3 のワイヤの 3 本 (DIO0・T1・2+) を 1 か所で結び、W1 と 1+ を結ぶだけで、
基板を使わない (ブレッドボードの同じ列に挿すなら 3-3 の図2 と同じ挿し方)。

## 計器の設定

WaveForms の画面の項目の名前は版で違うことがある (**目安**)。

| 計器 | 設定 |
| --- | --- |
| Patterns | DIO0: Clock、Frequency 100 Hz、Duty 50 % (10 ms ごとに立ち上がる) |
| Wavegen | W1: Sine 1 kHz、Amplitude 1 V。起動の条件 (Trigger) に **External 1 (T1)** を選ぶ。1 回の起動で出す長さ (Run) を 3 ms (3 周期)、休み (Wait) 0、くり返し (Repeat) は無限 |
| Scope | CH1: Range 500 mV/div、CH2: Range 1 V/div。Time 1 ms/div、トリガの源を **External 1 (T1)** の立ち上がり、位置 −4 div |
| 機器の設定 | T1 を入力にする (出力にしているとぶつかる) |

T1 の立ち上がりのたびに W1 は 0 V から正弦の 3 周期を出して止まり、次の合図を待つ (図2)。Scope も同じ T1 で捕まえるので、
画面は毎回同じ所で止まる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 T1 の合図 (CH2) の立ち上がりで W1 (CH1) が 3 周期だけ出る
time: 1ms/div
trigger: ch2 rising 1.65V at -4div
ch1: {wave: = 1V * sin(2 * pi * 1kHz * t) * step(t) * step(3ms - t), range: 500mV/div, position: 1.5div}
ch2: {wave: square 100Hz 1.65V offset 1.65V, range: 1V/div, position: -4div}
cursors: [0, 3ms]
measure: [vmax, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/03-wavegen/scope/18-external-trigger-t1.svg)

図2 では CH2 の立ち上がりでトリガを掛けて描いたが、実機の Scope は T1 (CH2 と同じ線) で掛かる。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| バーストの長さ (カーソル) | 3.00 ms (1 kHz の 3 周期) | Run の長さ |
| バーストの間隔 | 10.0 ms (CH2 の 100 Hz) | W1 が T1 の合図にそろう。Patterns の周波数を変えると間隔もついてくる |
| T1 の立ち上がりから W1 が動くまで | 数 µs 以下 (**未確認**) | 遅れは公開されていない。Time を 1 µs/div まで縮めて読む。トリガの分解能は 8〜20 ns (仕様、既定 10 ns) |
| Patterns を止めたとき | W1 は止まったまま | 合図が無ければ出さない。Scope も Normal (Auto でない) なら画面が止まる |
| Wavegen の Trigger を None に戻したとき | W1 は勝手に出続け、Scope の画面の波は 1 回ごとに位置が変わる | 合図と無関係に走るので、10 ms と 3 ms + 休みの周期がずれて流れる |

分かること:

- **外部トリガは「いつ始めるか」をそろえるだけで、「どの速さで動くか」はそろえない**。W1 の 1 kHz は AD3 の中の時計で決まる。
  外の機械の時計と W1 の周波数をそろえたいときは、T1 で基準の時計を出し入れする使い方がある (仕様に「Trigger 1 can be used to export or import a reference clock」とある。2 台の同期は 0-8)
- T1 を**出力**にすると、Wavegen の起動などの AD3 の中のトリガを外へ出せる。ベンチのオシロスコープの外部トリガ (EXT TRIG) に入れれば、
  AD3 の Wavegen に合わせて別のオシロスコープを止められる
- 合図の線が長いと、辺の跳ね返りで 1 回の合図が 2 回に数えられることがある。T1 の線は短くし、GND を同じ所で結ぶ

## LTspice での確かめ (対象外)

時間の算術で確かめた (回路は AD3 のピンどうしを結ぶだけ)。1 kHz の 3 周期は 3 × 1 ms = 3.00 ms、Patterns の 100 Hz の周期は 10.0 ms で、
休みは 10 − 3 = 7 ms。T1 の高さ 3.3 V は DIO の H の下限 2.0 V (仕様) を超え、L の 0 V は上限 0.8 V を下回る。本文の表と合う。

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Wavegen・Scope・Patterns のトリガの節)。トリガの源・分解能と T1・T2 の電気の特性は
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
(Trigger System と Digital Channels の表)。
