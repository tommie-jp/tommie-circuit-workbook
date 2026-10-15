// io_reg.v を Pico 2 で回す。入力は DIP スイッチ、出力は LED
#include "pico/stdlib.h"
#include "Vio_reg.h"

// Verilog のポートと GPIO の対応 (表1)。添字がビットの番号
static const uint PIN_SW[2]  = {17, 16};   // sw[0] = GP17 (SW1)、sw[1] = GP16 (SW2)
static const uint PIN_LED[2] = {14, 15};   // led[0] = GP14 (D1)、led[1] = GP15 (D2)

// 1. 読む: スイッチを ON にすると L (内蔵プルアップ)。反転して 1 にする
static uint8_t read_sw() {
    uint8_t v = 0;
    for (int i = 0; i < 2; i++)
        if (!gpio_get(PIN_SW[i])) v |= 1u << i;
    return v;
}

// 3. 書く: 1 で H (LED が点く)
static void write_led(uint8_t v) {
    for (int i = 0; i < 2; i++)
        gpio_put(PIN_LED[i], (v >> i) & 1);
}

// 2. eval: 立ち下がりと立ち上がりで 2 回。これで 1 クロック
static void tick(Vio_reg &top) {
    top.clk = 0; top.eval();
    top.clk = 1; top.eval();
}

static void setpin(unsigned p,int v){ if(v) g_gpio|=1u<<p; else g_gpio&=~(1u<<p); }
static int getpin(unsigned p){ return (g_gpio>>p)&1; }
int main() {
    for (int i = 0; i < 2; i++) {
        gpio_init(PIN_SW[i]);
        gpio_set_dir(PIN_SW[i], GPIO_IN);
        gpio_pull_up(PIN_SW[i]);
        gpio_init(PIN_LED[i]);
        gpio_set_dir(PIN_LED[i], GPIO_OUT);
    }

    VerilatedContext ctx;
    Vio_reg top{&ctx};

    top.rst = 1;                 // リセットを 2 クロック掛ける
    tick(top);
    tick(top);
    top.rst = 0;

    const int tbl[6][2]={{1,1},{0,1},{0,1},{1,0},{0,0},{1,1}};
    for (int loop=1; loop<=6; loop++) {
        setpin(17,tbl[loop-1][0]); setpin(16,tbl[loop-1][1]);
        top.sw = read_sw();      // 1. 読む
        tick(top);               // 2. eval
        write_led(top.led);      // 3. 書く
        printf("loop %d: GP17=%d GP16=%d -> GP14=%d GP15=%d\n",loop,getpin(17),getpin(16),getpin(14),getpin(15));
    }
}
