#!/usr/bin/env python3
"""12-2 の .uf2 を picoemu (RP2350 のエミュレータ) に載せ、UART0 を TCP につないで play.py と対局させる。
同じ乱数の相手と、PC で作った主ループ (pc_exe) とも同じ局数を打ち、記録が同じかを比べる。
UART1 (GP4) も TCP につなぎ、受けた行の写しが送った字と同じかを見る。
GP2 (印) は見ない。picoemu は走り切って終わるときにしか -gpio-trace の VCD を閉じず、止めると書きかけで切れる (層 A が見る)。
picoemu は USB の CDC を外に出さないので、PC とは UART0 (Debug Probe の道) で話す。stdio は USB と同じ。

    python3 emu.py reversi122.uf2 ./reversi_c 10       # wb-picoemu のコンテナの中で
"""
import importlib.util
import pathlib
import random
import socket
import subprocess
import sys
import threading
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


def connect(port):
    for _ in range(100):
        try:
            s = socket.create_connection(("127.0.0.1", port))
            s.settimeout(60)
            return s
        except OSError:
            time.sleep(0.1)
    raise OSError(f"picoemu の {port} 番につながらない")


uf2, pc_exe, n = sys.argv[1], sys.argv[2], int(sys.argv[3])
emu = subprocess.Popen(["picoemu", uf2, "-arch", "m33", "-max-steps", "100000000000",
                        "-net-uart0", "5555", "-net-uart1", "5556"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
s0 = connect(5555)
s1 = connect(5556)
copy = bytearray()                            # UART1 の写し
threading.Thread(target=lambda: [copy.extend(b) for b in iter(lambda: s1.recv(4096), b"")], daemon=True).start()
sent = bytearray()                            # UART0 に送った字
link = play.Link(lambda b: (sent.extend(b), s0.sendall(b)), s0.makefile("rb").readline)
link.send("PI")
while link.recv() != "+PI":                   # RE は接続より前に出て、届かないこともある
    pass
t0 = time.time()
log_emu = run_games(link, n)
link.send("XB")
xb = link.recv()
time.sleep(1)                                 # 写しの残りが届くのを待つ
emu.kill()
emu.wait()

pc = subprocess.Popen([pc_exe], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
pc_link = play.Link(lambda b: (pc.stdin.write(b), pc.stdin.flush()), pc.stdout.readline)
pc_link.recv()                                # RE
log_pc = run_games(pc_link, n)
pc.stdin.close()

moves = sum(1 for s in log_emu if s.startswith("< MO"))
ok_log, ok_copy = log_emu == log_pc, bytes(copy) == bytes(sent)
print(f"picoemu: {n} 局、Pico 2 の手 {moves}、すべて合法 ({time.time() - t0:.0f} s)  {xb}")
print(("ok  " if ok_log else "NG  ") + "PC の記録と同じ")
print(("ok  " if ok_copy else "NG  ") + f"UART1 の写しが送った字と同じ ({len(copy)} / {len(sent)} 字)")
ok = ok_log and ok_copy
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
