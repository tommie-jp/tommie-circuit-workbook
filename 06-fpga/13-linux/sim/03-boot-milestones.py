#!/usr/bin/env python3
"""13-3: 起動の記録から区切りを抜き、CSV にする。

使い方:
    make linux-sd < /dev/null 2>&1 | python3 03-boot-milestones.py --stamp > boot.log   # 行の頭に実時間を付ける
    python3 03-boot-milestones.py boot.log > 03-boot-milestones.csv                     # 区切りを抜く

記録の行の頭の `[  秒]` が実時間 (この道具が付ける)。カーネルの行の `[  秒]` はカーネルの時計。
`@@PC <クロック> <番地> retired <数>` の行 (+pcmon) から、区切りのクロック数を直線で補う。
"""
import re
import sys
import time

MILESTONES = [
    ("load", r"^load: .*Image", "模型が走り始める (像を主記憶へ書いた)"),
    ("opensbi", r"^OpenSBI v", "OpenSBI の名乗り"),
    ("kernel", r"Booting Linux on hartid", "カーネルの最初の行"),
    ("clock", r"sched_clock:", "カーネルの時計が動き出す"),
    ("plic", r"riscv-plic:", "PLIC (割り込みコントローラ) を見つける"),
    ("console", r"printk: legacy console \[liteuart0\] enabled", "本番のコンソールに替わる"),
    ("mmc", r"litex-mmc .*initialized", "SD カードのドライバ"),
    ("card", r"mmcblk0: mmc0", "SD カードを見つける"),
    ("mount", r"EXT4-fs \(mmcblk0p2\): mounted", "ext4 を mount"),
    ("init", r"Run /sbin/init as init process", "init を起こす"),
    ("shell", r"^BusyBox v.*built-in shell", "シェルの名乗り"),
    ("prompt", r"LINUX RUN ENDED", "プロンプトで止まる"),
]
STAMP = re.compile(r"^\[\s*([0-9.]+)\] (.*)$")
KTIME = re.compile(r"^\[\s*([0-9.]+)\] ")
PCMON = re.compile(r"^@@PC (\d+) ([0-9a-f]+) retired (\d+)")
ENDED = re.compile(r"^\s*(\d+) cycles, (\d+) retired, (\d+) traps")


def stamp():
    t0 = time.monotonic()
    for line in sys.stdin:
        sys.stdout.write("[%8.1f] %s" % (time.monotonic() - t0, line))
        sys.stdout.flush()


def cycle_at(marks, sec):
    """実時間 sec のクロック数を、前後の @@PC の行から直線で補う。"""
    before = [m for m in marks if m[0] <= sec]
    after = [m for m in marks if m[0] > sec]
    if not before or not after:
        return None
    (t0, c0), (t1, c1) = before[-1], after[0]
    return round(c0 + (c1 - c0) * (sec - t0) / (t1 - t0))


def main(path):
    rows = []
    for raw in open(path, encoding="utf-8", errors="replace"):
        m = STAMP.match(raw.rstrip("\n"))
        if m:
            rows.append((float(m.group(1)), m.group(2)))
    marks = []
    final = None
    for sec, text in rows:
        m = PCMON.match(text)
        if m:
            marks.append((sec, int(m.group(1))))
        m = ENDED.match(text)
        if m:
            final = (sec, int(m.group(1)), int(m.group(2)), int(m.group(3)))
    if final:
        marks.append((final[0] + 1e-6, final[1]))
    print("key,real_s,kernel_s,cycles,cycles_kind,what")
    for key, pattern, what in MILESTONES:
        rx = re.compile(pattern)
        hit = next(((s, t) for s, t in rows if rx.search(KTIME.sub("", t)) or rx.search(t)), None)
        if hit is None:
            continue
        sec, text = hit
        k = KTIME.match(text)
        kernel = k.group(1) if k else ""
        if key == "prompt" and final:
            cycles, kind = final[1], "exact"
        elif key == "load":
            cycles, kind = 0, "exact"
        else:
            cycles, kind = cycle_at(marks, sec), "interpolated"
        print("%s,%.1f,%s,%s,%s,%s" % (key, sec, kernel, cycles, kind, what))


if __name__ == "__main__":
    if len(sys.argv) == 2 and sys.argv[1] == "--stamp":
        stamp()
    elif len(sys.argv) == 2:
        main(sys.argv[1])
    else:
        sys.exit(__doc__)
