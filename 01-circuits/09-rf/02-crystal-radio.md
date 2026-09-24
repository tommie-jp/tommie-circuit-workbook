---
book: circuits
chapter: 9
id: 9-2
title: ゲルマラジオ
tier: 50
source: 自作
board: BB
era: 古
---

# 9-2 ゲルマラジオ

電池を使わず、電波のエネルギーだけで音を出すラジオ。アンテナで受けた電波を
LC 同調で選び、ゲルマニウムダイオードで検波して、クリスタルイヤホンで聞く。
増幅する石が無いので、**長いアンテナと実際の大地アース**が必須になる。

## 回路図

```circuit
title: 図1 ゲルマラジオ
parts:
  ANT: port a1
  L1: inductor a5 c5 250u
  GL: ground c5
  VC1:
    type: device
    at: a8
    pins: [A, E]
  GVC: ground c9
  D1: diode a12 a15 1N60
  EAR:
    type: device
    at: a18
    pins: [A, B]
  GEAR: ground c19
  C2: capacitor a21 c21 1n
  GC2: ground c21
wires:
  - a1 -- a12
  - VC1.A |- a8
  - VC1.E -| c9
  - EAR.A |- a18
  - EAR.B -| c19
  - a15 -- a21
```

- L1 と VC1 (ポリバリコン) が並列の同調回路。アンテナ〜アースの間に浮かぶこの
  タンクだけが、受けた電波から 1 局分の周波数を選び出す
- D1 (ゲルマニウムダイオード) が検波部。同調回路の高い側から音声成分だけを
  取り出す
- C2 は残った高周波分をアースへ逃がすバイパス。無いとイヤホンからサーッという
  高周波の音が混じる

**同調周波数**: f<sub>0</sub> = 1 / (2π√(LC))。L1 = 250µH、VC1 = 20〜260pF (ポリバリコン
の可変範囲) で

| VC1 | f<sub>0</sub> |
| --- | --- |
| 20pF (絞りきり) | 約2.25MHz |
| 260pF (開ききり) | 約624kHz |

中波放送帯 (531〜1602kHz) をほぼ覆う。

## 実体配線図

```breadboard
title: 図2 ブレッドボードに組む
board: half
parts:
  ANT:
    type: device
    at: top
    label: アンテナ
    pins: ["1"]
  VC1:
    type: device
    at: top
    label: ポリバリコン 260pF
    pins: [A, E]
  EAR:
    type: device
    at: top
    label: クリスタルイヤホン
    pins: [A, B]
  L1: inductor/axial b3 b7 250u
  D1: diode e3(A) e9(K) 1N60
  C2: capacitor/ceramic c9 c11 1n
wires:
  - ANT.1 -- a3 yellow
  - VC1.A -- a3 yellow
  - VC1.E -- -t2 black
  - b7 -- -t7 black
  - EAR.A -- b9 blue
  - EAR.B -- -t13 black
  - d11 -- -t11 black
```

- **アンテナ線は 5〜10m** の被覆線を屋外か窓際に張る。長いほど受かる局が増える
- 上の -t レール (青) は**実物の大地アース**につなぐ。水道管やアース棒に線を
  這わせる (回路の共通線というだけでなく、本当に大地へ電流を逃がす経路)
- 3 列 (列 3) が ANT・VC1.A・L1 の左足をまとめたアンテナのネット。
  9 列が D1 のカソード・C2 の左足・EAR.A をまとめた検波出力のネット

## 見るべき値

計算値。ゲルマニウムダイオード (1N60) は立ち上がりが 0.2〜0.3V とシリコンより
低く、電池の無い微弱な信号でも検波できる。

| 確かめること | 結果 |
| --- | --- |
| VC1 を回す | 受かる局が変わる (同調が動く分かる) |
| D1 を 1N4148 (シリコン) に差し替え | ほとんど聞こえなくなる (立ち上がり電圧が高すぎる) |
| アース線を外す | 音が小さくなるか消える (電流の戻り道が細る) |

## 出典

自作。
