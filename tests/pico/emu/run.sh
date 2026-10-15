#!/bin/sh
# 層 D: picoemu (wb-picoemu) で out/pico-uf2 の .uf2 を動かして突き合わせる。前提: npm run pico:uf2。
# イメージが無ければ作る。
set -eu
cd "$(dirname "$0")/../../.."
docker image inspect wb-picoemu >/dev/null 2>&1 || docker build -q -f tests/pico/emu/Dockerfile.picoemu -t wb-picoemu .
docker run --rm -v "$PWD":/work -w /work wb-picoemu python3 -I tests/pico/emu/check.py
