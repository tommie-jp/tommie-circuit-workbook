#!/usr/bin/env python3
"""12-2 の .uf2 を picoemu (RP2350 のエミュレータ) に載せ、UART0 を TCP につないで play.py と対局させる。
同じ乱数の相手と、PC で作った主ループ (pc_exe) とも同じ局数を打ち、記録が同じかを比べる。

    python3 emu.py reversi122.uf2 ./reversi_c 10       # wb-picoemu のコンテナの中で
"""
import importlib.util
import pathlib
import random
import socket
import subprocess
import sys
import time

here = pathlib.Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("play", here / "02-reversi-uart-play.py")
play = importlib.util.module_from_spec(spec)
spec.loader.exec_module(play)


def run_games(link, n):
    rng = random.Random(2026)                 # test.py と同じ相手
    log = []
    for i in range(n):
        cpu = play.BLACK if i % 2 == 0 else play.WHITE
        play.game(link, cpu, lambda b, legal: rng.choice(legal), log)
    return log


def sock_link(port):
    for _ in range(100):
        try:
            s = socket.create_connection(("127.0.0.1", port))
            break
        except OSError:
            time.sleep(0.1)
    s.settimeout(60)
    f = s.makefile("rb")
    return play.Link(s.sendall, f.readline)


uf2, pc_exe, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
emu = subprocess.Popen(["picoemu", uf2, "-arch", "m33", "-max-steps", "100000000000", "-net-uart0", "5555"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
link = sock_link(5555)
link.send("PI")
while link.recv() != "+PI":                   # RE は接続より前に出て、届かないこともある
    pass
t0 = time.time()
log_emu = run_games(link, n)
link.send("XB")
xb = link.recv()
emu.kill()

pc = subprocess.Popen([pc_exe], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
pc_link = play.Link(lambda b: (pc.stdin.write(b), pc.stdin.flush()), pc.stdout.readline)
pc_link.recv()                                # RE
log_pc = run_games(pc_link, n)
pc.stdin.close()

moves = sum(1 for s in log_emu if s.startswith("< MO"))
print(f"picoemu: {n} 局、Pico 2 の手 {moves}、すべて合法 ({time.time() - t0:.0f} s)  {xb}")
print("PASS: PC の記録と同じ" if log_emu == log_pc else "FAIL: PC の記録と違う")
sys.exit(0 if log_emu == log_pc else 1)
