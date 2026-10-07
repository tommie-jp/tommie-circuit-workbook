---
book: analog-discovery
chapter: 0
id: 0-5
title: BNC アダプタと 10:1 プローブ — 帯域 9 MHz と 30 MHz の違い
tier: 100
source: 自作 (帯域の数値は Digilent の Analog Discovery 3 の公式仕様)
board: —
---

# 0-5 BNC アダプタと 10:1 プローブ — 帯域 9 MHz と 30 MHz の違い

Analog Discovery 3 (AD3) は付属の**ワイヤ**（フライングリード）でも測れるが、別売りの
**BNC アダプタ**を挟んで同軸ケーブルや 10:1 プローブをつなぐと、帯域がぐっと
広がる。ここではワイヤだけを使い、ループバック（0-3）に正弦波を流して周波数を
上げ、公称の帯域（9 MHz）のあたりで振幅がどれだけ落ちるかを確かめる。BNC アダプタ自体は
`1+` / `W1` などのピンの意味を変えないので、図には出さない（コネクタが変わるだけ）。

## 回路図

```circuit
title: 図1 ループバック配線 (0-3 と同じ)
parts:
  W1: sine 1,1 1,3 1
  M1: voltmeter 3,1 3,3 l=$\mathrm{CH1}$
  G1: ground 1,3
wires:
  - 1,1 -- 3,1
  - 1,3 -- 3,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/circuit/05-bnc-probe-bandwidth.svg)

0-3 と同じ配線。振幅 1 V（Vpp 2 V）を保ったまま、周波数だけを変える。

## 計器の設定

| 計器 | 設定 |
| --- | --- |
| Wavegen (W1) | 正弦波、振幅 1 V、周波数を 100 kHz → 0.8 MHz → 2.9 MHz → 9 MHz と切り替える |
| Scope (CH1) | DC、Range ±2 V 程度、Auto トリガ |

## 見るべき値

付属ワイヤ（フライングリード）で 2×15 ヘッダにつないだとき、公式資料
（Analog Discovery 3 の Specifications、Bandwidth の項）では、**オシロ（Scope）も
波形発生器（Wavegen）も同じ数字**で
**9 MHz @ −3 dB、2.9 MHz @ −0.5 dB、0.8 MHz @ −0.1 dB**。
ループバックは W1 の出力を CH1 で読むので、**発生器とオシロの 2 段ぶんの減衰が
かかる**。各段の周波数応答の積なので、dB で足せばよい。100 kHz は帯域に対して
十分低いので、ここでの Vpp（2.00 V）を基準にする。

| 周波数 | 1 段（各機器）の仕様上の減衰 | ループバック（2 段）の減衰 | 期待する Vpp（計算値） | 100 kHz に対する比 |
| --- | --- | --- | --- | --- |
| 100 kHz | 0 dB（基準） | 0 dB | 2.00 V | 100% |
| 0.8 MHz | −0.1 dB | −0.2 dB | 約 1.95 V | 約 97.7% |
| 2.9 MHz | −0.5 dB | −1.0 dB | 約 1.78 V | 約 89.1% |
| 9 MHz | −3 dB | −6 dB | 約 1.00 V | 約 50.1% |

仕様の 3 点は代表値なので、実測はこの計算値から少しずれるのが普通（未確認）。
それでも Vpp は 1 MHz を越えたあたりから目に見えて落ち始め、9 MHz では
ほぼ半分になる。

```graph
title: 図2 付属ワイヤのループバックの Vpp — 9 MHz で約 1.0 V (2 段で −6 dB) まで落ちる
x: 周波数 Hz log 100k..20M
y: 振幅 Vpp V 0..2.2
lines:
  仕様から計算 V:
    - 100k 2.00
    - 800k 1.954
    - 2.9M 1.783
    - 9M 1.002
notes:
  - mark 800k
  - mark 2.9M
  - mark 9M
  - level 1.0V
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/00-tools/graph/05-bnc-probe-bandwidth.svg)

1 段の −3 dB が 9 MHz（電圧で約 3 割減）なので、ループバックでは 9 MHz で約半分になる。
これは付属ワイヤの側の帯域の制限で、Analog Discovery 3 自体の故障ではない（原因の
内訳は仕様に書かれておらず、寄生インダクタンス・容量によるものかは未確認）。
Scope 1 段だけの減衰を分けて読みたいときは、Wavegen 以外の発生源が要る。

**BNC アダプタを挟むと**、同じ資料でオシロの帯域は
**30 MHz+ @ −3 dB、15 MHz @ −0.5 dB、6 MHz @ −0.1 dB** まで伸びる（波形発生器側も
**12 MHz @ −3 dB、4 MHz @ −0.5 dB、1 MHz @ −0.1 dB** に伸びる）。この教科書の標準は
BNC アダプタ有りの値で、ヘッダ直の 9 MHz は「アダプタを付けないとここまで」という注記である。
ループバックでは発生器とオシロが直列になるので、
ワイヤのときはどちらも同じ 9 MHz 付近で落ちて合成が上の表になるが、BNC アダプタを使うと
**波形発生器の 12 MHz が全体のボトルネックになる**（オシロの 30 MHz+ より低い）。この BNC アダプタ
経由の測定は、実際のアダプタを使わないここでは行わない — 0-6 で同じ 5 MHz の方形波を
ワイヤと同軸で見比べ、2-9 で 10:1 プローブの補正を扱う。

10:1 プローブは BNC アダプタと組み合わせて使う（プローブ自体は BNC 端で挿す）。
市販の 10:1 プローブは帯域が数十〜百 MHz 以上あるものが多く、正しく補正すれば
オシロ本体の帯域（BNC アダプタで 30 MHz+）がそのまま生きる。**プローブの補正が
ずれていると、帯域どころか波形の形自体が歪む**——それが 2-9 のテーマになる。

## 出典

自作。帯域の数値は Digilent の
[Analog Discovery 3 Specifications](https://assets.testequity.com/te1/Documents/pdf/digilent/Digilent_Analog-Discovery-3-Specifications_1123.pdf)
（オシロ・波形発生器の Bandwidth の項目、BNC アダプタ有り・無しの 2 列）。
図 2 は、この仕様の 3 点と 100 kHz の基準から計算した値で、実測ではない。
