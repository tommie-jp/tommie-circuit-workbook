---
book: analog-discovery
chapter: 1
id: 1-15
title: プロジェクトとプリセットで設定を使い回す
tier: 200
source: 自作 (Script の書き方は 1-5 と同じ)
board: —
---

# 1-15 プロジェクトとプリセットで設定を使い回す

0-4 では、画面ごと (窓の並び・各計器の設定) を 1 つのファイルに保存した。この教科書では、このファイルを
**プロジェクト**と呼ぶ (WaveForms の版によって、メニューの名前は Workspace か Project。保存の拡張子も版で違う。目安)。
実験のたびに同じ設定を打ち直さずに済む。

ただ、プロジェクトは「画面の写し」なので、題ごとに 1 つずつ増えていき、少しだけ違う設定 (振幅だけ違う、など) を
作るたびにファイルが増える。そこでこの題では 2 つを組み合わせる。

- **プロジェクト** — 窓の並びと、めったに変えない設定 (チャネルの色・表示・Measurements の項目) を入れる
- **プリセット** — 題ごとに変える値 (波形・周波数・振幅・レンジ) を、**数行の Script** に書いておく。
  Script は文字なので、題の本文に載せられ、差分も読める

ループバック (0-3) で、プリセットを流すと毎回同じ画面になるかを確かめる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: sine 1,2 1,4 1
  M1: voltmeter 3,2 3,4 l=$\mathrm{CH1}$
  G1: ground 1,4
wires:
  - 1,2 -- 3,2
  - 1,4 -- 3,4
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/15-project-presets.svg)

この題は実体配線図を付けない — 0-3 と同じループバックで、W1 と 1+ の付属ワイヤを直に挿し合わせるだけ (基板を使わない)。

## プリセットの Script

**Script** の窓に貼って `Run` を押す。プロジェクトに Script の窓ごと保存しておけば、開いて Run を押すだけになる。
プロパティの名前は 1-5 で使った物だけにした。**このスクリプトは実機で動かしていない。**

```javascript
// プリセット「1 kHz 正弦波・振幅 1 V・Scope は ±2.5 V」
// 変える値はこの 4 行だけ。別のプリセットは、ここを書き換えた写しを作る
var freq = 1000;   // Hz
var amp = 1.0;     // V (振幅)
var offset = 0;    // V
var range = 5;     // Scope のレンジ (V、全幅)

Wavegen1.Channel1.Mode.text = "Simple";
Wavegen1.Channel1.Simple.Type.text = "Sine";
Wavegen1.Channel1.Simple.Frequency.value = freq;
Wavegen1.Channel1.Simple.Amplitude.value = amp;
Wavegen1.Channel1.Simple.Offset.value = offset;
Scope1.Channel1.Range.value = range;

Wavegen1.run();
Scope1.run();
wait(0.5);
print("preset: " + freq + " Hz, " + amp + " V -> Vpp " + (2 * Scope1.Channel1.measure("Amplitude")).toFixed(3) + " V");
```

- 時間軸 (time/div) とトリガは、プロジェクトの側に入れておく (毎回同じなので)
- 最後の行で、プリセットを流した直後の Vpp を Log に書く。毎回同じ数が出れば、設定が再現できている

## 計器の設定

| 何を | どこに入れるか | 値 |
| --- | --- | --- |
| 窓の並び・Measurements の項目 (Vpp・Frequency) | プロジェクト | 一度決めたら変えない |
| Scope の時間軸・トリガ | プロジェクト | 200 µs/div、CH1 の立ち上がり 0 V |
| Wavegen の波形・周波数・振幅、Scope のレンジ | プリセット (Script) | 上のコード |

手順: (1) 時間軸とトリガを決めてプロジェクトに保存 → (2) WaveForms を閉じて開き直し、プロジェクトを開く → (3) プリセットを Run。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 プリセットを流した直後の画面 — Vpp 2.00 V・1.000 kHz (何度流しても同じ)
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/15-project-presets.svg)

## 見るべき値

| 確かめる所 | 期待する値 | 分かること |
| --- | --- | --- |
| プリセットを流した後の Log | `preset: 1000 Hz, 1 V -> Vpp 2.000 V` 前後 | Script の 4 行で決めた値が計器に入った |
| 開き直したプロジェクト | 時間軸 200 µs/div・トリガ 0 V が戻る | 変えない設定はプロジェクトが持つ |
| `amp` を 0.5 にした写し | Vpp 1.000 V 前後 | プリセットは値だけ違う写しで増やせる (プロジェクトは 1 つのまま) |

プリセットの Script は、題の本文のコードブロックにそのまま置ける。0-4 の CSV と画像の書き出しと合わせると、
「どの設定で測ったか」と「何が測れたか」を同じ題の中に残せる。

## LTspice での確かめ (対象外)

設定の使い回しの題で、回路は 0-3 のループバック。算術で確かめた。振幅 1 V の正弦波は Vpp = 2 × 1 V = 2.00 V、
`amp` を 0.5 にすると 1.00 V。1 kHz の 1 周期は 1 ms で、200 µs/div の画面 (横 10 目盛 = 2 ms) に 2 周期入る。本文の値と合う。

## 出典

自作。Script のプロパティの名前は 1-5 と同じ。プロジェクトの保存は 0-4。

参考: [Analog Discovery 3 Reference Manual](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Reference-Manual_1123.pdf)
