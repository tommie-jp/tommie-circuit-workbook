---
book: denken
chapter: 0
id: 0-3
title: 電圧と電流を同時に見る — シャント抵抗で電流を電圧に、AD の 2 ch
tier: 50
source: 自作
board: BB
---

# 0-3 電圧と電流を同時に見る — シャント抵抗で電流を電圧に、AD の 2 ch

AD のオシロスコープが直に読めるのは電圧だけで、電流は読めない。そこで
**分かっている小さい抵抗 (シャント抵抗)** を電流の通り道に直列に入れ、
その両端の電圧を読んで抵抗で割れば電流になる。以後の交流の実験
(第 3 章) はどれもこの形で電圧と電流を同時に見る。ここでは直流で仕組みを確かめる。

## この実験で確かめる式

| 式 | 意味 |
| --- | --- |
| I = V_shunt / R_s | シャント抵抗 R_s の両端の電圧から電流を計算する |
| V_load = V+ × R_load / (R_load + R_s) | 分圧の式。負荷の電圧は電源電圧より少しだけ低い |

## 回路図

```circuit
title: 図1 シャント抵抗で電流を電圧に
style:
  standard: jis
parts:
  V1: vsource c1 g1 5
  Rs: resistor c1 c5 10 i=I
  M2: voltmeter a1 a5 l=$\mathrm{CH2}$
  M1: voltmeter c5 g5 l=$\mathrm{CH1}$
  R1: resistor c8 g8 470
  G1: ground g5
wires:
  - a1 -- c1
  - a5 -- c5
  - c5 -- c8
  - g1 -- g5 -- g8
```

- V1 は AD の Supplies (V+)。5 V を出す
- Rs (10 Ω) が電流を測るシャント。CH2 は Rs の両端 (差動入力) で、読みを 10 で
  割ると電流になる (1 mV = 0.1 mA)
- CH1 は負荷 R1 (470 Ω) の両端の電圧。負荷の電圧そのもの

## 実体配線図

```breadboard
title: 図2 ブレッドボードと Analog Discovery
board: half
parts:
  Rs: resistor c5 c10 10
  R1: resistor d10 d15 470
  AD:
    type: device
    at: top
    label: Analog Discovery
    pins: [GND, V+, 2+, 1+, 2-, 1-]
wires:
  - AD.GND -- -t2 black
  - AD.V+ -- b5 red [h-10]
  - AD.2+ -- a5 blue
  - AD.1+ -- b10 orange [h-10]
  - AD.2- -- a10 white
  - AD.1- -- -t12 black
  - d15 -- -t15 black
```

- Rs と R1 は 10 列でつながる直列 (Rs の右足と R1 の左足が同じ列)
- CH2 (2+/2-) は Rs の両端 (5 列と 10 列) の差動入力。**GND にはつながない**
  (つなぐと負荷側の電圧が GND に落ちる)
- CH1 (1+) は R1 の左端 (10 列)。1− は GND レールへ

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Supplies | V+ = 5 V。Enable してから Master Enable を入れる |
| Scope | CH1・CH2 とも DC。CH2 の Range は小さめ (200 mV/div 程度) にして分解能を上げる |

## 見るべき値

計算値。

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| CH1 (負荷 R1 の電圧) | 4.90 V | V+ (5 V) より少し低い。Rs での電圧降下の分だけ下がる |
| CH2 (シャント Rs の電圧) | 104 mV | ÷ 10 Ω で電流 10.4 mA |
| 電流 I = CH2 / 10 | 10.4 mA | R1 単体で計算した I = 5 V / 470 Ω = 10.6 mA とほぼ一致 (Rs の分だけ少し小さい) |

分かること:

- **シャント抵抗は小さいほど、測る回路への影響が小さい。** Rs (10 Ω) は
  R1 (470 Ω) の 1/47 なので、電圧の低下は 2 % ほどにとどまる
- 同じ考え方に、電圧を測るときの倍率器 (7-2) や電流を測るときの分流器
  (7-1) がある。この本では AD の 2 ch を使うが、考え方はアナログの電流計・
  電圧計と同じ
- 交流でも同じ配線で使える。振幅だけでなく**位相も同時に読める**のが
  2 ch の強み (3-2 以降で使う)

## 出典

自作。計器の名前と操作は Digilent の
[WaveForms リファレンスマニュアル](https://digilent.com/reference/software/waveforms/waveforms-3/reference-manual)
(Supplies・Scope の節)。
