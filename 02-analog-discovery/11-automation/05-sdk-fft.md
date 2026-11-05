---
book: analog-discovery
chapter: 11
id: 11-5
title: SDK でオシロを取り込み、FFT を自分で書く
tier: 200
source: 自作 (SDK の関数は Digilent の WaveForms SDK と公式の Python サンプル)
board: —
---

# 11-5 SDK でオシロを取り込み、FFT を自分で書く

第 4 章の **Spectrum** は、Scope と同じ標本を FFT (高速フーリエ変換) で周波数ごとの成分に分けて描く。この題ではその中身を自分で書く。
11-2 の SDK で W1 の方形波を 8192 点取り込み、**基数 2 の FFT** (Cooley-Tukey) を 20 行ほどの Python で書いて、各次の高さを dBm で出す。
WaveForms の Spectrum (図3) と同じ数が出れば、FFT と単位の換算を自分で分かったことになる。

FFT は、点数 N を半分ずつに分け (偶数番と奇数番)、それぞれの FFT から全体を組み立てる。N = 2<sup>m</sup> なら m 段で終わり、
手計算の DFT (N² 回の掛け算) が N log₂N 回になる (8192 点で約 600 分の 1)。

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 W1 を 1+ に直につなぐ (基板を使わない)
parts:
  AD:
    type: device
    at: 2,3
    label: Analog Discovery 3
    pins: [W1, 1+, 1-, GND]
    turn: mirror
  G1: ground 8,5
wires:
  - AD.W1 -| 6,2.75
  - AD.1+ -| 6,2.75
  - AD.1- -| 8,5
  - AD.GND -| 8,5
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/circuit/05-sdk-fft.svg)

- W1 を 1+ に、1− を GND に、AD3 の線で直につなぐ。実体配線図は無い (基板を使わない。線 2 本を AD3 のヘッダーどうしに挿すだけ)
- W1 は振幅 1 V (−1〜+1 V) の方形波。Scope の入力 (±25 V) と 5 V のレンジ (±2.5 V) に収まる

## 計器の設定

WaveForms は閉じておき、`fft_scope.py` を `dwfconstants.py` と同じ場所で `python fft_scope.py` と打つ。

| 項目 | 値 | なぜ |
| --- | --- | --- |
| 標本化 | 125 kHz (125 MHz の 1000 分の 1) | AD3 の Scope は 125 MHz を整数で割った値を選ぶ。割り切れる値にする |
| 点数 N | 8192 (2<sup>13</sup>) | 基数 2 の FFT は点数が 2 の冪 |
| W1 | 方形波、976.5625 Hz、振幅 1 V | N 点にちょうど 64 周期が入る (64 × 125 kHz ÷ 8192)。窓を掛けなくても、線が隣へ漏れない |
| 窓 | なし (rect) | 周期がちょうど入るので要らない。入らないときは Hann を掛ける (第 4 章) |

```python
import cmath
import ctypes
import math
import time
from sys import platform

N = 8192                  # 点数 (2 の冪。FFT の決まり)
FS = 125e3                # 標本化 [Hz] (125 MHz の 1000 分の 1)
BIN = 64                  # 基本波を置く FFT の番号
F0 = BIN * FS / N         # 976.5625 Hz。N 点にちょうど 64 周期が入る


def fft(x):
    """基数 2 の FFT (Cooley-Tukey)。x の長さは 2 の冪。"""
    n = len(x)
    if n == 1:
        return [complex(x[0])]
    even = fft(x[0::2])
    odd = fft(x[1::2])
    out = [0j] * n
    for k in range(n // 2):
        t = cmath.exp(-2j * math.pi * k / n) * odd[k]
        out[k] = even[k] + t
        out[k + n // 2] = even[k] - t
    return out


def to_dbm(x):
    """片側の振幅スペクトル → 50 Ω の電力 [dBm]。振幅 a の正弦は a²/2/50 W。"""
    spec = fft(x)
    rows = []
    for k in range(1, len(x) // 2):
        amp = 2 * abs(spec[k]) / len(x)
        p_mw = (amp ** 2 / 2) / 50 * 1000
        rows.append((k * FS / len(x), 10 * math.log10(p_mw) if p_mw > 0 else -200))
    return rows


def capture():
    if platform.startswith("win"):
        dwf = ctypes.cdll.dwf
    elif platform.startswith("darwin"):
        dwf = ctypes.cdll.LoadLibrary("/Library/Frameworks/dwf.framework/dwf")
    else:
        dwf = ctypes.cdll.LoadLibrary("libdwf.so")
    import dwfconstants as constants  # WaveForms SDK に同梱の定数ファイル

    hdwf = ctypes.c_int()
    dwf.FDwfDeviceOpen(ctypes.c_int(-1), ctypes.byref(hdwf))
    if hdwf.value == 0:
        raise SystemExit("AD3 が開けない (WaveForms を閉じたか、USB を確かめる)")
    ch, node = ctypes.c_int(0), constants.AnalogOutNodeCarrier
    dwf.FDwfAnalogOutNodeEnableSet(hdwf, ch, node, ctypes.c_bool(True))
    dwf.FDwfAnalogOutNodeFunctionSet(hdwf, ch, node, constants.funcSquare)
    dwf.FDwfAnalogOutNodeFrequencySet(hdwf, ch, node, ctypes.c_double(F0))
    dwf.FDwfAnalogOutNodeAmplitudeSet(hdwf, ch, node, ctypes.c_double(1.0))
    dwf.FDwfAnalogOutConfigure(hdwf, ch, ctypes.c_bool(True))
    dwf.FDwfAnalogInChannelEnableSet(hdwf, ctypes.c_int(0), ctypes.c_bool(True))
    dwf.FDwfAnalogInChannelRangeSet(hdwf, ctypes.c_int(0), ctypes.c_double(5.0))
    dwf.FDwfAnalogInBufferSizeSet(hdwf, ctypes.c_int(N))
    dwf.FDwfAnalogInFrequencySet(hdwf, ctypes.c_double(FS))
    time.sleep(0.5)
    dwf.FDwfAnalogInConfigure(hdwf, ctypes.c_bool(False), ctypes.c_bool(True))
    status = ctypes.c_byte()
    while True:
        dwf.FDwfAnalogInStatus(hdwf, ctypes.c_bool(True), ctypes.byref(status))
        if status.value == constants.DwfStateDone.value:
            break
    buf = (ctypes.c_double * N)()
    dwf.FDwfAnalogInStatusData(hdwf, ctypes.c_int(0), buf, ctypes.c_int(N))
    real = ctypes.c_double()
    dwf.FDwfAnalogInFrequencyGet(hdwf, ctypes.byref(real))   # 本当に選ばれた標本化
    dwf.FDwfDeviceClose(hdwf)
    if abs(real.value - FS) > 1:
        print(f"標本化が {real.value:.1f} Hz になった。FS を書き換える")
    return list(buf)


if __name__ == "__main__":
    rows = to_dbm(capture())
    for n in (1, 3, 5, 7, 9):
        f, dbm = rows[n * BIN - 1]
        print(f"{n} 次  {f:9.2f} Hz  {dbm:7.2f} dBm")
```

- `fft()` は自分を 2 回呼ぶ (偶数番・奇数番)。長さ 1 になったらその値を返す。最後に e<sup>−j2πk/N</sup> を掛けて足し引きする所が「蝶」と呼ばれる計算
- `to_dbm()` は FFT の値を振幅に直し (2 × |X| / N)、50 Ω (オーム) の電力 (振幅² ÷ 2 ÷ 50 Ω) を mW で割って dBm にする。WaveForms の Spectrum の単位 dBm と同じ (10-1 と同じ約束)
- `capture()` は 11-2 と同じ呼び順。`FDwfAnalogInFrequencyGet` で、実際に選ばれた標本化を読み直す (125 kHz にならなければ線の位置がずれる)

```scope
# オシロスコープの画面 (tommie-fence の scope フェンス)
title: 図2 取り込む方形波 — 976.5625 Hz、±1 V
time: 200us/div
trigger: ch1 rising 0V
ch1: {wave: square 976.5625Hz 1V, range: 500mV/div}
measure: [vpp, freq]
```

![オシロスコープの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/scope/05-sdk-fft.svg)

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図3 WaveForms の Spectrum で見た同じ方形波 — 奇数次が 1/n で並ぶ
device: ad3
sweep: 0-48.828125kHz
samples: 8192
window: rect
unit: dBm
ref: 20dBm
signal: square 976.5625Hz 1V
markers: [976.5625Hz, 2929.6875Hz, 4882.8125Hz, 6835.9375Hz]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/02-analog-discovery/11-automation/spectrum/05-sdk-fft.svg)

この節のコードは AD3 で**実行して確かめていない** (実機は未確認)。`fft()` と `to_dbm()` は、AD3 の代わりに作った ±1 V の方形波 (8192 点) を渡して PC で動かし、
numpy の FFT との差が 3 × 10<sup>−12</sup> 以下になること、各次の高さが下の表と合うことを確かめた。

## 見るべき値

計算値。振幅 1 V の方形波の n 次 (奇数) は振幅 4/(nπ) V。

| 次数 | 周波数 | 振幅 | 電力 (50 Ω) | 自分の FFT (作った方形波) |
| --- | --- | --- | --- | --- |
| 1 | 976.6 Hz | 1.273 V | **12.10 dBm** | 12.10 dBm |
| 3 | 2.930 kHz | 0.424 V | 2.56 dBm (1 次より 9.54 dB 下) | 2.55 dBm |
| 5 | 4.883 kHz | 0.255 V | −1.88 dBm (13.98 dB 下) | −1.89 dBm |
| 7 | 6.836 kHz | 0.182 V | −4.80 dBm | −4.83 dBm |
| 偶数次 | 1.953 kHz など | 0 | 線が出ない | (−200 dBm、計算の上限) |

- 自分の FFT が 0.01〜0.03 dB 低いのは、標本化した方形波の折り返し (62.5 kHz より上の次数が下へ折れて重なる) のため。AD3 で測っても同じ向きに出る
- W1 を 1 kHz ちょうどにすると、N 点に 65.536 周期しか入らず、線が隣の番号へ漏れて 1 次が約 3 dB 低く読める。そのときは Hann の窓を掛け、
  窓の分 (Hann は振幅が半分、+6.02 dB) を足して直す (目安)
- 実物の W1 の方形波は立ち上がりが有限なので、高い次数ほど式より下がる (第 4 章)

## LTspice での確かめ (対象外)

回路を足さないプログラムの題なので SPICE の対象外。数は算術と PC で確かめた: 1 次の電力 = (4/π)² ÷ 2 ÷ 50 Ω = 16.2 mW = 12.10 dBm、
n 次は 20 log₁₀ n だけ下がる (3 次 9.54 dB、5 次 13.98 dB)。図3 の spectrum フェンスの読み値 (12.10・2.56・−1.88・−4.80 dBm) とも合う。

## 出典

自作。SDK の関数と呼び順は [Getting Started with WaveForms SDK](https://digilent.com/reference/test-and-measurement/guides/waveforms-sdk-getting-started) と
公式の Python サンプル ([Digilent/WaveForms-SDK-Getting-Started-PY](https://github.com/Digilent/WaveForms-SDK-Getting-Started-PY))。
参考: [高速フーリエ変換 (Wikipedia)](https://ja.wikipedia.org/wiki/高速フーリエ変換)
