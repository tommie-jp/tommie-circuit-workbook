---
book: analog-discovery
chapter: 11
id: 11-2
title: WaveForms SDK (Python) の最初
tier: 100
source: 公式 (Digilent Getting Started with WaveForms SDK) + 自作
board: —
---

# 11-2 WaveForms SDK (Python) の最初

11-1 までの Script は**WaveForms 本体の中の Script Editor** (JavaScript 風)
から計器を動かした。ここでは一歩外に出て、**WaveForms を起動していない
外部の Python プロセス**から、SDK (`dwf` ライブラリ、`ctypes` 経由の C 関数)
で AD を直接動かす。1-5・11-1 と同じ RC ローパス (R = 1 kΩ、C = 100 nF、
f<sub>c</sub> ≒ 1.59 kHz) を、Python だけで駆動・測定する。

Script Editor の `Scope1.channel[0].measure("Amplitude")` のような**便利な
測定関数は SDK には無い** — SDK が返すのは生の ADC サンプル列そのものなので、
振幅は自分で (最大値 − 最小値) / 2 のように計算する。この「生のデータを
もらって自分で処理する」形が、11-3 以降 (バッチ測定・matplotlib) につながる。

## 回路図

```circuit
title: 図1 RC ローパスを Python (SDK) から駆動・測定する
parts:
  AD:
    type: device
    at: a1
    label: Analog Discovery
    pins: [W1, GND, 1+, 1-, 2+, 2-]
  R1: resistor c3 c6 1k
  C1: capacitor c9 c12 100n
  G1: ground c14
wires:
  - AD.W1 -| c3
  - AD.1+ -| c3
  - AD.1- -| c14
  - c6 -- c9
  - AD.2+ -| c6
  - AD.2- -| c14
  - c12 -- c14
  - AD.GND -| c14
```

11-1 と全く同じ RC ローパス。1+ が入力 (W1)、2+ が出力 (R と C の中点)。

## 計器の設定

Python スクリプトの中で全部設定するので、WaveForms 本体は起動しなくてよい
(SDK が直接デバイスを掴む)。

| 項目 | 値 |
| --- | --- |
| Wavegen (W1) | Sine、1 kHz、振幅 1 V |
| Scope | サンプリング 20 MHz、バッファ 8192 点、レンジ ±5 V、CH1・CH2 とも有効 |
| 待ち時間 | 設定後 0.5 秒待ってから記録 (波形が落ち着くまで) |

```python
import ctypes
import math
import time
from sys import platform

# ライブラリを読み込む (OS ごとにパスが違う)
if platform.startswith("win"):
    dwf = ctypes.cdll.dwf
elif platform.startswith("darwin"):
    dwf = ctypes.cdll.LoadLibrary("/Library/Frameworks/dwf.framework/dwf")
else:
    dwf = ctypes.cdll.LoadLibrary("libdwf.so")

import dwfconstants as constants  # WaveForms SDK に同梱の定数ファイル

hdwf = ctypes.c_int()
dwf.FDwfDeviceOpen(ctypes.c_int(-1), ctypes.byref(hdwf))  # 最初に見つかった1台を開く

# --- Wavegen: W1 に 1 kHz・1 V の正弦波 ---
channel = ctypes.c_int(0)  # チャネル 1 は 0 始まり
dwf.FDwfAnalogOutNodeEnableSet(hdwf, channel, constants.AnalogOutNodeCarrier, ctypes.c_bool(True))
dwf.FDwfAnalogOutNodeFunctionSet(hdwf, channel, constants.AnalogOutNodeCarrier, constants.funcSine)
dwf.FDwfAnalogOutNodeFrequencySet(hdwf, channel, constants.AnalogOutNodeCarrier, ctypes.c_double(1000.0))
dwf.FDwfAnalogOutNodeAmplitudeSet(hdwf, channel, constants.AnalogOutNodeCarrier, ctypes.c_double(1.0))
dwf.FDwfAnalogOutConfigure(hdwf, channel, ctypes.c_bool(True))

# --- Scope: CH1・CH2 を ±5 V、20 MHz、8192 点で ---
dwf.FDwfAnalogInChannelEnableSet(hdwf, ctypes.c_int(-1), ctypes.c_bool(True))
dwf.FDwfAnalogInChannelRangeSet(hdwf, ctypes.c_int(-1), ctypes.c_double(5.0))
dwf.FDwfAnalogInBufferSizeSet(hdwf, ctypes.c_int(8192))
dwf.FDwfAnalogInFrequencySet(hdwf, ctypes.c_double(20e6))

time.sleep(0.5)  # 波形が落ち着くまで待つ

# --- 1 回だけ記録する ---
dwf.FDwfAnalogInConfigure(hdwf, ctypes.c_bool(False), ctypes.c_bool(True))
status = ctypes.c_byte()
while True:
    dwf.FDwfAnalogInStatus(hdwf, ctypes.c_bool(True), ctypes.byref(status))
    if status.value == constants.DwfStateDone.value:
        break

buf1 = (ctypes.c_double * 8192)()
buf2 = (ctypes.c_double * 8192)()
dwf.FDwfAnalogInStatusData(hdwf, ctypes.c_int(0), buf1, ctypes.c_int(8192))  # CH1 = 入力
dwf.FDwfAnalogInStatusData(hdwf, ctypes.c_int(1), buf2, ctypes.c_int(8192))  # CH2 = 出力

vin = (max(buf1) - min(buf1)) / 2   # 振幅は自分で計算する (measure() は無い)
vout = (max(buf2) - min(buf2)) / 2
gain_db = 20 * math.log10(vout / vin)
print("Vin =", round(vin, 4), "V   Vout =", round(vout, 4), "V   Gain =", round(gain_db, 2), "dB")

dwf.FDwfDeviceClose(hdwf)
```

- `dwf.FDwfDeviceOpen` `FDwfAnalogOutNodeEnableSet` `FDwfAnalogOutNodeFunctionSet`
  `FDwfAnalogOutNodeFrequencySet` `FDwfAnalogOutNodeAmplitudeSet`
  `FDwfAnalogOutConfigure` `FDwfAnalogInChannelEnableSet`
  `FDwfAnalogInChannelRangeSet` `FDwfAnalogInBufferSizeSet`
  `FDwfAnalogInFrequencySet` `FDwfAnalogInConfigure` `FDwfAnalogInStatus`
  `FDwfAnalogInStatusData` `FDwfDeviceClose` は、Digilent が公開している
  WaveForms SDK の実際の関数名 (Getting Started with WaveForms SDK / 公式の
  Python サンプルに沿った並び)。`constants` (`dwfconstants`) は WaveForms の
  インストール先に同梱されているファイルをそのまま import する
- ゲイン (dB) は `20 * log10(Vout / Vin)` — 11-1 の Script で
  `20 * Math.log(vout / vin) / Math.LN10` と書いたのと同じ式を、Python では
  `math.log10` でそのまま書ける

## 見るべき値

計算値。11-1 と同じ f<sub>c</sub> = 1.5915 kHz、f = 1 kHz での理論ゲインは
−1.45 dB (11-1 の表と同じ行)。

| 項目 | 期待する値 | 分かること |
| --- | --- | --- |
| Vin (CH1 の振幅) | 1.000 V 前後 | Wavegen の設定どおり |
| Vout (CH2 の振幅) | 0.845 V 前後 (= 10<sup>−1.45/20</sup>) | 1 kHz での理論ゲイン −1.45 dB に相当 |
| Vout/Vin をデシベルに直した値 | 約 −1.45 dB | 11-1 で Script Editor が出した値と同じであるはず |

**WaveForms の Script Editor で測った値と、外部 Python (SDK) で測った値は
一致するはずである。** 同じハードウェアを 2 つの違う入口 (内蔵 Script /
外部 SDK) から動かしているだけで、測っている物理量は同じだから。この一致を
確かめておくと、11-3 以降でバッチ測定を Python 側に任せてよい根拠になる。

## 出典

公式: [Getting Started with WaveForms SDK](https://digilent.com/reference/test-and-measurement/guides/waveforms-sdk-getting-started)
(Digilent)。関数名・呼び出し順は同社公開の Python サンプル
([Digilent/WaveForms-SDK-Getting-Started-PY](https://github.com/Digilent/WaveForms-SDK-Getting-Started-PY))
の `device.py` / `wavegen.py` / `scope.py` に沿って確認した。
