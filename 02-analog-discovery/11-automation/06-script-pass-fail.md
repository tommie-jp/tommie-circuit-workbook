---
book: analog-discovery
chapter: 11
id: 11-6
title: Script で合否判定 (検査もどき)
tier: 200
source: 自作 (計器の操作は Digilent の Using the Script Editor)
board: BB
---

# 11-6 Script で合否判定 (検査もどき)

工場の検査は、組んだ基板を決まった手順で測り、値が**許す範囲 (窓)** に入っていれば合格、外れたら不合格にする。
11-1 の RC ローパスを検査する Script を書き、2 つの周波数で利得を測って **PASS / FAIL** を出す。
大事なのは窓の決め方で、部品の公差の端どうしを組み合わせた最悪の場合 (ワーストケース) を計算し、その外側に測定の誤差の余裕を足す。
窓が狭すぎると良品を落とし、広すぎると部品の取り違えを見逃す。

この題は **11-1 と同じ基板をそのまま使い、Script だけを足す題**なので、回路図・実体配線図・オシロの図は 11-1 の図1〜図3 を指して再掲しない
(R1 1 kΩ (キロオーム) ±5 %、C1 100 nF ±10 %、W1 と 1+ が入力、2+ が出力)。

## 計器の設定

Wavegen を Sine・振幅 1 V で立ち上げ、Scope の CH1・CH2 を Amplitude 測定にしておいてから (11-1 と同じ)、Script Editor で次を実行する。

```javascript
// 11-6: RC ローパスの合否判定。窓は公差の最悪の場合 + 余裕 0.1 dB
var tests = [
    {f: 1000,  lo: -1.95, hi: -1.00},
    {f: 10000, lo: -17.40, hi: -14.65}
];

Wavegen1.Channel1.Mode.text = "Simple";
Wavegen1.Channel1.Simple.Type.text = "Sine";
Wavegen1.Channel1.Simple.Offset.value = 0;
Wavegen1.Channel1.Simple.Amplitude.value = 1;
Wavegen1.run();
Scope1.run();

var allPass = true;
for (var i = 0; i < tests.length; i++) {
    var t = tests[i];
    Wavegen1.Channel1.Simple.Frequency.value = t.f;
    wait(0.3);
    var vin = Scope1.channel[0].measure("Amplitude");
    var vout = Scope1.channel[1].measure("Amplitude");
    var gainDb = 20 * Math.log(vout / vin) / Math.LN10;
    var pass = (gainDb >= t.lo) && (gainDb <= t.hi);
    if (!pass) allPass = false;
    print(t.f + " Hz  " + gainDb.toFixed(2) + " dB  窓 " + t.lo + "〜" + t.hi + "  " + (pass ? "PASS" : "FAIL"));
}
Wavegen1.stop();
print(allPass ? "== 合格 (PASS) ==" : "== 不合格 (FAIL) ==");
```

- 計器の操作 (`Wavegen1.Channel1.Simple.*`、`Scope1.channel[].measure("Amplitude")`、`wait()`、`print()`) は 11-1 と同じ物だけを使う
- 窓は `tests` の 1 行に周波数と下限・上限をまとめて書く。窓を直すときに手順の行を触らない
- 1 つでも外れたら全体を不合格にする (`allPass`)。どの周波数で外れたかも 1 行ずつ出す

この節の Script は AD3 で**実行して確かめていない** (実機は未確認)。窓の数は下の LTspice の値から決めた。

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図1 合否の窓 — 公差の端の 2 本の外に 0.1 dB の余裕。C の取り違えは 1 kHz で外れる
x: 周波数 Hz log 100..100k
y: 利得 dB -40..0
lines:
  公称 dB: -10*log10(1+(x/1.5915k)^2)
  R −5 % C −10 % dB: -10*log10(1+(x/1.8615k)^2)
  R +5 % C +10 % dB: -10*log10(1+(x/1.378k)^2)
  C 10nF 取り違え dB: -10*log10(1+(x/15.915k)^2)
notes:
  - mark 1k
  - mark 10k
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/graph/06-script-pass-fail.svg)

## 部品

11-1 と同じ (R1 1 kΩ ±5 %、C1 100 nF ±10 %)。検査の Script を試すために、取り違えの部品 (10 nF のコンデンサ、10 kΩ の抵抗) を 1 本ずつ用意する。

## 見るべき値

計算値 (下の LTspice の値)。窓は、公差の端の 2 本 (R・C が両方小さい / 両方大きい) の利得に 0.1 dB の余裕を足した値。

| 組み合わせ | 1 kHz | 10 kHz | 判定 |
| --- | --- | --- | --- |
| 公称 (1 kΩ・100 nF、f<sub>c</sub> 1.59 kHz) | −1.45 dB | −16.07 dB | PASS |
| R −5 %・C −10 % (f<sub>c</sub> 1.86 kHz) | −1.10 dB | −14.75 dB | PASS (窓の上の端) |
| R +5 %・C +10 % (f<sub>c</sub> 1.38 kHz) | −1.84 dB | −17.30 dB | PASS (窓の下の端) |
| C を 10 nF と取り違え | −0.02 dB | −1.45 dB | FAIL (両方) |
| R を 10 kΩ と取り違え (茶黒橙と茶黒赤) | −16.07 dB | −35.96 dB | FAIL (両方) |
| 窓 | −1.95〜−1.00 dB | −17.40〜−14.65 dB | — |

- **公差の端の組を良品として通し、取り違えを落とす**ことを、表の 5 行で確かめる。実物では公差の端の部品は手に入らないので、LTspice の値で確かめる
- 窓の余裕 0.1 dB は、AD3 の 2 つのチャネルの振幅の差と雑音の目安 (目安。自分の AD3 で、同じ点を 10 回測った読みのばらつきから決め直す)
- 1 kHz は f<sub>c</sub> より下で、部品が変わっても利得の動きが小さい (±0.4 dB)。f<sub>c</sub> より上の 10 kHz のほうが動きが大きく (±1.3 dB)、取り違えを見分けやすい
- 本当の検査では、結果をファイルにも書き残し、何台めかの番号と日時を付ける (11-3 の CSV と同じ考え方)

## LTspice での確かめ

`sim/06-pass-fail.cir` で RC ローパスを 5 つの組み合わせで交流解析し、1 kHz と 10 kHz の利得を読んだ。

| 組み合わせ | 本文 (1 kHz・10 kHz) | LTspice | 判定 |
| --- | --- | --- | --- |
| 公称 | −1.45・−16.07 dB | −1.445・−16.072 dB | 合う |
| R −5 %・C −10 % | −1.10・−14.75 dB | −1.101・−14.751 dB | 合う |
| R +5 %・C +10 % | −1.84・−17.30 dB | −1.837・−17.297 dB | 合う |
| C 10 nF | −0.02・−1.45 dB | −0.017・−1.445 dB | 合う |
| R 10 kΩ | −16.07・−35.96 dB | −16.072・−35.965 dB | 合う |

## 出典

自作。計器の名前と操作は Digilent の
[Using the Script Editor](https://digilent.com/reference/test-and-measurement/guides/waveforms-script-editor)。
