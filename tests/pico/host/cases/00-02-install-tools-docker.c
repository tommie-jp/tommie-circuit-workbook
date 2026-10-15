// program: 06-fpga/00-tools/02-install-tools-docker-1.c
// FPGA 冊 0-2: 道具の動作確認の L チカ。GP15 を 500 ms ごとに反転する。
#include "pico/stdlib.h"
int main(void) {
    mock_reset(0);
    mock_run(2200000);
    mock_check(M.dir_out[15], "GP15 は出力");
    mock_check(M.nev == 5, "2.2 s で 5 回反転: %u", M.nev);
    for (uint i = 1; i < M.nev; i++) mock_check(M.ev[i].t_us - M.ev[i - 1].t_us == 500000, "500 ms ごと");
    return mock_report();
}
