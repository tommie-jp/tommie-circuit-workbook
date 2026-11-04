---
book: circuits
chapter: 9
id: 9-32
title: LC 共振の電流の波 — 共振の前後の位相、発生器の出力抵抗、LED を輪に入れない理由
tier: 100
source: 自作
board: BB
---

# 9-32 LC 共振の電流の波 — 共振の前後の位相、発生器の出力抵抗、LED を輪に入れない理由

**先に 9-1 (LC 同調) を組んでおく。** この題は 9-1 の輪で、発生器の電圧 (CH1) と輪の電流 (CH2) の位相が
共振の前後でどうずれるかと、発生器の出力抵抗の効き目を見る。あわせて、9-1 で LED を輪の外に置いた理由を LTspice の値で示す。回路・部品・計器の設定は 9-1 のまま。

**9-1 で LED を輪の中に入れない理由。** LED は約 1.8 V を超えるまで電流を流さないので、輪に入れると
電流を半周期ごとの細い山に刻み、共振を乱す。LTspice では、向きを逆にした LED 2 本を輪に入れると、
f<sub>0</sub> の電流は 17.6 mA から 4.5 mA に落ち、共振曲線も左右で揃わなくなる (8 kHz で 2.3 mA、32 kHz で 1.2 mA)。
1 本だけでも、C1 が片側に充電されて数周期で LED を押さえ込み、消えてしまう。

この題は実体配線図・Analog Discovery 3 の図を付けない。9-1 と同じ基板をそのまま使い、測り方だけを足す (図は 9-1 の図1・図2)。

## 計器の設定

9-1 の計器の設定のまま、出力 50 Ω の発生器で見る。CH1 は発生器の出力、CH2 は R1 の電圧 (輪の電流 × 100 Ω)。
12 kHz では CH2 を 200 mV/div に下げる。

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図1 共振より下 (12kHz) — CH2 は 1.01Vpp に下がり、CH1 より進む
time: 20us/div
trigger: ch1 rising 0V
ch1: {wave: sine 12kHz 5.88Vpp, range: 2V/div}
ch2: {wave: sine 12kHz 1.01Vpp phase 78deg, range: 200mV/div}
measure: [vpp, freq, phase]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/09-rf/scope/32-lc-resonance-phase.svg)

## 見るべき値

- **共振点 (15.9 kHz) では CH1 と CH2 の位相が揃う** (9-1 の図4)
- **共振より下では CH2 が CH1 より進む (図1、約 78°)。** C1 のリアクタンスが勝ち、輪がコンデンサのように振る舞うため。
  上では逆にコイルが勝ち、CH2 は遅れる (20 kHz で約 75° の遅れ)。
  位相は Measurements の Phase か、2 つの波の山の時間差 ÷ 周期 × 360° で読む
- 出力 50 Ω の発生器では、共振点で CH1 の振幅が下がる (6.0 → 約 4.2 Vpp、9-1 の図4)。
  電流の分だけ発生器の中の 50 Ω で電圧が落ちるため。出力 ≈ 0 Ω の発生器では下がらない
- 図1 の CH2 は 200 mV/div に下げてある。大きさは目盛りでなく Vpp の読み値で比べる
- 9-1 の図3 の出力 50 Ω と ≈ 0 Ω の 2 本は、すそ (12 kHz より下と 20 kHz より上) がほぼ同じで、頂点だけが 17.6 mA と 24.9 mA で違う。
  発生器の 50 Ω も輪の抵抗に入り、Q が下がって山が低く平らになるため。輪の抵抗と Q・山の鋭さの関係は
  02-analog-discovery/05-network/03-rl-lc-resonance.md (AD の冊 5-3) でも見る

## LTspice での確かめ

回路は 9-1 の図1 と同じで、CH2 の Vpp の突き合わせは 9-1 の「LTspice での確かめ」にある。
位相 (約 78°・約 75°)・CH1 の約 4.2 Vpp・LED を輪に入れたときの値は、ここでは走らせ直していない。

## 出典

自作。

参考: [LC回路 (Wikipedia)](https://ja.wikipedia.org/wiki/LC回路)、[同調回路 (Wikipedia)](https://ja.wikipedia.org/wiki/同調回路)
