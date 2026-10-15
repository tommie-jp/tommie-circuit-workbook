#!/bin/sh
# 本文の C プログラムを wb-pico-sdk (Pico SDK 2.2.0) で .uf2 にする。出力は out/pico-uf2/。
# 前提: npm run pico:extract 済み。Docker の wb-pico-sdk は 06-fpga/00-tools/02 で作る。
set -eu
cd "$(dirname "$0")/../../.."
rm -rf out/pico-uf2 && mkdir -p out/pico-uf2
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/work -w /work wb-pico-sdk bash -c '
  cp /opt/pico-sdk/external/pico_sdk_import.cmake out/pico-uf2/ &&
  cp tests/pico/uf2/CMakeLists.txt out/pico-uf2/ &&
  cmake -S out/pico-uf2 -B out/pico-uf2/build -DPICO_BOARD=pico2 -DPICO_PROGRAMS_DIR=/work/out/pico >/dev/null &&
  cmake --build out/pico-uf2/build -j8 2>&1 | grep -E "warning|error|Error" || true
  ls out/pico-uf2/build/*.uf2'
