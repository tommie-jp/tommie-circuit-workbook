#include <memory>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vcounter4.h"
int main(int argc, char** argv) {
    const std::unique_ptr<VerilatedContext> ctx{new VerilatedContext};
    ctx->commandArgs(argc, argv);
    ctx->traceEverOn(true);
    const std::unique_ptr<Vcounter4> top{new Vcounter4{ctx.get()}};
    VerilatedVcdC tfp;
    top->trace(&tfp, 99);
    tfp.open("counter4.vcd");
    top->clk = 0;
    top->rst_n = 0;
    for (int half = 0; half <= 16; half++) {
        if (half == 4) top->rst_n = 1;
        if (half > 0) top->clk = !top->clk;
        top->eval();
        tfp.dump(ctx->time());
        ctx->timeInc(1);
    }
    tfp.close();
    return 0;
}
