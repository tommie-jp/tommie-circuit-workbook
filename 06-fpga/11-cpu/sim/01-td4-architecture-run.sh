#!/bin/bash
# 11-1 の試験を組んで回す。td4_core (この題) と TD4 (5-8) を別々に C++ にし、1 本の試験台に link する。
# 使い方: bash 01-td4-architecture-run.sh   (Verilator 5.x と g++ が要る)
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
B="${TMPDIR:-/tmp}/td4-11-1"
rm -rf "$B"; mkdir -p "$B"
verilator --lint-only -Wall --top-module counter  "$HERE/01-td4-architecture.v"
verilator --lint-only -Wall --top-module td4_core "$HERE/01-td4-architecture.v"
verilator --cc --top-module td4_core --prefix Vtd4_core --Mdir "$B/core" "$HERE/01-td4-architecture.v"
verilator --cc --prefix VTD4 --Mdir "$B/ref" "$HERE/../../05-soft-fpga-pico/sim/08-td4.v"
make -s -C "$B/core" -f Vtd4_core.mk Vtd4_core__ALL.a
make -s -C "$B/ref"  -f VTD4.mk VTD4__ALL.a
VR="$(verilator --getenv VERILATOR_ROOT)"
g++ -std=c++17 -O1 -I"$B/core" -I"$B/ref" -I"$VR/include" -I"$VR/include/vltstd" \
    "$HERE/01-td4-architecture-tb.cpp" "$B/core/Vtd4_core__ALL.a" "$B/ref/VTD4__ALL.a" \
    "$VR/include/verilated.cpp" "$VR/include/verilated_threads.cpp" -o "$B/tb" -pthread
"$B/tb"

# 画面の側: soft-fpga の 01-counter の harness.cpp と link する (SOFT_FPGA に soft-fpga の写しの場所)
SF="${SOFT_FPGA:-$HOME/36-soft-FPGA}"
if [ -f "$SF/examples/01-counter/cxx/harness.cpp" ]; then
  verilator --cc --Mdir "$B/web" "$HERE/01-td4-architecture.v" --top-module counter --prefix Vcounter
  make -s -C "$B/web" -f Vcounter.mk Vcounter__ALL.a
  g++ -std=c++17 -O1 -I"$B/web" -I"$VR/include" -I"$VR/include/vltstd" \
      "$HERE/01-td4-architecture-harness-tb.cpp" "$SF/examples/01-counter/cxx/harness.cpp" "$B/web/Vcounter__ALL.a" \
      "$VR/include/verilated.cpp" "$VR/include/verilated_threads.cpp" -o "$B/web-tb" -pthread
  "$B/web-tb"
else
  echo "SKIP 画面の側 (soft-fpga の写しが無い: $SF)"
fi
