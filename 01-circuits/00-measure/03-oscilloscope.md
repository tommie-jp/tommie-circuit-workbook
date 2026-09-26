---
book: circuits
chapter: 0
id: 0-3
title: オシロスコープで波形を見る — 555 の出力を PC オシロ / AD2 で
tier: 50
source: 自作
board: BB
era: 今
---

# 0-3 オシロスコープで波形を見る — 555 の出力を PC オシロ / AD2 で

テスターは電圧の**大きさ**しか見せないが、オシロスコープは電圧が**時間とともに
どう変わるか**を見せる。555 タイマーの非安定 (無安定) 回路で方形波を作り、
USB 接続の PC オシロか Analog Discovery (AD2) の Scope 機能で波形を見る。

## 回路図

```circuit
title: 図1 555 非安定でつくる方形波
parts:
  V1: vsource c2 f2 9
  VCC: vcc c2
  G1: ground f2
  U1: dip8 e6 NE555
  VCC: vcc c7
  R1: resistor c9 d9i0 10k
  R2: resistor d9i0 f9i0 10k
  C1: capacitor f9i0 h9i0 10n
  G2: ground h9i0
  G3: ground b6
  VCC: vcc h6
  OUT: port f4a5
wires:
  - U1.8 -| c7
  - c7 -- c9
  - U1.7 -| d9i0
  - U1.6 -| f7i5
  - f7i5 -- f9i0
  - U1.1 -| b5
  - b5 -- b6
  - U1.2 -| a4
  - a4 -- a11 -- f11i0 -- f9i0
  - U1.3 -| f4a5
  - U1.4 -| h5
  - h5 -- h6
style:
  grid: on
  pitch: 1.2
```

555 の 2 番 (TRIG) と 6 番 (THR) をつなぐと**非安定**になる。8 番 (VCC) と
4 番 (RESET) は電源に、1 番 (GND) はグラウンドに、5 番 (CV) は今回使わず
浮かせたままにする (データシートどおり。気になるなら 0.01µF を GND へ)。

**R1 = R2 = 10 kΩ、C1 = 10 nF** のとき、周波数と Duty 比は次の式で決まる。

- 周波数: f = 1.44 / ((R1 + 2R2) × C) = 1.44 / (30 kΩ × 10 nF) ≈ **4.8 kHz**
  (周期 T ≈ 208 µs、計算値)
- High の時間: 0.693 × (R1 + R2) × C ≈ 139 µs
- Low の時間: 0.693 × R2 × C ≈ 69 µs
- Duty 比: 139 / 208 ≈ **67 %** (計算値。R1 と R2 が同じ値だと 50 % を超える)

出力 (3 番) は電源 9V に対して **約 0.2V 〜 約 7.5V** の方形波になる
(555 は出力段で 1.5V ほど落ちるため、VCC いっぱいまでは振れない)。

## 実体配線図

```breadboard
title: 図2 555 非安定をブレッドボードに組む
# 上下とも赤レール = +9V (9V 電池)、青レール = GND (上下の青レールは 28 列でつなぐ)
board: half
parts:
  U1: dip8 @ e10 NE555
  R1: resistor a15 a18 10k
  R2: resistor b18 b21 10k
  C1: capacitor/ceramic a21 a24 10n
  SCOPE:
    type: device
    at: bottom
    label: PC オシロ / AD2 (Ch1)
    pins: [SIG, GND]
wires:
  - U1.8 -- b15 red
  - U1.4 -- b15 orange
  - c15 -- +t15 red
  - U1.7 -- c18 yellow
  - U1.6 -- c21 green
  - U1.2 -- c21 blue
  - U1.1 -- b24 black
  - b24 -- -t24 black
  - U1.3 -- SCOPE.SIG gray
  - SCOPE.GND -- -b26 black
  - -t28 -- -b28 black
```

DIP8 の足は番号で配線した (`U1.8` が VCC、`U1.1` が GND)。抵抗 2 本とコンデンサは
同じ列を使って直列につなぎ (`a18` と `b18` が同じ列 18 で導通)、プローブ
(`SCOPE`) は 3 番ピンとグラウンドに当てる。8 番・4 番と R1 の上端が集まる列 15 は
`+t15` で +9V レールへ、1 番の GND (`-t`) とプローブの GND (`-b`) は 28 列の
黒線で上下の青レールをつないで同じ GND にする。

## 計器の設定

| 項目 | 値 |
| --- | --- |
| 結合 | DC |
| 電圧レンジ | 2 V/div (0 〜 約 7.5V が画面に収まる) |
| 時間レンジ | 50 µs/div (周期 208µs が 4 目盛り分) |
| トリガ | 立ち上がり、レベル 2V くらい |

PC オシロは付属ソフトの Scope 画面、AD2 は WaveForms の Scope で同じように設定する。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 波形の周期 | 約 208 µs (≈ 4.8 kHz) | 計算値と一致すれば R・C の値が合っている証拠 |
| High の時間 / Low の時間 | 約 139 µs / 約 69 µs | Duty 比 約 67 % (テスターでは見えない情報) |
| 振幅 (High − Low) | 約 7.3 V (0.2V 〜 7.5V) | テスターの直流レンジで測る平均値 (約 5V 前後) とは違う値になる |

テスターで同じ点を測ると、方形波の**平均値**に近い 1 つの数字しか出ない
(Duty 比 67% なら 9V × 0.67 ≈ 6V 前後)。波形の**形**が見えるのがオシロの強み。

## 出典

自作。
