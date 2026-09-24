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
  W1: sine a1 c1 1
  R1: resistor a3 c3 1k
  M1: voltmeter a5 c5 l=$\mathrm{CH1}$
  G1: ground c1
wires:
  - a1 -- a3 -- a5
  - c1 -- c3 -- c5
```

## 実体配線図

```breadboard
title: 図2 ブレッドボードで正弦波を測る (1-2 と同じ)
board: half
parts:
  R1: resistor c5 c10 1k
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-]
wires:
  - AD.W1 -- a5 yellow
  - AD.GND -- a10 black
  - AD.1+ -- b5 yellow
  - AD.1- -- b10 black
```

## Script

Scope の **Script** ウィンドウ (計器メニューの `Script`) に書く。
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

## 見るべき値

| 振幅の設定 | 期待する Vpp (計算値) |
| --- | --- |
| 0.5 V | 1.00 V |
| 1.0 V | 2.00 V |
| 1.5 V | 3.00 V |

Log ウィンドウに 3 行の表が出て、振幅を 2 倍にすると Vpp も 2 倍になる
(負荷 1 kΩ が Wavegen の出力インピーダンスに対して十分大きいため)
ことを確かめる。11-1 でこのスクリプトを掃引・自動判定に広げる。

## 出典

自作。Script の書き方は Digilent の
[WaveForms Script Editor](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Script の節) を参考にした。
