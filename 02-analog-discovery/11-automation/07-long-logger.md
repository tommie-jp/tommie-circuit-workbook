---
book: analog-discovery
chapter: 11
id: 11-7
title: ロガーの長期記録 (1 日)
tier: 200
source: 自作 (SDK の関数は Digilent の WaveForms SDK と公式の Python サンプル)
board: BB
---

# 11-7 ロガーの長期記録 (1 日)

部屋の温度を 10 秒ごとに 24 時間記録する。温度の検出は NTC サーミスタ (温度が上がると抵抗が下がる部品) と抵抗の分圧で、
AD3 の Supplies の V+ (5 V) に掛けて、分圧の点 (CH1) と V+ (CH2) を読む。**比 CH1 / CH2 から温度を出す**ので、V+ が少し揺れても温度は揺れない。

1 日の記録で効いてくるのは、測る仕組みより**止まらないこと**だ。この題の Python は、1 行ごとにファイルへ書き切る (途中で止まってもそこまでは残る)、
USB が一瞬抜けたら開き直して続ける、書く時刻を 10 秒ごとの刻みに合わせる (読む時間のぶん遅れていかない)、の 3 つを入れる。
WaveForms にも Data Logger という計器があり、短い記録ならそちらで足りる。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 V+ から NTC と R1 の分圧。CH1 と CH2 の比で温度を出す
parts:
  VP: vsource 2,2 2,6 5
  G1: ground 2,6
  RT1: thermistor-ntc 5,1 5,3 10k
  R1: resistor 5,4 5,6 10k
  M1: voltmeter 8,3.5 8,6 l=$\mathrm{CH1}$
  M2: voltmeter 11,1 11,6 l=$\mathrm{CH2}$
wires:
  - 2,2 -- 2,1 -- 5,1 -- 11,1
  - 5,3 -- 5,3.5 -- 5,4
  - 5,3.5 -- 8,3.5
  - 2,6 -- 5,6 -- 8,6 -- 11,6
style:
  grid: on
  pitch: 1.2
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/circuit/07-long-logger.svg)

- V<sub>P</sub> は AD3 の V+ (5 V)。RT1 は NTC サーミスタ (25 °C で 10 kΩ (オーム)、B 定数 3435 K と仮定。買った品の資料の値に直す)、R1 は 10 kΩ
- 25 °C で分圧の点 (CH1) は 2.5 V、流れる電流は 0.25 mA
- 温度の式: R<sub>T</sub> = R1 × (V<sub>CH2</sub> / V<sub>CH1</sub> − 1)、T = 1 / (1/T<sub>0</sub> + ln(R<sub>T</sub>/R<sub>0</sub>) / B) (T<sub>0</sub> = 298.15 K、R<sub>0</sub> = 10 kΩ、温度は K)

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 NTC (10〜14 列) と R1 (14〜18 列)。14 列が CH1
board: half
parts:
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [V+, 2+, GND, 1+, 1-, 2-]
  RT1: thermistor-ntc c10 c14 10k
  R1: resistor d14 d18 10k
wires:
  - AD.V+ -- +t4 red
  - AD.2+ -- +t7 orange
  - AD.GND -- -t9 black
  - AD.1+ -- a14 yellow
  - AD.1- -- -t21 black
  - AD.2- -- -t23 black
  - +t10 -- a10 red
  - a18 -- -t18 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/breadboard/07-long-logger.svg)

- V+ (赤) は上の赤レール、10 列から RT1 (10〜14 列) へ。R1 (14〜18 列) の 18 列は上の青レールへ
- 1+ は分圧の点の 14 列、2+ は赤レール (V+)、1−・2− と GND は青レール
- 部屋の温度を測るときは、RT1 を長めのリード線で基板から少し離し、AD3 や PC の排気が当たらない所に置く

## 計器の設定

オシロの図は載せない (直流の電圧を 10 秒ごとに読む題で、時間で変わる波形を見ない)。代わりに CH1 の電圧と温度の対応を図3 に描く。
WaveForms は閉じておき、`logger.py` を `dwfconstants.py` と同じ場所で `python logger.py` と打つ。`log-年月日-時分.csv` ができる。

| 項目 | 値 | なぜ |
| --- | --- | --- |
| Supplies | V+ 5 V (スクリプトの中で入れる) | 分圧の電源 |
| 1 回の読み | 10 kHz で 1000 点 (0.1 s) の平均 | 0.1 s は 50 Hz の 5 周期・60 Hz の 6 周期で、商用電源の誘導がどちらの地域でも平均で消える |
| レンジ | 50 V (CH1・CH2) | 5 V を読む。AD3 の 5 V のレンジは ±2.5 V までしか入らない |
| 間隔・長さ | 10 秒・24 時間 (8640 行) | 部屋の温度の変化は分の単位で、10 秒で足りる |

```python
import ctypes
import datetime
import math
import time
from sys import platform

PERIOD_S = 10          # 記録の間隔 [s]
HOURS = 24             # 記録する長さ [h]
FS = 10e3              # 標本化 [Hz]
N = 1000               # 1 回の点数 (0.1 s = 50 Hz の 5 周期・60 Hz の 6 周期)
R_FIX = 10e3           # R1 [Ω]
R0, T0, B = 10e3, 298.15, 3435.0   # NTC: 25 °C で 10 kΩ、B 定数 (買った品の資料の値に直す)


def ntc_celsius(v_t, v_plus):
    """分圧の比から NTC の抵抗、B 定数の式から温度を出す (V+ の揺れは比で消える)。"""
    r_ntc = R_FIX * (v_plus / v_t - 1)
    return 1 / (1 / T0 + math.log(r_ntc / R0) / B) - 273.15


def open_device(dwf):
    hdwf = ctypes.c_int()
    dwf.FDwfDeviceOpen(ctypes.c_int(-1), ctypes.byref(hdwf))
    if hdwf.value == 0:
        raise OSError("AD3 が開けない")
    # Supplies の V+ を 5 V に (チャネル 0 が V+、節 0 が入り切り、節 1 が電圧)
    dwf.FDwfAnalogIOChannelNodeSet(hdwf, ctypes.c_int(0), ctypes.c_int(0), ctypes.c_double(1))
    dwf.FDwfAnalogIOChannelNodeSet(hdwf, ctypes.c_int(0), ctypes.c_int(1), ctypes.c_double(5.0))
    dwf.FDwfAnalogIOEnableSet(hdwf, ctypes.c_bool(True))
    dwf.FDwfAnalogInChannelEnableSet(hdwf, ctypes.c_int(-1), ctypes.c_bool(True))
    dwf.FDwfAnalogInChannelRangeSet(hdwf, ctypes.c_int(-1), ctypes.c_double(50.0))   # 5 V を読むので 50 V のレンジ
    dwf.FDwfAnalogInBufferSizeSet(hdwf, ctypes.c_int(N))
    dwf.FDwfAnalogInFrequencySet(hdwf, ctypes.c_double(FS))
    time.sleep(1.0)
    return hdwf


def read_means(dwf, hdwf, done):
    dwf.FDwfAnalogInConfigure(hdwf, ctypes.c_bool(False), ctypes.c_bool(True))
    status = ctypes.c_byte()
    while True:
        if dwf.FDwfAnalogInStatus(hdwf, ctypes.c_bool(True), ctypes.byref(status)) == 0:
            raise OSError("読めない (USB が抜けた?)")
        if status.value == done:
            break
    means = []
    for ch in (0, 1):
        buf = (ctypes.c_double * N)()
        dwf.FDwfAnalogInStatusData(hdwf, ctypes.c_int(ch), buf, ctypes.c_int(N))
        means.append(sum(buf) / N)
    return means


def main():
    if platform.startswith("win"):
        dwf = ctypes.cdll.dwf
    elif platform.startswith("darwin"):
        dwf = ctypes.cdll.LoadLibrary("/Library/Frameworks/dwf.framework/dwf")
    else:
        dwf = ctypes.cdll.LoadLibrary("libdwf.so")
    import dwfconstants as constants  # WaveForms SDK に同梱の定数ファイル

    done = constants.DwfStateDone.value
    name = datetime.datetime.now().strftime("log-%Y%m%d-%H%M.csv")
    end = time.time() + HOURS * 3600
    hdwf = open_device(dwf)
    with open(name, "a", encoding="utf-8") as fp:
        fp.write("日時,CH1 (V),CH2 (V),温度 (°C)\n")
        next_t = time.time()
        while time.time() < end:
            try:
                v_t, v_plus = read_means(dwf, hdwf, done)
                line = f"{datetime.datetime.now().isoformat(timespec='seconds')},{v_t:.4f},{v_plus:.4f},{ntc_celsius(v_t, v_plus):.2f}"
            except OSError as err:
                line = f"{datetime.datetime.now().isoformat(timespec='seconds')},,,# {err}"
                dwf.FDwfDeviceCloseAll()
                time.sleep(5)
                hdwf = open_device(dwf)          # 開き直して続ける (開けなければここで止まる)
            fp.write(line + "\n")
            fp.flush()                           # 途中で止まっても、そこまでは残る
            print(line)
            next_t += PERIOD_S
            time.sleep(max(0, next_t - time.time()))
    dwf.FDwfDeviceCloseAll()


if __name__ == "__main__":
    main()
```

- `ntc_celsius()` は上の温度の式。V+ が 4.9 V に下がっても比は同じで、25.00 °C のまま (PC で確かめた)
- `read_means()` は読めなければ `OSError` を出す。`main()` はそれを受けて、その行に理由を書き、5 秒待って開き直す
- `fp.flush()` で 1 行ずつ書き切る。CSV の見出しは 11-4 の書き方で読めるように `日時,CH1 (V),CH2 (V),温度 (°C)`
- `FDwfAnalogIOChannelNodeSet` のチャネルと節の番号 (0 が V+、節 0 が入り切り・節 1 が電圧) は、公式の Python サンプルの AD2 の書き方に沿った。AD3 では確かめていない (目安)

```graph
# グラフ (tommie-fence の graph フェンス)
title: 図3 CH1 の電圧と温度 — 25 °C で 2.50 V、1 °C あたり約 47 mV
x: 温度 °C 0..40
y: CH1 V 0..5
lines:
  CH1 V: 5/(1+exp(3435*(1/(x+273.15)-1/298.15)))
notes:
  - mark 15
  - mark 25
  - mark 30
```

![グラフ](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/graph/07-long-logger.svg)

この節のコードは AD3 で**実行して確かめていない** (実機は未確認)。温度の式は、下の表の 5 点の電圧を渡して PC で動かし、
0・15・25・30・40 °C に戻ることを確かめた。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| RT1 | NTC サーミスタ | 10 kΩ (25 °C)、B 定数 3435 K (仮定。品の資料の値を `B` に書く) |
| R1 | 金属皮膜抵抗 (1/4 W、±1 %) | 10 kΩ (温度の確からしさは R1 で決まる) |
| — | 電源 | AD3 の Supplies の V+ (5 V、0.25 mA) |
| — | 計器 | AD3 の Scope (CH1 = 分圧の点、CH2 = V+)。PC の Python 3 と WaveForms SDK |

## 見るべき値

計算値。

| 温度 | NTC の抵抗 | CH1 | 分かること |
| --- | --- | --- | --- |
| 0 °C | 28.7 kΩ | 1.292 V | 寒い部屋でも 5 V のレンジの中 |
| 15 °C | 14.9 kΩ | 2.007 V | |
| 25 °C | 10.0 kΩ | 2.500 V | R1 と等しい所で一番感度が高い |
| 30 °C | 8.27 kΩ | 2.737 V | 25〜30 °C で 1 °C あたり 47 mV |
| 40 °C | 5.76 kΩ | 3.173 V | |

- 50 V のレンジの最小の刻み (14 ビット) は約 3 mV で、温度にして 0.06 °C。1000 点の平均でもっと細かく読める
- NTC 自身の発熱: 25 °C で 2.5 V × 0.25 mA = 0.63 mW。熱放散定数を 2 mW/°C (仮定。品の資料で確かめる) とすると 0.3 °C 高く読む。気になれば R1 と NTC を 47 kΩ の品にする
- 1 日の形は、朝に低く昼に高い (暖房・冷房と日当たりで変わる)。グラフは 11-4 の書き方で、横軸を時刻にして描く
- CSV は 1 行 40 字ほどで 8640 行、約 0.35 MB。1 週間で 2.5 MB ほど
- PC がスリープすると記録が止まる。長く記録するときは PC の電源の設定でスリープを切る

## LTspice での確かめ

`sim/07-logger-ntc.cir` で、NTC を B 定数の式の抵抗にして温度を 0・15・25・30・40 °C に替え、動作点の CH1 を読んだ。

| 温度 | 本文の CH1 | LTspice | 温度の式で戻した値 | 判定 |
| --- | --- | --- | --- | --- |
| 0 °C | 1.292 V | 1.2918 V | 0.00 °C | 合う |
| 15 °C | 2.007 V | 2.0068 V | 15.00 °C | 合う |
| 25 °C | 2.500 V | 2.5000 V (0.250 mA) | 25.00 °C | 合う |
| 30 °C | 2.737 V | 2.7368 V | 30.00 °C | 合う |
| 40 °C | 3.173 V | 3.1728 V | 40.00 °C | 合う |

## 出典

自作。SDK の関数と呼び順は [Getting Started with WaveForms SDK](https://digilent.com/reference/test-and-measurement/guides/waveforms-sdk-getting-started) と
公式の Python サンプル ([Digilent/WaveForms-SDK-Getting-Started-PY](https://github.com/Digilent/WaveForms-SDK-Getting-Started-PY))。
WaveForms の Data Logger は Digilent の [Using the Data Logger](https://digilent.com/reference/test-and-measurement/guides/waveforms-data-logger)。
参考: [サーミスタ (Wikipedia)](https://ja.wikipedia.org/wiki/サーミスタ)
