---
book: circuits
chapter: 8
id: 8-10
title: 温度センサー IC (LM35 / TMP36)
tier: 100
source: 自作
board: BB
era: 今
---

# 8-10 温度センサー IC (LM35 / TMP36)

温度センサー IC で、温度を電圧として読む。
8-2 のサーミスタは、抵抗の変化を読むために分圧や増幅が要った。温度センサー IC は、
温度に比例した電圧をそのまま出してくれる。LM35 と TMP36 はピンの並びも
同じ TO-92 の 3 ピンなので、そのまま挿し替えて比べられる。
マイコンの ADC (11-3 で扱う) につなげば、温度計になる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 温度センサー IC の出力を取り出す
parts:
  VCC: vcc 2,2 5V
  C1: capacitor 2,4 2,6 100n
  G2: ground 2,6
  U1:
    type: ic3
    model: LM35
    at: 4,4
    label: LM35
    pins: [VS, VOUT, GND]
  G1: ground 5,5
  OUT: port 6,6
wires:
  - 2,2 -- 2,4
  - 2,4 -- U1.VS
  - U1.GND -| 5,5
  - U1.VOUT -- 4,6 -- 6,6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/circuit/10-temperature-ic.svg)

- LM35 は、10 mV/°C で 0 °C のとき 0 V という、ゲタ (オフセット) の無い特性。25 °C の
  室温なら約 250 mV が出る。マイナスの温度を測るには負電源が要る
  (LM35DZ のような 0〜100 °C の品なら、単電源のままでよい)
- TMP36 は 10 mV/°C だが、0 °C で 500 mV (25 °C で 750 mV) というオフセット付きの特性
  (V<sub>out</sub> = 0.5 V + 0.01 V/°C × T)。0 °C でも 0.5 V あるので、
  マイナス側に振れても 0 V を下回らない。単電源のままでマイナスの温度も測れるのが、LM35 との違いだ
- どちらもピンの並びは 1 = +Vs、2 = Vout、3 = GND で同じ (平らな面を手前にして左から)。同じ回路のまま
  差し替えて比べられる (計算式だけ違う)
- C1 (0.1 µF) は電源のバイパスコンデンサ (電源のノイズを GND へ逃がすコンデンサ) で、+Vs と GND の間に、IC の近くに置く。
  V<sub>out</sub> には付けない (LM35 の出力に容量を直接つなぐと発振しやすい)。データシートが指定する定石の値だ

## 実体配線図

電源は Analog Discovery 3 (AD3) の Supplies の +5 V (LM35 の消費電流は 60 µA 未満 (データシート) で、各レール約 50 mA の範囲に収まる)。
V<sub>out</sub> は AD3 の Scope の 1+ / 1− を直流の電圧計として当てて読む (テスターの DCV でも同じ値が読める)。
この題は直流の電圧だけを見るので、オシロの波形の図は付けない。

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 LM35 の出力を AD3 の電圧計で読む
board: half
parts:
  PS:
    type: device
    at: top
    label: AD3 Supplies 5V
    pins: [V+, GND]
  SC:
    type: device
    at: bottom
    label: AD3 Scope (DC 電圧計)
    pins: [1+, 1-]
  U1: ic3 b8(VS) b9(VOUT) b10(GND) LM35
  C1: capacitor/ceramic c13 c16 100n
wires:
  - PS.V+ -- +t1 red
  - PS.GND -- -t2 black
  - +t8 -- a8 red
  - a10 -- -t10 black
  - +t13 -- a13 red
  - a16 -- -t16 black
  - SC.1+ -- e9 orange
  - SC.1- -- e10 gray
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/01-circuits/08-sensors/breadboard/10-temperature-ic.svg)

- U1 (LM35、TO-92) は、平らな印字面を手前にして左から +Vs・Vout・GND (データシートの TO-92 の底面図の 1・2・3 と同じ並び)。
  8・9・10 列の b 行に挿す。+Vs (8 列) は赤の線で上の + レール、GND (10 列) は黒の線で上の − レールへ短く引く
- C1 (0.1 µF) は IC のすぐ右の 13 列と 16 列に挿し、13 列を赤の線で + レール、16 列を黒の線で − レールへつなぐ。
  レールを通して +Vs と GND の間に入り、IC の近くでバイパスする。Vout (9 列) には何も付けない
- AD3 Scope の 1+ を `e9` (Vout の列)、1− を `e10` (GND の列) につなぐ。Scope は DC カップリング、100 mV/div 程度で、
  画面の Measurements の平均値 (DC) を読む。TMP36 を試すときは、同じ 3 つの穴に挿し替える

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| U1 | 温度センサー IC (LM35DZ、TO-92) | +Vs 4〜30 V、10 mV/°C (0 °C で 0 V) |
| C1 | 積層セラミックコンデンサ (バイパス) | 0.1 µF |
| — | 電源 | 5 V (AD3 の Supplies の V+) |
| — | 計器 | AD3 の Scope 1+ / 1− (直流の電圧を読む)。テスターでもよい |

## 見るべき値

表の値は計算値。LM35 は V<sub>out</sub> = 0.01 × T [V] (T は °C)、
TMP36 (同じ回路に差し替えた場合) は V<sub>out</sub> = 0.5 + 0.01 × T [V]。
V<sub>out</sub> は、テスターの DC 電圧レンジ (mV が読めるレンジ) で、OUT と GND の間を測る。

| 温度 | LM35 の V<sub>out</sub> (計算値) | TMP36 の V<sub>out</sub> (計算値、参考) |
| --- | --- | --- |
| 0 °C | 0 V | 0.50 V |
| 25 °C (室温) | 0.25 V | 0.75 V |
| 37 °C (体温) | 0.37 V | 0.87 V |
| 100 °C | 1.00 V | 1.50 V |
| −10 °C | 測れない (単電源では 0 V 未満は出せない) | 0.40 V (TMP36 ならではの利点) |

| 測る所 | 期待する値 | 分かること |
| --- | --- | --- |
| 指でつまんだとき | 数秒でじわじわ電圧が上がる | 体温 (約 32〜35 °C の表面温度) に近づく |
| C1 を外したとき | 電源のノイズが V<sub>out</sub> に乗りやすくなる (目安) | データシートが電源のバイパスを勧める理由 |

## LTspice での確かめ

LM35・TMP36 の内部は SPICE の対象外で、データシートの式 V<sub>out</sub> = 0.01 × T (LM35)・0.5 + 0.01 × T (TMP36) を `sim/10-temperature-ic.cir` の .meas で計算して表と突き合わせた (算術)。

| 温度 | LM35 (本文) | LM35 (算術) | TMP36 (本文) | TMP36 (算術) | 判定 |
| --- | --- | --- | --- | --- | --- |
| 0 °C | 0 V | 0 V | 0.50 V | 0.50 V | 合う |
| 25 °C | 0.25 V | 0.25 V | 0.75 V | 0.75 V | 合う |
| 37 °C | 0.37 V | 0.37 V | 0.87 V | 0.87 V | 合う |
| 100 °C | 1.00 V | 1.00 V | 1.50 V | 1.50 V | 合う |
| −10 °C | 測れない | — | 0.40 V | 0.40 V | 合う |

## 出典

自作。

参考: [Texas Instruments LM35 データシート](https://www.ti.com/lit/ds/symlink/lm35.pdf)、[TMP36 データシート (Analog Devices、Adafruit のミラー)](https://cdn-learn.adafruit.com/assets/assets/000/010/131/original/TMP35_36_37.pdf)
