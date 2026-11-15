---
book: nanovna
chapter: 3
id: 3-13
title: GHz の治具 — 端面 SMA + 短いマイクロストリップ
tier: 200
source: 自作
board: CB
device: V2
---

# 3-13 GHz の治具 — 端面 SMA + 短いマイクロストリップ

3-12 で 50 Ω (オーム) の幅に切ったマイクロストリップは、線そのものは反射しない。GHz になると、
反射の元は**端面 SMA の根元**に移る。SMA の中心ピンは線より細く、ピンの下の誘電体と
基板の縁で形が変わるので、その所に小さな容量が付く。この題では、その容量を 0.3 pF と見積もり
(目安)、**線を短くすると根元の反射どうしが重なりにくい**ことを、NanoVNA V2 の 3 GHz までで確かめる。

銅張り基板の使える範囲は 1 GHz までが目安で、3 GHz はその外にある。この題は線を 12 mm に
詰めるので FR4 の損失は 3 GHz でも 0.1 dB に届かず (目安)、比誘電率 εr (イプシロン アール) の
ばらつきも 12 mm の線では位相を少し回すだけで済む。だから FR4 のまま使う。
NanoVNA の出力 (0 dBm 以下) だけを通す。

## 回路図

GHz での等価回路。C1・C2 が SMA の根元の容量、TL1 が 12 mm の 50 Ω の線。

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 GHz の治具の等価回路 (根元の容量 + 短い線)
parts:
  J1: sma 1,2 mirror CH0
  C1: capacitor 3,2 3,4 0.3p
  TL1: tline 5,2 9,2 50 l=$\mathrm{12mm}$
  C2: capacitor 11,2 11,4 0.3p
  J2: sma 13,2 CH1
  G1: ground 1,3
  G2: ground 3,4
  G3: ground 11,4
  G4: ground 13,3
wires:
  - J1.1 -- 3,2 -- 5,2
  - 9,2 -- 11,2 -- J2.1
  - J1.2 -- 1,3
  - J2.2 -- 13,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/circuit/13-ghz-fixture.svg)

- C1・C2 は部品ではなく、SMA の中心ピンと線の継ぎ目の容量 (等価回路)。0.3 pF は見積もりで、
  実物は SMA の型と半田の盛り方で変わる。3 GHz で 177 Ω の並列になる
- 1 つの根元だけなら、3 GHz で S11 は −17.1 dB。2 つの根元の反射は線の長さぶん遅れて重なり、
  線の長さによって強め合ったり弱め合ったりする

## 部品

| 部品 | 値・型 | 注意 |
| --- | --- | --- |
| 銅張り基板 | 両面 FR4、厚さ 1.6 mm、εr 4.4 (仮定)。5×7 cm から 12 mm × 16 mm を切り出す | 裏は全面の銅 |
| J1・J2 | 端面 SMA (メス)、基板 1.6 mm 用 | 中心ピンを線の端に寝かせ、外皮の腕で基板を上下から挟む |

## 銅張り基板の寸法図

```copper
# 銅張り基板の寸法図 (tommie-fence の copper フェンス)
board:
  size: 12x16mm
  ground: back
title: 図2 GHz の治具 (線 12 mm)
f: 3G
copper:
  L1: line 0,8 12,8 3.06mm
parts:
  J1: sma left 8 CH0
  J2: sma right 8 CH1
```

![銅張り基板の寸法図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/copper/13-ghz-fixture.svg)

| 何 | 寸法・置き方 |
| --- | --- |
| 線 L1 | 幅 3.06 mm・長さ 12 mm (3-12 で計算した 50 Ω の幅。3 GHz で 79°) |
| 基板の縁 | 縁の銅を 0.5 mm ほどヤスリで落とし、表の線と裏の面が縁で触れないようにする |
| J1・J2 | 中心ピンは線の端から 1〜2 mm だけ載せ、ピンの先を余らせない。外皮の腕は上下とも半田付け |

- 線の真ん中を 1 mm 切れば、1608 のチップ部品を直列に跨がせる治具になる (3-12 と同じ)。
  基準面を真ん中へ移すポート延長は、片側 6 mm で 36.5 ps (速度係数 0.548)
- 上下の腕を両方とも裏の面と表の縁に付けないと、外皮の電流が回り込み、GHz で S21 に谷が出る
  (目安)。両面に半田を流す

**根元を補償する (任意)**: 根元の線を少し細くすると、細い所のインダクタンスが根元の容量を
打ち消す。打ち消すのに要るのは L = C × Z0² = 0.3 pF × 50² = 0.75 nH。幅 1.0 mm (87.5 Ω) の線なら
長さ 1.5 mm でほぼこの値になる (計算値。細い線そのものの容量は無視した目安)。幅が 3 mm を切るのは
補償のためで、線路の幅の決まり (3 mm 以上) の例外として書く。

## 掃引の設定

計器は VNA。この題は 1.5 GHz より上を見るので NanoVNA V2 (歴史的な機種) で図を書いてあり、標準の LiteVNA64 でも同じ手順で測れる (H4 は 1.5 GHz まで)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 100 MHz〜3 GHz |
| 点数 | 301 |
| 校正 | SOLT。ケーブルの先で (付属キットの GHz での限界は 9-2) |
| 表示 | S11 の Log Mag と Smith チャート |

**12 mm の線** (図2) の見えるはずの画面。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-3G 301
title: 図3 線 12 mm — S11 の山は 1.7 GHz の −19.6 dB だけ
dut:
  - shunt C 0.3p
  - line 50 12mm vf 0.548
  - shunt C 0.3p
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1G
  - 1.7G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/13-ghz-fixture-1.svg)

**同じ根元で、線を 3-12 の 50 mm にした**ときの見えるはずの画面。設定は図3 と同じ。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: v2
sweep: 100M-3G 301
title: 図4 線 50 mm — 根元の反射が何度も重なり、3 GHz で −11.9 dB
dut:
  - shunt C 0.3p
  - line 50 50mm vf 0.548
  - shunt C 0.3p
traces:
  - S11 logmag
  - S11 smith
markers:
  - 1G
  - 1.7G
  - 3G
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/03-fixtures/vna/13-ghz-fixture-2.svg)

- 図4 の S11 は 0.80 GHz と 2.41 GHz に谷があり、約 1.6 GHz ごとに波打つ (2 つの根元の間を往復する
  時間 50 mm × 2 ÷ (0.548 c) = 0.61 ns の逆数)。根元の容量の反射は周波数とともに大きくなるので、
  山は高い周波数ほど高い。図3 は線が短く、波の周期が 6.8 GHz と長いので、3 GHz までに山が 1 つしか来ない
- Smith では、図4 の点は中心のまわりを何周もし、図3 の点は小さな輪を 1 つ描くだけ

## 見るべき値

計算値 (根元の容量 0.3 pF・損失の無い線、CH1 は 50 Ω で終端)。

| 周波数 | 根元 1 つだけ S11 | 12 mm の線 S11 | 50 mm の線 S11 | 12 mm + 補償 0.75 nH S11 |
| --- | --- | --- | --- | --- |
| 1 GHz | −26.5 dB | −21.7 dB | −28.9 dB | −46.6 dB |
| 1.7 GHz | — | −19.6 dB (山) | −16.1 dB | −33.7 dB |
| 3 GHz | −17.1 dB | −36.3 dB | −11.9 dB | −22.0 dB |

- **線が短い治具は、0〜3 GHz の S11 の悪い所が −19.6 dB に留まる**。50 mm の線は 3 GHz で −11.9 dB まで
  悪くなる。GHz の治具の線をできるだけ短くするのはこのため
- 12 mm の線の 3 GHz の低い値は、2 つの根元の反射が打ち消し合う谷 (3 GHz の少し上) へ向かう途中で、根元の容量や εr が
  変われば動く。谷の深さを治具の良さと読まない
- 補償すると 1.7 GHz で 14 dB 良くなる。−20 dB より下に抑えたい周波数まで、補償の長さを
  削りながら S11 を見て合わせる
- S21 は 3 GHz まで 0.3 dB も落ちない (損失を除いた値)。GHz の治具の良し悪しは S11 で見る

## LTspice での確かめ

`sim/13-ghz-fixture.cir` で、図の `dut:` の模型を LTspice の AC 解析にかけた (50 Ω の電源と 50 Ω の終端。線は損失の無い T 素子、コイルの直列抵抗は 1 µΩ (マイクロオーム))。理想の模型どうしの比べで、実測ではない。

| 図 | 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- | --- |
| 図3 (12 mm) | 1 GHz / 1.7 GHz / 3 GHz | S11 | −21.7 / −19.6 / −36.3 dB | −21.70 / −19.64 / −36.32 dB | 合う |
| 図4 (50 mm) | 1 GHz / 1.7 GHz / 3 GHz | S11 | −28.9 / −16.1 / −11.9 dB | −28.94 / −16.14 / −11.91 dB | 合う |
| 図4 | 3 GHz | S21 | −0.29 dB | −0.289 dB | 合う |
| 補償つき | 1 GHz / 1.7 GHz / 3 GHz | S11 | −46.6 / −33.7 / −22.0 dB | −46.62 / −33.66 / −22.00 dB | 合う |
| 根元 1 つ | 3 GHz | S11 | −17.1 dB | −17.08 dB | 合う |

補償の長さは算術で確かめた。L = 0.3 pF × 50² = 0.75 nH。幅 1.0 mm の線は Hammerstad-Jensen の式で
Z0 87.5 Ω・εeff 3.08 で、L = Z0 × l × √εeff / c から l = 1.46 mm。

## 出典

自作。端面 SMA の根元を細い線で補償する考え方は、[マイクロストリップ (Wikipedia)](https://en.wikipedia.org/wiki/Microstrip) の不連続の扱いと、伝送線路の低域通過の段 (L と C の組で Z0 = √(L / C)) による。
