#!/bin/bash
# soft-fpga の scripts/build-wasm-91.sh。build-wasm-02.sh を写し、例の場所・obj_dir・Verilog・出す関数を替えた
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/.."
EXAMPLE="$ROOT/examples/91-pong"
OBJ_DIR="$ROOT/obj_dir_91"
source "$SCRIPT_DIR/_build-wasm-common.sh"
wasm_sync_verilated_cpp if-missing
wasm_require_emsdk

verilator --cc "$EXAMPLE/verilog/pong.v" --Mdir "$OBJ_DIR"

COMMON_FLAGS="-O2 -std=c++17 -DVL_IGNORE_UNKNOWN_ARCH -I$VERILATOR_ROOT/include -I$OBJ_DIR"
wasm_compile_verilated_cpp

# shellcheck disable=SC2086
em++ $COMMON_FLAGS \
    "$OBJ_DIR"/V*.cpp \
    "$OBJ_DIR/verilated.wasm.o" \
    "$EXAMPLE/cxx/harness.cpp" \
    -s EXPORTED_FUNCTIONS="[\"_sim_init\",\"_set_keys\",\"_run_frame\",\"_get_fb\",\"_get_score\",\"_get_frames\"]" \
    -s EXPORTED_RUNTIME_METHODS='["HEAPU8"]' \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXIT_RUNTIME=0 \
    -o "$EXAMPLE/web/sim.js"
