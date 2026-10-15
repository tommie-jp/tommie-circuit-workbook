#!/bin/bash
# 11-2 の試験を組んで回す。02-td4-trace.v の counter を C++ にし、直した harness.cpp と試験台に link する。
# 使い方: SOFT_FPGA=<soft-fpga の写し> bash 02-td4-trace-run.sh   (Verilator 5.x と g++ が要る)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
SF="${SOFT_FPGA:-$HOME/36-soft-FPGA}"
B="${TMPDIR:-/tmp}/td4-11-2"
rm -rf "$B"; mkdir -p "$B"
# td4_core までが 11-1 と同じであることを確かめる (11-1 の 2〜117 行目 = 11-2 の 4〜119 行目)
if diff <(sed -n 2,117p "$HERE/01-td4-architecture.v") <(sed -n 4,119p "$HERE/02-td4-trace.v") >/dev/null; then
  echo "PASS td4_core までは 11-1 と同じ"
else
  echo "FAIL td4_core までが 11-1 と違う"; exit 1
fi
verilator --lint-only -Wall --top-module counter "$HERE/02-td4-trace.v"
verilator --cc --top-module counter --prefix Vcounter --Mdir "$B/web" "$HERE/02-td4-trace.v"
make -s -C "$B/web" -f Vcounter.mk Vcounter__ALL.a
VR="$(verilator --getenv VERILATOR_ROOT)"
g++ -std=c++17 -O1 -I"$B/web" -I"$VR/include" -I"$VR/include/vltstd" -I"$SF/examples/01-counter/cxx" \
    "$HERE/02-td4-trace-tb.cpp" "$HERE/02-td4-trace-harness.cpp" "$B/web/Vcounter__ALL.a" \
    "$VR/include/verilated.cpp" "$VR/include/verilated_threads.cpp" -o "$B/tb" -pthread
"$B/tb"
