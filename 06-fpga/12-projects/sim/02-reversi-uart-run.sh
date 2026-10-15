#!/bin/sh
# 12-2 の PC の試験。主ループを PC 用の替え玉 (02-reversi-uart-pcstub) で 2 通りにビルドし、test.py で対局させる。
#   reversi_c    : SOFT_FPGA なし (C の関数で計算)
#   reversi_fpga : SOFT_FPGA あり (12-1 の回路を Verilator で C++ にした物で計算)
# 使い方: sh 02-reversi-uart-run.sh [作業用のフォルダ]
set -eu
H=$(cd "$(dirname "$0")" && pwd)
W=${1:-$(mktemp -d)}
mkdir -p "$W" && cd "$W"
VI=$(verilator --getenv VERILATOR_ROOT)/include
cp "$H/01-reversi-accel.v" reversi_accel.v
cp "$H/01-reversi-accel-legal.v" legal_bb.v
cp "$H/01-reversi-accel-flip.v" flip_calc.v
verilator --cc -Wall --no-timing reversi_accel.v legal_bb.v flip_calc.v --Mdir v_accel >/dev/null
make -s -C v_accel -f Vreversi_accel.mk >/dev/null
gcc -std=gnu11 -O2 -Wall -Wextra -I"$H/02-reversi-uart-pcstub" -o reversi_c "$H/02-reversi-uart.c"
gcc -std=gnu11 -O2 -Wall -Wextra -DSOFT_FPGA -I"$H/02-reversi-uart-pcstub" -c -o main.o "$H/02-reversi-uart.c"
g++ -O2 -std=c++17 -Wall -Iv_accel -isystem "$VI" -isystem "$VI/vltstd" -c -o accel.o "$H/02-reversi-uart-accel.cpp"
g++ -O2 -std=c++17 -isystem "$VI" -Iv_accel -o reversi_fpga main.o accel.o v_accel/Vreversi_accel__ALL.a \
    "$VI/verilated.cpp" "$VI/verilated_threads.cpp" -pthread
python3 -I "$H/02-reversi-uart-test.py" ./reversi_fpga ./reversi_c
