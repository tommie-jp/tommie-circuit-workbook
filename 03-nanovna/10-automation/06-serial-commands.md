---
book: nanovna
chapter: 10
id: 10-6
title: シリアルコマンドで直接制御 (Python)
tier: 200
source: 自作 (コマンドは NanoVNA-H のファームウェアのソース、呼び方は NanoVNA-Saver のソース)
board: —
device: H4
---

# 10-6 シリアルコマンドで直接制御 (Python)

NanoVNA-H4 は USB で PC に**仮想シリアルポート**として見え、字のコマンドを 1 行ずつ受け付ける (shell)。
NanoVNA-Saver も裏ではこのコマンドを送っている。Saver を通さず Python から直接送れば、掃引・読み出し・保存を
**ボタンを押さずに**繰り返せる — Saver で手で保存していた所 (2-5) を、プログラムに置き換える一歩目である。

この題では、0-3 の 20 dB パッドを例に、1 回の `scan` で S11 と S21 を読み、Saver と同じ形の `.s2p` に書く。

## 使うコマンド

NanoVNA-H のファームウェア (`main.c`) のコマンドの表から、この題で使う物だけ。行の終わりは CR (`\r`)。
本体は送った字をそのまま返し (こだま)、答えの行を CR LF で区切って並べ、最後にプロンプト `ch>` (後ろに空白 1 つ) を出す。

| コマンド | 働き | 返事 |
| --- | --- | --- |
| `version` | ファームウェアの版 | 版の 1 行 |
| `scan 開始 終了 点数 outmask` | その範囲を 1 回掃引し、掃引を止める | outmask で選んだ物を 1 点 1 行で |
| `resume` | 止めた掃引を再び回す (本体の画面が動く) | 無し |

outmask は足し算で選ぶ: **1 = 周波数 (Hz)、2 = S11 (data 0) の実部・虚部、4 = S21 (data 1) の実部・虚部**。
7 なら 1 行が `周波数 S11実部 S11虚部 S21実部 S21虚部` の 5 つの数になる。周波数は Hz の整数で書く (`1M` は読まない)。
点数の上限は版による (この系統の H4 は 401 点。2-4)。本体に校正が掛かっていれば、`scan` の値も校正済み。

- この題のコマンドは **NanoVNA-H / H4 の系統** (hugen79 の版と、そこから分かれた DiSlord の版) の物。
  NanoVNA V2 と、その系統の LiteVNA64 は、レジスタを読み書きするバイナリのやり方で話す (目安。手元の版の資料で確かめる) ので、
  このスクリプトはそのままでは動かない。LiteVNA64 を PC から動かすなら、Saver (両方に対応) を使う
- Saver は版が 0.7.1 以上なら `scan … 0b110` (S11 と S21) と `scan … 0b001` (周波数) を送っている。この題は 1 回で全部取る `7`

## 回路図

```circuit
# 回路図 (tommie-fence の circuit フェンス)
title: 図1 0-3 の 20 dB パッド (43・11・43 Ω) を CH0 と CH1 の間に
parts:
  J1: sma 2,2 mirror CH0
  R1: resistor 4,2 6,2 43
  R2: resistor 6,2 6,4 11
  R3: resistor 6,2 8,2 43
  J2: sma 10,2 CH1
  G1: ground 2,3
  G2: ground 6,4
  G3: ground 10,3
wires:
  - J1.1 -- 4,2
  - 8,2 -- J2.1
  - J1.2 -- 2,3
  - J2.2 -- 10,3
notes:
  - text 7,3.6 blue left: NanoVNA の USB を PC の Python へ
```

![回路図](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/circuit/06-serial-commands.svg)

この題は実体配線図を付けない — 0-3 の perfboard の 20 dB パッド (0-3 の図2) をそのまま使う。

## 掃引の設定

計器は VNA (NanoVNA-H4 と PC の Python)。AD3 とオシロは使わない (S パラメータを見る題)。

| 項目 | 値 |
| --- | --- |
| 範囲 | 1 MHz〜300 MHz (`scan 1000000 300000000 101 7`) |
| 点数 | 101 |
| 校正 | 本体で SOLT してスロット 0 に保存 (1-1・1-6)。`scan` の値はこの校正で直した物 |
| ポート | Windows は `COM5` など (デバイスマネージャーで見る)、Linux は `/dev/ttyACM0` など (`dialout` の組に入る) |
| 表示 | S21 の Log Mag、S11 の Log Mag |

20 dB パッドで見えるはずの画面。Python が書いた `.s2p` を Saver の Files ... → Load as sweep で開くと同じ線になる。

```vna
# NanoVNA の画面 (tommie-fence の vna フェンス)
device: h4
sweep: 1M-300M 101
title: 図2 20 dB パッドは S21 −19.76 dB・S11 −31.19 dB で平ら
dut:
  - series R 43
  - shunt R 11
  - series R 43
traces:
  - S21 logmag
  - S11 logmag
markers:
  - 10M
```

![NanoVNA の画面](https://tommie-jp.github.io/tommie-circuit-workbook/03-nanovna/10-automation/vna/06-serial-commands.svg)

## Python のスクリプト

pyserial を入れる (`pip install pyserial`)。Saver を閉じてから (同じポートは 1 つのソフトしか開けない)
`python vna_scan.py COM5 10-6-pad20.s2p` と打つ。

```python
import math
import sys

import serial  # pyserial

START, STOP, POINTS = 1_000_000, 300_000_000, 101   # [Hz]、点数 (H4 は 401 点まで。版による)
MASK = 0b111            # scan の outmask: 1 = 周波数、2 = S11 (data 0)、4 = S21 (data 1)
PROMPT = b"ch> "


def command(ser, cmd):
    """1 行のコマンドを送り、プロンプト 'ch> ' までの返事を行の並びで返す (頭の 1 行は送った字のこだま)。"""
    ser.reset_input_buffer()
    ser.write((cmd + "\r").encode("ascii"))
    raw = ser.read_until(PROMPT)
    if not raw.endswith(PROMPT):
        raise TimeoutError(f"{cmd}: 返事がプロンプトまで来ない (ポート・ケーブル・版を確かめる)")
    lines = raw[: -len(PROMPT)].decode("ascii").split("\r\n")
    if lines and lines[0].strip() == cmd:
        lines = lines[1:]
    return [ln.strip() for ln in lines if ln.strip()]


def scan(ser):
    """scan で 1 回掃引し、(周波数, S11, S21) の並びを返す。"""
    rows = []
    for ln in command(ser, f"scan {START} {STOP} {POINTS} {MASK}"):
        v = ln.split()
        if len(v) != 5:
            raise ValueError(f"読めない行: {ln}")
        rows.append((int(v[0]), complex(float(v[1]), float(v[2])), complex(float(v[3]), float(v[4]))))
    if len(rows) != POINTS:
        raise ValueError(f"{len(rows)} 点しか来ない ({POINTS} 点のはず)")
    return rows


def save_s2p(path, rows):
    """Saver と同じ形 (# HZ S RI R 50) で書く。測らない S12・S22 は 0。"""
    with open(path, "w", encoding="utf-8") as fp:
        fp.write("# HZ S RI R 50\n")
        for f, s11, s21 in rows:
            fp.write(f"{f} {s11.real} {s11.imag} {s21.real} {s21.imag} 0 0 0 0\n")


def run(ser, path):
    print("版:", " ".join(command(ser, "version")))
    rows = scan(ser)
    command(ser, "resume")                # scan の後は掃引が止まっているので本体の画面を動かし直す
    save_s2p(path, rows)
    f, s11, s21 = min(rows, key=lambda r: abs(r[0] - 10e6))
    print(f"{len(rows)} 点を {path} に保存。{f / 1e6:.3f} MHz: "
          f"S21 {20 * math.log10(abs(s21)):.2f} dB  S11 {20 * math.log10(abs(s11)):.2f} dB")


def main():
    port, path = sys.argv[1], sys.argv[2]           # 例: COM5 か /dev/ttyACM0、10-6-pad20.s2p
    with serial.Serial(port, timeout=5) as ser:     # USB の仮想シリアルなので速さ (baud) は効かない
        run(ser, path)


if __name__ == "__main__":
    main()
```

- `read_until(b"ch> ")` は、プロンプトが来るか `timeout` (5 秒) が切れるまで読む。101 点の `scan` は Saver の README で 1.5 秒ほど
  (101 点の 1 区切り)。IF の帯域を狭くした (2-9) ときや 401 点のときは `timeout` を延ばす
- 書き出しの形は Saver と同じなので、10-2 の scikit-rf がそのまま読む
- `run(ser, path)` を `main()` から分けてあるのは、ポートの代わりに偽の物を渡して PC だけで試すため (下)。
  繰り返すなら `run()` を `for` で回し、名前に回の番号を付ける。温度を変えながらの記録 (4-27) も同じ形で回せる

このスクリプトは NanoVNA につないで**まだ動かしていない** (実機は未確認)。PC で、ファームウェアの `scan` の書き出し
(`%f` の 6 桁、行の終わりの空白、CR LF、こだま、プロンプト `ch>`) を真似て 20 dB パッドの S パラメータを返す偽のポート
(`write` と `read_until` と `reset_input_buffer` だけを持つ) を作り、`run()` に渡して動かした (Python 3.12、pyserial 3.5)。
送ったコマンドは `version`・`scan 1000000 300000000 101 7`・`resume` の順で、「101 点を 10-6-pad20.s2p に保存。9.970 MHz:
S21 −19.76 dB  S11 −31.19 dB」と出て、書いた `.s2p` を scikit-rf 2.2.0 が 2 ポート・101 点として読んだ。

## 部品

| 記号 | 部品 | 値 |
| --- | --- | --- |
| R1・R3 | 炭素皮膜抵抗 (1/4 W) | 43 Ω (オーム) |
| R2 | 炭素皮膜抵抗 (1/4 W) | 11 Ω |
| J1・J2 | 端面 SMA (メス) | 0-3 の perfboard |
| — | 計器 | NanoVNA-H4、PC (Python 3、pyserial) |
| — | 電源 | 使わない (USB の給電だけ) |

## 見るべき値

計算値 (0-3 の 20 dB パッドの理想)。

| 見る所 | 値 | 分かること |
| --- | --- | --- |
| `version` の返事 | 版の 1 行 | ポートと話せている |
| 返ってきた行の数 | 101 | 点が欠けていない (欠ければスクリプトが止まる) |
| 10 MHz に一番近い点 (9.970 MHz) の S21 | −19.76 dB | Saver で測った値 (2-9 の 1 段の値) と同じ |
| 同じ点の S11 | −31.19 dB | 同上 |
| `resume` の後 | 本体の画面が動き出す | 掃引を止めたままにしていない |

- 同じ物を Saver で保存した `.s2p` と、このスクリプトの `.s2p` を 10-2 で重ねると、校正が同じなら重なる。ずれたら、
  Saver の側だけに Saver の校正 (10-5) が掛かっていないかを見る (このスクリプトの値は本体の校正だけ)

## LTspice での確かめ

`sim/06-serial-scan.cir` で図1 のパッドを AC 解析にかけた (50 Ω の電源と 50 Ω の終端)。理想の模型で、実測ではない。

| 周波数 | 項目 | 本文の数字 | LTspice | 判定 |
| --- | --- | --- | --- | --- |
| 10 MHz | S21 / S11 | −19.76 dB / −31.19 dB | −19.76 dB / −31.19 dB (0.10285 / 0.02758) | 合う |
| 9.970 MHz | S21 | −19.76 dB | −19.76 dB | 合う |

0-3 の LTspice の表 (−19.76 dB) とも同じ。

## 出典

自作。コマンドの名前・引数・outmask の意味・プロンプト `ch>`・行の区切りは
[NanoVNA-H のファームウェア](https://github.com/hugen79/NanoVNA-H) の `main.c` (`cmd_scan` とコマンドの表)。
Saver の送り方は [NanoVNA-Saver](https://github.com/NanoVNA-Saver/nanovna-saver) のソース (`Hardware/VNA.py`・`Hardware/NanoVNA.py`)。
シリアルの読み書きは [pySerial のドキュメント](https://pyserial.readthedocs.io/en/latest/)。
