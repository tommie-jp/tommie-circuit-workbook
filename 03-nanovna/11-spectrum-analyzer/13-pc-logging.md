---
book: nanovna
chapter: 11
id: 11-13
title: PC から操作して記録する
tier: 200
source: 自作
board: —
device: SA
---

# 11-13 PC から操作して記録する

tinySA は USB でつなぐと PC から**シリアルのポート**に見え、文字の命令 (`scan`・`rbw`・`marker` など) で操作できる。
画面の 450 点を 1 枚ずつ写すのではなく、**掃引の結果を数の表として PC に取り込み、時刻を付けて貯める**のがこの題。
第 10 章で NanoVNA をシリアルで操作した (10-6) のと同じ考え方で、FM 放送帯の 1 時間の記録を例にする。

既成のソフトもある。tinySA-App (Windows、公式) と QtTinySA (Python、Linux でも動く) は画面の写しと
保存ができ、PC からなら 450 点を超える点数でも掃引できる (公式の FAQ。tinySA-App は 30000 点まで)。
自分で書くのは、決まった時刻に決まった掃引を繰り返して残したいときである。

## つなぎ方

- tinySA を USB で PC につなぐ。Windows も Linux もドライバは要らない (Linux なら `/dev/ttyACM0` など)
- **初めに CAL 出力で確かめる**: tinySA Ultra の CAL 端子を、短い SMA のケーブルで RF 端子へつなぐ。
  CAL 出力は 30 MHz の方形波で、基本波が −35.6 dBm (公式の仕様)。読みが分かっている信号なので、
  プログラムが正しい数を取り込めているかを確かめられる
- 確かめたら、ケーブルを外して 11-12 のアンテナをつなぎ替える

この題は回路図と実体配線図を付けない。tinySA と PC を USB で、CAL と RF を SMA のケーブルでつなぐだけで、組む回路が無い。

## 命令 (シリアル)

公式の USB の頁から、この題で使う物だけ。命令は 1 行の文字で、行末は CR。返事の最後に `ch>` が来る。

| 命令 | 働き |
| --- | --- |
| `scan 開始 終了 点数 3` | 1 回掃引して、1 行ずつ周波数 [Hz] と読み [dBm] を返す (3 = 周波数 1 + 測った値 2)。点数は Ultra で 450 まで。終わると掃引が止まったままになるので `resume` で戻す |
| `rbw 100` | RBW を 100 kHz に (`auto` で自動) |
| `caloutput 30` | CAL 出力を 30 MHz に (`off` で止める) |
| `scanraw 開始 終了 点数` | 点数に上限の無い掃引。値は 2 バイトの数で、Ultra は **値 ÷ 32 − 174 = dBm** |
| `capture` | 画面の写し (Ultra は 480 × 320 画素、1 画素 2 バイト) |
| `ui off` | PC が操作している間、tinySA の画面の描き直しを止める (速くなる。画面に触れば戻る) |

USB の ID は、tinySA と古いファームウェアの Ultra が 0x0483 / 0x5740 (ST の仮想 COM ポート)、
新しいファームウェア (V1.4273 以降) の Ultra が 0x1781 / 0x0A44 (公式の USB の頁)。プログラムは両方を探す。

## プログラム

Python 3 と pyserial (`pip install pyserial`) で書く。`scan` の返事を行に分けて、時刻・周波数・dBm の 3 列で
CSV に足していく。**実機ではまだ動かしていない** (返事の形は公式の頁の説明どおりと仮定し、
その形を返すにせの装置 (PC の疑似端末) で読み取りを確かめた)。

```python
"""tinySA を USB のシリアルで操作し、掃引の結果を CSV に足していく (11-13)。"""
import csv
import sys
import time
from datetime import datetime

import serial
from serial.tools import list_ports

TINYSA_IDS = {(0x0483, 0x5740), (0x1781, 0x0A44)}  # tinySA / tinySA Ultra (新しいファームウェア)
PROMPT = b"ch>"


def find_port():
    for p in list_ports.comports():
        if (p.vid, p.pid) in TINYSA_IDS:
            return p.device
    sys.exit("tinySA が見つかりません")


def command(ser, text):
    """1 行送り、プロンプト ch> までの返事を行の並びで返す。"""
    ser.write((text + "\r").encode())
    reply = ser.read_until(PROMPT).decode(errors="replace")
    lines = reply.replace("\r", "").split("\n")
    return [s for s in lines[1:] if s and not s.startswith("ch>")]  # 1 行目は打った命令のこだま


def scan(ser, start, stop, points=450):
    """scan の outmask 3 = 周波数 (1) + 測った値 (2)。1 行 = 周波数 [Hz] と dBm。"""
    rows = command(ser, f"scan {start} {stop} {points} 3")
    command(ser, "resume")  # scan は掃引を止めたままにするので戻す
    return [(float(r.split()[0]), float(r.split()[1])) for r in rows]


def main(start, stop, interval_s, count, path):
    with serial.Serial(find_port(), timeout=30) as ser, open(path, "a", newline="") as f:
        command(ser, "")  # 打ちかけの行を流す
        out = csv.writer(f)
        for _ in range(count):
            stamp = datetime.now().isoformat(timespec="seconds")
            for freq, dbm in scan(ser, start, stop):
                out.writerow([stamp, int(freq), dbm])
            f.flush()
            time.sleep(interval_s)


if __name__ == "__main__":
    # 例: FM 放送帯を 10 分ごとに 6 回 (1 時間)
    main(76_000_000, 98_450_000, 600, 6, "fm-band.csv")
```

- 1 回の掃引は 450 行。10 分おきに 6 回で、1 時間に 2,700 行貯まる
- 読み終えたら `resume` を送る。送らないと tinySA の画面が止まったままになる
- 長く記録するときは、`ui off` を最初に送ると掃引が速くなり、PC の時刻と掃引の時刻のずれが小さくなる

## 計器の画面

CAL 出力 (30 MHz) を RF につないで、`rbw 300` のあと `scan 0 449000000 450 3` を送ったときに
**読めるはずの値** (計算値。方形波のデューティを 50 % と仮定し、奇数次が 1/n で並ぶとした)。

```spectrum
# スペクトラムアナライザの画面 (tommie-fence の spectrum フェンス)
title: 図1 CAL 出力 30 MHz — 基本波 −35.6 dBm と 3 倍・5 倍
device: tinysa-ultra
sweep: 0-449M 450
rbw: 300kHz
ref: -20dBm
signal: square 30MHz -37.7dBm
markers: [30M, 90M, 150M]
```

![スペクトラムアナライザの画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/11-spectrum-analyzer/spectrum/13-pc-logging.svg)

- 1 点 = 1 MHz なので、30 MHz の倍数が点の真上に載る。`scan` の返事の 31 行目 (0 Hz から数えて) が 30 MHz
- 図の `square` の振幅 −37.7 dBm は「同じ高さの正弦波の電力」で、方形波の基本波はその 4/π (パイ) 倍 (+2.10 dB) の
  −35.6 dBm に立つ

## 見るべき値

| 確かめること | 期待する値 |
| --- | --- |
| CSV の 30 MHz の行 | −35.6 dBm ± 2 dB (公式の仕様の、校正後の絶対値の確かさ) |
| 90 MHz・150 MHz の行 | −45.1 dBm・−49.6 dBm (計算値、デューティ 50 % の仮定) |
| 偶数倍 (60・120 MHz) の行 | 基本波よりずっと低い (デューティが 50 % に近いほど低い) |
| `scanraw` の値 4429 | 4429 ÷ 32 − 174 = −35.59 dBm |
| 1 回の掃引の行の数 | 450 |

分かること:

- CAL の読みが画面のマーカーと CSV で同じなら、取り込みは正しい。そこで初めてアンテナにつなぎ替えて記録を始める
- 記録した CSV は、局ごと (周波数ごと) の dBm の時間変化として図にできる (第 10 章の scikit-rf と同じく、
  Python の表の道具で読む)。11-12 の電界強度の式に通せば、電界強度の 1 時間の変化になる

## LTspice での確かめ (対象外)

PC と計器の通信の題で、SPICE で模型にする回路が無い。数は算術で確かめた: 方形波の基本波は同じ振幅の正弦の
4/π 倍 (20 log₁₀ (4/π) = 2.10 dB) なので −37.7 + 2.10 = −35.6 dBm。3 倍・5 倍は −35.6 − 20 log₁₀ 3 = −45.14 dBm、
−35.6 − 20 log₁₀ 5 = −49.58 dBm (図の読み値と合う)。`scanraw` の換算は 4429 ÷ 32 − 174 = −35.59 dBm。
10 分おきに 6 回 × 450 点 = 2,700 行。プログラムの読み取りは、公式の頁の返事の形をまねた疑似端末で 450 行を読めることを確かめた
(実機ではない)。

## 出典

自作。命令・返事の形・USB の ID・`scanraw` の換算は
[tinySA の USB の頁](https://tinysa.org/wiki/pmwiki.php?n=Main.USBInterface)、CAL 出力 (30 MHz で −35.6 dBm) と
絶対値の確かさ (±2 dB) は[仕様](https://tinysa.org/wiki/pmwiki.php?n=TinySA4.Specification)、
PC のソフト (tinySA-App・QtTinySA・Python のライブラリ) は[PC のソフトの頁](https://tinysa.org/wiki/pmwiki.php?n=Main.PCSW)、
点数の上限は [FAQ](https://tinysa.org/wiki/pmwiki.php?n=Main.FAQ) (いずれも 2026-11-14 に確認)。
シリアルは [pySerial](https://pyserial.readthedocs.io/en/latest/)。
