---
book: analog-discovery
chapter: 1
id: 1-5
title: Script の最初の 1 行 — 波形を出し、測り、表にする
tier: 50
source: 自作 (公式は WaveForms Script Editor)
board: BB
---

# 1-5 Script の最初の 1 行 — 波形を出し、測り、表にする

WaveForms の **Script** はボタンを毎回押す代わりに JavaScript もどきの
短いコードで計器を動かす機能。ここでは 1-2 と同じ回路 (Wavegen → 抵抗
負荷 → Scope) を使い、振幅を 3 段階に変えながら Vpp を測って表にする。
11 章「自動化」の入口。

## 回路図

```circuit
title: 図1 正弦波を作って測る (1-2 と同じ)
parts:
  W1: sine 1,1 1,3 1
  R1: resistor 3,1 3,3 1k
  M1: voltmeter 5,1 5,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1 -- 5,1
  - 1,3 -- 3,3 -- 5,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/circuit/05-script-basics.svg)

## 実体配線図

```breadboard
title: 図2 ブレッドボードで正弦波を測る (1-2 と同じ)
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [1+, W1, 1-, GND]
wires:
  - AD.W1 -- b5 yellow
  - AD.GND -- b10 black
  - AD.1+ -- a5 orange
  - AD.1- -- a10 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/breadboard/05-script-basics.svg)

## Script

**Script** の窓 (計器メニューの `Script`) に書く。
`Run` を押すと、振幅を変えながら Vpp を測って `Log` ウィンドウに表を出す。

```javascript
// W1 の振幅を 0.5 V / 1.0 V / 1.5 V の順に変え、Vpp を測って表にする
var amps = [0.5, 1.0, 1.5];

Wavegen1.Channel1.Mode.text = "Simple";
Wavegen1.Channel1.Simple.Type.text = "Sine";
Wavegen1.Channel1.Simple.Offset.value = 0;
Wavegen1.Channel1.Simple.Frequency.value = 1000; // 1 kHz

Scope1.Channel1.Range.value = 5;

Wavegen1.run();
Scope1.run();
wait(0.2);

for (var i = 0; i < amps.length; i++) {
  Wavegen1.Channel1.Simple.Amplitude.value = amps[i];
  wait(0.2); // 出力が落ち着くまで待つ

  var amplitude = Scope1.Channel1.measure("Amplitude");
  var vpp = 2 * amplitude;

  print("振幅 " + amps[i] + " V -> Vpp = " + vpp.toFixed(3) + " V");
}

Wavegen1.stop();
```

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、1 kHz、振幅はスクリプトが 0.5 / 1.0 / 1.5 V の順に変える |
| Scope (CH1) | DC、Range 5 V、Auto トリガ (Script から `measure("Amplitude")` で読む) |

```scope
title: 図3 振幅 1.0 V の設定なら Scope は Vpp 2.00 V を読む (1 kHz の正弦波)
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
cursors: [250us, 750us]
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/scope/05-script-basics.svg)

図3 は振幅 1.0 V の回のオシロの画面。1 kHz なので 1 周期が 1 ms で、`measure("Amplitude")` が返す値の 2 倍の Vpp を画面の表にも出す。

## 見るべき値

| 振幅の設定 | 期待する Vpp (計算値) |
| --- | --- |
| 0.5 V | 1.00 V |
| 1.0 V | 2.00 V |
| 1.5 V | 3.00 V |

```graph
title: 図4 Vpp は振幅の設定のちょうど 2 倍 (1.00 / 2.00 / 3.00 V)
x: 振幅の設定 V 0..2
y: Vpp V 0..4
lines:
  計算 (Vpp = 2 × 振幅) V: 2*x
notes:
  - mark 0.5
  - mark 1
  - mark 1.5
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/01-waveforms/graph/05-script-basics.svg)

Log ウィンドウに 3 行の表が出て、振幅を 2 倍にすると Vpp も 2 倍になる
(負荷 1 kΩ が Wavegen の出力インピーダンスに対して十分大きいため)
ことを確かめる。11-1 でこのスクリプトを掃引・自動判定に広げる。

## 出典

自作。Script の書き方は Digilent の
[WaveForms Script Editor](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Script の節) を参考にした。
