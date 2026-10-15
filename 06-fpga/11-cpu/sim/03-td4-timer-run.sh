#!/bin/bash
# 11-3 の試験を組んで回す。
#  1. 03-td4-timer.v を lint し、Verilator でクロックの数を数える (03-td4-timer-tb.cpp)
#  2. 本文の td4_113.cpp と 5-5 の board.h を Markdown から取り出し、替え玉の GPIO とタイマで回す (03-td4-timer-pc.cpp)
# 使い方: bash 03-td4-timer-run.sh   (Verilator 5.x・g++・python3 が要る)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
CH5="$HERE/../../05-soft-fpga-pico"
B="${TMPDIR:-/tmp}/td4-11-3"
rm -rf "$B"; mkdir -p "$B/lint"

# 5-8 の TD4.v と ROM の 16 行のほかは同じか
if diff <(grep -v "rom\[4'b" "$CH5/sim/08-td4.v") <(grep -v "rom\[4'b" "$HERE/03-td4-timer.v" | sed 1d) >/dev/null; then
  echo "PASS ROM の 16 行のほかは 5-8 の TD4.v と同じ"
else
  echo "FAIL 5-8 の TD4.v と ROM のほかが違う"; exit 1
fi

# 1. lint (ファイル名をモジュール名にそろえて) と数える試験
cp "$HERE/03-td4-timer.v" "$B/lint/TD4.v"
verilator --lint-only -Wall "$B/lint/TD4.v" && echo "PASS lint (-Wall) 警告 0 件"
verilator --cc --exe --build -Wall --prefix VTD4 --Mdir "$B/count" "$B/lint/TD4.v" "$HERE/03-td4-timer-tb.cpp" -o tb >/dev/null
"$B/count/tb"

# 2. 本文のプログラムを PC で回す
extract() {  # extract <md> <見出しの行> : その行のあとの最初のコードブロックを出す
  python3 -I - "$1" "$2" <<'PY'
import sys
lines = open(sys.argv[1], encoding='utf-8').read().split('\n')
i = lines.index(sys.argv[2])
while not lines[i].startswith('```'): i += 1
j = i + 1
while not lines[j].startswith('```'): j += 1
print('\n'.join(lines[i + 1:j]))
PY
}
extract "$CH5/05-clock-measure.md" '`board.h`:' > "$B/board.h"
extract "$HERE/../03-td4-timer.md" '`td4_113.cpp`:' > "$B/td4_113.cpp"
sed -e 's/while (true)/while (g_run())/' -e 's/int main()/void target_main()/' "$B/td4_113.cpp" > "$B/td4_113_pc.cpp"
verilator --cc --prefix VTD4 --Mdir "$B/pc" "$B/lint/TD4.v" >/dev/null
make -s -C "$B/pc" -f VTD4.mk VTD4__ALL.a
VR="$(verilator --getenv VERILATOR_ROOT)"
g++ -std=c++17 -O1 -I"$B" -I"$B/pc" -I"$CH5/sim/pcstub" -I"$VR/include" -I"$VR/include/vltstd" \
    "$HERE/03-td4-timer-pc.cpp" "$CH5/sim/pcstub/defs.cpp" "$B/pc/VTD4__ALL.a" \
    "$VR/include/verilated.cpp" "$VR/include/verilated_threads.cpp" -o "$B/pc-tb" -pthread
"$B/pc-tb"
