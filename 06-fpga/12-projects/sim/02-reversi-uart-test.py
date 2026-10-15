#!/usr/bin/env python3
"""12-2 の試験: PC で作った Pico 2 の主ループ (標準入出力を UART に見立てる) と、play.py の対局を回す。

    python3 test.py ./reversi_fpga ./reversi_c

1. 決まった入力に決まった応答を返すか (PI・VE・誤りの応答)
2. 乱数の相手と 200 局 (Pico 2 が黒 100 局・白 100 局)。Pico 2 の手を毎回 play.py のルールで確かめる
3. 回路のビルドと C のビルドで、200 局の記録が 1 字も違わないか
"""
import importlib.util
import pathlib
import random
import subprocess
import sys

here = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("play", here / "02-reversi-uart-play.py")
play = importlib.util.module_from_spec(spec)
spec.loader.exec_module(play)

errors = 0


def check(cond, what):
    global errors
    print(("ok  " if cond else "NG  ") + what)
    if not cond:
        errors += 1


def start(exe):
    p = subprocess.Popen([exe], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    return p, play.Link(lambda b: (p.stdin.write(b), p.stdin.flush()), p.stdout.readline)


def replies(exe, text):
    out = subprocess.run([exe], input=text.encode(), capture_output=True, timeout=10).stdout
    return out.decode().split("\r\n")[:-1]


def fixed(exe):
    r = replies(exe, "PI\r\nVE\r\nSB\r\nMOe3\r\nmo\r\nPI\nMOz9\r\nMOa1\r\nEB\r\nPA\r\n\r\nZZ\r\n")
    want = ["RE", "+PI", "+VE02wb-reversi-12-2", "MOd3", "MOf3", "-02 lowercase", "-03 need CR LF",
            "-04 bad coord", "-05 illegal move", "-06 not my game", "-01 unknown"]
    check(r == want, f"{exe}: 決まった応答 {r}")


def games(exe, n):
    p, link = start(exe)
    link.recv()                                    # RE
    rng = random.Random(2026)
    log, results = [], []
    for i in range(n):
        cpu = play.BLACK if i % 2 == 0 else play.WHITE
        results.append(play.game(link, cpu, lambda b, legal: rng.choice(legal), log))
    link.send("XB")
    xb = link.recv()
    p.stdin.close()
    p.wait()
    return log, results, xb


exes = sys.argv[1:]
for e in exes:
    fixed(e)
records = {}
for e in exes:
    log, results, xb = games(e, 200)
    win = sum(1 for k, (nb, nw) in enumerate(results) if (nb > nw) == (k % 2 == 0) and nb != nw)
    draw = sum(1 for nb, nw in results if nb == nw)
    cpu_moves = sum(1 for s in log if s.startswith("< MO"))
    cpu_pass = sum(1 for s in log if s == "< PA")
    check(len(results) == 200, f"{e}: 200 局を最後まで打った。Pico 2 の手 {cpu_moves}、パス {cpu_pass}、すべて合法")
    print(f"    Pico 2 の勝ち {win}、引き分け {draw}、負け {200 - win - draw}  {xb}")
    records[e] = log
if len(exes) == 2:
    a, b = records.values()
    check(a == b, f"2 つのビルドの記録が同じ ({len(a)} 行)")
print("PASS" if errors == 0 else f"FAIL: {errors}")
sys.exit(1 if errors else 0)
