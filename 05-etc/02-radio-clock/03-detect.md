---
book: etc
chapter: 2
id: 2-3
title: 時報音の検出 — 440 Hz と 880 Hz の帯域通過フィルタとしきい値比較
tier: 200
source: 自作
board: BB
---

# 2-3 時報音の検出 — 440 Hz と 880 Hz の帯域通過フィルタとしきい値比較

全体の中の位置は [01-block.md](01-block.md) の ② 時報音の検出。音声信号から 440 Hz と 880 Hz の
音を別々に取り出し、「その音があるあいだ H」の T440 と T880 にする。時報の形は 01-block.md を見る。

## ブロック図

```plantuml
@startuml
top to bottom direction
skinparam shadowing false
skinparam defaultFontName "Noto Sans CJK JP"
skinparam rectangle {
  RoundCorner 6
}

rectangle "音声増幅\nAC 結合" as AF
rectangle "帯域通過フィルタ\n中心 440 Hz" as BPF4
rectangle "帯域通過フィルタ\n中心 880 Hz" as BPF8
rectangle "整流 + 平滑\n(アタック速く\nリリース遅く)" as ENV4
rectangle "整流 + 平滑\n(アタック速く\nリリース遅く)" as ENV8
rectangle "しきい値比較器\nLM393" as CMP4
rectangle "しきい値比較器\nLM393" as CMP8
rectangle "T440\n(H = 440 Hz あり)" as T4 #FFF8E1
rectangle "T880\n(H = 880 Hz あり)" as T8 #FFF8E1

AF --> BPF4
AF --> BPF8
BPF4 --> ENV4
BPF8 --> ENV8
ENV4 --> CMP4
ENV8 --> CMP8
CMP4 --> T4
CMP8 --> T8
@enduml
```

![ブロック図](https://tommie-jp.github.io/tommie-circuit-workbook/05-etc/02-radio-clock/plantuml/03-detect.svg)

440 Hz の予報音は約 0.1 秒と短いので、平滑はアタックを速くする。しきい値は可変抵抗で調整する。

(回路図と部品表はこれから書く)
