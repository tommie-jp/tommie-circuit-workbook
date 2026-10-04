---
book: analog-discovery
chapter: 7
id: 7-9
title: チャタリングを捕まえる
tier: 100
source: 自作 (計器の操作は Digilent の Using the Logic Analyzer)
board: BB
---

# 7-9 チャタリングを捕まえる

機械式のスイッチは、押した・離した瞬間に接点が物理的に跳ねる。この跳ねを
**チャタリング**と呼ぶ。理想のスイッチなら H⇄L は 1 回のきれいなエッジだが、
実物は数 ms の間に何度も H・L を行き来する。Logic をスイッチより十分速い
サンプルレートで捕まえ、この様子を実際に見る。

## 回路図

```circuit
title: 図1 タクトスイッチのチャタリングを Logic で見る
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [V+, GND, DIO0]
  R1: resistor n1 n3 10k
  SW1: button n3 n5
  G1: ground n5
wires:
  - AD.V+ -| n1
  - AD.DIO0 -| n3
  - AD.GND -| n5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/circuit/09-switch-bounce.svg)

- R1 (10 kΩ) は**プルアップ**。スイッチが離れている間、DIO0 は R1 を通じて
  H (3.3 V) に保たれる
- SW1 を押すと n3 が GND (n5) に落ちて DIO0 は L になる。**このとき接点が
  何度も跳ね、L と H を短い時間に何度も行き来する** (チャタリング)
- 電流は 3.3 V / 10 kΩ = 0.33 mA (押している間だけ) と小さく、スイッチにも
  AD にも負担にならない

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  SW1: button @ e5
  R1: resistor g5 g9 10k
  AD:
    type: device
    at: bottom
    label: Analog Discovery
    pins: [V+, GND, DIO0]
wires:
  - -t5 -- a5 black
  - -t20 -- -b20 black
  - AD.GND -- -b6 black
  - AD.V+ -- +b21 red
  - j9 -- +b9 red
  - AD.DIO0 -- i5 yellow
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/breadboard/09-switch-bounce.svg)

- `button @ e5` は溝をまたぐタクトスイッチで、e5・e7・f5・f7 の 4 穴を占める。
  **e5 と e7 (上ブロック側) は内部でつながっていて 1 本の足、f5 と f7
  (下ブロック側) も同様に 1 本の足**として動く (実物では見えない結線)
- 上ブロック側 (e5) を `-t5 -- a5` で GND の上のレールへ。下ブロック側
  (f5) が DIO0 のプルアップ先の節点。**R1 の足を f5 に重ねると部品同士が
  同じ穴を取り合うので、同じネットの別の穴 (g5) から取る**
- R1 (g5〜g9) はプルアップ。g9 側を `j9 -- +b9` で V+ のレールへ。
  スイッチの節点 (f5 と同じ列・同じ下ブロックのネット) は `i5` から DIO0 へ
  引き出す
- 上下のレールは 20 列 (GND) で渡す。V+ は下のレールだけで足りる

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 3.3 V、Master Enable を入れる |
| Logic | DIO0 を Enable。Rate は **1 MS/s** (1 µs の分解能でチャタリングの 1 回 1 回が見え、AD3 の 1 本 32,768 標本のバッファで 32 ms を撮れる)。Trigger は DIO0 の立ち下がりで、押した瞬間の前後が入る位置にする |

計器は Analog Discovery 3 の Supplies (3.3 V) と Logic。AD3 の DIO は 3.3 V の信号で、5 V 耐性がある。
10 MS/s にすると 32,768 標本で 3.3 ms しか撮れず、5〜10 ms 続くチャタリングの全体が入らないので、1 MS/s にした。

Logic で押した瞬間を撮ると、図3 のような形になる。t = 0 の立ち下がりが最初の接触、そのあと H・L を 3 回行き来して 2.4 ms で L に落ち着く。
この時刻は典型的な形を見せるための**仮の値**で、押し方・個体で変わる。

```logic
title: 図3 押した瞬間、DIO0 が H と L を行き来する
device: ad3
time: 500us/div
start: -500us
sample: 1MHz
signals:
  DIO0: dio0 edges -500us=1 0s=0 150us=1 300us=0 900us=1 1ms=0 2.3ms=1 2.4ms=0
cursors: [225us, 2.35ms]
trigger: DIO0 falling at 0s
```

![ロジックアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/07-logic/logic/09-switch-bounce.svg)

カーソルは最初に跳ね上がった H の真ん中 (225 µs) と、最後に跳ね上がった H の真ん中 (2.35 ms)。どちらも DIO0 = 1。
ΔX = 2.125 ms は、この図の例で跳ね返りが続いた時間の目安 (最初の H から最後の H まで)。

## 見るべき値

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 待機中の DIO0 | H (3.3 V) | プルアップが効いている |
| 押した瞬間 (理想のスイッチなら) | H→L の 1 回のエッジ | 理想の接点なら一発で決まるはず |
| 押した瞬間 (実測) | 数 ms の間に H・L を何度も繰り返す | 接点が物理的に跳ねている — ソフトでの対策 (デバウンス) が要る理由 |
| チャタリングの続く時間 | 目安 5〜10 ms 以下 (OMRON B3F など一般的なタクトスイッチのデータシート値) | 個体差・押し方で変わる実測値であり計算値ではない |
| 離した瞬間 | 押した瞬間と同様にチャタリングが出る | 押すときも離すときも接点が跳ねる原理は同じ |

**このチャタリングをソフトやハードでどう抑えるかは 7-17 (デバウンス回路の評価)
で扱う。** ここではまず「本当に何度も跳ねている」という事実を、自分の目で
波形として確かめることが目的。

## 出典

自作。計器の名前と操作は Digilent の
[Using the Logic Analyzer](https://digilent.com/reference/test-and-measurement/guides/waveforms-logic-analyzer)。
タクトスイッチのチャタリング時間の目安は一般的なタクトスイッチ (OMRON B3F 系)
のデータシート値による。
