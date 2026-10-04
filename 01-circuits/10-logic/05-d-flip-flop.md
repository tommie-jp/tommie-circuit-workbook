---
book: circuits
chapter: 10
id: 10-5
title: D フリップフロップ (4013) と T フリップフロップ
tier: 100
source: 自作
---

# 10-5 D フリップフロップ (4013) と T フリップフロップ

10-2 の RS ラッチは、ボタンを押している間ずっと出力が入力に従った。フリップフロップ (FF) は
クロックの立ち上がり (L から H に変わる瞬間) にだけ入力を取り込み、それ以外の時間は
入力が変わっても出力を保つ。決まった瞬間にだけ値を写すので、カウンタやレジスタ (10-6) の
部品になる。

ここでは D フリップフロップの IC (CD4013、2 回路入り) を使う。1 回路はそのまま
D-FF (クロックの立ち上がりで D の値を Q に写す) として、もう 1 回路は Q̄ を D に戻す
配線で T-FF (クロックが来るたびに Q が反転する) に仕立てる。

## 回路図

```circuit
title: 図1 D-FFとQバー帰還のT-FF (CD4013)
parts:
  VCC: vcc e4e0 5V
  SWD: switch e4e0 g4e0
  RpdD: resistor g4e0 i4e0 10k
  GD: ground i4e0
  VCC: vcc d7g5 5V
  SWC1: button d7g5 f7g5
  RpdC1: resistor f7g5 f5g5 10k
  GC1: ground f5g5
  U1: dip14 g12 CD4013
  VCC: vcc e13a5 5V
  GU1: ground i10a5
  RQ1: resistor c9 d9 330
  DQ1: led d9 e9 red
  GQ1: ground e9
  VCC: vcc e15a5 5V
  SWC2: button e15a5 g15a5
  RpdC2: resistor g15a5 i15a5 10k
  GC2: ground i15a5
  RQ2: resistor c17a5 d17a5 330
  DQ2: led d17a5 e17a5 red
  GQ2: ground e17a5
  GS2: ground i13a5
wires:
  - U1.14 -| e13a5
  - U1.5 -| g4e0
  - U1.3 -| f7g5
  - U1.4 -| h10a5
  - U1.6 -| h10a5
  - U1.7 -| h10a5
  - h10a5 -- i10a5
  - U1.1 -| c10a5
  - c10a5 -- c9
  - U1.11 -| g15a5
  - U1.10 -| h13c5
  - U1.8 -| h13c5
  - h13c5 -- i13a5
  - U1.13 -| c14
  - c14 -- c17a5
  - U1.12 -| g14i2
  - g14i2 |- U1.9
notes:
  - text c2 blue: "D1 (PIN 5)"
  - text b5 blue: "CLK1 (PIN 3、立ち上がりでDをQへ)"
  - text b14 blue: "CLK2 (PIN 11、押すたびにQが反転)"
  - text k1 small left: "VDD は PIN 14 (+5V)、VSS は PIN 7 (GND)"
  - text l1 small left: "使わない RESET・SET (PIN 4・6・8・10) は GND へ"
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/10-logic/circuit/05-d-flip-flop.svg)

- FF1 (D-FF): SWD が D1 (PIN 5) を決める。SWC1 (CLK1、PIN 3) を押すと CLK1 が
  0V から +5V へ立ち上がり、その瞬間の D1 の値を Q1 (PIN 1) に写す。押している
  間や離したあとは D1 を変えても Q1 は動かない (次の立ち上がりまで保持)
- FF2 (T-FF): Q̄2 (PIN 12) を D2 (PIN 9) へ配線で戻してある。CLK2 (PIN 11) が
  立ち上がるたびに、Q2 (PIN 13) は今と反対の値を取り込むので反転する。SWC2 を
  1 回押すごとに DQ2 が点く・消えるを繰り返す。クロック 2 回で Q2 が 1 往復するので、
  周波数が半分になる (1/2 分周)。10-4 の 4040 の中では、この T-FF が 12 段つながっている
- RESET (PIN 4・10)・SET (PIN 6・8) は CD4013 では H で働く (Q を強制的に 0・1 にする)。
  ここでは使わないので、両方 GND に落として無効にする
- ボタンの接点は、押した瞬間に細かく何度も跳ねて、オン・オフを繰り返す
  (チャタリング)。CLK にボタンをそのままつなぐと、1 回の押下で Q が 2 回以上
  反転して見えることがある。きれいな 1 パルスにするには 10-9 のチャタリング除去を足す

## 見るべき値

| 操作 | Q1 (DQ1) | Q2 (DQ2) |
| --- | --- | --- |
| SWD を閉じて (D1 = 1) SWC1 を押す | 点灯 (1) に変わる | — |
| SWD を開けて (D1 = 0) SWC1 を押す | 消灯 (0) に変わる | — |
| SWD を変えずに SWC1 をもう一度押す | 変わらない (直前の値を保持) | — |
| SWD を切り替えるだけ (SWC1 は押さない) | 変わらない | — |
| SWC2 を 1 回押す | — | 反転 (消灯→点灯 か 点灯→消灯) |
| SWC2 をもう 1 回押す | — | また反転 (元に戻る) |

T-FF の Q2 は、CLK2 を 2 回押してようやく 1 周する。CLK2 に一定間隔のパルス
(例えば 3-2 の 555 の出力) を入れれば、Q2 はその半分の周波数で振れる。

## 出典

自作。
