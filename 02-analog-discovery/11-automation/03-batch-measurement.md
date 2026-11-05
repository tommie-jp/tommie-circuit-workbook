---
book: analog-discovery
chapter: 11
id: 11-3
title: 部品 10 個のバッチ測定
tier: 200
source: 自作 (SDK の関数は Digilent の WaveForms SDK と公式の Python サンプル)
board: BB
---

# 11-3 部品 10 個のバッチ測定

買った抵抗 10 本 (1 kΩ (キロオーム)、公差 ±5 %) を 1 本ずつ挿し替えて測り、表 (CSV) に書き出して平均・ばらつき・公差の外を数える。
1 本ずつ WaveForms の画面を読んで手で書き写すと、10 本でも書き間違える。11-2 の Python (WaveForms SDK) に、
**挿し替えるたびに Enter を押すと測って 1 行書く**くり返しを足す。測り方は分圧で、基準の抵抗 R1 (1 kΩ、±1 %) と被測定の抵抗 R2 を直列にし、
W1 の正弦波に対する R2 の両端の比から R2 を逆算する。

v<sub>2</sub> / v<sub>1</sub> = R<sub>x</sub> / (R1 + R<sub>x</sub>) なので、**R<sub>x</sub> = R1 × v<sub>2</sub> / (v<sub>1</sub> − v<sub>2</sub>)**。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 基準の R1 と被測定の R2 の分圧を SDK で測る
parts:
  AD:
    type: device
    at: 1,1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor 3,3 6,3 1k
  R2: resistor 9,3 12,3 1k
  G1: ground 14,3
wires:
  - AD.W1 -| 3,3
  - AD.1+ -| 3,3
  - AD.1- -| 14,3
  - 6,3 -- 9,3
  - AD.2+ -| 6,3
  - AD.2- -| 14,3
  - 12,3 -- 14,3
  - AD.GND -| 14,3
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/circuit/03-batch-measurement.svg)

- 11-1 の RC ローパスの C を、被測定の抵抗 R2 に替えた形。R1 は基準で、1 % の金属皮膜にする (測る値の確からしさは R1 で決まる)
- W1 は 1 V<sub>p</sub>・1 kHz。R2 が 1 kΩ なら v<sub>2</sub> は 0.5 V<sub>p</sub>、流れる電流は 0.5 mA<sub>p</sub>

## 実体配線図

```breadboard
# ブレッドボードの実体配線図 (tommie-fence の breadboard フェンス)
title: 図2 R2 (10〜14 列) を 1 本ずつ挿し替える
board: half
parts:
  R1: resistor c5 c10 1k
  R2: resistor d10 d14 1k
  AD:
    type: device
    at: top
    label: Analog Discovery 3
    pins: [GND, W1, 1+, 1-, 2+, 2-]
wires:
  - AD.GND -- -t3 black
  - AD.W1 -- a5 yellow
  - AD.1+ -- b5 orange [h10]
  - AD.1- -- -t8 black
  - AD.2+ -- a10 blue
  - AD.2- -- -t12 black
  - a14 -- -t14 black
```

![ブレッドボードの実体配線図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/breadboard/03-batch-measurement.svg)

- 配線は 11-1 と同じで、C1 の場所 (`d10`〜`d14`) に R2 を挿す。R2 だけを抜き差しするので、R1 と線には触れない
- 挿し替える間は W1 を出したままでよい (1 V・0.5 mA なので、触れても部品は傷まない)

## 計器の設定

WaveForms は閉じておく (SDK と同時には AD3 を掴めない)。次のスクリプトを `batch.py` として保存し、WaveForms に同梱の `dwfconstants.py` と同じ場所で
`python batch.py` と打つ。

| 項目 | 値 |
| --- | --- |
| Wavegen (W1) | Sine、1 kHz、振幅 1 V |
| Scope | 100 kHz で 10000 点 (0.1 s = 1 kHz の 100 周期)、レンジ 5 V、CH1・CH2 |
| 振幅の求め方 | 1 kHz の成分だけを取り出す (1 点の DFT)。11-2 の (最大値 − 最小値) / 2 は雑音の山を拾いやすい |
| 書き出し | `batch.csv` (番号・抵抗・ずれ) と、画面に平均・標準偏差・最小・最大・公差の外の番号 |

```python
import csv
import ctypes
import math
import statistics
import time
from sys import platform

if platform.startswith("win"):
    dwf = ctypes.cdll.dwf
elif platform.startswith("darwin"):
    dwf = ctypes.cdll.LoadLibrary("/Library/Frameworks/dwf.framework/dwf")
else:
    dwf = ctypes.cdll.LoadLibrary("libdwf.so")
import dwfconstants as constants  # WaveForms SDK に同梱の定数ファイル

R_REF = 1000.0      # 基準抵抗 R1 [Ω] (1 % の金属皮膜)
F_TEST = 1000.0     # 測る周波数 [Hz]
FS = 100e3          # 標本化 [Hz]
N = 10000           # 点数 (0.1 s = 1 kHz の 100 周期)
COUNT = 10          # 部品の数
TOL = 0.05          # 公差 ±5 %


def amplitude(buf, f, fs):
    """f の成分の振幅 (1 点の DFT)。max - min より雑音に強い。"""
    re = sum(v * math.cos(2 * math.pi * f * k / fs) for k, v in enumerate(buf))
    im = sum(v * math.sin(2 * math.pi * f * k / fs) for k, v in enumerate(buf))
    return 2 * math.hypot(re, im) / len(buf)


def capture(hdwf):
    dwf.FDwfAnalogInConfigure(hdwf, ctypes.c_bool(False), ctypes.c_bool(True))
    status = ctypes.c_byte()
    while True:
        dwf.FDwfAnalogInStatus(hdwf, ctypes.c_bool(True), ctypes.byref(status))
        if status.value == constants.DwfStateDone.value:
            break
    b1 = (ctypes.c_double * N)()
    b2 = (ctypes.c_double * N)()
    dwf.FDwfAnalogInStatusData(hdwf, ctypes.c_int(0), b1, ctypes.c_int(N))
    dwf.FDwfAnalogInStatusData(hdwf, ctypes.c_int(1), b2, ctypes.c_int(N))
    return list(b1), list(b2)


def resistance(v1, v2):
    """分圧の式を逆に解く: v2 / v1 = Rx / (R_REF + Rx)"""
    return R_REF * v2 / (v1 - v2)


def main():
    hdwf = ctypes.c_int()
    dwf.FDwfDeviceOpen(ctypes.c_int(-1), ctypes.byref(hdwf))
    if hdwf.value == 0:
        raise SystemExit("AD3 が開けない (WaveForms を閉じたか、USB を確かめる)")
    ch = ctypes.c_int(0)
    node = constants.AnalogOutNodeCarrier
    dwf.FDwfAnalogOutNodeEnableSet(hdwf, ch, node, ctypes.c_bool(True))
    dwf.FDwfAnalogOutNodeFunctionSet(hdwf, ch, node, constants.funcSine)
    dwf.FDwfAnalogOutNodeFrequencySet(hdwf, ch, node, ctypes.c_double(F_TEST))
    dwf.FDwfAnalogOutNodeAmplitudeSet(hdwf, ch, node, ctypes.c_double(1.0))
    dwf.FDwfAnalogOutConfigure(hdwf, ch, ctypes.c_bool(True))
    dwf.FDwfAnalogInChannelEnableSet(hdwf, ctypes.c_int(-1), ctypes.c_bool(True))
    dwf.FDwfAnalogInChannelRangeSet(hdwf, ctypes.c_int(-1), ctypes.c_double(5.0))
    dwf.FDwfAnalogInBufferSizeSet(hdwf, ctypes.c_int(N))
    dwf.FDwfAnalogInFrequencySet(hdwf, ctypes.c_double(FS))
    time.sleep(0.5)

    rows = []
    for no in range(1, COUNT + 1):
        input(f"{no} 個めを挿して Enter: ")
        b1, b2 = capture(hdwf)
        rx = resistance(amplitude(b1, F_TEST, FS), amplitude(b2, F_TEST, FS))
        rows.append((no, rx))
        print(f"  {no:2d}: {rx:8.1f} Ω")
    dwf.FDwfDeviceClose(hdwf)
    report(rows, 1000.0)


def report(rows, nominal):
    with open("batch.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["番号", "抵抗 (Ω)", "ずれ (%)"])
        for no, rx in rows:
            w.writerow([no, f"{rx:.1f}", f"{(rx / nominal - 1) * 100:.2f}"])
    values = [rx for _, rx in rows]
    bad = [no for no, rx in rows if abs(rx / nominal - 1) > TOL]
    print(f"平均 {statistics.mean(values):.1f} Ω  標準偏差 {statistics.stdev(values):.1f} Ω")
    print(f"最小 {min(values):.1f} Ω  最大 {max(values):.1f} Ω  公差の外 {bad or 'なし'}")


if __name__ == "__main__":
    main()
```

- `amplitude()` は、測った列に 1 kHz の cos と sin を掛けて足し、その大きさを振幅にする (DFT の 1 点)。100 周期ぶん足すので、ほかの周波数の雑音は打ち消し合う
- `capture()` の関数名と呼び順は 11-2 と同じ。開けないとき (`hdwf` が 0) は止まって理由を出す
- `report()` が CSV を書く。11-4 はこの CSV を matplotlib でグラフにする

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図3 1 本め (1 kΩ) を測っている画面 — CH2 は CH1 のちょうど半分
time: 500us/div
trigger: ch1 rising 0V
ch1: {wave: sine 1kHz 1V, range: 500mV/div}
ch2: {wave: ch1 | gain 0.5, range: 500mV/div}
measure: [vpp]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/scope/03-batch-measurement.svg)

この節のコードは AD3 で**実行して確かめていない** (実機は未確認)。分圧の逆算・DFT の振幅・CSV の書き出しは、
AD3 の代わりに作った正弦波の列を渡して PC で確かめた (950・1000・1050 Ω を 950.0・1000.0・1050.0 Ω と読んだ)。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1 | 金属皮膜抵抗 (1/4 W、±1 %) | 1 kΩ (基準) |
| R2 | 被測定の抵抗 10 本 (カーボン皮膜、±5 %) | 1 kΩ |
| — | 電源 | 使わない (W1 の 0.5 mA だけ) |
| — | 計器 | AD3 の Wavegen (W1) と Scope (CH1 = W1、CH2 = R2)。PC の Python 3 と WaveForms SDK |

## 見るべき値

計算値。

| 項目 | 期待する値 | 分かること |
| --- | --- | --- |
| v<sub>2</sub> / v<sub>1</sub> (R2 = 950・1000・1050 Ω) | 0.4872・0.5000・0.5122 | ±5 % の端でも比は ±2.5 % しか動かない |
| 読み値の 10 本 | 950〜1050 Ω の中 | 外れた番号が `公差の外` に出る |
| R1 の ±1 % の影響 | 全部の読みが同じ向きに 1 % ずれる | ばらつき (標準偏差) には効かず、平均だけをずらす |
| 振幅の読みの 0.1 % の誤差 | 抵抗の読みで 0.2 % | R<sub>x</sub> = R1 のとき、比の誤差は抵抗で 2 倍になる (感度は R1 / (R1 + R<sub>x</sub>) = 0.5) |

- **R1 と R<sub>x</sub> を同じくらいにすると一番よく測れる** (比が 0.5 の近く)。10 kΩ の部品を測るなら R1 も 10 kΩ にする
- 平均を正しくしたいなら、先に 0.1 % の抵抗を 1 本測って R1 の本当の値を逆に求め、`R_REF` に書き込む (校正)
- 同じくり返しで、コンデンサの容量も測れる。比を複素数で扱い、C<sub>x</sub> = 1 / (2πf × R1 × |v<sub>2</sub> / (v<sub>1</sub> − v<sub>2</sub>)|) にする
  (NanoVNA の教科書の 10-3 は、同じバッチを VNA の Touchstone で行う)

## LTspice での確かめ

`sim/03-batch-divider.cir` で図1 を交流解析し、R2 を 950・1000・1050 Ω に替えて 1 kHz の v<sub>2</sub> (v<sub>1</sub> = 1 V) を読んだ。

| R2 | 本文の比 | LTspice | 逆算した R<sub>x</sub> | 判定 |
| --- | --- | --- | --- | --- |
| 950 Ω | 0.4872 | 0.4872 (−6.246 dB) | 950 Ω | 合う |
| 1000 Ω | 0.5000 | 0.5000 (−6.021 dB) | 1000 Ω | 合う |
| 1050 Ω | 0.5122 | 0.5122 (−5.811 dB) | 1050 Ω | 合う |

## 出典

自作。SDK の関数と呼び順は [Getting Started with WaveForms SDK](https://digilent.com/reference/test-and-measurement/guides/waveforms-sdk-getting-started) と
公式の Python サンプル ([Digilent/WaveForms-SDK-Getting-Started-PY](https://github.com/Digilent/WaveForms-SDK-Getting-Started-PY))。
