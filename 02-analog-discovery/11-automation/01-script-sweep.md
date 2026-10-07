---
book: analog-discovery
chapter: 11
id: 11-1
title: Script で掃引と測定を自動化 (1-5 の続き)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Script Editor)
board: BB
---

# 11-1 Script で掃引と測定を自動化 (1-5 の続き)

1-5 では振幅を 3 段に変えて Vpp を測り、表にした。ここでは同じ考え方を
**周波数を変えながら繰り返す**ところまで自動化する。**Script** から
Wavegen の周波数を書き換え、Scope の振幅を読み、表にして出す —
自分で作る簡易ネットワークアナライザ。配線は RC ローパス 1 つだけで、
5-1 と同じ。

## 回路図

```circuit
title: 図1 RC ローパスを Script で掃引する
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor 3,3 6,3 1k
  C1: capacitor 9,3 12,3 100n
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 14,3
  - 6,3 -- 9,3
  - AD.2+ -| 6,3
  - AD.2- -| 14,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/circuit/01-script-sweep.svg)

R = 1 kΩ、C = 100 nF で、理論の折れ点 f<sub>c</sub> = 1/(2πRC) ≒ 1.59 kHz。
1+ が入力 (W1)、2+ が出力 (R と C の中点)。

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery 3 (5-1 と同じ配線)
board: half
parts:
  R1: resistor c5 c10 1k
  C1: capacitor d10 d14 100n
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
  - a14 -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/breadboard/01-script-sweep.svg)

R1 と C1 は 10 列で中点を共有する。1+ は入力 (5 列)、2+ は R1 と C1 の中点 (10 列)、1−・2− と C1 の下端は GND のレールへ。

## 計器の設定

Wavegen を Sine・振幅 1 V で立ち上げ、Scope の CH1・CH2 を Amplitude 測定に
しておいてから、Script Editor で次を実行する。

```javascript
// 11-1: RC ローパスを周波数を変えながら測る
var freqs = [100, 300, 1000, 3000, 10000, 30000, 100000, 300000]; // Hz

Wavegen1.Channel1.Mode.text = "Simple";
Wavegen1.Channel1.Simple.Type.text = "Sine";
Wavegen1.Channel1.Simple.Offset.value = 0;
Wavegen1.Channel1.Simple.Amplitude.value = 1;
Wavegen1.Channel1.Simple.Frequency.value = freqs[0];
Wavegen1.run();
Scope1.run();
wait(0.5);

print("f[Hz]\tVin[V]\tVout[V]\tGain[dB]");
for (var i = 0; i < freqs.length; i++) {
    Wavegen1.Channel1.Simple.Frequency.value = freqs[i];
    wait(0.2);
    var vin = Scope1.channel[0].measure("Amplitude");
    var vout = Scope1.channel[1].measure("Amplitude");
    var gainDb = 20 * Math.log(vout / vin) / Math.LN10;
    print(freqs[i] + "\t" + vin.toFixed(3) + "\t" + vout.toFixed(3) + "\t" + gainDb.toFixed(2));
}
Wavegen1.stop();
print("-- done --");
```

- `Wavegen1.Channel1.Simple.Frequency.value` を書き換えるだけで、ダイアログを
  開き直さずに周波数を変えられる
- `wait(0.2)` は周波数を変えてから読むまでの落ち着き時間。低い周波数のときは
  もう少し長くしないと測定中に波形が安定しない
- `Scope1.channel[0]` が CH1、`[1]` が CH2 (0 始まり)

```scope
title: 図3 Script が 3 kHz を出しているときの画面 — CH2 は CH1 の 0.47 倍で約 62° 遅れる
time: 100us/div
trigger: ch1 rising 0V
ch1: {wave: sine 3kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | rc 100us, range: 500mV/div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/scope/01-script-sweep.svg)

図3 は表の 3,000 Hz の行 (理論ゲイン −6.58 dB) をオシロで見た画面 (計算値)。
Script の `measure("Amplitude")` は CH1 を 1.000 V、CH2 を 0.469 V と読み、`Gain[dB]` は 20 log₁₀(0.469 / 1.000) ≈ −6.58 になる。

## 見るべき値

計算値。理論値 = 1/√(1+(f/f<sub>c</sub>)²)、f<sub>c</sub> = 1.5915 kHz。

| f [Hz] | 理論ゲイン [dB] |
| --- | --- |
| 100 | −0.02 |
| 300 | −0.15 |
| 1,000 | −1.45 |
| 3,000 | −6.58 |
| 10,000 | −16.07 |
| 30,000 | −25.52 |
| 100,000 | −35.96 |
| 300,000 | −45.51 |

Script が出す表の `Gain[dB]` 列がこの理論値に近ければ、配線と Script の両方が
合っている。**1-5 で 3 行だった表が、ここでは 8 行に増えただけ**。
やっていることは同じで、繰り返しを Script に任せている。

Script が出す 8 行を方眼に打つと、この線の上に乗るはずである。

```graph
title: 図4 Script の Gain[dB] が乗るはずの理論の線 (計算)
x: 周波数 Hz log 100..300k
y: 利得 dB -50..0
lines:
  理論 dB: -10*log10(1+(x/1.5915k)^2)
notes:
  - mark 1k
  - mark 3k
  - mark 10k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/graph/01-script-sweep.svg)

分かること:

- 10 kHz から上は 10 倍ごとに約 20 dB ずつ下がる (1 次のローパスの傾き)。表の
  30 k → 300 kHz の 2 行も 20 dB 差になっている

## 出典

自作。計器の名前と操作は Digilent の
[Using the Script Editor](https://digilent.com/reference/test-and-measurement/guides/waveforms-script-editor)。
Script の書き方 (`Wavegen1.ChannelN.Simple.*`、`Scope1.channel[]`、`wait()`、`print()`)
は WaveForms の Script Editor が使う実際の API に沿っている。
