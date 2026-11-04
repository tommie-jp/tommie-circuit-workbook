---
book: fpga
chapter: 12
id: 12-8
title: リバーシを PC から指す — play.py で対戦し、200 局で回路と C を突き合わせる
tier: 300
source: 自作。プロトコルは tommie-jp/reversi-uart-protocol v0.2 (CC BY 4.0)
board: BB
device: PICO
---

# 12-8 リバーシを PC から指す — play.py で対戦し、200 局で回路と C を突き合わせる

> [!WARNING]
> **この題は実機で組んでいない。** Pico 2 のプログラムは `.uf2` までビルドし、RP2350 のエミュレータ (picoemu) に載せて
> UART0 越しに 200 局を打たせた。PC では同じプログラムを替え玉の stdio で動かし、PC の側のプログラムと 200 局を打たせた。
> 実物の Pico 2 への書き込み、USB と Debug Probe での PC との対局、AD3 での測定はしていない。
> picoemu は USB を外に出さないので、USB の道は picoemu でも確かめていない。
> 「見るべき値」の時間の欄は、測って書く。

12-2 では、12-1 のリバーシのアクセラレータを Pico 2 の Soft-FPGA に載せ、リバーシ UART プロトコルの行に答える `.uf2` を作った。
この題はその相手の PC の側を書く。Python の play.py で Pico 2 と対局し、Pico 2 の手を毎回ルールに当てて確かめる。
同じ play.py で乱数の相手と 200 局を回し、回路の版と C の版の `.uf2` (と、その元の `reversi.c`) が同じ手を選ぶことを突き合わせる。

この題は回路図・実体配線図・Analog Discovery 3 とロジックアナライザの図を載せない。回路・配線・計器は 12-2 と同じで、前の題の回路は再掲しない。
話す行の決まりは 12-2 の「話す行」、Pico 2 のプログラムとビルドは 12-2 の「Pico 2 のプログラム」にある。

## PC の側 — play.py

PC の側は Python で書いた。人が打つ (既定) か、乱数で打つ相手を何局も回す。**Pico 2 の手を毎回自分でルールに当てて確かめ**、合法でなければ止まる。
シリアルポートを開くのに pyserial (`pip install pyserial`) を使う。

```python
#!/usr/bin/env python3
"""12-2 PC の側: Pico 2 とリバーシ UART プロトコルで対戦する。

    python3 play.py /dev/ttyACM0            # 人が打つ (PC は白、Pico 2 は黒)
    python3 play.py /dev/ttyACM0 --cpu white --random 5   # 乱数で打つ相手を 5 局

盤のルールはこのファイルの中で数え直し、Pico 2 の手が合法かを毎回確かめる。
"""
import argparse
import random
import sys

DIRS = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
EMPTY, BLACK, WHITE = 0, 1, 2


def new_board():
    b = [[EMPTY] * 8 for _ in range(8)]
    b[3][3], b[3][4], b[4][3], b[4][4] = WHITE, BLACK, BLACK, WHITE   # d4 e4 d5 e5
    return b


def flips(b, r0, c0, me):
    """(r0, c0) に me を置いたとき裏返る石の (行, 列) の並び。打てなければ空"""
    if b[r0][c0] != EMPTY:
        return []
    you = BLACK + WHITE - me
    out = []
    for dr, dc in DIRS:
        r, c, line = r0 + dr, c0 + dc, []
        while 0 <= r < 8 and 0 <= c < 8 and b[r][c] == you:
            line.append((r, c))
            r, c = r + dr, c + dc
        if line and 0 <= r < 8 and 0 <= c < 8 and b[r][c] == me:
            out += line
    return out


def moves(b, me):
    return [(r, c) for r in range(8) for c in range(8) if flips(b, r, c, me)]


def play(b, r, c, me):
    for fr, fc in flips(b, r, c, me):
        b[fr][fc] = me
    b[r][c] = me


def coord(r, c):
    return "abcdefgh"[c] + str(r + 1)


def show(b):
    mark = {EMPTY: ".", BLACK: "X", WHITE: "O"}
    lines = ["  a b c d e f g h"]
    for r in range(8):
        lines.append(f"{r + 1} " + " ".join(mark[b[r][c]] for c in range(8)))
    return "\n".join(lines)


class Link:
    """1 行ずつ送り、1 行ずつ受ける。行の終わりは CR LF"""

    def __init__(self, write, readline):
        self._write, self._readline = write, readline

    def send(self, s):
        self._write((s + "\r\n").encode("ascii"))

    def recv(self):
        raw = self._readline()
        if not raw:
            raise EOFError("相手が黙った")
        return raw.decode("ascii").rstrip("\r\n")


def wait_move(link, log):
    """Pico 2 の MO か PA を待つ。ほかの行 (RE・+ で始まる応答) は記録して読み飛ばす"""
    while True:
        line = link.recv()
        log.append("< " + line)
        if line.startswith("MO") or line == "PA":
            return line
        if line.startswith("-"):
            raise RuntimeError(f"Pico 2 がエラーを返した: {line}")


def game(link, cpu, choose, log):
    """1 局打つ。cpu は Pico 2 の色 (BLACK か WHITE)。choose(b, legal) が PC の手を選ぶ。
    戻り値は (黒の石の数, 白の石の数)"""
    b = new_board()
    pc = BLACK + WHITE - cpu
    link.send("SB" if cpu == BLACK else "SW")
    log.append("> " + ("SB" if cpu == BLACK else "SW"))
    turn = BLACK
    while True:
        if turn == cpu:
            line = wait_move(link, log)
            legal = moves(b, cpu)
            if line == "PA":
                if legal:
                    raise RuntimeError(f"Pico 2 が打てるのにパスした: {[coord(*m) for m in legal]}")
            else:
                r, c = int(line[3]) - 1, "abcdefgh".index(line[2])
                if (r, c) not in legal:
                    raise RuntimeError(f"Pico 2 の手 {line} は合法でない")
                play(b, r, c, cpu)
        else:
            if not moves(b, BLACK) and not moves(b, WHITE):
                nb = sum(row.count(BLACK) for row in b)
                nw = sum(row.count(WHITE) for row in b)
                end = "EB" if nb > nw else "EW" if nw > nb else "ED"
                link.send(end)
                log.append("> " + end)
                return nb, nw
            legal = moves(b, pc)
            if legal:
                r, c = choose(b, legal)
                play(b, r, c, pc)
                msg = "MO" + coord(r, c)
            else:
                msg = "PA"
            link.send(msg)
            log.append("> " + msg)
        turn = BLACK + WHITE - turn


def human(b, legal):
    print(show(b))
    while True:
        s = input(f"あなたの手 ({' '.join(coord(*m) for m in legal)}): ").strip().lower()
        if len(s) == 2 and s[0] in "abcdefgh" and s[1] in "12345678":
            m = (int(s[1]) - 1, "abcdefgh".index(s[0]))
            if m in legal:
                return m
        print("その手は打てない")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("port")
    ap.add_argument("--cpu", choices=["black", "white"], default="black")
    ap.add_argument("--random", type=int, metavar="N", help="乱数で打つ相手と N 局")
    ap.add_argument("--baud", type=int, default=115200)
    a = ap.parse_args()
    import serial                       # pyserial
    ser = serial.Serial(a.port, a.baud, timeout=5)
    link = Link(ser.write, ser.readline)
    link.send("PI")
    print("<", link.recv())             # RE が先に来ることもある
    cpu = BLACK if a.cpu == "black" else WHITE
    rng = random.Random(1)
    games = a.random or 1
    for _ in range(games):
        log = []
        choose = (lambda b, legal: rng.choice(legal)) if a.random else human
        nb, nw = game(link, cpu, choose, log)
        print(f"黒 {nb} 白 {nw}")
    link.send("XB")
    print("<", link.recv())


if __name__ == "__main__":
    sys.exit(main())
```

- 盤のルールは 12-1 の参照実装と同じ考え方 (8 方向を 1 マスずつ辿る) を Python で書き直した。Pico 2 の答えを、別の言語の別の書き方で確かめる
- 終局の判断は PC がする。両方とも打てなくなったら、石の数で `EB` `EW` `ED` を送る。Pico 2 は終局を判断しない (プロトコルの §11)
- PC が打った後は、Pico 2 が必ず `MO` か `PA` を返す。両方打てない局面でも、Pico 2 の `PA` を受けてから `EB` などを送る
- `game()` は送り先と受け先を `Link` で受け取るので、シリアルポートの代わりに PC のプロセスや TCP をつないで試験できる (下の「プログラムでの確かめ」)

## 動かす

### Debug Probe が無いとき (既定)

1. Pico 2 の BOOTSEL を押しながら USB をつなぎ、出たドライブに `reversi122.uf2` を写す (0-2)
2. 書き込むと Pico 2 が起き直し、USB のシリアルポートが出る。Linux なら `/dev/ttyACM0` など、Windows なら `COM3` など
3. 端末ソフト (改行を CR LF で送る設定) で `PI` を打ち、`+PI` が返るのを見る。USB なので速さ (bps) の設定は何でもよい
4. `python3 play.py /dev/ttyACM0` で対局する。乱数の相手と 5 局なら `python3 play.py /dev/ttyACM0 --random 5`

Pico 2 を書き直したり BOOTSEL で止めたりすると、USB のシリアルポートは一度消えて出直す。play.py を開いたままにしていたら、開き直す。

### Debug Probe があるとき

同じ `.uf2` のまま、12-2 の図3 (実体配線図) の緑・黄・黒の 3 本を挿して、Probe の UART の口を開く。

1. Debug Probe を PC につなぐ。Probe は書き込みの口と UART の口の 2 つを出す。Linux なら Pico 2 の USB と合わせて `/dev/ttyACM0` と `/dev/ttyACM1` が出る。番号はつなぐ順で変わるので、次の手順で名前から選ぶ
2. `ls /dev/serial/by-id/` で `Debug_Probe` を含む名前を探し、`python3 play.py /dev/serial/by-id/<その名前>` で対局する (115200 bps は play.py の既定)
3. Probe から書き込むなら BOOTSEL は要らない (0-9)

答えは USB と UART0 の両方に出る。Probe で対局している間に Pico 2 の USB のポートを別の端末で開いても、同じ答えが見える。
Pico 2 を先に起こすと、`RE` の行は PC が開く前に出て捨てられる。play.py は `RE` を読み飛ばすので、どちらの順でもよい。

## 見るべき値

| 項目 | 値 | どこで得たか |
| --- | --- | --- |
| 乱数の相手と 200 局 (Pico 2 が黒 100・白 100) | 最後まで打ち切り、Pico 2 の 5 582 手がすべて合法。Pico 2 の勝ち 165・引き分け 2・負け 33 | PC の試験 (回路の版と C の版で同じ) と picoemu |
| 200 局で回路が探すのに使ったクロック | 41 387 (考えた回数 5 774、1 回あたり平均 7.2) | `XB` の `clocks` |

- 「考えた回数」5 774 には、Pico 2 が打った 5 582 手と、打てる所が無くて `PA` を返した 192 回が入る
- 乱数の相手に 8 割ほど勝つのは、角を取り、多く裏返す手を選ぶからである。強い相手には勝てない (先を読まない)

## プログラムでの確かめ

PC と picoemu の 2 つの所で、12-2 のプログラムを play.py と対局させた。SDK のモックでの確かめ (層 A) は 12-2 にある。

### PC で 200 局 — 回路の版と C の版

`sim/02-reversi-uart-run.sh` が、12-2 の `reversi.c` を PC 用の替え玉 (`sim/02-reversi-uart-pcstub/`。`getchar_timeout_us` を標準入力、`stdio_put_string` を標準出力にし、UART1 と GPIO は何もしない) で 2 通りにビルドし、
`sim/02-reversi-uart-test.py` で play.py と対局させる。回路の版は、12-1 の Verilog を Verilator 5.042 で C++ にして 12-2 の `accel.cpp` とつないだ。

```text
ok  ./reversi_fpga: 決まった応答 ['RE', '+PI', '+VE02wb-reversi-12-2', 'MOd3', 'MOf3', '-02 lowercase', '-03 need CR LF', '-04 bad coord', '-05 illegal move', '-06 not my game', '-01 unknown']
ok  ./reversi_c: 決まった応答 (同じ 11 行)
ok  ./reversi_fpga: 200 局を最後まで打った。Pico 2 の手 5582、パス 192、すべて合法
    Pico 2 の勝ち 165、引き分け 2、負け 33  +XB moves=5774 clocks=41387 us=11087
ok  ./reversi_c: 200 局を最後まで打った。Pico 2 の手 5582、パス 192、すべて合法
    Pico 2 の勝ち 165、引き分け 2、負け 33  +XB moves=5774 clocks=41387 us=4490
ok  2 つのビルドの記録が同じ (11848 行)
PASS
```

`us=` は PC の時間で、走らせるたびに少し変わる (4 回で回路の版 13 438・13 629・11 599・11 087、C の版 4 066・4 886・4 189・4 490)。
2 つのビルドの記録 (PC と Pico 2 が送った全部の行) が 1 字も違わないので、回路の版と C の版は 200 局の全部の局面で同じ手を選んだ。

### picoemu — `.uf2` を丸ごと動かす

USB 付きでビルドした `.uf2` を RP2350 のエミュレータ picoemu (`wb-picoemu` のイメージ。5-2 と同じ版) に Cortex-M33 として載せ、
`-net-uart0` で UART0 を、`-net-uart1` で UART1 (写し) を TCP につないだ。
`sim/02-reversi-uart-emu.py` が play.py の `game()` を UART0 の TCP で回し、同じ乱数の相手と PC の版 (`reversi_c`) とも打って、記録を比べる。
UART1 に届いた写しが、UART0 に送った字と同じかも比べる。

**picoemu は USB の CDC を外に出さない** (USB の列挙を始めるところまでは動く)。なので PC とは UART0、つまり Debug Probe の道で話させた。
主ループは USB か UART0 かを区別しないので、UART0 で通れば行の扱いは同じ。USB の道そのもの (TinyUSB の動き・ポートを開く前の出力が捨てられること) は実機で確かめる。
GP2 の印と GP16〜GP18 の状態は picoemu では見ていない。picoemu は走り切って終わるときにしか `-gpio-trace` の VCD を閉じず、対局の途中で止めると書きかけで切れるため (12-2 の層 A で見た)。

```bash
docker run --rm -v "$PWD":/w -w /w wb-picoemu python3 -I 02-reversi-uart-emu.py build/reversi122.uf2 ./reversi_c 200
```

| `.uf2` | 結果 |
| --- | --- |
| `reversi122.uf2` (回路の版) | 200 局、Pico 2 の手 5 582 がすべて合法。PC の記録と同じ。UART1 の写しが送った字 35 602 字と同じ。`+XB moves=5774 clocks=41387 us=351346938` |
| `reversi122_c.uf2` (C の版) | 200 局、同じく PC の記録と同じ。写しも同じ。`+XB moves=5774 clocks=41387 us=91437902` |

picoemu の `us` は、picoemu が命令を数えて進める時刻で、実機の時間ではない (5-2)。picoemu の中では回路の版が C の版の約 3.8 倍の時間を数えた。
PC の比 (約 2.8〜3.4 倍) に近いが、実機の比は測って確かめる。

確かめていないもの: 実物の Pico 2 との対局、USB と Debug Probe のそれぞれで play.py が話せること。ほかは 12-2 の「プログラムでの確かめ」の終わりにまとめた。

## 出典

自作。

- 行の決まり: [tommie-jp/reversi-uart-protocol](https://github.com/tommie-jp/reversi-uart-protocol) の README (ドラフト v0.2、CC BY 4.0)。§5 文字と改行、§7 行の書式と答えのコード、§8 座標、§11 CPU の状態 (終局の判断は PC がする)
