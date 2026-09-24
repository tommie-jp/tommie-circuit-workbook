---
book: analog-discovery
chapter: 11
id: 11-1
title: Script で掃引と測定を自動化 (1-5 の続き)
tier: 50
source: 自作 (計器の操作は Digilent の Using the Script Editor)
board: —
---

# 11-1 Script で掃引と測定を自動化 (1-5 の続き)

1-5 では 1 点だけ波形を出して測り、表にした。ここでは同じ考え方を
**周波数を変えながら繰り返す**ところまで自動化する。**Script** から
Wavegen の周波数を書き換え、Scope の振幅を読み、表にして出す —
自分で作る簡易ネットワークアナライザ。配線は RC ローパス 1 つだけで、
すでに組んである回路をそのまま使う (板の絵は 1-5 と同じなので省く)。

## 回路図

```circuit
title: 図1 RC ローパスを Script で掃引する
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 1k
  C1: capacitor c9 c12 100n
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c14
  - c6 -- c9
  - AD.2+ -| c6
  - AD.2- -| c14
  - c12 -- c14
  - AD.GND -| c14
```

R = 1 kΩ、C = 100 nF で、理論の折れ点 f<sub>c</sub> = 1/(2πRC) ≒ 1.59 kHz。
1+ が入力 (W1)、2+ が出力 (R と C の中点)。

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

## 見るべき値

計算値。理論値 = 1/√(1+(f/f<sub>c</sub>)²)、f<sub>c</sub> = 1.5915 kHz。

| f [Hz] | 理論ゲイン [dB] |
| --- | --- |
| 100 | −0.02 |
| 1,000 | −1.45 |
| 3,000 | −6.58 |
| 10,000 | −16.07 |
| 30,000 | −25.52 |
| 100,000 | −35.96 |
| 300,000 | −45.51 |

Script が出す表の `Gain[dB]` 列がこの理論値に近ければ、配線と Script の両方が
合っている。**1-5 で 1 行だけ確かめた表が、ここでは 8 行に増えただけ** —
やっていることの本質は同じで、繰り返しを Script に任せている。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Script Editor](https://digilent.com/reference/test-and-measurement/guides/waveforms-script-editor)。
Script の書き方 (`Wavegen1.ChannelN.Simple.*`、`Scope1.channel[]`、`wait()`、`print()`)
は WaveForms の Script Editor が使う実際の API に沿っている。
